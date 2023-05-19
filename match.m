
function [ S ] = match( M1, M2, display_flag )
    if nargin==2; display_flag=0; end
    count1=size(M1,1); count2=size(M2,1); 
    bi=0; bj=0; ba=0; % 匹配度最佳的点
    S=0;            % 最高的相似度
    for i=1:count1
        T1=transform(M1,i);
        for j=1:count2
            if M1(i,3)==M2(j,3)
                T2=transform(M2,j);
                for a=-5:5                      %旋转角度
                    T3=transform2(T2,a*pi/180);
                    sm=score(T1,T3);
                    if S<sm
                        S=sm;
                        bi=i; bj=j; ba=a;
                    end                
                end
            end
        end
    end
    %作图
    if display_flag==1
        figure, title(['特征比较： ' num2str(S)]);
        T1=transform(M1,bi);
        T2=transform(M2,bj);
        T3=transform2(T2,ba*pi/180);
        plot_data(T1,1);
        plot_data(T3,2);
    end
end