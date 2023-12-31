class_name Math
class Lib:
	# Bitflag checks
	static func has_flag(flags: int, flag: int) -> bool:
		return (flags & flag) != 0

	static func has_all_flags(value: int, flags: int) -> bool:
		return (value & flags) == flags

	static func set_flag(flags: int, flag: int) -> int:
		return flags | flag

	static func clear_flag(flags: int, flag: int) -> int:
		return flags & ~flag

	static func toggle_flag(flags: int, flag: int) -> int:
		return flags ^ flag

	static func get_flags(value: int, n_flags: int) -> Array[bool]:
		var _r := [] as Array[bool]
		for i in n_flags:
			_r.append(has_flag(value, 1 << i))
		return _r

	# Angle and vector math

	# yes i know this is redundant but hey forget about it ok i have my cursed little freak reasons
	static func get_vec3xz(vec: Vector3, with_slide: bool = false) -> Vector3:
		return  vec.slide(Vector3.UP) if with_slide else Vector3(vec.x, 0, vec.z)

	static func get_vec3y(vec: Vector3) -> Vector3:
		return Vector3(0, vec.y, 0)

## TODO: define what order is besides ZX or signed_angle. Pseudo euler order
	static func vec_to_angle(vec, as_deg: bool = false, order: int = 0) -> float:
		var _r: float = NAN
		if (vec is Vector2i || vec is Vector2):
			_r = atan2(vec.y, vec.x)

		elif (vec is Vector3 || vec is Vector3i):
			match order:
				0: _r = atan2(vec.z, vec.x)
				_: _r = vec.signed_angle_to(Vector3.FORWARD, Vector3.UP)

		if _r != NAN:
			return rad_to_deg(_r) if as_deg else _r

		push_warning("Warning: Math.Lib.vec2ang was supplied with an invalid type. Valid types include Vector2/3 and Vector2i/3i.")
		return _r

	static func get_cgaz_angles(vel: float, max: float, opt: float, min: float) -> Array[float]:
		return [
		vel - max, vel - 90.0, vel - opt, vel - min,
		vel,
		vel + min, vel + opt, vel + 90.0, vel + max,
		] as Array[float]

	#static func vec2ang(vec: Vector2, as_deg: bool = false) -> float:
		#var _r := atan2(vec.x, vec.y)
		#return rad_to_deg(_r) if as_deg else _r
	#static func vec3ang(vec: Vector3, as_deg: bool = false, order: int = 0) -> float:
		#var _r := 0.0
		#match order:
			#0:
				#_r = atan2(vec.z, vec.x)
			#_:
				#_r = vec.signed_angle_to(Vector3.FORWARD, Vector3.UP)
#
				#if as_deg:
					#_r = rad_to_deg(_r)
		#return _r

	# TODO: make arbitrary angle calculation loop, to support N dimensional sectors, rather than 8 only
	static func get_sector(angle: float, sectors: int = 8) -> int:
		if sectors <= 0:
			return -1
			push_warning("Invalid sector count request: %s" % sectors)

		var sector_size: float = 360.0 / sectors
		var sector := floori(angle / sector_size)

		if angle > 360.0 || angle < 0.0:
			angle = fmod(angle, 360.0)
			sector = floori(angle / sector_size)

		return sector


	static func get_sprite_dir(
		sprite_xform: Transform3D,
		target_xform: Transform3D,
		only_xz: bool = true) -> int:

		var from := sprite_xform.origin
		var to := target_xform.origin
		var look_dir := -sprite_xform.basis.z

		if only_xz:
			from.y = 0
			to.y = 0
			look_dir.y = 0

		# get the sector angles by arctan then lock to 0 < x < 360.0
		var pos := vec_to_angle(from - to, true)
		var basis := vec_to_angle(from - look_dir, true)
		var angle := wrap_fmod(pos, basis, 360.0)

		return get_sector(angle)


	# custom ccd
	static func get_shape_hull(_shape: Shape3D) -> AABB:
		return _shape.get_debug_mesh().get_aabb()

	# code below has roots from idTech3 and btan2's Q_Move for Godot 3.5
	static func cast_trace(
		what: CollisionObject3D, shape: Shape3D,
		from: Vector3, to: Vector3) -> Math.Trace:

		var collided: bool = false
		var motion := to - from

		var params := PhysicsShapeQueryParameters3D.new()
		params.set_shape(shape)
		params.transform.origin = from
		params.collide_with_bodies = true
		params.set_motion(motion)
		params.exclude = [what.get_rid()]

		var space_state := what.get_world_3d().direct_space_state
		var results := space_state.cast_motion(params)

		if results[0] == 1.0:
			collided = false
			return Math.Trace.new(to)

		var end_pos := from + motion * results[1]

		params.transform.origin = end_pos

		var rest := space_state.get_rest_info(params)
		var norm := rest.get(&"normal", Vector3.UP) as Vector3

		return Math.Trace.new(end_pos, results[0], norm)


	# misc funcs
	static func _short_path(path: String, delim: String, pad: int = 0) -> String:
		var split := path.split(delim)
		var _r: String = ""

		for s in split:
			_r += (s if s == split[-1] else s[0] + delim)

		if pad > 0:
			for i in (pad - _r.length()):
				_r += " "

		return _r

	@warning_ignore("shadowed_global_identifier")
	static func wrap_fmod(x: float, y: float, range: float) -> float:
		return fmod(x - y + range, range)


# TODO: add surface flag data in player collision checks
class Trace extends RefCounted:
	var end_pos: Vector3
	var fraction: float
	var normal: Vector3
	var surface_flags: Array

	@warning_ignore("shadowed_variable")
	func _init(end_pos: Vector3, fraction: float = 1.0,  normal: Vector3 = Vector3.UP) -> void:
		self.end_pos = end_pos
		self.fraction = fraction
		self.normal = normal
		return
