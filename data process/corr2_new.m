function r = corr2_new(a,b)
%CORR2 2-D correlation coefficient.
%   R = CORR2(A,B) computes the correlation coefficient between A
%   and B, where A and B are matrices or vectors of the same size.
%
%   Class Support
%   -------------
%   A and B can be numeric or logical. 
%   R is a scalar double.
%
%   Example
%   -------
%   I = imread('pout.tif');
%   J = medfilt2(I);
%   R = corr2(I,J)
%
%   See also CORRCOEF, STD2.

%   Copyright 1992-2013 The MathWorks, Inc.

%a = a - mean2(a);
%b = b - mean2(b);
r = sum(sum(a.*b))/sqrt(sum(sum(a.*a))*sum(sum(b.*b)));