#include "e127controller.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/packed_data_container.hpp>

using namespace godot;

const double SPHERE_COEFF = 4.0 / 3.0 * Math_PI;

// Connect methods defined here to Godot
void E127Controller::_bind_methods() {
    // I've left in the methods from the tutorial as reference
    //ClassDB::bind_method(D_METHOD("get_positions"), &GravityController::get_positions);
    //ClassDB::bind_method(D_METHOD("set_positions", "p_positions"), &GravityController::set_positions);
    //ADD_PROPERTY(PropertyInfo(Variant::PACKED_VECTOR3_ARRAY, "positions"), "set_positions", "get_positions");

    ClassDB::bind_method(D_METHOD("get_bodies"), &E127Controller::get_bodies);
    ClassDB::bind_method(D_METHOD("get_body", "id"), &E127Controller::get_body);
    ClassDB::bind_method(D_METHOD("add_body", "m", "r", "x", "y", "vx", "vy", "force_nonlinear", "use_linear", "negligible_mass"), &E127Controller::add_body, DEFVAL(0.0), DEFVAL(0.0), DEFVAL(false), DEFVAL(false), DEFVAL(false));
    ClassDB::bind_method(D_METHOD("set_body", "body_dict"), &E127Controller::set_body);

    ClassDB::bind_method(D_METHOD("step", "delta"), &E127Controller::naive_step);
    ClassDB::bind_method(D_METHOD("probe", "delta", "x", "y"), &E127Controller::naive_probe);
    
    // Getters & Setters
    ClassDB::bind_method(D_METHOD("get_mass_scale"), &E127Controller::get_mass_scale);
    ClassDB::bind_method(D_METHOD("set_mass_scale", "v"), &E127Controller::set_mass_scale);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "mass_scale"), "set_mass_scale", "get_mass_scale");

    ClassDB::bind_method(D_METHOD("get_distance_scale"), &E127Controller::get_distance_scale);
    ClassDB::bind_method(D_METHOD("set_distance_scale", "v"), &E127Controller::set_distance_scale);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "distance_scale"), "set_distance_scale", "get_distance_scale");

    ClassDB::bind_method(D_METHOD("get_bodies_in_rect", "rect"), &E127Controller::get_bodies_in_rect);
}


// Represents a body that is being simulated
struct E127Controller::body {
    uint16_t id; // 2 bytes
    bool sentinel; // 1 byte
    bool force_nonlinear; // 1 byte
    bool use_linear; // 1 byte
    bool negligible_mass; // 1 byte
    // Radius
    float r; // 4 bytes
    // Mass
    float m; // 4 bytes
    // Position
    double x; // 8 bytes
    double y; // 8 bytes
    // Velocity
    float vx; // 4 bytes
    float vy; // 4 bytes
    // 38 bytes total
};

struct E127Controller::collision {
    uint16_t id_a;
    uint16_t id_b;
    uint8_t type;
    double distance;
};

// Class init - Initialize variables here.
E127Controller::E127Controller() {
    // All simulated bodies, in order of initial id, including sentinels
    bodies = std::vector<body>();
    
    mass_scale = 1.0;
    distance_scale = 1.0;
    // Gravittional constant * mass scale / (distance scale squared)
    total_scale = 6.6734E-11;
}

// Class cleanup
E127Controller::~E127Controller() {
	// Cleanup! (I have no clue what's supposed to go here)
    // I'm sure it's not an issue
}

// Add a body to this node's simulation
void E127Controller::add_body(double m, double r, double x, double y, double vx, double vy, bool force, bool use, bool ignore) {
    // Setup body
    body b = body();
    b.m = m;
    b.r = r;
    b.x = x;
    b.y = y;
    b.vx = vx;
    b.vy = vy;
    b.force_nonlinear = force;
    b.use_linear = use;
    b.negligible_mass = ignore;
    // ID is how many items in the vector before this item is added
    b.id = bodies.size();
    bodies.emplace_back(b);
}

// Stop processing body of id
void E127Controller::disable_body(int id) {
    bodies[id].sentinel = true;
}

