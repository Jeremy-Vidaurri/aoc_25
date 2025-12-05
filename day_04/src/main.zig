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

const row = struct { elements: []u8 };
const grid = struct { rows: []row };

pub fn part_one(input: *[]u8, allocator: std.mem.Allocator) !void {
    var lines = std.mem.splitScalar(u8, input.*, '\n');
    var result: i128 = 0;
    const row_count: i32 = 137;
    var g = grid{ .rows = try allocator.alloc(row, row_count) };
    var row_idx: usize = 0;

    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, &std.ascii.whitespace);
        if (trimmed.len == 0) continue;
        var r = row{ .elements = try allocator.alloc(u8, trimmed.len) };
        for (0.., trimmed) |i, char| {
            r.elements[i] = char;
        }
        g.rows[row_idx] = r;
        row_idx += 1;
    }
    //std.debug.print("{d}\n", .{row_idx});

    for (0.., g.rows) |row_num, r| {
        for (0.., r.elements) |col_num, elem| {
            var total_neighbors: i32 = 0;
            //std.debug.print("elem: {c} row: {d} col: {d}\n", .{ elem, row_num, col_num });
            if (elem != '@') continue;

            // not on left edge
            if (col_num != 0 and r.elements[col_num - 1] == '@') {
                //std.debug.print("1.{d} {d}\n", .{ row_num, col_num });
                total_neighbors += 1;
            }

            // not on right edge
            if (col_num != r.elements.len - 1 and r.elements[col_num + 1] == '@') {
                //std.debug.print("2.{d} {d}\n", .{ row_num, col_num });
                total_neighbors += 1;
            }

            // not on top edge
            if (row_num != 0 and g.rows[row_num - 1].elements[col_num] == '@') {
                //std.debug.print("3.{d} {d}\n", .{ row_num, col_num });
                total_neighbors += 1;
            }

            // not on bottom edge
            if (row_num != g.rows.len - 1 and g.rows[row_num + 1].elements[col_num] == '@') {
                //std.debug.print("4.{d} {d}\n", .{ row_num, col_num });
                total_neighbors += 1;
            }

            // not on top-left edge
            if (col_num != 0 and row_num != 0 and g.rows[row_num - 1].elements[col_num - 1] == '@') {
                //std.debug.print("5.{d} {d}\n", .{ row_num, col_num });
                total_neighbors += 1;
            }

            // not on top-right edge
            if (col_num != r.elements.len - 1 and row_num != 0 and g.rows[row_num - 1].elements[col_num + 1] == '@') {
                //std.debug.print("6.{d} {d}\n", .{ row_num, col_num });
                total_neighbors += 1;
            }

            // not on bottom-left edge
            if (col_num != 0 and row_num != g.rows.len - 1 and g.rows[row_num + 1].elements[col_num - 1] == '@') {
                //std.debug.print("7.{d} {d}\n", .{ row_num, col_num });
                total_neighbors += 1;
            }

            // not on bottom-right edge
            if (col_num != r.elements.len - 1 and row_num != g.rows.len - 1 and g.rows[row_num + 1].elements[col_num + 1] == '@') {
                //std.debug.print("8.{d} {d}\n", .{ row_num, col_num });
                total_neighbors += 1;
            }

            if (total_neighbors < 4) {
                result += 1;
                //std.debug.print("FOUND: {d} {d}\n\n", .{ row_num, col_num });
            }
        }
    }

    std.debug.print("Part 1: {d}\n", .{result});
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var input = try readInput(allocator);
    defer allocator.free(input);
    try part_one(&input, allocator);
}
