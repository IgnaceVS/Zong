function [U,V,n,m] = fm_uvdata(AUCRmat, AVCRmat)
    nsyll_strophe = nnz(any(AUCRmat(:,:),1)); 
    U = AUCRmat(:,1:nsyll_strophe);      % The u-vectors of a strophe
    V = AVCRmat(:,1:nsyll_strophe);      % The v-vectors of a strophe

    n  = size(U,2); % number of syllables in the song
    m  = size(U,1); % length
end
