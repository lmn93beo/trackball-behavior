%depends on nidaqmx http://joule.ni.com/nidu/cds/view/p/id/965/lang/en
%
%code may be shared/modified as long as my name travels with it.
%
% Copyright (C) 2008 Erik Flister, UCSD, e_flister@REMOVEME.yahoo.com
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307,
% USA

function bufferedDigOut
clc

len=100;
card1=uint32(rand(1,len)*double(intmax('uint32')));

hpath='C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h';
libpath='C:\WINDOWS\system32\nicaiu.dll';
nidaqmx='nidaqmx';

task1 =libpointer('uint32Ptr',0);
clock_task = libpointer('uint32Ptr',0);

try
    [notfound warnings]=loadlibrary(libpath, hpath, 'alias', nidaqmx);

    %% Create tasks and channels

    tasks=[];

    taskname='task_1';
    [errCode taskname task1]=calllib(nidaqmx,'DAQmxCreateTask',taskname,task1);
    %task is supposed to come back as a uint32Ptr, but it's just a uint32
    checkErr(errCode,nidaqmx,'DAQmxCreateTask');
    tasks=[tasks task1];

    taskname='clock_task';
    [errCode taskname clock_task]=calllib(nidaqmx,'DAQmxCreateTask',taskname,clock_task);
    %task is supposed to come back as a uint32Ptr, but it's just a uint32
    checkErr(errCode,nidaqmx,'DAQmxCreateTask');
    tasks=[tasks clock_task];

    %from NIDAQmx.h
    %*** Values for the Line Grouping parameter of DAQmxCreateDIChan and DAQmxCreateDOChan ***
    cDAQmx_Val_ChanPerLine =0;   %One Channel For Each Line
    cDAQmx_Val_ChanForAllLines =1;   %One Channel For All Lines
    deviceM  = 'Dev1';

    % set dig output channels
    chanName1=[deviceM '/port0/line0:31'];
    chan1='chan1';
    [errCode lines names]=calllib(nidaqmx,'DAQmxCreateDOChan',task1,chanName1, chan1, cDAQmx_Val_ChanForAllLines);
    checkErr(errCode,nidaqmx,'DAQmxCreateDOChan');

    %from NIDAQmx.h
    %*** Value set for the ActiveEdge parameter of DAQmxCfgSampClkTiming and DAQmxCfgPipelinedSampClkTiming ***
    cDAQmx_Val_Rising =10280;   %Rising
    cDAQmx_Val_Falling =10171;   %Falling
    cDAQmx_Val_FiniteSamps =10178;   %Finite Samples
    cDAQmx_Val_ContSamps =10123;   %Continuous Samples
    cDAQmx_Val_Hz = 10373; %units
    cDAQmx_Val_Low = 10214; %resting state of the (pulse) output terminal.

    rate=1000000;
    dutyCycle = .5;
    buffSize = length(card1);
    loop=cDAQmx_Val_ContSamps; %cDAQmx_Val_FiniteSamps

    counter = [deviceM '/ctr0'];
    [errCode] = calllib(nidaqmx,'DAQmxCreateCOPulseChanFreq',clock_task,counter,'',cDAQmx_Val_Hz,cDAQmx_Val_Low,0,rate,dutyCycle);
    checkErr(errCode,nidaqmx,'DAQmxCreateCOPulseChanFreq');

    [errCode] = calllib(nidaqmx,'DAQmxCfgImplicitTiming',clock_task,loop,buffSize);
    checkErr(errCode,nidaqmx,'DAQmxCfgImplicitTiming');

    clock = ['/' deviceM '/ctr0InternalOutput'];

    [errCode src]=calllib(nidaqmx,'DAQmxCfgSampClkTiming',task1,clock,rate,cDAQmx_Val_Rising,loop, buffSize);
    checkErr(errCode,nidaqmx,'DAQmxCfgSampClkTiming');

    %from NIDAQmx.h
    %*** Values for the Data Layout parameter of DAQmxWriteAnalogF64, DAQmxWriteBinaryI16, DAQmxWriteDigitalU8, DAQmxWriteDigitalU32, DAQmxWriteDigitalLines ***
    cDAQmx_Val_GroupByChannel =0;  %Group by Channel (noninterleaved)
    cDAQmx_Val_GroupByScanNumber =1;  %Group by Scan Number (interleaved)
    cDAQmx_Val_WaitInfinitely =-1.0;

    autoStart=0;
    timeout=0;
    sampsPerChanWritten=libpointer('int32Ptr',0);
    reserved=libpointer();

    %% Output Data

    % set up buffers to send
    datap1=libpointer('uint32Ptr',card1);

    errCode =calllib(nidaqmx,'DAQmxWriteDigitalU32',task1,buffSize,autoStart,timeout,cDAQmx_Val_GroupByChannel,datap1,sampsPerChanWritten,reserved);
    checkErr(errCode,nidaqmx,'DAQmxWriteDigitalU32');

    if ~(get(sampsPerChanWritten,'Value'))==buffSize
        sampsPerChanWritten
        get(sampsPerChanWritten,'Value')
        buffSize
        'failed to write full buffer'
    end

    cDAQmx_Val_DMA  =10054; % Direct Memory Access. Data transfers take place independently from the application.
    cDAQmx_Val_Interrupts  =10204; % Data transfers take place independently from the application. Using interrupts increases CPU usage because the CPU must service interrupt requests. Typically, you should use interrupts if the device is out of DMA channels.
    cDAQmx_Val_ProgrammedIO  =10264; % Data transfers take place when you call an NI-DAQmx Read function or an NI-DAQmx Write function.
    cDAQmx_Val_USBbulk  =12590; % Data transfers take place independently from the application using a USB bulk pipe.

    mech=libpointer('int32Ptr',0);
    [errCode chanName mech]=calllib(nidaqmx,'DAQmxGetDODataXferMech',task1, chan1, mech);
    checkErr(errCode,nidaqmx,'DAQmxGetDODataXferMech')
    if mech~=cDAQmx_Val_DMA
        error('channel not DMA')
    end

    'Starting master task...'
    [errCode]=calllib(nidaqmx,'DAQmxStartTask',task1);
    checkErr(errCode,nidaqmx,'DAQmxStartTask');

    'Starting counter task...'
    [errCode]=calllib(nidaqmx,'DAQmxStartTask',clock_task);
    checkErr(errCode,nidaqmx,'DAQmxStartTask');

    %% Stop tasks and invoke cleanup
    'hit a key to stop output'
    pause

    [errCode]=calllib(nidaqmx,'DAQmxStopTask',task1);
    checkErr(errCode,nidaqmx,'DAQmxStopTask');

    [errCode]=calllib(nidaqmx,'DAQmxStopTask',clock_task);
    checkErr(errCode,nidaqmx,'DAQmxStopTask');

    cleanup(nidaqmx,tasks);

