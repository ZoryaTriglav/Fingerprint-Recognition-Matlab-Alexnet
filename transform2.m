
function [ Tnew ] = transform2( T, alpha )
    Count=size(T,1);
    Tnew=zeros(Count,4);
    R=[cos(alpha) sin(alpha) 0 0;...
      -sin(alpha) cos(alpha) 0 0;...
      0 0 1 0; 0 0 0 1];             % 旋转变换矩阵
    for i=1:Count
        B=T(i,:)-[0 0 alpha 0]; %全部减去alpha
        Tnew(i,:)=R*B';
    end
end