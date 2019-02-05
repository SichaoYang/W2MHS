function num = WhyD_batch(hObject, eventdata, handles, batch)
%%                       PARAMETERS
%%  batch:
%   path of user selected files and folders 

num = 0;

for i = 1:length(batch)
    if batch(i).isdir
        path = batch(i).name;
        subbatch = dir(fullfile(path, '*.nii'));
        for j = 1:length(subbatch)
            subbatch(j).name = fullfile(subbatch(j).folder, subbatch(j).name);
        end
        n = WhyD_batch(hObject, eventdata, handles, subbatch);
        if n > 0
            fprintf('Successfully added %d subjects in directory %s\n', n, path);
        else
            fprintf('Did not find any matching subjects in directory: %s\n', path);
        end
        num = num + n;
        continue
    end
    [~, bravo, ~] = fileparts(lower(batch(i).name));
    if isempty(regexp(bravo, 'bravo', 'once')), continue; end
    flair = strrep(bravo, 'bravo', 'flair');
    found = 0;
    ind = regexp(bravo, '[0-9].*'); if isempty(ind), ind = 1; end
    id = regexprep(regexprep(bravo(ind:end), '(bravo|flair| )', ''), '_+', '_');
    if id(end) == '_', id = id(1:end-1); end
    
    for j = 1:length(batch)
        [~, name, ~] = fileparts(lower(batch(j).name));
        if(strcmpi(name, flair))
            found = j;
            tmp = get(handles.image_list, 'String');
            [row, ~] = size(tmp);
            
            string(1:79) = 'ID:                    T1:                         T2:                         ';
            endInd = min(4+numel(id)-1, 22);
            string(4:endInd) = id(1:endInd-3);

            endInd = min(27+numel(bravo)-1, 50);
            string(27:endInd) = bravo(1:endInd-26);

            endInd = min(56+numel(flair)-1, 79);
            string(56:endInd) = flair(1:endInd-55);

            tmp{row+1} = string;
            set(handles.image_list, 'String', tmp);

            image_matrix = getappdata(handles.image_list, 'image_matrix');
            id_matrix = getappdata(handles.image_list, 'id_matrix');

            [row, ~] = size(image_matrix);
            image_matrix{row+1,1} = batch(i).name;  image_matrix{row+1,2} = batch(j).name;
            id_matrix{row+1,1} = id;

            num = num + 1;
            setappdata(handles.image_list, 'image_matrix', image_matrix);
            setappdata(handles.image_list, 'id_matrix', id_matrix);
            set(handles.image_list, 'Value', row+1);
            
            break
        end
    end

    if found == 0
        fprintf('Could not find a match for: %s.nii\n', bravo);
    end
end

if num ~=0
    fprintf('Successfully added %d subjects...\n', num );
else
    fprintf('Did not find any matching subjects...\n');
end

