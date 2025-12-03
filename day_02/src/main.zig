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

pub fn is_valid_id(id: i128) !bool {
    const allocator = std.heap.page_allocator;
    var string_num = try std.fmt.allocPrint(allocator, "{d}", .{id});
    const length = string_num.len;
    var idx: usize = 0;

    if (@mod(length, 2) != 0) return false;

    const half = @divExact(length, 2);
    while (idx < half) : (idx += 1) {
        if (string_num[idx] != string_num[idx + half]) return false;
    }
    return true;
}

pub fn part_one(input: *[]u8) !void {
    var lines = std.mem.splitScalar(u8, input.*, ',');
    var result: i128 = 0;

    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, &std.ascii.whitespace);
        if (trimmed.len == 0) continue;

        const hyphen_idx = std.mem.indexOf(u8, trimmed, "-").?;

        const left = trimmed[0..hyphen_idx];
        const right = trimmed[hyphen_idx + 1 ..];

        var left_int = try std.fmt.parseInt(i128, left, 10);
        const right_int = try std.fmt.parseInt(i128, right, 10);

        while (left_int <= right_int) {
            if (try is_valid_id(left_int)) {
                result += left_int;
            }
            left_int += 1;
        }
    }
    std.debug.print("Part 1: {d}", .{result});
}

pub fn is_repeated(id: []u8, seq_len: usize, total_len: usize) !bool {
    const parts_count = @divExact(total_len, seq_len);

    for (0..seq_len) |i| {
        const check_char = id[i];
        for (0..parts_count) |j| {
            if (id[seq_len * j + i] != check_char) return false;
        }
    }
    return true;
}

pub fn is_valid_id_two(id: i128) !bool {
    const allocator = std.heap.page_allocator;
    var string_num = try std.fmt.allocPrint(allocator, "{d}", .{id});
    const length = string_num.len;
    const half = @divTrunc(length, 2);

    for (1..half + 1) |i| {
        if (@mod(length, i) != 0) continue;
        if (try is_repeated(string_num, i, length)) return true;
    }
    return false;
}

pub fn part_two(input: *[]u8) !void {
    var lines = std.mem.splitScalar(u8, input.*, ',');
    var result: i128 = 0;

    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, &std.ascii.whitespace);
        if (trimmed.len == 0) continue;

        const hyphen_idx = std.mem.indexOf(u8, trimmed, "-").?;

        const left = trimmed[0..hyphen_idx];
        const right = trimmed[hyphen_idx + 1 ..];

        var left_int = try std.fmt.parseInt(i128, left, 10);
        const right_int = try std.fmt.parseInt(i128, right, 10);

        while (left_int <= right_int) {
            //std.debug.print("{d}\n", .{left_int});
            if (try is_valid_id_two(left_int)) {
                result += left_int;
            }
            left_int += 1;
        }
    }
    std.debug.print("Part 2: {d}", .{result});
}

pub fn main() !void {
    var input = try readInput(std.heap.page_allocator);
    defer std.heap.page_allocator.free(input);
    //try part_one(&input);
    try part_two(&input);
}
