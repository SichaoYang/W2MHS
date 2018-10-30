function  WhyD_batch(hObject, eventdata, handles, path)

clc

if(path(numel(path)) ~= '/')
    path(numel(path)+1) = '/';
end

%%                       PARAMETERS
%   Modify the following parameters:

%%  batch_path:
%   --This is where all of your T1 and T2 images should be stored.  This
%   script will automatically grab all of the image pairs it finds in the
%   directory. Keep the '/' at the end!

batch = dir(path);
s = size(batch);  name = {'0'};
num = 0;

for i = 3 : s(1)

    fNam = lower(batch(i).name);  br = regexp(fNam, 'bravo');
    fl = regexp(fNam, 'flair');  s = size(batch); l = size(fNam);
    found = 0; ind = 0;

    for j = 1:l(2)
        char = fNam(j);
        if (char == '0' || char == '1' || char == '2' || char == '3' || ...
                char == '4' || char == '5' || char == '6' || char == '7' || ...
                char == '8' || char == '9') && ind == 0
            ind = j; found = 1;
            break;
        end
    end
    if(ind ~=0)
        id = strrep(strrep(strrep(strrep(strrep(lower(fNam(ind:end)),'bravo','')   ...
            ,'flair',''),'__','_'),'.nii',''),' ','');
    else
        id = strrep(strrep(strrep(strrep(strrep(lower(fNam),'bravo','')   ...
            ,'flair',''),'_',''),'.nii',''),' ','');
    end

    if name{1,1} == '0'
        name = {strrep(strrep(fNam(1:ind-1),'_',''),' ','')};
    end

    if (numel(br) == 1)
        for j = 4 : s(1)
            search = strrep(fNam,'bravo', 'flair');
            if(strcmpi(batch(j).name,search))
                found = j;


                tmp = get(handles.image_list, 'String');
                [row, col] = size(tmp);


                string(1:79) = 'ID:                    T1:                         T2:                         ';
                endInd = 4+numel(id)-1;
                if(endInd > 22)
                    endInd = 22;
                end
                string(4:endInd) = id(1:endInd-3);

                endInd = 27+numel(batch(i).name)-1;
                if(endInd > 50)
                    endInd = 50;
                end
                string(27:endInd) = batch(i).name(1:endInd-26);

                endInd = 56+numel(batch(j).name)-1;
                if(endInd > 79)
                    endInd = 79;
                end
                string(56:endInd) = batch(j).name(1:endInd-55);

                tmp{row+1} = string;
                set(handles.image_list, 'String', tmp);

                tmp = getappdata(handles.image_list, 'image_matrix');
                tmp2 = getappdata(handles.image_list, 'id_matrix');

                [row, col] = size(tmp);
                tmp{row+1,1} = strcat(path,batch(i).name);  tmp{row+1,2} = strcat(path,batch(j).name);
                tmp2{row+1,1} = id;

                num = num + 1;
                setappdata(handles.image_list, 'image_matrix', tmp);
                setappdata(handles.image_list, 'id_matrix', tmp2);
                set(handles.image_list, 'Value', row+1);

            end
        end
    end

   
    if found == 0 && numel(br) == 1
        fprintf('Could not find a match for: %s\n', batch(i).name);
    else
    end
end

clear batch br char col fNam fl found i id ind j l row s search

if num ~=0
    fprintf('Successfully added %d subjects...\n', num );
else
    fprintf('Did not find any matching subjects in directory: %s\n', path);

end
