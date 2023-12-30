Contains some useful tools for various functions in Godot.

Example usage:

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
```

output:
```
Flags now: 0
Get flags [false, false]
Has flag A false
Has flag B false
Has each flag A, B: false
Flags now: 1
Get flags [true, false]
Has flag A true
Has flag B false
Has each flag A, B: false
Flags now: 5
Get flags [true, false]
Has flag A true
Has flag B true
Has each flag A, B: true
Flags now: 4
Get flags [false, false]
Has flag A false
Has flag B true
Has each flag A, B: false
Flags now: 0
Get flags [false, false]
Has flag A false
Has flag B false
Has each flag A, B: false
```

Some other misc. functions are included as well, documentation coming at some point


Please feel free to use.
CCD code inspired from btan2:
https://github.com/Btan2/Q_Move/tree/main
