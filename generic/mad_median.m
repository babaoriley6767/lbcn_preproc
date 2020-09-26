function mad_median = mad_median(A)

c=-1/(sqrt(2)*erfcinv(3/2));
mad_median  = c*median(abs(A-median(A)));

end

