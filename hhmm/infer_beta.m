function [sstats] = infer_beta(x, theta, sstats)

T = length(x);

for k = 0:T-1
    for t = T-k:-1:1
        sstats = infer_beta_rec(x, theta, sstats, k, t);
    end
end

end

function [sstats] = infer_beta_rec(x, theta, sstats, k, t)
    n_child = size(sstats.subs,1);
    
    if k == 0
        
        % Calculate the probability given that each child started at t
        for child_idx = 1:n_child
            
            if sstats.subs{child_idx}.isleaf
                % Child is must have started (and finished) by producing
                sstats.subs{child_idx}.lbeta(t,t) = theta.subs{child_idx}.lB(x(t))...
                                                    + theta.lA(child_idx, end);
            else
               % Calc the prob the child start by starting with each of its
               % children 
               sstats.subs{child_idx} = infer_beta_rec(x, theta.subs{child_idx}, sstats.subs{child_idx}, k, t);
               
               n_gchild = size(sstats.subs{child_idx}.subs,1);
               lp_gchild = zeros(n_gchild,1);
               for gchild_idx = 1:n_gchild
                  lp_gchild(gchild_idx) = theta.subs{child_idx}.lpi(gchild_idx)... +
                                          + sstats.subs{child_idx}.subs{gchild_idx}.lbeta(t,t);                                  
               end
               
               sstats.subs{child_idx}.lbeta(t,t) = log_sum_exp(lp_gchild)...
                                                   + theta.lA(child_idx, end);
            end
        end
        
    else
       
        % Calculate the probability given that each child started at t
        for child_idx = 1:n_child

            if sstats.subs{child_idx}.isleaf
                
                % After producing it could have transitioned to any of its siblings
                lp_to_sib = zeros(n_child,1);
                for sib_idx = 1:n_child
                    lp_to_sib(sib_idx) = theta.lA(child_idx, sib_idx)... 
                                         + sstats.subs{sib_idx}.lbeta(t + 1, t + k);
                end
                
                sstats.subs{child_idx}.lbeta(t,t+k) = theta.subs{child_idx}.lB(x(t))...
                                                       + log_sum_exp(lp_to_sib);
            else
                % Calculate the probability that the child started because
                % one of its own children started
                sstats.subs{child_idx} = infer_beta_rec(x, theta.subs{child_idx}, sstats.subs{child_idx}, k, t);
                
                % May have left to a sibling at some point 
                lp_non_finish = zeros(k,1);
                for l = 0:k-1
                    
                    % Calculate the probability that the child started because
                    % each of its own children started
                    n_gchild = size(sstats.subs{child_idx}.subs,1);
                    lp_gchild = zeros(n_gchild,1);
                    for gchild_idx = 1:n_gchild
                        lp_gchild(gchild_idx) = theta.subs{child_idx}.lpi(gchild_idx)...
                                                + sstats.subs{child_idx}.subs{gchild_idx}.lbeta(t,t+l);
                    end
                    
                    % Calculate the prob of leaving to each sibiling at
                    % some point after that
                    lp_to_sib = zeros(n_child,1);
                    for sib_idx = 1:n_child
                        lp_to_sib(sib_idx) = theta.lA(child_idx, sib_idx)...
                                             + sstats.subs{sib_idx}.lbeta(t+l+1,t+k);
                    end
                    

                    
                    lp_non_finish(l+1) = log_sum_exp(lp_gchild) + log_sum_exp(lp_to_sib);
                end
                
                % Or may have stayed in the child til the end
                n_gchild = size(sstats.subs{child_idx}.subs,1);
                lp_gchild = zeros(n_gchild,1);
                for gchild_idx = 1:n_gchild
                    lp_gchild(gchild_idx) = theta.subs{child_idx}.lpi(gchild_idx)...
                                            + sstats.subs{child_idx}.subs{gchild_idx}.lbeta(t,t+k);
                end
                lp_finish = log_sum_exp(lp_gchild) + theta.lA(child_idx,end);
               
                
                sstats.subs{child_idx}.lbeta(t,t+k) = log_sum_exp([lp_non_finish; lp_finish]);
            end
            
        end
        
    end



end
