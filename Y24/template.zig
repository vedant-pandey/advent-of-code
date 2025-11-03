const std = @import("std");
const utils = @import("utils.zig");
const FileName = "/Volumes/RAM_Disk_10GB/day18";

fn part1() void {
    const st = std.time.Instant.now() catch unreachable;

    const soln = 0;

    const en = std.time.Instant.now() catch unreachable;
    std.debug.print("Part 1 - {}\n", .{soln});
    std.debug.print("\tTime - {}\n", .{en.since(st)});
}

fn part2() void {
    const st = std.time.Instant.now() catch unreachable;

    const soln = 0;
    const en = std.time.Instant.now() catch unreachable;
    std.debug.print("Part 2 - {}\n", .{soln});
    std.debug.print("\tTime - {}\n", .{en.since(st)});
}

pub fn main() !void {
    var file = try std.fs.openFileAbsolute(FileName, .{ .mode = .read_only });
    defer file.close();

    var inputBuffer: [1024 * 1024]u8 = undefined;
    var reader = file.reader(&inputBuffer);

    while (reader.interface.takeDelimiterExclusive('\n')) |line| {
        _ = line;
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }

    part1();
    part2();
}
