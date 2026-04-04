#!/bin/bash
echo "- Setting up additional goodies..."

# Warning START
echo " "
echo "================================"
echo "   START OF  EXTERNAL SCRIPTS   "
echo "================================"
echo " "

# Backport exports
export BACKPORT_GENERAL_PATCH="https://github.com/JackA1ltman/NonGKI_Kernel_Build_2nd/raw/refs/heads/mainline/Patches/backport_patches.sh"

# KernelSU Settings - v1.7
if [[ "$KERNELSU_SELECTOR" == "zako" ]]; then
    export KSU_SETUP_URI="https://github.com/ReSukiSU/ReSukiSU/raw/refs/heads/main/kernel/setup.sh"
    export KSU_BRANCH="main"
    export KSU_HOOK="https://github.com/JackA1ltman/NonGKI_Kernel_Build_2nd/raw/refs/heads/mainline/Patches/syscall_hook_patches.sh"
elif [[ "$KERNELSU_SELECTOR" == "zako-susfs" ]]; then
    export KSU_SETUP_URI="https://github.com/ReSukiSU/ReSukiSU/raw/refs/heads/main/kernel/setup.sh"
    export KSU_BRANCH="main"
    export KSU_HOOK="https://github.com/JackA1ltman/NonGKI_Kernel_Build_2nd/blob/mainline/Patches/susfs_inline_hook_patches.sh"
elif [[ "$KERNELSU_SELECTOR" == "none" ]]; then
    export KSU_SETUP_URI=""
    export KSU_BRANCH=""
    export KSU_HOOK=""
else
    echo "- Invalid KERNELSU_SELECTOR. Use a valid option."
    echo "  Valid options: zako, zako-susfs, none."
    echo "  Yours is $KERNELSU_SELECTOR."
    exit 1
fi

# Baseband Guard Settings - v1.0
if [[ "$BBG_SELECTOR" == "bbg" ]]; then
    export BBG_SETUP_URI="https://github.com/vc-teahouse/Baseband-guard/raw/main/setup.sh"
elif [[ "$BBG_SELECTOR" == "none" ]]; then
    export BBG_SETUP_URI=""
else
    echo "- Invalid BBG_SELECTOR. Use a valid option."
    echo "  Valid options: bbg, none."
    echo "  Yours is $BBG_SELECTOR."
    exit 1
fi

# KernelSU setup
if [[ "$KERNELSU_SELECTOR" == "zako" ]]; then
    # Setup
    curl -LSs $KSU_SETUP_URI | bash -s $KSU_BRANCH
    # Add configs
    echo "CONFIG_KSU=y" >> $MAIN_DEFCONFIG
    echo "CONFIG_KSU_MULTI_MANAGER_SUPPORT=y" >> $MAIN_DEFCONFIG
    echo "CONFIG_KPM=n" >> $MAIN_DEFCONFIG
    echo "CONFIG_KSU_MANUAL_HOOK=y" >> $MAIN_DEFCONFIG
    echo "CONFIG_HAVE_SYSCALL_TRACEPOINTS=y" >> $MAIN_DEFCONFIG
    echo "CONFIG_THREAD_INFO_IN_TASK=y" >> $MAIN_DEFCONFIG
    # Apply hooks
    curl -LSs $BACKPORT_GENERAL_PATCH | bash
    curl -LSs $KSU_HOOK | bash
