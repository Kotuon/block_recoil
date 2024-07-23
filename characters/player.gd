extends CharacterBody2D
class_name Player

## Movement ##
# Scale numbers so values aren't as large
var modifier : float = 100.0
# General values
var gravity : float = 15.0
var walk_speed : float = 400.0

var friction : float = 0.1
var accel : float = 0.25

var freeze_timer := Timer.new()
var last_grounded_position : Vector2
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
var force_of_coin : float = 15.0
var has_shot_coin : bool = false
# Resource bar
@onready var mana_bar := $ManaBar
var mana_recharge_timer := Timer.new()
var total_mana : float = 100.0
var coin_cost_rate : float = 90.0
var coin_recharge_rate : float = 1.0
var curr_mana : float = total_mana
var time_until_mana_recharge_starts : float = 1.0
var should_recharge_mana : bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # Initializing respawn point
    last_grounded_position = position

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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process( delta: float ) -> void:
    if can_move:
        update_walk( delta )
        update_jump()
        update_coin( delta )

    update_mana_bar( delta )

    if position.y > 1440.0:
        can_move = false
        freeze_timer.start()
        position = last_grounded_position


func update_walk( delta: float ) -> void:
    var inputDirection = Input.get_axis( "walk_left", "walk_right" )
    velocity.y += gravity * delta * modifier

    if inputDirection != 0:
        var walkAmount = inputDirection * walk_speed * delta * modifier
        velocity.x = lerp( velocity.x, walkAmount, accel )
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
        last_grounded_position = position
        velocity.y = jump_speed * modifier


func update_coin( delta: float ) -> void:
    if Input.is_action_just_pressed( "take_coin" ):
        has_shot_coin = false
        coin_ref.position = Vector2( -10000000.0, -10000000.0 )

    var has_input : bool = false

    if Input.is_action_pressed( "push_coin" ) && has_shot_coin && curr_mana > 0.0:
        coin_ref.coin_push( position, force_of_coin )
        has_input = true
        mana_recharge_timer.stop()
        should_recharge_mana = false
        if coin_ref.has_hit:
            curr_mana = clampf( curr_mana - coin_cost_rate * delta, 0.0, total_mana )

    if Input.is_action_pressed( "pull_coin" ) && has_shot_coin && curr_mana > 0.0:
        coin_ref.coin_pull( position, force_of_coin )
        has_input = true
        mana_recharge_timer.stop()
        should_recharge_mana = false
        if coin_ref.has_hit:
            curr_mana = clampf( curr_mana - coin_cost_rate * delta, 0.0, total_mana )

    if !has_shot_coin && Input.is_action_just_pressed( "push_coin" ):
        coin_ref.start_coin_push( position, velocity )

    if !has_input && mana_recharge_timer.is_stopped():
        mana_recharge_timer.start()


func update_mana_bar( delta: float ) -> void:
    if should_recharge_mana:
        curr_mana = lerp( curr_mana, total_mana, coin_recharge_rate * delta )

    mana_bar.set_value_no_signal( curr_mana )
