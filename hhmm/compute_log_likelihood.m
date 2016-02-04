function log_p = compute_log_likelihood(x, theta, sstats)

T = length(x);
sstats = infer_alpha(x, theta, sstats);

lp_child_end = zeros(size(sstats.subs));
for i = 1:size(sstats.subs,1)
    lp_child_end(i) = sstats.subs{i}.lalpha(1,T) + theta.lA(i,end);
end

log_p = log_sum_exp(lp_child_end);

end

