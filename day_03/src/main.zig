const std = @import("std");

pub fn readInput(allocator: std.mem.Allocator) ![]u8 {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile("src/input.txt", .{ .mode = .read_only });
    defer file.close();

    const file_size = try file.getEndPos();
    var buffer = try allocator.alloc(u8, file_size);
    const bytes_read = try file.read(buffer);

    return buffer[0..bytes_read];
}

pub fn part_one(input: *[]u8) !void {
    var lines = std.mem.splitScalar(u8, input.*, '\n');
    var result: i128 = 0;

    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, &std.ascii.whitespace);
        if (trimmed.len == 0) continue;
        var max_tens: i8 = 0;
        var tens_idx: usize = 0;
        for (0..trimmed.len - 1) |i| {
            const digit = try std.fmt.parseInt(i8, &[_]u8{trimmed[i]}, 10);
            if (digit > max_tens) {
                max_tens = digit;
                tens_idx = i;
            }
        }
        var max_ones: i8 = 0;
        for (tens_idx + 1..trimmed.len) |i| {
            const digit = try std.fmt.parseInt(i8, &[_]u8{trimmed[i]}, 10);
            if (digit > max_ones) {
                max_ones = digit;
            }
        }
        result += max_tens * 10 + max_ones;
    }
    std.debug.print("Part 1: {d}\n", .{result});
}

const ArrayUnit = struct { value: i32, idx: usize };

pub fn search(string: []const u8, start_idx: usize, end_idx: usize) !ArrayUnit {
    var unit = ArrayUnit{ .idx = 0, .value = 0 };
    for (start_idx..end_idx) |i| {
        const digit = try std.fmt.parseInt(i8, &[_]u8{string[i]}, 10);
        if (digit > unit.value) {
            unit.value = digit;
            unit.idx = i;
        }
    }
    return unit;
}

pub fn part_two(input: *[]u8) !void {
    var lines = std.mem.splitScalar(u8, input.*, '\n');
    var result: i128 = 0;

    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, &std.ascii.whitespace);
        if (trimmed.len == 0) continue;

        var digits_remaining: u8 = 12;
        var start_idx: usize = 0;
        var current_value: i128 = 0;

        for (0..12) |_| {
            const next_value = try search(trimmed, start_idx, trimmed.len - @as(usize, digits_remaining) + 1);
            start_idx = next_value.idx + 1;
            current_value += std.math.pow(i128, 10, digits_remaining - 1) * next_value.value;
            digits_remaining -= 1;
        }

        result += current_value;
    }
    std.debug.print("Part 2: {d}", .{result});
}

pub fn main() !void {
    var input = try readInput(std.heap.page_allocator);
    defer std.heap.page_allocator.free(input);
    try part_one(&input);
    try part_two(&input);
}
