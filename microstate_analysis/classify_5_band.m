clear;  clc;
%delta
load('G:\SEED_ICA\prepro_pipeline2\5_band\xyl1\delta\coverage.mat')
load('G:\SEED_ICA\prepro_pipeline2\5_band\xyl1\delta\duration.mat')
load('G:\SEED_ICA\prepro_pipeline2\5_band\xyl1\delta\occurence.mat')
load('G:\SEED_ICA\prepro_pipeline2\5_band\xyl1\delta\TP_all.mat')
data_delta = feature_fusion(coverage, duration, occurence, TP_all);
%theta
load('G:\SEED_ICA\prepro_pipeline2\5_band\xyl1\theta\coverage.mat')
load('G:\SEED_ICA\prepro_pipeline2\5_band\xyl1\theta\duration.mat')
load('G:\SEED_ICA\prepro_pipeline2\5_band\xyl1\theta\occurence.mat')
load('G:\SEED_ICA\prepro_pipeline2\5_band\xyl1\theta\TP_all.mat')
data_theta = feature_fusion(coverage, duration, occurence, TP_all);
%alpha
load('G:\SEED_ICA\prepro_pipeline2\5_band\xyl1\alpha\coverage.mat')
load('G:\SEED_ICA\prepro_pipeline2\5_band\xyl1\alpha\duration.mat')
load('G:\SEED_ICA\prepro_pipeline2\5_band\xyl1\alpha\occurence.mat')
load('G:\SEED_ICA\prepro_pipeline2\5_band\xyl1\alpha\TP_all.mat')
data_alpha = feature_fusion(coverage, duration, occurence, TP_all);
%beta
load('G:\SEED_ICA\prepro_pipeline2\5_band\xyl1\beta\coverage.mat')
load('G:\SEED_ICA\prepro_pipeline2\5_band\xyl1\beta\duration.mat')
load('G:\SEED_ICA\prepro_pipeline2\5_band\xyl1\beta\occurence.mat')
load('G:\SEED_ICA\prepro_pipeline2\5_band\xyl1\beta\TP_all.mat')
data_beta = feature_fusion(coverage, duration, occurence, TP_all);
% gamma
load('G:\SEED_ICA\prepro_pipeline2\5_band\xyl1\gamma\coverage.mat')
load('G:\SEED_ICA\prepro_pipeline2\5_band\xyl1\gamma\duration.mat')
load('G:\SEED_ICA\prepro_pipeline2\5_band\xyl1\gamma\occurence.mat')
load('G:\SEED_ICA\prepro_pipeline2\5_band\xyl1\gamma\TP_all.mat')
data_gamma = feature_fusion(coverage, duration, occurence, TP_all);
%% 
data = [data_delta, data_theta, data_alpha, data_beta, data_gamma];
% data = data_alpha;
[data_sta, ps] = mapminmax(data',-1,1);
data = data_sta';
len = size(data,1);
label = zeros(len,1);
for i = 1:1:215
label(i,:) = 1;
label(i+215,:) = 2;
label(i+215*2,:) = 3;
end
data = data(:,any(data));
%% 
indices     = crossvalind('Kfold', max(size(data,1)), 10);
%unidrnd
%             randIndex   =unidrnd(10);
svmpredictlable = cell(10,1);
knnpredictlabel = cell(10,1);
accuracy_svm = zeros(10,3);
accuracy_knn = zeros(10,1);
accuracy_rf = zeros(10,1);
for i = 1:1:10
test        = (indices == i);
train       = ~test;
traindata   = data(train, :);
testdata    = data(test, :);
train_label = label(train,:);
test_label  =label(test,:);
% %% 
% [ranks,weights] = relieff(traindata,train_label,3,'method','classification');
% index = find(weights>0.06);
% traindata = traindata(:,index);
% testdata = testdata(:, index);
%%
newtrainX=[];newtrainY=[];newtestX=[];newtestY=[];
perm1=randperm(length(traindata(:,1)));
newtrainX(:,:)=traindata(perm1,:);
newtrainY(:,:)=train_label(perm1,:);
perm2=randperm(length(testdata(:,1)));
newtestX(:,:)=testdata(perm2,:);
newtestY(:,:)=test_label(perm2,:);
% %% 
% %
% %     bestcv = 0;
% %     for log2c = -4:12
% %         for log2g = -8:4
% %             cmd = ['-v 5 -c', num2str(2^log2c), '-g', num2str(2^log2g)];
% %             cv = svmtrain(newtrainY, newtrainX,cmd);
% %             if(cv >= bestcv)
% %                 bestcv = cv;  bestc = 2^log2c;  bestg = 2^log2g;
% %             end
% %         end
% %     end
% %     cmd = ['-t 2 -v 5','-c', num2str(2^log2c), '-g', num2str(2^log2g)];
% model = svmtrain(newtrainY, newtrainX, '-s 0 -t 0');
% [svmpredict_label, accuracys, ~] = svmpredict(newtestY, newtestX, model);
% accuracy_svm(i,:) = accuracys;
% svmpredictlable{i,1} = svmpredict_label;
    %% KNN
[knnpredict_label] = KNN(newtrainX,newtrainY,newtestX, 3);
[corrPredictions, accuracyk] =  Misclassification_accuracy(newtestY, knnpredict_label);
accuracy_knn(i,:) = accuracyk;
knnpredictlabel{i,1} = knnpredict_label;
end
mean_accuracys =mean(accuracy_svm(:,1));
mean_accuracyk = mean(accuracy_knn);
mean_accuracyrf = mean(accuracy_rf);
