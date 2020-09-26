function data = nanste(data)
    
    data = nanstd(data)/sqrt(size(data,1));
    
end

