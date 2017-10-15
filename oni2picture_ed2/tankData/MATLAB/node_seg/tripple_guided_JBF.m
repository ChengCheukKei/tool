%% TRIPPLE_GUIDED_JBF
%  D1:480*640. pc1��ӵ��unique correspondence�ĵ��2DͶӰͼuvd.   ��������mask
%  D2:480*640. pc2��2DͶӰͼuvd.                                  guidance
%  Y1:480*640. pc1��ӵ��unique correspondence�ĵ��2DͶӰͼuvY.
%  Y2:480*640. pc2�ĵ��2DͶӰͼuvY
function mask_gbf = tripple_guided_JBF(D1, D2, Y1, Y2)
    [H, W] = size(D2);
    mask_gbf = zeros(H,W);
    sigma_c = 8;  win_width = 11;  %win_width����������  
    thres = 0.5;
    num_win = win_width * win_width;
    half_w = (win_width - 1) / 2;
    sigma_precompute = -2 * sigma_c * sigma_c;
    r_start = half_w + 1; r_end = round(H - half_w - 1);
    c_start = half_w + 1; c_end = round(W - half_w - 1);
    
    G1_mat = fspecial('gaussian', win_width, half_w);
    G1_vec = reshape(mat2gray(G1_mat), 1, num_win);
    win_vec = -half_w:half_w;
    
    for r = r_start : r_end
        for c = c_start : c_end
            vec_patch = reshape(D2(r+win_vec, c+win_vec), 1, num_win);
            vec_i = ones(1, num_win)*D2(r,c);
            mask_vec = exp((vec_i - vec_patch).^2/sigma_precompute).*G1_vec;%�̶�ֵ�����Ա�������
            
            res_i = sum(weight_vec.*mask_vec)/sum(weight_vec);
            mask_gbf(r,c) = res_i;
        end
    end
    
    
    
    
    
    
end