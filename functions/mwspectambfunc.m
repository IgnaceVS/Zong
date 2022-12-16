function [AUmat,AVmat,Amattot]=mwspectambfunc(datamat,WIN,Fs,NFFT,wei, visual, plots, index)
    NSTEP=8;
    [N,maxsyll,~]=size(datamat);

    TI0=1:NSTEP:N;

    datamat=datamat(:,:,1);
    [L,K]=size(WIN);

    lower = 1;
    upper = maxsyll;
    
    if visual > 0 % Not pretty, but works for now...
        lower = visual;
        upper = visual;
    end
    loading_msg = strcat({'Bird '}, num2str(index), {': Preparing data... '});
    visible_progress = 'off';
    if visual == 0
        visible_progress = 'on';
    end
    loading = waitbar(0, strcat(loading_msg, '0%'), 'Visible' , visible_progress);
        
    AUmat = zeros(NFFT/2, upper-lower+1);
    AVmat = zeros(NFFT/2, upper-lower+1);
    
    for syllno = lower:upper
        X=datamat(:,syllno);
        Lmax=find(X~=0, 1, 'last' );
        X=X(1:Lmax); 
        x=[zeros(fix(L/2),1);X;zeros(fix(L/2),1)];

        Rmattot=zeros(NFFT/2,length(TI0));
        Smattot=zeros(NFFT/2,length(TI0));
        Amattot=zeros(NFFT/2,NFFT/2);
        Dmattot=zeros(NFFT/2,NFFT/2);

        for k=1:K
            ii=0;

            Smat=zeros(NFFT,length(TI0));

            for i=1:NSTEP:Lmax
                ii=ii+1;
                testdata=x(i:i+L-1);
                Smat(:,ii)=abs(fft((WIN(:,k).*testdata),NFFT)).^2;
            end

            Rmat=ifft(Smat);
            Amat=fft(Rmat',NFFT);

            Amat=fftshift(Amat,2);
            Amat=fftshift(Amat,1);
            Amat=Amat';

            Smattot=Smattot+wei(k)*Smat(1:NFFT/2,:);
            Amattot=Amattot+wei(k)*(Amat(NFFT/4+1:NFFT-NFFT/4,NFFT/4+1:NFFT-NFFT/4));

        end

        Amattot=abs(Amattot);

        [u,~,v]=svd(Amattot);
                
        AUmat(:,syllno-lower+1)=abs(u(:,1));
        AVmat(:,syllno-lower+1)=abs(v(:,1));
    
        if visual
            plot(plots(1), 0:length(X)-1, X);
            xlabel(plots(1), 'Time/ms');
            title(plots(1), 'Signal');

            TI=TI0/Fs*1000;
            FI=(0:NFFT/2-1)'/(NFFT)*Fs/1000;

            c=[min(min(Smattot)) max(max(Smattot))];
            pcolor(plots(2), TI,FI,Smattot(1:NFFT/2,:));
            shading(plots(2), 'interp');
            caxis(plots(2), c);
            axis(plots(2), [0 380 0 5]);
            ylabel(plots(2), 'Frequency/kHz');
            xlabel(plots(2), 'Time/ms');
            title(plots(2), 'MT Spectrogram');

            NU=(-NFFT/4:NFFT/4-1)'/(NFFT)*Fs/1000/NSTEP;
            TAU=(-NFFT/4:NFFT/4-1)'/Fs*1000;
            c=[min(min(abs(Amattot))) max(max(abs(Amattot)))];
            pcolor(plots(3), NU,TAU,abs(Amattot(1:NFFT/2,1:NFFT/2)));
            shading(plots(3), 'interp');
            caxis(plots(3), c);
            axis(plots(3), [-0.1 0.1 -10 10]);
            xlabel(plots(3), 'Doppler/kHz');
            ylabel(plots(3), 'Lag/ms');
            title(plots(3), 'MT Ambiguity function');

        end
        if isvalid(loading)
            text = strcat(loading_msg, num2str(round(100*syllno/upper)), '%');
            waitbar(syllno/upper, loading, text);
        end
    end
    if isvalid(loading)
        close(loading);
    end
end
