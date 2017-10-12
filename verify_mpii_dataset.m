close all;clearvars all;clc;
% part id table
part_name = {'r ankle', 'r knee', 'r hip', 'l hip', 'l knee', 'l ankle', 'pelvis', 'thorax', 'upper neck', 'head top', 'r wrist', 'r elbow', 'r shoulder', 'l shoulder', 'l elbow', 'l wrist'};
% load image
Img_Dir = '/home/zouyunzhe/JointTracking/tmp/MPII/images/';
imagefiles = dir(strcat(Img_Dir,'*.jpg'));    

% load joint positions
Annotation_Path = '/home/zouyunzhe/JointTracking/tmp/MPII/mpii_human_pose_v1_u12_2/mpii_human_pose_v1_u12_1.mat';
load(Annotation_Path);

test_id = randi([1 size(imagefiles,1)]);
% test_id =10;

Img_Name = RELEASE.annolist(test_id).image.name;
Img_Path = strcat(Img_Dir,Img_Name);
I = imread(Img_Path);
num_rec=length(RELEASE.annolist(test_id).annorect);
% show image
figure(1);
imshow(I);
% show parts
hold on
for j = 1:num_rec
    fields = fieldnames(RELEASE.annolist(test_id).annorect(j));
    if ~ismember(fields,'annopoints')
        disp('non-existent field "annopoints"');
        continue;
    end
    num_parts=size(RELEASE.annolist(test_id).annorect(j).annopoints.point,2);
    x1 = RELEASE.annolist(test_id).annorect(j).x1;
    x2 = RELEASE.annolist(test_id).annorect(j).x2;
    y1 = RELEASE.annolist(test_id).annorect(j).y1;
    y2 = RELEASE.annolist(test_id).annorect(j).y2;
    rectangle('Position',[ x1 y1 abs(x1-x2) abs(y1-y2) ]);
    for i = 1:num_parts
        x = RELEASE.annolist(test_id).annorect(j).annopoints.point(i).x;
        y = RELEASE.annolist(test_id).annorect(j).annopoints.point(i).y;
        id = RELEASE.annolist(test_id).annorect(j).annopoints.point(i).id;
        plot(x,y,['o','r'],'MarkerSize',4);
    %     text(x,y,num2str(id),'Color','r','HorizontalAlignment','right');
        text(x,y,cell2mat(part_name(id+1)),'Color','r','HorizontalAlignment','right');
    end
end
hold off

