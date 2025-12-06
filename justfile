test DAY:
    watchexec -c=reset zig test src/{{DAY}}.zig

test-once DAY:
    zig test src/{{DAY}}.zig

run DAY:
    zig run src/{{DAY}}.zig
