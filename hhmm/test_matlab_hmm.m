text = lower(fileread('alice_in_wonderland.txt'));
text(isspace(text)) = ' ';
alphabet = unique(text);
alphabet = alphabet(isletter(alphabet) | alphabet == ' ');
n_alphabet = length(alphabet);
text_inds = string_to_indices(text, alphabet);

n_state = n_alphabet/2;
A = rand(n_state,n_state);
A = bsxfun(@rdivide, A, sum(A,2));

B = rand(n_state, n_alphabet);
B = bsxfun(@rdivide, B, sum(B,2));


[Anew Bnew] = hmmtrain(text_inds(1:10000), A, B, 'Maxiterations', 100);


%%
theta = init_params(q, n_alphabet, false);
theta.A(:,1:27) = Anew;

for child_idx = 1:n_alphabet
    theta.subs{child_idx}.B = Bnew(child_idx,:);
end

theta.pi = ones(n_alphabet,1);


theta = normalize_params(theta, theta);

