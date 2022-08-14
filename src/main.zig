const std = @import("std");

const lexer = @import("lexer.zig");
const parser = @import("parser.zig");

const Args = struct {
    source: []u8,
};

fn parse_args(allocator: *std.mem.Allocator) !Args {
    var args_iter = std.process.args();
    _ = args_iter.skip(); // Skip .exe name

    const source = try (args_iter.next(allocator.*).?);

    return Args{ .source = source };
}

fn read_file(path: []u8, allocator: *std.mem.Allocator) ![]u8 {
    var file = try std.fs.cwd().openFile(path, .{});

    const file_size = (try file.stat()).size;
    var buffer = try allocator.alloc(u8, file_size);

    try file.reader().readNoEof(buffer);

    return buffer;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var allocator = arena.allocator();

    const args = try parse_args(&allocator);
    const src = try read_file(args.source, &allocator);
    defer allocator.free(src);

    var tokens = try lexer.lex(src);
    tokens.dump();

    _ = parser.parse(&tokens, &allocator) catch {
        return;
    };
}
