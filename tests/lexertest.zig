const std = @import("std");
const lexer = @import("lexer");
const Lexer = lexer.Lexer;
const Token = lexer.Token;
const TokenTag = lexer.TokenTag;
const alloc = std.testing.allocator;
// rn this has tests for the lexer producing correct tokens for correct inputs, for malformed inputs a seperate test suite may be better because the lexer does not seem to stop lexing after reporting lexer errors
test "empty file" {
    var l = Lexer.init("");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 1), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .eof);
    try std.testing.expectEqual(@as(usize, 1), tokens.items[0].line);
    try std.testing.expectEqual(@as(usize, 0), tokens.items[0].column);
}
test "white spaces" {
    var l = Lexer.init("     ");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 1), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .eof);
    try std.testing.expectEqual(@as(usize, 1), tokens.items[0].line);
    try std.testing.expectEqual(@as(usize, 6), tokens.items[0].column);
}
test "only tabs" {
    var l = Lexer.init("        ");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 1), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .eof);
    try std.testing.expectEqual(@as(usize, 1), tokens.items[0].line);
    try std.testing.expectEqual(@as(usize, 9), tokens.items[0].column); // this thing depends on your text editor with which you write this test some insert \t when you press tab, some insert spaces result varies based on that, \t may require refactoring
}
test "only carriage returns" {
    var l = Lexer.init("\r\r\r");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 1), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .eof);
    try std.testing.expectEqual(@as(usize, 1), tokens.items[0].line);
    try std.testing.expectEqual(@as(usize, 4), tokens.items[0].column);
}
test "only newlines" {
    var l = Lexer.init("\n\n\n");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 1), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .eof);
    try std.testing.expectEqual(@as(usize, 4), tokens.items[0].line);
}
test "mixed whitespace" {
    var l = Lexer.init(" \t\r\n \n\t");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 1), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .eof);
    try std.testing.expectEqual(@as(usize, 3), tokens.items[0].line);
}
test "single comment" {
    var l = Lexer.init("//testcommentshere");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 1), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .eof);
    try std.testing.expectEqual(@as(usize, 1), tokens.items[0].line);
}
test "empty comment" {
    var l = Lexer.init("//");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 1), tokens.items.len);
    try std.testing.expectEqual(@as(usize, 1), tokens.items[0].line);
}
test "multiple consecutive comments" {
    var l = Lexer.init("//testcomment\n//testagain");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 1), tokens.items.len);
    try std.testing.expectEqual(@as(usize, 2), tokens.items[0].line);
}
test "comment followed by code" {
    var l = Lexer.init("//testcomment\nint x = 5;");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 6), tokens.items.len);
    try std.testing.expectEqual(@as(usize, 2), tokens.items[0].line);
}
test "code followed by comment" {
    var l = Lexer.init("int x = 1;//testcomment");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 6), tokens.items.len);
    try std.testing.expectEqual(@as(usize, 1), tokens.items[0].line);
}
test "comments followed with code followed with comments" {
    var l = Lexer.init("//testcomment\nint x = 5;//testagain");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 6), tokens.items.len);
    try std.testing.expectEqual(@as(usize, 2), tokens.items[0].line);
}
test "comment after indentation" {
    var l = Lexer.init("    //testagain");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 1), tokens.items.len);
    try std.testing.expectEqual(@as(usize, 1), tokens.items[0].line);
}
test "comment containing symbols" {
    var l = Lexer.init("//this comment will be tested with symbols like ! @ # $ % ^ & * ( ) _ - + =");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 1), tokens.items.len);
    try std.testing.expectEqual(@as(usize, 1), tokens.items[0].line);
}
test "comment containing quotes" {
    var l = Lexer.init("//\"test for quotes\"");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 1), tokens.items.len);
    try std.testing.expectEqual(@as(usize, 1), tokens.items[0].line);
}
test "comment containing braces" {
    var l = Lexer.init("//brace test {test}");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 1), tokens.items.len);
    try std.testing.expectEqual(@as(usize, 1), tokens.items[0].line);
}
test "comment between statements" {
    var l = Lexer.init("int x = 5;\n" ++ "// this is a comment\n" ++ "int y = 10;");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 11), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .type_);
    try std.testing.expect(tokens.items[1].payload == .identifier);
    try std.testing.expect(tokens.items[2].payload == .equal);
    try std.testing.expect(tokens.items[3].payload == .number);
    try std.testing.expect(tokens.items[4].payload == .semicolon);
    try std.testing.expect(tokens.items[5].payload == .type_);
    try std.testing.expectEqual(@as(usize, 3), tokens.items[5].line);
}
test "keyword int" {
    var l = Lexer.init("int");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .type_);
    try std.testing.expectEqual(lexer.TypeKind.Int, tokens.items[0].payload.type_);
    try std.testing.expect(tokens.items[1].payload == .eof);
}
test "keyword bool" {
    var l = Lexer.init("bool");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .type_);
    try std.testing.expectEqual(lexer.TypeKind.Bool, tokens.items[0].payload.type_);
    try std.testing.expect(tokens.items[1].payload == .eof);
}
test "keyword string" {
    var l = Lexer.init("string");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .type_);
    try std.testing.expectEqual(lexer.TypeKind.String, tokens.items[0].payload.type_);
    try std.testing.expect(tokens.items[1].payload == .eof);
}
test "keyword fn" {
    var l = Lexer.init("fn");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .func);
    try std.testing.expect(tokens.items[1].payload == .eof);
}
test "keyword if" {
    var l = Lexer.init("if");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .if_);
    try std.testing.expect(tokens.items[1].payload == .eof);
}
test "keyword else" {
    var l = Lexer.init("else");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .else_);
    try std.testing.expect(tokens.items[1].payload == .eof);
}
test "keyword while" {
    var l = Lexer.init("while");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .while_);
    try std.testing.expect(tokens.items[1].payload == .eof);
}
test "keyword return" {
    var l = Lexer.init("return");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .return_);
    try std.testing.expect(tokens.items[1].payload == .eof);
}
test "keyword true" {
    var l = Lexer.init("true");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .true_);
    try std.testing.expect(tokens.items[1].payload == .eof);
}
test "keyword false" {
    var l = Lexer.init("false");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .false_);
    try std.testing.expect(tokens.items[1].payload == .eof);
}
test "all keywords together" {
    var l = Lexer.init("int bool string fn if else while return true false");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 11), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .type_);
    try std.testing.expectEqual(lexer.TypeKind.Int, tokens.items[0].payload.type_);
    try std.testing.expect(tokens.items[1].payload == .type_);
    try std.testing.expectEqual(lexer.TypeKind.Bool, tokens.items[1].payload.type_);
    try std.testing.expect(tokens.items[2].payload == .type_);
    try std.testing.expectEqual(lexer.TypeKind.String, tokens.items[2].payload.type_);
    try std.testing.expect(tokens.items[3].payload == .func);
    try std.testing.expect(tokens.items[4].payload == .if_);
    try std.testing.expect(tokens.items[5].payload == .else_);
    try std.testing.expect(tokens.items[6].payload == .while_);
    try std.testing.expect(tokens.items[7].payload == .return_);
    try std.testing.expect(tokens.items[8].payload == .true_);
    try std.testing.expect(tokens.items[9].payload == .false_);
    try std.testing.expect(tokens.items[10].payload == .eof);
}

