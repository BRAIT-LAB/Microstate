clear;  clc;
% Get a list of all files in the MEG-rest data directory which end in
% -rest-1.edf   获取MEG-rest数据目录中以-rest-1.edf结尾的所有文件的列表
datadir = 'E:\+microstate\microstate_toolbox-master\tutorials\tutorial2_RestingSource_Group\MEG-rest';
scan1files = dir([datadir '/*-rest-1.edf']) ; 
% Initialize an empty microstate cohort object  初始化一个空的微状态队列对象
coh = microstate.cohort ; 
% Loop over scans   循环扫描
for i = 1:length(scan1files)
    
    % Make an empty microstate individual   定义一个空的微状态个体
    ms = microstate.individual; 
    % Read in the data  读取数据
    filename = [scan1files(i).folder '/' scan1files(i).name] ; 
    modality = 'source' ; % could be 'eeg' or 'meg' instead
    ms = ms.import_edf(filename, modality) ;
    % Load in the artifacts 导入伪迹
    filename = [scan1files(i).folder '/Artifacts/artfct-' scan1files(i).name(1:end-3) 'json'] ; 
    bad_samples = artifacts_json2badsamples(filename) ; 
    % Add the artifacts 添加伪迹
    ms = ms.add_bad_samples(bad_samples) ; 
    
    % Add the individual to the cohort  将个体添加到队列
    coh = coh.add_individuals(ms,'scan1',5000) ; 
end
% coh = coh.cluster_globalkoptimum('kmin',2,'kmax',40); 
% 
% or, for more info: 
% 
[coh,optimum_k,k_values,maps_all_k,gev_all_k] = coh.cluster_globalkoptimum('kmin',2,'kmax',20); 
% 首先对个体进行聚类然后对整体数据集进行聚类
coh = coh.ind_cluster_estimatemaps(k) ; 
coh = coh.cluster_global(k,'cohortstat','maps') ; 

load('cluster_globalkoptimum_output.mat')
% Call layout creator
template = 'hcp230' ; % Use the HCP230 atlas template
labels = readcell([datadir '/ROIlabels.txt'],'Delimiter','\n'); 
layout = microstate.functions.layout_creator(template,labels) ; 
coh.plot('globalmaps',layout,'cscale',[0.5,1]) ;
globalmaps = coh.globalmaps ; clear coh
% Get a list of all MEG files in the MEG-rest data directory
allMEGfiles = dir([datadir '/*-rest-*.edf']) ; 
% Initialize an empty microstate cohort object
coh = microstate.cohort ; 
% Loop over scans
rng('default') % for reproducibility
for i = 1:length(allMEGfiles)
   
    % Make an empty microstate individual
    ms = microstate.individual; 
    % Read in the data
    filename = [allMEGfiles(i).folder '/' allMEGfiles(i).name] ; 
    modality = 'source' ; % could be 'eeg' or 'meg' instead
    ms = ms.import_edf(filename,modality) ;
    % Load in the artifacts
    filename = [allMEGfiles(i).folder '/Artifacts/artfct-' allMEGfiles(i).name(1:end-3) 'json'] ; 
    bad_samples = artifacts_json2badsamples(filename) ; 
    % Add the artifacts
    ms = ms.add_bad_samples(bad_samples) ; 
    % Add the global maps to the microstate individual
    ms.maps = globalmaps ; 
    % Backfit the globalmaps to the data
    ms = ms.cluster_alignmaps ; 
    % Calculate GEV
    ms = ms.stats_gev ; 
    % 计算功能连接
    nets(i, :) = ms.networks_wpli([8,13]) ;
    % Add the individual to the cohort but don't save the data
    scanNum = allMEGfiles(i).name(end-4) ; % 1 if first scan, 2 if 2nd scan
    condition = ['scan' scanNum] ; % scan1 if first scan, scan2 if 2nd
    coh = coh.add_individuals(ms,condition,0) ; 
end
%%  绘制GEV值
coh = coh.cohort_stats ;
figure
coh.plot('gev');
%%  绘制微状态分段功能连接
% 计算每个微状态类的平均网络
load('E:\+microstate\toolbox-master\tutorials\tutorial2_RestingSource_Group\microstate_segmented_wpli.mat')
nets_avg = average_nets(nets) ;
% 绘制每个类的平均网络
microstate.functions.networks_plot(nets_avg) ;
figure
microstate.functions.networks_plot(nets_avg, layout, 'density', 0.025);

coh.plot('duration');