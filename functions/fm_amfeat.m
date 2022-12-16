function [AUCRmat,AVCRmat] = fm_amfeat(syllablemaster, visual, plots, index)
    [H,wei]=hermitefunc(256,8); % The multitaper set of 8 Hermite function windows

    AUCRmat=zeros(512,60);
    AVCRmat=zeros(512,60);

    [AUmat,AVmat]=mwspectambfunc(syllablemaster,H,44100/4,1024,wei, visual, plots, index);

    AUCRmat(1:length(AUmat(:,1)),1:length(AUmat(1,:)),1)=AUmat;
    AVCRmat(1:length(AVmat(:,1)),1:length(AVmat(1,:)),1)=AVmat;
end