function syllablemaster = fm_syllmatrix(wavname, refmatrix, index, fs, minsp, extth, lev, Filtl, Filts, visual, plots)
% usage: [syllablemaster] =  fm_syllmatrix('concatenatedbirdsong.wav',refmatrix,index, 44100,300,100,0.2,3000,200);
%  refmatrix is the reference database
%  index is the row number in the refmatrix
%  fs is the sampling frequency Hz (usually 44100)
% minsp :: ms is minimum space between syllables. (will be *Fs/1000)
%+- extth :: msec extension from threshold level (will be *Fs/1000)
% lev :: Level above threshold for detected samples 
% Filt1 = Smoothing size
% Filts = Threshold level

    file = fullfile(refmatrix{index,1}, filesep, wavname);
    % pads out start to catch early notes
    zerofill = zeros(44100,1);
    distdata = [zerofill; audioread(file); zerofill; 0.000000000001];

    motifl1=44100*6;
    motifl2=44100*10;

    timev = 1;

    motifv=ones(1,1)*motifl1;
    motifv(4)=motifl2;

    datamat=zeros(motifl2,1);

    time=fix(timev); 
    motifv= fix(length(distdata)-timev);
    datamat(1:motifv,1)=distdata(time+1:time+motifv);

    syllablemaster = f_syllablecut(datamat,fs,minsp,extth,lev,Filtl,Filts, visual, plots);  
end