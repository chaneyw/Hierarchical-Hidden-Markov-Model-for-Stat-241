function [A] = init_A(q)
    N = size(q,1);

    A = cell(size(q));
    
    A_vals = rand(N, N);
    A = bsx_fun(@rdivide, A, sum(A,2));
    
    for i = 1:N
        if isempty(q{i})
            A{i} = A_vals(i,:);
        else
            A{i} = {A_vals{i,:} init_A(q{i})};


end

