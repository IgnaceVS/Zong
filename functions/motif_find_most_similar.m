function [most_similar_motif_tutortutee, most_similar_motif_tutee, most_similar_motif_tutor] = motif_find_most_similar(Sim)
% finds the minimum, mean and range of similarity for a given tutee syllable
% compared to other tutee notes, compared to all tutor notes, and finally
% tutor notes compared to other tutor notes
% Rows in each output go min ; position (number of note/motif closest); mean ; range
    topidx = length(Sim)*.5;
    slicedsim = Sim(topidx+1:end,1:topidx);
    [M,I] = max(slicedsim,[],1);
    most_similar_motif_tutortutee = [M; I+topidx; mean(slicedsim,1); range(slicedsim)];

    tuteeslicedsim = Sim(1:topidx,1:topidx);
    tuteeslicedsim(logical(eye(size(tuteeslicedsim)))) = [];
    tuteeslicedsim = reshape(tuteeslicedsim,[],length(slicedsim));
    % mean_similar_motif_tutee = mean(tuteeslicedsim,1);
    [M4, I4]= max(tuteeslicedsim,[],1);
    most_similar_motif_tutee = [M4; I4; mean(tuteeslicedsim,1); range(tuteeslicedsim)];

    tutorslicedsim = Sim(topidx+1:end,topidx+1:end);
    tutorslicedsim(logical(eye(size(tutorslicedsim)))) = [];
    tutorslicedsim = reshape(tutorslicedsim,[],length(slicedsim));
    % mean_similar_motif_tutor = mean(tutorslicedsim,1) ;
    [M6, I6]= max(tutorslicedsim,[],1);
    most_similar_motif_tutor = [M6; I6; mean(tutorslicedsim,1); range(tutorslicedsim)];
end