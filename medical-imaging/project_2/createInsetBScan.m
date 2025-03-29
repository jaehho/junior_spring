function hInset = createInsetBScan(ax, x, z, BScan, ROI, insetPos, varargin)
    % createInsetBScan creates an inset magnified view of a B-scan image.
    %
    %   hInset = createInsetBScan(ax, x, z, BScan, ROI, insetPos)
    %
    % Inputs:
    %   ax       - Handle to the main axes containing the full B-scan image.
    %   x        - Lateral axis vector corresponding to the columns of BScan.
    %   z        - Depth axis vector corresponding to the rows of BScan.
    %   BScan    - The B-scan image data (2D matrix).
    %   ROI      - Region of interest specified as [xmin, xmax, zmin, zmax] in data units.
    %   insetPos - Position vector for the inset axes [left, bottom, width, height]
    %              in normalized units relative to the figure.
    %
    % Optional Name-Value Pair Arguments:
    %   'ScaleFactor'      - Factor to scale the x and z axes (default: 1e3, e.g., m→mm).
    %   'RectColor'        - Color of the ROI rectangle on the main axes (default: 'r').
    %   'RectLineWidth'    - Line width of the ROI rectangle (default: 1.5).
    %   'InsetBorderColor' - Color of the border around the inset image (default: 'k').
    %   'InsetBorderWidth' - Line width of the border around the inset image (default: 2).
    %
    % Output:
    %   hInset - Handle to the inset axes.
    %
    % Example usage:
    %   % After displaying your main B-scan image:
    %   ROI = [0.002, 0.004, 0.001, 0.003];  % [xmin, xmax, zmin, zmax] in data units
    %   insetPos = [0.6, 0.6, 0.25, 0.25];     % Inset position in normalized figure units
    %   hInset = createInsetBScan(gca, x, z, BScan_cropped, ROI, insetPos);
    %
    
    % Parse optional parameters
    p = inputParser;
    addParameter(p, 'ScaleFactor', 1e3);
    addParameter(p, 'RectColor', 'r');
    addParameter(p, 'RectLineWidth', 1.5);
    addParameter(p, 'InsetBorderColor', 'k');
    addParameter(p, 'InsetBorderWidth', 2);
    parse(p, varargin{:});
    sf = p.Results.ScaleFactor;
    rectColor = p.Results.RectColor;
    rectLineWidth = p.Results.RectLineWidth;
    insetBorderColor = p.Results.InsetBorderColor;
    insetBorderWidth = p.Results.InsetBorderWidth;
    
    % Draw the ROI rectangle on the main axes (border around the magnified region)
    axes(ax);  % Ensure ax is the current axes
    rectWidth  = ROI(2) - ROI(1);
    rectHeight = ROI(4) - ROI(3);
    rectangle('Position', [ROI(1), ROI(3), rectWidth, rectHeight], ...
              'EdgeColor', rectColor, 'LineWidth', rectLineWidth);
    
    % Determine the indices corresponding to the ROI boundaries
    [~, ix1] = min(abs(x - ROI(1)));
    [~, ix2] = min(abs(x - ROI(2)));
    [~, iz1] = min(abs(z - ROI(3)));
    [~, iz2] = min(abs(z - ROI(4)));
    
    % Ensure indices are in the proper order
    if ix1 > ix2, [ix1, ix2] = deal(ix2, ix1); end
    if iz1 > iz2, [iz1, iz2] = deal(iz2, iz1); end
    
    % Create the inset axes on the same figure using the specified position
    fig = ancestor(ax, 'figure');
    hInset = axes('Position', insetPos);
    
    % Plot the magnified ROI region in the inset axes
    imagesc(x(ix1:ix2) * sf, z(iz1:iz2) * sf, BScan(iz1:iz2, ix1:ix2));
    colormap(hInset, 'gray');
    axis image;
    axis off;  % Remove axes from the inset
    
    % Add a border around the inset image using an annotation (normalized to the figure)
    annotation(fig, 'rectangle', insetPos, 'Color', insetBorderColor, 'LineWidth', insetBorderWidth);
    
    end
    