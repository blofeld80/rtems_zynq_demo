#!/bin/bash
#SPDX-License-Identifier: BSD-2-Clause
#Copyright (C) 2023 B. Moessner


THIS_SCRIPT=$(realpath "$0")
THIS_DIR=$(dirname "${THIS_SCRIPT}")

# Read the configuration
source ${THIS_DIR}/config/config.sh


if [ ! -d "${TOP_DIR}" ]; then 
  mkdir -p ${TOP_DIR}
fi

git_clone_branch "OPENOCD"  ${OPENOCD_GIT_REPO} ${OPENOCD_VER_COMMIT} ${OPENOCD_SRC_DIR}  
git_clone_branch "QEMU"  ${QEMU_GIT_REPO} ${QEMU_VER_COMMIT} ${QEMU_SRC_DIR} 
git_clone_commit "RSB"   ${RTEMS_RSB_GIT_REPO} ${RTEMS_RSB_VER_COMMIT} ${RTEMS_RSB_SRC_DIR} 



#################################################
## Build tools

if [ ! -d "${QEMU_INSTALL_DIR}" ]; then 
  echo ""
  echo "###############################################################################"
  echo "Build and install Xilinx QEMU"
  echo "###############################################################################"
  echo ""
  pushd ${QEMU_SRC_DIR}
  if [ -d "${QEMU_SRC_DIR}/build" ]; then 
    rm -rf ${QEMU_SRC_DIR}/build
  fi
  mkdir ${QEMU_SRC_DIR}/build
  pushd ${QEMU_SRC_DIR}/build
  ../configure --static --target-list="aarch64-softmmu microblazeel-softmmu" --prefix=${QEMU_INSTALL_DIR}
  make -j $(nproc)
  make install -j 1
  popd
  popd
fi

if [ ! -d "${OPENOCD_INSTALL_DIR}" ]; then 
  echo ""
  echo "###############################################################################"
  echo "Build and install OpenOCD"
  echo "###############################################################################"
  echo ""
  pushd ${OPENOCD_SRC_DIR}
  ./bootstrap 
  ./configure --enable-jlink --enable-ftdi --enable-dummy --enable-rshim --enable-ftdi  --enable-stlink  --enable-ti-icdi --enable-ulink --enable-usb-blaster-2 --enable-ft232r  --enable-vsllink --enable-xds110  --enable-cmsis-dap-v2  --enable-osbdm --enable-opendous  --enable-armjtagew --enable-rlink --enable-usbprog --enable-esp-usb-jtag  --enable-cmsis-dap --enable-nulink  --enable-kitprog --enable-usb-blaster --enable-presto  --enable-openjtag  --enable-buspirate --enable-jlink --enable-aice --enable-jtag_vpi  --enable-vdebug  --enable-jtag_dpi  --enable-amtjtagaccel  --enable-bcm2835gpio --enable-imx_gpio  --enable-remote-bitbang --prefix=${OPENOCD_INSTALL_DIR}
  make -j $(nproc)
  make install -j 1
  popd
fi


#if [ ! -d "${ECLIPSE_INSTALL_DIR}" ]; then 
#  echo ""
#  echo "###############################################################################"
#  echo "Install Ecipse"
#  echo "###############################################################################"
#  echo ""
#  if [ ! -d "${ECLIPSE_SRC_DIR}" ]; then 
#    rm -rf ${ECLIPSE_SRC_DIR}
#  fi
#  mkdir ${ECLIPSE_SRC_DIR}

#  wget ${ECLIPSE_SRC_REPO}/${ECLIPSE_TAR_NAME} -P ${ECLIPSE_SRC_DIR}

#  mkdir ${ECLIPSE_INSTALL_DIR}
#  tar -zxvf ${ECLIPSE_SRC_DIR}/${ECLIPSE_TAR_NAME} -C ${ECLIPSE_INSTALL_DIR}
#fi


if [ ! -d "${RTEMS_TOOLCHAIN_INSTALL_DIR}" ]; then 
  echo ""
  echo "###############################################################################"
  echo "Build and install RTEMS toolchain"
  echo "###############################################################################"
  echo ""
  pushd ${RTEMS_RSB_SRC_DIR}/rtems
  ../source-builder/sb-set-builder --prefix=${RTEMS_TOOLCHAIN_INSTALL_DIR} 6/rtems-${RTEMS_BSP_ARCH}
  popd
fi
