function [H,wei,Df]=hermitefunc(M,K)
    % Computation of the Hermite functions (length M and number of windows K) 

    Fn=15;
    if abs(M/2-fix(M/2))<0.1
        t1=[-M/2+1:M/2]'/M*Fn;
    else
        t1=[-(M-1)/2:(M-1)/2]'/M*Fn;
    end

    h(:,1)=ones(M,1);
    h(:,2)=2*t1;

    if K>1
        for i=2:K
            h(:,i+1)=2*t1.*h(:,i)-2*(i-1)*h(:,i-1);
        end
    end

    for i=0:K
        H(:,i+1)=(h(:,i+1).*exp(-(t1.^2)/2)/sqrt(sqrt(pi)*2^(i)*factorial(i)));
    end

    H=H(:,1:K); %The number of K final Hermite functions

    wei=ones(K,1)/K;
    [N,K]=size(H);

    for i=1:K
        Pt=H(:,i)'*H(:,i);
        for n=1:N
            sumP=H(1:n,i)'*H(1:n,i);
            if sumP<0.005*Pt
                Lt(i)=2*(N/2-n);
            end
        end
        S1=abs(fft(H(:,i),1024)).^2;
        Pf=sum(S1(1:512));
        for f=1:512
            sumP=sum(S1(1:f));
            if sumP<=0.99*Pf
                Lf(i)=2*f/1024;
            end
        end
    end

    if K>1
        Dt=max(Lt);
        Df=max(Lf);
    else
        Dt=Lt;
        Df=Lf;
    end
end
