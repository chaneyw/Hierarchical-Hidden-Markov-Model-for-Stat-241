function [seq] = sample_hhmm(theta, seq, max_length)

if length(seq) >= max_length
    return;
end

if theta.isleaf
    char = find(cumsum(theta.B) > rand, 1);
    
    seq = [seq char];
else
    child_idx = find(cumsum(theta.pi) > rand, 1);
    
    while (child_idx ~= size(theta.subs,1) + 1) 
        seq = sample_hhmm(theta.subs{child_idx}, seq, max_length);
        child_idx = find(cumsum(theta.A(child_idx,:)) > rand, 1);
    end
end
    
end

