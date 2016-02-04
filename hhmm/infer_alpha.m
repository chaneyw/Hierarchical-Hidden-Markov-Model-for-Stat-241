function [sstats] = infer_alpha(x, theta, sstats)

T = length(x);

max_branch_factor = 100;

gchild_buf = zeros(max_branch_factor, 1);
sib_buf = zeros(max_branch_factor, 1);

for k = 0:T-1
    for t = 1:(T-k)
        sstats = infer_alpha_rec(x, theta, sstats, k, t);
    end
end


function [sstats] = infer_alpha_rec(x, theta, sstats, k, t)
    n_child = size(sstats.subs,1);


    if k == 0
        
        % Calculate the probability that each child finished at t
        for child_idx = 1:n_child

            
            if sstats.subs{child_idx}.isleaf
                % The child finished by producing a symbol
                sstats.subs{child_idx}.lalpha(t,t) = theta.lpi(child_idx) + theta.subs{child_idx}.lB(x(t));
            else
                % Calculate the probability that the child finished because
                % each of its own children finished
                sstats.subs{child_idx} = infer_alpha_rec(x, theta.subs{child_idx}, sstats.subs{child_idx}, k, t);
                
                n_gchild = size(sstats.subs{child_idx}.subs,1);
                %lp_gchild = zeros(n_gchild,1);
                for gchild_idx = 1:n_gchild
                    gchild_buf(gchild_idx) = sstats.subs{child_idx}.subs{gchild_idx}.lalpha(t,t) ...
                                            + theta.subs{child_idx}.lA(gchild_idx, end);
                end
                
                sstats.subs{child_idx}.lalpha(t,t) = theta.lpi(child_idx) + log_sum_exp(gchild_buf(1:n_gchild));
            end
        end
        
    else
        lp_non_start = [];
        
        % Calculate the probability that each child finished at t+k        
        for child_idx = 1:n_child
            
            
            if sstats.subs{child_idx}.isleaf
                
                % Calculate the probablity of coming into the child from
                % each of its siblings
                %lp_from_sib = zeros(n_child,1);
                for sib_idx = 1:n_child
                    sib_buf(sib_idx) = sstats.subs{sib_idx}.lalpha(t, t + k -1)...
                                           + theta.lA(sib_idx, child_idx);
                end
                
                % The child finished by producing a symbol
                sstats.subs{child_idx}.lalpha(t,t+k) = log_sum_exp(sib_buf(1:n_child))...
                                                       + theta.subs{child_idx}.lB(x(t+k));
            else
                % Calculate the probability that the child finished because
                % one of its own children finished 
                sstats.subs{child_idx} = infer_alpha_rec(x, theta.subs{child_idx}, sstats.subs{child_idx}, k, t);
                
                % May have come into to child from a sibling at some point 
                if isempty(lp_non_start)
                    lp_non_start = zeros(k,1);
                end
                for l = 0:k-1
                    
                    % Calculate the prob of coming from each sibiling at
                    % that point
                    %lp_from_sib = zeros(n_child,1);
                    for sib_idx = 1:n_child
                        sib_buf(sib_idx) = sstats.subs{sib_idx}.lalpha(t,t+l) ...
                                               + theta.lA(sib_idx,child_idx);
                    end
                    
                    % Calculate the probability that the child finished because
                    % each of its own children finished
                    n_gchild = size(sstats.subs{child_idx}.subs,1);
                    %lp_gchild = zeros(n_gchild,1);
                    for gchild_idx = 1:n_gchild
                        gchild_buf(gchild_idx) = sstats.subs{child_idx}.subs{gchild_idx}.lalpha(t+l+1,t+k)...
                                                + theta.subs{child_idx}.lA(gchild_idx, end);
                    end
                    
                    lp_non_start(l+1) = log_sum_exp(sib_buf(1:n_child)) + log_sum_exp(gchild_buf(1:n_child));
                end
                
                % Or may have been in the child the whole time til one its
                % children finished
                n_gchild = size(sstats.subs{child_idx}.subs,1);
                %lp_gchild = zeros(n_gchild,1);
                for gchild_idx = 1:n_gchild
                    gchild_buf(gchild_idx) = sstats.subs{child_idx}.subs{gchild_idx}.lalpha(t,t+k)...
                                            + theta.subs{child_idx}.lA(gchild_idx, end);
                end
                lp_start = theta.lpi(child_idx) + log_sum_exp(gchild_buf(1:n_gchild));
               
                
                sstats.subs{child_idx}.lalpha(t,t+k) = log_sum_exp([lp_non_start; lp_start]);
            end
            
        end
                
    end

end

end



