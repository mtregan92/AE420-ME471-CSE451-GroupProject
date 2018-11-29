%------------------------------------------------------------------------%
%------ Gmsh to Matlab script: Import mesh to matlab---------------------%
%------------------------------------------------------------------------%

clc
close all
clear 

%-----------------------------------------------------------------------%
% dlmread(filename,delimiter,[R1 C1 R2 C2]) reads only the range 
% bounded by row offsets R1 and R2 and column offsets C1 and C2.
%-----------------------------------------------------------------------%
file    =  ('Y:\Homework\AE420-FiniteElementAnalysis\Homework-04\HW4_Pr4_PartB_FINAL.msh');

% no of nodes is mentioned in 5th row and first column

N_n      = dlmread(file,'',[5-1 1-1 5-1 1-1]);
N_e      = dlmread(file,'',[7+N_n 0 7+N_n 0]);

node_id     = dlmread(file,'',[5 0 4+N_n 0]);
nodes       = dlmread(file,'',[5 1 4+N_n 3]);
elements    = dlmread(file,'',[8+N_n 0 7+N_n+N_e 7]);

%------- 2D Geometry

two_d_nodes = nodes(:,1:2);
elem_type   = elements(:,2);

%--- find the starting indices of 2D elements
two_ind = 1;
for i = 1:N_e
    if(elem_type(i) ~= 2)
        two_ind = two_ind+1;
    end
end
%----------------------------------------------

two_d_elements(1:N_e-two_ind,1:3) = 0;
k = 1;
for i = two_ind:N_e
   two_d_elements(k,1:3) = elements(i,6:8);
   k = k+1;
end

%----------------------------------------------
myNodes(1:N_n) = Node(0,0,0,0);
myElements(1:length(two_d_elements)) = Triangular3Node2DElement(nodes(1), nodes(2), nodes(3), 1, 10, 1);
for i = 1:length(two_d_elements)
    
    curNode = two_d_elements(i, 1);
    if(myNodes(curNode).Index == 0)
        myNodes(curNode) = Node(curNode, nodes(curNode, 1), nodes(curNode, 2), 0);
    end
    
    curNode = two_d_elements(i, 2);
    if(myNodes(curNode).Index == 0)
        myNodes(curNode) = Node(curNode, nodes(curNode, 1), nodes(curNode, 2), 0);
    end
    
    curNode = two_d_elements(i, 3);
    if(myNodes(curNode).Index == 0)
        myNodes(curNode) = Node(curNode, nodes(curNode, 1), nodes(curNode, 2), 0);
    end
end

for i = 1:length(two_d_elements)
    myElements(i) = Triangular3Node2DElement(myNodes(two_d_elements(i,1)), myNodes(two_d_elements(i,2)), myNodes(two_d_elements(i,3)), 0.3, 100000, 1);
end

% form global items
kGlo = GlobalStiffnessMatrix(N_n, 1);
rGlo = GlobalLoadVector(N_n, 1);
for i = 1:length(two_d_elements)
    localMat = myElements(i).LocalStiffnessMatrix3x3(10, 10);    
    kGlo.AddElementStiffnessMatrix(myElements(i), localMat);        
end
finalAnswer = NaN([1,N_n]);

