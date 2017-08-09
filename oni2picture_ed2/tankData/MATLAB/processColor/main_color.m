%% ��ȡcolorMap��ǰ��
clear all; close all;
for k = 1:24
% backgroundFile = 'E:\dataSet\set9\background\';
backgroundFile = 'E:\dataSet\Wajueji_1\background\';
% foregroundFile = 'E:\dataSet\set9\foreground\';
foregroundFile = ['E:\dataSet\Wajueji_1\foreground',int2str(k),'\'];
% extractedDepthFile = 'E:\dataSet\set9\processedData\depth\extractedTankData\';
extractedDepthFile = 'E:\dataSet\Wajueji_1\processedData\depth\extractedTankData\';
fusionBackgroundFraNum = 1; %��ɫͼ����Ҫ�����ں�
fusionForegroundSeg = 100; %ǰ���У�ÿ x ֡�ںϵõ��µĲ�ɫͼ
foregroundFraNum = 100;
backgroundData = {}; %save raw data from background file
foregroundData = {}; %save raw data from foreground file
fusionedBackgroundData = {};
fusionedForegroundData = {};
extractedTankData = {};

module1 = 1; %fusion background
module2 = 1; %fusion foreground
module3 = 1; %extract tank in foreground

if module1 ==1 
    %%read backGround data
    for i = 1:fusionBackgroundFraNum
        backgroundData(i).data = imread([backgroundFile,'color_','30','.png']);
    end
    %fusionedBackgroundData = fusionBackground_color_Func(backgroundData);
    fusionedBackgroundData = backgroundData(1).data;
%     imwrite(uint8(fusionedBackgroundData),'E:\dataSet\set9\processedData\color\fusionedBackgroundData\fusionedBackgroundData.png');
    imwrite(uint8(fusionedBackgroundData),'E:\dataSet\Wajueji_1\processedData\color\fusionedBackgroundData\fusionedBackgroundData.png');
end

if module2 == 1
    for i = 1:foregroundFraNum
        foregroundData(i).data = imread([foregroundFile,'color_',int2str(i),'.png']);
    end
    
    %%ֻ�Ǽ򵥵ؽ��и�֡����
%     fusionedForegroundData = fusionForeground_color_Func(foregroundData, fusionForegroundSeg);
    fusionedForegroundData(1).data = imread([foregroundFile,'color_',int2str(30),'.png']);
    
    %%save fusionedForegroundData
    for i = 1:foregroundFraNum/fusionForegroundSeg
%         imwrite(uint8(fusionedForegroundData(i).data),['E:\dataSet\set9\processedData\color\fusionedForegroundData\fusionedForegroundData',int2str(i),'.png'])
        imwrite(uint8(fusionedForegroundData(i).data),['E:\dataSet\Wajueji_1\processedData\color\fusionedForegroundData\fusionedForegroundData',int2str(k),'.png'])
    end
end

if module3 == 1
    if(module1 == 0) 
%         fusionedBackgroundData = imread('E:\dataSet\set9\processedData\color\fusionedBackgroundData\fusionedBackgroundData.png');
        fusionedBackgroundData = imread('E:\dataSet\Wajueji_1\processedData\color\fusionedBackgroundData\fusionedBackgroundData.png');
    end
    if(module2 == 0)
        for i = 1:foregroundFraNum/fusionForegroundSeg
%             fusionedForegroundData(i).data = imread(['E:\dataSet\set9\processedData\color\fusionedForegroundData\fusionedForegroundData',int2str(i),'.png']);
            fusionedForegroundData(i).data = imread(['E:\dataSet\Wajueji_1\processedData\color\fusionedForegroundData\fusionedForegroundData',int2str(k),'.png']);
        end
    end
    
    %%read extracted depthMap
    for i = 1:foregroundFraNum/fusionForegroundSeg
%         extractedDepthMap(i).data = imread([extractedDepthFile,'extractedTankData',int2str(i),'.png']);
        extractedDepthMap(i).data = imread([extractedDepthFile,'extractedTankData',int2str(k),'.png']);
    end
    
    extractedTankData = extractTank_color_Func(fusionedBackgroundData, fusionedForegroundData, extractedDepthMap);
    
    %%save extractedTankData
    for i = 1:foregroundFraNum/fusionForegroundSeg
%         imwrite(uint8(extractedTankData(i).data), ['E:\dataSet\set9\processedData\color\extractedTankData\extractedTankData',int2str(i),'.png']);
        imwrite(uint8(extractedTankData(i).data), ['E:\dataSet\Wajueji_1\processedData\color\extractedTankData\extractedTankData',int2str(k),'.png']);
    end
end

disp(['processing k=',int2str(k)]);
end
