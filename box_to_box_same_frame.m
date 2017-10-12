close all;
clear all;clc;

% labels_type='val_with_box_augmentation';
% save_dir='val_box_pairs_same_frame';
labels_type='train_with_box_augmentation';
% save_dir='train_box_pairs_same_frame';
save_dir='train_box_list';
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
    save_path=fullfile(Annotation_root,save_dir,seq_path);

    idx_labeled_frames=find([Annotation.annolist.is_labeled]==1);
    for num_mat = 1:length(idx_labeled_frames)
        cur_frame_idx=idx_labeled_frames(num_mat);
        % mat file name
        mat_pair_name=cat(2,Annotation.annolist(cur_frame_idx).image.name(find(Annotation.annolist(1).image.name=='/',1,'last')+1:end-4),'_pair.mat');
        mat_box_list_name=cat(2,mat_pair_name(1:end-8),'box_list.mat');
        % create box list
        box_counter = 1;    
        for i=1:length(Annotation.annolist(cur_frame_idx).bounding_box)
            if isfield(Annotation.annolist(cur_frame_idx).bounding_box(i),'track_id')
                if ~isempty(Annotation.annolist(cur_frame_idx).bounding_box(i).track_id)
                    bounding_boxes_list(box_counter).x=Annotation.annolist(cur_frame_idx).bounding_box(i).x1;
                    bounding_boxes_list(box_counter).y=Annotation.annolist(cur_frame_idx).bounding_box(i).y1;
                    bounding_boxes_list(box_counter).w=Annotation.annolist(cur_frame_idx).bounding_box(i).rec_width;
                    bounding_boxes_list(box_counter).h=Annotation.annolist(cur_frame_idx).bounding_box(i).rec_height;
                    bounding_boxes_list(box_counter).track_id=Annotation.annolist(cur_frame_idx).bounding_box(i).track_id;
                    bounding_boxes_list(box_counter).frame_idx=cur_frame_idx;
                    bounding_boxes_list(box_counter).image_name=Annotation.annolist(cur_frame_idx).image.name;
                    box_counter =box_counter+1;
                    for j=1:length(Annotation.annolist(cur_frame_idx).bounding_box(i).bounding_box_augmentation)
                        bounding_boxes_list(box_counter).x=Annotation.annolist(cur_frame_idx).bounding_box(i).bounding_box_augmentation(j).x1;  
                        bounding_boxes_list(box_counter).y=Annotation.annolist(cur_frame_idx).bounding_box(i).bounding_box_augmentation(j).y1;
                        bounding_boxes_list(box_counter).w=Annotation.annolist(cur_frame_idx).bounding_box(i).bounding_box_augmentation(j).rec_width;
                        bounding_boxes_list(box_counter).h=Annotation.annolist(cur_frame_idx).bounding_box(i).bounding_box_augmentation(j).rec_height;
                        bounding_boxes_list(box_counter).track_id=Annotation.annolist(cur_frame_idx).bounding_box(i).track_id;
                        bounding_boxes_list(box_counter).frame_idx=cur_frame_idx;
                        bounding_boxes_list(box_counter).image_name=Annotation.annolist(cur_frame_idx).image.name;
                        box_counter =box_counter+1;
                    end
                end
            end
        end
        clear i;
        clear j;
        if exist('bounding_boxes_list')
            save(cat(2,save_path,mat_box_list_name) ,'bounding_boxes_list');


%             % create pairs
%             [box_idx1,box_idx2]=meshgrid(1:box_counter-1,1:box_counter-1);
%             box_idx1=box_idx1(:);
%             box_idx2=box_idx2(:);
%             pairs=[box_idx1,box_idx2];
%             pairs=pairs(find(pairs(:,1)<pairs(:,2)),:);
%             for i=1:size(pairs,1)
%                 box_pairs(i).box1=bounding_boxes_list(pairs(i,1));
%                 box_pairs(i).box2=bounding_boxes_list(pairs(i,2));
%                 box_pairs(i).delta_t=box_pairs(i).box2.frame_idx-box_pairs(i).box1.frame_idx;
%                 box_pairs(i).is_same_id=box_pairs(i).box2.id==box_pairs(i).box1.id;
%             end
%             save(cat(2,save_path,mat_pair_name) ,'box_pairs');
            clear bounding_boxes_list;
%             clear box_pairs;
        end
    end
end