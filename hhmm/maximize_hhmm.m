function theta_seq = maximize_hhmm(sstats, theta, x, lambda)
    theta_seq = maximize_hhmm_rec(sstats,theta, x, true, lambda);
end

function theta_seq = maximize_hhmm_rec(sstats, theta, x, isroot, lambda)

% start by copying over the structure
theta_seq = theta;

n_child = size(sstats.subs,1);
T = length(x);

chi = exp(sstats.lchi);
xi = exp(sstats.lxi);

if isroot
    % There's only one meaningful time step for chi at the root, the first
    theta_seq.pi = chi(:,1);
    isroot = false;
else
    % At internal each time step of chi contributes a soft count the
    % vertical transition probs
    theta_seq.pi = sum(chi, 2);
end

% Smoothing
theta_seq.pi = theta_seq.pi + T*lambda.pi;

% Each time step of xi contributes a soft count to the horizontal
% transition probs
theta_seq.A = sum(xi, 3);
theta_seq.A = theta_seq.A + T*lambda.A;


for child_idx = 1:n_child
    
    if sstats.subs{child_idx}.isleaf

        % This sequence contributes a soft count of the probability that
        % that hhmm was in this state when a symbol was generated to propriate
        % symbol in B
        for symbol_idx = 1:size(theta.subs{child_idx}.B,1)
            % two ways it might have been in this state: it came for from a
            % parent or it came from  sibling after the first time step
            from_parent = chi(child_idx, :);
            from_parent = sum(from_parent(x == symbol_idx));
            
            from_sib = sum(squeeze(xi(:, child_idx, :)), 1);
            from_sib = from_sib(1:end-1);
            from_sib = sum(from_sib(x(2:end) == symbol_idx));
            
%             if symbol_idx == 2
%                 child_idx
%                 from_sib
%                 from_parent
%             end
            
            theta_seq.subs{child_idx}.B(symbol_idx) = from_parent + from_sib;
        end
        
        theta_seq.subs{child_idx}.B = theta_seq.subs{child_idx}.B + T*lambda.B;
    else
        theta_seq.subs{child_idx} = maximize_hhmm_rec(sstats.subs{child_idx},... 
                                                      theta.subs{child_idx}, x, isroot, lambda);
    end
    
    %theta_seq.subs{child_idx}.B
    
end
    
    %theta_seq.pi
    %theta_seq.A

end