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
%% 数据整合
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
%% 整体数据分成训练集和测试集
indices     = crossvalind('Kfold', max(size(data,1)), 10);%将数据样本随机分割为10部分，将数据集划分为10个大小相同的互斥子集
%K折交叉验证：每次将其中一个包作为测试集，剩下k-1个包作为训练集进行训练。
%计算k次求得的分类率的平均值，作为该模型或者假设函数的真实分类率。
%unidrnd是离散均匀随机数
%             randIndex   =unidrnd(10);%循环5次，分别取出第i（i取1.2.3.4.5中的任意一个）部分作为测试样本，其余4部分作为训练样本。
svmpredictlable = cell(10,1);
knnpredictlabel = cell(10,1);
accuracy_svm = zeros(10,3);
accuracy_knn = zeros(10,1);
accuracy_rf = zeros(10,1);
for i = 1:1:10
test        = (indices == i);
train       = ~test;%1：表示该组数据被选中，0：未被选中
traindata   = data(train, :);
testdata    = data(test, :);
train_label = label(train,:);%label数组存放情感的三种分类情况
test_label  =label(test,:);
% %% 特征选择
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
% %% 支持向量机测试
% %参数寻优
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
    %% KNN测试
[knnpredict_label] = KNN(newtrainX,newtrainY,newtestX, 3);
[corrPredictions, accuracyk] =  Misclassification_accuracy(newtestY, knnpredict_label);
accuracy_knn(i,:) = accuracyk;
knnpredictlabel{i,1} = knnpredict_label;
end
mean_accuracys =mean(accuracy_svm(:,1));
mean_accuracyk = mean(accuracy_knn);
mean_accuracyrf = mean(accuracy_rf);