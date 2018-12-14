
# W2MHS - Wisconsin White Matter Hyperintensities Segmentation Toolbox
#### Wisconsin Alzheimer’s Disease Research Center, UW-Madison
#### 2018

## About
This document only contains installation and using instructions for GUI users.  
Please refer to [W2MHS](https://github.com/SichaoYang/W2MHS) for more details about the project, source code, and commandline interface.

## Branches
source: Matlab source code for Matlab users.  
[linux](https://github.com/SichaoYang/W2MHS-release/tree/linux): standalone installation guide for Linux users.  
[windows](https://github.com/SichaoYang/W2MHS-release/tree/windows): standalone installation guide for Windows users.  
[macos](https://github.com/SichaoYang/W2MHS-release/tree/macos): standalone installation guide for MacOS users.  

## Installation
You can install and run the toolbox as:
1. MATLAB standalone application + dockerized Python scripts: runnable without MATLAB. Check the corresponding branch for W2MHS standalone and Docker installation instructions.
2. MATLAB source code + dockerized Python scripts: for MATLAB users. Check the corresponding branch for Docker installation instructions.
3. MATLAB source code + Python source code: runnable without Docker but require Python and dependent packages. Please refer to [W2MHS](https://github.com/SichaoYang/W2MHS).
4. All-in-one docker container: only for Linux users. [Install Docker](https://docs.docker.com/install/) and run  
```
sudo docker run -ti --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix -v <path/to/images>:/media sichao/w2mhs:v2018.1
```

## Usage
1. Enter *SPM Toolbox Path*, and *Output Path*, as well as *Output Name*
as the shared prefix of the output folders of all subjects.

2. Add subjects using the "Add T1 and T2 Volumes" button. Remove a subject from the batch by selecting
it and pressing the ”Remove Selected” button.
    
    The add subjects button will allow you to add one subject at a time or select a directory that contains
a batch of T1 and T2 image pairs. To use the directory batch function, the images must follow the naming
convention described in the *BatchSetup.m* script. Each subject must have a unique name or identifier
which is the Subject ID. If you enter one subject at a time make sure to enter this field and make sure
they are all unique. When using the directory batch function make sure that the subjects it imports are
automatically assigned Subject IDs.

3. (Optional) Use *Set Default* on the menu bar to set the default configuration of the GUI. You may
want the GUI to store both the SPM12 and W2MHS toolbox paths. Setting a new default will overwrite
the old configuration. Also, Use *Save* to save sessions to ’.mat’ files and *Load* them later.

4. (Optional) Set the advanced options as explained in *param.m*.

5. Click *Run* to start.
