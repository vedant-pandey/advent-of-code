const std = @import("std");
const FileName = "/Volumes/RAM_Disk_10GB/day15";

const Cell = enum(u3) {
    empty = 0,
    wall = 1,
    box = 2,
    robot = 3,

    wideBoxSt = 4,
    wideBoxEn = 5,

    fn fromChar(c: u8) Cell {
        return switch (c) {
            '.' => .empty,
            '#' => .wall,
            'O' => .box,
            '@' => .robot,
            '[' => .wideBoxSt,
            ']' => .wideBoxEn,
            else => unreachable,
        };
    }
    fn toChar(self: Cell) u8 {
        return switch (self) {
            .empty => '.',
            .wall => '#',
            .box => 'O',
            .robot => '@',
            .wideBoxSt => '[',
            .wideBoxEn => ']',
        };
    }
};

fn PackedCells(comptime T: type) type {
    return packed struct(T) {
        bits: (T) = 0,
        fn get(self: @This(), i: usize) Cell {
            const shift = @as(u8, @intCast(i * 3));
            const mask: T = 0b111;
            const val = (self.bits >> shift) & mask;
            return @enumFromInt(@as(u3, @intCast(val)));
        }

        pub fn set(self: *@This(), index: usize, value: Cell) void {
            const shift = @as(u8, @intCast(index * 3));
            const mask: T = 0b111;
            const clear_mask = ~(mask << shift);
            self.bits = (self.bits & clear_mask) | (@as(T, @intFromEnum(value)) << shift);
        }
    };
}

const PackedCells50 = packed struct(u150) {
    bits: u150 = 0,

    fn get(self: @This(), i: usize) Cell {
        const shift = @as(u8, @intCast(i * 3));
        const mask: u192 = 0b111;
        const val = (self.bits >> shift) & mask;
        return @enumFromInt(@as(u3, @intCast(val)));
    }

    pub fn set(self: *@This(), index: usize, value: Cell) void {
        const shift = @as(u8, @intCast(index * 3));
        const mask: u150 = 0b111;
        const clear_mask = ~(mask << shift);
        self.bits = (self.bits & clear_mask) | (@as(u150, @intFromEnum(value)) << shift);
    }
};

fn Warehouse(rows: comptime_int, cols: comptime_int) type {
    return struct {
        map: [rows]PackedCells(u150) = [_]PackedCells(u150){PackedCells(u150){}} ** rows,
        robo: Point,

        inline fn get(self: @This(), point: Point) Cell {
            return self.map[@intCast(point.x)].get(@intCast(point.y));
        }

        inline fn set(self: *@This(), point: Point, val: Cell) void {
            self.map[@intCast(point.x)].set(@intCast(point.y), val);
        }

        inline fn setInd(self: *@This(), i: usize, j: usize, val: Cell) void {
            self.map[i].set(j, val);
        }

        inline fn calculateGPS(self: @This()) u64 {
            var sum: u64 = 0;
            inline for (self.map, 0..) |row, i| {
                for (0..cols) |j| {
                    if (row.get(j) == .box) {
                        sum += @as(u64, @intCast(i)) * 100 + @as(u64, @intCast(j));
                    }
                }
            }
            return sum;
        }

        fn canMove(self: @This(), d: Direction) bool {
            var newP: Point = self.robo;
            newP = newP.move(d);

            if ((@as(u64, @intCast(newP.x)) >= rows) | (@as(u64, @intCast(newP.y)) >= cols)) {
                @branchHint(.unlikely);
                return false;
            }

            while (self.get(newP) == .box) {
                newP = newP.move(d);
            }

            return self.get(newP) == .empty;
        }

        inline fn moveRobotIterative(self: *@This(), d: Direction) void {
            var positions: [cols]Point = undefined;
            var count: usize = 0;

            var current = self.robo;
            while (count < cols) {
                positions[count] = current;
                count += 1;

                const next = current.move(d);
                const cell = self.get(next);

                switch (cell) {
                    .wall => return,
                    .empty => break,
                    .box => {
                        current = next;
                    },
                    else => unreachable,
                }
            }

            var i: usize = count;
            while (i > 0) {
                i -= 1;
                const from = positions[i];
                const to = from.move(d);
                self.set(to, self.get(from));
                self.set(from, .empty);
            }

            self.robo = self.robo.move(d);
        }

        fn tryMove(self: *@This(), d: Direction) void {
            if (!self.canMove(d)) {
                return;
            }

            moveRobotIterative(self, d);
        }
    };
}

