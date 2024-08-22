extends Node2D

@export var offset = Vector2( 0.0, -320.0 )
@export var duration : float = 5.0
var buttons : Array[Door_Button]

var has_opened : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var children = get_children()
    for i in children.size():
        if children[i].name.to_lower().contains("button"):
            buttons.push_back( children[i] )


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process( _delta: float ) -> void:
    if has_opened:
        return

    var all_hit : bool = true
    for i in buttons.size():
        if !buttons[i].is_enabled:
            all_hit = false
            break
    if all_hit:
        open()


func open() -> void:
    var tween = get_tree().create_tween().set_process_mode( Tween.TWEEN_PROCESS_PHYSICS )
    tween.set_loops( 1 )
    tween.set_ease( Tween.EASE_IN_OUT )
    tween.set_trans( Tween.TRANS_SINE )
    tween.tween_property( $AnimatableBody2D, "position", offset / scale, duration / 2.0 )

    has_opened = true
