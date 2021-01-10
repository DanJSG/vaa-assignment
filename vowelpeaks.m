%VOWELPEAKS Function for detecting Vowel Onset Points from a Spectral
%           Energy signal.
% Determines where the VOPs fall in the spectrum. Returns the frequency
% spectrums of the vowels, the positioning of them in the spectral energy
% signal, the positioning of them in the audio signal and their peak
% amplitudes.
% Input arguments:
%   filteredDifferential - the processed spectral energy signal
%   audio - the input audio signal
%   Fs - the sample frequency of the audio signal
%   fftPoints - the number of sample points to use for the FFT
%   windowLength - the length of the window function in samples
function[vowelSpectrums, vowelPositions, vowelPeaks, ...
    vowelPositionSamples] = vowelpeaks(filteredDifferential, audio, ... 
    Fs, fftPoints, windowLength)
    
    % Define the minimum distance between VOPs as 200ms
    minPeakDistance = min([(200e-3 * Fs) / windowLength, 99]);
    
    % Find the initial vowel positions using peak picking
    [approxVowelPeaks, approxVowelPositions] = ...
        findpeaks(filteredDifferential, 'MinPeakDistance', minPeakDistance, ...
        'MinPeakHeight', 5);
       
    % The number of vowels
    nVowels = length(approxVowelPositions);
    
    % Zero pad the audio file 
    audio(end:end + fftPoints) = 0;
    
    % Initialise variables before main loop
    vowelSpectrums = zeros(nVowels, fftPoints);
    vowelPositions = zeros(nVowels, 1);
    vowelPeaks = zeros(nVowels, 1);
    nConfirmedVowels = 0;
    
    % Set the overlap between the windows and create the window
    overlap = windowLength / 2;
    window = hamming(windowLength);
    
    % Convert the vowel positions into audio signal samples
    vowelPositionSamples = approxVowelPositions * overlap;
    
    % Loop over each initially detected vowel
    for n=1:nVowels
        
        % Define the start and end samples for the FFT to be taken
        startPosition = vowelPositionSamples(n);
        endPosition = startPosition + windowLength - 1;
        
        % If the end position is greater than the length of the audio then
        % zero pad
        if endPosition > length(audio)
            audio(startPosition + windowLength - 1:endPosition + 1) = 0;
        end
        
        % Take a frame of the audio and calculated the frequency spectrum
        frame = audio(startPosition:endPosition) .* window;
        frameSpectrum = abs(fft(frame, fftPoints));
        
        % Remove frequencies below 150 Hz
        lowFrequencyRemovalIndex = ceil(150 / ((Fs / 2) / (fftPoints / 2)));
        frameSpectrum(1:lowFrequencyRemovalIndex) = 0;

        % Find the max value of the spectrum
        [~, maxPeakLocation] = max(frameSpectrum(1:fftPoints / 2));
        
        % Define the highest possible first formant frequency as 1500 Hz
        highestFirstFormant = ceil(1500 / ((Fs / 2) / (fftPoints / 2)));
        
        % Check if the max peak falls below the highest first formant.
        % If it does then save it, else discard it as it cannot be a vowel.
        if maxPeakLocation < highestFirstFormant
            nConfirmedVowels = nConfirmedVowels + 1;
            vowelPositions(nConfirmedVowels) = approxVowelPositions(n);
            vowelPeaks(nConfirmedVowels) = approxVowelPeaks(n);
            vowelSpectrums(nConfirmedVowels, :) = frameSpectrum;
        end

    end
    
    % Populate the output variables
    vowelSpectrums = vowelSpectrums(1:nConfirmedVowels, :);
    vowelPositions = vowelPositions(1:nConfirmedVowels);
    vowelPeaks = vowelPeaks(1:nConfirmedVowels);
    vowelPositionSamples = vowelPositions * overlap;
    
end
