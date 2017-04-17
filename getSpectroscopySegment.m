function spectroscopy = getSpectroscopySegment(spectroscopy)
%void SetSpectroscopySegment(int segment,int type,double
%position,double duration,long dataPoints, int trigger,
%int triggerAction, bool servoOn, bool minLimitActive, 
%bool maxLimitActive, bool relativeLimitBaseline)
%test on 7/10
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

%unpack input
dApproach = spectroscopy.dApproach;
tApproach = spectroscopy.tApproach;
nApproach = abs(floor(dApproach/2e-9));
tWait = spectroscopy.tWait;
dRetract = spectroscopy.dRetract;   
tRetract = spectroscopy.tRetract;
nRetract = floor(dRetract/1e-9);
debugString = spectroscopy.debugString;
closedLoopStatus = spectroscopy.closedLoopStatus;
%Piezo Safety Check
rawDefl = GetStatusRawDefl();
ZpiezoAbs = GetServoZDirect();
ZpiezoAppAbs = ZpiezoAbs + dApproach;
ZpiezoRtrAbs = ZpiezoAppAbs + dRetract;
minZ = min([ZpiezoAbs, ZpiezoAppAbs, ZpiezoRtrAbs]);
maxZ = max([ZpiezoAbs, ZpiezoAppAbs, ZpiezoRtrAbs]);
%'here1'
if minZ<-6.5e-6||maxZ>6.5e-6||abs(rawDefl)>3
    debugString
    'minZ'
    minZ
    'maxZ'
    maxZ
    'rawDefl'
    rawDefl
    error('segment parameter out of piezo range')
end

if dApproach>0
    error('dApproach should be a negative number')
end
if dRetract<0
    error('dRetract should be a positive number')
end
%initialize segments
SpectroscopySegmentClearAll();
%closed/open loop sweep
SetSpectroscopyClosedLoopSweeps(closedLoopStatus);
%Approach Segment
SetSpectroscopySegment(0,1,dApproach,tApproach,nApproach,0,0,false,false,true,false);
%SetSpectroscopySegment(0,segmentRelative,dApproach,tApproach,...
%    nApproach, triggerNone, triggerActionNone, servoOff,...
%    minLimitInactive,maxLimitActive,relativeLimitBaselineOff);
%Wait Segment
SetSpectroscopySegment(1,1,0,tWait,0,0,0,false,false,false,false);
%SetSpectroscopySegment(1,segmentRelative,0,tWait,...
%    0, triggerNone, triggerActionNone, servoOff,...
%    minLimitInactive,maxLimitInactive,relativeLimitBaselineOff);
%Retract Segment
SetSpectroscopySegment(2,1,dRetract,tRetract,nRetract,0,0,false,false,true,false);
% SetSpectroscopySegment(2,segmentRelative,dReract,tRetract,...
%     nRetract, triggerNone, triggerActionNone, servoOff,...
%     minLimitInactive,maxLimitActive,relativeLimitBaselineOff);
%exe sweep
%debugString
%input('check segment parameters');
[approachData,retractData] = getSpectroscopyData(closedLoopStatus);
%output
spectroscopy.approachData = approachData;
spectroscopy.retractData = retractData;
spectroscopy.time = clock;
end
