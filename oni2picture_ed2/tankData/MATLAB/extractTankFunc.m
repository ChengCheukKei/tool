function extractedTankData = extractTankFunc(fusionedBackgroundData, fusionedForegroundData)
    fusionedForeFraNum = size(fusionedForegroundData, 2);
    thres = 20;%mm
    result = {};
    %%ǰ��������
    for i = 1:fusionedForeFraNum
        judgeArr =  (fusionedBackgroundData - (uint16(fusionedForegroundData(i).data)))>thres;
        result(i).data = fusionedForegroundData(i).data .* uint16(judgeArr);
    end
    extractedTankData = result;
    
    figure;
    imshow(extractedTankData(1).data, []), title('��1֡');
    figure;
    imshow(extractedTankData(2).data, []), title('��2֡');
end