const ast = @import("ast.zig");
const std = @import("std");
const lexer = @import("lexer.zig");

const Token = lexer.Token;
const TokenTag = lexer.TokenTag;
const TokenPayload = lexer.TokenPayload;

const Stmt = ast.Stmt;
const Param = ast.Param;
const VarInit = ast.VarInit;
const Expr = ast.Expr;
const Literal = ast.Literal;

//all parser declarations and implementation in this file
pub const ParseErr = struct {
    message: []const u8,
    token: Token,
};

pub const Parser = struct {
    tokens: []const Token,
    current: usize,
    next: usize,
    errors: std.ArrayList(ParseErr),
    allocator: std.mem.Allocator,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, tokens: []const Token) Parser {
        return .{ .tokens = tokens, .current = 0, .next = 1, .errors = std.ArrayList(ParseErr).init(allocator), .allocator = allocator };
    }

    fn getTag(token: Token) TokenTag {
        return std.meta.activeTag(token.payload);
    }
    //Parser helper functions start here

    fn peek(self: *Self) Token {
        return self.tokens[self.current];
    }

    fn isAtEnd(self: *const Self) bool {
        if (getTag(self.tokens[self.current]) == .eof) {
            return true;
        }
        return false;
    }

    fn match(self: *Self, expectedTag: TokenTag) bool {
        if (expectedTag == getTag(self.tokens[self.current])) {
            return true;
        } else {
            return false;
        }
    }

    fn previous(self: *Self) Token {
        return self.tokens[self.current - 1];
    }

    fn advance(self: *Self) Token {
        if (!self.isAtEnd()) {
            self.current += 1;
            self.next = self.current + 1;
            return self.tokens[self.current - 1];
        } else {
            return self.tokens[self.current];
        }
    }
    fn consume(self: *Self, expected: TokenTag) !Token {
        if (getTag(self.peek()) != expected)
            return error.ExpectedToken;

        return self.advance();
    }

    fn parseProgram(self: *Self) !*Stmt {
        _ = self;
    }
    fn parseFunction(self: *Self) !*Stmt {
        _ = self;
    }
    fn parseBlock(self: *Self) !*Stmt {
        _ = self;
    }
    fn parseStatement(self: *Self) !*Stmt {
        _ = self;
    }
    fn parseExpression(self: *Self) !*Expr {
        _ = self;
    }
    fn parseParameter(self: *Self) !*Param {
        _ = self;
    }
    fn parseLiteral(self: *Self) !*Expr {
        const token = self.advance();
        switch (token.payload) {
            .number => |value| {
                return try ast.makeLiteral(self.allocator, .{
                    .number = value,
                });
            },
            .string => |value| {
                return try ast.makeLiteral(self.allocator, .{
                    .string = value,
                });
            },
            .true_ => {
                return try ast.makeLiteral(self.allocator, .{
                    .boolean = true,
                });
            },
            .false_ => {
                return try ast.makeLiteral(self.allocator, .{
                    .boolean = false,
                });
            },
            //handle error handling here for unexpected literal
        }
    }
    fn parseVarInit(self: *Self) !*VarInit {
        _ = self;
    }
    fn parseEquality(self: *Self) !*Expr {
        _ = self;
    }
    fn parseComparison(self: *Self) !*Expr {
        _ = self;
    }
    fn parseTerm(self: *Self) !*Expr {
        _ = self;
    }
    fn parseFactor(self: *Self) !*Expr {
        _ = self;
    }
    fn parsePrimary(self: *Self) !*Expr {
        _ = self;
    }
    fn parseVarDecl(self: *Self) !*Stmt {
        _ = self;
    }
    fn parseAssignment(self: *Self) !*Stmt {
        _ = self;
    }
    fn parseCallStatement(self: *Self) !*Stmt {
        _ = self;
    }
    fn parseIfStatement(self: *Self) !*Stmt {
        _ = self;
    }
    fn parseWhileStatement(self: *Self) !*Stmt {
        _ = self;
    }
    fn parseReturnStatement(self: *Self) !*Stmt {
        _ = self;
    }
    fn parseFunctionCall(self: *Self) !*Expr {
        _ = self;
    }

    pub fn parse(self: *Self) !*Stmt {
        //entry point of parser
        _ = self;
    }
};
