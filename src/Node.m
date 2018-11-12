classdef Node < handle
    properties
        X
        Y
        Z
        Index
    end
    
    methods
        function obj = Node(i, x, y, z)
           obj.X = x;
           obj.Y = y;
           obj.Z = z;
           obj.Index = i;           
        end
        
        function node = GetNodeByIndex(nodesList, nodeIndex)
            for thing = nodesList
                if(thing.Index == nodeIndex)
                    node = thing;
                    return
                end
            end            
        end
    end    
end