elif [[ "$KERNELSU_SELECTOR" == "zako-susfs" ]]; then
    # Setup
    curl -LSs $KSU_SETUP_URI | bash -s $KSU_BRANCH
    # Add configs
    echo "CONFIG_KSU=y" >> $MAIN_DEFCONFIG
    echo "CONFIG_KSU_MULTI_MANAGER_SUPPORT=y" >> $MAIN_DEFCONFIG
    echo "CONFIG_KPM=n" >> $MAIN_DEFCONFIG
    echo "CONFIG_KSU_MANUAL_HOOK=y" >> $MAIN_DEFCONFIG
    echo "CONFIG_HAVE_SYSCALL_TRACEPOINTS=y" >> $MAIN_DEFCONFIG
    echo "CONFIG_THREAD_INFO_IN_TASK=y" >> $MAIN_DEFCONFIG
    # SUSFS
    if [[ "$KERNEL_VERSION" == "4.19" ]]; then
        # Patches
        wget -qO- "https://github.com/JackA1ltman/NonGKI_Kernel_Build_2nd/raw/refs/heads/mainline/Patches/Patch/susfs_patch_to_4.19.patch" | patch -p1 --fuzz=5
        # Configs
        echo "CONFIG_KSU_SUSFS=y" >> $MAIN_DEFCONFIG
        echo "CONFIG_KSU_SUSFS_SUS_PATH=y" >> $MAIN_DEFCONFIG
        echo "CONFIG_KSU_SUSFS_SUS_MOUNT=y" >> $MAIN_DEFCONFIG
        echo "CONFIG_KSU_SUSFS_SUS_KSTAT=y" >> $MAIN_DEFCONFIG
        echo "CONFIG_KSU_SUSFS_SPOOF_UNAME=y" >> $MAIN_DEFCONFIG
        echo "CONFIG_KSU_SUSFS_ENABLE_LOG=y" >> $MAIN_DEFCONFIG
        echo "CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS=y" >> $MAIN_DEFCONFIG
        echo "CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG=y" >> $MAIN_DEFCONFIG
        echo "CONFIG_KSU_SUSFS_OPEN_REDIRECT=y" >> $MAIN_DEFCONFIG
        echo "CONFIG_KSU_SUSFS_SUS_MAP=y" >> $MAIN_DEFCONFIG
        echo "CONFIG_KSU_SUSFS_TRY_UMOUNT=y" >> $MAIN_DEFCONFIG
    elif [[ "$KERNEL_VERSION" == "4.14" ]]; then
        # Patches
        wget -qO- "https://github.com/JackA1ltman/NonGKI_Kernel_Build_2nd/raw/refs/heads/mainline/Patches/Patch/susfs_patch_to_4.14.patch" | patch -p1 --fuzz=5
        # Configs
        echo "CONFIG_KSU_SUSFS=y" >> $MAIN_DEFCONFIG
        echo "CONFIG_KSU_SUSFS_SUS_PATH=y" >> $MAIN_DEFCONFIG
        echo "CONFIG_KSU_SUSFS_SUS_MOUNT=y" >> $MAIN_DEFCONFIG
        echo "CONFIG_KSU_SUSFS_SUS_KSTAT=y" >> $MAIN_DEFCONFIG
        echo "CONFIG_KSU_SUSFS_SPOOF_UNAME=y" >> $MAIN_DEFCONFIG
        echo "CONFIG_KSU_SUSFS_ENABLE_LOG=y" >> $MAIN_DEFCONFIG
        echo "CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS=y" >> $MAIN_DEFCONFIG
        echo "CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG=y" >> $MAIN_DEFCONFIG
        echo "CONFIG_KSU_SUSFS_OPEN_REDIRECT=y" >> $MAIN_DEFCONFIG
        echo "CONFIG_KSU_SUSFS_SUS_MAP=y" >> $MAIN_DEFCONFIG
        echo "CONFIG_KSU_SUSFS_TRY_UMOUNT=y" >> $MAIN_DEFCONFIG
    fi
    # Apply hooks
    curl -LSs $BACKPORT_GENERAL_PATCH | bash
    curl -LSs $KSU_HOOK | bash
elif [[ "$KERNELSU_SELECTOR" == "" ]]; then
    echo "No KernelSU to set up."
fi

# Baseband Guard setup
if [[ "$BBG_SELECTOR" == "bbg" ]]; then
    # Setup
    curl -LSs $BBG_SETUP_URI | bash
    # Add configs
    echo "CONFIG_BBG=y" >> $MAIN_DEFCONFIG
    # LSM config
    if [[ "$KERNEL_VERSION" == "4.19" ]]; then
        sed -i '/CONFIG_LSM=/s/"$/ ,baseband_guard"/' $MAIN_DEFCONFIG
    elif [[ "$KERNEL_VERSION" == "4.14" ]]; then
        echo "Kernel is $KERNEL_VERSION, skipping LSM config."
    fi
elif [[ "$BBG_SELECTOR" == "" ]]; then
    echo "No Baseband Guard to set up."
fi

# Warning END
echo " "
echo "================================"
echo "    END OF  EXTERNAL SCRIPTS    "
echo "================================"
echo " "