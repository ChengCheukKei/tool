%% SPARSE2DENSE
% �Ե�һ֡ͼΪguidance����ͼ����sparse unique correspondence point cloud��ֵ��dense point cloud
%         pc1:pointCloud.      �������ĵ��ƣ���Ҫ��3DͶӰ��2D���ƽ��
%         D2 :640*480 array.   pointCloud2��ԭ���ͼ
% unique_corr:pc1.Count*3.     [indice, correspondence, dist]
% camera_para:struct.          containing fx, fy, cx, cy
%        Yuv1:640*480*3 array
%        Yuv2:640*480*3 array
%    densePC1:640*480 array.   ��ֵ����ܵ�pointCloud1�����ͼ  
%
% Note:˼·����ͼ��Ϊguidance������ͼһ����������guided JBF���������£�
%      a) ��һ֡ͼ�е�ĳ�� i (�õ㲻ӵ��unique_correspondence)��Ϊ���ģ� ��widthΪ�߳����췽�δ���
%      b) ���������ص��ȨֵΪ: w = w_intensity * w_distance * w_depth
%      c) �� i �����ֵΪ d_i = ����_j * d_j / ����_j

function denseMap1 = sparse2dense(pc1, D2, unique_corr, camera_para, Yuv1, Yuv2)
    if nargin < 1, load('pc.mat','pc_197'); pc1 = pc_197; clear pc_197; end;
    if nargin < 2, D2 = imread('E:\dataSet\Wajueji_2\processedData\extractdata_afterDRev\d_198.png');end
    if nargin < 3, load('corrIndex.mat','corrIndex_wc03_thres2');
        unique_corr = corrIndex_wc03_thres2;  clear corrIndex_wc03_thres2; 
    end
    if nargin < 4, camera_para = struct('fx',504.261,'fy',503.905,'cx',352.457,'cy',272.202); end
    if nargin < 5, Yuv1 = imread('E:\dataSet\Wajueji_2\processedData\extractdata_afterDRev\c_197.png');end
    if nargin < 6, Yuv2 = imread('E:\dataSet\Wajueji_2\processedData\extractdata_afterDRev\c_198.png');end
    %%======ͶӰ����POI�˲���pc1�����ƽ��======
    validIndex = unique_corr(:,2)>0;  %exclude invalid correspondence
    unique_corr = unique_corr(validIndex,:);
    xyz_pc = select(pc1, unique_corr(:,1));  
    xyz_pc1 = xyz_pc.Location(:,:); y_pc1 = xyz_pc.Color(:,1);
    
    %D1:pointCloud1������ӵ��unique_correspondence�ĵ��ͶӰuvd
    %Y1:pointCloud1������ӵ��unique_correspondence�ĵ��ͶӰuvY
    [~, D1, Y1]= transformXYZ2UVD(xyz_pc1, camera_para, y_pc1);  

    denseMap1 = tripple_guided_JBF(D1, D2, Y1, Yuv2(:,:,2));
   
end

%map������һ�Ŷ�ά��ͶӰͼ
function [vud_pc, D, Y]= transformXYZ2UVD(xyz_pc, camera_para, y_pc1)
    D = zeros(480,640);  Y = zeros(480,640);
    vud_pc = zeros(size(xyz_pc));
    vud_pc(:,3) = xyz_pc(:,3);                                                       %d = z
    for i = 1:size(xyz_pc,1)
        vud_pc(i,2) = round(xyz_pc(i,1)*camera_para.fx/xyz_pc(i,3)+camera_para.cx);  %u = (x*f_x)/z + c_x
        vud_pc(i,1) = round(xyz_pc(i,2)*camera_para.fy/xyz_pc(i,3)+camera_para.cy);  %v = (y*f_y)/z + c_y
        D(vud_pc(i,1),vud_pc(i,2)) = vud_pc(i,3);
        Y(vud_pc(i,1),vud_pc(i,2)) = y_pc1(i,1);
    end
end








