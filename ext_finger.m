
function [ ret ] = ext_finger( img, display_flag ) %img：输入的灰度图像 display_flag：控制是否显示中间图像 ret：输出特征值矩阵
    if nargin==1; display_flag=0; end  %如果只输入图像，则默认不显示
    if ndims(img) == 3; img = rgb2gray(img); end %若输入的是RGB图像，则转换为灰度图像
% 图像增强 -------------------------------------------------------------
    %调用图像增强函数，得到经过图像增强和特征提取后的二值化指纹图像(binim)、掩模(mask)和指纹方向图像(orient_img_m)
    [ binim, mask, orient_img_m ] = enhance2(img);
    if display_flag==1
        imshow(binim);title('增强后图像');
    end
% 掩膜修补 -------------------------------------------------------------
    if display_flag==1;end
    inv_binim = (binim == 0); %反转二值图像
    thinned =  bwmorph(inv_binim, 'thin',Inf); %对图像进行细化操作，循环迭代至无法细化，得到指纹骨架
    mask(size(img,1)/2-50:size(img,1)/2+50,size(img,2)/2-50:size(img,2)/2+50)=1; %对重要区域的掩膜进行补全，使其全部读取，避免丢失重要信息
    
% 寻找特征点 --------------------------------------------------------
    if display_flag==1;end
    minu_count = 1; %设计细节点计数器为1
    minutiae(minu_count, :) = [0,0,0,0];  %初始化矩阵
    min_path_index = []; %置空矩阵
    % 循环遍历图像，寻找特征点，忽略图像边缘的一些像素
     for y=20:size(img,1)-14
        for x=21:size(img,2)-21
            if (thinned(y, x) == 1) 
                % 对于每个白色的像素，计算一个称为“CN”的值，用于表示像素周围黑白变化的次数。
                CN = 0; sx=0; sy=0;
                for i = 1:8
                  t1 = p(thinned, x, y, i); 
                  t2 = p(thinned, x, y, i+1);
                  CN = CN + abs (t1-t2);
                end   
                CN = CN / 2;
                if ((CN == 1) || (CN == 3)) %CN=1代表骨架末端，CN=3代表骨架分叉点，很有可能是特征点，下面进行进一步确认
                   skip=0;
                   for i = y-5:y+5
                        for j = x-5:x+5
                          if i>0 && j>0 && mask(i,j) == 0  %在确定可能是细节特征的像素周围的 11x11 区域内，检查图像所对应的掩模是否有0，若有则跳过该像素（不是脊线区域）
                             skip=1;
                          end
                        end
                   end
                   if skip == 1
                      continue;
                   end
                   %根据特征点周围的像素点的方向值求取这些方向值的中位数，并将其作为该特征点的方向值 m_o
                   t_a=[];
                   c = 0;
                   for e=y-1:y+1
                       for f=x-1:x+1
                           c = c + 1;
                           t_a(c) = orient_img_m(e,f);
                       end
                   end 
                   m_o = median(t_a);
                   %进一步判断分叉点方向
                   if CN == 3
                      [CN, prog, sx, sy,ang]=test_bifurcation(thinned, x,y);
                      if prog < 3 %如果追寻进度小于3，即遇到了不规则的脊线，则跳过这个像素点
                         continue
                      end
                      if ang < pi 
                         m_o = mod(m_o+pi,2*pi); %将分叉点的方向全部调整为向（左、右）上
                      end
                   else
                      %进一步判断结束点
                      progress=0;
                      xx=x; yy=y; pao=-1; pos=0;
                      while progress < 15 && xx > 1 && yy > 1 && yy<size(img,1) && xx<size(img,2) && pos > -1
                            pos=-1;
                            for g = 1:8
                                [ta, xa, ya] = p(thinned, xx, yy, g);
                                [tb, xb, yb] = p(thinned, xx, yy, g+1);
                                if (ta > tb)  && pos==-1 && g ~= pao
                                   pos=ta; 
                                   if g < 5
                                      pao = 4 + g;
                                   else
                                      pao = mod(4 + g, 9) + 1;
                                   end
                                   xx=xa; yy=ya;
                                end 
                            end
                            progress=progress+1;
                      end
                      if progress < 10 %如果脊线长度不足，则跳过该像素
                         continue
                      end
                      if mod(atan2(y-yy,xx-x), 2*pi) > pi
                         m_o=m_o+pi; %将结束点的方向全部调整为向（左、右）下
                      end
                   end 
                   %存储特征点
                   minutiae(minu_count, :) = [ x, y, CN, m_o ];
                   min_path_index(minu_count, :) = [sx sy];
                   minu_count = minu_count + 1;
                end
            end 
        end 
    end 

