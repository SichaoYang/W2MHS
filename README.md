
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
- MATLAB standalone application + dockerized Python scripts
    - Recommanded for all first-time users and users who cannot or does not want to run the toolbox on MATLAB. 
    - Requirements:
        - [Docker operating system support](https://docs.docker.com/install/#supported-platforms).
    - Pros:
        - Easy installation and configuration.
        - No MATLAB needed.
    - Cons:
        - MATLAB Runtime may take ~5GB space and some time to download.
    - Download and Installation:
        - [64-bit Linux](https://github.com/SichaoYang/W2MHS-release/tree/linux)
        - [64-bit Windows](https://github.com/SichaoYang/W2MHS-release/tree/windows)
        - [64-bit MacOS](https://github.com/SichaoYang/W2MHS-release/tree/macos)
        - Create an issue or contact [Sichao Yang](mailto:sichao@cs.wisc.edu) to add more installers if this list does not include your environment or an installer does not work on the corresponding operating system.
- MATLAB source code + dockerized Python scripts
    - For MATLAB users.
    - Requirement: 
        - [MATLAB](https://www.mathworks.com/products/matlab.html) with [Image Processing Toolbox](https://www.mathworks.com/products/image.html).
        - [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/).
        - [Docker operating system support](https://docs.docker.com/install/#supported-platforms).
    - Pros:
        - Small.
        - MATLAB scripts can be modified by users.
    - Cons: 
        - Requires MATLAB.
    - Download and Installation:
        1. Install and configure Docker according to instructions for  
            - [64-bit Linux](https://github.com/SichaoYang/W2MHS-release/tree/linux)  
            - [64-bit Windows](https://github.com/SichaoYang/W2MHS-release/tree/windows)  
            - [64-bit MacOS](https://github.com/SichaoYang/W2MHS-release/tree/macos)  
        2. Download and extract this toolbox and [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/).
        3. Open MATLAB **as Administrator/root**, navigate to the toolbox repository and run ```installW2MHS``` in MATLAB prompt.
- MATLAB source code + Python source code:
    - For MATLAB users who cannot or does not want to run Docker containers, maybe for better program performance.
    - Requirement: 
        - [MATLAB](https://www.mathworks.com/products/matlab.html) with [Image Processing Toolbox](https://www.mathworks.com/products/image.html).
        - [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/).
        - A version of [Python](https://www.python.org/) that [supports TensorFlow](https://www.tensorflow.org/install/pip).
    - Pros:
        - Smallest.
        - Fastest.
        - MATLAB and Python scripts can be modified by users.
        - No Docker needed.
    - Cons: 
        - Requires MATLAB.
        - Requires Python and Python configurations.
    - Download and Installation:
        Please refer to another repository [W2MHS](https://github.com/SichaoYang/W2MHS).
- All-in-one docker container
    For Linux Docker users.
    - Requirement:
        - [Docker operating system support](https://docs.docker.com/install/#supported-platforms).
    - Pros:
        - No Installation needed. Runnable after download.
        - No MATLAB needed.
    - Cons: 
        - Big. Needs ~8GB space for the image.
        - Needs to share host display with the container, which is platform-dependent.
    - Download and Installation:
        1. [Install Docker](https://docs.docker.com/install/).
        2. Provide access to X11 by running
            ```xhost +local:root```
        3. Run
            ```
            sudo docker run -ti --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix -v <host/images>:<container/images> sichao/w2mhs:v2018.1
            ```
            where ```-v <host/images>:<container/images>``` shares a directory ```<host/images>``` on your machine that contains the T1, T2 images with the container as a directory ```<container/images>``` inside the dockerized Ubuntu file system available to the GUI application. For multiple image folders, add a parent directory containing all of them, or add multiple ```-v <host/images>:<container/images>``` pairs accordingly.  
            E.g. if you use ```-v ~/Documents/Images:/media```, you will be able find everything under ```~/Documents/Images/``` in your file system as under ```/media/``` in the toolbox.  
            Docker will spend some time downloading the image before the first run.  
            For more information about using GUI with Docker, please refer to
            [Fabio Rehm's Blog](http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/) or 
            [Tutorial by ROS](http://wiki.ros.org/docker/Tutorials/GUI).

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
