const std = @import("std");
const zon = @import("builtin");

pub fn build(b: *std.Build) void {
    const zea = b.option(Zea, "arch", "Cpu architecture (Defaults to x86)") orelse Zea.x86;

    const kernel_step = b.step("kernel", "Build the kernel");
    const kernel = zea.buildKernel(b);
    b.installArtifact(kernel);
    kernel_step.dependOn(&kernel.step);

    const grub_step = b.step("grub", "Build grub iso");
    const grub_iso = buildIso(b, kernel);
    grub_step.dependOn(&grub_iso.step);

    const qemu_step = b.step("qemu", "Build and run the kernel in qemu");
    const qemu_cmd = b.addSystemCommand(&.{ "qemu-system-i386", "-kernel" });
    qemu_cmd.addArtifactArg(kernel);
    qemu_cmd.step.dependOn(&kernel.step);
    qemu_step.dependOn(&qemu_cmd.step);
}

fn buildIso(b: *std.Build, kernel: *std.Build.Step.Compile) *std.Build.Step.InstallFile {
    const grub_kernel = b.pathJoin(&.{ "boot", kernel.out_filename });
    const gen_grub = b.fmt(
        \\menuentry "ZeaOS" {{
        \\    multiboot /{s}
        \\}}
    , .{grub_kernel});

    const boot_dir = b.addWriteFiles();
    _ = boot_dir.addCopyFile(kernel.getEmittedBin(), grub_kernel);
    _ = boot_dir.add(b.pathJoin(&.{ "boot", "grub", "grub.cfg" }), gen_grub);

    const grub_iso_cmd = b.addSystemCommand(&.{"grub-mkrescue"});
    const iso_file = grub_iso_cmd.addPrefixedOutputFileArg("--output=", "zeaos.iso");
    grub_iso_cmd.addDirectoryArg(boot_dir.getDirectory());
    grub_iso_cmd.step.dependOn(&boot_dir.step);

    return b.addInstallFile(iso_file, "zeaos.iso");
}

const Zea = enum {
    x86,

    pub fn buildKernel(self: Zea, b: *std.Build) *std.Build.Step.Compile {
        const target = b.resolveTargetQuery(self.getTargetQuery());
        const optimize = b.standardOptimizeOption(.{});

        const kernel = b.addExecutable(.{
            .name = "kerenel.elf",
            .root_source_file = b.path("kernel/kernel.zig"),
            .target = target,
            .optimize = optimize,
            .code_model = .kernel,
        });
        kernel.setLinkerScript(b.path("kernel/linker.ld"));

        return kernel;
    }

    fn getTargetQuery(self: Zea) std.Target.Query {
        return switch (self) {
            .x86 => blk: {
                var disabled_features = std.Target.Cpu.Feature.Set.empty;
                var enabled_features = std.Target.Cpu.Feature.Set.empty;

                disabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.mmx));
                disabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.sse));
                disabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.sse2));
                disabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.avx));
                disabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.avx2));

                enabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.soft_float));

                break :blk std.Target.Query{
                    .cpu_arch = .x86,
                    .os_tag = .freestanding,
                    .abi = .none,
                    .cpu_features_sub = disabled_features,
                    .cpu_features_add = enabled_features,
                };
            },
        };
    }
};
