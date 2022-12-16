function similaritystats = fm_tt_compilesimilarity(tpoint, cluster_data, TwoTutors, least_syllables, tutor_compare)
% 1 Timepoint - the dph at time of recording
% 2 Group - what group they belong to
% 3 TutID 2 or 3
% a - number of syllables in the cluster this syll is part of
% 5 duurt - length of syllable
% duurtclus - mean duration of syllables in cluster
% 6 duurtSDclus - standard deviation of duration
% 7 cluster_data.Cluster_mean - mean cluster_data.Similarity value of this cluster from all others
% 8 cluster_data.Cluster_min - closest cluster to this cluster
% FF of this syll
% 9 FF mean clus
% 10 FF SD clus
% 11 cluster_data.within - cluster_data.Similarity cluster_data.within the cluster
    % 12:19 cluster_data.ratios - 
% -12 nSylls in clus from tutee:
% -13 tut1:
% -14 tut2 : 
% -15 logical if more than one bird involved in cluster 
% -16 total sylls in cluster
% -17 % of sylls belonging to tutee
% -18 % of sylls belonging to tutor1
% -19 % of sylls belonging to tutor2
% 20 least syllables (lowest number of sylls any birds had
% 21 cluster ID
% 22 syllable ID
    % 23:34 = Similarity statistics
% 23 min T-T
% 24 # of closest Tutor motif to this Tutee motif
% 25 mean min T-T
% 26 Range T-T
% 27 min Tutee-Tutee
% 28 # of closest Tutee motif to this Tutee motif
% 29 mean min Tutee-Tutee
% 30 Range Tutee-Tutee
% 31 min Tutor-Tutor
% 32 # of closest Tutor motif to this Tutor motif 
% 33 mean min Tutor-Tutor
% 34 Range Tutor-Tutor

    % labels each syll with # sylls in same cluster 
    aa=zeros(length(cluster_data.Sim),1);
    cluster_mean=zeros(length(cluster_data.Sim),1);
    cluster_min=zeros(length(cluster_data.Sim),1);
    Within=zeros(length(cluster_data.Sim),1);
    Ratios=zeros(length(cluster_data.Sim),8);
    for clus_idx = 1:max(cluster_data.clusters_opt)
        tempcluspos = cluster_data.clusters_opt==clus_idx;
        aa(tempcluspos) = cluster_data.a(clus_idx);
        cluster_mean(tempcluspos) = cluster_data.Cluster_mean(clus_idx);
        cluster_min(tempcluspos) = cluster_data.Cluster_min(clus_idx);
        Within(tempcluspos) = cluster_data.within(clus_idx);
        ratioid = find(tempcluspos);
        Ratios(tempcluspos,:)= repmat(cluster_data.ratios(clus_idx,:),nnz(tempcluspos),1);
    end

    % saves timepoint
    if isempty(tpoint) == 1
        timepoint(1:length(cluster_data.Sim)) = "NA";
    else
        timepoint(1:length(cluster_data.Sim)) = str2double(tpoint);
    end

    [most_similar_motif_tutortutee, most_similar_motif_tutee, most_similar_motif_tutor] =  motif_find_most_similar (cluster_data.Sim);
    similarity = [most_similar_motif_tutortutee zeros(size(most_similar_motif_tutortutee)); most_similar_motif_tutee zeros(size(most_similar_motif_tutortutee)); zeros(size(most_similar_motif_tutortutee)) most_similar_motif_tutor];
    TwoTutors(1:length(cluster_data.Sim)) = TwoTutors;
    if tutor_compare < 3
        tutID(1:length(cluster_data.Sim)) = tutor_compare;
    else
        tutID(1:(length(cluster_data.Sim)*.5)) = 1;
        tutID((length(cluster_data.Sim)*.5)+1:length(cluster_data.Sim)) = 2;
    end
    syllID = 1:length(cluster_data.Sim);
    least_syllables(1:length(cluster_data.Sim)) = least_syllables;

    similaritystats = [timepoint; TwoTutors; tutID; aa.'; cluster_data.duurt; cluster_data.duurtclus; cluster_mean.'; cluster_min.'; cluster_data.FF; cluster_data.FFclus; Within.'; Ratios.'; least_syllables; cluster_data.clusters_opt.'; syllID; similarity];

end