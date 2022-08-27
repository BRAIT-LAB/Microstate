function [EEG_psd, EEG_psdall] = EEG_PSD_modify(data, welch_window_size, long, Fs)
% welch_window_size = 1000;  Fs = 200;
for chan = 1:62
      [PowerTrial,fTrial] = spectrogram(data(chan,:),welch_window_size,[],[],Fs);
       PowerTrial = 10*log10(abs(PowerTrial));
       psd_delta0 = mean(PowerTrial((fTrial>=1 & fTrial<=3),:),1);
       psd_theta0 = mean(PowerTrial((fTrial>=4 & fTrial<=7),:),1);
       psd_alpha0 = mean(PowerTrial((fTrial>=8 & fTrial<=12),:),1);
       psd_beta0 = mean(PowerTrial((fTrial>=13 & fTrial<=30),:),1);
       psd_gamma0 = mean(PowerTrial((fTrial>=31 & fTrial<=47),:),1);
       psd_all0 = mean(PowerTrial((fTrial>=1 & fTrial<=47),:),1);
       psd_delta(chan) = psd_delta0;
       psd_theta(chan) = psd_theta0;
       psd_alpha(chan) = psd_alpha0;
       psd_beta(chan) = psd_beta0;
       psd_gamma(chan) = psd_gamma0;
       psd_all(chan) = psd_all0;
end
EEG_psd = [psd_delta, psd_theta, psd_alpha, psd_beta, psd_gamma];
EEG_psd = zscore(EEG_psd(:)');
EEG_psdall = psd_all;
end