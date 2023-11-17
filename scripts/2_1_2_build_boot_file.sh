#!/bin/bash
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2023 B. Moessner


THIS_SCRIPT=$(realpath "$0")
THIS_DIR=$(dirname "${THIS_SCRIPT}")


#################################################
## check the arguments the user has passed
function print_help {
  echo "Please call this script using ./2_1_2_build_boot_file -b bit_file -f fsbl_file -a app_file -o full_path_to_output_folder"
  echo "Paramter app_file is optional"
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
    -b|--bit_file)
      BIT_FILE="${2}"
      shift
      shift
      ;;
    -f|--fsbl_file)
      FSBL_FILE="${2}"
      shift
      shift
      ;;
    -a|--app_file)
      APP_FILE="${2}"
      shift
      shift
      ;;
    -o|--output)
      INSTALL_DIR="${2}"
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



source ${THIS_DIR}/config/config.sh


if [ -e ${WORKSPACE_DIR} ]     ; then rm -rf ${WORKSPACE_DIR}      ; fi
if [ -e ${SCRIPTING_DIR} ]     ; then rm -rf ${SCRIPTING_DIR}      ; fi

mkdir -p ${WORKSPACE_DIR}
mkdir -p ${SCRIPTING_DIR}


SCRIPT=${SCRIPTING_DIR}/run.tcl


printf 'the_ROM_image:\n' >> ${SCRIPT}
printf '{\n' >> ${SCRIPT}
printf '  [bootloader] '${FSBL_FILE}'\n' >> ${SCRIPT}
printf '  '${BIT_FILE}'\n' >> ${SCRIPT}
if [! -z ${APP_FILE+x} ]; then
printf '  '${APP_FILE}'\n' >> ${SCRIPT}
fi
printf '}\n' >> ${SCRIPT}


pushd ${SCRIPTING_DIR}
${VITIS_BOOTGEN_EXE} -arch zynq -image ${SCRIPT} -w on -o ${INSTALL_DIR}/boot.bin
${VITIS_BOOTGEN_EXE} -arch zynq -image ${SCRIPT} -w on -o ${INSTALL_DIR}/boot.mcs
popd


if [ -e ${WORKSPACE_DIR} ]     ; then rm -rf ${WORKSPACE_DIR}      ; fi
if [ -e ${SCRIPTING_DIR} ]     ; then rm -rf ${SCRIPTING_DIR}      ; fi

exit 0
 
