function [xMat, yMat] = BuildInputMatrices(xLimits, yLimits, xInc, yInc)

xVec = xLimits(1):xInc:xLimits(2);
xVec = xVec(:);
yVec = yLimits(1):yInc:yLimits(2);

NumOfYRows = length(xVec)
NumOfXColumns = length(yVec)

xMat = NaN*ones([NumOfYRows, NumOfXColumns]);
yMat = NaN*ones([NumOfYRows, NumOfXColumns]);

for i = 1:NumOfYRows
    yMat(i,:) = yVec;
end

for i = 1:NumOfXColumns
    xMat(:,i) = xVec;
end

%OutputStruct.xMat = xMat;
%OutputStruct.yMat = yMat;

end