close all;
clear all;clc;
% posetrack dataset
% part id table
part_name = {'r ankle', 'r knee', 'r hip', 'l hip', 'l knee', 'l ankle','r wrist', 'r elbow', 'r shoulder', 'l shoulder', 'l elbow', 'l wrist', 'Head-bottom', 'Nose', 'Head-top'};
labels_type='val_with_box';
%labels_type='train_with_box';
% load image
Root_Dir = '/home/zouyunzhe/JointTracking/tmp/posetrack/posetrack_data/';

% load joint positions
Annotation_Path = '/home/zouyunzhe/JointTracking/tmp/posetrack/posetrack_data/annotations/';
Annotation_Path = fullfile(Annotation_Path,labels_type);
Annotation_files = dir(fullfile(Annotation_Path,'*.mat'));

Annotation_index = 10;

Annotation_dir = fullfile(Annotation_Path,Annotation_files(Annotation_index).name);
Annotation = load(Annotation_dir);

for Img_Index = 1:1 %size(Annotation.annolist,2)
    if ~Annotation.annolist(Img_Index).is_labeled
        continue;
    end
    Img_Path = fullfile(Root_Dir,Annotation.annolist(Img_Index).image.name);
    num_rec=length(Annotation.annolist(Img_Index).annorect);

    % box
    box_var = zeros(num_rec,4)-1;

    % show image
    I = imread(Img_Path);
    figure();
    imshow(I);
    % show parts
    hold on
    for j = 1:num_rec
        if isempty(Annotation.annolist(Img_Index).annorect(j).annopoints)
%             disp('non-existent field "annopoints"');
            continue;
        end
        num_parts=size(Annotation.annolist(Img_Index).annorect(j).annopoints.point,2);
        % eck points of the head detection
        x1 = Annotation.annolist(Img_Index).annorect(j).x1;
        x2 = Annotation.annolist(Img_Index).annorect(j).x2;
        y1 = Annotation.annolist(Img_Index).annorect(j).y1;
        y2 = Annotation.annolist(Img_Index).annorect(j).y2;
        rectangle('Position',[ x1 y1 abs(x1-x2) abs(y1-y2) ]);
        for i = 1:num_parts
            x = Annotation.annolist(Img_Index).annorect(j).annopoints.point(i).x;
            y = Annotation.annolist(Img_Index).annorect(j).annopoints.point(i).y;
            id = Annotation.annolist(Img_Index).annorect(j).annopoints.point(i).id;
            plot(x,y,['o','r'],'MarkerSize',4);
            text(x,y,cell2mat(part_name(id+1)),'Color','r','HorizontalAlignment','right');
        end
        rec_width = Annotation.annolist(Img_Index).bounding_box(j).rec_width;
        rec_height = Annotation.annolist(Img_Index).bounding_box(j).rec_height;
        p_top_left_x = Annotation.annolist(Img_Index).bounding_box(j).x1;
        p_top_left_y = Annotation.annolist(Img_Index).bounding_box(j).y1;
        rectangle('Position',[p_top_left_x p_top_left_y rec_width rec_height],'LineWidth', 4,'EdgeColor','r'); 
        pause(0.5)
        
        % bouding box augmentation
        enlarge_box_augmentation = 0.2;
        x_aug_min = max(1,p_top_left_x - enlarge_box_augmentation*0.5*rec_width);
        y_aug_min = max(1,p_top_left_y - enlarge_box_augmentation*0.5*rec_height);
        x_aug_max = min(size(I,2),p_top_left_x + (1+enlarge_box_augmentation*0.5)*rec_width);
        y_aug_max = min(size(I,1),p_top_left_y + (1+enlarge_box_augmentation*0.5)*rec_height);
        rectangle('Position',[x_aug_min y_aug_min x_aug_max-x_aug_min y_aug_max-y_aug_min],'LineWidth', 4,'EdgeColor','b'); 
        
        n_aug_box = 0;
        aug_number = 3; % the number of boxes
        aug_box = zeros(aug_number,4) ;
        thres_iou = 0.7; % threshold
        box2 = [max(1,p_top_left_x),max(1,p_top_left_y),...
                max(1,p_top_left_x)+min(rec_width,size(I,2)-p_top_left_x),...
                max(1,p_top_left_y)+min(rec_height,size(I,1)-p_top_left_y)]; % the existing box
        while(n_aug_box<aug_number)
            p_aug_x = x_aug_min + 0.5*(x_aug_max-x_aug_min).*rand(1) ;
            p_aug_y = y_aug_min + 0.5*(y_aug_max-y_aug_min).*rand(1) ;
            p_aug_width = (x_aug_max-x_aug_min).*rand(1) ;
            p_aug_height = (y_aug_max-y_aug_min).*rand(1) ;
%             rectangle('Position',[p_aug_x p_aug_y ...
%                 min(p_aug_width,x_aug_max-p_aug_x) min(p_aug_height,y_aug_max-p_aug_y)],'LineWidth', 4,'EdgeColor','g'); 
            % compute IOU
            box1 = [p_aug_x,p_aug_y,...
                min(p_aug_x+p_aug_width,x_aug_max),min(p_aug_y+p_aug_height,y_aug_max)];
            if compute_IOU(box1,box2)>=thres_iou
                n_aug_box = n_aug_box +1;
                aug_box(n_aug_box ,:) = box1;
            end 
        end
        for it = 1: aug_number
             rectangle('Position',[aug_box(it,1) aug_box(it,2) ...
                    aug_box(it,3)-aug_box(it,1) aug_box(it,4)-aug_box(it,2)],'LineWidth', 4,'EdgeColor','g'); 
        end
    end
    hold off
end

