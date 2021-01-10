%MONOCONVERT Converts stereo audio files to mono.
% Converts stereo audio files to mono by summing the two channels into a
% single channel.
% Input arguments:
%   audio - the audio signal to convert
function[audio] = monoconvert(audio)
    
    % Number of channels in the audio
    nChannels = length(audio(1, :));

    % If the file has more than 1 channel, convert to mono
    if nChannels > 1
       audio(:, 1) =  0.5 * (audio(:, 1) + audio(:, 2));
       audio = audio(:, 1);
    end
    
end