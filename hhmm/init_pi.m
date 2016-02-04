function [ pi ] = init_pi(q)
    pi = cell(size(q));

    pi_vals = rand(size(q,1),1)/size(q.1);
    
    for i = 1:size(q,1)
        if isempty(q{1})
            pi{i} = pi_vals(i);
        else
            pi{i} = [pi_vals(i) init_pi(q{i})];
        end
    end
                
end

