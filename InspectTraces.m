% INSPECT TRACES
clear;clc;
tic
%Folders.folderList = uipickfiles( 'Output', 'struct');
cd('E:\Ephys\ePCx');
load('FoldersMice.mat')

% SELECT SOME PARAMETERS:
Genotype = "SST"; % WT SST PV
mouse = 2; % WT 4 6 7 9 10 12 20 SST 1 2 3 4 PV 2 3 5 6 7
window = 1:9900000; % window to load 30kS/s


% % % % % % % Select the folders of the chosen mouse
mouse_num = sprintf("M%d",mouse);
pattern = [mouse_num , Genotype];

for folder_num = 1:size(Folders.folderList,1)
folders_mouse(folder_num) = contains(Folders.folderList(folder_num).name,pattern(1)) && contains(Folders.folderList(folder_num).name,pattern(2));
end
folders_mouse = find(folders_mouse);

rootOB = fullfile(Folders.folderList(folders_mouse(1)).name,'ExtractedData');
rootPCx = fullfile(Folders.folderList(folders_mouse(2)).name,'ExtractedData');
% % % % % % %

% load OB LFP traces
cd(rootOB)

for channel = 1:32
    dataName = sprintf('CSC%d.mat',channel);
    m = matfile(dataName);
    SamplesOB(channel,:) = m.samples(1,window);
end

% load respiration
dataName = 'ADC1.mat';
m = matfile(dataName);
Resp = m.ADC(1,window);

% load PCx LFP traces
cd(rootPCx)

for channel = 1:64
    dataName = sprintf('CSC%d.mat',channel);
    m = matfile(dataName);
    SamplesPCx(channel,:) = m.samples(1,window);
end
TimeStamps = m.timestamps(1,window); % only for one channel, they are all the same



% Downsample and Filter All Data
samplingFrequency = 30000;
samplingFrequencyLFP = 1000;
r = samplingFrequency/samplingFrequencyLFP;
TimeStamps = decimate(TimeStamps, r);


% for OB
for channel = 1:32
lfp = [];
lfp = decimate(SamplesOB(channel,:), r);
lfp = [TimeStamps' lfp'];
lfp = Filter(lfp, 'passband', [0.5 100]);
LFP_OB(channel,:) = lfp(:,2);
end

% for PCx
for channel = 1:64
lfp = [];
lfp = decimate(SamplesPCx(channel,:), r);
lfp = [TimeStamps' lfp'];
lfp = Filter(lfp, 'passband', [0.5 100]);
LFP_PCx(channel,:) = lfp(:,2);
end

% for respiration
resp = [];
resp = decimate(Resp, r);
resp = [TimeStamps' resp'];
resp = Filter(resp, 'passband', [0.5 100]);
Resp = resp(:,2);

% % % % Reorder the channels based on the Assy7F Probe numbers
% % ASSY7F_channels =  [29 22 2 5 0 24 30 4 27 6 3 8 1 17 7 15 28 13 26 10 31 18 16 20 9 19 ...
% %        11 21 12 23 14 25 44 42 46 45 55 43 53 38 50 40 48 61 63 54 41 47 34 49 36 51 33 52 ...
% %        56 35 57 60 59 62 39 32 58 37]';
% %    
% % LFP_PCx = [ASSY7F_channels, LFP_PCx];
% % LFP_PCx = sortrows(LFP_PCx);
% % LFP_PCx = LFP_PCx(:,2:end);

% % ZSCORE TRACES
for channel = 1:64
    LFP_PCx(channel,:) = zscore(LFP_PCx(channel,:));
end
for channel = 1:32
    LFP_OB(channel,:) = zscore(LFP_OB(channel,:));
end
Resp = zscore(Resp);

n=6;

% PLOT TRACES AND MEAN CORRELATION 
figure
subplot(121)
colors = brewermap(9,'Set1');

for channel=1:10
    plot(LFP_PCx(channel,:)+channel*n,'color',colors(1,:));hold on
end
for channel=11:21
    plot(LFP_PCx(channel,:)+channel*n,'color',colors(2,:));hold on
end
for channel=22:32
    plot(LFP_PCx(channel,:)+channel*n,'color',colors(3,:));hold on
end
for channel=33:43
    plot(LFP_PCx(channel,:)+channel*n,'color',colors(4,:));hold on
end
for channel=44:54
    plot(LFP_PCx(channel,:)+channel*n,'color',colors(5,:));hold on
end
for channel=55:64
    plot(LFP_PCx(channel,:)+channel*n,'color',colors(7,:));hold on
end


plot(Resp-n,'color',colors(9,:));hold on


set(gcf,'color','white', 'PaperPositionMode', 'auto');
set(gca, 'box', 'off', 'tickDir', 'out', 'fontname', 'helvetica', 'fontsize', 14)
axis off
title('LFP PCx')


subplot(122)
for channel=1:32
    plot(LFP_OB(channel,:)+channel*n,'color',colors(8,:));hold on
end

plot(Resp-n,'color',colors(9,:));hold on

set(gcf,'Position',[33 100 2000 1200]);
set(gcf,'color','white', 'PaperPositionMode', 'auto');
set(gca, 'box', 'off', 'tickDir', 'out', 'fontname', 'helvetica', 'fontsize', 14)
axis off
title('LFP OB')

toc


% figure
% for channel=1:32
%     plot(LFP_OB(channel,:)+channel*n,'color',colors(2,:));hold on
%     plot(Resp+channel*n,'color',colors(1,:));hold on
% end
% 
% figure
% plot(LFP_OB')
%
% figure
% subplot(121)
% plot(LFP_OB(:,1000:3000)')
% subplot(122)
% plot(LFP_PCx([10 21 32 43 54 64 ],1000:3000)')
%
