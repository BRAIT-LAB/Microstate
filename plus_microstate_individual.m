clear;  clc;
EEGdir = 'G:\SEED_ICA\all\jl1';
EEGFiles = dir(fullfile(EEGdir, '*.set')); % load the data
data = pop_loadset('filename',EEGFiles(15).name,'filepath',EEGdir);
% 手动
ms = microstate.individual ;    % 创建一个空白的单独对象
ms = ms.import_eeglab(data);    
% 自动
timeseries = data.data' ; % time series in column format  列格式的时间序列
timeaxis = data.times ; % time axis   时间轴
ms_manualimport = microstate.individual(timeseries,'eeg',timeaxis);
% ms.plot('gfp')

%% 微状态分析
% Perform microstate analysis
rng('default') % for reproducibility
ms = ms.cluster_estimatemaps(4) ;   % 运行K-means聚类
%% 分析可视化微状态数据
% Call layout creator from the command line     从命令行调用布局创建器
template = 'eeg1020' ; % Use the EEG 10-20 system template
labels = {'Fp1'; 'Fpz'; 'Fp2'; 'AF3'; 'AF4'; 'F7'; 'F5'; 'F3'; 'F1'; 'Fz'; 'F2'; 'F4'; 'F6'; 'F8';...
'FT7'; 'FC5'; 'FC3'; 'FC1'; 'FCz'; 'FC2'; 'FC4'; 'FC6'; 'FT8'; 'T3'; 'C5'; 'C3'; 'C1'; ...
'Cz'; 'C2'; 'C4'; 'C6'; 'T4'; 'TP7'; 'CP5'; 'CP3'; 'CP1'; 'CPz'; 'CP2'; 'CP4'; 'CP6'; ...
'TP8'; 'T5'; 'P5'; 'P3'; 'P1'; 'Pz'; 'P2'; 'P4'; 'P6'; 'T6'; 'PO7'; 'PO5'; 'PO3'; 'POz'; ...
'PO4'; 'PO6'; 'PO8'; 'O1h'; 'O1'; 'Oz'; 'O2'; 'O2h'}; % equivalent to data.label      相当于 data.label
layout = microstate.functions.layout_creator(template,labels);
ms.plot('maps',layout);
%%
ms = ms.stats_all ;
% [p,confusion_matrix,networks] = ms.networks_plv([8,13]) ;    % 微状态分段功能连接模式
% 验证微状态模式和不同锁相模式显著相关的假设有用，p和confusion_matrix是多元模式分析假设检验的p值和混淆矩阵，networks包含从每个微观状态导出的网络
ms.plot('maps')