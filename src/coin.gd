extends CharacterBody2D
class_name Coin

var has_hit : bool = false
var move_velocity : Vector2

var gravity : float = 15.0
var total_gravity : float

var player : CharacterBody2D


func _physics_process( _delta: float ) -> void:
    if !has_hit:
        velocity = move_velocity
        total_gravity += gravity
        velocity.y += total_gravity


    move_and_slide()

    if is_on_floor() || is_on_wall() || is_on_ceiling():
        velocity = Vector2( 0.0, 0.0 )
        has_hit = true


func start_coin_push( player_position: Vector2, player_velocity : Vector2 ) -> void:
    player.has_shot_coin = true
    position = player_position
    velocity = player_velocity
    move_velocity = Vector2( 0.0, 0.0 )
    has_hit = false
    total_gravity = 0.0


func coin_push( player_position: Vector2, force_of_coin: float, force_on_player: float ) -> void:
    if !has_hit:
        move_velocity += ( get_global_mouse_position() - player_position ).normalized() * force_of_coin
    else:
        player.velocity += ( player.position - position ).normalized() * force_on_player
