function J = dimensionObjectiveFunction(symlengths, wrench, torqueWeight, volWeight, resolution, vizOption)
%% Description:
% Computes a quadratic objective function (for optimization) using torques
% and joint velocities, calculated from an input wrench and an input twist
% using the actuator Jacobian (which is a function of link lengths and
% joint angles).

% Inputs:
% symlengths: 8x1 array
%   [L1; L2; L3; L4; L7; L8; B1x; B1y;];
%   symlengths is converted to lengths (12x1) by the following symmetries:
%       L5 = L1;
%       L6 = L2;
%       B2x = B1x;
%       B2y = B1y;

% wrench: 3x1 array
%   [Fx; Fy; Mz];

% torqueWeight: scalar weight

% volWeight: scalar weight

% resolution: how many points along each dimension of the workspace. 11 is
% fast. 21 is slow.

% vizOption: 0 or 1
%   0: do not output visualization of reachable workspace
%   1: output a visualization of the reachable workspace

% Output:
% J: scalar value of the objective function

%% Convert "symlengths" to "lengths":
lengths = [symlengths(1); symlengths(2); symlengths(3); symlengths(4);
           symlengths(1); symlengths(2); symlengths(5); symlengths(6);
           symlengths(7); symlengths(7); symlengths(8); symlengths(8)];

%% Define the end-effector workspace that will be searched for the "achievable" workspace:
footXarray = linspace(-0.25, 0.25, resolution);
footYarray = linspace(-0.25, -0.0, resolution);
footAnglearray = linspace(-3*pi/4, -pi/4, resolution);
% footXarray = linspace(-0.0, 0.0, 11);
% footYarray = linspace(-0.25, -0.25, 11);
% footAnglearray = linspace(-80*pi/180, -80*pi/180, 11);

reachablePose = []; % array to store all the reachable foot poses
torqueMagArray = [];

%% Brute-force exploration of workspace:
for i = 1:length(footXarray)
    for j = 1:length(footYarray)
        for k = 1:length(footAnglearray)
            try
                footPose = [footXarray(i); footYarray(j); footAnglearray(k)];
                [tempAngles] = subchainIK(footPose,lengths,0);
                if checkJointLimits(tempAngles)
                    reachablePose = horzcat(reachablePose, footPose);
                    space_wrench = [cos(footPose(3)) -sin(footPose(3)) 0; 
                                   sin(footPose(3)) cos(footPose(3)) 0;
                                   0 0 1]*wrench;
                    torques = wrench2torques(tempAngles, lengths, space_wrench);
                    torqueMag = norm(torques);
                    torqueMagArray = horzcat(torqueMagArray,torqueMag);
%                     if vizOption==1
%                         plot3(footPose(1),footPose(2),footPose(3),'b.');
%                         hold on
%                     end
                end
            catch
%                 fprintf(['failed: x = ',num2str(footXarray(i)),', y = ',...
%                         num2str(footYarray(j)),', ang = ',...
%                         num2str(footAnglearray(k)),' is unsolvable.\n']);
            end % end try/catch
        end
    end
end

if vizOption==1
    reachablePoseT = reachablePose';

    % the following method is from
    % https://stackoverflow.com/questions/5492806/plotting-a-surface-from-a-set-of-interior-3d-scatter-points-in-matlab
    DT = delaunayTriangulation(reachablePoseT);  % Create the tetrahedral mesh
    hullFacets = convexHull(DT);       % Find the facets of the convex hull

    figure;
    % Plot the scattered points:
%     subplot(2,2,1);
    scatter3(reachablePoseT(:,1),reachablePoseT(:,2),reachablePoseT(:,3),'.');
%     axis square;
%     title('Interior points');
% 
%     %# Plot the tetrahedral mesh:
%     subplot(2,2,2);
%     tetramesh(DT);
%     axis square;
%     title('Tetrahedral mesh');
% 
%     %# Plot the 3-D convex hull:
%     subplot(2,2,3);
%     trisurf(hullFacets,DT.Points(:,1),DT.Points(:,2),DT.Points(:,3),'FaceColor','c')
%     axis square;
%     title('Convex hull');
    
    xlabel('Foot X')
    ylabel('Foot Y')
    zlabel('Foot angle')
    title('Reachable foot workspace')
end

%% Calculate "volume" of reachable workspace:
volWorkspace = (range(reachablePose(1,:))^2)*(range(reachablePose(2,:))^2)*(range(reachablePose(3,:))^2);
% fprintf('volWorkspace = %f\n',volWorkspace);

%% Calculate joint torques (Nm) from input wrench:
torqueMagMax = max(torqueMagArray);

%% Calculate value of objective function:
J = torqueWeight*(torqueMagMax^2) + volWeight*((1/volWorkspace)^2);
end