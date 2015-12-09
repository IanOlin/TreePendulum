%% Simulate

%simulationAngles = [180; 90; 90+1; -90+2; 0; 0; 0; 0];
simulationAngles = [180; 90; 90+5; -90+4; 0; 0; 0; 0];
treePenduloom(simulationAngles, 1, 0, 0, 0);

%% Energy plot

simulationAngles = [180; 90; 90+1; -90+2; 0; 0; 0; 0];
treePenduloom(simulationAngles, 0, 1, 0, 0);

%% Speed cutoff
simulationAngles = [180; 90; 90+1; -90+2; 0; 0; 0; 0];
treePenduloom(simulationAngles, 0, 0, 0, 1);

%% Heat Map - Calculations

BaseAngles = [180; 90; 90; -90; 0; 0; 0; 0];
angleDifference = 10; % degrees
nOfAngles = 50;

Epsilons = linspace(-angleDifference, angleDifference, nOfAngles); % The angles differences - *2 because the vector goes from the negative value to the 
LongestSlowTime = zeros(nOfAngles);                                % Pre allocate like there's no tomorrow


for i = 1:nOfAngles
    for j = 1:nOfAngles
        SlowTimes = treePenduloom( BaseAngles + [0; 0; Epsilons(i); Epsilons(j); 0; 0; 0; 0], 0, 0, 0, 0 );
        LongestSlowTime(i,j) = max( SlowTimes(2:end) );
    end
end

%% Heat Map - Plotting

imagesc(Epsilons, Epsilons, LongestSlowTime)
