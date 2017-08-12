function mask_gbf = guidedBilateralFilter(mask, fusionedForegroundData)
    [row, col]  =size(mask);
    windows_width = 11;%�������׷���num
    windows_height = 11;
    sigma = 7;
    thres = 0;
    window = ones(windows_height,windows_width);
    sigma_precompute = -2*sigma*sigma;
    r_start = round((windows_height + 1)/2);
    r_end = round(row - (windows_height+1)/2);
    c_start = round((windows_width + 1)/2);
    c_end = round(col - (windows_width + 1)/2);
    num =(r_end - r_start + 1)*(c_end - c_start + 1);%�������pixel��Ŀ
    %Ԥ����ռ�
    G1_array = zeros(size(window));%��� (i - j)^2
    G2_array(size(mask,1) * size(mask,2)).data = zeros(size(window));%��� (y_i - y_j)^2
    G_array(size(mask,1) * size(mask,2)).data = zeros(size(window));%G = G1 .* G2
    deviate_array_r = zeros(size(G1_array));%�������ƫ�ƾ���
    deviate_array_c = zeros(size(G1_array));%�������ƫ�ƾ���
    mask_gbf = zeros(size(mask));
    
    %%����G1_array�Լ����ƫ�ƾ���deviate_array
    [G1_array, deviate_array_r, deviate_array_c] = precomputeArray(windows_width, windows_height);
    G1_array = exp(G1_array ./ sigma_precompute);
    
    %%����G2_array, ˳��Ҳ����G = G1 .* G2
    for r = r_start : r_end
        for c = c_start : c_end
            G2_array(r*col+c).data = computeIntensity(fusionedForegroundData, r, c, windows_width, windows_height,...
                deviate_array_r, deviate_array_c);
            %%����G
            G2_array(r*col+c).data = exp(G2_array(r*col+c).data ./ sigma_precompute);
            G_array(r*col+c).data = G1_array .* G2_array(r*col+c).data;
            
            %%��һ��G
%             G_min = min(min(G_array(r*col+c).data));
%             G_max = max(max(G_array(r*col+c).data));
%             G_array(r*col+c).data = (G_array(r*col+c).data - G_min) ./ (G_max - G_min);
                G_array(r*col+c).data = G_array(r*col+c).data ./ sum(sum(G_array(r*col+c).data));
            
            %%ȡ����ǰ����(r,c)��Ӧ��windows��ÿ�����ص���ʵλ��
            origin = [r,c];
            mask_window = zeros(size(window));%ȡ��(r,c)��mask�ж�Ӧ�Ĵ���
            for i = 1:windows_height
                for j = windows_width
                     index = [origin(1) + deviate_array_r(i, j), origin(2) + deviate_array_c(i, j)];
                     mask_window(i,j) = mask(index(1),index(2));
                end
            end
            
            %%mask_gbf_i = sum(��_j * G_i), jΪi����������
            mask_gbf(r,c) = sum(sum(mask_window .* G_array(r*col+c).data));
        end
    end
    
    mask_gbf = mask_gbf > thres;
    
end


function [g1, d_array_r, d_array_c] = precomputeArray(windows_width, windows_height)
    g1 = zeros(windows_height, windows_width);
    d_array_r = zeros(windows_height, windows_width);
    d_array_c = zeros(windows_height, windows_width);
    origin = [(windows_height+1)/2, (windows_width+1)/2];
    for r = 1:windows_height
        for c = 1:windows_width
            g1(r,c) = (r - origin(1))^2 + (c - origin(2))^2;
            d_array_r(r,c) = r - origin(1);
            d_array_c(r,c) = c - origin(2);
        end
    end
end

function g2 = computeIntensity(fusionedForegroundData, r, c, windows_width, windows_height,...
    d_array_r, d_array_c)
    g2 = zeros(windows_height, windows_width);    
    origin = [r, c];
    for w_h = 1:windows_height
        for w_w = 1:windows_width
            index = [origin(1) + d_array_r(w_h, w_w), origin(2) + d_array_c(w_h, w_w)];%�������ƫ�Ʊ����windows��ÿ�����ص����ʵ�±�
            g2(w_h, w_w) = (fusionedForegroundData(index(1),index(2)) - fusionedForegroundData(r,c))^2;%����һ�����ֵ
        end
    end
end