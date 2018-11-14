classdef Node < handle
    % A Node is simply 3 coordinates and an index. 
    % It is simply data, it does not do anything.
    
    properties (GetAccess = public, SetAccess = private)
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
    end    
end

