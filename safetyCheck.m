function safetyCheck(textstring)
%SafetyCheck
rawDefl = GetStatusRawDefl();
curZ = GetServoZDirect();
laserSum = GetStatusSum;
if abs(rawDefl)>3||abs(curZ)>6e-6||laserSum<1
    textstring
    'rawDefl'
    rawDefl
    'CurrentZ'
    curZ
    'laserSum'
    laserSum
    SetMotorWithdrawDistance(50e-6);
    MotorWithdraw();
    error('safety check failed')
end