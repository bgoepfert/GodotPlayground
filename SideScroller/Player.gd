extends KinematicBody2D

# Player scene
# This scene consists of:
# - A KinematicBody2D which gives us functions for player movement like move_and_slide.
# - A capsule mesh instance to represent the player body
# - A Camera2D which is set to "current", so will be the active camera and will follow the player.
# - A CanvasLayer for the UI with 2 labels showing the controls and players stamina.

var _timer = null

const GRAVITY := 4500.0
const SPEED := 450.0
const JUMP_STRENGTH := 1000.0

onready var stamina_label := $CanvasLayer/Label

var velocity := Vector2.ZERO
var jump_stamina_cost := 30.0
var wall_jumps := 1
var gravity_direction := Vector2.UP

# Warning!: setget variables will only use the specified setter and getter functions when the
#           variable is changed from an EXTERNAL source, i.e. assigning a new value to stamina
#           from within this file/class will NOT call _set_stamina automatically.
var stamina := 100.0 setget _set_stamina
func _set_stamina(new_value: float) -> void:
	stamina = clamp(new_value, 0.0, 100.0)

func _ready():
	_timer = Timer.new()
	add_child(_timer)

	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.set_wait_time(1.5)
	_timer.set_one_shot(false) # Make sure it loops
	_timer.start()


func _on_Timer_timeout():
	_set_stamina(stamina + 20.0)

func _process(delta):
	stamina_label.text = "Stamina: " + str(stamina)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# get_axis returns a number between -1 and 1 from the input strength
	# of the given inputs, giving us a direction on a single axis
	# -1 for left, 1 for right, on a keyboard the input strength is either 0 or +/-1,
	# but on a joystick the strength can be anywhere between 0 to +/-1.
	# P.S. If both inputs are pressed at the same time, they are added together,
	# which on a keyboard will be -1 + 1 = 0.
	var input := Input.get_axis("move_left", "move_right")
	# Our x direction is now just the input above * speed to give us a horizontal velocity.
	# The move_and_slide function handles multiplying our velocity by the 
	# delta argument, so we do not need to include delta in our velocity calculations.
	velocity.x = input * SPEED
	# We want to constantly apply gravity to our player, and the player
	# should gain speed as they fall. delta is the time since the last frame, so it will
	# always be a very small number. We continually increase our y velocity
	# by GRAVITY * delta to simulate falling speed. You could also
	# use a smaller number for GRAVITY and not use delta, however then
	# the player would have a linear falling speed which doesn't feel as realistic.
	if gravity_direction == Vector2.UP:
		velocity.y += GRAVITY * delta
	elif gravity_direction == Vector2.DOWN:
		velocity.y -= GRAVITY * delta
	
	# is_jumping checks if the player pressed the jump input every frame.
	var is_jumping := Input.is_action_just_pressed("jump")
	# jump_cancelled checks if the player released the jump input every frame.
	var jump_cancelled := Input.is_action_just_released("jump")
	# We check if the player is pressing the jump action, and also that the player
	# has enough stamina to jump.
	if is_jumping and stamina >= jump_stamina_cost:
		# If the player has enough stamina to jump, we apply a velocity in the opposite direction
		# to the current gravity direction. This looks a bit counter-intuitive,
		# but in 2D, co-ordinates start at 0,0 in the top left corner, and negative y is up and
		# positive y is down.
		#
		# Note: Since gravity is constantly applied, even when the player is on the ground,
		# if the player stays on the ground their velocity.y value will become infinitely larger/smaller
		# over time. This is why we override the existing value with the
		# jump strength rather than just adding or subtracting from it.
		if gravity_direction == Vector2.UP:
			velocity.y = -JUMP_STRENGTH
		elif gravity_direction == Vector2.DOWN:
			velocity.y = JUMP_STRENGTH
		# We reduce the players stamina by 20.0 every time they jump.
		_set_stamina(stamina - 20.0)
	elif wall_jumps > 0 and is_on_wall():
		# We increase the players stamina by 20 if they touch a wall, allowing a "wall jump",
		# and reduce their available wall jumps by 1.
		wall_jumps -= 1
		_set_stamina(stamina + 20.0)

	elif jump_cancelled:
		# If the player releases the jump input, we reset their y velocity to 0, cancelling
		# their UP velocity, letting gravity take over straight away.
		velocity.y = 0.0
	elif is_on_floor():
		# We reset the players available wall jumps when they touch the floor.
		# The floor is determined by the second argument to move_and_slide.
		wall_jumps = 1

	# We pass our velocity to move_and_slide which provides basic movement and collision
	# for a KinematicBody.
	#
	# We also use gravity_direction for the up direction, otherwise is_on_floor() wouldn't work
	# properly after the player flips gravity, so their wall jumps wouldn't reset.
	move_and_slide(velocity, gravity_direction)
