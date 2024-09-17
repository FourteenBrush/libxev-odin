package xev

import "core:c"
when ODIN_OS == .Linux do foreign import xev "../lib/libxev.a"

@(link_prefix="xev_")
foreign xev {
	loop_init :: proc(loop: ^Loop) -> c.int ---
	loop_deinit :: proc(loop: ^Loop) ---
	loop_run :: proc(loop: ^Loop, mode: RunMode) -> c.int ---
	loop_now :: proc(loop: ^Loop) -> i64 ---
	loop_update_now :: proc(loop: ^Loop) ---

	completion_zero :: proc(c: ^Completion) ---
	completion_state :: proc(c: ^Completion) -> CompletionState ---

	threadpool_config_init :: proc(config: ^ThreadpoolConfig) ---
	threadpool_config_set_stack_size :: proc(config: ^ThreadpoolConfig, v: u32) ---
	threadpool_config_set_max_threads :: proc(config: ^ThreadpoolConfig, v: u32) ---

	threadpool_init :: proc(pool: ^Threadpool, config: ^ThreadpoolConfig) -> c.int ---
	threadpool_deinit :: proc(pool: ^Threadpool) ---
	threadpool_shutdown :: proc(pool: ^Threadpool) ---
	threadpool_schedule :: proc(pool: ^Threadpool, batch: ^ThreadpoolBatch) ---

	threadpool_task_init :: proc(t: ^ThreadpoolTask, cb: TaskCallback) ---
	threadpool_batch_init :: proc(b: ^ThreadpoolBatch) ---
	threadpool_batch_push_task :: proc(b: ^ThreadpoolBatch, t: ^ThreadpoolTask) ---
	threadpool_batch_push_batch :: proc(b: ^ThreadpoolBatch, other: ^ThreadpoolBatch) ---

	timer_init :: proc(w: ^Watcher) -> c.int ---
	timer_deinit :: proc(w: ^Watcher) ---
	timer_run :: proc(w: ^Watcher, loop: ^Loop, c: ^Completion, next_ms: u64, userdata: rawptr, cb: TimerCallback) ---
	timer_reset :: proc(w: ^Watcher, loop: ^Loop, c: ^Completion, c_cancel: ^Completion, next_ms: u64, userdata: rawptr, cb: TimerCallback) ---
	timer_cancel :: proc(w: ^Watcher, loop: ^Loop, c: ^Completion, c_cancel: ^Completion, userdata: rawptr, cb: TimerCallback) ---

	async_init :: proc(w: ^Watcher) -> c.int ---
	async_deinit :: proc(w: ^Watcher) ---
	async_notify :: proc(w: ^Watcher) -> c.int ---
	async_wait :: proc(w: ^Watcher, loop: ^Loop, c: ^Completion, userdata: rawptr, cb: TimerCallback) ---
}

// TODO: ensure correct
max_align_t :: [align_of(i128)]u8

SIZEOF_LOOP :: 512
SIZEOF_COMPLETION :: 320
SIZEOF_WATCHER :: 256
SIZEOF_THREADPOOL :: 64
SIZEOF_THREADPOOL_BATCH :: 24
SIZEOF_THREADPOOL_TASK :: 24
SIZEOF_THREADPOOL_CONFIG :: 64

Loop :: struct {
	_pad: max_align_t,
	data: [SIZEOF_LOOP - size_of(max_align_t)]u8,
}

Completion :: struct {
	_pad: max_align_t,
	data: [SIZEOF_COMPLETION - size_of(max_align_t)]u8,
}

Watcher :: struct {
	_pad: max_align_t,
	data: [SIZEOF_WATCHER - size_of(max_align_t)]u8,
}

Threadpool :: struct {
	_pad: max_align_t,
	data: [SIZEOF_THREADPOOL - size_of(max_align_t)]u8,
}

ThreadpoolBatch :: struct {
	_pad: max_align_t,
	data: [SIZEOF_THREADPOOL_BATCH - size_of(max_align_t)]u8,
}

ThreadpoolTask :: struct {
	_pad: max_align_t,
	data: [SIZEOF_THREADPOOL_TASK - size_of(max_align_t)]u8,
}

ThreadpoolConfig :: struct {
	_pad: max_align_t,
	data: [SIZEOF_THREADPOOL_CONFIG - size_of(max_align_t)]u8,
}

CallbackAction :: enum c.int {
	DISARM,
	REARM,
}

// odinfmt: disable
TaskCallback :: #type proc "c" (^ThreadpoolTask)
TimerCallback :: #type proc "c" (loop: ^Loop, co: ^Completion, result: c.int, userdata: rawptr) -> CallbackAction
AsyncCallback :: #type proc "c" (loop: ^Loop, co: ^Completion, result: c.int, userdata: rawptr) -> CallbackAction
// odinfmt: enable

RunMode :: enum c.int {
	RUN_NO_WAIT    = 0,
	RUN_ONCE       = 1,
	RUN_UNTIL_DONE = 2,
}

CompletionState :: enum c.int {
	DEAD   = 0,
	ACTIVE = 1,
}
