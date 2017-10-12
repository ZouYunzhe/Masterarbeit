close all;
clear all;clc;
% posetrack dataset
% part id table
part_name = {'r ankle', 'r knee', 'r hip', 'l hip', 'l knee', 'l ankle','r wrist', 'r elbow', 'r shoulder', 'l shoulder', 'l elbow', 'l wrist', 'Head-bottom', 'Nose', 'Head-top'};
%labels_type='val_with_box';
labels_type='train_with_box';
% load image
Root_Dir = '/home/zouyunzhe/JointTracking/tmp/posetrack/posetrack_data/';

% load joint positions
Annotation_Path = '/home/zouyunzhe/JointTracking/tmp/posetrack/posetrack_data/annotations/';
Annotation_Path = fullfile(Annotation_Path,labels_type);
Annotation_files = dir(fullfile(Annotation_Path,'*.mat'));

aug_number = 8; % the number of boxes


for Annotation_index = 135 : size(Annotation_files,1)

    Annotation_dir = fullfile(Annotation_Path,Annotation_files(Annotation_index).name);
    Annotation = load(Annotation_dir);

    for Img_Index = 1:size(Annotation.annolist,2)
        Img_Path = fullfile(Root_Dir,Annotation.annolist(Img_Index).image.name);
        if ~Annotation.annolist(Img_Index).is_labeled||exist(Img_Path)==0
            continue;
        end
        
        num_rec=length(Annotation.annolist(Img_Index).bounding_box);

        % box
        box_var = zeros(num_rec,4)-1;

        % show image
        I = imread(Img_Path);
        for j = 1:num_rec     
            if isempty(Annotation.annolist(Img_Index).bounding_box(j).x1)||...
                    abs(Annotation.annolist(Img_Index).bounding_box(j).x1/10000)>1||...
                    abs(Annotation.annolist(Img_Index).bounding_box(j).y1/10000)>1
                continue;
            end
            p_top_left_x = max(1,Annotation.annolist(Img_Index).bounding_box(j).x1);
            p_top_left_y = max(1,Annotation.annolist(Img_Index).bounding_box(j).y1);
            if size(I,2)<=p_top_left_x || size(I,1)<=p_top_left_y 
                continue;
            end
            rec_width = min(Annotation.annolist(Img_Index).bounding_box(j).rec_width,size(I,2)-p_top_left_x);
            rec_height = min(Annotation.annolist(Img_Index).bounding_box(j).rec_height,size(I,1)-p_top_left_y);
            
            % bouding box augmentation
            enlarge_box_augmentation = 0.15;
            x_aug_min = max(1,p_top_left_x - enlarge_box_augmentation*0.5*rec_width);
            y_aug_min = max(1,p_top_left_y - enlarge_box_augmentation*0.5*rec_height);
            x_aug_max = min(size(I,2),p_top_left_x + (1+enlarge_box_augmentation*0.5)*rec_width);
            y_aug_max = min(size(I,1),p_top_left_y + (1+enlarge_box_augmentation*0.5)*rec_height);
%             rectangle('Position',[x_aug_min y_aug_min x_aug_max-x_aug_min y_aug_max-y_aug_min],'LineWidth', 4,'EdgeColor','b'); 

            n_aug_box = 0;

            aug_box = zeros(aug_number,4) ;
            thres_iou = 0.7; % threshold
            box2 = [p_top_left_x,p_top_left_y,p_top_left_x+rec_width,p_top_left_y+rec_height]; % the existing box
%             box2 = [max(1,p_top_left_x),max(1,p_top_left_y),...
%                     max(1,p_top_left_x)+min(rec_width,size(I,2)-p_top_left_x),...
%                     max(1,p_top_left_y)+min(rec_height,size(I,1)-p_top_left_y)]; % the existing box
            while(n_aug_box<aug_number)
                p_aug_x = x_aug_min + (x_aug_max-x_aug_min).*rand(1) ;
                p_aug_y = y_aug_min + (y_aug_max-y_aug_min).*rand(1) ;
                p_aug_width = (x_aug_max-x_aug_min).*rand(1) ;
                p_aug_height = (y_aug_max-y_aug_min).*rand(1) ;
                % compute IOU
                box1 = [p_aug_x,p_aug_y,...
                    min(p_aug_x+p_aug_width,x_aug_max),min(p_aug_y+p_aug_height,y_aug_max)];
                if compute_IOU(box1,box2)>=thres_iou
                    n_aug_box = n_aug_box +1;
                    aug_box(n_aug_box ,:) = box1;
                end 
            end
    %         % symmetric boxes
    %         hor_axel = (x_aug_min + x_aug_max);
    %         ver_axel = (y_aug_min + y_aug_max);
    %         % symmetric 1
    %         box_xtmp = [hor_axel - aug_box(1:aug_number,1) hor_axel - aug_box(1:aug_number,3)]; 
    %         box_xtmp = sort(box_xtmp,2);
    %         aug_box(aug_number+1:2*aug_number,1) =  box_xtmp (:,1);
    %         aug_box(aug_number+1:2*aug_number,2) =  aug_box (1:aug_number,2);
    %         aug_box(aug_number+1:2*aug_number,3) =  box_xtmp (:,2);
    %         aug_box(aug_number+1:2*aug_number,4) =  aug_box (1:aug_number,4);
    %         
    %         % symmetric 2
    %         
    %         % symmetric 3
            Annotation.annolist(Img_Index).bounding_box(j).x1 = box2(1);
            Annotation.annolist(Img_Index).bounding_box(j).y1 = box2(2);
            Annotation.annolist(Img_Index).bounding_box(j).rec_width = box2(3)-box2(1);
            Annotation.annolist(Img_Index).bounding_box(j).rec_height = box2(4)-box2(2);
            Annotation.annolist(Img_Index).bounding_box(j).track_id = Annotation.annolist(Img_Index).annorect(j).track_id;
            for it = 1: aug_number
                Annotation.annolist(Img_Index).bounding_box(j).bounding_box_augmentation(it).x1 = aug_box(it,1);  
                Annotation.annolist(Img_Index).bounding_box(j).bounding_box_augmentation(it).y1 = aug_box(it,2);  
                Annotation.annolist(Img_Index).bounding_box(j).bounding_box_augmentation(it).rec_width = aug_box(it,3)-aug_box(it,1);  
                Annotation.annolist(Img_Index).bounding_box(j).bounding_box_augmentation(it).rec_height = aug_box(it,4)-aug_box(it,2);  
            end
        end
    end
    annolist = Annotation.annolist;
    % save to local
    %save_path = fullfile('/home/zouyunzhe/JointTracking/tmp/posetrack/posetrack_data/annotations/val_with_box_augmentation',Annotation_files(Annotation_index).name);
    save_path = fullfile('/home/zouyunzhe/JointTracking/tmp/posetrack/posetrack_data/annotations/train_with_box_augmentation',Annotation_files(Annotation_index).name);
    save(save_path ,'annolist');
    clear annolist;
end

