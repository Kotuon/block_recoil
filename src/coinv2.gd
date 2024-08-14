extends CharacterBody2D


@onready var lifetime_timer := $Lifetime
var gravity : float = 15.0
var modifier : float = 100.0

func _ready() -> void:
    var timeout_lifetime = func():
        queue_free()
    lifetime_timer.connect( "timeout", timeout_lifetime )

func _physics_process( delta: float ) -> void:
    velocity.y += gravity * delta * modifier
    move_and_slide()
