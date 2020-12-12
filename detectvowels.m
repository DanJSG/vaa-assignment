
[audio, Fs] = audioread("clips\brooklyn1.wav");

nChannels = length(audio(1, :));

% If the file has more than 1 channel, convert to mono
if nChannels > 1
   audio(:, 1) =  0.5 * (audio(:, 1) + audio(:, 2));
   audio = audio(:, 1);
end

% Store the number of samples in the file
nAudioSamples = length(audio);

% Normalise the amplitude of the signal
audio = normalize(audio, 'range', [-1, 1]);

% Create a window and set the overlap to be half the width of the window
windowLength = 1024;
window = hamming(windowLength);
overlap = windowLength / 2;

% Zero pad audio to match window length
paddingLength = (overlap * ceil(nAudioSamples / overlap)) - nAudioSamples;
audio(end:end + paddingLength) = 0;
nAudioSamples = length(audio);

spectralSums = zeros(nAudioSamples / overlap, 1);

for n=1:(nAudioSamples / overlap) - 1

    % Get the start and end samples of the frame
    startSample = overlap * (n - 1) + 1;
    endSample = startSample + windowLength - 1;

    % Window the frame of audio using the hamming window
    frame = audio(startSample:endSample) .* window;
    
    frameSpectrum = abs(fft(frame, windowLength));
    
    [spectralPeakValues, spectralPeakLocations] = ...
        findpeaks(frameSpectrum, 'SortStr', 'ascend', 'NPeaks', 10);
    
    spectralSums(n) = sum(spectralPeakValues);
    
end

spectralSumTime = 1:length(spectralSums);

plot(spectralSums);
hold on;
plot(audio);

