#!/usr/bin/bash

KERNEL_VER=6.6.67

# install dependencies
sudo apt install -y build-essential libncurses5-dev fakeroot xz-utils libelf-dev liblz4-tool unzip flex bison bc debhelper rsync libssl-dev:native

KERNEL_ARCHIVE=linux-$KERNEL_VER.tar.xz
OUTPUT_ARCHIVE_DIR=../archives/$KERNEL_ARCHIVE

# remove old archive
if test -f "$OUTPUT_ARCHIVE_DIR"; then
	rm $OUTPUT_ARCHIVE_DIR
fi

# download kernel
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KERNEL_VER.tar.xz -O $OUTPUT_ARCHIVE_DIR

# move to destination
cd ..

if [ -d "linux-$KERNEL_VER" ]; then
	rm -rf linux-$KERNEL_VER
fi

# untar archive with linux kernel
tar -xvf archives/linux-$KERNEL_VER.tar.xz
cd linux-$KERNEL_VER

# setting config
echo "Setting config..."
cp ../cfg/config .config

# optimizations
echo "Enable THIN LTO..."

scripts/config --disable LTO_CLANG_FULL
scripts/config --enable LTO_CLANG_THIN

echo "Disabling Trusted Keys for successfull build..."

scripts/config --disable SYSTEM_TRUSTED_KEYS

# apply patch
echo "Applying acs override patch..."

patch -Np1 -F100 -i "../patches/add-acs-overrides.patch"

make olddefconfig
# build deb packages
time make -j $(nproc) bindeb-pkg LOCALVERSION=-vfio
