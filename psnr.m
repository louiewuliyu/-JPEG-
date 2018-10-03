function PSNR = psnr(ImageA,ImageB)
if (size(ImageA) ~= size(ImageB)) or (size(ImageA,2) ~= size(ImageB,2))  
    error('size error');  
    PSNR = 0;  
   return ;
end
ImageA=double(ImageA);
ImageB=double(ImageB);
M = size(ImageA,1);
N = size(ImageA,2);

sum1=M*N*max(max(ImageA.^2));

sum2 = 0 ;
for i = 1:M  
    for j = 1:N    
        sum2 = sum2 + (ImageA(i,j) - ImageB(i,j)).^2 ; 
    end
end
PSNR = 10*log10(sum1/sum2) ;
return