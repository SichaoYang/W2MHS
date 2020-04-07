# W2MHS - Wisconsin White Matter Hyperintensities Segmentation Toolbox
#### Wisconsin Alzheimer’s Disease Research Center, UW-Madison

## About
W2MHS is an open source toolbox designed for detecting and quantifying White Matter Hyperintensities (WMH) in Alzheimer’s and aging-related neurological disorders. WMHs arise as bright regions on T2- weighted FLAIR images. They reflect comorbid neural injury or cerebral vascular disease burden. Their precise detection is of interest in Alzheimer’s disease (AD) with regard to its prognosis. Our toolbox provides a self-sufficient set of tools for segmenting these WMHs reliably and further quantifying their burden for down-processing studies. This documentation provides the background on the algorithm and parameters that comprise W2MHS along with the syntax.

## Installation
- Upgrade MATLAB to R2019a or later.
- Install [Image Processing Toolbox](https://www.mathworks.com/products/image.html).
- Download [SPM12](https://www.fil.ion.ucl.ac.uk/SPM/software/SPM12/).
- (Optional) Download [W2MHS_Sample_Images](https://www.nitrc.org/frs/download.php/6325/W2MHS_Sample_Images.tar.gz).
- Open the W2MHS folder in MATLAB and run ```w2mhs``` (Alternatively, ```w2mhs.mlapp``` can be executed directly without opening the main program of MATLAB, but without a command window to display messages either).

## Execution
Procedures:  
1. Configure execution options on the ```Options``` tab.  
2. Configure output options on the ```Outputs``` tab.  
3. Add images and run the analysis on the ```Main``` tab.  
4. (Optional) Use tools on the ```Visuals``` tab to visualize output images.  
5. (Optional) Save current settings to a file and load it back later.

### Options
Once you modify an option, its helper will be displayed on the bottom right of the ```Options``` tab.
- **Input Image Type Identifiers**  
	Each subject needs a pair of T1 and T2 images, whose filenames differ only by the image type identifier:  
		T1: ```<pre>brav<suf>.nii```  
		T2: ```<pre>flair<suf>.nii```  
	```<pre><suf>``` is used as a unique, case-insensitive subject id to match the two images. Different subjects should have different ids. Leading, trailing, and duplicate underlines are removed.
- **Preprocessing switch**
	- **Yes**: Every subject will be preprocessed.
	- **No**: Previous preprocessing output will be used if spotted in the output folder.
- **Visualization switch**
	- **Yes**: Once a subject finishes, two NIfTI image visualizers will pop up: one with an overlaying WMH (both deep and periventricular) heatmap and the other without, sharing their crosshair control. Not recommended when running a batch of jobs.
	- **No**: Visualization can be conducted later using the visualization tools in the visuals tab.
- **Hyperparameters**:
	- **Classification Batch Size**: The number of voxels classified together in one iteration. A larger batch size enhances performance at the cost of higher memory consumption. Recommended value: 2048 * available memory in GB (e.g. 4096 if 2GB memory is available).
	- **Probability Map Cutoff**: The denoising threshold voxels classified as WMH with confidence below which will be excluded.
	- **Gray Matter Cleaning Distance**: The distance voxels classified as WMH within which from the gray matter surface will be excluded.
	- **Periventricular Region Width**: The number of voxels the ventricular template is dilated by.
	
### Outputs
See the ```Ouptuts``` tab or ```names.xls``` for the description of all output files. ```Filename``` can be customized. Uncheck the ```Keep``` checkbox of unneeded outputs to save disk space.

### Main
- **SPM12 Path**: Path to the root folder of SPM. If empty by default, the toolbox will search MATLAB search path for the first path ending with ```SPM12```.
- **Output Path**: Path to all output files. The output files of each subject will be under a subfolder named after its id.
- **Add Images**: Add input images through [uipickfiles](https://www.mathworks.com/matlabcentral/fileexchange/10867-uipickfiles-uigetfile-on-steroids). Navigate to destination directories, select images or directories on the left panel, click ```Add→``` to add them to the right panel, add files in other directories in the same way, and click ```Done```. If a directory is added, all NIfTI images under it and its subfolders will be added recursively. Added images will be listed in the list box below.
- **Remove**: Remove the image selected in the list box below.
- **Clear**: Remove all added images.
- **Move Up/Down**: Switch the selected image with the image above/below it.
- **Run**: The subject will be processed in sequence. Each subject undergoes four modules: preprocessing, segmentation, quantification, and visualization.

### Modules
- **Preprocessing**: SPM coregisters the T2 image to the T1 image and segments WM, GM, and CSF PVEs. Then a ventricular template is created using geometrical methods and dilated by ```Periventricular Region Width```.
- **Classification**: Voxels are grouped into batches of ```Classification Batch Size``` and convolved with 16 kernels. A neural network pre-trained on human-labeled data predicts WMH probability of each voxel from the convolutions. *TODO: discard the kernels and train a 3D MASK RCNN directly from the labeled images.*
- **Quantification**: The estimated volume of WM (EV), deep WM (dEV), and periventricular WM (pEV) are calculated based on the predicted probability map and the total intracranial volume (ICV) of the subject. The predictions within ```Gray Matter Cleaning Distance``` and below ```Probability Map Cutoff``` are excluded. There are two ways of categorizing dEV and pEV:
	- The hard way (cut): all WMH voxels within the dilated ventricular template is considered periventricular.
	- The soft way (conn): all WMH areas connected to the dilated ventricular template is considered periventricular.
	
### Visualization
The NIfTI images saved by [Tools for NIfTI and ANALYZE image](https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image) can have an offset when visualized in other software (e.g. AFNI). Therefore, a visualization module is embedded in W2MHS.
- **Quick NIfTI Image Viewer & Path Generator**: Input a subject id and select the name of an image that is checked to be kept. Click ```Gen & Copy``` to generate the full path of the corresponding image file, which is automatically copied to the clipboard. Click ```View``` to view the image.
- **Advanced NIfTI Image Viewer**: Select ```Underlay``` and ```Overlay``` images and click ```View```. A human-readable visualization of the classification result superimposing the overlay (e.g. the probability map, ```pmap```) over the underlay (e.g. the coregistered, bias-corrected input image, ```bias_corr```) will pop up. When ```Show Underlay in A Separate Window``` is checked, another window visualizing only underlay will pop up for reference. Crosshair coordinates are shared across the two windows.

### Settings File
- **Save Settings**: Save current settings on the ```Main```, ```Options```, and ```Outputs``` tabs to an external ```.mat``` file.
- **Open Settings**: Load settings from an external ```.mat``` file.
- **Set as Default**: Save current settings on the ```Main```, ```Options```, and ```Outputs``` to be the default settings when W2MHS reopens. Default settings are saved to ```default.mat``` under the W2MHS directory.
- **Reset to Default**: Load default settings.
- **Save Before Exit**: Click to check or uncheck. If checked, the settings right before W2MHS closes will be set as the default settings and thus be recoverable.  
