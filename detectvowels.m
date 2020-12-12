
[audio, Fs] = audioread("clips\brooklyn1.wav");

% Number of channels in the audio
nChannels = length(audio(1, :));

% If the file has more than 1 channel, convert to mono
if nChannels > 1
   audio(:, 1) =  0.5 * (audio(:, 1) + audio(:, 2));
   audio = audio(:, 1);
end

% Normalise the amplitude of the signal
audio = normalize(audio, 'range', [-1, 1]);

% Store the number of samples in the file
nAudioSamples = length(audio);

% Add 5ms fade in and out to avoid any strange cropping artifcats which
% sometimes occur
fadeTime = 5e-3; % 5ms
fadeSamples = floor(5e-3 * Fs);
fade = ones(nAudioSamples, 1);
fade(1:fadeSamples) = linspace(0, 1, fadeSamples);
fade(end - fadeSamples + 1:end) = linspace(1, 0, fadeSamples);
audio = audio .* fade;

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
        findpeaks(frameSpectrum, 'SortStr', 'descend', 'NPeaks', 10);
    
    spectralSums(n) = sum(spectralPeakValues);
    
end

spectralSumTime = 1:length(spectralSums);

peakDistance = min([(150e-3 * Fs) / windowLength, 99]);

firstOrderDifferential = gradient(spectralSums(:)) ./ gradient(1:length(spectralSums));
firstOrderDifferential = firstOrderDifferential(:, 1);

gaussianWindow = gausswin(8);
gaussianFiltered = filter(gaussianWindow, 1, firstOrderDifferential);

gaussianFiltered(gaussianFiltered < 0) = 0;

[vowelPeaks, vowelPositions] = findpeaks(gaussianFiltered, 'MinPeakDistance', peakDistance, 'MinPeakHeight', 0.2);

nVowels = length(vowelPositions);

fftPoints = 4096;
frequencyIndex = linspace(1, Fs / 2, fftPoints / 2);
vowelSpectrums = zeros(nVowels, fftPoints);

confirmedVowelPositions = zeros(nVowels, 1);
confirmedVowelPeaks = zeros(nVowels, 1);
nConfirmedVowels = 0;

vowelPositionSamples = vowelPositions * overlap;

for n=1:nVowels
    startPosition = vowelPositionSamples(n);
    endPosition = startPosition + windowLength - 1;
    
    frame = audio(startPosition:endPosition) .* window;
    frameSpectrum = abs(fft(frame, fftPoints));
    
    lowFrequencyRemovalIndex = ceil(80 / ((Fs / 2) / (fftPoints / 2)));
    frameSpectrum(1:lowFrequencyRemovalIndex) = 0;
    
    [maxPeak, maxPeakLocation] = max(frameSpectrum(1:fftPoints / 2));
    highestFirstFormant = ceil(1400 / ((Fs / 2) / (fftPoints / 2)));
    
    if maxPeakLocation < highestFirstFormant
        nConfirmedVowels = nConfirmedVowels + 1;
        confirmedVowelPositions(nConfirmedVowels) = vowelPositions(n);
        confirmedVowelPeaks(nConfirmedVowels) = vowelPeaks(n);
        vowelSpectrums(nConfirmedVowels, :) = frameSpectrum;
    end
    
end

vowelSpectrums = vowelSpectrums(1:nConfirmedVowels, :);
confirmedVowelPositions = confirmedVowelPositions(1:nConfirmedVowels);
confirmedVowelPeaks = confirmedVowelPeaks(1:nConfirmedVowels);

vowelFormants = zeros(nConfirmedVowels, 5);
for n=1:nConfirmedVowels
    [peaks, peakLocs] = findpeaks(vowelSpectrums(n, 1:fftPoints / 2), 'SortStr', 'descend', 'NPeaks', 5);
%     sampleIndices = peakLocs * overlap;
    vowelFormants(n, :) = frequencyIndex(peakLocs);
    vowelFormants(n, :) = sort(vowelFormants(n, :));
end



hold off;
figure(1);
plot(spectralSums);
hold on;
plot(gaussianFiltered);
plot(confirmedVowelPositions, confirmedVowelPeaks, 'x', 'Color', 'black', 'LineWidth', 2);
legend(["Sums", "Smoothed Derivative", "Peaks"]);
hold off;

confirmedVowelPositionSamples = confirmedVowelPositions * overlap;

figure(2);
plot(audio);
hold on;
for n=1:nConfirmedVowels
    xline(confirmedVowelPositionSamples(n), 'LineWidth', 2, 'Color', 'red');
end
hold off;

% figure(3);
% semilogx(frequencyIndex, vowelSpectrums(1, 1:end / 2));    
% hold on;

for n=1:nConfirmedVowels
    figure(2 + n);
    semilogx(frequencyIndex, vowelSpectrums(n, 1:end / 2));    
end
hold off;
% semilogx(vowelSpectrums(5, 1:end / 2));

% [peaks, locs] = findpeaks(vowelSpectrums(1, 1:end / 2), 'SortStr', );
