function silhouette = compute_silhouette(clusters, Dissim)
% Computes silhouette values
% Input: 
% clusters  (nx1)   -   clusters(j) gives cluster index of syllable j
% Dissim    (nxn)   -   dissimilarity matrix
%
% Output: 
% Silhouette-index: based on the difference between the average
% distance to points in the closest cluster and to points in the same cluster
    K   = max(clusters);      % number of clusters
    n   = length(clusters);   % number of syllables 
    s = zeros(1,n);
    MEAN_IN = s;
    MIN_OUT = s;
    % For each data point, calculate the mean distance between that point
    % and the other points in its cluster
    for i = 1:n
        cl = clusters(i);                  % cluster of syllable i
        sylls_cl = find(clusters == cl);   % all syllables in that cluster
        idx = sylls_cl(sylls_cl ~= i);     % take all OTHER sylls in that cluster
        mean_in = mean(Dissim(i, idx));    % mean of all distances to that syllable
        MEAN_IN(i) = mean_in;              % mean_in = NaN, if N = 1
    end

    % For each data point, calculate the mean distance between that point
    % and all points which are NOT in that cluster:
    for i = 1:n
        cl       = clusters(i);
        all_cl   = 1:K;
        other_cl = all_cl(all_cl ~= cl);  % all other clusters
        mean_dist_i_others = zeros(1,K-1);
        for j = 1:length(other_cl)             % go through all other clusters and calculate the mean distance to syll i
            J = other_cl(j);
            % all sylls in cluster J
            mean_dist_i_others(j) = mean(Dissim(i, clusters == J));   % mean of distances between syll i and all sylls in cluster j
        end
        MIN_OUT(i) = min(mean_dist_i_others);
    end

    for i = 1:n
        s(i) = (MIN_OUT(i) - MEAN_IN(i))/max([MIN_OUT(i), MEAN_IN(i)]);
    end

    silhouette = nanmean(s);
end



