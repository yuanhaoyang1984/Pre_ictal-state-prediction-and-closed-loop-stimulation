scrsize=get(groot,'screensize');
stimu0=500; % ms
stimu1=1500; % ms
folder=uigetdir('H:\数字信号处理\');
threshold_EEG = 0.24

if folder==0
    fprintf('No folder selected.\n')
else
    [~,~,files]=dirr(folder,'\.adicht$','name');
    files=files';
end
for ii = 1:length(files)
    f = adi.readFile(files{ii});
    EEG_chan = f.getChannelByName('3');
    raw_EEG_data = EEG_chan.getData(1); %Get data from the first record
    EEG = raw_EEG_data';

%     pai = zeros(2,204);
    Sampling_Frequency=1000;
    data_size = length(EEG)./(60*Sampling_Frequency);
%     forplot = EEG(60*1000*(timestamp(ii,j)-30):60*1000*(timestamp(ii,j)+30));
%     for i =1:floor(data_size)-1
%         %[a,b]=Model_Predict_EEG(forplot((i-1)*60*1000+1:i*60*1000),0.28);
%         signal = EEG((i-1)*60*Sampling_Frequency+1:(i)*60*Sampling_Frequency);
%         Complexity = 1;
%         cfg                     = [];
%         cfg.Fs                  = Sampling_Frequency;
%         cfg.phase_freqs         = [2:2:30];
%         cfg.amp_freqs           = [50:2:100];
%         cfg.method              = 'plv';
%         cfg.filt_order          = 2;
%         %     cfg.surr_method         = 'swap_blocks';
%         cfg.surr_N              = 200;
%         cfg.amp_bandw_method    = 'number';
%         cfg.amp_bandw           = 40;
% 
%         [MI_raw]                = PACmeg(cfg,signal);
%         MI_raw_matrix           = MI_raw;
% 
%         [SIG1,sigDEN] = func_denoisem(signal);
%         [power_line,f]=pwelch(sigDEN,4000,256,1000,Sampling_Frequency);
%         power_line=10*log(power_line);
% 
%         chan1_loc=find(f<=4&f>=2);
%         chan2_loc=find(f<=8&f>=4);
%         chan3_loc=find(f<=16&f>=8);
%         chan4_loc=find(f<=30&f>=16);
%         chan5_loc=find(f<=50&f>=30);
%         chan6_loc=find(f<=100&f>=50);
% 
%         power_delta = mean(power_line(chan1_loc));
% 
%         power_theta = mean(power_line(chan2_loc));
% 
%         power_alpha = mean(power_line(chan3_loc));
% 
%         power_beta = mean(power_line(chan4_loc));
% 
%         power_low_gamma = mean(power_line(chan5_loc));
% 
%         power_high_gamma = mean(power_line(chan6_loc));
% 
%         Power_raw_matrix = [power_delta;power_theta;power_alpha;power_beta;power_low_gamma;power_high_gamma];
% 
%         for j = 1:size(MI_raw_matrix,1)
%             MI_matrix(j,1)=mean(MI_raw_matrix(j,:));
%         end
% 
%         feature_matrix=[MI_matrix;Power_raw_matrix;Complexity];
% 
%         val_Pai = sim(EEG_Model,feature_matrix);
% 
%         if val_Pai >= threshold_EEG
%             status = 1;
%         else
%             status = 0;
%         end
%         pai{ii}(1,i)=val_Pai;
%         pai{ii}(2,i)=status;
%     end
    f = adi.readFile(files{ii});
    ECG_chan = f.getChannelByName('4');
    raw_ECG_data = EEG_chan.getData(1); %Get data from the first record
    ECG = raw_ECG_data';
    Fs = Sampling_Frequency;
    desiredFs = 400;
    window_size=1/6;      %min
    size_matrix=floor(length(ECG)/(window_size*60*desiredFs))-1;
    if size_matrix<=2
        continue
    end
    
        MI_raw_matrix=zeros(window_size*60*desiredFs+96,size_matrix);
        Power_raw_matrix=zeros(window_size*60*desiredFs,size_matrix);
        [p,q] = rat(desiredFs / Fs);
        ECG = resample(ECG,p,q);
    for i = 1:floor(length(ECG)./(window_size*60*desiredFs))-1
        signal = ECG((i-1)*400*10+1:(i-1)*400*10+4096);
        val = predict(ECG_Model_DNN, signal');
        val_class = predict(ECG_Model_DNN,signal','ReturnCategorical',1);


        %     if val_Pai >= threshold_ECG
        %         status = 1;
        %     else
        %         status = 0;
        %     end
        ECG_class{ii}(1,i) = val_class;
        ECG_Pai {ii}(1:2,i)= val;
    end
end