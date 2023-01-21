function [rawWaveformsFull, rawWaveformsPeakChan] = bc_extractRawWaveformsFast(param, spikeTimes_samples, spikeTemplates,...
    reExtract, savePath, verbose)
% JF, Get raw waveforms for all templates and estimate maximum drift for
% each unit 
% ------
% Inputs
% ------
% param with:
% rawFile: raw .bin or .dat file location
% nChannels: number of recorded channels (including sync), (eg 385)
% nSpikesToExtract: number of spikes to extract per template
%
% spikeTimes_samples: nSpikes × 1 uint64 vector giving each spike time in samples (*not* seconds)
% spikeTemplates: nSpikes × 1 uint32 vector giving the identity of each
%   spike's matched template
% verbose: boolean, display progress bar or not
% savePath, where to save output data
% ------
% Outputs
% ------
% rawWavefromsFull: nUnits x nTimePoints x nChannels single matrix of 
%  mean raw waveforms for each unit and channel
% rawWaveformsPeakChan: nUnits x 1 vector of each unit's channel with the maximum
%   amplitude
% maximumDriftEstimate
% ------
% Reference
% ------
% for drift estimate: Siegle, J.H., Jia, X., Durand, S. et al. Survey of spiking in the mouse 
% visual system reveals functional hierarchy. Nature 592, 86–92 (2021). https://doi.org/10.1038/s41586-020-03171-x
% from the paper: To compute the maximum drift for one unit, 
% the peak channel was calculated from the top principal 
% components of every spike. Next, the peak channel values are 
% binned in 51-s intervals, and the median value is calculated 
% across all spikes in each bin (assuming at least 10 spikes 
% per bin). The maximum drift is defined as the difference 
% between the maximum peak channel and the minimum peak channel
% across all bins. The average maximum drift across all units
% is used to identify sessions with a high amount of probe 
% motion relative to the brain.

%% Check if data already extracted
rawWaveformFolder = dir(fullfile(savePath, 'templates._bc_rawWaveforms.npy'));
old_rawWaveformFolder = dir(fullfile(savePath, 'templates._jf_rawWaveforms.npy'));

if ~isempty(rawWaveformFolder) && reExtract == 0

    rawWaveformsFull = readNPY(fullfile(savePath, 'templates._bc_rawWaveforms.npy'));
    rawWaveformsPeakChan = readNPY(fullfile(savePath, 'templates._bc_rawWaveformPeakChannels.npy'));

elseif ~isempty(old_rawWaveformFolder) && reExtract == 0
    rawWaveformsFull = readNPY(fullfile(savePath, 'templates._jf_rawWaveforms.npy'));
    rawWaveformsPeakChan = readNPY(fullfile(savePath, 'templates._jf_rawWaveformPeakChannels.npy'));

