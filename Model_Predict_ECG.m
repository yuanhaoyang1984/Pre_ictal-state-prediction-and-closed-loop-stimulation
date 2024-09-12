function [val_Pai,status] = Model_Predict_ECG(signal,threshold_ECG)
global ECG_Model_DNN
global ECG_Model_FCN
global Sampling_Frequency
val = predict(ECG_Model_DNN, signal);
val_class = predict(ECG_Model,signal,'ReturnCategorical',1)-1;

val_Pai = sim(ECG_Model_FCN,val);    
if val_Pai >= threshold_ECG
        status = 1;
    else 
        status = 0;
    end
end