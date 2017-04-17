function [approachData,retractData] = getSpectroscopyData(closedLoopStatus)
%execute sweep
%input closedLoopStatus, read Z sensor if true
%output approachData,retractData n*3(4) TXV(Z)
%piezo safety : none, rely on calling function
%9:03PM 7/9/13, test on 7/10
%assuming no data points in tWait
SpectroscopySweepStart();
WaitForStatusSpectroscopySweeping(true);
WaitForStatusSpectroscopySweeping(false);
T = ReadPlotSpectroscopyTime();
X = ReadPlotSpectroscopySweep();
V = ReadPlotSpectroscopyMain();
if closedLoopStatus
    Z = ReadPlotSpectroscopyAux0();
end
%clean up data
XMaxId = find(abs(diff(X))>1e-6,1,'first');
% 'XMaxId'
% XMaxId
if isempty(XMaxId)
    XMaxId=length(T);
end
T = T(1:XMaxId);
X = X(1:XMaxId);
V = V(1:XMaxId);
if closedLoopStatus
    Z = Z(1:XMaxId);
end
%Separate Appr and Retr Data
XMinId = find(X==min(X),1,'first');
N = length(T);
if closedLoopStatus
    approachData = zeros(XMinId,4);
    retractData = zeros(N-XMinId,4);
else
    approachData = zeros(XMinId,3);
    retractData = zeros(N-XMinId,3);
end
approachData(:,1) = T(1:XMinId);
retractData(:,1) = T(XMinId+1:end);
approachData(:,2) = X(1:XMinId);
retractData(:,2) = X(XMinId+1:end);
approachData(:,3) = V(1:XMinId);
retractData(:,3) = V(XMinId+1:end);
if closedLoopStatus
    approachData(:,4) = Z(1:XMinId);
    retractData(:,4) = Z(XMinId+1:end);
end
