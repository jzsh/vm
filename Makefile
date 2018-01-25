KERNEL_DIR=linux-4.4.60/
BUSYBOX=busybox-1.20.2

all:
	cd $(KERNEL_DIR); \
	make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm vexpress_defconfig; \
	make CROSS_COMPILE=arm-linux-gnueabi- ARCH=arm

busybox:
	cd $(BUSYBOX); \
	make defconfig; \
	make CROSS_COMPILE=arm-linux-gnueabi- ; \
	make install CROSS_COMPILE=arm-linux-gnueabi-

fs:
	rm -rf rootfs; mkdir -p rootfs/{dev,etc/init.d,lib}
	sudo cp busybox-1.20.2/_install/* -r rootfs/
	sudo cp -P /usr/arm-linux-gnueabi/lib/* rootfs/lib/
	sudo mknod rootfs/dev/tty1 c 4 1
	sudo mknod rootfs/dev/tty2 c 4 2
	sudo mknod rootfs/dev/tty3 c 4 3
	sudo mknod rootfs/dev/tty4 c 4 4
	dd if=/dev/zero of=a9rootfs.ext3 bs=1M count=32
	mkfs.ext3 a9rootfs.ext3
	sudo mkdir tmpfs
	sudo mount -t ext3 a9rootfs.ext3 tmpfs/ -o loop
	sudo cp -r rootfs/*  tmpfs/
	sudo umount tmpfs

start:
	qemu-system-arm -M vexpress-a9 \
	-m 512M \
	-kernel $(KERNEL_DIR)/arch/arm/boot/zImage \
	-dtb  $(KERNEL_DIR)/arch/arm/boot/dts/vexpress-v2p-ca9.dtb \
	-nographic \
	-append "root=/dev/mmcblk0  console=ttyAMA0" \
	-sd a9rootfs.ext3

clean:
	-rm -rf tmpfs a9rootfs.ext3 rootfs



