@tool
extends EditorPlugin


func _enter_tree():
    add_custom_type("TDCamera2D", "Camera2D", preload("td_camera_2d.gd"), null)

func _exit_tree():
    remove_custom_type("TDCamera2D")
