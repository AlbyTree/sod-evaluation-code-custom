%% This is a modified version of the original code
clear all
close all;clc;
methods = {'HS', 'DRFI', 'CPD', 'ELD'};
datasets = {'PASCAL_S', 'ECSSD', 'DUTS_Test', 'HKU_IS', 'DUT_OMRON'};
results_CPD_path = '../ALGS/CPD/results/VGG16/model-3/';
results_others_path = '../Survey_Results/';
results_HS_path = [results_others_path, 'HS/'];
results_DRFI_path = [results_others_path, 'DRFI/'];
results_ELD_path = [results_others_path, 'ELD/'];
results_all_path = {results_HS_path, results_DRFI_path, results_CPD_path, results_ELD_path};

gt_all_path = '../DATASETS/TEST/';

for method_id = 1:length(methods)
	for dataset_id = 1:length(datasets)
		savepath = ['./results/', methods{method_id}, '/', datasets{dataset_id}, '/', 'MAE/']; % save path of the 256 combinations of precision-recall values
        if ~exist(savepath,'dir')
			mkdir(savepath);
        end
        if(strcmp(methods{method_id}, 'CPD'))
            result_path = [results_CPD_path, datasets{dataset_id}, '/*.png'];
        else
            result_path = [results_others_path, methods{method_id}, '/', datasets{dataset_id}, '/*.png'];
        end
        dir_im = dir(result_path);
		assert(~isempty(dir_im),'No saliency map found, please check the path!');
		gt_path = [gt_all_path, datasets{dataset_id}, '/gt/', '*.png'];
		dir_tr= dir(gt_path);
		assert(~isempty(dir_tr),'No ground-truth image found, please check the path!');
		if(strcmp(methods{method_id}, 'ELD') && strcmp(datasets{dataset_id}, 'DUT_OMRON'))
			fprintf('ELD method on DUT_OMRON misses 2 images!\n');		
		else
			assert(length(dir_im)==length(dir_tr),'The number of saliency maps and ground-truth images are not equal!')
		end
		imNum = length(dir_tr);
		MAE = 0;
		%% compute MAE
        for i = 1:imNum
		  	imName = dir_tr(i).name;
            fprintf('Image path: %s\n', [result_path(1:end-5),imName(1:end-4),result_path(end-3:end)]);
            fprintf('GT path: %s\n', [gt_path(1:end-5),imName]);
            %if(strcmp(imName, 'sun_akxddynsopjifavt.png') || strcmp(imName, 'sun_barwtmnxkuxyttlj.png'))
			%	print('Skipping ELD missing files on DUT_OMRON!\n');
			%else
				input_im = imread([result_path(1:end-5),imName(1:end-4),result_path(end-3:end)]);
				input_im = double(input_im(:,:,1))./255;
				truth_im = imread([gt_path(1:end-5),imName]);
				truth_im = double(truth_im(:,:,1));
                %if max(max(truth_im))==255
                truth_im = truth_im./255;
                %end
                MAE = MAE + mean2(abs(truth_im-input_im));
                fprintf('Curr. MAE: %f\n', MAE);
            %end
            display(num2str(i));
        end
           
        MAE = MAE/imNum;
        fprintf('MAE=%f\n',MAE);
        save([savepath methods{method_id}, '_', datasets{dataset_id}, '_MAE'],'MAE');
        fid = fopen([savepath methods{method_id}, '_', datasets{dataset_id}, '_MAE.txt'],'wt');
		fprintf(fid,'%f\n',MAE);
		fclose(fid);
	end
end
