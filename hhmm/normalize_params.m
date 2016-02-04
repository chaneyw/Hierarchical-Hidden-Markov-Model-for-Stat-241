% Sets theta to the normalization of counts_sum
function [theta] = normalize_params(theta, counts_sum)

if counts_sum.isleaf
    theta.B = counts_sum.B/sum(counts_sum.B);
    theta.lB = log(theta.B);
    
    1 == 1;
else
    theta.pi = counts_sum.pi/sum(counts_sum.pi);
    theta.lpi = log(theta.pi);
    theta.A = bsxfun(@rdivide, counts_sum.A, sum(counts_sum.A,2));
    theta.lA = log(theta.A);
    
    for i = 1:size(counts_sum.subs,1)
        theta.subs{i} = normalize_params(theta.subs{i}, counts_sum.subs{i});
    end
end

end