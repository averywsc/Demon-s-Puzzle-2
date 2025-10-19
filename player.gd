extends CharacterBody3D

# --- Movement Variables ---
@export var SPEED: float = 5.0
@export var SPRINT_SPEED: float = 8.0
@export var JUMP_VELOCITY: float = 4.5

# --- Mouse Look Variables ---
@export var MOUSE_SENSITIVITY: float = 0.002
const PITCH_LIMIT = deg_to_rad(89.0) # Limit for looking up and down

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# This node will be used to rotate the camera up and down.
@onready var camera_pivot: Node3D = $CameraPivot

func _ready() -> void:
	# This hides the mouse cursor and keeps it centered.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	# Handle mouse motion for looking around.
	if event is InputEventMouseMotion:
		# Rotate the entire CharacterBody left and right (yaw).
		self.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		# Rotate the camera pivot up and down (pitch).
		camera_pivot.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		# Clamp the camera's rotation to prevent it from flipping over.
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -PITCH_LIMIT, PITCH_LIMIT)

	# Allow the player to release the mouse cursor by pressing Escape.
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	# --- Gravity ---
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# --- Jumping ---
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# --- Movement ---
	# Determine current speed.
	var current_speed = SPRINT_SPEED if Input.is_action_pressed("sprint") else SPEED

	# Get the input direction and handle the movement/deceleration.
	# Input.get_vector() is a handy function that gets WASD/arrow key input.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Apply movement velocity.
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		# If no input, slow down (friction).
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	# --- Apply Movement ---
	move_and_slide()
