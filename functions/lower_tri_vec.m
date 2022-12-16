function D = lower_tri_vec(Dissim)
% calculates the lower triangular matrix (without diagonal) of a matrix
% Dissim and stacks it as vector
    m = size(Dissim,2); 
    D = zeros(1, (m-1)*m/2);
    i_first = 1;
    for i = 1:m-1
        i_last = i_first + (m-i-1);
        D(i_first:i_last) = Dissim((i+1):m, i)';
        i_first = i_last + 1;
    end
end