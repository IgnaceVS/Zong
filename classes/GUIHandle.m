classdef GUIHandle < handle
    % Handle containing all data and the actual user interface.

    % Constants to keep the layout specification easy to read.
    properties (Constant)
        % Sizes
        window_size = [1000 750];
        row_height = 20;
        xs = [40 20];
        s = [70 20];
        m = [100 20];
        l = [140 20];
        xl = [170 20];
        % Offsets
        column = [10 60 210 360 440 620 710 810];
        row = 750 - [50 80 110 140];
        % Default parameter settings
        def_fs = 44100;
        def_minsp = 300;
        def_extth = 100;
        def_lev = 0.2;
        def_filtl = 3000;
        def_filts = 200;
        
        refm = 1;
        syll = 2;
        mttf = 3;
        sim = 4;
        clus = 5;
        par = 6;
    end

    properties (Access = private)
        window; % uifigure
        tgroup; % uitabgroup
        tab; % uitab
        P; % array of uipanel
        P_refm; % struct
        P_syll; % struct
        P_mttf; % struct
        P_clus; % struct
        P_sim; % struct
        P_par; % struct
        params; % struct with items to pass input parameters
        master; % Temporary values used during clustering
        data; % all computed data;
        help; % Help button footer
    end

    methods (Access = public)
        % Constructor
        function gui = GUIHandle()
            % GUI window
            gui.window = uifigure('Name', 'zong GUI', 'Position', [100 100 gui.window_size], 'AutoResizeChildren', 'off', 'Resize', 'off');
            
            % Tab selector
            gui.tgroup = uitabgroup('Parent', gui.window, 'TabLocation', 'Left', 'Position', [0 0 gui.window_size], 'SelectionChangedFcn', @(hObject, event)tab_change(gui));

            % Array of tabs
            gui.tab = [uitab('Parent', gui.tgroup, 'Title', 'Refmatrix Editor'), ...
                       uitab('Parent', gui.tgroup, 'Title', 'Syllable Cut'), ...
                       uitab('Parent', gui.tgroup, 'Title', 'MT TF'), ...
                       uitab('Parent', gui.tgroup, 'Title', 'Similarity'), ...
                       uitab('Parent', gui.tgroup, 'Title', 'Cluster'), ...
                       uitab('Parent', gui.tgroup, 'Title', 'Parameters')];

            % Array of panels, linked to tabs        
            gui.P = [uipanel('Parent', gui.tab(gui.refm), 'Title', 'Reference Matrix Editor', 'Position', [0 0 gui.window_size], 'AutoResizeChildren', 'off'), ...
                     uipanel('Parent', gui.tab(gui.syll), 'Title', 'Syllable Cut', 'Position', [0 0 gui.window_size], 'AutoResizeChildren', 'off'), ...
                     uipanel('Parent', gui.tab(gui.mttf), 'Title', 'Ambiguity Features', 'Position', [0 0 gui.window_size], 'AutoResizeChildren', 'off'), ...
                     uipanel('Parent', gui.tab(gui.sim), 'Title', 'Similarity', 'Position', [0 0 gui.window_size], 'AutoResizeChildren', 'off'), ...
                     uipanel('Parent', gui.tab(gui.clus), 'Title', 'Cluster', 'Position', [0 0 gui.window_size], 'AutoResizeChildren', 'off'), ...
                     uipanel('Parent', gui.tab(gui.par), 'Title', 'Parameters', 'Position', [0 0 gui.window_size], 'AutoResizeChildren', 'off')];

            %% Panel 1
            % Buttons
            gui.P_refm.button_load   = uibutton('Parent', gui.P(gui.refm), 'Text', 'Load',   'Position', [gui.column(1), gui.row(1), gui.s], 'ButtonPushedFcn', @(hObject, event)P_refm_load(gui));
            gui.P_refm.button_save   = uibutton('Parent', gui.P(gui.refm), 'Text', 'Save',   'Position', [gui.column(1), gui.row(2), gui.s], 'ButtonPushedFcn', @(hObject, event)P_refm_save(gui));
            gui.P_refm.button_create = uibutton('Parent', gui.P(gui.refm), 'Text', 'Create', 'Position', [gui.column(1), gui.row(3), gui.s], 'ButtonPushedFcn', @(hObject, event)P_refm_create(gui));
           
            % Data table
            gui.P_refm.table_refmatrix = uitable('Parent', gui.P(gui.refm), ...
                                             'Position', [20 + gui.s(1) 5 810 715], ...
                                             'ColumnName', {'File'; 'Birdname'; 'days post hatch'; 'Timepoint'; 'Comparison 1'; 'Comparison 2'; 'Group'}, ...
                                             'ColumnWidth', {'auto', 'auto', 'auto', 'auto', 'auto', 'auto', 'auto'}, ...
                                             'ColumnEditable', [false(1,4) true(1,3)], ...
                                             'ColumnFormat', {'char', 'char', 'char', 'numeric', 'numeric', 'numeric', 'char' });

            %% Panel header: sets parameters, parent changes to active panel (unless it is panel 1)
            gui.params.label_bird  = uilabel   ('Parent', gui.P(gui.syll), 'Position', [gui.column(1), gui.row(1), gui.xs], 'Text', 'Bird:');
            gui.params.select_bird = uidropdown('Parent', gui.P(gui.syll), 'Position', [gui.column(2), gui.row(1), gui.l], 'Items', {'0: No reference matrix'}, 'ValueChangedFcn', @(hObject, event)change_select(gui));
            gui.params.label_wav   = uilabel   ('Parent', gui.P(gui.syll), 'Position', [gui.column(1), gui.row(2), gui.xs], 'Text', 'Audio:');
            gui.params.select_wav  = uidropdown('Parent', gui.P(gui.syll), 'Position', [gui.column(2), gui.row(2), gui.l], 'Items', {'No reference matrix'});

            gui.params.label_freq  = uilabel   ('Parent', gui.P(gui.syll), 'Position', [gui.column(3), gui.row(1), gui.xl], 'Text', 'Sampling frequency (Hz):');
            gui.params.text_freq   = uitextarea('Parent', gui.P(gui.syll), 'Position', [gui.column(4), gui.row(1), gui.s], 'Value', num2str(gui.def_fs));
            gui.params.label_minsp = uilabel   ('Parent', gui.P(gui.syll), 'Position', [gui.column(3), gui.row(2), gui.xl], 'Text', 'Min. syllable spacing (ms):');
            gui.params.text_minsp  = uitextarea('Parent', gui.P(gui.syll), 'Position', [gui.column(4), gui.row(2), gui.s], 'Value', num2str(gui.def_minsp));

            gui.params.label_extth = uilabel   ('Parent', gui.P(gui.syll), 'Position', [gui.column(5), gui.row(1), gui.xl], 'Text', 'Threshold level extension (ms):');
            gui.params.text_extth  = uitextarea('Parent', gui.P(gui.syll), 'Position', [gui.column(6), gui.row(1), gui.s], 'Value', num2str(gui.def_extth));
            gui.params.label_lev   = uilabel   ('Parent', gui.P(gui.syll), 'Position', [gui.column(5), gui.row(2), gui.xl], 'Text', 'Level above threshold:');
            gui.params.text_lev    = uitextarea('Parent', gui.P(gui.syll), 'Position', [gui.column(6), gui.row(2), gui.s], 'Value', num2str(gui.def_lev));

            gui.params.label_filtl = uilabel   ('Parent', gui.P(gui.syll), 'Position', [gui.column(7), gui.row(1), gui.m], 'Text', 'Smoothing size:');
            gui.params.text_filtl  = uitextarea('Parent', gui.P(gui.syll), 'Position', [gui.column(8), gui.row(1), gui.s], 'Value', num2str(gui.def_filtl));
            gui.params.label_filts = uilabel   ('Parent', gui.P(gui.syll), 'Position', [gui.column(7), gui.row(2), gui.m], 'Text', 'Threshold level:');
            gui.params.text_filts  = uitextarea('Parent', gui.P(gui.syll), 'Position', [gui.column(8), gui.row(2), gui.s], 'Value', num2str(gui.def_filts));
            gui.params.defaults_check = uicheckbox('Parent', gui.P(gui.syll), 'Position', [gui.column(7), gui.row(3), gui.m], 'Text', 'Use table', 'Value', 0, 'ValueChangedFcn', @(hObject, event)change_checkbox(gui));

            %% Panel footer
            gui.help = uibutton('Parent', gui.P(gui.refm), 'Text', '?', 'Position', [gui.column(1), 10, 20 20], 'ButtonPushedFcn', @(hObject, event)show_help(gui));

            %% Panel 2: "plot"-button

            gui.P_syll.button_plot = uibutton('Parent', gui.P(gui.syll), 'Position', [gui.column(8),gui.row(3), gui.s], 'Text', 'Plot', 'ButtonPushedFcn', @(hObject, event)P_syll_plot(gui));

            gui.P_syll.subplots = [subplot(8,6,[7:11 13:17 19:23], 'Parent', gui.P(gui.syll)), ...
                               subplot(8,6,[31:35 37:41 43:47], 'Parent', gui.P(gui.syll))];

            %% Panel 3: shows P_syll parameters, adds a syllable selector and plots data using fm_amfeat

            gui.P_mttf.label_syllable  = uilabel   ('Parent', gui.P(gui.mttf), 'Position', [gui.column(1), gui.row(3), gui.s], 'Text', 'Syllable:');
            gui.P_mttf.select_syllable = uidropdown('Parent', gui.P(gui.mttf), 'Position', [gui.column(2), gui.row(3), gui.l], 'Items', {'No syllable master'});

            gui.P_mttf.button_plot = uibutton('Parent', gui.P(gui.mttf), 'Position', [gui.column(8),gui.row(3), gui.s], 'Text', 'Plot', 'ButtonPushedFcn', @(hObject, event)P_mttf_plot(gui));

            gui.P_mttf.subplots = [subplot(16,5,[11:14 16:19 21:24 26:29], 'Parent', gui.P(gui.mttf)), ...
                               subplot(16,5,[36:39 41:44 46:49 51:54], 'Parent', gui.P(gui.mttf)), ...
                               subplot(16,5,[61:64 66:69 71:74 76:79], 'Parent', gui.P(gui.mttf))];

            %% Panel 4

            gui.P_sim.label_sim  = uilabel   ('Parent', gui.P(gui.sim), 'Position', [gui.column(1), gui.row(1), gui.xs], 'Text', 'Sim.:');
            gui.P_sim.select_sim = uidropdown('Parent', gui.P(gui.sim), 'Position', [gui.column(2), gui.row(1), gui.l], 'Items', {'Individual', 'Comparison'});
            gui.P_sim.label_loading = [uilabel('Parent', gui.P(gui.sim), 'Position', [gui.column(1), gui.row(3), gui.s], 'Text', 'Loading:', 'Visible', false);
                                    uilabel('Parent', gui.P(gui.sim), 'Position', [gui.column(2), gui.row(3), gui.l], 'Text', '', 'Visible', false)];

            gui.P_sim.button_sim = uibutton('Parent', gui.P(gui.sim), 'Position', [gui.column(8), gui.row(3), gui.s], 'Text', 'Similarity', 'ButtonPushedFcn', @(hObject, event)P_sim_similarity(gui));

            %% Panel 5

            gui.P_clus.label_comp  = uilabel   ('Parent', gui.P(gui.clus), 'Position', [gui.column(1), gui.row(3), gui.m], 'Text', 'Comp.:');
            gui.P_clus.label_comp1 = uilabel   ('Parent', gui.P(gui.clus), 'Position', [gui.column(2), gui.row(3), gui.m], 'Text', 'Bird:');
            gui.P_clus.label_name1 = uilabel   ('Parent', gui.P(gui.clus), 'Position', [gui.column(3), gui.row(3), gui.s], 'Text', '-----');
            gui.P_clus.label_wav1  = uilabel   ('Parent', gui.P(gui.clus), 'Position', [gui.column(4), gui.row(3), gui.xs], 'Text', 'Audio:');
            gui.P_clus.select_wav1 = uidropdown('Parent', gui.P(gui.clus), 'Position', [gui.column(5), gui.row(3), gui.xl], 'Items', {''});

            gui.P_clus.label_comp2 = uilabel   ('Parent', gui.P(gui.clus), 'Position', [gui.column(2), gui.row(4), gui.m], 'Text', 'Bird:');
            gui.P_clus.label_name2 = uilabel   ('Parent', gui.P(gui.clus), 'Position', [gui.column(3), gui.row(4), gui.m], 'Text', '-----');
            gui.P_clus.label_wav2  = uilabel   ('Parent', gui.P(gui.clus), 'Position', [gui.column(4), gui.row(4), gui.xs], 'Text', 'Audio:');
            gui.P_clus.select_wav2 = uidropdown('Parent', gui.P(gui.clus), 'Position', [gui.column(5), gui.row(4), gui.xl], 'Items', {''});

            gui.P_clus.select_cluster = uidropdown('Parent', gui.P(gui.clus), 'Position', [gui.column(7), gui.row(4), gui.m], 'Items', {''});
            gui.P_clus.button_comp = uibutton('Parent', gui.P(gui.clus), 'Position', [gui.column(8), gui.row(4), gui.s], 'Text', 'Cluster', 'ButtonPushedFcn', @(hObject, event)P_clus_cluster(gui));

            gui.P_clus.subplots = [subplot(17,12,[37:47 49:59 61:71 73:83], 'Parent', gui.P(gui.clus)), ...
                               subplot(17,12,[97:107 109:119 121:131 133:143], 'Parent', gui.P(gui.clus)), ...
                               subplot(17,12,[157:159 169:171 181:183 193:195], 'Parent', gui.P(gui.clus)), ...
                               subplot(17,12,[161:163 173:175 185:187 197:199], 'Parent', gui.P(gui.clus)), ...
                               subplot(17,12,[165:167 177:179 189:191 201:203], 'Parent', gui.P(gui.clus))];

            xoffset = (gui.P_clus.subplots(3).Position(3) * gui.window_size(1) - gui.m(1))/2; % Align middle of play button to a subplot.
            yoffset = 1.5 * gui.row_height;
            gui.P_clus.button_audio = [uibutton('Parent', gui.P(gui.clus), 'Position', [gui.P_clus.subplots(3).Position(1) * gui.window_size(1) + xoffset, yoffset, gui.m], 'Text', 'Play sound', 'ButtonPushedFcn', @(hObject, event)P_clus_audio(gui,1)), ...
                                   uibutton('Parent', gui.P(gui.clus), 'Position', [gui.P_clus.subplots(4).Position(1) * gui.window_size(1) + xoffset, yoffset, gui.m], 'Text', 'Play sound', 'ButtonPushedFcn', @(hObject, event)P_clus_audio(gui,2)), ...
                                   uibutton('Parent', gui.P(gui.clus), 'Position', [gui.P_clus.subplots(5).Position(1) * gui.window_size(1) + xoffset, yoffset, gui.m], 'Text', 'Play sound', 'ButtonPushedFcn', @(hObject, event)P_clus_audio(gui,3))];
            
            %% Panel 6
            gui.P_par.button_load   = uibutton('Parent', gui.P(gui.par), 'Text', 'Load',   'Position', [gui.column(1), gui.row(1), gui.s], 'ButtonPushedFcn', @(hObject, event)P_par_load(gui));
            gui.P_par.button_save   = uibutton('Parent', gui.P(gui.par), 'Text', 'Save',   'Position', [gui.column(1), gui.row(2), gui.s], 'ButtonPushedFcn', @(hObject, event)P_par_save(gui));
            % Data table
            gui.P_par.table_params = uitable('Parent', gui.P(gui.par), ...
                                          'Position', [20 + gui.s(1) 5 810 715], ...
                                          'ColumnName', {'Bird'; 'Audio'; 'Sampling freq.'; 'Min. syllable spacing'; 'Threshold level extension'; 'Level above threshold'; 'Smoothing size'; 'Threshold level'}, ...
                                          'ColumnWidth', {'auto', 'auto', 'auto', 'auto', 'auto', 'auto', 'auto', 'auto'}, ...
                                          'ColumnEditable', [false true(1,7)], ...
                                          'ColumnFormat', {'char', 'char', 'numeric', 'numeric', 'numeric', 'numeric', 'numeric', 'numeric' });
            
        end
    end

    methods (Access = private)
        %% Callbacks
        % Functions linked to interaction with GUI.

        % Keep parameter header visible when changing tabs.
        % All tabs except for tab 1.
        function tab_change(gui)
            index = gui.current_page();
            gui.help.Parent = gui.P(index);
            if index ~= gui.refm
                gui.show_param_header(index);
            end
        end

        % Create refmatrix by scanning directories.
        function P_refm_create(gui)
            tutors_folder = uigetdir(matlabroot, 'Select "tutors" folder');
            if tutors_folder
                tutees_folder = uigetdir(fileparts(tutors_folder), 'Select "tutees" folder');
                if tutees_folder
                    gui.P_refm.table_refmatrix.Data = [];
                    gui.data = [];
                    loading = waitbar(0, 'Loading refmatrix', 'Visible' , 'on');
                    gui.P_refm.table_refmatrix.Data = initialize_refmatrix(tutors_folder, tutees_folder);
                    if isvalid(loading)
                        waitbar(0.25, loading, 'Setting up bird selection menu.');
                    end
                    gui.recreate_select_bird();
                    if isvalid(loading)
                        waitbar(0.5, loading, 'Allocating memory.');
                    end
                    gui.prealloc_birds();
                    if isvalid(loading)
                        waitbar(0.75, loading, 'Setting up parameter table.');
                    end
                    gui.init_params_table();
                    if isvalid(loading)
                        waitbar(1, loading, 'Done!');
                        pause(0.5);
                    end
                    if isvalid(loading)
                        close(loading);
                    end
                end
            end
        end

        % Load existing refmatrix
        function P_refm_load(gui)
            [target_file, target_folder] = uigetfile('*.mat', 'Select refmatrix');
            target_file = strcat(target_folder, target_file);
            if target_file
                loading = waitbar(0, 'Loading refmatrix', 'Visible' , 'on');

                temp = load(target_file);
                
                gui.P_refm.table_refmatrix.Data = [];
                gui.data = [];
                % Fix incomplete input.
                refmatsize = size(temp.refmatrix);
                if refmatsize(2) < 7
                    temp.refmatrix{1,7} = '';
                end
                
                gui.P_refm.table_refmatrix.Data = temp.refmatrix;

                if isvalid(loading)
                    waitbar(0.25, loading, 'Setting up bird selection menu.');
                end
                gui.recreate_select_bird();
                if isvalid(loading)
                    waitbar(0.5, loading, 'Allocating memory.');
                end
                gui.prealloc_birds();
                if isvalid(loading)
                    waitbar(0.75, loading, 'Setting up parameter table.');
                end
                gui.init_params_table();
                if isvalid(loading)
                    waitbar(1, loading, 'Done!');
                    pause(0.5);
                end
                if isvalid(loading)
                    close(loading);
                end
            end
        end

        % Save this refmatrix to a .mat file.
        function P_refm_save(gui)
            refmatrix = gui.P_refm.table_refmatrix.Data;
            uisave('refmatrix', 'refmatrix.mat');
        end

        % Computes and visualizes data of a single refmatrix entry.
        % It does NOT count as a complete initialization.
        function P_syll_plot(gui)
            index = gui.get_selection_index();

            if index > 0
                if ~gui.params.defaults_check.Value
                    wavname = gui.params.select_wav.Value;
                    fs = cell2num(gui.params.text_freq.Value);
                    minsp = cell2num(gui.params.text_minsp.Value);
                    extth = cell2num(gui.params.text_extth.Value);
                    lev = cell2num(gui.params.text_lev.Value);
                    filtl = cell2num(gui.params.text_filtl.Value);
                    filts = cell2num(gui.params.text_filts.Value);
                else
                    wavname = gui.P_par.table_params.Data{index,2};
                    fs = gui.P_par.table_params.Data{index,3};
                    minsp = gui.P_par.table_params.Data{index,4};
                    extth = gui.P_par.table_params.Data{index,5};
                    lev = gui.P_par.table_params.Data{index,6};
                    filtl = gui.P_par.table_params.Data{index,7};
                    filts = gui.P_par.table_params.Data{index,8};
                end

                gui.data.bird(index).syllablemaster = fm_syllmatrix(wavname, gui.P_refm.table_refmatrix.Data, index, fs, minsp, extth, lev, filtl, filts, true, gui.P_syll.subplots);
                gui.data.bird(index).maxsyll = size(gui.data.bird(index).syllablemaster, 2);
                gui.data.bird(index).is_init = false; % Recalculating this phase invalidates P_mttf because it partially overwrites its data.

                gui.P_mttf_write_params();
                gui.P_clus_write_params();
            end
        end

        % Computes and visualizes data of a single syllable entry.
        % It does NOT count as a complete initialization.
        function P_mttf_plot(gui)
            index = gui.get_selection_index();

            if index > 0 && gui.data.bird(index).maxsyll > 0
                [~, ~] = fm_amfeat(gui.data.bird(index).syllablemaster, str2double(gui.P_mttf.select_syllable.Value), gui.P_mttf.subplots, index);
                gui.P_clus_write_params();
            end
        end

        % Computes and visualizes data of bird and its tutors.
        % Initializes and retains the data in memory if needed.
        function P_clus_cluster(gui)
            index = gui.get_selection_index();

            if index > 0
                compID1 = gui.P_refm.table_refmatrix.Data{index, 5};
                compID2 = gui.P_refm.table_refmatrix.Data{index, 6};
                
                if ~gui.params.defaults_check.Value
                    fs = ones(1,3) * cell2num(gui.params.text_freq.Value);
                    minsp = ones(1,3) * cell2num(gui.params.text_minsp.Value);
                    extth = ones(1,3) * cell2num(gui.params.text_extth.Value);
                    lev = ones(1,3) * cell2num(gui.params.text_lev.Value);
                    filtl = ones(1,3) * cell2num(gui.params.text_filtl.Value);
                    filts = ones(1,3) * cell2num(gui.params.text_filts.Value);
                else
                    indices = ones(1,3) * index;
                    if ~isempty(compID1)
                        indices(2) = compID1;
                    end
                    if ~isempty(compID2)
                        indices(3) = compID2;
                    end
                    
                    fs = cell2mat(gui.P_par.table_params.Data(indices,3));
                    minsp = cell2mat(gui.P_par.table_params.Data(indices,4));
                    extth = cell2mat(gui.P_par.table_params.Data(indices,5));
                    lev = cell2mat(gui.P_par.table_params.Data(indices,6));
                    filtl = cell2mat(gui.P_par.table_params.Data(indices,7));
                    filts = cell2mat(gui.P_par.table_params.Data(indices,8));
                end

                if ~strcmp(gui.P_clus.select_cluster.Value, '')
                    % cluster_index: 1 is individual, 2 is bird<->tutor1, 3 is bird<->tutor2, 4 is tutor1<->tutor2 
                    if strcmp(gui.P_clus.select_cluster.Value, num2str(index))
                        cluster_index = 1;
                        gui.compute_data(index, gui.params.select_wav.Value, fs(1), minsp(1), extth(1), lev(1), filtl(1), filts(1));
                        [gui.data.audio, gui.data.bird(index).cluster_data(cluster_index)] = fm_cluster(gui.data.bird(index).syllablemaster(:,1:gui.data.bird(index).n), gui.data.bird(index), 0, true, gui.P_clus.subplots);
                    else
                        to_compare = split(gui.P_clus.select_cluster.Value, ' & ');

                        indices = [cell2num(to_compare(1)) cell2num(to_compare(2))];

                        if indices(1) == index && indices(2) == compID1
                            tutor_compare = 1;
                            cluster_index = 2;
                        elseif indices(1) == index
                            tutor_compare = 2;
                            cluster_index = 3;
                        else
                            tutor_compare = 23;
                            cluster_index = 4;
                        end

                        wavnames = {gui.params.select_wav.Value, gui.P_clus.select_wav1.Value, gui.P_clus.select_wav2.Value};

                        gui.compute_tt_data(index, wavnames, fs, minsp, extth, lev, filtl, filts);
                        least_syllables = ones(1,3) * gui.data.bird(index).n;
                        if ~isempty(compID1)
                            least_syllables(2) = gui.data.bird(compID1).n;
                        end
                        if ~isempty(compID2)
                            least_syllables(3) = gui.data.bird(compID2).n;
                        end
                        least_syllables = min(least_syllables); 
                        gui.data.master = fm_uvcomp(gui.data.bird(indices(1)), gui.data.bird(indices(2)), least_syllables);
                        [gui.data.audio, gui.data.bird(index).cluster_data(cluster_index)] = fm_cluster(gui.data.master.data, gui.data.master, tutor_compare, true, gui.P_clus.subplots);
                    end
                end
                gui.P_mttf_write_params();
            end
        end

        function P_clus_audio(gui, sound_id)
            if ~isempty(gui.data.audio{sound_id})
                sound(gui.data.audio{sound_id}(:), 11025);
            end
        end

        function P_sim_similarity(gui)
            if verLessThan('matlab', '9.8') % Writematrix 'append' option is not available for older versions.
                uialert(gui.window, 'MATLAB Version R2020a or more recent is required.', 'Unavailable feature');
            else
                wavname = gui.params.select_wav.Value;
                fs = str2double(cell2mat(gui.params.text_freq.Value));
                minsp = cell2num(gui.params.text_minsp.Value);
                extth = cell2num(gui.params.text_extth.Value);
                lev = cell2num(gui.params.text_lev.Value);
                filtl = cell2num(gui.params.text_filtl.Value);
                filts = cell2num(gui.params.text_filts.Value);

                gui.P_sim.label_loading(1).Visible = true;
                gui.P_sim.label_loading(2).Visible = true;

                for i = 1:size(gui.P_refm.table_refmatrix.Data, 1)
                    if gui.params.defaults_check.Value
                        wavname = gui.P_par.table_params.Data{i,2};
                        fs = gui.P_par.table_params.Data{i,3};
                        minsp = gui.P_par.table_params.Data{i,4};
                        extth = gui.P_par.table_params.Data{i,5};
                        lev = gui.P_par.table_params.Data{i,6};
                        filtl = gui.P_par.table_params.Data{i,7};
                        filts = gui.P_par.table_params.Data{i,8};
                    end
                    
                    gui.P_sim.label_loading(2).Text = strcat(num2str(i), {' of '}, num2str(size(gui.P_refm.table_refmatrix.Data, 1)));
                    gui.compute_data(i, wavname, fs, minsp, extth, lev, filtl, filts);
                end
                gui.P_sim.label_loading(1).Visible = false;
                gui.P_sim.label_loading(2).Visible = false;

                loading_msg = 'Compiling similarity of bird';
                loading = waitbar(0, loading_msg);
                if strcmp(gui.P_sim.select_sim.Value, 'Individual')

                    for index = 1:size(gui.P_refm.table_refmatrix.Data, 1)
                        [~, gui.data.bird(index).cluster_data(1)] = fm_cluster(gui.data.bird(index).syllablemaster(:,1:gui.data.bird(index).n), gui.data.bird(index), 0, false, 0);
                        gui.data.bird(index).ind_similaritystats = fm_ind_compile(gui.P_refm.table_refmatrix.Data{index,3}, gui.data.bird(index).cluster_data(1));
                        if isvalid(loading)
                            text = strcat(loading_msg, {' '}, num2str(index), {'... '}, num2str(round(100*index/size(gui.P_refm.table_refmatrix.Data, 1))), '%');
                            waitbar(index/size(gui.P_refm.table_refmatrix.Data, 1), loading, text);
                        end
                    end
                    [target_file, target_folder] = uiputfile('*', 'Select file', 'clusters_ind.xls');
                    if isvalid(loading)
                        close(loading);
                    end
                    if target_file
                        fm_ind_excel(gui.P_refm.table_refmatrix.Data, gui.data.bird, strcat(target_folder, target_file));
                    end
                else
                    for index = 1:size(gui.P_refm.table_refmatrix.Data, 1)
                        compID1 = gui.P_refm.table_refmatrix.Data{index, 5};
                        compID2 = gui.P_refm.table_refmatrix.Data{index, 6};
                        TwoTutors = 0;
                        least_syllables = 0;

                        if ~isempty(compID1) && isempty(compID2)
                            least_syllables = min([gui.data.bird(index).n gui.data.bird(compID1).n]);
                        end
                        if ~isempty(compID1) && ~isempty(compID2)
                            TwoTutors = 1;
                            least_syllables = min([gui.data.bird(index).n gui.data.bird(compID1).n gui.data.bird(compID2).n]);
                        end

                        if ~isempty(compID1)
                            gui.data.master = fm_uvcomp(gui.data.bird(index), gui.data.bird(compID1), least_syllables);
                            [~, gui.data.bird(index).cluster_data(2)] = fm_cluster(gui.data.master.data, gui.data.master, 1, false, 0);
                            gui.data.bird(index).tt_similaritystats{1} = fm_tt_compilesimilarity(gui.P_refm.table_refmatrix.Data{index,3}, gui.data.bird(index).cluster_data(2), TwoTutors, least_syllables, 1);
                        end
                        if ~isempty(compID2)
                            gui.data.master = fm_uvcomp(gui.data.bird(index), gui.data.bird(compID2), least_syllables);
                            [~, gui.data.bird(index).cluster_data(3)] = fm_cluster(gui.data.master.data, gui.data.master, 2, false, 0);
                            gui.data.bird(index).tt_similaritystats{2} = fm_tt_compilesimilarity(gui.P_refm.table_refmatrix.Data{index,3}, gui.data.bird(index).cluster_data(3), TwoTutors, least_syllables, 2);
                        end
                        if ~isempty(compID1) && ~isempty(compID2)
                            gui.data.master = fm_uvcomp(gui.data.bird(compID1), gui.data.bird(compID2), least_syllables);
                            [~, gui.data.bird(index).cluster_data(4)] = fm_cluster(gui.data.master.data, gui.data.master, 23, false, 0);
                            gui.data.bird(index).tt_similaritystats{3} = fm_tt_compilesimilarity(gui.P_refm.table_refmatrix.Data{index,3}, gui.data.bird(index).cluster_data(4), TwoTutors, least_syllables, 23);
                        end
                        if isvalid(loading)
                            text = strcat(loading_msg, {' '}, num2str(index), {'... '}, num2str(round(100*index/size(gui.P_refm.table_refmatrix.Data, 1))), '%');
                            waitbar(index/size(gui.P_refm.table_refmatrix.Data, 1), loading, text);
                        end
                    end
                    [target_file, target_folder] = uiputfile('*', 'Select file', 'clusters_comp.xls');
                    if isvalid(loading)
                        close(loading);
                    end
                    if target_file
                        fm_simtoexcel(gui.P_refm.table_refmatrix.Data, gui.data.bird, strcat(target_folder, target_file));
                    end
                end

                gui.P_mttf_write_params();
                gui.P_clus_write_params();
            end
        end
        
        function change_checkbox(gui)
                gui.params.select_wav.Visible = ~gui.params.defaults_check.Value;

                gui.params.text_freq.Visible = ~gui.params.defaults_check.Value;
                gui.params.text_minsp.Visible = ~gui.params.defaults_check.Value;

                gui.params.text_extth.Visible = ~gui.params.defaults_check.Value;
                gui.params.text_lev.Visible = ~gui.params.defaults_check.Value;

                gui.params.text_filtl.Visible = ~gui.params.defaults_check.Value;
                gui.params.text_filts.Visible = ~gui.params.defaults_check.Value;

                gui.P_clus.select_wav1.Visible = ~gui.params.defaults_check.Value;
                gui.P_clus.select_wav2.Visible = ~gui.params.defaults_check.Value;
        end
        
        % Show a help dialog box with instructions for the current page.
        function show_help(gui) 
            index = gui.current_page();
            text = '';
            switch index
                case gui.refm
                    text = {'The reference matrix contains metadata that is required to use the program.';...
                            '';...
                            'Create: Create new reference matrix based on the "tutors" and "tutees" folders.';...
                            '';...
                            'Load: Load an existing reference matrix.';...
                            '';...
                            'Save: Save the matrix in the table to a file.';...
                            '';...
                            'Table: View and edit the current reference matrix.'};
                case gui.syll
                    text = {'The "syllable cut" function detects and shows';...
                            'syllables within a song (.wav) of a bird.'};
                case gui.mttf
                    text = {'The "ambiguity features" function plots information per syllable.';...
                            'This requires running "syllable cut" to map the syllables first.'};
                case gui.sim
                    text = {'The "similarity" function compiles clustering information for all birds.';...
                            'This requires MATLAB version R2020a or higher.';...
                            '';...
                            'Clustering options:';...
                            '   + Individual bird';...
                            '   + All tutor1/2 <->tutee and tutor1 <-> tutor2 comparisons';... 
                            '       as specified by the reference matrix.'};
                case gui.clus
                    text = {'The "cluster" function detects and plots similarities between syllables of one or more birds.';...
                            '';...
                            'Clustering options:';...
                            '   + Individual bird';...
                            '   + Selected bird  <-> Comparison 1/2 (refmatrix)';...
                            '   + Comparison 1 <-> Comparison 2'};
                case gui.par
                    text = {'This table allows you to set different parameters per bird.'};
            end
            msgbox(text, gui.P(index).Title, 'help');
        end

        %% Helpers

        % Get the index of the current panel in the tab-array.
        function index = current_page(gui)
            for index = 1:numel(gui.tab)
                if gui.tgroup.SelectedTab == gui.tab(index)
                    break;
                end
            end
        end

        % Initializes the "bird"-subtree for each row in the refmatrix.
        function prealloc_birds(gui)
            for i = 1:size(gui.P_refm.table_refmatrix.Data, 1)
                gui.data.bird(i).is_init = false;
                gui.data.bird(i).wavname = '';
                gui.data.bird(i).fs = 0;
                gui.data.bird(i).minsp = 0;
                gui.data.bird(i).extth = 0;
                gui.data.bird(i).lev = 0;
                gui.data.bird(i).filtl = 0;
                gui.data.bird(i).filts = 0;
                gui.data.bird(i).maxsyll = 0;
            end
            
        end

        % Computes and retains the data for a single bird with given parameters.
        % Counts as initialization.
        function compute_data(gui, index, wavname, fs, minsp, extth, lev, filtl, filts)
            if ~gui.data.bird(index).is_init || gui.is_stale(index, wavname, fs, minsp, extth, lev, filtl, filts)
                gui.data.bird(index).syllablemaster = fm_syllmatrix(wavname, gui.P_refm.table_refmatrix.Data, index, fs, minsp, extth, lev, filtl, filts, 0, 0);
                gui.last_call(index, wavname, fs, minsp, extth, lev, filtl, filts);
                gui.data.bird(index).maxsyll = size(gui.data.bird(index).syllablemaster, 2);
                [gui.data.bird(index).AUCRmat, gui.data.bird(index).AVCRmat] = fm_amfeat(gui.data.bird(index).syllablemaster, 0, 0, index);
                [gui.data.bird(index).U, gui.data.bird(index).V, gui.data.bird(index).n, gui.data.bird(index).m] = fm_uvdata(gui.data.bird(index).AUCRmat, gui.data.bird(index).AVCRmat);
                gui.data.bird(index).is_init = true;
            end
        end

        % Computes and retains the data for a single bird and its tutors with given parameters.
        % Counts as initialization.
        function compute_tt_data(gui, index, wavnames, fs, minsp, extth, lev, filtl, filts)
            gui.compute_data(index, wavnames{1}, fs(1), minsp(1), extth(1), lev(1), filtl(1), filts(1));
            compID1 = gui.P_refm.table_refmatrix.Data{index, 5};
            compID2 = gui.P_refm.table_refmatrix.Data{index, 6};
            if ~isempty(compID1)
                gui.compute_data(compID1, wavnames{2}, fs(2), minsp(2), extth(2), lev(2), filtl(2), filts(2));
            end
            if ~isempty(compID2)
                gui.compute_data(compID2, wavnames{3}, fs(3), minsp(3), extth(3), lev(3), filtl(3), filts(3));
            end            
        end        

        % Stores "metadata" of last computation of bird(index).
        % Used to avoid recomputation of existing data.
        function last_call(gui, index, wavname, fs, minsp, extth, lev, filtl, filts)
            gui.data.bird(index).wavname = wavname;
            gui.data.bird(index).fs = fs;
            gui.data.bird(index).minsp = minsp;
            gui.data.bird(index).extth = extth;
            gui.data.bird(index).lev = lev;
            gui.data.bird(index).filtl = filtl;
            gui.data.bird(index).filts = filts;
        end

        % Checks "metadata" of last computation of bird(index).
        % Used to avoid recomputation of existing data.
        function stale = is_stale(gui, index, wavname, fs, minsp, extth, lev, filtl, filts)
            stale = true;
            if strcmp(gui.data.bird(index).wavname, wavname) ...
                && gui.data.bird(index).fs == fs ...
                && gui.data.bird(index).minsp == minsp ...
                && gui.data.bird(index).extth == extth ...
                && gui.data.bird(index).lev == lev ...
                && gui.data.bird(index).filtl == filtl ...
                && gui.data.bird(index).filts == filts
                stale = false;
            end
        end

        % Bookkeeping when changing selected bird.
        function change_select(gui)
            gui.params.select_wav.Items = recreate_select_wav(gui, gui.get_selection_index());
            gui.P_mttf_write_params();
            gui.P_clus_write_params();
        end

        % Recreate the dropdown bird menu.
        % Should be called at any change in refmatrix.
        function recreate_select_bird(gui)
            ref_size = size(gui.P_refm.table_refmatrix.Data, 1);
            ref_ind = range2strcell(1:ref_size);
            selection_list = strcat(ref_ind(:), {': '}, gui.P_refm.table_refmatrix.Data(:,2), {' '}, gui.P_refm.table_refmatrix.Data(:,3));
            gui.params.select_bird.Items = selection_list;
            gui.params.select_wav.Items = gui.recreate_select_wav(gui.get_selection_index());
            gui.P_clus_write_params();
        end

        % Recreate the dropdown wav menu items.
        % Should be called at any change in refmatrix or bird selection.
        function selection_list = recreate_select_wav(gui, index)
            files = dir(fullfile(cell2mat(gui.P_refm.table_refmatrix.Data(index,1)), '*.wav'));
            ref_size = size(files, 1);
            selection_list = cell(1,ref_size);
            for i = 1:ref_size
                selection_list(i) = {files(i).name};
            end
            if ref_size == 0
                selection_list = {'No wav-files'};
            end
        end

        % Get selected bird.
        function index = get_selection_index(gui)
            value = split(gui.params.select_bird.Value, ':');
            index = 0;
            if size(value, 1) > 1
                index = cell2num(value(1));
            end
        end

        % Update parameters specific to panel 3.
        function P_mttf_write_params(gui)
            index = gui.get_selection_index();
            maxsyll = gui.data.bird(index).maxsyll;
            if maxsyll > 0
                gui.P_mttf.select_syllable.Items = range2strcell(1:gui.data.bird(index).maxsyll);
            else
                gui.P_mttf.select_syllable.Items = {'No syllable master'};
            end
        end

        % Update parameters specific to panel 4.
        function P_clus_write_params(gui)
            index = gui.get_selection_index();

            compID1 = gui.P_refm.table_refmatrix.Data{index, 5};
            compID2 = gui.P_refm.table_refmatrix.Data{index, 6};
            cluster_items = {num2str(index)};

            if ~isempty(compID1)
                gui.P_clus.label_comp1.Text = strcat({'Bird '}, num2str(compID1), {': '});
                gui.P_clus.label_name1.Text = gui.P_refm.table_refmatrix.Data{compID1, 2};
                gui.P_clus.select_wav1.Items = gui.recreate_select_wav(compID1);

                if ~isempty(compID2)
                    gui.P_clus.label_comp2.Text = strcat({'Bird '}, num2str(compID2), {': '});
                    gui.P_clus.label_name2.Text = gui.P_refm.table_refmatrix.Data{compID2, 2};
                    gui.P_clus.select_wav2.Items = gui.recreate_select_wav(compID2);
                    to_cluster = range2strcell([index, compID1, compID2]);
                    cluster_items = cell(1,4);
                    cluster_items(1) = {num2str(index)};
                    cluster_items(2) = strcat(to_cluster(1), {' & '}, to_cluster(2));
                    cluster_items(3) = strcat(to_cluster(1), {' & '}, to_cluster(3));
                    cluster_items(4) = strcat(to_cluster(2), {' & '}, to_cluster(3));
                else
                    gui.P_clus.label_comp2.Text = 'Bird:';
                    gui.P_clus.label_name2.Text = '-----';
                    gui.P_clus.select_wav2.Items = {''};
                    cluster_items(1) = {num2str(index)};
                    cluster_items(2) = strcat(num2str(index), {' & '}, num2str(compID1));
                end
            else
                gui.P_clus.label_comp1.Text = 'Bird:';
                gui.P_clus.label_name1.Text = '-----';
                gui.P_clus.select_wav1.Items = {''};
                gui.P_clus.label_comp2.Text = 'Bird:';
                gui.P_clus.label_name2.Text = '-----';
                gui.P_clus.select_wav2.Items = {''};        
            end
            gui.P_clus.select_cluster.Items = cluster_items;
        end

        % Load existing parameter file
        function P_par_load(gui)
             [target_file, target_folder] = uigetfile('*.mat', 'Select parameter file');
             target_file = strcat(target_folder, target_file);
             if target_file
                 temp = load(target_file);

                 param_size = size(temp.param_table);
                 table_size = size(gui.P_par.table_params.Data);
                 if isequal(param_size, table_size)
                     gui.P_par.table_params.Data(:,2:8) = temp.param_table(:,2:8);
                 else
                    uialert(gui.window, 'Input has incorrect size.', 'Parameter table');
                 end
             end
        end

        % Save this parameter file to a .mat file.
        function P_par_save(gui)
            param_table = gui.P_par.table_params.Data;
            uisave('param_table', 'param_table.mat');
        end

        % Shifts input fields to different panel.
        function show_param_header(gui, tab_index)
            if tab_index ~= gui.par
                if tab_index ~= gui.sim
                    gui.params.label_bird.Parent = gui.P(tab_index);
                    gui.params.select_bird.Parent = gui.P(tab_index);
                end

                gui.params.label_wav.Parent = gui.P(tab_index);
                gui.params.select_wav.Parent = gui.P(tab_index);

                gui.params.label_freq.Parent = gui.P(tab_index);
                gui.params.text_freq.Parent = gui.P(tab_index);
                gui.params.label_minsp.Parent = gui.P(tab_index);
                gui.params.text_minsp.Parent = gui.P(tab_index);

                gui.params.label_extth.Parent = gui.P(tab_index);
                gui.params.text_extth.Parent = gui.P(tab_index);
                gui.params.label_lev.Parent = gui.P(tab_index);
                gui.params.text_lev.Parent = gui.P(tab_index);

                gui.params.label_filtl.Parent = gui.P(tab_index);
                gui.params.text_filtl.Parent = gui.P(tab_index);
                gui.params.label_filts.Parent = gui.P(tab_index);
                gui.params.text_filts.Parent = gui.P(tab_index);
                
                gui.params.defaults_check.Parent = gui.P(tab_index);
            end
        end

        % Initialize default parameters in the table
        function init_params_table(gui)
            gui.P_par.table_params.Data = cell(size(gui.P_refm.table_refmatrix.Data,1), 8);
            for i = 1:size(gui.P_refm.table_refmatrix.Data, 1)
                wav_select = gui.recreate_select_wav(i);
                gui.P_par.table_params.Data(i,:) = {gui.params.select_bird.Items{i}, wav_select{1}, gui.def_fs, gui.def_minsp, gui.def_extth, gui.def_lev, gui.def_filtl, gui.def_filts};
            end
        end
    end
end

% Conversion between numeric array to cell array with strings of numbers.
function cell_range = range2strcell(range)
    nums = size(range, 2);
    cell_range = cell(1,nums);
    for i = 1:nums
        cell_range(i) = {num2str(range(i))};
    end
end

function num = cell2num(cell_in)
    num = str2double(cell2mat(cell_in));
end