else
    %% Initialize stuff
    % Get spike times and indices
    nChannels = param.nChannels; % (385)
    nSpikesToExtract = param.nRawSpikesToExtract;
    spikeWidth = param.SpikeWidth;
    halfWid = floor(spikeWidth / 2);
    dataTypeNBytes = numel(typecast(cast(0, 'uint16'), 'uint8'));
    clustInds = unique(spikeTemplates);
    nClust = numel(clustInds);
    rawFileInfo = dir(param.rawFile);

    if ~isfolder(fullfile(savePath))
        mkdir(savePath)
    end
    if param.saveMultipleRaw && ~isfolder(fullfile(rawFileInfo.folder,['RawWaveforms_' rawFileInfo.name]))
        mkdir(fullfile(rawFileInfo.folder,['RawWaveforms_' rawFileInfo.name]))
    end

    fprintf('Extracting raw waveforms from %s ... \n', param.rawFile)
    % Get binary file name
    fid = fopen(param.rawFile, 'r');

    %% Interate over spike clusters and find all the data associated with them
    rawWaveforms = struct;
    if nChannels == 385
        rawWaveformsFull = nan(nClust, nChannels-1, spikeWidth);% Remove sync
    else
        rawWaveformsFull = nan(nClust, nChannels, spikeWidth); 
    end
    rawWaveformsPeakChan = nan(nClust, 1);

    for iCluster = 1:nClust
        rawWaveforms(iCluster).clInd = clustInds(iCluster);
        rawWaveforms(iCluster).spkInd = spikeTimes_samples(spikeTemplates == clustInds(iCluster));
        if numel(rawWaveforms(iCluster).spkInd) >= nSpikesToExtract
            spksubi = round(linspace(1, numel(rawWaveforms(iCluster).spkInd), nSpikesToExtract))';
            rawWaveforms(iCluster).spkIndsub = rawWaveforms(iCluster).spkInd(spksubi);
        else
            rawWaveforms(iCluster).spkIndsub = rawWaveforms(iCluster).spkInd;
        end
        nSpkLocal = numel(rawWaveforms(iCluster).spkIndsub);

        rawWaveforms(iCluster).spkMap = nan(384, spikeWidth, nSpkLocal);
        for iSpike = 1:nSpkLocal
            thisSpikeIdx = rawWaveforms(iCluster).spkIndsub(iSpike);
                
            if thisSpikeIdx > halfWid && (thisSpikeIdx + halfWid) * dataTypeNBytes < rawFileInfo.bytes % check that it's not out of bounds

                bytei = ((thisSpikeIdx - halfWid) * nChannels) * dataTypeNBytes;
                fseek(fid, bytei, 'bof');
                data0 = fread(fid, nChannels*spikeWidth, 'int16=>int16'); % read individual waveform from binary file
                frewind(fid);
                data = reshape(data0, nChannels, []);
                %         if whitenBool
                %             [data, mu, invMat, whMat]=whiten(double(data));
                %         end
                %         if size(data, 2) == spikeWidth
                %             rawWaveforms(iCluster).spkMap(:, :, iSpike) = data;
                %         end
                if size(data, 2) == spikeWidth && nChannels == 385
                    rawWaveforms(iCluster).spkMap(:, :, iSpike) = data(1:nChannels-1, :, :); %remove sync channel
                elseif size(data, 2) == spikeWidth
                    rawWaveforms(iCluster).spkMap(:, :, iSpike) = data(1:nChannels, :, :);
                end
            end
        end
        if param.saveMultipleRaw
            tmpspkmap = permute(rawWaveforms(iCluster).spkMap,[2,1,3]); % Compatible with UnitMatch QQ
            writeNPY(tmpspkmap, fullfile(rawFileInfo.folder,['RawWaveforms_' rawFileInfo.name],['Unit' num2str(iCluster) '_RawSpikes.npy']))
        end

        rawWaveforms(iCluster).spkMapMean = nanmean(rawWaveforms(iCluster).spkMap, 3);
        rawWaveformsFull(iCluster,:, :) = rawWaveforms(iCluster).spkMapMean - mean(rawWaveforms(iCluster).spkMapMean(:, 1:10), 2);

        spkMapMean_sm = smoothdata(rawWaveforms(iCluster).spkMapMean, 1, 'gaussian', 5);

        [~, rawWaveformsPeakChan(iCluster)] = max(max(spkMapMean_sm, [], 2)-min(spkMapMean_sm, [], 2));
             %figure();
            %plot(spkMapMean_sm(rawWaveformsPeakChan(iCluster),:))

        if (mod(iCluster, 100) == 0 || iCluster == nClust) && verbose
            fprintf(['\n   Finished ', num2str(iCluster), ' of ', num2str(nClust), ' units.']);
        end

    end

    fclose(fid);
 
    writeNPY(rawWaveformsFull, fullfile(savePath, 'templates._bc_rawWaveforms.npy'))
    writeNPY(rawWaveformsPeakChan, fullfile(savePath, 'templates._bc_rawWaveformPeakChannels.npy'))
end


end