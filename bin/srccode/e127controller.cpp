#include "e127controller.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/packed_data_container.hpp>

using namespace godot;


// Connect methods defined here to Godot
void E127Controller::_bind_methods() {
    // I've left in the methods from the tutorial as reference
    //ClassDB::bind_method(D_METHOD("get_positions"), &GravityController::get_positions);
    //ClassDB::bind_method(D_METHOD("set_positions", "p_positions"), &GravityController::set_positions);
    //ADD_PROPERTY(PropertyInfo(Variant::PACKED_VECTOR3_ARRAY, "positions"), "set_positions", "get_positions");

    ClassDB::bind_method(D_METHOD("get_bodies"), &E127Controller::get_bodies);
    ClassDB::bind_method(D_METHOD("get_body", "id"), &E127Controller::get_body);
    ClassDB::bind_method(D_METHOD("add_body", "m", "r", "x", "y", "vx", "vy"), &E127Controller::add_body, DEFVAL(0.0), DEFVAL(0.0));
    ClassDB::bind_method(D_METHOD("set_body", "body_dict"), &E127Controller::set_body);

    ClassDB::bind_method(D_METHOD("naive_step", "delta"), &E127Controller::naive_step);
    ClassDB::bind_method(D_METHOD("naive_probe", "delta", "x", "y"), &E127Controller::naive_probe);

    ClassDB::bind_method(D_METHOD("build_tree"), &E127Controller::build_tree);
    ClassDB::bind_method(D_METHOD("barnes_hut_step", "delta", "theta"), &E127Controller::barnes_hut_step, DEFVAL(1.0));
    ClassDB::bind_method(D_METHOD("barnes_hut_probe", "delta", "x", "y", "theta", "r"), &E127Controller::barnes_hut_probe, DEFVAL(1.0), DEFVAL(0.0));
    
    // Getters & Setters
    ClassDB::bind_method(D_METHOD("get_mass_scale"), &E127Controller::get_mass_scale);
    ClassDB::bind_method(D_METHOD("set_mass_scale", "v"), &E127Controller::set_mass_scale);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "mass_scale"), "set_mass_scale", "get_mass_scale");

    ClassDB::bind_method(D_METHOD("get_distance_scale"), &E127Controller::get_distance_scale);
    ClassDB::bind_method(D_METHOD("set_distance_scale", "v"), &E127Controller::set_distance_scale);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "distance_scale"), "set_distance_scale", "get_distance_scale");

    ClassDB::bind_method(D_METHOD("disable_body"), &E127Controller::disable_body);

    ClassDB::bind_method(D_METHOD("get_sentinel_ids"), &E127Controller::get_sentinel_ids);
    
    ClassDB::bind_method(D_METHOD("get_bodies_in_rect", "rect"), &E127Controller::get_bodies_in_rect);

    ClassDB::bind_method(D_METHOD("get_live_body_count"), &E127Controller::get_live_body_count);

    ADD_SIGNAL(MethodInfo("body_collided", PropertyInfo(Variant::INT, "body_id"), PropertyInfo(Variant::INT, "new_id")));
}


// Represents a body that is being simulated
struct E127Controller::body {
    // ID
    int32_t id; // 4 bytes
    // Radius
    float r; // 4 bytes
    // Mass
    float m; // 4 bytes
    // Position
    double x; // 8 bytes
    double y; // 8 bytes
    // Velocity
    double vx; // 4 bytes
    double vy; // 4 bytes
    // 6*4 + 3*8 = 48 bytes total
};


// Represents a node in the quad- or oct- tree
struct E127Controller::tree_node {
    // Points to first child. 
    // Second child is first_child + 1
    // Eighth is first_child + 7
    // = 0 when it is empty.
    // = negative when it holds a body.
    int32_t first_child; // 4 bytes
    // Position of centre. These are single precision to make the tree_node in total to be exactly 64 bytes.
    double cx; // 4 bytes
    double cy; // 4 bytes
    // Radius. the cube ranges from (cx-d, cy-d, cz-d) to (cx+d, cy+d, cz+d)
    float d; // 4 bytes
    // Position of centre of mass
    double com_x; // 4 bytes
    double com_y; // 4 bytes
    // Mass
    float m; // 4 bytes
    // 7*4 = 28 bytes total
};


