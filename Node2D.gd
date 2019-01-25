extends Node2D

# wave variables
export (int) var num_points = 100
export (int) var y_offset = 400
export (int) var num_background_waves = 4
export (int) var max_background_wave_height = 6
export (float) var background_wave_compression = 0.1
export (int) var background_wave_max_freq = 10

# spring and propagation variables
export (float) var spring_constant = 25
export (float) var dampening = 0.4
export (int) var propagation_iterations = 5
export (float) var spread = 80
export (float) var acceleration_factor = 10

export (int) var splash_index_range = 1

var screen_size
var points = []
var sine_offsets = []
var sine_amplitudes = []
var sine_phases = []
var sine_frequencies = []
var x_dist = 0
var time = 0
var count = 0
var up = true

var particles = preload("res://WaterParticles.tscn")

class Point:
	var position = Vector2(0, 0)
	var velocity = Vector2(0, 0)
	
	func init(position):
		self.position = position

func create_wave_points():
	for i in range(num_points):
		var p = Point.new()
		p.init(Vector2(x_dist * i, y_offset))
		points.append(p)
		
func init_sine_values():
	for i in range(num_background_waves):
		sine_offsets.append(PI * randf())
		sine_amplitudes.append(randf() * max_background_wave_height)
		sine_phases.append(randf() * background_wave_compression)
		sine_frequencies.append(randf() * background_wave_max_freq)
		
func overlap_sines(x):
	var result = 0
	for i in range(num_background_waves):
		result += sine_offsets[i] + sine_amplitudes[i] * sin(x * sine_phases[i] + time * sine_frequencies[i])
	return result

func update_points(delta):
	for i in range(points.size()):
		var p = points[i]
		# calculate spring force
		var dy = p.position.y - y_offset
		var acceleration = acceleration_factor * Vector2(0, -spring_constant * dy - (dampening * p.velocity.y))

		p.velocity += acceleration * delta
		p.position += p.velocity * delta
									
func propagate_waves(delta):
	var left_deltas = [0]
	var right_deltas = []
	for i in range(propagation_iterations):
		for j in range(points.size()):
			if j > 0:
				left_deltas.append(spread * (points[j].position.y - points[j - 1].position.y))
			if j < points.size() - 1:
				right_deltas.append(spread * (points[j].position.y - points[j + 1].position.y))
		
		right_deltas.append(0)
		for k in range(points.size()):
			if k > 0:
				points[k-1].velocity.y += left_deltas[k] * delta
			if k < points.size() - 1:
				points[k+1].velocity.y += right_deltas[k] * delta
				
func splash(x, height):
	var closest_index = floor((x / screen_size.x) * num_points)
		
	var p = particles.instance()
	p.position = Vector2(x, points[closest_index].position.y)
	add_child(p)
	
	points[closest_index].position.y = height

	for i in range(closest_index - splash_index_range, closest_index + splash_index_range):
		if i >= 0:
			points[i].position.y = height
		if i < num_points:
			points[i].position.y = height
			
func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		var pos = get_viewport().get_mouse_position()
		if pos.y >= y_offset:
			splash(pos.x, pos.y)
		
func _ready():
	screen_size = get_viewport_rect().size
	x_dist = screen_size.x / num_points
	
	var screensize = OS.get_screen_size(0)
	var windowsize = OS.get_window_size()

	OS.set_window_position(screensize*0.5 - windowsize*0.5)
		
	init_sine_values()
	create_wave_points()

func _process(delta):
	time += delta
	count += delta
					
	if count > 1:
		count = 0
		print(Performance.get_monitor(Performance.TIME_FPS))
	propagate_waves(delta)
	update_points(delta)
	
	var vertices = PoolVector2Array()
	var uv_vertices = PoolVector2Array()
	for i in range(num_points):
		vertices.push_back(Vector2(points[i].position.x, points[i].position.y + overlap_sines(points[i].position.x)))
	
	vertices.push_back(Vector2(screen_size.x + 10, y_offset)) # add vertex for edge of viewport
	$Water/Line2D.points = vertices
	
	# add vertices to fill below the waves
	vertices.push_back(Vector2(screen_size.x + 10, screen_size.y + 50))
	vertices.push_back(Vector2(-10, screen_size.y + 50))
	vertices.push_back(Vector2(-10, y_offset))
	
	$Water/Polygon2D.polygon = vertices	
