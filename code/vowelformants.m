%VOWELFORMANTS Function for estimating the vowel formants of a signal.
% Takes an audio signal and a set of vowel onset points and estimates the
% first two formatns in the vowels using the LPC spectrum and peak picking.
% Input arguments:
%   audio - input audio signal
%   Fs - sampling frequency of the audio signal
%   vowelPositions - locations of the Vowel Onset Points (VOPs)
%   windowLength - the length of the window in samples
%   nFft - the number of samples to use in the FFT
function[vowelFormants] = vowelformants(audio, Fs, vowelPositions, windowLength, nFft)
    
    % Pre-define matrix for the vowel formants
    vowelFormants = zeros(length(vowelPositions), 2);
    
    % Loop through each VOP
    for n=1:length(vowelPositions)
        
        % Extract a frame of audio
        frame = audio(vowelPositions(n):vowelPositions(n) + windowLength - 1);
        
        % Calculate the LPC coefficients for that frame of audio
        lpcCoeffs = lpc(frame, 50);
        
        % Get the filter frequency and phase response of the LPC coefficients
        [lpcSpectrum, lpcFDomain] = freqz(1, lpcCoeffs, nFft, Fs);
        
        % Take the absolute value of the filter frequency response and crop
        % out the reflected section of the spectrum
        lpcSpectrum = abs(lpcSpectrum(1:nFft / 2));
        lpcFDomain = lpcFDomain(1:nFft / 2);
        
        % Find the top 3 peaks within this signal
        [~, formantPositions] = findpeaks(lpcSpectrum, 'NPeaks', 3);
        
        % Sort these peaks to be in order
        formantPositions = sort(formantPositions);
        
        % Convert peak locations to frequency
        formantFreqs = lpcFDomain(formantPositions);
        
        % Save the first two vowel formants for output
        vowelFormants(n, :) = formantFreqs(1:2);

    end

end