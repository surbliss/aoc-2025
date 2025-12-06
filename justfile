test DAY:
    zig test src/{{DAY}}.zig

wtest DAY:
    watchexec -c=reset zig test src/{{DAY}}.zig

run DAY:
    zig run src/{{DAY}}.zig
