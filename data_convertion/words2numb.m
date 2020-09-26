function trialinfo = words2numb(K,trialinfo,ntrials)
%ntrials = length(K.trials);
for i=1:ntrials
    %numwords = {'one','two','three','four','five','six','seven','eight','nine','ten',''};
    numwords = {'one','two','three','four','five','six','seven','eight','nine','ten','eleven','twelve','thirteen','fourteen','fifteen','sixteen','seventeen','eighteen','nineteen','twenty','twentyone','twentytwo','twentythree','twentyfour','twentyfive',''};
    
    
    tmp=strcmp(trialinfo.stim1(i),numwords);
    tmp2=strcmp(trialinfo.stim2(i),numwords);
    tmp3=strcmp(trialinfo.stim3(i),numwords);
    trialinfo.operand1(i)=find(tmp==1);
    trialinfo.operand2(i)=find(tmp2==1);
    trialinfo.presResult(i)=find(tmp3==1);
    %trialinfo.operand1(i)=number;
end
end 