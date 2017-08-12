function extractedTankData = extractTank_color_ycbcr_Func(fusionedBackgroundData, fusionedForegroundData, extractedDepthMap)
    thres = 60;
    frameNum = 1;%size(fusionedForegroundData,2);
    
    %%ȡmask
    for i = 1:frameNum
        Y_fg = fusionedForegroundData(:,:,1);
        Y_bg = fusionedBackgroundData(:,:,1);

        mask1 = abs(double(Y_bg) - double(Y_fg)) > thres;
%         mask1 = ones(480,640);
    %%��mask1���͸�ʴ
%         se = strel('rectangle', [5 5]);
%         mask1 = imdilate(mask1, se);
%         mask1 = imerode(mask1, se);
%         mask1_jbf = guidedBilateralFilter(mask1, Y_fg);
        
        mask2 = extractedDepthMap(i).data > 0;
        figure, imshow(mask2,[]),title('depth mask');
%         figure, imshow(Y_fg,[]);
%         figure, imshow(Y_bg,[]);

        extractedTankData(i).data = zeros(size(fusionedBackgroundData));
%         index = mask1 .* mask2;%mask�����
%             index = mask1_jbf .* mask2;
             index = (mask1_jbf + mask2)>0;
%         index = (mask1 + mask2) > 0;%mask�����
        extractedTankData(i).data(:,:,1) = uint8(fusionedForegroundData(:,:,1)) .* uint8(index);
        extractedTankData(i).data(:,:,2) = uint8(fusionedForegroundData(:,:,2)) .* uint8(index);
        extractedTankData(i).data(:,:,3) = uint8(fusionedForegroundData(:,:,3)) .* uint8(index);

    end
end