ASM = nasm
DD = dd

all: birthday.img birthday.iso

birthday.img: boot/boot.bin kernel/kernel.bin
	$(DD) if=/dev/zero of=birthday.img bs=512 count=2880
	$(DD) if=boot/boot.bin of=birthday.img bs=512 count=1 conv=notrunc
	$(DD) if=kernel/kernel.bin of=birthday.img bs=512 count=1 seek=1 conv=notrunc

birthday.iso: birthday.img
	mkdir -p iso_tmp
	cp birthday.img iso_tmp/
	genisoimage -o birthday.iso -b birthday.img -no-emul-boot -boot-load-size 4 -boot-info-table iso_tmp/
	rm -rf iso_tmp

boot/boot.bin: boot/boot.asm
	$(ASM) -f bin boot/boot.asm -o boot/boot.bin

kernel/kernel.bin: kernel/kernel.asm
	$(ASM) -f bin kernel/kernel.asm -o kernel/kernel.bin

clean:
	rm -f boot/boot.bin kernel/kernel.bin birthday.img birthday.iso

run: birthday.img
	qemu-system-i386 -drive format=raw,file=birthday.img,index=0,if=floppy -boot a

usb: birthday.img
	@echo "To write to USB drive, run:"
	@echo "sudo dd if=birthday.img of=/dev/sdX bs=1M status=progress"
	@echo "Replace /dev/sdX with your USB device. BE VERY CAREFUL!"

.PHONY: all clean run usb
