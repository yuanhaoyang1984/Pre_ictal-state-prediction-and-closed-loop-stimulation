close all
%%
clear
%%
clc
train_matrix_all=[];
resting=[];
pre_onset=[];
result_val = {};
result_val_class = {};
result_status_s={};
timesize = 1;
folder=uigetdir('H:\数字信号处理\');

if folder==0
    fprintf('No folder selected.\n')
else
    [~,~,files]=dirr(folder,'\.edf$','name');
    files=files';
end
% build Deep Neural Network model
lgraph = layerGraph();
tempLayers = [
    sequenceInputLayer(4096,"Name","sequence")
    convolution1dLayer(8,64,"Name","conv1d_1","Padding","same","WeightsInitializer","he")
    batchNormalizationLayer("Name","batchnorm_1")
    reluLayer("Name","relu_1")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    maxPooling1dLayer(4,"Name","maxpool1d_1","Padding","same")
    convolution1dLayer(1,128,"Name","conv1d_2","Padding","same","Stride",4,"WeightsInitializer","he")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    convolution1dLayer(8,128,"Name","conv1d_3","Padding","same","WeightsInitializer","he")
    batchNormalizationLayer("Name","batchnorm_2")
    reluLayer("Name","relu_2")
    dropoutLayer(0.8,"Name","dropout_1")
    convolution1dLayer(8,128,"Name","conv1d_4","Padding","same","Stride",4,"WeightsInitializer","he")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = additionLayer(2,"Name","addition_1");
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    batchNormalizationLayer("Name","batchnorm_6")
    reluLayer("Name","relu_6")
    dropoutLayer(0.8,"Name","dropout_5")
    convolution1dLayer(8,196,"Name","conv1d_6","Padding","same","WeightsInitializer","he")
    batchNormalizationLayer("Name","batchnorm_3")
    reluLayer("Name","relu_3")
    dropoutLayer(0.8,"Name","dropout_2")
    convolution1dLayer(8,196,"Name","conv1d_7","Padding","same","Stride",4,"WeightsInitializer","he")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    maxPooling1dLayer(4,"Name","maxpool1d_2","Padding","same")
    convolution1dLayer(1,196,"Name","conv1d_5","Padding","same","Stride",4,"WeightsInitializer","he")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = additionLayer(2,"Name","addition_2");
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    batchNormalizationLayer("Name","batchnorm_7")
    reluLayer("Name","relu_7")
    dropoutLayer(0.8,"Name","dropout_6")
    convolution1dLayer(8,256,"Name","conv1d_9","Padding","same","WeightsInitializer","he")
    batchNormalizationLayer("Name","batchnorm_4")
    reluLayer("Name","relu_4")
    dropoutLayer(0.8,"Name","dropout_3")
    convolution1dLayer(8,256,"Name","conv1d_10","Padding","same","Stride",4,"WeightsInitializer","he")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    maxPooling1dLayer(4,"Name","maxpool1d_3","Padding","same")
    convolution1dLayer(1,256,"Name","conv1d_8","Padding","same","Stride",4,"WeightsInitializer","he")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = additionLayer(2,"Name","addition_3");
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    batchNormalizationLayer("Name","batchnorm_8")
    reluLayer("Name","relu_8")
    dropoutLayer(0.8,"Name","dropout_7")
    convolution1dLayer(8,320,"Name","conv1d_12","Padding","same")
    batchNormalizationLayer("Name","batchnorm_5")
    reluLayer("Name","relu_5")
    dropoutLayer(0.8,"Name","dropout_4")
    convolution1dLayer(8,320,"Name","conv1d_13","Padding","same","Stride",4,"WeightsInitializer","he")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    maxPooling1dLayer(4,"Name","maxpool1d_4","Padding","same")
    convolution1dLayer(1,320,"Name","conv1d_11","Padding","same","Stride",4,"WeightsInitializer","he")];
lgraph = addLayers(lgraph,tempLayers);

tempLayers = [
    additionLayer(2,"Name","addition_4")
    batchNormalizationLayer("Name","batchnorm_9")
    reluLayer("Name","relu_9")
    dropoutLayer(0.8,"Name","dropout_8")
    fullyConnectedLayer(2,"Name","fc","WeightsInitializer","he")
    sigmoidLayer("Name","sigmoid")
    classificationLayer("Name","classoutput")];
lgraph = addLayers(lgraph,tempLayers);


% 清理辅助变量
clear tempLayers;

lgraph = connectLayers(lgraph,"relu_1","maxpool1d_1");
lgraph = connectLayers(lgraph,"relu_1","conv1d_3");
lgraph = connectLayers(lgraph,"conv1d_4","addition_1/in2");
lgraph = connectLayers(lgraph,"conv1d_2","addition_1/in1");
lgraph = connectLayers(lgraph,"addition_1","batchnorm_6");
lgraph = connectLayers(lgraph,"addition_1","maxpool1d_2");
lgraph = connectLayers(lgraph,"conv1d_5","addition_2/in1");
lgraph = connectLayers(lgraph,"conv1d_7","addition_2/in2");
lgraph = connectLayers(lgraph,"addition_2","batchnorm_7");
lgraph = connectLayers(lgraph,"addition_2","maxpool1d_3");
lgraph = connectLayers(lgraph,"conv1d_8","addition_3/in1");
lgraph = connectLayers(lgraph,"conv1d_10","addition_3/in2");
lgraph = connectLayers(lgraph,"addition_3","batchnorm_8");
lgraph = connectLayers(lgraph,"addition_3","maxpool1d_4");
lgraph = connectLayers(lgraph,"conv1d_11","addition_4/in1");
lgraph = connectLayers(lgraph,"conv1d_13","addition_4/in2");

% plot(lgraph);
options = trainingOptions('sgdm','InitialLearnRate',0.001,'MaxEpochs',50,'MiniBatchSize',16,'Shuffle','every-epoch','Plots','training-progress','Verbose', 0, ...
    'LearnRateSchedule', 'piecewise','LearnRateDropFactor',0.1,'ExecutionEnvironment','gpu');
for ii=1:length(files)
    %读入
    [r,annotation]=edfread(files{ii});
    
    %获取颞叶
    T_channel_signal=r{:,["EEGT3_Ref","EEGT4_Ref","EEGT5_Ref","EEGT6_Ref"]};
    T_channel_signal_expand=cell2mat(T_channel_signal); %时间轴上展开
    
    %比对通道，T3 左颞 T4 右颞， T5 左颞后，T6 右颞后
    ECG_signal=r{:,["POLX7"]};
    ECG_signal_expand=cell2mat(ECG_signal); %时间轴上展开
    hdr.frequency(1)=length(ECG_signal{1,1});
    Fs=hdr.frequency(1);
    d=designfilt('bandstopiir','FilterOrder',2, ...
        'HalfPowerFrequency1',49,'HalfPowerFrequency2',51, ...
        'DesignMethod','butter','SampleRate',Fs);

    ECG_50=filtfilt(d,ECG_signal_expand);
    tm=1/Fs:1/Fs:length(ECG_signal_expand)/Fs;
    fmaxd_1=5; %Hz
    fmaxn_1=fmaxd_1/(Fs/2);
    [B,A]=butter(1,fmaxn_1,'low');
    ecg_low=filtfilt(B,A,ECG_50);
    ECG=ECG_50-ecg_low;

    % filter_band_qrs = dwtfilterbank('Wavelet','sym4','SignalLength',numel(qrsEx),'Level',3);
    wt = modwt(ECG,5);
    wtrec = zeros(size(wt));
    wtrec(4:5,:) = wt(4:5,:);
    y_Detection_ECG = imodwt(wtrec,'sym4');

    y_Detection_ECG = abs(y_Detection_ECG).^2;
    [qrspeaks,locs] = findpeaks(y_Detection_ECG,tm,'MinPeakHeight',350,...
        'MinPeakDistance',0.150);
    desiredFs = 400;
    [p,q] = rat(desiredFs / Fs);
    ECG = resample(ECG,p,q);

    for epoch=1:4
                
        %base settings
        jj=epoch;
        Filter_freq = 1 ;%Hz
        %     uilabel(SZ_DetPanel,'FontName','Bahnschrift','Position',[5 300 140 30],'Text',{'High pass filter for'; 'seizure detection:'});
        SZ_Threshold = 1.5; %
        size_RMS = 20 ;%size_RMS*5(ms) 
        MovMean_Window = 10; %segment 
        MinIctal = 10; %(s)
        MinInterval = 10; %(s)
        size_BL= 1;%min
        loc=[];
        hdr.frequency(1)=length(ECG_signal{1,1})
        %
        train_matrix=[];
        train_matrix_all=[];
        window_size=1/6;      %min
        EEG_signal=T_channel_signal_expand(:,jj);        
        size_matrix=floor(length(ECG)/(window_size*60*desiredFs))-1;
        if size_matrix<=2
            continue
        end
        MI_raw_matrix=zeros(window_size*60*desiredFs+96,size_matrix);
        Power_raw_matrix=zeros(window_size*60*desiredFs,size_matrix);
        % MI_surr_matrix=zeros(1,15);

%         MI_matrix=zeros(300*desiredFs,size_matrix);
%         Complexity=zeros(300*hdr.frequency(1),size_matrix);
        matrix_RR_interval = zeros(1, size(MI_raw_matrix,2)-1);
        for i=1:size(MI_raw_matrix,2)-1
            %     window_start=oneset_time-window_size*60*(hdr.frequency(1))*i;
            %     window_end=oneset_time-window_size*60*(hdr.frequency(1))*(i-1)-1;
            window_end=window_size*60*(desiredFs)*i+96;
            window_start=1+window_size*60*(desiredFs)*(i-1);
            signal=ECG(window_start:window_end);
            %             signal=signal';
            MI_raw_matrix(:,i) = signal;
            wt = modwt(signal,5);
            wtrec = zeros(size(wt));
            wtrec(4:5,:) = wt(4:5,:);
            y_Detection_ECG = imodwt(wtrec,'sym4');

            y_Detection_ECG = abs(y_Detection_ECG).^2;
            tm=1/desiredFs:1/desiredFs:length(signal)/desiredFs;
            [qrspeaks,locs] = findpeaks(y_Detection_ECG,tm,'MinPeakHeight',350,...
                'MinPeakDistance',0.150);
            [qrspeaks_2,locs] = findpeaks(y_Detection_ECG,tm,'MinPeakHeight',prctile(qrspeaks,75),...
                'MinPeakDistance',0.150);
            matrix_RR_interval(1,i) = mean(diff(locs));
        end
        %%detection begin
        i=1;
        Fs=hdr.frequency(1);
        j=1;
        Data = T_channel_signal_expand(:,epoch);
        if Filter_freq > 0
            Highpass2 = designfilt('highpassiir','PassbandFrequency',Filter_freq,'StopbandFrequency',Filter_freq-0.295,'PassbandRipple',0.1000,'StopbandAttenuation',60,'DesignMethod','ellip','SampleRate',200);
            Data_HP = filtfilt(Highpass2,Data);
        else
            Data_HP = Data;
        end
        %         size_BL=10;%min
        tm=1/Fs:1/Fs:length(Data)/Fs;
        fmaxd_1=5; %Hz
        fmaxn_1=fmaxd_1/(Fs/2);
        [B,A]=butter(1,fmaxn_1,'low');
        data_low=filtfilt(B,A,Data);
        Data=Data-data_low;
        size_Data = size(T_channel_signal,1)/60;
        %% SEIZURE DETECTION
        flag=0;
        time_rms=size_RMS*(1000/Fs)/60000:size_RMS*(1000/Fs)/60000:size_Data;

        Reshaped_Data{j} = reshape(Data_HP(1:end),size_RMS,[]);
        rms_Data{j} = rms(Reshaped_Data{j});
      
        MovMean_Data{j} = movmean(rms_Data{j},MovMean_Window);
        SZlogic{j} = (MovMean_Data{j}/prctile(MovMean_Data{j},25))>SZ_Threshold;
        SZlogic{j}(1,[1,end])=0;
        SZstart1{j} = time_rms(islocalmax(SZlogic{j},"FlatSelection","first"));
        SZend1{j} = time_rms(islocalmax(SZlogic{j},"FlatSelection","last"));
        if isempty(find(SZend1{j})-SZstart1{j}>=MinIctal/60)
            SZend3{j}=[];
            SZstart3{j}=[];
            SZs_dur{j}=[];
            flag=1;
        
        else
        SZstart2{j} = SZstart1{j}((SZstart1{j}<SZend1{j})&(SZend1{j})-SZstart1{j}>=MinIctal/60);
        SZend2{j} = SZend1{j}((SZstart1{j}<SZend1{j})&(SZend1{j})-SZstart1{j}>=MinIctal/60);
        end
        if isempty(find(SZstart2{j}(2:end)-SZend2{j}(1:end-1)>=MinInterval/60)) | (flag==1)
            SZend3{j}=[];
            SZstart3{j}=[];
            SZs_dur{j}=[];
        else
            SZstart3{j} = SZstart2{j}(logical([1,SZstart2{j}(2:end)-SZend2{j}(1:end-1)>=MinInterval/60]));
            SZend3{j} = SZend2{j}(logical([SZstart2{j}(2:end)-SZend2{j}(1:end-1)>=MinInterval/60,1]));
            SZs{j} = SZend3{j}-SZstart3{j};
            SZs_dur{j} = SZend3{j}-SZstart3{j};
        end
        timestamp=SZstart3{j};
%         matrix_all=train_matrix_all;
        a=floor(timestamp/(1/6))+1;

%% deep learning
        x=find(a<=size(MI_raw_matrix,2));
        a=a(x);
        status=zeros(1,size(MI_raw_matrix,2));
        status(a)=1;
        status_s=status;
        for jj=1:timesize*(5/window_size)
            xx=find(a>jj);
            pro_itach=a(xx)-jj;
            status_s(pro_itach)=1;
        end
        status=status_s;
        pre_onset = [pre_onset, matrix_RR_interval(1,find(status_s(1:end-1) == 1))];
        resting = [resting , matrix_RR_interval(1,find(status_s(1:end-1) == 0))];
        options = trainingOptions('sgdm','InitialLearnRate',0.001,'MaxEpochs',50,'MiniBatchSize',16,'Shuffle','every-epoch','Verbose', 0, ...
            'LearnRateSchedule', 'piecewise','LearnRateDropFactor',0.1,'ExecutionEnvironment','gpu');
        train_matrix = mat2cell(MI_raw_matrix,[4096],ones(1,size(MI_raw_matrix,2)));
        status_cell = {};
        for i=1:length(status_s)
            status_cell{end+1} = categorical(status_s(i));
        end

        if length(unique(status_s))==1
            result_status_s{end+1}=status_s;
            result_val_class{end+1}=[];
            result_val{end+1} = [];
            continue
        end
        model = trainNetwork(train_matrix,status_cell,lgraph,options);
        val = predict(model, train_matrix);
        val_class = predict(model,train_matrix,'ReturnCategorical',1);
        result_status_s{end+1}=status_s;
        val_class_1={};
        for i=1:length(val_class)
            val_class_1{i}=grp2idx(val_class{i});
        end
        result_val_class{end+1}=cell2mat(val_class_1)-1;
        result_val{end+1} = cell2mat(val');
    end
end