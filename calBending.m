function dBending = calBending(approachData,deflSens)
%Force Distance Curve
%V
% \
%  \
%   \
%    \
%      ----------------m
%slope         plateu
%9:57am 7/11/14, test on 7/10
Y = approachData(:,3);%V
X = approachData(:,2);%m

plateuY = Y(X>(min(X)+0.5*range(X)));
plateuX = X(X>(min(X)+0.5*range(X)));
length(plateuX)
p = polyfit(plateuX,plateuY,1);
Y = Y - (p(1).*X + p(2));


maxYId = find(Y==max(Y),'1','last');
if maxYId>floor(0.7*length(X))
Y = Y(1:maxYId);
X = X(1:maxYId);
end
slopeY = Y(Y>1.3*range(plateuY));
slopeX = X(Y>1.3*range(plateuY));
if length(slopeX)<3
    dBending = max(Y)/deflSens;
    return
end
p = polyfit(slopeX,slopeY,1);
quality = abs(p(1)-deflSens)/deflSens;
if quality<2
    dBending = -p(2)/p(1)-min(X);
else
    dBending = max(Y)/deflSens;
end
end

