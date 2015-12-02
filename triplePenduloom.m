function triplePenduloom()

g = 9.81;       % m.s^-2    Gravity constant
m = 1000000;          % kg        Mass of thing
l = 1;          % m         Length of rod
simTime = 5;   % s         Simulation Time

initialDataDegrees = [45; 135; -135; 0; 0; 0]; % [theta1; theta2; theta3; theta1'; theta2'; theta3';]
initialData = initialDataDegrees.*pi/180;   % Put it into rads
%initialData = [-.46; -1.2; 0; 0];

[T1, D1] = ode45(@updateAngles, [0:0.02:simTime], initialData);
%plot(T1, [D1(:,1) D1(:,2)])
%plot(T1, D1(:,3))

X1 = l*sin(D1(:,1));
Y1 = l*-cos(D1(:,1));
X2 = X1+l*sin(D1(:,2));
Y2 = Y1 - l*cos(D1(:,2));
X3 = X2 + l*sin(D1(:,3));
Y3 = Y2 - l*cos(D1(:,3));

minmax = [ min([Y1;Y3]), max([Y1;Y3]), min([X1;X3]), max([X1;X3])];
                    % Used for axes framing

for i=1:length(T1)
    clf;
    axis(minmax);
    hold on; % to your butts
    axis square;
    
    line([0, Y1(i)], [0, X1(i)]);
    line([Y1(i), Y2(i)], [X1(i), X2(i)]);
    line([Y2(i), Y3(i)], [X2(i), X3(i)]);
    
    plot(Y1(i), X1(i), 'b.', 'MarkerSize', 20);
    plot(Y2(i), X2(i), 'r.', 'MarkerSize', 20);
    plot(Y3(i), X3(i), 'g.', 'MarkerSize', 20);

    drawnow;
end

plot([Y1, Y2, Y3], [X1, X2, X3])

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
        theta3 = Angles(3);
        theta1dot = Angles(4);
        theta2dot = Angles(5);
        theta3dot = Angles(6);
        
         g = g - 0.01;
        
        % DiffyQs
        Res = [theta1dot; theta2dot; theta3dot; ...
            (1/4).*l.^(-1).*((-4)+cos(2.*(theta1+(-1).*theta2))+cos(2.*( ...
  theta2+(-1).*theta3))).^(-1).*(9.*g.*cos(theta1)+(-3).*g.*cos( ...
  theta1+(-2).*theta2)+g.*cos(theta1+(-2).*theta3)+(-1).*g.*cos( ...
  theta1+2.*theta2+(-2).*theta3)+(-2).*g.*cos(theta1+(-2).*theta2+ ...
  2.*theta3)+8.*l.*theta2dot.^2.*sin(theta1+(-1).*theta2)+4.*l.* ...
  theta1dot.^2.*sin(2.*(theta1+(-1).*theta2))+2.*l.*theta3dot.^2.* ...
  sin(theta1+(-1).*theta3)+2.*l.*theta3dot.^2.*sin(theta1+(-2).* ...
  theta2+theta3)); ...
  (1/4).*l.^(-1).*((-4)+cos(2.*(theta1+(-1).*theta2) ...
  )+cos(2.*(theta2+(-1).*theta3))).^(-1).*((-6).*g.*cos(2.*theta1+( ...
  -1).*theta2)+8.*g.*cos(theta2)+(-1).*g.*cos(2.*theta1+(-1).* ...
  theta2+(-2).*theta3)+2.*g.*cos(theta2+(-2).*theta3)+g.*cos(2.* ...
  theta1+theta2+(-2).*theta3)+4.*l.*theta1dot.^2.*((-5).*sin(theta1+ ...
  (-1).*theta2)+sin(theta1+theta2+(-2).*theta3))+(-2).*l.* ...
  theta3dot.^2.*sin(2.*theta1+(-1).*theta2+(-1).*theta3)+10.*l.* ...
  theta3dot.^2.*sin(theta2+(-1).*theta3)+(-8).*l.*theta2dot.^2.*cos (...
  theta1+(-1).*theta3).*sin(theta1+(-2).*theta2+theta3)); ...
  (-1/2).* ...
  l.^(-1).*((-4)+cos(2.*(theta1+(-1).*theta2))+cos(2.*(theta2+(-1).* ...
  theta3))).^(-1).*(g.*cos(2.*theta1+(-1).*theta3)+(-1).*g.*cos(2.* ...
  theta1+(-2).*theta2+(-1).*theta3)+g.*cos(2.*theta2+(-1).*theta3)+ ...
  5.*g.*cos(theta3)+(-2).*g.*cos(2.*theta1+(-2).*theta2+theta3)+8.* ...
  l.*theta2dot.^2.*sin(theta2+(-1).*theta3)+8.*l.*theta1dot.^2.*cos (...
  theta1+(-1).*theta2).*sin(theta2+(-1).*theta3)+2.*l.* ...
  theta3dot.^2.*sin(2.*(theta2+(-1).*theta3)))];
        
        
end


end
