
function [ binim, mask, oimg2 ] = f_enhance( img )
    enhimg =  fft_enhance_cubs(img,12);             
    enhimg =  fft_enhance_cubs(enhimg,24);     
    blksze = 5;   thresh = 0.085;              
    [normim, mask] = ridgesegment(enhimg, blksze, thresh);
    oimg2 = ridgeorient(normim, 1, 3, 3); 
    [freq, medfreq] = ridgefreq(normim, mask, oimg2, 32, 5, 5, 15);
    binim = ridgefilter(normim, oimg2, medfreq.*mask, 0.5, 0.5, 1) > 0;
end