%ESTIMATEVOWELS Function to estimate the vowel based on the first two
%               formants.
% Estimates vowel based on the first two formants and finding the closest
% average vowel position.
function[vowels] = estimatevowels(vowelFormants)
    
    % The number of vowels
    nVowels = length(vowelFormants);
    
    % Vowel symbol representations
    vowelSymbols = ...
        ["/i/", "/ɪ/", "/ɛ/", "/æ/", "/ʌ/", "/ɑ/", "/ɔ/", "/u/", "/ʊ/"];
    
    % The average vowel formants for the vowels
    vowelAverages = [
        [290, 2540]
        [410, 2235]
        [570, 2085]
        [760, 1885]
        [760, 1295]
        [790, 1155]
        [580, 880]
        [335, 910]
        [455, 1090]
    ];
    
    % Number of potential vowel positions
    nVowelZones = length(vowelAverages);
    
    % Number of actual vowels to find
    actualVowels = zeros(nVowels, 1);
    
    % Loops over each vowel
    for n=1:nVowels

        currentVowel = vowelFormants(n, :);
        
        % Initialises the distance from the average position to be very
        % high
        distanceToAverage = 10e6;
        closestVowelIndex = 0;
        % Loops through each vowel and uses the pythagorean theorem to
        % calculate closeness and determine which vowel it is nearest to
        for m=1:nVowelZones
           vowelAverage = vowelAverages(m, :);
           distance = ...
               sqrt( (vowelAverage(1) - currentVowel(1))^2 + (vowelAverage(2) - currentVowel(2))^2);
           if distance < distanceToAverage
              distanceToAverage = distance;
              closestVowelIndex = m;
           end
        end
        
        % Store the index of the actual vowel
        actualVowels(n) = closestVowelIndex;

    end
    
    % Convert the indexes of the actual vowels to their respective symbols
    vowels = vowelSymbols(actualVowels)';

end