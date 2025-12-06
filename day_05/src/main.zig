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

const range = struct { low: i128, high: i128 };

pub fn part_one(input: *[]u8) !void {
    const allocator = std.heap.page_allocator;
    var lines = std.mem.splitScalar(u8, input.*, '\n');
    var result: i128 = 0;
    var in_available_section: bool = false;
    var fresh_ids = try allocator.alloc(range, 177);
    var idx: usize = 0;

    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, &std.ascii.whitespace);
        if (trimmed.len == 0) {
            in_available_section = true;
            continue;
        }
        if (!in_available_section) {
            const hyphen_idx = std.mem.indexOf(u8, trimmed, "-").?;

            const left = trimmed[0..hyphen_idx];
            const right = trimmed[hyphen_idx + 1 ..];

            const left_int = try std.fmt.parseInt(i128, left, 10);
            const right_int = try std.fmt.parseInt(i128, right, 10);

            //std.debug.print("Processing range: {d} - {d}\n", .{ left_int, right_int });
            fresh_ids[idx] = range{ .low = left_int, .high = right_int };
            idx += 1;
        } else {
            const check_id = try std.fmt.parseInt(i128, trimmed, 10);
            for (fresh_ids) |r| {
                if (check_id >= r.low and check_id <= r.high) {
                    result += 1;
                    //std.debug.print("Found {d}\n", .{check_id});
                    break;
                }
            }
        }
    }
    std.debug.print("Part 1: {d}\n", .{result});
}

pub fn less_than(_: void, lhs: range, rhs: range) bool {
    return lhs.low < rhs.low;
}

pub fn part_two(input: *[]u8) !void {
    const allocator = std.heap.page_allocator;
    var lines = std.mem.splitScalar(u8, input.*, '\n');
    var result: i128 = 0;
    var fresh_ids = try std.ArrayList(range).initCapacity(allocator, 177);

    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, &std.ascii.whitespace);
        if (trimmed.len == 0) {
            break;
        }
        const hyphen_idx = std.mem.indexOf(u8, trimmed, "-").?;

        const left = trimmed[0..hyphen_idx];
        const right = trimmed[hyphen_idx + 1 ..];

        const left_int = try std.fmt.parseInt(i128, left, 10);
        const right_int = try std.fmt.parseInt(i128, right, 10);

        try fresh_ids.append(allocator, range{ .low = left_int, .high = right_int });
    }

    std.mem.sort(range, fresh_ids.items, {}, less_than);

    var merged_list = try std.ArrayList(range).initCapacity(allocator, fresh_ids.items.len);
    var idx: usize = 0;
    var last_position: usize = 0;
    while (idx < fresh_ids.items.len) : (idx += 1) {
        if (idx == 0 or merged_list.items[last_position].high < fresh_ids.items[idx].low) {
            try merged_list.append(allocator, fresh_ids.items[idx]);
            last_position += 1;
        } else if (merged_list.items[last_position].high >= fresh_ids.items[idx].low) {
            merged_list.items[last_position].high = @max(merged_list.items[last_position].high, fresh_ids.items[idx].high);
        }

        if (idx == 0) {
            last_position -= 1;
        }
    }

    for (merged_list.items) |r| {
        result += r.high - r.low + 1;
    }
    std.debug.print("Part 2: {d}\n", .{result});
}

pub fn main() !void {
    var input = try readInput(std.heap.page_allocator);
    defer std.heap.page_allocator.free(input);
    try part_one(&input);
    try part_two(&input);
}
