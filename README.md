
# W2MHS - Wisconsin White Matter Hyperintensities Segmentation Toolbox
#### Wisconsin Alzheimer’s Disease Research Center, UW Madison
#### 2018

## About
W2MHS is an open source toolbox designed for detecting and quantifying White Matter Hyperintensities
(WMH) in Alzheimer’s and aging related neurological disorders. WMHs arise as bright regions on T2-
weighted FLAIR images. They reflect comorbid neural injury or cerebral vascular disease burden. Their
precise detection is of interest in Alzheimer’s disease (AD) with regard to its prognosis. Our toolbox provides
self-sufficient set of tools for segmenting these WMHs reliably and further quantifying their burden for 
down-processing studies. This documentation provides the background on the algorithm and parameters that
comprise W2MHS along with the syntax.

## Package Details
W2MHS is implemented in MATLAB and Python.

The MATLAB scripts use
[Image Processing Toolbox](https://www.mathworks.com/products/image.html), 
[Tools for NIfTI and ANALYZE image](https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image), and
[SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/).
Please go to [MathWorks](http://www.mathworks.com/index.html)
for details about the MATLAB software (installation, support, and licensing). 

To run the Python scripts, please ensure that
Python can be invoked as the ```python``` command from the command-line interpreter
and the required packages
[Matplotlib](https://matplotlib.org/),
[NumPy](http://www.numpy.org/),
[SciPy](https://www.scipy.org/),
[scikit-learn](http://scikit-learn.org/stable/), and
[TensorFlow](https://www.tensorflow.org/)
are present in the python path.

The inputs to the toolbox include a T1 weighted MRI image and a T2 FLAIR image.
Hence W2MHS uses multichannel images to segment WMHs. The several modules of **W2MHS** include:
- *Pre-processing Module*: Pre-processing involves constructing the White Matter (WM) region of inter-
est and partial volume estimates of the tissues (White Matter, Gray Matter, Cerebro Spinal Fluid)
among other things (bias correction, registration etc.). W2MHS uses a popular neuroimaging toolkit
[SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/) for this pre-processing.
- *Segmentation Module*: Segmentation module is the heart of W2MHS.
A Deep Neural Network implemented in [TensorFlow](https://www.tensorflow.org/)
is used to detect the WMHs.
- *Quantification Module*: The purpose of this module is to summarize the WMH segmentations. This is
especially important in down-stream analysis.
- *Visualization Module*: The purpose of this module is to visualize the hyperintense regions. Probability maps are 
converted into a heatmap.

We first walk you through installation of the toolbox, followed by the several ways to interface with it.
Finally there are details on some more advanced features and parameters of W2MHS.

## Installation
First, unpack the toolbox to the MATLAB toolbox folder or a directory of your choice.
The Tools for NIfTI and ANALYZE image are already included in the toolbox, but 
the [Image Processing Toolbox](https://www.mathworks.com/products/image.html) and
[SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/) need to be installed manually.
Then, run ```installW2MHS``` in MATLAB to add the toolbox to the MATLAB path and
check the presence of the dependent files. See the **Contents** section for more details. 

## Usage
### Graphical Interface

Run ```W2MHS``` in MATLAB to open up a GUI window.
To get started check if the W2MHS Toolbox Path is not automatically entered; if not, correct that field.
Next, make sure the path of SPM12b is entered correctly in the "SPM Toolbox Path" field.

You can go to File : Set Default on the menu bar to set the default configuration of the GUI. You may
want the GUI to store both the SPM12b and W2MHS toolbox paths. Setting a new default will overwrite
the old configuration. Note that you can also save sessions to ’.mat’ files and restore them later.

Make sure to enter all fields before running on subjects. Enter a name and output path, then you may
add subjects using the ”Add T1 and T2 Volumes” button. To remove a subject from the batch simply select
it and press the ”Remove Selected” button.

The add subjects button will allow you to add one subject at a time or select a directory that contains
a batch of T1 and T2 image pairs. To use the directory batch function, the images must follow the naming
convention described in the ```BatchSetup.m``` script. Each subject must have a unique name or identifier
which is the Subject ID. If you enter one subject at a time make sure to enter this field and make sure
they are all unique. When using the directory batch function make sure that the subjects it imports are
automatically assigned Subject IDs.

### Main Script Parameters
Syntax of the W2MHS main script for command line usage:

```WhyD_setup(output_name, output_path, input_images, output_ids, w2mhstoolbox_path, spmtoolbox_path, do_train, do_preproc, do_quantify, do_visualize)```
1. output_name : Name for the experiment (takes in only one field)
2. output_path : Path of the directory where the outputs are to be stored (takes in only one field)
3. input_images : Path of the T1 and T2 FLAIR images (.nii files) (number of fields is 2 times the number
of subjects)
4. output_ids : IDs for the subjects (number of fields is the same as the number of subjects)
5. w2mhstoolbox_path : Path of W2MHS
6. spmtoolbox_path : Path of SPM12b
7. do_train : Optional argument for training (default : no)
8. do_preproc : Optional argument for preprocessing (default : yes)
9. do_quantify : Optional argument for quantification (default : yes)
10. do_visualize : Optional argument for visualizing (default : yes)

### Command Line Example
To better understand the syntax and usage of WhyD setup.m, here is an example run. Given he and
T2-FLAIR images from 3 subjects and we want detect and quantify the WMH volume in each. The name
for these experiments is “mystudy”. We want to store all the outputs in “/home/myname/myoutputs”.
We denote the “1”, “2” and “3”. And their T1 and T2-FLAIR .nii image files are at “T1ofsubject1”,
“T2ofsubject1”, “T1ofsubject2”, “T2ofsubject2”, “T1ofsubject3”, “T2ofsubject3” respectively. With this
setup, we then generate a example.m file as follows, and run it:
```
%% function example
clear all; clc; close all;
output_path = {’/home/myname/myoutputs’};
output_name = {’mystudy’};
output_ids = {’1’; ’2’, ’3’};
input_images = {’T1ofsubject1’,’T2ofsubject1’ ; ’T1ofsubject2’,’T2ofsubject2’ ;...
’T1ofsubject3’,‘T2ofsubject3’};
input_meth = {’rf_regress’};
w2mhstoolbox_path = ’/home/.../W2MHS’;
spmtoolbox_path = ’/home/.../spm12b’;
do_train = ’no’; do_preproc = ’no’; do_quantify = ’yes’;
param(.6,2.5,’yes’);
WhyD_setup(output_name, output_path, input_images, output_ids, w2mhstoolbox_path,...
spmtoolbox_path, do_train, do_preproc, do_quantify);
```

The outputs of these experiments are stored in three directories for each of the three subjects with
names “mystudy 1”, “mystudy 2” and “mystudy 3”. Their paths are “/home/myname/myoutputs/mystudy
1”, “/home/myname/myoutputs/mystudy 2” and “/home/myname/myoutputs/mystudy 3” respectively. In
each of these directories the outputs include
final WMH probability maps of WMH detections,
heatmap visualizations,
WMH quantification measures,
preprocessing files like GM, WM and CSF, ventricular maps etc.
Each folder contains a “names_id.mat” file (where “id” is the subject id).
It lists the contents of all the output files.
For example, this mat file for our subject “1” looks something like:
```
       directory_path: '/home/myname/myoutputs/mystudy_1'
          folder_name: 'mystudy'
            folder_id: '1'
         source_bravo: 'BRAVO_1.nii'
         source_flair: 'FLAIR_1.nii'
         pve_flair_c1: 'c1rFLAIR_1.nii'
         pve_flair_c2: 'c2rFLAIR_1.nii'
         pve_flair_c3: 'c3rFLAIR_1.nii'
          flair_coreg: 'rFLAIR_1.nii'
       flair_biascorr: 'mrFLAIR_1.nii'
                 Vent: 'Vent_strip_1.nii'
                GMCSF: 'GMCSF_strip_1.nii'
               WM_mod: 'WM_modstrip_1.nii'
               method: 'DNN Classification'
              seg_out: 'DNN_out_1.nii'
        seg_unrectify: 'DNN_unrectify_1.nii'
             seg_pmap: 'DNN_pmap_1.nii'
         accumulation: 'Quant_1.mat'
              heatmap: 'DNN_heatmap_1.nii'
```
Of particular importance there are the fields "seg_pmap", "heatmap" and a file "Quant_id.mat" which represent
the final WMH image (probability map), the heatmap visualization, and the WMH quantification measures.

To view an output image, run ```view_nii(load_nii('path/to/image.nii'))``` in MATLAB command prompt.

### Batch Script
W2MHS also comes with a batch script for processing a lot of subjects. The GUI has a similar batch
feature but this batch script only requires a directory and it will figure out the rest. There is a particular 
file setup and naming convention that must be followed for any of the W2MHS batch scripts to read
in your inputs. To learn more about the usage of this script read the comments in the ```BatchSetup.m``` script.

### Advanced Options
**Training** We have provided features as well as a learned DNN model with the W2MHS toolbox
but you may use your own features as well. The raw features are not included in the source code download
but may be downloaded separately. They are approximately 1GB. See the examples, ’features training.mat’
paired with ’labels training.mat’ in ’W2MHS/training’ to get a feel for the format of the features we use. Our
current model uses 119,284 feature vectors, half of which are extracted from voxel patches identified as white
matter hyperintensities and half from voxel patches that are not hyperintense. We are currently working on
providing code that will assist our users in creating their own features to train a more individualized DNN model.

**Hyperparameters** Most of the parameters for the detection and preprocessing are set to reasonable values.
Three parameters of importance are “clean_th” (a cleaning threshold parameter) and “pmap_cut” (a
probability map cut value that is used for hyperintensity accumulation) and a “Yes” / “No” option to conserve disk space
(W2MHS will delete extraneous intermittent files throughout processing). Note that this
option will use approximately one fifth of the disk space as the traditional output. To edit the default settings
simply open the ```param.m``` script in the W2MHS source folder and modify the parameters. More details on
what these parameters do are included in the ```param.m``` script.

It is also easy to modify these hyperparameters for individual runs. If you are using the GUI, you will
see the three options at the bottom. Simply modify them to meet your needs. If you are running W2MHS
via the command line, before ```WhyD_setup``` is called you must call ```param```. Specify
the three hyperparameters in the arguments of this function call.
Example: param( 0.6, 2.5 ,'yes');
The first is the "pmap_cut", second is "clean_th", and last is "Conserve Disk Space."
If you do not call this script, the default parameters will be used.

##  Contents
### Scripts
- **WhyD_setup.m** : This is the main setup script. It creates the necessary directories and calls other
internal scripts.
- **WhyD_batch.m** : An internal batch script. Use BatchSetup.m if you want to do a command line
batch automatically.
- **WhyD_preproc.m** : Internal preprocessing script that generates a SPM12 batch processing to coreg-
ister and segment WM, GM and CSF tissues. It also constructs ventricle maps and PV estimates.
- **WhyD_detect.m** : Internal segmentation script that performs the hyperintensity segmentation using the DNN.
- **WhyD_postproc.m** : Internal postprocessing script that cleans up the segmented outputs.
- **WhyD_quant.m** : Internal quantification script that calculates the hyperintensity accumulation (deep,
periventricular, and total).
- **WhyD_visual**: Internal visualization script that converts the p-map output from **WhyD_postproc.m** into a heatmap,
which is then superimposed on the original co-registered image (or another image you choose, specified by variable ```source```),
visualizing the probability of hyperintense regions with the color gradient specified by argument ```colorbar```.
If there is only one subject, the heatmap will be displayed right after generation. 
- **W2MHS_training.py** : Internal Python+TensorFlow training script. This is an optional script that generates a learned DNN model
using a given set of features and labels. In the default setting this script is not used
(a pre-generated model is included in the toolbox). In order to visualize the model performance set
```system(sprintf('python %s/W2MHS_training.py False', w2mhstoolbox_path));``` to
```system(sprintf('python %s/W2MHS_training.py True', w2mhstoolbox_path));``` in **WhyD_setup.m**.
- **W2MHS_testing.py** : Internal Python+TensorFlow testing script called from **Whyd_detect.m**.
It loads the hyperparameters of DNN model saved by **W2MHS_training.py** and
classifies each new instance of the testing set into hyperintense or non-hyperintense voxels.
- **performance_metrics.py**: Optional script used to test the validity of the learned model.
The script can be used to check the performance of the model on new features set.
See the code for usage and **W2MHS_training.py** for an example.
- **getKernels.m, getCenter.m, get_gauss_conv.m** : Internal scripts called by **WhyD detect.m**.
See the paper for details.
- **check_preproc.m**: Internal script called by **WhyD_setup.m** to see if a subject needs preprocessing 
when the user choose not to preprocess the subject.
- **check_training.m** : Internal scripts called by **WhyD_setup.m**, which calls the **check_training.py** module.
- **check_training.py**: Script used to check whether necessary training outputs are present in order to decide 
if the model needs to be trained when the user chooses not to train the model
- **BatchSetup.m** : Easy way to run a batch. Open this script and edit the parameters inside.
- **W2MHS.m** : Opens the GUI interface.
- **installW2MHS.m** : Add the toolbox to the MATLAB path and
check the presence of the dependent files. Setting argument ```install_py``` to ```true```, 
```installW2MHS(true)``` will further check and install the Python dependencies listed in ```requirements.txt```
with [pip](https://pypi.org/project/pip/). If you prefer using the GPU, 
you can install the corresponding version of TensorFlow and modify the Python scripts to import it.
- **params.m** : Contains hyperparameters which may be modified and saved in the W2MHS directory.
### Subdirectories
- **NIFTI_codes** : Folder containing scripts from [Tools for NIfTI and ANALYZE image](https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image).
- **training** : Folder containing training data and the extracted model (TensorFlow checkpoint).
### Files under training directory: training/*
- **options_training.mat**: Internal mat file providing parameters for **WhyD_detect**.
- **checkpoint**, **Training_model.index**, **Training_model.meta**,
**Training_model.data-00000-of-00001**: Optional TensorFlow files storing a DNN trained by **W2MHS_training.py**.
- **features_training.mat**, **labels_training.mat**: Optional mat files containing the training data
needed by **W2MHS_training.py**. Can be downloaded from [NITRC](https://www.nitrc.org/frs/download.php/5548/W2MHS_Source_Code_and_Training_Data.zip).

## Notes
This toolbox was developed on Windows and Linux operating systems, and should work on both.
If you have trouble running W2MHS or if you have other bug reports or feature requests,
post in the help forums on
[NITRC](https://www.nitrc.org/forum/forum.php?forum_id=3854) or 
[SourceForge](https://sourceforge.net/p/w2mhs/discussion/general/)
for further assistance.
