extends CharacterBody2D
class_name Player

var modifier : float = 100.0

var gravity : float = 10.0
var walk_speed : float = 400.0

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

var friction : float = 0.1
var accel : float = 0.25

func _draw() -> void:
    pass


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


func _physics_process(_delta: float) -> void:
    pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    var inputDirection = Input.get_axis( "walk_left", "walk_right" )
    velocity.y += gravity * delta * modifier

    if inputDirection != 0:
        var walkAmount = inputDirection * walk_speed * delta * modifier
        velocity.x = lerp( velocity.x, walkAmount , accel )
    else:
        velocity.x = lerp( velocity.x, 0.0, friction )

    var last_collision_result = is_on_floor()
    var collision_result = move_and_slide()

    if !collision_result && last_collision_result:
        can_coyote_jump = true

    if Input.is_action_just_pressed( "jump" ):
        has_jump_input = true
        if !is_on_floor():
            jump_memory_timer.start()


    if (is_on_floor() || can_coyote_jump) && has_jump_input:
        has_jump_input = false
        velocity.y = jump_speed * modifier
