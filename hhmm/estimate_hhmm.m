rng(4);

text = lower(fileread('alice_in_wonderland.txt'));
text(isspace(text)) = ' ';
alphabet = unique(text);
alphabet = alphabet(isletter(alphabet) | alphabet == ' ');
n_alphabet = length(alphabet);
text_inds = string_to_indices(text, alphabet);

n_seq = 1000;
X = cell(n_seq,1);
seq_length = 10;
for i = 1:n_seq
    t_start = randi(length(text_inds) - seq_length);
    X{i} = text_inds(t_start:t_start+seq_length-1);
end



% X = [1 1;
%      1 2;
%      2 1;
%      2 2];

n_states_per_level = 2;
q = cell(n_states_per_level,1);
for child_idx = 1:n_states_per_level
    q{child_idx} = cell(n_states_per_level,1);
    for gchild_idx = 1:n_states_per_level
        q{child_idx}{gchild_idx} = cell(n_states_per_level,1);
    end
end

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


log_p = zeros(n_seq,1);
log_p_test = zeros(n_seq,1);


%X{1} = [1 2 3 4];
theta = init_params(q, n_alphabet);
max_iter = 500;
for iter = 1:max_iter
    
    iter
    
    theta_new = [];
    
    fprintf(1, '\n     ');
    
    tic
    for seq_idx = 1:n_seq

        fprintf(1, '\b\b\b\b\b%4.1f%%', 100*seq_idx/n_seq);
        
        x = X{seq_idx};
        
        sstats = init_sstats(q, length(x));
              
        [sstats log_p(seq_idx) log_p_test(seq_idx)] = infer_hhmm(x, theta, sstats);
         
        theta_seq = maximize_hhmm(sstats, theta, x);
    
        theta_new = sum_params(theta_new, theta_seq);

    end
    
    fprintf(1,'\n');
    toc
    
    mean_log_p = mean(log_p)
    
    theta = normalize_params(theta, theta_new);
end

p = exp(log_p)
p_test = exp(log_p)
