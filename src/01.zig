const std = @import("std");
const file = @import("file.zig");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const expectError = std.testing.expectError;

const INPUT = std.mem.trim(u8, @embedFile("data/01.txt"), "\n");
const INPUT_LINES = countLines(INPUT);

// Types
const Error = error{InvalidDirection};

const Dial = struct {
    num: i16 = 50,

    fn rotate(self: *Dial, rotation: Rotation) void {
        switch (rotation) {
            .left => |v| self.num = @mod((self.num - v), 100),
            .right => |v| self.num = @mod((self.num + v), 100),
        }
    }

    fn rotateCountClicks(self: *Dial, rotation: Rotation) usize {
        var new_num: i16 = undefined;
        var count: usize = 0;
        switch (rotation) {
            .left => |v| {
                new_num = self.num - v;
                while (new_num < 0) {
                    new_num += 100;
                    count += 1;
                }
                if (self.num == 0) count -= 1;
                if (new_num == 0) count += 1;
            },
            .right => |v| {
                new_num = self.num + v;
                while (new_num > 99) {
                    new_num -= 100;
                    count += 1;
                }
            },
        }
        self.num = new_num;
        return count;
    }
};

const Rotation = union(enum) {
    left: i16,
    right: i16,

    fn parse(line: []const u8) !Rotation {
        const direction = line[0];
        const val = try std.fmt.parseInt(i16, line[1..], 10);
        return switch (direction) {
            'L' => return .{ .left = val },
            'R' => return .{ .right = val },
            else => Error.InvalidDirection,
        };
    }
};
// Main solution
pub fn main() !void {
    const rotations = try parseInput(INPUT_LINES, INPUT);
    std.debug.print("Solution 1: {d}\n", .{solve1(&rotations)});
    std.debug.print("Solution 2: {d}\n", .{solve2(&rotations)});
}

fn solve1(rotations: []const Rotation) usize {
    var dial = Dial{};
    var count: usize = 0;
    for (rotations) |r| {
        dial.rotate(r);
        if (dial.num == 0) count += 1;
    }
    return count;
}

fn solve2(rotations: []const Rotation) usize {
    var dial = Dial{};
    var count: usize = 0;
    for (rotations) |r| {
        count += dial.rotateCountClicks(r);
    }
    return count;
}

// Helping functions
fn countLines(comptime input: []const u8) usize {
    @setEvalBranchQuota(100000);
    const newlines = std.mem.count(u8, input, "\n");
    return newlines + 1;
}

fn parseInput(comptime size: usize, comptime input: []const u8) ![size]Rotation {
    var lines = std.mem.splitScalar(u8, input, '\n');
    var buffer: [size]Rotation = undefined;

    var i: usize = 0;
    while (lines.next()) |l| {
        const r = try Rotation.parse(l);
        buffer[i] = r;
        i += 1;
    }
    return buffer;
}

// Tests
const example =
    \\L68
    \\L30
    \\R48
    \\L5
    \\R60
    \\L55
    \\L1
    \\L99
    \\R14
    \\L82
;

const exampleVals = [_]Rotation{
    .{ .left = 68 },
    .{ .left = 30 },
    .{ .right = 48 },
    .{ .left = 5 },
    .{ .right = 60 },
    .{ .left = 55 },
    .{ .left = 1 },
    .{ .left = 99 },
    .{ .right = 14 },
    .{ .left = 82 },
};

test "parse example" {
    const actual = try parseInput(exampleVals.len, example);

    for (0..exampleVals.len) |i| {
        try expectEqual(exampleVals[i], actual[i]);
    }
}

test "parse actual" {
    _ = try parseInput(INPUT_LINES, INPUT);
}

test "test example" {
    try expectEqual(3, solve1(&exampleVals));
}

test "basic left" {
    var dial = Dial{};
    dial.rotate(Rotation{ .left = 10 });

    try expect(dial.num == 40);
}

test "basic right" {
    var dial = Dial{};
    dial.rotate(Rotation{ .right = 10 });

    try expect(dial.num == 60);
}

test "Overflow left" {
    var dial = Dial{};
    dial.rotate(Rotation{ .left = 65 });

    try expect(dial.num == 85);
}

test "parse left" {
    const input = "L13";

    try expectEqual(Rotation{ .left = 13 }, Rotation.parse(input));
}

test "parse fail" {
    const input = "K45";
    try expectError(Error.InvalidDirection, Rotation.parse(input));
}

test "mem.count 1" {
    const text =
        \\hej
        \\med
        \\
    ;

    try expectEqual(1, std.mem.count(
        u8,
        std.mem.trim(u8, text, "\n"),
        "\n",
    ));
}

fn tryDiv(expected: i32, numerator: i32, denominator: i32) !void {
    try expectEqual(expected, @divTrunc(numerator, denominator));
}
test "rotatet right with clicks" {
    var dial = Dial{ .num = 30 };
    const clicks = dial.rotateCountClicks(.{ .right = 344 });
    try expectEqual(3, clicks);
}

fn dbg(val: anytype) void {
    std.debug.print("{d}\n", .{val});
}
test "rotatet left with clicks" {
    var dial = Dial{ .num = 30 };
    const clicks = dial.rotateCountClicks(.{ .left = 344 });
    try expectEqual(4, clicks);
}

test {
    var dial = Dial{ .num = 0 };
    const clicks = dial.rotateCountClicks(.{ .left = 1 });
    try expectEqual(0, clicks);
}
test {
    var dial = Dial{ .num = 1 };
    const clicks = dial.rotateCountClicks(.{ .left = 1 });
    try expectEqual(1, clicks);
}
test {
    var dial = Dial{ .num = 0 };
    const clicks = dial.rotateCountClicks(.{ .right = 1 });
    try expectEqual(0, clicks);
}
test {
    var dial = Dial{ .num = 99 };
    const clicks = dial.rotateCountClicks(.{ .right = 1 });
    try expectEqual(1, clicks);
}

test "New parser" {
    const x = try file.parseFile(Rotation, Rotation.parse, "data/01.txt", "\n");
    std.debug.print("{d}\n", .{x.len}); // 4664
    std.debug.print("{}\n", .{x[0]});
    std.debug.print("{}\n", .{x[4663]});
    // std.debug.print("{}\n", .{x[4664]}); // Crashes, expectidly
}
