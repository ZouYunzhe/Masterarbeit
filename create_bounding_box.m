close all;
clearvars all;clc;
% posetrack dataset
% part id table
part_name = {'r ankle', 'r knee', 'r hip', 'l hip', 'l knee', 'l ankle','r wrist', 'r elbow', 'r shoulder', 'l shoulder', 'l elbow', 'l wrist', 'Head-bottom', 'Nose', 'Head-top'};
% labels_type='val';
labels_type='train';
% load image
Root_Dir = '/home/zouyunzhe/JointTracking/tmp/posetrack/posetrack_data/';

% load joint positions
Annotation_Path = '/home/zouyunzhe/JointTracking/tmp/posetrack/posetrack_data/annotations/';
Annotation_Path = fullfile(Annotation_Path,labels_type);
Annotation_files = dir(fullfile(Annotation_Path,'*.mat'));

for Annotation_index = 1 : size(Annotation_files,1)

    Annotation_dir = fullfile(Annotation_Path,Annotation_files(Annotation_index).name);
    Annotation = load(Annotation_dir);

    for Img_Index = 1:size(Annotation.annolist,2)
        if ~Annotation.annolist(Img_Index).is_labeled
            continue;
        end
        Img_Path = fullfile(Root_Dir,Annotation.annolist(Img_Index).image.name);
        num_rec=length(Annotation.annolist(Img_Index).annorect);

        % box
        box_var = zeros(num_rec,4)-1;

        % show image
    %     I = imread(Img_Path);
    %     figure();
    %     imshow(I);
        % show parts
    %     hold on
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
    %         rectangle('Position',[ x1 y1 abs(x1-x2) abs(y1-y2) ]);
    %         for i = 1:num_parts
    %             x = Annotation.annolist(Img_Index).annorect(j).annopoints.point(i).x;
    %             y = Annotation.annolist(Img_Index).annorect(j).annopoints.point(i).y;
    %             id = Annotation.annolist(Img_Index).annorect(j).annopoints.point(i).id;
    %             plot(x,y,['o','r'],'MarkerSize',4);
    %             text(x,y,cell2mat(part_name(id+1)),'Color','r','HorizontalAlignment','right');
    %         end
            box_var(j,1) = max([Annotation.annolist(Img_Index).annorect(j).annopoints.point.x,x1,x2]);
            box_var(j,2) = min([Annotation.annolist(Img_Index).annorect(j).annopoints.point.x,x1,x2]);
            box_var(j,3) = max([Annotation.annolist(Img_Index).annorect(j).annopoints.point.y,y1,y2]);
            box_var(j,4) = min([Annotation.annolist(Img_Index).annorect(j).annopoints.point.y,y1,y2]);

            % create bouding box
            enlarge = 1.15;

    %         if box_var(j,2) == min(x1,x2)
    %             p_top_left_x = box_var(j,2);
    %             if box_var(j,1) == max(x1,x2)
    %                 rec_width = abs(box_var(j,2)-box_var(j,1));
    %             else
    %                 rec_width = abs(box_var(j,2)-box_var(j,1))*(1+(enlarge-1)*0.5);
    %             end
    %         else
    %             p_top_left_x = box_var(j,2)-abs(box_var(j,2)-box_var(j,1))*0.5*(enlarge-1);
    %             if box_var(j,1) == max(x1,x2)
    %                 rec_width = abs(box_var(j,2)-box_var(j,1))*(1+(enlarge-1)*0.5);                
    %             else
    %                 rec_width = abs(box_var(j,2)-box_var(j,1))*enlarge;
    %             end
    %         end        
    %         if box_var(j,4) == min(y1,y2)
    %             p_top_left_y = box_var(j,4);
    %             if box_var(j,3) == max(y1,y2)
    %                 rec_height = abs(box_var(j,4)-box_var(j,3));
    %             else
    %                 rec_height = abs(box_var(j,4)-box_var(j,3))*(1+(enlarge-1)*0.5);
    %             end
    %         else
    %             p_top_left_y = box_var(j,4)-abs(box_var(j,4)-box_var(j,3))*0.5*(enlarge-1);
    %             if box_var(j,3) == max(y1,y2)
    %                 rec_height = abs(box_var(j,4)-box_var(j,3))*(1+(enlarge-1)*0.5);                
    %             else
    %                 rec_height = abs(box_var(j,4)-box_var(j,3))*enlarge;
    %             end
    %         end
    %         rectangle('Position',[p_top_left_x p_top_left_y rec_width rec_height],'LineWidth', 4,'EdgeColor','r');

            rec_width = abs(box_var(j,2)-box_var(j,1))*enlarge;
            rec_height = abs(box_var(j,4)-box_var(j,3))*enlarge;
            delta_x = abs(box_var(j,2)-box_var(j,1))*0.5*(enlarge-1);
            delta_y = abs(box_var(j,4)-box_var(j,3))*0.5*(enlarge-1);
            p_top_left_x = box_var(j,2)-delta_x;
            p_top_left_y = box_var(j,4)-delta_y;
    %         rectangle('Position',[p_top_left_x p_top_left_y rec_width rec_height],'LineWidth', 4,'EdgeColor','r');

            % save the bounding box
            Annotation.annolist(Img_Index).bounding_box(j).x1 = p_top_left_x;
            Annotation.annolist(Img_Index).bounding_box(j).y1 = p_top_left_y;
            Annotation.annolist(Img_Index).bounding_box(j).rec_width = rec_width;
            Annotation.annolist(Img_Index).bounding_box(j).rec_height = rec_height;  
            Annotation.annolist(Img_Index).bounding_box(j).enlarge = enlarge;  
        end
    %     hold off
    end
    annolist = Annotation.annolist;
    % save to local
    %save_path = fullfile('/home/zouyunzhe/JointTracking/tmp/posetrack/posetrack_data/annotations/val_with_box',Annotation_files(Annotation_index).name);
    save_path = fullfile('/home/zouyunzhe/JointTracking/tmp/posetrack/posetrack_data/annotations/train_with_box',Annotation_files(Annotation_index).name);
    save(save_path ,'annolist');
end