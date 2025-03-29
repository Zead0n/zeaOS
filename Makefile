ZIG_OUTPUT=zig-out
GRUB_DIR=isogrub
ISO_BIN=bin
ISO_FILENAME=zeaos.iso

build:
	zig build -p $(ZIG_OUTPUT)

iso: build
	mkdir -p $(GRUB_DIR)/boot/grub; \
	mkdir $(ISO_BIN); \
	cp $(ZIG_OUTPUT)/bin/kernel.elf $(GRUB_DIR)/boot/kernel.elf; \
	cp boot/grub/grub.cfg $(GRUB_DIR)/boot/grub/grub.cfg; \
	grub-mkrescue -o $(ISO_BIN)/$(ISO_FILENAME) $(GRUB_DIR); \

run:
	qemu-system-i386 -cdrom $(ISO_BIN)/$(ISO_FILENAME)

build-run: iso run

clean:
	rm -rf $(GRUB_DIR); \
	rm -rf $(ZIG_OUTPUT); \
	rm -rf $(ISO_BIN)
