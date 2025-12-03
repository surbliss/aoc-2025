const std = @import("std");
const file = @import("file.zig");
const expectEqual = std.testing.expectEqual;

const IdRange = struct {
    lower: u64,
    upper: u64,

    fn parse(input: []const u8) !IdRange {
        var split = std.mem.splitScalar(u8, input, '-');
        const lower = try std.fmt.parseInt(u64, split.next().?, 10);
        const upper = try std.fmt.parseInt(u64, split.next().?, 10);
        return .{ .lower = lower, .upper = upper };
    }

    fn sumIdsWhere(self: IdRange, validator: fn (u64) bool) u64 {
        var sum: u64 = 0;
        for (self.lower..self.upper + 1) |id| {
            if (validator(id)) sum += id;
        }
        return sum;
    }
    // Delete these
    fn sumInvalidIds1(self: IdRange) u64 {
        var sum: u64 = 0;
        for (self.lower..self.upper + 1) |id| {
            if (isInvalidId1(id)) sum += id;
        }
        return sum;
    }

    fn sumInvalidIds2(self: IdRange) u64 {
        var sum: u64 = 0;
        for (self.lower..self.upper + 1) |id| {
            if (isInvalidId2(id)) sum += id;
        }
        return sum;
    }
};

// Solutions
pub fn main() !void {
    const ranges = try file.parseFile(IdRange, IdRange.parse, "data/02.txt", ",");
    std.debug.print("Solution 1: {}\n", .{solve1(ranges)});
    std.debug.print("Solution 2: {}\n", .{solve2(ranges)});
}

fn solve1(ranges: []const IdRange) u64 {
    var sum: u64 = 0;
    for (ranges) |r| {
        sum += r.sumIdsWhere(isInvalidId1);
    }
    return sum;
}

fn solve2(ranges: []const IdRange) u64 {
    var sum: u64 = 0;
    for (ranges) |r| {
        sum += r.sumIdsWhere(isInvalidId2);
    }
    return sum;
}

// Helping functions
fn isInvalidId1(id: u64) bool {
    const first, const second = splitId(id) orelse return false;
    return first == second;
}

fn splitId(id: u64) ?struct { u64, u64 } {
    const digits = std.math.log10_int(id) + 1;
    if (digits % 2 == 1) return null;
    const help_val = std.math.pow(u64, 10, digits / 2);
    return .{ id / help_val, id % help_val };
}

// Bad = repeats (i.e invalid)
fn isInvalidId2(id: u64) bool {
    const digits = std.math.log10_int(id) + 1;
    for (2..digits + 1) |i| {
        if (isInvalidSplitBy(id, i)) return true;
    }
    return false;
}

// Bad = repeats, for given splitting
fn isInvalidSplitBy(id: u64, split_count: u64) bool {
    const digits = std.math.log10_int(id) + 1;
    if (digits % split_count != 0) return false;
    const split_digits = digits / split_count;
    var buf: [20]u8 = undefined;
    // u64 should never need more than 20 bytes
    const id_str = std.fmt.bufPrint(&buf, "{d}", .{id}) catch unreachable;

    const first_split = id_str[0..split_digits];
    for (1..split_count) |i| {
        const current_split = id_str[i * split_digits .. (i + 1) * split_digits];
        if (std.mem.eql(u8, first_split, current_split)) continue;

        return false;
    }
    return true;
}

const exampleText = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";

test "Parse file success" {
    _ = try file.parseFile(IdRange, IdRange.parse, "data/02.txt", ",");
}
test "Parse example success" {
    _ = try file.parseExample(IdRange, IdRange.parse, exampleText, ",");
}

test "Parse example val" {
    const x = try file.parseExample(IdRange, IdRange.parse, exampleText, ",");
    try expectEqual(IdRange{ .lower = 11, .upper = 22 }, x[0]);
    try expectEqual(IdRange{ .lower = 95, .upper = 115 }, x[1]);
    try expectEqual(IdRange{ .lower = 2121212118, .upper = 2121212124 }, x[x.len - 1]);
}

test "Split ID" {
    const x = 123456;
    try expectEqual(.{ 123, 456 }, splitId(x));
}

test "Split ID fail" {
    try expectEqual(null, splitId(123));
}

test "Example result" {
    const range = IdRange{ .lower = 11, .upper = 22 };
    try expectEqual(11 + 22, range.sumInvalidIds1());
}

test "Example 1-2" {
    const exampleRanges = try file.parseExample(IdRange, IdRange.parse, exampleText, ",");
    try expectEqual(1227775554, solve1(exampleRanges));
}

// test "Example 2 all" {
//     const exampleRanges = try file.parseExample(IdRange, IdRange.parse, exampleText, ",");
//     try expectEqual(4174379265, solve2(exampleRanges));
//     return error.SkipZigTest;
// }

test "Is invalid split 1" {
    try expectEqual(true, isInvalidSplitBy(123123123, 3));
}

test "Is valid split 1" {
    try expectEqual(false, isInvalidSplitBy(12312312, 3));
    try expectEqual(false, isInvalidSplitBy(123123, 3));
}

test "Solve2 example" {
    const exampleRanges = try file.parseExample(IdRange, IdRange.parse, exampleText, ",");
    try expectEqual(4174379265, solve2(exampleRanges));
}

test "sum examples2" {
    const idRange = IdRange{ .lower = 95, .upper = 115 };
    const expected = 99 + 111;
    const actual = idRange.sumInvalidIds2();
    try expectEqual(expected, actual);
}
