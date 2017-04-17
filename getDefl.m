function VDefl = getDefl(closedLoopStatus)
%use expert spectroscopy mode to measure time-averaged rawDefl
%input: true=closedLoop false=openLoop
%out : time-averaged rawDefl
%8:10PM 7/9/14,test on 7/10
segmentAbsolute =		0;
segmentRelative =		1;
segmentEnd =			2;
triggerNone =			0;
triggerActionNone =     0;
servoOn =               1;
servoOff =              0;
minLimitActive =        true;
minLimitInactive =      false;
maxLimitActive =        true;
maxLimitInactive =      false;
relativeLimitBaselineOn = true;
relativeLimitBaselineOff = false;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curZ = GetServoZDirect();
if abs(curZ)>6.5e-6
    SetMotorWithdrawDistance(30e-6);
    MotorWithdraw();
    error('Z Position out of piezo Range')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Duration = 0.3;
nData = 30;
%initialize segments
SpectroscopySegmentClearAll()
%closed/open loop sweep
SetSpectroscopyClosedLoopSweeps(closedLoopStatus)
%Piezo hold still
SetSpectroscopySegment(0,1,0,Duration,nData,0,0,false,false,false,false);
%SetSpectroscopySegment(0,segmentRelative,0,Duration,...
%    nData, triggerNone, triggerActionNone, servoOff,...
%    minLimitInactive,maxLimitInactive,relativeLimitBaselineOff);
%exe sweep
SpectroscopySweepStart();
WaitForStatusSpectroscopySweeping(true);
WaitForStatusSpectroscopySweeping(false);
V = ReadPlotSpectroscopyMain();
SpectroscopySegmentClearAll()
VDefl = mean(V(1:nData));
end
