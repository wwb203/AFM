%script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Intialization
%demanding Data,mainRefPix,spring
%constant,vesicle
%expecting experiment.FD, currentVesicleId
addPicoSDKPath;
closedLoop = true;
openLoop = false;
servoOn = true;
servoOff = false;
stepNum = 10;
stepSize = 5e-9;
loopNum = 1;
vApproach = 1e-6;%1 um/s
vRetract = 1e-6;%1 um/s
spectroscopy = struct();
load('experiment.mat');
if isfield(experiment,'FD')%a continued experiment
    vesicleId = experiment.vesicleId;
else
    experiment.FD = cell(0,0);
    experiment.vesicleId = 1;
    vesicleId = 1;
end
spectroscopyNum = size(experiment.FD,1);
vesicleList = experiment.vesicleList;
vesicleNum = length(vesicleList);
mainRefPixel = experiment.mainRefPixel;
I = experiment.Topography;
mainDeltaZ = (max(I(:)) - I(mainRefPix(1),mainRefPix(2)))*1e-6;
maxDeltaZ = range(I(:))*1e-6;
dV = 0.2;
%END of Intialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calibration at mainRefPix
result = input('Adjust Setpoint');
result = input('Approach Tip');
result = input('Adjust Motor');
setZRelative(maxDeltaZ + 0.5e-6,openLoop);
moveToPix(mainRefPixel);
%deflSens measurement
VFree = getDefl(closedLoop);
SetServoSetpoint(VFree + dV);
SetServoActive(servoOn);
pause(0.2)
deflSens = getDeflSens(dV,closedLoop);%now servo is on with dV relative to CurVfree
setZRelative(mainDeltaZ + 1e-6,openLoop);
%servo is off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%start experiment loop
for loopId = 1:loopNum%mainLoop
    for i = 1:vesicleNum%vesicleLoop
        Cvesicle = experiment.vesicle(vesicleId);
        refPix = Cvesicle.refPix;
        for ROIPixId = 1:size(Cvesicle.PixList,1)%Pixel on one vesicle
            ROIPix = Cvesicle.PixList(ROIPixId,:);
            HRef = I(refPix(1),refPix(2))*1e-6;%convert from um to m
            HROI = I(ROIPix(1),ROIPix(2))*1e-6;%convert from um to m
            deltaH = HROI - HRef;
            safetyCheck('pixelLoop');
            %calibration at RefPix
            moveToPix(refPix);
            VFree = getDefl(closedLoop);
            dZ = dV/deflSens;
            SetServoSetpoint(VFree + dV);
            SetServoActive(servoOn);
            pause(0.3)
            dRetract = 1.5e-6 + 20e-9 + stepNum*stepSize + ...
                        deltaH + dZ;
            setZRelative(dRetract,closedLoop);
            moveToPix(ROIPix);
            VRef = getDefl(closedLoop);
            VCorrection = 0;
            for stepId=1:stepNum
                dZ = VCorrection/deflSens;
                spectroscopy.dRetract = 1.5e-6 + stepId*stepSize + dZ;
                spectroscopy.dApproach = -spectroscopy.dRetract;
                spectroscopy.tRetract = spectroscopy.dRetract/vRetract;
                spectroscopy.tApproach = -spectroscopy.dApproach/vApproach;
                spectroscopy.tWait = 0.5;%0.5s
                spectroscopy.debugString = 'pulling above vesicle';
                spectroscopy.closedLoopStatus = closedLoop;
                spectroscopy.ROIPixId = ROIPixId;
                spectroscopy = getSpectroscopySegment(spectroscopy);
                spectroscopyNum = spectroscopyNum + 1;
                experiment.FD{spectroscopyNum} = spectroscopy;
                VFree = calSpectroscopyVFree(spectroscopy.approachData);
                VCorrection = VFree - VRef;
            end%End of step loop
        end%End of pixel loop
        vesicleId = mod(vesicleId,vesicleNum) + 1;
        experiment.VesicleId = vesicleId;
    end%End of Vesicle loop
end%End of Mainloop
SetServoSetpoint(VFree + dV);
SetServoActive(servoOn);
%SetMotorWithdrawDistance(30e-6);
%MotorWithdraw();