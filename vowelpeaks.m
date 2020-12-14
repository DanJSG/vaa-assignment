function[vowelSpectrums, vowelPositions, vowelPeaks, ...
    vowelPositionSamples] = vowelpeaks(filteredDifferential, audio, ... 
    Fs, fftPoints, windowLength)
    
    overlap = windowLength / 2;
    window = hamming(windowLength);

    minPeakDistance = min([(200e-3 * Fs) / windowLength, 99]);

    [approxVowelPeaks, approxVowelPositions] = ...
        findpeaks(filteredDifferential, 'MinPeakDistance', minPeakDistance, ...
        'MinPeakHeight', 5);
    
    disp(approxVowelPositions);
    
    approxVowelPositions = approxVowelPositions;
    
    disp(approxVowelPositions);
    
    nVowels = length(approxVowelPositions);

    audio(end:end + fftPoints) = 0;
    vowelSpectrums = zeros(nVowels, fftPoints);

    vowelPositions = zeros(nVowels, 1);
    vowelPeaks = zeros(nVowels, 1);
    nConfirmedVowels = 0;

    vowelPositionSamples = approxVowelPositions * overlap;

    for n=1:nVowels
        startPosition = vowelPositionSamples(n);
        endPosition = startPosition + windowLength - 1;
    
        if endPosition > length(audio)
            audio(startPosition + windowLength - 1:endPosition + 1) = 0;
        end
        
        frame = audio(startPosition:endPosition) .* window;
        frameSpectrum = abs(fft(frame, fftPoints));

        lowFrequencyRemovalIndex = ceil(200 / ((Fs / 2) / (fftPoints / 2)));
        frameSpectrum(1:lowFrequencyRemovalIndex) = 0;

        [~, maxPeakLocation] = max(frameSpectrum(1:fftPoints / 2));
        highestFirstFormant = ceil(1500 / ((Fs / 2) / (fftPoints / 2)));

        if maxPeakLocation < highestFirstFormant
            nConfirmedVowels = nConfirmedVowels + 1;
            vowelPositions(nConfirmedVowels) = approxVowelPositions(n);
            vowelPeaks(nConfirmedVowels) = approxVowelPeaks(n);
            vowelSpectrums(nConfirmedVowels, :) = frameSpectrum;
        end

    end

    vowelSpectrums = vowelSpectrums(1:nConfirmedVowels, :);
    vowelPositions = vowelPositions(1:nConfirmedVowels);
    vowelPeaks = vowelPeaks(1:nConfirmedVowels);
    vowelPositionSamples = vowelPositions * overlap;

end
