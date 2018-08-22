#!/usr/bin/env bash
#===============================================================================
#
#          FILE: verify_tx2_cuda_install.sh
# 
#         USAGE: ./verify_tx2_cuda_install.sh [-c <CUDA_VERSION>] [-s] [-h]
# 
#   DESCRIPTION: Verifies that nvcc, libcuda, libcudnn (parts of the cuda-toolkit)
#                were correctly installed and can be linked to and found in the
#                PATH.
# 
#       OPTIONS: -c <CUDA_VERSION>: set the CUDA version
#                -s: set the PATH and LD_LIBRARY_PATH environment variables
#                -h: print the usage info
#  REQUIREMENTS: None
#        AUTHOR: Elliott Indiran <eindiran@uchicago.edu>
#===============================================================================

set -o errexit  # Exit on a command failing
set -o errtrace # Exit when a function or subshell has an error
set -o nounset  # Treat unset variables as an error
set -o pipefail # Return error code for first failed command in pipe

CUDA_VERSION=9.0
SET_PATH_FLAG=""

while getopts "hsc" opt; do
    case "$opt" in
        c)
            CUDA_VERSION="${OPTARG}"
            ;;
        s)
            SET_PATH_FLAG=true
            ;;
        h|*)
            echo "Usage: ./verify_tx2_cuda_install.sh [-s] [-h]"
            exit 0
            ;;
    esac
    shift 1
done

if [ -z "$SET_PATH_FLAG" ] ; then
    # if --set-path is not passed, simply perform a check on PATH and LD_LIBRARY_PATH instead
    if [ "$(echo "$PATH" | tr ":" "\n" | grep -c "cuda-$CUDA_VERSION")" -eq 0 ] ; then
        echo "PATH is missing \"cuda-$CUDA_VERSION\""
        exit 1
    elif [ "$(echo "$LD_LIBRARY_PATH" | tr ":" "\n" | grep -c "cuda-$CUDA_VERSION")" -eq 0 ] ; then
        echo "LD_LIBRARY_PATH is missing \"cuda-$CUDA_VERSION\""
        exit 1
    fi
else
    # if --set-path flag is passed, set up the PATH and LD_LIBRARY_PATH env variables
    if [ -z "$PATH" ] ; then
        PATH=/usr/local/cuda-$CUDA_VERSION/bin
    else
        PATH=$PATH:/usr/local/cuda-$CUDA_VERSION/bin
    fi

    if [ -z "$LD_LIBRARY_PATH" ]; then
        LD_LIBRARY_PATH=/usr/local/cuda-$CUDA_VERSION/lib64:/usr/local/cuda-$CUDA_VERSION/lib
    else
        LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-$CUDA_VERSION/lib64:/usr/local/cuda-$CUDA_VERSION/lib
    fi
    export PATH  # export after setup
    export LD_LIBRARY_PATH
fi

# Check for nvcc
if [ "$(nvcc -V 2>/dev/null | wc -l)" -lt 4 ] ; then
    echo "nvcc not found."
    exit 1
fi

# Check for libcuda and related libs
if [ "$(ldconfig -p | grep -c cuda)" -eq 0 ] ; then
    echo "libcuda and related libraries not linked correctly."
    exit 1
fi

# Check for libcudnn
if [ "$(ldconfig -p | grep -c dnn)" -eq 0 ] ; then
    echo "libcudnn libraries not linked correctly."
    exit 1
fi

# Check for /usr/include/cudnn.h
if [ ! -f /usr/include/cudnn.h ] ; then
    echo "/usr/include/cudnn.h not found."
    exit 1
fi

echo "Everything is correctly configured:"
echo "PATH and LD_LIBRARY_PATH are configured correctly and nvcc, libcuda, and libcudnn were found."
exit 0
