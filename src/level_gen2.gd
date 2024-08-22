extends Node2D


@export var difficulty_curve : Array[int]
var times_generated : int = 0

var FLOOR := preload( "res://terrain/floor.tscn" )
var CHECKPOINT := preload( "res://items/checkpoint.tscn" )
var PLAYER := preload( "res://characters/player.tscn" )

var player : CharacterBody2D

var rng := RandomNumberGenerator.new()

var curr_position := Vector2( 0.0, 0.0 )

var min_floor_size : float = 1.5
var max_floor_size : float = 5.5

var min_h_jump_size : float = 135.0
var max_h_jump_size : float = 225.0

var min_v_jump_size : float = 40.0
var max_v_jump_size : float = 60.0

var min_series_size : int = 1
var max_series_size : int = 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var start_floor = FLOOR.instantiate()
    add_child( start_floor )
    start_floor.set_position( curr_position )
    start_floor.set_scale( Vector2( max_floor_size, 1.0 ) )

    var start_checkpoint = CHECKPOINT.instantiate()
    add_child( start_checkpoint )
    start_checkpoint.set_position( curr_position + Vector2( 30.0, -25.0 ) )
    start_checkpoint.set_name( "StartPosition" )

    player = PLAYER.instantiate()
    add_child( player )
    player.set_position( start_checkpoint.position )

    curr_position.x += ( max_floor_size * 40.0 ) + min_h_jump_size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
