function T = GetDemographics(sbj_name)

% Load table
[DOCID,GID] = getGoogleSheetInfo('demographics', []);
googleSheet = GetGoogleSpreadsheet(DOCID, GID);

% Select the subject rows
T = googleSheet(contains(googleSheet.subject_name, sbj_name),:);

end