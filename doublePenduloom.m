function doublePenduloom()

g = 9.81;       % m.s^-2    Gravity constant
m = 1;          % kg        Mass of thing
l = 1;          % m         Length of rod
simTime = 20;   % s         Simulation Time

initialDataDegrees = [45; 180; 0; 0]; % [theta1; theta2; theta3; theta1'; theta2'; theta3';]
initialData = initialDataDegrees.*pi/180;   % Put it into rads
%initialData = [-.46; -1.2; 0; 0];

[T1, D1] = ode45(@updateAngles, [0:0.01:simTime], initialData);
%plot(T1, [D1(:,1) D1(:,2)])
plot(T1, D1(:,3))

X1 = l*sin(D1(:,1));
Y1 = l*-cos(D1(:,1));
X2 = X1+l*sin(D1(:,2));
Y2 = Y1 - l*cos(D1(:,2));

minmax = [ min([Y1;Y2]), max([Y1;Y2]), min([X1;X2]), max([X1;X2])];
                    % Used for axes framing

for i=1:length(T1)
    clf;
    axis(minmax);
    hold on; % to your butts
    
    plot(Y1(i), X1(i), 'b.', 'MarkerSize', 20);
    plot(Y2(i), X2(i), 'r.', 'MarkerSize', 20);
    
    drawnow;
end

plot([Y1, Y2], [X1, X2])

% axis([-2, 0 -2, 2])
% 
% comet(Y2, X2)
% axis([-2, 2 -2, 0])
% hold on
% comet(Y1, X1)
% axis([-2, 2 -2, 0])
% hold off

function Res = updateAngles(t, Angles)
        % Unwrap like it's xmas
        theta1 = Angles(1);
        theta2 = Angles(2);
        theta1dot = Angles(3);
        theta2dot = Angles(4);
        
        % DiffyQs
        Res = [theta1dot; theta2dot; l.^(-1).*((-5)+cos(2.*(theta1+(-1).*theta2))).^(-1).*(3.*g.*cos( ...
  theta1)+(-1).*g.*cos(theta1+(-2).*theta2)+2.*l.*theta2dot.^2.*sin( ...
  theta1+(-1).*theta2)+l.*theta1dot.^2.*sin(2.*(theta1+(-1).*theta2) ...
  ));(-1).*l.^(-1).*((-5)+cos(2.*(theta1+(-1).*theta2))).^(-1).*(2.* ...
  g.*(cos(2.*theta1+(-1).*theta2)+(-2).*cos(theta2))+6.*l.* ...
  theta1dot.^2.*sin(theta1+(-1).*theta2)+l.*theta2dot.^2.*sin(2.*( ...
  theta1+(-1).*theta2)))];
        
        
end


end
