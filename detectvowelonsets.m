
[audio, Fs] = audioread("clips\london1.wav");

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

% Zero pad audio to match window and overlap length
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
    
    % Take the FFT and get the frequency spectrum of the frame
    frameSpectrum = abs(fft(frame, windowLength));
    
    % Calculate the top 10 spectral 
    [spectralPeakValues, spectralPeakLocations] = ...
        findpeaks(frameSpectrum, 'SortStr', 'descend', 'NPeaks', 10, 'MinPeakHeight', 10);
    
    spectralSums(n) = sum(spectralPeakValues);
    
end

spectralSumTime = 1:length(spectralSums);

peakDistance = min([(150e-3 * Fs) / windowLength, 99]);

firstOrderDifferential = gradient(spectralSums(:)) ./ gradient(1:length(spectralSums));
firstOrderDifferential = firstOrderDifferential(:, 1);

gaussianWindow = gausswin(8);
gaussianFiltered = filter(gaussianWindow, 1, firstOrderDifferential);

gaussianFiltered(gaussianFiltered < 0) = 0;

[vowelPeaks, vowelPositions] = findpeaks(gaussianFiltered, ...
    'MinPeakDistance', peakDistance);

nVowels = length(vowelPositions);

fftPoints = 4096;
audio(end:end + fftPoints) = 0;
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
    
    lowFrequencyRemovalIndex = ceil(200 / ((Fs / 2) / (fftPoints / 2)));
    frameSpectrum(1:lowFrequencyRemovalIndex) = 0;
    
    [maxPeak, maxPeakLocation] = max(frameSpectrum(1:fftPoints / 2));
    highestFirstFormant = ceil(1500 / ((Fs / 2) / (fftPoints / 2)));

    if maxPeakLocation < highestFirstFormant
        nConfirmedVowels = nConfirmedVowels + 1;
        confirmedVowelPositions(nConfirmedVowels) = vowelPositions(n);
        confirmedVowelPeaks(nConfirmedVowels) = vowelPeaks(n);
        vowelSpectrums(nConfirmedVowels, :) = frameSpectrum;
        continue;
    end
    
    disp(maxPeakLocation);
    figure(10 + n);
    semilogx(frameSpectrum(1:end / 2));
       
end

vowelSpectrums = vowelSpectrums(1:nConfirmedVowels, :);
confirmedVowelPositions = confirmedVowelPositions(1:nConfirmedVowels);
confirmedVowelPeaks = confirmedVowelPeaks(1:nConfirmedVowels);
confirmedVowelPositionSamples = confirmedVowelPositions * overlap;

vowelFormants = zeros(nConfirmedVowels, 2);
for n=1:nConfirmedVowels
%     currentSpectrum = vowelSpectrums(n, 1:fftPoints / 2);
    
    % Minimum number of samples between F1 and F2
    minDifferenceSamples = ceil(200 / ((Fs / 2) / (fftPoints / 2)));
    
    % Sample points for max and min formant frequencies
    lowestF1 = ceil(200 / ((Fs / 2) / (fftPoints / 2)));
    highestF1 = ceil(1000 / ((Fs / 2) / (fftPoints / 2)));
    lowestF2 = ceil(550 / ((Fs / 2) / (fftPoints / 2)));
    highestF2 = ceil(2700 / ((Fs / 2) / (fftPoints / 2)));
    
    % 1st formant search spectrum
    f1Spectrum = vowelSpectrums(n, 1:fftPoints / 2);
    f1Spectrum(1:lowestF1) = 0;
    f1Spectrum(highestF1:end) = 0;
    
    [f1Peak, f1Location] = findpeaks(f1Spectrum, 'SortStr', 'descend', 'NPeaks', 1);
    
    % 2nd formant search spectrum
    f2Spectrum = vowelSpectrums(n, 1:fftPoints / 2);
    f2Spectrum(1:max([lowestF2, f1Location + minDifferenceSamples])) = 0;
    f2Spectrum(highestF2:end) = 0;
    
    [f2Peak, f2Location] = findpeaks(f2Spectrum, 'SortStr', 'descend', 'NPeaks', 1);
    
    vowelFormants(n, 1) = frequencyIndex(f1Location);
    vowelFormants(n, 2) = frequencyIndex(f2Location);
    
end

hold off;
figure(1);
plot(spectralSums);
hold on;
plot(gaussianFiltered);
plot(confirmedVowelPositions, confirmedVowelPeaks, 'x', 'Color', 'black', 'LineWidth', 2);
legend(["Sums", "Smoothed Derivative", "Peaks"]);
hold off;

figure(2);
plot(audio);
hold on;
for n=1:nConfirmedVowels
    xline(confirmedVowelPositionSamples(n), 'LineWidth', 2, 'Color', 'red');
end
hold off;

figure(2 + nConfirmedVowels + 1);
hold on;
for n=1:nConfirmedVowels
    plot(vowelFormants(n, 1), vowelFormants(n, 2), 'x');
end
hold off;