% 过滤错误特征点 ------------------------------------------------
    if display_flag==1;end
    minu_count = minu_count -1;
    t_minutiae = [];
    t_minu_count = 1;
    t_mpi = [];
    %如果特征点周围5*5的区域所对应的掩模区域有像素等于0，过滤掉这个特征点（非重要区域）
    for i=1:minu_count
        X = minutiae(i,1); Y = minutiae(i,2);
        rc=0; 
        for y=max(Y-2,1):min(Y+2, size(binim,1)) 
            if rc > 0
               break
            end
            for x=max(X-2,1):min(X+2, size(binim,2))  
                if mask(y,x) == 0
                   rc = rc + 1;   
                   break
                end
            end
        end
        if rc > 0 
             continue;
        else
            t_minutiae(t_minu_count, :) = minutiae(i, :);
            t_mpi(t_minu_count, :) = min_path_index(i, :);
            t_minu_count = t_minu_count + 1;
        end
    end
    minutiae = t_minutiae;
    min_path_index = t_mpi;
   %通过计算指纹细节点之间的距离来筛选出符合条件的节点，然后通过路径追踪算法确定节点的位置
    minu_count = size(minutiae,1);
    t_minu_count = 1; t_minutiae = [];
    %计算所有指纹细节点之间的欧几里得距离，保存在dist_m中。
    dist_m = dist2(minutiae(:,1:2), minutiae(:,1:2));
    dist_test=49; %判断距离设置为49
    %对于每个指纹细节点i，遍历所有其他节点j，如果节点i和j之间的距离小于等于dist_test，则将reject_flag设为1。
    path_len = 45;
    for i=1:minu_count
      reject_flag = 0;
      P_x = minutiae(i,1); P_y = minutiae(i,2);
      for j = i + 1 : minu_count
        if dist_m(i,j) <= dist_test
           reject_flag = 1;
        end
      end
      %对于没有找到小于dist_test距离的点，将进一步提取特征点
      if reject_flag == 0 && mask(P_y, P_x) > 0
         reverse_p = 0;  
         %检查当前特征点（P_x，P_y）是否有沿路径的前一个点
         % （min_path_index（i，1），min_path_index（i，2））。
         % 如果有，则算法从该点开始，否则从当前点开始。
         if min_path_index(i,1) == 0
           x = P_x;
           y = P_y; 
         else
           x =  min_path_index(i,1);
           y =  min_path_index(i,2); 
         end
         p1x=P_x; p1y=P_y;
         x1=x; y1=y;
         iter = 0;
         for m=1:path_len
               iter = iter + 1;
               cn = 0;
               for ii = 1:8
                   t1 = p(thinned, x1, y1, ii);
                   t2 = p(thinned, x1, y1, ii+1);
                   cn = cn + abs (t1-t2);
               end
               cn = cn / 2;
               if cn ~= 3 && cn ~= 4 || m == 1
                  for n=1:8
                      if reverse_p == 0 || iter > 1 
                         [ta, xa, ya] = p(thinned, x1, y1, n);
                      else
                         [ta, xa, ya] = p(thinned, x1, y1, 9-n);    
                      end
                      if ta == 1 && (xa ~= p1x || ya ~= p1y) && (xa ~= x || ya ~= y)
                         p1x = x1; p1y = y1;
                         x1 = xa; y1 = ya;
                         break;
                      end
                  end
               end
         end
         %存储特征点
         t_minutiae(t_minu_count, :) = minutiae(i, :);
         t_minu_count = t_minu_count + 1;
      end
    end
    minutiae = t_minutiae;
    minu_count = t_minu_count-1;
% 绘制图像 ---------------------------------------------------------
    if display_flag == 1
        minutiae_img = uint8(zeros(size(img, 1),size(img, 2), 3));
        for i=1:minu_count 
        x1 = minutiae(i, 1); y1 = minutiae(i, 2);
        if minutiae(i, 3) == 1
           if minutiae(i, 4) > pi
            for k = y1-2: y1 + 2
              for l = x1-2: x1 + 2
                minutiae_img(k, l,:) = [255, 0, 0]; %打出方向向上的结束点
              end
            end
           else
            for k = y1-2: y1 + 2
             for l = x1-2: x1 + 2
                minutiae_img(k, l,:) = [0, 255, 0]; %打出方向向下的结束点
              end
            end
           end
        elseif minutiae(i, 3) == 3
          if minutiae(i, 4) > pi
            for k = y1-2: y1 + 2
              for l = x1-2: x1 + 2
                minutiae_img(k, l,:) = [0, 0, 255]; %打出开口向下的分叉点
              end
            end
          else 
            for k = y1-2: y1 + 2
              for l = x1-2: x1 + 2
                minutiae_img(k, l,:) = [255, 0, 255]; %打出开口向上的分叉点
              end
            end
          end
        end   
        end
        combined = uint8(minutiae_img);    
        for x=1:size(binim,2)
        for y=1:size(binim,1)
            if mask(y,x) == 0
                combined(y,x,:) = [0,0,0];
                continue
            end
            if (binim(y,x))
                combined(y,x,:) = [255,255,255];
            else
                combined(y,x,:) = [0,0,0];
            end
            if ((minutiae_img(y,x,3) ~= 0) || (minutiae_img(y,x,1) ~= 0) ) || (minutiae_img(y,x,2) ~= 0)
                combined(y,x,:) = minutiae_img(y,x,:);
            end
        end
        end
        if display_flag==1
            imshow(combined);title('特征点标记图像');
        end
    end
    ret=minutiae;
end 