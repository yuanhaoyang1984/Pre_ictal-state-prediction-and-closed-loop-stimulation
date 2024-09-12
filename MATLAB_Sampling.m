%This script demonstrates live data streaming from LabChart to MATLAB.

%Instructions:
%1) Open a document in LabChart
%2) Run this script in MATLAB
%3) When LabChart starts sampling, the latest data from channels 1, 3 and 4 are 
%plotted in MATLAB (while sampling).
%4) If you stop sampling and make a selection in LabChart, then MATLAB will plot the
%selection.

global gLCApp;
global gLCDoc;
global gChans; %Array of channel numbers specifying channels to retrieve sampling data from
global gChansData;
global time_program_start;
global pause_signal
global Sampling_Frequency
global Signal_Type
global mediator
global threshold_value
global drug_flag
global ECG_Model_DNN
global ECG_Model_FCN
global EEG_Model
global Labchart_document
global st

drug_flag = 0;
threshold_value = 0.5; % threshold
mediator = 'elec' %'elec' or 'drug'
Signal_Type = 'EEG' %'EEG' or 'ECG'
Sampling_Frequency = 200 ;
pause_signal = 0;

if Signal_Type == 'EEG'
    if isempty(EEG_Model)
        error('Please load EEG Model.');
    end
end
if Signal_Type == 'ECG'
    if isempty(ECG_Model_DNN)
        error('Please load ECG_DNN Model.');
    end
    if isempty(ECG_Model_FCN)
        error('Please load EEG_FCN Model.');
    end
end

if mediator=='drug'
    stimulator_paramenters.Baseline = 0;
    stimulator_paramenters.StartDelay = 0; %s
    stimulator_paramenters.NRepeat = -1; %Times,-1 for numerous
    stimulator_paramenters.MaxiumPulseRate = 10; %Hz
    stimulator_paramenters.PulseAmplitude = 5; % v
    stimulator_paramenters.PulseWidth = 100 %ms
    stimulator_paramenters.SyncChan = 1;
    Labchart_document = labchart.getActiveDocument();
    Labchart_document = Labchart_document;
    clear waveform_stimulator
    waveform_stimulator = Labchart_document.stimulator.setStimulatorWaveform(1, 'pulse'); %set channel 1 to biphasic
    waveform_stimulator.setBaseline(stimulator_paramenters.Baseline);
    waveform_stimulator.setStartDelay(stimulator_paramenters.StartDelay, 's');
    waveform_stimulator.setNRepeats(stimulator_paramenters.NRepeat);
    waveform_stimulator.setMaxRepeatRate(stimulator_paramenters.MaxiumPulseRate,'Hz')
    waveform_stimulator.setPulseAmplitude(stimulator_paramenters.PulseAmplitude)
    waveform_stimulator.setPulseWidth(stimulator_paramenters.PulseWidth, 'ms')
    waveform_stimulator.setSyncChan(stimulator_paramenters.SyncChan)
    st = Labchart_document.stimulator;
end
if mediator=='elec'
    Labchart_document = labchart.getActiveDocument();
    waveform_stimulator = Labchart_document.stimulator.setStimulatorWaveform(1, 'pulse'); %set channel 1 to biphasic
    waveform_stimulator.setBaseline(stimulator_paramenters.Baseline);
    waveform_stimulator.setStartDelay(stimulator_paramenters.StartDelay, 's');
    waveform_stimulator.setNRepeats(stimulator_paramenters.NRepeat);
    waveform_stimulator.setMaxRepeatRate(stimulator_paramenters.MaxiumPulseRate,'Hz')
    waveform_stimulator.setPulseAmplitude(stimulator_paramenters.PulseAmplitude)
    waveform_stimulator.setPulseWidth(stimulator_paramenters.PulseWidth, 'ms')
    waveform_stimulator.setSyncChan(stimulator_paramenters.SyncChan)
    st = Labchart_document.stimulator;
    global waveform_stimulator
end
%First a reference to a LabChart instance (gLCApp) is obtained, either by attaching to 
%an already running LabChart, or starting LabChart.
try
    gLCApp = actxGetRunningServer('ADIChart.Application');
catch err
    error('Please start LabChart before running this script.');
end
if (isempty(gLCApp.ActiveDocument))
    error('Please open a document in LabChart before running this script.');
end

gLCDoc = gLCApp.ActiveDocument;

gChans = [3]; % collect sampling data from channels 1, 3 and 4.

RegisterLCEvents(gLCDoc); % hook up the OnSelectionChange event and the sampling events such as OnNewSamples and OnBlockStart.

% waitfor(pause_signal);
% time_program_start = clock;
% 
% gChansData