test "single letter identifier" {
    var l = Lexer.init("x");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .identifier);
    try std.testing.expectEqualStrings("x", tokens.items[0].payload.identifier);
    try std.testing.expect(tokens.items[1].payload == .eof);
}

test "multi letter identifier" {
    var l = Lexer.init("hello");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .identifier);
    try std.testing.expectEqualStrings("hello", tokens.items[0].payload.identifier);
    try std.testing.expect(tokens.items[1].payload == .eof);
}

test "internal underscore identifier" {
    var l = Lexer.init("test_ident");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .identifier);
    try std.testing.expectEqualStrings("test_ident", tokens.items[0].payload.identifier);
    try std.testing.expect(tokens.items[1].payload == .eof);
}

test "ending underscore identifier" {
    var l = Lexer.init("test_");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);

    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .identifier);
    try std.testing.expectEqualStrings("test_", tokens.items[0].payload.identifier);
    try std.testing.expect(tokens.items[1].payload == .eof);
}

test "identifier with digits" {
    var l = Lexer.init("hello123");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);

    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .identifier);
    try std.testing.expectEqualStrings("hello123", tokens.items[0].payload.identifier);
    try std.testing.expect(tokens.items[1].payload == .eof);
}

test "long identifier" {
    var l = Lexer.init("this_is_a_really_long_identifier_name_6767");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);

    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .identifier);
    try std.testing.expectEqualStrings(
        "this_is_a_really_long_identifier_name_6767",
        tokens.items[0].payload.identifier,
    );
    try std.testing.expect(tokens.items[1].payload == .eof);
}

