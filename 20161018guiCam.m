%% Application for camera %%
%Created: July 4, 2016%

%LIST OF GLOBAL VARIABLES:
%selectCOM, pump, time1, selectPump, selectCmd, selectRate, selectLength,
%selectDiameter, Diameter

%vid, selectCamFrames, selectCamRes

%Need to replace (~,~,~) with revalent variables
%timer be off by a couple ms
%% GUI for MAIN PUMP CONTROLS
function guiCam
    f = figure('Visible','off','Position',[360,500,800,230]); %Size of GUI window
    set(f,'Name','Application for Camera'); %Name of Figure
    fpanelCam = uipanel('Parent',f,'Title',' Camera Controls ','TitlePosition','centertop','Position',[0.005,0.01,0.99,0.99]); %Title of GUI
%% GUI for CAMERA CONTROLS (Group 4 Camera)
    connectCamera = uicontrol('Style','pushbutton','String','Connect Camera','Position',[20,70,100,25],'Callback',@connectCamera_callback,'BackgroundColor',[0.93,0.93,0.93]); %Button to connect camera
    global selectCamFrames
        selectCamFramesCaption = uicontrol('Style','text','String','Select Number of Frames','Position',[150,90,70,35]);
        selectCamFrames = uicontrol('Style','edit','Position',[150,70,70,25],'Callback',@selectCamSettings_callback,'BackgroundColor','w');
    global selectCamRes
        selectCamFramesCaption = uicontrol('Style','text','String','Select HxW','Position',[240,95,70,25]);
        selectCamRes = uicontrol('Style','edit','Position',[240,70,70,25],'Callback',@selectCamSettings_callback,'BackgroundColor','w');
    global selectCamRate
        selectCamRateCaption = uicontrol('Style','text','String','Select Frame Rate (frames/s)','Position',[325,90,80,35]);
        selectCamRate = uicontrol('Style','edit','Position',[330,70,70,25],'Callback',@selectCamSettings_callback,'BackgroundColor','w');
    global selectCamName
        selectCamNameCaption = uicontrol('Style','text','String','Name:','Position',[20,150,70,25]);
        selectCamName = uicontrol('Style','edit','Position',[40,130,70,25],'Callback',@selectCamSettings_callback,'BackgroundColor','w');
    %THIS SHOULD BE RUNNING AT SAME TIME AS RUN PUMPS?
    startCamera = uicontrol('Style','pushbutton','String','Start Camera','Position',[420,70,100,25],'Callback',@startCamera_callback,'BackgroundColor',[0.93,0.93,0.93]); %Button to start camera
    runCamera = uicontrol('Style','pushbutton','String','Run Camera','Position',[530,70,100,25],'Callback',@runCamera_callback,'BackgroundColor',[0.93,0.93,0.93]); %Button to connect camera
    stopCamera = uicontrol('Style','pushbutton','String','Stop Camera','Position',[640,70,100,25],'Callback',@stopCamera_callback,'BackgroundColor',[0.93,0.93,0.93]); %Button to connect camera
%% OTHER GUI SETTINGS
    movegui(f,'west');
    set(f,'Visible','on');
end
%% CONNECT CAMERA CALLBACK
function connectCamera_callback (~,~,~)   
    global vid src
        vid = videoinput('gentl', 1, 'Mono8'); %Acquires camera
        triggerconfig(vid, 'Manual'); %Manually controls camera
        src = getselectedsource(vid);
        src.AcquisitionTimingMode = 'FrameRate';
        imaqmem(18*1000000000); %Memory allocation for camera is 18 GB, can be changed
        disp('Camera connected.');
