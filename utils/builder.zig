const std = @import("std");

pub const Builder = struct {
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,

    pub fn buildKernel(self: Builder, b: *std.Build) *std.Build.Step.Compile {
        const kernel_dir = b.path("kernel");

        const kernel_module = b.createModule(.{
            .root_source_file = kernel_dir.path(b, "kernel.zig"),
            .target = self.target,
            .optimize = self.optimize,
        });

        switch (self.target.result.cpu.arch) {
            .x86 => {
                kernel_module.red_zone = false;
                kernel_module.code_model = .kernel;
            },
            else => {},
        }

        const kernel = b.addExecutable(.{
            .name = "kernel.elf",
            .root_module = kernel_module,
        });
        kernel.setLinkerScript(kernel_dir.path(b, "linker.ld"));

        return kernel;
    }
};
