extends CharacterBody3D

# Speed of the enemy in meters per second.
@export var SPEED = 3.0

# A reference to the NavigationAgent3D node.
# The @onready keyword makes sure the variable is assigned right before the game starts.
@onready var nav_agent = $NavigationAgent3D

func _ready():
	# We want the enemy to start moving as soon as it's in the game.
	# So, we call the function to pick a new destination.
	pick_random_destination()

func _physics_process(delta):
	# First, check if the navigation agent has finished its path.
	if nav_agent.is_navigation_finished():
		# If it has, pick a new random spot to walk to.
		pick_random_destination()
		return # Stop processing this frame to avoid issues.

	# Get the current position of the enemy.
	var current_location = global_transform.origin
	# Get the next position on the path the agent wants to go to.
	var next_location = nav_agent.get_next_path_position()
	
	# Calculate the direction from the enemy to the next point.
	var new_velocity = (next_location - current_location).normalized() * SPEED
	
	# Set the velocity and use move_and_slide to move the character.
	velocity = new_velocity
	move_and_slide()

# This function picks a random spot in the room.
func pick_random_destination():
	# NOTE: Change these X and Z values to match the size of your room!
	# This picks a random X between -10 and 10, and a random Z between -10 and 10.
	var random_x = randf_range(-10.0, 10.0)
	var random_z = randf_range(-10.0, 10.0)
	
	# Set the navigation agent's target destination.
	# It will automatically calculate the path on the NavMesh.
	nav_agent.target_position = Vector3(random_x, global_position.y, random_z)

# This function will run when something enters the enemy's Hitbox.
func _on_hitbox_body_entered(body):
	# Check if the body that entered is in the "player" group.
	if body.is_in_group("player"):
		print("Player touched! Game Over.")
		# Reloads the entire scene, effectively restarting the level.
		get_tree().reload_current_scene()
