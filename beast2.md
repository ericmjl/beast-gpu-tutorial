---
title: Install BEAST and BEAGLE on an AWS GPU instance
author: Terry Jones
date: 2015-10-01 11:16
---

# Quickstart

If you just want to launch an AWS instance with BEAST installed along with
BEAGLE with GPU support, use the EC2 AMI `ami-6f63250a` and launch either a
`g2.2xlarge` (1 GPU, 15GB RAM, $0.65 per hour) or `g2.8xlarge` (4 GPUs,
60GB RAM, $2.60 per hour) instance running Ubuntu 14.04. Each GPU has 1,536
CUDA cores and 4GB of video memory.

Amazon EC2 [instance types](https://aws.amazon.com/ec2/instance-types/) and
[pricing](https://aws.amazon.com/ec2/pricing/).  Note that if you know
you're going to be doing a lot of this, you will find it cheaper to
purchase a reserved instance.

# How I built the EC2 image

I started an AWS `g2.2xlarge` instance running Ubuntu 14.04.  Then connect to it and get started:

```sh
$ ssh -i ~/dark-matter/aws/default.pem -l ubuntu 54.167.43.174  # Your IP address and keypair will be different!
$ sudo apt-get update
$ sudo apt-get upgrade
```

# Install NVIDIA CUDA drivers

I followed instructions
[here](http://tleyden.github.io/blog/2014/10/25/cuda-6-dot-5-on-aws-gpu-instance-running-ubuntu-14-dot-04/)
with slight modifications to get a more recent version (7.5) of CUDA. The
instructions on that page worked fine, but for the record here's what I
did:

```sh
$ sudo apt-get update
$ sudo apt-get install build-essential
$ sudo apt-get install linux-image-extra-virtual
```

Take the "package maintainers version" when asked about the grub update.

Get CUDA:

```sh
$ curl -O -L 'http://developer.download.nvidia.com/compute/cuda/7.5/Prod/local_installers/cuda_7.5.18_linux.run'
```

This gets you version 7.5 of CUDA, which might be out of date by the time
you read this. If you go to the
[NVIDIA CUDA download page](https://developer.nvidia.com/cuda-downloads)
and select your version of Linux etc., you can then copy the link of the
`Download` button and use that instead of the 7.5.18 version mentioned
above.

```sh
# Your version numbers may differ in the following.
$ chmod +x cuda_7.5.18_linux.run
$ mkdir nvidia_installers
$ sudo ./cuda_7.5.10_linux.run -a -extract=`pwd`/nvidia_installers
$ cd nvidia_installers
$ sudo ./NVIDIA-Linux-x86_64-352.39.run
```

Reboot:

```sh
$ sudo reboot
```

Log back into the instance.

```sh
cat <<EOT
blacklist nouveau
blacklist lbm-nouveau
options nouveau modeset=0
alias nouveau off
alias lbm-nouveau off
EOT | sudo tee -a /etc/modprobe.d/blacklist-nouveau.conf
```

Disable the Kernel Nouveau and reboot:

```sh
$ echo options nouveau modeset=0 | sudo tee -a /etc/modprobe.d/nouveau-kms.conf
$ sudo update-initramfs -u
$ sudo reboot
```

Log back into the instance and install Linux source and headers. You can
get your kernel version (and put it into the following) from `uname -r`
(mine was `3.13.0-65`, obviously).

```sh
$ sudo apt-get install linux-source
$ sudo apt-get install linux-headers-3.13.0-65-generic
```

Re-run NVIDIA installer:

```sh
$ cd nvidia_installers
$ sudo ./NVIDIA-Linux-x86_64-352.39.run -a
```

Load the kernel module:

```sh
$ sudo modprobe nvidia
```

Run the CUDA and samples installer:

```sh
$ sudo ./cuda-linux64-rel-7.5.18-19867135.run
$ sudo ./cuda-samples-linux-7.5.18-19867135.run
```

Verify CUDA is correctly installed

```sh
$ cd /usr/local/cuda/samples/1_Utilities/deviceQuery
$ sudo make
$ ./deviceQuery
```

You should see the following (your version number may differ) at the end of
the output:

```
deviceQuery, CUDA Driver = CUDART, CUDA Driver Version = 7.5, CUDA Runtime Version = 7.5, NumDevs = 1, Device0 = GRID K520
Result = PASS
```

# BEAGLE

From the instructions on
[installing BEAGLE on Linux](https://github.com/beagle-dev/beagle-lib/wiki/LinuxInstallInstructions)
page:

```sh
$ sudo apt-get install autoconf automake libtool subversion pkg-config openjdk-6-jdk git openCL-dev
```

Then

```sh
$ git clone --depth=1 https://github.com/beagle-dev/beagle-lib.git
$ cd beagle-lib
$ ./autogen.sh
$ ./configure --prefix=/usr/local --with-opencl=/usr/lib/x86_64-linux-gnu
$ sudo make install
```

# Java 8

From [this page](http://tecadmin.net/install-oracle-java-8-jdk-8-ubuntu-via-ppa):

```sh
$ sudo add-apt-repository ppa:webupd8team/java
$ sudo apt-get update
$ sudo apt-get install oracle-java8-installer
```

# BEAST

You might want to get a more recent version than the one below:

```sh
$ cd
$ curl -O -L 'https://github.com/CompEvol/beast2/releases/download/v2.3.1/BEAST.v2.3.1.Linux.tgz'
$ cd /usr/local
$ sudo tar xfz ~/BEAST.v2.3.1.Linux.tgz
```

See what BEAGLE resources BEAST thinks it has available

```sh
$ /usr/local/beast/bin/beast -beagle_info
```

If all has worked, the output of the last command above will look roughly like

```
BEAGLE resources available:
0 : CPU
    Flags: PRECISION_SINGLE PRECISION_DOUBLE COMPUTATION_SYNCH EIGEN_REAL EIGEN_COMPLEX SCALING_MANUAL SCALING_AUTO SCALING_ALWAYS SCALERS_RAW SCALERS_LOG VECTOR_SSE VECTOR_NONE THREADING_NONE PROCESSOR_CPU FRAMEWORK_CPU


1 : GRID K520
    Global memory (MB): 4096
    Clock speed (Ghz): 0.80
    Number of cores: 1536
    Flags: PRECISION_SINGLE PRECISION_DOUBLE COMPUTATION_SYNCH EIGEN_REAL EIGEN_COMPLEX SCALING_MANUAL SCALING_AUTO SCALING_ALWAYS SCALERS_RAW SCALERS_LOG VECTOR_NONE THREADING_NONE PROCESSOR_GPU FRAMEWORK_CUDA


2 : GRID K520 (OpenCL 1.2 CUDA)
    Global memory (MB): 4095
    Clock speed (Ghz): 0.80
    Number of multiprocessors: 8
    Flags: PRECISION_SINGLE PRECISION_DOUBLE COMPUTATION_SYNCH EIGEN_REAL EIGEN_COMPLEX SCALING_MANUAL SCALING_AUTO SCALING_ALWAYS SCALERS_RAW SCALERS_LOG VECTOR_NONE THREADING_NONE PROCESSOR_GPU FRAMEWORK_OPENCL
```

## Testing BEAGLE

```sh
$ cd ~/beagle-lib
$ make check
```

# Make an EC2 image

On the AWS control panel for EC2, select the instance you did the above
on. In the "Actions" menu you can select Image / Create Image. As mentioned
above, the image I created is `ami-6f63250a`.
