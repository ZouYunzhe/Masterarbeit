clc;close all;clear all;
root_path='/home/zouyunzhe/JointTracking/tmp/MOT16/';
dataset_type ='train';
seq_list = dir(fullfile(root_path,dataset_type));
seq_list(1:2)=[];
seq_nr = 1;
seq_path= fullfile(seq_list(seq_nr ).folder,seq_list(seq_nr ).name);
% notation_path=fullfile(seq_path,'gt/gt.txt');
% groundtruth = csvread(notation_path);
load('/home/zouyunzhe/JointTracking/tmp/MOT16/train/MOT16-02/gt/gt_new.mat');
groundtruth = groundtruth_aug;

img_list=dir(fullfile(seq_path,'img1/*.jpg'));

% show one example
% line_nr=1;
frame_nr=20;
num_of_id_wanted=5;
id_wanted=unique(groundtruth((groundtruth(:,7)==1)&(groundtruth(:,1)==frame_nr),2));
id_wanted=id_wanted(1:num_of_id_wanted);
if_consider=groundtruth(:,1)==frame_nr;
consider_ind=find(if_consider==1);
img_path=fullfile(img_list(1).folder,img_list(frame_nr).name);
figure;imshow(img_path);
hold on
% line_nr=find(if_consider==1,1,'first');
for it = 1:length(consider_ind)
    line_info=groundtruth(consider_ind(it),:);
    if line_info(7)==1&&line_info(8)~=-1
        if sum(line_info(2)==id_wanted)~=0
            rectangle('Position',[ line_info(3) line_info(4) line_info(5) line_info(6)],'EdgeColor','g');
        end
    elseif line_info(8)==-1 % false positive
        rectangle('Position',[ line_info(3) line_info(4) line_info(5) line_info(6)],'EdgeColor','b');
        rectangle('Position',[ 1000 500 200 50],'EdgeColor','b');
    else
        rectangle('Position',[ line_info(3) line_info(4) line_info(5) line_info(6)],'EdgeColor','r');
    end
    
end
hold off