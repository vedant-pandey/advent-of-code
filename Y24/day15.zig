const std = @import("std");
const FileName = "/Volumes/RAM_Disk_10GB/day15";

fn widenMap(map: *const [50][50]u8) [50][100]u8 {
    var wideMap: [50][100]u8 = .{.{0} ** 100} ** 50;
    for (map, 0..) |row, i| {
        for (row, 0..) |val, j| {
            switch (val) {
                '#' => {
                    wideMap[i][2 * j] = '#';
                    wideMap[i][2 * j + 1] = '#';
                },
                'O' => {
                    wideMap[i][2 * j] = '[';
                    wideMap[i][2 * j + 1] = ']';
                },
                '.' => {
                    wideMap[i][2 * j] = '.';
                    wideMap[i][2 * j + 1] = '.';
                },
                '@' => {
                    wideMap[i][2 * j] = '@';
                    wideMap[i][2 * j + 1] = '.';
                },
                else => unreachable,
            }
        }
    }
    return wideMap;
}

fn canMove(map: *[50][50]u8, row: i64, col: i64, dr: i64, dc: i64) bool {
    const newRow = row + dr;
    const newCol = col + dc;

    if (newRow < 0 or newRow >= 50 or newCol < 0 or newCol >= 50) {
        return false;
    }

    const cell = map[@intCast(newRow)][@intCast(newCol)];

    if (cell == '#') {
        return false;
    }

    if (cell == '.') {
        return true;
    }

    if (cell == 'O') {
        return canMove(map, newRow, newCol, dr, dc);
    }

    return false;
}

fn doMove(map: *[50][50]u8, row: i64, col: i64, dr: i64, dc: i64) void {
    const newRow = row + dr;
    const newCol = col + dc;

    const cell = map[@intCast(newRow)][@intCast(newCol)];

    if (cell == 'O') {
        doMove(map, newRow, newCol, dr, dc);
    }

    // Move current cell to new position
    map[@intCast(newRow)][@intCast(newCol)] = map[@intCast(row)][@intCast(col)];
    map[@intCast(row)][@intCast(col)] = '.';
}

fn moveStep(map: *[50][50]u8, inst: u8, roboRow: *i64, roboCol: *i64) void {
    var dr: i64 = 0;
    var dc: i64 = 0;

    switch (inst) {
        '^' => dr = -1,
        'v' => dr = 1,
        '<' => dc = -1,
        '>' => dc = 1,
        else => return,
    }

    if (canMove(map, roboRow.*, roboCol.*, dr, dc)) {
        doMove(map, roboRow.*, roboCol.*, dr, dc);
        roboRow.* += dr;
        roboCol.* += dc;
    }
}

fn calculateGPS(map: *[50][50]u8) i64 {
    var sum: i64 = 0;
    for (map.*, 0..) |row, i| {
        for (row, 0..) |cell, j| {
            if (cell == 'O') {
                sum += @as(i64, @intCast(i)) * 100 + @as(i64, @intCast(j));
            }
        }
    }
    return sum;
}

fn part1(map: *[50][50]u8, instructions: []const u8, roboRow: *i64, roboCol: *i64) void {
    const st = std.time.Instant.now() catch unreachable;

    for (instructions) |inst| {
        moveStep(map, inst, roboRow, roboCol);
    }

    const soln = calculateGPS(map);

    const en = std.time.Instant.now() catch unreachable;
    std.debug.print("Part 1 - {}\n", .{soln});
    std.debug.print("\tTime - {}\n", .{en.since(st)});
}

fn moveStep2(map: *[50][100]u8, inst: u8, roboRow: *i64, roboCol: *i64) void {
    var dr: i64 = 0;
    var dc: i64 = 0;

    switch (inst) {
        '^' => dr = -1,
        'v' => dr = 1,
        '<' => dc = -1,
        '>' => dc = 1,
        else => return,
    }

    if (canMove2(map, roboRow.*, roboCol.*, dr, dc)) {
        doMove2(map, roboRow.*, roboCol.*, dr, dc);
        roboRow.* += dr;
        roboCol.* += dc;
    }
}

