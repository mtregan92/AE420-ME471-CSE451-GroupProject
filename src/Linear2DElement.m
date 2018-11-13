classdef Linear2DElement < Element
    %LINEAR1DELEMENT 
    % z value will be ignored
    
    properties
        Node1
        Node2
        LengthSymbol
    end
    
    methods
        function obj = Linear2DElement(node1, node2)            
            obj@Element([node1, node2]);
            obj.Node1 = node1;
            obj.Node2 = node2;
            len = sym('l');
            obj.LengthSymbol = len;
        end
        
        function kLocal = LocalStiffnessMatrix(obj, coefficient)
            node1 = obj.Node1;
            node2 = obj.Node2;
            angle = atan2(node1.Y-node2.Y, node1.X - node2.X);
            c = cos(angle);
            s = sin(angle);
            c2 = round(c*c * 1e8)/1e8;
            s2=round(s*s* 1e8)/1e8;
            cs=round(c*s* 1e8)/1e8;
            realLength = Element.ComputeLengthBetweenNodes(node1, node2);
            coefficient = subs(coefficient, obj.LengthSymbol, realLength);
            
            kLocal = coefficient * [c2, cs, -c2, -cs; cs, s2, -cs, -s2; -c2, -cs, c2, cs; -cs, -s2, cs, s2];            
        end
        
        %function concentratedLoadVector = CreateConcentratedLoadVector(obj, nodeIndex, coef, xDir, yDir) 
        %    % note that calling code should NOT call this more than once
        %    % for a new load
        %    if~(nodeIndex == obj.Node1.Index || nodeIndex == obj.Node2.Index)
        %        concentratedLoadVector  = [0;0];
        %        return
        %    end
        %    realLength = obj.ComputeLengthBetweenNodes(obj.Node1, obj.Node2);
        %    coef=subs(coef, LengthSymbol, realLength);
        %    angleSplitBetween
        %end
        
        function gravityLoadVector = CreateGravityLoadVector(obj, coef)
            node1 = obj.Node1;
            node2 = obj.Node2;
            realLength = obj.ComputeLengthBetweenNodes(node1, node2);
            coef=subs(coef, obj.LengthSymbol, realLength);
            gravityLoadVector = coef * [0; 1 /2; 0; 1 /2];
        end
        
        function thermalLoadVector = CreateThermalLoadVector(obj, coef)
            node1 = obj.Node1;
            node2 = obj.Node2;
            angle = atan2(node1.Y-node2.Y, node1.X - none2.X);
            c = cos(angle);
            s = sin(angle);
            thermalLoadVector= coef*[-c; -s; c; s];
        end
    end    
end

