            %------------------------------------------------------
            %       Project - Diploma thesis                        
            %       Photoplethysmographic imaging - PPGI  Application (App)
            %       Author: Patrik Procka                                
            %       Create date:  October 2020
            %       last edited: 14.3.2021
            %       Supervisor: doc. Ing. Stefan Borik PhD.           
            %-----------------------------------------------------
%------------------------------------------------------
%               Abbrevations of created objects in name Structure
%       
% example: objecta - app.preprocess.control.options.cbSelectSignals 
%  - preprocess section, control panel, options panel - checkbox Select  Signals
%                           
% fig - figure      
% gr - grid layout
% p - panel
% btg - buttongroup
% tbg - tab Group 
% lbl - label
% tb - tab
% bt  - button
% rbt - radio button
% dd - dropDown
% cb - checkbox
% ax - axes
% spn - spinner
% im - image
% ef - edit field
% ta - text area
% lb - listbox
%
%   UI objects defined in url     
% https://www.mathworks.com/help/matlab/develop-apps-using-the-uifigure-function.html
%
%-------------------------------------------------------
%               Script Structure 
%   -> Create structure variable (variables can accessed through guidata during program runnig)
%       data = guidata(app.figMainApp);
%       data    - interface (data about graphic interface)
%                   - intro (data of Frames, Signals, Video)
%                   - mainTabGroupsName (Names of Table structure)
%                   - preprocess (variables of preprocess section)
%                   - results (variables of results section)
%                   - logic (logic values to control and manage script)
%   -> Create UI Design App
%       -> Main menu
%       -> Preprocess/Process
%       -> Results
%   -> GUI Layout and Design Functions
%   -> Callback Functions - Section sorted
%   -> Support functions  
%   -> Filters

%% clear previous data
if exist('data','var') == 1
    delete(app.figMainApp); %#ok<GPFST>
end
clear; close all; clc; 

%% Create Variable
    % Interface images and Enum of colors in Marking signals
                % C:\Users\Patrik Procka\OneDrive\MatlabOneDrive\DiplomovaPracaProjekt\Images\
data.interface.image.tick = '_Tick.png';
data.interface.image.background = '_Background.jpeg';
data.interface.image.left = '_Left.png';
data.interface.image.right = '_Right.png';
data.interface.image.info = '_Info.png';
data.interface.image.sync = '_Sync.png';
data.interface.colors  = ["Blue", "Green", "Red", "Cyan", "Magenta", "Yellow" , "Black", "White"];
    % Background and font colors 
data.interface.background.colorOne = [0 .1 .2];
data.interface.background.colorTwo = [0 .2 .3];
data.interface.background.colorThree = [.1 .3 .4];   
data.interface.fontColor = [1 1 1];
    % Menu data - positions, names of menu and button positions
data.intro.menu.panelPosition = [4  3];
data.intro.menu.buttonNames = ["Video","Frames", "Signals","Information","Exit"];
data.intro.menu.buttonPositions = CreateMenuPosition(data.intro.menu.buttonNames);
    % Video formats
data.intro.video.format = [".avi",".mp4"];
    % Load frames format
data.intro.frames.format = [".Raw",".Bmp",".Mat"];
data.intro.frames.dataType = ["uint8","ubit10","ubit12","uint16"];
data.intro.frames.framesRate = 30;
    %
data.intro.info = {'This app was created for signal extraction from video or frames sequentions. Data can be selected from image, processed with object tracking and spatial filtering, displayed and store as mat file.'...
                            '',...
                            '',...
                            'Katedra Teoretickej elektrotechniky a Biomedicínskeho inžinierstva',...
                            'Fakulta elektrotechniky a informačných technologií',...
                            'Žilinska univerzita v Žiline',...
                            '',...
                            '©Patrik Procka'};
    % Create tab names 
data.mainTabGroupNames = ["Processing", "Results"];
    % Preprocess variables 
data.preprocess.static.filterType = ["Average","Gaussian"];
data.preprocess.static.kernelSize = ["3x3","5x5","7x7","9x9","11x11","13x13","15x15","17x17","19x19", "21x21", "23x23"];
data.preprocess.static.results = ["Result 1", "Result 2","Result 3"];
data.preprocess.static.saveFormat = {'.mat','.tiff','.pgm'};
    % results variables 
data.results.static.BIOPAC ={'BIOPAC'};
data.results.static.filter = {'No Filter','LP<0.8Hz' ,'LP<1Hz', 'LP<4Hz','LP<6Hz','LP<8Hz','PB1<_<8Hz'};
data.results.static.overlap = {'No overlap','1/2', '1/4', '1/8','1/12'};
data.results.static.window = {'hamming', 'bartlett', 'blackman'};
data.results.static.analysis = {'Spectrum', 'Spectrogram', 'Periodogram', 'Scalogram'};
data.results.static.signal = {'Signal'};
data.results.sourceData.filterName = ' ';
    % create input variable
data.input = [];
    % create results structure empty - need to variable exist 
[data.output(1), data.output(2), data.output(3)] = deal(CreateResultsStructureEmpty);
    % logic valus -> control scipt functions
[data.logic.intro.videoLoaded,... 
 data.logic.intro.framesLoaded,...
 data.logic.intro.signalsLoaded,... 
 data.logic.intro.signals.ECG,... 
 data.logic.intro.signals.PPG,...
 data.logic.intro.signals.RR,...
 data.logic.preprocess.options.markROI,...
 data.logic.preprocess.options.trackROI,...
 data.logic.preprocess.options.spatialFilter,...
 data.logic.preprocess.options.selectSignals,... 
 data.logic.preprocess.ROI.marked,...
 data.logic.preprocess.ROI.confirmed,...
 data.logic.preprocess.tracker.applied,...
 data.logic.preprocess.tracker.confirmed,...
 data.logic.preprocess.spatialFilter.applied,... 
 data.logic.preprocess.spatialFilter.confirmed,...
 data.logic.preprocess.selectSignals.selected,...
 data.logic.preprocess.selectSignals.average,...
 data.logic.preprocess.process.saveAsMatFile,...
 data.logic.results.source,...
 data.logic.results.filter,...
 data.logic.results.filterUsed,...
 data.logic.results.directorySelected,...
 ... %data.logic.results.filterUsed,...
 ] = deal(false);
    % true logic valuse
 data.logic.results.dispAllSignals = true;
    % define global variable 
global app;

%% Create design GUI
app.figMainApp = uifigure('Name', 'PPGI - PhotoPlethysmoGraphy Imaging App',... 
       'Visible', 'off',...
       'Position', [250 70 1080 720],...        %'Position', [2 40 1920 1010],..
       'Color' ,data.interface.fontColor);
    % store data to object figMain
guidata(app.figMainApp, data);
    % close function (exit and cross) - end 2
app.figMainApp.CloseRequestFcn = {@F_figMainAppClose, app.figMainApp};
    % Maximize window after run program
%MaximizedWindow(app);
    % Set grid for better spatial location when change size of window
    % Layout of grid -> 6 row, 3 columns 