// Class init - Initialize variables here.
E127Controller::E127Controller() {
    // Either a quad or octree, for quick body calculation.
    tree = std::vector<E127Controller::tree_node>();
    // All simulated bodies, in order of initial id.
    // Also contains bodies with id -1.
    bodies = std::vector<body>();
    // Whether or not the tree is up to date.
    is_tree_valid = false;
    // If any bodies are added with a z or vz != 0, this is set to false.
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
void E127Controller::add_body(double m, double r, double x, double y, double vx, double vy) {
    // Setup body
    body b = body();
    b.m = m;
    b.r = r;
    b.x = x;
    b.y = y;
    b.vx = vx;
    b.vy = vy;
    // ID is how many items in the vector before this item is added
    b.id = bodies.size();
    bodies.emplace_back(b);

    is_tree_valid = false;
}


// Stop processing body of id
void E127Controller::disable_body(int id) {
    bodies[id].id = -1;
}


// Make a delta-second simulation step using the naive algorithm
void E127Controller::naive_step(double delta) {
    // Iterate over pairs of bodies
    std::vector<int32_t> collisions = std::vector<int32_t>();
    for (int32_t i=0; i < bodies.size(); i++) {
        if (bodies[i].id == -1) {continue;}
        for (int32_t j = i + 1; j < bodies.size(); j++) {
            if (bodies[j].id == -1) {continue;}
            // Calculate axial distances
            double dx = bodies[i].x - bodies[j].x;
            double dy = bodies[i].y - bodies[j].y;
            
            // Collision check
            double dr = (bodies[i].r < bodies[j].r ? bodies[j].r - bodies[i].r : bodies[i].r - bodies[j].r) + 2;
            // Do square/cube check then do square distance check
            if (abs(dx) < dr && abs(dy) < dr && dx*dx + dy*dy < dr*dr) {
                collisions.push_back(i);
                collisions.push_back(j);
                continue;
            }
            // Using the similar triangles present in the vector calculation
            double axis_cf_denom = total_scale * delta * pow(dx*dx + dy*dy, -1.5);
            
            double b1_axis_cf;
            // if distance is less than radius
            if (dx*dx+dy*dy < bodies[j].r*bodies[j].r) {
                // coeffecient = sqrt(mG/R^3) w/ scale factors
                b1_axis_cf = bodies[j].m * 6.6734E-11 * mass_scale * pow(bodies[j].r * distance_scale, -3.0) * delta;
            } else {
                // otherwise its normal
                b1_axis_cf = bodies[j].m * axis_cf_denom; 
            }

            double b2_axis_cf;
            if (dx*dx+dy*dy < bodies[i].r*bodies[i].r) {
                b2_axis_cf = bodies[i].m * 6.6734E-11 * mass_scale * pow(bodies[i].r * distance_scale, -3.0) * delta;
            } else {
                b2_axis_cf = bodies[i].m * axis_cf_denom;
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
        body& b1 = bodies[collisions.back()];
        collisions.pop_back();
        body& b2 = bodies[collisions.back()];
        collisions.pop_back();

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
        emit_signal("body_collided", b2.id, b1.id);
        emit_signal("body_collided", b1.id, b1.id);
        // Make b2 sentinel
        b2.id = -1;
    }
    // Update positions.
    for (int i=0; i < bodies.size(); i++) {
        bodies[i].x += bodies[i].vx * delta;
        bodies[i].y += bodies[i].vy * delta;
    }
    is_tree_valid = false;
}


// Get the acceleration at a point x,y,z=0 over time delta using the naive algorithm
Dictionary E127Controller::naive_probe(double delta, double x, double y) {
    Dictionary out = Dictionary();
    double ax = 0.0;
    double ay = 0.0;
    double az = 0.0;
    for (int i=0;i<bodies.size();i++) {
        // Skip sentinel
        if (bodies[i].id < 0) {continue;}
        // Calculate axial distances
        double dx = bodies[i].x - x;
        double dy = bodies[i].y - y;
        
        // Collision check
        // Do square/cube check then do square distance check
        if (dx < bodies[i].r && dy < bodies[i].r && dx*dx + dy*dy < bodies[i].r*bodies[i].r) {
            out.set("collision_id", bodies[i].id);
        }

        // Using the similar triangles present in the vector calculation
        double axis_cf = delta * delta * bodies[i].m * pow(dx*dx + dy*dy, -1.5) * total_scale;
        // Apply acceleration
        ax += axis_cf * dx;
        ay += axis_cf * dy;
    }
    out.set("ax", ax);
    out.set("ay", ay);
    return out;
}


// Create the quad or octree.
void E127Controller::build_tree() {
    tree = std::vector<tree_node>();
    float max_d = 0;
    double tree_distance_cutoff = 0;
    // Find the greatest axial distance from the origin.
    for (int i=0;i<bodies.size();i++) {
        if (bodies[i].id == -1) {continue;}
        if (bodies[i].x > max_d) {max_d = bodies[i].x;}
        if (-bodies[i].x > max_d) {max_d = -bodies[i].x;}
        if (bodies[i].y > max_d) {max_d = bodies[i].y;}
        if (-bodies[i].y > max_d) {max_d = -bodies[i].y;}

        if (bodies[i].r > tree_distance_cutoff) {
            tree_distance_cutoff = bodies[i].r;
        }
    }
    max_d = ceil(max_d + 1);
    tree_distance_cutoff *= tree_distance_cutoff;
    // DEBUG UtilityFunctions::print("Tree width = ", max);
    // Make root
    tree_node n = tree_node();
    n.first_child = 0;
    n.cx = 0;
    n.cy = 0;
    n.d = max_d;
    tree.emplace_back(n);
    // Insert all bodies
    for (int32_t i=0;i<bodies.size();i++) {
        if (bodies[i].id == -1) {continue;}
        insert_body(i, 0);
    }

    calculate_COMs(0);
    is_tree_valid = true;
    // DEBUG UtilityFunctions::print("Tree Completed - size=", tree.size());
}


// Recursive function: Insert a body into quad / octree.
void E127Controller::insert_body(int32_t b, int32_t i) {
    // DEBUG UtilityFunctions::print("inserting body ", b," starting at index ", i);
    int32_t idx = i;
    if (tree[idx].first_child == 0) {
        // Store the body in this node
        // DEBUG UtilityFunctions::print("Body ", b, " placed in empty leaf ", idx);
        tree[idx].first_child = -b - 1;
        return;
    }
    if (tree[idx].first_child < 0) {
        // already a node here! split the cell.
        int32_t b_in_tree = -tree[idx].first_child - 1;
        // Set the first child to the end of the vector.
        // DEBUG UtilityFunctions::print("first child set to ", tree.size());
        tree[idx].first_child = tree.size() + 1;
        double d = 0.5*tree[idx].d;
        
        // Add 4 empty leaves
        // all combinations of +/-x and +/-y
        for (int8_t yd=-1; yd<2; yd+=2) {
            for (int8_t xd=-1; xd<2; xd+=2) {
                tree_node n = tree_node();
                n.d = d;
                n.cx = tree[idx].cx - xd * d;
                n.cy = tree[idx].cy - yd * d;
                n.first_child = 0;
                tree.emplace_back(n);
                // DEBUG UtilityFunctions::print("Quad ", xd, yd, " (", n.cx, ", ", n.cy, "), d=", d, " added");
            }
        }
        insert_body(b_in_tree, idx);
    }
    // Traverse
    body& body = bodies[b];
    bool leftx = body.x <= tree[idx].cx;
    bool lefty = body.y <= tree[idx].cy;
    insert_body(b, tree[idx].first_child + leftx + lefty * 2 - 1);
}


// Recursive function: Calculate centres of mass for all nodes, then 
void E127Controller::calculate_COMs(int32_t n) {
    tree_node& node = tree[n];
    // If first_child is negative, then this is an end node...
    if (node.first_child == 0) {
        node.com_x = 0.0;
        node.com_y = 0.0;
        node.m = 0.0;
        return;}
    if (node.first_child < 0) {
        body& b = bodies[-node.first_child - 1];
        node.com_x = b.x;
        node.com_y = b.y;
        node.m = b.m;
        return;
    }
    // ...if it's not, iteration is required. 2D has 4 children per node.
    // Prepare stuff for later averaging
    node.com_x = 0.0;
    node.com_y = 0.0;
    node.m = 0.0;
    // Sum Values from Childrne
    for (int i=-1; i<3; i++) {
        tree_node& child_node = tree[node.first_child + i];
        
        // Recursive calculations!
        calculate_COMs(node.first_child + i);
        node.com_x += child_node.com_x * child_node.m;
        node.com_y += child_node.com_y * child_node.m;
        node.m += child_node.m;
    }
    // Take averages.
    node.com_x /= node.m;
    node.com_y /= node.m;
}


// Gets indices of all tree nodes where width/distance < theta. Search starts at index i.
std::vector<int32_t> E127Controller::get_bh_nodes(double x, double y, double theta, int32_t i) {
    int32_t idx = i;
    tree_node& node = tree[idx];
    // Prepare output vect
    std::vector<int32_t> out = std::vector<int32_t>();
    // Empty leaf. Return empty vector.
    if (node.first_child == 0) {
        // DEBUG UtilityFunctions::print("get_bh_nodes called on index ", i, ": Empty");
        return std::vector<int32_t>();
    }
    // Not Empty leaf. Return self index.
    if (node.first_child < 0) {
        // DEBUG UtilityFunctions::print("get_bh_nodes called on index ", i, ": Mono");
        out.emplace_back(idx);
        return out;
    }
    
    double dx = node.com_x - x;
    double dy = node.com_y - y;
    double d_squared = dx*dx + dy*dy;

    // this is equivalent to width / distance < theta. Rearranged to remove the sqrt (in distance calc) and division.
    // Second test is to ensure collision is accurate.
    if (4*node.d*node.d < theta*theta*d_squared && d_squared > tree_distance_cutoff) {
        // If it passes, end this search. Return current idx.
        // DEBUG UtilityFunctions::print("get_bh_nodes called on index ", i, ": Passes distance");
        out.emplace_back(idx);
        return out;
    }
    // If it fails other checks, repeat on all children of the node. Add their results to output.
    // DEBUG UtilityFunctions::print("No simple solution on index ", i, ". Looping over children");
    // If quadtree, 4.
    for (int32_t i=-1; i<3; i++) {
        std::vector<int32_t> valid_nodes = get_bh_nodes(x, y, theta, tree[idx].first_child + i);
        out.insert(out.end(), valid_nodes.begin(), valid_nodes.end());
    }
    // DEBUG UtilityFunctions::print("Closing loop for index ", i, ". Length = ", out.size());
    return out;
}


// Make a delta-second simulation step using the Barnes-Hut algorithm. Will create the tree if it isn't valid. Tree is never valid after this function call.
void E127Controller::barnes_hut_step(double delta, double theta) {
    // Ensure tree validity
    if (!is_tree_valid) {
        build_tree();
    }
    std::vector<int32_t> collisions = std::vector<int32_t>();
    // Iterate over bodies for accelerations.
    for (int i=0; i<bodies.size(); i++) {
        if (bodies[i].id == -1) {continue;}
        // Make reference to current looping body for ease of writing
        body& b = bodies[i];
        // Get the nodes used for calculations
        std::vector<int32_t> nodes = get_bh_nodes(b.x, b.y, theta, 0);
        // DEBUG UtilityFunctions::print("Body ", b.id, " with ", nodes.size(), " nodes, iterating..");
        // Iterate over calculation nodes
        for (int32_t j=0; j<nodes.size(); j++) {
            // Make ref to node
            tree_node& n = tree[nodes[j]];
            // Get axial distances
            double dx = n.com_x - b.x;
            double dy = n.com_y - b.y;
            double d_squared = dx*dx + dy*dy;
            // Skip self & touching bodies.
            if (n.first_child < 0) {
                if (-n.first_child - 1 == i) {
                    continue;
                }
                float dr = bodies[-n.first_child - 1].r + b.r;
                if (dr*dr >= d_squared) {
                    if (-n.first_child - 1 > i) {
                        collisions.push_back(i);
                        collisions.push_back(-n.first_child - 1);
                    }
                    continue;
                }
            }
            // Using the similar triangles present in the vector calculation
            double axis_cf = delta * n.m * pow(d_squared, -1.5) * total_scale;
            // Apply acceleration
            b.vx += axis_cf * dx;
            b.vy += axis_cf * dy;
            // DEBUG UtilityFunctions::print("b",b.id,"n",nodes[j], "  n.m=", n.m, " cf=", axis_cf, " dx=", dx, " dy=", dy);
        }
    }
    // Resolve collisions
    while (collisions.size() > 0) {
        body& b1 = bodies[collisions.back()];
        collisions.pop_back();
        body& b2 = bodies[collisions.back()];
        collisions.pop_back();

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
        emit_signal("body_collided", b2.id, b1.id);
        emit_signal("body_collided", b1.id, b1.id);
        // Make b2 sentinel
        b2.id = -1;
    }
    // Velocity
    for (auto& b:bodies) {
        if (b.id == -1) {continue;}
        b.x += b.vx * delta;
        b.y += b.vy * delta;
    }
    is_tree_valid = false;
}


// Get the acceleration at a point x,y,z=0 over time delta using the Barnes-Hut algorithm. Will build a tree if it isn't valid.
Dictionary E127Controller::barnes_hut_probe(double delta, double x, double y, double theta, double r) {
    if (!is_tree_valid) {
        build_tree();
    }
    Dictionary out = Dictionary();
    // Get the nodes used for calculations
    std::vector<int32_t> nodes = get_bh_nodes(x, y, theta, 0);
    // Iterate over calculation nodes
    double ax = 0.0;
    double ay = 0.0;
    for (int32_t j=0; j<nodes.size(); j++) {
        // Make ref to node
        tree_node& n = tree[nodes[j]];
        // Get axial distances
        double dx = n.com_x - x;
        double dy = n.com_y - y;
        double d_squared = dx*dx + dy*dy;
        // Find collision
        if (n.first_child < 0) {
            float dr = bodies[-n.first_child - 1].r + r;
            if (dr*dr >= d_squared) {
                out.set("collision_id", -n.first_child - 1);
            }
        }
        // Using the similar triangles present in the vector calculation
        double axis_cf = delta * delta * n.m * pow(dx*dx + dy*dy, -1.5) * total_scale;
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
    for (int32_t i = 0; i<bodies.size();i++) {
        if (bodies[i].id == -1) {
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
        if (b.id == -1) { continue; }
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


// Clamps bodies' positions to within a circle of radius r
void E127Controller::clamp_to_circle(double r) {
    for (int i = 0; i<bodies.size(); i++) {
        body& body = bodies[i];
        if (body.id == -1) {continue;}
        double r2_by_d = 2 * r / sqrt(body.x*body.x + body.y*body.y);
        if (r2_by_d < 2.0) {
            body.x *= 1 - r2_by_d;
            body.y *= 1 - r2_by_d;
        }
    }
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
        if (b.id == -1) {continue;}
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


// Get any body, even if it's a sentinel (id=-1, this body is no longer simulated)
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


int E127Controller::get_live_body_count() {
    int out = 0;
    for (int i=0; i<bodies.size(); i++) {
        if (bodies[i].id != -1) {
            out += 1;
        }
    }
    return out;
}
