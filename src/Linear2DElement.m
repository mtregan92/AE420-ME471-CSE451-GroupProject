classdef Linear2DElement < Element
    %LINEAR1DELEMENT 
    % z value will be ignored
    
    properties
        Node1Index
        Node2Index
        LenghSymbol
    end
    
    methods
        function obj = Linear2DElement(node1Index, node2Index, nodesList)            
            obj@Element(nodesList)
            obj.Node1Index = node1Index;
            obj.Node2Index = node2Index;
            obj.LenghSymbol = syms('l');
        end
        
        function kLocal = LocalStiffnessMatrix(obj, coefficient)
            node1 = Node.GetNodeByIndex(obj.NodesList, obj.Node1Index);
            node2 = Node.GetNodeByIndex(obj.NodesList, obj.Node2Index);
            angle = atan2(node1.Y-node2.Y, node1.X - none2.X);
            c = cos(angle);
            c2 = c*c;
            s = sin(angle);
            s2=s*s;
            cs=c*s;
            realLength = obj.ComputeLengthBetweenNodes(node1, node2);
            coefficient = subs(coefficient, LengthSymbo, realLength);
            
            kLocal = coefficient * [c2, cs, -s2, -cs; cs, s2, -cs, -s2; -c2, -cs, c2, cs; -cs, -s2, cs, s2];            
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
            node1 = Node.GetNodeByIndex(obj.NodesList, obj.Node1Index);
            node2 = Node.GetNodeByIndex(obj.NodesList, obj.Node2Index);
            realLength = obj.ComputeLengthBetweenNodes(node1, node2);
            coef=subs(coef, LengthSymbol, realLength);
            gravityLoadVector = coef * [0; realLength /2; 0; realLength /2];
        end
        
        function thermalLoadVector = CreateThermalLoadVector(obj, coef)
            node1 = Node.GetNodeByIndex(obj.NodesList, obj.Node1Index);
            node2 = Node.GetNodeByIndex(obj.NodesList, obj.Node2Index);
            angle = atan2(node1.Y-node2.Y, node1.X - none2.X);
            c = cos(angle);
            s = sin(angle);
            thermalLoadVector= coef*[-c; -s; c; s];
        end
    end    
end

