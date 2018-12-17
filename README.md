
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

## Installation and Running
We currently provide four options for installing and running the W2MHS toolbox.
1. **MATLAB standalone application + dockerized Python scripts**
    - Recommanded for all first-time users and users who cannot or does not want to run the toolbox on MATLAB. 
    - Requirements:
        - [Docker operating system support](https://docs.docker.com/install/#supported-platforms).
    - Pros:
        - Easy installation and configuration.
        - No MATLAB needed.
    - Cons:
        - MATLAB Runtime may take ~5GB space and some time to download.
    - Download, Install and Run:
        - [64-bit Linux](https://github.com/SichaoYang/W2MHS-release/tree/linux)
        - [64-bit Windows](https://github.com/SichaoYang/W2MHS-release/tree/windows)
        - [64-bit MacOS](https://github.com/SichaoYang/W2MHS-release/tree/macos)
        - Create an issue or contact [Sichao Yang](mailto:sichao@cs.wisc.edu) to add more installers if this list does not include your environment or an installer does not work on the corresponding operating system.
2. **MATLAB source code + dockerized Python scripts**
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
    - Download, Install and Run:
        1. Install and configure Docker according to instructions for  
            - [64-bit Linux](https://github.com/SichaoYang/W2MHS-release/tree/linux)  
            - [64-bit Windows](https://github.com/SichaoYang/W2MHS-release/tree/windows)  
            - [64-bit MacOS](https://github.com/SichaoYang/W2MHS-release/tree/macos)  
        2. Download and extract this toolbox and [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/).
        3. Open MATLAB **as Administrator/root**, navigate to the toolbox repository and run ```installW2MHS``` in MATLAB prompt.
        4. To run the toolbox, open MATLAB **as Administrator/root** and run ```W2MHS``` in MATLAB prompt.
3. **MATLAB source code + Python source code**
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
    - Download, Install and Run:
        Please refer to another repository [W2MHS](https://github.com/SichaoYang/W2MHS).
4. **All-in-one docker container**
    For Linux Docker users.
    - Requirement:
        - [Docker operating system support](https://docs.docker.com/install/#supported-platforms).
    - Pros:
        - No Installation needed. Runnable after download.
        - No MATLAB needed.
    - Cons: 
        - Big. Needs ~8GB space for the image.
        - Needs to share host display with the container, which is platform-dependent.
    - Download, Install and Run:
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

## GUI Explanation
- **Menu Bar -- File**
    - **Load** -- Load a configuration of the GUI to a '.mat' file.  
    - **Save** -- Save the current configuration of the GUI to a '.mat' file.  
    - **Reset** -- Reset the current configuration of the GUI to the default configuration.  
    - **Set Default** -- Save the current configuration of the GUI to 'default.mat' under the root directory of the toolbox as the default configuration.
    - **Close** -- Close the toolbox.
- **Panel -- Mandatory Arguments**
    - **Output Name** -- The shared prefix of the output folders of all subjects.
    - **Output Path** -- The path to contain the output folders.
    - **Add T1 and T2 Volumes**
        - **Single Subject** -- Add the T1 and T2 image of a subject and give the subject a unique ID.
        - **Directory** -- Add all pairs of T1 and T2 images under a directory following the naming conventions (not case sensitive):  
        ```
        <batch name><unique id><bravo|flair>.nii
        <batch name>_<unique id>_<bravo|flair>.nii
        ```  
        where *<batch name>* is supposed to be the same for all subjects in the folder, *<unique id>* must be unique for each subject and must begin with an integer, and the string 'bravo' or 'flair' must present after *<unique id>*. 
    - **Remove Selected** -- Remove the selected the subject.
    - **Move Up/Move Down** -- Change the order of the subjects.
    - **SPM Toolbox Path** -- The root directory of SPM12. This field is automatically filled in for standalone users.
- **Panel -- Options**
    - **Do Training** -- Choose 'Yes' to retrain the model. To train a new model on your data, refer to the original paper and contact the authors for help on creating your *features_training.mat* and *labels_training.mat*. Put them in the *training* folder under the toolbox directory.
    - **Do Preprocessing** -- Choose 'No' to skip preprocessing of the subjects that are preprocessed earlier and have all the preprocessing outputs in the same output folder.
    - **Do Quantification** -- Choose 'Yes' to calculate and save accumulation measures of subject *<id>* to *Quant_<id>.mat* in the output folder.
    - **Do Visualization** -- Choose 'Yes' to display the heatmap. If 'No' is chosen, the user can still view the heatmap of subject *<id>* later by running ```view_nii(load_nii('DNN_heatmap_<id>.nii'))``` or by superimposing *DNN_pmap_<id>.nii* on any source image in the output using thrid party software, such as afni.
    - **Fold Size** -- The number of voxels detected together. A larger fold size accelerates the detetion at the expense of a higher memory consumption. Suggested default: 5000.
    - **Cleaning Threshold** -- A distance measure. Any hyperintensities within this distance from the gray matter surface will be removed during postprocessing. Suggested default: 2.5.
    - **Probability Map Cut Value** -- The cutoff for deciding which voxels to include in the final quantification. All voxels with a probability below this threshold will be ignored when quantifying. Suggested default: 0.5.
    - **Conserve Disk Space** -- If you want to conserve disk space set this option to 'yes'. The preprocessing module will delete extraneous and intermittent .nii files when they are no longer needed. The only downside is that you will need to preprocess the subjects again the next time you segment hyperintensities. Suggested default: 'No'.
