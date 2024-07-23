extends Node2D


@export var offset = Vector2( 0.0, -320.0 )
@export var duration : float = 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var tween = get_tree().create_tween().set_process_mode( Tween.TWEEN_PROCESS_PHYSICS )
    tween.set_loops().set_parallel( false )
    tween.tween_property( $AnimatableBody2D, "position", offset / scale, duration / 2.0 )
    tween.tween_property( $AnimatableBody2D, "position", Vector2.ZERO, duration / 2.0 )
