function [sstats] = init_sstats(q, T)

small = -inf;

sstats.lalpha = small*ones(T,T);
sstats.lbeta = small*ones(T,T);
sstats.leta_in = small*ones(T,1);
sstats.leta_out = small*ones(T,1);


if isempty(q)
    sstats.isleaf = true;
else
    sstats.isleaf = false;
    
    n_subs = size(q,1);
    
    sstats.lchi = small*ones(n_subs, T);
    sstats.lxi = small*ones(n_subs, n_subs + 1, T);
    
    
    sstats.subs = cell(n_subs, 1);
    
    for i = 1:n_subs
        sstats.subs{i} = init_sstats(q{i},T);
    end
end
    

end

