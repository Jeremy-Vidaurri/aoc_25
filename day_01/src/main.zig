const std = @import("std");

pub fn read_input(buffer: *[19136]u8) !void {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile("src/input.txt", .{ .mode = .read_only });
    const io = std.testing.io;

    defer file.close();

    var read_buffer: [1024]u8 = undefined;
    var fr = file.reader(io, &read_buffer);
    var reader = &fr.interface;

    @memset(buffer[0..], 0);

    _ = reader.readSliceAll(buffer[0..]) catch 0;
}

pub fn part_1(input: *[19136]u8) !void {
    var lines = std.mem.splitScalar(u8, input, '\n');
    var position: i32 = 50;
    var result: i32 = 0;
    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, &std.ascii.whitespace);
        if (trimmed.len > 0) {
            const dir = trimmed[0];
            const _mag = trimmed[1..];
            var magnitude = try std.fmt.parseInt(i32, _mag, 10);
            if (dir == 'L') {
                magnitude *= -1;
            }

            position = try std.math.mod(i32, position + magnitude, 100);
            if (position == 0) {
                result += 1;
            }
        }
    }
    std.debug.print("Part 1: {d}\n", .{result});
}

pub fn part_2(input: *[19136]u8) !void {
    var lines = std.mem.splitScalar(u8, input, '\n');
    var position: i32 = 50;
    var result: i32 = 0;
    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, &std.ascii.whitespace);
        if (trimmed.len > 0) {
            const dir = trimmed[0];
            const _mag = trimmed[1..];
            var magnitude = try std.fmt.parseInt(i32, _mag, 10);
            if (dir == 'L') {
                magnitude *= -1;
            }

            if (magnitude > 0 and magnitude + position >= 100) {
                std.debug.print("Starting: {d}, mag: {d}, Ending: {d}, count: {d}\n", .{ position, magnitude, magnitude + position, @divTrunc(magnitude + position, 100) });
                //try std.testing.io.sleep(std.Io.Duration.fromSeconds(5), std.Io.Clock.real);
                result += @divTrunc(magnitude + position, 100);
            } else if (magnitude < 0 and magnitude + position <= 0) {
                std.debug.print("Starting: {d}, mag: {d}, Ending: {d}, count: {d}\n", .{ position, magnitude, magnitude + position, @divTrunc(magnitude + position, -100) + 1 });
                //try std.testing.io.sleep(std.Io.Duration.fromSeconds(5), std.Io.Clock.real);
                result += @divTrunc((magnitude + position), -100);
                if (position != 0) {
                    result += 1;
                }
            }
            position = try std.math.mod(i32, position + magnitude, 100);
        }
    }
    std.debug.print("Part 2: {d}\n", .{result});
}

pub fn main() !void {
    var input: [19136]u8 = undefined;
    try read_input(&input);
    try part_1(&input);
    try part_2(&input);
}
