% IOU Intersection over union score.
%   The inputs can be two masks with the same dimensions
%   (binary,int,float,double matrices), or two vectors holding the
%   coordinates of the vertices of the bounding boxes,
%   ([xmin,ymin,xmax,ymax]), or a matrix Nx4 and a 1x4 vector. In the last
%   case, the output is a vector with the IOU score of mask2 with each one
%   of the bounding boxes in mask1
%
%   d = iou(in1,in2)
%
function d = compute_IOU(in1,in2)

% inputs are bounding box vectors   
if (isvector(in1) && numel(in1) == 4) && (isvector(in2) && numel(in2) == 4) 
    intersectionBox = [max(in1(1:2), in2(1:2)), min(in1(3:4), in2(3:4))];
    iw = intersectionBox(3)-intersectionBox(1);
    ih = intersectionBox(4)-intersectionBox(2);
    if iw>0 && ih>0
        % compute overlap as area of intersection / area of union
        unionArea = (in1(3)-in1(1))*(in1(4)-in1(2))+...
                    (in2(3)-in2(1))*(in2(4)-in2(2))- iw*ih;
        d = iw*ih/unionArea;
    else
        d = 0;
    end
else
    error('Input must be two bounding box vector')
end