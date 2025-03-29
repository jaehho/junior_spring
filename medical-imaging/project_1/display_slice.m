function slice_data = display_slice(slice_type, slice_index, volume, pixelSpacing, sliceSpacing, x_lim, y_lim, ax)
    % Get slice data as a 2D array
    if strcmp(slice_type, 'Axial')
        slice_data = squeeze(volume(:,:,slice_index));
        coord_label = 'z';
    elseif strcmp(slice_type, 'Sagittal')
        slice_data = squeeze(volume(:,slice_index,:));
        slice_data = slice_data.'; % Transpose to rotate
        coord_label = 'x';
    elseif strcmp(slice_type, 'Coronal')
        slice_data = squeeze(volume(slice_index,:,:));
        slice_data = slice_data.';
        coord_label = 'y';
    end

    % Create figure and display the slice
    imshow(flipud(slice_data)); % Flip upside down as MATLAB array starts at top left
    title(sprintf('%s Slice (%s = %d)', slice_type, coord_label, slice_index));
    
    % Adjust aspect ratio for non-axial slices
    if ~strcmp(slice_type, 'Axial')
        daspect([sliceSpacing pixelSpacing 1]); 
    end
    
    % Customize Axes
    axis xy on; % Set axis origin to bottom left and visible
    set(gca, 'box', 'off'); % Remove axis on top and right
    
    % Set scale for tick marks based on the slice type
    if strcmp(slice_type, 'Axial')
        scale_x = pixelSpacing;
        scale_y = pixelSpacing;
    else
        scale_x = sliceSpacing;
        scale_y = pixelSpacing;
    end

    % Generate and set tick positions in mm and convert them to pixels
    generate_ticks = @(lim, spacing, scale) 0:spacing:(lim*scale);

    % Generate tick positions in mm
    x_tick_mm = generate_ticks(x_lim, 50, scale_x); 
    y_tick_mm = generate_ticks(y_lim, 50, scale_y);
    
    % Convert tick positions to pixels
    x_tick_pixels = x_tick_mm / scale_x;
    y_tick_pixels = y_tick_mm / scale_y;
    set(ax, 'XTick', x_tick_pixels, 'XTickLabel', x_tick_mm);
    set(ax, 'YTick', y_tick_pixels, 'YTickLabel', y_tick_mm);
    
    % Set axis labels based on the slice type
    if strcmp(slice_type, 'Axial')
        xlabel(ax, 'x (mm)');
        ylabel(ax, 'y (mm)');
    elseif strcmp(slice_type, 'Sagittal')
        xlabel(ax, 'y (mm)');
        ylabel(ax, 'z (mm)');
    elseif strcmp(slice_type, 'Coronal')
        xlabel(ax, 'x (mm)');
        ylabel(ax, 'z (mm)');
    end
    print(sprintf('%s Slice', slice_type), '-dsvg')
end