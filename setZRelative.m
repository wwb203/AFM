function setZRelative(ZRel,closedLoopStatus)
%use expert spectroscopy mode to set relative Z
%input: ZRel(+up,-down);closedLoop true=closed false=open
%output: 1. withdraw piezo because curZ is unsafe
%        2. error, setZ is unsafe
%        3. sucessfully set Z relative
%piezo safety: check Z_current and Z_set
%12:55PM 7/11/14,test on 7/14/14
segmentAbsolute =		0;
segmentRelative =		1;
segmentEnd =			2;
triggerNone =			false;
triggerActionNone =     false;
servoOn =               true;
servoOff =              false;
minLimitActive =        true;
minLimitInactive =      false;
maxLimitActive =        true;
maxLimitInactive =      false;
relativeLimitBaselineOn = true;
relativeLimitBaselineOff = false;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%safetycheck
curZ = GetServoZDirect();
if abs(curZ)>6.5e-6
    SetMotorWithdrawDistance(30e-6);
    MotorWithdraw();
    error('curZ,withdraw')
end
setZ = curZ + ZRel;
if abs(setZ)>6.5e-6
    error('setZ Position out of piezo Range')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Duration = ZRel/3e-6;%speed = 3um/s
    %initialize segments
    SpectroscopySegmentClearAll()
    %open/closed loop sweep
    SetSpectroscopyClosedLoopSweeps(closedLoopStatus)
    SetSpectroscopySegment(0,1,ZRel,Duration,0,0,0,false,false,false,false);
    %SetSpectroscopySegment(0,segmentRelative,ZRel,Duration,...
    %    0, triggerNone, triggerActionNone, servoOff,...
    %    minLimitInactive,maxLimitInactive,relativeLimitBaselineOff);
    SpectroscopySweepStart();
    WaitForStatusSpectroscopySweeping(true);
    WaitForStatusSpectroscopySweeping(false);
    SpectroscopySegmentClearAll()
    SetSpectroscopyClosedLoopSweeps(false)
end