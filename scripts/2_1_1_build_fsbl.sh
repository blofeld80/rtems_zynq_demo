#!/bin/bash
# SPDX-License-Identifier: BSD-2-Clause
# Copyright (C) 2023 B. Moessner


THIS_SCRIPT=$(realpath "$0")
THIS_DIR=$(dirname "${THIS_SCRIPT}")


#################################################
## check the arguments the user has passed
function print_help {
  echo "Please call this script using ./2_1_1_build_fsbl -b <bit_file_name> -x full_path_to_xsa_file -o full_path_to_output_folder"
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
    -x|--xsa_file)
      XSA_FILE="${2}"
      shift
      shift
      ;;
    -b|--bit_file_name)
      BIT_FILE_NAME="${2}"
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

CPU="ps7_cortexa9_0"


SCRIPT=${SCRIPTING_DIR}/run.tcl

printf 'platform create -name FsblPlatform -hw '${XSA_FILE}' -proc '${CPU}' -os standalone -out '${WORKSPACE_DIR}'\n' >>  ${SCRIPT}
printf 'platform write\n' >>  ${SCRIPT}
printf 'platform read '${WORKSPACE_DIR}'/FsblPlatform/platform.spr\n' >>  ${SCRIPT}
printf 'platform active FsblPlatform\n' >>  ${SCRIPT}
printf 'platform generate -domains\n' >>  ${SCRIPT}
printf 'set flags [platform config -extra-compiler-flags fsbl]\n' >>  ${SCRIPT}
printf 'lappend flags "-DFSBL_DEBUG"\n' >>  ${SCRIPT}
printf 'lappend flags "-DFSBL_DEBUG_INFO"\n' >>  ${SCRIPT}
printf 'platform fsbl -extra-compiler-flags ${flags}\n' >>  ${SCRIPT}
printf 'platform generate\n' >> ${SCRIPT}
printf 'exit\n' >> ${SCRIPT}

pushd ${SCRIPTING_DIR}
${VITIS_XSCT_EXE}  ${SCRIPT}
popd


cp ${WORKSPACE_DIR}/FsblPlatform/export/FsblPlatform/sw/FsblPlatform/boot/fsbl.elf ${INSTALL_DIR}
cp ${WORKSPACE_DIR}/FsblPlatform/hw/${BIT_FILE_NAME} ${INSTALL_DIR}


if [ -e ${WORKSPACE_DIR} ]     ; then rm -rf ${WORKSPACE_DIR}      ; fi
if [ -e ${SCRIPTING_DIR} ]     ; then rm -rf ${SCRIPTING_DIR}      ; fi

exit 0