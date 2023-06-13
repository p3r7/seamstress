const std = @import("std");
const events = @import("events.zig");

var quit = false;
var pid: std.Thread = undefined;
var allocator: std.mem.Allocator = undefined;

pub fn init(allocator_pointer: std.mem.Allocator) !void {
    allocator = allocator_pointer;
    pid = try std.Thread.spawn(.{}, input_run, .{});
}

pub fn deinit() void {
    quit = true;
    std.io.getStdIn().close();
    pid.join();
}

fn input_run() !void {
    var stdout = std.io.getStdOut().writer();
    var stdin = std.io.getStdIn().reader();
    var buf = try allocator.alloc(u8, 4096);
    defer allocator.free(buf);
    // var poller = std.io.poll(allocator, enum { stdin }, .{ .stdin = stdin });
    // defer poller.deinit();
    var fds = [1]std.os.pollfd{std.os.pollfd{ .fd = 0, .events = std.os.POLL.IN, .revents = 0 }};

    while (!quit) {
        const data = try std.os.poll(&fds, 1);
        if (data == 0) continue;
        const len = stdin.read(buf) catch break;
        if (len == 0) break;
        if (len >= buf.len - 1) {
            try stdout.print("error: line too long!\n", .{});
            continue;
        }
        var line: [:0]u8 = try allocator.allocSentinel(u8, len, 0);
        std.mem.copyForwards(u8, line, buf[0..len]);
        if (std.mem.eql(u8, line, "quit\n")) {
            allocator.free(line);
            quit = true;
            continue;
        }
        var event = try events.new(events.Event.Exec_Code_Line);
        event.Exec_Code_Line.line = line;
        try events.post(event);
    }
    try events.post(try events.new(events.Event.Quit));
}