end
%% SET CAMERA PARAMETERS CALLBACK
function selectCamSettings_callback (~,~,~)
    global selectCamName
        str = get(selectCamName, 'string');
        global filename_common
        filename_common = str;
    global selectCamFrames
        str = get(selectCamFrames,'string');
        frameNumber = str2num(str);
    global vid    
        if isempty(get(selectCamFrames,'string'));
            disp('Set Desired number of frames.');
        else
            set(vid,'FramesPerTrigger',frameNumber); %Sets how many frames to record into file
        end 

    global selectCamRes
        if isempty(get(selectCamRes,'string'));
            disp('Set Camera resolution. Limit of 1000x2000. Please type as H W.');
        else
            str = get(selectCamRes,'string');
            CamRes1 = [0 0];
            CamRes2 = str2num(str);
            CamRes = [CamRes1 CamRes2];
            vid.ROIPosition = CamRes; %The resolution of the video, has a limit of 1000x2000. MUST BE TYPED AS H W               
        end 
        
    global selectCamRate src
        if isempty(get(selectCamRate,'string'));
            disp('Set frame rate.');
        else
        str = str2num(get(selectCamRate,'string'));      
        src.AcquisitionFrameRate = str;
        src.Gain = 5;
        src.ExposureTime = 9999;
        end
    disp('Lag.');
end
%% START CAMERA CALLBACK
function startCamera_callback (~,~,~)
    global vid
        preview(vid)
        start(vid);
end 
%% RUN CAMERA CALLBACK
function runCamera_callback (~,~,~)
    global vid
        trigger(vid); filename_camtime = datestr(now,'yyyy-mm-dd HH:MM:SS.FFF'); %Date and time the run started at
        wait(vid,inf); 
        [frames,frametime] = getdata(vid, get(vid,'FramesAvailable'));

    global filename_common
%         filename_common = CamName;
        filepath_new = [pwd '\' 'Cam - ' filename_common]; %Make folder in current working directory
        if ~exist(filepath_new,'dir')
            mkdir(filepath_new);
        end

        filename_avi = [filepath_new '\cellmovie']; %filename for movie file

        writerObj = VideoWriter(filename_avi,'MPEG-4'); %Compress to MP4
        writerObj.FrameRate=100; %Converts the number of frames into this specific frame rate
            open(writerObj);
            writeVideo(writerObj,frames); %Writes frames camptured in frames into object

        framenumber = transpose(1:numel(frametime)); %Creating text file with frame number corresponding to timestamp
        timematrix = [framenumber frametime];
        filename_timestamp = [filepath_new '\frametimestamps.txt']; %file name for frametimestamp file
        dlmwrite(filename_timestamp,timematrix,'delimiter',' ');    
        save([filepath_new '\Camdata.mat'],'framenumber','frametime','filename_camtime');
        disp(' Finished Saving.');
        
%             figure;
% dt = diff(time); %Time difference between each frame
% dt_ms = dt*1000;
% fps = length(time)/time(end);	% No. frames / total time originally
% subplot(2,2,1), plot(dt_ms), xlabel('frames'), ylabel('dt(ms)'); %Time difference between each frame
% 	histx = [0:0.1:max(dt_ms)]; %Histogram of above
% 	histy = hist(dt_ms,histx);
% 	subplot(2,2,2), bar(histx,histy), axis([0 mean(dt_ms)*2 0 max(histy)]),xlabel('dt(ms)'), ylabel('count');
% 	subplot(2,2,3), plot(1./dt), xlabel('frames'), ylabel('inst. fps');
% 	subplot(2,2,4), plot(time), xlabel('frames'), ylabel('time(s)');

end 
%% STOP CAMERA CALLBACK
function stopCamera_callback (~,~,~)
    global vid src
        delete(vid)
        clear (vid)
        clear (src)
        disp(' Camera disconnected.')
end 
%%
%% INSTRUCTIONS
% FOR CAMERA:
%1) Connect Camera. Wait for message to continue.
%2) Set the number of frames, resolution, and memory allocation. 
%- Resolution is limited to 1000x2000. HxW must be set as H W (no x).
%- Memory allocation is limited to 20 Gb.
%3) If lag is shown twice, that means camera is connected.
%4) Start Camera to preview camera. Bottom shows waiting for manual
%trigger.
%5) Run Camera.

% FOR PUMPS:
%1) Select correct COM port.
%2) Set diary name.
%3) Set syringe diameters for the pumps.
%4) For each command line, set the pump, desired command, and desired
%values for the command.
%- First set of commands should set the Pump Rate. Note: Pump Rate must also
%include a duration of 0.05 as well as the desired pump rate value.
%- Infuse/Withdraw must be accompanied with Stop after. (Run no longer
%needed.)
%5) Disconnect COM after use. 

%Pump Rate Units:
%UM = uL/min
%MM = mL/min
%UH = uL/hr
%MH = mL/hr
