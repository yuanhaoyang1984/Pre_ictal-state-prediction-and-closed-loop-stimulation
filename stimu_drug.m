function stimu_drug(status)
global threshold_value
global mediator
global st
global drug_flag
global drug_time_start
global Labchart_document
global st
if mediator == 'drug'
    if status == 0 
%         stimulator_paramenters.Baseline = 0;
%         stimulator_paramenters.StartDelay = 0; %s
%         stimulator_paramenters.NRepeat = -1; %Times,-1 for numerous
%         stimulator_paramenters.MaxiumPulseRate = 10; %Hz
%         stimulator_paramenters.PulseAmplitude = 5; % v
%         stimulator_paramenters.PulseWidth = 100 %ms
%         stimulator_paramenters.SyncChan = 1;
%         time1 = clock;
% %         Labchart_document = labchart.getActiveDocument();
%         labchart_document = Labchart_document;
%         waveform_stimulator = labchart_document.stimulator.setStimulatorWaveform(1, 'pulse'); %set channel 1 to biphasic
%         waveform_stimulator.setBaseline(stimulator_paramenters.Baseline);
%         waveform_stimulator.setStartDelay(stimulator_paramenters.StartDelay, 's');
%         waveform_stimulator.setNRepeat(stimulator_paramenters.NRepeat);
%         waveform_stimulator.setMaxRepeatRate(stimulator_paramenters.MaxiumPulseRate,'Hz')
%         waveform_stimulator.setPulseAmplitude(stimulator_paramenters.PulseAmplitud)
%         waveform_stimulator.setPulseWidth(stimulator_paramenters.PulseWidth, 'ms')
%         waveform_stimulator.setSyncChan(stimulator_paramenters.SyncChan)
%         st = labchart_document.stimulator;
%         time_stimulation_start = clock;
%         if drug_flag == 1
%             Time_now
%         end
        st.enableChannels(1:2)

    end

if status == 1
    st.disableChannels(1:2)
    % drug_stimulator('end');
    drug_flag = 1;
    drug_time_start = clock;
end
end
end