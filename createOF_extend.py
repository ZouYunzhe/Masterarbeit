# LIFT env
# $LD_LIBRARY_PATH=/home/henschel/tmp/OF/web_gpudm_1.0/caffe/build/lib

import os as os
import argparse
import glob
import math
from subprocess import call

parser = argparse.ArgumentParser(description='Input pathes')

parser.add_argument('-datSet')

parser.add_argument('-GPUID')

cwd = os.getcwd()
args = parser.parse_args()

imgDir = "/home/henschel/dataPed/" + args.datSet + "/left/"

fileNames = sorted(glob.glob(imgDir + "*.jpg"))

datSet = args.datSet

deepmatching = "./web_gpudm_1.0/deep_matching_gpu.py"
epicflow = "./EpicFlow_v1.00/epicflow"

/home/zouyunzhe/JointTracking/tmp/posetrack/posetrack_data/

print "/prog/matlab/R2016b/bin/matlab -nosplash -nodisplay -r \"cd /home/henschel/tmp/OF/; createOF_SED('" + args.datSet + "'); exit\""
# call("/prog/matlab/R2016b/bin/matlab -nosplash -nodisplay -r \"cd /home/henschel/tmp/OF/; createOF_SED('"+args.datSet+"'); exit\"",shell=True)


print(os.getcwd())

if not os.path.exists("results/" + args.datSet):
    os.makedirs("results/" + args.datSet)
if not os.path.exists("results/" + args.datSet + "/DM"):
    os.makedirs("results/" + args.datSet + "/DM")
if not os.path.exists("results/" + args.datSet + "/edgeFiles"):
    os.makedirs("results/" + args.datSet + "/edgeFiles")
if not os.path.exists("results/" + args.datSet + "/ForwardFlow"):
    os.makedirs("results/" + args.datSet + "/ForwardFlow")
if not os.path.exists("results/" + args.datSet + "/BackwardFlow"):
    os.makedirs("results/" + args.datSet + "/BackwardFlow")
# for current, next in zip(fileNames, fileNames[1:]):
#    current_Name =os.path.splitext(os.path.basename(current))[0]
#    flowName = str(int(current_Name))
#    flowName = flowName.zfill(int(round(math.ceil(math.log(len(fileNames))/math.log(10)))))
#    outputfile = "/home/henschel/tmp/OF/results/"+args.datSet+"/ForwardFlow/ForwardFlow"+flowName+".flo"
#    matchfile = "/home/henschel/tmp/OF/results/"+args.datSet+"/tmp.match"
#    call(["python "+deepmatching+" "+current+" "+next+" -ngh 16 -out  "+matchfile],shell=True)
#    edgefile = "results/"+datSet+"/edgeFiles/edgefile_"+current_Name+".jpg"
#    print epicflow+" "+current+" "+next+" "+edgefile+" "+matchfile+" "+outputfile
#    call([epicflow+" "+current+" "+next+" "+edgefile+" "+matchfile+" "+outputfile],shell=True)
#    os.remove("/home/henschel/tmp/OF/results/"+args.datSet+"/tmp.match")


for timeDist in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]:
    for next, current in zip(fileNames, fileNames[timeDist:]):
        current_Name = os.path.splitext(os.path.basename(current))[0]
        flowName = str(int(current_Name))
        flowName = flowName.zfill(int(round(math.ceil(math.log(len(fileNames)) / math.log(10)))))
        next_Name = os.path.splitext(os.path.basename(next))[0]

        nextName = str(int(next_Name))
        nextName = nextName.zfill(int(round(math.ceil(math.log(len(fileNames)) / math.log(10)))))

        #    outputfile = "/home/henschel/tmp/OF/results/"+args.datSet+"/BackwardFlow/BackwardFlow"+flowName+".flo"
        matchfile = "/home/henschel/tmp/OF/results/" + args.datSet + "/DM/" + flowName + "_" + nextName + ".dm"
        print "python " + deepmatching + " " + current + " " + next + " -ds 2 -ngh 384 -GPU " + args.GPUID + " -out  " + matchfile
        while os.path.exists(matchfile) == False or os.stat(matchfile).st_size == 0:
            call([
                     "python " + deepmatching + " " + current + " " + next + " -ds 2 -ngh 384 -GPU " + args.GPUID + " -out  " + matchfile],
                 shell=True)

        #    edgefile = "results/"+datSet+"/edgeFiles/edgefile_"+current_Name+".jpg"
        #    print epicflow+" "+current+" "+next+" "+edgefile+" "+matchfile+" "+outputfile
        #    call([epicflow+" "+current+" "+next+" "+edgefile+" "+matchfile+" "+outputfile],shell=True)
        #    os.remove("/home/henschel/tmp/OF/results/"+args.datSet+"/tmp.match")
