% Loads datasets and methods paths
run("./setup_dirs.m");

% A matrix that tells if we've already done ROC curve on a method
% where rows are datasets, columns are methods.
% '0' means we haven't, '1' we have.
% Set a breakpoint and change values if you don't want to evaluate a method
% again.
dataset_method_evaluated = zeros(length(datasets_list), length(methods_list));

% Already done HS on ECSSD, PASCAL-S
dataset_method_evaluated(1,1) = 1;
dataset_method_evaluated(2,1) = 1;

% For every dataset, evaluate every method saliency maps and save the score
for d = 1:length(datasets_path)
	for m = 1:length(methods_list)
        if dataset_method_evaluated(d,m) == 0
            if methods_list(m) == "HS"
                dir_im = dir(resultpath_all(d,m)+"*.png");
            else
                dir_im = dir(resultpath_all(d,m));
            end
            assert(~isempty(dir_im),'No saliency map found, please check the path!');
        
            dir_tr= dir(truthpath_all(d)+"*.png");
            assert(~isempty(dir_tr),'No ground-truth image found, please check the path!');
            assert(length(dir_im)==length(dir_tr),'The number of saliency maps and ground-truth images are not equal!')
            imNum = length(dir_tr);
            TPR = zeros(256,1);
            FPR = zeros(256,1);
            % Fix images natural order
            dir_im_fixed = natsortfiles({dir_im.name});
            dir_tr_fixed = natsortfiles({dir_tr.name});
            fprintf("Testing method %s on dataset %s\n", methods_list(m), datasets_list(d));
            %% compute ROC
            for i = 1:imNum
              %imName = dir_im(i).name;
              %truthImName = dir_tr(i).name;
              % Convert cell name into a string name
              imName = char(dir_im_fixed(i));
              truthImName = char(dir_tr_fixed(i));
              % input_im = imread([resultpath(1:end-5),imName(1:end-4),resultpath(end-3:end)]);
              input_im = imread(resultpath_all(d,m)+imName);
              truth_im = imread(truthpath_all(d)+truthImName);
              % truth_im = imread([truthpath(1:end-5),truthImName]);
              truth_im = truth_im(:,:,1);
              input_im = input_im(:,:,1);
                 if max(max(truth_im))==255
                truth_im = truth_im./255;
                 end
                P = sum(sum(truth_im));
                N = sum(sum(~truth_im));
                for threshold = 0:255
                if P~=0 && N~=0
                index1 = (input_im>=threshold);
                TP = sum(sum(truth_im & index1));
                FP = sum(sum((~truth_im) & index1));
                TPR(threshold+1) = TPR(threshold+1)+TP/P;
                FPR(threshold+1) = FPR(threshold+1)+FP/N; 
                end
                end
                display(num2str(i));
            end    
            TPR = TPR/imNum;
            FPR = FPR/imNum;
            index = (TPR>1);
            TPR(index)=1;
            index = (FPR>1);
            FPR(index)=1;
            ROC = [TPR';FPR'];
            ROC_save_file = datasets_list(d)+'-'+methods_list(m)+'-'+'ROC-curve.txt';
            fprintf("Saving the results in %s\n", ROC_save_file);
            fid = fopen(savepath_all(d,m)+ROC_save_file,'at');
            fprintf(fid,'%f %f\n',ROC);
            fclose(fid);
            disp('Done!');
            dataset_method_evaluated(d,m) = 1;
        end
	end
end
