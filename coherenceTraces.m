%% Load decimated traces
Gtype = "SST";
mouseID= 1;
filename = 'E:\Ephys\ePCx';
load(append(filename,sprintf('/decim%s%d.mat',Gtype,mouseID)), 'dtraces')

%% Throw out channels with big outliers
outlier_channels_pcx = [];
n = 1;
for i = 1:64
    extr_value = max(abs(dtraces.pcx(i,:)),[ ],2);
    st_dev = std(dtraces.pcx(i,:),[ ],2);
    if(any(extr_value >=5*st_dev))
        outlier_channels_pcx(n) = i;
        n = n+1;
    end
end
good_channels_pcx = setdiff(1:64,outlier_channels_pcx);

outlier_channels_ob = [];
n = 1;
for i = 1:32
    extr_value = max(abs(dtraces.ob(i,:)),[ ],2);
    st_dev = std(dtraces.ob(i,:),[ ],2);
    if(any(extr_value >=6*st_dev))
        outlier_channels_ob(n) = i;
        n = n+1;
    end
end
good_channels_ob = setdiff(1:32,outlier_channels_ob);

%% Pick a channel
chanOB  = randsample(good_channels_ob,1);
chanPCx = randsample(good_channels_pcx,1);

%% Cut trials Exp1
Fs = dtraces.fsampling;
E = find(diff(dtraces.LTTL)>0.5);
winEvent  =[90, 5];
if E(1)< winEvent(1)*Fs
    E=E(2:end);
end

trialedDataExp1 = zeros(3,sum(winEvent)*Fs,15);
trialedDataExp1(1,:,1:size(E,2)) = createdatamatc(Resp, E/Fs, Fs, winEvent);
trialedDataExp1(2,:,1:size(E,2)) = createdatamatc(dtraces.ob(chanOB,:)', E/Fs, Fs, winEvent);
trialedDataExp1(3,:,1:size(E,2)) = createdatamatc(dtraces.pcx(chanPCx,:)', E/Fs, Fs, winEvent);
%% Choose trials Exp1
% Throw out trials with big outliers
outlier_trials = [];
n = 1;
for i = 1:size(E,2)
    extr_value = max(abs(trialedDataExp1(:,:,i)),[ ],2);
    st_dev = std(trialedDataExp1(:,:,i),[ ],2);
    if(any(extr_value >=6*st_dev))
        outlier_trials(n) = i;
        n = n+1;
    end
end
data = trialedDataExp1(:,:,setdiff(1:size(E,2),outlier_trials));
data = zscore(data, [ ], 2);

%% Cut trials Exp2
% TODO
% The olf TTLs are missing

E = find(diff(TODOolfdecimated)>0.5);
if E(1)< winEvent(1)*samplingFrequencyLFP
    E=E(2:end);
end

trialedDataExp2 = zeros(3,sum(winEvent)*Fs,60);
trialedDataExp2(1,:,:) = createdatamatc(Resp, E/Fs, Fs, winEvent);
trialedDataExp2(2,:,:) = createdatamatc(dtraces.ob(chanOB,:), E/Fs, Fs, winEvent);
trialedDataExp2(3,:,:) = createdatamatc(dtraces.pcx(chanPCx,:), E/Fs, Fs, winEvent);


%% Spectrograms and coherograms
params.Fs = Fs;
endBaseline =params.Fs*winEvent(1);
params.trialave = 1;
params.err = 0;
params.tapers = [2 3];
params.fpass = [0.5 30];

movingwin = [2 0.5];
[ctmp,~,~,~,~,timogram,freqogram]=cohgramc(squeeze(data(1,:,:)),...
    squeeze(data(2,:,:)),movingwin,params);

coherograms        = zeros(3,size(ctmp,1),size(ctmp,2));
phase_throug_time  = zeros(size(coherograms));
cross_spectrograms = zeros(size(coherograms));
spectrograms       = zeros(size(coherograms));


[coherograms(1,:,:),phase_throug_time(1,:,:),cross_spectrograms(1,:,:),...
    spectrograms(1,:,:),spectrograms(2,:,:),~,~]=cohgramc(squeeze(data(1,:,:)),squeeze(data(2,:,:)),movingwin,params);
[coherograms(2,:,:),phase_throug_time(2,:,:),cross_spectrograms(2,:,:),...
    ~,spectrograms(3,:,:),~,~]=cohgramc(squeeze(data(1,:,:)),squeeze(data(3,:,:)),movingwin,params);
[coherograms(3,:,:),phase_throug_time(1,:,:),cross_spectrograms(3,:,:),...
    ~,~,~,~]=cohgramc(squeeze(data(2,:,:)),squeeze(data(3,:,:)),movingwin,params);

%% Plot spectrograms and coherograms
coh_titles = ["Coh Res-OB" "Coh Res-PCx" "Coh OB-PCx"];
for i =1:3
    figure
    plot_matrix(squeeze(coherograms(i,:,:)),timogram,freqogram,'n')
    title(coh_titles(i))
end

spec_titles = ["Spectr Res" "Spectr OB" "Spectr PCx"];
for i =1:3
    figure
    plot_matrix(squeeze(spectrograms(i,:,:)),timogram,freqogram,'l')
    title(spec_titles(i))
end

