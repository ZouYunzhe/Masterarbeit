clc;close all;clear all;

labels_type='train_with_box_augmentation';
% save_dir='train_box_pairs_same_frame';
save_dir='train_list_for_sequence';
% load joint positions
Annotation_root = '/home/zouyunzhe/JointTracking/tmp/posetrack/posetrack_data/annotations/';
Annotation_bounding_box_list_root= fullfile(Annotation_root,'train_box_list');
Annotation_joint_list_root= fullfile(Annotation_root,'train_joit_list');
Annotation_Path = fullfile(Annotation_root,labels_type);
Annotation_files = dir(fullfile(Annotation_Path,'*.mat'));
Annotation_index = 0;
%% get the box list and joint list path
folder_layer1=dir(Annotation_bounding_box_list_root);
folder_layer1(1:2)=[];
for folder_layer1_idx=3:3%1:length(folder_layer1)
    folder_layer2=dir(fullfile(folder_layer1(folder_layer1_idx).folder,folder_layer1(folder_layer1_idx).name));
    folder_layer2(1:2)=[];
    re_path1=folder_layer1(folder_layer1_idx).name;
    for folder_layer2_idx=78:length(folder_layer2)
        path_tmp_box=fullfile(folder_layer2(folder_layer2_idx).folder,folder_layer2(folder_layer2_idx).name);
        re_path2=folder_layer2(folder_layer2_idx).name;
        path_tmp_joint=fullfile(Annotation_joint_list_root,re_path1,re_path2);
        files_box=dir(fullfile(path_tmp_box,'*.mat')); % box list path
        files_joint=dir(fullfile(path_tmp_joint,'*.mat')); % joint list path
        save_path=fullfile(Annotation_root,save_dir,re_path1,re_path2);
        Annotation_index=Annotation_index+1;
        Annotation_path = fullfile(Annotation_Path,Annotation_files(Annotation_index).name);
        Annotation = load(Annotation_path); % annotation for the sequence
        if exist(save_path,'dir')==0
            mkdir(save_path);
        end
        box_list_dir=files_box(1).folder;
        joint_list_dir=files_joint(1).folder;
        seq_list=create_list_for_sequence(box_list_dir,joint_list_dir,Annotation);
        save(fullfile(save_path,cat(2,re_path2,'.mat')),'seq_list');
        clear seq_list;
    end
end
