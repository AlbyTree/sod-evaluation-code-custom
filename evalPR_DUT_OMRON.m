%% This is a modified version of the original code
clear all
close all;clc;

methods = {'ELD'};
datasets = {'DUT_OMRON'};

results_others_path = '../Survey_Results/';
results_ELD_path = [results_others_path, 'ELD/'];
results_all_path = {results_ELD_path};
gt_all_path = '../DATASETS/TEST/';

%for method_id = 1:length(methods)
	for dataset_id = 1:length(datasets)
        method_id = 1;
		savepath = ['./results/', methods{method_id}, '/', datasets{dataset_id}, '/', 'PRcurve/']; % save path of the 256 combinations of precision-recall values
		if ~exist(savepath,'dir')
			mkdir(savepath);
		end
		result_path = [results_all_path{method_id}, datasets{dataset_id}, '/*.png'];
		dir_im = dir(result_path);
		assert(~isempty(dir_im),'No saliency map found, please check the path!');
		gt_path = [gt_all_path, datasets{dataset_id}, '/gt/', '*.png'];
		dir_tr= dir(gt_path);
		assert(~isempty(dir_tr),'No ground-truth image found, please check the path!');
		if(strcmp(methods{method_id}, 'ELD') && strcmp(datasets{dataset_id}, 'DUT_OMRON'))
			fprintf('ELD method on DUT_OMRON misses 2 images!\n');		
		else
			assert(length(dir_im)==length(dir_tr),'The number of saliency maps and ground-truth images are not equal!');
		end
		imNum = length(dir_tr);
		precision = zeros(256,1);
		recall = zeros(256,1);

		%% compute pr curve
		for i = 1:imNum
			imName = dir_tr(i).name;
			if(strcmp(imName, 'sun_akxddynsopjifavt.png') || strcmp(imName, 'sun_barwtmnxkuxyttlj.png'))
				fprintf('Skipping ELD missing file %s on DUT_OMRON!\n', imName);
            else
                fprintf('Image path: %s\n', [result_path(1:end-5),imName(1:end-4),result_path(end-3:end)]);
                fprintf('GT path: %s\n', [gt_path(1:end-5),imName]);
				input_im = imread([result_path(1:end-5),imName(1:end-4),result_path(end-3:end)]);
				truth_im = imread([gt_path(1:end-5),imName]);
				truth_im = truth_im(:,:,1);
				input_im = input_im(:,:,1);
                if max(max(truth_im))==255
					truth_im = truth_im./255;
                end
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
				display(num2str(i));
			end
		end
		precision = precision./(imNum-2);
		recall = recall./(imNum-2);
		pr = [precision'; recall'];
		fid = fopen([savepath methods{method_id}, '_', datasets{dataset_id}, '_PRCurve.txt'],'at');
		fprintf(fid,'%f %f\n',pr);
		fclose(fid);
		disp('Done!');
	end
%end
