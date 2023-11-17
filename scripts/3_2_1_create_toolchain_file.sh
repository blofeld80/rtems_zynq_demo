#!/bin/bash
#SPDX-License-Identifier: BSD-2-Clause
#Copyright (C) 2023 B. Moessner


THIS_SCRIPT=$(realpath "$0")
THIS_DIR=$(dirname "${THIS_SCRIPT}")

#################################################
## check the arguments the user has passed
function print_help {
  echo "Please call this script using ./3_2_1_create_toolchain_file -b <bsp_name>"
  echo "where bsp_name is one of:"
  echo "  xilinx_zynq_pynq"
  echo "  xilinx_zynq_picozed"
  echo "  xilinx_zynq_microzed"
  echo "  xilinx_zynq_zybo"
  echo "  xilinx_zynq_zybo_z7"
  echo "  xilinx_zynq_zedboard"
  echo "  xilinx_zynq_zc702"
  echo "  xilinx_zynq_zc706"
}

function print_error {
  echo "ERROR: ${1}"
}


if [[ $# -eq 0 ]] ; then
    print_error "No board provided!"
    print_help
    exit 1
fi

for a in "$@"; do
  case $1 in
    -b|--board)
      RTEMS_BSP_NAME="${2}"
      shift
      shift
      ;;
    -h|--help)
      print_help
      exit 1
      ;;
    -*|--*)
      echo "Unknown argument $1"
      exit 1
      ;;
    *)
      ;;
  esac
done



#################################################
## check if the board is supported by this script
case ${RTEMS_BSP_NAME} in

  xilinx_zynq_pynq)
    echo "Builing for bsp: ${RTEMS_BSP_NAME}"
    ;;
  xilinx_zynq_picozed)
    echo "Builing for bsp: ${RTEMS_BSP_NAME}"
    ;;
  xilinx_zynq_microzed)
    echo "Builing for bsp: ${RTEMS_BSP_NAME}"
    ;;
  xilinx_zynq_zybo)
    echo "Builing for bsp: ${RTEMS_BSP_NAME}"
    ;;
  xilinx_zynq_zybo_z7)
    echo "Builing for bsp: ${RTEMS_BSP_NAME}"
    ;;
  xilinx_zynq_zedboard)
    echo "Builing for bsp: ${RTEMS_BSP_NAME}"
    ;;
  xilinx_zynq_zc702)
    echo "Builing for bsp: ${RTEMS_BSP_NAME}"
    ;;
  xilinx_zynq_zc702)
    echo "Builing for bsp: ${RTEMS_BSP_NAME}"
    ;;
  xilinx_zynq_zc706)
    echo "Builing for bsp: ${RTEMS_BSP_NAME}"
    ;;
  *)
    print_error "Unknown board ${RTEMS_BSP_NAME}"
    exit 1
    ;;
esac


  
# Read the configuration
source ${THIS_DIR}/config/config.sh

CMAKE_TCF_DIR=${RTEMS_OS_INSTALL_DIR}/../cmake

if [ -d "${CMAKE_TCF_DIR}" ]; then 
  rm -rf ${CMAKE_TCF_DIR}
fi 

mkdir ${CMAKE_TCF_DIR}


cp ${THIS_DIR}/../app/cmake/toolchain.cmake.in ${CMAKE_TCF_DIR}/toolchain.cmake


sed -i "s;REPLACE_RTEMS_TOOLCHAIN_INSTALL_DIR;${RTEMS_TOOLCHAIN_INSTALL_DIR};g" ${CMAKE_TCF_DIR}/toolchain.cmake
sed -i "s;REPLACE_RTEMS_BSP_ARCH;${RTEMS_BSP_ARCH};g" ${CMAKE_TCF_DIR}/toolchain.cmake
sed -i "s;REPLACE_RTEMS_BSP_NAME;${RTEMS_BSP_NAME};g" ${CMAKE_TCF_DIR}/toolchain.cmake
sed -i "s;REPLACE_RTEMS_LIBBSD_INC_DIR;${RTEMS_LIBBSD_INSTALL_DIR}/${RTEMS_BSP_ARCH}-rtems6/${RTEMS_BSP_NAME}/lib/include;g" ${CMAKE_TCF_DIR}/toolchain.cmake
sed -i "s;REPLACE_RTEMS_LIBBSD_LIB_DIR;${RTEMS_LIBBSD_INSTALL_DIR}/${RTEMS_BSP_ARCH}-rtems6/${RTEMS_BSP_NAME}/lib;g" ${CMAKE_TCF_DIR}/toolchain.cmake
sed -i "s;REPLACE_RTEMS_INC_DIR;${RTEMS_OS_INSTALL_DIR}/${RTEMS_BSP_ARCH}-rtems6/${RTEMS_BSP_NAME}/lib/include;g" ${CMAKE_TCF_DIR}/toolchain.cmake
sed -i "s;REPLACE_RTEMS_LIB_DIR;${RTEMS_OS_INSTALL_DIR}/${RTEMS_BSP_ARCH}-rtems6/${RTEMS_BSP_NAME}/lib;g" ${CMAKE_TCF_DIR}/toolchain.cmake
sed -i "s;REPLACE_APP_FOLDER;${THIS_DIR}/../app;g" ${CMAKE_TCF_DIR}/toolchain.cmake
