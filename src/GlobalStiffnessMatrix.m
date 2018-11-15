classdef GlobalStiffnessMatrix < handle
    %GlobalStiffnessMatrix is a type that can be used to assemble the
    %global stiffness matrix from a set of Elements.  
    
    properties (GetAccess = public, SetAccess = private)
        % The stiffness matrix.  Note that this does mutate as elements are
        % added to the matrix.
        K
        % The number of variables per node (2 for 2D X and Y, 3 for 3D X, Y
        % and Z).
        NumberOfFreeElementsPerNode
    end
    
    methods
        function obj = GlobalStiffnessMatrix(numNodes, numFreeElements)
            % switch to the sparse matrix when we are happy with the
            % assembly part of FEM
            %obj.K=sparse ( numNodes*numFreeElements , numNodes*numFreeElements );
            obj.K = zeros(numNodes*numFreeElements, numNodes*numFreeElements);
            obj.NumberOfFreeElementsPerNode=numFreeElements;
        end
        
%         function Add2NodeElementStiffnessMatrixNew(obj, elements, coef)
%             % Combine a local stiffness matrix into the global stiffness
%             % matrix.
%             n=obj.NumberOfFreeElementsPerNode;
%             %elNum = 0;
%             %for el = elements
%             %    elNum=elNum+1;
%                 
%                 for k=1:length(elements)
%                     elm = elements(k);
%                     E=elm.LocalStiffnessMatrix(coef);
%                     rowCount = 0;
%                     for row = E.'
%                         colCount = 0;
%                         rowCount=rowCount+1;
%                         for val = row
%                             colCount = colCount+1;
%                             
%                             rowInK = elm.Nodes(floor(rowCount/2+1)).Index;
%                             colInK = elm.Nodes(floor(colCount/2+1)).Index;
%                             obj.K(rowInK, colInK)=obj.K(rowInK, colInK)+val(colCount); 
%                         end
%                     end
%                     
%                     
%                     
% %                     for il =1:length(elements(k).Nodes)
% %                         i=elements(k).Nodes(il).Index + (il-1)*n;%me(il, elNum);
% %                         for jl =1:length(elements(k).Nodes)
% %                             j=elements(k).Nodes(jl).Index + (jl-1)*n;%me(jl, elNum);
% %                             
% %                             obj.K(i, j)=obj.K(i, j)+E(il, jl);                               
% %                             obj.K(i, j+1)=obj.K(i, j+1)+E(il, jl+1);  
% %                             obj.K(i, j+2)=obj.K(i, j+2)+E(il, jl+2);                              
% %                             obj.K(i, j+3)=obj.K(i, j+3)+E(il, jl+3);  
% %                             % and more if n=3
% %                                % obj.K(j+xyzC, i)=obj.K(i, j+xyzC);
% %                             
% %                         end
% %                     end
%                 end
%             %end
% 
%         end
        
        function Add2NodeElementStiffnessMatrix(obj, element, kLocal)
            % Combine a local stiffness matrix into the global stiffness
            % matrix.
            n=obj.NumberOfFreeElementsPerNode;       
            node1 = element.Nodes(1);
            node2 = element.Nodes(2);
            %for node1 = element.Nodes
                %for node2 = element.Nodes                                    
                    for r = 1:n
                        for c = 1:n
                            obj.K((node1.Index-1)*n+r, (node1.Index-1)*n+c) = obj.K((node1.Index-1)*n+r, (node1.Index-1)*n+c)+kLocal(r,c);
                            obj.K((node1.Index-1)*n+r, (node2.Index-1)*n+c) = obj.K((node1.Index-1)*n+r, (node2.Index-1)*n+c)+kLocal(r+2,c);
                            obj.K((node2.Index-1)*n+r, (node1.Index-1)*n+c) = obj.K((node2.Index-1)*n+r, (node1.Index-1)*n+c)+kLocal(r,c+2);
                            obj.K((node2.Index-1)*n+r, (node2.Index-1)*n+c) = obj.K((node2.Index-1)*n+r, (node2.Index-1)*n+c)+kLocal(r+2,c+2);
                        end
                    end
               %end
            %end
        end
        
        function Add3NodeElementStiffnessMatrix(obj, element, kLocal)
            % CURRENTLY UNTESTED 
            n=obj.NumberOfFreeElementsPerNode;
            node1 = element.Nodes(1);
            node2 = element.Nodes(2);
            node3 = element.Nodes(3);
            for r = 1:n
                for c = 1:n
                    % the elements from kLocal getting added to the matrix
                    % are probably wrong!!!!!
                    obj.K((node1.Index-1)*n+r, (node1.Index-1)*n+c) = obj.K((node1.Index-1)*n+r, (node1.Index-1)*n+c)+kLocal(r,c);
                    obj.K((node1.Index-1)*n+r, (node2.Index-1)*n+c) = obj.K((node1.Index-1)*n+r, (node2.Index-1)*n+c)+kLocal(r+3,c);
                    obj.K((node1.Index-1)*n+r, (node3.Index-1)*n+c) = obj.K((node1.Index-1)*n+r, (node3.Index-1)*n+c)+kLocal(r+6,c);
                    
                    obj.K((node2.Index-1)*n+r, (node1.Index-1)*n+c) = obj.K((node2.Index-1)*n+r, (node1.Index-1)*n+c)+kLocal(r,c+3);
                    obj.K((node2.Index-1)*n+r, (node2.Index-1)*n+c) = obj.K((node2.Index-1)*n+r, (node2.Index-1)*n+c)+kLocal(r+3,c+3);
                    obj.K((node2.Index-1)*n+r, (node3.Index-1)*n+c) = obj.K((node2.Index-1)*n+r, (node3.Index-1)*n+c)+kLocal(r+4,c+3);

                    obj.K((node3.Index-1)*n+r, (node1.Index-1)*n+c) = obj.K((node3.Index-1)*n+r, (node1.Index-1)*n+c)+kLocal(r,c+3);
                    obj.K((node3.Index-1)*n+r, (node2.Index-1)*n+c) = obj.K((node3.Index-1)*n+r, (node2.Index-1)*n+c)+kLocal(r+3,c+3);
                    obj.K((node3.Index-1)*n+r, (node2.Index-1)*n+c) = obj.K((node3.Index-1)*n+r, (node2.Index-1)*n+c)+kLocal(r+5,c+3);
                end
            end
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


