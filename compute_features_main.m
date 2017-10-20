% The main function for feature computing.
% The feature functions are all called with the same parameter.
clc;close all;clear all;
features{1}=@myAdd;
features{2}=@mySub;
a=10;
b=5;
for i= 1:2
    disp(features{i}(a,b));
end

