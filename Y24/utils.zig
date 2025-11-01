const std = @import("std");

// Timer util
pub const Timer = struct {
    st: std.time.Instant,
    label: [*:0]const u8,
    pub fn end(self: @This()) void {
        const en = std.time.Instant.now() catch unreachable;
        var time: f64 = @floatFromInt(en.since(self.st));
        time /= 1.0e9;
        std.debug.print("[{s}] Time - {d:10.9} s\n", .{ self.label, time });
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
            .count = 1,
            .totalTime = 0,
        };
    }
    pub fn addStop(self: *@This()) void {
        const en = std.time.Instant.now() catch unreachable;
        self.totalTime += en.since(self.lastSt);
        self.count += 1;
        self.lastSt = en;
    }

    pub fn end(self: *@This()) void {
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
