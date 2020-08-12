%% This is a modified version of the original code
clear all;%close all;
dataset = 'ECSSD'; % name of the dataset
methods = {'CPD', 'HS', 'DRFI', 'ELD'};
methods_colors = distinguishable_colors(length(methods));

%% load PRCurve.txt and draw PR curves
figure
hold on
for m = 1:length(methods)
	readpath = ['./results/', methods{m}, '/', dataset, '/F_Measure/']; 
	pr_file = [methods{m}, '_', dataset, '_F_Measure.mat'];
    prFileName = [readpath, pr_file];
    load(prFileName);
    thresholds = [0:255];
    plot(thresholds, f_m,'color',methods_colors(m,:),'linewidth',2);
end
set(gca,'XTick',[0 51 102 153 204 255]);
set(gca,'XTickLabel',get(gca,'XTick'));
axis([0 255 0 1]);
hold off
grid on;
legend(methods, 'Location', 'SouthWest');
xlabel('Thresholds','fontsize',12);
ylabel('F-Measure','fontsize',12);
