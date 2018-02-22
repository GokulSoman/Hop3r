function J = subchainJacobian(qa,qu,lengths,chain)
%% Description:
% Calculates the Jacobian of the subchain specified by 'chain'
%
% Inputs:
%   qa: actuated joint positions (3x1 column vector) 
%       qa = [theta1; phi1; psi1];
%   qu: unactuated joint positions (6x1 column vector)
%       qu = [theta2; theta3; phi2; phi3; psi2; psi3];
%   lengths: the relevant dimensions of the robot, stored in a 10x1 column
%       vector according to this order:
%       lengths = [L1; L2; L3; L4; L5 L6; L7; L8; B1; B2], where
%       B1, L1, L2, and L8 correspond to the theta-chain,
%       L3, L4, L7, and L8 correspond to the phi-chain, and
%       B2, L5, L6, and L8 correspond to the psi-chain.
%   chain: the Jacobian will be calculated for this open
%   subchain.
%       chain = 1: theta-chain Jacobian
%       chain = 2: phi-chain Jacobian
%       chain = 3: psi-chain Jacobia
%
% Outputs:
%   J: the actuator Jacobian, a 3x3 matrix.
%
% Dependencies:
%   none
%
%% "unpack" link lengths from "lengths" input vector:
% Note: this step is just for cleaner-looking code.
% Also note: not all lengths are used when computing the constraint
%   Jacobian.
L1 = lengths(1);
L2 = lengths(2);
L3 = lengths(3);
L4 = lengths(4);
L5 = lengths(5);
L6 = lengths(6);
L7 = lengths(7);
L8 = lengths(8);
B1x = lengths(9);
B2x = lengths(10);
B1y = lengths(11);
B2y = lengths(12);

%% "unpack" individual angles from "qa" and "qu" input vectors:
% Note: this step is just for cleaner-looking code.
th1 = qa(1); th2 = qu(1); th3 = qu(2); % theta-chain
ph1 = qa(2); ph2 = qu(3); ph3 = qu(4); % phi-chain
ps1 = qa(3); ps2 = qu(5); ps3 = qu(6); % psi-chain

%% 
switch chain
    case 1 % theta-chain
        J = [-L1*sin(th1) - L2*sin(th1+th2) - L8*sin(th1+th2+th3), ...
            -L2*sin(th1+th2) - L8*sin(th1+th2+th3), ...
            -L8*sin(th1+th2+th3);
            L1*cos(th1) + L2*cos(th1+th2) + L8*cos(th1+th2+th3), ...
            L2*cos(th1+th2) + L8*cos(th1+th2+th3), ...
            L8*cos(th1+th2+th3);
            1,1,1];
    case 2 % phi-chain
        J = [-L3*sin(ph1) - L4*sin(ph1+ph2) - (L7+L8)*sin(ph1+ph2+ph3), ...
            -L4*sin(ph1+ph2) - (L7+L8)*sin(ph1+ph2+ph3), ...
            -(L7+L8)*sin(ph1+ph2+ph3);
            L3*cos(ph1) + L4*cos(ph1+ph2) + (L7+L8)*cos(ph1+ph2+ph3), ...
            L4*cos(ph1+ph2) + (L7+L8)*cos(ph1+ph2+ph3), ...
            (L7+L8)*cos(ph1+ph2+ph3);
            1,1,1];
    case 3 % psi-chain
        J = [-L5*sin(ps1) - L6*sin(ps1+ps2) - L8*sin(ps1+ps2+ps3), ...
            -L6*sin(ps1+ps2) - L8*sin(ps1+ps2+ps3), ...
            -L8*sin(ps1+ps2+ps3);
            L5*cos(ps1) + L6*cos(ps1+ps2) + L8*cos(ps1+ps2+ps3), ...
            L6*cos(ps1+ps2) + L8*cos(ps1+ps2+ps3), ...
            L8*cos(ps1+ps2+ps3);
            1,1,1];
    otherwise
        error('subchainJacobian error: unknown open subchain selection');
end % end "switch chain..."
end