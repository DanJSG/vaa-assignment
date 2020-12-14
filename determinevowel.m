clear;
clc;

vowelFormants = [
    [205, 2564]         % /i/
    [233, 598]          % /u/
    [668, 1659]         % /ae/
];
nVowels = length(vowelFormants);

vowelSymbol = ["/i/", "/ɪ/", "/ɛ/", "/æ/", "/ʌ/", "/ɑ/", "/ɔ/", "/u/", "/ʊ/"];
vowelZones = [
    [200, 440, 1950, 3800]
    [300, 620, 1750, 3700]
    [480, 900, 1700, 3500]
    [600, 1240, 1550, 2750]
    [580, 1160, 1120, 1850]
    [660, 1320, 880, 1630]
    [400, 780, 540, 1140]
    [200, 400, 540, 1220]
    [400, 600, 880, 1440]
];
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


nVowelZones = length(vowelZones);

labeledVowelFormants = zeros(nVowels, nVowelZones + 1);
% labeledVowelFormants(:, 1:2) = vowelFormants;
for n=1:nVowels
    currentVowel = vowelFormants(n, :);
    nPossibleVowels = 0;
    possibleVowels = zeros(nVowelZones, 1);
    for m=1:nVowelZones
        if currentVowel(1) > vowelZones(m, 1) && ...
                currentVowel(1) < vowelZones(m, 2) && ...
                currentVowel(2) > vowelZones(m, 3) && ...
                currentVowel(2) < vowelZones(m, 4)
            nPossibleVowels = nPossibleVowels + 1;
            possibleVowels(nPossibleVowels) = m;
        end   
    end
    labeledVowelFormants(n, 1) = nPossibleVowels;
    labeledVowelFormants(n, 2:end) = possibleVowels;
end

actualVowels = zeros(nVowels, 1);
for n=1:nVowels
    currentVowel = vowelFormants(n, :);
    currentLabeledVowel = labeledVowelFormants(n, :);
    nPossibleVowels = currentLabeledVowel(1);
    if nPossibleVowels < 2
        actualVowels(n) = currentLabeledVowel(2);
        continue;
    end
    
    % Start with a very large number that the actual distance will always 
    % be smaller than and an invalid index
    distanceToAverage = 10e6;
    closestVowelIndex = 0;
    for m=1:nPossibleVowels
        possibleVowelIndex = currentLabeledVowel(m);
        vowelAverage = vowelAverages(possibleVowelIndex, :);
        distance = ... 
            sqrt( (vowelAverage(1) - currentVowel(1))^2 + (vowelAverage(2) - currentVowel(2))^2 );
        if distance < distanceToAverage
            distanceToAverage = distance;
            closestVowelIndex = possibleVowelIndex;
        end
    end
    
    actualVowels(n) = closestVowelIndex;
    
end

