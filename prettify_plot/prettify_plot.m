function prettify_plot(varargin)
% make current figure pretty
% ------
% Inputs: Name - Pair arguments
% ------
% - XLimits: string or number.
%   If a string, either:
%       - 'keep': don't change any of the xlimits
%       - 'same': set all xlimits to the same values
%       - 'row': set all xlimits to the same values for each subplot row
%       - 'col': set all xlimits to the same values for each subplot col
%   If a number, 1 * 2 double setting the minimum and maximum values
% - YLimits: string or number.
%   If a string, either:
%       - 'keep': don't change any of the ylimits
%       - 'same': set all ylimits to the same values
%       - 'row': set all ylimits to the same values for each subplot row
%       - 'col': set all ylimits to the same values for each subplot col
%   If a number, 1 * 2 double setting the minimum and maximum values
% - FigureColor: string (e.g. 'w', 'k', 'Black', ..) or RGB value defining the plots
%       background color.
% - TextColor: string (e.g. 'w', 'k', 'Black', ..) or RGB value defining the plots
%       text color.
% - LegendLocation: string determining where the legend is. Either:
%   'north'	Inside top of axes
%   'south'	Inside bottom of axes
%   'east'	Inside right of axes
%   'west'	Inside left of axes
%   'northeast'	Inside top-right of axes (default for 2-D axes)
%   'northwest'	Inside top-left of axes
%   'southeast'	Inside bottom-right of axes
%   'southwest'	Inside bottom-left of axes
%   'northoutside'	Above the axes
%   'southoutside'	Below the axes
%   'eastoutside'	To the right of the axes
%   'westoutside'	To the left of the axes
%   'northeastoutside'	Outside top-right corner of the axes (default for 3-D axes)
%   'northwestoutside'	Outside top-left corner of the axes
%   'southeastoutside'	Outside bottom-right corner of the axes
%   'southwestoutside'	Outside bottom-left corner of the axes
%   'best'	Inside axes where least conflict occurs with the plot data at the time that you create the legend. If the plot data changes, you might need to reset the location to 'best'.
%   'bestoutside'	Outside top-right corner of the axes (when the legend has a vertical orientation) or below the axes (when the legend has a horizontal orientation)
% - LegendReplace: ! buggy ! boolean, if you want the legend box to be replace by text
%       directly plotted on the figure, next to the each subplot's
%       line/point
% - titleFontSize: double
% - labelFontSize: double
% - generalFontSize: double
% - Font: string. See listfonts() for a list of all available fonts
% - pointSize: double
% - lineThickness: double
% - AxisTicks
% - AxisBox
% - AxisAspectRatio 'equal', 'square', 'image'
% - AxisTightness 'tickaligned' 'tight', 'padded'
% ------
% to do:
% - option to adjust vertical and horiz. lines
% - padding
% - fit data to plot (adjust lims)
% - padding / suptitles
% ------
% Julie M. J. Fabre

% Set default parameter values
options = struct('XLimits', 'keep', ... %set to 'keep' if you don't want any changes
    'YLimits', 'keep', ... %set to 'keep' if you don't want any changes
    'CLimits', 'all', ... %set to 'keep' if you don't want any changes
    'FigureColor', [1, 1, 1], ...
    'TextColor', [0, 0, 0], ...
    'LegendLocation', 'best', ...
    'LegendReplace', false, ... %BUGGY
    'LegendBox', 'off', ...
    'TitleFontSize', 15, ...
    'LabelFontSize', 15, ...
    'GeneralFontSize', 15, ...
    'Font', 'Arial', ...
    'BoldTitle', 'off', ...
    'WrapText', 'on', ...
    'PointSize', 15, ...
    'LineThickness', 2, ...
    'AxisTicks', 'out', ...
    'TickLength', 0.035, ...
    'TickWidth', 1.3, ...
    'AxisBox', 'off', ...
    'AxisGrid', 'off', ...
    'AxisAspectRatio', 'keep', ... %set to 'keep' if you don't want any changes
    'AxisTightness', 'keep', ... %BUGGY set to 'keep' if you don't want any changes %'AxisWidth', 'keep',... %BUGGY set to 'keep' if you don't want any changes %'AxisHeight', 'keep',...%BUGGY set to 'keep' if you don't want any changes
    'AxisUnits', 'points', ...
    'DivergingColormap', '*RdBu', ... %set to 'keep' if you don't want any changes
    'SequentialColormap', 'YlOrRd', ... %set to 'keep' if you don't want any changes
    'PairedColormap', 'Paired', ... %set to 'keep' if you don't want any changes
    'QualitativeColormap', 'Set1'); %set to 'keep' if you don't want any changes