% apply BC's (first load, then removing rows/cols
nodesToZeroOut = [];
nodesAddressed = zeros([1,N_n]);
safeNode = NaN;
for i=1:length(two_d_elements)
    theElement = myElements(i);
    area = theElement.AreaOfElement();

    nodesToLoopOver = [];
    if(nodesAddressed(theElement.Nodes(1).Index) == 0)
        nodesToLoopOver = [nodesToLoopOver, theElement.Nodes(1)];
    end
    if(nodesAddressed(theElement.Nodes(2).Index) == 0)
        nodesToLoopOver = [nodesToLoopOver, theElement.Nodes(2)];
    end
    if(nodesAddressed(theElement.Nodes(3).Index) == 0)
        nodesToLoopOver = [nodesToLoopOver, theElement.Nodes(3)];
    end
       
    
    nodesOnCircle = [];
    nodesOn25DegEdge = [];
    nodesOnInsulatedEdge = [];    
    
    for innerNode = nodesToLoopOver
        ellipseCheck = (innerNode.X*innerNode.X/4) + (innerNode.Y*innerNode.Y/1);
        if(ellipseCheck < 1.1)
            nodesOnCircle =[nodesOnCircle, innerNode];
            nodesToZeroOut = [nodesToZeroOut, innerNode];
        end
        if(innerNode.Y > 4.9)
            nodesOn25DegEdge=[nodesOn25DegEdge, innerNode];
            %nodesToZeroOut = [nodesToZeroOut, innerNode];
        end
    end
    for innerNode = theElement.Nodes
        if(innerNode.X > 4.9 || innerNode.X < 0.1 || innerNode.Y < 0.1)
            nodesOnInsulatedEdge=[nodesOnInsulatedEdge, innerNode];
            %nodesToZeroOut = [nodesToZeroOut, innerNode];
        end
    end
    % 200 deg center
    if(length(nodesOnCircle) == 2)
        dist = Element.Compute2DLengthBetweenNodes(nodesOnCircle(1), nodesOnCircle(2));
        rVec = [-1, -1, 0];
        if(nodesOnCircle(1).Index == theElement.Nodes(1).Index && nodesOnCircle(2).Index == theElement.Nodes(3).Index)
            rVec = [-1, 0, -1];
        elseif((nodesOnCircle(1).Index == theElement.Nodes(2).Index && nodesOnCircle(2).Index == theElement.Nodes(3).Index))
            rVec = [0, -1, -1];
        end
        rGlo.Add3NodeElementScalarLoad(theElement, (200 * dist/2) * rVec);
        
        finalAnswer(nodesOnCircle(1).Index) = 200;
        finalAnswer(nodesOnCircle(2).Index) = 200;
        nodesAddressed(nodesOnCircle(1).Index)=1;
        nodesAddressed(nodesOnCircle(2).Index)=1;
        %rGlo.Add3NodeElementScalarLoad(theElement, (200 * area/3) * [1,1,1]);
        %finalAnswer(nodeOnCirc.Index) = 200;
        %nodesAddressed(nodeOnCirc.Index)=1;
    end
    
    % 25 deg top edge
    if(length(nodesOn25DegEdge)==2)
        dist = Element.Compute2DLengthBetweenNodes(nodesOn25DegEdge(1), nodesOn25DegEdge(2));
        rVec = [-1, -1, 0];
        if(nodesOn25DegEdge(1).Index == theElement.Nodes(1).Index && nodesOn25DegEdge(2).Index == theElement.Nodes(3).Index)
            rVec = [-1, 0, -1];
        elseif((nodesOn25DegEdge(1).Index == theElement.Nodes(2).Index && nodesOn25DegEdge(2).Index == theElement.Nodes(3).Index))
            rVec = [0, -1, -1];
        end
        %rGlo.Add3NodeElementScalarLoad(theElement, (25 * dist/2) * rVec);
        
        %rGlo.Add3NodeElementScalarLoad(theElement, (25 * area/3) * [1,1,1]);
        %finalAnswer(nodesOn25DegEdge(1).Index) = 25;
        %finalAnswer(nodesOn25DegEdge(2).Index) = 25;
        %nodesAddressed(nodesOn25DegEdge(1).Index)=1;
        %nodesAddressed(nodesOn25DegEdge(2).Index)=1;
    end

    % insulated edge
    if(length(nodesOnInsulatedEdge)==2)
        dist = Element.Compute2DLengthBetweenNodes(nodesOnInsulatedEdge(1), nodesOnInsulatedEdge(2));
        rVec = [-1, -1, 0];
        if(nodesOnInsulatedEdge(1).Index == theElement.Nodes(1).Index && nodesOnInsulatedEdge(2).Index == theElement.Nodes(3).Index)
            rVec = [-1, 0, -1];
        elseif((nodesOnInsulatedEdge(1).Index == theElement.Nodes(2).Index && nodesOnInsulatedEdge(2).Index == theElement.Nodes(3).Index))
            rVec = [0, -1, -1];
        end
        %rGlo.Add3NodeElementScalarLoad(theElement, (0 * dist/2) * rVec);
        
        %nodesAddressed(nodesOnInsulatedEdge(1).Index)=1;
        %nodesAddressed(nodesOnInsulatedEdge(2).Index)=1;
    
        %finalAnswer(nodesOnInsulatedEdge(1).Index) = 0;
        %finalAnswer(nodesOnInsulatedEdge(2).Index) = 0;
    end       
    
    
    
end

uniqueNodesToZeroOut = unique(nodesToZeroOut);

[rows] = size(uniqueNodesToZeroOut);
orderedUniqueNodesToZeroOut = reshape(sort(uniqueNodesToZeroOut(:), 'descend'), [rows]);

kGlo.ApplyZeroBoundaryConditionToNode(uniqueNodesToZeroOut)
rGlo.ApplyZeroBoundaryConditionTo1DNode(uniqueNodesToZeroOut)

kinv=inv(kGlo.K);
answer = kinv*rGlo.R

otherCounter = 1;
for i = 1:N_n
    if(isnan(finalAnswer(i)))
        finalAnswer(i) = answer(otherCounter);
        otherCounter=otherCounter+1;
    end
end
finalAnswer
%---- visualize in matlab ---------------------
figure(1)
trimesh(two_d_elements, two_d_nodes(:,1),two_d_nodes(:,2), finalAnswer)

xlabel('X','fontsize',14)
ylabel('Y','fontsize',14)
title('GMsh to MATLAB import','fontsize',14)
fh = figure(1);
set(fh, 'color', 'white'); 

%-------------------------------------------------------------------------


