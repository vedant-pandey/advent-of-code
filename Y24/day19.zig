const std = @import("std");
const utils = @import("utils.zig");
const FileName = "/Volumes/RAM_Disk_10GB/day19";
// Single line comma separated types of towel available -> >= 3 chars each
// blank line
// 400 lines of patterns required

const PatternsLen = 447;
const DesignsLen = 400;

fn countDesignsRec(design: []const u8, patSet: *std.StringHashMap(bool), cache: *std.AutoHashMap(usize, usize), st: usize, en: usize) usize {
    if (st > en) {
        return 1;
    }

    if (cache.get(st)) |res| {
        return res;
    }

    var soln: usize = 0;
    for (st..en + 1) |i| {
        if (patSet.contains(design[st .. i + 1])) {
            soln += countDesignsRec(design, patSet, cache, i + 1, en);
        }
    }

    cache.put(st, soln) catch unreachable;

    return soln;
}

fn canMakeDesignRec(design: []const u8, patSet: *std.StringHashMap(bool), st: usize, en: usize) bool {
    if (st > en) {
        return true;
    }
    for (st..en + 1) |i| {
        if (patSet.contains(design[st .. i + 1]) and canMakeDesignRec(design, patSet, i + 1, en)) {
            return true;
        }
    }

    return false;
}

fn canMakeDesign(design: []const u8, patSet: *std.StringHashMap(bool)) bool {
    return canMakeDesignRec(design, patSet, 0, design.len - 1);
}

fn part1(patSet: *std.StringHashMap(bool), designs: *const [DesignsLen][]const u8) void {
    const t = utils.Timer.start("Part 1");
    defer t.end();

    var soln: u64 = 0;
    for (designs) |design| {
        if (canMakeDesign(design, patSet)) {
            soln += 1;
        }
    }

    std.debug.print("Part 1 - {}\n", .{soln});
}

fn part2(patSet: *std.StringHashMap(bool), designs: *const [DesignsLen][]const u8, allocator: std.mem.Allocator) void {
    const t = utils.Timer.start("Part 2");
    defer t.end();

    var soln: u64 = 0;
    var cache = std.AutoHashMap(usize, usize).init(allocator);
    defer cache.deinit();

    for (designs) |design| {
        cache.clearRetainingCapacity();
        soln += countDesignsRec(design, patSet, &cache, 0, design.len - 1);
    }
    std.debug.print("Part 2 - {}\n", .{soln});
}

pub fn main() !void {
    var file = try std.fs.openFileAbsolute(FileName, .{ .mode = .read_only });
    defer file.close();

    var inputBuffer: [1024 * 1024]u8 = undefined;
    var reader = file.reader(&inputBuffer);

    var i: usize = 0;
    var patterns: [PatternsLen][]const u8 = undefined;
    var designs: [DesignsLen][]const u8 = undefined;
    var j: usize = 0;
    {
        const t = utils.Timer.start("Read Input");
        defer t.end();
        while (reader.interface.takeDelimiterExclusive('\n')) |line| {
            switch (i) {
                0 => {
                    var it = std.mem.splitAny(u8, line, ",");
                    while (it.next()) |pat| {
                        patterns[j] = std.mem.trim(u8, pat, " ");
                        j += 1;
                    }
                    j = 0;
                },
                1 => {},
                else => {
                    designs[j] = line;
                    j += 1;
                },
            }

            i += 1;
        } else |err| switch (err) {
            error.EndOfStream => {},
            else => return err,
        }
    }

    var arena = std.heap.ArenaAllocator.init(std.heap.raw_c_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var patSet = std.StringHashMap(bool).init(allocator);
    defer patSet.deinit();
    {
        const t = utils.Timer.start("Fill Patterns");
        defer t.end();
        for (patterns) |pattern| {
            patSet.put(pattern, true) catch unreachable;
        }
    }

    part1(&patSet, &designs);
    part2(&patSet, &designs, allocator);
}
