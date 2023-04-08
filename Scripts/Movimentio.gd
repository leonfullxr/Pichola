extends KinematicBody2D 

export var canJump :bool = true
export var canDash :bool = true
export var canMove :bool = true
export var canWallJump :bool = true
export var exraJumps :int = 1
export var number_of_dashes = 1
export var dash_distanece :float = 200
export var dash_duration :float = 0.1
var force_right_mov = false
var block_right_mov = false
var force_left_mov = false
var block_left_mov = false
export var MAX_SPEED = 300.0
export var ACCEL_TIME = 0.2
export var DECEL_TIME = 0.1
export var ON_AIR_FACTOR = 1.2
var X_ACCEL :float
var X_DECEL :float
var looking_rigth :bool = true

export var MAX_JUMP_HEIGHT = -50.0
export var RISING_TIME = 0.2
export var FALLING_TIME = 0.1
export var SECOND_JUMP_HEIGHT_FACTOR = 0.7
export var MAX_FALLING_SPEED_FACOR = 1
export var WALL_JUMP_BLOCK_TIME :float = 0.1
export var WALL_SPEED_FACTOR :float = 0.4
var MAX_FALLING_SPEED :float
var RISING_POS :Parabola
var FALLING_POS :Parabola
var rising_timer :SceneTreeTimer
var jumps_left
var dashes_left

export var flipWithVel :bool = true

var jump_origin :Vector2
signal jump
signal exrta_jump
signal wall_jump
signal below_jum_height
signal flor_touched
signal dashed

var is_paused = false
var hitting_floor :bool = false 
var was_on_floor :bool = true
var dashing :bool = false
var current_check_point :Area2D
var initial_pos : Vector2
var pos_when_entering_checkpoint : Vector2
var below_jump_height_notified = true
var on_floor_notified = true
var velocity :Vector2 = Vector2(0, 0)
func _ready():
	initalizeValues()
	connectSignals()

func _physics_process(delta):
	if dashing:
		pass
	elif Input.is_action_just_pressed("DASH") and dashes_left > 0 and canDash:
		dash()
	elif collidingWithWall() and not custom_is_on_floor() and canWallJump():
		onWallbehaviour(delta)
	else:
		setVertialVel(delta)
		setHorizontalVel(delta)
	
	move_and_slide(velocity, Vector2(0, -1))
	
	flip()
	
	if position.y >= jump_origin.y and not below_jump_height_notified:
		emit_signal("below_jum_height")
		below_jump_height_notified = true
	
	if custom_is_on_floor() and not on_floor_notified:
		emit_signal("flor_touched")
		on_floor_notified = true
	
	if custom_is_on_floor() and not initial_pos:
		initial_pos = position
	
	if custom_is_on_floor():
		$animation_tree_bird.set("parameters/ground_air_or_wall/current", 0)
	elif collidingWithWall() and canWallJump():
		$animation_tree_bird.set("parameters/ground_air_or_wall/current", 2)
	else:
		$animation_tree_bird.set("parameters/ground_air_or_wall/current", 1)
	
	if custom_is_on_floor() and not was_on_floor:
		hitGround()
	
	was_on_floor = custom_is_on_floor()


func initalizeValues():
	# Vertical Movment
	RISING_POS = Parabola.new(-MAX_JUMP_HEIGHT/pow(RISING_TIME, 2), 2*MAX_JUMP_HEIGHT/RISING_TIME, 0)
	FALLING_POS = Parabola.new(-MAX_JUMP_HEIGHT/pow(FALLING_TIME, 2), 0, MAX_JUMP_HEIGHT)
	MAX_FALLING_SPEED = FALLING_POS.derivative_on(FALLING_TIME)*MAX_FALLING_SPEED_FACOR
	rising_timer = get_tree().create_timer(0)
	jumps_left = exraJumps
	dashes_left = number_of_dashes
	
	# Horizontal Movment
	X_ACCEL = MAX_SPEED / ACCEL_TIME
	X_DECEL = MAX_SPEED / DECEL_TIME 
	
	initial_pos = position
	
	$animation_tree_bird.active = true
	$animation_tree_bird.set("parameters/DashTimeScale/scale", 0.6/dash_duration)

func connectSignals():
	connect("dashed", self, "activateDashingAnim")


func onWallbehaviour(delta):
	var wall_on_left = collidingWithLefthWall()
	
	if Input.is_action_just_pressed("JUMP"):
		emit_signal("wall_jump")
		$animation_tree_bird.set("parameters/air_state/current", 3)
		velocity.y = RISING_POS.derivative_on(0)
		if wall_on_left:
			velocity.x = MAX_SPEED
			forceRigthInput(WALL_JUMP_BLOCK_TIME)
		else:
			velocity.x = -MAX_SPEED
			forceLeftInput(WALL_JUMP_BLOCK_TIME)
	else:
		if velocity.y <= 0 or Input.is_action_pressed("DOWN"):
			setVertialVel(delta)
		else:
			var vel_y_before = velocity.y
			setVertialVel(delta)
			var vel_cahnge = velocity.y - vel_y_before
			velocity.y = min(MAX_FALLING_SPEED * WALL_SPEED_FACTOR, velocity.y + vel_cahnge * MAX_FALLING_SPEED)
		setHorizontalVel(delta)
	


