% matrix_all=[];
% n=size(train_matrix_all,1)/33;
% for i=1:size(train_matrix_all,1)/33
%     matrix_all=[matrix_all,train_matrix_all((i-1)*33+1:i*33,1:24)];
% end
% 
% a=floor(timestamp/(300))+1;
% b=a+1;
% 
% 
status=zeros(1,573);
status(a)=1;
% status(b)=1;
for i=1:20
    status(a-i)=1;
end
train_m=matrix_all;
label_matrix=status;
% status = zeros(1,data_size);
trainFcn = 'trainlm'
% trainFcn = 'trainscg'
hiddenLayerSize = 33;
% net =  fitnet([hiddenLayerSize hiddenLayerSize],trainFcn);
net = patternnet([hiddenLayerSize hiddenLayerSize hiddenLayerSize hiddenLayerSize hiddenLayerSize hiddenLayerSize],trainFcn);
% Setup Division of Data for Training, Validation, Testing
RandStream.setGlobalStream(RandStream('mt19937ar','seed',1)); % to get constant result
net.divideFcn = 'dividerand'; % Divide targets into three sets using blocks of indices
net.divideParam.trainRatio = 60/100;
net.divideParam.valRatio = 20/100;
net.divideParam.testRatio = 20/100;
%TRAINING PARAMETERS
net.trainParam.show=50;  % of ephocs in display
net.trainParam.lr=0.01;  % learning rate
net.trainParam.epochs=200;  % max epochs
net.trainParam.goal=1e-5;  % training goal
net.performFcn='crossentropy';  % Name of a network performance function %type help nnperformance
% net.numLayers = 3      % 创建更多的隐藏层以及添加激活层函数
% net.layers{i}.name  
% net.layerConnect(3,2) = 1;
% net.outputConnect = [0 0 1];
% net.layers{2}.size = 1;
% net.layers{2}.transferFcn = 'tansig';
% Train the Network
[net,tr] = train(net,train_m,label_matrix,'useParallel','yes','showResources','yes'); 
% Test the Network

% View the Network
% view(net)
y = net(train_m);
% val = sim(net,train_m);
% classes = vec2ind(val);                     %将分类结果转换为class
% r = sum(classes == label2class(TEST_labels'))/(size(train_m,2));  %计算正确率
figure
plot(y)
class=round(y);

% e = gsubtract(t,y);
performance = perform(net,label_matrix,y)
figure
k=smoothdata(y(4*24+1:6*24),'gaussian',2);
plot(smoothdata(y(4*24+1:6*24),'gaussian',2),'Color','black')
hold on
plot(23:27,k(23:27),'Color',[1 0 0])
hold on 
plot(33:37,k(33:37),'Color',[1 0 0])

neuro_stat=zeros(1,24*n);
y_1=find(status==1);
y_0=find(status==0);
pro_onset=y(y_1);
resting=y(y_0);