% read the acceptable names
optionNames = fieldnames(options);

% count arguments
nArgs = length(varargin);
if round(nArgs/2) ~= nArgs / 2
    error('prettify_plot() needs propertyName/propertyValue pairs')
end

for iPair = reshape(varargin, 2, []) % pair is {propName;propValue}
    %inputName = lower(iPair{1}); % make case insensitive
    inputName = iPair{1};

    if any(strcmp(inputName, optionNames))
        % overwrite options. If you want you can test for the right class here
        % Also, if you find out that there is an option you keep getting wrong,
        % you can use "if strcmp(inpName,'problemOption'),testMore,end"-statements
        options.(inputName) = iPair{2};
    else
        error('%s is not a recognized parameter name', inputName)
    end
end

% Check Name/Value pairs make sense
if ischar(options.FigureColor) || isstring(options.FigureColor) %convert to rgb
    options.FigureColor = rgb(options.FigureColor);
end
if ischar(options.TextColor) || isstring(options.TextColor) %convert to rgb
    options.TextColor = rgb(options.TextColor);
end
if sum(options.FigureColor-options.TextColor) <= 1.5 %check background and text and sufficiently different
    if sum(options.FigureColor) >= 1.5
        options.TextColor = [0, 0, 0];
    else
        options.TextColor = [1, 1, 1];
    end
end
% Get handles for current figure and axis
currFig = gcf;


% Set color properties for figure and axis
set(currFig, 'color', options.FigureColor);

% get axes children
all_axes = find(arrayfun(@(x) contains(currFig.Children(x).Type, 'axes'), 1:size(currFig.Children, 1)));

% update font
fontname(options.Font)

