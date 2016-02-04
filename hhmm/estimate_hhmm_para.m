rng(4);

text = fileread('alice_in_wonderland.txt');
alphabet = unique(text);
n_alphabet = length(alphabet);

n_seq = 1000;
X = cell(n_seq,1);
seq_length = 10;
for i = 1:n_seq
    t_start = randi(length(text) - seq_length);
    string = text(t_start:(t_start+seq_length - 1))
    X{i} = string_to_indices(string, alphabet);
end



% X = [1 1;
%      1 2;
%      2 1;
%      2 2];

q = cell(2,1);
q{1} = cell(2,1);
q{2} = cell(2,1);
% q{1}{2} = cell(3,1);
% q{1}{1} = cell(3,1);
% q{1}{1}{2} = cell(5,1);


% n_alphabet = 4;
% theta_truth = init_params(q, n_alphabet);
% 
% max_seq_length = 100;
% n_seq = 10;
% X = cell(n_seq,1);
% for i = 1:n_seq
%     X{i} = sample_hhmm(theta_truth, [], max_seq_length);
% end
% 
% n_samples = 10000;
% seq_count = zeros(n_seq,1);
% for i = 1:n_samples
%     seq = sample_hhmm(theta_truth, [], max_seq_length);
%     for j = 1:n_seq
%         if length(seq) == length(X{j}) && all(seq == X{j})
%             seq_count(j) = seq_count(j) + 1;
%         end
%     end
% end
% p_sampler = seq_count/n_samples
% 
% log_p = zeros(n_seq,1);
% log_p_test = zeros(n_seq,1);


%X{1} = [1 2 3 4];
theta = init_params(q, n_alphabet);
theta_seq = cell{n_seq,1}
sstats_seq = cell{n_seq,1};
for i = 1:n_seq
    theta_seq{i} = init_params(q, n_alphabet);
    sstats_seq{i} = init_sstats(q,length(X{seq_idx});
end
max_iter = 500;
for iter = 1:max_iter
    
    iter
    
    for seq_idx = 1:n_seq
        
        
        x = X{seq_idx};
              
        [sstats_seq{seq_idx} log_p(seq_idx) log_p_test(seq_idx)] = infer_hhmm(x, theta, sstats_seq{seq_idx});
         
        theta_seq{i} = maximize_hhmm(sstats_seq{seq_idx}, theta_seq{i}, x);
    
        theta_new = sum_params(theta_new, theta_seq);
    end
    
    mean_log_p = mean(log_p)
    
    theta = normalize_params(theta, theta_new);
end

p = exp(log_p)
p_test = exp(log_p)
