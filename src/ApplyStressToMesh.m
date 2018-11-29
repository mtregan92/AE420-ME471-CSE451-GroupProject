function femSystem = ApplyStressToMesh(mesh, E, poison, pressure, boltReactionPressure) 
%TODO, pass in boundary conditions and other loadings
%TODO, pass in which nodes are gasket

%APPLYSTRESSTOMESH Summary of this function goes here
%   Detailed explanation goes here
    % no of nodes is mentioned in 5th row and first column
    N_n      = mesh.NumNodes;
    nodes       = mesh.Nodes;
    %----------------------------------------------
    % create the Node instances
    myNodes(1:N_n) = Node(0,0,0,0);
    myElements(1:length(mesh.TwoDElements)) = Triangular3Node2DElement(nodes(1), nodes(2), nodes(3), poison, E, 1);

    nodeCount = 0;
    for tempNode = 1:N_n

        nodeCount = nodeCount+1;
        myNodes(nodeCount) = Node(nodeCount, nodes(nodeCount, 1), nodes(nodeCount, 2), 0);
    end
    % create the element instances
    for i = 1:length(mesh.TwoDElements)
        myElements(i) = Triangular3Node2DElement(myNodes(mesh.TwoDElements(i,1)), myNodes(mesh.TwoDElements(i,2)), myNodes(mesh.TwoDElements(i,3)), poison, E, 1);
    end

    % initalize the global items
    kGlo = GlobalStiffnessMatrix(N_n, 2);
    rGlo = GlobalLoadVector(N_n, 2);
    for i = 1:length(mesh.TwoDElements)
        localMat = myElements(i).LocalStiffnessMatrix(1);    
        kGlo.AddElementStiffnessMatrix(myElements(i), localMat);        
    end

    % populate final answer
    finalAnswer = NaN([1,N_n*2]);

    % apply the pressure to the right side
    for node = myNodes
        if((node.Y >= 5.0 && node.X <= 3.0) || node.X == 0)
            rGlo.R((node.Index-1)*2 +1) = pressure;
            rGlo.R((node.Index-1)*2 +2) = 0;
        end
    end

    % find the nodes that we will zero out for BC's (ones where x=0)
    %nodesToZeroOut = [];
    indicesZeroedOut = [];
    for node = myNodes
        if(node.Y < 4.005 && node.X > 4.5) % Y is fixed at the bolt
            %nodesToZeroOut = [nodesToZeroOut, node];
            finalAnswer((node.Index-1)*2 +1) = 0;
            finalAnswer((node.Index-1)*2 +2) = 0;
            indicesZeroedOut = [indicesZeroedOut, (node.Index-1)*2+1, (node.Index-1)*2+2];
        end
    end

    % create copies of the entire stiffness matrix and load vector 
    % so post processing can be done later
    kBck = kGlo.K;
    rBck = rGlo.R;
    
    % apply the boundary conditions
    kGlo.ApplyZeroBoundaryConditionToIndices(indicesZeroedOut)
    rGlo.ApplyZeroBoundaryConditionToIndices(indicesZeroedOut)

    % solve!
    kinv=inv(kGlo.K);
    answer = kinv*rGlo.R;

    otherCounter = 1;
    for i = 1:N_n*2
        if(~ismember(i, indicesZeroedOut))
            finalAnswer(i) = answer(otherCounter);
            otherCounter=otherCounter+1;
        end
    end
    femSystem = FemSystem(kBck, rBck, finalAnswer);

end

