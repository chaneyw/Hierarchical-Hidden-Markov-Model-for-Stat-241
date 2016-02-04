%rng(4);
clear;

%matlabpool

% Get the test and training data
text = lower(fileread('alice_in_wonderland.txt'));
text(isspace(text)) = ' ';
alphabet = unique(text);
alphabet = alphabet(isletter(alphabet) | alphabet == ' ');
n_alphabet = length(alphabet);
text_inds = string_to_indices(text, alphabet);

half_pt = ceil(length(text_inds)/2);
test_inds = text_inds(1:half_pt);
train_inds = text_inds(half_pt:end);

seq_length = 10;

n_test_seq = 10;
Xtest = cell(n_test_seq,1);
for i = 1:n_test_seq
    t_start = randi(length(test_inds) - seq_length);
    Xtest{i} = test_inds(t_start:t_start+seq_length-1);
end

n_train_seq = 10;
Xtrain = cell(n_train_seq,1);
for i = 1:n_train_seq
    t_start = randi(length(train_inds) - seq_length);
    Xtrain{i} = train_inds(t_start:t_start+seq_length-1);
end




% Build a HHMM tree structure

breadth = 3;
depth = 3; % note this isn't actually used to build the tree-- change depth by hand
q = cell(2,1);
for child_idx = 1:breadth
    q{child_idx} = cell(breadth,1);
     for gchild_idx = 1:breadth
         q{child_idx}{gchild_idx} = cell(breadth,1);
         for ggchild_idx = 1:breadth
             q{child_idx}{ggchild_idx} = cell(breadth,1);
         end
     end
end


% Smoothing parameters
gamma = 1e-9;
lambda.pi = gamma/length(q);
lambda.A = gamma/length(q)^2;
lambda.B = gamma/length(q)*n_alphabet;



% Do EM to fit the HHMM
theta = init_params(q, n_alphabet, false);
counts_seq = cell(n_train_seq,1);
sstats_seq = cell(n_test_seq,1);

max_iter = 100;
train_log_p = zeros(n_train_seq,1);
mean_log_p_hist = zeros(max_iter,1);

for iter = 1:max_iter
    
    iter
    
    fprintf(1,'\n      ');
    
    tic
    parfor seq_idx = 1:n_train_seq
        
        
        fprintf(1, '\b\b\b\b\b%4.1f%%', 100*seq_idx/n_train_seq);
        
        x = Xtrain{seq_idx};
        
        counts_seq{seq_idx} = init_params(q, n_alphabet, true);
        sstats_seq{seq_idx} = init_sstats(q,length(x));

        [sstats_seq{seq_idx} train_log_p(seq_idx)] = infer_hhmm(x, theta, sstats_seq{seq_idx});
        
        counts_seq{seq_idx} = maximize_hhmm(sstats_seq{seq_idx}, counts_seq{seq_idx}, x, lambda);
        
    end
    
    fprintf(1,'\n');
    toc
    
    mean_log_p = mean(train_log_p)
    mean_log_p_hist(iter) = mean_log_p;
    
    
    counts_sum = init_params(q, n_alphabet, true);
    counts_sum = add_params_list(counts_sum, counts_seq);
    
    theta = normalize_params(theta, counts_sum);
end


% Calculate the log-likelihood on the test data
test_log_p = zeros(n_test_seq, 1);
for i = 1:n_test_seq
   x_test = Xtest{i};
   sstats = init_sstats(q, length(x_test));
   test_log_p(i) = compute_log_likelihood(x_test, theta, sstats); 
end

test_p = exp(test_log_p);
test_bits_per_char = mean(log2(test_p))/seq_length;

% shuffled test set performance
shuffled_test_log_p = zeros(n_test_seq, 1);
for i = 1:n_test_seq
    x_test_shuffled = Xtest{i};
    x_test_shuffled = x_test_shuffled(randperm(length(x_test_shuffled)));
    sstats = init_sstats(q, length(x_test_shuffled));
    shuffled_test_log_p(i) = compute_log_likelihood(x_test_shuffled, theta, sstats);
end

shuffled_test_p = exp(shuffled_test_log_p);
shuffled_test_bits_per_char = mean(log2(shuffled_test_p))/seq_length;


filename = sprintf('runs/b=%d_d=%d_%s.mat', breadth, depth, datestr(now, 'yyyymmddTHHMMSS'));

runtime = cputime;

save(filename);

%matlabpool close;
