function[vowelFormants] = vowelformants(spectrums, fftPoints, Fs)
    
    nConfirmedVowels = length(spectrums(:, 1));
    disp(nConfirmedVowels);
    frequencyIndex = linspace(1, Fs / 2, fftPoints / 2);
    
    vowelFormants = zeros(nConfirmedVowels, 2);
    for n=1:nConfirmedVowels
%         currentSpectrum = vowelSpectrums(n, 1:fftPoints / 2);

        % Minimum number of samples between F1 and F2
        minDifferenceSamples = ceil(200 / ((Fs / 2) / (fftPoints / 2)));

        % Sample points for max and min formant frequencies
        lowestF1 = ceil(200 / ((Fs / 2) / (fftPoints / 2)));
        highestF1 = ceil(1000 / ((Fs / 2) / (fftPoints / 2)));
        lowestF2 = ceil(550 / ((Fs / 2) / (fftPoints / 2)));
        highestF2 = ceil(2700 / ((Fs / 2) / (fftPoints / 2)));

        % 1st formant search spectrum
        f1Spectrum = spectrums(n, 1:fftPoints / 2);
        f1Spectrum(1:lowestF1) = 0;
        f1Spectrum(highestF1:end) = 0;

        [~, f1Location] = findpeaks(f1Spectrum, 'SortStr', 'descend', 'NPeaks', 1);

        % 2nd formant search spectrum
        f2Spectrum = spectrums(n, 1:fftPoints / 2);
        f2Spectrum(1:max([lowestF2, f1Location + minDifferenceSamples])) = 0;
        f2Spectrum(highestF2:end) = 0;

        [~, f2Location] = findpeaks(f2Spectrum, 'SortStr', 'descend', 'NPeaks', 1);

        vowelFormants(n, 1) = frequencyIndex(f1Location);
        vowelFormants(n, 2) = frequencyIndex(f2Location);

    end

end