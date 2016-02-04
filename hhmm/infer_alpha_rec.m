function [sstats] = infer_alpha_rec(x, theta, sstats, k, t)
    n_subs = size(sstats.subs,1);


    if k == 0
        
        for child_idx = 1:n_subs

            if sstats.subs{child_idx}.isleaf
                sstats.subs{child_idx}.alpha(t,t) = theta.pi(child_idx)*theta.subs{child_idx}.B(x(t));
            else
                sstats.subs{child_idx} = infer_alpha_rec(x, theta.subs{child_idx}, sstats.subs{child_idx}, k, t);
                
                alpha_sum = 0;
                for grand_child_idx = 1:size(sstats.subs{child_idx}.subs,1)
                    alpha_sum = alpha_sum + sstats.subs{child_idx}.subs{grand_child_idx}.alpha(t,t)*...
                        theta.subs{child_idx}.A(grand_child_idx, end);
                end
                
                sstats.subs{child_idx}.alpha(t,t) = theta.pi(child_idx)*alpha_sum;
            end
        end
        
    else
        
        for child_idx = 1:n_subs
            
            if sstats.subs{child_idx}.isleaf
                alpha_sum = 0;
                for sibling_idx = 1:n_subs
                    alpha_sum = alpha_sum + sstats.subs{sibling_idx}.alpha(t, t + k -1)*...
                                            theta.A(sibling_idx, child_idx);
                end
                
                sstats.subs{child_idx}.alpha(t,t+k) = alpha_sum*theta.subs{child_idx}.B(x(t+k));
            else
                
                sstats.subs{child_idx} = infer_alpha_rec(x, theta.subs{child_idx}, sstats.subs{child_idx}, k, t);
                
                non_start_sum = 0;
                for l = 0:k-1
                    first_part_sum = 0;
                    for sibling_idx = 1:n_subs
                        first_part_sum = first_part_sum + sstats.subs{sibling_idx}.alpha(t,t+l)*...
                                                          theta.A(sibling_idx,child_idx);
                    end
                    
                    second_part_sum = 0;
                    for grand_child_idx = 1:size(sstats.subs{child_idx}.subs,1)
                        second_part_sum = second_part_sum + sstats.subs{child_idx}.subs{grand_child_idx}.alpha(t+l+1,t+k)*...
                                                            theta.subs{child_idx}.A(grand_child_idx, end);
                    end
                    
                    non_start_sum = non_start_sum + first_part_sum*second_part_sum;
                end
                
                start_sum = 0;
                for grand_child_idx = 1:size(sstats.subs{child_idx}.subs,1)
                    start_sum = start_sum + sstats.subs{child_idx}.subs{grand_child_idx}.alpha(t,t+k)*...
                                            theta.subs{child_idx}.A(grand_child_idx, end);
                end
                
                sstats.subs{child_idx}.alpha(t,t+k) = non_start_sum + start_sum*theta.pi(child_idx);
            end
            
        end
                
    end

end

