%test setZRelative
addPicoSDKPath;
closedLoop = true;
openLoop = false;
height1 = GetServoZDirect();
setZRelative(0.5e-6,openLoop);
height2 = GetServoZDirect();
height1 - height2