%% This is a modified version of the original code
clear all;%close all;
dataset = 'PASCAL_S'; % change the name of the dataset to test on
methods = {'CPD', 'HS', 'DRFI', 'ELD'};
methods_colors = distinguishable_colors(length(methods));
figure
fig_title = ['MAE on ', dataset];
%hold on
num = length(methods);
MAE_all = zeros(num,1);
for m = 1:num
	readpath = ['./results/', methods{m}, '/', dataset, '/MAE/']; 
	mae_file = [methods{m}, '_', dataset, '_MAE.mat'];
    load(strcat(readpath,mae_file));
    MAE_all(m) = MAE;
end
bar(MAE_all, 'b');
title(fig_title);
%hold off;
grid on;
set(gca,'YLim',[0 0.45]); 
set(gca,'YTick',0:0.05:0.45);
set(gca,'xticklabel',methods);
xlabel('Methods');
ylabel('MAE');
%ylabel('Mean Absolute Error');
