const std = @import("std");
const utils = @import("utils.zig");
const FileName = "/Volumes/RAM_Disk_10GB/day17";
const BufferSize = 1024 * 1024;

const opCodes: [16]OpCode = .{
    @enumFromInt(2),
    @enumFromInt(4),
    @enumFromInt(1),
    @enumFromInt(7),
    @enumFromInt(7),
    @enumFromInt(5),
    @enumFromInt(0),
    @enumFromInt(3),
    @enumFromInt(4),
    @enumFromInt(0),
    @enumFromInt(1),
    @enumFromInt(7),
    @enumFromInt(5),
    @enumFromInt(5),
    @enumFromInt(3),
    @enumFromInt(0),
};

const Registers = struct {
    A: *i64,
    B: *i64,
    C: *i64,
};

// OpCode
const OpCode = enum(u3) {
    adv = 0, // regA = regA/(2**(combo operand))
    bxl = 1, // regB = regB ^ (literal operand)
    bst = 2, // (regB = (combo operand) % 8) | (regB = (combo operand) & 0b111)
    jnz = 3, // if (regA != 0) goto index (literal operand)
    bxc = 4, // regB = regB ^ regC  [ignore the operand]
    out = 5, // (combo operand) % 8 => add to output list
    bdv = 6, // regB = regA/(2**(combo operand))
    cdv = 7, // regC = regA/(2**(combo operand))

    fn fromChar(ch: u8) OpCode {
        return @enumFromInt(ch - '0');
    }

    fn perform(operator: @This(), outputList: *std.ArrayList(i64), allocator: std.mem.Allocator, operand: OpCode, reg: Registers, i: *u64) void {
        switch (operator) {
            .adv => {
                reg.A.* = @divTrunc(reg.A.*, (std.math.pow(i64, 2, combo(operand, reg))));
            },
            .bxl => {
                reg.B.* = reg.B.* ^ @intFromEnum(operand);
            },
            .bst => {
                reg.B.* = combo(operand, reg) & 0b111;
            },
            .jnz => {
                if (reg.A.* != 0) {
                    i.* = @intFromEnum(operand);
                    return;
                }
            },
            .bxc => {
                reg.B.* = reg.B.* ^ reg.C.*;
            },
            .out => {
                outputList.append(allocator, combo(operand, reg) & 0b111) catch unreachable;
            },
            .bdv => {
                reg.B.* = @divTrunc(reg.A.*, (std.math.pow(i64, 2, combo(operand, reg))));
            },
            .cdv => {
                reg.C.* = @divTrunc(reg.A.*, (std.math.pow(i64, 2, combo(operand, reg))));
            },
        }
        i.* += 2;
    }

    fn performAndCheck(operator: @This(), tempList: *std.ArrayList(i64), origList: *std.ArrayList(i64), allocator: std.mem.Allocator, operand: OpCode, reg: Registers, i: *u64) bool {
        operator.perform(tempList, allocator, operand, reg, i);
        const tempListItems = tempList.items;
        const origListItems = origList.items;

        return !(operator == .out and tempListItems.len > 0 and tempListItems[tempListItems.len - 1] != origListItems[tempListItems.len - 1]);
    }
};

fn combo(opCode: OpCode, reg: Registers) i64 {
    return switch (opCode) {
        .adv => 0,
        .bxl => 1,
        .bst => 2,
        .jnz => 3,
        .bxc => reg.A.*,
        .out => reg.B.*,
        .bdv => reg.C.*,
        .cdv => unreachable,
    };
}

fn part1(allocator: std.mem.Allocator, reg: Registers) std.ArrayList(i64) {
    const t = utils.Timer.start("Solve Part 1");
    defer t.end();
    const outputList = runWithValue(allocator, reg.A.*);

    {
        const s = utils.Timer.start("Print Part 1");
        defer s.end();
        std.debug.print("Part 1 - ", .{});

        for (outputList.items, 0..) |output, i| {
            if (i == outputList.items.len - 1) {
                std.debug.print("{}", .{output});
            } else {
                std.debug.print("{},", .{output});
            }
        }
        std.debug.print("\n", .{});
    }

    return outputList;
}

fn runWithValue(allocator: std.mem.Allocator, initialA: i64) std.ArrayList(i64) {
    var A = initialA;
    var B: i64 = 0;
    var C: i64 = 0;
    const reg: Registers = .{
        .A = &A,
        .B = &B,
        .C = &C,
    };

    var outputList = std.ArrayList(i64).initCapacity(allocator, 100) catch unreachable;

    var i: u64 = 0;
    while (i < opCodes.len) {
        opCodes[i].perform(&outputList, allocator, opCodes[i + 1], reg, &i);
    }

    return outputList;
}

fn findA(allocator: std.mem.Allocator, targetList: *std.ArrayList(i64), origRegA: i64, depth: usize, timer: *utils.AggregateTimer) ?i64 {
    defer timer.addStop();
    if (depth == targetList.items.len) {
        return origRegA;
    }

    var candidate: i64 = 0;
    while (candidate < 8) : (candidate += 1) {
        const regA = (origRegA << 3) | candidate;

        var output = runWithValue(allocator, regA);
        defer output.deinit(allocator);

        const expectedLen = depth + 1;
        if (output.items.len >= expectedLen) {
            var matches = true;
            const targetStart = targetList.items.len - expectedLen;
            for (0..expectedLen) |i| {
                const outputIdx = output.items.len - expectedLen + i;
                const targetIdx = targetStart + i;
                if (output.items[outputIdx] != targetList.items[targetIdx]) {
                    matches = false;
                    break;
                }
            }

            if (matches) {
                if (findA(allocator, targetList, regA, depth + 1, timer)) |res| {
                    return res;
                }
            }
        }
    }

    return null;
}

fn part2(origOutputList: *std.ArrayList(i64), allocator: std.mem.Allocator, regOrig: Registers) void {
    const t = utils.Timer.start("Solve Part 2");
    defer t.end();

    _ = regOrig;

    var timer = utils.AggregateTimer.init("findA Part 2");
    defer timer.end();
    if (findA(allocator, origOutputList, 0, 0, &timer)) |res| {
        std.debug.print("Part 2 - {}\n", .{res});
    }
}

pub fn main() !void {
    var regA: i64 = 62769524;
    var regB: i64 = 0;
    var regC: i64 = 0;

    const reg: Registers = .{ .A = &regA, .B = &regB, .C = &regC };

    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var outputList = part1(allocator, reg);
    defer outputList.deinit(allocator);

    var targetList = std.ArrayList(i64).initCapacity(allocator, 100) catch unreachable;
    defer targetList.deinit(allocator);
    for (opCodes) |op| {
        targetList.append(allocator, @intFromEnum(op)) catch unreachable;
    }
    part2(&targetList, allocator, reg);
}
