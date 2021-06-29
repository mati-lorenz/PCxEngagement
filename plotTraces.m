%% Load decimated traces
Gtype = "SST";
mouseID= 1;
filename = 'E:\Ephys\ePCx';
load(append(filename,sprintf('/decim%s%d.mat',Gtype,mouseID)), 'dtraces')

%% PLOT TRACES without common average referencing (CAR)
chn_separation=6;
figure
subplot(121)
colors = brewermap(9,'Set1');
pcx = zscore(dtraces.pcx,[],2);
ob = zscore(dtraces.ob,[],2);
res = zscore(dtraces.res);
for channel=1:10
    plot(pcx(channel,:)+channel*chn_separation,'color',colors(1,:));hold on
end
for channel=11:21
    plot(pcx(channel,:)+channel*chn_separation,'color',colors(2,:));hold on
end
for channel=22:32
    plot(pcx(channel,:)+channel*chn_separation,'color',colors(3,:));hold on
end
for channel=33:43
    plot(pcx(channel,:)+channel*chn_separation,'color',colors(4,:));hold on
end
for channel=44:54
    plot(pcx(channel,:)+channel*chn_separation,'color',colors(5,:));hold on
end
for channel=55:64
    plot(pcx(channel,:)+channel*chn_separation,'color',colors(7,:));hold on
end


plot(res-chn_separation,'color',colors(9,:));hold on
plot(dtraces.LTTL-2*chn_separation,'color',colors(9,:));hold on


set(gcf,'color','white', 'PaperPositionMode', 'auto');
set(gca, 'box', 'off', 'tickDir', 'out', 'fontname', 'helvetica', 'fontsize', 14)
axis off
title('LFP PCx - No CAR')


subplot(122)
for channel=1:32
    plot(ob(channel,:)+channel*chn_separation,'color',colors(8,:));hold on
end

plot(res-chn_separation,'color',colors(9,:));hold on
plot(dtraces.LTTL-2*chn_separation,'color',colors(9,:));hold on

set(gcf,'Position',[33 100 2000 1200]);
set(gcf,'color','white', 'PaperPositionMode', 'auto');
set(gca, 'box', 'off', 'tickDir', 'out', 'fontname', 'helvetica', 'fontsize', 14)
axis off
title('LFP OB')

%% PLOT TRACES with common average referencing (CAR)
figure
subplot(121)
colors = brewermap(9,'Set1');
rpcx = zscore(pcx - median(pcx,1),[],2);
rob = zscore(ob - median(ob,1),[],2);

for channel=1:10
    plot(rpcx(channel,:)+channel*chn_separation,'color',colors(1,:));hold on
end
for channel=11:21
    plot(rpcx(channel,:)+channel*chn_separation,'color',colors(2,:));hold on
end
for channel=22:32
    plot(rpcx(channel,:)+channel*chn_separation,'color',colors(3,:));hold on
end
for channel=33:43
    plot(rpcx(channel,:)+channel*chn_separation,'color',colors(4,:));hold on
end
for channel=44:54
    plot(rpcx(channel,:)+channel*chn_separation,'color',colors(5,:));hold on
end
for channel=55:64
    plot(rpcx(channel,:)+channel*chn_separation,'color',colors(7,:));hold on
end


plot(res-chn_separation,'color',colors(9,:));hold on
plot(dtraces.LTTL-2*chn_separation,'color',colors(9,:));hold on


set(gcf,'color','white', 'PaperPositionMode', 'auto');
set(gca, 'box', 'off', 'tickDir', 'out', 'fontname', 'helvetica', 'fontsize', 14)
axis off
title('LFP PCx - CAR')


subplot(122)
for channel=1:32
    plot(rob(channel,:)+channel*chn_separation,'color',colors(8,:));hold on
end

plot(res-chn_separation,'color',colors(9,:));hold on
plot(dtraces.LTTL-2*chn_separation,'color',colors(9,:));hold on

set(gcf,'Position',[33 100 2000 1200]);
set(gcf,'color','white', 'PaperPositionMode', 'auto');
set(gca, 'box', 'off', 'tickDir', 'out', 'fontname', 'helvetica', 'fontsize', 14)
axis off
title('LFP OB')