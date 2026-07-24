const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const lexer_module = b.createModule(.{
        .root_source_file = b.path("src/lexer.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "ziguana",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the lexer application");
    run_step.dependOn(&run_cmd.step);
    const lexer_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("tests/lexertest.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    lexer_tests.root_module.addImport("lexer", lexer_module);
    const run_lexer_tests = b.addRunArtifact(lexer_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lexer_tests.step);
}
