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
% number of nodes gets used a lot
N_n=originalMesh.NumNodes;
femSystem=1;
lastPressure = 0;
% do it all!
for pressureSte = 1:1
    pressureToLoad = lastPressure + pressure/1;
    femSystem = ApplyStressToMesh(mesh, E_fl, poison, pressureToLoad);
    newMesh = ReadInMeshInfo(file, femSystem.D);
    lastPressure = pressureToLoad;
end
finalAnswer = femSystem.D;
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

%myNodes(1:N_n) = Node(0,0,0,0);
%updated2dNodes = [N_n,3];
%for n = 1:N_n
%    currentNode = myNodes(n);
%   myNodes(n) = Node(currentNode.Index, currentNode.X + finalAnswer((n-1)*2+1), currentNode.Y + finalAnswer((n-1)*2+2), 0);
%    updated2dNodes(n,1) = myNodes(n).X;
%    updated2dNodes(n,2) = myNodes(n).Y;
%end
%updated2dNodesForPlot = updated2dNodes(:,1:2);
figure(4)
trimesh(newMesh.TwoDElements, newMesh.TwoDNodes(:,1),newMesh.TwoDNodes(:,2))
xlabel('X','fontsize',14)
ylabel('Y','fontsize',14)
title('New Mesh','fontsize',14)
fh = figure(4);
set(fh, 'color', 'white'); 
%-------------------------------------------------------------------------