func setVertialVel(delta):
	if Input.is_action_just_pressed("JUMP") and custom_is_on_floor() and canJump: # Just jumped
		rising_timer = get_tree().create_timer(RISING_TIME)
		velocity.y = RISING_POS.derivative_on(0)
		jump_origin = position
		below_jump_height_notified = false
		on_floor_notified = false
		emit_signal("jump")
		$animation_tree_bird.set("parameters/air_state/current", 2)
	elif Input.is_action_just_pressed("JUMP") and not custom_is_on_floor() and jumps_left > 0 and canJump: # extra jumps
		dontFocreAnything()
		rising_timer = get_tree().create_timer(RISING_TIME * SECOND_JUMP_HEIGHT_FACTOR)
		velocity.y = RISING_POS.derivative_on(0) * SECOND_JUMP_HEIGHT_FACTOR
		jumps_left -= 1
		emit_signal("exrta_jump")
		$animation_tree_bird.set("parameters/air_state/current", 0)
	elif Input.is_action_pressed("JUMP") and rising_timer.time_left > 0 and not $WallCollision/Cealing.get_overlapping_bodies().size() != 0: # Rising
		velocity.y += RISING_POS.second_derivative() * delta
	elif not custom_is_on_floor() and velocity.y < 0 and $WallCollision/Cealing.get_overlapping_bodies().size() != 0: # Colliding with cealing
		velocity.y = 0
	elif not custom_is_on_floor(): # Falling
		var change_in_vel = FALLING_POS.second_derivative() * delta
		var curr_max_speed = MAX_FALLING_SPEED
		
		if velocity.y < 0:
			change_in_vel *= 2
		
		if Input.is_action_pressed("JUMP"):
			change_in_vel *= 0.8
		
		if Input.is_action_pressed("DOWN") and not collidingWithWall():
			curr_max_speed *= 1.5
		
		velocity.y = min(velocity.y + change_in_vel, curr_max_speed)
		
		if velocity.y > 0:
			$animation_tree_bird.set("parameters/air_state/current", 1)
			$animation_tree_bird.set("parameters/FallingSpeed/scale", velocity.y/MAX_FALLING_SPEED)
		
	else: #On ground
		jumps_left = exraJumps
		dashes_left = number_of_dashes
		velocity.y = 0

func setHorizontalVel(delta):
	var direction = 0
	
	if inputMovingRigth():
		if force_right_mov:
			direction += 1
		else:
			direction += Input.get_action_strength("MOVE_RIGTH")
	
	if inputMovingLeft():
		if force_left_mov:
			direction -= 1
		else:
			direction -= Input.get_action_strength("MOVE_LEFT")
	
	
	var curr_max_speed = MAX_SPEED
	
	if not custom_is_on_floor():
		curr_max_speed *= ON_AIR_FACTOR
	
	
	# Moverse
	var pot_vel1 = velocity.x + direction*X_ACCEL*delta
	if not canMove:
		pass
	elif abs(pot_vel1) <= curr_max_speed:
		velocity.x = pot_vel1
	elif abs(velocity.x) < curr_max_speed:
		velocity.x = curr_max_speed * sign(pot_vel1)
	
	# Frenar
	if direction == 0 or sign(direction) != sign(velocity.x) or abs(velocity.x) > curr_max_speed:
		var curr_decel = X_DECEL
		if abs(velocity.x) > curr_max_speed and sign(direction) == sign(velocity.x):
			curr_decel *= 0.2
		
		var pot_vel2 = velocity.x - curr_decel*delta * sign(velocity.x)
		if sign(pot_vel2) != sign(velocity.x):
			velocity.x = 0
		else:
			velocity.x = pot_vel2
	
	if collidingWithRigthWall():
		velocity.x = min(0, velocity.x)
	
	if collidingWithLefthWall():
		velocity.x = max(0, velocity.x)
	
	if hitting_floor:
		pass
	elif abs(velocity.x) > 0:
		$animation_tree_bird.set("parameters/movement_velocity/scale", MAX_SPEED/abs(velocity.x))
		$animation_tree_bird.set("parameters/OnGroundState/current", 1)
	else:
		$animation_tree_bird.set("parameters/OnGroundState/current", 0)

