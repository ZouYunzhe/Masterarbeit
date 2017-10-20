# LIFT env
# $LD_LIBRARY_PATH=/home/henschel/tmp/OF/web_gpudm_1.0/caffe/build/lib

import os as os
import argparse
import glob
from subprocess import call

# parser = argparse.ArgumentParser(description='Input pathes')
# parser.add_argument('-datSet')
# parser.add_argument('-GPUID')
# args = parser.parse_args()

# imgDir = "/home/zouyunzhe/JointTracking/tmp/posetrack/posetrack_data/images/bonn/" + args.datSet + "/"
# saveDir = "/home/zouyunzhe/JointTracking/tmp/posetrack/posetrack_data/DM_seq/bonn/"

# datSet = args.datSet

deepmatching = "./web_gpudm_1.0/deep_matching_gpu.py"


def computeDM_seq(imgDir, saveDir, TimeDist, GPUID):
    fileNames = sorted(glob.glob(imgDir + "/*.jpg"))
    if not os.path.exists(saveDir):
        os.makedirs(saveDir)
    for timeDist in TimeDist:
        for next, current in zip(fileNames, fileNames[timeDist:]):
            current_Name = os.path.splitext(os.path.basename(current))[0]
            next_Name = os.path.splitext(os.path.basename(next))[0]
            if (int(current_Name) - int(next_Name)) == timeDist:
                matchfile = saveDir + "/" + current_Name + "_" + next_Name + ".dm"
                print "python " + deepmatching + " " + current + " " + next + " -ds 2 -ngh 384 -GPU " + str(GPUID) + " -out  " + matchfile
                while os.path.exists(matchfile) == False or os.stat(matchfile).st_size == 0:
                    call([
                        "python " + deepmatching + " " + current + " " + next + " -ds 2 -ngh 384 -GPU " + str(GPUID) + " -out  " + matchfile],
                        shell=True)
