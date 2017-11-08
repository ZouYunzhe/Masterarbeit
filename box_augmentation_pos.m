function M_aug=box_augmentation_pos(bbox,enlarge_box_augmentation,aug_number_pos,thres_iou_pos,if_multi_core)
% inputs: bbox: original bounding box, 1*9 vector
%         enlarge_box_augmentation: the enlarge ratio
%         aug_number_pos: the number of the augmented boxes (positive)
%         thres_iou_pos: threshold of the IOU
%         aug_number_fpos: the number of the augmented boxes (false positive)
%         aug_number_fpos: threshold of the IOU (false postitive)
%         if_multi_core: indicates weather to use multi core to accelerate
% outputs: M_aug: the matrix of the augmented boxes. (n_aug_box_pos+n_aug_box_fpos)+*9
% For positive samples, first enlarge the bounding box, then random set a
% bouding box in this region. The boxes which can reach the wanted IOU are
% saved.
% For false positive samples, directly translate the bouding box to achieve
% the willing IOU.
% This function only augments the boxes. It doesn't check if the box has an
% intersection with the image. This will be done while making pairs.
    p_top_left_x = bbox(3);
    p_top_left_y = bbox(4);
    rec_width = bbox(5);
    rec_height = bbox(6);
    % the considered region
%     x_aug_min = max(1,p_top_left_x - enlarge_box_augmentation*0.5*rec_width);
%     y_aug_min = max(1,p_top_left_y - enlarge_box_augmentation*0.5*rec_height);
%     x_aug_max = min(img_size(2),p_top_left_x + (1+enlarge_box_augmentation*0.5)*rec_width);
%     y_aug_max = min(img_size(1),p_top_left_y + (1+enlarge_box_augmentation*0.5)*rec_height);

    x_aug_min = p_top_left_x - enlarge_box_augmentation*0.5*rec_width;
    y_aug_min = p_top_left_y - enlarge_box_augmentation*0.5*rec_height;
    x_aug_max = p_top_left_x + (1+enlarge_box_augmentation*0.5)*rec_width;
    y_aug_max = p_top_left_y + (1+enlarge_box_augmentation*0.5)*rec_height;
    
    n_aug_box = 0;
    M_aug = repmat(bbox,aug_number_pos,1);
    M_aug(:,3:6)=0;
    box2 = [p_top_left_x,p_top_left_y,p_top_left_x+rec_width,p_top_left_y+rec_height]; % the existing box

    while(n_aug_box<aug_number_pos)
        p_aug_x = x_aug_min + (x_aug_max-x_aug_min).*rand(1) ;
        p_aug_y = y_aug_min + (y_aug_max-y_aug_min).*rand(1) ;
        p_aug_width = (x_aug_max-x_aug_min).*rand(1) ;
        p_aug_height = (y_aug_max-y_aug_min).*rand(1) ;
        % compute IOU
        box1 = [p_aug_x,p_aug_y,...
            min(p_aug_x+p_aug_width,x_aug_max),min(p_aug_y+p_aug_height,y_aug_max)];
        if compute_IOU(box1,box2)>=thres_iou_pos
            n_aug_box = n_aug_box +1;
            M_aug(n_aug_box ,3:6) = [box1(1:2),box1(3)-box1(1),box1(4)-box1(2)];
        end 
    end
    
    if if_multi_core==1
        % reshape in 1*9*n for the use of parfor
        M_aug_tmp=M_aug;
        M_aug=zeros(1,9*aug_number_pos);
        for k = 0:aug_number_pos-1
            M_aug(k*9+1:(k+1)*9)=M_aug_tmp(k+1,:);
        end
    end
end