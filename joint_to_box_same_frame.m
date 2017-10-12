close all;
clear all;clc;
% load data from bounding box list and joint list. 

% labels_type='val_with_box_augmentation';
% save_dir='val_joit_list';
labels_type='train_with_box_augmentation';
% save_dir='train_box_pairs_same_frame';
save_dir='train_joit_box_pairs_same_frame';
% load joint positions
Annotation_root = '/home/zouyunzhe/JointTracking/tmp/posetrack/posetrack_data/annotations/';
Annotation_bounding_box_list_root= fullfile(Annotation_root,'train_box_list');
Annotation_joint_list_root= fullfile(Annotation_root,'train_joit_list');
Annotation_Path = fullfile(Annotation_root,labels_type);
Annotation_files = dir(fullfile(Annotation_Path,'*.mat'));

% is_head_rec=0;
%% get the box list and joint list path
folder_layer1=dir(Annotation_bounding_box_list_root);
folder_layer1(1:2)=[];
for folder_layer1_idx=1:length(folder_layer1)
    folder_layer2=dir(fullfile(folder_layer1(folder_layer1_idx).folder,folder_layer1(folder_layer1_idx).name));
    folder_layer2(1:2)=[];
    re_path1=folder_layer1(folder_layer1_idx).name;
    for folder_layer2_idx=1:length(folder_layer2)
        path_tmp_box=fullfile(folder_layer2(folder_layer2_idx).folder,folder_layer2(folder_layer2_idx).name);
        re_path2=folder_layer2(folder_layer2_idx).name;
        path_tmp_joint=fullfile(Annotation_joint_list_root,re_path1,re_path2);
        files_box=dir(fullfile(path_tmp_box,'*.mat')); % box list path
        files_joint=dir(fullfile(path_tmp_joint,'*.mat')); % joint list path


        for mat_file_idx=1:length(files_box)
            mat_pair_name=files_box(mat_file_idx).name(1:end-13);
            save_path=fullfile(Annotation_root,save_dir,re_path1,re_path2,mat_pair_name);
            if exist(save_path)~=7
                mkdir(save_path);
            end
            %% get the box list and joint list data
            box_tmp=load(fullfile(files_box(mat_file_idx).folder,files_box(mat_file_idx).name));
            joint_tmp=load(fullfile(files_joint(mat_file_idx).folder,files_joint(mat_file_idx).name));


            %% create pairs (head to box)

            if isfield(joint_tmp.joint_list,'head_rec')
                if ~isempty(joint_tmp.joint_list.head_rec)
                    [head_idx,box_idx]=meshgrid(1:length(joint_tmp.joint_list.head_rec),1:length(box_tmp.bounding_boxes_list));
                    head_idx=head_idx(:);
                    box_idx=box_idx(:);
                    pairs=[head_idx,box_idx];
                    num_pairs=size(pairs,1);
                    joint_to_box_pairs=initializeEmptyStructHeadToBoxArray(num_pairs);
                    for i=1:num_pairs
                        joint_to_box_pairs(i).head_rec=joint_tmp.joint_list.head_rec(pairs(i,1));
                        joint_to_box_pairs(i).box=box_tmp.bounding_boxes_list(pairs(i,2));
                        joint_to_box_pairs(i).delta_t=joint_to_box_pairs(i).box.frame_idx-joint_to_box_pairs(i).head_rec.frame_idx;
                        joint_to_box_pairs(i).is_same_id=joint_to_box_pairs(i).box.id==joint_to_box_pairs(i).head_rec.track_id;
                        % rename box list field 'id' with 'track_id'
                        [joint_to_box_pairs(i).box.('track_id')]=joint_to_box_pairs(i).box.('id');
                        joint_to_box_pairs(i).box = rmfield(joint_to_box_pairs(i).box,'id');
                    end
                    save(cat(2,save_path,'/',mat_pair_name,'_head_box.mat') ,'joint_to_box_pairs');
                    clear joint_to_box_pairs;
                end
            end 
            % create pairs (joint to box)
            for cur_joint_type=1:15 %15tpyes
                if isfield(joint_tmp.joint_list,'joint_type')
                    if ~isempty(joint_tmp.joint_list.joint_type(cur_joint_type).x)
                        [joint_idx,box_idx]=meshgrid(1:length(joint_tmp.joint_list.joint_type(cur_joint_type).x),1:length(box_tmp.bounding_boxes_list));
                        joint_idx=joint_idx(:);
                        box_idx=box_idx(:);
                        pairs=[joint_idx,box_idx];
                        num_pairs=size(pairs,1);
                        joint_to_box_pairs=initializeEmptyStructJointToBoxArray(num_pairs);
                        for i=1:num_pairs
                            joint_to_box_pairs(i).joint.x=joint_tmp.joint_list.joint_type(cur_joint_type).x(pairs(i,1));
                            joint_to_box_pairs(i).joint.y=joint_tmp.joint_list.joint_type(cur_joint_type).y(pairs(i,1));
                            joint_to_box_pairs(i).joint.is_visible=joint_tmp.joint_list.joint_type(cur_joint_type).is_visible(pairs(i,1));
                            joint_to_box_pairs(i).joint.track_id=joint_tmp.joint_list.joint_type(cur_joint_type).track_id(pairs(i,1));
                            joint_to_box_pairs(i).joint.frame_idx=joint_tmp.joint_list.joint_type(cur_joint_type).frame_idx;
                            joint_to_box_pairs(i).joint.image_name=joint_tmp.joint_list.joint_type(cur_joint_type).image_name;
                            joint_to_box_pairs(i).joint.type_id=cur_joint_type-1;
                            joint_to_box_pairs(i).box=box_tmp.bounding_boxes_list(pairs(i,2));
                            joint_to_box_pairs(i).delta_t=joint_to_box_pairs(i).box.frame_idx-joint_to_box_pairs(i).joint.frame_idx;
                            joint_to_box_pairs(i).is_same_id=joint_to_box_pairs(i).box.id==joint_to_box_pairs(i).joint.track_id;
                            % rename box list field 'id' with 'track_id'
                            [joint_to_box_pairs(i).box.('track_id')]=joint_to_box_pairs(i).box.('id');
                            joint_to_box_pairs(i).box = rmfield(joint_to_box_pairs(i).box,'id');
                        end
                        save(cat(2,save_path,'/',mat_pair_name,'_joint',num2str(cur_joint_type-1),'_box.mat') ,'joint_to_box_pairs');
                        clear joint_to_box_pairs;
                    end
                end  
            end
        end
    end
end



function Joint_Box = initializeEmptyStructHeadToBoxArray(num_pairs)
tmp.head_rec = [];
tmp.box= [];
tmp.delta_t=[];
tmp.is_same_id=[];
Joint_Box = repmat(tmp,num_pairs,1);
end

function Joint_Box = initializeEmptyStructJointToBoxArray(num_pairs)

tmp.joint = [];
tmp.box= [];
tmp.delta_t=[];
tmp.is_same_id=[];
Joint_Box = repmat(tmp,num_pairs,1);

end