// Make a delta-second simulation step using the naive algorithm
void E127Controller::naive_step(double delta) {
    // Iterate over pairs of bodies
    std::vector<E127Controller::collision> collisions = std::vector<E127Controller::collision>();
    for (uint16_t i=0; i < bodies.size(); i++) {
        if (bodies[i].sentinel) {continue;}
        for (uint16_t j = i + 1; j < bodies.size(); j++) {
            if (bodies[j].sentinel) {continue;}
            // Calculate axial distances
            double dx = bodies[i].x - bodies[j].x;
            double dy = bodies[i].y - bodies[j].y;
            
            // Collision check
            double dr = bodies[i].r + bodies[j].r;
            double square_distance = dx*dx + dy*dy;

            // Do preliminary square check
            if (dx < dr && dy < dr && dx*dx) {
                double ratio = (bodies[i].m < bodies[j].m ? bodies[i].m / bodies[j].m : bodies[j].m / bodies[i].m);
                if (bodies[i].r < 10 || bodies[j].r < 10 || ratio < 0.001) {
                    if ((square_distance < pow(bodies[i].r - 0.5*bodies[j].r, 2.0) || square_distance < pow(bodies[j].r - 0.5*bodies[i].r, 2.0))) {
                        UtilityFunctions::print("type 1 collision detected");
                        collision c = collision();
                        c.id_a = i;
                        c.id_b = j;
                        c.type = 1;
                        collisions.emplace_back(c);
                    }
                } else {
                    if (square_distance < pow(bodies[i].r + bodies[j].r, 2.0)) {
                        UtilityFunctions::print("type 2 collision detected");
                        collision c = collision();
                        c.id_a = i;
                        c.id_b = j;
                        c.distance = sqrt(square_distance);
                        c.type = 2;
                        collisions.emplace_back(c);
                    }
                }
            }

            // Using the similar triangles present in the vector calculation
            double b1_axis_cf = 0.0;
            double b2_axis_cf = 0.0;
            if (bodies[i].force_nonlinear || bodies[j].force_nonlinear || (!bodies[i].use_linear && !bodies[j].use_linear)) {
                double axis_cf_denom = pow(dx*dx + dy*dy, -1.5);
                if (!bodies[j].negligible_mass) {
                    b1_axis_cf = delta * bodies[j].m * axis_cf_denom * total_scale;
                }
                if (!bodies[i].negligible_mass) {
                    b2_axis_cf = delta * bodies[i].m * axis_cf_denom * total_scale;
                }
            } 
            else if (bodies[i].use_linear && bodies[j].use_linear) {
                double axis_cf_denom = 1.0 / (dx*dx + dy*dy);
                if (!bodies[j].negligible_mass) {
                    b1_axis_cf = delta * bodies[j].m * axis_cf_denom * total_scale;
                }
                if (!bodies[i].negligible_mass) {
                    b2_axis_cf = delta * bodies[i].m * axis_cf_denom * total_scale;
                }
            } 
            else {
                if (!bodies[j].negligible_mass) {
                    b1_axis_cf = delta * bodies[j].m * (bodies[j].use_linear ? 1.0 / (dx*dx + dy*dy) : pow(dx*dx + dy*dy, -1.5)) * total_scale;
                }
                if (!bodies[i].negligible_mass) {
                    b2_axis_cf = delta * bodies[i].m * (bodies[i].use_linear ? 1.0 / (dx*dx + dy*dy) : pow(dx*dx + dy*dy, -1.5)) * total_scale;
                }
            }
            // Apply acceleration for body 2
            bodies[j].vx += b2_axis_cf * dx;
            bodies[j].vy += b2_axis_cf * dy;
            // Apply acceleration for body1. distances are 180 degrees in the wrong direction, 
            //so resultant acceleration is subtracted.
            bodies[i].vx -= b1_axis_cf * dx;
            bodies[i].vy -= b1_axis_cf * dy;
        }
    }
    while (collisions.size() > 0) {
        collision& col = collisions.back();
        collisions.pop_back();
        body& b1 = bodies[col.id_a];
        body& b2 = bodies[col.id_b];
        if (col.type == 1) {
            UtilityFunctions::print("type 1 collision processing");
            // Total mass.
            double mass = b1.m + b2.m;
            double b1_ratio = b1.m / mass;
            double b2_ratio = b2.m / mass;
            b1.m = mass;
            // Center of Mass
            b1.x = b1.x * b1_ratio + b2.x * b2_ratio;
            b1.y = b1.y * b1_ratio + b2.y * b2_ratio;
            // Momentum
            b1.vx = b1.vx * b1_ratio + b2.vx * b2_ratio;
            b1.vy = b1.vy * b1_ratio + b2.vy * b2_ratio;
            // Radius
            b1.r = pow(pow(b1.r, 3) + pow(b2.r, 3), 1.0 / 3.0);
            b1.negligible_mass = false;
            // Make b2 sentinel
            b2.sentinel = true;
        } else if (col.type == 2) {
            body& high = (b1.m > b2.m ? b1 : b2);
            body& low = (b1.m > b2.m ? b2 : b1);
            UtilityFunctions::print("type 2 collision processing", b1.id, " & ", b2.id, ": ", low.id, "<", high.id);
            UtilityFunctions::print("high{r=", high.r, " m=", high.m, ")}");
            UtilityFunctions::print("low{r=", low.r, " m=", low.m, ")}");
            // vector: high towards low
            double dx = low.x - high.x;
            double dy = low.y - high.y;
            dx /= col.distance;
            dy /= col.distance;

            if (high.y == low.y) {
                low.y += 0.00001;
            }

            // margin of 1 px 
            double overlap = (high.r + low.r + 1 - col.distance) / 2.0;
            double ratio = high.m/(high.m+low.m);

            double low_volume = SPHERE_COEFF * (pow(low.r, 3.0) - pow(low.r - overlap * ratio, 3.0));

            double low_density = low.m / (SPHERE_COEFF * pow(low.r, 3.0));
            double low_displaced_mass = low_density * low_volume;
            double low_displaced_energy = low_displaced_mass * (low.vx*low.vx + low.vy*low.vy);

            double high_volume = SPHERE_COEFF * (pow(high.r, 3.0) - pow(high.r - overlap * (1-ratio), 3.0));

            double high_density = high.m / (SPHERE_COEFF * pow(high.r, 3.0));
            double high_displaced_mass = high_density * high_volume;
            double high_displaced_energy = high_displaced_mass * (high.vx*high.vx + high.vy*high.vy);

            double displaced_mass = low_displaced_mass + high_displaced_mass;
            double density = displaced_mass / (high_volume + low_volume);
            double displaced_energy = low_displaced_energy + high_displaced_energy;
            
            double body_r = pow(3*displaced_mass/(2*Math_TAU*density), 1.0/3.0);

            // velocity of low relative to high.
            double rel_vx = high.vx - low.vx;
            double rel_vy = high.vy - low.vy;
            // get positions of intersections of the circles body_r bigger than the two current bodies
            double c = (high.x*high.x+high.y*high.y+pow(low.r+body_r,2.0)-(low.x*low.x+low.y*low.y+pow(high.r+body_r,2.0)))/(2*(high.y-low.y));
            double m = (low.x-high.x)/(high.y-low.y);
            double A = 1+m*m;
            double B = 2*(m*(c-high.y)-high.x);
            double sqrt_val = sqrt(B*B-4*A*(high.x*high.x+pow(c-high.y,2.0)-pow(high.r+body_r,2.0)));
            if (sqrt_val != sqrt_val) {
                continue;
            }
            // tadaaa. magic
            if (dy < 0) {
                sqrt_val = -sqrt_val;
            }
            double X1 = (-B+sqrt_val)/(2*A);
            double Y1 = m*X1+c;
            double X2 = (-B-sqrt_val)/(2*A);
            double Y2 = m*X2+c;
            double midp_x = (X1+X2)/2.0;
            double midp_y = (Y1+Y2)/2.0;
            UtilityFunctions::print("p1=(",X1, ", ", Y1, ") p2=(", X2, ", ", Y2, ") mp=(", midp_x, ", ", midp_y, ")");
            // Project rel_v onto d
            double normalised_perpendicular_projection = Math_SQRT2 * (dy*rel_vx-dx*rel_vy)/sqrt(rel_vx*rel_vx+rel_vy*rel_vy);
            UtilityFunctions::print("low_volume: ", low_volume, "\nlow_density: ", low_density, "\nlow_mass: ", low_displaced_mass, 
                                    "\nhigh_volume: ", high_volume, "\nhigh_density: ", high_density, "\nhigh_mass: ", high_displaced_mass,
                                    "\nlow_vx: ", low.vx, " low_vy: ", low.vy, " sqdv: ", low.vx*low.vx+low.vy*low.vy);
            // Add the body
            // TODO - choose P1 or P2.
            bool do_p2 = static_cast <float> (rand())/static_cast <float> (RAND_MAX)<1-normalised_perpendicular_projection;
            double& point_x = (do_p2 ? X2 : X1);
            double& point_y = (do_p2 ? Y2 : Y1);
            double body_vy = point_y - midp_y;
            double body_vx = point_x - midp_x;
            UtilityFunctions::print(body_vx, ", ", body_vy, " > ", sqrt(body_vx*body_vx+body_vy*body_vy));
            double v_factor = 2*sqrt(displaced_energy / (displaced_mass*(body_vy*body_vy + body_vx*body_vx)));
            body_vx *= v_factor;
            body_vy *= v_factor;
            
            body b = body();
            b.x = point_x;
            b.y = point_y;
            b.vx = body_vx;
            b.vy = body_vx;
            b.m = displaced_mass;
            b.r = body_r;
            b.negligible_mass = true;
            b.id = bodies.size();
            UtilityFunctions::print("body{(",b.x, ", ", b.y, ") (", b.vx, ", ", b.vy, ") m=", b.m, " r=", b.r, "}");
            bodies.push_back(b);
            // move bodies away from each other and reduce radii
            UtilityFunctions::print("overlap ",overlap, " ", ratio, " ", col.distance);
            UtilityFunctions::print("radii ",low.r, " ", high.r);
            
            low.m -= low_displaced_mass;
            high.m -= high_displaced_mass;

            low.r -= overlap * ratio;
            high.r -= overlap * (1-ratio);

            low.x += dx * overlap * ratio;
            low.y += dy * overlap * (1-ratio);
            high.x -= dx * overlap * ratio;
            high.y -= dy * overlap * (1-ratio);
            UtilityFunctions::print("radii after ", low.r, " ", high.r);
        }
    }
    // Update positions.
    for (int i=0; i < bodies.size(); i++) {
        bodies[i].x += bodies[i].vx * delta;
        bodies[i].y += bodies[i].vy * delta;
    }
}

