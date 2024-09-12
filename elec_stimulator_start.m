function elec_stimulator_start(stimulator_paramenters)

global waveform_stimulator
global Labchart_document
time1 = clock;

waveform_stimulator.setBaseline(stimulator_paramenters.Baseline);
waveform_stimulator.setStartDelay(stimulator_paramenters.StartDelay, 's');
waveform_stimulator.setNRepeats(stimulator_paramenters.NRepeat);
waveform_stimulator.setMaxRepeatRate(stimulator_paramenters.MaxiumPulseRate,'Hz')
waveform_stimulator.setPulseAmplitude(stimulator_paramenters.PulseAmplitude)
waveform_stimulator.setPulseWidth(stimulator_paramenters.PulseWidth, 'ms')
s = Labchart_document.stimulator;
time_stimulation_start = clock; 

s.enableChannels(1:2)
s.startStimulation();
% s.stimulator.disableChannels(1:2)
end