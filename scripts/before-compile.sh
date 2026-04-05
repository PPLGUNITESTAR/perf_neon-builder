#!/bin/bash
echo "- Setting up kernel source pre-compilation..."

# Apply O3 flags
echo "-- Applying O3 flags before compiling..."
sed -i 's/KBUILD_CFLAGS\s\++= -O2/KBUILD_CFLAGS   += -O3/g' Makefile
sed -i 's/LDFLAGS\s\++= -O2/LDFLAGS += -O3/g' Makefile

# Ensure out directory exists
mkdir -p out &> /dev/null

# Setup main defconfig for compilation
make O=out \
    ARCH=arm64 \
    LLVM=1 \
    LLVM_IAS=1 \
    CC=clang \
    LD=ld.lld \
    AR=llvm-ar \
    AS=llvm-as \
    NM=llvm-nm \
    OBJCOPY=llvm-objcopy \
    OBJDUMP=llvm-objdump \
    STRIP=llvm-strip \
    CROSS_COMPILE=aarch64-linux-android- \
    CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
    CLANG_TRIPLE=aarch64-linux-gnu- \
    $ACTUAL_MAIN_DEFCONFIG &> /dev/null

echo "-- Appending fragments to .config..."
for fragment in $COMMON_DEFCONFIG $DEVICE_DEFCONFIG $FEATURE_DEFCONFIG; do
    if [ -f "arch/arm64/configs/$fragment" ]; then
        echo "  Merging $fragment..."
        cat "arch/arm64/configs/$fragment" >> out/.config
    else
        echo "  Warning: Fragment arch/arm64/configs/$fragment not found!"
    fi
done

echo "CONFIG_LOCALVERSION=\"$KERNEL_NAME\"" >> out/.config

# Run olddefconfig
yes "" | make O=out \
    ARCH=arm64 \
    LLVM=1 \
    LLVM_IAS=1 \
    CC=clang \
    LD=ld.lld \
    AR=llvm-ar \
    AS=llvm-as \
    NM=llvm-nm \
    OBJCOPY=llvm-objcopy \
    OBJDUMP=llvm-objdump \
    STRIP=llvm-strip \
    CROSS_COMPILE=aarch64-linux-android- \
    CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
    CLANG_TRIPLE=aarch64-linux-gnu- \
    olddefconfig &> /dev/null

# Run syncconfig
yes "" | make O=out \
    ARCH=arm64 \
    LLVM=1 \
    LLVM_IAS=1 \
    CC=clang \
    LD=ld.lld \
    AR=llvm-ar \
    AS=llvm-as \
    NM=llvm-nm \
    OBJCOPY=llvm-objcopy \
    OBJDUMP=llvm-objdump \
    STRIP=llvm-strip \
    CROSS_COMPILE=aarch64-linux-android- \
    CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
    CLANG_TRIPLE=aarch64-linux-gnu- \
    syncconfig &> /dev/null

# Final cleanup commit before compilation
echo "-- Cleaning up git before compiling..."
git config user.email $GIT_EMAIL &> /dev/null
git config user.name $GIT_NAME &> /dev/null
git config set advice.addEmbeddedRepo true &> /dev/null
git add . &> /dev/null
git commit -m "cleanup: applied patches before build" &> /dev/null