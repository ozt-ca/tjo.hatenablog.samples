function handle=jicolorbar(loc,tit)
% JICOLORBAR  Same as COLORBAR, but does not resize current axis. (JRI)
%   COLORBAR('vert') appends a vertical color scale to the current
%   axis. COLORBAR('horiz') appends a horizontal color scale. COLORBAR('vshort')
%   adds a half-height color scale.
%
%   COLORBAR(H) places the colorbar in the axes H. The colorbar will
%   be horizontal if the axes H width > height (in pixels).
%
%   COLORBAR without arguments either adds a new vertical color scale
%   or updates an existing colorbar.
%
%   H = COLORBAR(...) returns a handle to the colorbar axis.

%   Clay M. Thompson 10-9-92
%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision: 5.31 $  $Date: 1998/07/24 18:08:03 $

%   If called with COLORBAR(H) or for an existing colorbar, don't change
%   the NextPlot property.

% JRI Modified matlab function colorbar

changeNextPlot = 1;

fs = get(gca,'fontsize')-1; %fontsize for colorbar axis

if nargin<1, loc = 'vert'; end
if nargin<2, tit = ''; end

% Catch colorbar('delete') special case -- must be called by the deleteFcn.
if nargin==1 & strcmp(loc,'delete'),
  ax = gcbo;
  if strcmp(get(ax,'tag'),'TMW_COLORBAR'), ax=get(ax,'parent'); end
  ud = get(ax,'userdata');
  if isfield(ud,'PlotHandle') & ishandle(ud.PlotHandle) & ...
     isfield(ud,'origPos') & ~isempty(ud.origPos)
     units = get(ud.PlotHandle,'units');
     set(ud.PlotHandle,'units','normalized');
     set(ud.PlotHandle,'position',ud.origPos);
     set(ud.PlotHandle,'units',units);
  end
  if isfield(ud,'DeleteProxy') & ishandle(ud.DeleteProxy)
    delete(ud.DeleteProxy)
  end
  if ~isempty(legend)
    legend % Update legend
  end
  return
end

ax = [];
if nargin==1,
    if ishandle(loc)
        ax = loc;
        if ~strcmp(get(ax,'type'),'axes'),
            error('Requires axes handle.');
        end
        units = get(ax,'units'); set(ax,'units','pixels');
        rect = get(ax,'position'); set(ax,'units',units)
        if rect(3) > rect(4), loc = 'horiz'; else loc = 'vert'; end
        changeNextPlot = 0;
    end
end

% Determine color limits by context.  If any axes child is an image
% use scale based on size of colormap, otherwise use current CAXIS.

ch = get(gcda,'children');
hasimage = 0; t = [];
cdatamapping = 'direct';

for i=1:length(ch),
    typ = get(ch(i),'type');
    if strcmp(typ,'image'),
        hasimage = 1;
        cdatamapping = get(ch(i), 'CDataMapping');
    elseif strcmp(typ,'surface') & ...
            strcmp(get(ch(i),'FaceColor'),'texturemap') % Texturemapped surf
        hasimage = 2;
        cdatamapping = get(ch(i), 'CDataMapping');
    elseif strcmp(typ,'patch') | strcmp(typ,'surface')
        cdatamapping = get(ch(i), 'CDataMapping');
    end
end

if ( strcmp(cdatamapping, 'scaled') )
  % Treat images and surfaces alike if cdatamapping == 'scaled'
  t = caxis;
  d = (t(2) - t(1))/size(colormap,1);
  t = [t(1)+d/2  t(2)-d/2];
else
    if hasimage,
        t = [1, size(colormap,1)]; 
    else
        t = [1.5  size(colormap,1)+.5];
    end
end

h = gcda;

if nargin==0,
    % Search for existing colorbar
    ch = get(findobj(gcf,'type','image','tag','TMW_COLORBAR'),{'parent'}); ax = [];
    for i=1:length(ch),
        ud = get(ch{i},'userdata');
        d = ud.PlotHandle;
        if prod(size(d))==1 & isequal(d,h), 
            ax = ch{i}; 
            pos = get(ch{i},'Position');
            if pos(3)<pos(4), loc = 'vert'; else loc = 'horiz'; end
            changeNextPlot = 0;
            % Make sure image deletefcn doesn't trigger a colorbar('delete')
            % for colorbar update
            set(get(ax,'children'),'deletefcn','')
            break; 
        end
    end
end

origNextPlot = get(gcf,'NextPlot');
if strcmp(origNextPlot,'replacechildren') | strcmp(origNextPlot,'replace'),
    set(gcf,'NextPlot','add')
end

