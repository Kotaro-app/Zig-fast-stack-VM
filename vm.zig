const std = @import("std");

pub const VM = struct {
    stack: std.ArrayList(i64),
    memory: std.ArrayList(u8),
    program: []const u8,
    pc: u64,
    allocator: std.mem.Allocator,
    running: bool,

    pub fn create(allocator: std.mem.Allocator, program: []const u8, stack_size: u64, mem_size: u64) !VM {
        if (stack_size == 0 or mem_size == 0) {
            std.log.err("Invalid size specified: stack_size={}, mem_size={}", .{ stack_size, mem_size });
            return error.InvalidSize;
        }

        const program_copy = try allocator.dupe(u8, program);
        errdefer allocator.free(program_copy);

        var stack = try std.ArrayList(i64).initCapacity(allocator, stack_size);
        errdefer stack.deinit();

        var memory = try std.ArrayList(u8).initCapacity(allocator, mem_size);
        errdefer memory.deinit();
        try memory.resize(mem_size);
        @memset(memory.items[0..mem_size], 0);

        return VM{
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
        self.* = undefined;
    }

    pub inline fn push(self: *VM, value: i64) !void {
        try self.stack.append(value);
    }

    pub inline fn pop(self: *VM) !i64 {
        return self.stack.popOrNull() orelse error.StackUnderflow;
    }
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const program = "test";

    var vm = try VM.create(allocator, program, 1024, 65536);
    defer vm.destroy();
}
