function seq_list=create_list_for_sequence(box_list_dir,joint_list_dir,Annotation)
% pack the box and joint lists into one list for the sequence
% input: box_list_dir,joint_list_dir,annotation
% output: seq_list
% the sequence list has the following fields:
% 1) box_list
% 2) joint_list
% 3) image_name_list
box_mat_files=dir(cat(2,box_list_dir,'/*.mat'));
joint_mat_files=dir(cat(2,joint_list_dir,'/*.mat'));
% image name list
seq_list.image_name_list=[Annotation.annolist.image];
box_start_idx=1;
box_end_idx=1;
joint_idx=0;
head_rec_start_idx=1;
head_rec_end_idx=1;
for mat_num=1:length(box_mat_files)
    %% box list
    load(fullfile(box_list_dir,box_mat_files(mat_num).name)); % load one box list mat file (bounding_boxes_list)
    box_end_idx=box_start_idx+length(bounding_boxes_list)-1;
    % rename box list field 'id' with 'track_id' and delete the field 'image_name'
    bounding_boxes_list = rmfield(bounding_boxes_list,'image_name');
    seq_list.box_list(box_start_idx:box_end_idx)=bounding_boxes_list;
    clear bounding_boxes_list;
    box_start_idx=box_end_idx+1;
    
    %% joint list
    load(fullfile(joint_list_dir,joint_mat_files(mat_num).name)); % load one joint list mat file (joint_list)
    % joints
    for joint_num=1:numel([joint_list.joint_type.track_id])
        joint_idx=joint_idx+1;
        x=[joint_list.joint_type.x];
        y=[joint_list.joint_type.y];
        is_visible=[joint_list.joint_type.is_visible];
        track_id=[joint_list.joint_type.track_id];
        frame_idx=joint_list.joint_type(1).frame_idx;
        joint_type=[joint_list.joint_type.joint_type];
        seq_list.joint_list.joints(joint_idx).x=x(joint_num);
        seq_list.joint_list.joints(joint_idx).y=y(joint_num);
        seq_list.joint_list.joints(joint_idx).is_visible=is_visible(joint_num);
        seq_list.joint_list.joints(joint_idx).track_id=track_id(joint_num);
        seq_list.joint_list.joints(joint_idx).frame_idx=frame_idx;
        seq_list.joint_list.joints(joint_idx).joint_type=joint_type(joint_num);  
       
    end
    % head rec
    if isfield(joint_list,'head_rec')
        head_rec_end_idx=head_rec_start_idx+length(joint_list.head_rec)-1;
        joint_list.head_rec = rmfield(joint_list.head_rec,'image_name');
        seq_list.joint_list.head_rec(head_rec_start_idx:head_rec_end_idx)=joint_list.head_rec;  
        clear joint_list; 
        head_rec_start_idx=head_rec_end_idx+1;
    end
end