clc;close all;clear all;
load('/home/zouyunzhe/JointTracking/tmp/posetrack/posetrack_data/annotations/train_list_for_sequence/bonn/000001_bonn/000001_bonn.mat')


% test box to box (need to be improved)
pairs_number_all=123;
pairs_type=1;
pos_ratio=0.55;
delta_frame=25;
pairs_batch_box_to_box =create_pairs(pairs_number_all,pairs_type,seq_list,pos_ratio,delta_frame);
r_box_to_box = sum(pairs_batch_box_to_box(:,5))/size(pairs_batch_box_to_box,1)

% test joint to box
pairs_number_all=123;
pairs_type=2;
pos_ratio=0.43;
delta_frame=25;
pairs_batch_joint_to_box=create_pairs(pairs_number_all,pairs_type,seq_list,pos_ratio,delta_frame,1);
r_joint_to_box = sum(pairs_batch_joint_to_box(:,5))/size(pairs_batch_joint_to_box,1)

% test joint to joint
pairs_number_all=123;
pairs_type=3;
pos_ratio=0.53;
delta_frame=10;
pairs_batch_joint_to_joint=create_pairs(pairs_number_all,pairs_type,seq_list,pos_ratio,delta_frame,[1,2]);
r_joint_to_joint = sum(pairs_batch_joint_to_joint(:,5))/size(pairs_batch_joint_to_joint,1)



