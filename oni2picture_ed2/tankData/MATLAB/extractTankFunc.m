function extractedTankData = extractTankFunc(fusionedBackgroundData, fusionedForegroundData,ycbcr_mat)
    fusionedForeFraNum = size(fusionedForegroundData, 2);
    thres = 60;%mm
    result = {};
    %%ǰ��������
    
    for i = 1:fusionedForeFraNum
        mask1 =  (double(fusionedBackgroundData) - (double(fusionedForegroundData(i).data)))>thres;
        
        mask2 = fusionedForegroundData(i).data < 1000;
        
%         result(i).data = uint16(fusionedForegroundData(i).data) .* uint16(mask1) .* uint16(mask2);
%%guided bilateral filter
        mask_1_2 = mask1 .* mask2;
%         mask_gbf = guidedBilateralFilter(mask_1_2, fusionedForegroundData(i).data);%����
%         mask_gbf = guided_JBF(mask_1_2, fusionedForegroundData(i).data);%����
        mask_1_2 = imerode(mask_1_2, strel('disk', 3));
        mask_a = guided_JBF(mask_1_2, ycbcr_mat(:,:,1));%����
        mask_a = guided_JBF(mask_a, ycbcr_mat(:,:,1));%����
        mask_gbf = guided_JBF(mask_a, ycbcr_mat(:,:,1));%����
        figure, imshow(mask_gbf,[]),title('mask_gbf = processed(mask_1_2)');
        figure, imshow(mask_1_2, []),title('mask_1_2');
        
        result(i).data = uint16(fusionedForegroundData(i).data) .* uint16(mask_gbf);
        
%%��ʴ���ʹ���
%         se = strel('rectangle', [5 5]);
%         mask3 = imdilate(result(i).data > 0, se);
%         mask3 = imerode(mask3, se);
%         result(i).data = result(i).data .* uint16(mask3);
        
        
%%ת����[0-255]
%          result(i).data = double(result(i).data) .* (255/10000);       
    end   
    extractedTankData = result;
end