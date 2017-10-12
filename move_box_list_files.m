clc;close all;
clear all;

Annotation_root = '/home/zouyunzhe/JointTracking/tmp/posetrack/posetrack_data/annotations/';
Annotation_path = fullfile(Annotation_root,'train_box_pairs_same_frame');

folder_layer = dir(Annotation_path);
folder_layer(1:2) = [];
if length(folder_layer)

% old_folder =
% new_folder =