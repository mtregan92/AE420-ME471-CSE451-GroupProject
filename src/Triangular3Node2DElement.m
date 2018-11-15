classdef Triangular3Node2DElement < Element
    %TRIANGULAR3NODE2DELEMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    % again, Z is ignored
    
    properties
        Node1
        Node2
        Node3
        PoisonsRatio
        E
        Thickness
    end
    
    methods
        function obj = Triangular3Node2DElement(node1, node2, node3, v, e, thickness)
            obj@Element([node1, node2, node3]);
            obj.Node1 = node1;
            obj.Node2 = node2;
            obj.Node3 = node3;
            obj.PoisonsRatio = v;
            obj.E = e;
            obj.Thickness = thickness;
        end
        
        function kLocal = LocalStiffnessMatrix(obj, coefficient)
            % From this link:  http://www.unm.edu/~bgreen/ME360/2D%20Triangular%20Elements.pdf
            x1 = obj.Node1.X;
            x2 = obj.Node2.X;            
            x3 = obj.Node3.X;
            
            y1 = obj.Node1.Y;
            y2 = obj.Node2.Y;
            y3 = obj.Node3.Y;
            
            x13 = x1-x3;
            x23 = x2-x3;
            x12 = x1-x2;
            x31 = -1*x13;
            x32 = -1*x23;
            x21 = -1*x12;
            
            y13 = y1-y3;
            y23 = y2-y3;
            y12 = y1-y2;
            y31 = -1*y13;
            y32 = -1*y23;
            y21 = -1*y12;
            
            
            detJ = x13*y23-y13*x23;
            area = (1/2)*abs(detJ);
            B = (1/detJ)*[y23, 0, y31, 0, y12, 0; 0, x32, 0, x13, 0, x21; x32, y23, x13, y31, x21, y12];
            v = obj.PoisonsRatio;
            D = obj.E/(1-v*v)*[1, v, 0; v, 1, 0; 0, 0, (1-v)/2];
            
            kLocal = obj.Thickness*area*transpose(B)*D*B;
        end
        
    end
    
end