% update (sub)plot properties
for iAx = 1:size(all_axes, 2)
    thisAx = all_axes(iAx);
    currAx = currFig.Children(thisAx);
    set(currAx, 'color', options.FigureColor);
    if ~isempty(currAx)

        % Set grid/box/tick options
        set(currAx, 'TickDir', options.AxisTicks)
        set(currAx, 'Box', options.AxisBox)
        set(currAx, 'TickLength', [options.TickLength, options.TickLength]); % Make tick marks longer.
        set(currAx, 'LineWidth', options.TickWidth); % Make tick marks and axis lines thicker.

        %set(currAx, 'Grid', options.AxisGrid)
        if strcmp(options.AxisAspectRatio, 'keep') == 0
            axis(currAx, options.AxisAspectRatio)
        end
        if strcmp(options.AxisTightness, 'keep') == 0
            axis(currAx, options.AxisTightness)
        end

        % Set text properties
        set(currAx.XLabel, 'FontSize', options.LabelFontSize, 'Color', options.TextColor);
        if strcmp(currAx.YAxisLocation, 'left') % if there is both a left and right yaxis, keep the colors
            set(currAx.YLabel, 'FontSize', options.LabelFontSize);
        else
            set(currAx.YLabel, 'FontSize', options.LabelFontSize, 'Color', options.TextColor);
        end
        if strcmp(options.BoldTitle, 'on')
            set(currAx.Title, 'FontSize', options.TitleFontSize, 'Color', options.TextColor, ...
                'FontWeight', 'Bold')
        else
            set(currAx.Title, 'FontSize', options.TitleFontSize, 'Color', options.TextColor, ...
                'FontWeight', 'Normal');
        end
        set(currAx, 'FontSize', options.GeneralFontSize, 'GridColor', options.TextColor, ...
            'YColor', options.TextColor, 'XColor', options.TextColor, ...
            'MinorGridColor', options.TextColor);
        if ~isempty(currAx.Legend)
            set(currAx.Legend, 'Color', options.FigureColor, 'TextColor', options.TextColor)
        end

        % Adjust properties of line children within the plot
        childLines = findall(currAx, 'Type', 'line');
        for thisLine = childLines'
            % if any lines/points become the same as background, change
            % these.
            if sum(thisLine.Color == options.FigureColor) == 3
                thisLine.Color = options.TextColor;
            end
            % adjust markersize
            if strcmp('.', get(thisLine, 'Marker'))
                set(thisLine, 'MarkerSize', options.PointSize);
            end
            % adjust line thickness
            if strcmp('-', get(thisLine, 'LineStyle'))
                set(thisLine, 'LineWidth', options.LineThickness);
            end
        end

        % Adjust properties of errorbars children within the plot
        childErrBars = findall(currAx, 'Type', 'ErrorBar');
        for thisErrBar = childErrBars'
            if strcmp('.', get(thisErrBar, 'Marker'))
                set(thisErrBar, 'MarkerSize', options.PointSize);
            end
            if strcmp('-', get(thisErrBar, 'LineStyle'))
                set(thisErrBar, 'LineWidth', options.LineThickness);
            end
        end

        % Adjust axis position
        %set(currAx, 'Units', options.AxisUnits); % Set units to pixels
        % if ~strcmp(options.AxisWidth, 'keep') && ~strcmp(options.AxisHeight, 'keep')
        %     AxisHeight = str2num(options.AxisHeight);
        %     AxisWidth = str2num(options.AxisWidth);
        %     ax_pos_ori = get(currAx, 'Position');
        %     % Scale subplot width and height independently to maintain aspect ratio
        %     scale_w = AxisWidth / ax_pos_ori(3);
        %     scale_h = AxisHeight / ax_pos_ori(4);
        %     new_pos = [ax_pos_ori(1), ax_pos_ori(2) + (ax_pos_ori(4) - AxisHeight * scale_h),...
        %                ax_pos_ori(3) * scale_w, ax_pos_ori(4) * scale_h];
        %     set(currAx, 'Position', new_pos);
        %     ax_pos(iAx,:) = new_pos;
        % elseif ~strcmp(options.AxisWidth, 'keep')
        %
        %     AxisWidth = str2num(options.AxisWidth);
        %     ax_pos_ori = get(currAx, 'Position');
        %     % Scale subplot width and height independently to maintain aspect ratio
        %     scale_w = AxisWidth / ax_pos_ori(3);
        %     scale_h = 1;
        %     new_pos = [ax_pos_ori(1), ax_pos_ori(2) + ax_pos_ori(4),...
        %                ax_pos_ori(3) * scale_w, ax_pos_ori(4)];
        %     set(currAx, 'Position', new_pos);
        %     ax_pos(iAx,:) = new_pos;
        % elseif ~strcmp(options.AxisHeight, 'keep')
        %      AxisHeight = str2num(options.AxisHeight);
        %     ax_pos_ori = get(currAx, 'Position');
        %     % Scale subplot width and height independently to maintain aspect ratio
        %     scale_w = 1;
        %     scale_h = AxisHeight / ax_pos_ori(4);
        %     new_pos = [ax_pos_ori(1), ax_pos_ori(2) + (ax_pos_ori(4) - AxisHeight * scale_h),...
        %                ax_pos_ori(3) * scale_w, ax_pos_ori(4) * scale_h];
        %     set(currAx, 'Position', new_pos);
        %     ax_pos(iAx,:) = new_pos;
        % else
        %     ax_pos = get(currAx, 'Position');
        % end
        ax_pos = get(currAx, 'Position');

        % Get x and y limits
        xlims_subplot(iAx, :) = currAx.XLim;
        ylims_subplot(iAx, :) = currAx.YLim;

        % adjust legend
        if ~isempty(currAx.Legend)
            if options.LegendReplace
                prettify_legend(currAx)
            else
                set(currAx.Legend, 'Location', options.LegendLocation)
                set(currAx.Legend, 'Box', options.LegendBox)
            end
        end


    end
end


