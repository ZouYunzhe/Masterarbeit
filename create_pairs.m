function pairs_batch=create_pairs(pairs_number_all,pairs_type,seq_list,pos_ratio,delta_frame)
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
                
            else
                max_it=labled_frame_numbers(end)-delta_frame-labled_frame_numbers(1)+1;
                pair_batch_allparts = init_pair_batch_allparts(max_it);
                pairs_number_iter = ceil(pairs_number_all/max_it);
                for it =1:max_it
                   frame1_idx = labled_frame_numbers(it);
                   frame2_idx = labled_frame_numbers(it)+delta_frame;
                   
                   frame_idx_tmp =[ seq_list.box_list.frame_idx];
                   box_idx_tmp=1:length(frame_idx_tmp);
                   track_id_tmp =[ seq_list.box_list.track_id];
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
%                    for i = 1:pairs_number_iter
%                        pairs_pos_tmp=[boxes_idx_frame1(pos_pairs_frame1_idx(p_pos(i))),boxes_idx_frame2(pos_pairs_frame2_idx(p_pos(i))),1,1,1];
%                        pairs_neg_tmp=[boxes_idx_frame1(neg_pairs_frame1_idx(p_neg(i))),boxes_idx_frame2(neg_pairs_frame2_idx(p_neg(i))),1,1,0];
%                        pairs_batch_part(i,:)=pairs_pos_tmp;
%                        pairs_batch_part(end-i+1,:)=pairs_neg_tmp;
%                    end
                   pair_batch_allparts(it).pairs_batch_part=pairs_batch_part;                  
                end
                pairs_batch= concat_pair_batch_parts(pair_batch_allparts,pairs_number_iter);
            end
        end
    case 2 
        %% joint to box
        
        
    case 3
        %% joint to joint
        
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
function pairs_batch = concat_pair_batch_parts(pair_batch_allparts,pairs_number_iter)
    full_size=length(pair_batch_allparts)*pairs_number_iter;
    pairs_batch=zeros(full_size,5)-1;
    % fill in the data
    for j=1:length(pair_batch_allparts)
        idx_start=(j-1)*pairs_number_iter+1;
        idx_end=j*pairs_number_iter;
        pairs_batch(idx_start:idx_end,:)=pair_batch_allparts(j).pairs_batch_part;
    end
    % shuffle the batch
    pairs_batch = pairs_batch(randperm(size(pairs_batch,1)),:);
end