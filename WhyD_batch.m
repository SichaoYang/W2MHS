function  WhyD_batch(~, ~, handles, path)

%clc

if(path(end) ~= '/')
    path(end+1) = '/';
end

%%                       PARAMETERS
%   Modify the following parameters:

%%  batch_path:
%   --This is where all of your T1 and T2 images should be stored.  This
%   script will automatically grab all of the image pairs it finds in the
%   directory. Keep the '/' at the end!

batch = dir(path);
s = size(batch);
name = {'0'};
num = 0;

for i = 3 : s(1)

    fNam = lower(batch(i).name);
    br = regexp(fNam, 'bravo');
    ind = regexp(fNam, '[0-9].*');
    if ind, found = 1;
    else,   found = 0; ind = 0;
    end
    
    id = strrep(strrep(strrep(strrep(strrep(fNam(max(ind,1):end),...
        'bravo',''),'flair',''),'__','_'),'.nii',''),' ','');
    if name{1,1} == '0'
       name = {strrep(strrep(fNam(1:ind-1),'_',''),' ','')};
    end

    if (numel(br) == 1)
        for j = 4 : s(1)
            search = strrep(fNam,'bravo', 'flair');
            if(strcmpi(batch(j).name, search))
                found = j;

                tmp = get(handles.image_list, 'String');
                [row, ~] = size(tmp);


                string(1:79) = 'ID:                    T1:                         T2:                         ';
                endInd = min(4+numel(id)-1, 22);
                string(4:endInd) = id(1:endInd-3);

                endInd = min(27+numel(batch(i).name)-1, 50);
                string(27:endInd) = batch(i).name(1:endInd-26);

                endInd = min(56+numel(batch(j).name)-1, 79);
                string(56:endInd) = batch(j).name(1:endInd-55);
                
                tmp{row+1} = string;
                set(handles.image_list, 'String', tmp);

                image_matrix = getappdata(handles.image_list, 'image_matrix');
                id_matrix = getappdata(handles.image_list, 'id_matrix');

                [row, ~] = size(image_matrix);
                image_matrix{row+1,1} = strcat(path,batch(i).name);  image_matrix{row+1,2} = strcat(path,batch(j).name);
                id_matrix{row+1,1} = id;

                num = num + 1;
                setappdata(handles.image_list, 'image_matrix', image_matrix);
                setappdata(handles.image_list, 'id_matrix', id_matrix);
                set(handles.image_list, 'Value', row+1);
            end
        end
    end

   
    if found == 0 && numel(br) == 1
        fprintf('Could not find a match for: %s\n', batch(i).name);
    end
end

if num ~=0
    fprintf('Successfully added %d subjects...\n', num );
else
    fprintf('Did not find any matching subjects in directory: %s\n', path);
end

clear batch s name num fNam br ind found id i j row search

