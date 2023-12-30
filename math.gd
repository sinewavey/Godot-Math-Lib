class_name Math
class Lib:
	# Bitflag checks
	static func has_flag(flags: int, flag: int) -> bool:
		return (flags & flag) != 0

	static func set_flag(flags: int, flag: int) -> int:
		return flags | flag

	static func clear_flag(flags: int, flag: int) -> int:
		return flags & ~flag

	static func toggle_flag(flags: int, flag: int) -> int:
		return flags ^ flag

	static func has_each_flag(value: int, flags: Array[int]) -> Array[bool]:
		var _r: Array[bool]
		for flag in flags:
			_r.append(true if value & flag else false)
		return _r


	static func has_flags(value: int, flags: Array[int]) -> bool:
		for flag: int in flags:
			if value & flag:
				return true
		return false


	static func get_flags(value: int, n_flags: int) -> Array[bool]:
		var _a := [] as Array[bool]

		for i in n_flags:
			_a.append(has_flag(value, 1 << i))

		return _a

	# Angle math
	static func get_sector(angle: float) -> int:
		if angle > 22.6 && angle <= 67.5:
			return 1

		if angle > 67.6 && angle <= 112.5:
			return 2

		if angle > 112.6 && angle <= 157.5:
			return 3

		if angle > 157.6 && angle <= 202.5:
			return 4

		if angle > 202.6 && angle <= 247.5:
			return 5

		if angle > 247.6 && angle <= 292.5:
			return 6

		if angle > 292.3 && angle <= 337.5:
			return 7

		return 0

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
		var pos := vec3ang(from - to, true)
		var basis := vec3ang(from - look_dir, true)
		var angle := wrap_fmod(pos, basis, 360.0)

		return get_sector(angle)


	static func flat_vec3(vec: Vector3) -> Vector3:
		return Vector3(vec.x, 0, vec.z)


	static func vec3ang(vec: Vector3, as_deg: bool = false, order: int = 0) -> float:
		var _r: float = 0.0
		match order:
			0:
				_r = vec2ang(Vector2(vec.z, vec.x), as_deg)
			_:
				_r = vec.signed_angle_to(Vector3.FORWARD, Vector3.UP)

				if as_deg:
					_r = rad_to_deg(_r)
		return _r


	static func vec2ang(vec: Vector2, as_deg: bool = false) -> float:
		var _r := atan2(vec.x, vec.y)
		return rad_to_deg(_r) if as_deg else _r


	# custom ccd
	static func get_shape_hull(_shape: Shape3D) -> AABB:
		return _shape.get_debug_mesh().get_aabb()


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
