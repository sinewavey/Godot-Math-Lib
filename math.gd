class_name Math

enum Order2 { XX, XY, XZ, YX, YY, YZ, ZX, ZY, ZZ}
enum Order3 { XYZ, XZY, YXZ, YZX, ZXY, ZYX }


class Lib:
	# Bitflag checks
	# Honestly, this is more of a how-to guide than a real "use these methods"

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


	static func embed_vec2(vec: Vector2, order: Math.Order3, flatten: bool = false) -> Vector3:
		var _r := Vector3()

		match order:
			Order3.XYZ:
				_r.x = vec.x
				_r.y = vec.y
			Order3.XZY:
				_r.x = vec.y
				_r.z = vec.x
			Order3.YXZ:
				_r.y = vec.x
				_r.x = vec.y
			Order3.YZX:
				_r.y = vec.x
				_r.z = vec.y
			Order3.ZXY:
				_r.z = vec.x
				_r.x = vec.y
			Order3.ZYX:
				_r.z = vec.x
				_r.y = vec.y

		return _r

## TODO: define what order is besides ZX or signed_angle. Pseudo euler order
	@warning_ignore("untyped_declaration")
	static func vec_to_angle(vec, as_deg: bool = false, order: Math.Order2 = Order2.ZX) -> float:
		var _r: float = NAN
		if (vec is Vector2i || vec is Vector2):
			_r = atan2(vec.y, vec.x)

		elif (vec is Vector3 || vec is Vector3i):
			match order:
				#enum Order { XYZ, XZY, YXZ, YZX, ZXY, ZYX }
				Order2.ZX: _r = atan2(vec.z, vec.x)
				Order2.ZY: _r = atan2(vec.y, vec.x)
				Order2.XY: _r = atan2(vec.z, vec.x)
				Order2.XZ: _r = atan2(vec.y, vec.x)
				Order2.XY: _r = atan2(vec.z, vec.x)
				Order2.XZ: _r = atan2(vec.y, vec.x)
				_: _r = vec.signed_angle_to(Vector3.FORWARD, Vector3.UP)

		if _r != NAN:
			return rad_to_deg(_r) if as_deg else _r

		push_warning("Warning: Math.Lib.vec2ang was supplied with an invalid type. Valid types include Vector2/3 and Vector2i/3i.")
		return _r


	# TODO: make arbitrary angle calculation loop, to support N dimensional sectors, rather than 8 only
	static func get_sector8(angle: float) -> int:
		if (angle > -22.5 && angle < 22.6):
			return 0

		if (angle >= 22.5 && angle < 67.5):
			return 7

		if (angle >= 67.5 && angle < 112.5):
			return 6

		if (angle >= 112.5 && angle < 157.5):
			return 5

		if (angle <= -157.5 || angle >= 157.5):
			return 4

		if (angle >= -157.4 && angle < -112.5):
			return 3

		if (angle >= -112.5 && angle < -67.5):
			return 2

		if (angle >= -67.5 && angle <= -22.5):
			return 1

		return 0


	static func get_sprite_dir(
		sprite_xform: Transform3D,
		view_xform: Transform3D,
		only_xz: bool = true) -> int:

		var from := sprite_xform.origin
		var to := view_xform.origin
		var look_dir := -sprite_xform.basis.z

		if only_xz:
			from.y = 0
			to.y = 0
			look_dir.y = 0

		# get the sector angles by arctan then lock to 0 < x < 360.0
		var pos := vec_to_angle(from - to, true)
		var basis := vec_to_angle(from - look_dir, true)
		var angle := wrap_fmod(pos, basis, 360.0)
		return get_sector8(angle)


	# custom ccd
	static func get_shape_hull(_shape: Shape3D) -> AABB:
		return _shape.get_debug_mesh().get_aabb()


	# code below has roots from idTech3 and btan2's Q_Move for Godot 3.5
	static func cast_trace(
		what: CollisionObject3D, shape: Shape3D,
		from: Vector3, to: Vector3) -> Math.Trace:

		var _collided: bool = false
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
			_collided = false
			return Math.Trace.new(to)

		_collided = true

		var end_pos := from + motion * results[1]

		params.transform.origin = end_pos

		var rest := space_state.get_rest_info(params)
		var norm := rest.get("normal", Vector3.UP) as Vector3
		return Math.Trace.new(end_pos, results[0], norm)


	static func blast_radius(who: Node3D, radius: float) -> Array[Dictionary]:
		var shape_rid = PhysicsServer3D.sphere_shape_create()
		PhysicsServer3D.shape_set_data(shape_rid, radius)

		var params = PhysicsShapeQueryParameters3D.new()

		params.shape_rid = shape_rid
		params.collide_with_bodies = true
		params.collide_with_areas = false
		params.transform = who.global_transform
		PhysicsServer3D.free_rid.bind(shape_rid).call_deferred()

		return who.get_world_3d().direct_space_state.intersect_shape(params)


	# misc funcs
	static func short_path(path: String, delim: String, pad: int = 0) -> String:
		var split := path.split(delim)
		var _r: String = ""

		for s in split:
			_r += (s if s == split[-1] else s[0] + delim)

		if pad > 0:
			for i in (pad - _r.length()):
				_r += " "

		return _r

	static func get_cam_info(camera: Camera3D, excludes: Array[CollisionObject3D] = [null], layers: int = 0xFFFFFFFF) -> CamInfo:
		return CamInfo.new(camera, layers, excludes)


	static func get_dir() -> String:
		if Engine.is_editor_hint() || OS.has_feature("editor"):
			return "res:/"

		else:
			return OS.get_executable_path().get_base_dir()

	@warning_ignore("shadowed_global_identifier")
	static func wrap_fmod(x: float, y: float, range: float) -> float:
		return fmod(x - y + range, range)


