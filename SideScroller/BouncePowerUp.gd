extends Node2D

# BouncePowerUp scene
# This scene consists of:
# - 2 triangle mesh instances that change colour to show if the power up is active or not.
# - An Area2D node to capture whenever the player touches the powerup so we can trigger a function.
# - A timer instantiated from code to create a cooldown for the powerup

# Store references to each node we will need to modify in the script,
# using the onready flag to ensure the Node has loaded into the scene
# so we don't get a null reference.
onready var area := $Area2D
onready var mesh1 := $MeshInstance2D
onready var mesh2 := $MeshInstance2D2

var _timer = null

func _ready() -> void:
	# Set the starting colour of our meshes to blue.
	mesh1.modulate = Color.blue
	mesh2.modulate = Color.blue
	
	_timer = Timer.new()
	add_child(_timer)
	
	# Connect the body_entered signal to the _on_Player_entered function found
	# in this script (self).
	area.connect("body_entered", self, "_on_Player_entered")
	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.set_wait_time(2)
	_timer.set_one_shot(true) # Make sure it doesn't loop

func _on_Player_entered(player: Node) -> void:
	# If the timer is inactive, the player can use the power up.
	if _timer.time_left == 0.0:
		# If the players velocity.y is positive, they are moving towards the ground,
		# so we first set their velocity.y to 0
		if player.velocity.y > 0:
			player.velocity.y = 0.0
		# Now we can add the boost to their current velocity, giving them a "super jump".
		# Note: We could just set velocity.y to -1500.0 rather than decreasing it by -1500.0,
		#       but this way the user can use the boost in different ways, by timing when in
		#       their jump they want to hit the boost, rather than it being the same boost
		#       regardless of when they hit it.
		player.velocity.y -= 1500.0
		# Start the pickup cooldown timer
		_timer.start()
		# Set the meshes colours to black to indicate the boost cannot be used.
		mesh1.modulate = Color.black
		mesh2.modulate = Color.black

# When the cooldown (timer) is over, set the meshes colours back to blue to indicate it can be used again.
func _on_Timer_timeout() -> void:
	mesh1.modulate = Color.blue
	mesh2.modulate = Color.blue
