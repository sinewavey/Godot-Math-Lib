# Godot Math Library

Some useful math and collision tools for various functions in Godot.

# License

GNU GPL v3

You do not need to credit me, but you should credit `Btan2` if you use the custom collision code per their request. 
See the original repositiory: https://github.com/Btan2/Q_Move/tree/main


# Usage
Put `math.gd` somewhere in your project. Usually this goes where your other autoload or singletons go, like `src/global`.

Then, you can simply access functions with `Math.Lib` anywhere.

Examples:

```
func _ready() -> void:
	var flag_a := 1 << 0
	var flag_b := 1 << 2

	var flag_test: int = 0

	var flags: Array[int] = [flag_a, flag_b]

	prints("Flags now:", flag_test)
	prints("Get flags", Math.Lib.get_flags(flag_test, flags.size()))
	prints("Has flag A", Math.Lib.has_flag(flag_test, flag_a))
	prints("Has flag B", Math.Lib.has_flag(flag_test, flag_b))
	prints("Has each flag A, B:", Math.Lib.has_all_flags(flag_test, flag_a + flag_b))
	flag_test = Math.Lib.set_flag(flag_test, flag_a)

	prints("Flags now:", flag_test)
	prints("Get flags", Math.Lib.get_flags(flag_test, flags.size()))
	prints("Has flag A", Math.Lib.has_flag(flag_test, flag_a))
	prints("Has flag B", Math.Lib.has_flag(flag_test, flag_b))
	prints("Has each flag A, B:", Math.Lib.has_all_flags(flag_test, flag_a + flag_b))

	flag_test = Math.Lib.set_flag(flag_test, flag_b)
	prints("Flags now:", flag_test)
	prints("Get flags", Math.Lib.get_flags(flag_test, flags.size()))
	prints("Has flag A", Math.Lib.has_flag(flag_test, flag_a))
	prints("Has flag B", Math.Lib.has_flag(flag_test, flag_b))
	prints("Has each flag A, B:", Math.Lib.has_all_flags(flag_test, flag_a + flag_b))

	flag_test = Math.Lib.clear_flag(flag_test, flag_a)
	prints("Flags now:", flag_test)
	prints("Get flags", Math.Lib.get_flags(flag_test, flags.size()))
	prints("Has flag A", Math.Lib.has_flag(flag_test, flag_a))
	prints("Has flag B", Math.Lib.has_flag(flag_test, flag_b))
	prints("Has each flag A, B:", Math.Lib.has_all_flags(flag_test, flag_a + flag_b))

	flag_test = Math.Lib.toggle_flag(flag_test, flag_b)
	prints("Flags now:", flag_test)
	prints("Get flags", Math.Lib.get_flags(flag_test, flags.size()))
	prints("Has flag A", Math.Lib.has_flag(flag_test, flag_a))
	prints("Has flag B", Math.Lib.has_flag(flag_test, flag_b))
	prints("Has each flag A, B:", Math.Lib.has_all_flags(flag_test, flag_a + flag_b))


# outputs:
# Flags now: 0
# Get flags [false, false]
# Has flag A false
# Has flag B false
# Has each flag A, B: false
# Flags now: 1
# Get flags [true, false]
# Has flag A true
# Has flag B false
# Has each flag A, B: false
# Flags now: 5
# Get flags [true, false]
# Has flag A true
# Has flag B true
# Has each flag A, B: true
# Flags now: 4
# Get flags [false, false]
# Has flag A false
# Has flag B true
# Has each flag A, B: false
# Flags now: 0
# Get flags [false, false]
# Has flag A false
# Has flag B false
# Has each flag A, B: false
```

Some other misc. functions are included as well, documentation coming at some point



