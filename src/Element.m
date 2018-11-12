classdef (Abstract) Element
    %ELEMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        NodeIndices
        NodexList
    end
    
    methods
        function obj = Element(nodesList)
            obj.NodeIndices = [];
            obj.NodexList = nodesList;
        end
        
        function leng = ComputeLengthBetweenNodes(node1, node2)
            diffX = node1.X-node2.X;
            diffY = node1.Y-node2.Y;
            diffZ = node1.Z-node2.Z;
            leng = sqrt(diffX*diffX+diffY*diffY+diffZ*diffZ);
        end
    end
   
    methods (Abstract)        
        LocalStiffnessMatrix(obj, coefficient)        
    end
end

