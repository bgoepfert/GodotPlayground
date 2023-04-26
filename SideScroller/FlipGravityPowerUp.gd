extends Node2D

# FlipGravityPowerUp scene
# This scene consists of:
# - 2 semi-circle mesh instances that change colour to show which direction gravity will be flipped.
# - An Area2D node to capture whenever the player touches the powerup so we can trigger a function.

onready var area := $Area2D
onready var top := $TopMesh
onready var bottom := $BottomMesh

# Called when the node enters the scene tree for the first time.
func _ready():
	top.modulate = Color.white
	bottom.modulate = Color.black
	
	area.connect("body_entered", self, "on_Player_entered")

func on_Player_entered(player: Node) -> void:
	# Flip gravity direction and mesh colours
	if player.gravity_direction == Vector2.UP:
		player.gravity_direction = Vector2.DOWN
		top.modulate = Color.black
		bottom.modulate = Color.white
	# Flip gravity direction and mesh colours back to original
	elif player.gravity_direction == Vector2.DOWN:
		player.gravity_direction = Vector2.UP
		top.modulate = Color.white
		bottom.modulate = Color.black
