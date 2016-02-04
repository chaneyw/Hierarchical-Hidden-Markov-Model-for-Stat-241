function [theta_sum] = sum_params(theta_sum, theta_seq)

if isempty(theta_sum)
    theta_sum = theta_seq;
elseif theta_sum.isleaf
    theta_sum.B = theta_sum.B + theta_seq.B;
else
    theta_sum.pi = theta_sum.pi + theta_seq.pi;
    theta_sum.A = theta_sum.A + theta_seq.A;
    
    
    for i = 1:size(theta_seq.subs,1)
        theta_sum.subs{i} = sum_params(theta_sum.subs{i}, theta_seq.subs{i});
    end
end

end

