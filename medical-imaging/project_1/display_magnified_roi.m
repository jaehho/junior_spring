function display_magnified_roi(img, roi, magnification_factor, overlay_position, ax)
    roi_x = roi(1);
    roi_y = roi(2);
    roi_w = roi(3);
    roi_h = roi(4);
    overlay_x = overlay_position(1);
    overlay_y = overlay_position(2);

    % Display original image with fixed uint8 contrast in the subplot
    axes(ax);
    imshow(img, [0 255]);
    hold on;
    
    % Magnify the region of interest (ROI)
    magnified_region = imresize(img(roi_y:roi_y+roi_h, roi_x:roi_x+roi_w), magnification_factor);
    
    % Overlay magnified region
    h = imshow(magnified_region, [0 255]);
    set(h, 'XData', [overlay_x, overlay_x + size(magnified_region, 2)], ...
           'YData', [overlay_y, overlay_y + size(magnified_region, 1)]);
    
    % Draw a rectangle around the original region
    rectangle('Position', roi, 'EdgeColor', 'r', 'LineWidth', 2);
    
    % Draw a rectangle around the overlay magnified region
    rectangle('Position', [overlay_x, overlay_y, size(magnified_region, 2), size(magnified_region, 1)], ...
              'EdgeColor', 'b', 'LineWidth', 2); % Blue border around the overlay
    
    hold off;
end