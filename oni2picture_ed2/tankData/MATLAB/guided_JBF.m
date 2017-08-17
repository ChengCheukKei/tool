function [mask_gbf, weight_o, g_t]= guided_JBF(mask, I, is_ime, count_i, weight)
    I = double(I);
    [H, W]  =size(mask);  mask_gbf = zeros(H,W);
    win_width = 11;%�������׷���num
    win_height =11; num_win = win_height*win_height;
    half_w = (win_width-1)/2;
    sigma_c = 8;
    thres = 0.5;
    g_t = 0;%count the num of changing pixels in mask
    sigma_precompute = -2*sigma_c*sigma_c;
    r_start = half_w+1; % round((win_height + 1)/2);  
    r_end = round(H - half_w-1);
    c_start = half_w+1;     c_end = round(W - half_w-1);
    
    G1_mat = fspecial('gaussian', win_width, half_w);
    G1_vec = reshape(mat2gray(G1_mat), 1, num_win);  win_vec = -half_w:half_w;

    weight_o = zeros([H*W,num_win]);
    
    %%only for count weight_o
    if count_i == 0 %
        for r = r_start : r_end
            for c = c_start : c_end          
                vec_patch = reshape(I(r+win_vec, c+win_vec), 1, num_win);
                vec_i = ones(1, num_win)*I(r,c);
                mask_vec = reshape(mask(r+win_vec, c+win_vec), 1, num_win);
                weight_vec = exp((vec_i - vec_patch).^2/sigma_precompute).*G1_vec;%�̶�ֵ�����Ա�������
                weight_o((r-1)*W+c,:) = weight_vec;
                res_i = sum(weight_vec.*mask_vec)/sum(weight_vec);
                mask_gbf(r,c) = res_i;
            end
        end 
        return;
    end
    
   
    if is_ime == 1  %guided imerode
        for r = r_start : r_end
            for c = c_start : c_end          
                if mask(r,c)
                    mask_vec = reshape(mask(r+win_vec, c+win_vec), 1, num_win);
                    
                    weight_vec = weight((r-1)*W+c,:);
                    
                    res_i = sum(weight_vec.*mask_vec)/sum(weight_vec);
                    mask_gbf(r,c) = res_i;
                    
                end
            end
        end
    elseif is_ime == 0%guided imdilate
        for r = r_start : r_end
            for c = c_start : c_end          
                if ~mask(r,c)
                    mask_vec = reshape(mask(r+win_vec, c+win_vec), 1, num_win);
                   
                    weight_vec = weight((r-1)*W+c,:);
                    
                    res_i = sum(weight_vec.*mask_vec)/sum(weight_vec);
                    mask_gbf(r,c) = res_i;
                end
            end
        end
        mask_gbf = (mask_gbf + mask)>0;
        
    else  %is_ime == -1    do all pixels
        for r = r_start : r_end
            for c = c_start : c_end          
                    mask_vec = reshape(mask(r+win_vec, c+win_vec), 1, num_win);
                   
                    weight_vec = weight((r-1)*W+c,:);
                    
                    res_i = sum(weight_vec.*mask_vec)/sum(weight_vec);
                    mask_gbf(r,c) = res_i; 
            end
        end
    end
% figure(1), imshow(mat2gray(mask_gbf), 'border', 'tight'), title('grayscale result')
mask_gbf = mask_gbf>thres;
Res_I(:,:,1) = mask_gbf*255;
Res_I(:,:,2) = I;
Res_I(:,:,3) = zeros(H,W);
figure(4), imshow(uint8(Res_I), 'border', 'tight'), title('after JBF')
% figure(2), imshow(mask_gbf, 'border', 'tight'), title('after JBF')
Res_I(:,:,1) = mask*255;
figure(3), imshow(uint8(Res_I), 'border', 'tight'), title('before JBF')
  
g_t = abs(sum(sum(logical(mask) - logical(mask_gbf))));


end