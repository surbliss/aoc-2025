const std = @import("std");
const file = @import("file.zig");
const expectEqual = std.testing.expectEqual;

// Main functions
pub fn main() !void {
    const input = try file.parseFile(Bank, Bank.parse, "data/03.txt", "\n");
    std.debug.print("Solution 1: {d}\n", .{try solve1(input)});
    std.debug.print("Solution 2: {d}\n", .{try solve2(input)});
}

fn solve1(input: []const Bank) !usize {
    var sum: usize = 0;
    for (input) |bank| {
        sum += try bank.maxVoltage1();
    }
    return sum;
}

fn solve2(input: []const Bank) !usize {
    var sum: usize = 0;
    for (input) |bank| {
        sum += try bank.maxVoltage2();
    }
    return sum;
}

// Datatype
const Bank = struct {
    batteries: []const u8, // Single digits

    fn parse(line: []const u8) error{}!Bank {
        return .{ .batteries = line };
    }

    fn maxVoltage1(self: Bank) !usize {
        var current = self.batteries[0];
        var next = self.batteries[1];
        var max_first = current;
        var max_second = next;
        for (2..self.batteries.len) |i| {
            current = next;
            next = self.batteries[i];
            if (max_first < current) {
                max_first = current;
                max_second = next;
            } else if (max_second < next) {
                max_second = next;
            }
        }
        const max_str: [2]u8 = .{ max_first, max_second };
        return std.fmt.parseInt(usize, &max_str, 10);
    }

    fn maxVoltage2(self: Bank) !usize {
        var max: [12]u8 = self.batteries[0..12].*;
        for (1..self.batteries.len - 11) |i| {
            const current = self.batteries[i .. i + 12];
            for (0..12) |j| {
                if (current[j] > max[j]) {
                    @memcpy(max[j..], current[j..]);
                    break;
                }
            }
        }

        return std.fmt.parseInt(usize, &max, 10);
    }
};

// Testing
const example =
    \\987654321111111
    \\811111111111119
    \\234234234234278
    \\818181911112111
;

test "example line 1" {
    const bank = Bank{ .batteries = "987654321111111" };
    try expectEqual(98, bank.maxVoltage1());
}

test "parse example" {
    _ = try file.parseExample(Bank, Bank.parse, example, "\n");
}

test "solve example 1" {
    const input = try file.parseExample(Bank, Bank.parse, example, "\n");
    try expectEqual(357, solve1(input));
}

test "2 example line 1" {
    const bank = Bank{ .batteries = "987654321111111" };
    try expectEqual(987654321111, bank.maxVoltage2());
}
test "2 example line 3" {
    const bank = Bank{ .batteries = "234234234234278" };
    try expectEqual(434234234278, bank.maxVoltage2());
}

test "solve example 2" {
    const input = try file.parseExample(Bank, Bank.parse, example, "\n");
    try expectEqual(3121910778619, solve2(input));
}
