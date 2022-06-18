const c = @import("switch/c.zig");

export fn main(_: c_int, _: [*]const [*:0]const u8) void {
    _ = c.consoleInit(null);
    defer c.consoleExit(null);

    _ = c.printf("Hello, Zig");
    while (c.appletMainLoop()) {
        c.consoleUpdate(null);
    }
}
