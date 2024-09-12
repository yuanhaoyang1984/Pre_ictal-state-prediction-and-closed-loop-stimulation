close all
%%
clear
%%
clc
train_matrix_all=[];
resting=[];
pre_onset=[];
folder=uigetdir('H:\数字信号处理\');
train_m=[];
label_matrix=[];
if folder==0
    fprintf('No folder selected.\n')
else
    [~,~,files]=dirr(folder,'\.edf$','name');
    files=files';
end
for ii=1:length(files)
    %load data
    [r,annotation]=edfread(files{ii});
    %get data from temporal lobe
    T_channel_signal=r{:,["EEGT3_Ref","EEGT4_Ref","EEGT5_Ref","EEGT6_Ref"]};
    T_channel_signal_expand=cell2mat(T_channel_signal); %expand
    %T3 左颞 T4 右颞， T5 左颞后，T6 右颞后
    for epoch=1:4
        %base settings
        jj=epoch;
        Filter_freq = 1 ;%Hz
        %     uilabel(SZ_DetPanel,'FontName','Bahnschrift','Position',[5 300 140 30],'Text',{'High pass filter for'; 'seizure detection:'});
        SZ_Threshold = 1.5; %几倍基线的条件滤波
        size_RMS = 20 ;%size_RMS*5(ms) 不改
        MovMean_Window = 10; %segment 不改
        MinIctal = 10; %(s)
        MinInterval = 10; %(s)
        size_BL= 1;%min
        loc=[];
        hdr.frequency(1)=length(T_channel_signal{1,1})
        %
        train_matrix=[];
        train_matrix_all=[];
        window_size=5;      %min
        EEG_signal=T_channel_signal_expand(:,jj);        
        size_matrix=floor(length(EEG_signal)/(window_size*60*hdr.frequency(1)));
        MI_raw_matrix=cell(1,size_matrix);
        Power_raw_matrix=zeros(6,size_matrix);
        % MI_surr_matrix=zeros(1,15);

        MI_matrix=zeros(26,size_matrix);
        Complexity=zeros(1,size_matrix);
        for i=1:length(MI_raw_matrix)
            %     window_start=oneset_time-window_size*60*(hdr.frequency(1))*i;
            %     window_end=oneset_time-window_size*60*(hdr.frequency(1))*(i-1)-1;
            window_end=window_size*60*(hdr.frequency(1))*i;
            window_start=1+window_size*60*(hdr.frequency(1))*(i-1);
            signal=EEG_signal(window_start:window_end);
            signal=signal';
            [C, H, gs] = calc_lz_complexity(signal,'exhaustive',1);
            Complexity(1,i) = C;
            cfg                     = [];
            cfg.Fs                  = hdr.frequency(1);
            cfg.phase_freqs         = [2:2:30];
            cfg.amp_freqs           = [50:2:100];
            cfg.method              = 'plv';
            cfg.filt_order          = 2;
            %     cfg.surr_method         = 'swap_blocks';
            cfg.surr_N              = 200;
            cfg.amp_bandw_method    = 'number';
            cfg.amp_bandw           = 40;
            
            [MI_raw]                = PACmeg(cfg,signal);
            MI_raw_matrix{i}        =MI_raw;
            %   MI_surr_matrix(1,i)     =MI_surr;
        end
        
        
        %power值
        for i=1:size(Power_raw_matrix,2)
            %     window_start=oneset_time-window_size*60*(hdr.frequency(1))*i;
            %     window_end=oneset_time-window_size*60*(hdr.frequency(1))*(i-1)-1;
            window_end=window_size*60*(hdr.frequency(1))*i;
            window_start=1+window_size*60*(hdr.frequency(1))*(i-1);
            signal=EEG_signal(window_start:window_end);
            signal=signal';
            [SIG1,sigDEN] = func_denoisem(signal);
            [power_line,f]=pwelch(sigDEN,4000,256,1000,hdr.frequency(1));
            power_line=10*log(power_line);

            chan1_loc=find(f<=4&f>=2);
            chan2_loc=find(f<=8&f>=4);
            chan3_loc=find(f<=16&f>=8);
            chan4_loc=find(f<=30&f>=16);
            chan5_loc=find(f<=50&f>=30);
            chan6_loc=find(f<=100&f>=50);
            
            power_delta=mean(power_line(chan1_loc));
            
            power_theta=mean(power_line(chan2_loc));
            
            power_alpha=mean(power_line(chan3_loc));
            
            power_beta=mean(power_line(chan4_loc));
            
            power_low_gamma=mean(power_line(chan5_loc));
            
            power_high_gamma=mean(power_line(chan6_loc));

            Power_raw_matrix(:,i)=[power_delta;power_theta;power_alpha;power_beta;power_low_gamma;power_high_gamma];
            
        end
        
        
        for i=1:length(MI_raw_matrix)
            for j = 1:size(MI_raw_matrix{i},1)
                MI_matrix(j,i)=mean(MI_raw_matrix{i}(j,:));
            end
        end
        
        train_matrix=[MI_matrix;Power_raw_matrix;Complexity];
        train_matrix_all=[train_matrix_all;train_matrix];
        %%detection begin
        i=1;
        Fs=length(T_channel_signal{1,1});
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
        time_rms=(size_RMS*(1/Fs))/60:(size_RMS*(1/Fs))/60:size_Data;

        Reshaped_Data{j} = reshape(Data_HP(1:end),size_RMS,[]);
        rms_Data{j} = rms(Reshaped_Data{j});
        %     rms_Data{j} = min(Reshaped_Data{j});
        MovMean_Data{j} = movmean(rms_Data{j},MovMean_Window);
        SZlogic{j} = (MovMean_Data{j}/prctile(MovMean_Data{j},25))>SZ_Threshold;
        SZlogic{j}(1,[1,end])=0;
        SZstart1{j} = time_rms(islocalmax(SZlogic{j},"FlatSelection","first"));
        SZend1{j} = time_rms(islocalmax(SZlogic{j},"FlatSelection","last"));
        if isempty((SZend1{j})-SZstart1{j}>=MinIctal/60)
            SZend3{j}=[];
            SZstart3{j}=[];
            SZs_dur{j}=[];
            

        else
            SZstart2{j} = SZstart1{j}((SZstart1{j}<SZend1{j})&(SZend1{j})-SZstart1{j}>=MinIctal/60);
            SZend2{j} = SZend1{j}((SZstart1{j}<SZend1{j})&(SZend1{j})-SZstart1{j}>=MinIctal/60);
            if isempty(SZstart2{j}(2:end)-SZend2{j}(1:end-1)>=MinInterval/60)
                SZend3{j}=[];
                SZstart3{j}=[];
                SZs_dur{j}=[];
            else
                SZstart3{j} = SZstart2{j}(logical([1,SZstart2{j}(2:end)-SZend2{j}(1:end-1)>=MinInterval/60]));
                SZend3{j} = SZend2{j}(logical([SZstart2{j}(2:end)-SZend2{j}(1:end-1)>=MinInterval/60,1]));
                SZs{j} = SZend3{j}-SZstart3{j};
                SZs_dur{j} = SZend3{j}-SZstart3{j};
            end
        end

        timestamp=SZstart3{j};
        matrix_all=train_matrix_all;
        a=floor(timestamp/(window_size))+1;

%% deep learning matrix
        x=find(a<=size(matrix_all,2));
        a=a(x);
        status=zeros(1,size(matrix_all,2));
        status(a)=1;
        status_s=status;
        for jj=1:2
            xx=find(a>jj);
            pro_itach=a(xx)-jj;
            status_s(pro_itach)=1;
        end
        train_m=[train_m,matrix_all];
        label_matrix=[label_matrix,status_s];
        
    end
end

        trainFcn = 'trainscg'
        hiddenLayerSize = 33;
        net = patternnet([hiddenLayerSize hiddenLayerSize hiddenLayerSize hiddenLayerSize hiddenLayerSize hiddenLayerSize],trainFcn);
        % Setup Division of Data for Training, Validation, Testing
        RandStream.setGlobalStream(RandStream('mt19937ar','seed',1)); % to get constant result
        net.divideFcn = 'dividerand'; % Divide targets into three sets using blocks of indices
        net.divideParam.trainRatio = 60/100;
        net.divideParam.valRatio = 20/100;
        net.divideParam.testRatio = 20/100;
        %TRAINING PARAMETERS
        net.trainParam.show=50;  % of ephocs in display
        net.trainParam.lr=0.05;  % learning rate
        net.trainParam.epochs=200;  % max epochs
        net.trainParam.goal=1e-5;  % training goal
        net.performFcn='crossentropy';  % Name of a network performance function %type help nnperformance
        [net,tr] = train(net,train_m,label_matrix,'useParallel','yes','showResources','yes');
        % Test the Network

        % View the Network
        view(net)
        y = net(train_m);
        % val = sim(net,train_m);
        % classes = vec2ind(val);                     
        % r = sum(classes == label2class(TEST_labels'))/(size(train_m,2)); 
        figure
        plot(y)
        class=round(y);
        y_1=find(status_s==1);
        y_0=find(status_s==0);
        pre_onset=[pre_onset,y(y_1)];
        resting=[resting,y(y_0)];
