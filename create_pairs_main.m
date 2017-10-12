clc;close all;clear all;
load('/home/zouyunzhe/JointTracking/tmp/posetrack/posetrack_data/annotations/train_list_for_sequence/bonn/000001_bonn/000001_bonn.mat')
pairs_batch=create_pairs(100,1,seq_list,0.5,29);