const std = @import("std");
const FileName = "/Volumes/RAM_Disk_10GB/day16";
// 141 * 141

// CONSTANTS
const GridSize = 141;
const BufferSize = 1024 * 1024;

// POSITIONS STRUCT
const Positions = packed struct(u32) {
    stI: u8 = 0,
    stJ: u8 = 0,
    enI: u8 = 0,
    enJ: u8 = 0,
};

// DIRECTION ENUM
const Direction = enum(u2) {
    up,
    down,
    left,
    right,

    fn getNextItem(self: @This(), item: Item) Item {
        var next = item;
        switch (self) {
            .up => {
                next.row -= 1;
            },
            .down => {
                next.row += 1;
            },
            .left => {
                next.col -= 1;
            },
            .right => {
                next.col += 1;
            },
        }
        if (next.dir != self) {
            next.trn += 1;
        }
        next.dir = self;
        next.len += 1;
        return next;
    }
};

// ITEM STRUCT
const Item = packed struct(u64) {
    row: i9 = 0, // -128 to 127
    col: i9 = 0,
    len: u32 = 0,
    trn: u12 = 0,
    dir: Direction = .right,

    fn state(self: @This()) State {
        return .{
            .row = self.row,
            .col = self.col,
            .dir = self.dir,
        };
    }

    fn cost(self: @This()) u64 {
        return @as(u64, @intCast(self.trn))*1000 + @as(u64, @intCast(self.len));
    }
};

// STATE STRUCT
const State = struct {
    row: i9 = 0,
    col: i9 = 0,
    dir: Direction,
};

// STATIC QUEUE COMPTIME
fn Queue(comptime T: type, comptime capacity: usize) type {
    return struct {
        items: [capacity]T = undefined,
        head: usize = 0,
        tail: usize = 0,
        count: usize = 0,

        const Self = @This();

        fn push(self: *Self, item: T) !void {
            if (self.count >= capacity) {
                return error.QueueOverflow;
            }

            self.items[self.tail] = item;
            self.tail = (self.tail + 1) % capacity;
            self.count += 1;
        }

        fn pop(self: *Self) !T {
            if (self.count == 0) {
                return error.QueueUnderflow;
            }

            const item = self.items[self.head];
            self.head = (self.head + 1) % capacity;
            self.count -= 1;
            return item;
        }

        fn isEmpty(self: *const Self) bool {
            return self.count == 0;
        }
    };
}

// DYNAMIC QUEUE COMPTIME
fn DynamicQueue(comptime T: type) type {
    return struct {
        items: []T = undefined,
        head: usize = 0,
        tail: usize = 0,
        count: usize = 0,
        allocator: std.mem.Allocator,

        const Self = @This();

        fn init(allocator: std.mem.Allocator, initial_capacity: usize) !Self {
            const items = try allocator.alloc(Item, initial_capacity);
            return Self{
                .items = items,
                .allocator = allocator,
            };
        }

        fn deinit(self: *Self) void {
            self.allocator.free(self.items);
        }

        fn push(self: *Self, item: T) !void {
            if (self.count >= self.items.len) {
                try self.grow();
            }

            std.debug.print("Push | Head - {} | Tail - {} | Count - {}\n", .{ self.head, self.tail, self.count });

            self.items[self.tail] = item;
            self.tail = (self.tail + 1) % self.items.len;
            self.count += 1;
        }

        fn pop(self: *Self) !T {
            if (self.count == 0) {
                return error.QueueUnderflow;
            }
            std.debug.print("Pop | Head - {} | Tail - {} | Count - {}\n", .{ self.head, self.tail, self.count });

            const item = self.items[self.head];
            self.head = (self.head + 1) % self.items.len;
            self.count -= 1;
            return item;
        }

        fn grow(self: *Self) !void {
            const new_cap = self.items.len * 2;
            self.items = try self.allocator.realloc(self.items, new_cap);
        }

        fn empty(self: *const Self) bool {
            return self.count == 0;
        }
    };
}

fn compareItems(_: void, a: Item, b: Item) std.math.Order {
    return std.math.order(@as(u64, @intCast(a.trn)) * 1000 + @as(u64, @intCast(a.len)), @as(u64, @intCast(b.trn)) * 1000 + @as(u64, @intCast(b.len)));
}

inline fn isValid(item: Item) bool {
    return item.row >= 0 and item.row < GridSize and item.col >= 0 and item.col < GridSize;
}

fn part1(grid: *[GridSize][GridSize]u8, allocator: std.mem.Allocator, pos: Positions) u64 {
    const st = std.time.Instant.now() catch unreachable;

    var soln: u64 = std.math.maxInt(u64);

    var visitedSet = std.AutoHashMap(State, bool).init(allocator);
    defer visitedSet.deinit();

    var heap = std.PriorityQueue(Item, void, compareItems).init(allocator, {});
    defer heap.deinit();

    const first: Item = .{ .row = pos.stI, .col = pos.stJ };
    heap.add(first) catch unreachable;

    while (heap.removeOrNull()) |cur| {
        const state = State{ .row = cur.row, .col = cur.col, .dir = cur.dir };
        if (visitedSet.contains(state)) {
            continue;
        }
        visitedSet.put(state, true) catch unreachable;

        if (cur.row == pos.enI and cur.col == pos.enJ) {
            soln = @as(u64, @intCast(cur.trn)) * 1000 + @as(u64, @intCast(cur.len));
            break;
        }

        inline for (std.meta.fields(Direction)) |dir| {
            const dirName: Direction = @field(Direction, dir.name);
            const next = dirName.getNextItem(cur);

            if (isValid(next)) {
                const nextState = State{ .row = next.row, .col = next.col, .dir = next.dir };
                if (!visitedSet.contains(nextState)) {
                    const cell = grid[@intCast(next.row)][@intCast(next.col)];
                    if (cell != '#') {
                        heap.add(next) catch unreachable;
                    }
                }
            }
        }
    }

    const en = std.time.Instant.now() catch unreachable;
    std.debug.print("Part 1 - {}\n", .{soln});
    std.debug.print("\tTime - {:0>9} ns\n", .{en.since(st)});

    return soln;
}

