#!/bin/bash
#SPDX-License-Identifier: BSD-2-Clause
#Copyright (C) 2023 B. Moessner

THIS_SCRIPT=$(realpath "$0")
THIS_DIR=$(dirname "${THIS_SCRIPT}")

#################################################
## check the arguments the user has passed
function print_help {
  echo "Please call this script using ./2_1_0_build_hardware -b board_name"
  echo "where board_name is one of:"
  echo "  Pynq-Z1"
  echo "  Pynq-Z2"
  echo "  Picozed-7010"
  echo "  Picozed-7015"
  echo "  Picozed-7020"
  echo "  Picozed-7030"
  echo "  Microzed-7010"
  echo "  Microzed-7020"
  echo "  Zybo"
  echo "  Zybo-Z7-10"
  echo "  Zybo-Z7-20"
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
      TARGET_BOARD="${2}"
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
case ${TARGET_BOARD} in

  Pynq-Z1)
    ZYNQ_BOARD=Pynq-Z1
    ;;
  Pynq-Z2)
    ZYNQ_BOARD=Pynq-Z2
    ;;
  Picozed-7010)
    ZYNQ_BOARD=pz7010_fmc2
    ;;
  Picozed-7015)
    ZYNQ_BOARD=pz7015_fmc2
    ;;
  Picozed-7020)
    ZYNQ_BOARD=pz7020_fmc2
    ;;
  Picozed-7030)
    ZYNQ_BOARD=pz7030_fmc2
    ;;
  Microzed-7010)
    ZYNQ_BOARD=mz7010_som
    ;;
  Microzed-7020)
    ZYNQ_BOARD=mz7020_som
    ;;
  Zybo)
    ZYNQ_BOARD=system_wrapper
    ;;
  Zybo-Z7-10)
    ZYNQ_BOARD=system_wrapper
    ;;
  Zybo-Z7-20)
    ZYNQ_BOARD=system_wrapper
    ;;
  *)
    print_error "Unknown board ${TARGET_BOARD}"
    exit 1
    ;;
esac

echo "Builing for board: ${TARGET_BOARD}"

# Read the configuration
source ${THIS_DIR}/config/config.sh


HW_SRC_DIR=${TOP_SOURCE_DIR}/hw
HW_INSTALL_DIR=${TOP_INSTALL_DIR}/hw

if [ ! -d "${HW_SRC_DIR}" ]     ; then  mkdir -p ${HW_SRC_DIR}     ; fi
if [ ! -d "${HW_INSTALL_DIR}" ] ; then  mkdir -p ${HW_INSTALL_DIR} ; fi

BOARD_SRC_DIR=${HW_SRC_DIR}/${TARGET_BOARD}
BOARD_INSTALL_DIR=${HW_INSTALL_DIR}/${TARGET_BOARD}

if [ -d "${BOARD_SRC_DIR}" ]     ; then rm -rf ${BOARD_SRC_DIR}     ; fi
if [ -d "${BOARD_INSTALL_DIR}" ] ; then rm -rf ${BOARD_INSTALL_DIR} ; fi

#################################################
## Build PYNQ Boards
if [[ "$TARGET_BOARD" == "Pynq-Z1" || "$TARGET_BOARD" == "Pynq-Z2" ]]; then

  XSA_NAME=base.xsa
  BIT_NAME=base.bit
  XSA_FILE=${BOARD_INSTALL_DIR}/${XSA_NAME}
  BIT_FILE=${BOARD_INSTALL_DIR}/${BIT_NAME}


  git_clone_branch "PYNQ"  ${PYNQ_GIT_REPO} ${PYNQ_VER_COMMIT} ${BOARD_SRC_DIR} 
  sed -i "s/set scripts_vivado_version 2022.1/set scripts_vivado_version ${XILINX_VIVADO_VERSION}/g" ${BOARD_SRC_DIR}/boards/${ZYNQ_BOARD}/base/base.tcl
  pushd ${BOARD_SRC_DIR}/boards/${ZYNQ_BOARD}/base
  PATH=${PATH}:${VIVADO_PATH}
  make

  mkdir -p ${BOARD_INSTALL_DIR} 
  cp ${XSA_NAME} ${BOARD_INSTALL_DIR}
  popd
