build:
	zig build

iso: build
	mkdir -p isodir/boot/grub; \
	cp zig-out/bin/kernel.elf isodir/boot/kernel.elf; \
	cp grub/grub.cfg isodir/boot/grub/grub.cfg; \
	grub-mkrescue -o kernel.iso isodir; \
	rm -rf isodir

run: iso
	qemu-system-i386 -cdrom kernel.iso
