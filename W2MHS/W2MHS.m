classdef W2MHS < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        File                            matlab.ui.container.Menu
        LoadSettingsMenu                matlab.ui.container.Menu
        SaveSettingsMenu                matlab.ui.container.Menu
        SetDefaultMenu                  matlab.ui.container.Menu
        HelpMenu                        matlab.ui.container.Menu
        DocumentationMenu               matlab.ui.container.Menu
        WalkThroughMenu                 matlab.ui.container.Menu
        TabGroup                        matlab.ui.container.TabGroup
        MainTab                         matlab.ui.container.Tab
        SPM12PathField                  matlab.ui.control.EditField
        SPM12PathButton                 matlab.ui.control.Button
        OutputPathField                 matlab.ui.control.EditField
        OutputPathButton                matlab.ui.control.Button
        SubjectsListBox                 matlab.ui.control.ListBox
        AddImagesButton                 matlab.ui.control.Button
        RemoveButton                    matlab.ui.control.Button
        ClearButton                     matlab.ui.control.Button
        MoveUpButton                    matlab.ui.control.Button
        MoveDownButton                  matlab.ui.control.Button
        OptionsTab                      matlab.ui.container.Tab
        ProceduresPanel                 matlab.ui.container.Panel
        VisualizationSwitchLabel        matlab.ui.control.Label
        VisualSwitch                    matlab.ui.control.Switch
        PreprocSwitch                   matlab.ui.control.Switch
        PreprocessingSwitch_2Label      matlab.ui.control.Label
        HyperparametersPanel            matlab.ui.container.Panel
        ClassificationBatchSizeSpinnerLabel  matlab.ui.control.Label
        BatchSizeSpinner                matlab.ui.control.Spinner
        ProbabilityMapCutoffLabel       matlab.ui.control.Label
        PMapCutSpinner                  matlab.ui.control.Spinner
        GrayMatterCleaningDistanceSpinnerLabel  matlab.ui.control.Label
        CleanThSpinner                  matlab.ui.control.Spinner
        PeriventricularRegionWidthLabel  matlab.ui.control.Label
        VentDilSpinner                  matlab.ui.control.Spinner
        HelperArea                      matlab.ui.control.TextArea
        InputImageTypeIdentifiersPanel  matlab.ui.container.Panel
        T1Label                         matlab.ui.control.Label
        T1Field                         matlab.ui.control.EditField
        T2EditFieldLabel                matlab.ui.control.Label
        T2Field                         matlab.ui.control.EditField
        OutputsTab                      matlab.ui.container.Tab
        OutputTable                     matlab.ui.control.Table
        UtilsTab                        matlab.ui.container.Tab
        QuickOutputNIFTIImageViewerPathGeneratorPanel  matlab.ui.container.Panel
        ImageDropDownLabel              matlab.ui.control.Label
        ImageDropDown                   matlab.ui.control.DropDown
        ViewButton                      matlab.ui.control.Button
        SubjectIdEditFieldLabel         matlab.ui.control.Label
        SubjectIdField                  matlab.ui.control.EditField
        FullImagePathEditFieldLabel     matlab.ui.control.Label
        FullImagePathField              matlab.ui.control.EditField
        GenCopyButton                   matlab.ui.control.Button
        AdvancedNIFTIImageViewerPanel   matlab.ui.container.Panel
        UnderlayPathField               matlab.ui.control.EditField
        OverlayPathField                matlab.ui.control.EditField
        ViewButton_2                    matlab.ui.control.Button
        UseOverlayCheckBox              matlab.ui.control.CheckBox
        ShowUnderlayinASeparateWindowCheckBox  matlab.ui.control.CheckBox
        UnderlayPathButton              matlab.ui.control.Button
        OverlayPathButton               matlab.ui.control.Button
        BrainImage                      matlab.ui.control.UIAxes
        WiscImage                       matlab.ui.control.UIAxes
        ShadowLabel                     matlab.ui.control.Label
        TitleLabel                      matlab.ui.control.Label
        RunButton                       matlab.ui.control.Button
        VersionLabel                    matlab.ui.control.Label
    end

    
    properties (Access = private)
        Subjects
    end
    
    methods (Static)
        function files = expand_dir(ds)
            files = [];
            for i = 1:numel(ds)
                if ds(i).name(end) == '.', continue; end
                if ds(i).isdir
                    sub_ds = dir(ds(i).name);
                    for j = 1:numel(sub_ds), sub_ds(j).name = fullfile(sub_ds(j).folder, sub_ds(j).name); end
                    files = [files W2MHS.expand_dir(sub_ds)];
                else
                    [~, ds(i).fname] = fileparts(lower(ds(i).name));
                    files = [files ds(i)];
                end
            end
        end
    end
    
    methods (Access = private)
        function save_settings(app, file)
            saved.spm_path   = app.SPM12PathField.Value;
            saved.do_preproc = app.PreprocSwitch.Value;
            saved.do_visual  = app.VisualSwitch.Value;
            saved.batch_size = app.BatchSizeSpinner.Value;
            saved.pmap_cut   = app.PMapCutSpinner.Value;
            saved.clean_th   = app.CleanThSpinner.Value;
            saved.vent_dil_r = app.VentDilSpinner.Value;
            saved.output_folder = app.OutputPathField.Value;
            saved.SubjectsListBox.Items = app.SubjectsListBox.Items;
            saved.SubjectsListBox.ItemsData = app.SubjectsListBox.ItemsData;
            saved.Subjects = app.Subjects;
            save(file, 'saved');
        end
        
        function load_settings(app, file)
            load(file, 'saved');
            app.SPM12PathField.Value = saved.spm_path;
            app.PreprocSwitch.Value = saved.do_preproc;
            app.VisualSwitch.Value = saved.do_visual;
            app.BatchSizeSpinner.Value = saved.batch_size;
            app.PMapCutSpinner.Value = saved.pmap_cut;
            app.CleanThSpinner.Value = saved.clean_th;
            app.VentDilSpinner.Value = saved.vent_dil_r;
            app.OutputPathField.Value = saved.output_folder;
            app.SubjectsListBox.Items = saved.SubjectsListBox.Items;
            app.SubjectsListBox.ItemsData = saved.SubjectsListBox.ItemsData;
            app.Subjects = saved.Subjects;
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Add toolbox folder and subfolders to the search directory
            addpath(genpath(pwd));
            
            % Search for SPM12 in MATLAB search path
            paths = split(path, ':');
            spm_idx = find(cellfun(@(str) strcmpi(str(max(1,end-4):end), 'spm12'), paths), 1);
            if ~isempty(spm_idx), app.SPM12PathField.Value = paths{spm_idx}; end
            
            % Read output file table
            app.OutputTable.Data = readtable('names.xls');
            
            % Initialize subjects
            app.Subjects = {};
            
            % Load dafault settings
            file = 'default.mat'; if exist(file, 'file'), app.load_settings(file); end
        end

        % Button pushed function: SPM12PathButton
        function SPM12PathButtonPushed(app, event)
            dir = uigetdir(); if dir ~= 0, app.SPM12PathField.Value = dir; end
        end

        % Button pushed function: OutputPathButton
        function OutputPathButtonPushed(app, event)
            dir = uigetdir(); if dir ~= 0, app.OutputPathField.Value = dir; end
        end

        % Button pushed function: AddImagesButton
        function AddImagesButtonPushed(app, event)
            files = uipickfiles('type', {'*.nii', 'NIFTI files'}, ...
                                'prompt', 'Add NIFTI files or folders', ...
                                'out', 'struct');
            if ~isstruct(files(1)), return; end
            files = W2MHS.expand_dir(files);
            t1id = lower(app.T1Field.Value); t2id = lower(app.T2Field.Value);
            t1mask = arrayfun(@(file) ~isempty(strfind(lower(file.fname), t1id)), files);
            t1s = files(t1mask); t2s = files(~t1mask);
            for i = 1:numel(t1s)
                t1 = t1s(i); t1name = t1.fname; t2name = strrep(t1name, t1id, t2id);
                t2 = t2s(find(arrayfun(@(t2) strcmpi(t2.fname, t2name), t2s), 1));
                if ~isempty(t2)
                    id = regexprep(regexprep(strrep(t1name, t1id, ''), '_+', '_'), '(^_|_$)', '');
                    app.Subjects{end+1} = Subject(id, t1.name, t2.name);
                    app.SubjectsListBox.Items{end+1} = sprintf('ID:%-16s T1:%-22s T2:%-22s', id, t1name, t2name);
                end
            end
            app.SubjectsListBox.ItemsData = 1:numel(app.SubjectsListBox.Items);
            
        end

        % Button pushed function: RemoveButton
        function RemoveButtonPushed(app, event)
            n = app.SubjectsListBox.Value;
            if isempty(n), return; end
            app.Subjects = [app.Subjects(1:n-1) app.Subjects(n+1:end)];
            app.SubjectsListBox.Items(n) = [];
        end

        % Button pushed function: ClearButton
        function ClearButtonPushed(app, event)
            app.Subjects = {};
            app.SubjectsListBox.Items = {};
        end

        % Button pushed function: MoveUpButton
        function MoveUpButtonPushed(app, event)
            n = app.SubjectsListBox.Value;
            if isempty(n) || n == 1, return; end
            app.Subjects(n-1:n) = [app.Subjects(n) app.Subjects(n-1)];
            app.SubjectsListBox.Items(n-1:n) = [app.SubjectsListBox.Items(n) app.SubjectsListBox.Items(n-1)];
            app.SubjectsListBox.Value = n - 1;
        end

        % Button pushed function: MoveDownButton
        function MoveDownButtonPushed(app, event)
            n = app.SubjectsListBox.Value;
            if isempty(n) || n == numel(app.SubjectsListBox.Items), return; end
            app.Subjects(n:n+1) = [app.Subjects(n+1) app.Subjects(n)];
            app.SubjectsListBox.Items(n:n+1) = [app.SubjectsListBox.Items(n+1) app.SubjectsListBox.Items(n)];
            app.SubjectsListBox.Value = n + 1;
        end

        % Value changing function: T1Field
        function T1FieldValueChanging(app, event)
            app.HelperArea.Value = {'For each subject, the toolbox requires a pair of T1 and T2 images, whose filenames differ only by the customized image type identifier:';
                ''; ['T1: <pre>' event.Value '<suf>.nii']; ['T2: <pre>' app.T2Field.Value '<suf>.nii']; '';
                '<pre><suf> is used as a unique id of the subject to match the two images. Different subjects should have different ids. Leading, tailing, and consecutive underlines are removed.'};
        end

        % Button pushed function: RunButton
        function RunButtonPushed(app, event)
            Subject.spm_path(app.SPM12PathField.Value);
            Subject.do_preproc(app.PreprocSwitch.Value);
            Subject.do_visual(app.VisualSwitch.Value);
            Subject.batch_size(app.BatchSizeSpinner.Value);
            Subject.pmap_cut(app.PMapCutSpinner.Value);
            Subject.clean_th(app.CleanThSpinner.Value);
            Subject.vent_dil_r(app.VentDilSpinner.Value);
            
            output_folder = app.OutputPathField.Value;
            t = table2struct(app.OutputTable.Data);
            for i = 1:numel(t)
                if strcmpi(t(i).Ext, 'nii')
                    app.ImageDropDown.Items{i} = t(i).Name;
                    app.ImageDropDown.ItemsData{i} = t(i).Filename;
                end
            end
            
            for i = 1:numel(app.Subjects)
                id = app.Subjects{i}.id;
                app.Subjects{i}.names.folder = fullfile(output_folder, id);
                for j = 1:numel(t)
                    app.Subjects{i}.keeps.(t(j).Name) = t(j).Keep;
                    app.Subjects{i}.names.(t(j).Name) = [t(j).Filename '_' id '.' t(j).Ext];
                end
                app.Subjects{i}.run;
            end
        end

        % Value changing function: T2Field
        function T2FieldValueChanging(app, event)
            app.HelperArea.Value = {'For each subject, the toolbox requires a pair of T1 and T2 images, whose filenames differ only by the customized image type identifier:';
                ''; ['T1: <pre>' app.T1Field.Value '<suf>.nii']; ['T2: <pre>' event.Value '<suf>.nii']; '';
                '<pre><suf> is used as a unique id of the subject to match the two images. Different subjects should have different ids. Leading, tailing, and consecutive underlines are removed.'};
        end

        % Value changing function: BatchSizeSpinner
        function BatchSizeSpinnerValueChanging(app, event)
            value = event.Value; if isa(value, 'double'), value = sprintf('%d', value); end
            app.HelperArea.Value = {[value ' voxels are classified together in one iteration. A larger batch size enhances performance at the cost of higher memory consumption. Recommended value: 2048 * available memory in GB']; '(e.g. 4096 if 2GB memory is available).'};
        end

        % Value changing function: PMapCutSpinner
        function PMapCutSpinnerValueChanging(app, event)
            value = event.Value; if isa(value, 'double'), value = sprintf('%g', value); end
            app.HelperArea.Value = {['Voxels classified as WMH with a confidence below ' value ' (presumably noisy) will be excluded.']};
        end

        % Value changing function: CleanThSpinner
        function CleanThSpinnerValueChanging(app, event)
            value = event.Value; if isa(value, 'double'), value = sprintf('%g', value); end
            app.HelperArea.Value = {['Voxels classified as WMH within ' value ' voxels from the gray matter surface will be excluded.']};
        end

        % Value changing function: VentDilSpinner
        function VentDilSpinnerValueChanging(app, event)
            value = event.Value; if isa(value, 'double'), value = sprintf('%d', value); end
            app.HelperArea.Value = {['The ventricular template is dilated by ' value ' voxels.']};
        end

        % Value changed function: PreprocSwitch
        function PreprocSwitchValueChanged(app, event)
            value = app.PreprocSwitch.Value;
            if strcmpi(value, 'yes')
                app.HelperArea.Value = {'Yes. Every subject will be preprocessed.'};
            else
                app.HelperArea.Value = {'No. Previous preprocessing output will be used if spotted in the output folder.'};
            end
        end

        % Value changed function: VisualSwitch
        function VisualSwitchValueChanged(app, event)
            value = app.VisualSwitch.Value;
            if strcmpi(value, 'yes')
                app.HelperArea.Value = {'Yes. A WMH heatmap will be automatically generated and visualized in pop-up windows.'};
            else
                app.HelperArea.Value = {'No. Visualization can be conducted later using the visualization tool in the utils tab.'};
            end
        end

        % Value changed function: UseOverlayCheckBox
        function UseOverlayCheckBoxValueChanged(app, event)
            value = app.UseOverlayCheckBox.Value;
            if value
                app.OverlayPathField.Enable = true; 
                app.OverlayPathButton.Enable = true; 
            else
                app.OverlayPathField.Enable = false; 
                app.OverlayPathButton.Enable = false; 
            end
        end

        % Button pushed function: ViewButton
        function ViewButtonPushed(app, event)
            app.GenCopyButtonPushed();
            file = app.FullImagePathField.Value;
            if exist(file, 'file'), view_nii(load_nii(file));
            else, error('nii file does not exist!');
            end
        end

        % Button pushed function: GenCopyButton
        function GenCopyButtonPushed(app, event)
            id = app.SubjectIdField.Value; filename = app.ImageDropDown.Value;
            file = fullfile(app.OutputPathField.Value, id, [filename '_' id '.nii']);
            clipboard('copy', file);
            app.FullImagePathField.Value = file; 
        end

        % Button pushed function: UnderlayPathButton
        function UnderlayPathButtonPushed(app, event)
            dir = uigetdir(); if dir ~= 0, app.UnderlayPathField.Value = dir; end
        end

        % Button pushed function: OverlayPathButton
        function OverlayPathButtonPushed(app, event)
            dir = uigetdir(); if dir ~= 0, app.OverlayPathField.Value = dir; end
        end

        % Button pushed function: ViewButton_2
        function ViewButton_2Pushed(app, event)
            if app.UseOverlayCheckBox.Value && ~isempty(app.OverlayPathField.Value)
                Visual.init(app.UnderlayPathField.Value, app.OverlayPathField.Value, app.ShowUnderlayinASeparateWindowCheckBox.Value);
            elseif ~isempty(app.UnderlayPathField.Value)
                view_nii(load_nii(app.UnderlayPathField.Value));
            end
        end

        % Menu selected function: SaveSettingsMenu
        function SaveSettingsMenuSelected(app, event)
            [file_name, path_name] = uiputfile('W2MHS_save.mat', 'Save current settings as...');
            if ~isequal(file_name, 0) && ~isequal(path_name, 0)
                app.save_settings(fullfile(path_name, file_name));
            end
        end

        % Menu selected function: SetDefaultMenu
        function SetDefaultMenuSelected(app, event)
            app.save_settings('default.mat');
        end

        % Menu selected function: LoadSettingsMenu
        function LoadSettingsMenuSelected(app, event)
            [file_name, path_name] = uigetfile('.mat', 'Load settings from...');
            if ~isequal(file_name, 0) && ~isequal(path_name, 0)
                app.load_settings(fullfile(path_name, file_name));
            end
        end

        % Cell edit callback: OutputTable
        function OutputTableCellEdit(app, event)
            writetable(app.OutputTable.Data, 'names.xls');
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0 0 0];
            app.UIFigure.Colormap = [0.2431 0.149 0.6588;0.251 0.1647 0.7059;0.2588 0.1804 0.7529;0.2627 0.1961 0.7961;0.2706 0.2157 0.8353;0.2745 0.2353 0.8706;0.2784 0.2549 0.898;0.2784 0.2784 0.9216;0.2824 0.302 0.9412;0.2824 0.3216 0.9569;0.2784 0.349 0.9686;0.2745 0.3686 0.9843;0.2706 0.3882 0.9922;0.2588 0.4118 0.9961;0.2431 0.4353 1;0.2196 0.4588 0.9961;0.1961 0.4863 0.9882;0.1843 0.5059 0.9804;0.1804 0.5294 0.9686;0.1765 0.549 0.9529;0.1686 0.5686 0.9373;0.1529 0.5922 0.9216;0.1451 0.6078 0.9098;0.1373 0.6275 0.898;0.1255 0.6471 0.8902;0.1098 0.6627 0.8745;0.0941 0.6784 0.8588;0.0706 0.6941 0.8392;0.0314 0.7098 0.8157;0.0039 0.7216 0.7922;0.0078 0.7294 0.7647;0.0431 0.7412 0.7412;0.098 0.749 0.7137;0.1412 0.7569 0.6824;0.1725 0.7686 0.6549;0.1922 0.7765 0.6235;0.2157 0.7843 0.5922;0.2471 0.7922 0.5569;0.2902 0.7961 0.5176;0.3412 0.8 0.4784;0.3922 0.8039 0.4353;0.4471 0.8039 0.3922;0.5059 0.8 0.349;0.5608 0.7961 0.3059;0.6157 0.7882 0.2627;0.6706 0.7804 0.2235;0.7255 0.7686 0.1922;0.7725 0.7608 0.1647;0.8196 0.749 0.1529;0.8627 0.7412 0.1608;0.902 0.7333 0.1765;0.9412 0.7294 0.2118;0.9725 0.7294 0.2392;0.9961 0.7451 0.2353;0.9961 0.7647 0.2196;0.9961 0.7882 0.2039;0.9882 0.8118 0.1882;0.9804 0.8392 0.1765;0.9686 0.8627 0.1647;0.9608 0.8902 0.1529;0.9608 0.9137 0.1412;0.9647 0.9373 0.1255;0.9686 0.9608 0.1059;0.9765 0.9843 0.0824];
            app.UIFigure.Position = [100 100 600 510];
            app.UIFigure.Name = 'UI Figure';

            try
                % Create File
                app.File = uimenu(app.UIFigure);
                app.File.Text = 'File';

                % Create LoadSettingsMenu
                app.LoadSettingsMenu = uimenu(app.File);
                app.LoadSettingsMenu.MenuSelectedFcn = createCallbackFcn(app, @LoadSettingsMenuSelected, true);
                app.LoadSettingsMenu.Accelerator = 'o';
                app.LoadSettingsMenu.Text = 'Load Settings';

                % Create SaveSettingsMenu
                app.SaveSettingsMenu = uimenu(app.File);
                app.SaveSettingsMenu.MenuSelectedFcn = createCallbackFcn(app, @SaveSettingsMenuSelected, true);
                app.SaveSettingsMenu.Accelerator = 's';
                app.SaveSettingsMenu.Text = 'Save Settings';

                % Create SetDefaultMenu
                app.SetDefaultMenu = uimenu(app.File);
                app.SetDefaultMenu.MenuSelectedFcn = createCallbackFcn(app, @SetDefaultMenuSelected, true);
                app.SetDefaultMenu.Text = 'Set Default';

                % Create HelpMenu
                app.HelpMenu = uimenu(app.UIFigure);
                app.HelpMenu.Text = 'Help';

                % Create DocumentationMenu
                app.DocumentationMenu = uimenu(app.HelpMenu);
                app.DocumentationMenu.Text = 'Documentation';

                % Create WalkThroughMenu
                app.WalkThroughMenu = uimenu(app.HelpMenu);
                app.WalkThroughMenu.Text = 'Walk-Through';
            catch
                warning('UI Menu not supported for this version of app designer...');
            end

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [21 51 560 340];

            % Create MainTab
            app.MainTab = uitab(app.TabGroup);
            app.MainTab.Title = 'Main';

            % Create SPM12PathField
            app.SPM12PathField = uieditfield(app.MainTab, 'text');
            app.SPM12PathField.Position = [121 283 430 22];

            % Create SPM12PathButton
            app.SPM12PathButton = uibutton(app.MainTab, 'push');
            app.SPM12PathButton.ButtonPushedFcn = createCallbackFcn(app, @SPM12PathButtonPushed, true);
            app.SPM12PathButton.Position = [11 283 100 22];
            app.SPM12PathButton.Text = 'SPM12 Path';

            % Create OutputPathField
            app.OutputPathField = uieditfield(app.MainTab, 'text');
            app.OutputPathField.Position = [121 253 430 22];

            % Create OutputPathButton
            app.OutputPathButton = uibutton(app.MainTab, 'push');
            app.OutputPathButton.ButtonPushedFcn = createCallbackFcn(app, @OutputPathButtonPushed, true);
            app.OutputPathButton.Position = [11 253 100 22];
            app.OutputPathButton.Text = 'Output Path';

            % Create SubjectsListBox
            app.SubjectsListBox = uilistbox(app.MainTab);
            app.SubjectsListBox.Items = {};
            app.SubjectsListBox.FontName = 'Courier';
            app.SubjectsListBox.Position = [11 15 540 200];
            app.SubjectsListBox.Value = {};

            % Create AddImagesButton
            app.AddImagesButton = uibutton(app.MainTab, 'push');
            app.AddImagesButton.ButtonPushedFcn = createCallbackFcn(app, @AddImagesButtonPushed, true);
            app.AddImagesButton.Position = [11 223 100 22];
            app.AddImagesButton.Text = 'Add Images';

            % Create RemoveButton
            app.RemoveButton = uibutton(app.MainTab, 'push');
            app.RemoveButton.ButtonPushedFcn = createCallbackFcn(app, @RemoveButtonPushed, true);
            app.RemoveButton.Position = [121 223 100 22];
            app.RemoveButton.Text = 'Remove';

            % Create ClearButton
            app.ClearButton = uibutton(app.MainTab, 'push');
            app.ClearButton.ButtonPushedFcn = createCallbackFcn(app, @ClearButtonPushed, true);
            app.ClearButton.Position = [231 223 100 22];
            app.ClearButton.Text = 'Clear';

            % Create MoveUpButton
            app.MoveUpButton = uibutton(app.MainTab, 'push');
            app.MoveUpButton.ButtonPushedFcn = createCallbackFcn(app, @MoveUpButtonPushed, true);
            app.MoveUpButton.Position = [341 223 100 22];
            app.MoveUpButton.Text = 'Move Up';

            % Create MoveDownButton
            app.MoveDownButton = uibutton(app.MainTab, 'push');
            app.MoveDownButton.ButtonPushedFcn = createCallbackFcn(app, @MoveDownButtonPushed, true);
            app.MoveDownButton.Position = [451 223 100 22];
            app.MoveDownButton.Text = 'Move Down';

            % Create OptionsTab
            app.OptionsTab = uitab(app.TabGroup);
            app.OptionsTab.Title = 'Options';

            % Create ProceduresPanel
            app.ProceduresPanel = uipanel(app.OptionsTab);
            app.ProceduresPanel.Title = 'Procedures';
            app.ProceduresPanel.Position = [211 195 330 100];

            % Create VisualizationSwitchLabel
            app.VisualizationSwitchLabel = uilabel(app.ProceduresPanel);
            app.VisualizationSwitchLabel.HorizontalAlignment = 'center';
            app.VisualizationSwitchLabel.Position = [201 13 73 22];
            app.VisualizationSwitchLabel.Text = 'Visualization';

            % Create VisualSwitch
            app.VisualSwitch = uiswitch(app.ProceduresPanel, 'slider');
            app.VisualSwitch.Items = {'No', 'Yes'};
            app.VisualSwitch.ValueChangedFcn = createCallbackFcn(app, @VisualSwitchValueChanged, true);
            app.VisualSwitch.Position = [213 50 45 20];
            app.VisualSwitch.Value = 'No';

            % Create PreprocSwitch
            app.PreprocSwitch = uiswitch(app.ProceduresPanel, 'slider');
            app.PreprocSwitch.Items = {'No', 'Yes'};
            app.PreprocSwitch.ValueChangedFcn = createCallbackFcn(app, @PreprocSwitchValueChanged, true);
            app.PreprocSwitch.Position = [73 50 45 20];
            app.PreprocSwitch.Value = 'No';

            % Create PreprocessingSwitch_2Label
            app.PreprocessingSwitch_2Label = uilabel(app.ProceduresPanel);
            app.PreprocessingSwitch_2Label.HorizontalAlignment = 'center';
            app.PreprocessingSwitch_2Label.Position = [56 13 82 22];
            app.PreprocessingSwitch_2Label.Text = 'Preprocessing';

            % Create HyperparametersPanel
            app.HyperparametersPanel = uipanel(app.OptionsTab);
            app.HyperparametersPanel.Title = 'Hyperparameters';
            app.HyperparametersPanel.Position = [21 15 320 160];

            % Create ClassificationBatchSizeSpinnerLabel
            app.ClassificationBatchSizeSpinnerLabel = uilabel(app.HyperparametersPanel);
            app.ClassificationBatchSizeSpinnerLabel.HorizontalAlignment = 'right';
            app.ClassificationBatchSizeSpinnerLabel.Position = [48 103 137 22];
            app.ClassificationBatchSizeSpinnerLabel.Text = 'Classification Batch Size';

            % Create BatchSizeSpinner
            app.BatchSizeSpinner = uispinner(app.HyperparametersPanel);
            app.BatchSizeSpinner.Step = 1024;
            app.BatchSizeSpinner.ValueChangingFcn = createCallbackFcn(app, @BatchSizeSpinnerValueChanging, true);
            app.BatchSizeSpinner.Limits = [1 Inf];
            app.BatchSizeSpinner.RoundFractionalValues = 'on';
            app.BatchSizeSpinner.ValueDisplayFormat = '%.0f';
            app.BatchSizeSpinner.Position = [200 103 100 22];
            app.BatchSizeSpinner.Value = 4096;

            % Create ProbabilityMapCutoffLabel
            app.ProbabilityMapCutoffLabel = uilabel(app.HyperparametersPanel);
            app.ProbabilityMapCutoffLabel.HorizontalAlignment = 'right';
            app.ProbabilityMapCutoffLabel.Position = [62 73 123 22];
            app.ProbabilityMapCutoffLabel.Text = 'Probability Map Cutoff';

            % Create PMapCutSpinner
            app.PMapCutSpinner = uispinner(app.HyperparametersPanel);
            app.PMapCutSpinner.Step = 0.1;
            app.PMapCutSpinner.ValueChangingFcn = createCallbackFcn(app, @PMapCutSpinnerValueChanging, true);
            app.PMapCutSpinner.Limits = [0 1];
            app.PMapCutSpinner.Position = [200 73 100 22];
            app.PMapCutSpinner.Value = 0.5;

            % Create GrayMatterCleaningDistanceSpinnerLabel
            app.GrayMatterCleaningDistanceSpinnerLabel = uilabel(app.HyperparametersPanel);
            app.GrayMatterCleaningDistanceSpinnerLabel.HorizontalAlignment = 'right';
            app.GrayMatterCleaningDistanceSpinnerLabel.Position = [15 43 170 22];
            app.GrayMatterCleaningDistanceSpinnerLabel.Text = 'Gray Matter Cleaning Distance';

            % Create CleanThSpinner
            app.CleanThSpinner = uispinner(app.HyperparametersPanel);
            app.CleanThSpinner.Step = 0.5;
            app.CleanThSpinner.ValueChangingFcn = createCallbackFcn(app, @CleanThSpinnerValueChanging, true);
            app.CleanThSpinner.Limits = [0 Inf];
            app.CleanThSpinner.Position = [200 43 100 22];
            app.CleanThSpinner.Value = 2.5;

            % Create PeriventricularRegionWidthLabel
            app.PeriventricularRegionWidthLabel = uilabel(app.HyperparametersPanel);
            app.PeriventricularRegionWidthLabel.HorizontalAlignment = 'right';
            app.PeriventricularRegionWidthLabel.Position = [27 13 158 22];
            app.PeriventricularRegionWidthLabel.Text = 'Periventricular Region Width';

            % Create VentDilSpinner
            app.VentDilSpinner = uispinner(app.HyperparametersPanel);
            app.VentDilSpinner.ValueChangingFcn = createCallbackFcn(app, @VentDilSpinnerValueChanging, true);
            app.VentDilSpinner.Limits = [0 10];
            app.VentDilSpinner.RoundFractionalValues = 'on';
            app.VentDilSpinner.ValueDisplayFormat = '%.0f';
            app.VentDilSpinner.Position = [200 13 100 22];
            app.VentDilSpinner.Value = 3;

            % Create HelperArea
            app.HelperArea = uitextarea(app.OptionsTab);
            app.HelperArea.Editable = 'off';
            app.HelperArea.Position = [361 15 180 160];
            app.HelperArea.Value = {'Instructions about an option will be shown here when the option is changed.'};

            % Create InputImageTypeIdentifiersPanel
            app.InputImageTypeIdentifiersPanel = uipanel(app.OptionsTab);
            app.InputImageTypeIdentifiersPanel.Title = 'Input Image Type Identifiers';
            app.InputImageTypeIdentifiersPanel.Position = [21 195 171 100];

            % Create T1Label
            app.T1Label = uilabel(app.InputImageTypeIdentifiersPanel);
            app.T1Label.HorizontalAlignment = 'right';
            app.T1Label.Position = [1 48 25 22];
            app.T1Label.Text = 'T1:';

            % Create T1Field
            app.T1Field = uieditfield(app.InputImageTypeIdentifiersPanel, 'text');
            app.T1Field.ValueChangingFcn = createCallbackFcn(app, @T1FieldValueChanging, true);
            app.T1Field.Position = [40 48 119 22];
            app.T1Field.Value = 'bravo';

            % Create T2EditFieldLabel
            app.T2EditFieldLabel = uilabel(app.InputImageTypeIdentifiersPanel);
            app.T2EditFieldLabel.HorizontalAlignment = 'right';
            app.T2EditFieldLabel.Position = [1 18 25 22];
            app.T2EditFieldLabel.Text = 'T2:';

            % Create T2Field
            app.T2Field = uieditfield(app.InputImageTypeIdentifiersPanel, 'text');
            app.T2Field.ValueChangingFcn = createCallbackFcn(app, @T2FieldValueChanging, true);
            app.T2Field.Position = [40 18 119 22];
            app.T2Field.Value = 'flair';

            % Create OutputsTab
            app.OutputsTab = uitab(app.TabGroup);
            app.OutputsTab.Title = 'Outputs';

            % Create OutputTable
            app.OutputTable = uitable(app.OutputsTab);
            app.OutputTable.ColumnName = {'Keep'; 'Filename'; 'Ext'; 'Name'; 'Description'};
            app.OutputTable.ColumnWidth = {40, 'auto', 30, 'auto'};
            app.OutputTable.RowName = {''};
            app.OutputTable.ColumnEditable = [true true false false false];
            app.OutputTable.CellEditCallback = createCallbackFcn(app, @OutputTableCellEdit, true);
            app.OutputTable.Position = [20 15 521 285];

            % Create UtilsTab
            app.UtilsTab = uitab(app.TabGroup);
            app.UtilsTab.Title = 'Utils';

            % Create QuickOutputNIFTIImageViewerPathGeneratorPanel
            app.QuickOutputNIFTIImageViewerPathGeneratorPanel = uipanel(app.UtilsTab);
            app.QuickOutputNIFTIImageViewerPathGeneratorPanel.Title = 'Quick Output NIFTI Image Viewer & Path Generator';
            app.QuickOutputNIFTIImageViewerPathGeneratorPanel.Position = [20 185 521 115];

            % Create ImageDropDownLabel
            app.ImageDropDownLabel = uilabel(app.QuickOutputNIFTIImageViewerPathGeneratorPanel);
            app.ImageDropDownLabel.HorizontalAlignment = 'right';
            app.ImageDropDownLabel.Position = [246 53 39 22];
            app.ImageDropDownLabel.Text = 'Image';

            % Create ImageDropDown
            app.ImageDropDown = uidropdown(app.QuickOutputNIFTIImageViewerPathGeneratorPanel);
            app.ImageDropDown.Items = {};
            app.ImageDropDown.Position = [300 53 105 22];
            app.ImageDropDown.Value = {};

            % Create ViewButton
            app.ViewButton = uibutton(app.QuickOutputNIFTIImageViewerPathGeneratorPanel, 'push');
            app.ViewButton.ButtonPushedFcn = createCallbackFcn(app, @ViewButtonPushed, true);
            app.ViewButton.Position = [421 53 89 22];
            app.ViewButton.Text = 'View';

            % Create SubjectIdEditFieldLabel
            app.SubjectIdEditFieldLabel = uilabel(app.QuickOutputNIFTIImageViewerPathGeneratorPanel);
            app.SubjectIdEditFieldLabel.HorizontalAlignment = 'right';
            app.SubjectIdEditFieldLabel.Position = [40 53 59 22];
            app.SubjectIdEditFieldLabel.Text = 'Subject Id';

            % Create SubjectIdField
            app.SubjectIdField = uieditfield(app.QuickOutputNIFTIImageViewerPathGeneratorPanel, 'text');
            app.SubjectIdField.Position = [114 53 126 22];

            % Create FullImagePathEditFieldLabel
            app.FullImagePathEditFieldLabel = uilabel(app.QuickOutputNIFTIImageViewerPathGeneratorPanel);
            app.FullImagePathEditFieldLabel.HorizontalAlignment = 'right';
            app.FullImagePathEditFieldLabel.Position = [9 18 90 22];
            app.FullImagePathEditFieldLabel.Text = 'Full Image Path';

            % Create FullImagePathField
            app.FullImagePathField = uieditfield(app.QuickOutputNIFTIImageViewerPathGeneratorPanel, 'text');
            app.FullImagePathField.Editable = 'off';
            app.FullImagePathField.Position = [114 18 296 22];

            % Create GenCopyButton
            app.GenCopyButton = uibutton(app.QuickOutputNIFTIImageViewerPathGeneratorPanel, 'push');
            app.GenCopyButton.ButtonPushedFcn = createCallbackFcn(app, @GenCopyButtonPushed, true);
            app.GenCopyButton.Position = [421 18 89 22];
            app.GenCopyButton.Text = 'Gen & Copy';

            % Create AdvancedNIFTIImageViewerPanel
            app.AdvancedNIFTIImageViewerPanel = uipanel(app.UtilsTab);
            app.AdvancedNIFTIImageViewerPanel.Title = 'Advanced NIFTI Image Viewer';
            app.AdvancedNIFTIImageViewerPanel.Position = [21 15 521 150];

            % Create UnderlayPathField
            app.UnderlayPathField = uieditfield(app.AdvancedNIFTIImageViewerPanel, 'text');
            app.UnderlayPathField.Position = [110 88 400 22];

            % Create OverlayPathField
            app.OverlayPathField = uieditfield(app.AdvancedNIFTIImageViewerPanel, 'text');
            app.OverlayPathField.Position = [110 53 400 22];

            % Create ViewButton_2
            app.ViewButton_2 = uibutton(app.AdvancedNIFTIImageViewerPanel, 'push');
            app.ViewButton_2.ButtonPushedFcn = createCallbackFcn(app, @ViewButton_2Pushed, true);
            app.ViewButton_2.Position = [421 18 89 22];
            app.ViewButton_2.Text = 'View';

            % Create UseOverlayCheckBox
            app.UseOverlayCheckBox = uicheckbox(app.AdvancedNIFTIImageViewerPanel);
            app.UseOverlayCheckBox.ValueChangedFcn = createCallbackFcn(app, @UseOverlayCheckBoxValueChanged, true);
            app.UseOverlayCheckBox.Text = 'Use Overlay';
            app.UseOverlayCheckBox.Position = [14 18 89 22];
            app.UseOverlayCheckBox.Value = true;

            % Create ShowUnderlayinASeparateWindowCheckBox
            app.ShowUnderlayinASeparateWindowCheckBox = uicheckbox(app.AdvancedNIFTIImageViewerPanel);
            app.ShowUnderlayinASeparateWindowCheckBox.Text = 'Show Underlay in A Separate Window';
            app.ShowUnderlayinASeparateWindowCheckBox.Position = [110 18 227 22];
            app.ShowUnderlayinASeparateWindowCheckBox.Value = true;

            % Create UnderlayPathButton
            app.UnderlayPathButton = uibutton(app.AdvancedNIFTIImageViewerPanel, 'push');
            app.UnderlayPathButton.ButtonPushedFcn = createCallbackFcn(app, @UnderlayPathButtonPushed, true);
            app.UnderlayPathButton.Position = [11 88 90 22];
            app.UnderlayPathButton.Text = 'Underlay Path';

            % Create OverlayPathButton
            app.OverlayPathButton = uibutton(app.AdvancedNIFTIImageViewerPanel, 'push');
            app.OverlayPathButton.ButtonPushedFcn = createCallbackFcn(app, @OverlayPathButtonPushed, true);
            app.OverlayPathButton.Position = [11 53 90 22];
            app.OverlayPathButton.Text = 'Overlay Path';

            % Create BrainImage
            app.BrainImage = uiaxes(app.UIFigure);
            title(app.BrainImage, '')
            xlabel(app.BrainImage, '')
            ylabel(app.BrainImage, '')
            app.BrainImage.XTick = [];
            app.BrainImage.YTick = [];
            app.BrainImage.BackgroundColor = [0 0 0];
            app.BrainImage.Position = [-5 400 110 110];