fi

#################################################
## Build Avnet Boards
if [[ "$TARGET_BOARD" == "Picozed-7010" ]] || [[ "$TARGET_BOARD" == "Picozed-7015" ]] || [[ "$TARGET_BOARD" == "Picozed-7020" ]] || [[ "$TARGET_BOARD" == "Picozed-7030" ]] || [[ "$TARGET_BOARD" == "Microzed-7010" ]] || [[ "$TARGET_BOARD" == "Microzed-7020" ]]; then

  if [ ! -d "${BOARD_SRC_DIR}" ] ; then  mkdir -p ${BOARD_SRC_DIR} ; fi

  XSA_NAME=${ZYNQ_BOARD}_base.xsa
  BIT_NAME=${ZYNQ_BOARD}_base.bit
  XSA_FILE=${BOARD_INSTALL_DIR}/${XSA_NAME}
  BIT_FILE=${BOARD_INSTALL_DIR}/${BIT_NAME}

  git_clone_branch "Avnet BDF Repo"  ${AVNET_BDF_GIT_REPO} ${AVNET_BDF_VER_COMMIT} ${BOARD_SRC_DIR}/bdf
  git_clone_branch "Avnet HDL Repo"  ${AVNET_HDL_GIT_REPO} ${AVNET_HDL_VER_COMMIT} ${BOARD_SRC_DIR}/hdl
  pushd ${BOARD_SRC_DIR}/hdl/scripts

  # do not create a project folder which includes the vivado version to make the copy process more easy
  sed -i 's/${board}_${project}_${vivado_ver}/${board}_${project}/g' ${BOARD_SRC_DIR}/hdl/scripts/make.tcl 

  ${VIVADO_EXE} -mode batch -source make.tcl -tclargs board=${ZYNQ_BOARD} project=base sdk=no close_project=yes dev_arch=zynq
  popd

  pushd ${BOARD_SRC_DIR}/hdl/projects/${ZYNQ_BOARD}_base
  mkdir -p ${BOARD_INSTALL_DIR} 
  cp ${XSA_NAME} ${BOARD_INSTALL_DIR}
  popd
fi

