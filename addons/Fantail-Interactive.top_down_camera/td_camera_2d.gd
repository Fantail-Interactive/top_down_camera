extends Camera2D

## Scroll by using ui direction actions
@export var keyboard_pan := true
@export_group("Keyboard Settings")
@export var move_left_action := "ui_left"
@export var move_right_action := "ui_right"
@export var move_up_action := "ui_up"
@export var move_down_action := "ui_down"
@export_group("")
## Scroll by clicking right mouse button
@export var mouse_drag_pan := true
@export_group("Drag Settings")
@export var drag_action := "drag_camera"
@export_group("")
## Scroll by moving mouse to the window edge
@export var mouse_edge_pan := false
@export var use_mouse_wheel := true
@export_group("Zoom Settings")
@export var min_zoom := 2.0
@export var max_zoom := 0.5
@export var zoom_speed := 0.1
@export var zoom_in_action := "zoom_in"
@export var zoom_out_action := "zoom_out"
@export_group("")
## How close should the mouse cursor be to the window edge (in pixels) before it starts
## to pan the camera
@export var edge_margin := 50
## Camera speed (pixels/s)
@export var pan_speed := 450

var prev_mouse_pos := Vector2.ZERO
var dragging := false
var move_left := false
var move_right := false
var move_up := false
var move_down := false


func _ready() -> void:
    # We want the camera to move when we set position
    set_drag_horizontal_enabled(false)
    set_drag_vertical_enabled(false)

## Check for events detected by _unhandled_input and handle them
func _process(delta: float) -> void:
    var motion := Vector2.ZERO
    if keyboard_pan:
        if move_left:
            motion += Vector2.LEFT
        if move_up:
            motion += Vector2.UP
        if move_right:
            motion += Vector2.RIGHT
        if move_down:
            motion += Vector2.DOWN

    var mouse_pos := get_local_mouse_position()
    # Pan camera when the mouse has been moved to the window edges
    if mouse_edge_pan:
        var rect := get_viewport().get_visible_rect()
        var margin_rect = rect.grow(-edge_margin)
        margin_rect.position -= rect.size / 2
        if not margin_rect.has_point(mouse_pos):
            motion += margin_rect.get_center().direction_to(mouse_pos)

    motion *= (pan_speed * (1 / zoom.x)) * delta / Engine.time_scale

    if mouse_drag_pan and dragging:
        motion = prev_mouse_pos - mouse_pos

    # Update position of the camera.
    position += motion
    clamp_position_to_limits()

    if use_mouse_wheel:
        if Input.is_action_just_released(zoom_in_action):
            zoom += Vector2(zoom_speed, zoom_speed)
        if Input.is_action_just_released(zoom_out_action):
            zoom -= Vector2(zoom_speed, zoom_speed)

        zoom.x = clampf(zoom.x, max_zoom, min_zoom)
        zoom.y = zoom.x

    prev_mouse_pos = get_local_mouse_position()

## Check for any unhandled input events and take note of them
##
## We are taking press/release events and turning them into a flag of whether the
## button is being held down
##
## NOTE: This is done here to ensure that we only consume input events if no other node does.
## i.e. the camera won't move if the player is moving through menus
func _unhandled_input(event: InputEvent) -> void:
    # TODO: Change to input action
    if event.is_action(drag_action):
        dragging = event.is_pressed()
        return

    # Transform a key change event into a "pressed" flag.
    # We do it this way because we're checking against an InputEvent, not Input
    if event.is_action_pressed(move_left_action):
        move_left = true
    if event.is_action_pressed(move_up_action):
        move_up = true
    if event.is_action_pressed(move_right_action):
        move_right = true
    if event.is_action_pressed(move_down_action):
        move_down = true
    if event.is_action_released(move_left_action):
        move_left = false
    if event.is_action_released(move_up_action):
        move_up = false
    if event.is_action_released(move_right_action):
        move_right = false
    if event.is_action_released(move_down_action):
        move_down = false

## Clamp the camera position to within the camera limits
##
## This fixes an issue where the camera can get "stuck" when in corners. I assume this
## is due to stopping all movement when a limit is reached
func clamp_position_to_limits() -> void:
    var view_size := get_viewport().get_visible_rect ().size * get_zoom().x
    var half_width := view_size.x / 2.0
    var half_height := view_size.y / 2.0
    position.x = clampf(position.x, limit_left + half_width, limit_right - half_width)
    position.y = clampf(position.y, limit_top + half_height, limit_bottom - half_height)
