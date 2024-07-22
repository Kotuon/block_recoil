extends CharacterBody2D
class_name Player

## Movement ##
# Scale numbers so values aren't as large
var modifier : float = 100.0
# General values
var gravity : float = 10.0
var walk_speed : float = 400.0

var friction : float = 0.1
var accel : float = 0.25

## Jump ##
# Jump memory
var jump_memory_timer := Timer.new()
var jump_memory_time : float = 0.1
# Coyote time
var coyote_timer := Timer.new()
var coyote_time : float = 0.1
var can_coyote_jump : bool = false
# General
var jump_speed : float = -5.0
var has_jump_input : bool = false

## Coin ##
var has_shot_coin : bool = false
var coin_ref : CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # Jump memory timer setup
    add_child( jump_memory_timer )
    jump_memory_timer.one_shot = true
    jump_memory_timer.wait_time = jump_memory_time

    var timeout_jump_memory = func():
        has_jump_input = false
    jump_memory_timer.connect( "timeout", timeout_jump_memory )

    # Coyote timer setup
    add_child( coyote_timer )
    coyote_timer.one_shot = true
    coyote_timer.wait_time = coyote_time

    var timeout_coyote = func():
        can_coyote_jump = false
    coyote_timer.connect( "timeout", timeout_coyote )

    # Coin object setup
    coin_ref = preload( "res://items/coin.tscn" ).instantiate()
    get_parent().add_child.call_deferred( coin_ref )
    coin_ref.position = Vector2( -10000000.0, -10000000.0 )


func _physics_process( _delta: float ) -> void:
    pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process( delta: float ) -> void:
    update_walk( delta )
    update_jump()

    if Input.is_action_just_pressed( "take_coin" ):
        has_shot_coin = false
        coin_ref.position = Vector2( -10000000.0, -10000000.0 )

    if Input.is_action_pressed( "push_coin" ) && has_shot_coin:
        if coin_ref.has_hit:
            velocity += ( position - coin_ref.position ).normalized() * 15.0

    if Input.is_action_pressed( "pull_coin" ) && has_shot_coin:
        if coin_ref.has_hit:
            velocity += ( coin_ref.position - position ).normalized() * 15.0

    if !has_shot_coin && Input.is_action_just_pressed( "push_coin" ):
        has_shot_coin = true
        coin_ref.position = position
        coin_ref.move_velocity = ( get_global_mouse_position() - position ).normalized() * 1000.0
        coin_ref.has_hit = false



func update_walk( delta: float ) -> void:
    var inputDirection = Input.get_axis( "walk_left", "walk_right" )
    velocity.y += gravity * delta * modifier

    if inputDirection != 0:
        var walkAmount = inputDirection * walk_speed * delta * modifier
        velocity.x = lerp( velocity.x, walkAmount , accel )
    else:
        velocity.x = lerp( velocity.x, 0.0, friction )


func update_jump() -> void:
    var last_collision_result = is_on_floor()
    var collision_result = move_and_slide()

    if !collision_result && last_collision_result:
        can_coyote_jump = true
        coyote_timer.start()

    if Input.is_action_just_pressed( "jump" ):
        has_jump_input = true
        if !is_on_floor():
            jump_memory_timer.start()


    if ( is_on_floor() || can_coyote_jump ) && has_jump_input:
        has_jump_input = false
        can_coyote_jump = false
        velocity.y = jump_speed * modifier
