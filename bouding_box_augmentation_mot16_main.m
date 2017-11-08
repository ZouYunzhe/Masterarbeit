% augment the considered bounding box with 8 boxes which have 0.7 IOU and
% 0.7 visibility compared to the original one
clc;close all;clear all;
% the pathes
root_path='/home/zouyunzhe/JointTracking/tmp/MOT16/';
dataset_type ='train';
seq_list = dir(fullfile(root_path,dataset_type));
seq_list(1:2)=[];
% for every sequence
for seq_nr = 1:size(seq_list,1)
    seq_path= fullfile(seq_list(seq_nr ).folder,seq_list(seq_nr ).name);
    notation_path=fullfile(seq_path,'gt/gt.txt');
    save_path = fullfile(seq_path,'gt/gt_new.mat');
    groundtruth = csvread(notation_path);
    img_list=dir(fullfile(seq_path,'img1/*.jpg'));

    % parameters for the augmentation (positive)
    enlarge_pos = 0.20;
    aug_number_pos = 8;
    thres_iou_pos = 0.7;
    thres_visible_pos=0.7;
%     img_size = size(imread(fullfile(img_list(1).folder,img_list(1).name)));
    
    % parameters for the augmentation (false positive)
    aug_number_fpos = 4;
    thres_iou_fpos = 0.46;
    thres_visible_fpos=0.5;
    
    % 1) find the indexes of the considered bounding boxes
    % the logic index for the bounding boxes for positive samples
    if_consider_pos = groundtruth(:,7)==1&groundtruth(:,9)>=thres_visible_pos;
    % the logic index for the bounding boxes for false positive samples
    if_consider_fpos = groundtruth(:,7)==1&groundtruth(:,9)>=thres_visible_fpos;
    % bouding box augmentation (false positive)
    considered_bbox_fpos = groundtruth(if_consider_fpos,:);
    M_aug_fpos_tmp=zeros(length(considered_bbox_fpos),9*aug_number_fpos);
    parfor it = 1:length(considered_bbox_fpos)
        M_aug_fpos_tmp(it,:)=box_augmentation_fpos(considered_bbox_fpos(it,:),aug_number_fpos,thres_iou_fpos);
    end
    M_aug_fpos=zeros(size(M_aug_fpos_tmp,1)*aug_number_fpos,9);
    for k =0:aug_number_fpos-1
        M_aug_fpos(k*size(M_aug_fpos_tmp,1)+1:(k+1)*size(M_aug_fpos_tmp,1),:)=M_aug_fpos_tmp(:,k*9+1:(k+1)*9);
    end
    % bouding box augmentation (positive)
    % 2) do the augmentation for every considered bounding box and add them to
    % the new ground truth file
    tic    
    if_multi_core=1;
    considered_bbox_pos = groundtruth(if_consider_pos,:);
    M_aug_pos_tmp=zeros(length(considered_bbox_pos),9*aug_number_pos);
    % use multi core to accelerate the process
    clear it;clear k;
    parfor it = 1:length(considered_bbox_pos)
        M_aug_pos_tmp(it,:) = box_augmentation_pos(considered_bbox_pos(it,:),enlarge_pos,aug_number_pos,thres_iou_pos,if_multi_core);
    end
    toc
    M_aug_pos=zeros(size(M_aug_pos_tmp,1)*aug_number_pos,9);
    for k =0:aug_number_pos-1
        M_aug_pos(k*size(M_aug_pos_tmp,1)+1:(k+1)*size(M_aug_pos_tmp,1),:)=M_aug_pos_tmp(:,k*9+1:(k+1)*9);
    end
    groundtruth_aug=[groundtruth;M_aug_pos;M_aug_fpos];
    %     save(cat(2,'/home/zouyunzhe/JointTracking/varify_with_matlab/test_parfor/batch_',num2str(batch_idx,'%04d'),'.mat'),'M_aug');
    clear M_aug M_aug_tmp if_consider frame_idx cur_bbox
    save(save_path,'groundtruth_aug');
end
