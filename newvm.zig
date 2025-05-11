const std = @import("std");

pub const VM = struct {
    stack: std.ArrayList(i64),
    memory: std.ArrayList(u8),
    program: []const u8,
    pc: u64,
    allocator: std.mem.Allocator,
    running: bool,

    pub fn create(allocator: std.mem.Allocator, program: []const u8) !VM {
        const program_copy = try allocator.dupe(u8, program);
        errdefer allocator.free(program_copy);

        var stack = std.ArrayList(i64).init(allocator);
        var memory = std.ArrayList(u8).init(allocator);

        return VM {
            .stack = stack,
            .memory = memory,
            .program = program_copy,
            .pc = 0,
            .allocator = allocator,
            .running = false,
        };
    }

    pub fn destroy(self: *VM) void {
        self.allocator.free(self.program);
        self.stack.deinit();
        self.memory.deinit();
    }

    pub inline fn push(self: *VM, value: i64) !void {
        try self.stack.append(value);
    }

    pub inline fn pop(self: *VM) !i64 {
        return self.stack.popOrNull() orelse error.StackUnderflow;
    }
};
