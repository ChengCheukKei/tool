%%��fusionForegroundSeg֡����������û���ںϵĲ���
function fusionedForegroundData = fusionForeground_color_Func(foregroundData, fusionForegroundSeg)
    frameNum = size(foregroundData, 2);
    if mod(frameNum, fusionForegroundSeg) ~=0
        disp('fusionForeground_color_Func��������');
    end
    for i = 1:frameNum/fusionForegroundSeg
        fusionedForegroundData(i).data = foregroundData(fusionForegroundSeg*(i-1)+1).data;
    end
end