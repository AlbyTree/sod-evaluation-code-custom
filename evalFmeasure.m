%% This is a modified version of the original code
clear all
close all;clc;

methods = {'HS', 'DRFI', 'CPD', 'ELD'};
datasets = {'PASCAL_S', 'ECSSD', 'DUTS_Test', 'HKU_IS', 'DUT_OMRON'};
for dataset_id = 1:length(datasets)
    for method_id = 1:length(methods)
        fprintf('Evaluate %s on %s\n', methods{method_id}, datasets{dataset_id});
		savepath = ['./results/', methods{method_id}, '/', datasets{dataset_id}, '/', 'F_Measure/']; % save path of the 256 combinations of precision-recall values
		if ~exist(savepath,'dir')
			mkdir(savepath);
		end
		results_pr_path = ['./results/', methods{method_id}, '/', datasets{dataset_id}, '/PRcurve/'];
		pr_file = [methods{method_id}, '_', datasets{dataset_id}, '_PRCurve.txt'];
		pr_file_path = [results_pr_path, pr_file];
		PR_list = load(pr_file_path);
		%f_m = double.empty();
		%for i = 1:length(PR_list)
		%	p = PR_list(i, 1);
		%	r = PR_list(i, 2);
		%	f_m(i) = 1.3*p*r/(0.3*p+r);
		%end
		p = PR_list(:, 1);
		r = PR_list(:, 2);
		f_m = 1.3.*p.*r./(0.3.*p+r);
		average_f_m = mean(f_m);
		max_f_m = max(f_m);
		fprintf(' max fmeasure=%f\n',max_f_m);
        
        save([savepath methods{method_id} '_' datasets{dataset_id} '_F_Measure'],'p','r','f_m');
 		av_f_m_file = fopen([savepath methods{method_id} '_' datasets{dataset_id} '_Average_F_Measure.txt'], 'wt');
        fprintf(av_f_m_file, '%f\n', average_f_m);
        max_f_m_file = fopen([savepath methods{method_id} '_' datasets{dataset_id} '_Max_F_Measure.txt'], 'wt');
		fprintf(max_f_m_file, '%f\n', max_f_m);
 		disp('Done');
    end
end
