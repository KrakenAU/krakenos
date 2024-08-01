# Makefile for KrakenOS

# Compiler and flags
ASM = nasm
ASMFLAGS = -f bin

# Compiler for C
CC = gcc
CFLAGS = -m32 -ffreestanding -fno-pie -fno-stack-protector -nostdlib -nostdinc -fno-builtin -c -O2

# Linker
LD = ld
LDFLAGS = -m i386pe -Ttext 0x100000 --entry kernel_main -nostdlib

# Directories
BUILD_DIR = build
BOOT_DIR = boot
KERNEL_DIR = kernel

# Files
BOOTLOADER = $(BOOT_DIR)/bootloader.asm
SECONDSTAGE = $(BOOT_DIR)/secondstage.asm
BOOTLOADER_BIN = $(BUILD_DIR)/bootloader.bin
SECONDSTAGE_BIN = $(BUILD_DIR)/secondstage.bin
OS_IMAGE = krakenOS.img
KERNEL_SRC = $(KERNEL_DIR)/kernel.c
KERNEL_OBJ = $(BUILD_DIR)/kernel.o
KERNEL_BIN = $(BUILD_DIR)/kernel.bin

# Default target
all: $(OS_IMAGE)

# Create build directory
$(BUILD_DIR):
	mkdir $(BUILD_DIR)

# Compile bootloader
$(BOOTLOADER_BIN): $(BOOTLOADER) | $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

$(SECONDSTAGE_BIN): $(SECONDSTAGE) | $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

# Compile kernel
$(KERNEL_OBJ): $(KERNEL_SRC) | $(BUILD_DIR)
	$(CC) $(CFLAGS) $< -o $@

# Link kernel
$(KERNEL_BIN): $(KERNEL_OBJ)
	$(LD) $(LDFLAGS) $< -o $@

# Create disk image
$(OS_IMAGE): $(BOOTLOADER_BIN) $(SECONDSTAGE_BIN) $(KERNEL_BIN)
	dd if=/dev/zero of=$@ bs=512 count=34
	dd if=$(BOOTLOADER_BIN) of=$@ conv=notrunc
	dd if=$(SECONDSTAGE_BIN) of=$@ bs=512 seek=1 conv=notrunc
	dd if=$(KERNEL_BIN) of=$@ bs=512 seek=3 conv=notrunc

# QEMU command
QEMU = qemu-system-i386
QEMU_FLAGS = -hda

# Run target
run: $(OS_IMAGE)
	$(QEMU) $(QEMU_FLAGS) $(OS_IMAGE)

# Clean up
clean:
	if exist $(BUILD_DIR) rmdir /s /q $(BUILD_DIR)
	if exist $(OS_IMAGE) del $(OS_IMAGE)

# Print success message
.PHONY: success
success:
	@echo Build successful!

# Add success message to the all target
all: success