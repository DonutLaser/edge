const std = @import("std");

pub const Expression = union {
    string_literal: []const u8,
};

pub const FunctionCall = struct { name: []const u8, args: std.ArrayList(Expression) };
