clc;close all;clear all;
% the pathes
root_path='/home/zouyunzhe/JointTracking/tmp/MOT16/';
dataset_type ='train';
seq_list = dir(fullfile(root_path,dataset_type));
seq_list(1:2)=[];
delta_frame=1:9;
k_max=100;
pos_ratio=0.5;
fpos_ratio=0.05;
pairs_per_seq=1e5;
% for every sequence
for seq_nr = 1:size(seq_list,1)
    seq_path= fullfile(seq_list(seq_nr).folder,seq_list(seq_nr).name);
    save_path = cat(2,seq_path,'/box_pairs_',seq_list(seq_nr).name,'.mat');
%     if exist(save_path)~=2 % if file doesn't exist
    % create frame pair list
    notation_path = fullfile(seq_path,'gt/gt_new.mat');
    load(notation_path);
    frames_list=unique(groundtruth_aug(:,1));
    frames_list_tmp=repmat(delta_frame,length(frames_list),1);
    frames_list_tmp=frames_list_tmp(:);
    frames_list=repmat(frames_list,length(delta_frame),1);
    frames_pair_list=[frames_list-frames_list_tmp,frames_list];
    frames_pair_list=frames_pair_list(frames_pair_list(:,1)>0,:);
    num_box_pairs_all_per_frame_pair = round(pairs_per_seq/size(frames_pair_list,1));
    img_path = cat(2,seq_path,'/img1/000001.jpg');
    img_size = size(imread(img_path));
    box_pairs=[];

    % parfor
    tic
    parfor idx = 1:size(frames_pair_list,1)
        pairs_tmp=create_pairs_mot16_seq(frames_pair_list(idx,:),groundtruth_aug,num_box_pairs_all_per_frame_pair,pos_ratio,fpos_ratio,img_size);
        box_pairs = [box_pairs;pairs_tmp];
    end
    toc
    save(save_path,'box_pairs')
%     end
end

% varify
% for i=1:length(pairs)
%     a=groundtruth_aug(pairs(i,3),2)==groundtruth_aug(pairs(i,4),2);
%     if a~=pairs(i,5)
%         disp('error');
%     end
% end
% disp('ok')