test "identifier after newline" {
    var l = Lexer.init("\nhello");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .identifier);
    try std.testing.expectEqualStrings("hello", tokens.items[0].payload.identifier);
    try std.testing.expect(tokens.items[1].payload == .eof);
}

test "identifier after comment" {
    var l = Lexer.init("// comment\nhellotest");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .identifier);
    try std.testing.expectEqualStrings("hellotest", tokens.items[0].payload.identifier);
    try std.testing.expect(tokens.items[1].payload == .eof);
}

test "identifier beside punctuation" {
    var l = Lexer.init("(hello)");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 4), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .lparen);
    try std.testing.expect(tokens.items[1].payload == .identifier);
    try std.testing.expectEqualStrings("hello", tokens.items[1].payload.identifier);
    try std.testing.expect(tokens.items[2].payload == .rparen);
    try std.testing.expect(tokens.items[3].payload == .eof);
}

test "identifier beginning with keyword int" {
    var l = Lexer.init("integer");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .identifier);
    try std.testing.expectEqualStrings("integer", tokens.items[0].payload.identifier);
    try std.testing.expect(tokens.items[1].payload == .eof);
}

test "identifier beginning with keyword return" {
    var l = Lexer.init("returnValue");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .identifier);
    try std.testing.expectEqualStrings("returnValue", tokens.items[0].payload.identifier);
    try std.testing.expect(tokens.items[1].payload == .eof);
}

test "identifier beginning with keyword while" {
    var l = Lexer.init("whileLoop");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .identifier);
    try std.testing.expectEqualStrings("whileLoop", tokens.items[0].payload.identifier);
    try std.testing.expect(tokens.items[1].payload == .eof);
}