fn canMove2(map: *[50][100]u8, row: i64, col: i64, dr: i64, dc: i64) bool {
    const newRow = row + dr;
    const newCol = col + dc;

    if (newRow < 0 or newRow >= map.len or newCol < 0 or newCol >= map[0].len) {
        return false;
    }

    const cell = map[@intCast(newRow)][@intCast(newCol)];

    if (cell == '#') {
        return false;
    }

    if (cell == '.') {
        return true;
    }

    if (dr == 0) {
        return canMove2(map, newRow, newCol, dr, dc);
    }

    if (cell == '[') {
        return canMove2(map, newRow, col, dr, dc) and canMove2(map, newRow, col+1, dr, dc);
    }

    if (cell == ']') {
        return canMove2(map, newRow, col-1, dr, dc) and canMove2(map, newRow, col, dr, dc);
    }

    return false;
}

fn doMove2(map: *[50][100]u8, row: i64, col: i64, dr: i64, dc: i64) void {
    const newRow = row + dr;
    const newCol = col + dc;
    const cell = map[@intCast(newRow)][@intCast(newCol)];

    // Horizontal movement - simpler, just chain
    if (dr == 0) {
        if (cell != '.') {
            doMove2(map, newRow, newCol, dr, dc);
        }
    } else {
        // Vertical movement - must move BOTH parts of the box
        if (cell == '[') {
            doMove2(map, newRow, newCol, dr, dc);
            doMove2(map, newRow, newCol + 1, dr, dc);
        } else if (cell == ']') {
            doMove2(map, newRow, newCol - 1, dr, dc);
            doMove2(map, newRow, newCol, dr, dc);
        }
    }

    // Move current cell to new position
    map[@intCast(newRow)][@intCast(newCol)] = map[@intCast(row)][@intCast(col)];
    map[@intCast(row)][@intCast(col)] = '.';
}

fn calculateGPS2(map: *[50][100]u8) i64 {
    var sum: i64 = 0;
    for (map.*, 0..) |row, i| {
        for (row, 0..) |cell, j| {
            if (cell == '[') {
                sum += @as(i64, @intCast(i)) * 100 + @as(i64, @intCast(j));
            }
        }
    }
    return sum;
}

fn part2(map: *[50][100]u8, instructions: []const u8, roboRow: *i64, roboCol: *i64) void {
    const st = std.time.Instant.now() catch unreachable;

    for (instructions) |inst| {
        moveStep2(map, inst, roboRow, roboCol);
    }
    const soln = calculateGPS2(map);
    const en = std.time.Instant.now() catch unreachable;
    std.debug.print("Part 2 - {}\n", .{soln});
    std.debug.print("\tTime - {}\n", .{en.since(st)});
}

pub fn main() !void {
    var file = try std.fs.openFileAbsolute(FileName, .{ .mode = .read_only });
    defer file.close();

    var inputBuffer: [1024 * 1024]u8 = undefined;
    var reader = file.reader(&inputBuffer);

    const st = std.time.Instant.now() catch unreachable;
    var map: [50][50]u8 = .{.{0} ** 50} ** (50);
    var mapReady = false;
    var ind: u32 = 0;

    var instructions: [20 * 1000]u8 = .{0} ** (20 * 1000);
    var instInd: u32 = 0;
    var roboRow: i64 = 0;
    var roboCol: i64 = 0;

    while (reader.interface.takeDelimiterExclusive('\n')) |line| {
        if (line.len == 0) continue;
        mapReady = ind >= 50;
        if (!mapReady) {
            for (0..50) |j| {
                map[ind][j] = line[j];
                if (line[j] == '@') {
                    roboRow = ind;
                    roboCol = @intCast(j);
                }
            }
        } else {
            for (0..line.len) |j| {
                instructions[instInd] = line[j];
                instInd += 1;
            }
        }
        ind += 1;
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }

    const en = std.time.Instant.now() catch unreachable;
    std.debug.print("Reading Input - {d} ns\n", .{en.since(st)});

    var wideMap = widenMap(&map);
    var wideRoboRow = roboRow;
    var wideRoboCol = 2 * roboCol;
    part1(&map, &instructions, &roboRow, &roboCol);
    part2(&wideMap, &instructions, &wideRoboRow, &wideRoboCol);
}
