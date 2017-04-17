function [deflSens,VFree] = getDeflSens(dV,closedLoopStatus)
%use getSpectroscopySegment to measure deflSens V/m
%assume servo on
%input dV for setpoint, closedLoop = true
%output deflSens
%return with servo on
%piezo safety: inside getSpectroscopySegment
%8:40PM 7/9/14, test on 7/10
openLoop = false;
closedLoop = true;
servoOn = true;
%thermal drifting correction

setZRelative(0.8e-6, closedLoop);
%VFree = getDefl(openLoop);
VFree = GetStatusRawDefl();
SetServoSetpoint(VFree + dV);
SetServoActive(true);

SetSpectroscopyMaxLimit(0.4);
SetSpectroscopyMaxLimitRelative(true);

spectroscopy = struct();
setZRelative(0.8e-6,closedLoop);

spectroscopy.dApproach = -1e-6;
spectroscopy.tApproach = 1;
spectroscopy.dRetract = 1e-6;
spectroscopy.tRetract = 1;
spectroscopy.tWait = 0;
spectroscopy.closedLoopStatus = closedLoopStatus;
spectroscopy.debugString = 'getDeflSens';
spectroscopy = getSpectroscopySegment(spectroscopy);
deflSens = calDeflSens(spectroscopy.approachData);
VFree = calSpectroscopyVFree(spectroscopy.approachData);
VFreeRaw = GetStatusRawDefl();
if abs(VFree-VFreeRaw)>1
    VFree
    VFreeRaw
    error('error in VFree')
end
SetServoSetpoint(VFree + dV);
SetServoActive(true);
pause(0.2);
end
