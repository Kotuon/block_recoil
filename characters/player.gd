extends CharacterBody2D
class_name Player

@onready var camera := $Camera2D
var time_in_air : float = 0.0
var max_time_in_air : float = 1.0
var startup_time_in_air : float = 0.75

## Movement ##
# Scale numbers so values aren't as large
var modifier : float = 100.0
# General values
var gravity : float = 15.0
var walk_speed : float = 400.0

var friction : float = 0.1
var accel : float = 0.25

var last_checkpoint : Checkpoint
var freeze_timer := Timer.new()
var time_frozen : float = 0.75
var can_move : bool = true

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
var coin_ref : CharacterBody2D
const COIN := preload( "res://items/coinv2.tscn" )
var force_of_coin : float = 25.0
var force_on_player : float = 10.0
var has_shot_coin : bool = false
# Resource bar
@onready var mana_bar := $ManaBar
var mana_recharge_timer := Timer.new()
var total_mana : float = 100.0
var coin_cost_rate : float = 80.0
var coin_recharge_rate : float = 2.0
var curr_mana : float = total_mana
var time_until_mana_recharge_starts : float = 0.5
var should_recharge_mana : bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    last_checkpoint = get_parent().get_node( "StartPosition" )

    add_child( freeze_timer )
    freeze_timer.set_one_shot( true )
    freeze_timer.set_wait_time( time_frozen )

    var timeout_freeze = func():
        can_move = true
    freeze_timer.connect( "timeout", timeout_freeze )

    # Setting cursor
    Input.set_default_cursor_shape( Input.CURSOR_CROSS )

    # Jump memory timer setup
    add_child( jump_memory_timer )
    jump_memory_timer.set_one_shot( true )
    jump_memory_timer.set_wait_time( jump_memory_time )

    var timeout_jump_memory = func():
        has_jump_input = false
    jump_memory_timer.connect( "timeout", timeout_jump_memory )

    # Coyote timer setup
    add_child( coyote_timer )
    coyote_timer.set_one_shot( true )
    coyote_timer.set_wait_time( coyote_time )

    var timeout_coyote = func():
        can_coyote_jump = false
    coyote_timer.connect( "timeout", timeout_coyote )

    # Coin object setup
    coin_ref = preload( "res://items/coin.tscn" ).instantiate()
    get_parent().add_child.call_deferred( coin_ref )
    coin_ref.position = Vector2( -10000000.0, -10000000.0 )
    coin_ref.player = self

    # Mana bar setup
    mana_bar.min_value = 0.0
    mana_bar.max_value = total_mana
    mana_bar.set_value_no_signal( curr_mana )

    # Mana recharge timer setup
    add_child( mana_recharge_timer )
    mana_recharge_timer.set_one_shot( true )
    mana_recharge_timer.set_wait_time( time_until_mana_recharge_starts )

    var timeout_mana = func():
        should_recharge_mana = true
    mana_recharge_timer.connect( "timeout", timeout_mana )


func _physics_process( _delta: float ) -> void:
    pass


func _process( delta: float ) -> void:
    var last_floor_collision : bool = is_on_floor()

    if can_move:
        update_walk( delta )
        update_jump()
        #update_coinv1( delta )
        update_coinv2()

    update_mana_bar( delta )

    if !is_on_floor():
        time_in_air += delta

        if last_floor_collision:
            if time_in_air < 0.0:
                time_in_air = 0.0
    else:
        time_in_air -= delta

        if time_in_air > startup_time_in_air + 1.0:
            time_in_air = startup_time_in_air + 1.0

    #camera.zoom.x = lerp( 0.9, 0.5, clampf( time_in_air - startup_time_in_air, 0.0, 1.0 ) )
    #camera.zoom.y = lerp( 0.9, 0.5, clampf( time_in_air - startup_time_in_air, 0.0, 1.0 ) )

    if position.y > 1440.0:
        can_move = false
        freeze_timer.start()
        position = last_checkpoint.global_position
        time_in_air = 0.0


func update_walk( delta: float ) -> void:
    var inputDirection = Input.get_axis( "walk_left", "walk_right" )

    if !is_on_floor():
        velocity.y += gravity * delta * modifier

    if inputDirection != 0:
        var walkAmount = inputDirection * walk_speed * delta * modifier
        velocity.x = lerp( velocity.x, walkAmount, accel )
    elif is_on_floor():
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
        if time_in_air < startup_time_in_air:
            time_in_air = 0.0


func update_mana_bar( delta: float ) -> void:
    if should_recharge_mana:
        curr_mana = lerp( curr_mana, total_mana, coin_recharge_rate * delta )

    mana_bar.set_value_no_signal( curr_mana )


func update_coinv1( delta: float ) -> void:
    if Input.is_action_just_released( "push_coin" ):
        has_shot_coin = false
        coin_ref.position = Vector2( -10000000.0, -10000000.0 )

    var has_input : bool = false

    if has_shot_coin && Input.is_action_pressed( "push_coin" ) && curr_mana > 0.0:
        coin_ref.coin_push( position, force_of_coin, force_on_player )
        has_input = true
        mana_recharge_timer.stop()
        should_recharge_mana = false
        if coin_ref.has_hit:
            curr_mana = clampf( curr_mana - coin_cost_rate * delta, 0.0, total_mana )

    if !has_shot_coin && Input.is_action_just_pressed( "push_coin" ):
        coin_ref.start_coin_push( position, velocity )

    if !has_input && mana_recharge_timer.is_stopped():
        mana_recharge_timer.start()


func update_coinv2() -> void:
    if Input.is_action_just_pressed( "push_coin" ):
        print("new coin")
        var coin_instance : CharacterBody2D = COIN.instantiate()
        get_parent().add_child( coin_instance )

        var direction_to_mouse : Vector2 = ( get_global_mouse_position() - position ).normalized()
        coin_instance.global_position = global_position
        coin_instance.velocity = direction_to_mouse * force_of_coin * 50.0

        velocity += direction_to_mouse * -1.0 * force_on_player * 50.0
