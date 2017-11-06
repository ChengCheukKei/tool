%% SPARSE2DENSE_V3
%======JTF��ͼ���������ֵ��û��unique_corr�ĵ��transformation=====
% �Ե�һ֡ͼΪguidance����ͼ���в�ֵ�������ֵ��û��unique_corr�ĵ��transformation
%         pc1:pointCloud.      guidance���ƣ���Ҫ��ת��pc2�����꣬Ȼ���3DͶӰ��2D���ƽ��
%         pc2:pointCloud.      �������ĵ��ƣ���Ҫ��3DͶӰ��2D���ƽ��
% point_corr:pc1.Count*3.     [indice, correspondence, dist]
% camera_para:struct.          containing fx, fy, cx, cy
%        Tmat:cell.            save ICP result of each node in each layers
% pc_bestNode_distr: array.    n*1.  ��¼ÿ��point���������node���ĸ�
% transformationMap��480*640*6. ������pc2��2DͶӰͼһ������ÿ�����ص��ֵΪtransfomation��[��,�£��ã�t1,t2,t3]
%
% Note:˼·����ͼһΪguidance������ͼ������������guided JBF���������£�
%      1.pc1����unique_corr�ĵ㣬transform��pc2������.�õ�D1,Y1,transformationMap1
%      2.pc2����unique_corr�ĵ㣬ͶӰ�õ�D2, Y2, transformationMap2,mask2
%      3.pc2�����е㣬ͶӰ�õ�D3,Y3,transformationMap3,mask3
%      4.mask = (~mask2) & mask3. ��������mask==1�ĵ㣬�˴�������z-buffer
%      3.tripple_filter�У�ֻ�Է��δ�����depth~=0����ȵ���м�Ȩƽ�����˴�Ҫ������mask==1�����ص㶼Ҫ���transformation
%      tripple_filter
%      a) ��һ֡ͼ�е�ĳ�� i (�õ㲻ӵ��unique_correspondence)��Ϊ���ģ� ��widthΪ�߳����췽�δ���
%      b) ���������ص��ȨֵΪ: w = w_intensity * w_distance * w_depth
%      c) �� i ��[��,�£��ã�t1,t2,t3]Ϊ t_i = ����_j * t_j / ����_j

function transformationMap = sparse2dense_v3(pc1, pc2, point_corr, camera_para, Tmat, pc_bestNode_distr)
    addpath(genpath('E:\matlab_thirdparty_lib'));
    if nargin < 1, load('pc.mat','pc_197'); pc1 = pc_197; clear pc_197; end;
    if nargin < 2, load('pc.mat','pc_198'); pc2 = pc_198; clear pc_198; end;
    if nargin < 3, load('corrIndex.mat','corrIndex_wc03_thres2');
        point_corr = corrIndex_wc03_thres2;  clear corrIndex_wc03_thres2; 
    end
    if nargin < 4, camera_para = struct('fx',504.261,'fy',503.905,'cx',352.457,'cy',272.202); end
    if nargin < 5, load('Tmat_wc03.mat'); end
    if nargin < 6, load('pc_bestNode_distr.mat');
        pc_bestNode_distr = pc_bestNode_distr_wc03; clear pc_bestNode_distr_wc03; 
    end
    %%======��pc1��unique_corrͶӰ��pc2=======
    pc1_inCoo2 = transform_pc1_into_coordinate_of_pc2(pc1, Tmat, pc_bestNode_distr);
    
    %%======ͶӰ����POI�˲���pc1_inCoo2�����ƽ��======
    unique_corr = point_corr(point_corr(:,2)>0,:);
    not_unique_corr = point_corr(point_corr(:,2)==0,:);
     
    xyz_pc1 = select(pc1_inCoo2, unique_corr(:,1));  %20342  
    y_pc1 = xyz_pc1.Color(:,1); xyzidx_pc1 = [xyz_pc1.Location(:,:), unique_corr(:,1)]; 
    %D1:pc1_inCoo2������ӵ��unique_correspondence�ĵ��ͶӰuvd. guidance
    %Y1:pc1_inCoo2������ӵ��unique_correspondence�ĵ��ͶӰuvY
    %transformationMap1:480*640*3. ��¼ÿ�����ص��
    [~, D1, Y1, idx_map1]= transformXYZ2UVDI(xyzidx_pc1, camera_para, y_pc1, unique_corr);
    transformationMap1 = idx_to_transformation(idx_map1, pc_bestNode_distr, Tmat);
    
    %D2:pointCloud2������ӵ��unique_correspondence�ĵ��ͶӰuvd
    %Y2:pointCloud2������ӵ��unique_correspondence�ĵ��ͶӰuvY
    %idx_map2:��¼D2��ͶӰ��(����unique_corr)��pc1�еĶ�Ӧcorr
    xyz_pc2 = select(pc2,unique_corr(:,2));
    y_pc2 = xyz_pc2.Color(:,1); xyzidx_pc2 = [xyz_pc2.Location(:,:), unique_corr(:,2)];
    [~, D2, ~, idx_map2]= transformXYZ2UVDI(xyzidx_pc2, camera_para, y_pc2, unique_corr);
    mask2 = D2 > 0;
    transformationMap2 = idx_to_transformation(idx_map2, pc_bestNode_distr, Tmat);
    
    %D3:pointCloud2�����е��ͶӰuvd
    %Y3:pointCloud2�����е��ͶӰuvY
    xyz_pc3 = pc2;
    y_pc3 = xyz_pc3.Color(:,1); xyzidx_pc3 = [xyz_pc3.Location(:,:), zeros(pc2.Count,1)];
    [~, D3, Y3, ~]= transformXYZ2UVDI(xyzidx_pc3, camera_para, y_pc3, zeros(pc2.Count,1));
    mask3 = D3 > 0;
    
    %mask>0�ĵ���Ҫtripple_filter����ĵ�
    mask = mask3 & (~mask2);
    
    %��idx_map2ת��transformationMap2
   transformationMap2 = idx_to_transformation(idx_map2, pc_bestNode_distr, Tmat);
    
   transformationMap = tripple_guided_JBF_v3(D1, D3, Y1, Y3, mask, transformationMap1, transformationMap2);
   
    
    %%======�ϲ�addMap_idx_map��idx_map2��======
    %�ϲ����������ص��Ļ���idx_map2�����ȼ�����addMap