test "identifier beginning with keyword if" {
    var l = Lexer.init("ifCondition");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .identifier);
    try std.testing.expectEqualStrings("ifCondition", tokens.items[0].payload.identifier);
    try std.testing.expect(tokens.items[1].payload == .eof);
}
test "identifier beginning with keyword true" {
    var l = Lexer.init("truecondition");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .identifier);
    try std.testing.expectEqualStrings("truecondition", tokens.items[0].payload.identifier);
    try std.testing.expect(tokens.items[1].payload == .eof);
}
test "identifier beginning with keyword false" {
    var l = Lexer.init("falsecondition");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .identifier);
    try std.testing.expectEqualStrings("falsecondition", tokens.items[0].payload.identifier);
    try std.testing.expect(tokens.items[1].payload == .eof);
}
test "integer zero" {
    var l = Lexer.init("0");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .number);
    try std.testing.expectEqual(@as(i64, 0), tokens.items[0].payload.number);
    try std.testing.expect(tokens.items[1].payload == .eof);
}
test "single digit integer" {
    var l = Lexer.init("9");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .number);
    try std.testing.expectEqual(@as(i64, 9), tokens.items[0].payload.number);
    try std.testing.expect(tokens.items[1].payload == .eof);
}
test "multiple digit integer" {
    var l = Lexer.init("67");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .number);
    try std.testing.expectEqual(@as(i64, 67), tokens.items[0].payload.number);
    try std.testing.expect(tokens.items[1].payload == .eof);
}
test "leading zero integer" {
    var l = Lexer.init("067");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .number);
    try std.testing.expectEqual(@as(i64, 67), tokens.items[0].payload.number);
    try std.testing.expect(tokens.items[1].payload == .eof);
}
test "large integer" {
    var l = Lexer.init("123456789");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 2), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .number);
    try std.testing.expectEqual(@as(i64, 123456789), tokens.items[0].payload.number);
    try std.testing.expect(tokens.items[1].payload == .eof);
}
test "integer before operator" {
    var l = Lexer.init("50+");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 3), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .number);
    try std.testing.expectEqual(@as(i64, 50), tokens.items[0].payload.number);
    try std.testing.expect(tokens.items[1].payload == .plus);
    try std.testing.expect(tokens.items[2].payload == .eof);
}
test "integer after operator" {
    var l = Lexer.init("+50");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 3), tokens.items.len);
    try std.testing.expect(tokens.items[1].payload == .number);
    try std.testing.expect(tokens.items[0].payload == .plus);
    try std.testing.expectEqual(@as(i64, 50), tokens.items[1].payload.number);
    try std.testing.expect(tokens.items[2].payload == .eof);
}
test "integer before punctuation" {
    var l = Lexer.init("50,");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 3), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .number);
    try std.testing.expectEqual(@as(i64, 50), tokens.items[0].payload.number);
    try std.testing.expect(tokens.items[1].payload == .comma);
    try std.testing.expect(tokens.items[2].payload == .eof);
}
test "empty string" {
    var l = Lexer.init("\"\"");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);

    try std.testing.expectEqual(@as(usize, 3), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .string_start);
    try std.testing.expect(tokens.items[1].payload == .string_end);
    try std.testing.expect(tokens.items[2].payload == .eof);
}
test "simple string" {
    var l = Lexer.init("\"hello\"");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 4), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .string_start);
    try std.testing.expect(tokens.items[1].payload == .string_segment);
    try std.testing.expectEqualStrings(
        "hello",
        tokens.items[1].payload.string_segment,
    );
    try std.testing.expect(tokens.items[2].payload == .string_end);
    try std.testing.expect(tokens.items[3].payload == .eof);
}
test "string with spaces" {
    var l = Lexer.init("\"    \"");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 4), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .string_start);
    try std.testing.expect(tokens.items[1].payload == .string_segment);
    try std.testing.expectEqualStrings(
        "    ",
        tokens.items[1].payload.string_segment,
    );
    try std.testing.expect(tokens.items[2].payload == .string_end);
    try std.testing.expect(tokens.items[3].payload == .eof);
}
test "string with punctuation" {
    var l = Lexer.init("\".,;\"");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 4), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .string_start);
    try std.testing.expect(tokens.items[1].payload == .string_segment);
    try std.testing.expectEqualStrings(
        ".,;",
        tokens.items[1].payload.string_segment,
    );
    try std.testing.expect(tokens.items[2].payload == .string_end);
    try std.testing.expect(tokens.items[3].payload == .eof);
}
test "string with numbers" {
    var l = Lexer.init("\"123456789\"");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 4), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .string_start);
    try std.testing.expect(tokens.items[1].payload == .string_segment);
    try std.testing.expectEqualStrings(
        "123456789",
        tokens.items[1].payload.string_segment,
    );
    try std.testing.expect(tokens.items[2].payload == .string_end);
    try std.testing.expect(tokens.items[3].payload == .eof);
}
test "string with operators" {
    var l = Lexer.init("\"+-%*/+=-=><\"");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 4), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .string_start);
    try std.testing.expect(tokens.items[1].payload == .string_segment);
    try std.testing.expectEqualStrings(
        "+-%*/+=-=><",
        tokens.items[1].payload.string_segment,
    );
    try std.testing.expect(tokens.items[2].payload == .string_end);
    try std.testing.expect(tokens.items[3].payload == .eof);
}
test "string with braces" {
    var l = Lexer.init("\"{}\"");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 5), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .string_start);
    try std.testing.expect(tokens.items[1].payload == .interpolation_start); // no support for string with braces in the string rn
    try std.testing.expect(tokens.items[2].payload == .interpolation_end);
    try std.testing.expect(tokens.items[3].payload == .string_end);
    try std.testing.expect(tokens.items[4].payload == .eof);
}
test "long string" {
    var l = Lexer.init("\"this string is supposed to test a long string\"");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 4), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .string_start);
    try std.testing.expect(tokens.items[1].payload == .string_segment);
    try std.testing.expectEqualStrings("this string is supposed to test a long string", tokens.items[1].payload.string_segment);
    try std.testing.expect(tokens.items[2].payload == .string_end);
    try std.testing.expect(tokens.items[3].payload == .eof);
}
test "multiple strings" {
    var l = Lexer.init("\"multiple\" \"string\"");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 7), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .string_start);
    try std.testing.expect(tokens.items[1].payload == .string_segment);
    try std.testing.expectEqualStrings("multiple", tokens.items[1].payload.string_segment);
    try std.testing.expect(tokens.items[2].payload == .string_end);
    try std.testing.expect(tokens.items[3].payload == .string_start);
    try std.testing.expect(tokens.items[4].payload == .string_segment);
    try std.testing.expectEqualStrings("string", tokens.items[4].payload.string_segment);
    try std.testing.expect(tokens.items[5].payload == .string_end);
    try std.testing.expect(tokens.items[6].payload == .eof);
}
test "string followed by identifier" {
    var l = Lexer.init("\"stringtest\"; ident");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 6), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .string_start);
    try std.testing.expect(tokens.items[1].payload == .string_segment);
    try std.testing.expectEqualStrings("stringtest", tokens.items[1].payload.string_segment);
    try std.testing.expect(tokens.items[2].payload == .string_end);
    try std.testing.expect(tokens.items[3].payload == .semicolon);
    try std.testing.expect(tokens.items[4].payload == .identifier);
    try std.testing.expect(tokens.items[5].payload == .eof);
}
test "leading underscore identifier" {
    var l = Lexer.init("_test");
    var tokens = try l.lex(alloc);
    defer tokens.deinit(alloc);
    try std.testing.expectEqual(@as(usize, 3), tokens.items.len);
    try std.testing.expect(tokens.items[0].payload == .invalid);
    try std.testing.expectEqualStrings("_", tokens.items[0].payload.invalid);
    try std.testing.expect(tokens.items[1].payload == .identifier);
    try std.testing.expectEqualStrings("test", tokens.items[1].payload.identifier);
    try std.testing.expect(tokens.items[2].payload == .eof);
}
test "identifier followed by string" {}
test "string without interpolation" {}
test "interpolation at beginning" {}
test "interpolation in middle" {}
test "interpolation at end" {}
test "multiple interpolations" {}
test "expression inside interpolation" {}
test "function call inside interpolation" {}
test "nested expression in interpolation" {}
test "empty interpolation" {}
test "adjacent interpolations" {}
test "plus operator" {}
test "minus operator" {}
test "multiply operator" {}
test "divide operator" {}
test "modulus operator" {}
test "assignment operator" {}
test "equal operator" {}
test "not equal operator" {}
test "less than operator" {}
test "less than equal operator" {}
test "greater than operator" {}
test "greater than equal operator" {}
test "logical not operator" {}
test "logical and operator" {}
test "logical or operator" {}
test "all operators together" {}
test "left parenthesis" {}
test "right parenthesis" {}
test "left brace" {}
test "right brace" {}
test "left bracket" {}
test "right bracket" {}
test "comma" {}
test "semicolon" {}
test "colon" {}
test "dot" {}
test "all punctuation together" {}
test "empty array type" {}
test "fixed size array type" {}
test "array with identifier size" {}
test "empty array literal" {}
test "integer array literal" {}
test "string array literal" {}
test "nested array literal" {}
test "array with expressions" {}
test "empty function" {}
test "function with one parameter" {}
test "function with multiple parameters" {}
test "function returning value" {}
test "nested function call" {}
test "simple addition expression" {}
test "simple subtraction expression" {}
test "simple multiplication expression" {}
test "simple division expression" {}
test "simple modulus expression" {}
test "unary minus expression" {}
test "unary plus expression" {}
test "logical not expression" {}
test "parenthesized expression" {}
test "complex arithmetic expression" {}
test "variable declaration" {}
test "variable initialization" {}
test "assignment statement" {}
test "return statement" {}
test "if statement" {}
test "if else statement" {}
test "while statement" {}
test "block statement" {}
test "minimal program" {}
test "simple program" {}
test "multiple function program" {}
test "nested block program" {}
test "token at beginning of file" {}
test "token after spaces" {}
test "token after tabs" {}
test "token after newline" {}
test "token after blank line" {}
test "token after multiple blank lines" {}
test "token after comment" {}
test "multiple tokens same line" {}
test "multiple tokens different lines" {}
test "eof position" {}
test "eof after identifier" {}
test "eof after integer" {}
test "eof after string" {}
test "eof after punctuation" {}
test "eof after comment" {}
test "eof after whitespace" {}
test "unexpected character at sign" {}
test "unexpected character dollar" {}
test "unexpected character backtick" {}
test "unexpected character tilde" {}
test "unexpected character caret" {}
test "unterminated string" {}
test "unterminated interpolation" {}
test "invalid escape sequence" {}
test "integer overflow" {}
test "invalid numeric literal" {}
test "invalid identifier" {}
test "error location line" {}
test "error location column" {}
test "multiple lexer errors" {}
test "very long identifier" {}
test "very long integer" {}
test "very long string" {}
test "thousand identifiers" {}
test "hundred lines of source" {}
test "large source file" {}
test "many comments" {}
test "many blank lines" {}
