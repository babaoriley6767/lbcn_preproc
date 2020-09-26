% Retrieve google sheets
[DOCID,GID] = getGoogleSheetInfo('subjects_by_task', []);
googleSheet = GetGoogleSpreadsheet(DOCID, GID);

% Convert strings to numbers in the relevant columns
column_names = googleSheet.Properties.VariableNames;
for i = 2:size(googleSheet,2)
    googleSheet.(column_names{i}) = str2num((cell2mat(googleSheet.(column_names{i}))));
end

% Extract data
data = table2array(googleSheet(:,2:end));

% Generate all task combinations
for i = 1:size(data,2)
    combs{i} = combnk(1:size(data,2),i);
    combs_names{i} = cellstr(int2str(combs{i}));
end
tasks = cat(1,combs_names{:});

% Calculate the number of subjects per tasks combination
for i = 1:length(tasks)
    num_subjects(i,1) = sum(sum(data(:,str2num(tasks{i})),2)==length(str2num(tasks{i})));
end
   
% Combine data into table
table_task_by_subject = table(tasks,num_subjects);
% Take only the combinations that have at least 1 subject and sort 
table_task_by_subject = table_task_by_subject(table_task_by_subject.num_subjects > 0,:);
table_task_by_subject = sortrows(table_task_by_subject, 'num_subjects', 'descend');


%% Combining tasks
combs_names = [];
tasks = [];
num_subjects = [];
data_comb(:,1) = sum(data(:,1:3),2)>0;
data_comb(:,2) = sum(data(:,3:4),2)>0;
data_comb(:,3) = data(:,6);

for i = 1:size(data_comb,2)
    combs{i} = combnk(1:size(data_comb,2),i);
    combs_names{i} = cellstr(int2str(combs{i}));
end
tasks = cat(1,combs_names{:});

% Calculate the number of subjects per tasks combination
for i = 1:length(tasks)
    num_subjects(i,1) = sum(sum(data_comb(:,str2num(tasks{i})),2)==length(str2num(tasks{i})));
end
   
% Combine data into table
table_task_by_subject = table(tasks,num_subjects);



