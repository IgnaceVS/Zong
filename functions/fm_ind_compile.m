function similaritystats = fm_ind_compile(tpoint, cluster_data)
% 1 Timepoint - the dph at time of recording
% 2 a - number of syllables in each cluster
% 3 duurt
% 4 duurtclus - mean duration of syllables in cluster
% 5 cluster mean (mean similarity to other clusters)
% 6 cluster min - closest similarity to another cluster
% 7 FF
% 8 FFclus 
% 9 FF clus SD
% 10 within - Similarity within the cluster
% 11 cluster ID
% 12 syllable ID
% 13 min Tutee-Tutee
% 14 # of closest Tutee motif to this Tutee motif
% 15 mean min Tutee-Tutee
% 16 Range Tutee-Tutee

	% labels each syll with various stats for its own cluster 
    if max(cluster_data.clusters_opt) == 1
        Within(length(cluster_data.Sim),1) = mean(cluster_data.within);
        aa = cluster_data.clusters_opt;
        cluster_mean = cluster_data.Cluster_mean;
        cluster_min = cluster_data.Cluster_min;
    else
        aa=zeros(length(cluster_data.Sim),1);
        cluster_mean=zeros(length(cluster_data.Sim),1);
        cluster_min=zeros(length(cluster_data.Sim),1);
        Within=zeros(length(cluster_data.Sim),1);
        for clus_idx = 1:max(cluster_data.clusters_opt)
            tempcluspos = cluster_data.clusters_opt==clus_idx;
            aa(tempcluspos) = cluster_data.a(clus_idx);
            cluster_mean(tempcluspos) = cluster_data.Cluster_mean(clus_idx);
            cluster_min(tempcluspos) = cluster_data.Cluster_min(clus_idx);
            Within(tempcluspos) = cluster_data.within(clus_idx);
        end
    end

    if isempty(tpoint) == 1
        timepoint(1:length(cluster_data.Sim)) = "NA";
    else
        timepoint(1:length(cluster_data.Sim)) = str2double(tpoint);
    end

    similarity =  ind_most_similar (cluster_data.Sim);
    syllID = 1:length(cluster_data.Sim);
    similaritystats = [timepoint; aa.'; cluster_data.duurt; cluster_data.duurtclus; cluster_mean.'; cluster_min.'; cluster_data.FF; cluster_data.FFclus; Within.'; cluster_data.clusters_opt.'; syllID; similarity];
end