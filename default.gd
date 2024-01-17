class_name DEFAULT

# globals
const SCALE_FACTOR: float = 0.03125 				# default = 0.03125 = 1/32

const GRAVITY: float = 25.0
const GRAVITY_WATER: float = 0.5 * GRAVITY

const AM_SPEED: float = (320 * SCALE_FACTOR) 		# default = 320/32 = 10.0
const AM_STOPSPEED: float = 100 * SCALE_FACTOR		# default = 100 / 32 = 3.125

const AM_DUCKMOD: float = 0.25 * AM_SPEED			# default 2.5
const AM_WALKMOD: float = 0.50 * AM_SPEED			# default 5.0
const AM_WADEMOD: float = 0.70 * AM_SPEED			# default 7.0
const AM_SWIMMOD: float = 0.50 * AM_SPEED			# default 5.0

const AM_ACCEL: float = 10.0						# default 10.0
const AM_AIRACCEL: float = 1.0						# default 1.0
const AM_WATERACCEL: float = 4.0					# default 4.0
const AM_FLYACCEL: float = 8.0						# default 8.0

const AM_FRIC: float = 6.0							# default 6.0
const AM_WATERFRIC: float = 1.0						# default 1.0
const AM_FLYFRIC: float = 3.0						# default 3.0

const AM_JUMP: float = (270.0 * SCALE_FACTOR) 		# default = 270/32 = 8.4375
const AM_HANGTIME: float = 0.2						# default 0.2

const AM_STEP_HEIGHT: float = 18 * SCALE_FACTOR		# default 0.5625 meters
