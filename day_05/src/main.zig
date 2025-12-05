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

pub fn main() !void {
    var input = try readInput(std.heap.page_allocator);
    defer std.heap.page_allocator.free(input);
    try part_one(&input);
}
