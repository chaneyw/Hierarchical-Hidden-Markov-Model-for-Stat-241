breadth = 3;
depth = 3; % note this isn't actually used to build the tree-- change depth by hand
q_true = cell(breadth,1);
for child_idx = 1:breadth
    q_true{child_idx} = cell(breadth,1);
     for gchild_idx = 1:breadth
         q_true{child_idx}{gchild_idx} = cell(breadth,1);
         %for ggchild_idx = 1:breadth
         %    q_true{child_idx}{gchild_idx}{ggchild_idx} = cell(breadth,1);
         %end
     end
end
n_alphabet = 4;

bias = 3;
theta_true = init_params_bias(q_true, n_alphabet, bias, false);

sample = zeros(1,1000);
for i = 1:1000
    sample(i)=length(sample_hhmm(theta_true,[],Inf));
end

max(sample)
mean(sample)