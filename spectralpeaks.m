%SPECTRALPEAKS Function for calculating the spectral peaks energy of a
%              signal.
% Sums the largest 10 spectral peaks for the input signal at each window of
% data.
% Input arguments:
%   audio - the input audio signal
%   windowLength - the length of the window in samples
function[spectralPeaksSignal] = spectralpeaks(audio, windowLength)

    % Get the length of the input audio
    nAudioSamples = length(audio);

    % Create a window and set the overlap to be half the width of the window
    window = hamming(windowLength);
    overlap = windowLength / 2;

    % Zero pad audio to match window and overlap length
    paddingLength = (overlap * ceil(nAudioSamples / overlap)) - nAudioSamples;
    audio(end:end + paddingLength) = 0;
    nAudioSamples = length(audio);

    spectralPeaksSignal = zeros(nAudioSamples / overlap, 1);
    
    % Loop over each frame
    for n=1:(nAudioSamples / overlap) - 1
        % Get the start and end samples of the frame
        startSample = overlap * (n - 1) + 1;
        endSample = startSample + windowLength - 1;
        % Window the frame of audio using the hamming window
        frame = audio(startSample:endSample) .* window;
        % Take the absolute value of the FFT of the frame
        frameSpectrum = abs(fft(frame, windowLength));
        % Pick the 10 largest valued spectral peaks
        [spectralPeakValues, ~] = ...
            findpeaks(frameSpectrum, 'SortStr', 'descend', 'NPeaks', 10);
        % Sum the spectral peaks for the current sample
        spectralPeaksSignal(n) = sum(spectralPeakValues);
    end
    
end
