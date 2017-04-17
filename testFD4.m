%script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Intialization
%demanding Data,mainRefPix,spring
%constant,vesicle
%expecting experiment.FD, currentVesicleId
addPicoSDKPath;
closedLoop = false;

servoOn = true;
servoOff = false;
stepNum = 12;
stepSize = 0e-9;
vApproach = 0.7e-6;%1 um/s
vRetract = 0.7e-6;%1 um/s
spectroscopy = struct();
spectroscopyNum = 0;
FD = cell(0,0);
dV = 0.2;

I = experiment.Topography;
mainRefPix = [115,152];
ROIPix = [115,190];
mainDeltaZ = (max(I(:)) - I(mainRefPix(1),mainRefPix(2)))*1e-6;
maxDeltaZ = range(I(:))*1e-6;
HRef = I(mainRefPix(1),mainRefPix(2))*1e-6;%convert from um to m
HROI = I(ROIPix(1),ROIPix(2))*1e-6;%convert from um to m
deltaH = HROI - HRef
%END of Intialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calibration at mainRefPix

result = input('expert mode');
result = input('custom segments');
input('sweeps 1');
%setZRelative(maxDeltaZ + 0.5e-6,openLoop);
%moveToPix(mainRefPixel);
%deflSens measurement
setZRelative(1e-6+maxDeltaZ,closedLoop);
moveToPix(mainRefPix);
VFree = getDefl(closedLoop);
SetServoSetpoint(VFree + dV);
SetServoActive(servoOn);
pause(2)
%deflSens = getDeflSens(dV,closedLoop);%now servo is on with dV relative to CurVfree
tic;
setZRelative(500e-9,closedLoop);
%servo is off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%start experiment loop
safetyCheck('pixelLoop');
%calibration at RefPix
%VFree = getDefl(closedLoop);
dZ = dV/deflSens;
SetServoSetpoint(VFree + dV);
SetServoActive(servoOn);
pause(1)
SetSpectroscopyMaxLimit(0.6);
dRetract = 0.8e-6;
setZRelative(dRetract+dZ/2,closedLoop);
[dBending, VRef] = bendingCorrection(dRetract,deflSens)
setZRelative(dBending+deltaH+15e-9,closedLoop);
moveToPix(ROIPix);
VCorrection = 0;
dBend2 = 0;
for stepId=1:stepNum
    dZ = VCorrection/deflSens;
    spectroscopy.dRetract = dRetract +dZ;
    spectroscopy.dApproach = -spectroscopy.dRetract;
    spectroscopy.tRetract = spectroscopy.dRetract/vRetract;
    spectroscopy.tApproach = -spectroscopy.dApproach/vApproach;
    spectroscopy.tWait = 0.2;%0.5s
    spectroscopy.debugString = 'pulling above vesicle';
    spectroscopy.closedLoopStatus = closedLoop;
    spectroscopy = getSpectroscopySegment(spectroscopy);
    spectroscopyNum = spectroscopyNum + 1;
    FD{stepId,1} = spectroscopy;
    VFree = calSpectroscopyVFree(spectroscopy.approachData);
    dBend2 = calBending(spectroscopy.approachData,deflSens)
    spectroscopy.dBend2 = dBend2;
    if dBend2>4e-9
        setZRelative(80e-9,closedLoop);
    elseif dBend2<1e-9
        dBend2 = dBend2 - 5e-9;
    else
        dBend2 = dBend2 + 10e-9;
    end
    dRetract = dRetract - dBend2;
    VCorrection = VFree - VRef;
    figure
    hold on
    plot(FD{stepId,1}.approachData(1:end-3,2),FD{stepId,1}.approachData(1:end-3,3),'-r');
    plot(FD{stepId,1}.retractData(1:end-3,2),FD{stepId,1}.retractData(1:end-3,3),'-b');
    hold off
    %GetStatusRawDefl()
    %'VCrrection'
    %VCorrection
end%End of step loop
SetServoSetpoint(VFree + dV);
SetServoActive(servoOn);
toc