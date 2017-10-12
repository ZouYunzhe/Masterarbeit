close all;
clear all;clc;

% labels_type='val_with_box_augmentation';
% save_dir='val_joit_list';
labels_type='train_with_box_augmentation';
% save_dir='train_box_pairs_same_frame';
save_dir='train_joit_list';
% load joint positions
Annotation_root = '/home/zouyunzhe/JointTracking/tmp/posetrack/posetrack_data/annotations/';
Annotation_Path = fullfile(Annotation_root,labels_type);
Annotation_files = dir(fullfile(Annotation_Path,'*.mat'));

aug_number = 8; % the number of boxes

for Annotation_index=1:length(Annotation_files)
    Annotation_dir = fullfile(Annotation_Path,Annotation_files(Annotation_index).name);
    Annotation = load(Annotation_dir);

    % sequence

    seq_path=Annotation.annolist(1).image.name(find(Annotation.annolist(1).image.name=='/',1,'first')+1:find(Annotation.annolist(1).image.name=='/',1,'last'));
    % fullfile(Annotation_root,save_dir,seq_path)

    % create dir for sequence
    if exist(fullfile(Annotation_root,save_dir,seq_path))~=7
        mkdir(fullfile(Annotation_root,save_dir,seq_path));
    end
    save_path=fullfile(Annotation_root,save_dir,seq_path); % sequence
    % image size in this sequence
    [size_x,size_y,~]=size(imread(fullfile('/home/zouyunzhe/JointTracking/tmp/posetrack/posetrack_data',Annotation.annolist(1).image.name)));

    idx_labeled_frames=find([Annotation.annolist.is_labeled]==1);
    for num_mat = 1:length(idx_labeled_frames)
        cur_frame_idx=idx_labeled_frames(num_mat);
        % mat file name
        mat_joint_list_name=cat(2,Annotation.annolist(cur_frame_idx).image.name(find(Annotation.annolist(1).image.name=='/',1,'last')+1:end-4),'_joint_list.mat');
       
        % create joint list for the frame
        cur_img_name = Annotation.annolist(cur_frame_idx).image.name;
        cur_frame_idx = idx_labeled_frames(num_mat);
        joint_list.joint_type = initializeEmptyStructJointArray(cur_img_name,cur_frame_idx);
        for annorect_number = 1:length(Annotation.annolist(cur_frame_idx).annorect)
            joint_list.head_rec(annorect_number).x = Annotation.annolist(cur_frame_idx).annorect(annorect_number).x1;
            joint_list.head_rec(annorect_number).y = Annotation.annolist(cur_frame_idx).annorect(annorect_number).y1;
            joint_list.head_rec(annorect_number).w = abs(Annotation.annolist(cur_frame_idx).annorect(annorect_number).x2-Annotation.annolist(cur_frame_idx).annorect(annorect_number).x1);
            joint_list.head_rec(annorect_number).h = abs(Annotation.annolist(cur_frame_idx).annorect(annorect_number).y2-Annotation.annolist(cur_frame_idx).annorect(annorect_number).y1);
            joint_list.head_rec(annorect_number).track_id = Annotation.annolist(cur_frame_idx).annorect(annorect_number).track_id;
            joint_list.head_rec(annorect_number).frame_idx = cur_frame_idx;
            joint_list.head_rec(annorect_number).image_name = cur_img_name;
            
            % if exist annopoints
            if ~isempty(Annotation.annolist(cur_frame_idx).annorect(annorect_number).annopoints)
                for joint_detected_id=1:length(Annotation.annolist(cur_frame_idx).annorect(annorect_number).annopoints.point)
                    idx_tmp = Annotation.annolist(cur_frame_idx).annorect(annorect_number).annopoints.point(joint_detected_id).id+1;  
                    % varify if the joint is valid in the image
                    x_tmp=Annotation.annolist(cur_frame_idx).annorect(annorect_number).annopoints.point(joint_detected_id).x;
                    y_tmp=Annotation.annolist(cur_frame_idx).annorect(annorect_number).annopoints.point(joint_detected_id).y;
                    if x_tmp>0 && x_tmp<=size_y && y_tmp>0 && y_tmp<=size_x 
                        joint_list.joint_type(idx_tmp).x = [joint_list.joint_type(idx_tmp).x,Annotation.annolist(cur_frame_idx).annorect(annorect_number).annopoints.point(joint_detected_id).x];
                        joint_list.joint_type(idx_tmp).y = [joint_list.joint_type(idx_tmp).y,Annotation.annolist(cur_frame_idx).annorect(annorect_number).annopoints.point(joint_detected_id).y];
                        joint_list.joint_type(idx_tmp).is_visible = [joint_list.joint_type(idx_tmp).is_visible,Annotation.annolist(cur_frame_idx).annorect(annorect_number).annopoints.point(joint_detected_id).is_visible];
                        joint_list.joint_type(idx_tmp).track_id = [joint_list.joint_type(idx_tmp).track_id,Annotation.annolist(cur_frame_idx).annorect(annorect_number).track_id];
                        joint_list.joint_type(idx_tmp).joint_type = [joint_list.joint_type(idx_tmp).joint_type,idx_tmp-1];
                    end
                end
            end
        end
        if exist('joint_list')==1
            save(cat(2,save_path,mat_joint_list_name) ,'joint_list');
            clear joint_list;
        end
    end
end

function Joint = initializeEmptyStructJointArray(img_name,frame_idx)

tmp.x = [];
tmp.y= [];
tmp.is_visible = [];
tmp.track_id = [];
tmp.joint_type=[];
tmp.frame_idx = frame_idx;
tmp.image_name = img_name;
Joint = repmat(tmp,15,1);
end
