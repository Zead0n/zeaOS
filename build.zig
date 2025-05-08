const std = @import("std");

pub fn build(b: *std.Build) void {
    const arch = b.option(Arch, "arch", "Cpu architecture (Defaults to x86)") orelse Arch.x86;
    const optimize = b.standardOptimizeOption(.{});

    const kernel_module = b.createModule(.{
        .root_source_file = b.path("kernel/kernel.zig"),
        .target = b.resolveTargetQuery(arch.getTargetQuery()),
        .optimize = optimize,
    });

    switch (arch) {
        .x86 => {
            kernel_module.red_zone = false;
            kernel_module.code_model = .kernel;
        },
    }

    const kernel = b.addExecutable(.{
        .name = "kernel.elf",
        .root_module = kernel_module,
    });
    kernel.setLinkerScript(b.path("kernel/linker.ld"));

    const kernel_step = b.step("kernel", "Build the kernel");
    b.installArtifact(kernel);
    kernel_step.dependOn(b.getInstallStep());

    const qemu_i386_cmd = b.addSystemCommand(&.{ "qemu-system-i386", "-kernel" });
    qemu_i386_cmd.addArtifactArg(kernel);
    qemu_i386_cmd.step.dependOn(&kernel.step);
    const qemu_i386_step = b.step("qemu-i386", "Build and run kernel on i386");
    qemu_i386_step.dependOn(&qemu_i386_cmd.step);
}

const Arch = enum {
    x86,

    pub fn toStdArch(self: Arch) std.Target.Cpu.Arch {
        return switch (self) {
            .x86 => .x86,
        };
    }

    fn getTargetQuery(self: Arch) std.Target.Query {
        var query: std.Target.Query = .{
            .cpu_arch = self.toStdArch(),
            .os_tag = .freestanding,
            .abi = .none,
        };

        switch (self) {
            .x86 => {
                const Target = std.Target.x86;

                query.cpu_features_add = Target.featureSet(&.{ .popcnt, .soft_float });
                query.cpu_features_sub = Target.featureSet(&.{ .avx, .avx2, .sse, .sse2, .mmx });
            },
        }

        return query;
    }
};