// Get the acceleration at a point x,y,z=0 over time delta using the naive algorithm
Dictionary E127Controller::naive_probe(double delta, double x, double y) {
    Dictionary out = Dictionary();
    double ax = 0.0;
    double ay = 0.0;
    for (uint16_t i=0;i<bodies.size();i++) {
        // Skip sentinel
        if (bodies[i].sentinel) {continue;}
        if (bodies[i].negligible_mass) {continue;}
        // Calculate axial distances
        double dx = bodies[i].x - x;
        double dy = bodies[i].y - y;
        
        // Collision check
        // Do square/cube check then do square distance check
        if (dx < bodies[i].r && dy < bodies[i].r && dx*dx + dy*dy < bodies[i].r*bodies[i].r) {
            out.set("collision_id", bodies[i].id);
        }

        // Using the similar triangles present in the vector calculation
        double axis_cf = delta * bodies[i].m * pow(dx*dx + dy*dy, -1.5) * total_scale;
        // Apply acceleration
        ax += axis_cf * dx;
        ay += axis_cf * dy;
    }
    out.set("ax", ax);
    out.set("ay", ay);
    return out;
}

// Get the acceleration at a point x,y,z=0 over time delta using the naive algorithm with 1/r attraction
Dictionary E127Controller::linear_naive_probe(double delta, double x, double y) {
    Dictionary out = Dictionary();
    double ax = 0.0;
    double ay = 0.0;
    for (uint16_t i=0;i<bodies.size();i++) {
        // Skip sentinel
        if (bodies[i].sentinel) {continue;}
        if (bodies[i].negligible_mass) {continue;}
        // Calculate axial distances
        double dx = bodies[i].x - x;
        double dy = bodies[i].y - y;
        
        // Collision check
        // Do square/cube check then do square distance check
        if (dx < bodies[i].r && dy < bodies[i].r && dx*dx + dy*dy < bodies[i].r*bodies[i].r) {
            out.set("collision_id", bodies[i].id);
        }

        // Using the similar triangles present in the vector calculation
        double axis_cf;
        if (bodies[i].force_nonlinear) {
            axis_cf = delta * bodies[i].m * pow(dx*dx + dy*dy, -1.5) * total_scale;
        } else {
            axis_cf = delta * bodies[i].m / (dx*dx + dy*dy) * total_scale;
        }
        // Apply acceleration
        ax += axis_cf * dx;
        ay += axis_cf * dy;
    }
    out.set("ax", ax);
    out.set("ay", ay);
    return out;
}

