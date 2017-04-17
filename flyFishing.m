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
stepNum = 5;
stepSize = 0e-9;
vApproach = 0.7e-6;%1 um/s
vRetract = 0.7e-6;%1 um/s
spectroscopy = struct();
spectroscopyNum = 0;
FD = cell(0,0);
dV = 0.1;

%END of Intialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calibration at mainRefPix

result = input('expert mode');
result = input('custom segments');
input('sweeps 1');
%setZRelative(maxDeltaZ + 0.5e-6,openLoop);
%moveToPix(mainRefPixel);
%deflSens measurement
setZRelative(0.8e-6,closedLoop);
%moveToPix(mainRefPix);
VFree = getDefl(closedLoop);
SetServoSetpoint(VFree + dV);
SetServoActive(servoOn);
pause(2)
%deflSens = getDeflSens(dV,closedLoop);%now servo is on with dV relative to CurVfree
tic;
%setZRelative(500e-9,closedLoop);
%servo is off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%start experiment loop
safetyCheck('pixelLoop');
%calibration at RefPix
%VFree = getDefl(closedLoop);

%SetServoSetpoint(VFree + dV);
%SetServoActive(servoOn);
%pause(1)
SetSpectroscopyMaxLimit(0.1);
dRetract = 1e-6;
setZRelative(dRetract+50e-9,closedLoop);
VRef = getDefl(closedLoop);
%[dBending, VRef] = bendingCorrection(dRetract,deflSens)
%setZRelative(dBending+15e-9,closedLoop);
 dBend2 = 0;
dZ = 0;
for stepId=1:stepNum

    spectroscopy.dRetract = dRetract;
    spectroscopy.dApproach = -spectroscopy.dRetract;
    spectroscopy.tRetract = spectroscopy.dRetract/vRetract;
    spectroscopy.tApproach = -spectroscopy.dApproach/vApproach;
    spectroscopy.tWait = 1;%second
    spectroscopy.debugString = 'pulling above vesicle';
    spectroscopy.closedLoopStatus = closedLoop;
    spectroscopy = getSpectroscopySegment(spectroscopy);
    spectroscopyNum = spectroscopyNum + 1;
    FD{stepId,1} = spectroscopy;
    VFree = calSpectroscopyVFree(spectroscopy.approachData);
    dBend2 = calBending(spectroscopy.approachData,deflSens);
    spectroscopy.dBend2 = dBend2;
    if dBend2>4e-9
        setZRelative(30e-9,closedLoop);
    elseif dBend2<1e-9
        dBend2 = dBend2 - 3e-9;
    else
        dBend2 = dBend2 + 5e-9;
    end
    dRetract = dRetract - dBend2;
    figure
    hold on
    plot(FD{stepId,1}.approachData(1:end-10,2),FD{stepId,1}.approachData(1:end-10,3),'-r');
    plot(FD{stepId,1}.retractData(1:end-10,2),FD{stepId,1}.retractData(1:end-10,3),'-b');
    hold off
    %GetStatusRawDefl()
    %'VCrrection'
    %VCorrection
end%End of step loop
SetServoSetpoint(VFree + dV);
SetServoActive(servoOn);
toc