%             app.BrainImage.Toolbar.Visible = 'off';
            imshow('brain.jpg', 'Parent', app.BrainImage, 'XData', [0 app.BrainImage.Position(3)], 'YData', [0 app.BrainImage.Position(4)]);

            % Create WiscImage
            app.WiscImage = uiaxes(app.UIFigure);
            title(app.WiscImage, '')
            xlabel(app.WiscImage, '')
            ylabel(app.WiscImage, '')
            app.WiscImage.XTick = [];
            app.WiscImage.YTick = [];
            app.WiscImage.BackgroundColor = [0 0 0];
            app.WiscImage.Position = [500 395 100 110];
%             app.WiscImage.Toolbar.Visible = 'off';
            imshow('uw.png', 'Parent', app.WiscImage, 'XData', [0 app.WiscImage.Position(3)], 'YData', [0 app.WiscImage.Position(4)]);

            % Create ShadowLabel
            app.ShadowLabel = uilabel(app.UIFigure);
            app.ShadowLabel.BackgroundColor = [0.9412 0.9412 0.9412];
            app.ShadowLabel.HorizontalAlignment = 'center';
            app.ShadowLabel.FontSize = 20;
            app.ShadowLabel.Position = [111 411 390 70];
            app.ShadowLabel.Text = '';

            % Create TitleLabel
            app.TitleLabel = uilabel(app.UIFigure);
            app.TitleLabel.BackgroundColor = [0.8 0.8 0.8];
            app.TitleLabel.HorizontalAlignment = 'center';
            app.TitleLabel.FontSize = 20;
            app.TitleLabel.FontWeight = 'bold';
            app.TitleLabel.Position = [101 421 390 70];
            app.TitleLabel.Text = {'Wisconsin White Matter Hyperintensity '; 'Segmentation and Quantification'};

            % Create RunButton
            app.RunButton = uibutton(app.UIFigure, 'push');
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushed, true);
            app.RunButton.BackgroundColor = [0.902 0.902 0.902];
            app.RunButton.FontSize = 20;
            app.RunButton.FontWeight = 'bold';
            app.RunButton.Position = [481 10 100 31];
            app.RunButton.Text = 'Run';

            % Create VersionLabel
            app.VersionLabel = uilabel(app.UIFigure);
            app.VersionLabel.FontColor = [1 1 1];
            app.VersionLabel.Position = [21 9 48 22];
            app.VersionLabel.Text = 'v2019.3';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = W2MHS

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end