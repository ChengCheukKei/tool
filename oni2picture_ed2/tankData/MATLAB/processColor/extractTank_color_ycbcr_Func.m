function mask_gbf_c = extractTank_color_ycbcr_Func(fusionedBackgroundData, fusionedForegroundData, k,...
    mask_d4c, mask_c4d, series, mask_border)
    %%ȡmask
        global debug_mode;    global gt;
        Y_fg = fusionedForegroundData(:,:,1);
        Y_bg = fusionedBackgroundData(:,:,1);

        if debug_mode, figure(888),imshow(mask_c4d,[]),title('color intensity substract');drawnow; end;
        
%         mask_c4d = logical(mask_d4c) .* mask_c4d;
%         if debug_mode, figure(666),imshow(mask_c4d,[]),title('mask\_d4c .* mask\_c4d');drawnow; end;

        count = 0;%��һ��ִ��
        weight_i = zeros(1,1);
        %��ִ��һ��ȫ�ֵ�guided_JBF���õ�������weight_o
        if 1
        [~, weight_o,~]= guided_JBF(mask_c4d, Y_fg,-1,count, weight_i,3,5,0.5);%����ֻ�Ǽ�����weight_o
        count = count + 1;
        g_thres = 10;%guided thres------per pixel
        g_t = inf;
        while count<15
            [mask_c4d, ~, g_t] = guided_JBF(mask_c4d, Y_fg, -1, count, weight_o,3,5,0.5);%guided imdilate
            if g_t <= g_thres
                disp(['frame ',int2str(k), '------------total for ', int2str(count), ' times!']);
                break;
            end
            count = count + 1;
            disp(['g_t = ',int2str(g_t), ', now is ' ,int2str(count), 'th time']);
        end
        end
        mask_gbf_c = logical(mask_c4d);
        I(:,:,1) = mask_gbf_c*255;
        I(:,:,2) = Y_fg;
        I(:,:,3) = mat2gray(gt)*255;
        if debug_mode, figure(666),imshow(uint8(I));end;
        mask_gbf_c = logical(mask_d4c) | logical(mask_gbf_c) & logical(mask_border);
        I(:,:,1) = mask_gbf_c*255;
        if debug_mode, figure(666),imshow(uint8(I));drawnow; end;
    end