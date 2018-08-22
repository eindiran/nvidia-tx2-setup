# Setting up JetPack on an Ubuntu 16.04 VM
This document will describe how to spin up a virtual machine using Virtual Box that is suitable for running JetPack and flashing NVidia Jetson boards, like the TX2.

Traditionally, JetPack requires either an Ubuntu 14.04 or an Ubuntu 16.04 machine to run. This guide will allow you to run JetPack without issues, agnostic of what operating system you are running.

## A quick note about the TX-2
If you are using an older TX-2, powering on the TX-2 may appear to not work. This is okay: the issue is almost certainly a video driver failure, NOT a boot failure, even if the fan doesn't run.
When you run JetPack to upgrade the software on the Jetson, it should get the drivers it needs to display to most monitors. If it still can't display, its time to buy a new monitor.

To see whether you might need to reflash the OS onto the Jetson, it is recommended that you power on the Jetson now and check that you can see your screen.

1. To power on the Jetson, first plug in the keyboard, mouse, and DVI cable leading to the monitor. It may be helpful to use something to aggregate the keyboard and mouse into a single USB cable since there is only one USB slot on the TX-2.

2. In the box that came with the TX-2, there should be a power adapter cable. First plug the cable into the wall, then into your Jetson.

3. The POWER button is the button furthest from the board's edge, and is labeled in very small letters. Press and release the POWER button.

The TX-2 boots very quickly, so almost immediately you should see something on your screen.
If you don't first check that the monitor is looking at the right input, then check that the cable is correctly plugged in.
If it still isn't displaying, it is likely that the Jetson doesn't have the right drivers to power your monitor.
This problem will be fixed later in the installation, so don't worry too much and proceed to the next step.

