extends CharacterBody2D


var gravity : float = 15.0
var modifier : float = 100.0

func _physics_process( delta: float ) -> void:
    velocity.y += gravity * delta * modifier
    move_and_slide()
