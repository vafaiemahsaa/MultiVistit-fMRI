function [GMmask] = AverageGMmask()
    counter = 0;
    GMmask = struct;
    GMmask.img = zeros(22, 27, 22);

    for i = 1:65
        index = sprintf('%02d', i);
        file = strcat('sub-', index);
        
        for visit = 1:3
            path_GMmask = fullfile('path to GM mask visit', num2str(visit), file, 'anat', strcat(file, 'postfix'));
            
            if exist(path_GMmask, 'file') == 2
                temp = load_nii(path_GMmask);
                GMmask.img = GMmask.img + temp.img;
                counter = counter + 1;
            else
                disp([path_GMmask, ' does not exist.']);
            end
        end
    end

    GMmask.img = GMmask.img / counter;
    GMmask.hdr = temp.hdr;

    % Save the NIfTI structure to a file
    % save_nii(GMmask, 'GMmask.nii');
end
