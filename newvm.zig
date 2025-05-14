const std = @import("std");

pub const VM = struct {
    pc: usize,
    sp: usize,
    fpp: usize,
    running: bool,
    call_stack: []CallFrame,
    data_stack: []Value,
    memory: []u8,
    code: []const u8,
    allocator: std.mem.Allocator,

    pub const CallFrame = struct {
        ret_addr: usize,
        fp: usize,
        arg_count: u8,
        local_count: u8,
    };

    pub const Value = extern union(enum) {
        int: i64,
        float: f64,
        bool: bool,
        string: struct {
            ptr: [*]const u8,
            len: usize,
        },
        nil: void,
    };

    pub fn create(
        allocator: std.mem.Allocator,
        code: []const u8,
        call_stack_size: usize,
        data_stack_size: usize,
        memory_size: usize,
    ) !VM {
        const call_stack = try allocator.alloc(CallFrame, call_stack_size);
        errdefer allocator.free(call_stack);
        const data_stack = try allocator.alloc(Value, data_stack_size);
        errdefer allocator.free(data_stack);
        const memory = try allocator.alloc(u8, memory_size);
        errdefer allocator.free(memory);
        return VM{
            .pc = 0,
            .sp = 0,
            .fp = 0,
            .running = false,
            .call_stack = call_stack,
            .data_stack = data_stack,
            .memory = memory,
            .code = code,
            .allocator = allocator,
        };
    }

    pub fn destroy(self: *VM) void {
        self.allocator.free(self.call_stack);
        self.allocator.free(self.data_stack);
        self.allocator.free(self.memory);
    }

    pub inline fn push(self: *VM, value: Value) !void {
        if (self.sp >= self.data_stack.len) {
            const new_len = self.data_stack.len + (self.data_stack.len >> 1) + 16;
            self.data_stack = try self.allocator.realloc(self.data_stack, new_len);
        }
        self.data_stack[self.sp] = value;
        self.sp += 1;
    }

    pub inline fn pop(self: *VM) !Value {
        if (self.sp == 0) {
            return error.StackUnderflow;
        }
        self.sp -= 1;
        return self.data_stack[self.sp];
    }
};
