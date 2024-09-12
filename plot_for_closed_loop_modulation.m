f = adi.readFile("C:\Users\czzzc\Desktop\EEG+ECG+GCaMP6s\20231109 EEG-elec 0.28.adicht");
EEG_chan = f.getChannelByName('3');
raw_EEG_data = EEG_chan.getData(1); %Get data from the first record
EEG = raw_EEG_data';
pai = zeros(2,36);
for i =1:36
    [a,b]=Model_Predict_EEG(forplot((i-1)*60*1000+1:i*60*1000),0.28);
    pai(1,i)=a;
    pai(2,i)=b;
end