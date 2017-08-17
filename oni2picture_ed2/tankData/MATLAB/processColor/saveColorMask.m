function saveColorMask(fusionedBackgroundData, fusionedForegroundData, k)
    thres = 30;
    Y_fg = fusionedForegroundData(:,:,1);
    Y_bg = fusionedBackgroundData(:,:,1);
    
    mask1 = abs(double(Y_bg) - double(Y_fg)) > thres;
    imwrite(uint8(mask1), ['E:\dataSet\Wajueji_2\processedData\intensityMask\mask',int2str(k),'_c.png']);
end