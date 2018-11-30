%========================================================================
% This is the script that will run the cases we care about
%========================================================================

clc
close all
clear 
currentFolder = pwd;
file    =  strcat(currentFolder, '\simpleFlange.msh');
% these constants are their natural SI value then multiplied/divided
% to use a consistent set of units (the numbers at this point are simply
% made up/plausable)
E_fl = 195e9/1e6; %195 GPa, consistent unit is MPa
poison = 0.3;
pressure = 100e6 / 1e6; %100 MPa, consistent unit is MPa
% read in the mesh
originalMesh = ReadInMeshInfo(file, []);
mesh = originalMesh;
% number of nodes gets used a lot, store it
N_n=originalMesh.NumNodes;

% get nodes that are fixed (just making up numbers here)
fixedNodes = Node.FindNodesInRange(originalMesh.Nodes, 2.98, 4.02, 0, 5); % pretend bolt is fixed
% and where we stop modeling the pipe (cause why not)
fixedNodes = [fixedNodes, Node.FindNodesInRange(originalMesh.Nodes, 0, 1.01, 0, 0.02)];

% get nodes where there is a pressure
pressureNodes = Node.FindNodesInRange(originalMesh.Nodes, 0, 0.02, 0, 6);
pressureNodes = [pressureNodes, Node.FindNodesInRange(originalMesh.Nodes, 0, 3, 4.98, 6)];
pressureNodes = [pressureNodes, Node.FindNodesInRange(originalMesh.Nodes, 2.98, 3.02, 4.98, 6)];

% do it all!
numSteps = 5;
finalAnswer = zeros(1,N_n*2);
pressures = [100, -100, 100, -100, 100, -100, 100, -100];
maxDisplacements = [1,length(pressures)];
femSystems(1:length(pressures)) = FemSystem(1,2,3);
pc = 0;
%for pressureSte = 1:numSteps
for pressureToLoad = pressures
    pc=pc+1;
    %pressureToLoad = lastPressure + pressure/numSteps;
    femSystem = ApplyStressToMesh(mesh, E_fl, poison, pressureToLoad, pressureNodes, 0, [], fixedNodes);
    femSystems(pc)=femSystem;
    mesh = ReadInMeshInfo(file, femSystem.D);
    finalAnswer = finalAnswer + femSystem.D;
    lastPressure = pressureToLoad;
    maxDisplacements(pc) = max(abs(finalAnswer));
end
maxDisplacements
% post processing
magnitudes = 1:N_n;
xs = 1:N_n;
ys = 1:N_n;
for nC= 1:N_n
    x=finalAnswer((nC-1)*2+1);
    xs(nC) = x;
    y=finalAnswer((nC-1)*2+2);
    ys(nC) = y;
    magnitudes(nC) = sqrt(x*x+y*y);
    %TODO: Stresses, strains, displacements at critical points (do we
    %leak)?
end

%---- visualize in matlab ---------------------
twoDNodes = mesh.TwoDNodes;
figure(1)
trimesh(mesh.TwoDElements, twoDNodes(:,1),twoDNodes(:,2), magnitudes)
xlabel('X','fontsize',14)
ylabel('Y','fontsize',14)
title('GMsh to MATLAB import','fontsize',14)
fh = figure(1);
set(fh, 'color', 'white'); 

figure(2)
trimesh(mesh.TwoDElements, twoDNodes(:,1),twoDNodes(:,2), xs)
xlabel('X','fontsize',14)
ylabel('Y','fontsize',14)
title('X displacement','fontsize',14)
fh = figure(2);
set(fh, 'color', 'white'); 

figure(3)
trimesh(mesh.TwoDElements, twoDNodes(:,1),twoDNodes(:,2), ys)
xlabel('X','fontsize',14)
ylabel('Y','fontsize',14)
title('Y displacement','fontsize',14)
fh = figure(3);
set(fh, 'color', 'white'); 

figure(4)
trimesh(mesh.TwoDElements, mesh.TwoDNodes(:,1),mesh.TwoDNodes(:,2))
xlabel('X','fontsize',14)
ylabel('Y','fontsize',14)
title('New Mesh','fontsize',14)
fh = figure(4);
set(fh, 'color', 'white'); 
%-------------------------------------------------------------------------