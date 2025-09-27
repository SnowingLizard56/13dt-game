class_name MapEvent extends Resource

@export var title: String = ""
@export_multiline var exposition: String = "-"
@export var options: Array[EventEffect] = []:
	get():
		if options == []:
			var ee = EventEffect.new()
			ee.title = "Continue"
			options.append(ee)
		return options
