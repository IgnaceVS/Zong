function ratios = f_cluster_entanglement_tut_tutor(mastern,clusters_opt,tut_compare)
% Cluster entaglement - to discern how tightly entwined two birds syllables are
    if tut_compare==1 % Compare to first tutor.
        clusID = clusters_opt;
        clusID(1:mastern(1),2) = 1;
        clusID(mastern(1)+1:(mastern(1)+mastern(2)),2) = 2;
    elseif tut_compare==2 % Compare to second tutor.
        clusID = clusters_opt;
        clusID(1:mastern(1),2) = 1;
        clusID(mastern(1)+1:(mastern(1)+mastern(2)),2) = 3;

    elseif tut_compare==23 % Comparison between tutors.
        clusID = clusters_opt;
        clusID(1:mastern(1),2) = 2;
        clusID(mastern(1)+1:(mastern(1)+mastern(2)),2) = 3;
    end

    ratios = zeros(max(clusters_opt),3);

    for clus_idx=1:max(clusters_opt)
        tempcluspos = clusters_opt==clus_idx;

        ratios(clus_idx,1) = sum(clusID(tempcluspos,2) == 1);
        ratios(clus_idx,2) = sum(clusID(tempcluspos,2) == 2);
        ratios(clus_idx,3) = sum(clusID(tempcluspos,2) == 3);
        if ratios(clus_idx,1)>0 && ( ratios(clus_idx,2)>0 || ratios(clus_idx,3)>0 )
            ratios(clus_idx,4) = 1;
        else
            ratios(clus_idx,4) = 0;
        end

        ratios(:,5) = sum(ratios(:,1:3),2);
        ratios(:,6) = (ratios(:,1)./ratios(:,5));
        ratios(:,7) = (ratios(:,2)./ratios(:,5));
        ratios(:,8) = (ratios(:,3)./ratios(:,5));
    end
end
