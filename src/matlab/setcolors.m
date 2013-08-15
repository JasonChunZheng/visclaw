function setcolors(p,x,y,z,q)

% SETCOLORS determines mapping between q data and color map
%
%      This subroutine, called by the Clawpack graphics routines, sets the
%      way in which q data is mapped to the graphics colormap.  This routine
%      is in the same location as the rest of the Clawpack graphics files;
%      if you wish to modify this file, copy claw/matlab/setcolors.m to your
%      working directory, and make any desired changes.
%
%      The syntax for this routine is
%
%              setcolors(p,x,y,z,q);
%
%      where p is the handle to the patch whose colors are being set,
%      (x,y,z) are the Cartesian locations of cell centers with corresponding
%      data values in q.  If a mapped grid or manifold is being plotted,
%      (x,y,z) are given in the Cartesian locations, NOT the physical
%      locations of cell centers.
%
%      By default, the q values are mapped linearly into current colormap,
%      with min and max values clamped to limits set by caxis.
%
%      This default behavior is accomplished with the following Matlab
%      commands :
%
%            set(p,'CData',q);                % Data to use for coloring.
%            set(p,'CDataMapping','scaled');  % Scale into current color map.
%            set(p,'FaceColor','flat');       % Single color per cell
%
%      Other color mapping schemes can be provided, for example to mask out
%      embedded boundary regions, or to flag certain values that lie out
%      side of a given data range.
%
%      For example, to highlight all values that lie outside of a given
%      range [a,b] (to see where overshoots and undershoots occur, for example).
%      Assume for example that the current colormap has length 'n', and that
%      in location 1 you have assigned the color black ([0 0 0]) and in
%      location n you have assigned the color white ([1 1 1]).  You want to
%      color all values q < a the color black, and all values q > b the
%      color white.  Everything in the range [a,b] should be mapped into the
%      colormap 'default'.  The following code will do this:
%
%      Example :
%
%           colormap('default');
%           cmap = [[0 0 0]; colormap; [1 1 1]];  % set black, white values
%           colormap(cmap);
%           n = length(cmap);
%
%           % Assign a color into map (2:n-1) based on value of q:
%           a = 0;  % value data range.
%           b = 1;
%
%           % Map a -> index value 2
%           % Map b -> index value n-1
%           idx = ((n-1)-2)/(b-a)*(q - a) + 2;
%
%           % Map all values that fall outside of the range
%           % [a,b] the color black or white
%           qcolors(q < a) = 1;   % assign values < a the color black.
%           qcolors(q > b) = n;   % assign values > b the color white.
%           qcolors(q >= a & q <= b) = round(idx);
%
%           % Set CData property for patch
%           set(p,'CData',qcolors);
%
%           % Interpret values in CData as indices which can be used
%           % directly into colormap.
%           set(p,'CDataMapping','direct');
%
%      See also PATCH, COLORMAP.

set(p,'CData',q);                % Data to use for coloring.
set(p,'CDataMapping','scaled');  % Scale into current color map.
set(p,'FaceColor','flat');       % Single color per cell

% Return here if you just want the usual colormap
return;

% Continue if you want to highlight under and overshoots.

% --------------------------------------------------------
% User specified values for overshoot/undershoot values.
% ---------------------------------------------------------
% Specify colors for under/over shoots
color_under = [1 0 1];   % cyan
color_over = [0 1 1];    % magenta

% Specify a tolerance for a under/over shoot value.
% Values outside of [value_under-tol, value_over+tol] will be
% colored using colors specified above.
tol = 1e-4;

% Specify exact values within which the exact solution should lie
value_lower = 0;
value_upper = 1;

% Specify the current colormap to be used for all values
% between [value_under, value_over];
yrbcolormap;
cm_user = colormap;

% ----------------------------------------------------
% The rest should be automatic
% ----------------------------------------------------
nmax = length(cm_user);
cm_extended = [color_over; cm_user; color_under];

% Fix q so that floor for indexing works.
mfix = (value_lower-tol) < q & q <= value_lower;
q(mfix) = value_lower;
mfix = value_upper <= q & q <= (value_upper + tol);
q(mfix) = value_upper-1e-8; % So floor works

idx = q;
m0 = value_lower <= q & q < value_upper;
slope = (q(m0) - value_lower)/(value_upper-value_lower);

% map value_lower => 1 and value_upper => nmax
idx(m0) = 1 + floor(1 + slope*(nmax-1));

m_over = q > (value_upper + tol);
idx(m_over) = nmax + 2;   % last index of cm_extended
m_under = q < -tol;
idx(m_under) = 1;   % first index in cm_extended

set(p,'CData',idx);      % Color by indexing directly into the color map
fv = get(p,'FaceVertexCData');

% Colors will be hardwired and not affected later calls to a colormap function.
set(p,'FaceVertexCData',cm_extended(fv,:));

% set(p,'CDataMapping','direct');
set(p,'FaceColor','flat');