catch
    x = lasterror
    x.message
    x.stack.line
    cleanup(nidaqmx,tasks);
end


%% Check for errors
function checkErr(e,lib,fcn)
if e~=0
    sprintf('error in %s\n',fcn)
    if e>0
        sprintf('got warning %d',e)
    elseif e<0
        sprintf('got error %d',e)
    end

    errBuff=libpointer();
    [errBuffSize errBuff]=calllib(lib,'DAQmxGetErrorString',e,errBuff,0);
    errBuff=repmat(' ',1,errBuffSize);
    [newerr errBuff]=calllib(lib,'DAQmxGetErrorString',e,errBuff,errBuffSize);
    if newerr~=0
        'why is newerr ~=0?'
    end
    errBuff

    errBuff=libpointer();
    [errBuffSize errBuff]=calllib(lib,'DAQmxGetExtendedErrorInfo',errBuff,0);
    errBuff=repmat(' ',1,errBuffSize);
    [newerr errBuff]=calllib(lib,'DAQmxGetExtendedErrorInfo',errBuff,errBuffSize);
    if newerr~=0
        'why is newerr ~=0?'
    end
    errBuff

    error([lib ' error'])
end


%% Clean everything up
function cleanup(lib,tasks)
for i=1:length(tasks)
    if tasks(i)~=0
        %task is supposed to be a uint32Ptr but DAQmxCreateTask returns a uint32
        %get(task,'Value')
        errCode=calllib(lib,'DAQmxClearTask',tasks(i));
    end
    checkErr(errCode,lib,'DAQmxClearTask');
end

unloadlibrary(lib)