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

const row = struct { elem: []i128 };
const matrix = struct { rows: []row };

pub fn part_one(input: *[]u8) !void {
    const allocator = std.heap.page_allocator;
    var lines = std.mem.splitScalar(u8, input.*, '\n');
    var result: i128 = 0;
    var orig_matrix = matrix{ .rows = try allocator.alloc(row, 4) };
    var row_idx: usize = 0;
    var ops: []u8 = try allocator.alloc(u8, 1000);

    // Parse the input into a matrix
    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, &std.ascii.whitespace);
        if (trimmed.len == 0) continue;

        var values = std.mem.splitScalar(u8, trimmed, ' ');
        var new_row = row{ .elem = try allocator.alloc(i128, 1000) };
        var idx: usize = 0;
        while (values.next()) |val| {
            var trimmed_value = std.mem.trim(u8, val, &std.ascii.whitespace);
            if (trimmed_value.len == 0) continue;
            if (row_idx != 4) {
                //std.debug.print("Uhhh: {s}\n", .{trimmed_value});
                new_row.elem[idx] = try std.fmt.parseInt(i128, trimmed_value, 10);
            } else {
                ops[idx] = trimmed_value[0];
            }
            idx += 1;
        }
        if (row_idx != 4) {
            orig_matrix.rows[row_idx] = new_row;
            row_idx += 1;
        }
    }

    // Transpose the matrix
    var new_matrix = matrix{ .rows = try allocator.alloc(row, 1000) };
    for (0..1000) |i| {
        new_matrix.rows[i] = row{ .elem = try allocator.alloc(i128, 4) };
    }

    for (0.., orig_matrix.rows) |i, r| {
        for (0.., r.elem) |j, e| {
            new_matrix.rows[j].elem[i] = e;
        }
    }

    // Do the math
    for (0.., new_matrix.rows) |i, r| {
        const op = ops[i];
        var row_total: i128 = 0;
        if (op == '*') {
            row_total = 1;
        }

        for (r.elem) |e| {
            if (op == '+') {
                row_total += e;
            } else {
                row_total *= e;
            }
        }
        result += row_total;
    }

    std.debug.print("Part 1: {d}", .{result});
}

pub fn main() !void {
    var input = try readInput(std.heap.page_allocator);
    defer std.heap.page_allocator.free(input);
    try part_one(&input);
}
