function[audio] = dualfade(audio, Fs, fadeTime)
    nAudioSamples = length(audio);
    % Add fade in and out to avoid any strange cropping artifcats 
    fadeSamples = floor(fadeTime * Fs);
    fade = ones(nAudioSamples, 1);
    fade(1:fadeSamples) = linspace(0, 1, fadeSamples);
    fade(end - fadeSamples + 1:end) = linspace(1, 0, fadeSamples);
    audio = audio .* fade;
end