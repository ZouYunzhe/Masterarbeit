clc;close all;clear all;
root_path='/home/zouyunzhe/JointTracking/tmp/MOT16/';
dataset_type ='train';
seq_list = dir(fullfile(root_path,dataset_type));
seq_list(1:2)=[];
for seq_nr = 1:length(seq_list)
    seq_path= fullfile(seq_list(seq_nr ).folder,seq_list(seq_nr).name);
    matfile=dir(cat(2,seq_path,'/*.mat'));
    matfile_path=fullfile(matfile.folder,matfile.name);
    load(matfile_path);
    disp(cat(2,matfile.name,'....loaded'));
    img_list=dir(fullfile(seq_path,'img1/*.jpg'));
    
    disp(cat(2,'number of pairs:',num2str(size(box_pairs,1))));
    disp(cat(2,'number of positive pairs:',num2str(sum(box_pairs(:,11)))));
    disp(cat(2,'number of negative pairs:',num2str(size(box_pairs,1)-sum(box_pairs(:,11)))));
%     disp(cat(2,'number of false positive pairs:',num2str(size(box_pairs,1))));
    h=figure;
    for it=1:10
        rand_idx=randperm(size(box_pairs,1));
        pair_to_show = box_pairs(rand_idx(it),:);
        label=pair_to_show(11);
        img1_path=fullfile(img_list(1).folder,img_list(pair_to_show(5)).name);
        img2_path=fullfile(img_list(1).folder,img_list(pair_to_show(10)).name);

        subplot(1,2,1);
        imshow(img1_path);
        hold on
        if label==1
            rectangle('Position',[ pair_to_show(1) pair_to_show(2) pair_to_show(3) pair_to_show(4)],'EdgeColor','g');
        else
            rectangle('Position',[ pair_to_show(1) pair_to_show(2) pair_to_show(3) pair_to_show(4)],'EdgeColor','r');
        end
        title(num2str(pair_to_show(5)));
        hold off
        subplot(1,2,2);
        imshow(img2_path);
        if label==1
            rectangle('Position',[ pair_to_show(6) pair_to_show(7) pair_to_show(8) pair_to_show(9)],'EdgeColor','g');
        else
            rectangle('Position',[ pair_to_show(6) pair_to_show(7) pair_to_show(8) pair_to_show(9)],'EdgeColor','r');
        end
        title(num2str(pair_to_show(10)));
        hold off
        w = waitforbuttonpress;
        if w == 0
            clf;
        end
    end
    close(h);
end