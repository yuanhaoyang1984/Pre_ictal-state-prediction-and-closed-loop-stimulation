function doOnNewSamples(newTicks)
%To debug thus function, set a breakpoint in it and call it manually
%from the MATLAB command line after sampling has been stopped.
%Example event handler called when sampling, whenever new samples might be
%available, typically 20 times a second.
%This example gets any new samples from channel gChan, appends them to
%the gChan1Data vector, then plots the latest 5000 samples.
global gLCDoc;
global gLatestBlock;
global gBlockSecsPerTick;
global gLatestTickInBlock;
global gChans;
global gChansData;
global gT;
global Sampling_Frequency;
global Signal_Type
global threshold_value
global mediator
global st
global drug_flag
global drug_time_start
global random_elec_mode   % =1 表示随机刺激模式开启
global random_stim_n      % 每30分钟刺激次数 n
global random_last_time   % 上次随机窗口起始时间（用clock存储）
global random_stim_count  % 当前30分钟窗口内已刺激次数

%disp('OnNewSamples called')
gLatestTickInBlock = gLatestTickInBlock+newTicks;
% HRESULT GetChannelData([in]ChannelDataFlags flags, [in]long channelNumber, [in]long blockNumber, [in]long startSample, [in]long numSamples, [out,retval]VARIANT *data) const;
% For the sampling case we can pass -1 for the number of samples parameter,
% meaning return all available samples
newSamplesMax = 0; %max new samples added across channels
minChanLength = 1e30; %number of samples in the shortest channel

slot = 1;
for ch = gChans
    % HRESULT GetChannelData([in]ChannelDataFlags flags, [in]long channelNumber, [in]long blockNumber, [in]long startSample, [in]long numSamples, [out,retval]VARIANT *data) const;
    % For the sampling case we can pass -1 for the number of samples parameter,
    % meaning return all available samples
    chanSamples = gLCDoc.GetChannelData (1, ch, gLatestBlock+1, length(gChansData{slot})+1, -1);
    gChansData{slot} = [gChansData{slot}; chanSamples'];
    if minChanLength > length(gChansData{slot})
        minChanLength = length(gChansData{slot});
    end
    if newSamplesMax < length(chanSamples)
        newSamplesMax = length(chanSamples);
    end
    slot = slot+1;
end

if newSamplesMax > 0
    nSamples = length(gT);
    gT = [gT; [nSamples:nSamples+newSamplesMax-1]'*gBlockSecsPerTick];
end

%plot the latest 5000 samples
plotRange = max(1,minChanLength-5*60*Sampling_Frequency):minChanLength;
slot = 1;
if strcmp(Signal_Type, 'EEG')
    for ch = gChans
        slot = slot+1;
        if random_elec_mode == 1
            time_now = clock;
            elapsed_time = etime(time_now, random_last_time); % 计算与上次窗口起点的时间差（秒）

            % 每30分钟重置计数
            if elapsed_time > 1800  % 1800秒 = 30分钟
                random_last_time = time_now;
                random_stim_count = 0;
            end

            % 如果当前窗口内刺激次数还没到 n
            if random_stim_count < random_stim_n
                % 计算触发概率（平均每30分钟 n 次）
                % 假设每秒检查一次（根据OnNewSamples调用频率微调）
                if rand < (random_stim_n / 1800)
                    stimulator_paramenters.Baseline = 0;
                    stimulator_paramenters.StartDelay = 0; %s
                    stimulator_paramenters.NRepeat = 1; %Times,-1 for numerous
                    stimulator_paramenters.MaxiumPulseRate = 10; %Hz
                    stimulator_paramenters.PulseAmplitude = 5; %V
                    stimulator_paramenters.PulseWidth = 1; %ms
                    stimulator_paramenters.SyncChan = 1;
                    elec_stimulator_start(stimulator_paramenters);

                    random_stim_count = random_stim_count + 1;
                    disp(['[随机刺激] 触发第 ' num2str(random_stim_count) ...
                        ' 次 (30min窗口) at ' datestr(now)]);
                end
            end
        else
            %         subplot(length(gChans),1,slot), plot(gT(plotRange),gChansData{slot}(plotRange));
            [Pai_Val,status] = Model_Predict_EEG(gChansData{slot}(plotRange), threshold_value)
            channelStr = ['Channel ' int2str(ch)];
            %         title(channelStr);

            if status == 1 & mediator == 'elec'
                stimulator_paramenters.Baseline = 0;
                stimulator_paramenters.StartDelay = 0; %s
                stimulator_paramenters.NRepeat = 1; %Times,-1 for numerous
                stimulator_paramenters.MaxiumPulseRate = 10; %Hz
                stimulator_paramenters.PulseAmplitude = 5; % v
                stimulator_paramenters.PulseWidth = 1 %ms
                stimulator_paramenters.SyncChan = 1;
                elec_stimulator_start(stimulator_paramenters);
            end
        end
        if mediator == 'drug'
            if drug_flag == 1
                time_now = clock;
                diftime = time_now-drug_time_start;
                if diftime(5)*60+diftime(6)>10
                    drug_flag = 0;
                end
            end
            if drug_flag == 0
                stimu_drug(status);
            end

        end

    end
end
if strcmp(Signal_Type, 'ECG')
    for ch = gChans
        subplot(length(gChans),1,slot), plot(gT(plotRange),gChansData{slot}(plotRange));
        [Pai_Val,status] = Model_Predict_ECG(gChansData{slot}(plotRange), threshold_value)
        channelStr = ['Channel ' int2str(ch)];
        title(channelStr);
        slot = slot+1;
        if status == 1 & mediator == 'elec'
            stimulator_paramenters.Baseline = 0;
            stimulator_paramenters.StartDelay = 0; %s
            stimulator_paramenters.NRepeat = 1; %Times,-1 for numerous
            stimulator_paramenters.MaxiumPulseRate = 10; %Hz
            stimulator_paramenters.PulseAmplitude = 5; % v
            stimulator_paramenters.PulseWidth = 1 %ms
            stimulator_paramenters.SyncChan = 1;
            elec_stimulator_start(stimulator_paramenters);
        end
        if mediator == 'drug'
            if drug_flag == 1
                time_now = clock;
                diftime = time_now-drug_time_start;
                if diftime(5)*60+diftime(6)>10
                    drug_flag = 0;
                end
            end
            if drug_flag == 0
                stimu_drug(status)
            end

        end
    end
end
