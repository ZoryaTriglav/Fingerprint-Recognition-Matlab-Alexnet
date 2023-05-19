
function [j,X, Y] = p(img, x, y, i)
%  4 | 3 | 2
%  5 |   | 1
%  6 | 7 | 8

switch (i)
    case {1, 9}
        Y=y;
        X=x+1;
        j = img(y, x + 1); %获取当前像素右方的像素值
    case 2
        Y=y-1;
        X=x+1;
        j = img(y - 1, x + 1);%获取当前像素右上方的像素值
    case 3
        Y=y-1;
        X=x;
        j = img(y - 1, x);%获取当前像素上方的像素值
    case 4
        Y=y-1;
        X=x-1;
        j = img(y - 1, x - 1);%获取当前像素左上方的像素值
    case 5
        Y=y;
        X=x-1;
        j = img(y, x - 1);%获取当前像素左方的像素值
    case 6
        Y=y+1;
        X=x-1; 
        j = img(y + 1, x - 1);%获取当前像素左下方的像素值
    case 7
        Y=y+1;
        X=x;
        j = img(y + 1, x);%获取当前像素下方的像素值
    case 8
        Y=y+1;
        X=x+1; 
        j = img(y + 1, x + 1);%获取当前像素右下方的像素值
end

