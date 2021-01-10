%DUALFADE Function to fade an audio signal in and out by a specified time.
% Adds a fade in and fade out to the audio signal of a set amount of
% milliseconds.
% Input arguments:
%   audio - the audio signal to process
%   Fs - the sampling frequency of the audio signal
%   fadeTime - the fade in and out time in milliseconds
function[audio] = dualfade(audio, Fs, fadeTime)
    % Number of samples in the audio file
    nAudioSamples = length(audio);
    % Number of samples for the fade time
    fadeSamples = floor(fadeTime * Fs);
    
    % Set up fade array
    fade = ones(nAudioSamples, 1);
    fade(1:fadeSamples) = linspace(0, 1, fadeSamples);
    fade(end - fadeSamples + 1:end) = linspace(1, 0, fadeSamples);
    
    % Multiply by the fade array to apply the fade
    audio = audio .* fade;
end
