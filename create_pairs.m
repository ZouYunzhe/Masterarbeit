function pairs_batch=create_pairs(pairs_number_all,pairs_type,seq_list,pos_ratio,delta_frame,varargin)
% To create pairs in the sequence according to the pairs_type
% inputs: 
% pairs_number_iter:
%     the number of pairs to be created 
% pairs_type:
% the variable pair_type has the following values:
% 1) box to box
% 2) joint to box
% 3) joint to joint
% seq_list:
%     the notation listfor the sequence
% pos_ratio:
%     the ratio of the positive example
% delta_frame:
%     the frame number difference between the objects
% varargin:
%     the type of the joint. for joint to box 1*1; for joint to joint 1*2
% output:
%     pairs_batch (n*5 matrix)
%         -(collum 1)index_obj1: the index of the first object
%         -(collum 2)index_obj2: the index of the second object
%         -(collum 3)type_obj1: the type of the first object, 1 for box, 0
%         for joint
%         -(collum 4)type_obj2: the type of the second object,1 for box, 0 
%         for joint         
%         -(collum 5)is_same_id: 1 for the same id, 0 for the different
switch (pairs_type)
    case 1
        %% box to box
        labled_frame_numbers=unique([seq_list.box_list.frame_idx]);
        delta_frame_max=labled_frame_numbers(end)-labled_frame_numbers(1);
        if delta_frame>delta_frame_max
            disp('Error. Delta frame is too large.');
        else
            if delta_frame==0
                % in the same frame
                max_it=length(labled_frame_numbers);
                pair_batch_allparts = init_pair_batch_allparts(max_it);
                pairs_number_iter = ceil(pairs_number_all/max_it);
                frame_idx_tmp =[seq_list.box_list.frame_idx];
                track_id_tmp =[seq_list.box_list.track_id];
                for it = 1:max_it
                    frame_idx = labled_frame_numbers(it);
                    box_idx_tmp=1:length(frame_idx_tmp);
                    boxes_idx_frame_logical = frame_idx_tmp==frame_idx; % logical index
                    track_id_frame = track_id_tmp(boxes_idx_frame_logical); % track_id of the current frame
                    boxes_idx_frame = box_idx_tmp(boxes_idx_frame_logical); % integer numbers
                    num_boxes = length(track_id_frame);
                    same_track_id_mat=~xor(repmat(track_id_frame,num_boxes,1),repmat(track_id_frame',1,num_boxes));
                    [box_idx1,box_idx2]=meshgrid(1:num_boxes,1:num_boxes);                    
                    box_idx1=box_idx1(:);
                    box_idx2=box_idx2(:);
                    pairs=[box_idx1,box_idx2];
                    same_track_id_mat=same_track_id_mat(:);
                    same_track_id_mat=same_track_id_mat((pairs(:,1)<pairs(:,2)));
                    pairs=pairs((pairs(:,1)<pairs(:,2)),:);
                    pos_pairs_frame_idx=find(same_track_id_mat==1);
                    neg_pairs_frame_idx=find(same_track_id_mat==0);
                    % get the positive and negative samples
                    k = round(pairs_number_iter*pos_ratio); % number of positive 
                    k_ = pairs_number_iter-k; % number of negative 
                    p_pos = randperm(length(pos_pairs_frame_idx));
                    p_pos = p_pos(1:k); 
                    p_neg = randperm(length(neg_pairs_frame_idx));
                    p_neg = p_neg(1:k_); 
                    pairs_batch_part = zeros(pairs_number_iter,5)-1;
                    pairs_pos_tmp=[boxes_idx_frame(pairs(pos_pairs_frame_idx(p_pos),1));boxes_idx_frame(pairs(pos_pairs_frame_idx(p_pos),2))]';
                    pairs_pos_tmp(:,3:5)=1;
                    pairs_neg_tmp=[boxes_idx_frame(pairs(neg_pairs_frame_idx(p_neg),1));boxes_idx_frame(pairs(neg_pairs_frame_idx(p_neg),2))]';
                    pairs_neg_tmp(:,3:4)=1;
                    pairs_neg_tmp(:,5)=0;
                    pairs_batch_part(1:size(pairs_pos_tmp,1),:)=pairs_pos_tmp;
                    pairs_batch_part(size(pairs_pos_tmp,1)+1:end,:)=pairs_neg_tmp;
                    pair_batch_allparts(it).pairs_batch_part=pairs_batch_part;    
                end
                pairs_batch= concat_pair_batch_parts(pair_batch_allparts,pairs_number_iter,pairs_number_all,pos_ratio);
            else
                % in different frames
                max_it=labled_frame_numbers(end)-delta_frame-labled_frame_numbers(1)+1;
                pair_batch_allparts = init_pair_batch_allparts(max_it);
                pairs_number_iter = ceil(pairs_number_all/max_it);
                frame_idx_tmp =[seq_list.box_list.frame_idx];
                track_id_tmp =[seq_list.box_list.track_id];
                for it =1:max_it
                   frame1_idx = labled_frame_numbers(it);
                   frame2_idx = labled_frame_numbers(it)+delta_frame;                 
                   box_idx_tmp=1:length(frame_idx_tmp);
                   boxes_idx_frame1_logical = frame_idx_tmp==frame1_idx; % logical numbers 
                   boxes_idx_frame2_logical = frame_idx_tmp==frame2_idx; % logical numbers 
                   track_id_frame1 = track_id_tmp(boxes_idx_frame1_logical);
                   track_id_frame2 = track_id_tmp(boxes_idx_frame2_logical)';
                   boxes_idx_frame1 = box_idx_tmp(boxes_idx_frame1_logical); % integer numbers 
                   boxes_idx_frame2 = box_idx_tmp(boxes_idx_frame2_logical); % integer numbers 
                   num_frame1 = length(track_id_frame1 );
                   num_frame2 = length(track_id_frame2 );
                   same_track_id_mat=~xor(repmat(track_id_frame1,num_frame2,1),repmat(track_id_frame2,1,num_frame1));
                   [pos_pairs_frame2_idx,pos_pairs_frame1_idx] = find(same_track_id_mat == 1);
                   [neg_pairs_frame2_idx,neg_pairs_frame1_idx] = find(same_track_id_mat == 0);
                   % pick k positive samples from all
                   k = round(pairs_number_iter*pos_ratio); % number of positive 
                   k_ = pairs_number_iter-k; % number of negative 
                   p_pos = randperm(length(pos_pairs_frame2_idx));
                   p_pos = p_pos(1:k); 
                   p_neg = randperm(length(neg_pairs_frame2_idx));
                   p_neg = p_neg(1:k_); 
                   pairs_batch_part = zeros(pairs_number_iter,5)-1;
 
                   pairs_pos_tmp=[boxes_idx_frame1(pos_pairs_frame1_idx(p_pos));boxes_idx_frame2(pos_pairs_frame2_idx(p_pos))]';
                   pairs_pos_tmp(:,3:5)=1;
                   pairs_neg_tmp=[boxes_idx_frame1(neg_pairs_frame1_idx(p_neg));boxes_idx_frame2(neg_pairs_frame2_idx(p_neg))]';
                   pairs_neg_tmp(:,3:4)=1;
                   pairs_neg_tmp(:,5)=0;
                   pairs_batch_part(1:size(pairs_pos_tmp,1),:)=pairs_pos_tmp;
                   pairs_batch_part(size(pairs_pos_tmp,1)+1:end,:)=pairs_neg_tmp;
                   pair_batch_allparts(it).pairs_batch_part=pairs_batch_part;                  
                end
                pairs_batch= concat_pair_batch_parts(pair_batch_allparts,pairs_number_iter,pairs_number_all,pos_ratio);
            end
        end
    case 2 
        %% joint to box
        type_of_joint = cell2mat(varargin);
        cur_joint_type=type_of_joint(1);
        joint_type_list=[seq_list.joint_list.joints.joint_type];
        cur_joint_logical_idx=joint_type_list==cur_joint_type; % logical index
        joint_frames=[seq_list.joint_list.joints.frame_idx];       
        joint_idx=find(cur_joint_logical_idx==1);
        joint_frames=joint_frames(cur_joint_logical_idx);
        joint_frames_unique=unique(joint_frames);
        labled_box_frame=unique([seq_list.box_list.frame_idx]);
        pairs_batch = zeros(pairs_number_all,5)-1;
        pairs_batch(:,3)=0;
        pairs_batch(:,4)=1;
        k = round(pairs_number_all*pos_ratio); % number of positive 
        k_ = pairs_number_all-k; % number of negative 
        pairs_all=[];
        for it = 1:length(joint_frames_unique)
            if sum(labled_box_frame==joint_frames_unique(it)+delta_frame)>0
                % box available
                cur_joint_frame_id=joint_frames_unique(it);
                cur_box_frame_id=joint_frames_unique(it)+delta_frame;
                cur_joint_logical_idx=joint_frames==cur_joint_frame_id;
                cur_joint_idx=joint_idx(cur_joint_logical_idx);
                cur_box_logical_idx=[seq_list.box_list.frame_idx]==cur_box_frame_id;
                cur_box_idx=find(cur_box_logical_idx);
                tmp=[seq_list.joint_list.joints.track_id];
                cur_joint_track_id=tmp(cur_joint_logical_idx);
                clear tmp;
                tmp = [seq_list.box_list.track_id];
                cur_box_track_id=tmp(cur_box_logical_idx);
                same_track_id_mat=~xor(repmat(cur_box_track_id,length(cur_joint_track_id),1),repmat(cur_joint_track_id',1,length(cur_box_track_id)));
                pairs_part=zeros(numel(same_track_id_mat),3)-1;
                col1=repmat(cur_joint_idx,length(cur_box_track_id),1);
                col1=col1(:);
                col2=repmat(cur_box_idx',length(cur_joint_track_id),1)';
                col3=same_track_id_mat';
                col3=col3(:);
                pairs_part(:,1)=col1;
                pairs_part(:,2)=col2;
                pairs_part(:,3)=col3; 
            end
            pairs_all=cat(1,pairs_all,pairs_part);            
        end        
        % randomly select pairs
        pos_poistions=find(pairs_all(:,3)==1);
        pos_poistions_selected=pos_poistions(randperm(length(pos_poistions)));
        if k>length(pos_poistions_selected)
            % not enough positive samples
            k=pos_poistions_selected;
            k_=round(k/pos_ratio*(1-pos_ratio));                
        end
        pos_poistions_selected=pos_poistions_selected(1:k);
        pairs_batch(1:k,1:2)=pairs_all(pos_poistions_selected,1:2);
        pairs_batch(1:k,5)=pairs_all(pos_poistions_selected,3);
        neg_poistions=find(pairs_all(:,3)==0);
        neg_poistions_selected=neg_poistions(randperm(length(neg_poistions)));
        neg_poistions_selected=neg_poistions_selected(1:k_);
        pairs_batch(k+1:k+k_,1:2)=pairs_all(neg_poistions_selected,1:2);
        pairs_batch(k+1:k+k_,5)=pairs_all(neg_poistions_selected,3); 
        % delete the empty 
        if sum(pairs_batch(:,5)==-1)>0
            pairs_batch((pairs_batch(:,5)==-1),:)=[];
        end
        % shuffle batch
        pairs_batch = pairs_batch(randperm(size(pairs_batch,1)),:);
    case 3
        %% joint to joint
        type_of_joint = cell2mat(varargin);
        type_of_joint1 = type_of_joint(1);
        type_of_joint2 = type_of_joint(2);
        if delta_frame==0&&(type_of_joint1==type_of_joint2)
            % same frame and same type
        else
            joint_type_list=[seq_list.joint_list.joints.joint_type];
            joint_frames=[seq_list.joint_list.joints.frame_idx];         
            joint1_logical_idx=joint_type_list==type_of_joint1; % logical index for joint 1
            joint2_logical_idx=joint_type_list==type_of_joint2; % logical index for joint 2            
            joint1_idx=find(joint1_logical_idx==1);
            joint2_idx=find(joint2_logical_idx==1);
            joint1_frames=joint_frames(joint1_logical_idx);
            joint2_frames=joint_frames(joint2_logical_idx);
            joint1_frames_unique=unique(joint1_frames);
            joint2_frames_unique=unique(joint2_frames);
            pairs_batch = zeros(pairs_number_all,5)-1;
            pairs_batch(:,3)=0;
            pairs_batch(:,4)=0;
            k = round(pairs_number_all*pos_ratio); % number of positive 
            k_ = pairs_number_all-k; % number of negative 
            pairs_all=[];
            for it = 1:length(joint1_frames_unique)
                if sum(joint2_frames_unique==joint1_frames_unique(it)+delta_frame)>0
                    % joint type 2 available
                    cur_joint1_frame_id=joint1_frames_unique(it);
                    cur_joint2_frame_id=joint1_frames_unique(it)+delta_frame;
                    cur_joint1_logical_idx=joint1_frames==cur_joint1_frame_id;
                    cur_joint2_logical_idx=joint2_frames==cur_joint2_frame_id;
                    cur_joint1_idx=joint1_idx(cur_joint1_logical_idx);
                    cur_joint2_idx=joint2_idx(cur_joint2_logical_idx);
                    tmp=[seq_list.joint_list.joints.track_id];
                    cur_joint1_track_id=tmp(cur_joint1_logical_idx);
                    cur_joint2_track_id=tmp(cur_joint2_logical_idx);
                    same_track_id_mat=~xor(repmat(cur_joint2_track_id,length(cur_joint1_track_id),1),repmat(cur_joint1_track_id',1,length(cur_joint2_track_id)));
                    pairs_part=zeros(numel(same_track_id_mat),3)-1;
                    col1=repmat(cur_joint1_idx,length(cur_joint2_idx),1);
                    col1=col1(:);
                    col2=repmat(cur_joint2_idx',length(cur_joint1_idx),1)';
                    col3=same_track_id_mat';
                    col3=col3(:);
                    pairs_part(:,1)=col1;
                    pairs_part(:,2)=col2;
                    pairs_part(:,3)=col3; 
                end
                pairs_all=cat(1,pairs_all,pairs_part);            
            end        
            % randomly select pairs
            pos_poistions=find(pairs_all(:,3)==1);
            pos_poistions_selected=pos_poistions(randperm(length(pos_poistions)));
            if k>length(pos_poistions_selected)
                % not enough positive samples
                k=pos_poistions_selected;
                k_=round(k/pos_ratio*(1-pos_ratio));                
            end
            pos_poistions_selected=pos_poistions_selected(1:k);
            pairs_batch(1:k,1:2)=pairs_all(pos_poistions_selected,1:2);
            pairs_batch(1:k,5)=pairs_all(pos_poistions_selected,3);
            neg_poistions=find(pairs_all(:,3)==0);
            neg_poistions_selected=neg_poistions(randperm(length(neg_poistions)));
            neg_poistions_selected=neg_poistions_selected(1:k_);
            pairs_batch(k+1:k+k_,1:2)=pairs_all(neg_poistions_selected,1:2);
            pairs_batch(k+1:k+k_,5)=pairs_all(neg_poistions_selected,3);
            % delete the empty 
            if sum(pairs_batch(:,5)==-1)>0
                pairs_batch((pairs_batch(:,5)==-1),:)=[];
            end
            % shuffle batch
            pairs_batch = pairs_batch(randperm(size(pairs_batch,1)),:);
        end
    otherwise
        disp('Error. Unknown type.')
end

end

%% all batch parts
function pair_batch_allparts = init_pair_batch_allparts(iter)
    tmp.pairs_batch_part=[];
    pair_batch_allparts=repmat(tmp,iter,1);
end

%% concat all parts
function pairs_batch = concat_pair_batch_parts(pair_batch_allparts,pairs_number_iter,pairs_number_all,pos_ratio)
    full_size=length(pair_batch_allparts)*pairs_number_iter;
    pairs_batch=zeros(full_size,5)-1;
    % fill in the data
    for j=1:length(pair_batch_allparts)
        idx_start=(j-1)*pairs_number_iter+1;
        idx_end=j*pairs_number_iter;
        pairs_batch(idx_start:idx_end,:)=pair_batch_allparts(j).pairs_batch_part;
    end
    % delete extra if needed
    num_del=full_size-pairs_number_all;
    if num_del>0
        neg_position=find(pairs_batch(:,5)==0);
        pos_position=find(pairs_batch(:,5)==1);
        pos_number=floor(pairs_number_all*pos_ratio);
        pos_cur_number=sum(pairs_batch(:,5));
        if pos_cur_number<=pos_number
            % delete negative samples
            del_pos=randperm(length(neg_position));
            del_pos=neg_position(del_pos(1:num_del));
            pairs_batch(del_pos,:)=[];
        else
            if num_del>(pos_cur_number-pos_number)
                % delete positive and negative samples
                del_pos=randperm(length(pos_position));
                del_pos=pos_position(del_pos(1:(pos_cur_number-pos_number)));
                pairs_batch(del_pos,:)=[];
                clear del_pos;
                del_pos=randperm(length(neg_position));
                del_pos=neg_position(del_pos(1:num_del-(pos_cur_number-pos_number)));
                pairs_batch(del_pos,:)=[];  
            else
                % delete only positive samples
                del_pos=randperm(length(pos_position));
                del_pos=pos_position(del_pos(1:num_del));
                pairs_batch(del_pos,:)=[];          
            end
        end
    end
    % shuffle the batch
    pairs_batch = pairs_batch(randperm(size(pairs_batch,1)),:);
end