function VFree = calSpectroscopyVFree(approachData)
%\
% \
%  \
%   \
%     ----------------
%slope            plateu
%test on 7/10/14
X = approachData(:,2);
Y = approachData(:,3);
plateuY = Y(X>(min(X) + 0.7*range(X)));
VFree =  mean(plateuY(:));
end