## Setting up VirtualBox
Go to the VirtualBox site [here](https://www.virtualbox.org/wiki/Downloads) and choose the package for your platform. Download it and follow the steps to get it installed.

Once you are done installing VirtualBox, head back to the VirtualBox site. Immediately below there is a section called "VirtualBox $VERSION Oracle VM VirtualBox Extension Pack".
Click the link in that section to download the extension pack.
Make sure all of you VMs are closed, since the pack wont install if there are any open, then proceed to open the installer.
This pack contains the extension required to setup USB 2.0 and USB 3.0 support for our VMs. Out of the box, VMs in VirtualBox only support USB 1.0.
Follow the instructions and soon the extension pack should be installed. Close and relaunch VirtualBox.

Once you have VirtualBox opened, set up a new Ubuntu Linux VM. From Ubuntu's site, download the 16.04 LTS release, [here](http://releases.ubuntu.com/16.04/). Make sure you grab the correct .iso file for desktops on your architecture.
When making the VM, set the RAM to 2048 bytes, and set the storage to 30 GBs. Use a .vdi format for the digital disk.
Make sure you point the VM to the image of Ubuntu 16.04 you just downloaded. Once you are done spinning up the VM, close down VirtualBox and restart it.

### Resizing your VM
If you decide to be stingy and give your VM too little storage space, rather than spinning up a whole new VM, you can resize the .vdi file.

 - `VBoxManage modifyhd ./$STORAGE_FILENAME.vdi --resize 30000`

The above command will set the .vdi file to 30 GBs.

## Making sure USB support works
Once the machine is created, go to "Settings", click "Ports", then "USB". Change `Enable USB Controller` to `USB 3.0`.

Next, open a shell and add your user to the group `vboxusers`. Either command below should work:

 - `sudo usermod -aG vboxusers $USER`
 - `sudo adduser $USER vboxusers`

You'll need to logout and log in again for this to take effect.

Fire up your VM. In the bottom right of the window, there should be a series of small icons. One of these icons is a little USB cable. Right click the icon. It will bring up a small menu of USB devices. If you want to access the device on the VM, check the line on the menu. If you want to access the device on the host computer, uncheck the line. If you have already plugged in the TX-2, this menu should contain an entree like "NVidia Corp. APX." or "NVidia Corp.".

If you want to set up the VM so it always gains access to the TX-2 when plugged in, which is recommended, you'll need to set up USB filters. As above, click on "Settings", then "Ports", then "USB". Down at the bottom of the window, there should be a section labeled "USB Device Filters". Click the green `+` symbol, to add a filter. In the section of the filter called name, add "NVidia Corp.".

## Setting up JetPack
First, we are going to need a fresh copy of JetPack from the Nvidia website, so go [here](https://developer.nvidia.com/embedded-computing). Click on "Downloads" and select the most recent version of JetPack. This will download a .run file to your downloads directory. When it finishes, open up a shell and run:

 - `chmod a+x JetPack-*.run`

## Running JetPack
Now that the permissions are set correctly, run the following command in the shell:

 - `./JetPack-*.run`

This will launch JetPack's installer. Choose the default install and download directories, whcih should be inside your home directory. Make a note of what they are, so you can find where files are downloaded to later.

Choose the TX-2 on the "Select Development Environment" page, then authenticate as a sudoer. Choose the full installation, check the "Automatically resolve dependency conflicts" box, and click "Next". It will launch a window asking you to agree to a pile of EULAs. Blindly select agree to all of them.

If done this way, you will reflash the OS image onto the TX-2. If you want to do something else, choose custom installation, and remove the "Flash OS Image on Target" package.

### Plugging in the Jetson
At a certain point in the installation, you should be prompted to plug the Jetson into the host machine. If done correctly, you should be able to see a device with the name "Nvidia Corp." by running `lsusb`.

1. Unplug the Jetson from the power source.

2. Plug the micro USB into the Jetson, then plug the USB into the host machine running the VM (which is running JetPack).

3. Reconnect the power to the Jetson.

4. Press and release the POWER button, the button closest to the middle of the board. Then press and hold the RECOVERY FORCE button, to the left of the POWER button; while still holding the RECOVERY FORCE button, press and release the RESET button, all the way to the edge of the board. Wait two full seconds, then release the RECOVERY FORCE button.

5. Now open a shell in the VM and run `lsusb`. You should see a device in the list with the name "NVidia Corp.".

6. Return to the window that prompted you to complete these steps. Press Enter.

This will start the process of flashing the OS. If you were having driver issues before and couldn't see the screen when plugged into your monitor, this is likely to fix the problem for you.

## Issues
If you follow the installer instructions and have no issues with the installation, smile and realize that the rest of this guide no longer applies to you. You're done!

If the installer hangs, there is still hope, but unfortunately you aren't quite done yet.

### Storage problems
One common place to encounter issues is if JetPack runs out of space. This is caused by giving the storage of the VM insufficient space. To fix this issue, shutdown the VM and JetPack and on the host machine resize the .vdi file holding the virtual disk of the VM using the instructions above.

### IP address resolution and SSH issues
The most common issue is that the network and the Jetson aren't playing nice. This is hard to fix in the VM, so the best way around this is to follow the steps below.

You will know that you encountered this problem if during the installation, the console window gets stuck at "Determining IP address of target" or gives you the option to manually input the IP address.

First, try manually entering the IP address. To find it, hop over to the keyboard plugged in to the TX-2 and open a shell. Type in `ip addr | grep "eth0"`. That will print out info related to the ethernet connection to the TX-2. Use the first IP address, labeled 'inet'.

Sometimes, this will work and JetPack will now be able to communicate with the TX-2 over an SSH connection and install the required packages. If not, you will need to install the packages manually.

## Installing the CUDA Toolkit on the TX-2
Don't just start here as allowing JetPack to do the installation is much easier.

First, run the reflash process via JetPack, following the steps all the way through. if you have no trouble with the IP address step, at the end, JetPack will have installed the CUDA Toolkit for you.

However, if you have trouble getting JetPack to recognize the IP address of the TX-2 you are installing onto, at the "Determining the target IP address" step, press Ctrl + c. This will end the installation and bring back up the JetPack installer wizard.

Uncheck "Remove downloaded files". You will need the files that JetPack downloaded for the steps below. Close the wizard.

### Bundling the required files
Make a new directory:

 - `mkdir cuda_files`

Copy over the following files into it:
  1. cuda-repo-l4t-8-0-local_8.0.64-1_arm64.deb
  2. libcudnn5_5.1.10-1+cuda8.0_arm64.deb
  3. libcudnn5-dev_5.1.10-1+cuda8.0_arm64.deb
  4. cuda-l4t.sh

These four files are the only files needed to install CUDA and cuDNN. They can be found in `~/JetPack/jetpack_downloads` (all the .deb files) and in `~/JetPack/_installer` (cuda-l4t.sh). These are the directories you made note of before, when setting the download directories for JetPack. If you downloaded the files to a different location, copy the files from there.

Bundle these files into a .zip file with the contents here:

 - `/atv/2005/src/speechware/tools/tx2-flash/scripts`

Copy the .zip file onto the TX-2. It is a giant pain to do it with the single USB port, so I recommend using Dropbox or a NFS, something that allows you to access the file from the internet without a direct connection to the TX-2.

### Installing
On the TX-2, run the following commands:

 - `mkdir -p ~/cuda-l4t`
 - `mv $BUNDLED_FILES.zip ~/cuda-l4t`
 - `unzip $BUNDLED_FILES.zip`
 - `rm $BUNDLED_FILES.zip`
 - `./install_cuda_tx2.sh`

This will install the CUDA toolkit. In the installer script, you will have your .bashrc file brought up in an editor. This is so you can correct your PATH and LD_LIBRARY_PATH env variables as desired, since the cuda-l4t.sh script will prepend to them.
