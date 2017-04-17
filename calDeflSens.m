function deflSens = calDeflSens(approachData)
%Force Distance Curve
%V
% \
%  \
%   \
%    \
%      ----------------m
%slope         plateu
%9:57am 7/11/14, test on 7/10
Y = approachData(:,3);
X = approachData(:,2);
plateuY = Y(X>(min(X)+0.7*range(X)));
Y = Y - mean(plateuY(:));
slopeY = Y(Y>0.3*range(Y));
slopeX = X(Y>0.3*range(Y));
p = polyfit(slopeX,slopeY,1);
deflSens = abs(p(1));%V/m
figure
hold on
plot(X,Y,'b-');
plot(slopeX,p(1).*slopeX+p(2),'r-');
title('DeflSens')
hold off
end