%     if sum(sum((addMap_idx_map>0)&(idx_map2>0)))~=0, error('idx_map && addMap ~= 0');end  %����Ƿ��������ص�
%     idx_map2 = addMap_idx_map + idx_map2;
    
    %���idx_map�еĵ��Ƿ���pc_best_Node����û����
%     load('test.mat','idx_map');
%     idx_map = int16(idx_map);
%     for r = 1:480
%         for c = 1:640
%             if idx_map(r,c) == 0, continue; end
%             if pc_bestNode_distr(idx_map(r,c)) ~= 0
%                 disp(['r=',num2str(r),', c=',num2str(c)]);
%             end
%         end
%     end
end


function [vud_pc, D, Y, idx_map]= transformXYZ2UVDI(xyzidx_pc, camera_para, y_pc1, unique_corr)
    D = zeros(480,640);  Y = zeros(480,640);
    xyz_pc = xyzidx_pc(:,1:3); idx = xyzidx_pc(:,4);
    vud_pc = zeros(size(xyz_pc));
    vud_pc(:,3) = xyz_pc(:,3);                                                       %d = z
    count = 0;
    idx_map = zeros(size(D));
    for i = 1:size(xyz_pc,1)
        if vud_pc(i,3) == 0, continue; end
        vud_pc(i,2) = round(xyz_pc(i,1)*camera_para.fx/xyz_pc(i,3)+camera_para.cx);  %u = (x*f_x)/z + c_x
        vud_pc(i,1) = round(xyz_pc(i,2)*camera_para.fy/xyz_pc(i,3)+camera_para.cy);  %v = (y*f_y)/z + c_y
        D(vud_pc(i,1),vud_pc(i,2)) = vud_pc(i,3);
        Y(vud_pc(i,1),vud_pc(i,2)) = y_pc1(i,1);
        idx_map(vud_pc(i,1),vud_pc(i,2)) = unique_corr(i,1);
        count = count + 1;
    end
%     figure(1),imshow(D,[]);
%     figure(2),imshow(idx_map,[]);
end

%% TRANSFORM_PC1_INTO_COORDINATE_OF_PC2
function pc1_inCoo2 = transform_pc1_into_coordinate_of_pc2(pc1, Tmat, pc_bestNode_distr)
    xyz_pc1_inCoo2 = zeros(pc1.Count,3);
    for i = 1:pc1.Count
        if pc_bestNode_distr(i,1) == 0, continue; end;  %exclude the poins that belonging to no node 
        p = pc1.Location(i,:);
        T = Tmat{4}{pc_bestNode_distr(i,1)};
        p_afterTran = transformPointsForward(T, p);
        xyz_pc1_inCoo2(i,:) = p_afterTran;
    end
    pc1_inCoo2 = pointCloud(xyz_pc1_inCoo2);
    pc1_inCoo2.Color = pc1.Color;
end

function transformationMap = idx_to_transformation(idx_map, pc_bestNode_distr, Tmat)
    %===�Ȱ�Tmat{4}ת��[��,�£��ã�t1,t2,t3]
    Tmat_6DoF = zeros(size(Tmat{4},2),1);
    for i = 1:size(Tmat_6DoF)
        T = Tmat{4}{i}.T;
        R = T(1:3,1:3); t = T(4,1:3);
        Tmat_6DoF(i,1:3) = rodrigues(R);
        Tmat_6DoF(i,4:6) = t;
    end
    transformationMap = zeros(480,640,6);  %[��,�£��ã�t1,t2,t3]
    for r = 1:480
        for c = 1:640
            idx = idx_map(r,c);
            if idx==0, continue; end
            t_idx = pc_bestNode_distr(idx);
            transformationMap(r,c,:) = Tmat_6DoF(t_idx,:);
        end
    end
end
 