// Get all sentinel ids.
TypedArray<int> E127Controller::get_sentinel_ids() {
    TypedArray<int> out = TypedArray<int>();
    for (uint16_t i = 0; i<bodies.size();i++) {
        if (bodies[i].sentinel) {
            out.push_back(i);
        }
    }
    return out;
}

// Get all bodies that overlap with passed rect
TypedArray<Dictionary> E127Controller::get_bodies_in_rect(Rect2 rect) {
    TypedArray<Dictionary> out = TypedArray<Dictionary>();
    Vector2 rect_mid = rect.size / 2.0;
    for (auto& b : bodies) {
        if (b.sentinel) { continue; }
        float cx = abs(b.x - rect.position.x - rect_mid.x);
        float cy = abs(b.y - rect.position.y - rect_mid.y);
        // Too far away
        if (cx > rect_mid.x + b.r) { continue; }
        if (cy > rect_mid.y + b.r) { continue; }
        // 
        if (cx > rect_mid.x && cy > rect_mid.y) {
            if (pow(cx - rect_mid.x, 2) + pow(cy - rect_mid.y, 2) > b.r*b.r) { continue; }
        }
        Dictionary v = Dictionary();
        v.set("id", b.id);
        v.set("r", b.r);
        v.set("m", b.m);
        v.set("x", b.x);
        v.set("y", b.y);
        v.set("vx", b.vx);
        v.set("vy", b.vy);
        out.push_back(v);
    }
    return out;
}