% adjust/add colorbar
colorbars = findobj(currFig, 'Type', 'colorbar');
clims = nan(length(colorbars), 2);
col_pos = nan(length(colorbars), 2);
for iColorBar = 1:length(colorbars)
    currColorbar = colorbars(iColorBar);
    clims(iColorBar, :) = colorbars(iColorBar).Limits;
    if currColorbar.Limits(1) < 0 && currColorbar.Limits(2) > 0 % equalize, and use a diverging colormap
        if max(abs(currColorbar.Limits)) > 4
            clims(iColorBar, :) = [-ceil(max(abs(currColorbar.Limits))), ...
                ceil(max(abs(currColorbar.Limits)))];
        else % don't round up
            clims(iColorBar, :) = [-max(abs(currColorbar.Limits)), ...
                max(abs(currColorbar.Limits))];
        end
        colormap(currColorbar.Parent, brewermap(100, options.DivergingColormap))
    else %use a sequential colormap
        if max(abs(currColorbar.Limits)) > 4
            clims(iColorBar, :) = [min(0, ceil(max(currColorbar.Limits))), ...
                max(0, ceil(max(currColorbar.Limits)))];
        else % don't round up
            clims(iColorBar, :) = [min(0, max(currColorbar.Limits)), ...
                max(0, max(currColorbar.Limits))];
        end
        colormap(currColorbar.Parent, brewermap(100, options.SequentialColormap))
    end
    col_pos = currColorbar.Position;
end
col_cols = unique(col_pos(:, 1));
row_cols = unique(col_pos(:, 2));

col_clims = arrayfun(@(x) [min(min(clims(col_pos(:, 1) == col_cols(x), :))), ...
    max(max(clims(col_pos(:, 1) == col_cols(x), :)))], 1:size(col_cols, 1), 'UniformOutput', false);
row_clims = arrayfun(@(x) [min(min(clims(col_pos(:, 2) == row_cols(x), :))), ...
    max(max(clims(col_pos(:, 2) == row_cols(x), :)))], 1:size(row_cols, 1), 'UniformOutput', false);

colorbarProperties = struct;
for iColorBar = 1:length(colorbars)
    currColorbar = colorbars(iColorBar);
    %colorbarProperties = table;

    % set limits in smart way + choose colormap.
    if ismember(options.CLimits, {'all', 'row', 'col'})
        % get rows and cols

        if ismember(options.CLimits, {'all'})
            currColorbar.Limits = [min(min(clims)), max(max(clims))];
        end
        if ismember(options.CLimits, {'col'})
            currColorbar.Limits = col_clims{col_pos(iColorBar, 1) == col_cols};
        end
        if ismember(options.CLimits, {'row'})
            currColorbar.Limits = row_clims{col_pos(iColorBar, 2) == row_cols};
        end

    else
        currColorbar.Limits = clims(iColorBar, :);
    end
    colorbarProperties(iColorBar).Limits = currColorbar.Limits;
    colorbarProperties(iColorBar).Parent = currColorbar.Parent;
    % get label
    if ~isempty(currColorbar.Label.String) % label string
        label = currColorbar.Label.String;
    elseif ~isempty(currColorbar.Title.String) % title
        label = currColorbar.Title.String;
    elseif ~isempty(currColorbar.XLabel.String) %x label string
        label = currColorbar.Xlabel.String;
    else
        label = '';
    end

    colorbarProperties(iColorBar).Label = label;
    currColorbar.Units = 'Points'; %get old, add padding.
    colorbarProperties(iColorBar).Position_ori = currColorbar.Position;

    % remove colorbar
    % get parent axis size
    parentPosition_ori = colorbarProperties(iColorBar).Parent.Position; % [left bottom width height]
    delete(currColorbar)

    % get parent axis size
    parentPosition = colorbarProperties(iColorBar).Parent.Position; % [left bottom width height]
    padding = 5;
    colorbarProperties(iColorBar).Position = [parentPosition(3) + padding, ...
        padding, colorbarProperties(iColorBar).Position_ori(3), parentPosition(4) - 2 * padding];

    % add colorbar back
    newColorbar = colorbar;
    newColorbar.Parent = colorbarProperties(iColorBar).Parent;
    newColorbar.Units = 'Points';
    newColorbar.Position = colorbarProperties(iColorBar).Position_ori + [50, 30, 0, -60]; % QQ
    newColorbar.Label.String = colorbarProperties(iColorBar).Label;
    newColorbar.Limits = colorbarProperties(iColorBar).Limits;
    newColorbar.Units = 'Normalized'; % set back to normalized so it scales with figure

    % add colorbar limits above and below
    newColorbar.Title.String = num2str(colorbarProperties(iColorBar).Limits(2));
    set(newColorbar.XLabel, {'String', 'Rotation', 'Position'}, {num2str(colorbarProperties(iColorBar).Limits(1)), ...
        0, [0.5 - 0.01, colorbarProperties(iColorBar).Limits(1) - 1]})
    newColorbar.TickLabels = {};


