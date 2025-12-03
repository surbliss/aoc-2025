const std = @import("std");
const file = @import("file.zig");
const expectEqual = std.testing.expectEqual;
const expect = std.testing.expect;

const FILE_PATH = "data/01.txt"; // Rename!

// Main functions
pub fn main() !void {
    const input = try file.parseFile(Data, Data.parse, FILE_PATH, "\n");
    std.debug.print("Solution 1: {d}\n", .{solve1(input)});
    std.debug.print("Solution 2: {d}\n", .{solve2(input)});
}

fn solve1(_: []const Data) usize {
    return 0;
}

fn solve2(_: []const Data) usize {
    return 0;
}

// Datatype
const Data = struct {
    fn parse(_: []const u8) error{}!Data {
        return Data{};
    }
};

// Testing
const example =
    \\ Paste example here
;

test "parse example" {
    _ = try file.parseExample(Data, Data.parse, example, "\n");
}

test "parse file" {
    _ = try file.parseFile(Data, Data.parse, FILE_PATH, "\n");
}

test "1 example part" {
    try expect(true);
}

test "1 solve example" {
    const input = try file.parseExample(Data, Data.parse, example, "\n");
    try expectEqual(0, solve1(input));
}

test "2 example part" {
    try expect(true);
}
test "2 solve example" {
    const input = try file.parseExample(Data, Data.parse, example, "\n");
    try expectEqual(0, solve2(input));
}
