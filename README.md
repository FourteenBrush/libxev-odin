# Odin Bindings for libxev

https://github.com/mitchellh/libxev/tree/main

Static libs can be found in `lib` and are generated with `zig build -Doptimize=ReleaseSmall`

Example usage (prints `timer_callback` every second):

```go
package main

import "core:fmt"
import "base:runtime"

import "xev"

main :: proc() {
    loop: xev.Loop
    assert(xev.loop_init(&loop) == 0)
    defer xev.loop_deinit(&loop)

    watcher: xev.Watcher
    assert(xev.timer_init(&watcher) == 0)
    defer xev.timer_deinit(&watcher)

    comp: xev.Completion
    xev.timer_run(&watcher, &loop, &comp, 1000, nil, timer_callback)
}

timer_callback :: proc "c" (loop: ^xev.Loop, comp: ^xev.Completion, result: i32, userdata: rawptr) -> xev.CallbackAction {
    context = runtime.default_context() // for println
    fmt.println(#procedure)
    return .DISARM
}
```
