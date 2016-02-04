function [ log_sum ] = log_sum_exp(log_vals)

level = max(log_vals);

if level == -inf
    log_sum = -inf;
else
    log_sum = level + log(sum(exp(log_vals - level)));
end

end

