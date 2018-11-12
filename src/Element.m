classdef (Abstract) Element
    %ELEMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        NodeIndices
        NodeMap
    end
    
    methods
        function obj = Element(nodeMap)
            obj.NodeIndices = [];
            %TODO: change the list to a map
            obj.NodeMap = nodeMap;
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

