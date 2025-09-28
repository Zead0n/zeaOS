const std = @import("std");

pub fn createQemuCommand(b: *std.Build, lp: std.Build.LazyPath, arch: std.Target.Cpu.Arch) *std.Build.Step.Run {
    const source = @src();
    const qemu_cmd: []const u8 = switch (arch) {
        .x86 => "qemu-system-i386",
        else => std.debug.panic(
            \\
            \\Cannot run qemu system for architecture: {s}
            \\We either:
            \\  - Couldn't find it in {s}
            \\  - Haven't implemented building it
        , .{ @tagName(arch), source.file }),
    };

    const cmd = b.addSystemCommand(&.{qemu_cmd});
    cmd.addArg("-hda");
    cmd.addFileArg(lp);

    return cmd;
}
