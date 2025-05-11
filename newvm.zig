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

        const stack = std.ArrayList(i64).init(allocator);
        const memory = std.ArrayList(u8).init(allocator);

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

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const program = "test";
    std.debug.print("Pre start", .{});
    var vm = try VM.create(allocator,program);
    std.debug.print("Start", .{});
    for(1..10000) |_| {
        try vm.push(8);
    }
    std.debug.print("Finish", .{});
    defer vm.destroy(); 
}
