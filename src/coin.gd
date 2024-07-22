extends CharacterBody2D
class_name Coin

var has_hit : bool = false
var move_velocity : Vector2

var gravity : float = 10.0
var total_gravity : float

func _physics_process( _delta: float ) -> void:

    if !has_hit:
        velocity = move_velocity
        total_gravity += gravity
        velocity.y += total_gravity


    move_and_slide()

    if is_on_floor() || is_on_wall() || is_on_ceiling():
        velocity = Vector2( 0.0, 0.0 )
        has_hit = true
        total_gravity = 0.0
        move_velocity = Vector2( 0.0, 0.0 )
