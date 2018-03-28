function [npx,npy] = spdiv(param)
% ------------------------------------------------------------------------
% This funciton takes an imporatant parameter of interest and decides the
% approriate division of subplot figures.  Essentially determines the grid
% of subplots to use.
%   NOTE:  MATLAB's subplot comamand desires a (x,y) determination of the
%          size grid that it will create for its subplots.
%
% Original Author:  Barry Pawlowski <bpawlows@nd.edu>
%
% Inputs:
%       param -  The important parameter to determine base the grid off
%                of.
%
% Outputs:
%       npx -   x number of plots (Number of rows)
%       npy -   y number of plots (Number of columns)
%
% Last Updated:  March 28, 2018
%
% Edits:
%
% ------------------------------------------------------------------------
%  --- Begin Function
% I) There are multiple things that need to be checked, first if it is a
% perfect square then, the grid needs to be uniform in both x and y.
%       i.e. Say param is an integer n, and m is the square root of n and m
%            itself is an integer.  Then the grid would be (npx,npy)= (m,m).
sof = sqrt(param);      % Taking the square root
sofmod = mod(sof,1);    % Determining if the square root is an integer
if sofmod == 0
    npx = sof;  npy = sof;
else
    % 2) If there is not a perfect square additional criteria needs to be
    % checked.  Here the square root will still be used, but a difference
    % will be checked.
    sofr = round(sof);  sofr2 = sofr.^2;   % Round and square the square root
    sofr2dif = sofr2 - param;
    if sofr2dif > 0
        npx = sofr;   npy = sofr;
    else
        npx = sofr;   npy = sofr + 1;
    end
end
