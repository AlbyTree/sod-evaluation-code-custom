%% This is a modified version of the original code
clear all
close all;clc;

fprintf('COMPUTING PR\n');
methods = {'CPD', 'HS', 'DRFI', 'ELD'};

% Ordered by size except for DUT-OMRON that needs to be the last one
% so it is skipped when we test the last model ELD
datasets = {'PASCAL_S', 'ECSSD', 'HKU_IS', 'DUTS_Test', 'DUT_OMRON'};

% Keep track of what was already tested
% so it can be skipped later if needed.
% Rows = datasets, Columns = methods
already_done = [[1,1,1,1],
				[1,1,1,1],
				[1,1,1,1],
				[1,1,1,1],
				[1,1,0,0]];
% Uncomment to reset whole test
%already_done = zeros(length(datasets), length(methods));

results_CPD_path = '../ALGS/CPD/results/VGG16/model-3/';
results_others_path = '../Survey_Results/';
gt_all_path = '../DATASETS/TEST/';

fprintf('Models to test: %s\n', sprintf('%s, ', methods{:}));
fprintf('Datasets selected: %s\n', sprintf('%s, ', datasets{:}));
fprintf('CPD results path: %s\n', results_CPD_path);
fprintf('Other models path: %s\n', results_others_path);
fprintf('Ground-truth datasets path: %s\n', gt_all_path);

measure_folder_name = 'PRcurve/';
for dataset_id = 1:length(datasets)
	% Max saliency of ground-truth images
	max_saliency_val = 255;
    for method_id = 1:length(methods)
			if(already_done(dataset_id, method_id) ~= 1)
            if(strcmp(datasets{dataset_id}, 'DUT_OMRON') && strcmp(methods{method_id}, 'ELD'))
				fprintf('Skipping testing model ELD	on DUT-OMRON because it is missing 2 files!\n');
			else
				fprintf('Testing model %s on datasets %s\n', methods{method_id}, datasets{dataset_id});
				savepath = ['./results/', methods{method_id}, '/', datasets{dataset_id}, '/', measure_folder_name]; % save path of the 256 combinations of precision-recall values
				if ~exist(savepath,'dir')
					mkdir(savepath);
				end
				if(strcmp(methods{method_id}, 'CPD'))
					result_path = [results_CPD_path, datasets{dataset_id}, '/*.png'];
				else
					result_path = [results_others_path, datasets{dataset_id}, '/', methods{method_id}, '/*.png'];
				end
				dir_im = dir(result_path);
				assert(~isempty(dir_im),'No saliency map found, please check the path!');
				gt_path = [gt_all_path, datasets{dataset_id}, '/gt/', '*.png'];
				dir_tr= dir(gt_path);
				assert(~isempty(dir_tr),'No ground-truth image found, please check the path!');
				assert(length(dir_im)==length(dir_tr),'The number of saliency maps and ground-truth images are not equal!');
				fprintf('Model results path: %s\n', result_path);
				fprintf('Dataset ground-truth path: %s\n\n', gt_path);

				imNum = length(dir_tr);
				precision = zeros(256,1);
				recall = zeros(256,1);
                fprintf('STARTING NOW!\n');
				%% compute pr curve
				for i = 1:imNum
					imName = dir_tr(i).name;
					fprintf('Image path: %s\n', [result_path(1:end-5),imName(1:end-4),result_path(end-3:end)]);
					fprintf('Ground-truth path: %s\n', [gt_path(1:end-5),imName]);
					input_im = imread([result_path(1:end-5),imName(1:end-4),result_path(end-3:end)]);
					truth_im = imread([gt_path(1:end-5),imName]);
					truth_im = truth_im(:,:,1);
					input_im = input_im(:,:,1);
					% Normalize ground-truth to 0,1 values.
					% IMPORTANT:
					% the dataset PASCAL-S doesn't actually have max saliency of 255
					% so we need to find the max value of each image to normalize to 0,1.
					if(strcmp(datasets{dataset_id}, 'PASCAL_S'))
						max_saliency_val = max(max(truth_im));
					end
					truth_im = truth_im./max_saliency_val;
					% Compute PR on binarized image
					for threshold = 0:255
						index1 = (input_im>=threshold);
						truePositive = length(find(index1 & truth_im));
						groundTruth = length(find(truth_im));
						detected = length(find(index1));
						if truePositive~=0
							precision(threshold+1) = precision(threshold+1)+truePositive/detected;
							recall(threshold+1) = recall(threshold+1)+truePositive/groundTruth;
						end
					end
					fprintf('%d/%d done!\n', i, imNum);
				end
				% Adjust PR values
				precision = precision./imNum;
				recall = recall./imNum;
				pr = [precision'; recall'];
				measure_file_name = '_PRCurve.txt';
				measure_file = [methods{method_id}, '_', datasets{dataset_id}, measure_file_name];
				fid = fopen([savepath measure_file],'wt');
				fprintf(fid,'%f %f\n',pr);
				fclose(fid);
				disp('Done!');
				already_done(dataset_id, method_id) = 1;
            end
			end
    end
end
