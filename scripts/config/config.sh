#!/bin/bash
#SPDX-License-Identifier: BSD-2-Clause
#Copyright (C) 2023 B. Moessner


TOP_DIR=~/quick-start
TOP_INSTALL_DIR=${TOP_DIR}/install
TOP_SOURCE_DIR=${TOP_DIR}/src
TOP_WORK_DIR=${TOP_DIR}/work

TOOL_INSTALL_DIR=${TOP_INSTALL_DIR}/tools   # toolchain, qemu, openocd will go in here
SW_INSTALL_DIR=${TOP_INSTALL_DIR}/sw        # rtems, libbsd 
HW_INSTALL_DIR=${TOP_INSTALL_DIR}/hw        # xsa, bitstream, boot.bin

if [ ! -d "${TOOL_INSTALL_DIR}" ]; then mkdir -p ${TOOL_INSTALL_DIR} ; fi
if [ ! -d "${SW_INSTALL_DIR}" ];   then mkdir -p ${SW_INSTALL_DIR} ; fi
if [ ! -d "${HW_INSTALL_DIR}" ];   then mkdir -p ${HW_INSTALL_DIR} ; fi

#################################################
## RTEMS build config
RTEMS_BSP_ARCH=arm
#RTEMS_BSP_NAME=xilinx_zynq_pynq


#################################################
## RSB
RTEMS_RSB_GIT_REPO=https://github.com/RTEMS/rtems-source-builder.git
RTEMS_RSB_SRC_DIR=${TOP_SOURCE_DIR}/rsb
RTEMS_RSB_VER_COMMIT="633023de6517998ee3b84e7ed172b1c5f2bf502b"
RTEMS_TOOLCHAIN_INSTALL_DIR=${TOOL_INSTALL_DIR}/toolchain

#################################################
## RTEMS
RTEMS_OS_GIT_REPO=https://github.com/blofeld80/rtems.git
RTEMS_OS_SRC_DIR=${TOP_SOURCE_DIR}/rtems
RTEMS_OS_VER_COMMIT=feature/add_zynq_boards_2
RTEMS_OS_INSTALL_DIR=${SW_INSTALL_DIR}/${RTEMS_BSP_NAME}/rtems

#################################################
## QEMU
QEMU_GIT_REPO=https://github.com/Xilinx/qemu.git
QEMU_SRC_DIR=${TOP_SOURCE_DIR}/qemu
QEMU_VER_COMMIT="xilinx_v2023.2"
QEMU_INSTALL_DIR=${TOOL_INSTALL_DIR}/qemu


#################################################
## RTEMS Libbsd
RTEMS_LIBBSD_GIT_REPO=https://github.com/RTEMS/rtems-libbsd.git
RTEMS_LIBBSD_SRC_DIR=${TOP_SOURCE_DIR}/rtems-libbsd
RTEMS_LIBBSD_VER_COMMIT=e07b74b88af55df551046bd1beb775f843a96fe5
RTEMS_LIBBSD_INSTALL_DIR=${SW_INSTALL_DIR}/${RTEMS_BSP_NAME}/rtems-libbsd


#################################################
## Eclipse
ECLIPSE_INSTALL_DIR=${TOOL_INSTALL_DIR}/eclipse
ECLIPSE_SRC_DIR=${TOP_SOURCE_DIR}/eclipse
ECLIPSE_SRC_REPO=http://ftp.halifax.rwth-aachen.de/eclipse/technology/epp/downloads/release/2023-09/R/
ECLIPSE_TAR_NAME=eclipse-embedcpp-2023-09-R-linux-gtk-x86_64.tar.gz


#################################################
## OpenOCD
OPENOCD_GIT_REPO=https://github.com/openocd-org/openocd.git
OPENOCD_SRC_DIR=${TOP_SOURCE_DIR}/openocd
OPENOCD_VER_COMMIT=v0.12.0
OPENOCD_INSTALL_DIR=${TOOL_INSTALL_DIR}/openocd


#################################################
## Xilinx tools
XILINX_BASE_PATH=/opt/Xilinx
XILINX_VIVADO_VERSION="2021.2"
XILINX_VITIS_VERSION="2021.2"
VIVADO_PATH=${XILINX_BASE_PATH}/Vivado/${XILINX_VIVADO_VERSION}/bin
VIVADO_EXE=${XILINX_BASE_PATH}/Vivado/${XILINX_VIVADO_VERSION}/bin/vivado
VITIS_XSCT_EXE=${XILINX_BASE_PATH}/Vitis/${XILINX_VITIS_VERSION}/bin/xsct
VITIS_BOOTGEN_EXE=${XILINX_BASE_PATH}/Vitis/${XILINX_VITIS_VERSION}/bin/bootgen

# TMP Dirs
WORKSPACE_DIR=${TOP_WORK_DIR}/workspace
SCRIPTING_DIR=${TOP_WORK_DIR}/scripts


#################################################
#################################################
## HW Section


#################################################
## PYNQ repos
PYNQ_GIT_REPO=https://github.com/Xilinx/PYNQ.git
PYNQ_VER_COMMIT="v3.0.1"

#################################################
## AVNET repos
AVNET_HDL_GIT_REPO=https://github.com/Avnet/hdl.git
AVNET_HDL_VER_COMMIT="2021.2"
AVNET_BDF_GIT_REPO=https://github.com/Avnet/bdf.git
AVNET_BDF_VER_COMMIT="master" 


#################################################
## Digilent repos
DIGILENT_ZYBO_GIT_REPO=https://github.com/Digilent/Zybo-Z7-HW.git
DIGILENT_ZYBO_Z7_10_VER_COMMIT="822f012a692db936ed39a17de411f5b6bead27bb" # branch "10/Petalinux/master"
DIGILENT_ZYBO_Z7_20_VER_COMMIT="89b4a8e5f9f6f1579cb4768a9aeff0f3640093b9" # branch "20/Petalinux/master"

DIGILENT_BDF_GIT_REPO=https://github.com/Digilent/vivado-boards.git
DIGILENT_BDF_VER_COMMIT="8ed4f9981da1d80badb0b1f65e250b2dbf7a564d" # branch master

DIGILENT_ZYBO_DESIGN=zybo_base_system
DIGILENT_ZYBO_DESIGN_ZIP=${DIGILENT_ZYBO_DESIGN}.zip
DIGILENT_ZYBO_DESIGN_URL=https://digilent.com/reference/_media/reference/programmable-logic/zybo/${DIGILENT_ZYBO_DESIGN_ZIP}



#################################################
## Git clone functions
function git_clone_branch {
  if [ ! -d "${4}" ]; then 
    echo ""
    echo "###############################################################################"
    echo "Fetch ${1}:" 
    echo "  Clone branch ${3}" 
    echo "  from repo ${2}"
    echo "  into folder ${4}"
    echo "###############################################################################"
    echo ""
    git clone --depth=1 -b ${3} ${2} ${4}
  fi
}

function git_clone_commit {
  if [ ! -d "${4}" ]; then 
    echo ""
    echo "###############################################################################"
    echo "Fetch ${1}:" 
    echo "  Clone commit ${3}" 
    echo "  from repo ${2}"
    echo "  into folder ${4}"
    echo "###############################################################################"
    echo ""
    git clone ${2} ${4}
    pushd ${4}
    git checkout ${3}
    popd
  fi
} 
