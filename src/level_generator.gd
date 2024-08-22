extends Node2D


@export var difficulty_curve : Array[int]
var times_generated : int = 0

var FLOOR := preload( "res://terrain/floor.tscn" )
var CHECKPOINT := preload( "res://items/checkpoint.tscn" )
var PLAYER := preload( "res://characters/player.tscn" )
var INTRO := preload( "res://sequences/s_intro.tscn" )

var player : CharacterBody2D

@export var EASY_TILE : Array[PackedScene] = [
    preload( "res://sequences/s_straight.tscn" ),
    preload( "res://sequences/s_c_horizontal_easy.tscn" ),
    preload( "res://sequences/s_c_vertical_easy.tscn" ),
    preload( "res://sequences/s_horizontal_jumps_easy.tscn"),
    preload( "res://sequences/s_vertical_jumps_easy.tscn"),
    preload( "res://sequences/s_mp_horizontal_easy.tscn" ),
    preload( "res://sequences/s_mp_vertical_easy.tscn" ),
    preload( "res://sequences/s_boost_easy.tscn" ),
]

@export var MED_TILE : Array[PackedScene] = [
    preload( "res://sequences/s_horizontal_jumps_med.tscn" ),
    preload( "res://sequences/s_vertical_jumps_med.tscn"),
    preload( "res://sequences/s_c_horizontal_med.tscn" ),
    preload( "res://sequences/s_c_vertical_med.tscn" ),
    preload( "res://sequences/s_boost_med.tscn" ),
]

@export var HARD_TILE : Array[PackedScene] = [
    preload( "res://sequences/s_mp_horizontal_hard.tscn"),
    preload( "res://sequences/s_horizontal_jumps_hard_2.tscn" ),
    preload( "res://sequences/s_vertical_hard.tscn" ),
]

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

var last_tile_easy : int = -1
var last_tile_med : int = -1
var last_tile_hard : int = -1
var last_difficulty : int = -1


func _ready() -> void:
    #var start_floor = FLOOR.instantiate()
    #add_child( start_floor )
    #start_floor.set_position( curr_position )
    #start_floor.set_scale( Vector2( max_floor_size, 1.0 ) )


    var intro_space = INTRO.instantiate()
    add_child( intro_space )
    intro_space.set_position( curr_position )

    var children = intro_space.get_children()
    var curr_floor_tile = children[children.size() - 2]

    var start_checkpoint = CHECKPOINT.instantiate()
    add_child( start_checkpoint )
    start_checkpoint.set_position( curr_position + Vector2( 30.0, -25.0 ) )
    start_checkpoint.set_name( "StartPosition" )

    player = PLAYER.instantiate()
    add_child( player )
    player.set_position( start_checkpoint.position )

    curr_position += curr_floor_tile.position + Vector2( ( curr_floor_tile.scale.x * 40.0 ) + min_h_jump_size, 0.0 )

    generate_series_premade()


func _process( _delta: float ) -> void:
    if player.position.x >= curr_position.x - 750.0:
        generate_series_premade()


func generate_series_premade() -> void:
    #var difficulty = rng.randi_range( 0, 1 )
    var difficulty : int = difficulty_curve[times_generated % difficulty_curve.size()]
    var tile_to_use : PackedScene
    var index : int = -1

    if difficulty == 0:
        print( "Easy" )
    elif difficulty == 1:
        print( "Medium" )
    else:
        print( "Hard" )

    match difficulty:
        0:
            index = rng.randi_range( 0, EASY_TILE.size() - 1 )
            while index == last_tile_easy && last_difficulty == difficulty:
                index = rng.randi_range( 0, EASY_TILE.size() - 1 )
            tile_to_use = EASY_TILE[index]
            last_tile_easy = index
        1:
            index = rng.randi_range( 0, MED_TILE.size() - 1 )
            while index == last_tile_med && last_difficulty == difficulty:
                index = rng.randi_range( 0, MED_TILE.size() - 1 )
            tile_to_use = MED_TILE[index]
            last_tile_med = index
        2:
            index = rng.randi_range( 0, HARD_TILE.size() - 1 )
            while index == last_tile_hard && last_difficulty == difficulty:
                index = rng.randi_range( 0, HARD_TILE.size() - 1 )
            tile_to_use = HARD_TILE[index]
            last_tile_hard = index

    var new_tile = tile_to_use.instantiate()
    add_child( new_tile )
    new_tile.set_position( curr_position )

    var children = new_tile.get_children()
    var curr_floor_tile = children[children.size() - 2]

    var gap_size = lerp( min_h_jump_size, max_h_jump_size, float( difficulty ) / 2.0 )
    curr_position += curr_floor_tile.position + Vector2( ( curr_floor_tile.scale.x * 40.0 ) + gap_size, 0.0 )

    last_difficulty = difficulty
    times_generated += 1
