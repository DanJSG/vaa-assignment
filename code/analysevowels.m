% Clear variables, refresh console, close existing plots
clear;
clc;
close all;

% Load the audio file
[audio, Fs] = audioread("../audio/brooklyn2.wav");

% Define the window length and number of points for the FFT
windowLength = 2048;
fftPoints = 4096;

% Preprocess the audio: convert to mono, normalize, fade in and out
audio = monoconvert(audio);
audio = (audio / max(abs(audio)));
audio = dualfade(audio, Fs, 5e-3);

% Calculate the spectral peaks energy of the signal 
spectralPeaksSignal = spectralpeaks(audio, windowLength);
% Calculate the first order differential of the spectral peaks signal
firstOrderDifferential = gradient(spectralPeaksSignal(:)) ./ gradient(1:length(spectralPeaksSignal))';

% Apply Gaussian window in frequency domain AKA convolve with FOGD operator
gaussianWindow = gausswin(8);
gaussianFiltered = filter(gaussianWindow, 1, firstOrderDifferential);

% Clip values below 0 to 0
gaussianFiltered(gaussianFiltered < 0) = 0;

% Estimate the vowel positions
[vowelSpectrums, vowelPositions, vowelPeaks, ...
    vowelPositionSamples] = vowelpeaks(gaussianFiltered, audio, Fs, fftPoints, windowLength);

% Extrac the formants of the vowels
formantFreqs = vowelformants(audio, Fs, vowelPositionSamples, windowLength, fftPoints);

% Estimate the vowels based on the formant frequencies
vowels = estimatevowels(formantFreqs);

% Display the detected VOPs in the console
disp("******* DETECTED VOPS ******" + newline);
disp(vowelPositionSamples ./ Fs);
disp("****************************" + newline);

% Display the extracted formant frequencies in the console
disp("**** EXTRACTED FORMANTS ****" + newline);
disp(formantFreqs);
disp("****************************" + newline);

% Display the estimated vowels in the console.
disp("***** ESTIMATED VOWELS *****" + newline);
disp(vowels);
disp("****************************" + newline);

% Plot the audio's waveform with the vowel onset points labelled on it.
tDomain = linspace(0, length(audio) / Fs, length(audio));
figure(1);
hold on;
plot(tDomain, audio);
title("Audio Signal with Labelled Vowel Onset Positions");
xlabel("Time (s)");
ylabel("Amplitude");
for n=1:length(vowelPositionSamples)
    xline(tDomain(vowelPositionSamples(n)), 'LineWidth', 2, 'Color', 'red');
end
legend(["Audio", "Vowel Onset Points"]);
hold off;
