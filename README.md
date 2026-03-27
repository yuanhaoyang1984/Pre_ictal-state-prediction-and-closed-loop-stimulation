 This repository is for the publication and peer-review. edited by Haoyang(Andrew) Yuan(yuana@crick.ac.uk/yuanhaoyang1984@gmail.com) in Han&Lu Lab(Fenghan169@njmu.edu.cn)
 
 The main code is for closed-loop stimulation of epileptic mice based on Labchart recording system.
 
 Besides the packages we uploaded, the repository needs another package named PACmeg to run. Here is the link for the package(https://github.com/neurofractal/PACmeg).
 
Pre-ictal state detection 

  We provide example demos and expected outputs in the demo folder.
  To run the code, execute the relevant script and select the demo folder within the repository. This will generate a model along with prediction and decoding accuracy results.

Closed-loop stimulation system

  I.Background information 
  
  1.1 Purpose
  
  Writing a detailed design specification is an essential part of the software application development process. It primarily provides developers with a concrete design plan and implementation approach for the software, giving users a general understanding of the functionality being developed. It also promotes standardization in software engineering, ensuring that designers follow a unified set of writing conventions for detailed design documents. This saves documentation time, reduces the risks of software implementation, and ensures that software design materials are both standardized and comprehensive — facilitating software implementation, testing, maintenance, and version upgrades.
  
  1.2 Background
  
  Closed-loop stimulation involves real-time automatic adjustment of interventions based on changes in biomarkers through data processing algorithms. Specifically, after an intervention is applied, feedback is recorded and used to adjust the parameters of the next intervention before triggering it, thereby establishing a feedback-stimulation loop that enables simultaneous monitoring and intervention through automated precision control. Closed-loop neuromodulation can adjust stimulation parameters in real time based on an individual's physiological state, achieving optimal regulatory effects while reducing side effects. Bioelectrical signals (EEG/ECG), as important indicators of life monitoring, are frequently used as biomarkers for precision control. By applying data analysis methods such as machine learning, distribution testing, correlation analysis, and time-frequency analysis to automatically recognize EEG/ECG signals with specific characteristics and implement effective interventions, research efficiency and outcomes can be significantly improved.
   
  II. Overall Software Design
  
  2.0 Software Installation
  
  No installation is required. Simply download or clone the repository and add the folder along with all its subfolders to the MATLAB path. The software will then be ready to run.
  Estimated installation time: 5 minutes
  
  2.1 Summary of Software Requirements
  
  This software adopts the traditional software development lifecycle approach, using a top-down, stepwise refinement structured software design methodology.
  The software has the following main functional areas:
  1.	Open the software and enter the user operation interface;
  2.	Select the signal type and configure the input channels corresponding to the EEG or ECG signals to be monitored;
  3.	Import a pre-trained model;
  4.	Click to start signal acquisition in LabChart; the software simultaneously calculates and displays the characteristic parameters of the bioelectrical signal and the seizure prediction parameter Π;
  5.	When the prediction parameter reaches the set threshold level, the system issues an alert for that time period and simultaneously outputs an automatic drug delivery (TTL) signal, or applies electrical stimulation;
  6.	End the recording in LabChart; the software automatically stops prediction;
  7.	Exit the program.
  In addition to implementing the above functions, the software is required to have a convenient, simple, intuitive, and visually appealing operation flow, facilitating future maintenance and upgrades.
  Estimated running time: The software runs continuously for the duration of the recording and modulation session, with no fixed time limit. Runtime will vary depending on the length of each experimental session.
  
  2.2 Conditions and Constraints
  
  This software only supports analysis of real-time data acquired through LabChart.
    	
  2.3 Structure Diagram Design and Description
    	
  The main function of this software is to open the user operation interface on a PC, acquire the electrophysiological signals under test, perform signal labeling and preprocessing, extract characteristic parameters, select a model, run predictions, save the model, perform real-time prediction on data recorded by LabChart, and display the results on the interface. At the same time, it delivers different control signals, including electrical modulation of specific frequency bands and pulse signals to start and stop a drug delivery pump.
   
  III. Software Function Descriptions
  
  3.1 Real-Time Bioelectrical Signal Prediction Process
  
  Open the LabChart recording software and run MATLAB. The system first checks whether a model has been imported, then selects the type of raw electrophysiological signal to be predicted and its corresponding channel. The MATLAB program is then run to monitor LabChart software activity. When sampling is started in LabChart, the risk index Π is calculated in real time from the recorded electrophysiological data and displayed. When Π reaches the threshold, a control signal is transmitted to external devices. When LabChart stops sampling, the software simultaneously stops prediction.
  
  3.2 Control Signal Output Process
  
  The software has been individually configured for different stimulation requirements. First, by setting pulse signals, the start and stop of an external drug delivery pump can be controlled. Second, by filtering the frequency band to be regulated, the electrical stimulation intensity is calculated and predicted, corrected, and output as pulse stimulation to modulate a specific frequency band.
   
  IV. Software Development and Runtime Environment
  
  4.1 Software Development Environment
  
  4.1.1 Hardware Configuration
  
  The software was developed on a standard desktop computer with the following specifications: Intel Core i5 processor, 16 GB RAM, 1 TB hard drive.
  
  4.1.2 Software Environment
  
  The desktop computer runs Windows 10 (64-bit), with the software operating within a MATLAB (version 2022a) environment.
  4.2 Software Runtime Environment
  
  The software's user interface was developed using the GUI toolkit in MATLAB 2022a. Therefore, versions of MATLAB lower than 2022a may not be able to run the software correctly.
  
   The main code is MATLAB_Sampling.m.