end


% make x and y lims the same
if ismember(options.XLimits, {'all', 'row', 'col'}) || ismember(options.YLimits, {'all', 'row', 'col'})
    % get rows and cols
    col_subplots = unique(ax_pos(:, 1));
    row_subplots = unique(ax_pos(:, 2));

    col_xlims = arrayfun(@(x) [min(min(xlims_subplot(ax_pos(:, 1) == col_subplots(x), :))), ...
        max(max(xlims_subplot(ax_pos(:, 1) == col_subplots(x), :)))], 1:size(col_subplots, 1), 'UniformOutput', false);
    row_xlims = arrayfun(@(x) [min(min(xlims_subplot(ax_pos(:, 2) == row_subplots(x), :))), ...
        max(max(xlims_subplot(ax_pos(:, 2) == row_subplots(x), :)))], 1:size(row_subplots, 1), 'UniformOutput', false);
    col_ylims = arrayfun(@(x) [min(min(ylims_subplot(ax_pos(:, 1) == col_subplots(x), :))), ...
        max(max(ylims_subplot(ax_pos(:, 1) == col_subplots(x), :)))], 1:size(col_subplots, 1), 'UniformOutput', false);
    row_ylims = arrayfun(@(x) [min(min(ylims_subplot(ax_pos(:, 2) == row_subplots(x), :))), ...
        max(max(ylims_subplot(ax_pos(:, 2) == row_subplots(x), :)))], 1:size(row_subplots, 1), 'UniformOutput', false);

    for iAx = 1:size(all_axes, 2)
        thisAx = all_axes(iAx);
        currAx = currFig.Children(thisAx);
        if ~isempty(currAx)
            if ismember(options.XLimits, {'all'})
                set(currAx, 'Xlim', [min(min(xlims_subplot)), max(max(xlims_subplot))]);
            end
            if ismember(options.YLimits, {'all'})
                set(currAx, 'Ylim', [min(min(ylims_subplot)), max(max(ylims_subplot))]);
            end
            if ismember(options.XLimits, {'row'})
                set(currAx, 'Xlim', row_xlims{ax_pos(iAx, 2) == row_subplots});
            end
            if ismember(options.YLimits, {'row'})
                set(currAx, 'Ylim', row_ylims{ax_pos(iAx, 2) == row_subplots});
            end
            if ismember(options.XLimits, {'col'})
                set(currAx, 'Xlim', col_xlims{ax_pos(iAx, 1) == col_subplots});
            end
            if ismember(options.YLimits, {'col'})
                set(currAx, 'Ylim', col_ylims{ax_pos(iAx, 1) == col_subplots});
            end
        end
        if ~isempty(currAx.Legend)
            if options.LegendReplace
                prettify_legend(currAx)
            else
                set(currAx.Legend, 'Location', options.LegendLocation)
                set(currAx.Legend, 'Box', options.LegendBox)
            end
        end
    end
end
end


function resize_subplots(fig_handles, width, height)
for fig_idx = 1:length(fig_handles)
    fig = fig_handles(fig_idx);
    ax_handles = findobj(fig, 'Type', 'axes');

    % Resize subplots
    for ax_idx = 1:length(ax_handles)
        ax = ax_handles(ax_idx);
        ax_pos = get(ax, 'Position');
        % Scale subplot width and height independently to maintain aspect ratio
        scale_w = width / ax_pos(3);
        scale_h = height / ax_pos(4);
        new_pos = [ax_pos(1), ax_pos(2) + (ax_pos(4) - height * scale_h), ...
            ax_pos(3) * scale_w, ax_pos(4) * scale_h];
        set(ax, 'Position', new_pos);
    end

    % Optionally, adjust figure size here if needed
    % For example, to make room for suptitle or other figure-level annotations.
end
end
