close all;clear all;clc;
% load image
Img_Dir = '/home/zouyunzhe/JointTracking/tmp/test/MOT16-01/img1/';
fn = 10;
Img_Name = sprintf('%06d',fn);
Img_Path = strcat(Img_Dir,Img_Name,'.jpg');
I = imread(Img_Path );

% load joint positions
Jointdata_Dir = '/home/zouyunzhe/JointTracking/tmp/TestHumanPose_WithTracking/matfile/';
Jointdata_Name = strcat('person_conf_multi_',Img_Name ,'.mat');
Jointdata_Path = strcat(Jointdata_Dir,Jointdata_Name);
load(Jointdata_Path);

% show image
figure(1);
imshow(I);

% show joints
hold on
for person_id = 1:size(person_conf_multi,1)
    for part_id = 1:size(person_conf_multi,2)
        plot(person_conf_multi(person_id,part_id,1),person_conf_multi(person_id,part_id,2),['o','r'],'MarkerSize',8);
    end
end
hold off
title('Figure 1');

% load joint positions
Jointdata_Dir2 = '/home/zouyunzhe/JointTracking/tmp/TestHumanPose_SingleFrame/matfile/';
Jointdata_Path2 = strcat(Jointdata_Dir2,Jointdata_Name);
load(Jointdata_Path2);

% show image
figure(2);
imshow(I);

% show joints
hold on
for person_id = 1:size(person_conf_multi,1)
    for part_id = 1:size(person_conf_multi,2)
        plot(person_conf_multi(person_id,part_id,1),person_conf_multi(person_id,part_id,2),['o','b'],'MarkerSize',8);
    end
end
hold off
title('Figure 2');

