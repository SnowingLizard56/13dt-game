#ifndef E127_CONTROLLER
#define E127_CONTROLLER

// Extending Node
#include <godot_cpp/classes/node.hpp>
// node.hpp is the bindings for sprite2d

namespace godot {

class E127Controller : public Node {
	GDCLASS(E127Controller, Node) 	


// private stuff. like from c#
private:
	struct body;
	struct collision;
	
	std::vector<body> bodies;

	double mass_scale;
	double distance_scale;
	double total_scale;

// public stuff. like from c#
public:
	E127Controller();
	~E127Controller();

	TypedArray<Dictionary> get_bodies() const;
	TypedArray<Dictionary> get_bodies_in_rect(Rect2 rect);
	Dictionary get_body(const int id) const;
	void set_body(const Dictionary _new);
	void disable_body(const int id);

	TypedArray<int> get_sentinel_ids();

	double get_mass_scale() const;
	void set_mass_scale(const double mass_scale);
	double get_distance_scale() const;
	void set_distance_scale(const double distance_scale);

	void add_body(double m, double r, double x, double y, double vx = 0.0, double vy = 0.0, bool force_nonlinear = false, bool use_linear = false, bool negligible_mass = false);
	
	// Simulation / Major calculations

	void naive_step(double delta);
	Dictionary naive_probe(double delta, double x, double y);
	Dictionary linear_naive_probe(double delta, double x, double y);

	// void _process(double delta) override;

protected:
	static void _bind_methods();
};

}

#endif