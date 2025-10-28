const std = @import("std");
const FileName = "/Volumes/RAM_Disk_10GB/day14";
const TimeLimit = 100;
const Width = 101;
const Height = 103;

const Robot = struct { posX: i32, posY: i32, velX: i32, velY: i32 };

inline fn tick(roboList: *std.ArrayList(Robot)) *std.ArrayList(Robot) {
    for (roboList.items) |*robo| {
        robo.posX = @mod(robo.posX + robo.velX, Width);
        robo.posY = @mod(robo.posY + robo.velY, Height);
    }

    return roboList;
}

inline fn calcSafety(roboList: *std.ArrayList(Robot)) u64 {
    var q1: usize = 0;
    var q2: usize = 0;
    var q3: usize = 0;
    var q4: usize = 0;
    for (roboList.items) |robo| {
        if ((robo.posX == Width / 2) or (robo.posY == Height / 2)) {
            continue;
        }

        if ((robo.posX < Width / 2) and (robo.posY < Height / 2)) {
            q1 += 1;
        } else if ((robo.posX < Width / 2) and (robo.posY > Height / 2)) {
            q2 += 1;
        } else if ((robo.posX > Width / 2) and (robo.posY < Height / 2)) {
            q3 += 1;
        } else {
            q4 += 1;
        }
    }

    return q1 * q2 * q3 * q4;
}

fn part1(roboList: *std.ArrayList(Robot)) void {
    const st = std.time.Instant.now() catch unreachable;
    for (0..TimeLimit) |_| {
        _ = tick(roboList);
    }
    const soln = calcSafety(roboList);
    std.debug.print("Part 1 - {}\n", .{soln});
    const en = std.time.Instant.now() catch unreachable;
    std.debug.print("\tTime - {}\n", .{en.since(st)});
}

fn part2(roboList: *std.ArrayList(Robot)) void {
    var minSafety: u64 = std.math.maxInt(u64);
    var treeTime: u64 = 0;

    for (0..10000) |step| {
        const curSafety = calcSafety(tick(roboList));
        if (curSafety < minSafety) {
            minSafety = curSafety;
            treeTime = step + 1;
        }
    }

    std.debug.print("Part 2 - {}\n", .{treeTime});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var file = try std.fs.openFileAbsolute(FileName, .{ .mode = .read_only });
    defer file.close();

    var roboBuffer: [500]Robot = undefined;
    var roboList = std.ArrayListUnmanaged(Robot).initBuffer(&roboBuffer);

    var buffer: [1024 * 1024]u8 = undefined;
    var reader = file.reader(&buffer);

    const st = try std.time.Instant.now();

    while (true) {
        const line = reader.interface.takeDelimiterExclusive('\n') catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        {
            var e1: usize = 0;
            var c1: usize = 0;
            var s: usize = 0;
            var e2: usize = 0;
            var c2: usize = 0;
            for (line, 0..) |ch, i| {
                if (ch == ',') {
                    if (c1 == 0) {
                        c1 = @intCast(i);
                    } else {
                        c2 = @intCast(i);
                    }
                } else if (ch == '=') {
                    if (e1 == 0) {
                        e1 = @intCast(i);
                    } else {
                        e2 = @intCast(i);
                    }
                } else if (ch == ' ') {
                    s = @intCast(i);
                }
            }

            const posX = try std.fmt.parseInt(i32, line[e1 + 1 .. c1], 10);
            const posY = try std.fmt.parseInt(i32, line[c1 + 1 .. s], 10);
            const velX = try std.fmt.parseInt(i32, line[e2 + 1 .. c2], 10);
            const velY = try std.fmt.parseInt(i32, line[c2 + 1 ..], 10);

            try roboList.append(allocator, .{ .posX = posX, .posY = posY, .velX = velX, .velY = velY });
        }
    }
    // std.Thread.sleep(2_000_000_000);
    const en = try std.time.Instant.now();
    std.debug.print("Reading Input - {d} ns\n", .{en.since(st)});

    var clone = roboList.clone(allocator) catch unreachable;
    defer clone.deinit(allocator);

    part1(&clone);
    part2(&roboList);
}