app.grMainGrid = uigridlayout(app.figMainApp);
app.grMainGrid.RowHeight = {10,'6.5x',300,'3x',30,10};
app.grMainGrid.ColumnWidth = {10,100,'1x',300,'1x',100,10};
app.grMainGrid.Padding = [0 0 0 0];
    % Set backgorund - need to set on Layout (layout can't be transparent) 
SetBackgroundIm(app, data.interface.image.background);

%% GUI Home Page               
        % Main Label of application 
app.intro.lblNameSupport = uilabel(app.grMainGrid,...
    'text','Photon Hunter',...
    'FontColor', data.interface.background.colorTwo,...
    'HorizontalAlignment', 'center',...
    'VerticalAlignment','top',...
    'FontSize', 82);
app.intro.lblNameSupport.Layout.Column = [1,7]; 
app.intro.lblNameSupport.Layout.Row = 2;

app.intro.lblName = uilabel(app.grMainGrid,...
    'text','Photon Hunter',...
    'FontColor', data.interface.fontColor,...
    'HorizontalAlignment', 'center',...
    'VerticalAlignment','top',...
    'FontSize', 80);
app.intro.lblName.Layout.Column = [1,7]; 
app.intro.lblName.Layout.Row = 2;

    % Create Tab group, which contains Preprocessing, Processing, Results tabs  
app.tbgMainTabGroup = uitabgroup(app.grMainGrid,...
    'Visible', 'off');
app.tbgMainTabGroup.Layout.Column = [1,size(app.grMainGrid.ColumnWidth,2)]; 
app.tbgMainTabGroup.Layout.Row = [1,size(app.grMainGrid.RowHeight,2)-1];   

%%%%%%%%%%%%% Home Menu %%%%%%%%%%%%%%%% 
app.intro.btgMenu= uibuttongroup(app.grMainGrid,...
    'BackgroundColor',data.interface.background.colorTwo,...
    'Visible', 'on');
app.intro.btgMenu.Layout.Column = data.intro.menu.panelPosition(1); 
app.intro.btgMenu.Layout.Row = data.intro.menu.panelPosition(2);

    app.intro.menu.btVideo = uibutton(app.intro.btgMenu,...
        'Position', data.intro.menu.buttonPositions(1,:),...
        'text', data.intro.menu.buttonNames(1),...
        'FontSize', 20); 
    app.intro.menu.btVideo.ButtonPushedFcn = @F_IntroMenubtVideo;

    app.intro.menu.btFrames = uibutton(app.intro.btgMenu,...
        'Position', data.intro.menu.buttonPositions(2,:),...
        'text', data.intro.menu.buttonNames(2),...
        'FontSize', 20); 
    app.intro.menu.btFrames.ButtonPushedFcn =@F_IntroMenubtFrames;

    app.intro.menu.btSignals = uibutton(app.intro.btgMenu,...
        'Position', data.intro.menu.buttonPositions(3,:),...
        'text', data.intro.menu.buttonNames(3),...
        'FontSize', 20); 
    app.intro.menu.btSignals.ButtonPushedFcn =@F_IntroMenubtSignals; 

    app.intro.menu.btInfo = uibutton(app.intro.btgMenu,...
        'Position', data.intro.menu.buttonPositions(4,:),...
        'text', data.intro.menu.buttonNames(4),...
        'FontSize', 20); 
    app.intro.menu.btInfo.ButtonPushedFcn =@F_IntroMenubtInfo;  

    app.intro.menu.btExit = uibutton(app.intro.btgMenu,...
        'Position', data.intro.menu.buttonPositions(5,:),...
        'text', data.intro.menu.buttonNames(5),...
        'FontSize', 20); 
    app.intro.menu.btExit.ButtonPushedFcn = {@F_IntroMenubtExit, app.figMainApp}; 

%%%%%%%%%%% Video Menu  %%%%%%%%%%%%%%%%%%   
app.intro.btgVideo= uibuttongroup(app.grMainGrid,...
    'BackgroundColor',data.interface.background.colorTwo,...
    'Visible', 'off');
app.intro.btgVideo.Layout.Column = data.intro.menu.panelPosition(1);
app.intro.btgVideo.Layout.Row = data.intro.menu.panelPosition(2);

        app.intro.video.lblVideo = uilabel (app.intro.btgVideo,...
            'Text', 'Video', ...
            'FontColor', data.interface.fontColor,...
            'FontSize', 24,...
            'Position', [20 260 260 30]);

        app.intro.video.btgFormat= uibuttongroup(app.intro.btgVideo,...
           'position',[20 180 260 70] ,...
           'Title','Format', ...
           'BackgroundColor', data.interface.background.colorOne,...
           'ForeGroundColor', data.interface.fontColor);
                app.intro.video.rbtFormat(1) = uiradiobutton(app.intro.video.btgFormat,...
                    'Text' , data.intro.video.format(1),...
                    'Position', [10 25 50 20],...
                    'FontColor', data.interface.fontColor);
                app.intro.video.rbtFormat(2) = uiradiobutton(app.intro.video.btgFormat,...
                    'Text' , data.intro.video.format(2), ...
                    'Position', [10 5 50 20],...
                    'FontColor', data.interface.fontColor);

        app.intro.video.btLoad = uibutton(app.intro.btgVideo,...
            'Position', [155 10 125 30],...
            'text', 'Load Video',...
            'FontSize', 18); 
        app.intro.video.btLoad.ButtonPushedFcn = @F_IntroVideobtLoad; 

        app.intro.video.btCancel = uibutton(app.intro.btgVideo,...
            'Position', [20 10 125 30],...
            'text', 'Cancel',...
            'FontSize', 18); 
        app.intro.video.btCancel.ButtonPushedFcn = @F_IntroVideobtCancel; 

%%%%%%%%%% Frames Menu %%%%%%%%%%%%%      
    app.intro.btgFrames = uibuttongroup(app.grMainGrid,...
        'BackgroundColor',data.interface.background.colorTwo,...
        'Visible', 'off');
    app.intro.btgFrames.Layout.Column = data.intro.menu.panelPosition(1); 
    app.intro.btgFrames.Layout.Row = data.intro.menu.panelPosition(2);

            app.intro.frames.lblFrames = uilabel (app.intro.btgFrames,...
                'Text', 'Frames', ...
                'FontColor', data.interface.fontColor,...
                'FontSize', 24,...
                'Position', [20 260 260 30]);

            app.intro.frames.btgFormat= uibuttongroup(app.intro.btgFrames,...
               'position',[20 160 120 90] ,...
               'Title','Format:', ...
               'BackgroundColor', data.interface.background.colorOne,...
               'ForeGroundColor', data.interface.fontColor);
                    app.intro.frames.format.rbtFormat(1) = uiradiobutton(app.intro.frames.btgFormat,...
                        'Text' , data.intro.frames.format(1),...
                        'Position', [10 45 50 20],...
                        'FontColor',data.interface.fontColor);
                    app.intro.frames.format.rbtFormat(2) = uiradiobutton(app.intro.frames.btgFormat,...
                        'Text' , data.intro.frames.format(2), ...
                        'Position', [10 25 50 20],...
                        'FontColor', data.interface.fontColor);
                    app.intro.frames.format.rbtFormat(3) = uiradiobutton(app.intro.frames.btgFormat,...
                        'Text' , data.intro.frames.format(3), ...
                        'Position', [10 5 50 20],...
                        'FontColor', data.interface.fontColor);
                    app.intro.frames.btgFormat.SelectionChangedFcn = {@F_IntroFramesbtgFramesFormat,...
                       app.intro.frames.format.rbtFormat} ;
            
            app.intro.frames.btgNumOfFrames= uibuttongroup(app.intro.btgFrames,...
               'position',[150 180 130 70] ,...
               'Title','Number of frames:', ...
               'BackgroundColor', data.interface.background.colorOne,...
               'ForeGroundColor', data.interface.fontColor);
                    app.intro.frames.numOfFrames.lblNumber = uilabel(app.intro.frames.btgNumOfFrames,...
                        'text', 'Frame num:',...
                        'position', [0 26 70 20],...
                        'FontColor', data.interface.fontColor,...
                        'HorizontalAlignment','Right');
                    app.intro.frames.numOfFrames.efNumber = uieditfield(app.intro.frames.btgNumOfFrames,'numeric',...
                        'Value', 1000,...
                        'position', [75 26 50 20]);
                    app.intro.frames.numOfFrames.lblStep = uilabel(app.intro.frames.btgNumOfFrames,...
                        'text', 'step:',...
                        'position', [0 5 70 20],...
                        'FontColor', data.interface.fontColor,...
                        'HorizontalAlignment','Right');
                    app.intro.frames.numOfFrames.efStep = uieditfield(app.intro.frames.btgNumOfFrames,'numeric',...
                        'Value', 1,...
                        'position', [75 5 50 20]);

            app.intro.frames.btgFramesRate = uibuttongroup(app.intro.btgFrames,...
               'position',[150 140 130 30] ,...
               'BackgroundColor', data.interface.background.colorOne,...
               'ForeGroundColor', data.interface.fontColor);
                    app.intro.frames.framesRate.lblRate = uilabel(app.intro.frames.btgFramesRate,...
                        'text', 'Frame rate:',...
                        'position', [0 5 70 20],...
                        'FontColor', data.interface.fontColor,...
                        'HorizontalAlignment','Right');
                    app.intro.frames.framesRate.spnRate = uispinner(app.intro.frames.btgFramesRate,...
                        'Limits', [1  1000],...
                        'Value', data.intro.frames.framesRate,...
                        'position', [75 5 50 20]);

           app.intro.frames.ddDataType = uidropdown(app.intro.btgFrames,...
               'Items',data.intro.frames.dataType,...
               'Value', data.intro.frames.dataType(1),...
               'Position', [150 100 130 30],...
               'FontColor', data.interface.fontColor,...
               'BackgroundColor',data.interface.background.colorOne);

           app.intro.frames.btgFramesRes = uibuttongroup(app.intro.btgFrames,...
               'position',[20 70 120 80] ,...
               'Title','Resolution',... 
               'BackgroundColor', data.interface.background.colorOne,...
               'ForeGroundColor', data.interface.fontColor);
                    app.intro.frames.framesRes.lblWidth = uilabel(app.intro.frames.btgFramesRes,...
                        'text', 'Width:',...
                        'position', [0 30 50 20],...
                        'FontColor', data.interface.fontColor,...
                        'HorizontalAlignment','Right');
                    app.intro.frames.framesRes.efWidth = uieditfield(app.intro.frames.btgFramesRes, 'numeric',...
                        'value', 1936,...
                        'position', [55 30 60 20],...
                        'ValueDisplayFormat', '%.0f px');
                    app.intro.frames.framesRes.lblHeight = uilabel(app.intro.frames.btgFramesRes,...
                        'text','Height:',...
                        'position', [0 10 50 20],...
                        'FontColor', data.interface.fontColor,...
                        'HorizontalAlignment','Right');
                    app.intro.frames.framesRes.efHeight = uieditfield(app.intro.frames.btgFramesRes,'numeric',...
                        'value',1464 ,...
                        'position', [55 10 60 20],...
                        'ValueDisplayFormat', '%.0f px');

            app.intro.frames.btLoad = uibutton(app.intro.btgFrames,...
                'Position', [155 10 125 30],...
                'text', 'Load Frames',...
                'FontSize', 18); 
            app.intro.frames.btLoad.ButtonPushedFcn = @F_IntroFramesbtLoad; 

            app.intro.frames.btCancel = uibutton(app.intro.btgFrames,...
                'Position', [20 10 125 30],...
                'text', 'Cancel',...
                'FontSize', 18); 
            app.intro.frames.btCancel.ButtonPushedFcn = @F_IntroFramesbtCancel;

%%%%%%%%%%   Signals Menu   %%%%%%%%%%%%%                 
    app.intro.btgSignals = uibuttongroup(app.grMainGrid,...
        'BackgroundColor',data.interface.background.colorTwo,...
        'Visible', 'off');
    app.intro.btgSignals.Layout.Column = data.intro.menu.panelPosition(1);
    app.intro.btgSignals.Layout.Row = data.intro.menu.panelPosition(2);

            app.intro.signals.lblSignals = uilabel (app.intro.btgSignals,...
                'Text', 'Signals',...
                'FontColor', data.interface.fontColor,...
                'FontSize', 24,...
                'Position', [20 260 260 30]);
            
            app.intro.signals.btgSource = uibuttongroup(app.intro.btgSignals,...
                'Position', [25 55 20 200],...
                'BackgroundColor', data.interface.background.colorTwo,...
                'BorderType', 'none');
                    app.intro.signals.source.cbECG = uicheckbox(app.intro.signals.btgSource,...
                        'Text', '',...
                        'Position', [3 182 20 20]);
                    app.intro.signals.source.cbECG.ValueChangedFcn = @F_IntroSignalsSourceECG;
                    app.intro.signals.source.cbPPG = uicheckbox(app.intro.signals.btgSource,...
                        'Text', '',...
                        'Position', [3 112 20 20]);
                    app.intro.signals.source.cbPPG.ValueChangedFcn = @F_IntroSignalsSourcePPG;
                    app.intro.signals.source.cbRR = uicheckbox(app.intro.signals.btgSource,...
                        'Text', '',...
                        'Position', [3 42 20 20]);
                    app.intro.signals.source.cbRR.ValueChangedFcn = @F_IntroSignalsSourceRR;

            app.intro.signals.btgECG = uibuttongroup(app.intro.btgSignals,...
               'position',[45 190 230 65] ,...
               'BackgroundColor', data.interface.background.colorOne,...
               'ForegroundColor', data.interface.fontColor,...
               'Title','ECG:');
                     app.intro.signals.ECG.lblSamplingFrequency = uilabel(app.intro.signals.btgECG,...
                        'Position', [5 25 130 20],...
                        'text','Sampling frequency:',...
                        'FontColor', data.interface.fontColor,...
                        'HorizontalAlignment','right');
                    app.intro.signals.ECG.efSamplingFrequency = uieditfield(app.intro.signals.btgECG, 'numeric',...
                        'position', [140 25 80 18],...
                        'Value', 1000,...
                        'ValueDisplayFormat','%.0f Hz');               
                    app.intro.signals.ECG.lblChannel = uilabel(app.intro.signals.btgECG,...
                        'Position', [5 4 130 20],...
                        'text','Channel:',...
                        'FontColor', data.interface.fontColor,...
                        'HorizontalAlignment','right');
                    app.intro.signals.ECG.spnChannel = uispinner(app.intro.signals.btgECG,...
                        'position', [140 4 80 18],...
                        'Value', 1,...
                        'Limits', [1 3]);
                    ManageChildOfGroup(app.intro.signals.btgECG, 'Off');
                   
            app.intro.signals.btgPPG = uibuttongroup(app.intro.btgSignals,...
               'position',[45 120 230 65] ,...
               'BackgroundColor', data.interface.background.colorOne,...
               'ForegroundColor', data.interface.fontColor,...
               'Title','PPG:');
                     app.intro.signals.PPG.lblSamplingFrequency = uilabel(app.intro.signals.btgPPG,...
                        'Position', [5 25 130 20],...
                        'text','Sampling frequency:',...
                        'FontColor', data.interface.fontColor,...
                        'HorizontalAlignment','right');
                    app.intro.signals.PPG.efSamplingFrequency = uieditfield(app.intro.signals.btgPPG, 'numeric',...
                        'position', [140 25 80 18],...
                        'Value', 1000,...
                        'ValueDisplayFormat','%.0f Hz');
                    app.intro.signals.PPG.lblChannel = uilabel(app.intro.signals.btgPPG,...
                        'Position', [5 4 130 20],...
                        'text','Channel:',...
                        'FontColor', data.interface.fontColor,...
                        'HorizontalAlignment','right');
                    app.intro.signals.PPG.spnChannel = uispinner(app.intro.signals.btgPPG,...
                        'position', [140 4 80 18],...
                        'Value', 2,...
                        'Limits', [1 3]); 
                    ManageChildOfGroup(app.intro.signals.btgPPG, 'Off');
                   
            app.intro.signals.btgRR = uibuttongroup(app.intro.btgSignals,...
               'position',[45 50 230 65] ,...
               'BackgroundColor', data.interface.background.colorOne,...
               'ForegroundColor', data.interface.fontColor,...
               'Title','Respiratory:');
                     app.intro.signals.RR.lblSamplingFrequency = uilabel(app.intro.signals.btgRR,...
                        'Position', [5 25 130 20],...
                        'text','Sampling frequency:',...
                        'FontColor', data.interface.fontColor,...
                        'HorizontalAlignment','right');
                    app.intro.signals.RR.efSamplingFrequency = uieditfield(app.intro.signals.btgRR, 'numeric',...
                        'position', [140 25 80 18],...
                        'Value', 1000,...
                        'ValueDisplayFormat','%.0f Hz');
                    app.intro.signals.RR.lblChannel = uilabel(app.intro.signals.btgRR,...
                        'Position', [5 4 130 20],...
                        'text','Channel:',...
                        'FontColor', data.interface.fontColor,...
                        'HorizontalAlignment','right');
                    app.intro.signals.RR.spnChannel = uispinner(app.intro.signals.btgRR,...
                        'position', [140 4 80 18],...
                        'Value', 3,...
                        'Limits', [1 3]);
                    ManageChildOfGroup(app.intro.signals.btgRR, 'Off');

            app.intro.signals.btLoad = uibutton(app.intro.btgSignals,...
                'Position', [155 10 125 30],...
                'text', 'Load Signals',...
                'FontSize', 18); 
            app.intro.signals.btLoad.ButtonPushedFcn = @F_IntroSignalsbtLoad; 

            app.intro.signals.btCancel = uibutton(app.intro.btgSignals,...
               'Position', [20 10 125 30],...
                'text', 'Cancel',...
                'FontSize', 18); 
            app.intro.signals.btCancel.ButtonPushedFcn = @F_IntroSignalsbtCancel; 

%%%%%%%%%%% Informations %%%%%%%%%%%%%
    app.intro.btgInfo = uibuttongroup(app.grMainGrid,...
        'BackgroundColor',data.interface.background.colorTwo,...
        'Visible', 'off');
    app.intro.btgInfo.Layout.Column = 4; 
    app.intro.btgInfo.Layout.Row = 3;

            app.intro.info.lbl = uilabel (app.intro.btgInfo,...
                'Text', 'Informations',...
                'FontColor', data.interface.fontColor,...
                'FontSize', 24,...
                'Position', [20 260 260 30]);

            app.intro.info.btCancel = uibutton(app.intro.btgInfo,...
               'Position', [20 10 125 30],...
                'text', 'Cancel',...
                'FontSize', 18); 
            app.intro.info.btCancel.ButtonPushedFcn = @F_IntroInfobtCancel; 

            app.intro.info.taInfo = uitextarea(app.intro.btgInfo,...
                'position', [20 50 260 200],...
                'editable', 'off',...
                'FontColor', 'black',...
                'BackgroundColor', data.interface.background.colorThree,...
                'HorizontalAlignment', 'center',...
                'Value', data.intro.info);

%%%%%%%%%% Next Button %%%%%%%%%%%%%
    app.intro.btNext = uibutton(app.grMainGrid,...
        'text','Next',...
        'FontSize', 18,...
        'Visible', 'off');
    app.intro.btNext.Layout.Column = size(app.grMainGrid.ColumnWidth,2)-1;
    app.intro.btNext.Layout.Row = size(app.grMainGrid.RowHeight,2)-2;
        % Problem. Why size(app.grMainGrid.RowHeight,2)-1? When add new button - create new row - last row
    app.intro.btNext.ButtonPushedFcn = @F_IntrobtNext;

%% GUI Tab Group - Creation                                          
    % create interactive buttons Next And previous
    % and create uniform grid Layout for tab
CreateTabStructure(data.mainTabGroupNames, data.interface.background.colorTwo);

%% GUI Tab Group - Preprocessing
app.grPreprocess = uigridlayout(app.mainTabGroup.grTabGrid(1));
app.grPreprocess.Layout.Row = 1;
app.grPreprocess.Layout.Column = [1 3];
app.grPreprocess.ColumnWidth = {'2x', 350};
app.grPreprocess.RowHeight = {'1x'};
app.grPreprocess.BackgroundColor = data.interface.background.colorOne;

    app.preprocess.axAxesImage = uiaxes(app.grPreprocess);
    % app.preprocess.axAxesImage.ALim = [0 1];
    app.preprocess.axAxesImage.XTick = [];
    app.preprocess.axAxesImage.YTick = [];
    app.preprocess.axAxesImage.BoxStyle = 'full';
    app.preprocess.axAxesImage.Layout.Row = 1;
    app.preprocess.axAxesImage.Layout.Column = 1;
    app.preprocess.axAxesImage.Toolbar.Visible = 'off';
    app.preprocess.axAxesImage.AmbientLightColor = data.interface.background.colorTwo;
    app.preprocess.axAxesImage.Color = data.interface.background.colorTwo;
    disableDefaultInteractivity(app.preprocess.axAxesImage);

    app.preprocess.pControl  = uipanel(app.grPreprocess);
    app.preprocess.pControl .TitlePosition = 'centertop';
    app.preprocess.pControl .Title = 'Control Panel';
    app.preprocess.pControl .Layout.Row = 1;
    app.preprocess.pControl .Layout.Column = 2;
    app.preprocess.pControl .FontWeight = 'bold';
    app.preprocess.pControl .Scrollable = 'on';
    app.preprocess.pControl.BackgroundColor = data.interface.background.colorTwo;
    app.preprocess.pControl.ForegroundColor = data.interface.fontColor;

            app.preprocess.control.pOptions = uipanel(app.preprocess.pControl );
            app.preprocess.control.pOptions.TitlePosition = 'centertop';
            app.preprocess.control.pOptions.Title = 'Options';
            app.preprocess.control.pOptions.FontWeight = 'bold';
            app.preprocess.control.pOptions.Position = [5 440 135 150];
            app.preprocess.control.pOptions.BackgroundColor = data.interface.background.colorTwo;
            app.preprocess.control.pOptions.ForegroundColor = data.interface.fontColor;

                    app.preprocess.control.options.cbMarkROI = uicheckbox(app.preprocess.control.pOptions);
                    app.preprocess.control.options.cbMarkROI.Text = 'Mark ROI';
                    app.preprocess.control.options.cbMarkROI.Position = [10 106 73 25];
                    app.preprocess.control.options.cbMarkROI.ValueChangedFcn = @F_PreprocessControlOptionscbMarkROI;
                    app.preprocess.control.options.cbMarkROI.FontColor = data.interface.fontColor;

                    app.preprocess.control.options.cbTrackROI = uicheckbox(app.preprocess.control.pOptions);
                    app.preprocess.control.options.cbTrackROI.Text = 'ROI tracking';
                    app.preprocess.control.options.cbTrackROI.Position = [20 84 89 25];
                    app.preprocess.control.options.cbTrackROI.Enable = false;
                    app.preprocess.control.options.cbTrackROI.FontColor = data.interface.fontColor;

                    app.preprocess.control.options.cbSpatialFilter = uicheckbox(app.preprocess.control.pOptions);
                    app.preprocess.control.options.cbSpatialFilter.Text = 'Spatial Filter';
                    app.preprocess.control.options.cbSpatialFilter.Position = [20 62 89 25];
                    app.preprocess.control.options.cbSpatialFilter.Enable = false;
                    app.preprocess.control.options.cbSpatialFilter.FontColor = data.interface.fontColor;
                    
                    app.preprocess.control.options.cbSelectSignals = uicheckbox(app.preprocess.control.pOptions);
                    app.preprocess.control.options.cbSelectSignals.Text = 'Select Signals';
                    app.preprocess.control.options.cbSelectSignals.Position = [10 40 98 25];
                    app.preprocess.control.options.cbSelectSignals.FontColor = data.interface.fontColor;

                    app.preprocess.control.options.btConfirm = uibutton(app.preprocess.control.pOptions, 'push');
                    app.preprocess.control.options.btConfirm.Position = [25 12 80 25];
                    app.preprocess.control.options.btConfirm.Text = 'Confirm';
                    app.preprocess.control.options.btConfirm.ButtonPushedFcn = @F_PreprocessControlOptionsbtConfirm;

            app.preprocess.control.pRotation = uipanel(app.preprocess.pControl );
            app.preprocess.control.pRotation.TitlePosition = 'centertop';
            app.preprocess.control.pRotation.Title = 'Image rotation';
            app.preprocess.control.pRotation.FontWeight = 'bold';
            app.preprocess.control.pRotation.Position = [145 530 200 60];
            app.preprocess.control.pRotation.BackgroundColor = data.interface.background.colorTwo;
            app.preprocess.control.pRotation.ForegroundColor = data.interface.fontColor;

                    app.preprocess.control.rotation.btDisplayImage = uibutton(app.preprocess.control.pRotation, 'push');
                    app.preprocess.control.rotation.btDisplayImage.Position = [55 8 90 25];
                    app.preprocess.control.rotation.btDisplayImage.Text = 'Restore Image';
                    app.preprocess.control.rotation.btDisplayImage.ButtonPushedFcn = @F_PreprocessControlRotationbtDisplayImage;
                    
                    app.preprocess.control.rotation.btLeft = uibutton(app.preprocess.control.pRotation, 'push');
                    app.preprocess.control.rotation.btLeft.Position = [5 8 45 25];
                    app.preprocess.control.rotation.btLeft.Text = '';
                    app.preprocess.control.rotation.btLeft.Icon = data.interface.image.left;
                    app.preprocess.control.rotation.btLeft.IconAlignment = 'center';
                    app.preprocess.control.rotation.btLeft.ButtonPushedFcn =  @F_PreprocessControlRotationLeft;

                    app.preprocess.control.rotation.btRight = uibutton(app.preprocess.control.pRotation, 'push');
                    app.preprocess.control.rotation.btRight.Position = [150 8 45 25];
                    app.preprocess.control.rotation.btRight.Text = '';
                    app.preprocess.control.rotation.btRight.Icon = data.interface.image.right;
                    app.preprocess.control.rotation.btRight.IconAlignment = 'center';
                    app.preprocess.control.rotation.btRight.ButtonPushedFcn = @F_PreprocessControlRotationRight;

            app.preprocess.control.pROI = uipanel(app.preprocess.pControl );
            app.preprocess.control.pROI.TitlePosition = 'centertop';
            app.preprocess.control.pROI.Title = 'Region of interest';
            app.preprocess.control.pROI.FontWeight = 'bold';
            app.preprocess.control.pROI.Position = [145 440 200 85];
            app.preprocess.control.pROI.BackgroundColor = data.interface.background.colorTwo;
            app.preprocess.control.pROI.ForegroundColor = data.interface.fontColor;
            
                    app.preprocess.control.ROI.btDisplayImage = uibutton(app.preprocess.control.pROI, 'push');
                    app.preprocess.control.ROI.btDisplayImage.Position = [15 34 80 25];
                    app.preprocess.control.ROI.btDisplayImage.Text = 'Display Im';
                    app.preprocess.control.ROI.btDisplayImage.ButtonPushedFcn = @F_PreprocessControlROIbtDisplayImage;
                    
                    app.preprocess.control.ROI.btMarkROI = uibutton(app.preprocess.control.pROI, 'push');
                    app.preprocess.control.ROI.btMarkROI.Position = [99 35 80 25];
                    app.preprocess.control.ROI.btMarkROI.Text = 'Mark ROI';
                    app.preprocess.control.ROI.btMarkROI.ButtonPushedFcn = @F_PreprocessControlROIbtMarkROI;

                    app.preprocess.control.ROI.btRestore = uibutton(app.preprocess.control.pROI, 'push');
                    app.preprocess.control.ROI.btRestore.Position = [15 4 80 25];
                    app.preprocess.control.ROI.btRestore.Text = 'Restore';
                    app.preprocess.control.ROI.btRestore.ButtonPushedFcn = @F_PreprocessControlROIbtRestore;
                    
                    app.preprocess.control.ROI.btConfirm = uibutton(app.preprocess.control.pROI, 'push');
                    app.preprocess.control.ROI.btConfirm.Position = [99 4 80 26];
                    app.preprocess.control.ROI.btConfirm.Text = 'Confirm';
                    app.preprocess.control.ROI.btConfirm.IconAlignment = 'right';
                    app.preprocess.control.ROI.btConfirm.ButtonPushedFcn = @F_PreprocessControlROIbtConfirm;

            app.preprocess.control.pTracker = uipanel(app.preprocess.pControl );
            app.preprocess.control.pTracker.TitlePosition = 'centertop';
            app.preprocess.control.pTracker.Title = 'Region of interest tracker options';
            app.preprocess.control.pTracker.FontWeight = 'bold';
            app.preprocess.control.pTracker.Position = [5 340 340 95];
            app.preprocess.control.pTracker.BackgroundColor = data.interface.background.colorTwo;
            app.preprocess.control.pTracker.ForegroundColor = data.interface.fontColor;
            
                    app.preprocess.control.tracker.lblMinQuality = uilabel(app.preprocess.control.pTracker);
                    app.preprocess.control.tracker.lblMinQuality.HorizontalAlignment = 'right';
                    app.preprocess.control.tracker.lblMinQuality.Position = [1 40 69 25];
                    app.preprocess.control.tracker.lblMinQuality.Text = 'Min Quality:';
                    app.preprocess.control.tracker.lblMinQuality.FontColor = data.interface.fontColor;

                    app.preprocess.control.tracker.spnMinQuality = uispinner(app.preprocess.control.pTracker);
                    app.preprocess.control.tracker.spnMinQuality.Step = 0.01;
                    app.preprocess.control.tracker.spnMinQuality.Limits = [0 1];
                    app.preprocess.control.tracker.spnMinQuality.Position = [80 40 75 25];
                    app.preprocess.control.tracker.spnMinQuality.Value = 0.15;

                    app.preprocess.control.tracker.lblFilterSize = uilabel(app.preprocess.control.pTracker);
                    app.preprocess.control.tracker.lblFilterSize.HorizontalAlignment = 'right';
                    app.preprocess.control.tracker.lblFilterSize.Position = [3 10 62 25];
                    app.preprocess.control.tracker.lblFilterSize.Text = 'Filter Size:';
                    app.preprocess.control.tracker.lblFilterSize.FontColor = data.interface.fontColor;

                    app.preprocess.control.tracker.spnFilterSize = uispinner(app.preprocess.control.pTracker);
                    app.preprocess.control.tracker.spnFilterSize.Step = 2;
                    app.preprocess.control.tracker.spnFilterSize.Limits = [3 33];
                    app.preprocess.control.tracker.spnFilterSize.RoundFractionalValues = 'on';
                    app.preprocess.control.tracker.spnFilterSize.ValueDisplayFormat = '%.0fpx';
                    app.preprocess.control.tracker.spnFilterSize.Position = [80 10 75 25];
                    app.preprocess.control.tracker.spnFilterSize.Value = 7;

                    app.preprocess.control.tracker.btRestore = uibutton(app.preprocess.control.pTracker, 'push');
                    app.preprocess.control.tracker.btRestore.Position = [170 10 80 25];
                    app.preprocess.control.tracker.btRestore.Text = 'Restore';
                    app.preprocess.control.tracker.btRestore.ButtonPushedFcn = @F_PreprocessControlTrackerRestore;

                    app.preprocess.control.tracker.btConfirm = uibutton(app.preprocess.control.pTracker, 'push');
                    app.preprocess.control.tracker.btConfirm.Position = [255 10 80 25];
                    app.preprocess.control.tracker.btConfirm.Text = 'Confirm';
                    app.preprocess.control.tracker.btConfirm.IconAlignment = 'right';
                    app.preprocess.control.tracker.btConfirm.ButtonPushedFcn = @F_PreprocessControlTrackerConfirm;

                    app.preprocess.control.tracker.btApply = uibutton(app.preprocess.control.pTracker, 'push');
                    app.preprocess.control.tracker.btApply.Position = [255 40 80 25];
                    app.preprocess.control.tracker.btApply.Text = 'Apply';
                    app.preprocess.control.tracker.btApply.ButtonPushedFcn = @F_PreprocessControlTrackerApply;

                    app.preprocess.control.tracker.btDisplayImage = uibutton(app.preprocess.control.pTracker, 'push');
                    app.preprocess.control.tracker.btDisplayImage.Position = [170 40 80 25];
                    app.preprocess.control.tracker.btDisplayImage.Text = 'Display Im';
                    app.preprocess.control.tracker.btDisplayImage.ButtonPushedFcn = @F_PreprocessControlTrackerDisplayImage;

            app.preprocess.control.pSpatialFilter = uipanel(app.preprocess.pControl );
            app.preprocess.control.pSpatialFilter.TitlePosition = 'centertop';
            app.preprocess.control.pSpatialFilter.Title = 'Spatial Filter';
            app.preprocess.control.pSpatialFilter.FontWeight = 'bold';
            app.preprocess.control.pSpatialFilter.Position = [5 175 175 160];
            app.preprocess.control.pSpatialFilter.BackgroundColor = data.interface.background.colorTwo;
            app.preprocess.control.pSpatialFilter.ForegroundColor = data.interface.fontColor;

                    app.preprocess.control.spatialFilter.lblFilterType = uilabel(app.preprocess.control.pSpatialFilter);
                    app.preprocess.control.spatialFilter.lblFilterType.HorizontalAlignment = 'right';
                    app.preprocess.control.spatialFilter.lblFilterType.Position = [7 110 62 22];
                    app.preprocess.control.spatialFilter.lblFilterType.Text = 'Filter type:';
                    app.preprocess.control.spatialFilter.lblFilterType.FontColor = data.interface.fontColor;

                    app.preprocess.control.spatialFilter.ddFilterType = uidropdown(app.preprocess.control.pSpatialFilter);
                    app.preprocess.control.spatialFilter.ddFilterType.Items = data.preprocess.static.filterType; 
                    app.preprocess.control.spatialFilter.ddFilterType.Position = [70 110 88 25];
                    app.preprocess.control.spatialFilter.ddFilterType.Value = 'Average';

                    app.preprocess.control.spatialFilter.lblKernelSize = uilabel(app.preprocess.control.pSpatialFilter);
                    app.preprocess.control.spatialFilter.lblKernelSize.HorizontalAlignment = 'right';
                    app.preprocess.control.spatialFilter.lblKernelSize.Position = [2 78 68 25];
                    app.preprocess.control.spatialFilter.lblKernelSize.Text = 'Kernel size:'; 
                    app.preprocess.control.spatialFilter.lblKernelSize.FontColor = data.interface.fontColor;

                    app.preprocess.control.spatialFilter.ddKernelSize = uidropdown(app.preprocess.control.pSpatialFilter);
                    app.preprocess.control.spatialFilter.ddKernelSize.Position = [71 78 87 25];
                    app.preprocess.control.spatialFilter.ddKernelSize.Items = data.preprocess.static.kernelSize;

                    app.preprocess.control.spatialFilter.btRestore = uibutton(app.preprocess.control.pSpatialFilter, 'push');
                    app.preprocess.control.spatialFilter.btRestore.Position = [5 10 80 25];
                    app.preprocess.control.spatialFilter.btRestore.Text = 'Restore';
                    app.preprocess.control.spatialFilter.btRestore.ButtonPushedFcn = @F_PreprocessControlSpatialFilterbtRestore ;
                    
                    app.preprocess.control.spatialFilter.btApply = uibutton(app.preprocess.control.pSpatialFilter, 'push');
                    app.preprocess.control.spatialFilter.btApply.Position = [90 40 80 25];
                    app.preprocess.control.spatialFilter.btApply.Text = 'Apply';
                    app.preprocess.control.spatialFilter.btApply.ButtonPushedFcn = @F_PreprocessControlSpatialFilterbtApply;
                    
                    app.preprocess.control.spatialFilter.btConfirm = uibutton(app.preprocess.control.pSpatialFilter, 'push');
                    app.preprocess.control.spatialFilter.btConfirm.Position = [90 10 80 25];
                    app.preprocess.control.spatialFilter.btConfirm.Text = 'Confirm';
                    app.preprocess.control.spatialFilter.btConfirm.IconAlignment = 'right';
                    app.preprocess.control.spatialFilter.btConfirm.ButtonPushedFcn = @F_PreprocessControlSpatialFilterbtConfirm;

                    app.preprocess.control.spatialFilter.btDisplayImage = uibutton(app.preprocess.control.pSpatialFilter, 'push');
                    app.preprocess.control.spatialFilter.btDisplayImage.Position = [5 39 80 26];
                    app.preprocess.control.spatialFilter.btDisplayImage.Text = 'Display Im';
                    app.preprocess.control.spatialFilter.btDisplayImage.ButtonPushedFcn = @F_PreprocessControlSpatialFilterbtDisplayImage;

            app.preprocess.control.pSelectSignals = uipanel(app.preprocess.pControl );
            app.preprocess.control.pSelectSignals.TitlePosition = 'centertop';
            app.preprocess.control.pSelectSignals.Title = 'Select Signals';
            app.preprocess.control.pSelectSignals.FontWeight = 'bold';
            app.preprocess.control.pSelectSignals.Scrollable = 'on';
            app.preprocess.control.pSelectSignals.Position = [185 175 160 160];
            app.preprocess.control.pSelectSignals.BackgroundColor = data.interface.background.colorTwo;
            app.preprocess.control.pSelectSignals.ForegroundColor = data.interface.fontColor;

                    app.preprocess.control.selectSignals.lblNumOfSignals = uilabel(app.preprocess.control.pSelectSignals);
                    app.preprocess.control.selectSignals.lblNumOfSignals.HorizontalAlignment = 'right';
                    app.preprocess.control.selectSignals.lblNumOfSignals.Position = [6 110 86 25];
                    app.preprocess.control.selectSignals.lblNumOfSignals.Text = 'Num of Signals:';
                    app.preprocess.control.selectSignals.lblNumOfSignals.FontColor = data.interface.fontColor;

                    app.preprocess.control.selectSignals.spnNumOfSignals = uispinner(app.preprocess.control.pSelectSignals);
                    app.preprocess.control.selectSignals.spnNumOfSignals.Limits = [1 8];
                    app.preprocess.control.selectSignals.spnNumOfSignals.RoundFractionalValues = 'on';
                    app.preprocess.control.selectSignals.spnNumOfSignals.Position = [99 110 56 25];
                    app.preprocess.control.selectSignals.spnNumOfSignals.Value = 1;

                    app.preprocess.control.selectSignals.cbAverage = uicheckbox(app.preprocess.control.pSelectSignals);
                    app.preprocess.control.selectSignals.cbAverage.Text = '     Average:';
                    app.preprocess.control.selectSignals.cbAverage.Position = [8 79 87 25];
                    app.preprocess.control.selectSignals.cbAverage.ValueChangedFcn = @F_PreprocessControlSelectSignalsSelectcbAverage;
                    app.preprocess.control.selectSignals.cbAverage.FontColor = data.interface.fontColor;

                    app.preprocess.control.selectSignals.spnAverage = uispinner(app.preprocess.control.pSelectSignals);
                    app.preprocess.control.selectSignals.spnAverage.Step = 2;
                    app.preprocess.control.selectSignals.spnAverage.Limits = [3 Inf];
                    app.preprocess.control.selectSignals.spnAverage.RoundFractionalValues = 'on';
                    app.preprocess.control.selectSignals.spnAverage.ValueDisplayFormat = '%.0fpx';
                    app.preprocess.control.selectSignals.spnAverage.Position = [99 79 56 25];
                    app.preprocess.control.selectSignals.spnAverage.Value = 3;

                    app.preprocess.control.selectSignals.btSelectSignals = uibutton(app.preprocess.control.pSelectSignals, 'push');
                    app.preprocess.control.selectSignals.btSelectSignals.Position = [75 40 80 25];
                    app.preprocess.control.selectSignals.btSelectSignals.Text = 'Select signals';
                    app.preprocess.control.selectSignals.btSelectSignals.ButtonPushedFcn = @F_PreprocessControlSelectSignalsSelectSignals;

                    app.preprocess.control.selectSignals.btRestore = uibutton(app.preprocess.control.pSelectSignals, 'push');
                    app.preprocess.control.selectSignals.btRestore.Position = [5 10 150 25];
                    app.preprocess.control.selectSignals.btRestore.Text = 'Restore';
                    app.preprocess.control.selectSignals.btRestore.ButtonPushedFcn = @F_PreprocessControlSelectSignalsRestore;

                    app.preprocess.control.selectSignals.btDisaplyImage = uibutton(app.preprocess.control.pSelectSignals, 'push');
                    app.preprocess.control.selectSignals.btDisaplyImage.Position = [5 40 65 25];
                    app.preprocess.control.selectSignals.btDisaplyImage.Text = 'Display Im';  
                    app.preprocess.control.selectSignals.btDisaplyImage.ButtonPushedFcn = @F_PreprocessControlSelectSignalsDisplayImage;

            app.preprocess.control.pProcess = uipanel(app.preprocess.pControl );
            app.preprocess.control.pProcess.TitlePosition = 'centertop';
            app.preprocess.control.pProcess.Title = 'Process';
            app.preprocess.control.pProcess.FontWeight = 'bold';
            app.preprocess.control.pProcess.Position = [5 5 340 165];
            app.preprocess.control.pProcess.BackgroundColor = data.interface.background.colorTwo;
            app.preprocess.control.pProcess.ForegroundColor = data.interface.fontColor;

                    app.preprocess.control.process.btStartProcess = uibutton(app.preprocess.control.pProcess, 'push');
                    app.preprocess.control.process.btStartProcess.FontWeight = 'bold';
                    app.preprocess.control.process.btStartProcess.Position = [217 10 110 50];
                    app.preprocess.control.process.btStartProcess.Text = 'Start process';
                    app.preprocess.control.process.btStartProcess.ButtonPushedFcn = @F_PreprocessControlProcessStartProcess;

                    app.preprocess.control.process.cbSaveROIFrames = uicheckbox(app.preprocess.control.pProcess);
                    app.preprocess.control.process.cbSaveROIFrames.Text = '';
                    app.preprocess.control.process.cbSaveROIFrames.Position = [40 116 25 22];
                    app.preprocess.control.process.cbSaveROIFrames.ValueChangedFcn = @F_PreprocessControlProcesscbSaveROIFrames;
                    
                    app.preprocess.control.process.lblSaveROIFrames = uilabel(app.preprocess.control.pProcess);
                    app.preprocess.control.process.lblSaveROIFrames.HorizontalAlignment = 'right';
                    app.preprocess.control.process.lblSaveROIFrames.Position = [60 115 125 25];
                    app.preprocess.control.process.lblSaveROIFrames.Text = 'Save frames of ROI as:';
                    app.preprocess.control.process.lblSaveROIFrames.FontColor = data.interface.fontColor;

                    app.preprocess.control.process.efSaveROIFrames = uieditfield(app.preprocess.control.pProcess, 'text');
                    app.preprocess.control.process.efSaveROIFrames.Position = [190 115 78 25];
                    app.preprocess.control.process.efSaveROIFrames.Value = 'MONO';
                    app.preprocess.control.process.efSaveROIFrames.HorizontalAlignment = 'right';
                    
                    app.preprocess.control.process.ddSaveROIFramesFormat = uidropdown(app.preprocess.control.pProcess);
                    app.preprocess.control.process.ddSaveROIFramesFormat.Position = [275 115 60 25];
                    app.preprocess.control.process.ddSaveROIFramesFormat.Items = data.preprocess.static.saveFormat;

                    app.preprocess.control.process.lblSaveSignals = uilabel(app.preprocess.control.pProcess);
                    app.preprocess.control.process.lblSaveSignals.HorizontalAlignment = 'right';
                    app.preprocess.control.process.lblSaveSignals.Position = [0 86 185 22];
                    app.preprocess.control.process.lblSaveSignals.Text = 'Save processed data to:';
                    app.preprocess.control.process.lblSaveSignals.FontColor = data.interface.fontColor;

                    app.preprocess.control.process.ddSaveSignals = uidropdown(app.preprocess.control.pProcess);
                    app.preprocess.control.process.ddSaveSignals.Items = {'', ''};
                    app.preprocess.control.process.ddSaveSignals.Position = [190 85 140 25];
                    app.preprocess.control.process.ddSaveSignals.Value = '';
                    app.preprocess.control.process.ddSaveSignals.Items = data.preprocess.static.results; 

                    app.preprocess.control.process.lblNotes = uilabel(app.preprocess.control.pProcess);
                    app.preprocess.control.process.lblNotes.HorizontalAlignment = 'right';
                    app.preprocess.control.process.lblNotes.Position = [5 65 37 22];
                    app.preprocess.control.process.lblNotes.Text = 'Notes:';
                    app.preprocess.control.process.lblNotes.FontColor = data.interface.fontColor;

                    app.preprocess.control.process.taNotes = uitextarea(app.preprocess.control.pProcess);
                    app.preprocess.control.process.taNotes.Position = [5 5 200 60];
                    
ManageChildOfGroup(app.preprocess.control.pROI, 'off');
ManageChildOfGroup(app.preprocess.control.pTracker, 'off');
ManageChildOfGroup(app.preprocess.control.pSpatialFilter, 'off');
ManageChildOfGroup(app.preprocess.control.pSelectSignals, 'off');
ManageChildOfGroup(app.preprocess.control.pProcess, 'off');

%% GUI Tab Group - Results;
app.grResults = uigridlayout(app.mainTabGroup.grTabGrid(2));
app.grResults.Layout.Row = 1;
app.grResults.Layout.Column = [1 3];
app.grResults.ColumnWidth = {'1x', 320};
app.grResults.RowHeight = {'1.2x', 200, 147};
app.grResults.BackgroundColor = data.interface.background.colorOne;

    app.results.axPPGI = uiaxes(app.grResults);
    app.results.axPPGI.Layout.Row = [1 2];
    app.results.axPPGI.Layout.Column = 1;
    app.results.axPPGI.Color = [0.92, 0.92, 0.92];
    app.results.axPPGI.XColor = data.interface.fontColor;
    app.results.axPPGI.YColor = data.interface.fontColor;
    app.results.axPPGI.Title.String = 'PPGI Signal';
    app.results.axPPGI.Title.Color = data.interface.fontColor;
    disableDefaultInteractivity(app.results.axPPGI);
    app.results.axPPGI.Toolbar.Visible = 'off';

    app.results.axBIOPAC = uiaxes(app.grResults);
    app.results.axBIOPAC.Layout.Row = 3;
    app.results.axBIOPAC.Layout.Column = 1;
    app.results.axBIOPAC.Color = [0.92, 0.92, 0.92];
    app.results.axBIOPAC.XColor = data.interface.fontColor;
    app.results.axBIOPAC.YColor = data.interface.fontColor;
    app.results.axBIOPAC.Title.String = 'BIOPAC';
    app.results.axBIOPAC.Title.Color = data.interface.fontColor;
    disableDefaultInteractivity(app.results.axBIOPAC);
    app.results.axBIOPAC.Toolbar.Visible = 'off';

    app.results.imResult = uiimage(app.grResults);
    app.results.imResult.Layout.Row = 1;
    app.results.imResult.Layout.Column = 2;
    app.results.imResult.BackgroundColor = data.interface.background.colorTwo;
    
    app.results.pControl = uipanel(app.grResults);
    app.results.pControl.TitlePosition = 'centertop';
    app.results.pControl.Title = 'Control Panel';
    app.results.pControl.Layout.Row = [2 3];
    app.results.pControl.Layout.Column = 2;
    app.results.pControl.FontSize = 15;
    app.results.pControl.BackgroundColor = data.interface.background.colorTwo;
    app.results.pControl.ForegroundColor = data.interface.fontColor;
    app.results.pControl.FontWeight = 'bold';
    app.results.pControl.FontSize = 12;

            app.results.control.pSourceData = uipanel(app.results.pControl);
            app.results.control.pSourceData.Title = 'Source data:';
            app.results.control.pSourceData.Position = [5 175 310 160];
            app.results.control.pSourceData.BackgroundColor = data.interface.background.colorTwo;
            app.results.control.pSourceData.ForegroundColor = data.interface.fontColor;
            app.results.control.pSourceData.FontWeight = 'bold';
         
                    app.results.control.sourceData.pSignals = uipanel(app.results.control.pSourceData);
                    app.results.control.sourceData.pSignals.Title = 'Signals to Display:';
                    app.results.control.sourceData.pSignals.Position = [130 40 170 95];
                    app.results.control.sourceData.pSignals.BackgroundColor = data.interface.background.colorTwo;
                    app.results.control.sourceData.pSignals.ForegroundColor = data.interface.fontColor;
                    app.results.control.sourceData.pSignals.FontWeight = 'bold';
                           
                            app.results.control.sourceData.signals.cb(1) = uicheckbox(app.results.control.sourceData.pSignals);
                            app.results.control.sourceData.signals.cb(1).Text = '1. Blue';
                            app.results.control.sourceData.signals.cb(1).Position = [5 54 59 22];
                            app.results.control.sourceData.signals.cb(1).FontColor = data.interface.fontColor;
                            
                            app.results.control.sourceData.signals.cb(2) = uicheckbox(app.results.control.sourceData.pSignals);
                            app.results.control.sourceData.signals.cb(2).Text = '2. Green';
                            app.results.control.sourceData.signals.cb(2).Position = [5 36 69 22];
                            app.results.control.sourceData.signals.cb(2).FontColor = data.interface.fontColor;

                            app.results.control.sourceData.signals.cb(3) = uicheckbox(app.results.control.sourceData.pSignals);
                            app.results.control.sourceData.signals.cb(3).Text = '3. Red';
                            app.results.control.sourceData.signals.cb(3).Position = [5 18 57 22];
                            app.results.control.sourceData.signals.cb(3).FontColor = data.interface.fontColor;
                            
                            app.results.control.sourceData.signals.cb(4) = uicheckbox(app.results.control.sourceData.pSignals);
                            app.results.control.sourceData.signals.cb(4).Text = '4. Cyan';
                            app.results.control.sourceData.signals.cb(4).Position = [5 0 63 22];
                            app.results.control.sourceData.signals.cb(4).FontColor = data.interface.fontColor;
                            
                            app.results.control.sourceData.signals.cb(5) = uicheckbox(app.results.control.sourceData.pSignals);
                            app.results.control.sourceData.signals.cb(5).Text = '5. Magenta';
                            app.results.control.sourceData.signals.cb(5).Position = [80 54 82 22];
                            app.results.control.sourceData.signals.cb(5).FontColor = data.interface.fontColor;

                            app.results.control.sourceData.signals.cb(6) = uicheckbox(app.results.control.sourceData.pSignals);
                            app.results.control.sourceData.signals.cb(6).Text = '6. Yellow';
                            app.results.control.sourceData.signals.cb(6).Position = [80 36 70 22];
                            app.results.control.sourceData.signals.cb(6).FontColor = data.interface.fontColor;
                            
                            app.results.control.sourceData.signals.cb(7) = uicheckbox(app.results.control.sourceData.pSignals);
                            app.results.control.sourceData.signals.cb(7).Text = '7. Black';
                            app.results.control.sourceData.signals.cb(7).Position = [80 18 65 22];
                            app.results.control.sourceData.signals.cb(7).FontColor = data.interface.fontColor;

                            app.results.control.sourceData.signals.cb(8) = uicheckbox(app.results.control.sourceData.pSignals);
                            app.results.control.sourceData.signals.cb(8).Text = '8. White';
                            app.results.control.sourceData.signals.cb(8).Position = [80 0 66 22];
                            app.results.control.sourceData.signals.cb(8).FontColor = data.interface.fontColor;
                            
                    ManageChildOfGroup(app.results.control.sourceData.pSignals, 'off');
                   
                    app.results.control.sourceData.ddSource = uidropdown(app.results.control.pSourceData);
                    app.results.control.sourceData.ddSource.Items = {'Source'};
                    app.results.control.sourceData.ddSource.Position = [10 113 115 22];
                    app.results.control.sourceData.ddSource.ValueChangedFcn = @F_ResultsControlSourceDataSource;

                    app.results.control.sourceData.ddQuantity = uidropdown(app.results.control.pSourceData);
                    app.results.control.sourceData.ddQuantity.Items = {'All signals', 'Select signals'};
                    app.results.control.sourceData.ddQuantity.Position = [10 87 115 22];
                    app.results.control.sourceData.ddQuantity.Value = 'All signals';
                    app.results.control.sourceData.ddQuantity.ValueChangedFcn = @F_ResultsControlSourceDataQuantity;
                    
                    app.results.control.sourceData.ddFilter= uidropdown(app.results.control.pSourceData);
                    app.results.control.sourceData.ddFilter.Position = [10 61 85 22];
                    app.results.control.sourceData.ddFilter.Items = data.results.static.filter;
                    app.results.control.sourceData.ddFilter.Enable = false;
                    app.results.control.sourceData.ddFilter.ValueChangedFcn = @F_ResultsControlSourceFilter;
                    
                    app.results.control.sourceData.btFilterInfo= uibutton(app.results.control.pSourceData);
                    app.results.control.sourceData.btFilterInfo.Position = [100 61 25 22];
                    app.results.control.sourceData.btFilterInfo.Text = '';
                    app.results.control.sourceData.btFilterInfo.Icon = data.interface.image.info;
                    app.results.control.sourceData.btFilterInfo.IconAlignment = 'center';
                    app.results.control.sourceData.btFilterInfo.Enable = false;
                    app.results.control.sourceData.btFilterInfo.ButtonPushedFcn = @F_ResultsControlSourceDataFilterInfo;
                    
                    app.results.control.sourceData.ddBIOPAC= uidropdown(app.results.control.pSourceData);
                    app.results.control.sourceData.ddBIOPAC.Position = [10 35 85 22];
                    app.results.control.sourceData.ddBIOPAC.Items = {'BIOPAC'};
                    app.results.control.sourceData.ddBIOPAC.Enable = false;
                    app.results.control.sourceData.ddBIOPAC.ValueChangedFcn = @F_ResultsControlSourceDataBIOPAC;
                    
                    app.results.control.sourceData.btBIOPACSync= uibutton(app.results.control.pSourceData);
                    app.results.control.sourceData.btBIOPACSync.Position = [100 35 25 22];
                    app.results.control.sourceData.btBIOPACSync.Text = '';
                    app.results.control.sourceData.btBIOPACSync.Icon = data.interface.image.sync;
                    app.results.control.sourceData.btBIOPACSync.IconAlignment = 'center';
                    app.results.control.sourceData.btBIOPACSync.Enable = false;
                    app.results.control.sourceData.btBIOPACSync.ButtonPushedFcn = @F_ResultsControlSourceDataBIOPACSync;
                                             
                    app.results.control.sourceData.btToolbar = uibutton(app.results.control.pSourceData, 'state');
                    app.results.control.sourceData.btToolbar.Text = 'Enable Toolbar';
                    app.results.control.sourceData.btToolbar.Position = [10 9 115 22];
                    app.results.control.sourceData.btToolbar.Enable = false;
                    app.results.control.sourceData.btToolbar.ValueChangedFcn = @F_ResultsControlSourceDataToolbar;
                    
                    app.results.control.sourceData.btDisplay = uibutton(app.results.control.pSourceData, 'push');
                    app.results.control.sourceData.btDisplay.Position = [145 5 140 30];
                    app.results.control.sourceData.btDisplay.Text = 'Display Data';
                    app.results.control.sourceData.btDisplay.Enable = false;
                    app.results.control.sourceData.btDisplay.FontWeight = 'bold';
                    app.results.control.sourceData.btDisplay.ButtonPushedFcn = @F_ResultsControlSourceDataDisplay;
                    
            app.results.control.pAnalysis= uipanel(app.results.pControl);
            app.results.control.pAnalysis.Title = 'Analysis:';
            app.results.control.pAnalysis.Position = [5 5 195 165];
            app.results.control.pAnalysis.BackgroundColor = data.interface.background.colorTwo;
            app.results.control.pAnalysis.ForegroundColor = data.interface.fontColor;
            app.results.control.pAnalysis.FontWeight = 'bold';
            
                    app.results.control.analysis.ddSignal = uidropdown(app.results.control.pAnalysis);
                    app.results.control.analysis.ddSignal.Position = [5 115 95 25];
                    app.results.control.analysis.ddSignal.Items = data.results.static.signal;
                    
                    app.results.control.analysis.lbAnalysisType = uilistbox(app.results.control.pAnalysis);
                    app.results.control.analysis.lbAnalysisType.Position = [5 35 95 75];
                    app.results.control.analysis.lbAnalysisType.Items = data.results.static.analysis;
                    app.results.control.analysis.lbAnalysisType.ValueChangedFcn = @F_ResultsControlAnalysisAnalysisType;
                    
                    app.results.control.analysis.cbDeleteMeanValue = uicheckbox(app.results.control.pAnalysis);
                    app.results.control.analysis.cbDeleteMeanValue.Position = [105 116 100 25];
                    app.results.control.analysis.cbDeleteMeanValue.Text = 'Delete Mean';
                    app.results.control.analysis.cbDeleteMeanValue.FontColor = data.interface.fontColor;
                    
                    app.results.control.analysis.pParameter = uipanel(app.results.control.pAnalysis);
                    app.results.control.analysis.pParameter.Position = [100 30 100 90];
                    app.results.control.analysis.pParameter.BorderType = 'none';
                    app.results.control.analysis.pParameter.BackgroundColor = data.interface.background.colorTwo;

                            app.results.control.analysis.parameter.lbWindow = uilistbox(app.results.control.analysis.pParameter);
                            app.results.control.analysis.parameter.lbWindow.Position = [5 5 85 55];
                            app.results.control.analysis.parameter.lbWindow.Items = data.results.static.window;

                            app.results.control.analysis.parameter.ddOverlap = uidropdown(app.results.control.analysis.pParameter);
                            app.results.control.analysis.parameter.ddOverlap.Position = [5 65 85 22];
                            app.results.control.analysis.parameter.ddOverlap.Items = data.results.static.overlap;
                            
                    ManageChildOfGroup(app.results.control.analysis.pParameter, 'off');
                            
                    app.results.control.analysis.btAnalyze = uibutton(app.results.control.pAnalysis);
                    app.results.control.analysis.btAnalyze.Position = [50 5 100 25];
                    app.results.control.analysis.btAnalyze.Text = 'Analyze';
                    app.results.control.analysis.btAnalyze.FontWeight = 'bold';
                    app.results.control.analysis.btAnalyze.ButtonPushedFcn = @F_ResultsControlAnalysisAnalyze;

            app.results.control.pSaveData= uipanel(app.results.pControl);
            app.results.control.pSaveData.Title = 'Save data:';
            app.results.control.pSaveData.Position = [205 5 110 165];
            app.results.control.pSaveData.BackgroundColor = data.interface.background.colorTwo;
            app.results.control.pSaveData.ForegroundColor = data.interface.fontColor;
            app.results.control.pSaveData.FontWeight = 'bold';

                    app.results.control.saveData.ddSource = uidropdown(app.results.control.pSaveData);
                    app.results.control.saveData.ddSource.Items = {'Source'};
                    app.results.control.saveData.ddSource.Position = [5 115 100 25];

                    app.results.control.saveData.efFileName = uieditfield(app.results.control.pSaveData, 'text');
                    app.results.control.saveData.efFileName.Position = [5 85 75 25];
                    app.results.control.saveData.efFileName.HorizontalAlignment = 'right';
                    app.results.control.saveData.efFileName.Value = 'Name';
                                             
                    app.results.control.saveData.lblFileNameFormat = uilabel(app.results.control.pSaveData);
                    app.results.control.saveData.lblFileNameFormat.HorizontalAlignment = 'left';
                    app.results.control.saveData.lblFileNameFormat.Text = '.mat';
                    app.results.control.saveData.lblFileNameFormat.Position = [79 85 30 25];
                    app.results.control.saveData.lblFileNameFormat.FontColor = data.interface.fontColor;
                                        
                    app.results.control.saveData.btDirectory = uibutton(app.results.control.pSaveData, 'push');
                    app.results.control.saveData.btDirectory.Position = [5 45 100 30];
                    app.results.control.saveData.btDirectory.Text = 'Get Directory';
                    app.results.control.saveData.btDirectory.IconAlignment = 'right';
                    app.results.control.saveData.btDirectory.ButtonPushedFcn = @F_ResultsControlSaveDataGetDirectory;
                    
                    app.results.control.saveData.btSave = uibutton(app.results.control.pSaveData, 'push');
                    app.results.control.saveData.btSave.Position = [5 10 100 30];
                    app.results.control.saveData.btSave.Text = 'Save data';
                    app.results.control.saveData.btSave.FontWeight = 'bold';
                    app.results.control.saveData.btSave.ButtonPushedFcn = @F_ResultsControlSaveDataSave;

%% Set visible All
 app.figMainApp.Visible = 'on';
 
%% GUI Functions - Layout and Design (not Callbacks)
function [] = MaximizedWindow(app) %#ok<DEFNU>
    state = get(app.figMainApp, 'WindowState');
    if ~strcmpi(state,'maximized')
        app.figMainApp.WindowState = 'maximized';
    end
end

function [] = SetBackgroundIm (app,image)
        %  set background and layout form
    app.imMainIm = uiimage(app.grMainGrid);
    app.imMainIm.Layout.Row = [1 length(app.grMainGrid.RowHeight)];
    app.imMainIm.Layout.Column = [1 length(app.grMainGrid.ColumnWidth)];
        % load image 
    im = imread(image);
        % set source of image
    app.imMainIm.ImageSource = im;
    app.imMainIm.ScaleMethod = 'fill';
end

function [] = CreateTabStructure(tbNames, Color)
    global app 
        %
    for i = 1 : size(tbNames, 2)
            % create tab with define names 
        app.mainTabGroup.tbMain(i) = uitab(app.tbgMainTabGroup, 'Title', tbNames(i));
        app.mainTabGroup.tbMain(i).BackgroundColor = Color;
            % create uniform grid for all tabs
        app.mainTabGroup.grTabGrid(i) = uigridlayout(app.mainTabGroup.tbMain(i));
        app.mainTabGroup.grTabGrid(i).RowHeight = {'1x',30};
        app.mainTabGroup.grTabGrid(i).ColumnWidth = {100,'1x',100};
        app.mainTabGroup.grTabGrid(i).BackgroundColor = Color;
            % Back button in every tab
        app.mainTabGroup.btBack = uibutton(app.mainTabGroup.grTabGrid(i), 'text','Back');
        app.mainTabGroup.btBack.ButtonPushedFcn = {@F_MainTabGroupbtBack, false, tbNames}; 
        app.mainTabGroup.btBack.Layout.Column = 1; 
        app.mainTabGroup.btBack.Layout.Row = size(app.mainTabGroup.grTabGrid(i).RowHeight, 2);
            % Next buuton in every tab except last
        if i < size(tbNames,2)
            app.mainTabGroup.btNext  = uibutton(app.mainTabGroup.grTabGrid(i),'text','Next');
            app.mainTabGroup.btNext .ButtonPushedFcn = {@F_MainTabGroupbtNext, true, tbNames};
            app.mainTabGroup.btNext .Layout.Column =  size(app.mainTabGroup.grTabGrid(i).ColumnWidth, 2); 
            app.mainTabGroup.btNext .Layout.Row =  size(app.mainTabGroup.grTabGrid(i).RowHeight, 2);
        end
    end
end       

%% Callback Functions
function [] = F_figMainAppClose(~,~,fig)
        % click to end application (cross)
    CloseFigure(fig);
end

function [] = F_IntrobtNext(src,~)
    global app
    data = guidata(src); 
        % assign image to new variable
    data.preprocess.image.original = data.input.image.original;
    data.preprocess.image.originalConverted = ConvertDataToImageAndEqualize(data.input.image.original);
        % show image in axes
    DisplayPreprocessImage(data.preprocess.image.originalConverted);
        % need to turn off visibilty -> if not , buttons appears in tabgroup
        % Solution -> ask someone - temp solution
    set(app.intro.btgMenu, 'Visible' ,'Off');
    set(app.intro.btgVideo, 'Visible', 'Off');
    set(app.intro.btgFrames, 'Visible' ,'Off');
    set(app.intro.btgSignals , 'Visible' ,'Off');
    set(app.intro.btgInfo , 'Visible' ,'Off');
    set(app.intro.btNext, 'Visible' ,'Off');
        % turn visibility on (tabgroup)
    set(app.tbgMainTabGroup, 'Visible','On');  
        % Assign value
    guidata(src, data);
end
    
function [] = F_MainTabGroupbtBack(~, ~, type, tbNames)
        % Callbacks for button next in tab Group
    TabNextBack(type, tbNames);
end

function [] = F_MainTabGroupbtNext(~, ~, type, tbNames)
        % Callbacks for button Back in tab Group
    TabNextBack(type, tbNames);
end

%% Intro Callback Functions 
%%%%%%%%%% Video Menu %%%%%%%%%%%%%%
function [] = F_IntroMenubtVideo(~,~)
    OpenMenuOrClickCancel('Menu','Video');
end

function [] = F_IntroVideobtLoad(src,~)
    global app
    data = guidata(src);
        % Get selected video format 
    data.input.video.format = testRadioButtonClicked(app.intro.video.rbtFormat);
        % find path and name of video
    [file,path] = uigetfile(['*' data.input.video.format]);
    if ~isequal(file,0) 
        set(app.intro.menu.btFrames, 'Icon', '');
        set(app.intro.btgVideo, 'Visible', 'off');
        set(app.intro.btgMenu, 'Visible', 'on');
            % Cursor loading on
        LoadingCursor(true);
            % Create input data 
        data.input.video.object = VideoReader(strcat(path,file));
        data.input.image.original = readFrame(data.input.video.object);
            % Cursor loadinf off
        LoadingCursor(false);
            % Add tick to video button 
        set(app.intro.menu.btVideo, 'Icon',data.interface.image.tick);
        set(app.intro.menu.btVideo, 'IconAlignment', 'right');
        set(app.intro.btNext, 'Visible', 'on');
            % change logic values 
        data.logic.intro.videoLoaded = true;
        data.logic.intro.framesLoaded = false;
    else
        data.logic.intro.videoLoaded = false;
        set(app.intro.menu.btVideo, 'Icon', '');
    end
    guidata(src,data);
end

function [] = F_IntroVideobtCancel(~, ~)
    OpenMenuOrClickCancel('Cancel', 'Video');
end

%%%%%%%%%% Frames Menu %%%%%%%%%%%%%%%%%%%%%%%
function [] = F_IntroMenubtFrames(~,~) 
    OpenMenuOrClickCancel('Menu','Frames');
end

function [] = F_IntroFramesbtgFramesFormat(~, ~, format)
        % test selected format - Raw - need data type , Fs and resolution
        % bmp file - need only Fs 
        % when bmp selected -> data type and resulution input disabled
    global app
        % Raw  format
    if format(1).Value 
        ManageChildOfGroup(app.intro.frames.btgFramesRes ,'on');
        % Mat or Bmp
    else 
        ManageChildOfGroup(app.intro.frames.btgFramesRes ,'off');
    end 
end

function [] = F_IntroFramesbtLoad(src,~)
    global app
    data = guidata(src);
        % clear all previous data stored in frames
    data.input.frames = [];
        % assign input values to variables, used later in script
    data.input.frames.format = testRadioButtonClicked(app.intro.frames.format.rbtFormat);
    [data.input.frames.step, step] = deal(app.intro.frames.numOfFrames.efStep.Value);
    data.input.frames.frameRate = floor(app.intro.frames.framesRate.spnRate.Value/data.input.frames.step);
    [data.input.frames.framesNumber, framesNumber] = deal(app.intro.frames.numOfFrames.efNumber.Value);
        % Data neede only in raw format , other way redundant 
    data.input.frames.dataType = app.intro.frames.ddDataType.Value;
    data.input.frames.resolution.width = app.intro.frames.framesRes.efWidth.Value;
    data.input.frames.resolution.height = app.intro.frames.framesRes.efHeight.Value;
        % Get file location
    [file,path] = uigetfile(['D:\VideosFlirMatlab\FLIR\Rec_63_12bit_Ruka\*' data.input.frames.format]);
        % Test if path folder was selected
    if ~isequal(file,0)
            % Assign file and path to variables
        data.input.frames.file = file;
        data.input.frames.path = path;   
            % Delete icon on video
        set(app.intro.menu.btVideo, 'Icon', '');
        set(app.intro.btgFrames, 'Visible', 'off');
        set(app.intro.btgMenu, 'Visible', 'on');
            % Cursor loading visible
        LoadingCursor(true);
            % Load first frame of data
        data.input.image.original  = ReadCurrentFrame(path, file, data.input.frames.format,...
            data.input.frames.dataType, data.input.frames.resolution);
            % Cursor loading invisible 
        LoadingCursor(false);
            % Add Icon to Frames button 
        set(app.intro.menu.btFrames, 'Icon', data.interface.image.tick);
        set(app.intro.menu.btFrames, 'IconAlignment', 'right');
        set(app.intro.btNext, 'Visible', 'on');
            % Change logic values 
        data.logic.intro.videoLoaded = false;
        data.logic.intro.framesLoaded = true;
            %
             % get number of frames in Folder with defined data type
        numberOfFramesInFolder=dir([path '/*' data.input.frames.format]);
        numberOfFramesInFolder = numel(numberOfFramesInFolder);
            % set number 
        if framesNumber*step>numberOfFramesInFolder
            warndlg('Quantty of selected frames is bigger than real quantity. Quantity will be adapted.',...
                'Warning');
            [data.input.frames.framesNumber, app.intro.frames.numOfFrames.efNumber.Value] = deal(floor(numberOfFramesInFolder/step));
        end
    else
        set(app.intro.menu.btFrames, 'Icon', '');
    end
        % create time vector of signals with defined step and number of loaded frames
    data.input.frames.timeVector = 0:1/data.input.frames.frameRate:...
        ((data.input.frames.framesNumber / (data.input.frames.frameRate*data.input.frames.step))...
        -1/data.input.frames.frameRate);
        % save data
    guidata(src,data);
end

function [] = F_IntroFramesbtCancel(~,~)
    OpenMenuOrClickCancel('Cancel', 'Frames');
end

%%%%%%%%%%%%%%% Signals Menu %%%%%%%%%%%%%%%%%%%%%
function [] = F_IntroMenubtSignals(~,~) 
    OpenMenuOrClickCancel('Menu','Signals');
end

function[] = F_IntroSignalsSourceECG(src,~)
    global app
    if src.Value
        ManageChildOfGroup(app.intro.signals.btgECG, 'On');
    else
        ManageChildOfGroup(app.intro.signals.btgECG, 'Off');
    end
end

function[] = F_IntroSignalsSourcePPG(src,~)
    global app
    if src.Value
        ManageChildOfGroup(app.intro.signals.btgPPG, 'On');
    else
        ManageChildOfGroup(app.intro.signals.btgPPG, 'Off');
    end
end

function[] = F_IntroSignalsSourceRR(src,~)
    global app
    if src.Value
        ManageChildOfGroup(app.intro.signals.btgRR, 'On');
    else
        ManageChildOfGroup(app.intro.signals.btgRR, 'Off');
    end
end

function [] = F_IntroSignalsbtLoad(src,~)
    global app
    data = guidata(src);
        % Get logical value of input signals (true -> signal loaded)
    logECG = app.intro.signals.source.cbECG.Value;
    data.logic.intro.signals.ECG = logECG;
        %
    logPPG = app.intro.signals.source.cbPPG.Value;
    data.logic.intro.signals.PPG = logPPG;
        %
    logRR = app.intro.signals.source.cbRR.Value;
    data.logic.intro.signals.RR = logRR;
        % Test if cb was marked
    if logECG||logPPG||logRR    
            %
        [file,path] = uigetfile('D:\VideosFlirMatlab\FLIR\Rec_63_12bit_Ruka\ *.mat');
        if ~isequal(file,0)
            LoadingCursor(true);
                % load data 
            temp = load([path,file]);
        
                % Assign ECG values
            if logECG
                chECG = app.intro.signals.ECG.spnChannel.Value;
                [data.input.signals.ECG.samplingFrequency, ECGfvz] = deal(app.intro.signals.ECG.efSamplingFrequency.Value);
                data.input.signals.ECG.unit = temp.units(chECG, :);
                data.input.signals.ECG.signal = transpose(temp.data(:, chECG));
                data.input.signals.ECG.timeVector = 0: 1/ECGfvz: length(data.input.signals.ECG.signal)/ECGfvz-1/ECGfvz;
            end
                % Assign PPG values
            if logPPG
                chPPG = app.intro.signals.PPG.spnChannel.Value;
                [data.input.signals.PPG.samplingFrequency, PPGfvz] = deal(app.intro.signals.PPG.efSamplingFrequency.Value);
                data.input.signals.PPG.unit = temp.units(chPPG, :);
                data.input.signals.PPG.signal = transpose(temp.data(:, chPPG));
                data.input.signals.PPG.timeVector = 0: 1/PPGfvz: length(data.input.signals.PPG.signal)/PPGfvz-1/PPGfvz;
            end
                % Assign RR values
            if logRR
                chRR = app.intro.signals.RR.spnChannel.Value;
                [data.input.signals.RR.samplingFrequency, RRfvz] = deal(app.intro.signals.RR.efSamplingFrequency.Value);
                data.input.signals.RR.unit = temp.units(chRR, :);
                data.input.signals.RR.signal = transpose(temp.data(:, chRR));
                data.input.signals.RR.timeVector = 0: 1/RRfvz: length(data.input.signals.RR.signal)/RRfvz-1/RRfvz;
            end
                % Add tick to button
            set(app.intro.menu.btSignals, 'Icon',data.interface.image.tick);
            set(app.intro.menu.btSignals, 'IconAlignment', 'right');
            data.logic.intro.signalsLoaded = true;
            set(app.intro.btgSignals, 'Visible', 'off');
            set(app.intro.btgMenu, 'Visible', 'on');
            LoadingCursor(false);
        else
            set(app.intro.menu.btSignals, 'Icon','');
            data.logic.intro.signalsLoaded = false;
        end
    end
        % Save data
    guidata(src,data);
end

function [] = F_IntroSignalsbtCancel(~,~)
    OpenMenuOrClickCancel('Cancel', 'Signals');
end

%%%%%%%%%% Informations and Exit Menu %%%%%%%%%%%%%%%%%%%%
function [] = F_IntroMenubtInfo(~,~)
    OpenMenuOrClickCancel('Menu','Inf');
end

function [] = F_IntroInfobtCancel (~, ~)
    OpenMenuOrClickCancel('Cancel','Inf');
end

function [] = F_IntroMenubtExit(~,~,fig)
    CloseFigure(fig);
end

%% Processing Callback Functions 
%%%%%%%%%%  Options %%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = F_PreprocessControlOptionscbMarkROI(src,~)
    global app
    if src.Value
        app.preprocess.control.options.cbTrackROI.Enable = true;
        app.preprocess.control.options.cbSpatialFilter.Enable = true;
    else
            % manage tracking check box
        app.preprocess.control.options.cbTrackROI.Enable = false;
        app.preprocess.control.options.cbTrackROI.Value = false;
            % manage spatial filter check box
        app.preprocess.control.options.cbSpatialFilter.Enable = false;
        app.preprocess.control.options.cbSpatialFilter.Value = false;
    end
end

function [] = F_PreprocessControlOptionsbtConfirm(src,~)
    global app
    data = guidata(src);
    opts = data.logic.preprocess.options;
        % get logical values of check boxes
    opts.markROI = app.preprocess.control.options.cbMarkROI.Value;
    opts.trackROI = app.preprocess.control.options.cbTrackROI.Value;
    opts.spatialFilter = app.preprocess.control.options.cbSpatialFilter.Value;
    opts.selectSignals = app.preprocess.control.options.cbSelectSignals.Value;
        % Enable/disable panel ROI
    if opts.markROI
        ManageChildOfGroup(app.preprocess.control.pROI, 'on');
            % create new image file 
        data.preprocess.image.markROI = data.preprocess.image.originalConverted;
    else
        ManageChildOfGroup(app.preprocess.control.pROI, 'off');
    end
        % Enable/disable panel Tracker
    if opts.trackROI
        ManageChildOfGroup(app.preprocess.control.pTracker, 'on');
            % create new image file
        data.preprocess.image.tracker = data.preprocess.image.originalConverted;
    else
        ManageChildOfGroup(app.preprocess.control.pTracker, 'off');
    end
        % Enable/disable panel Spatial Filter
    if opts.spatialFilter
        ManageChildOfGroup(app.preprocess.control.pSpatialFilter, 'on');
            % create new image file
        data.preprocess.image.spatialFilter = data.preprocess.image.originalConverted;
    else
        ManageChildOfGroup(app.preprocess.control.pSpatialFilter, 'off');
    end
        % Enable/disable panel Select Signals
    if opts.selectSignals
        ManageChildOfGroup(app.preprocess.control.pSelectSignals, 'on');
            % create new image file
        data.preprocess.image.selectSignals = data.preprocess.image.originalConverted;
    else
        ManageChildOfGroup(app.preprocess.control.pSelectSignals, 'off');
    end
        % Enable/disable panel Process
    if opts.markROI || opts.trackROI || opts.spatialFilter || opts.selectSignals 
        ManageChildOfGroup(app.preprocess.control.pProcess, 'on');
    else
        ManageChildOfGroup(app.preprocess.control.pProcess, 'off');
    end
        % assign new values of check boxes to variables
    data.logic.preprocess.options = opts;
    guidata(src, data);
end

%%%%%%%%%%  Image Rotation %%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = F_PreprocessControlRotationbtDisplayImage(src,~)
    data = guidata(src);
    DisplayPreprocessImage(data.preprocess.image.originalConverted);
end

function [] = F_PreprocessControlRotationLeft(src,~)
    data = guidata(src);
    data.preprocess.image.originalConverted = imrotate(data.preprocess.image.originalConverted, 90);
    DisplayPreprocessImage(data.preprocess.image.originalConverted);
    guidata(src, data);
end

function [] = F_PreprocessControlRotationRight(src, ~)
    data = guidata(src);
    data.preprocess.image.originalConverted = imrotate(data.preprocess.image.originalConverted, -90);
    DisplayPreprocessImage(data.preprocess.image.originalConverted);
    guidata(src, data);
end

%%%%%%%%%%  Region of interest %%%%%%%%%%%%%%%%%%%%%%%%
function [] = F_PreprocessControlROIbtDisplayImage (src,~)
    data = guidata(src);
    DisplayPreprocessImage(data.preprocess.image.markROI);
end

function [] = F_PreprocessControlROIbtMarkROI (src,~)
    global app
    data = guidata(src);
        % 
    if data.logic.preprocess.ROI.marked || data.logic.preprocess.ROI.confirmed
        warndlg('Region of interest has been marked. If you want mark ROI, please click Restore.', 'Warning')
    else
        drawInfo = drawrectangle(app.preprocess.axAxesImage,...
            'LineWidth',2,...
             'label', 'ROI',...
             'Color','black');
            % save data in variable 
        data.preprocess.ROI.drawInfo = drawInfo;
            % set logical values 
        data.logic.preprocess.ROI.marked = true;
    end
    guidata(src,data);
end

function [] = F_PreprocessControlROIbtRestore (src,~)
    global app
    data = guidata(src);
        % add image from original 
    data.preprocess.image.markROI = data.preprocess.image.originalConverted; 
    DisplayPreprocessImage(data.preprocess.image.markROI);
        % delete confim icon
    app.preprocess.control.ROI.btConfirm.Icon = '';
        % set logic values
    data.logic.preprocess.ROI.marked = false;
    data.logic.preprocess.ROI.confirmed = false;
    guidata(src, data)
end

function [] = F_PreprocessControlROIbtConfirm (src, ~)
    data = guidata(src);
    if data.logic.preprocess.ROI.marked && (~data.logic.preprocess.ROI.confirmed)
        data.preprocess.image.markROI = insertShape(data.preprocess.image.markROI,...
            'Rectangle',round(data.preprocess.ROI.drawInfo.Position),...
            'Color','black',...
            'LineWidth', 4 );
            %
        data.preprocess.ROI.drawInfo = GetMargins(data.preprocess.ROI.drawInfo.Position);
        DisplayPreprocessImage(data.preprocess.image.markROI);
            %
        data.logic.preprocess.ROI.confirmed = true;
            % assign images to Spatial filter and Tracker
        [data.preprocess.image.spatialFilter, data.preprocess.image.tracker, data.preprocess.image.selectSignals] = deal(...
            data.preprocess.image.markROI);
        %
    elseif ~data.logic.preprocess.ROI.marked
        warndlg('Region of interest has not been marked yet.', 'Warning');
    else
        warndlg('Region of interest has already been marked', 'Warning');
    end
        %
    guidata(src, data);
    src.Icon = data.interface.image.tick; 
end

%%%%%%%%%%  Tracker  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function []  = F_PreprocessControlTrackerDisplayImage (src,~)
    data = guidata(src);
    DisplayPreprocessImage(data.preprocess.image.tracker);
end

function []  = F_PreprocessControlTrackerApply (src,~)
    global app;
    data = guidata(src);
        %
    [data.preprocess.tracker.position, data.preprocess.tracker.positionNew] = deal(data.preprocess.ROI.drawInfo.position);
    data.preprocess.tracker.rectPointsOfROI = bbox2points(data.preprocess.tracker.position(1, :));
        %
    [data.preprocess.tracker.minQuality, minQuality] = deal(app.preprocess.control.tracker.spnMinQuality.Value);
    [data.preprocess.tracker.filterSize, filterSize] = deal(app.preprocess.control.tracker.spnFilterSize.Value);
        %
    data.preprocess.tracker.trackedPoints = detectMinEigenFeatures(data.preprocess.image.originalConverted, ...
        'ROI', data.preprocess.tracker.position , 'MinQuality', minQuality, 'FilterSize', filterSize);
        %
    data.preprocess.image.tracker = insertMarker(data.preprocess.image.markROI,...
        data.preprocess.tracker.trackedPoints, 'size', 10);
        % 
    DisplayPreprocessImage(data.preprocess.image.tracker);
        %
    data.preprocess.tracker.pointTracker = vision.PointTracker('NumPyramidLevels', 3 ,'MaxBidirectionalError', 2,...
        'BlockSize', [31 31], 'MaxIterations', 30);
      % Assign values of points locations and initialize tracker system 
    data.preprocess.tracker.trackedPointsLocation = data.preprocess.tracker.trackedPoints.Location;
    initialize(data.preprocess.tracker.pointTracker, data.preprocess.tracker.trackedPointsLocation,...
        data.preprocess.image.originalConverted);
        % Assign old points
    data.preprocess.tracker.trackedPointsLocationOld = data.preprocess.tracker.trackedPointsLocation;
        % set logic value 
    data.logic.preprocess.tracker.applied = true;
        % save all data
    guidata(src, data);
end

function []  = F_PreprocessControlTrackerConfirm (src,~)
    data = guidata(src);
        %
    if data.logic.preprocess.tracker.applied
        data.logic.preprocess.tracker.confirmed = true;
        src.Icon = data.interface.image.tick;
    else
        warndlg('Tracker has not been applied', 'Warning');
    end
        %
    guidata(src, data);
end

function []  = F_PreprocessControlTrackerRestore (src,~)
    global app
    data = guidata(src);
        %
    data.preprocess.image.tracker = data.preprocess.image.markROI;
    DisplayPreprocessImage(data.preprocess.image.tracker);
        %
    data.logic.preprocess.tracker.applied = false;
    data.logic.preprocess.tracker.confirmed = false;
    app.preprocess.control.tracker.btConfirm.Icon = '';
        %
    guidata(src, data);
end

%%%%%%%%%%  Spatial filter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = F_PreprocessControlSpatialFilterbtDisplayImage(src,~)
    data = guidata(src);
    DisplayPreprocessImage(data.preprocess.image.spatialFilter);
end

function [] = F_PreprocessControlSpatialFilterbtApply(src,~)
    global app
    data = guidata(src);
        % ROI must be selected
    if data.logic.preprocess.ROI.confirmed 
        [data.preprocess.spatialFilter.filterType, filterType] = deal(app.preprocess.control.spatialFilter.ddFilterType.Value);
        [data.preprocess.spatialFilter.kernelSize, kernelSize ]= deal( find(strcmpi(data.preprocess.static.kernelSize,...
            app.preprocess.control.spatialFilter.ddKernelSize.Value)));
            % assign image to var image and cut 
        image = data.preprocess.image.markROI;
        pos = data.preprocess.ROI.drawInfo;
        imPart = image(pos.Top:pos.Bottom,pos.Left:pos.Right);
            %
        [data.preprocess.spatialFilter.spatialFilter, spatialFilter] = deal( fspecial(filterType, (kernelSize*2)+1 ));
            %
        imPart = imfilter(imPart, spatialFilter, 'symmetric');
            %
        image(pos.Top:pos.Bottom,pos.Left:pos.Right) = imPart;
            %
        image = insertShape(image,...
                'Rectangle',round(data.preprocess.ROI.drawInfo.position),...
                'Color','black',...
                'LineWidth', 4 );
            %
        data.preprocess.image.spatialFilter = image;
        DisplayPreprocessImage(data.preprocess.image.spatialFilter);
            %
        data.logic.preprocess.spatialFilter.applied = true;
    else
        warndlg('Region of interest was not selected', 'Warning');
    end
        %
    guidata(src, data);    
end

function [] = F_PreprocessControlSpatialFilterbtConfirm(src,~)
    data = guidata(src);
    if data.logic.preprocess.spatialFilter.applied
        data.logic.preprocess.spatialFilter.confirmed  = true;
        src.Icon = data.interface.image.tick;
    end
    guidata(src, data);
end

function [] = F_PreprocessControlSpatialFilterbtRestore(src,~)
    global app
    data = guidata(src);
        % set default values of dropdowns 
    app.preprocess.control.spatialFilter.ddFilterType.Value = data.preprocess.static.filterType(1);
    app.preprocess.control.spatialFilter.ddKernelSize.Value = data.preprocess.static.kernelSize(1);
        % assign original ROI image to spatial filter image and display it 
    data.preprocess.image.spatialFilter = data.preprocess.image.originalConverted;    
    DisplayPreprocessImage(data.preprocess.image.spatialFilter);
        % set logical values to false 
    data.logic.preprocess.spatialFilter.confirmed  = false;
    data.logic.preprocess.spatialFilter.applied = false;
        % delete tick icon from Confirm button
    app.preprocess.control.spatialFilter.btConfirm.Icon = '';
        % save all data
    guidata(src, data);
end

%%%%%%%%%%  Select Signals  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = F_PreprocessControlSelectSignalsSelectcbAverage(src,~)
    data = guidata(src);
    data.logic.preprocess.selectSignals.average = src.Value;
    guidata(src, data);
end

function [] = F_PreprocessControlSelectSignalsDisplayImage (src,~)
    data = guidata(src);
    DisplayPreprocessImage(data.preprocess.image.selectSignals);
end

function [] = F_PreprocessControlSelectSignalsSelectSignals (src,~)
    global app
    data = guidata(src);
        % assign selected Values
    [data.preprocess.selectSignals.numberOfSignals,  numberOfSignals]  = deal(...
        app.preprocess.control.selectSignals.spnNumOfSignals.Value);
    data.logic.preprocess.selectSignals.average = app.preprocess.control.selectSignals.cbAverage.Value;
    data.preprocess.selectSignals.average = app.preprocess.control.selectSignals.spnAverage.Value;
        % Create marker (size)
    markerSize =round(length(data.preprocess.image.selectSignals)/190);
    markerWidth=round(markerSize/2);
        % empty positions of SelectSignals
    data.preprocess.selectSignals.position = [];
    data.preprocess.selectSignals.positionROI = [];
        % start 
     if ~data.logic.preprocess.selectSignals.selected
            % loop for selecting signals
        for i = 1:numberOfSignals
                % get position of pixels
            [data.preprocess.selectSignals.position.y(i), data.preprocess.selectSignals.position.x(i)] = ginputuiax(...
                app.preprocess.axAxesImage);
                % insert shape to this position
            data.preprocess.image.selectSignals = insertShape( data.preprocess.image.selectSignals,'circle',...
                [data.preprocess.selectSignals.position.y(i) data.preprocess.selectSignals.position.x(i) markerSize],...
                 'linewidth',markerWidth, 'color', data.interface.colors(i));   
                % display inserted shape
            DisplayPreprocessImage(data.preprocess.image.selectSignals);
        end
        % set logic value -> confirmed;
        data.logic.preprocess.selectSignals.selected = true;  
     else 
         warndlg('Signals has been selected', 'Warning');
     end
        % selected signals position in ROI
    if data.logic.preprocess.ROI.confirmed
         data.preprocess.selectSignals.positionROI.y = data.preprocess.selectSignals.position.y - data.preprocess.ROI.drawInfo.Left;
         data.preprocess.selectSignals.positionROI.x = data.preprocess.selectSignals.position.x - data.preprocess.ROI.drawInfo.Top;
    end
     guidata(src, data);
end

function [] = F_PreprocessControlSelectSignalsRestore (src,~)
%    global app
    data = guidata(src);
        % set default values 
%     app.preprocess.control.selectSignals.spnNumOfSignals.Value = 1;
%     app.preprocess.control.selectSignals.spnAverage.Value = 3;
%     app.preprocess.control.selectSignals.cbAverage.Value = false;
        % set logic value
    data.logic.preprocess.selectSignals.selected = false;
        % if ROI marked -> assign marked image to select signals image
        % otherwise assign orginal image
    if data.logic.preprocess.ROI.confirmed
        data.preprocess.image.selectSignals = data.preprocess.image.markROI;
    else
        data.preprocess.image.selectSignals = data.preprocess.image.originalConverted;
    end
        %
    data.preprocess.selectSignals.position = [];
    data.preprocess.selectSignals.positionROI = [];
        % display assigned image
    DisplayPreprocessImage(data.preprocess.image.selectSignals);
    guidata(src, data);
end

%%%%%%%%%%%%%% Process %%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = F_PreprocessControlProcesscbSaveROIFrames(src,~)
    data = guidata(src);
    data.logic.preprocess.process.saveAsMatFile = src.Value;
    guidata(src, data);
end

function [] = F_PreprocessControlProcessStartProcess(src,~)
    global app
    data = guidata(src);
        % process confirmation 
    answer = questdlg('Are you sure you want to process data?', ...
	'Confirmation', ...
	'Yes','No','Cancel', 'Cancel');
        % 
    if strcmpi(answer, 'Yes')
        if data.logic.intro.videoLoaded
                % nefunkcne zatial
            PreprocessVideoData();
        elseif data.logic.intro.framesLoaded
            signals = PreprocessFramesData(data.input.frames, data.preprocess, data.logic, app.preprocess.control.process.ddSaveROIFramesFormat.Value);
        else
            warndlg('Input data has not been selected' ,'Warning');
        end
            % Assign important data to results if signal was selected
        if data.logic.preprocess.selectSignals.selected
                % num ->  target position (find target postion between output)
            num = find(strcmpi(app.preprocess.control.process.ddSaveSignals.Value, data.preprocess.static.results), true);
                % empty structure before assignation
            data.output(num) = EmptyOutputStructure(data.output(num));
                % assignation to structure
            data.output(num) = CreateOutputStructure(data.logic, signals, data.input, data.preprocess,...
                data.preprocess.image.selectSignals, data.interface.colors);
                % if result name does not exist in sourceItems -> add name to
                % source Items in results section (for load signals and save data)
            if ~any(strcmpi(app.preprocess.control.process.ddSaveSignals.Value, app.results.control.sourceData.ddSource.Items))
                app.results.control.sourceData.ddSource.Items = [app.results.control.sourceData.ddSource.Items,...
                app.preprocess.control.process.ddSaveSignals.Value];
                    % add value to saveAs dropdown
                app.results.control.saveData.ddSource.Items = [app.results.control.saveData.ddSource.Items,...
                app.preprocess.control.process.ddSaveSignals.Value];     
            end
        end
        msgbox('Operation completed.');
    end
    guidata(src, data);
end

%% Results Callback Function
%%%%%%%%%%%% Source Data %%%%%%%%%%%%%%%%
function [] = F_ResultsControlSourceDataSource(src,~)
    global app
    data = guidata(src);
    if any(strcmpi(app.results.control.sourceData.ddSource.Value, data.preprocess.static.results))
            % find which result was choosen
        [data.results.num,  num] = deal(find(strcmpi(app.results.control.sourceData.ddSource.Value, data.preprocess.static.results), true));
            % assign to quantity value its first item 
        app.results.control.sourceData.ddQuantity.Value = app.results.control.sourceData.ddQuantity.Items(1);
            % set image source and display it 
        app.results.imResult.ImageSource = data.output(num).info.image;
            %
        if data.logic.intro.signalsLoaded
            test = false;
            app.results.control.sourceData.ddBIOPAC.Items = data.results.static.BIOPAC;
            if data.output(num).ECG.loaded
                app.results.control.sourceData.ddBIOPAC.Items = [app.results.control.sourceData.ddBIOPAC.Items, data.output(num).ECG.name];
                test = true;
            end 
            if data.output(num).PPG.loaded
                 app.results.control.sourceData.ddBIOPAC.Items = [app.results.control.sourceData.ddBIOPAC.Items,data.output(num).PPG.name];
                 test = true;
            end
            if data.output(num).RR.loaded
                app.results.control.sourceData.ddBIOPAC.Items = [app.results.control.sourceData.ddBIOPAC.Items,data.output(num).RR.name];
                test = true;
            end
            if test
                app.results.control.sourceData.ddBIOPAC.Enable = true;
            end
        end
            % mark achievable signals in Signals to display , other signals set to turn off 
        for i = 1: size(data.output(num).PPGI.signal, 1)            
            app.results.control.sourceData.signals.cb(i).Enable = true;
            app.results.control.sourceData.signals.cb(i).Value = true; 
            app.results.control.analysis.ddSignal.Items = [app.results.control.analysis.ddSignal.Items,...
                app.results.control.sourceData.signals.cb(i).Text];
        end   
        for i = size(data.output(num).PPGI.signal, 1)+1 : 8
            app.results.control.sourceData.signals.cb(i).Enable = false;
            app.results.control.sourceData.signals.cb(i).Value = false;
        end
            % enable other elements
        app.results.control.sourceData.btToolbar.Enable =  true;
        app.results.control.sourceData.btDisplay.Enable = true;
        app.results.control.sourceData.ddFilter.Enable = true;
            %
        data.logic.results.source = true;
        % if Source was not loaded 
    else
            % disable panel SignalsToDisplay and SaveDataAs
        ManageChildOfGroup(app.results.control.sourceData.pSignals, 'off');
        app.results.control.analysis.ddSignal.Items = {'Signal'};
        app.results.control.sourceData.btToolbar.Enable =  false;
        app.results.control.sourceData.btDisplay.Enable = false;
                % filter data
        app.results.control.sourceData.ddFilter.Enable = false;
        app.results.control.sourceData.ddFilter.Value = data.results.static.filter(1);
        data.logic.results.filter = false;
        data.logic.results.filterUsed = false;
            % disable BIOPAC and empty items 
        app.results.control.sourceData.ddBIOPAC.Enable = false;
        app.results.control.sourceData.ddBIOPAC.Items = data.results.static.BIOPAC;
            % unmarked signals checkboxes
        for i = 1:8
            app.results.control.sourceData.signals.cb(i).Value = false; 
        end
            % set quantity dropdow to its first item
        app.results.control.sourceData.ddQuantity.Value = app.results.control.sourceData.ddQuantity.Items(1);
            % empty image source 
        app.results.imResult.ImageSource = '';
            % logic value source - false 
        data.logic.results.source = false;
            % clear all axes 
        cla(app.results.axBIOPAC);
        cla(app.results.axPPGI);
    end
    guidata(src, data);
end

function [] = F_ResultsControlSourceDataQuantity(src,~)
    global app
    data = guidata (src);
    data.logic.results.dispAllSignals =  strcmpi(app.results.control.sourceData.ddQuantity.Value, app.results.control.sourceData.ddQuantity.Items(1));
    guidata(src, data);
end

function [] = F_ResultsControlSourceFilter(src, ~)
    global app
    data = guidata(src);
     x = true;
    switch src.Value
        case data.results.static.filter(2)
            data.results.sourceData.filter = LP_08_32_80(data.output(data.results.num).PPGI.samplingFrequency);
                % set data
            x = true;
        case data.results.static.filter(3)
            data.results.sourceData.filter = LP_1_2_80(data.output(data.results.num).PPGI.samplingFrequency);
        case data.results.static.filter(4)
            data.results.sourceData.filter = LP_4_6_80(data.output(data.results.num).PPGI.samplingFrequency);
        case data.results.static.filter(5)
            data.results.sourceData.filter = LP_6_8_80(data.output(data.results.num).PPGI.samplingFrequency);
        case data.results.static.filter(6)
            data.results.sourceData.filter = LP_8_10_80(data.output(data.results.num).PPGI.samplingFrequency);
        case data.results.static.filter(7)
            data.results.sourceData.filter = BP_06_1__8_84(data.output(data.results.num).PPGI.samplingFrequency);
        otherwise
            data.results.sourceData.filter = [];
            x = false;
    end
    [data.logic.results.filter, app.results.control.sourceData.btFilterInfo.Enable] = deal(x);
        % save all data
    guidata(src, data);
end

function [] = F_ResultsControlSourceDataFilterInfo(src, ~)
    data = guidata(src);
    freqz(data.results.sourceData.filter)
end

function [] = F_ResultsControlSourceDataDisplay (src, ~)
    global app
    data = guidata(src);
        % Loading cursor on
    LoadingCursor(true)
        % clear both axes
    cla(app.results.axPPGI);
        % number of output data to display  (output 3 -> num = 3 -> data.output(3).PPGI ...)
    num = data.results.num;
        % 
        % FILTER USAGE
        %
    logicFilterName = strcmpi(data.results.sourceData.filterName, app.results.control.sourceData.ddFilter.Value);
        %
    if data.logic.results.filter && ~logicFilterName
            % erase previous data
        data.output(num).PPGI.signalFilt = [];
        data.output(num).PPGI.timeVectorFilt  = [];
            % filter iterations 
        for i = 1:size(data.output(num).PPGI.signal, 1)  
            data.output(num).PPGI.signalFilt(i,:) = filter(data.results.sourceData.filter, data.output(num).PPGI.signal(i,:));
        end
            % get filter delay
        delay = mean(grpdelay(data.results.sourceData.filter))*2;
            % delete delay of filter in signals and time Vector
        data.output(num).PPGI.signalFilt(:,1:delay) = [ ];
        data.output(num).PPGI.timeVectorFilt = data.output(num).PPGI.timeVector(1:length(data.output(num).PPGI.timeVector)-delay);
            % manage variables 
        data.results.sourceData.filterName = app.results.control.sourceData.ddFilter.Value;
        data.logic.results.filterUsed = true;
    elseif ~data.logic.results.filter
        data.logic.results.filterUsed = false;
    end
      % SAVE DATA from filter 
    guidata(src, data);
        %
        % DISPLAY SIGNALS ITERATIONS
        %
    for i = 1:size(data.output(num).PPGI.signal, 1)
        hold(app.results.axPPGI, 'on' );
            % If filter was used -> display filtered signals
        if data.logic.results.filter
             if data.logic.results.dispAllSignals
                plot(app.results.axPPGI, data.output(num).PPGI.timeVectorFilt,data.output(num).PPGI.signalFilt(i,:),...
                    'Color', data.output(num).info.colors(i));
            else
                if app.results.control.sourceData.signals.cb(i).Value
                    plot(app.results.axPPGI, data.output(num).PPGI.timeVectorFilt,data.output(num).PPGI.signalFilt(i,:), ...
                        'Color', data.output(num).info.colors(i));
                end
             end
                % if filter was not used 
        else
            if data.logic.results.dispAllSignals
                plot(app.results.axPPGI, data.output(num).PPGI.timeVector,data.output(num).PPGI.signal(i,:),...
                    'Color', data.output(num).info.colors(i));
            else
                if app.results.control.sourceData.signals.cb(i).Value
                    plot(app.results.axPPGI, data.output(num).PPGI.timeVector,data.output(num).PPGI.signal(i,:), ...
                        'Color', data.output(num).info.colors(i));
                end
            end
        end
    end
        % Loading cursor off
    LoadingCursor(false);
end

function [] = F_ResultsControlSourceDataToolbar(src,~)
    global app
    if src.Value
        app.results.axBIOPAC.Toolbar.Visible = 'on';
        app.results.axPPGI.Toolbar.Visible = 'on';
    else
        app.results.axBIOPAC.Toolbar.Visible = 'off';
        app.results.axPPGI.Toolbar.Visible = 'off';
    end
end

function [] = F_ResultsControlSourceDataBIOPAC(src,~)
        global app
        data = guidata(src);
        num = data.results.num;
        %
        % BIOPAC SIGNALS DISPLAY
        %
    if ~(strcmpi(app.results.control.sourceData.ddBIOPAC.Value, data.results.static.BIOPAC))
            % enable synchronization button
        app.results.control.sourceData.btBIOPACSync.Enable = true;
        app.results.axBIOPAC.XLim = [0 inf];
            % get length and fvz of PPGI signal -> off
%         lenPPGI = size(data.output(num).PPGI.signal, 2);
%         PPGIfvz = data.output(num).PPGI.samplingFrequency;
            % switch sequention
        switch app.results.control.sourceData.ddBIOPAC.Value
                % ECG singnal
            case 'ECG'
%             len = round( (lenPPGI/PPGIfvz) * data.output(num).ECG.samplingFrequency );
%             EXAMPLE
%             plot(app.results.axBIOPAC, data.output(num).ECG.timeVector(1:len), data.output(num).ECG.signal(1:len), 'Color', 'black');
            plot(app.results.axBIOPAC, data.output(num).ECG.timeVector, data.output(num).ECG.signal, 'Color', 'black');
                % PPGG signal
            case 'PPG'
%             len = round( (lenPPGI/PPGIfvz) * data.output(num).PPG.samplingFrequency );
            plot(app.results.axBIOPAC, data.output(num).PPG.timeVector, data.output(num).PPG.signal, ...
                    'Color', 'black');
                % RR signal
            case 'RR'
%             len = round( (lenPPGI/PPGIfvz) * data.output(num).RR.samplingFrequency);
            plot(app.results.axBIOPAC, data.output(num).RR.timeVector, data.output(num).RR.signal, ...
                    'Color', 'black');
        end   
    else
        cla(app.results.axBIOPAC);
        app.results.control.sourceData.btBIOPACSync.Enable = false;
    end
end

function [] = F_ResultsControlSourceDataBIOPACSync(~, ~)
    global app
    app.results.axBIOPAC.XLim = app.results.axPPGI.XLim;
end

%%%%%%%%%%%% Analysis %%%%%%%%%%%%%%%%%%%
function [] = F_ResultsControlAnalysisAnalysisType(src,~)
    global app
    data = guidata(src);
    if strcmpi(src.Value, data.results.static.analysis(2)) || strcmpi(src.Value, data.results.static.analysis(3))
        ManageChildOfGroup(app.results.control.analysis.pParameter, 'on');
    else
        ManageChildOfGroup(app.results.control.analysis.pParameter, 'off');
    end
end

function [] = F_ResultsControlAnalysisAnalyze(src,~)
    global app
    data = guidata(src);
        % test if signal was selected
        if ~strcmpi(app.results.control.analysis.ddSignal.Value, 'Signal')
            num  =  data.results.num;
            AnalysisType = app.results.control.analysis.lbAnalysisType.Value;
            overlap =   app.results.control.analysis.parameter.ddOverlap.Value;
            windowName = app.results.control.analysis.parameter.lbWindow.Value;
                % finding signal position in variable
            for i = 1:size(data.output(num).PPGI.signal, 1)
                if strcmpi(app.results.control.analysis.ddSignal.Value, app.results.control.sourceData.signals.cb(i).Text)
                    break
                end
            end
                % choose if analyze filtered signal or non filtered
            if data.logic.results.filterUsed
                signal = data.output(num).PPGI.signalFilt(i,:);
            else
                signal = data.output(num).PPGI.signal(i,:);
            end
                % get sampling frequency of signal
            fvz = data.output(num).PPGI.samplingFrequency;
                % delete mean value 
            if app.results.control.analysis.cbDeleteMeanValue.Value
                [signal] = DeleteMeanValue(signal); 
            end
                % switch process
            switch AnalysisType
                case data.results.static.analysis(1)
                    CalculateSpectrum (signal, fvz, data.interface.colors(i));
                case data.results.static.analysis(2)
                    CalculateSpectrogram (signal, fvz, windowName, overlap, data.interface.colors(i));
                case data.results.static.analysis(3)
                    CalculatePeriodogram (signal, fvz, windowName, overlap);
                case data.results.static.analysis(4)
                    CalculateScalogram (signal, fvz, data.interface.colors(i));
            end
        else
            warndlg('Signal was not selected', 'Warning');
        end
    %----------------------------------------------------
    function [signal] = DeleteMeanValue(signal)
        meanValue = mean(signal);
        signal = signal - meanValue;
    end
    %---------------------------------------------------
end

%%%%%%%%%%%% Save Data %%%%%%%%%%%%%%%%%
function [] = F_ResultsControlSaveDataGetDirectory(src, ~)
    global app
    data = guidata(src);
    % select Directory to save data 
    folder = uigetdir();
    if ~isequal(folder,0)
        app.results.control.saveData.btDirectory.Icon = data.interface.image.tick;
        data.results.saveData.selectedDir = folder;
        data.logic.results.directorySelected = true;
    else
        data.results.saveData.selectedDir = ' ';
         set(app.results.control.saveData.btDirectory, 'Icon', '');
         data.logic.results.directorySelected = false;
    end
        % save data
    guidata(src, data);
end

function [] = F_ResultsControlSaveDataSave (src, ~)
    global app 
    data = guidata(src);
    if data.logic.results.directorySelected
            % Get Save Name and number of output
        sourceName = app.results.control.saveData.ddSource.Value;
        if ~strcmpi(sourceName, 'Source')
            saveName = app.results.control.saveData.efFileName.Value;
            num  =  deal(find(strcmpi(app.results.control.saveData.ddSource.Value, data.preprocess.static.results), true));
                % create save name
            saveString = [data.results.saveData.selectedDir  '\' saveName '.mat']; 
            saveData = data.output(num);
                %
            save(saveString,  '-struct' , 'saveData');
            msgbox('Data saved.');
        else
            warndlg('Source data was not selected', 'Warning');
        end
    else 
        warndlg('Target directory was not selected', 'Warning');
    end
end

 %% Support Functions 
function CloseFigure(fig)
        % Close Figure function -> Warn dialog if the user want to close application. 
        %   INPUT 
        % fig - figure object - which would be closed
        %
    Markion = uiconfirm(fig,'Do you want to close the PPGI app?',...
            'Confirmation');
    switch Markion
        case 'OK'
            delete(fig); clear; clc;  
        case 'Cancel'
            return
    end
end

function  [x] = CreateResultsStructureEmpty()
    x.PPGI = [];
    x.ECG = [];
    x.PPG = [];
    x.RR = [];
    x.info = [];
end

function [res] = EmptyOutputStructure(res)
 	res.PPGI = [];
    res.ECG = [];
    res.PPG = [];
    res.RR = [];
    res.info = [];
end

function [radioButtonSelected] = testRadioButtonClicked(radioButtons)
    % Function to know which radio buttons are clicked
    %   INPUT
    %
    for i = 1:size(radioButtons,2)
        if radioButtons(i).Value
            radioButtonSelected = radioButtons(i).Text;
        end
    end
end

function [dim] = GetMargins(Position)
    Position = round(Position);
    dim.position = Position;
    dim.Top =  Position(2);
    dim.Left = Position(1);
    dim.Right =   dim.Left + Position(3);
    dim.Bottom =  dim.Top + Position(4);
end

function [pos] = CreateMenuPosition(names)
    % INPUT
    % names - names of Created buttons
    %
    % define height
    height = 18;
    pos = zeros(size(names,2),4); 
    for i = 1:size(names,2)
            % distace from left side
            % distance from bottom
            % width
            % height
        pos(size(names,2)-i+1,:) = [25 height 250 40] ;
        height = height + 55;
    end
end

function [] = TabNextBack(type, tbNames)
    % type define if click back or next
    % next defined as 1
    % back defined as 0
    global app
    num = find(app.tbgMainTabGroup.SelectedTab.Title == tbNames); 
    if type 
        if num < size(tbNames,2)
            app.tbgMainTabGroup.SelectedTab = app.mainTabGroup.tbMain(num + 1);
        end
    else 
        if num > 1
            app.tbgMainTabGroup.SelectedTab = app.mainTabGroup.tbMain(num - 1);
        else
                % set buttons visibility
            set(app.intro.btgMenu, 'Visible' ,'On');
            set(app.intro.btNext, 'Visible' ,'On');
                % set tab group visibility
            set(app.tbgMainTabGroup, 'Visible','Off'); 
        end
    end
end

function [] = OpenMenuOrClickCancel(btClicked , submenu)
    global app   
    a = 'on';
    b = 'off';
    if strcmpi(btClicked, 'Menu')
        app.intro.btgMenu.Visible = b;
        switch submenu
            case 'Video'
                app.intro.btgVideo.Visible= a;
            case 'Frames'
                app.intro.btgFrames.Visible= a;
            case 'Signals'
                app.intro.btgSignals.Visible= a;
            case 'Inf'
                app.intro.btgInfo.Visible= a;
        end
    elseif strcmpi(btClicked,'Cancel')
        app.intro.btgMenu.Visible = a;
        switch submenu
            case 'Video'
                app.intro.btgVideo.Visible= b;
            case 'Frames'
                app.intro.btgFrames.Visible= b;
            case 'Signals'
                app.intro.btgSignals.Visible= b;
            case 'Inf'
                app.intro.btgInfo.Visible= b;
        end
    end 
end

function [] = ManageChildOfGroup(group, state)
    % Group define parent of interactive chidlren which will be disabled 
    % state - 'on' or  'off' , (define target state of childs)
    % Panel or buttonGroup - cant be disabled
    %   
    % Get all children of parent
    children  = get(group, 'Children');
    childrenSize = size(children, 1);
        %
    for i = 1:childrenSize
        if (strcmp(children(i).Type, 'uibuttongroup')||strcmp(children(i).Type, 'uipanel')) ...
                ||strcmp(children(i).Type, 'uitab')||strcmp(children(i).Type, 'uitabgroup')
                %
            ManageChildOfGroup(children(i),state);
        else
            set(children(i), 'Enable', state);
        end
    end
end

function [] = LoadingCursor(state)
    % state = true  -> define loading
    % state = false -> free to use 
    global app
    if state
        set(app.figMainApp, 'Pointer','watch');
        drawnow(); 
    else
        set(app.figMainApp, 'pointer','arrow');
        drawnow();
    end
end

function [] = DisplayPreprocessImage (image)
    global app 
    I = imshow(image, 'parent',app.preprocess.axAxesImage);
    app.preprocess.axAxesImage.XLim = [0 I.XData(2)];
    app.preprocess.axAxesImage.YLim = [0 I.YData(2)];
    app.preprocess.axAxesImage.Visible = 'on';
    disableDefaultInteractivity(app.preprocess.axAxesImage);
    axis(app.preprocess.axAxesImage,'off');
end

function [image] = ConvertDataToImageAndEqualize (image)
    maxValue = single(max(max(image)));
    image = single(image);
    image = image.*(255/maxValue);
    image = uint8(image);
end

function [prefix, i, suffix] = GetFramesName(name, format)
            % file -> name of file
            % format -> format of file
            % create file name -> need to upgrade function     
        bracket1 = find(name=='(') + 1;
        bracket2 = find(name==')') - 1;
            % everything before (
        first = name(1:(bracket1-2));
            % test if the number is bigger than 9 
        x = bracket2 - bracket1;
        if x == 0
            i = str2double(name(bracket1));
        else
            i = str2double(name(bracket1:bracket2));
        end
            % na kopletku :)
        prefix = [first, '('];
        suffix = [')', format];
end

function [] = PreprocessVideoData()

end

function [signals] = PreprocessFramesData(input, preprocess, logic, saveFormat)
        % Get frames name in right format
    signals = [];
    [prefix, number ,suffix] = GetFramesName(input.file, input.format);
        % pre-set and create directory when frames save as mat file
    if logic.preprocess.process.saveAsMatFile
        savePath = input.path(1:length(input.path)-1);
        savePath = [savePath, 'Crop\'];
        mkdir(savePath);
    end
        % dialog box loafing 
    waitBar = waitbar(0/input.framesNumber,'Please wait...');
    count = 0;
        % Frames iteration
    for i = 1: input.step: input.framesNumber
            % fileName - number of selected image + i sequence of loaded
            % frames to process
        fileName = [prefix, int2str(number + i - 1), suffix]; 
            % [frame] = ReadCurrentFrame(path,  file, format, dataType, dim, logicConvertToImage)
        [frame] = ReadCurrentFrame(input.path, fileName, input.format, input.dataType, input.resolution);
            % ROI part
        if logic.preprocess.options.markROI && logic.preprocess.ROI.confirmed
                % If tracker is used 
            if logic.preprocess.options.trackROI && logic.preprocess.tracker.confirmed
                [frame] =  PreprocesTracker (frame, preprocess.tracker);
            else 
                [frame] =  imcrop(frame, preprocess.ROI.drawInfo.position);
            end
                % spatial filter is used
            if logic.preprocess.options.spatialFilter && logic.preprocess.spatialFilter.confirmed
                [frame] = PreprocesSpatialFiltering (frame, preprocess.spatialFilter.spatialFilter);
            end
        end 
            % if selected signals 
        if logic.preprocess.options.selectSignals && logic.preprocess.selectSignals.selected
                % if selected ROI -> frame has different dimensions
            if logic.preprocess.options.markROI && logic.preprocess.ROI.confirmed
                temp =  PreprocesGetPixelValues (frame, preprocess.selectSignals, logic.preprocess.selectSignals, true);
            else
                temp = PreprocesGetPixelValues (frame, preprocess.selectSignals, logic.preprocess.selectSignals, false);
            end
           signals = [signals; temp];
        end
            % if save cut frames as mat files
        if logic.preprocess.process.saveAsMatFile
            PreprocesSaveFramesROI (frame ,i, savePath, saveFormat);
        end
            % diag box
        count = count + input.step;
        waitbar(count/input.framesNumber, waitBar, 'Processing your data');
    end 
    close(waitBar);
        % assign values to new variable 
end

function [frame] = ReadCurrentFrame(path,  file, format, dataType, resolution)
        % path to image
        % name of Image
        % format 
        % data type
        % dimensions
        %
        % create file name from path and name
    filename = fullfile(path, file);
        % 
    switch format
        case '.Raw'
            fid = fopen(filename);
                % test dataType -> load 12 bit data faster 
            if dataType=="ubit12"
                data = fread(fid, [3 inf], 'uint8=>uint16');
                    % bitshift -> faster way to read 12 bit data 
                frame = [data(1, :) + bitshift( bitand(data(2, :), 0b0000000000001111), 8); ...
                    bitshift(bitand(data(2, :), 0b0000000011110000), -4) + bitshift(data(3, :), 4)];
                    % reshape data from 3 columns to image data
                frame = reshape (frame, [resolution.width resolution.height]);
            else
                frame = fread(fid,[resolution.width, resolution.height],  dataType);
            end
            fclose(fid);
                % transpose loaded data
            frame = transpose(frame);
        case '.Bmp'
            frame = imread(filename);
        case '.Mat'
            frame = load(filename);
            frame = frame.im;
    end
        % define class of output data
    frame = uint16(frame);
end

function [cutframe, tracker] =  PreprocesTracker (frame, tracker)
    trackerFrame =  ConvertDataToImageAndEqualize(frame);
        % track the points. Note that some points may be lost
    [tracker.trackedPointsLocation, tracker.isFound] = step(tracker.pointTracker, trackerFrame);
    tracker.trackedPointsNewFounded = tracker.trackedPointsLocation(tracker.isFound, :);
    tracker.trackedPointsOldFounded = tracker.trackedPointsLocationOld(tracker.isFound, :);
        %   Need at least 2 points
    if size(tracker.trackedPointsNewFounded, 1) >= 2
            % estimate the geometric transformation between the old points 
            % and the new points and eliminate outliers
        [tracker.xform, tracker.inlierIdx] = estimateGeometricTransform2D(tracker.trackedPointsOldFounded,...
            tracker.trackedPointsNewFounded, 'similarity', 'MaxDistance',  2);
        tracker.trackedPointsOldFounded  = tracker.trackedPointsOldFounded( tracker.inlierIdx, :);
        tracker.trackedPointsNewFounded = tracker.trackedPointsNewFounded( tracker.inlierIdx, :);
            % Apply the transformation to the bounding box points
        tracker.rectPointsOfROI = transformPointsForward( tracker.xform, tracker.rectPointsOfROI);
        tracker.positionNew(1:2) = transformPointsForward( tracker.xform, tracker.positionNew(1:2));
            % create binary mask 
        %tracker.binaryMask = roipoly(frame, tracker.rectPointsOfROI(:,1), tracker.rectPointsOfROI(:,2));
        %maskedFrame = frame.*uint8(tracker.binaryMask);
            % Save data to original directory with name FLIRCrop
        %tracker.centroid = regionprops(tracker.binaryMask, 'Centroid');
        cutframe = imcrop(frame, tracker.positionNew);
            % Reset the points
        tracker.trackedPointsLocationOld = tracker.trackedPointsLocation;
        setPoints(tracker.pointTracker, tracker.trackedPointsLocationOld);
    end 
end

function [frame] =  PreprocesSpatialFiltering (frame, spatialFilter)
    frame = imfilter(frame, spatialFilter, 'symmetric');
end

function [] =  PreprocesSaveFramesROI (frame, i, savePath, saveFormat)
        % save('mono.mat', 'image2', '-nocompression');
        % imwrite(image2,'mono.tiff', 'Compression', 'none');
        % imwrite(image2, 'mono.pgm');
        shiftFrame = bitshift(frame, 4);
    global app
    name = app.preprocess.control.process.efSaveROIFrames.Value;
    saveName = [name, ' (', int2str(i), ')', saveFormat];
    switch saveFormat
        case '.mat'
            save([savePath, saveName], 'shiftFrame', '-nocompression');
        case '.tiff'
            imwrite(shiftFrame, [savePath, saveName], 'Compression', 'none');
        case '.pgm'
            imwrite(shiftFrame, [savePath, saveName]);
    end
    
end

function [signals] =  PreprocesGetPixelValues (frame, selectSignals, logic, ROI)
        % assign values new
    if ROI
        pos = selectSignals.positionROI;
    else
        pos = selectSignals.position;
    end
        % average = 3 -> 3x3 - that means minus one and divide by 2 
    kernel = (selectSignals.average-1)/2;
        % signals iteration
    frame = single(frame);
    for j = 1:selectSignals.numberOfSignals
        if logic.average
            temp = single(frame(pos.x(j)-kernel:pos.x(j)+kernel, pos.y(j)-kernel: pos.y(j)+kernel));   
        else
            temp = single(frame(pos.x(j), pos.y(j)));
        end
            % assign to signals
        signals(j) = mean(mean(temp));
    end
end

function [output] = CreateOutputStructure(logic, outputSignals, input, preprocess, image, colors)
    global app
        % PPGI information 
    output.PPGI.signal = transpose(outputSignals);
    output.PPGI.samplingFrequency = input.frames.frameRate;
    output.PPGI.timeVector = input.frames.timeVector;
        % Assign ECG information 
        
    if logic.intro.signals.ECG
        output.ECG = input.signals.ECG;
    else
        output.ECG = [];
    end
    output.ECG.loaded = logic.intro.signals.ECG;
    output.ECG.name = 'ECG';
        % Assign PPG information
    if logic.intro.signals.PPG
        output.PPG = input.signals.PPG;
    else
        output.PPG = [];
    end
    output.PPG.name = 'PPG';
    output.PPG.loaded = logic.intro.signals.PPG;
        % Assign RR information
    if logic.intro.signals.RR
        output.RR = input.signals.RR;
    else
        output.RR = [];
    end
    output.RR.name = 'RR';
    output.RR.loaded = logic.intro.signals.RR;
        % Assign Info data as colors, used filters, kernel ...
    output.info.colors = colors;
        % assign note text write in process section 
    output.info.note = app.preprocess.control.process.taNotes.Value;
        % assing image to results var -> image from select signals
    output.info.image = image;
    output.info.tracker.used = logic.preprocess.tracker.confirmed;
    output.info.spatialFilter.used = logic.preprocess.spatialFilter.confirmed;
    if output.info.spatialFilter.used
        output.info.spatialFilter.type = preprocess.spatialFilter.filterType;
        kernelSize = int2str(preprocess.spatialFilter.kernelSize*2+1);
        output.info.spatialFilter.kernelSize =[kernelSize, 'x', kernelSize];
    end
        % if average of pixel was used in select signals
    output.info.average.used = logic.preprocess.selectSignals.average;
    if output.info.average.used
        avg = int2str(preprocess.selectSignals.average);
        output.info.average.size = [avg, 'x', avg];
    end
end

function [absolut, fOs] = CalculateSpectrum (signal,fvz,color)
        % Spectrum calculation
    spektrum = fft(signal);
    N = length(spektrum);
    fOs = 0:fvz/N:fvz-fvz/N;
    absolut = abs(spektrum)/(N/2);
    absolut(1) = absolut(1)/2;
        % Display Spectrum
%     fig  = uifigure;
%     ax = uiaxes(fig);
    figure
    plot(fOs, absolut); 
    set(gca, 'XLim', [0 fvz/2-1]);
    title(strcat('Spectrum (', color,')'));
    xlabel('f [Hz]'); 
    ylabel('A [-]');
end

function [] = CalculatePeriodogram (signal, fvz, windowName, overlap)
        % input parameters
    window = CreateWindow (windowName, fvz);
    noverlap = CreateNoverlap(overlap, fvz);
   	nfft = fvz;
        % function
    pwelch(signal, window, noverlap, nfft, fvz);
end

function [] = CalculateSpectrogram (signal, fvz, windowName, overlap, color)
        % input parameters
    window = CreateWindow (windowName, fvz);
    noverlap = CreateNoverlap(overlap,fvz);
    f = length(window);
        % function
    [s, f, t] = spectrogram (signal, window, noverlap, f, fvz);
       % zobrazenie spectrogramu pomocou f. imagesc
    figure;
    imagesc(t, f,10*log10 (abs(s))); 
    set(gca, 'YDir', 'normal');
    title(strcat('Spectrogram (', color,')'));
        % nastavenie osi
    xlabel('{\it t} [s]');
    ylabel('{\it f} [Hz]');
        % nastavenie colorbar, map
    colorbar; colormap jet;
end

function [] = CalculateScalogram (signal, fvz, color)
        figure;
        cwt(signal, fvz);
        title(strcat('Magnitude Scalogram (',color,')'));
end

function [noverlap] = CreateNoverlap(overlap, fvz)
    switch overlap
        case 'No overlap'
            noverlap = 0;
        case '1/2'
            noverlap = floor(fvz/2); 
        case '1/4'
            noverlap = floor(fvz/4);
        case '1/8'
            noverlap = floor(fvz/8);
        case '1/12'
            noverlap = floor(fvz/12);
    end
end

function [window] = CreateWindow (windowName, fvz)
    switch windowName
        case 'hamming'
            window = hamming(fvz);
        case 'bartlett'
            window = bartlett(fvz);
        case 'blackman'
            window = blackman(fvz);
    end
end

function  [x, y] = ginputuiax(huiax)
        %GINPUTUIAX Graphical input from mouse with custum cursor pointer.
        %   [X,Y] = ginputuiax(huiax,N) gets N points from the uiaxes, huiax and returns 
        %   the X- and Y-coordinates in length N vectors X and Y.  
        %   GINPUTUIAX is similar to Matlab's original GINPUT, except
        %   that it works with UIFIGURE & UIAXES
        %
        %Check if uiax is from uiaxes
    if ~isvalid(huiax) && ~strcmpi('matlab.app.control.UIAxes',class(huiax))
        return; %Not uiaxes   
    end
        %Activate line that moves for the whole fig
    hFig = ancestor(huiax,'figure');
        % Save current window functions
    hWBDF = get(hFig, 'WindowButtonDownFcn');
    hWBMF = get(hFig, 'WindowButtonMotionFcn');  
        % Save current pointer
    curPointer = get(hFig, 'Pointer');
        % Change window functions
    set(hFig, 'WindowButtonDownFcn', @mouseClickFcn);
    set(hFig, 'WindowButtonMotionFcn', @mouseMoveFcn);
        % Change actual cursor to blank
    x = [];
    y = [];
    
    uiwait(hFig);
    %--------------------------------------------------------------------------
        function mouseMoveFcn(varargin)
                % This function updates cursor location based on pointer location
            cursorPt = huiax.CurrentPoint;      
                %Prevent cursor from moving beyond XLim
            if cursorPt(1,1)<huiax.XLim(2)&&cursorPt(1)>huiax.XLim(1,1)&&cursorPt(1,2)...
                    <huiax.YLim(2)&&cursorPt(1,2)>huiax.YLim(1)
                set(hFig, 'Pointer', 'crosshair');
            else 
                set(hFig, 'Pointer', 'arrow');
            end
        end
    %--------------------------------------------------------------------------
        function mouseClickFcn(varargin)
                % This function updates cursor location based on pointer location
            cursorPt = huiax.CurrentPoint;
                % Restore window functions and pointer
            set(hFig, 'WindowButtonDownFcn', hWBDF);
            set(hFig, 'WindowButtonMotionFcn', hWBMF);
            set(hFig, 'Pointer', curPointer);
                %Click on huiax
            if cursorPt(1,1)<huiax.XLim(2)&&cursorPt(1)>huiax.XLim(1,1)&&cursorPt(1,2)...
                    <huiax.YLim(2)&&cursorPt(1,2)>huiax.YLim(1)
                    % This function captures the information for the selected point  
                pt = round(huiax.CurrentPoint);
                x = pt(1,1);
                y = pt(1,2);
                    % After Captured point -> exit           
                uiresume(hFig);
            else 
                    %If click on other graphic objects
                uiresume(hFig);
            end 
        end
    %--------------------------------------------------------------------------
end

%% Filters
function Hd = LP_08_32_80(fvz)
        %UNTITLED Returns a discrete-time filter object.
        % MATLAB Code
        % Generated by MATLAB(R) 9.9 and Signal Processing Toolbox 8.5.
        % Generated on: 14-Mar-2021 12:09:11
        % Equiripple Lowpass filter designed using the FIRPM function.
        % All frequency values are in Hz.
    Fs = fvz;  % Sampling Frequency
    Fpass = 0.8;             % Passband Frequency
    Fstop = 3.2;             % Stopband Frequency
    Dpass = 0.057501127785;  % Passband Ripple
    Dstop = 0.0001;          % Stopband Attenuation
    dens  = 20;              % Density Factor
        % Calculate the order from the parameters using FIRPMORD.
    [N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(Fs/2), [1 0], [Dpass, Dstop]);
        % Calculate the coefficients using the FIRPM function.
    b  = firpm(N, Fo, Ao, W, {dens});
    Hd = dfilt.dffir(b);
end

function Hd = LP_1_2_80(fvz)
        %LP_1_2_80 Returns a discrete-time filter object.    
        % MATLAB Code
        % Generated by MATLAB(R) 9.9 and Signal Processing Toolbox 8.5.
        % Generated on: 10-Feb-2021 09:04:21
        % Equiripple Lowpass filter designed using the FIRPM function.
        % All frequency values are in Hz.
    Fs = fvz;  % Sampling Frequency
    Fpass = 1;               % Passband Frequency
    Fstop = 2;               % Stopband Frequency
    Dpass = 0.057501127785;  % Passband Ripple
    Dstop = 0.0001;          % Stopband Attenuation
    dens  = 20;              % Density Factor
        % Calculate the order from the parameters using FIRPMORD.
    [N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(Fs/2), [1 0], [Dpass, Dstop]);
        % Calculate the coefficients using the FIRPM function.
    b  = firpm(N, Fo, Ao, W, {dens});
    Hd = dfilt.dffir(b);
end

function Hd = LP_4_6_80(fvz)
        % LP_4_6_80 Returns a discrete-time filter object.
        % MATLAB Code
        % Generated by MATLAB(R) 9.9 and Signal Processing Toolbox 8.5.
        % Generated on: 09-Feb-2021 22:55:15
        % Equiripple Lowpass filter designed using the FIRPM function.
        % All frequency values are in Hz.
    Fs = fvz;  % Sampling Frequency
    Fpass = 4;               % Passband Frequency
    Fstop = 6;               % Stopband Frequency
    Dpass = 0.057501127785;  % Passband Ripple
    Dstop = 0.0001;          % Stopband Attenuation
    dens  = 20;              % Density Factor
        % Calculate the order from the parameters using FIRPMORD.
    [N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(Fs/2), [1 0], [Dpass, Dstop]);
        % Calculate the coefficients using the FIRPM function.
    b  = firpm(N, Fo, Ao, W, {dens});
    Hd = dfilt.dffir(b);
end

function Hd = LP_6_8_80(fvz)
        % LP_6_8_80 Returns a discrete-time filter object.
        % MATLAB Code
        % Generated by MATLAB(R) 9.9 and Signal Processing Toolbox 8.5.
        % Generated on: 14-Mar-2021 11:52:13
        % Equiripple Lowpass filter designed using the FIRPM function.
        % All frequency values are in Hz.
    Fs = fvz;  % Sampling Frequency
    Fpass = 6;               % Passband Frequency
    Fstop = 8;               % Stopband Frequency
    Dpass = 0.057501127785;  % Passband Ripple
    Dstop = 0.0001;          % Stopband Attenuation
    dens  = 20;              % Density Factor
        % Calculate the order from the parameters using FIRPMORD.
    [N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(Fs/2), [1 0], [Dpass, Dstop]);
        % Calculate the coefficients using the FIRPM function.
    b  = firpm(N, Fo, Ao, W, {dens});
    Hd = dfilt.dffir(b);
end

function Hd = LP_8_10_80(fvz)
        % LP_8_10_80 Returns a discrete-time filter object.
        % MATLAB Code
        % Generated by MATLAB(R) 9.9 and Signal Processing Toolbox 8.5.
        % Generated on: 15-Mar-2021 22:11:52
        % Equiripple Lowpass filter designed using the FIRPM function.
        % All frequency values are in Hz.
    Fs = fvz;  % Sampling Frequency
    Fpass = 8;               % Passband Frequency
    Fstop = 10;              % Stopband Frequency
    Dpass = 0.057501127785;  % Passband Ripple
    Dstop = 0.0001;          % Stopband Attenuation
    dens  = 20;              % Density Factor
        % Calculate the order from the parameters using FIRPMORD.
    [N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(Fs/2), [1 0], [Dpass, Dstop]);
        % Calculate the coefficients using the FIRPM function.
    b  = firpm(N, Fo, Ao, W, {dens});
    Hd = dfilt.dffir(b);
end

function Hd = BP_06_1__8_84(fvz)
        %UNTITLED Returns a discrete-time filter object.
        % MATLAB Code
        % Generated by MATLAB(R) 9.9 and Signal Processing Toolbox 8.5.
        % Generated on: 15-Mar-2021 22:09:38
        % Equiripple Bandpass filter designed using the FIRPM function.
        % All frequency values are in Hz.
    Fs = fvz;  % Sampling Frequency
    Fstop1 = 0.6;             % First Stopband Frequency
    Fpass1 = 1;               % First Passband Frequency
    Fpass2 = 8;               % Second Passband Frequency
    Fstop2 = 8.4;             % Second Stopband Frequency
    Dstop1 = 0.001;           % First Stopband Attenuation
    Dpass  = 0.057501127785;  % Passband Ripple
    Dstop2 = 0.0001;          % Second Stopband Attenuation
    dens   = 20;              % Density Factor
        % Calculate the order from the parameters using FIRPMORD.
    [N, Fo, Ao, W] = firpmord([Fstop1 Fpass1 Fpass2 Fstop2]/(Fs/2), [0 1 ...
                              0], [Dstop1 Dpass Dstop2]);
        % Calculate the coefficients using the FIRPM function.
    b  = firpm(N, Fo, Ao, W, {dens});
    Hd = dfilt.dffir(b);
end