func dash():
	dashing = true
	var direction :Vector2= Input.get_vector("MOVE_LEFT", "MOVE_RIGTH", "UP", "DOWN")
	
	if direction != Vector2.ZERO:
		direction = closestCardinalDirection(direction)
		
		velocity = dash_distanece/dash_duration * direction.normalized()
		
		if custom_is_on_floor() and (direction.angle() >= 0 or direction.angle() <= -PI + 0.001):
			$animation_tree_bird.set("parameters/DashType/current", 0)
		elif $Sprite.flip_h == false:
			$Sprite.rotation = direction.angle()
			$animation_tree_bird.set("parameters/DashType/current", 1)
		else:
			$Sprite.rotation = direction.angle() + PI
			$animation_tree_bird.set("parameters/DashType/current", 1)
		print()
		
	else:
		if looking_rigth:
			velocity = dash_distanece/dash_duration * Vector2.RIGHT
		else:
			velocity = dash_distanece/dash_duration * Vector2.LEFT
		
		if custom_is_on_floor():
			$animation_tree_bird.set("parameters/DashType/current", 0)
		else:
			$animation_tree_bird.set("parameters/DashType/current", 1)
	
	emit_signal("dashed")
	dashes_left -= 1
	
	yield(get_tree().create_timer(dash_duration), "timeout")
	dashing = false
	$Sprite.rotation = 0
	$animation_tree_bird.set("parameters/dash_or_not/current", 1)

func flip():
	if dashing or is_paused:
		pass
	elif collidingWithLefthWall() and not custom_is_on_floor() and canWallJump():
		$Sprite.flip_h = false
		looking_rigth = true
	elif collidingWithRigthWall() and not custom_is_on_floor() and canWallJump():
		$Sprite.flip_h = true
		looking_rigth = false
	elif not flipWithVel and (Input.is_action_pressed("MOVE_RIGTH") or Input.is_action_pressed("MOVE_LEFT")):
		if Input.is_action_pressed("MOVE_RIGTH"):
			$Sprite.flip_h = false
		elif Input.is_action_pressed("MOVE_LEFT"):
			$Sprite.flip_h = true
	elif flipWithVel:
		if velocity.x > 0:
			$Sprite.flip_h = false
		elif velocity.x < 0:
			$Sprite.flip_h = true
	
	if not collidingWithWall() or custom_is_on_floor():
		if Input.is_action_pressed("MOVE_RIGTH"):
			looking_rigth = true
		elif Input.is_action_pressed("MOVE_LEFT"):
			looking_rigth = false

func forceRigthInput(duration):
	force_right_mov = true
	force_left_mov = false
	block_left_mov = true
	block_right_mov = false
	yield(get_tree().create_timer(duration), "timeout")
	force_right_mov = false
	block_left_mov = false

func forceLeftInput(duration):
	force_left_mov = true
	force_right_mov = false
	block_right_mov = true
	block_left_mov = false
	yield(get_tree().create_timer(duration), "timeout")
	force_left_mov = false
	block_right_mov = false
	
	
func dontFocreAnything():
	force_right_mov = false
	block_left_mov = false
	force_left_mov = false
	block_right_mov = false

func inputMovingRigth() -> bool:
	return (Input.is_action_pressed("MOVE_RIGTH") or force_right_mov) and not block_right_mov

func inputMovingLeft() -> bool:
	
	return (Input.is_action_pressed("MOVE_LEFT") or force_left_mov) and not block_left_mov

func collidingWithWall() -> bool:
	return collidingWithRigthWall() or collidingWithLefthWall()

func collidingWithRigthWall() -> bool:
	return $WallCollision/Right.get_overlapping_bodies().size() > 0

func collidingWithLefthWall() -> bool:
	return $WallCollision/Left.get_overlapping_bodies().size() > 0

func update_check_point(check_point):
	if not current_check_point:
		current_check_point = check_point
	elif current_check_point.check_point_priority <= check_point.check_point_priority:
		current_check_point = check_point
	
	pos_when_entering_checkpoint = position


func respawn():
	if current_check_point:
		position.x = current_check_point.get_node("Where").global_position.x
		position.y = pos_when_entering_checkpoint.y
	else:
		position = initial_pos

func activateDashingAnim():
	$animation_tree_bird.set("parameters/dash_or_not/current", 0)

func custom_is_on_floor():
	return $WallCollision/Floor.get_overlapping_bodies().size() > 0 or is_on_floor()

func hitGround():
	$animation_tree_bird.set("parameters/OnGroundState/current", 2)
	hitting_floor = true
	yield(get_tree().create_timer(0.03), "timeout")
	hitting_floor = false

func closestCardinalDirection(direction :Vector2):
	var pairs :Array = []
	var min_dif_angle = PI
	var min_dif = abs(direction.angle() - PI)
	
	for i in 8:
		var angle = PI - TAU/8 * i
		if abs(direction.angle() - angle) < min_dif:
			min_dif = abs(direction.angle() - angle)
			min_dif_angle = angle
	
	return Vector2.RIGHT.rotated(min_dif_angle) * direction.length()

func canWallJump():
	return canJump and canWallJump

var canMoveBP = false
var canJumpBP = false
var canWallJumpBP = false
var canDashBP = false

func pause():
	print("paused")
	canMoveBP = canMove
	canJumpBP = canJump
	canWallJumpBP = canWallJump
	canDashBP = canDash
	$"../PicholaFollower".is_paused = true
	
	is_paused = true
	canMove = false
	canJump = false
	canWallJump = false
	canDash = false

func unpause():
	canMove = canMoveBP
	canJump =  canJumpBP
	canWallJump = canWallJumpBP
	canDash = canDashBP
	$"../PicholaFollower".is_paused = false
	
	is_paused = false
