    d = labchart.getActiveDocument;
    d.stimulator.enableChannels(1:2)
    w = d.stimulator.setStimulatorWaveform(1, 'pulse'); %set channel 1 to biphasic
    w.setBaseline(0);
    w.setStartDelay(0, 's');
    w.setNRepeats(-1);
    w.setMaxRepeatRate(50,'Hz')
    w.setPulseAmplitude(5)
    w.setPulseWidth(1, 'ms')
    w.setSyncChan(1)
    s = d.stimulator;
d.stimulator.enableChannels(1:2)
d.stimulator.disableChannels(1:2)