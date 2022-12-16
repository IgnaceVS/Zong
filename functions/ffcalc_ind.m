function [FF, FFclusind, pitchmaster, duurt, duurtclusind] = ffcalc_ind(syllablemaster, clusters_opt)

FF=[];
pitchmaster = [];
temp_x = [];
duurt = [];
FFclus = [];
FFclusind = [];
duurtclus = [];
SFF = [];
Sd = [];
    
    for i=1:size(syllablemaster,2)
        %using yin algorithm
        temp_x = syllablemaster(:,i,1).';
        duurt = [duurt numel(nonzeros(temp_x))];
        [~, pitchmaster(:,i)] = yin_estimator(temp_x,11025);
    end
    duurt = duurt./11.025;
    pitchmaster = downsample(pitchmaster,254); % Reduces by factor of 23ms window so avoid repeat values
    pitchmaster(isinf(pitchmaster)) = 0; % Replace infinite values with zeros
    pitchmaster = movmean(pitchmaster,5,1); % Creates moving average of 5 timebins
    FF = max(pitchmaster); % takes the highest average, this is the fundamental frequency of the syllable

    for clus_idx = 1:max(clusters_opt)
        tempcluspos = find(clusters_opt==clus_idx);
%         FFclus(i) = mean(FF(tempcluspos));
%         SFF(i) = std(FF(tempcluspos),1,2);
%         duurtclus(clus_idx) = mean(duurt(tempcluspos));
%         Sd(i) = std(duurt(tempcluspos),1,2);
    FFclus = [FFclus mean(FF(tempcluspos))];
    SFF = [SFF std(FF(tempcluspos),1,2)];
    duurtclus = [duurtclus mean(duurt(tempcluspos))];
    Sd = [Sd std(duurt(tempcluspos),1,2)];
    end
    
    for clus_idxx = 1:max(clusters_opt)
        tempclusposs = find(clusters_opt==clus_idxx);
        FFclusin(tempclusposs) = FFclus(clus_idxx);
        SDFF(tempclusposs) = SFF(clus_idxx);
        duurtclusin(tempclusposs) = duurtclus(clus_idxx);
        SDDU(tempclusposs) = Sd(clus_idxx);
    end
    FFclusind = [FFclusin; SDFF];
    duurtclusind = [duurtclusin; SDDU];
end