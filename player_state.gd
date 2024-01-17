class_name PlayerState extends RefCounted

var ref: ActorPlayer

var cl_time: float

var fsu: Vector4
var wish_dir: Vector3
var wish_speed: float
var accel: float

var prev_transform: Transform3D:
	set(v):
		prev_transform = v
		prev_pos = v.origin

var cur_transform: Transform3D:
	set(v):
		cur_transform = v
		cur_pos = v.origin

var cur_pos: Vector3
var prev_pos: Vector3

var camera: Camera3D:
	set(v):
		camera = v
		projection = camera.get_camera_projection()
		var x_fov := projection.get_fov()
		aspect = projection.get_aspect()
		screen_size = (v.get_viewport() as SubViewport).size

		fov = Vector2(
			x_fov,
			Projection.get_fovy(x_fov, aspect)
			)

var projection: Projection
var aspect: float
var fov: Vector2

var velocity: Vector3:
	set(v):
		velocity = v
		velocity_xz = Math.Lib.get_vec3xz(velocity)
		speed = v.length()
		speed_xz = velocity_xz.length()

var velocity_xz: Vector3
var speed: float
var speed_xz: float

var ground_plane: bool
var ground_normal: Vector3
var walking: bool

var state: ActorMotion.State

var screen_size: Vector2i

@warning_ignore("shadowed_variable")
func _init(ref: ActorPlayer, cl_time: float) -> void:
	self.ref = ref
	self.cl_time = cl_time
	self.fsu = ref.motion.fsu
	self.wish_dir = ref.motion.wish_dir
	self.wish_speed = ref.motion.SPEED
	self.accel = ref.motion.ACCEL
	camera = ref.get_node("%PlayerCam") as Camera3D
	return
