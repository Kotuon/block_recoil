extends Node2D


@export var difficulty_curve : Array[int]
var times_generated : int = 0

var FLOOR := preload( "res://terrain/floor.tscn" )
var CHECKPOINT := preload( "res://items/checkpoint.tscn" )
var PLAYER := preload( "res://characters/player.tscn" )

var player : CharacterBody2D

@export var EASY_TILE : Array[PackedScene] = [
    preload( "res://sequences/s_c_horizontal_easy.tscn" ),
    preload( "res://sequences/s_c_vertical_easy.tscn" ),
    preload( "res://sequences/s_horizontal_jumps_easy.tscn"),
    preload( "res://sequences/s_vertical_jumps_easy.tscn"),
    preload( "res://sequences/s_mp_horizontal_easy.tscn" ),
    preload( "res://sequences/s_mp_vertical_easy.tscn" )
]

@export var HARD_TILE : Array[PackedScene] = [
    preload( "res://sequences/s_c_vertical_hard.tscn" ),
    preload( "res://sequences/s_c_horizontal_hard.tscn" ),
    preload( "res://sequences/s_mp_horizontal_hard.tscn"),
    preload( "res://sequences/s_vertical_jumps_hard.tscn"),
    preload( "res://sequences/s_horizontal_jumps_hard.tscn" ),
    preload( "res://sequences/s_horizontal_jumps_hard_2.tscn" )
]

var rng := RandomNumberGenerator.new()

var curr_position := Vector2( 0.0, 0.0 )
var curr_h_jump_difficulty : float = 0
var curr_v_jump_difficulty : float = 0
var curr_platform_difficulty : float = 0

var min_floor_size : float = 1.5
var max_floor_size : float = 5.5

var min_h_jump_size : float = 90.0
var max_h_jump_size : float = 180.0

var min_v_jump_size : float = 40.0
var max_v_jump_size : float = 60.0

var min_series_size : int = 1
var max_series_size : int = 4

var last_tile : int = -1
var last_difficulty : int = -1


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

    for i in 1:
        generate_series_premade()


func _process( _delta: float ) -> void:
    if player.position.x >= curr_position.x - 750.0:
        generate_series_premade()


func generate_series_scratch() -> void:
    var series_size = rng.randi_range( min_series_size, max_series_size )
    curr_h_jump_difficulty = rng.randf_range( 0.0, 1.0 )
    curr_v_jump_difficulty = rng.randf_range( 0.0, 1.0 )
    curr_platform_difficulty = rng.randf_range( 0.0, 1.0 )

    var floor_size : float = ( 1.0 - curr_platform_difficulty ) * max_floor_size + curr_platform_difficulty * min_floor_size
    var h_jump_size : float = ( 1.0 - curr_h_jump_difficulty ) * min_h_jump_size + curr_h_jump_difficulty * max_h_jump_size
    var v_jump_size : float = ( 1.0 - curr_v_jump_difficulty ) * min_v_jump_size + curr_v_jump_difficulty * max_v_jump_size

    for i in series_size:
        var new_floor = FLOOR.instantiate()
        add_child( new_floor )
        new_floor.set_position( curr_position )
        new_floor.set_scale( Vector2( floor_size, 1.0 ) )

        if ( i + 1 ) == series_size:
            var new_checkpoint = CHECKPOINT.instantiate()
            add_child( new_checkpoint )
            new_checkpoint.set_position( curr_position + Vector2( 30, -25 ) )

        curr_position.x += ( floor_size * 40.0 ) + h_jump_size
        curr_position.y -= v_jump_size


func generate_series_premade() -> void:
    #var difficulty = rng.randi_range( 0, 1 )
    var difficulty : int = difficulty_curve[times_generated % difficulty_curve.size()]
    var tile_to_use : PackedScene
    var index : int = -1

    if difficulty == 0:
        print( "Easy" )
    else:
        print( "Hard" )

    match difficulty:
        0:
            index = rng.randi_range( 0, EASY_TILE.size() - 1 )
            while index == last_tile && last_difficulty == difficulty:
                index = rng.randi_range( 0, EASY_TILE.size() - 1 )
            tile_to_use = EASY_TILE[index]
        1:
            index = rng.randi_range( 0, HARD_TILE.size() - 1 )
            while index == last_tile && last_difficulty == difficulty:
                index = rng.randi_range( 0, HARD_TILE.size() - 1 )
            tile_to_use = HARD_TILE[index]

    var new_tile = tile_to_use.instantiate()
    add_child( new_tile )
    new_tile.set_position( curr_position )

    var children = new_tile.get_children()
    var curr_floor_tile = children[children.size() - 2]
    curr_position += curr_floor_tile.position + Vector2( ( curr_floor_tile.scale.x * 40.0 ) + 90.0, 0.0 )

    last_tile = index
    last_difficulty = difficulty
    times_generated += 1