const Point = packed struct(u32) {
    x: i16 = 0,
    y: i16 = 0,

    inline fn addPoint(self: Point, other: Point) Point {
        return .{
            .x = self.x + other.x,
            .y = self.y + other.y,
        };
    }

    inline fn move(self: Point, dir: Direction) Point {
        return self.addPoint(dir.getPoint());
    }
};

const Direction = enum {
    up,
    left,
    right,
    down,

    inline fn getPoint(self: Direction) Point {
        return switch (self) {
            .up => .{ .x = -1, .y = 0 },
            .down => .{ .x = 1, .y = 0 },
            .right => .{ .x = 0, .y = 1 },
            .left => .{ .x = 0, .y = -1 },
        };
    }

    inline fn fromChar(ch: u8) Direction {
        return switch (ch) {
            '^' => .up,
            'v' => .down,
            '<' => .left,
            '>' => .right,
            else => unreachable,
        };
    }
};

fn inflateWarehouse(warehouse: Warehouse(50, 50)) Warehouse(50, 100) {
    var wide: Warehouse(50, 100) = undefined;
    for (warehouse.map, 0..) |row, i| {
        for (0..50) |j| {
            wide.setInd(i, 2 * j, .empty);
            wide.setInd(i, 2 * j + 1, row.get(j));
            switch (row.get(j)) {
                .wall => {
                    wide.setInd(i, 2 * j, .wall);
                },
                .box => {
                    wide.setInd(i, 2 * j, .wideBoxSt);
                    wide.setInd(i, 2 * j + 1, .wideBoxEn);
                },
                else => {},
            }
        }
    }

    return wide;
}

// fn part1(warehouse: *Warehouse(50, 50), instructions: []const u8, robo: Point) void {
fn part1(warehouse: *Warehouse(50, 50), instructions: []const u8) void {
    const st = std.time.Instant.now() catch unreachable;

    for (instructions) |inst| {
        warehouse.tryMove(Direction.fromChar(inst));
    }

    const soln = warehouse.calculateGPS();

    const en = std.time.Instant.now() catch unreachable;
    std.debug.print("Part 1 - {}\n", .{soln});
    std.debug.print("\tTime - {}\n", .{en.since(st)});
}

fn part2() void {
    const st = std.time.Instant.now() catch unreachable;
    const soln = 0;
    std.debug.print("Part 2 - {}\n", .{soln});
    const en = std.time.Instant.now() catch unreachable;
    std.debug.print("\tTime - {}\n", .{en.since(st)});
}

pub fn main() !void {
    var file = try std.fs.openFileAbsolute(FileName, .{ .mode = .read_only });
    defer file.close();

    var inputBuffer: [1024 * 1024]u8 = undefined;
    var reader = file.reader(&inputBuffer);

    const st = std.time.Instant.now() catch unreachable;
    var warehouse: Warehouse(50, 50) = undefined;
    var i: u32 = 0;

    var instructions: [20 * 1000]u8 = .{0} ** (20 * 1000);
    var instInd: u32 = 0;

    while (reader.interface.takeDelimiterExclusive('\n')) |line| {
        if (line.len == 0) continue;
        if (i < 50) {
            for (0..50) |j| {
                const point: Point = .{ .x = @intCast(i), .y = @intCast(j) };
                warehouse.set(point, Cell.fromChar(line[j]));
                if (line[j] == '@') {
                    warehouse.robo = point;
                }
            }
        } else {
            for (0..line.len) |j| {
                instructions[instInd] = line[j];
                instInd += 1;
            }
        }
        i += 1;
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }

    const en = std.time.Instant.now() catch unreachable;
    std.debug.print("Reading Input - {d} ns\n", .{en.since(st)});

    // var wide: Warehouse(50, 100) = inflateWarehouse(warehouse);
    part1(&warehouse, &instructions);
    // part2(&wide);
    part2();
}
