@tool @icon("res://addons/VirtualSteering/icon.png")
extends TextureRect
class_name VirtualSteering

@export var rotation_limit: int = 180 # 180 recommend
@export var output_limit: int = 60 # Maximum rotation in degrees for returning over the scale of -handle_rotation_limit to handle_rotation_limit.
@export_range(1, 20) var wheel_sensitivity : float = 12
@export_range(0.1, 1) var wheel_return_speed : float = 0.2

var last_drag_position: Vector2
var touch_released: bool = false

func _ready():
	if !ProjectSettings.get_setting("input_devices/pointing/emulate_touch_from_mouse") and not DisplayServer.is_touchscreen_available():
		printerr("Enable \"emulate touch from mouse\" in Project Settings !! ")
		return
	
	set_process_input(true)


func _physics_process(delta: float) -> void:
	pivot_offset = size / 2
	if touch_released:
		rotation = lerpf(rotation, 0.0, delta / wheel_return_speed)
		if abs(rotation) <= .01:
			rotation = 0.0
			touch_released = false
	

# handles the touch and the drag.
func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		var local_current : Vector2 = event.position - pivot_offset
		var local_last := last_drag_position - pivot_offset
		var angle_diff_deg := rad_to_deg(local_current.angle_to(local_last)) * wheel_sensitivity / 5.0 #Compute angle difference in degrees
		
		# Smooth rotation update
		var target_rotation := rotation_degrees - angle_diff_deg
		rotation_degrees = lerpf(rotation_degrees, target_rotation, 0.2)
		
		# Clamp to allowed range
		rotation_degrees = clampf(rotation_degrees, -rotation_limit, rotation_limit) 

		last_drag_position = event.position
		touch_released = false
	
	elif event is InputEventScreenTouch:
		if event.pressed:
			touch_released = false
			last_drag_position = event.position
		else:
			touch_released = true

# return the output between -1 to 1
func get_output() -> float:
	return -(_convert_to_output(rotation))

# return the output in degree between -rotation_limit to rotation_limit
func get_output_deg() -> float:
	return _convert_to_output_deg(rotation_degrees)

# convert the handle rotation to the output rotatin.
func _convert_to_output(a: float) -> float:
	return a * deg_to_rad(output_limit) / deg_to_rad(180)

func _convert_to_output_deg(a: float) -> float:
	return a * output_limit / 180
