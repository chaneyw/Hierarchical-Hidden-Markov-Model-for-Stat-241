function sstats = infer_chi(x, theta, sstats, log_p)

T = length(x);

n_child = size(sstats.subs,1);
for child_idx = 1:n_child
    sstats.lchi(child_idx, 1) = theta.lpi(child_idx) + sstats.subs{child_idx}.lbeta(1,T);
end

sstats.lchi = sstats.lchi - log_p;

for child_idx = 1:n_child
    sstats.subs{child_idx} = infer_chi_rec(x, theta.subs{child_idx}, sstats.subs{child_idx}, log_p);
end



end


function sstats = infer_chi_rec(x, theta, sstats, log_p)

if sstats.isleaf
    return;
end

T = length(x);

n_child = size(sstats.subs,1);
for child_idx = 1:n_child
    
    for t = 1:T
        lp_up_at = zeros(T-t+1,1);
        for e = t:T
            lp_up_at(e-t+1) = sstats.subs{child_idx}.lbeta(t,e) + sstats.leta_out(e);
        end
        
        sstats.lchi(child_idx,t) = sstats.leta_in(t) + theta.lpi(child_idx)... 
                                   + log_sum_exp(lp_up_at);
    end
end

sstats.lchi = sstats.lchi - log_p;

for child_idx = 1:n_child
    sstats.subs{child_idx} = infer_chi_rec(x, theta.subs{child_idx}, sstats.subs{child_idx}, log_p);
end


end