% Adds the all soft counts from count_seq to the counts sum 
function [counts_sum] = add_params_list(counts_sum, counts_seq)
n_seq = length(counts_seq);

if counts_sum.isleaf
    for i = 1:n_seq
        counts_sum.B = counts_sum.B + counts_seq{i}.B;
    end
else
    for i = 1:n_seq    
        counts_sum.pi = counts_sum.pi + counts_seq{i}.pi;
        counts_sum.A = counts_sum.A + counts_seq{i}.A;
    end
    
    for child_idx = 1:length(counts_sum.subs)
        counts_children = cell(n_seq, 1);
        for i = 1:n_seq
            counts_children{i} = counts_seq{i}.subs{child_idx};
        end
        
        counts_sum.subs{child_idx} = add_params_list(counts_sum.subs{child_idx}, counts_children);
    end
end

end

