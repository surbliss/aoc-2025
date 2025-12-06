const std = @import("std");
const expect = std.testing.expect;
const MAX_ALLOC = 65536; // 2^16
const MAX_EXAMPLE_ALLOC = 1024;

pub const FileError = error{ParseFailed} || std.mem.Allocator.Error;

var file_buffer: [MAX_ALLOC]u8 align(16) = undefined;
var file_fba = std.heap.FixedBufferAllocator.init(&file_buffer);
const file_allocator = file_fba.allocator();

var example_fba = std.heap.FixedBufferAllocator.init(&example_buffer);
var example_buffer: [MAX_EXAMPLE_ALLOC]u8 align(16) = undefined;
const example_allocator = example_fba.allocator();

pub fn parseFile(
    comptime T: type,
    comptime parser: fn ([]const u8) anyerror!T,
    comptime file: []const u8,
    comptime delimiter: []const u8,
) FileError![]const T {
    const input = comptime std.mem.trim(u8, @embedFile(file), "\n");
    return parseInput(T, parser, input, delimiter, file_allocator);
}

pub fn parseExample(
    comptime T: type,
    comptime parser: fn ([]const u8) anyerror!T,
    comptime input: []const u8,
    delimiter: []const u8,
) FileError![]const T {
    return parseInput(T, parser, input, delimiter, example_allocator);
}

fn parseInput(
    comptime T: type,
    comptime parser: fn ([]const u8) anyerror!T,
    comptime input: []const u8,
    delimiter: []const u8,
    allocator: std.mem.Allocator,
) FileError![]const T {
    var split_input = std.mem.splitSequence(u8, input, delimiter);
    const split_input_count = std.mem.count(u8, input, delimiter) + 1;
    const result = try allocator.alloc(T, split_input_count);
    var i: usize = 0;
    while (split_input.next()) |x| : (i += 1)
        // Coerce error - We don't want to return 'anyerror'
        result[i] = parser(x) catch return FileError.ParseFailed;
    return result;
}
