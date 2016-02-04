function sstats = infer_xi(x, theta, sstats, log_p)

T = length(x);

n_child = size(sstats.subs,1);
for child_idx = 1:n_child
    for sib_idx = 1:n_child
        
        % For t < T a horizontal transition can happen to sibling the
        % continues the sequence
        for t = 1:T-1
            sstats.lxi(child_idx, sib_idx, t) = sstats.subs{child_idx}.lalpha(1,t)...
                + theta.lA(child_idx, sib_idx) + sstats.subs{sib_idx}.lbeta(t+1,T);
        end
    end
end

% ???? seems like the only thing that can happen is a transition to
% the end state when t == T but the paper has for all siblings
% is this a mistake? The transition to the end state the root is artificial
% anyway because the sequences truncated versions of continuing data
for child_idx = 1:n_child
    sstats.lxi(child_idx,1:(end-1), T) = -inf;
    sstats.lxi(child_idx, end, T) = sstats.subs{child_idx}.lalpha(1,T)...
                                   + theta.lA(child_idx, end);
end
                            
                            
sstats.lxi = sstats.lxi - log_p;
                            
for child_idx = 1:n_child                            
    sstats.subs{child_idx} = infer_xi_rec(x, theta.subs{child_idx}, sstats.subs{child_idx}, log_p);
end
    
end

function sstats = infer_xi_rec(x, theta, sstats, log_p)

if sstats.isleaf
    return;
end

T = length(x);

n_child = size(sstats.subs,1);
for child_idx = 1:n_child
    for sib_idx = 1:n_child
        
        for t = 1:T-1
            
            lp_down = zeros(t,1);
            for s = 1:t
                lp_down(s) = sstats.leta_in(s) + sstats.subs{child_idx}.lalpha(s,t);
            end
            
            lp_up = zeros(T-t,1);
            for e = t+1:T
                lp_up(e-t) = sstats.subs{sib_idx}.lbeta(t+1,e) + sstats.leta_out(e);
            end
            
            sstats.lxi(child_idx, sib_idx, t) = log_sum_exp(lp_down)...
                + theta.lA(child_idx, sib_idx) + log_sum_exp(lp_up);
        end
    end
end

for child_idx = 1:n_child
    for t = 1:T
        lp_down = zeros(t,1);
        for s = 1:t
            lp_down(s) = sstats.leta_in(s) + sstats.subs{child_idx}.lalpha(s,t);
        end

        sstats.lxi(child_idx, end, t) = log_sum_exp(lp_down)...
            + theta.lA(child_idx, end) + sstats.leta_out(t);
    end
end

sstats.lxi = sstats.lxi - log_p;

for child_idx = 1:n_child                            
    sstats.subs{child_idx} = infer_xi_rec(x, theta.subs{child_idx}, sstats.subs{child_idx}, log_p);
end

end

