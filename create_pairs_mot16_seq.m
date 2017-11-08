function box_pairs = create_pairs_mot16_seq(frame_pair,groundtruth,num_box_pair_total,pos_ratio,fpos_ratio,img_size)
% outputs: 
%   pairs: the box pairs with size of num_box_pair_max*11
%             (x1,y1,w1,h1,t1,x2,y2,w2,h2,t2,label)
    if frame_pair(1)~=frame_pair(2)
        num_pos_pairs = round(num_box_pair_total*pos_ratio);
%         num_fpos_pairs = round(num_box_pair_total*fpos_ratio);
%         num_neg_pairs = num_box_pair_total-num_pos_pairs-num_fpos_pairs;
        boxes_frame1_logic=groundtruth(:,1)==frame_pair(1);
        boxes_frame2_logic=groundtruth(:,1)==frame_pair(2);
        boxes_frame1 = groundtruth(boxes_frame1_logic,:);
        boxes_frame2 = groundtruth(boxes_frame2_logic,:);
               
        % create pos pairs
        obj_list_frame1= boxes_frame1(boxes_frame1(:,7)==1&boxes_frame1(:,8)~=-1,:);
        obj_list_frame2= boxes_frame2(boxes_frame2(:,7)==1&boxes_frame2(:,8)~=-1,:);
        if num_pos_pairs >0
            pos_pairs=select_pairs(obj_list_frame1, obj_list_frame2, num_pos_pairs, 1,img_size );
        else
            pos_pairs=[];
        end
        % create neg pairs
        num_pos_pairs = min(size(pos_pairs,1),num_pos_pairs);
        num_neg_pairs = round(num_pos_pairs*(1-pos_ratio-fpos_ratio)/pos_ratio);
        if num_neg_pairs >0
            neg_pairs=select_pairs(obj_list_frame1, obj_list_frame2, num_neg_pairs,0,img_size);
        else
            neg_pairs=[];
        end
        % create fpos pairs
        num_fpos_pairs = round(num_pos_pairs*fpos_ratio/pos_ratio);
        obj_list_frame2_fpos= boxes_frame2(boxes_frame2(:,7)==1&boxes_frame2(:,8)==-1,:);
        if num_fpos_pairs >0
            fpos_pairs=select_pairs(obj_list_frame1, obj_list_frame2_fpos, num_fpos_pairs ,-1,img_size);
        else
            fpos_pairs=[];
        end
        box_pairs = [pos_pairs;fpos_pairs;neg_pairs];
    end
end
function pairs=select_pairs(obj_list_frame1, obj_list_frame2, num, tpye_of_pair,img_size )
    t1=obj_list_frame1(1,1); % frame number
    t2=obj_list_frame2(1,1); % frame number
    [id1,id2]=meshgrid(obj_list_frame1(:,2),obj_list_frame2(:,2));
    pair_ids_tmp=id1-id2;
    if tpye_of_pair==1 % pos
        [idx_frame2,idx_frame1] = find(pair_ids_tmp==0);
    elseif tpye_of_pair==-1 % false positive
        [idx_frame2,idx_frame1] = find(pair_ids_tmp==0);
    else % negative
        [idx_frame2,idx_frame1] = find(pair_ids_tmp~=0);
    end        
    box1 = obj_list_frame1(idx_frame1,:);
    box2 = obj_list_frame2(idx_frame2,:);
    % random select n valid pairs
    pairs=zeros(num,11);
    num_selected=0;
    iteration = 1;
    candidates=randperm(length(idx_frame1));
    while num_selected<num
        if iteration<length(candidates)
            tmp_position=candidates(iteration);
        else
            pairs(num_selected+1:end,:)=[];
            break;
        end
        box1_selected=box1(tmp_position,:);
        box2_selected=box2(tmp_position,:);
        % verify box (must have intersection with image)   
        if 1<box1_selected(3)&&box1_selected(3)<img_size(2)...
           &&1<box2_selected(3)&&box2_selected(3)<img_size(2)...
           &&1<box1_selected(4)&&box1_selected(4)<img_size(1)...
           &&1<box2_selected(4)&&box2_selected(4)<img_size(1)
           num_selected=num_selected+1;
           pairs(num_selected,1:4)=box1_selected(3:6);
           pairs(num_selected,5)=t1;
           pairs(num_selected,6:9)=box2_selected(3:6);
           pairs(num_selected,10)=t2;
           if tpye_of_pair==1
                pairs(num_selected,11)=1;
           else
                pairs(num_selected,11)=0;
           end
        end
        iteration=iteration+1;
    end


end