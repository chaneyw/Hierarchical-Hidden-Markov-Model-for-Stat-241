function [indices] = string_to_indices(string, alphabet)

indices = zeros(size(string));

n_alphabet = length(alphabet);

for i = 1:n_alphabet
    indices(string == alphabet(i)) = i;    
end

indices = indices(indices > 0);

end

