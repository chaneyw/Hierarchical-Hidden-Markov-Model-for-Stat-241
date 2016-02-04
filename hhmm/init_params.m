function [theta] = init_params(q, n_alphabet, iscounts)

if isempty(q)
    theta.isleaf = true;
    
    if iscounts
        theta.B = zeros(n_alphabet,1);
    else
        theta.B = rand(n_alphabet, 1);
        theta.B = theta.B/sum(theta.B);
        theta.lB = log(theta.B);
    end
else
    theta.isleaf = false;
    
    n_subs = size(q,1);
    
    if iscounts
        theta.pi = zeros(n_subs,1);
        theta.A = zeros(n_subs, n_subs + 1);
    else
        theta.pi = rand(n_subs,1);
        theta.pi = theta.pi/sum(theta.pi);
        theta.lpi = log(theta.pi);
        
        theta.A = rand(n_subs,n_subs + 1);
        theta.A(:,end) = theta.A(:,end);
        theta.A = bsxfun(@rdivide, theta.A, sum(theta.A,2));
        theta.lA = log(theta.A);
    end

    theta.subs = cell(n_subs,1);
    
    for i = 1:n_subs
        theta.subs{i} = init_params(q{i}, n_alphabet, iscounts);
    end
end

end

