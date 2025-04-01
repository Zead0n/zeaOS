const std = @import("std");
const arch = @import("../arch/arch.zig");

pub fn buildKernel(b: *std.Build, exeOptions: std.Build.ExecutableOptions) *std.Build.Step.Compile {
    const kernel = b.addExecutable(exeOptions);
    return kernel;
}
