function AverageGMmaskG_Optimized()
    visit = 'V2';
    GMmaskThr = 0.4;
    graphThr = 0.2;
    
    subs = [];

    for i = 2 % Use your desired range of subjects here
        % Creating the object subject
        sub = subjectG(i);
        
        % Constructing the folder and filename
        index = sprintf('%02d', i);
        folder = strcat('sub-', index);
        filename_bold = strcat(folder, '_antsed_bold_blur_res-8.nii');
        path_bold = fullfile('path to func file', visit, folder, 'func', filename_bold);
        
        % Loading the bold file
        mysub = load_nii(path_bold);
        
        % Load the GMmask, considering that you didn't provide the exact loading method
        GMmask = loadGMmask(); % Load your GMmask here
        
        % Creating the graph for each object
        sub = CreateGraph(sub, mysub, GMmask.img, GMmaskThr);
        
        % Collecting subjects into an array
        subs = [subs, sub]; 
    end

    [x, y] = size(subs);

    for i = 1:y
        % Calculate global and nodal features of the graph
        GraphFeatures(subs(i), graphThr, visit);
        dcMap(subs(i), visit, GMmaskThr);
    end

    % save('filename', '-v7.3')
end