## data objects


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

class CamInfo extends RefCounted:
	var cam_3d: Camera3D:
		set(v):
			cam_3d = v
			viewport = v.get_viewport()
			world_3d = v.get_world_3d()
			projection = v.get_camera_projection()
			ray_origin = v.project_ray_origin(screen_size / 2)
			ray_end = ray_origin + v.project_ray_normal(screen_size / 2) * 1000


	var projection: Projection:
		set(v):
			projection = v
			fov_x = projection.get_fov()
			aspect = projection.get_aspect()
			fov_y = Projection.get_fovy(fov_x, aspect)

	var fov_x: float
	var fov_y: float
	var aspect: float
	var screen_size: Vector2
	var world_3d: World3D

	var ray_origin: Vector3
	var ray_end: Vector3

	var viewport: Viewport:
		set(v):
			viewport = v
			if v is SubViewport:
				screen_size = (v as SubViewport).size

			else:
				screen_size = Vector2i(
					ProjectSettings.get_setting("size/viewport_width"),
					ProjectSettings.get_setting("size/viewport_height")
					)

	var params: PhysicsRayQueryParameters3D

	var collided: bool = false
	var collider: Node = null

	var collision_point: Vector3
	var collision_normal: Vector3

	func _init(
		_camera: Camera3D, layers: int = 0xFFFFFFFF, excludes: Array[CollisionObject3D] = [null]) -> void:

		cam_3d = _camera

		var exc: Array[RID] = []

		for node in excludes:
			if node:
				exc.append(node.get_rid())

		params = PhysicsRayQueryParameters3D.create(
			ray_origin,
			ray_end,
			layers,
			exc
		)

		var results := world_3d.direct_space_state.intersect_ray(params)

		if !results.is_empty():
			collided = true
			collider = results.collider
			collision_point = results.position
			collision_normal = results.normal

		else:
			collided = false
			collider = null
			collision_point = ray_end
			collision_normal = (ray_end - ray_origin).normalized()

		return
