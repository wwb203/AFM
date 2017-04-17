function deflDriftCurve()
%test on 7/3/14
addPicoSDKPath;
t_step = 60;%second
duration = 120;%min
time = zeros(duration,1);
Defl = zeros(duration,1);
for i=1:duration
    Defl(i) = GetStatusRawDefl();
    %Defl(i) = i^2;
    time(i) = i;
    figure(40)
    plot(time(1:i),Defl(1:i),'-');
    xlabel('time(min)');
    ylabel('RawDefl(V)');
    if i>5
        p = polyfit(time(i-4:i),Defl(i-4:i),1);%V/min
        driftspeed = p(1)*1000;
        title(sprintf('driftspeed %f(mV/min)',driftspeed));
    else
        title('Cantilever Drift Speed');
    end
    pause(t_step);
end
