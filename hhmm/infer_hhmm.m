function [sstats log_p] = infer_hhmm(x, theta, sstats)

T = length(x);

%disp 'alpha'
%tic
sstats = infer_alpha(x, theta, sstats);
%toc

% disp 'beta'
% tic
sstats = infer_beta(x, theta, sstats);
% toc 

% disp 'eta_in'
% tic
sstats = infer_eta_in(x, theta, sstats);
% toc

% disp 'eta_out'
% tic
sstats = infer_eta_out(x, theta, sstats);
% toc

lp_child_end = zeros(size(sstats.subs));
for i = 1:size(sstats.subs,1)
    lp_child_end(i) = sstats.subs{i}.lalpha(1,T) + theta.lA(i,end);
end

log_p = log_sum_exp(lp_child_end);



% disp 'xi'
% tic
sstats = infer_xi(x, theta, sstats, log_p);
%toc

% disp 'chi'
% tic
sstats = infer_chi(x, theta, sstats, log_p);
% toc


end

