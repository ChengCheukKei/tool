function extractedTankData = extractTankFunc(fusionedBackgroundData, fusionedForegroundData)
    fusionedForeFraNum = size(fusionedForegroundData, 2);
    thres = 30;%mm
    result = {};
    %%ǰ��������
    for i = 1:fusionedForeFraNum
%         judgeArr =  abs((uint16(fusionedBackgroundData) - (uint16(fusionedForegroundData(i).data))))>thres;
        mask1 =  (double(fusionedBackgroundData) - (double(fusionedForegroundData(i).data)))>thres;
        mask2 = fusionedForegroundData(i).data < 2000;
        
        %%before imerode and  imdilate
        figure, hold on;
        result(i).data = uint16(fusionedForegroundData(i).data) .* uint16(mask1) .* uint16(mask2);
        subplot(1,3,1);
        imshow(result(i).data,[]);
        %%after imerode and  imdilate
        se = strel('rectangle', [5 5]);
        mask3 = imerode(result(i).data > 0, se);
        subplot(1,3,2); imshow(mask3,[]);
        mask3 = imdilate(mask3, se);
        subplot(1,3,3); imshow(mask3,[]);
        hold off;
        
        result(i).data = result(i).data .* uint16(mask3);
        %%ת����[0-255]
%          result(i).data = double(result(i).data) .* (255/10000);
        
    end
    extractedTankData = result;
    
    %%visualization
    for i = 1:fusionedForeFraNum
        figure; imshow(extractedTankData(i).data, []); title(['��',int2str(i),'֡']);
    end
end