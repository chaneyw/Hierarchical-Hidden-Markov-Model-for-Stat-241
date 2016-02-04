function [sstats] = infer_eta_in(x, theta, sstats)

% Root node is base case
n_child = size(sstats.subs,1);
for child_idx = 1:n_child
    
    % For the first time step must have come directly into the child
    sstats.subs{child_idx}.leta_in(1) = theta.lpi(child_idx);
    
    % subsequent times steps could have come in from any sibling
    for t=2:length(x)
        
        lp_sib = zeros(n_child,1);
        for sib_idx = 1:n_child
            lp_sib(sib_idx) = sstats.subs{sib_idx}.lalpha(1,t-1)...
                              + theta.lA(sib_idx, child_idx);
        end
        
        sstats.subs{child_idx}.leta_in(t) = log_sum_exp(lp_sib);
    end
end

for child_idx = 1:n_child
    sstats.subs{child_idx} = infer_eta_in_rec(x, theta.subs{child_idx}, sstats.subs{child_idx});
end


end


function [sstats] = infer_eta_in_rec(x, theta, sstats)

if sstats.isleaf
    return;
end

n_child = size(sstats.subs,1);
for child_idx = 1:n_child
    % For the first time step must have come directly into the child from
    % the parent
    sstats.subs{child_idx}.leta_in(1) = sstats.leta_in(1) + theta.lpi(child_idx);
    
    
    % subsequent times steps could have come in from any sibling or just come in
    % directly from the parent node
    for t = 2:length(x)
        
        % coming in from a sibling requires come down to this level from a
        % parent at some earlier time step and having that siblinging
        % finish at time step immediately preceeding t
        lp_tau = zeros(t-1, 1);
        for tau = 1:t-1
            
            lp_sib = zeros(n_child,1);
            for sib_idx = 1:n_child
                lp_sib(sib_idx) = sstats.subs{sib_idx}.lalpha(tau,t-1)...
                                  + theta.lA(sib_idx, child_idx);
            end
            
            lp_tau(tau) = sstats.leta_in(tau) + log_sum_exp(lp_sib);
        end
        
        lp_direct = sstats.leta_in(t) + theta.lpi(child_idx);
        
        sstats.subs{child_idx}.leta_in(t) = log_sum_exp([lp_tau; lp_direct]);
        
    end
end

for child_idx = 1:n_child
    sstats.subs{child_idx} = infer_eta_in_rec(x, theta.subs{child_idx}, sstats.subs{child_idx});
end
    
end