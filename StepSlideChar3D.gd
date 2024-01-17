class_name StepSlideChar3D extends Node3D

const MAX_CLIP_PLANES: int = 5

enum Event {
	JUMP,
	LAND,
}

enum State {
	## Walking on surface with (relatively) shallow floor angle
	WALK,

	## Moving through the air, or when on surface with sufficiently steep angled normal
	FLY,

	## In a body of water
	SWIM,

	## Climbing a ladder
	LDDR,

	## Alive, but controls locked
	FRZN,

	## Dead
	DEAD,

	## You know what this does
	NCLP
	}

var state: State = State.FLY:
	set = set_state


func set_state(value: State) -> void:
	prev_state = state
	state = value
	return

var prev_state: State = State.FLY
var prev_pos: Vector3

var walking: bool
var ground_plane: bool
var ground_normal: Vector3

var SPEED: float
var ACCEL: float
var GRAVITY: float

var surface_flags: int

# the target to affect. normally, should be the owner.
var actor: Actor
var dead: bool = false
var fsu: Vector4
var delta: float
var wish_dir: Vector3

# conditions
var water_level: int = 0:
	set(value):
		prev_water_level = water_level
		water_level = value

var prev_water_level: int = 0

@warning_ignore("shadowed_variable")
func assign(actor: Actor) -> void:
	self.actor = actor
	return


@warning_ignore("shadowed_variable")
func move(delta: float) -> void:
	self.delta = delta
	check_pos()
	update()
	sm_enter()
	return


func check_pos() -> void:
	ground_plane = false
	ground_normal = Vector3.UP
	water_level = 0
	surface_flags = 0

	# ladders go here

	#for zone: FuncZone in actor.cur_zones:
		#if zone.type in [FuncZone.Type.WATER, FuncZone.Type.ACID]:
			#if zone.get_aabb().encloses(actor.get_hull()):
				#water_level = 2
				#break
#
			#elif zone.get_aabb().intersects(actor.get_hull()):
				#water_level = 1
#
			#else:
				#water_level = 0


	var collision := KinematicCollision3D.new()
	var trace := actor.test_move(actor.global_transform, Vector3.DOWN * 0.01, collision, 0.00, false, 1)

	if trace:
		ground_plane = true
		ground_normal = collision.get_normal(0)

		# NOTE: This is a reference to a custom entity. You can ignore this.
		for i in collision.get_collision_count():
			var collider := collision.get_collider(i)
			if collider is Geometry:
				surface_flags |= int(str((collider as Geometry).properties.get("surface_flags", 0)))

	return


func update() -> void:
	walking = false
	actor.collision_mask = 0xB

	GRAVITY = DEFAULT.GRAVITY
	SPEED = DEFAULT.AM_SPEED
	ACCEL = DEFAULT.AM_AIRACCEL

	wish_dir = (fsu[1] * global_transform.basis.x + fsu[0] * -global_transform.basis.z).normalized().slide(ground_normal)

	#if actor.flags & Actor.Flag.DEAD:
		#state = State.DEAD
#
		## corpse can fly through bodies
		#actor.collision_mask = 0b1
		#return

	if water_level > 0:
		state = State.SWIM
		ACCEL = DEFAULT.AM_WATERACCEL
		SPEED = (DEFAULT.AM_SWIMMOD if water_level > 1 else DEFAULT.AM_WADEMOD)
		GRAVITY = DEFAULT.GRAVITY_WATER
		return

	#if actor.flags & Actor.Flag.FROZEN:
		#state = State.FRZN
		#wish_dir = Vector3.ZERO
		#return

	#if actor.flags & Actor.Flag.RESPAWNED:
		#if !Input.is_anything_pressed():
			#actor.flags &= ~Actor.Flag.RESPAWNED
		#return

	if (ground_plane && ground_normal.y > 0.7):
		if state == State.FLY:
			crash_land()

		state = State.WALK
		walking = true

		if surface_flags & 2:
			ACCEL = DEFAULT.AM_AIRACCEL

		else:
			ACCEL = DEFAULT.AM_ACCEL

	else:
		state = State.FLY

	return

func sm_enter() -> void:
	prev_pos = actor.global_position

	if state == State.SWIM:
		water_jump()

	else:
		if jump():
			pass
			#Events.audio("res://assets/sounds/footstep/concrete/concrete_jump0%s.wav" % randi_range(1, 7), randf_range(0.7, 0.8), randf_range(0.9, 1.1) )

	actor.velocity += accelerate(actor.velocity, wish_dir, SPEED, ACCEL) * wish_dir

	# NOTE: actor.PlayerState is an extra data object here I use every frame to transmit data to
	# many many places. You can ignore this, too.
	if actor.ps:
		actor.ps.velocity = actor.velocity
		Events.relay(Events.ps_upd, actor.ps)

	friction()

	if state == State.FLY:
		move_air()

	else:
		move_walk()

	return


func push(force: float = 200.0, dir := Vector3.UP) -> void:
	actor.velocity += (DEFAULT.SCALE_FACTOR * force) * dir
	return

# TODO: multiple ramp jumps get eaten up? Fix. -- Was jump buffer. Fixed and removed
# Jump buffer just wasn't even fun really only made things worse so now you have DUSK autojump
func jump() -> bool:
	if (
		#actor.flags & Actor.Flag.RESPAWNED ||
		fsu[2] < 1 || !walking):
		return false

	fsu[2] = 0
	actor.velocity.y += DEFAULT.AM_JUMP
	ground_normal = Vector3.ZERO
	ground_plane = false
	walking = false

	return true


