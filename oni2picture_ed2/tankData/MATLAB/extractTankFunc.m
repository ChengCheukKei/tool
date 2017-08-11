function extractedTankData = extractTankFunc(fusionedBackgroundData, fusionedForegroundData)
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
        mask_gbf = guidedBilateralFilter(mask_1_2, fusionedBackgroundData);%����
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
    
    %%visualization
%     for i = 1:fusionedForeFraNum
%         figure; imshow(extractedTankData(i).data, []); title(['��',int2str(i),'֡']);
%     end
end