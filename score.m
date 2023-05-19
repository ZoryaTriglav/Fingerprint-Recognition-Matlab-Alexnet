
function [ sm ] = score( T1, T2 )
    Count1=size(T1,1); Count2=size(T2,1); n=0;
    T=15;  %设置距离阈值
    TT=14; %设置角度阈值
    for i=1:Count1
        Found=0; j=1;
        while (Found==0) && (j<=Count2)
            dx=(T1(i,1)-T2(j,1));
            dy=(T1(i,2)-T2(j,2));
            d=sqrt(dx^2+dy^2);    %判断两点距离是否小于阈值
            if d<T
                DTheta=abs(T1(i,3)-T2(j,3))*180/pi; %判断角度是否小于阈值
                DTheta=min(DTheta,360-DTheta);
                if DTheta<TT
                    n=n+1;        %分数+1
                    Found=1;
                end
            end
            j=j+1;
        end
    end
    sm=sqrt(n^2/(Count1*Count2));       %计算相似性指数
end