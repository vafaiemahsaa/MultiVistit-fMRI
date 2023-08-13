classdef subjectG
    properties
        sID;
        nodes;
        xyzcoordinates;
        crGraph;
        thr_crGraph;
        dc;
        label;
        features;
    end
    
    methods
        function obj = subjectG(xsID)
            obj.sID = xsID;
            obj.nodes = [];
            obj.xyzcoordinates = [];
            obj.crGraph = [];
            obj.thr_crGraph = [];
            obj.dc = [];
            obj.label = '';
            obj.features = [];
        end
        
        function obj = SaveNodeCoordinates(obj, xdim1, xdim2, xdim3, xID)
            temp_node = nodeG(xdim1, xdim2, xdim3, xID);
            obj.nodes = [obj.nodes, temp_node];
        end
        
        function obj = ReturnCoordinates(obj)
            obj.xyzcoordinates = [];
            for i = 1:numel(obj.nodes)
                obj.xyzcoordinates = [obj.xyzcoordinates; [obj.nodes(i).dim1, obj.nodes(i).dim2, obj.nodes(i).dim3]];
            end
        end
        
        function obj = CreateGraph(obj, mysub, mymask, thr)
            [dim1, dim2, dim3, volume_fmri_data] = size(mysub.img);
            mynodes = zeros(1, volume_fmri_data - 5);
            count = 1;
            
            for i = 1:dim1
                for j = 1:dim2
                    for k = 1:dim3
                        isitnan = false;
                        isnode = true;
                        temp = mymask(i, j, k);
                        
                        if temp < thr
                            isnode = false;
                            mymask(i, j, k) = 0;
                        else
                            mymask(i, j, k) = 1;
                        end
                        
                        if isnode
                            temp = mysub.img(i, j, k, 6:volume_fmri_data) .* mymask(i, j, k);
                            temp_nan = isnan(temp);
                            
                            if any(temp_nan)
                                isitnan = true;
                            end
                            
                            if ~isitnan
                                mynodes(count, :) = temp;
                                obj = obj.SaveNodeCoordinates(i, j, k, count);
                                count = count + 1;
                            end
                        end
                    end
                end
            end
            
            [x, ~] = size(mynodes);
            obj.crGraph = zeros(x, x);
            
            for i = 1:x
                for j = 1:x
                    [M, ~] = corrcoef(mynodes(i, :), mynodes(j, :));
                    obj.crGraph(i, j) = M(1, 2);
                end
            end
        end
        
        function obj = GraphFeatures(obj, thr)
            temp1 = threshold_proportional(obj.crGraph, thr);
            obj.thr_crGraph = [obj.thr_crGraph, temp1];
            obj.dc = degrees_und(temp1);
        end
        
        function dcMap(obj, GMmask, visit, thr)
            temp = GMmask;
            [dim1, dim2, dim3] = size(GMmask.img);
            count = 1;
            
            for i = 1:dim1
                for j = 1:dim2
                    for k = 1:dim3
                        if temp.img(i, j, k) < thr
                            temp.img(i, j, k) = 0;
                        else
                            temp.img(i, j, k) = 1;
                            temp.img(i, j, k) = obj.dc(count);
                            count = count + 1;
                        end
                    end
                end
            end
            
            index = sprintf('%02d', obj.sID);
            stringname = strcat('PT_PL', index, '_', visit, '_dcmaps-.nii');
            save_nii(temp, stringname);
        end
    end
end
