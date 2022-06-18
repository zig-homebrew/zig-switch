const std = @import("std");
const builtin = @import("builtin");

const emulator = "Ryujinx";
const flags = .{"-lnx"};
const devkitpro = "/opt/devkitpro";

pub fn build(b: *std.build.Builder) void {
    const mode = b.standardReleaseOptions();

    const obj = b.addObject("zig-switch", "src/main.zig");
    obj.setOutputDir("zig-out");
    obj.linkLibC();
    obj.setLibCFile(std.build.FileSource{ .path = "libc.txt" });
    obj.addIncludeDir(devkitpro ++ "/libnx/include");
    obj.addIncludeDir(devkitpro ++ "/portlibs/switch/include");
    obj.setTarget(.{
        .cpu_arch = .aarch64,
        .os_tag = .freestanding,
        .cpu_model = .{ .explicit = &std.Target.aarch64.cpu.cortex_a57 },
    });
    obj.setBuildMode(mode);

    const extension = if (builtin.target.os.tag == .windows) ".exe" else "";
    const elf = b.addSystemCommand(&(.{
        devkitpro ++ "/devkitA64/bin/aarch64-none-elf-gcc" ++ extension,
        "-g",
        "-march=armv8-a+crc+crypto",
        "-mtune=cortex-a57",
        "-mtp=soft",
        "-fPIE",
        "-Wl,-Map,zig-out/zig-switch.map",
        "-specs=" ++ devkitpro ++ "/libnx/switch.specs",
        "zig-out/zig-switch.o",
        "-L" ++ devkitpro ++ "/libnx/lib",
        "-L" ++ devkitpro ++ "/portlibs/switch/lib",
    } ++ flags ++ .{
        "-o",
        "zig-out/zig-switch.elf",
    }));

    const nro = b.addSystemCommand(&.{
        devkitpro ++ "/tools/bin/elf2nro" ++ extension,
        "zig-out/zig-switch.elf",
        "zig-out/zig-switch.nro",
    });

    b.default_step.dependOn(&nro.step);
    nro.step.dependOn(&elf.step);
    elf.step.dependOn(&obj.step);

    const run_step = b.step("run", "Run in Yuzu");
    const yuzu = b.addSystemCommand(&.{ emulator, "zig-out/zig-switch.nro" });
    run_step.dependOn(&nro.step);
    run_step.dependOn(&yuzu.step);
}
