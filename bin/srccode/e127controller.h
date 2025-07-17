#ifndef E127CONTROLLER
#define E127CONTROLLER

// Extending Node
#include <godot_cpp/classes/node.hpp>
// node.hpp is the bindings for sprite2d

namespace godot {

class E127Controller : public Node {
	GDCLASS(E127Controller, Node)



// private stuff. like from c#
private:
	struct tree_node;
	std::vector<E127Controller::tree_node> tree;
	bool is_tree_valid;
	struct body;
	
	std::vector<body> bodies;
	float tree_distance_cutoff;

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

	bool get_do_collision() const;
	void set_do_collision(const bool collision_on);

	void add_body(double m, double r, double x, double y, double vx = 0.0, double vy = 0.0);
	
	// Simulation / Major calculations
	void clamp_to_circle(double r);

	void naive_step(double delta);
	Dictionary naive_probe(double delta, double x, double y);

	void build_tree();
	void insert_body(int32_t b, int32_t i);
	void calculate_COMs(int32_t n);
	int get_live_body_count();

	std::vector<int32_t> get_bh_nodes(double x, double y, double theta, int32_t i);
	void barnes_hut_step(double delta, double theta = 1.0);

	Dictionary barnes_hut_probe(double delta, double x, double y, double theta = 1.0, double r = 0.0);

	// void _process(double delta) override;

protected:
	static void _bind_methods();
};

}

#endif