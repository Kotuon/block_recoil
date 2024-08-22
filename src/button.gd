extends Node2D
class_name Door_Button


@onready var mesh := $MeshInstance2D
@export var disabled_texture : Texture2D
@export var enabled_texture : Texture2D

var is_enabled : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    mesh.set_texture( disabled_texture )


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process( _delta: float ) -> void:
    pass


func _draw() -> void:
    pass


func _on_area_2d_body_entered( body: Node2D ) -> void:
    if !is_enabled && body.name.to_lower() == "player":
        mesh.set_texture( enabled_texture )
        is_enabled = true
