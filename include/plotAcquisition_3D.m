% function plotAcquisition_3D(acqResults)
%     % Load the data
%     dopplerFreq = acqResults.carrFreq;    % Doppler frequency
%     codePhase = acqResults.codePhase;     % Code phase
%     peakMetric = acqResults.peakMetric;   % Acquisition metric
% 
%     % Verify if the data is valid
%     if isempty(dopplerFreq) || isempty(codePhase) || isempty(peakMetric)
%         error('Acquisition results are empty or invalid.');
%     end
% 
%     % Build the grid
%     dopplerUnique = unique(dopplerFreq);   % The only Doppler value
%     codePhaseUnique = unique(codePhase);  % The only Code phase value
%     [dopplerGrid, codePhaseGrid] = meshgrid(dopplerUnique, codePhaseUnique);
% 
%     % Initialize Acquisition metric
%     acquisitionMetric = zeros(size(dopplerGrid));
% 
%     % Fill Acquisition metric
%     for i = 1:length(peakMetric)
%         % Find the corresponding Doppler and Code phase index
%         dopplerIdx = dopplerUnique == dopplerFreq(i);
%         codePhaseIdx = codePhaseUnique == codePhase(i);
% 
%         % Fill the Acquisition metric
%         acquisitionMetric(codePhaseIdx, dopplerIdx) = peakMetric(i);
%     end
% 
%     % Drawing 3D Shapes
%     figure;
%     surf(dopplerGrid, codePhaseGrid, acquisitionMetric);
%     title('3D Acquisition Results');
%     xlabel('Doppler Frequency [Hz]');
%     ylabel('Code Phase [samples]');
%     zlabel('Acquisition Metric');
%     colormap('jet');      % Set the color map
%     shading interp;       % Make the display smooth
%     colorbar;             % Show the color bar
% end

function plotAcquisition_3D(acqResults)
    % Load the data
    dopplerFreq = acqResults.carrFreq;    % Doppler frequency
    codePhase = acqResults.codePhase;     % Code phase
    peakMetric = acqResults.peakMetric;   % Acquisition metric

    % Verify if the data is valid
    if isempty(dopplerFreq) || isempty(codePhase) || isempty(peakMetric)
        error('Acquisition results are empty or invalid.');
    end

    % Determine the grid range
    dopplerMin = min(dopplerFreq);
    dopplerMax = max(dopplerFreq);
    codePhaseMin = min(codePhase);
    codePhaseMax = max(codePhase);

    % Build the mesh (make sure it is evenly spaced)
    dopplerUnique = linspace(dopplerMin, dopplerMax, 100);   % 100 points
    codePhaseUnique = linspace(codePhaseMin, codePhaseMax, 100); % 100 points
    [dopplerGrid, codePhaseGrid] = meshgrid(dopplerUnique, codePhaseUnique);

    % Initialize the Acquisition metric matrix
    acquisitionMetric = zeros(size(dopplerGrid));

    % Populate the Acquisition metric matrix
    for i = 1:length(peakMetric)
        % Find the closest grid point index
        [~, dopplerIdx] = min(abs(dopplerUnique - dopplerFreq(i)));
        [~, codePhaseIdx] = min(abs(codePhaseUnique - codePhase(i)));

        % Populate the Acquisition metric value
        acquisitionMetric(codePhaseIdx, dopplerIdx) = peakMetric(i);
    end

    % Drawing 3D Shapes
    figure;
    surf(dopplerGrid, codePhaseGrid, acquisitionMetric);
    title('3D Acquisition Results');
    xlabel('Doppler Frequency [Hz]');
    ylabel('Code Phase [samples]');
    zlabel('Acquisition Metric');
    colormap('jet');      % Setting the Color Map
    shading interp;       % Smooth display
    colorbar;             % Show Color Bar
end