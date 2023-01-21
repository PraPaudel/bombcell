%bc_qualityParamValues
param = struct;

%% calculating quality metrics parameters 
% plotting parameters 
param.plotDetails = 0; % generates a lot of plots, 
% mainly good if you running through the code line by line to check things,
% to debug, or to get nice plots for a presentation
param.plotGlobal = 1; % plot summary of quality metrics 
param.verbose = 1; % update user on progress
param.reextractRaw = 0; % re extract raw waveforms or not 

% saving parameters 
param.saveAsParquet = 1; % save outputs at .parquet file 
param.saveAsMat = 1; % save outputs at .mat file - useful for GUI

% amplitude parameters
param.ephysMetaFile = [ephysMetaDir.folder, filesep, ephysMetaDir.name];
param.nRawSpikesToExtract = 100; % how many raw spikes to extract for each unit 
param.saveMultipleRaw = 1; % If you wish to save the nRawSpikesToExtract as well
param.decompressData = 1; % whether to decompress .cbin ephys data 

% refractory period parameters
param.tauR = 0.0020; % refractory period time (s)
param.tauC = 0.0001; % censored period time (s)

% percentage spikes missing parameters 
param.computeTimeChunks = 1; % compute fraction refractory period violations 
% and percent sp[ikes missing for different time chunks 
param.deltaTimeChunk = 360; %time in seconds 

% presence ratio 
param.presenceRatioBinSize = 60; % in seconds 

% drift estimate
param.driftBinSize = 60; % in seconds

% waveform parameters
param.waveformBaselineWindow = [20, 30]; % in samples 
param.minThreshDetectPeaksTroughs = 0.2; % this is multiplied by the max value 
% in a units waveform to give the minimum prominence to detect peaks using
% matlab's findpeaks function.

% recording parametrs
param.ephys_sample_rate = 30000; % samples per second
param.nChannels = 385; %number of recorded channels (including any sync channels)
% recorded in the raw data. This is usually 384 or 385 for neuropixels
% recordings

% distance metric parameters
param.computeDistanceMetrics = 0; % whether to compute distance metrics - this can be time consuming 
param.nChannelsIsoDist = 4; % number of nearby channels to use in distance metric computation 


%% classifying units into good/mua/noise parameters 
param.minAmplitude = 20; 
param.maxRPVviolations = 10;
param.maxPercSpikesMissing = 20;
param.minNumSpikes = 300;

%waveform 
param.maxNPeaks = 2;
param.maxNTroughs = 1;
param.somatic = 1; 
param.minWvDuration = 100; % in us
param.maxWvDuration = 800; % in us
param.minSpatialDecaySlope = -0.001;
param.maxWvBaselineFraction = 0.3;

%distance metrics
param.isoDmin = 20; 
param.lratioMax = 0.1;
param.ssMin = NaN; 