#################################################
## Build Digilent Boards
if [[ "$TARGET_BOARD" == "Zybo-Z7-10" ]] || [[ "$TARGET_BOARD" == "Zybo-Z7-20" ]] || [[ "$TARGET_BOARD" == "Zybo" ]] ; then

  if [[ "$TARGET_BOARD" == "Zybo-Z7-10" ]] || [[ "$TARGET_BOARD" == "Zybo-Z7-20" ]] ; then

    if [[ "$TARGET_BOARD" == "Zybo-Z7-10" ]] ; then
      COMMIT=${DIGILENT_ZYBO_Z7_10_VER_COMMIT}
    else
      COMMIT=${DIGILENT_ZYBO_Z7_20_VER_COMMIT}
    fi 

    XSA_NAME=${ZYNQ_BOARD}.xsa
    BIT_NAME=${ZYNQ_BOARD}.bit
    XSA_FILE=${BOARD_INSTALL_DIR}/${XSA_NAME}
    BIT_FILE=${BOARD_INSTALL_DIR}/${BIT_NAME}

    git_clone_commit "Digilent BDF Repo"  ${DIGILENT_BDF_GIT_REPO} ${DIGILENT_BDF_VER_COMMIT} ${BOARD_SRC_DIR}/bdf
    git_clone_commit "Digilent HW Repo"  ${DIGILENT_ZYBO_GIT_REPO} ${COMMIT} ${BOARD_SRC_DIR}/hdl
    
    pushd ${BOARD_SRC_DIR}/hdl
    git submodule update --init --recursive
    # update to the latest board revision
    sed -i "s/digilentinc.com:zybo-z7-10:part0:1.1/digilentinc.com:zybo-z7-10:part0:1.2/g" project_info.tcl
    sed -i "s/digilentinc.com:zybo-z7-20:part0:1.1/digilentinc.com:zybo-z7-20:part0:1.2/g" project_info.tcl

    pushd ${BOARD_SRC_DIR}/hdl/scripts
    # usually one would install the board files in /opt/Xilinx/Vivado/2021.2/data/boards/board_files, 
    #but that would require sudo. Therefore, we simply add the path to the project script
    echo "set_param board.RepoPaths ${BOARD_SRC_DIR}/bdf/new/board_files" > checkout2.tcl
    cat checkout.tcl >> checkout2.tcl
    N=$(nproc)
    sed -i "s/launch_runs -to_step write_bitstream impl_1/launch_runs -to_step write_bitstream impl_1 -jobs ${N}/g" checkout2.tcl

    ${VIVADO_EXE} -mode batch -source checkout2.tcl -tclargs -b -v ${XILINX_VIVADO_VERSION}
    popd
    popd
    pushd ${BOARD_SRC_DIR}/hdl/hw_handoff
    mkdir -p ${BOARD_INSTALL_DIR} 
    cp ${XSA_NAME} ${BOARD_INSTALL_DIR}
    popd

  else

    # Yep, a horrible demo design. Letś try to fix the worst mistakes
    XSA_NAME=${ZYNQ_BOARD}.xsa
    BIT_NAME=${ZYNQ_BOARD}.bit
    XSA_FILE=${BOARD_INSTALL_DIR}/${XSA_NAME}
    BIT_FILE=${BOARD_INSTALL_DIR}/${BIT_NAME}
    mkdir -p ${BOARD_INSTALL_DIR} 

    if [ ! -d "${BOARD_SRC_DIR}" ] ; then  mkdir -p ${BOARD_SRC_DIR} ; fi
    if [ -e ${SCRIPTING_DIR} ]     ; then rm -rf ${SCRIPTING_DIR}      ; fi

    pushd ${BOARD_SRC_DIR}

    wget ${DIGILENT_ZYBO_DESIGN_URL} -P ${BOARD_SRC_DIR}
    unzip ${DIGILENT_ZYBO_DESIGN_ZIP}
    mkdir -p ${SCRIPTING_DIR}

    SCRIPT=${SCRIPTING_DIR}/run.tcl
    PROJ_NAME=zybo_bsd
    PROJ_PATH=${BOARD_SRC_DIR}/${DIGILENT_ZYBO_DESIGN}/source/vivado/hw/${PROJ_NAME}
    PROJ_FILE=${PROJ_PATH}/${PROJ_NAME}.xpr
    N=$(nproc)
    
    sed -i "s/btns_4bits_tri_i/BTNs_4Bits_tri_i/g" ${PROJ_PATH}/${PROJ_NAME}.srcs/constrs_1/new/base.xdc
    sed -i "s/leds_4bits_tri_o/LEDs_4Bits_tri_o/g" ${PROJ_PATH}/${PROJ_NAME}.srcs/constrs_1/new/base.xdc
    sed -i "s/sws_4bits_tri_i/SWs_4Bits_tri_i/g" ${PROJ_PATH}/${PROJ_NAME}.srcs/constrs_1/new/base.xdc
    sed -i "s/iic_0_scl_io/IIC_0_scl_io/g" ${PROJ_PATH}/${PROJ_NAME}.srcs/constrs_1/new/base.xdc
    sed -i "s/iic_0_sda_io/IIC_0_sda_io/g" ${PROJ_PATH}/${PROJ_NAME}.srcs/constrs_1/new/base.xdc


    printf 'open_project '${PROJ_FILE}'\n' >>  ${SCRIPT}
    printf 'upgrade_project -migrate_output_products\n' >>  ${SCRIPT}
    printf 'report_ip_status -name ip_status\n' >>  ${SCRIPT}
    printf 'update_compile_order -fileset sources_1\n' >>  ${SCRIPT}
    printf 'upgrade_ip [get_ips  {system_ground_0 system_processing_system7_0_0 system_LEDs_4Bits_1 system_vdd_1 system_xlconstant_0_2 system_axi_vdma_1_1 system_processing_system7_0_axi_periph_2 system_SWs_4Bits_2 system_axi_protocol_converter_0_0 system_axi_vdma_0_0 system_BTNs_4Bits_0 system_axi_mem_intercon_0}] -log ip_upgrade.log\n' >>  ${SCRIPT}
    printf 'export_ip_user_files -of_objects [get_ips {system_ground_0 system_processing_system7_0_0 system_LEDs_4Bits_1 system_vdd_1 system_xlconstant_0_2 system_axi_vdma_1_1 system_processing_system7_0_axi_periph_2 system_SWs_4Bits_2 system_axi_protocol_converter_0_0 system_axi_vdma_0_0 system_BTNs_4Bits_0 system_axi_mem_intercon_0}] -no_script -sync -force -quiet\n' >>  ${SCRIPT}
    printf 'generate_target all [get_files  '${PROJ_PATH}'/'${PROJ_NAME}'.srcs/sources_1/bd/system/system.bd]\n' >>  ${SCRIPT}
    printf 'export_ip_user_files -of_objects [get_files '${PROJ_PATH}'/'${PROJ_NAME}'.srcs/sources_1/bd/system/system.bd] -no_script -sync -force -quiet\n' >>  ${SCRIPT}
    printf 'export_simulation -of_objects [get_files '${PROJ_PATH}'/'${PROJ_NAME}'.srcs/sources_1/bd/system/system.bd] -directory '${PROJ_PATH}'/'${PROJ_NAME}'.ip_user_files/sim_scripts -ip_user_files_dir '${PROJ_PATH}'/'${PROJ_NAME}'.ip_user_files -ipstatic_source_dir '${PROJ_PATH}'/'${PROJ_NAME}'.ip_user_files/ipstatic -lib_map_path [list {modelsim='${PROJ_PATH}'/'${PROJ_NAME}'.cache/compile_simlib/modelsim} {questa='${PROJ_PATH}'/'${PROJ_NAME}'.cache/compile_simlib/questa} {xcelium='${PROJ_PATH}'/'${PROJ_NAME}'.cache/compile_simlib/xcelium} {vcs='${PROJ_PATH}'/'${PROJ_NAME}'.cache/compile_simlib/vcs} {riviera='${PROJ_PATH}'/'${PROJ_NAME}'.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet\n' >>  ${SCRIPT}
   
    printf 'launch_runs impl_1 -to_step write_bitstream -jobs '${N}'\n' >>  ${SCRIPT}
    printf 'wait_on_run impl_1\n' >>  ${SCRIPT}
    printf 'open_run impl_1\n' >>  ${SCRIPT}
    printf 'write_hw_platform -fixed -file '${XSA_FILE}' -include_bit -force\n' >>  ${SCRIPT}
    printf 'validate_hw_platform '${XSA_FILE}' -verbose\n' >>  ${SCRIPT}
    printf 'close_design\n' >>  ${SCRIPT}
    printf 'exit\n' >> ${SCRIPT}
    pushd ${SCRIPTING_DIR}
    ${VIVADO_EXE} -mode batch -source ${SCRIPT}
    popd
    popd

    if [ -e ${SCRIPTING_DIR} ]     ; then rm -rf ${SCRIPTING_DIR}      ; fi
  fi
fi

#################################################
## Create Bootloader
FSBL_ELF=${BOARD_INSTALL_DIR}/fsbl.elf
${THIS_DIR}/2_1_1_build_fsbl.sh -x ${XSA_FILE} -b ${BIT_NAME} -o ${BOARD_INSTALL_DIR}

#################################################
## Create bootimage containing only first stage loader and bitstream
${THIS_DIR}/2_1_2_build_boot_file.sh -b ${BIT_FILE} -f ${FSBL_ELF} -o ${BOARD_INSTALL_DIR}

#return 0 
