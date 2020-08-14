**IMPORTANT**: This is a modified version of [this](https://github.com/yaoliUoA/evalsaliency) repository. I modified the code for my thesis. Read the instructions of the original authors first.  

* For my thesis I evaluated 4 models(HS, DRFI, ELD, CPD) on 5 datasets(PASCAL-S, ECSSD, HKU-IS, DUTS Test Set, DUT-OMRON).
* The evaluation measures used were Precision-Recall Curve, F-Measure Score and Mean Absolute Error Score.
* I modified the **'eval_PR'** and **'eval_MAE'** files so that I could compute the measures for all the models on all the datasets.  
Unfortunately, the ELD model saliency maps on DUT-OMRON are **missing 2 files** and the original evaluation code is assuming that for every ground truth file there's a saliency map file with the same name: executing the 'eval_PR' and 'eval_MAE' codes then produces an error.  
As time was not on my side while I was doing my thesis, I decided to copy pretty much the same code and skip the missing files in these extra files(I'm aware this is an horrible decision).  
These extra files names end with **'DUT_OMRON'**.
* The **'draw_\*'** files were modified so I could create figures with all the models measures on 1 dataset.
* The **'Unused-Files'** folder contains some files that I didn't need.
* The **'FIGURES'** folder contains the computed measures images used for my thesis. 