func crash_land() -> void:
	#Game.dbg("crashland")
	return


func water_jump() -> bool:
	return false

@warning_ignore("shadowed_variable")
func accelerate(vel: Vector3, wish_dir: Vector3, wish_speed: float, acceleration: float) -> float:
	#if actor.flags & actor.Flag.DEAD:
		#return 0.0

	var current_speed := vel.dot(wish_dir)
	var add_speed := wish_speed - current_speed

	if add_speed <= 0:
		return 0.0

	var accel := wish_speed * acceleration * delta

	if accel > add_speed:
		accel = add_speed

	return accel


func friction() -> void:
	var vel := actor.velocity

	if walking:
		vel[1] = 0

	var speed := vel.length()

	if speed < 1 * DEFAULT.SCALE_FACTOR:
		actor.velocity = Math.Lib.get_vec3y(vel)
		return

	var drop: float = 0.0
	var control: float = 0.0

	if !water_level:
		if walking && !(surface_flags & 2):
			#if !(actor.flags & Actor.Flag.STUNNED):
				control = DEFAULT.AM_STOPSPEED if speed < DEFAULT.AM_STOPSPEED else speed
				drop += control * DEFAULT.AM_FRIC * delta

	if water_level:
		drop += speed * DEFAULT.AM_WATERFRIC * delta

	var mod: float = speed - drop

	if mod < 0.0:
		mod = 0.0

	mod /= speed

	actor.velocity *= mod

	return


func clip_velocity(vel: Vector3, normal: Vector3, overbounce: float = 1.0) -> Vector3:
	if overbounce == 1.0:
		return vel.slide(normal)

	else:

		var backoff := vel.dot(normal)
		var adj := (backoff * overbounce) if backoff < 0 else (backoff / overbounce)
		return vel - (normal * adj)


func move_air() -> void:
	actor.velocity.y -= delta * GRAVITY

	# you should add your max Y height check here like this
	#if global_position.y > ps.prev_tr.origin.y:
		#ps.prev_tr.origin.y = global_position.y

	var subdelta := delta / MAX_CLIP_PLANES
	for i in MAX_CLIP_PLANES:
		var collision := actor.move_and_collide(actor.velocity * subdelta)

		if collision:
			if actor.velocity.dot(collision.get_normal(0)) < 0:
				actor.velocity = clip_velocity(actor.velocity, collision.get_normal(0))
				# actor.velocity should slide along the surface normal
	return


func move_walk() -> void:
	if surface_flags & 2:
		actor.velocity.y -= delta * GRAVITY

	var subdelta := delta / 5
	for i in MAX_CLIP_PLANES:
		var collision := actor.move_and_collide(actor.velocity * subdelta)

		if collision:
			var normal := collision.get_normal()

			if normal.y < 0.7:
				if actor.velocity.dot(normal) < 0.0 && !move_step(actor, collision):
					actor.velocity = clip_velocity(actor.velocity, normal)

			else:
				actor.velocity = clip_velocity(actor.velocity, normal)

	return


func move_step(shape: CollisionObject3D, collision: KinematicCollision3D) -> bool:
	var vel: Vector3 = actor.velocity.normalized() * SPEED if actor.velocity.length_squared() < SPEED * SPEED else actor.velocity

	var collider := collision.get_collider()
	var norm := collision.get_normal()

	# shouldn't happen, but
	if !collider || !norm:
		return false

	if !is_valid_collider(collider):
		return false

	var original_pos: Vector3 = shape.global_position
	var step_pos: Vector3 = original_pos

	# TODO: add check for sufficiently small actor velocity
	# Step pos x/z should have a minimum offset
	## WAREYA WAS RIGHT ALL ALONG!
	# This hsould be fixed actually, but I'm leaving this funny comment


	# we desire going this far
	step_pos += Math.Lib.get_vec3xz(vel) * delta
	step_pos.y += DEFAULT.AM_STEP_HEIGHT

	# check upwards to see if we can clear the step
	var up := Math.Lib.cast_trace(actor, actor.hitbox.shape, shape.global_position, shape.global_position + Vector3.UP * DEFAULT.AM_STEP_HEIGHT)

	# if the final distance is less, cap the check height to ensure stairs are reversible
	if up.end_pos.y < step_pos.y:
		step_pos.y = up.end_pos.y

	# now cast forwards to see how far the step goes
	var fwd := Math.Lib.cast_trace(actor, actor.hitbox.shape, up.end_pos, step_pos)

	# from there we either hit something or again went the full distance
	# at the end of that trace, go back down to find the floor
	var _d := Vector3(fwd.end_pos.x, original_pos.y, fwd.end_pos.z)
	var down := Math.Lib.cast_trace(actor, actor.hitbox.shape, fwd.end_pos, _d)

	if down.end_pos.y > original_pos.y && down.normal.y > 0.7:
		actor.global_position = down.end_pos
		return true

	return false


func is_valid_collider(collider: Object) -> bool:
	if !(collider is CSGShape3D) && !(collider is CollisionObject3D):
		return false

	if collider is CSGShape3D:
		if !((collider as CSGShape3D).collision_layer & 1):
			return false

	elif collider is CollisionObject3D:
		if !((collider as CollisionObject3D).collision_layer & 1):
			return false

	return true

