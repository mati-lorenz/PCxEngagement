clear;clc;
tic
%%
Gtype = "PV";
mouseID= 2;
window = 1:30000*1802;
if Gtype~="WT"
    window = window + 16190000;
end
finalsmplrate = 100;

%Folders.folderList = uipickfiles( 'Output', 'struct');
filename = 'E:\Ephys\ePCx';
cd(filename);
load('FoldersMice.mat')

%% SELECT SOME PARAMETERS:
Genotype = Gtype; % WT SST PV
mouse = mouseID; % WT 4 6 7 9 10 12 20 SST 1 2 3 4 PV 2 3 5 6 7

%  Select the folders of the chosen mouse
mouse_num = sprintf("M%d",mouse);
pattern = [mouse_num , Genotype];


for folder_num = 1:size(Folders.folderList,1)
    folders_mouse(folder_num) = contains(Folders.folderList(folder_num).name,pattern(1)) && contains(Folders.folderList(folder_num).name,pattern(2));
end
folders_mouse = find(folders_mouse);

rootOB = fullfile(Folders.folderList(folders_mouse(1)).name,'ExtractedData');
rootPCx = fullfile(Folders.folderList(folders_mouse(2)).name,'ExtractedData');

%% load OB LFP traces
cd(rootOB)
SamplesOB=zeros(32,size(window,2));
for channel = 1:32
    dataName = sprintf('CSC%d.mat',channel);
    m = matfile(dataName);
    SamplesOB(channel,:) = m.samples(1,window);
end

% load respiration
dataName = 'ADC1.mat';
m = matfile(dataName);
resp = m.ADC(1,window);

% load light TTLs
dataName = 'DIG2.mat';
m = matfile(dataName);
lightTTL = m.Dig_inputs(1,window);

% load PCx LFP traces
cd(rootPCx)
SamplesPCx=zeros(64,size(window,2));
for channel = 1:64
    dataName = sprintf('CSC%d.mat',channel);
    m = matfile(dataName);
    SamplesPCx(channel,:) = m.samples(1,window);
end
TimeStamps = m.timestamps(1,window); % only for one channel, they are all the same



%% Downsample and Filter All Data
samplingFrequency = 30000;
samplingFrequencyLFP = finalsmplrate;
r = samplingFrequency/samplingFrequencyLFP;
TimeStamps = downsample(TimeStamps, r);


%% for OB
LFP_OB=zeros(32,ceil(size(window,2)/r));
for channel = 1:32
lfp = decimate(SamplesOB(channel,:), r);
lfp = [TimeStamps' lfp'];
lfp = Filter(lfp, 'passband', [0.5 30]);
LFP_OB(channel,:) = lfp(:,2);
end

% for PCx
LFP_PCx=zeros(64,ceil(size(window,2)/r));
for channel = 1:64
lfp = decimate(SamplesPCx(channel,:), r);
lfp = [TimeStamps' lfp'];
lfp = Filter(lfp, 'passband', [0.5 30]);
LFP_PCx(channel,:) = lfp(:,2);
end

% for respiration
Resp = decimate(resp, r);
Resp = [TimeStamps' Resp'];
Resp = Filter(Resp, 'passband', [0.5 30]);
Resp = Resp(:,2);
LightTTL = lightTTL(1:r:end);


% clearvars SamplesOB SamplesPCx lfp resp

%% ZSCORE TRACES
% dtraces=[];
% dtraces.rpcx = zscore(rLFP_PCx,[ ], 2);
% dtraces.rob  = zscore(rLFP_OB, [ ], 2);
% dtraces.pcx  = zscore(LFP_PCx,[ ], 2);
% dtraces.ob   = zscore(LFP_OB, [ ], 2);
% dtraces.res  = zscore(Resp);
% dtraces.LTTL = zscore(LightTTL);
% dtraces.time = zscore(TimeStamps);
% 
% dtraces.fsampling = samplingFrequencyLFP;
% dtraces.Gtype = Gtype;
% dtraces.mouseID = mouseID;

%% make final struct
dtraces=[];
dtraces.ob   = LFP_OB;
dtraces.pcx   = LFP_PCx;
dtraces.res  = Resp;
dtraces.LTTL = LightTTL;
dtraces.time = TimeStamps;

dtraces.fsampling = samplingFrequencyLFP;
dtraces.Gtype = Gtype;
dtraces.mouseID = mouseID;
%% Save
save(append(filename,sprintf('/decim%s%d.mat',Gtype,mouseID)), 'dtraces')
toc