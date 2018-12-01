%% Application for syringe pumps %%
%Created: July 4, 2016%

%LIST OF GLOBAL VARIABLES:
%selectCOM, pump, time1, selectPump, selectCmd, selectRate, selectLength,
%selectDiameter, Diameter

%vid, selectCamFrames, selectCamRes

%timer be off by a couple ms
%% GUI for MAIN PUMP CONTROLS
function guiPumps
    n1 = 6; %Easier to find
    f = figure('Visible','off','Position',[360,500,800,400]); %Size of GUI window
    set(f,'Name','Application for Syringe Pumps'); %Name of Figure
%     fpanelCam = uipanel('Parent',f,'Title',' Camera Controls ','TitlePosition','centertop','Position',[0.005,0.01,0.99,0.99]); %Title of GUI
    fpanelPumps = uipanel('Parent',f,'Title',' Syringe Pump Controls ','TitlePosition','centertop','Position',[0.005,0.01,0.99,0.99]); %Title of GUI (Previously 0.99)
    %Group 1 (Connections/Parameters)
    global selectCOM %Connecting COM pump
        selectCOMCaption = uicontrol('Style','text','String','Select COM','Position',[20,350,70,25]);
        selectCOM = uicontrol('Style','popupmenu','String',{'COM1','COM2','COM3','COM4','COM5'},'Position',[20,320,70,25],'Callback',@selectCOM_callback,'BackgroundColor','w');
    global selectLoop
            selectLoopCaption = uicontrol('Style','text','String','Select Number of Loops','Position',[105,345,80,30]);
            selectLoop = uicontrol('Style','edit','Position',[110,320,70,25],'Callback',@selectLoop_callback,'BackgroundColor','w');
    global selectDiameter %Setting syringe diameter
        for i=1:2 %Syringe diameters for i amount of pumps, REMEMBER set i=1:m, m=Number of pumps 
            selectDiameterCaption(i) = uicontrol('Style','text','String',sprintf('Pump %d: Select Diameter (mm)',i),'Position',[105+i*90,345,80,30]);
            selectDiameter(i) = uicontrol('Style','edit','Position',[110+i*90,320,70,25],'Callback',@selectDiameter_callback,'BackgroundColor','w');
    global selectPumpName 
        selectPumpNameCaption = uicontrol('Style','text','String','Name:','Position',[375,345,80,30]);
        selectPumpName = uicontrol('Style','edit','Position',[375,320,70,25],'Callback',@selectPumpName_callback,'BackgroundColor','w');
        end
    %Group 2 (Run/Disconnections/Instructions)        
    runPumps = uicontrol('Style','pushbutton','String','Run Pumps','Position',[480,50,120,25],'Callback',@runPumps_callback,'BackgroundColor',[0.93,0.93,0.93]); %Button to run commands
    runPumps2 = uicontrol('Style','pushbutton','String','Run Pumps (Program)','Position',[605,50,120,25],'Callback',@runPumps2_callback,'BackgroundColor',[0.93,0.93,0.93]); %Button to run commands programmatically
    disconnectPump = uicontrol('Style','pushbutton','String','Disconnect COM','Position',[480,20,120,25],'Callback',@disconnectPumps_callback,'BackgroundColor',[0.93,0.93,0.93]); %Button to disconnect pump from computer

    instructionsCaption = uipanel('Parent',f,'Title','Instructions','Position',[0.6,0.23,0.35,0.70]); %Instructions section (Previously 0.7)
    instructions = {'- First command should be Pump Rate, second command should be Run'...
                    '- Pump Rate command must include Select Rate & Duration, where Select Duration must be 0.05'...
                    '- Select Rate: Only if Pump Rate command is selected. (ex. 5.0 MM)'...
                    '- Select Duration: Only if Infuse/Withdraw/Pump Rate command is selected. If Pump Rate selected, Duration must be 0.05'...
                    '- Remember to disconnect COM after use.'...
                    ' ','Pump Rate Units:','UM = uL/min','MM = mL/min','UH = uL/hr','MH = mL/hr'};
    instructionsLegend = uicontrol('Parent',instructionsCaption,'Style','text','String',instructions,'Position',[1,1,270,255],'HorizontalAlignment','left');
