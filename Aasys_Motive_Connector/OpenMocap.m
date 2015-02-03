function flag = OpenMocap(  HostIP, ClientIP, NatNETdllPath )
% OPENMOCAP initiates a network connection to Motive Data Stream.
% IMPORTANT: OPEN MOTIVE AND ENABLE DATA STREAMING BEFORE STARTING THIS.
%
% Syntax:
%    OpenMocap
%    OpenMocap(HostIP)
%    OpenMocap(HostIP,ClientIP)
%    OpenMocap(HostIP,ClientIP,NatNETdllPATH)
%
% Description:
%    OPENMOCAP opens up communication with Motive, tracking software by
%    Optitrack using NatNET*. This function creates a global Mocap variable
%    for easy use and transition between functions.
%
%    Default Settings:
%       ClientIP               - local host*
%       HostIP                 - local host*
%       NatNETdllPATH          - 'NatNet_SDK_2.6\lib\NatNetML.dll' x86
%                              - 'NatNet_SDK_2.6\lib\x64\NatNetML.dll' x64
%    
%    Examples:
%       OpenMocap             
%           - connect with default setting.
%       OpenMocap('111.11.11.1')
%           - connect to '111.11.11.1' host with other defaults.
%       OpenMocap('111.11.11.1','222.22.22.2')
%           - connect to '111.11.11.1' host, from  '222.22.22.2' client and
%           default NatNETdllPATH.
%       OpenMocap('111.11.11.1','222.22.22.2','C:\NatNetML.dll')
%           - connect to '111.11.11.1' host, from  '222.22.22.2' client and
%           set NatNETdllPATH to 'C:\NatNetML.dll'.
%       OpenMocap('local','local','C:\NatNetML.dll')
%           - default host and client and set NatNETdllPATH to 'C:\NatNetML.dll'.
%       OpenMocap('111.11.11.1','local','C:\NatNetML.dll')
%           - connect to '111.11.11.1' host, from  default client and
%           set NatNETdllPATH to 'C:\NatNetML.dll'.
%
% NOTE:
%   *dot NET needs to be supported in order to use NatNET and this function.
%   *java needs to supported to get local host
%
% Other Functions:
%   related functions  --> GetMocap, CloseMocap
%   dependent function --> cprintf
%
% Programmed and Copyright by Aasys Sresta: <aasysresta@gmail.com>
% $Revision: 2.00 $  $Date: 2014/10/15 06:23:00 $

%% checks

    if ~NET.isNETSupported
        error('dot NET is not supported on this system!!');
    end

%%
    cprintf('\n\n\n');
    cprintf('*blue','************AASYS MOTIVE CONNECTOR************\n');
    cprintf('Hyperlinks','aasysresta@gmail.com\n\n'); 

    cprintf('SystemCommands','!!!Make sure motive is open and data streaming is enabled!!!\n'); 
%% definations
    varUpdateColor = 'comment';
    statusUpdateColor = [0,0.75,0];
    msgColor = [0 0.4 0];
    
%%    
    
    %declare global Mocap variable in base
    cprintf(statusUpdateColor, 'creating a global Mocap variable...\n'); 
    global Mocap;
    evalin('base','global Mocap'); 
    
    try
        CloseMocap(); % close just in case
    catch
    end
    
%% INITIALIZE VALUES
    %get or set NatNET dll path
    if nargin < 3   
        filepath = mfilename('fullpath');
        findSlash = [strfind(filepath,'\'),strfind(filepath,'/')];
        if ~isempty(findSlash)
            filepath = filepath(1:findSlash(end));
        end
        if strcmpi(getenv('PROCESSOR_ARCHITECTURE'),'amd64')
            NatNETdllPath = fullfile(filepath,'NatNetMLx64.dll');
        else
            NatNETdllPath = fullfile(filepath,'NatNetMLx86.dll');
        end
    end 
    cprintf(varUpdateColor, 'NatNET path set to : ');
    cprintf('Strings', '%s\n',NatNETdllPath);
    
    % client and host IP
    if nargin < 2 || strcmpi(ClientIP,'local')
        ClientIP = char(java.net.InetAddress.getLocalHost.getHostAddress);      
    end 
    cprintf(varUpdateColor, 'Client IP set to : ');
    cprintf('Strings', '%s\n',ClientIP);
    
    if nargin < 1 || strcmpi(HostIP,'local')
        HostIP = char(java.net.InetAddress.getLocalHost.getHostAddress);      
    end 
    cprintf(varUpdateColor, 'Host IP set to : ');
    cprintf('Strings', '%s\n',HostIP);    
    
%% MOCAP CONNECTION     
    %add NatNET
    cprintf(statusUpdateColor, 'adding NatNET assembly...\n');
    NET.addAssembly(NatNETdllPath);
    
    cprintf(statusUpdateColor, 'creating NatNETClient object...\n');
    %declare Mocap
    Mocap = NatNetML.NatNetClientML(0);
    
    %connect
    cprintf(statusUpdateColor, 'connecting...\n');
    Mocap.Initialize(ClientIP, HostIP);
    
    
    cprintf(statusUpdateColor, 'testing...\n');
    % get two frames and check if the data is valid
    data = GetMocap;
    frame1 = data.FrameID;
    pause(1);
    data = GetMocap;
    frame2 = data.FrameID;
    if frame1==frame2 || frame1==0
        cprintf('Errors', 'COMMUNICATION COULD NOT BE ESTABLISHED!!!\n');        
        beep;        
        CloseMocap;
        error('')
        flag = 1;
    else
        flag = 0;
        cprintf(msgColor, 'MOTIVE CONNECTION OK!!!\n');
    end

end
