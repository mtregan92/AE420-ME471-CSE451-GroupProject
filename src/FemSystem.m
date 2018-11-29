classdef FemSystem < handle
    %FEMSYSTEM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        K
        R
        D
    end
    
    methods
        function obj = FemSystem(k, r, d)
            obj.K = k;
            obj.R = r;
            obj.D = d;
        end
    end
    
end