%% GUI for CUSTOMIZABLE PUMP COMMANDS (Group 3 Command lines)
    global n
    n=n1; %SET THE NUMBER OF COMMANDS WANTED/Should move to top of code so it can be easily set
    for i=1:n
            txt(i) = uicontrol('Style','text','String',sprintf('Cmd %d:',i),'Position',[30,285-i*30,80,25],'BackgroundColor',[0.93,0.93,0.93]); %Text for command lines
        global selectPump %Selecting which pump to command
            selectPumpCaption = uicontrol('Style','text','String','Select Pump','Position',[110,285,80,25]);
            selectPump(i) = uicontrol('Style','popupmenu','String',{'Pump 1','Pump 2','Pump 3','Pump 4',' '},'Position',[110,290-i*30,80,25],'Callback',@selectCmd_callback,'BackgroundColor','w');
        global selectCmd %Selecting specific pump command
            selectCmdCaption = uicontrol('Style','text','String','Select Cmd','Position',[200,285,80,25]);
            selectCmd(i) = uicontrol('Style','popupmenu','String',{'Pump Rate','Infuse','Withdraw','Run','Stop',' '},'Position',[200,290-i*30,80,25],'Callback',@selectCmd_callback,'BackgroundColor','w');
        global selectRate %Setting rate of flow and unit for Pump Rate
            selectRateCaption = uicontrol('Style','text','String','Select Rate','Position',[290,285,80,25]);
            selectRate(i) = uicontrol('Style','edit','Position',[290,290-i*30,80,25],'Callback',@selectCmd_callback,'BackgroundColor','w');
        global selectLength %Setting time duration of command for Infuse and Withdraw
            selectLengthCaption = uicontrol('Style','text','String','Select Duration (s)','Position',[380-5,285,95,25]);
            selectLength(i) = uicontrol('Style','edit','Position',[380,290-i*30,80,25],'Callback',@selectCmd_callback,'BackgroundColor','w');
    end 
%% OTHER GUI SETTINGS
    movegui(f,'east');
    set(f,'Visible','on');
end
%% SELECT PUMP NAME
function selectPumpName_callback (~,~,~)
    global selectPumpName
        str = get(selectPumpName,'String');
        global filename_common
        filename_common = str;
end 
%% SELECT COM1-4 FOR PUMP & CONNECT PUMP
function selectCOM_callback (~,~,~)
    global selectCOM %Callback for selecting which COM for pump
        str = get(selectCOM,'String');
        val = get(selectCOM,'Value' );    
    switch str{val}
        case 'COM1'
            COM = 'COM1'; %COM1 can be selected in lab computer since it exists as a communication  port. What is that
        case 'COM2'
            COM = 'COM2';
        case 'COM3'
            COM = 'COM5';   %change back to COM3
        case 'COM4'  
            COM = 'COM4';
        case 'COM5'  
            COM = 'COM5';            
    end 
    
    global pump    
        pump = instrfind('Type','serial','Port',COM,'Tag',''); %Turns usb into serial port
    if isempty(pump) %If pump variable doesn't exist then
        pump = serial(COM);
        set(pump,'BaudRate',19200);  %Set baud rate of pump
        fopen(pump);
        fprintf(' %s is connected.\r',get(pump,'Name')) %Confirms which COM the defined pump is
    else
        fprintf(' %s: %s is already connected.\r',get(pump,'Name'),get(pump,'Status')) %Indicates that pump is already defined, HOWEVER, if COM1 is selected after selecting COM4, it says already connected (minor error, can fix)
    end
end 
%% SET SYRINGE DIAMETER CALLBACK
function selectDiameter_callback (~,~,~)
    global Diameter %Callback for setting syringe diameter. Can this function be merged with another function to reduce code and global variable?
    global selectDiameter
        Diameter{1} = sprintf('0 DIA %s',get(selectDiameter(1),'string')); 
        Diameter{2} = sprintf('1 DIA %s',get(selectDiameter(2),'string'));
end 
%% SET LOOP NUMBER CALLBACK
function selectLoop_callback (~,~,~)
    global m
    global selectLoop
        m = get(selectLoop,'string');
end 
%% SELECT COMMAND CALLBACK
function selectCmd_callback (~,~,~)
    global n %Callback to select Pump, its command, rate, and time duration
    for i=1:n
        global selectPump %Select specific pump
            str = get(selectPump(i),'String');
            val = get(selectPump(i),'Value' );       
        switch str{val}
            case 'Pump 1'
                Add{i} = '0 ';
            case 'Pump 2'
                Add{i} = '1 ';      
            case 'Pump 3'
                Add{i} = '2 ';      
            case 'Pump 4'
                Add{i} = '3 ';
            case ' '
                Add{i} = ' ';
        end   

        global selectCmd %Select specific command
            str = get(selectCmd(i),'String');
            val = get(selectCmd(i),'Value' );       
        switch str{val}
            case 'Pump Rate'
                Cmd{i} = 'RAT ';
            case 'Infuse'
                Cmd{i} = 'DIR INF ';      
            case 'Withdraw'
                Cmd{i} = 'DIR WDR ';      
            case 'Run'
                Cmd{i} = 'RUN ';
            case 'Stop'
                Cmd{i} = 'STP ';
            case ' '
                Cmd{i} = ' ';
        end

        global selectRate %Select specific rate (for Pump Rate commands only)
            str = get(selectRate(i),'string');
            Rate{i} = str;

        global Length %Select specific time duration of command (for Infuse/Withdraw & Pump Rate only)
        global selectLength
            str = get(selectLength(i),'string'); 
            Length{i} = str2num(str);

        global Command %Combines all callback values into one string to be sent to RunPumps_callback
            Command{i} = [Add{i} Cmd{i} Rate{i}];
    end 
end 
%% RUN PUMPS CALLBACK
function runPumps_callback (~,~,~,~,~)
    global filename_common
    filename_pumptime = datestr(now,'yyyy-mm-dd HH:MM:SS.FFF');        
    diary(filename_common) %Records command window to pumptimestamps file
