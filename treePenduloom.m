function res = treePenduloom(Initial, showSimulation, showEnergy, showSpeedPlot, showCutoffPlot)
% showSimulation, showEnergy and showSpeedPlot are bool
clf;

g = 9.81;           % m.s^-2    Gravity constant
m = 70;             % kg        Mass of thing
l = 1;              % m         Length of rod
simTime = 10;       % s         Simulation Time
timeStep = 0.02;    % s
speedCutoff = 0.05; % m.s^-1


% %                    [th1; th2; th3; th5; velocities]
% initialDataDegrees = [178; -70; 190; 110; 0; 0; 0; 0]; % [theta1; theta2; theta3; theta1'; theta2'; theta3';]
initialDataDegrees = Initial;

                % Put it in the actual simulation's degrees then Put it into rads
initialData = (initialDataDegrees + [-90; -90; -90; -90; 0; 0; 0; 0]).*pi/180;   

%Rest  = [0; 90; 0; 0; 0; 0; 0; 0];
%Straight Upside Down = [180; 0; 180; 180; 0; 0; 0; 0];
%Inverted = [180; -90; 180; 180; 0; 0; 0; 0]
%Just a good one = [178; -70; 190; 110; 0; 0; 0; 0];
%Periodid = [30; 120; 30; 30; 0; 0; 0; 0]

[T1, D1] = ode45(@updateAngles, 0:timeStep:simTime, initialData);

Y1 = l*sin(D1(:,1));
X1 = l*-cos(D1(:,1));
Y2 = Y1 + l*sin(D1(:,2));
X2 = X1 - l*cos(D1(:,2));
Y3 = Y2 + l*sin(D1(:,3));
X3 = X2 - l*cos(D1(:,3));
Y4 = Y1 + l*sin(D1(:,2)+pi);
X4 = X1 - l*cos(D1(:,2)+pi);
Y5 = Y4 + l*sin(D1(:,4));
X5 = X4 - l*cos(D1(:,4));

%minmax = [min([X1;X5]), max([X1;X5]), min([Y1;Y5]), max([Y1;Y5])];
% Used for axes framing

%Show simulation
if showSimulation 
    for i=1:length(T1)
        clf;
        %axis(minmax);
        axis([-3*l, 3*l, -3*l, 3*l])
        hold on; % to your butts
        axis square;
        
        line([0, X1(i)], [0, Y1(i)]);           % Y is the vector in the x direction
        line([X1(i), X2(i)], [Y1(i), Y2(i)]);
        line([X2(i), X3(i)], [Y2(i), Y3(i)]);
        line([X1(i), X4(i)], [Y1(i), Y4(i)]);
        line([X4(i), X5(i)], [Y4(i), Y5(i)]);
        
        plot(X1(i), Y1(i), 'b.', 'MarkerSize', 20);
        plot(X2(i), Y2(i), 'r.', 'MarkerSize', 20);
        plot(X3(i), Y3(i), 'g.', 'MarkerSize', 20);
        plot(X4(i), Y4(i), 'r.', 'MarkerSize', 20);
        plot(X5(i), Y5(i), 'g.', 'MarkerSize', 20);
        
        drawnow;
    end
    
    % Plot total trace
    % plot([X1, X2, X3, X4, X5], [Y1, Y2, Y3, Y4, Y5]) % plot everything
    plot([X3, X5], [Y3, Y5]) % Plot ndoes 3 and 5 only
end % if showSimulation


if showEnergy
    %Calculate energies (thx based mathematica)
    PotentialE = m*g*(Y1+Y2+Y3+Y4+Y5);
    KineticE = (1/2).*l.^2.*m.*(5.*D1(:,5).^2+3.*D1(:,6).^2+D1(:,7).^2+ ...
        D1(:,8).^2+2.*D1(:,5).*(D1(:,6).*(2.*cos(D1(:,1)+(-1).* ...
        D1(:,2))+cos(pi+(-1).*D1(:,1)+D1(:,2)))+D1(:,7).*cos(D1(:,1)+(-1).* ...
        D1(:,3))+D1(:,8).*cos(D1(:,1)+(-1).*D1(:,4)))+2.*D1(:,6).*( ...
        D1(:,7).*cos(D1(:,2)+(-1).*D1(:,3))+D1(:,8).*cos(pi+D1(:,2)+(-1) ...
        .*D1(:,4))));
    
    figure;
    %Adding total kinetic energy and potential energy
    plot(T1, [PotentialE, KineticE, PotentialE+KineticE])
end

% Node 3 speed
V3 = diff([X3, Y3], 1, 1);
Speeds3 = sqrt(V3(:,1).^2+V3(:,2).^2);
normalizedSpeeds3 = Speeds3./repmat(max(Speeds3), size(Speeds3,2), 1);
Colors3 = [normalizedSpeeds3, zeros(length(normalizedSpeeds3), 1), 1-normalizedSpeeds3];

% Node 5 speed
V5 = diff([X5, Y5], 1, 1);
Speeds5 = sqrt(V5(:,1).^2+V5(:,2).^2);
normalizedSpeeds5 = Speeds5./repmat(max(Speeds5), size(Speeds5,2), 1);
Colors5 = [1-normalizedSpeeds5, normalizedSpeeds5, 1-normalizedSpeeds5];

% Path in terms of velocity
if showSpeedPlot
    figure;
    hold on % to your butts
    
    for i=1:length(T1)-2        % -2 since the colors are based on the velocities, of which there is one less of +
        axis([-3*l, 3*l, -3*l, 3*l])
        subplot(2,1,1)
        plot(X3(i), Y3(i), '.', 'Color', Colors3(i, :));                                        % Plot points
        plot([X3(i), X3(i+1)], [Y3(i), Y3(i+1)], 'Color', (Colors3(i,:)+Colors3(i+1,:))./2)     % Plot lines
        hold on
        subplot(2,1,2)
        plot(X5(i), Y5(i), '.', 'Color', Colors5(i, :));
        plot([X5(i), X5(i+1)], [Y5(i), Y5(i+1)], 'Color', (Colors5(i,:)+Colors5(i+1,:))./2)
        
        hold on
    end
    
    hold off
end %if showSpeedPlot

SlowLogical3 = Speeds3<speedCutoff; % Get a logical vector of all of the times under the cutoff.
SlowLogical5 = Speeds5<speedCutoff;
timeLengths = [getStreaks(SlowLogical3); getStreaks(SlowLogical5)]; % Not the best way to calculate, 

if showCutoffPlot
    figure;
    hold on % to your butts
    
    for i=1:length(T1)-2        % -2 since the colors are based on the velocities, of which there is one less of +
        axis([-3*l, 3*l, -3*l, 3*l])
        %subplot(2,1,1)
        plot(X3(i), Y3(i), '.', 'Color', [1-SlowLogical3(i),0,SlowLogical3(i)]);                 % Plot points
        plot([X3(i), X3(i+1)], [Y3(i), Y3(i+1)], 'Color', (Colors3(i,:)+Colors3(i+1,:))./2)     % Plot lines
%         hold on
%         subplot(2,1,2)
%         plot(X5(i), Y5(i), '.', 'Color', [1-SlowLogical5(i),0,SlowLogical5(i)]);
%         plot([X5(i), X5(i+1)], [Y5(i), Y5(i+1)], 'Color', [normalizedSpeeds5(i), 0, 1-normalizedSpeeds5(i)])
        
        hold on
    end
    
    hold off
end

% %Force on acrobats
% %use diff twice on position vectors
% figure;
% subplot(2,1,1)
% plot(T1, sqrt(X1.^2+Y1.^2))
% subplot(2,1,2)
% plot(T1(1:end-1), diff(sqrt(X1.^2+Y1.^2)))

% %Acceleration calculation
% figure;
% A3 = diff([X3, Y3], 2, 1);
% A5 = diff([X5, Y5], 2, 1);
% % A3 = cumsum(abs(A3), 1);
% % A5 = cumsum(abs(A5), 1);
% plot(T1(1:end-2), m.*sqrt(A3(:,1).^2+A3(:,2).^2))
% hold on % to your butts
% plot(T1(1:end-2), m.*sqrt(A5(:,1).^2+A5(:,2).^2))
% refline(0, 20*g)
% hold off

res = timeLengths*timeStep;

function Res = updateAngles(t, Angles)
        % Unwrap like it's xmas
        theta1 = Angles(1);
        theta2 = Angles(2);
        theta3 = Angles(3);
        theta4 = Angles(4);
        theta1dot = Angles(5);
        theta2dot = Angles(6);
        theta3dot = Angles(7);
        theta4dot = Angles(8);
        
        % g = g - 0.005;
        
        % DiffyQs
        
%%%%%%%%%%%%%%%%
%  �\_(?)_/�  %
%%%%%%%%%%%%%%%%

	Res = [theta1dot; theta2dot; theta3dot; theta4dot; ...
  (-1).*l.^(-1).*((-1).*((-3).*cos(theta1+(-1).*theta2)+(-1).*cos( ... 
  pi+(-1).*theta1+theta2)+cos(theta1+theta2+(-2).*theta3)+cos(pi+ ... 
  theta1+theta2+(-2).*theta4)).^2+((-8)+cos(2.*(theta1+(-1).*theta3) ... 
  )+cos(2.*(theta1+(-1).*theta4))).*((-4)+cos(2.*(theta2+(-1).* ...
  theta3))+cos(2.*(pi+theta2+(-1).*theta4)))).^(-1).*(((-3).*cos( ... 
  theta1+(-1).*theta2)+(-1).*cos(pi+(-1).*theta1+theta2)+cos(theta1+ ... 
  theta2+(-2).*theta3)+cos(pi+theta1+theta2+(-2).*theta4)).*(3.*g.* ... 
  cos(theta2)+3.*g.*cos(pi+theta2)+(-1).*g.*cos(theta2+(-2).*theta3) ... 
  +(-1).*g.*cos(pi+theta2+(-2).*theta4)+2.*l.*theta3dot.^2.*sin( ...
  theta2+(-1).*theta3)+l.*theta1dot.^2.*((-3).*sin(theta1+(-1).* ...
  theta2)+sin(pi+(-1).*theta1+theta2)+sin(theta1+theta2+(-2).* ...
  theta3)+sin(pi+theta1+theta2+(-2).*theta4))+2.*l.*theta4dot.^2.* ... 
  sin(pi+theta2+(-1).*theta4)+l.*theta2dot.^2.*(sin(2.*(theta2+(-1) ... 
  .*theta3))+sin(2.*(pi+theta2+(-1).*theta4))))+(-1).*((-4)+cos(2.*( ... 
  theta2+(-1).*theta3))+cos(2.*(pi+theta2+(-1).*theta4))).*(8.*g.* ... 
  cos(theta1)+(-1).*g.*cos(theta1+(-2).*theta3)+(-1).*g.*cos(theta1+ ... 
  (-2).*theta4)+2.*l.*theta3dot.^2.*sin(theta1+(-1).*theta3)+l.* ...
  theta2dot.^2.*(3.*sin(theta1+(-1).*theta2)+(-1).*sin(pi+(-1).* ...
  theta1+theta2)+sin(theta1+theta2+(-2).*theta3)+sin(pi+theta1+ ...
  theta2+(-2).*theta4))+2.*l.*theta4dot.^2.*sin(theta1+(-1).*theta4) ... 
  +2.*l.*theta1dot.^2.*cos(theta3+(-1).*theta4).*sin(2.*theta1+(-1) ... 
  .*theta3+(-1).*theta4)));(-1).*l.^(-1).*(52+(-6).*cos(pi)+(-8).* ... 
  cos(2.*(theta1+(-1).*theta2))+(-6).*cos(pi+(-2).*theta1+2.*theta2) ... 
  +2.*cos(pi+2.*theta2+(-2).*theta3)+(-2).*cos(2.*(theta1+(-1).* ...
  theta3))+(-10).*cos(2.*(theta2+(-1).*theta3))+2.*cos(pi+(-2).* ...
  theta1+2.*theta3)+6.*cos(pi+2.*theta1+(-2).*theta4)+6.*cos(pi+2.* ... 
  theta2+(-2).*theta4)+(-2).*cos(pi+2.*theta1+2.*theta2+(-2).* ...
  theta3+(-2).*theta4)+(-2).*cos(pi+2.*theta3+(-2).*theta4)+(-6).* ... 
  cos(2.*(theta1+(-1).*theta4))+(-14).*cos(2.*(pi+theta2+(-1).* ...
  theta4))+cos(2.*(theta1+theta2+(-1).*theta3+(-1).*theta4))+cos(2.* ... 
  (pi+theta1+theta2+(-1).*theta3+(-1).*theta4))+cos(2.*(theta1+(-1) ... 
  .*theta2+theta3+(-1).*theta4))+cos(2.*(pi+(-1).*theta1+theta2+ ...
  theta3+(-1).*theta4))).^(-1).*((-23).*g.*cos(2.*theta1+(-1).* ...
  theta2)+23.*g.*cos(theta2)+39.*g.*cos(pi+theta2)+(-7).*g.*cos(pi+( ... 
  -2).*theta1+theta2)+(-5).*g.*cos(theta2+(-2).*theta3)+g.*cos(pi+ ... 
  theta2+(-2).*theta3)+5.*g.*cos(2.*theta1+theta2+(-2).*theta3)+(-3) ... 
  .*g.*cos(pi+2.*theta1+theta2+(-2).*theta3)+(-2).*g.*cos(pi+(-2).* ... 
  theta1+theta2+2.*theta3)+3.*g.*cos(theta2+(-2).*theta4)+(-7).*g.* ... 
  cos(pi+theta2+(-2).*theta4)+(-3).*g.*cos(2.*theta1+theta2+(-2).* ... 
  theta4)+5.*g.*cos(pi+2.*theta1+theta2+(-2).*theta4)+g.*cos(2.* ...
  theta1+(-1).*theta2+2.*theta3+(-2).*theta4)+(-1).*g.*cos(pi+ ...
  theta2+2.*theta3+(-2).*theta4)+g.*cos(pi+(-2).*theta1+theta2+2.* ... 
  theta3+(-2).*theta4)+(-2).*g.*cos(pi+(-2).*theta1+theta2+2.* ...
  theta4)+(-1).*g.*cos(theta2+(-2).*theta3+2.*theta4)+(-4).*l.* ...
  theta3dot.^2.*sin(2.*theta1+(-1).*theta2+(-1).*theta3)+24.*l.* ...
  theta3dot.^2.*sin(theta2+(-1).*theta3)+(-2).*l.*theta3dot.^2.*sin( ... 
  pi+theta2+(-1).*theta3)+2.*l.*theta3dot.^2.*sin(pi+(-2).*theta1+ ... 
  theta2+theta3)+(-2).*l.*theta3dot.^2.*sin(2.*theta1+theta2+(-1).* ... 
  theta3+(-2).*theta4)+2.*l.*theta3dot.^2.*sin(pi+2.*theta1+theta2+( ... 
  -1).*theta3+(-2).*theta4)+2.*l.*theta3dot.^2.*sin(2.*theta1+(-1).* ... 
  theta2+theta3+(-2).*theta4)+(-2).*l.*theta3dot.^2.*sin(pi+theta2+ ... 
  theta3+(-2).*theta4)+(-2).*l.*theta1dot.^2.*(23.*sin(theta1+(-1).* ... 
  theta2)+(-7).*sin(pi+(-1).*theta1+theta2)+(-5).*sin(theta1+theta2+ ... 
  (-2).*theta3)+sin(pi+theta1+theta2+(-2).*theta3)+3.*sin(theta1+ ... 
  theta2+(-2).*theta4)+(-7).*sin(pi+theta1+theta2+(-2).*theta4)+(-1) ... 
  .*sin(theta1+(-1).*theta2+2.*theta3+(-2).*theta4)+sin(pi+(-1).* ... 
  theta1+theta2+2.*theta3+(-2).*theta4))+(-6).*l.*theta4dot.^2.*sin( ... 
  2.*theta1+(-1).*theta2+(-1).*theta4)+(-6).*l.*theta4dot.^2.*sin( ... 
  theta2+(-1).*theta4)+28.*l.*theta4dot.^2.*sin(pi+theta2+(-1).* ...
  theta4)+2.*l.*theta4dot.^2.*sin(2.*theta1+theta2+(-2).*theta3+(-1) ... 
  .*theta4)+(-2).*l.*theta4dot.^2.*sin(pi+2.*theta1+theta2+(-2).* ... 
  theta3+(-1).*theta4)+(-1).*l.*theta2dot.^2.*(8.*sin(2.*(theta1+( ... 
  -1).*theta2))+(-6).*sin(pi+(-2).*theta1+2.*theta2)+2.*sin(pi+2.* ... 
  theta2+(-2).*theta3)+(-10).*sin(2.*(theta2+(-1).*theta3))+6.*sin( ... 
  pi+2.*theta2+(-2).*theta4)+(-2).*sin(pi+2.*theta1+2.*theta2+(-2).* ... 
  theta3+(-2).*theta4)+(-14).*sin(2.*(pi+theta2+(-1).*theta4))+sin( ... 
  2.*(theta1+theta2+(-1).*theta3+(-1).*theta4))+sin(2.*(pi+theta1+ ... 
  theta2+(-1).*theta3+(-1).*theta4))+(-1).*sin(2.*(theta1+(-1).* ...
  theta2+theta3+(-1).*theta4))+sin(2.*(pi+(-1).*theta1+theta2+ ...
  theta3+(-1).*theta4)))+(-2).*l.*theta4dot.^2.*sin(pi+(-2).*theta1+ ... 
  theta2+2.*theta3+(-1).*theta4)+(-2).*l.*theta4dot.^2.*sin(theta2+( ... 
  -2).*theta3+theta4));(-1).*l.^(-1).*(52+(-6).*cos(pi)+(-8).*cos( ... 
  2.*(theta1+(-1).*theta2))+(-6).*cos(pi+(-2).*theta1+2.*theta2)+2.* ... 
  cos(pi+2.*theta2+(-2).*theta3)+(-2).*cos(2.*(theta1+(-1).*theta3)) ... 
  +(-10).*cos(2.*(theta2+(-1).*theta3))+2.*cos(pi+(-2).*theta1+2.* ... 
  theta3)+6.*cos(pi+2.*theta1+(-2).*theta4)+6.*cos(pi+2.*theta2+(-2) ... 
  .*theta4)+(-2).*cos(pi+2.*theta1+2.*theta2+(-2).*theta3+(-2).* ...
  theta4)+(-2).*cos(pi+2.*theta3+(-2).*theta4)+(-6).*cos(2.*(theta1+ ... 
  (-1).*theta4))+(-14).*cos(2.*(pi+theta2+(-1).*theta4))+cos(2.*( ... 
  theta1+theta2+(-1).*theta3+(-1).*theta4))+cos(2.*(pi+theta1+ ...
  theta2+(-1).*theta3+(-1).*theta4))+cos(2.*(theta1+(-1).*theta2+ ... 
  theta3+(-1).*theta4))+cos(2.*(pi+(-1).*theta1+theta2+theta3+(-1).* ... 
  theta4))).^(-1).*((-2).*g.*cos(pi+(-1).*theta3)+(-17).*g.*cos(2.* ... 
  theta1+(-1).*theta3)+6.*g.*cos(pi+2.*theta1+(-1).*theta3)+(-10).* ... 
  g.*cos(2.*theta2+(-1).*theta3)+(-14).*g.*cos(pi+2.*theta2+(-1).* ... 
  theta3)+g.*cos(2.*pi+2.*theta2+(-1).*theta3)+19.*g.*cos(theta3)+( ... 
  -20).*g.*cos(pi+theta3)+6.*g.*cos(pi+(-2).*theta1+theta3)+10.*g.* ... 
  cos(2.*theta1+(-2).*theta2+theta3)+4.*g.*cos(pi+(-2).*theta1+2.* ... 
  theta2+theta3)+g.*cos(2.*pi+(-2).*theta1+2.*theta2+theta3)+(-1).* ... 
  g.*cos(2.*theta1+(-1).*theta3+(-2).*theta4)+(-2).*g.*cos(2.* ...
  theta2+(-1).*theta3+(-2).*theta4)+6.*g.*cos(pi+2.*theta2+(-1).* ... 
  theta3+(-2).*theta4)+(-4).*g.*cos(2.*pi+2.*theta2+(-1).*theta3+( ... 
  -2).*theta4)+2.*g.*cos(2.*theta1+2.*theta2+(-1).*theta3+(-2).* ...
  theta4)+(-5).*g.*cos(pi+2.*theta1+2.*theta2+(-1).*theta3+(-2).* ... 
  theta4)+3.*g.*cos(2.*pi+2.*theta1+2.*theta2+(-1).*theta3+(-2).* ... 
  theta4)+g.*cos(theta3+(-2).*theta4)+(-2).*g.*cos(2.*theta1+theta3+ ... 
  (-2).*theta4)+g.*cos(pi+2.*theta1+theta3+(-2).*theta4)+2.*g.*cos( ... 
  pi+2.*theta2+theta3+(-2).*theta4)+(-5).*g.*cos(2.*pi+2.*theta2+ ... 
  theta3+(-2).*theta4)+(-2).*g.*cos(pi+(-2).*theta1+2.*theta2+ ...
  theta3+(-2).*theta4)+4.*g.*cos(2.*pi+(-2).*theta1+2.*theta2+ ...
  theta3+(-2).*theta4)+g.*cos(pi+(-2).*theta1+2.*theta2+(-1).* ...
  theta3+2.*theta4)+g.*cos(pi+(-2).*theta1+theta3+2.*theta4)+2.*l.* ... 
  theta3dot.^2.*sin(pi+2.*theta2+(-2).*theta3)+(-2).*l.* ...
  theta3dot.^2.*sin(2.*(theta1+(-1).*theta3))+(-10).*l.* ...
  theta3dot.^2.*sin(2.*(theta2+(-1).*theta3))+(-2).*l.* ...
  theta3dot.^2.*sin(pi+(-2).*theta1+2.*theta3)+(-2).*l.* ...
  theta3dot.^2.*sin(pi+2.*theta1+2.*theta2+(-2).*theta3+(-2).* ...
  theta4)+(-4).*l.*theta2dot.^2.*(sin(2.*theta1+(-1).*theta2+(-1).* ... 
  theta3)+13.*sin(theta2+(-1).*theta3)+(-2).*sin(pi+theta2+(-1).* ... 
  theta3)+sin(pi+(-1).*theta2+theta3)+sin(pi+(-2).*theta1+theta2+ ... 
  theta3)+(-1).*sin(2.*theta1+theta2+(-1).*theta3+(-2).*theta4)+2.* ... 
  sin(pi+2.*theta1+theta2+(-1).*theta3+(-2).*theta4)+(-1).*sin(2.* ... 
  pi+2.*theta1+theta2+(-1).*theta3+(-2).*theta4)+sin(2.*theta1+(-1) ... 
  .*theta2+theta3+(-2).*theta4)+(-1).*sin(pi+2.*theta1+(-1).*theta2+ ... 
  theta3+(-2).*theta4)+(-1).*sin(pi+theta2+theta3+(-2).*theta4)+3.* ... 
  sin(2.*pi+theta2+theta3+(-2).*theta4))+4.*l.*theta1dot.^2.*((-9).* ... 
  sin(theta1+(-1).*theta3)+sin(pi+theta1+(-1).*theta3)+(-3).*sin(pi+ ... 
  (-1).*theta1+theta3)+5.*sin(theta1+(-2).*theta2+theta3)+sin( ...
  theta1+2.*theta2+(-1).*theta3+(-2).*theta4)+(-3).*sin(pi+theta1+ ... 
  2.*theta2+(-1).*theta3+(-2).*theta4)+2.*sin(2.*pi+theta1+2.* ...
  theta2+(-1).*theta3+(-2).*theta4)+(-1).*sin(theta1+theta3+(-2).* ... 
  theta4)+sin(pi+(-1).*theta1+2.*theta2+theta3+(-2).*theta4)+(-2).* ... 
  sin(2.*pi+(-1).*theta1+2.*theta2+theta3+(-2).*theta4))+2.*l.* ...
  theta3dot.^2.*sin(pi+2.*theta3+(-2).*theta4)+(-4).*l.* ...
  theta4dot.^2.*sin(2.*theta1+(-1).*theta3+(-1).*theta4)+4.*l.* ...
  theta4dot.^2.*sin(pi+2.*theta1+(-1).*theta3+(-1).*theta4)+l.* ...
  theta3dot.^2.*sin(2.*(theta1+theta2+(-1).*theta3+(-1).*theta4))+ ... 
  l.*theta3dot.^2.*sin(2.*(pi+theta1+theta2+(-1).*theta3+(-1).* ...
  theta4))+4.*l.*theta4dot.^2.*sin(2.*theta2+(-1).*theta3+(-1).* ...
  theta4)+(-12).*l.*theta4dot.^2.*sin(pi+2.*theta2+(-1).*theta3+(-1) ... 
  .*theta4)+(-4).*l.*theta4dot.^2.*sin(theta3+(-1).*theta4)+(-12).* ... 
  l.*theta4dot.^2.*sin(pi+theta3+(-1).*theta4)+4.*l.*theta4dot.^2.* ... 
  sin(2.*theta1+(-2).*theta2+theta3+(-1).*theta4)+(-1).*l.* ...
  theta3dot.^2.*sin(2.*(theta1+(-1).*theta2+theta3+(-1).*theta4))+( ... 
  -1).*l.*theta3dot.^2.*sin(2.*(pi+(-1).*theta1+theta2+theta3+(-1).* ... 
  theta4))+4.*l.*theta4dot.^2.*sin(pi+(-2).*theta1+2.*theta2+theta3+ ... 
  (-1).*theta4));(-1).*l.^(-1).*(52+(-6).*cos(pi)+(-8).*cos(2.*( ...
  theta1+(-1).*theta2))+(-6).*cos(pi+(-2).*theta1+2.*theta2)+2.*cos( ... 
  pi+2.*theta2+(-2).*theta3)+(-2).*cos(2.*(theta1+(-1).*theta3))+( ... 
  -10).*cos(2.*(theta2+(-1).*theta3))+2.*cos(pi+(-2).*theta1+2.* ...
  theta3)+6.*cos(pi+2.*theta1+(-2).*theta4)+6.*cos(pi+2.*theta2+(-2) ... 
  .*theta4)+(-2).*cos(pi+2.*theta1+2.*theta2+(-2).*theta3+(-2).* ...
  theta4)+(-2).*cos(pi+2.*theta3+(-2).*theta4)+(-6).*cos(2.*(theta1+ ... 
  (-1).*theta4))+(-14).*cos(2.*(pi+theta2+(-1).*theta4))+cos(2.*( ... 
  theta1+theta2+(-1).*theta3+(-1).*theta4))+cos(2.*(pi+theta1+ ...
  theta2+(-1).*theta3+(-1).*theta4))+cos(2.*(theta1+(-1).*theta2+ ... 
  theta3+(-1).*theta4))+cos(2.*(pi+(-1).*theta1+theta2+theta3+(-1).* ... 
  theta4))).^(-1).*((-16).*g.*cos(pi+(-1).*theta4)+(-27).*g.*cos(2.* ... 
  theta1+(-1).*theta4)+19.*g.*cos(pi+2.*theta1+(-1).*theta4)+4.*g.* ... 
  cos(2.*theta2+(-1).*theta4)+(-4).*g.*cos(pi+2.*theta2+(-1).* ...
  theta4)+(-23).*g.*cos(2.*pi+2.*theta2+(-1).*theta4)+7.*g.*cos(pi+( ... 
  -2).*theta1+2.*theta2+(-1).*theta4)+7.*g.*cos(2.*pi+(-2).*theta1+ ... 
  2.*theta2+(-1).*theta4)+g.*cos(2.*theta1+(-2).*theta3+(-1).* ...
  theta4)+(-3).*g.*cos(2.*theta2+(-2).*theta3+(-1).*theta4)+4.*g.* ... 
  cos(pi+2.*theta2+(-2).*theta3+(-1).*theta4)+(-1).*g.*cos(2.*pi+2.* ... 
  theta2+(-2).*theta3+(-1).*theta4)+3.*g.*cos(2.*theta1+2.*theta2+( ... 
  -2).*theta3+(-1).*theta4)+(-5).*g.*cos(pi+2.*theta1+2.*theta2+(-2) ... 
  .*theta3+(-1).*theta4)+2.*g.*cos(2.*pi+2.*theta1+2.*theta2+(-2).* ... 
  theta3+(-1).*theta4)+g.*cos(2.*theta3+(-1).*theta4)+(-1).*g.*cos( ... 
  pi+(-2).*theta1+2.*theta3+(-1).*theta4)+3.*g.*cos(2.*theta1+(-2).* ... 
  theta2+2.*theta3+(-1).*theta4)+g.*cos(2.*pi+(-2).*theta1+2.* ...
  theta2+2.*theta3+(-1).*theta4)+13.*g.*cos(theta4)+3.*g.*cos(pi+( ... 
  -2).*theta1+theta4)+(-4).*g.*cos(2.*theta1+(-2).*theta2+theta4)+ ... 
  3.*g.*cos(pi+(-2).*theta1+2.*theta2+theta4)+2.*g.*cos(2.*pi+(-2).* ... 
  theta1+2.*theta2+theta4)+(-3).*g.*cos(2.*theta2+(-2).*theta3+ ...
  theta4)+(-1).*g.*cos(pi+(-2).*theta1+2.*theta2+(-2).*theta3+ ...
  theta4)+(-1).*g.*cos(pi+(-2).*theta1+2.*theta3+theta4)+6.*l.* ...
  theta4dot.^2.*sin(pi+2.*theta1+(-2).*theta4)+6.*l.*theta4dot.^2.* ... 
  sin(pi+2.*theta2+(-2).*theta4)+(-2).*l.*theta4dot.^2.*sin(pi+2.* ... 
  theta1+2.*theta2+(-2).*theta3+(-2).*theta4)+(-2).*l.* ...
  theta4dot.^2.*sin(pi+2.*theta3+(-2).*theta4)+(-6).*l.* ...
  theta4dot.^2.*sin(2.*(theta1+(-1).*theta4))+(-14).*l.* ...
  theta4dot.^2.*sin(2.*(pi+theta2+(-1).*theta4))+(-4).*l.* ...
  theta3dot.^2.*sin(2.*theta1+(-1).*theta3+(-1).*theta4)+2.*l.* ...
  theta3dot.^2.*sin(pi+2.*theta1+(-1).*theta3+(-1).*theta4)+l.* ...
  theta4dot.^2.*sin(2.*(theta1+theta2+(-1).*theta3+(-1).*theta4))+ ... 
  l.*theta4dot.^2.*sin(2.*(pi+theta1+theta2+(-1).*theta3+(-1).* ...
  theta4))+2.*l.*theta3dot.^2.*sin(2.*theta2+(-1).*theta3+(-1).* ...
  theta4)+(-12).*l.*theta3dot.^2.*sin(pi+2.*theta2+(-1).*theta3+(-1) ... 
  .*theta4)+2.*l.*theta3dot.^2.*sin(2.*pi+2.*theta2+(-1).*theta3+( ... 
  -1).*theta4)+4.*l.*theta3dot.^2.*sin(theta3+(-1).*theta4)+12.*l.* ... 
  theta3dot.^2.*sin(pi+theta3+(-1).*theta4)+(-2).*l.*theta3dot.^2.* ... 
  sin(2.*theta1+(-2).*theta2+theta3+(-1).*theta4)+l.*theta4dot.^2.* ... 
  sin(2.*(theta1+(-1).*theta2+theta3+(-1).*theta4))+l.* ...
  theta4dot.^2.*sin(2.*(pi+(-1).*theta1+theta2+theta3+(-1).*theta4)) ... 
  +(-2).*l.*theta3dot.^2.*sin(pi+(-2).*theta1+2.*theta2+theta3+(-1) ... 
  .*theta4)+(-2).*l.*theta3dot.^2.*sin(2.*pi+(-2).*theta1+2.*theta2+ ... 
  theta3+(-1).*theta4)+2.*l.*theta1dot.^2.*((-29).*sin(theta1+(-1).* ... 
  theta4)+16.*sin(pi+theta1+(-1).*theta4)+(-7).*sin(pi+(-1).*theta1+ ... 
  2.*theta2+(-1).*theta4)+(-7).*sin(2.*pi+(-1).*theta1+2.*theta2+( ... 
  -1).*theta4)+3.*sin(theta1+2.*theta2+(-2).*theta3+(-1).*theta4)+( ... 
  -4).*sin(pi+theta1+2.*theta2+(-2).*theta3+(-1).*theta4)+sin(2.*pi+ ... 
  theta1+2.*theta2+(-2).*theta3+(-1).*theta4)+sin(pi+(-1).*theta1+ ... 
  2.*theta3+(-1).*theta4)+3.*sin(theta1+(-2).*theta2+2.*theta3+(-1) ... 
  .*theta4)+(-3).*sin(pi+(-1).*theta1+theta4)+(-4).*sin(theta1+(-2) ... 
  .*theta2+theta4)+(-1).*sin(theta1+(-2).*theta3+theta4)+sin(pi+(-1) ... 
  .*theta1+2.*theta2+(-2).*theta3+theta4))+2.*l.*theta3dot.^2.*sin( ... 
  pi+(-2).*theta1+2.*theta2+(-1).*theta3+theta4)+(-2).*l.* ...
  theta3dot.^2.*sin(pi+(-2).*theta1+theta3+theta4)+2.*l.* ...
  theta2dot.^2.*((-1).*sin(2.*theta1+(-1).*theta2+(-1).*theta4)+4.* ... 
  sin(pi+2.*theta1+(-1).*theta2+(-1).*theta4)+10.*sin(theta2+(-1).* ... 
  theta4)+(-33).*sin(pi+theta2+(-1).*theta4)+3.*sin(2.*pi+theta2+( ... 
  -1).*theta4)+(-2).*sin(2.*theta1+theta2+(-2).*theta3+(-1).*theta4) ... 
  +sin(pi+2.*theta1+theta2+(-2).*theta3+(-1).*theta4)+5.*sin(pi+(-1) ... 
  .*theta2+2.*theta3+(-1).*theta4)+sin(pi+(-2).*theta1+theta2+2.* ... 
  theta3+(-1).*theta4)+(-1).*sin(2.*pi+(-2).*theta1+theta2+2.* ...
  theta3+(-1).*theta4)+3.*sin(pi+(-2).*theta1+theta2+theta4)+sin( ... 
  theta2+(-2).*theta3+theta4)+(-1).*sin(pi+(-2).*theta1+(-1).* ...
  theta2+2.*theta3+theta4)))];

end %function Res = updateAngles(t, Angles)


function Res = getStreaks(LogicalVector)
    
    Streaks = zeros(ceil(length(LogicalVector)/2), 1); % Largest streak vector (ie: [1 0 1 0 ... 0 1 0 1])
    streakIDX = 1;
    
    if ~islogical(LogicalVector) % Return -1 if the vector is not logical
        Res = -1;
    end
    
    if LogicalVector(1) ~= 0     % If the list starts with a 1, the following loop will miscount the first streak without this
        Streaks(1) = 1;
    end    

    for k = 2:length(LogicalVector)
        
            %New Streak
        if (LogicalVector(k-1) == 0 && LogicalVector(k) == 1)
            Streaks(streakIDX+1) = 1; % Add 1 as a new elemet
            streakIDX = streakIDX +1; % Move to the next spot
        
            %Next element is also a 1
        elseif (LogicalVector(k) == 1 && LogicalVector(k) == LogicalVector(k-1))
            Streaks(streakIDX) = Streaks(streakIDX)+1; % Increment element at the 'end' position
        end
        
    end %for k = 2:length(LogicalVector)
    
    Res = Streaks(Streaks ~= 0); %Don't return the residual zeros from the preallocation
end %getStreaks()

end



% Shhhhhh

% Cancer graph
% subplot(2,1,1)
% plot(T1, [P1, P2, P3, P4, P5])
% title('Potential Energy')
% xlabel('Time')
% ylabel('Energy')
% 
% subplot(2,1,2)
% plot(T1, [K1, K2, K3, K4, K5])
% title('Kinetic Energy')
% xlabel('Time')
% ylabel('Energy')
% 
% subplot(3,1,3)
% plot(T1, [PotentialE, KineticE, PotentialE+KineticE, P1+P2+P3+P4+P5+K2+K3+K4+K5])
% title('Total Energy')
% xlabel('Time')
% ylabel('Energy')






% P1 = m*l*Y1;
% P2 = m*l*Y2;
% P3 = m*l*Y3;
% P4 = m*l*Y4;
% P5 = m*l*Y5;
% 
% K1 = l.^2.*m.*D1(:,5).^2;
% K2 = ((l.*D1(:,5).*cos(D1(:,1))+l.*D1(:,6).*cos(D1(:,2))).^2+(l.* ...
%   D1(:,5).*sin(D1(:,1))+l.*D1(:,6).*sin(D1(:,2))).^2).^(1/2);
% K3 = ((l.*D1(:,5).*cos(D1(:,1))+l.*D1(:,6).*cos(D1(:,2))+l.* ...
%   D1(:,7).*cos(D1(:,3))).^2+(l.*D1(:,5).*sin(D1(:,1))+l.* ...
%   D1(:,6).*sin(D1(:,2))+l.*D1(:,7).*sin(D1(:,3))).^2).^(1/2);
% K4 = ((l.*D1(:,5).*cos(D1(:,1))+l.*D1(:,6).*cos(D1(:,2))).^2+(l.* ...
%   D1(:,5).*sin(D1(:,1))+l.*D1(:,6).*sin(D1(:,2))).^2).^(1/2);
% K5 = ((l.*D1(:,5).*cos(D1(:,1))+l.*D1(:,6).*cos(pi+D1(:,2))+l.* ...
%   D1(:,8).*cos(D1(:,4))).^2+(l.*D1(:,5).*sin(D1(:,1))+l.* ...
%   D1(:,6).*sin(pi+D1(:,2))+l.*D1(:,8).*sin(D1(:,4))).^2).^(1/2);


% minw = min(Speeds3)
% maxw = max(Speeds3)
% sumw = sum(timeLengths)
% meamw = mean(timeLengths)
% stdw = std(timeLengths)
%[mu,s,muci,sci] = normfit(timeLengths)

%Plot normal distribution
% figure
% histfit(timeLengths)

