const std = @import("std");

pub fn build(b: *std.Build) void {
    const arch = b.option(Arch, "arch", "Cpu architecture (Defaults to x86_64)") orelse Arch.x86_64;
    const optimize = b.standardOptimizeOption(.{});

    const kernel_module = b.createModule(.{
        .root_source_file = b.path("kernel/kernel.zig"),
        .target = b.resolveTargetQuery(arch.getTargetQuery()),
        .optimize = optimize,
    });

    switch (arch) {
        .x86_64 => {
            kernel_module.red_zone = false;
            kernel_module.code_model = .kernel;
        },
    }

    const kernel = b.addExecutable(.{
        .name = "kernel",
        .root_module = kernel_module,
    });

    const kernel_step = b.step("kernel", "Build the kernel");
    b.installArtifact(kernel);
    kernel_step.dependOn(&kernel.step);
}

const Arch = enum {
    x86_64,

    pub fn toStdArch(self: @This()) std.Target.Cpu.Arch {
        return switch (self) {
            .x86_64 => .x86_64,
        };
    }

    fn getTargetQuery(self: Arch) std.Target.Query {
        var query: std.Target.Query = .{
            .cpu_arch = self.toStdArch(),
            .os_tag = .freestanding,
            .abi = .none,
        };

        switch (self) {
            .x86_64 => {
                const Target = std.Target.x86;

                query.cpu_features_add = Target.featureSet(&.{ .popcnt, .soft_float });
                query.cpu_features_sub = Target.featureSet(&.{ .avx, .avx2, .sse, .sse2, .mmx });
            },
        }

        return query;
    }
};