%     disp(datestr(clock)) %Date and time the run started at
    global Command Length m n
    global time1
        time1 = tic; %Start timer (NOTE: Timer starts BEFORE commands start, not at same time, need to fix)
        
    global pump
    global Diameter %Sets syringe diameters
    for i=1:2 %REMEMBER set i=1:m, m=Number of pumps
        sendCmd(pump,Diameter{i}); 
    end 
        sendCmd(pump,'0 VOL 0 ML');  %Setting 0 volume is necessary to be able to reverse pump direction
    
    %Start of customized commands
    for j='1':m
        for i=1:n
            if strcmp(Command{i},'0 DIR INF ')
                sendCmd(pump,'0 RUN');
                sendCmd(pump,Command{i},Length{i});
            elseif strcmp(Command{i},'1 DIR INF ')
                sendCmd(pump,'1 RUN');
                sendCmd(pump,Command{i},Length{i});
            elseif strcmp(Command{i},'0 DIR WDR ')
                sendCmd(pump,'0 RUN');
                sendCmd(pump,Command{i},Length{i});
            elseif strcmp(Command{i},'1 DIR WDR ')
                sendCmd(pump,'1 RUN');
                sendCmd(pump,Command{i},Length{i});            
            else 
                sendCmd(pump,Command{i},Length{i});
            end
        end 
    end 
    time2 = toc(time1);
    fprintf('-------------- END OF RUN. Run Time: %0.5f s. --------------\r',time2); 
        diary off
        
    filepath_new = [pwd '\' 'Pump - ' filename_common]; %Make folder in current working directory
    if ~exist(filepath_new,'dir')
    mkdir(filepath_new);
    end
    save([filepath_new '\Pumpdata.mat'], 'filename_pumptime');
    disp(' Finished Saving.');
end
%% RUN PUMPS PROGRAMMATICALLY CALLBACK
function runPumps2_callback (~,~,~,~,~)
    filename_pumptime = datestr(now,'yyyy-mm-dd HH:MM:SS.FFF');  
    global filename_common    
    diary(filename_common) %Records command window to text file

    global time1
        time1 = tic; %Start timer (NOTE: Timer starts BEFORE commands start, not at same time, need to fix)
        
    global pump
        sendCmd(pump,'0 DIA 10.0');  
        sendCmd(pump,'1 DIA 10.0');
        sendCmd(pump,'0 VOL 0 ML');  	% setting 0 volume is necessary to be able to reverse pump direction

        sendCmd(pump,'0 RAT 5.0 MM',0.005); 
        sendCmd(pump,'1 RAT 4.0 MM',0.005);
        sendCmd(pump,'0 RUN');
        sendCmd(pump,'0 DIR WDR',1);
        sendCmd(pump,'0 STP');
        sendCmd(pump,'1 RUN');
        sendCmd(pump,'1 DIR INF',1);

        sendCmd(pump,'1 STP'); 
        
        time2 = toc(time1);
    fprintf('-------------- END OF RUN. Run Time: %0.5f s. --------------\r',time2);
        diary off
    
    filepath_new = [pwd '\' 'Pump - ' filename_common]; %Make folder in current working directory
    save([filepath_new '\Pumpdata.mat'], 'filename_pumptime');
    disp(' Finished Saving.');
end 
%% DISCONNECT COM/PUMP CALLBACK
function disconnectPumps_callback (~,~,~)
    global pump
        fclose(pump);
        delete(pump); %Closes & deletes connection between pump and computer
        disp(' Pumps disconnected.')    
end 
%%


%% send command
function response = sendCmd(obj,cmd,time)   
%     t1 = tic; %Start of timer t1
% 	fprintf('-----------------\r');
	%% 1. sending command
    global pump time1
	while ~strcmp(pump.TransferStatus,'idle')		% make sure the transfer is completed in 'idle' mode instead of 'read'
	end
	fprintf(pump, '%s\r', cmd);	t2 = toc(time1); 			% send
% 	fprintf(' SendCmd: %s\r', cmd);				% display
	%% 3. ensured duration of command
	if nargin < 3
		dt2 = 0;
	elseif nargin == 3					
		dt2 = delay(time);
    end
% 	timestamp = datestr(now,'HH:MM:SS.FFF');   %from BEFORE first command to AFTER snd->: & from BEFORE --- to AFTER snd->: (NOTE: time2 ends AFTER command, not at same time, need to fix)
%     fprintf(' Timestamp: %s\r',timestamp) %time for command + time for time duration of command
%     fprintf(' CmdTime: %0.5f , %0.2f\r',t2-dt2,dt2) %time for command + time for time duration of command
	fprintf('CmdTime: %s: %0.5f\r', cmd, t2);    %timestamp of RIGHT AFTER sending command

    
end
    %% 4. ensured delay of commands
function dt = delay(seconds)
	% function pause the program
	% seconds = delay time in seconds
	t1 = tic;
	dt = toc(t1);
	while dt < seconds
		dt = toc(t1);
	end
end

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