fn part2(grid: *[GridSize][GridSize]u8, allocator: std.mem.Allocator, pos: Positions, target_cost: u64) void {
    const st = std.time.Instant.now() catch unreachable;

    var queue = std.PriorityQueue(Item, void, compareItems).init(allocator, {});
    defer queue.deinit();

    var dist = std.AutoHashMap(State, u64).init(allocator);
    defer dist.deinit();

    var predecessors = std.AutoHashMap(State, std.ArrayList(State)).init(allocator);
    defer {
        var it = predecessors.iterator();
        while (it.next()) |entry| {
            entry.value_ptr.deinit(allocator);
        }
        predecessors.deinit();
    }

    const first: Item = .{ .row = pos.stI, .col = pos.stJ, .dir = .right };
    const firstState = first.state();

    queue.add(first) catch unreachable;
    dist.put(firstState, 0) catch unreachable;

    var endStates = std.ArrayList(State).initCapacity(allocator, 100) catch unreachable;
    defer endStates.deinit(allocator);

    while (queue.removeOrNull()) |cur| {
        const state = cur.state();

        const curDist = dist.get(state) orelse continue;
        if (curDist < cur.cost()) continue;

        if (cur.row == pos.enI and cur.col == pos.enJ and cur.cost() == target_cost) {
            endStates.append(allocator, state) catch unreachable;
        }

        inline for (std.meta.fields(Direction)) |dir| {
            const dirName: Direction = @field(Direction, dir.name);
            const next = dirName.getNextItem(cur);

            if (isValid(next)) {
                const cell = grid[@as(u64, @intCast(next.row))][@as(u64, @intCast(next.col))];
                if (cell != '#') {
                    const nextState = next.state();
                    const nextDist = dist.get(nextState) orelse std.math.maxInt(u64);

                    if (next.cost() < nextDist) {
                        dist.put(nextState, next.cost()) catch unreachable;
                        queue.add(next) catch unreachable;

                        var k = predecessors.get(nextState);

                        if (k) |*list| {
                            list.clearRetainingCapacity();
                        } else {
                            predecessors.put(nextState, std.ArrayList(State).initCapacity(allocator, 100) catch unreachable) catch unreachable;
                        }
                        predecessors.getPtr(nextState).?.append(allocator, state) catch unreachable;
                    } else if (next.cost() == nextDist) {
                        if (!predecessors.contains(nextState)) {
                            predecessors.put(nextState, std.ArrayList(State).initCapacity(allocator, 100) catch unreachable) catch unreachable;
                        }

                        predecessors.getPtr(nextState).?.append(allocator, state) catch unreachable;
                    }
                }
            }
        }
    }

    var tilesOnPath = std.AutoHashMap([2]i9, bool).init(allocator);
    defer tilesOnPath.deinit();

    var backtrack = std.ArrayList(State).initCapacity(allocator, 100) catch unreachable;
    defer backtrack.deinit(allocator);

    var visited = std.AutoHashMap(State, bool).init(allocator);
    defer visited.deinit();

    for (endStates.items) |endState| {
        backtrack.append(allocator, endState) catch unreachable;
    }

    while (backtrack.items.len > 0) {
        const state = backtrack.pop();

        if (visited.contains(state.?)) continue;

        visited.put(state.?, true) catch unreachable;

        tilesOnPath.put(.{state.?.row, state.?.col}, true) catch unreachable;

        if (predecessors.get(state.?)) |preds| {
            for (preds.items) |pred| {
                backtrack.append(allocator, pred) catch unreachable;
            }
        }
    }

    const soln = tilesOnPath.count();
    const en = std.time.Instant.now() catch unreachable;
    std.debug.print("Part 2 - {}\n", .{soln});
    std.debug.print("\tTime - {:0>9} ns\n", .{en.since(st)});
}

pub fn main() !void {
    var file = try std.fs.openFileAbsolute(FileName, .{ .mode = .read_only });
    defer file.close();

    var inputBuffer: [BufferSize]u8 = undefined;
    var reader = file.reader(&inputBuffer);

    const st = std.time.Instant.now() catch unreachable;

    var grid: [GridSize][GridSize]u8 = .{.{0} ** GridSize} ** GridSize;
    var pos: Positions = .{};

    for (0..GridSize) |i| {
        const line = reader.interface.takeDelimiterExclusive('\n') catch unreachable;
        for (0..GridSize) |j| {
            grid[i][j] = line[j];
            if (grid[i][j] == 'S') {
                pos.stI = @intCast(i);
                pos.stJ = @intCast(j);
            }
            if (grid[i][j] == 'E') {
                pos.enI = @intCast(i);
                pos.enJ = @intCast(j);
            }
        }
    }

    const en = std.time.Instant.now() catch unreachable;
    std.debug.print("Reading Input - {:0>9} ns\n", .{en.since(st)});

    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const cost = part1(&grid, allocator, pos);
    part2(&grid, allocator, pos, cost);
}
