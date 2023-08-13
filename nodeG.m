classdef nodeG
    %   saving the original cordinates of the nodes

    properties
        dim1;
        dim2;
        dim3;
        ID; % node index 
    end

    methods
        function obj = nodeG(xdim1,xdim2,xdim3,xID)
            obj.dim1=xdim1;
            obj.dim2=xdim2;
            obj.dim3=xdim3;
            obj.ID=xID;

        end
    end
end
