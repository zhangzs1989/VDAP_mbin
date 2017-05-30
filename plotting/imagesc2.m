function [h, hcb] = imagesc2(a,cm,nanclr)
% IMAGESC2 Does the same thing as imagesc but displays NaN values with a specific color
% This code is largely copied from a help forum at:
%  http://stackoverflow.com/questions/8481324/contrasting-color-for-nans-in-imagesc
% It is exists in VDAP_mbin for the specific purposes of displaying True
% and False Positive results as associated with the FP2 scripts. Any
% application outside of that usage may not work as desired.
%
% INPUT
% - a       : matrix to be displayed as a scaled image
% - cm  	: colormap
% - nanclr  : RGB triplet for NaN values
%
% OUTPUT
% - h       : handle to image
% - hcb     : handle to colorbar
%
% see also imagesc
%

warning('This function exists in VDAP_mbin for the specific purposes of displaying True and False Positive results as associated with the FalsePositives2 scripts. Any application outside of that usage may not work as desired.')


%# find minimum and maximum
% amin=min(a(:));
% amax=max(a(:));
amin = 0;
amax = 1;

%# size of colormap
n = size(cm,1);
%# color step
dmap=(amax-amin)/n;

%# standard imagesc
him = imagesc(a);
%# add nan color to colormap
colormap([nanclr; cm]);
%# changing color limits
caxis([0-dmap 1]);
%# place a colorbar
hcb = colorbar;
%# change Y limit for colorbar to avoid showing NaN color
ylim(hcb,[0 1])

if nargout > 0
    h = him;
end