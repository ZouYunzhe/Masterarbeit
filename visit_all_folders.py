import os as os
import argparse
import glob
import createDM_seq
import sys
sys.path.append("/home/zouyunzhe/DM_Henschel/web_gpudm_1.0/")
imgDir = "/home/zouyunzhe/JointTracking/tmp/posetrack/posetrack_data/images/"
saveDir = "/home/zouyunzhe/JointTracking/tmp/posetrack/posetrack_data/DM_seq/"
TimeDist = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
gpuid = 1
folderNames = sorted(glob.glob(imgDir + "*"))
for cur_folder in folderNames[0:1]:
    cur_saveDir = saveDir + cur_folder.split('/')[-1]
    sub_folderNames = sorted(glob.glob(cur_folder + "/*"))
    for cur_sub_folder in sub_folderNames[1:2]:
        cur_sub_saveDir = cur_saveDir + '/' + cur_sub_folder.split('/')[-1]
        print cur_sub_saveDir
        createDM_seq.computeDM_seq(cur_sub_folder, cur_sub_saveDir, TimeDist, gpuid)
