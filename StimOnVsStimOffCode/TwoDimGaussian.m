function GaussianSurface = TwoDimGaussian(XInputMat,YInputMat,xStats,yStats)

InputVecSize = size(XInputMat);

if(size(XInputMat)~=size(YInputMat))

end

xMean = xStats(1);
yMean = yStats(1);

xStdDev = xStats(2);
yStdDev = yStats(2);

GaussianSurface = NaN*ones(InputVecSize);

%NormalizationConstant = (1/(2*pi))*(1/xStdDev)*(1/yStdDev);
NormalizationConstant = 1;
for i = 1:InputVecSize(1)
    for j = 1:InputVecSize(2)
   
    GaussianSurface(i,j) = NormalizationConstant*exp(...
        -((XInputMat(i,j) - xMean)/(sqrt(2)*xStdDev))^2 -...
        ((YInputMat(i,j) - yMean)/(sqrt(2)*yStdDev))^2);
        
    end
end