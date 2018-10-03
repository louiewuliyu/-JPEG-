clc
clear all;
close all;

covername = input('Enter image file or path: ', 's');
messagename = input('Enter message file or path: ', 's');
%messagename = 'sysu';
cover = imread(covername);
sz = size(cover);
rows = sz(1,1);
cols = sz(1,2);
colors = max(max(cover));

fd = fopen(messagename, 'r');
message = fgetl(fd);
messagelength = length(message);

% figure(1), imshow(cover); title('Original Image');
 disp(message);
% 
% %cover = double(cover);
% %message = double(message);
 message = uint8(message);
% 
% coverzero = cover;
% %disp(coverzero);
% 
% quant_multiple = 1;
% blocksize = 8;
% DCT_quantizer = ...
%     [16 11 10 16 24 40 51 61; ...
%      12 12 14 19 26 58 60 55; ...
%      14 13 16 24 40 57 69 52; ...
%      14 17 22 29 51 87 80 62; ...
%      18 22 37 56 68 109 103 77; ...
%      24 35 55 64 81 104 113 92; ...
%      49 64 78 87 103 121 120 101; ...
%      72 92 95 98 112 100 103 99];
%  
% figure(2); imshow(coverzero); title('original image');
% 
% pad_cols = (1 - (cols/blocksize - floor(cols/blocksize))) * blocksize;
% if pad_cols == blocksize, pad_cols = 0; end
% 
% pad_rows = (1 - (cols/blocksize - floor(rows/blocksize))) * blocksize;
% if pad_rows == blocksize, pad_rows = 0; end
% 
% for extra_cols = 1:pad_cols
%     coverzero(1:rows, cols+extra_cols) = coverzero(1:rows, cols);
% end
% cols = cols + pad_cols; %coverzero is now pad_cols wider
% 
% for extra_rows = 1:pad_cols
%     coverzero(row+extra_rows, 1:cols) = coverzero(rows, 1:cols);
% end
% rows = rows + pad_rows;%coverzero is now pad_rows taller
% 
% for row = 1:blocksize:rows
%     for col = 1:blocksize:cols
%         DCT_matrix = coverzero(row:row+blocksize-1, col:col+blocksize-1);
%         DCT_matrix = dct2(DCT_matrix);
%         DCT_matrix = round(DCT_matrix ...
%             ./ (DCT_quantizer(1:blocksize, 1:blocksize) * quant_multiple));
%         jpeg_img(row:row+blocksize-1, col:col+blocksize-1) = DCT_matrix;
%         
%     end
% end
% 
% figure(3); hist(jpeg_img);
% figure(4); imshow(jpeg_img);

bitlength = 1;
messagebit = zeros(messagelength*8);
for i = 1:messagelength
    for imbed = 1:8
        messageshift = bitshift(message(i), 8-imbed);
        showmess = uint8(messageshift);
        showmess = bitshift(showmess, -7);
        
        messagebit(bitlength) = showmess;
        bitlength = bitlength + 1;
    end     
end

origin = imread('test/0.jpg');
temp = origin;
host_sz = size(temp);
host_rows = host_sz(1,1);
host_cols = host_sz(1,2);

%embedding
i = 1;
for row = 1:host_rows
    for col = 1:host_cols
        x = temp(row, col);
        if (x~=0) && (x~=1);
            r = mod(x, 2);
            if r == 0
                if messagebit(i) == 1
                    x = x+1;
                end
            else
                if messagebit(i) == 0
                    x = x-1;
                end
            end
            i = i+1;
        end
        temp(row, col) = x;
        
        if i == bitlength
            break;
        end
    end
    if i == bitlength
        break;
    end
end
    
    figure(5); imshow(temp);
    
%recover
stegoindex = 1;
imbed = 1;
messagechar = 0;
messageindex = 1;
for row = 1:host_rows
    for col = 1:host_cols
        stegomessage = temp(row, col);
        if (stegomessage~=0) && (stegomessage~=1)
            r = mod(stegomessage,2);
            if (r == 0)
                showmess = 0;
            else
                showmess = 1;
            end
            
            showmess = uint8(showmess);
            showmess = bitshift(showmess, (imbed - 1));
            messagechar = uint8(messagechar + showmess);
            
            stegoindex = stegoindex + 1;
            imbed = imbed + 1;
            if (imbed == 9)
                messagestring(messageindex) = char(messagechar);
                messageindex = messageindex + 1;
                messagechar = 0;
                imbed = 1;
            end
        end
        if (stegoindex == messagelength*8)
            break;
        end
    end
    if (stegoindex == messagelength*8)
        break;
    end
end

%disp(messagestring);
fid=fopen('recover2.txt','wt');
fprintf(fid,'%s\n',messagestring);
fclose(fid);
%hist(origin);
% 计算峰值信噪比(psnr)
psnr=psnr(origin, temp);
disp('psnr');
disp(psnr);
subplot(2,2,1),imshow('test/0.jpg');title('original graph');
subplot(2,2,2),imhist(origin);title('original graphic histogram');

subplot(2,2,3),imshow(temp);title('graph of data hiding');
subplot(2,2,4),imhist(temp);title('graph of data hiding histogram');
    



 
