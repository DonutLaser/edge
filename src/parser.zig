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

fn unexpected_token(token: *lexer.Token) ParserError {
    std.debug.print("Parser error at line:{d} -> Unexpected token {s}\n", .{@tagName(token.type)});
    return ParserError.InvalidSyntax;
}

pub fn parse(tokens: *lexer.TokenList, allocator: *std.mem.Allocator) anyerror!AST {
    var result = AST{ .funcs = std.ArrayList(FuncDecl).init(allocator.*) };

    var token = tokens.*.pop();
    while (token.type != lexer.TokenType.Eof) {
        if (token.type == lexer.TokenType.Func) {
            var parsed = try parse_function(tokens, allocator);
            try result.funcs.append(parsed);
        }

        token = tokens.*.pop();
    }

    return result;
}

fn parse_function(tokens: *lexer.TokenList, allocator: *std.mem.Allocator) anyerror!FuncDecl {
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

    result.body = try parse_block(tokens, allocator);

    token = tokens.*.pop();
    try expect_token(&token, lexer.TokenType.RBrace);

    return result;
}

fn parse_block(tokens: *lexer.TokenList, allocator: *std.mem.Allocator) anyerror!Block {
    var result = Block{ .statements = std.ArrayList(Statement).init(allocator.*) };

    var token = tokens.*.peek(0);
    while (token.type != lexer.TokenType.RBrace) {
        var statement = try parse_statement(tokens, allocator);
        try result.statements.append(statement);
    }

    return result;
}

fn parse_statement(tokens: *lexer.TokenList, allocator: *std.mem.Allocator) anyerror!Statement {
    var result = Statement{ .type = StatementType.FunctionCall, .data = StatementData{ .function_call = ast.FunctionCall{ .name = "", .args = std.ArrayList(ast.Expression).init(allocator.*) } } };

    var token = tokens.*.peek(0);
    if (token.type == lexer.TokenType.Identifier) {
        if (tokens.*.peek(1).type == lexer.TokenType.LParen) {
            result.data.function_call = try parse_function_call(tokens, allocator);
        }
    } else {}

    return result;
}

fn parse_function_call(tokens: *lexer.TokenList, allocator: *std.mem.Allocator) anyerror!ast.FunctionCall {
    var result = ast.FunctionCall{ .name = "", .args = std.ArrayList(ast.Expression).init(allocator.*) };

    var token = tokens.*.pop();
    result.name = token.value;

    _ = tokens.*.pop(); // Skip lparen

    token = tokens.*.peek(0);
    if (token.type != lexer.TokenType.RParen) {
        while (token.type != lexer.TokenType.RParen) {
            var expression = try parse_expression(tokens, allocator);
            try result.args.append(expression);

            token = tokens.*.peek(0);
            if (token.type == lexer.TokenType.Comma) {
                tokens.consume();
            }
        }
    } else {
        tokens.*.consume();
    }

    return result;
}

fn parse_expression(tokens: *lexer.TokenList, allocator: *std.mem.Allocator) ParserError!ast.Expression {
    _ = allocator;

    var result = ast.Expression{ .string_literal = "" };

    var token = tokens.*.pop();
    if (token.type == lexer.TokenType.StringLiteral) {
        result.string_literal = token.value;
    }

    return result;
}
