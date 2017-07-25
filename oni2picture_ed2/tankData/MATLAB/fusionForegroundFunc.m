% ��fusionForegroundSeg֡Ϊ��λ����λ�ڵ�֡�����ں�
function fusionedForegroundData = fusionForegroundFunc(foregroundData, fusionForegroundSeg)
    frameNum = size(foregroundData,2);
    if mod(frameNum, fusionForegroundSeg) ~= 0
        disp('fusionForegroundFunc error: frameNum������fusionForegroundSeg');
        return;
    end
    unitNum = frameNum / fusionForegroundSeg;
    result = {};
    for j = 1:unitNum
        for u = 1:640
            for v = 1:480
                tmp = 0; count = 0;
                for i = (fusionForegroundSeg*(j - 1)+1):(fusionForegroundSeg*j)
                    if foregroundData(i).data(v,u)~=0
                        tmp = tmp + foregroundData(i).data(v,u);
                        count = count + 1;
                    end
                end
                if count == 0   %���ص����ֵ��Ϊ0
                    result(j).data(v,u) = 0; continue;
                else
                    result(j).data(v,u) = double(tmp)/count;
                end
            end
        end
    end
    fusionedForegroundData = result;
end