% function time_stimulation_start = stimulator_pulse_loop(stimulator_paramenters)
stimulator_paramenters.Baseline = 0;
stimulator_paramenters.StartDelay = 0; %s
stimulator_paramenters.NRepeat = 1; %Times,-1 for numerous
stimulator_paramenters.MaxiumPulseRate = 10; %Hz
stimulator_paramenters.PulseAmplitude = 5; % v
stimulator_paramenters.PulseWidth = 0.1 %ms
stimulator_paramenters.SyncChan = 1;

Labchart_document = labchart.getActiveDocument;
waveform_stimulator = labchart_document.stimulator.setStimulatorWaveform(1, 'pulse'); %set channel 1 to biphasic
waveform_stimulator.setBaseline(stimulator_paramenters.Baseline);
waveform_stimulator.setStartDelay(stimulator_paramenters.StartDelay, 's');
waveform_stimulator.setNRepeat(stimulator_paramenters.NRepeat);
waveform_stimulator.setPulseRate(stimulator_paramenters.MaxiumPulseRate,'Hz')
waveform_stimulator.setPulseAmplitude(stimulator_paramenters.PulseAmplitud)
waveform_stimulator.setPulseWidth(stimulator_paramenters.PulseWidth, 'ms')
waveform_stimulator.setSyncChan(stimulator_paramenters.SyncChan)
s = labchart_document.stimulator;
s.startStimulation();
time_stimulation_start = clock; 
% end