if loc(1)=='v', % Append vertical scale to right of current plot
    
    if ~isempty(findstr(loc,'short')),
        scale = 0.5;         %height relative to axis height
    else
        scale = 1;
    end
    
    if isempty(ax),
        units = get(h,'units'); set(h,'units','normalized')
        pos = get(h,'Position'); 
        [az,el] = view;
        
        %JRI MODIFIED to not modify original axis size, and give a narrower bar
        stripe = 0.04; edge = 0.01; 

        if all([az,el]==[0 90]), space = 0; else space = .1; end
        %set(h,'Position',[pos(1) pos(2) pos(3)*(1-stripe-edge-space) pos(4)])
        
        % original code:
        %stripe = 0.075; edge = 0.02; 
        %if all([az,el]==[0 90]), space = 0.05; else space = .1; end
        %set(h,'Position',[pos(1) pos(2) pos(3)*(1-stripe-edge-space) pos(4)])
        
        %rect = [pos(1)+(1-stripe-edge)*pos(3) pos(2) stripe*pos(3) pos(4)];
        rect = [pos(1)+pos(3) pos(2)+(0.5*(1-scale)*pos(4)) stripe*pos(3) scale*pos(4)];
        ud.origPos = pos;
        
        % Create axes for stripe and
        % create DeleteProxy object (an invisible text object in
        % the target axes) so that the colorbar will be deleted
        % properly.
        ud.DeleteProxy = text('parent',h,'visible','off',...
                              'tag','ColorbarDeleteProxy',...
                              'handlevisibility','off',...
             'deletefcn','eval(''delete(get(gcbo,''''userdata''''))'','''')');
          ax = axes('Position', rect);
          %JRI ADDITION--smaller font
          set(ax,'fontsize',fs);

        setappdata(ax,'NonDataObject',[]); % For DATACHILDREN.M
        set(ud.DeleteProxy,'userdata',ax)
        set(h,'units',units)
    else
        axes(ax);
        ud = get(ax,'userdata');
    end
    
    % Create color stripe
    n = size(colormap,1);
    
    %%% JRI 10/14/03
    %%% enable fixed colors, so when change colormap, colorbar doesn't
    %%% change
    if ~isempty(findstr(loc,'fix')),
        cm = colormap;
        cc(:,1,1) = cm(:,1);
        cc(:,1,2) = cm(:,2);
        cc(:,1,3) = cm(:,3);
        image([0 1],t,cc,'Tag','TMW_COLORBAR','deletefcn','colorbar(''delete'')'); set(ax,'Ydir','normal')
    else
        image([0 1],t,(1:n)','Tag','TMW_COLORBAR','deletefcn','colorbar(''delete'')'); set(ax,'Ydir','normal')
    end
    set(ax,'YAxisLocation','right')
    set(ax,'xtick',[])

    % set up axes deletefcn
    set(ax,'tag','Colorbar','deletefcn','colorbar(''delete'')')

    title(tit)
    
elseif loc(1)=='h', % Append horizontal scale to top of current plot
    
    if isempty(ax),
        units = get(h,'units'); set(h,'units','normalized')
        pos = get(h,'Position');
        stripe = 0.075; space = 0.1;
        set(h,'Position',...
            [pos(1) pos(2)+(stripe+space)*pos(4) pos(3) (1-stripe-space)*pos(4)])
        rect = [pos(1) pos(2) pos(3) stripe*pos(4)];
        ud.origPos = pos;

        % Create axes for stripe and
        % create DeleteProxy object (an invisible text object in
        % the target axes) so that the colorbar will be deleted
        % properly.
        ud.DeleteProxy = text('parent',h,'visible','off',...
                              'tag','ColorbarDeleteProxy',...
                              'handlevisibility','off',...
             'deletefcn','eval(''delete(get(gcbo,''''userdata''''))'','''')');
        ax = axes('Position', rect);
        setappdata(ax,'NonDataObject',[]); % For DATACHILDREN.M
        set(ud.DeleteProxy,'userdata',ax)
        set(h,'units',units)
    else
        axes(ax);
        ud = get(ax,'userdata');
    end
    
    % Create color stripe
    n = size(colormap,1);
    image(t,[0 1],(1:n),'Tag','TMW_COLORBAR','deletefcn','colorbar(''delete'')'); set(ax,'Ydir','normal')
    set(ax,'ytick',[])

    % set up axes deletefcn
    set(ax,'tag','Colorbar','deletefcn','colorbar(''delete'')')
    
else
  error('COLORBAR expects a handle, ''vert'', or ''horiz'' as input.')
end

if ~isfield(ud,'DeleteProxy'), ud.DeleteProxy = []; end
if ~isfield(ud,'origPos'), ud.origPos = []; end
ud.PlotHandle = h;
set(ax,'userdata',ud)
axes(h)
set(gcf,'NextPlot',origNextPlot)
if ~isempty(legend)
  legend % Update legend
end
if nargout>0, handle = ax; end

%--------------------------------
function h = gcda
%GCDA Get current data axes

h = datachildren(gcf);
if isempty(h) | any(h == gca)
  h = gca;
else
  h = h(1);
end

