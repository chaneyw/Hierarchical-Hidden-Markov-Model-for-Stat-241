function [sstats] = infer_eta_out(x, theta, sstats)

T = length(x);

% root is base case
n_child = size(sstats.subs,1);
for child_idx = 1:n_child   
    for t = 1:T-1
        % a child of the root finishes by transitioning to one its siblings
        lp_to_sib = zeros(n_child,1);
        for sib_idx = 1:n_child
            lp_to_sib(sib_idx) = theta.lA(child_idx, sib_idx)...
                                 + sstats.subs{sib_idx}.lbeta(t+1,T);
        end
        
        sstats.subs{child_idx}.leta_out(t) = log_sum_exp(lp_to_sib);
    end
    
    % At time t = T the only way to finish is to end
    sstats.subs{child_idx}.leta_out(T) = theta.lA(child_idx, end);
end

for child_idx = 1:n_child
    sstats.subs{child_idx} = infer_eta_out_rec(x, theta.subs{child_idx}, sstats.subs{child_idx});
end


end

function [sstats] = infer_eta_out_rec(x, theta, sstats)

T = length(x);

if sstats.isleaf
    return;
end

n_child = size(sstats.subs,1);
for child_idx = 1:n_child
    
    for t = 1:T
        % The remainder of the sequence can be generated by a child
        % finishing directly to its parent
        lp_direct = theta.lA(child_idx, end) + sstats.leta_out(t);
        
        if t == T
            % It's the only way when t is T
            sstats.subs{child_idx}.leta_out(t) = lp_direct;
        else
            % For t < T it can also cede control to some sibling and finish to the parent at
            % some point later
            lp_tau = zeros(T-t,1);
            for tau = t+1:T
                
                lp_sib = zeros(n_child,1);
                for sib_idx = 1:n_child
                    lp_sib(sib_idx) = theta.lA(child_idx, sib_idx)...
                        + sstats.subs{sib_idx}.lbeta(t+1,tau);
                end
                
                lp_tau(tau - t) = log_sum_exp(lp_sib) + sstats.leta_out(tau);
                
            end
            
            sstats.subs{child_idx}.leta_out(t) = log_sum_exp([lp_tau; lp_direct]);
        end
        
        
    end
end
       

for child_idx = 1:n_child
    sstats.subs{child_idx} = infer_eta_out_rec(x, theta.subs{child_idx}, sstats.subs{child_idx});
end

end