#!/usr/bin/env bash
#===============================================================================
#
#          FILE: install_cuda_tx2.sh
# 
#         USAGE: ./install_cuda_tx2.sh 
# 
#   DESCRIPTION: Install Cuda Toolkit for aarch64 using files from JetPack.
#                Afterwards, run the verify_tx2_cuda_install.sh script.
# 
#       OPTIONS: None
#  REQUIREMENTS: None
#        AUTHOR: Elliott Indiran <eindiran@uchicago.edu>
#===============================================================================

set -o errexit  # Exit on a command failing
set -o errtrace # Exit when a function or subshell has an error
set -o nounset  # Treat unset variables as an error
set -o pipefail # Return error code for first failed command in pipe

# Run the cuda-l4t.sh install script
chmod a+x cuda-l4t.sh
sudo ./cuda-l4t.sh cuda-repo-l4t-9-0-local_9.0.252-1_arm64.deb 9.0 9-0
# Add the CUDA GPG key to apt
sudo apt-key add /var/cuda-repo-9-0-local/7fa2af80.pub
sudo dpkg -i libcudnn7_*
sudo dpkg -i libcudnn7-*
sudo apt install -i
sudo apt autoremove -y
sudo mv nvidia.conf /etc/ld.so.conf.d/
sudo chmod 644 /etc/ld.so.conf.d/nvidia.conf
# Clean up the PATH and LD_LIBRARY_PATH variables in the .bashrc
vim ~/.bashrc
# shellcheck source=/home/nvidia/.bashrc
source ~/.bashrc
./verify_tx2_cuda_install.sh
