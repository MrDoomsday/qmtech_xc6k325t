#!/bin/bash

# Define Vivado path here if needed
VIVADO_PATH=/home/user/Install/Xilinx/Vivado/2021.1/settings64.sh

# Check if Vivado path correct
if [ $VIVADO_PATH ]
then
    echo "Trying to run Vivado from path: $VIVADO_PATH"
    if test -f $VIVADO_PATH
    then
        source $VIVADO_PATH
    fi
fi

# Check if Vivado command in PATH
if ! command -v vivado
then
    echo "Can't find Vivado. Check if it included in PATH or define it in this script."
    exit 1
fi

# Run tcl script in Vivado 
vivado -mode batch -nojournal -log ./vivado.log -source create_vivado_prj.tcl