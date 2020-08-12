%% A demo code to display precision-recall curve for evaluating salient object detection algorithms
% Yao Li, Jan 2014

clear all;%close all;
dataset = 'ECSSD'; % name of the dataset
methods = {'CPD', 'HS', 'DRFI', 'ELD'};
methods_colors = distinguishable_colors(length(methods));

%% load PRCurve.txt and draw PR curves
figure
hold on
for m = 1:length(methods)
	readpath = ['./results/', methods{m}, '/', dataset, '/PRcurve/']; 
	pr_file = [methods{m}, '_', dataset, '_PRCurve.txt'];
    prFileName = [readpath, pr_file];
    R = load(prFileName);
    precision = R(:, 1);
    recall = R(:, 2);
    if(strcmp(methods{m}, 'ELD'))
       max_p = max(precision);
       max_p_index = find(precision == max_p);
       p_index_to_remove = max_p_index+1;
       for i = max_p_index+1:length(precision)
          precision(p_index_to_remove) = [];
          %p_index_to_remove = p_index_to_remove-1;
       end
       r_index_to_remove = p_index_to_remove;
       for i = max_p_index+1:length(recall)
          recall(r_index_to_remove) = [];
          %p_index_to_remove = p_index_to_remove-1;
       end
    end
    plot(recall, precision,'color',methods_colors(m,:),'linewidth',2);    
end
axis([0 1 0 1]);
hold off
grid on;
legend(methods, 'Location', 'SouthWest');
xlabel('Recall','fontsize',12);
ylabel('Precision','fontsize',12);
