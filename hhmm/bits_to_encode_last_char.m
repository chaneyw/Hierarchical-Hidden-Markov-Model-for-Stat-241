function [bits] = bits_to_encode_last_char(q, theta, n_alphabet, seq)

T = length(seq);

sstats = init_sstats(q,length(seq));

sstats = infer_alpha(seq, theta, sstats);

n_child = length(sstats.subs);
last_t_lp = zeros(n_child,1);
secondtolast_t_lp = zeros(n_child,1);
for child_idx = 1:length(sstats.subs)
   last_t_lp(child_idx) = sstats.subs{child_idx}.lalpha(1,T);
   secondtolast_t_lp(child_idx) = sstats.subs{child_idx}.lalpha(1,T-1);
end

p_last = exp(log_sum_exp(last_t_lp) - log_sum_exp(secondtolast_t_lp));

bits = p_last*log2(p_last);

end

