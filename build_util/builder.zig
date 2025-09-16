const std = @import("std");

pub const Builder = struct {
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,

    pub fn buildBoot(self: Builder, b: *std.Build) *std.Build.Step.ObjCopy {
        const boot_dir = b.path("boot");

        const boot_module = b.createModule(.{
            .target = self.target,
            .optimize = self.optimize,
        });
        boot_module.addAssemblyFile(boot_dir.path(b, "boot.S"));

        const boot_obj = b.addObject(.{
            .name = "boot.o",
            .root_module = boot_module,
        });
        boot_obj.setLinkerScript(boot_dir.path(b, "link.ld"));

        return b.addObjCopy(boot_obj.getEmittedBin(), .{
            .basename = "boot.bin",
            .format = .bin,
        });
    }

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
