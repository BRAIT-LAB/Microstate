clear;  clc;

EEGdir = 'D:\SEED_ICA\ICA_reference_filter\alpha';
EEGFiles = dir(fullfile(EEGdir, '*.set')); % load the data
% Initialize an empty microstate cohort object  
coh = microstate.cohort ; 
% Loop over scans   
for i = 1:length(EEGFiles)
   
    % Make an empty microstate individual  
    ms = microstate.individual; 
    % Read in the data  
    data = pop_loadset('filename',EEGFiles(i).name,'filepath',EEGdir);
    modality = 'eeg' ; % could be 'eeg' or 'meg' instead
    ms = ms.import_eeglab(data) ;
    % Add the individual to the cohort  
    coh = coh.add_individuals(ms,'scan1',2500) ; 
end
% coh = coh.cluster_globalkoptimum('kmin',2,'kmax',40); 
% 
% or, for more info: 
% 
[coh,optimum_k,k_values,maps_all_k,gev_all_k] = coh.cluster_globalkoptimum('kmin',2,'kmax',20); 

%% 
% Call layout creator from the command line    
template = 'eeg1020' ; % Use the EEG 10-20 system template
labels = {'Fp1'; 'Fpz'; 'Fp2'; 'AF3'; 'AF4'; 'F7'; 'F5'; 'F3'; 'F1'; 'Fz'; 'F2'; 'F4'; 'F6'; 'F8';...
'FT7'; 'FC5'; 'FC3'; 'FC1'; 'FCz'; 'FC2'; 'FC4'; 'FC6'; 'FT8'; 'T3'; 'C5'; 'C3'; 'C1'; ...
'Cz'; 'C2'; 'C4'; 'C6'; 'T4'; 'TP7'; 'CP5'; 'CP3'; 'CP1'; 'CPz'; 'CP2'; 'CP4'; 'CP6'; ...
'TP8'; 'T5'; 'P5'; 'P3'; 'P1'; 'Pz'; 'P2'; 'P4'; 'P6'; 'T6'; 'PO7'; 'PO5'; 'PO3'; 'POz'; ...
'PO4'; 'PO6'; 'PO8'; 'O1h'; 'O1'; 'Oz'; 'O2'; 'O2h'}; % equivalent to data.label     
layout = microstate.functions.layout_creator(template,labels);
coh.plot('globalmaps',layout);
%%
globalmaps = coh.globalmaps ; clear coh
% Initialize an empty microstate cohort object
coh = microstate.cohort ; 
% Loop over scans
rng('default') % for reproducibility
for i = 1:length(EEGFiles)
   
    % Make an empty microstate individual   
    ms = microstate.individual; 

    % Read in the data  
    data = pop_loadset('filename',EEGFiles(i).name,'filepath',EEGdir);
    modality = 'eeg' ; % could be 'eeg' or 'meg' instead
    ms = ms.import_eeglab(data) ;

    % Add the global maps to the microstate individual
    ms.maps = globalmaps ; 

    % Backfit the globalmaps to the data
    ms = ms.cluster_alignmaps ; 

    % Calculate GEV
    ms = ms.stats_all ; 

    % Add the individual to the cohort but don't save the data
    coh = coh.add_individuals(ms,'scan1',0) ; 
end
%% 
coh = coh.cohort_stats ;
figure
coh.plot('gev');
coh.plot('duration');
