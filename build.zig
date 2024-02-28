const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "seamstress",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);
    exe.headerpad_max_install_names = true;

    const install_lua_files = b.addInstallDirectory(.{
        .source_dir = .{ .path = "lua" },
        .install_dir = .{ .custom = "share/seamstress" },
        .install_subdir = "lua",
    });
    const install_resources = b.addInstallDirectory(.{
        .source_dir = .{ .path = "resources" },
        .install_dir = .{ .custom = "share/seamstress" },
        .install_subdir = "resources",
    });
    const install_examples = b.addInstallDirectory(.{
        .source_dir = .{ .path = "examples" },
        .install_dir = .{ .custom = "share/seamstress" },
        .install_subdir = "examples",
    });
    b.getInstallStep().dependOn(&install_resources.step);
    b.getInstallStep().dependOn(&install_lua_files.step);
    b.getInstallStep().dependOn(&install_examples.step);

    if (builtin.os.tag == .windows) {
        exe.addIncludePath(std.Build.LazyPath{ .path = "c:/msys64/mingw64/include" });
        exe.addLibraryPath(std.Build.LazyPath{ .path = "c:/msys64/mingw64/bin" });
        exe.addLibraryPath(std.Build.LazyPath{ .path = "c:/msys64/mingw64/lib" });
        // exe.addObjectFile(std.Build.LazyPath{ .path = "c:/msys64/mingw64/bin/SDL2.dll" });
    }

    if (builtin.os.tag == .windows) {
        exe.linkSystemLibrary("c");
        // exe.linkSystemLibrary("ostream");
        // exe.linkSystemLibrary("iphlpapi");
        // exe.linkSystemLibrary("setupapi");

        // NB: might be better to statically link
        // see https://github.com/ziglang/zig/issues/7799#issuecomment-856352102
        exe.addObjectFile(std.Build.LazyPath{ .path = "libSDL2.a" });
        exe.addObjectFile(std.Build.LazyPath{ .path = "libSDL2_ttf.a" });
        exe.addObjectFile(std.Build.LazyPath{ .path = "libSDL2_image.a" });
        // exe.linkSystemLibrary("SDL2");
        // exe.linkSystemLibrary("SDL2_ttf");
        // exe.linkSystemLibrary("SDL2_image");
        // exe.linkSystemLibrary("libSDL_image-1-2-0");

        exe.linkSystemLibrary("jpeg");
        exe.linkSystemLibrary("png");
        exe.linkSystemLibrary("tiff");
        exe.linkSystemLibrary("Lerc");
        exe.linkSystemLibrary("webp");

        exe.linkSystemLibrary("zlib");
        exe.linkSystemLibrary("deflate");
        exe.linkSystemLibrary("jbig");
        exe.linkSystemLibrary("sharpyuv");
        exe.linkSystemLibrary("zstd");
        exe.linkSystemLibrary("lzma");
    } else {
        const zig_sdl = b.dependency("SDL", .{
            .target = target,
            .optimize = optimize,
        });
        exe.linkLibrary(zig_sdl.artifact("SDL2"));
        exe.linkLibrary(zig_sdl.artifact("SDL2_ttf"));
        exe.linkLibrary(zig_sdl.artifact("SDL2_image"));
    }

    const zig_lua = b.dependency("Lua", .{
        .target = target,
        .optimize = optimize,
    });
    exe.addModule("ziglua", zig_lua.module("ziglua"));
    exe.linkLibrary(zig_lua.artifact("lua"));

    const zig_link = b.dependency("link", .{
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibrary(zig_link.artifact("abl_link"));

    if (builtin.os.tag == .windows) {
        exe.linkSystemLibrary("readline");
        // exe.linkSystemLibrary("pdcurses");
        exe.linkSystemLibrary("termcap");
    } else {
        const zig_readline = b.dependency("readline", .{
            .target = target,
            .optimize = optimize,
        });
        exe.linkLibrary(zig_readline.artifact("readline"));
        exe.linkSystemLibrary("ncurses");
    }

    if (builtin.os.tag == .windows) {
        // exe.linkSystemLibrary("liblo");
        exe.linkSystemLibrary("lo");
        // exe.linkSystemLibrary("liblo-7");
    } else {
        const zig_liblo = b.dependency("liblo", .{
            .target = target,
            .optimize = optimize,
        });
        exe.linkLibrary(zig_liblo.artifact("liblo"));
    }

    if (builtin.os.tag == .windows) {
        exe.linkSystemLibrary("rtmidi");
        // exe.linkSystemLibrary("librtmidi-6");
    } else {
        const zig_rtmidi = b.dependency("rtmidi", .{
            .target = target,
            .optimize = optimize,
        });
        exe.linkLibrary(zig_rtmidi.artifact("rtmidi"));
    }

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
