%% TRANSFORM_RGB2YCBCR : transform color background
function transformRGB2YCBCR
    outputFile_address = 'E:\dataSet\ICAISS\GSM\GSM_dataset\GSM\BootStraping_ds\ycbcrData\';
    inputFile_address = 'E:\dataSet\ICAISS\GSM\GSM_dataset\GSM\BootStraping_ds\colorData\';
    for i = 0:399     %%420~540
        disp(['processing frame', int2str(i)]);
         raw_rgb_map = imread([inputFile_address, 'img_', int2str(i), '.Jpeg']);
         ycbcr_map = rgb2ycbcr(raw_rgb_map);
         imwrite(ycbcr_map, [outputFile_address, 'ycbcr_color_', int2str(i), '.png']);
    end
end