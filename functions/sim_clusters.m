function [within, closestnonclustersim, howfarclus, Cluster_min, Cluster_mean] = sim_clusters (sim, clusters_opt)
% finds mean similarity within a cluster
% % finds distance between other clusters
    clussim = zeros(1, max(clusters_opt));
    for clus_idx = 1:max(clusters_opt)
        tempcluspos = find(clusters_opt==clus_idx);
        tempclussim = zeros(1, (length(tempcluspos)+1)*length(tempcluspos)/2);

        % loop to find similarity between all individual syllables within each
        % cluster and then take a mean of those
        c = 1;
        for syll_idx = 1:length(tempcluspos)
            for syllcomp = syll_idx:length(tempcluspos)
                tempclussim(c) = sim(syll_idx,syllcomp); 
                c = c + 1;
            end
        end
        clussim(clus_idx) = mean(tempclussim);
    end
    within = clussim;

    % For each data point, calculate the mean distance between that point
    % and all points which are NOT in that cluster:

    % % first loop flags current cluster with cl, flags non cluster members
    % with other_cl, loops through other clusters with J, compiling their
    % distance from i in mean_dist_i_others, then takes the minimal value here
    % to find the closest value
    if max(clusters_opt) == 1
        closestnonclustersim = []; 
        howfarclus  = [];
        Cluster_min  = [];
        Cluster_mean = [];
    else
        MIN_OUT = zeros(1, length(clusters_opt));
        MEAN_OUT = zeros(1, length(clusters_opt));
        for clus_idx_between = 1:length(clusters_opt)
            cl       = clusters_opt(clus_idx_between);
            all_cl   = 1:max(clusters_opt);
            other_cl = all_cl(all_cl ~= cl);  % all other clusters
            mean_dist_i_others = zeros(1,max(clusters_opt)-1);
            for j = 1:length(other_cl) % go through all other clusters and calculate the mean distance to syll i
                J = other_cl(j);
                % all sylls in cluster J
                mean_dist_i_others(j) = mean(sim(clus_idx_between, clusters_opt == J));   % mean of distances between syll i and all sylls in cluster j
            end
            MIN_OUT(clus_idx_between) = min(mean_dist_i_others);
            MEAN_OUT(clus_idx_between) = mean(mean_dist_i_others);
        end
        closestnonclustersim = MIN_OUT;
        howfarclus = MEAN_OUT;
        Cluster_min = zeros(1,max(clusters_opt));
        Cluster_mean = zeros(1,max(clusters_opt));
        for clusterID = 1:max(clusters_opt)
            sylls_clusterID = clusters_opt == clusterID;
            Cluster_min(clusterID) = mean(MIN_OUT(sylls_clusterID));
            Cluster_mean(clusterID) = mean(MEAN_OUT(sylls_clusterID));
        end
    end
end