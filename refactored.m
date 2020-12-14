[audio, Fs] = audioread("clips\london1.wav");

windowLength = 1024;
fftPoints = 4096;

audio = monoconvert(audio);
audio = normalize(audio, 'range', [-1, 1]);
audio = dualfade(audio, Fs, 5e-3);

spectralPeaksSignal = spectralpeaks(audio, windowLength);

firstOrderDifferential = gradient(spectralPeaksSignal(:)) ./ gradient(1:length(spectralPeaksSignal));
firstOrderDifferential = firstOrderDifferential(:, 1);

gaussianWindow = gausswin(8);
gaussianFiltered = filter(gaussianWindow, 1, firstOrderDifferential);

gaussianFiltered(gaussianFiltered < 0) = 0;

[vowelSpectrums, vowelPositions, vowelPeaks, ...
    vowelPositionSamples] = vowelpeaks(gaussianFiltered, audio, Fs, fftPoints, windowLength);

vowelFormants = vowelformants(vowelSpectrums, fftPoints, Fs);

vowels = estimatevowels(vowelFormants);

% sound(audio, Fs);











hold off;
figure(1);
plot(spectralPeaksSignal);
hold on;
plot(gaussianFiltered);
plot(vowelPositions, vowelPeaks, 'x', 'Color', 'black', 'LineWidth', 2);
legend(["Sums", "Smoothed Derivative", "Peaks"]);
hold off;

figure(2);
plot(audio);
hold on;
for n=1:length(vowelPositions)
    xline(vowelPositionSamples(n), 'LineWidth', 2, 'Color', 'red');
end
hold off;

figure(2 + length(vowelPositions) + 1);
hold on;
for n=1:length(vowelPositions)
    plot(vowelFormants(n, 1), vowelFormants(n, 2), 'x');
end
hold off;