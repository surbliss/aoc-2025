const std = @import("std");
const expectEqual = std.testing.expectEqual;
const expect = std.testing.expect;

// Should be enough for both text-file and example-string
const MAX_ALLOC = 65536; // 2^16

const INPUT = std.mem.trim(u8, @embedFile("data/04.txt"), "\n");
fn getWidth(text: []const u8) usize {
    return std.mem.indexOfScalar(u8, text, '\n').?;
}
fn getHeight(width: usize, text: []const u8) usize {
    return (text.len + 1) / (width + 1);
}
const WIDTH = getWidth(INPUT);
const HEIGHT = getHeight(WIDTH, INPUT);

// Main functions
pub fn main() !void {
    var buffer: [MAX_ALLOC]u8 align(16) = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();
    var grid = try Grid.parse(INPUT, allocator);

    // Not needed for FixedBufferAllocator, but needed if swapping allocator
    std.debug.print("Solution 1: {d}\n", .{solve1(grid)});
    std.debug.print("Solution 2: {d}\n", .{solve2(&grid)});
}

fn solve1(grid: Grid) usize {
    var sum: usize = 0;
    for (0..grid.height) |r| for (0..grid.width) |c| {
        if (grid.isAccessible(r, c)) sum += 1;
    };
    return sum;
}

fn solve2(grid: *Grid) usize {
    var sum: usize = 0;
    while (grid.remove()) |c| sum += c;
    return sum;
}

// Datatypes
const ParseError = error{ InvalidDimensions, InvalidChar } ||
    std.mem.Allocator.Error;

const Spot = enum {
    paper,
    empty,
    removing,
};

const Grid = struct {
    paper: []const []Spot,
    height: usize,
    width: usize,

    fn parse(
        input: []const u8,
        allocator: std.mem.Allocator,
    ) error{
        InvalidDimensions,
        OutOfMemory,
        InvalidChar,
    }!Grid {
        const width = getWidth(input);
        const height = getHeight(width, input);
        const paper = try allocator.alloc([]Spot, height);
        // Free outermost pointer in case of fail
        errdefer allocator.free(paper);
        var row: usize = 0;
        // Free all fully processed rows in case of fail
        errdefer for (paper[0..row]) |r| allocator.free(r);
        var lines = std.mem.splitScalar(u8, input, '\n');
        while (lines.next()) |l| : (row += 1) {
            if (l.len != width) return ParseError.InvalidDimensions;
            paper[row] = try allocator.alloc(Spot, width);
            // Free the last partly processed row, in case of fail
            errdefer allocator.free(paper[row]);
            for (l, 0..) |c, i| {
                paper[row][i] = try getSpot(c);
            }
        }
        if (row != height) return ParseError.InvalidDimensions;
        return Grid{ .paper = paper, .height = height, .width = width };
    }

    fn deinit(self: *const Grid, allocator: std.mem.Allocator) void {
        for (self.paper) |row| allocator.free(row);
        allocator.free(self.paper);
    }

    fn isAccessible(self: Grid, row: usize, col: usize) bool {
        switch (self.paper[row][col]) {
            .empty => return false,
            .removing => unreachable,
            .paper => {},
        }
        const rmin = if (row == 0) 0 else row - 1;
        const rmax = if (row == self.height - 1) self.height else row + 2;
        const cmin = if (col == 0) 0 else col - 1;
        const cmax = if (col == self.width - 1) self.width else col + 2;
        var paperCount: usize = 0;
        for (rmin..rmax) |r|
            for (cmin..cmax) |c| {
                if (r == row and c == col) continue;

                switch (self.paper[r][c]) {
                    .empty => continue,
                    .paper, .removing => paperCount += 1,
                }
            };
        return paperCount < 4;
    }

    /// Removes all accessible paper
    /// Returns number of papers removed
    fn remove(self: *Grid) ?usize {
        // Loop 1, mark those to remove
        var count: usize = 0;
        for (0..self.height) |r| for (0..self.width) |c| {
            if (self.isAccessible(r, c)) {
                self.paper[r][c] = .removing;
                count += 1;
            }
        };
        for (0..self.height) |r| for (0..self.width) |c| {
            if (self.paper[r][c] == .removing) self.paper[r][c] = .empty;
        };
        return switch (count) {
            0 => null,
            else => count,
        };
    }
};

// Helpers
fn getSpot(char: u8) error{InvalidChar}!Spot {
    return switch (char) {
        '.' => .empty,
        '@' => .paper,
        else => error.InvalidChar,
    };
}
// Testing
const example =
    \\..@@.@@@@.
    \\@@@.@.@.@@
    \\@@@@@.@.@@
    \\@.@@@@..@.
    \\@@.@@@@.@@
    \\.@@@@@@@.@
    \\.@.@.@.@@@
    \\@.@@@.@@@@
    \\.@@@@@@@@.
    \\@.@.@@@.@.
;

test {
    try expectEqual(10, getWidth(example));
}

test {
    const width = getWidth(example);
    try expectEqual(10, getHeight(width, example));
}

test "parse example" {
    const grid = try Grid.parse(example, std.testing.allocator);
    defer grid.deinit(std.testing.allocator);
}

test "parse input" {
    const grid = try Grid.parse(INPUT, std.testing.allocator);
    defer grid.deinit(std.testing.allocator);
}

test "neighbours" {
    const grid = try Grid.parse(example, std.testing.allocator);
    defer grid.deinit(std.testing.allocator);
}

test "accessible" {
    const grid = try Grid.parse(example, std.testing.allocator);
    defer grid.deinit(std.testing.allocator);
    try expect(!grid.isAccessible(0, 0));
    try expect(grid.isAccessible(0, 2));
}

test "1: Example" {
    const grid = try Grid.parse(example, std.testing.allocator);
    defer grid.deinit(std.testing.allocator);
    try expectEqual(13, solve1(grid));
}

test "2: Example" {
    var grid = try Grid.parse(example, std.testing.allocator);
    defer grid.deinit(std.testing.allocator);
    try expectEqual(43, solve2(&grid));
}
