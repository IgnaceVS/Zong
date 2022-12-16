function Xmat = f_syllablecut(data0, fs, minsp, extth, lev, Filtl, Filts, visual, plots)
% Syllablecut Variables and Example
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% syllablecut(datamat23A01(:,1),44100,60,400,60,1,4000,700)
% minsp :: ms is minimum space between syllables. (will be *Fs/1000)
% maxsp :: apparently not used
%+- extth :: msec extension from threshold level (will be *Fs/1000)
% lev :: Level above threshold for detected samples 
% Filt1 = Smoothing size
% Filts = Threshold level

    maxt=find(data0~=0, 1, 'last');
    data0=data0(1:maxt);

    data=decimate(data0,4);
    fs=fs/4;

    Next=fix(extth*fs/1000); %+- extth msec extension from threshold level.
    bets=minsp*fs/1000; % minsp ms is minimum space between syllables. 

    xpows=conv(ones(Filts,1)/Filts,data.^2);
    xpows=xpows(Filts/2+1:length(data)+Filts/2);
    xpowl=conv(ones(Filtl,1)/Filtl,data.^2);
    xpowl=xpowl(Filtl/2+1:length(data)+Filtl/2);
    t=0:length(data)-1;

    lev=lev/100*max(xpowl); %Level above threshold for detected samples 

    s=zeros(length(data),1);
    for i=1:length(data)
        if (xpows(i)>xpowl(i)+lev)
            s(i)=1;
        end
    end
    ss=find(s==1);

    ss=[1;ss;length(data)];
    sub=find(diff(ss)>bets);
    sub=sort(sub);
    sylllim=0.1*max(max(abs(data)));
    Xmat=zeros(8000,length(diff(sub)),2);    

    if visual
        plot(plots(1), t/fs,[xpows xpowl],'LineWidth',2);
        hold(plots(1), 'on');
        title(plots(1), 'a) The two smoothing power filters, (blue,green), and detected samples above threshold (red)');
        xlabel(plots(1), 's');
        ylabel(plots(1), 'Amplitude^2');   

        plot(plots(1), ss/fs,xpows(ss),'r.');
        hold(plots(1), 'off');

        plot(plots(2), t/fs,real(data));
        hold(plots(2), 'on');
        title(plots(2), 'b) Signal with detected syllables');
        xlabel(plots(2), 's');
        ylabel(plots(2), 'Amplitude');
    end

    for i=1:length(Xmat(1,:,1))
        in=max(1,ss(sub(i)+1)-Next):min(length(data),ss(sub(i+1))+Next);
        
        if visual
            plot(plots(2), [min(in) max(in)]/fs,(-sylllim+sylllim/4*(-1)^i)*[1 1],'m X')
            plot(plots(2), [min(in) max(in)]/fs,(-sylllim+sylllim/4*(-1)^i)*[1 1],'m -')
            text(plots(2), min(in)/fs-0.01,max(max(real(data))),int2str(i))
            axis(plots(2), [0 max(t)/fs min(data)*1.2 max(data)*1.2])
        end

        xx=data(in);
        tt=in;
        Xmat(1:length(xx),i,1)=xx;
        Xmat(1:length(tt),i,2)=tt;

    end
    if visual
        hold(plots(2), 'off');
    end
end
