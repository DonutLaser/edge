const std = @import("std");
const lexer = @import("lexer.zig");
const ast = @import("ast.zig");

const ParserError = error{
    InvalidSyntax,
};

const StatementType = enum {
    FunctionCall,
};

const StatementData = union {
    function_call: ast.FunctionCall,
};

const Statement = struct {
    type: StatementType,
    data: StatementData,
};

const Block = struct {
    statements: std.ArrayList(Statement),
};

const FuncDecl = struct {
    name: []const u8,
    body: Block,
};

const AST = struct {
    funcs: std.ArrayList(FuncDecl),
};

fn expect_token(token: *lexer.Token, expected: lexer.TokenType) ParserError!void {
    if (token.*.type != expected) {
        std.debug.print("Parser error at line:{d} -> Expected '{s}', got {s}\n", .{ token.*.line, @tagName(expected), token.*.value });
        return ParserError.InvalidSyntax;
    }
}

pub fn parse(tokens: *lexer.TokenList, allocator: *std.mem.Allocator) anyerror!AST {
    var result = AST{ .funcs = std.ArrayList(FuncDecl).init(allocator.*) };

    var token = tokens.*.pop();
    while (token.type != lexer.TokenType.Eof) {
        if (token.type == lexer.TokenType.Func) {
            var parsed = try parseFunction(tokens, allocator);
            try result.funcs.append(parsed);
        }

        token = tokens.*.pop();
    }

    return result;
}

fn parseFunction(tokens: *lexer.TokenList, allocator: *std.mem.Allocator) ParserError!FuncDecl {
    var result = FuncDecl{ .name = "", .body = undefined };

    var token = tokens.*.pop();
    try expect_token(&token, lexer.TokenType.Identifier);

    result.name = token.value;

    token = tokens.*.pop();
    try expect_token(&token, lexer.TokenType.LParen);
    token = tokens.*.pop();
    try expect_token(&token, lexer.TokenType.RParen);

    token = tokens.*.pop();
    try expect_token(&token, lexer.TokenType.Void);

    token = tokens.*.pop();
    try expect_token(&token, lexer.TokenType.LBrace);

    result.body = try parseBlock(tokens, allocator);

    token = tokens.*.pop();
    try expect_token(&token, lexer.TokenType.RBrace);

    return result;
}

fn parseBlock(tokens: *lexer.TokenList, allocator: *std.mem.Allocator) ParserError!Block {
    var result = Block{ .statements = std.ArrayList(Statement).init(allocator.*) };

    _ = tokens;

    return result;
}
