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

    pub fn buildGrubIso(self: Builder, b: *std.Build) *std.Build.Step.InstallFile {
        const kernel = self.buildKernel(b);
        const os_name = "ZeaOS";
        const iso_name = "zeaOS.iso";

        // NOTE: I don't recommend changing anything below,
        // but if grub, xorriso, etc. changes so that this
        // fails, update accordingly

        const boot_dir_name = "boot";
        const grub_cfg_path = b.pathJoin(&.{ boot_dir_name, "grub", "grub.cfg" });
        const grub_kernel_path = b.pathJoin(&.{ boot_dir_name, kernel.name });

        const grub_cfg = b.fmt(
            \\menuentry "{s}" {{
            \\  multiboot /{s}
            \\}}
        , .{ os_name, grub_kernel_path });

        const grub_files = b.addWriteFiles();
        grub_files.step.dependOn(&kernel.step);
        _ = grub_files.add(grub_cfg_path, grub_cfg);
        _ = grub_files.addCopyFile(kernel.getEmittedBin(), grub_kernel_path);

        const grub_cmd = b.addSystemCommand(&.{"grub-mkrescue"});
        const iso = grub_cmd.addPrefixedOutputFileArg("--output=", iso_name);
        grub_cmd.step.dependOn(&grub_files.step);
        grub_cmd.addDirectoryArg(grub_files.getDirectory());
        // NOTE: xorriso spits out an stderr when successful, we're just
        // going to ignore it if it matches this vvv
        grub_cmd.addCheck(.{
            .expect_stderr_match = "RockRidge filesystem manipulator, libburnia project.",
        });

        const iso_install = b.addInstallBinFile(iso, iso_name);
        iso_install.step.dependOn(&grub_cmd.step);

        return iso_install;
    }
};
