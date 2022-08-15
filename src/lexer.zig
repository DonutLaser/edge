const std = @import("std");

pub const TokenType = enum {
    Comma,
    Eof,
    Func,
    Identifier,
    LParen,
    LBrace,
    RParen,
    RBrace,
    StringLiteral,
    Void,
};

pub const Token = struct {
    type: TokenType,
    value: []const u8,
    line: u32,
};

pub const TokenList = struct {
    tokens: std.ArrayList(Token),
    index: u32,

    pub fn init() TokenList {
        return TokenList{
            .tokens = std.ArrayList(Token).init(std.heap.page_allocator),
            .index = 0,
        };
    }

    pub fn push(self: *TokenList, token: Token) !void {
        try self.tokens.append(token);
    }

    pub fn pop(self: *TokenList) Token {
        var result = self.tokens.items[self.index];
        self.index += 1;

        return result;
    }

    pub fn peek(self: *TokenList, offset: u8) Token {
        return self.tokens.items[self.index + offset];
    }

    pub fn consume(self: *TokenList) void {
        self.index += 1;
    }

    pub fn dump(self: TokenList) void {
        for (self.tokens.items) |item| {
            if (item.value.len > 0) {
                std.debug.print("{s}: {s}\n", .{ @tagName(item.type), item.value });
            } else {
                std.debug.print("{s}\n", .{@tagName(item.type)});
            }
        }
    }
};

pub fn lex(src: []u8) !TokenList {
    var result = TokenList.init();

    var cursor: u32 = 0;
    var line: u32 = 0;

    while (cursor < src.len) {
        while (std.ascii.isSpace(src[cursor])) {
            if (src[cursor] == '\n') {
                line += 1;
            }

            cursor += 1;
        }

        if (std.ascii.isAlpha(src[cursor])) {
            var start = cursor;

            while (std.ascii.isAlpha(src[cursor])) {
                cursor += 1;
            }

            var word = src[start..cursor];
            if (std.mem.eql(u8, word, "func")) {
                try result.push(Token{ .type = TokenType.Func, .value = "func", .line = line });
            } else if (std.mem.eql(u8, word, "void")) {
                try result.push(Token{ .type = TokenType.Void, .value = "void", .line = line });
            } else {
                try result.push(Token{ .type = TokenType.Identifier, .value = word, .line = line });
            }
        } else if (src[cursor] == ',') {
            try result.push(Token{ .type = TokenType.Comma, .value = ",", .line = line });
            cursor += 1;
        } else if (src[cursor] == '(') {
            try result.push(Token{ .type = TokenType.LParen, .value = "(", .line = line });
            cursor += 1;
        } else if (src[cursor] == ')') {
            try result.push(Token{ .type = TokenType.RParen, .value = ")", .line = line });
            cursor += 1;
        } else if (src[cursor] == '{') {
            try result.push(Token{ .type = TokenType.LBrace, .value = "{", .line = line });
            cursor += 1;
        } else if (src[cursor] == '}') {
            try result.push(Token{ .type = TokenType.RBrace, .value = "}", .line = line });
            cursor += 1;
        } else if (src[cursor] == '\'') {
            var start = cursor;

            cursor += 1;
            while (src[cursor] != '\'') {
                cursor += 1;
            }

            var str = src[start..cursor];
            try result.push(Token{ .type = TokenType.StringLiteral, .value = str, .line = line });
            cursor += 1;
        }
    }

    try result.push(Token{ .type = TokenType.Eof, .value = "", .line = line });

    return result;
}
