function extractedTankData = extractTankFunc(fusionedBackgroundData, fusionedForegroundData)
    fusionedForeFraNum = size(fusionedForegroundData, 2);
    thres = 30;%mm
    result = {};
    %%ǰ��������
    for i = 1:fusionedForeFraNum
%         judgeArr =  abs((uint16(fusionedBackgroundData) - (uint16(fusionedForegroundData(i).data))))>thres;
        judgeArr =  abs((double(fusionedBackgroundData) - (double(fusionedForegroundData(i).data))))>thres;
        result(i).data = uint16(fusionedForegroundData(i).data) .* uint16(judgeArr);
    end
    extractedTankData = result;
    
    %%visualization
    for i = 1:fusionedForeFraNum
        figure; imshow(extractedTankData(i).data, []); title(['��',int2str(i),'֡']);
    end
end