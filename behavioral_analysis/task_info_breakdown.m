tasks = dir(fullfile('/Users/pinheirochagas/Downloads/retaskversioninformation/'))
tasks(1:2)=[]
task_bd = struct
for i = 1:length(tasks)
    task = strsplit(tasks(i).name, '_');
    load([tasks(i).folder filesep tasks(i).name]);
    task_bd.(task{1}) = task_version_table;
end


% Breakdown
How many trials per subject per task per version per ISI per stimdur per condition per electrode 


VTC 
20
on average
10 trials per condition in x electrodes 





subjects
    implantation
    
task broad
    task specific 
            version
                condition
                    ISI
                    stimdur
brain
    recoring type
    location
    quality
    pathological
    
behavior
    quality
    
    
    
task
    condition
    
brain
    quality

behavior
    quality
    
    
    






    
    
 
    
    
    
    
    
    
    