// Getters and setters for Godot

double E127Controller::get_mass_scale() const {
    return mass_scale;
}

// Update mass_scale and total_scale
void E127Controller::set_mass_scale(const double _mass_scale) {
    mass_scale = _mass_scale;
    total_scale = 6.6734E-11 * _mass_scale / (distance_scale * distance_scale);
}

double E127Controller::get_distance_scale() const {
    return distance_scale;
}

// Update distance_scale and total_scale
void E127Controller::set_distance_scale(const double _distance_scale) {
    distance_scale = _distance_scale;
    total_scale = 6.6734E-11 * mass_scale / (_distance_scale * _distance_scale);
}

// Get all non-sentinel bodies. This is a slow function
TypedArray<Dictionary> E127Controller::get_bodies() const {
    // Convert from vector<body> to TypedArray<Dictionary> so that godot can understand it
    TypedArray<Dictionary> out = TypedArray<Dictionary>();
    for (auto& b : bodies) {
        if (b.sentinel) {continue;}
        Dictionary v = Dictionary();
        v.set("id", b.id);
        v.set("r", b.r);
        v.set("m", b.m);
        v.set("x", b.x);
        v.set("y", b.y);
        v.set("vx", b.vx);
        v.set("vy", b.vy);
        out.push_back(v);
    }
    return out;
}

// Get specific body
Dictionary E127Controller::get_body(const int id) const {
    // Convert body to Dictionary so that godot can see it
    Dictionary out = Dictionary();
    out.set("r", bodies[id].r);
    out.set("m", bodies[id].m);
    out.set("x", bodies[id].x);
    out.set("y", bodies[id].y);
    out.set("vx", bodies[id].vx);
    out.set("vy", bodies[id].vy);
    out.set("id", bodies[id].id);
    return out;
}

void E127Controller::set_body(const Dictionary _new) {
    // construct struct
    body b = body();
    b.r = _new["r"];
    b.m = _new["m"];
    b.x = _new["x"];
    b.y = _new["y"];
    b.vx = _new["vx"];
    b.vy = _new["vy"];
    b.id = _new["id"];

    bodies[b.id] = b;
}
