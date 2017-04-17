%test getDefl
addPicoSDKPath;
closedLoop = true;
openLoop = false;
dV = 0.2;
OLSens1 = getDeflSens(dV,openLoop);
CLSens = getDeflSens(dV,closedLoop);
OLSens2 = getDeflSens(dV,openLoop);
[OLSens1,CLSens,OLSens2]