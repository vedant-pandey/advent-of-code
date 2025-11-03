const std = @import("std");
const utils = @import("utils.zig");
const FileName = "/Volumes/RAM_Disk_10GB/day18";

const InstructionCount = 3450;
const GridRow = 71;
const GridCol = 71;

const Point = std.meta.Tuple(&.{ i32, i32 });
const Node = std.meta.Tuple(&.{ i32, i32, u64 });

fn toNode(point: Point) Node {
    return .{ point[0], point[1], 0 };
}

fn toPoint(node: Node) Point {
    return .{ node[0], node[1] };
}

inline fn pointEq(f: Point, s: Point) bool {
    return f[0] == s[0] and f[1] == s[1];
}

inline fn isValid(p: Point) bool {
    return p[0] >= 0 and p[0] < GridRow and p[1] >= 0 and p[1] < GridCol;
}

const Dir = utils.Direction;

fn fillGrid(grid: *[GridRow][GridCol]u8, instructionList: *const [InstructionCount]Point, iterLen: u64) void {
    for (instructionList[0..iterLen]) |inst| {
        grid[@intCast(inst[0])][@intCast(inst[1])] = '#';
    }
}

fn get(grid: *[GridRow][GridCol]u8, p: Point) u8 {
    return grid[@intCast(p[0])][@intCast(p[1])];
}

fn set(grid: *[GridRow][GridCol]u8, p: Point, val: u8) void {
    grid[@intCast(p[0])][@intCast(p[1])] = val;
}

fn bfs(grid: *[GridRow][GridCol]u8, allocator: std.mem.Allocator) [2]u64 {
    const st: Point = .{ 0, 0 };
    const en: Point = .{ GridRow - 1, GridCol - 1 };
    var visited = std.AutoHashMap(Point, bool).init(allocator);
    defer visited.deinit();

    var soln: [2]u64 = .{ std.math.maxInt(u64), 0 };

    var qBuffer: [GridRow * GridCol]Node = undefined;
    var bfsQ = utils.StaticDeque(Node).init(&qBuffer);
    visited.put(st, true) catch unreachable;

    _ = bfsQ.add(toNode(st));

    while (!bfsQ.empty()) {
        const cur = bfsQ.pop().?;
        const curPoint = toPoint(cur);

        if (pointEq(curPoint, en)) {
            soln[0] = @min(soln[0], cur[2]);
            soln[1] = 1;
            return soln;
        }

        inline for (std.meta.fields(Dir)) |dirName| {
            const d: [2]i8 = (@field(Dir, dirName.name)).getPoint();
            const next = Node{
                cur[0] + d[0],
                cur[1] + d[1],
                cur[2] + 1,
            };

            const n = toPoint(next);

            if (isValid(n) and !visited.contains(n) and get(grid, n) != '#') {
                visited.put(n, true) catch unreachable;
                _ = bfsQ.add(next);
            }
        }
    }

    return soln;
}

fn part1(grid: *[GridRow][GridCol]u8, instructionList: *const [InstructionCount]Point, allocator: std.mem.Allocator) !void {
    const t = utils.Timer.start("Part 1");
    defer t.end();

    fillGrid(grid, instructionList, 1024);

    const soln = bfs(grid, allocator);

    std.debug.print("Part 1 - {any}\n", .{soln});
}

fn part2(grid: *[GridRow][GridCol]u8, instructionList: *const [InstructionCount]Point, allocator: std.mem.Allocator) !void {
    const t = utils.Timer.start("Part 2");
    defer t.end();

    var soln: Point = .{ 0, 0 };
    var left: usize = 0;
    var right: usize = instructionList.len;

    while (left < right) {
        const mid = left + (right - left) / 2;

        grid.* = .{.{0} ** GridCol} ** GridRow;
        fillGrid(grid, instructionList, mid + 1);

        _, const isOpen = bfs(grid, allocator);

        if (isOpen == 0) {
            soln = instructionList[mid];
            right = mid;
        } else {
            left = mid + 1;
        }
    }

    std.debug.print("Part 2 - {}\n", .{soln});
}

pub fn main() !void {
    var file = try std.fs.openFileAbsolute(FileName, .{ .mode = .read_only });
    defer file.close();

    var inputBuffer: [1024 * 1024]u8 = undefined;
    var reader = file.reader(&inputBuffer);
    var grid: [GridRow][GridCol]u8 = .{.{0} ** GridCol} ** GridRow;

    var instArr: [InstructionCount]Point = undefined;

    {
        const t = utils.Timer.start("Reading input");
        defer t.end();

        var i: usize = 0;

        while (reader.interface.takeDelimiterExclusive('\n')) |line| {
            var it = std.mem.splitAny(u8, line, ",");
            instArr[i] = .{
                try std.fmt.parseUnsigned(i16, it.next().?, 10),
                try std.fmt.parseUnsigned(i16, it.next().?, 10),
            };
            i += 1;
        } else |err| switch (err) {
            error.EndOfStream => {},
            else => return err,
        }
    }

    var arena = std.heap.ArenaAllocator.init(std.heap.raw_c_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    try part1(&grid, &instArr, allocator);
    grid = .{.{0} ** GridCol} ** GridRow;
    try part2(&grid, &instArr, allocator);
}
