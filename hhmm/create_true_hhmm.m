function [q_true theta_true] = create_true_hhmm()

%build the true HHMM tree
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


%initialize the parameters with a bias towards end
bias = 3;
theta_true = init_params_bias(q_true, n_alphabet, bias, false);

%save('trueHHMM','q_true','theta_true');


