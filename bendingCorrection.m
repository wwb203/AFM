function [dBending, VFree] = bendingCorrection(dRetract,deflSens)
vApproach = 1e-6;%1 um/s
vRetract = 1e-6;%1 um/s
closedLoop = true;
openLoop = false;
spectroscopy.dRetract = dRetract;
spectroscopy.dApproach = -spectroscopy.dRetract;
spectroscopy.tRetract = spectroscopy.dRetract/vRetract;
spectroscopy.tApproach = -spectroscopy.dApproach/vApproach;
spectroscopy.tWait = 0;%0s
spectroscopy.debugString = 'bending correction';
spectroscopy.closedLoopStatus = closedLoop;
spectroscopy = getSpectroscopySegment(spectroscopy);
VFree = calSpectroscopyVFree(spectroscopy.approachData);
dBending = calBending(spectroscopy.approachData,deflSens);
end