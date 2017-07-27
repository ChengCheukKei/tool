%% ��ȡdepthMapǰ����tank
clear all; close all;
backgroundFile = 'E:\dataSet\set4\background\';
foregroundFile = 'E:\dataSet\set4\foreground\';
fusionBackgroundFraNum = 100; %�ںϱ�����֡��
fusionForegroundSeg = 5; %ǰ���У�ÿ x ֡�ںϵõ��µ����ͼ
foregroundFraNum = 600;
backgroundData = {}; %save raw data from background file
foregroundData = {}; %save raw data from foreground file
fusionedBackgroundData = {};
fusionedForegroundData = {};
extractedTankData = {};

module1 = 1; %fusion background
module2 = 1; %fusion foreground
module3 = 1; %extract tank in foreground

if module1 ==1 
    %read backGround data
    for i = 1:fusionBackgroundFraNum
        backgroundData(i).data = imread([backgroundFile,'depth_output',int2str(i),'.png']);
    end
    fusionedBackgroundData = fusionBackgroundFunc(backgroundData);
    imwrite(uint16(fusionedBackgroundData),'E:\dataSet\set4\processedData\depth\fusionedBackgroundData\fusionedBackgroundData.png');
end

if module2 == 1
    for i = 1:foregroundFraNum
        foregroundData(i).data = imread([foregroundFile,'depth_output',int2str(i),'.png']);
    end
    fusionedForegroundData = fusionForegroundFunc(foregroundData, fusionForegroundSeg);
    %save fusionedForegroundData
    for i = 1:foregroundFraNum/fusionForegroundSeg
        imwrite(uint16(fusionedForegroundData(i).data),['E:\dataSet\set4\processedData\depth\fusionedForegroundData\fusionedForegroundData',int2str(i),'.png'])
    end
end

if module3 == 1
    if(module1 == 0) 
        fusionedBackgroundData = imread('E:\dataSet\set4\processedData\depth\fusionedBackgroundData\fusionedBackgroundData.png');
    end
    if(module2 == 0)
        for i = 1:foregroundFraNum/fusionForegroundSeg
            fusionedForegroundData(i).data = imread(['E:\dataSet\set4\processedData\depth\fusionedForegroundData\fusionedForegroundData',int2str(i),'.png']);
        end
    end
    extractedTankData = extractTankFunc(fusionedBackgroundData, fusionedForegroundData);
    %save extractedTankData
    for i = 1:foregroundFraNum/fusionForegroundSeg
        imwrite(uint16(extractedTankData(i).data), ['E:\dataSet\set4\processedData\depth\extractedTankData\extractedTankData',int2str(i),'.png']);
    end
end