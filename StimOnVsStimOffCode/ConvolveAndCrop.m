function CroppedConvolution = ConvolveAndCrop(A,B)

% Matrix B is the Finite Impulse Response and matrix A is the surface to be
% convolved.

[ma, na] = size(A);
[mb, nb] = size(B);

xDim = [floor((ma+mb-1)/2)-floor(ma/2), floor((ma+mb-1)/2)+floor(ma/2)];
yDim = [floor((na+nb-1)/2)-floor(na/2), floor((na+nb-1)/2)+floor(na/2)];

C = conv2(A,B);

CroppedConvolution = C(xDim(1):xDim(2),yDim(1):yDim(2));

end