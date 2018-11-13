classdef GlobalStiffnessMatrix < handle
    %GLOBALSTIFFNESSMATRIX Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        K
        NumberOfFreeElementsPerNode
    end
    
    methods
        function obj = GlobalStiffnessMatrix(numNodes, numFreeElements)
            obj.K = zeros(numNodes*numFreeElements, numNodes*numFreeElements);
            obj.NumberOfFreeElementsPerNode=numFreeElements;
        end
        
        function Add2NodeElementStiffnessMatrix(obj, element, kLocal)
            n=obj.NumberOfFreeElementsPerNode;
            node1 = element.Nodes(1);
            node2 = element.Nodes(2);
            %for node1 = element.Nodes
                %for node2 = element.Nodes                                    
                    for r = 1:n
                        for c = 1:n
                            obj.K((node1.Index-1)*n+r, (node1.Index-1)*n+c) =obj.K((node1.Index-1)*n+r, (node1.Index-1)*n+c)+kLocal(r,c);
                            obj.K((node1.Index-1)*n+r, (node2.Index-1)*n+c) = obj.K((node1.Index-1)*n+r, (node2.Index-1)*n+c)+kLocal(r+2,c);
                            obj.K((node2.Index-1)*n+r, (node1.Index-1)*n+c) = obj.K((node2.Index-1)*n+r, (node1.Index-1)*n+c)+kLocal(r,c+2);
                            obj.K((node2.Index-1)*n+r, (node2.Index-1)*n+c) = obj.K((node2.Index-1)*n+r, (node2.Index-1)*n+c)+kLocal(r+2,c+2);
                        end
                    end
                %end
            %end
        end        
        
        function ApplyZeroBoundaryConditionToNode(obj, fixedNodes)
            [~, ind] = sort([fixedNodes.Index], 'descend');
            for node = fixedNodes(ind)
                for el = 1:obj.NumberOfFreeElementsPerNode
                    obj.K((node.Index-1)*obj.NumberOfFreeElementsPerNode+1, :) =[];
                    obj.K(:, (node.Index-1)*obj.NumberOfFreeElementsPerNode+1) =[];
                end
            end
        end
    end    
end


