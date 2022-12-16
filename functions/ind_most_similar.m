function [most_similar_motif_tutee] = ind_most_similar(Dissim)
% finds the minimum, mean and range of dissimilarity for a given tutee syllable
% compared to other tutee notes, compared to all tutor notes, and finally
% tutor notes compared to other tutor notes
% Rows in each output go min ; position (number of note/motif closest); mean ; range
    tutee_sliced_dissim = Dissim;
    tutee_sliced_dissim(logical(eye(size(tutee_sliced_dissim)))) = [];
    tutee_sliced_dissim = reshape(tutee_sliced_dissim,[],length(Dissim));
    % mean_similar_motif_tutee = mean(tuteesliceddissim,1);
    [M, I] = min(tutee_sliced_dissim,[],1);
    most_similar_motif_tutee = [M; I; mean(tutee_sliced_dissim,1); range(tutee_sliced_dissim)];
end