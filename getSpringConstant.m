addPicoSDKPath;
if ~exist('springConstant.mat','file')
    input('deflection~0V,turn on filter power');
    input('Approach Tip');
    input('Adjust Motor');
    dV = 0.2;
    [deflSens1,~] = getDeflSens(dV);%V/m
    MotorWithdraw();
    input('Withdraw Tip');
    %read&display spowerspectral
    %low pass filter power
    g = gpib('ni', 0, 5);
    save('gpibport.mat', 'g');
    fopen(g);
    fprintf(g, 'OUTP:STAT 1');
    fprintf(g, 'INST:NSEL 1');
    fprintf(g, 'Volt 5');
    fprintf(g, 'INST:NSEL 2');
    fprintf(g, 'Volt 5');
    pause(1)
    %connect to Data acquisition card
    s = daq.createSession('ni');
    s.addAnalogInputChannel('Dev2', 0, 'Voltage');
    Fs = 2^19;
    Duration  = 4;
    s.Rate = Fs;
    s.DurationInSeconds = Duration;
    %average over multiple pwd
    Navg = 10;
    for i = 1:Navg
        daqData = s.startForeground();
        %FFT
        N = length(daqData);
        daqData = daqData.*hann(N);
        xdft = fft(daqData, N);
        xdft = xdft(1:floor(length(xdft)/2 + 1));
        psdx = abs(xdft).^2/N/Fs;
        %power spectral
        psdx(2:end-1) = 2*psdx(2:end-1);
        
        %select data around peak
        freqleft = 0e3;
        freqright = 20e3;
        freq1 = freq(freq>freqleft&freq<freqright);
        psdx1 = psdx(freq>freqleft&freq<freqright);
        if i==1
            psd = psdx1;
        else
            psd = psd + psdx1;
        end
    end
    psd = psd/Navg;
    figure
    semilogy(freq1(1:10:end),psd(1:10:end),'-');grid on;
    %plot(freq1,F(p,freq1),'k-');
    title('Periodogram Using FFT');
    xlabel('Freqency (Hz)');
    ylabel('Power Frequency (V^2/Hz)');
    %hold off
    fprintf(g, 'OUTP:STAT 0');
    fclose(g);
    delete(g);
    delete('gpibport.mat')
    clear g
    save('springConstant.mat','Fs','Duration','Navg','psd','freq','deflSens1');
    input('Turn off filter power');
else
    load('springConstant.mat','Fs','Duration','Navg','psd','freq','deflSens1');
end
input('\nApproach Tip');
input('\nAdjust Motor');
dV = 0.2;
[deflSens2,~] = getDeflSens(dV);
MotorWithdraw();
SetMotorWithdrawDistance(50e-6);
result = input('Withdraw Tip');
S = (deflSens1 + deflSens2)/2;%V/m
prompt = 'peak lower frequency(kHz):';
freqLeft = input(prompt)*1e3;
prompt = 'peak higher frequency(kHz):';
freqRight = input(prompt)*1e3;
prompt = 'left noise range width(kHz):';
noiseLeft = input(prompt)*1e3;
prompt = 'right noise range width(kHz):';
noiseRight = input(prompt)*1e3;

noise = cat(1,psd(freq>noiseLeft&freq<freqLeft),...
    psd(freq>freqRight&freq<noiseRight));
noiseFloor = mean(noise(:));

freqf = freq(freq>freqLeft&freq<freqRight);
psdf = psdf(freq>freqLeft&freq<freqRight);
%integration from fl to fr
avg_Pv = trapz(freqf,psdf);
%substract noiseFloor
avg_Pv = avg_Pv - noiseFloor*(freqRight-freqLeft);

k = 0.9707*1.3806488e-23*(273+22)*S^2/1.09^2/avg_Pv
delete('springConstant.mat');
save('springConstant.mat','Fs','Duration','Navg','psd','freq','k','noiseLeft',...
    'freqLeft','freqRight','noiseRight');
%clean memory
clear('psd','psdf','Fs','Duration','Navg','freq','noiseLeft');
clear('freqLeft','freqRight','noiseRight');
