build:
	zig build

iso: build
	mkdir -p isodir/boot/grub; \
	cp zig-out/bin/kernel.elf isodir/boot/kernel.elf; \
	cp grub/grub.cfg isodir/boot/grub/grub.cfg; \
	grub-mkrescue -o zeaOS.iso isodir; \

run:
	qemu-system-i386 -cdrom zeaOS.iso

build-run: iso run

clean:
	rm -rf isodir; \
	rm -rf zig-out; \
	rm -f zeaOS.iso
