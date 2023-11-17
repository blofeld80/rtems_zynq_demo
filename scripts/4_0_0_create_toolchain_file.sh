#!/bin/bash
#SPDX-License-Identifier: BSD-2-Clause
#Copyright (C) 2023 B. Moessner


THIS_SCRIPT=$(realpath "$0")
THIS_DIR=$(dirname "${THIS_SCRIPT}")

# Read the configuration
source ${THIS_DIR}/config/config.sh

CMAKE_TCF_DIR=${TOP_INSTALL_DIR}/cmake

if [ -d "${CMAKE_TCF_DIR}" ]; then 
  rm -rf ${CMAKE_TCF_DIR}
fi 

mkdir ${CMAKE_TCF_DIR}

cp ${THIS_DIR}/app/cmake/toolchain.cmake.in ${CMAKE_TCF_DIR}/toolchain.cmake


sed -i "s;REPLACE_RTEMS_TOOLCHAIN_INSTALL_DIR;${RTEMS_TOOLCHAIN_INSTALL_DIR};g" ${CMAKE_TCF_DIR}/toolchain.cmake
sed -i "s;REPLACE_RTEMS_BSP_ARCH;${RTEMS_BSP_ARCH};g" ${CMAKE_TCF_DIR}/toolchain.cmake
sed -i "s;REPLACE_RTEMS_BSP_NAME;${RTEMS_BSP_NAME};g" ${CMAKE_TCF_DIR}/toolchain.cmake
sed -i "s;REPLACE_RTEMS_LIBBSD_INC_DIR;${RTEMS_LIBBSD_INSTALL_DIR}/${RTEMS_BSP_ARCH}-rtems6/${RTEMS_BSP_NAME}/lib/include;g" ${CMAKE_TCF_DIR}/toolchain.cmake
sed -i "s;REPLACE_RTEMS_LIBBSD_LIB_DIR;${RTEMS_LIBBSD_INSTALL_DIR}/${RTEMS_BSP_ARCH}-rtems6/${RTEMS_BSP_NAME}/lib;g" ${CMAKE_TCF_DIR}/toolchain.cmake
sed -i "s;REPLACE_RTEMS_INC_DIR;${RTEMS_OS_INSTALL_DIR}/${RTEMS_BSP_ARCH}-rtems6/${RTEMS_BSP_NAME}/lib/include;g" ${CMAKE_TCF_DIR}/toolchain.cmake
sed -i "s;REPLACE_RTEMS_LIB_DIR;${RTEMS_OS_INSTALL_DIR}/${RTEMS_BSP_ARCH}-rtems6/${RTEMS_BSP_NAME}/lib;g" ${CMAKE_TCF_DIR}/toolchain.cmake
sed -i "s;REPLACE_APP_FOLDER;${THIS_DIR}/app;g" ${CMAKE_TCF_DIR}/toolchain.cmake
