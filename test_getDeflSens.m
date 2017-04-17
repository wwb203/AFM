%test getDefl
t1 = now;
addPicoSDKPath;
closedLoop = true;
openLoop = false;
dV = 0.2;
CLSens = getDeflSens(dV,closedLoop);
t2 = now;
1/CLSens
'time'
t2-t1