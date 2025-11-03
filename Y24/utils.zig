const std = @import("std");

// Timer util
pub const Timer = struct {
    st: std.time.Instant,
    label: [*:0]const u8,
    pub fn end(self: @This()) void {
        const en = std.time.Instant.now() catch unreachable;
        var time: f64 = @floatFromInt(en.since(self.st));
        time /= 1.0e9;
        std.debug.print("[{s}] Time - {d:10.9}s\n", .{ self.label, time });
    }
    pub fn start(label: [*:0]const u8) Timer {
        return .{
            .st = std.time.Instant.now() catch unreachable,
            .label = label,
        };
    }
};

pub const AggregateTimer = struct {
    lastSt: std.time.Instant,
    label: [*:0]const u8,
    count: u64,
    totalTime: u64,
    pub fn init(label: [*:0]const u8) AggregateTimer {
        return .{
            .label = label,
            .lastSt = std.time.Instant.now() catch unreachable,
            .count = 0,
            .totalTime = 0,
        };
    }

    const Self = @This();

    pub fn addStart(self: *Self) void {
        self.lastSt = std.time.Instant.now() catch unreachable;
    }

    pub fn addStop(self: *Self) void {
        const en = std.time.Instant.now() catch unreachable;
        self.totalTime += en.since(self.lastSt);
        self.count += 1;
        self.lastSt = en;
    }

    pub fn end(self: *Self) void {
        const en = std.time.Instant.now() catch unreachable;
        self.totalTime += en.since(self.lastSt);
        self.lastSt = en;

        const time: f64 = @as(f64, @floatFromInt(self.totalTime)) / 1.0e9;
        const avgTime: f64 = time / @as(f64, @floatFromInt(self.count));
        std.debug.print(
            \\[{s}]
            \\        Total Time - {d:10.9}s
            \\        Avg Time   - {d:10.9}s
            \\        Count      - {} times
            \\
        , .{ self.label, time, avgTime, self.count });
    }
};

pub fn listEqual(comptime T: type, listA: *const std.ArrayList(T), listB: *const std.ArrayList(T)) bool {
    if (listA.items.len != listB.items.len) return false;

    for (0..listA.items.len) |i| {
        if (listA.items[i] != listB.items[i]) return false;
    }

    return true;
}

pub fn StaticDeque(comptime T: type) type {
    return struct {
        data: []T,
        st: usize = 0,
        en: usize = 0,
        size: usize = 0,

        const Self = @This();

        pub fn init(buffer: []T) Self {
            return .{ .data = buffer };
        }

        pub fn add(self: *Self, val: T) bool {
            if (self.size == self.data.len or self.data.len == 0) {
                return false;
            }

            self.data[self.en] = val;
            self.en = (self.en + 1) % (self.data.len);
            self.size += 1;

            return true;
        }

        pub fn addFront(self: *Self, val: T) bool {
            if (self.size == self.data.len or self.data.len == 0) {
                return false;
            }

            self.st = (self - 1 + self.data.len) % self.data.len;
            self.data[self.st] = val;
            self.size += 1;
            return true;
        }

        pub fn pop(self: *Self) ?T {
            if (self.size == 0) {
                return null;
            }

            const val = self.data[self.st];
            self.st = (self.st + 1) % self.data.len;
            self.size -= 1;
            return val;
        }

        pub fn popBack(self: *Self) ?T {
            if (self.size == 0) {
                return null;
            }

            const val = self.data[self.en];
            self.en = (self.en - 1 + self.data.len) % self.data.len;
            self.size -= 1;

            return val;
        }

        pub fn empty(self: *const Self) bool {
            return self.size == 0;
        }
    };
}

pub const Direction = enum {
    up,
    down,
    left,
    right,

    pub inline fn getPoint(self: @This()) [2]i8 {
        return switch (self) {
            .up => .{ -1, 0 },
            .down => .{ 1, 0 },
            .left => .{ 0, -1 },
            .right => .{ 0, 1 },
        };
    }
};
