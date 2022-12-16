function [audio, cluster_data] = fm_cluster(data, master, tutor_compare, visual, plots)
    %% Clustering of syllables in a song with Silhouette index
    % clear all; close all; clc
    %  n     (int)    - number of syllables in song
    %  data  (Nxn)    - song file containing n syllables of (max-)length N (padded with 0s if necessary) 
    %  m     (int)    - length of u- and v-vectors
    %  U     (mxn)    - the u-vectors for each syllable
    %  V     (mxn)    - the v-vectors for each syllable

    U = master.U;
    V = master.V;
    n = sum(master.n);
    audio = {};

    %% Compute dissimilarity matrix (pairwise distances between syllables)
    cluster_data.Similarity = min(U'*U,V'*V); 
    Dissim = 1-cluster_data.Similarity;
    Dissim(Dissim<0) = 0;  
    Dissim(logical(eye(size(Dissim)))) = 0; 

    %% Plot the song
    Fs = 44100/4;         
    l  = length(data(:));
    t  = linspace(0, l/Fs, l);
    % h  = figure
    if visual
        plot(plots(1), t,data(:));
        hold(plots(1), 'on');
        title(plots(1), ['Song to be classified, duration = ', num2str(l/Fs/60),' min'])
        axis(plots(1), 'tight');
        xlabel(plots(1), 'Time in seconds')
        hold(plots(1), 'off');
    end

    %% Compute and plot the dendrogram; use average link 
    Dissim_trian    = lower_tri_vec(Dissim);
    Z               = linkage(Dissim_trian, 'average');

    %% Compute silhouette values for different candidate cutoffs 
    rhogrid         = 0.033:0.001:0.1;                      
    number_clusters = zeros(1,length(rhogrid));
    clusters        = zeros(length(rhogrid), n);
    sil             = NaN(1, length(rhogrid));

    for i = 1:length(rhogrid)
        rho = rhogrid(i);

        % Trim the tree at cutoff rho to get the clusters
        clusters_rho = cluster(Z, 'cutoff', rho, 'criterion', 'distance');  

        clusters(i, 1:length(clusters_rho)) = clusters_rho;
        number_clusters(i) = max(clusters_rho);  % total number of clusters for threshold rho

        if(number_clusters(i)>1)
            sil(i) = compute_silhouette(clusters_rho, Dissim);
        end
    end

    %% Final clustering by trimming the dendrogram tree at optimal rho
    % Identify the optimal threshold
    [~, idx_sil] = sort(sil, 'descend');
    sil_opt_idx         = idx_sil(1);
    rho_opt = 0.0450;
    %rho_opt             = rhogrid(sil_opt_idx);
 
    % Cut the tree at rho_opt
    cluster_data.clusters_opt = cluster(Z, 'cutoff', rho_opt, 'criterion', 'distance');  
 
    % resulting cluster sizes:
    [cluster_data.a, ~] = hist(cluster_data.clusters_opt,unique(cluster_data.clusters_opt));

    %% Plot dendrogram and mark the trimming at rho_opt by color
    bx = 0:0.01:size(Dissim,2);
    if visual
        plot(plots(2),bx, rho_opt*ones(1, length(bx)),  ':', 'Color', 0.4*ones(1,3))
        hold(plots(2), 'on');
        dendrogram_subplot(plots(2),Z,0,'ColorThreshold', rho_opt);
        % Add cutoff threshold
        title(plots(2),'\bf Dendrogram')
        xlabel(plots(2),'syllables')
        ylabel(plots(2),'dissimilarity')
        hold(plots(2), 'off');

        %% Plot the 3 first clusters
        audio = cell(1,3);
        for cl = 1:3   % max(clus)
            data_play = data(:, cluster_data.clusters_opt == cl);
            plot(plots(cl+2),data_play(:))
            hold(plots(cl+2), 'on');
            title(plots(cl+2),['Cluster ', int2str(cl)])
            hold(plots(cl+2), 'off');

            audio(cl) = {data_play};
        end
    end
    cluster_data.Sim = 1-Dissim;
    [cluster_data.FF, cluster_data.FFclus, cluster_data.pitchmaster, cluster_data.duurt, cluster_data.duurtclus] = ffcalc_ind(data, cluster_data.clusters_opt);
    [cluster_data.within, cluster_data.closestnonclustersim, cluster_data.howfarclus, cluster_data.Cluster_min, cluster_data.Cluster_mean] = sim_clusters (cluster_data.Sim, cluster_data.clusters_opt);
    cluster_data.ratios = [];
    if tutor_compare ~= 0
        cluster_data.ratios = f_cluster_entanglement_tut_tutor (master.n,cluster_data.clusters_opt,tutor_compare);
    end
end

