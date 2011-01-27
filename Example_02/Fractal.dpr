(************************************************************************)
(*                                                                      *)
(*                 OpenCL1.0 and Delphi and Windows                     *)
(*                                                                      *)
(*      project site    : http://code.google.com/p/delphi-opencl/       *)
(*                                                                      *)
(*      file name       : Fractal.pas                                   *)
(*      last modify     : 27.01.11                                      *)
(*      license         : BSD                                           *)
(*                                                                      *)
(*      created by      : Maksim Tymkovich                              *)
(*                           (niello)                                   *)
(*      Site            : www.niello.org.ua                             *)
(*      e-mail          : muxamed13@ukr.net                             *)
(*      ICQ             : 446-769-253                                   *)
(*                                                                      *)
(*      and             : Alexander Kiselev                             *)
(*                          (Igroman)                                   *)
(*      Site : http://Igroman14.livejournal.com                         *)
(*      e-mail          : Igroman14@yandex.ru                           *)
(*      ICQ             : 207-381-695                                   *)
(*                                                                      *)
(************************delphi-opencl2010-2011**************************)
program Fractal;

{$APPTYPE CONSOLE}

uses
  CL,
  CL_platform,
  ShellAPI,//ShellExecute
  oclutils,//oclGetFirstDevice...
  Windows;

const
  Width  = 2048;
  Height = 2048;

var
  host_image: Array [0..Width*Height*4]of Byte;


procedure SliceToFile(const FileName: AnsiString);

var
  F: File;
  BFH: TBitmapFileHeader;
  BIH: TBitmapInfoHeader;
begin
  Assign(F, FileName);
  Rewrite(F,1);
  ZeroMemory(@BFH,SizeOf(BFH));
  ZeroMemory(@BIH,SizeOf(BIH));
  with BFH do
  begin
    bfType:=$4D42;
    bfSize:=SizeOf(BFH)+SizeOf(BIH)+Width*Height*4;
    bfOffBits:=SizeOf(BIH)+SizeOf(BFH);
  end;
  BlockWrite(F,BFH,SizeOf(BFH));
  with BIH do
  begin
    biSize:=SizeOf(BIH);
    biWidth:=Width;
    biHeight:=Height;
    biPlanes:=1;
    biBitCount:=32;
    biCompression:=BI_RGB;
    biSizeImage:=Width*Height*4;
  end;
  BlockWrite(F,BIH,SizeOf(BIH));
  BlockWrite(F,host_image,Width*Height*4*SizeOf(Byte));
  Close(F);
end;



var
  hContext: Pcl_context;
  Device: PPCL_device_id;
  hCmdQueue: Pcl_command_queue;
  hProgram: Pcl_program;
  hKernel: Pcl_kernel;
  Status: TCL_Int;
  sProgramSource: PAnsiChar;

  Image : PCL_Mem;
  device_work_size,device_work_off: Array [0..1]of TSize_t;

 //LibraryName: Integer;
 properties: array [0..2] of PCL_context_properties = (
                                                  PCL_context_properties(CL_CONTEXT_PLATFORM),
                                                  nil,
                                                  nil
                                                );
 platforms: PCL_platform_id;
begin
{
  Writeln('Select OpenCL library');
  Writeln('0: - atiocl.dll');
  Writeln('1: - OpenCL.dll');
  Readln(LibraryName);
  if LibraryName=0 then InitOpenCL('atiocl.dll')
  else InitOpenCL('OpenCL.dll');}

if not InitOpenCL('OpenCL.dll') then
begin
   InitOpenCL('atiocl.dll');
end;

Status:= clGetPlatformIDs(1,@platforms,nil);
Writeln('clGetPlatformIDs - '+GetString(Status));

properties[1]:= pcl_context_properties(platforms);
hContext := clCreateContextFromType(@properties, CL_DEVICE_TYPE_ALL,
                                   nil, nil, @Status);
Writeln('clCreateContextFromType - '+GetString(Status));

Device:=oclGetFirstDev(hContext);

hCmdQueue:=clCreateCommandQueue(hContext,Device^,0,@Status);
Writeln('clCreateCommandQueue - '+GetString(Status));


sProgramSource:=oclLoadProgSource('fractal.cl','',nil);
hProgram := clCreateProgramWithSource(hContext, 1,@sProgramSource, nil, @Status);
Writeln('clCreateProgramWithSource - '+GetString(Status));

Status:=clBuildProgram(hProgram, 0, nil, nil, nil, nil);
Writeln('clBuildProgram - '+GetString(Status));

Image:=  clCreateBuffer(hContext,CL_MEM_WRITE_ONLY,Width*Height*4*SizeOf(Byte),nil,@Status);
Writeln('clCreateBuffer - '+GetString(Status));


hKernel := clCreateKernel(hProgram, 'render', @Status);
Writeln('clCreateKernel - '+GetString(Status));

Status:=clSetKernelArg(hKernel,0,SizeOf(PCL_Mem),@image);
Writeln('clSetKernelArg - '+GetString(Status));

device_work_size[0]:=Width;
device_work_size[1]:=Height;

device_work_off[0]:=Height;
device_work_off[1]:=0;


Status:=clEnqueueNDRangeKernel(hCmdQueue,hkernel,2,nil,@device_work_size,nil,0,nil,nil);
Writeln('clEnqueueNDRangeKernel - '+GetString(Status));

Status:=clEnqueueReadBuffer(hCmdQueue, image, CL_FALSE, 0,
                              SizeOf(Byte)*Width*Height*4,
                              @host_image, 0, nil, nil);
Writeln('clEnqueueReadBuffer - '+GetString(Status));


Status:=clFinish(hCmdQueue);
Writeln('clFinish - '+GetString(Status));

Status:=clReleaseCommandQueue(hCmdQueue);
Writeln('clReleaseCommandQueue - '+GetString(Status));

Status:=clReleaseContext(hContext);
Writeln('clReleaseContext - '+GetString(Status));

SliceToFile('C:\OpenCL.bmp');
ShellExecute(0,'Open','C:\OpenCL.bmp','','',SW_SHOWMAXIMIZED);

end.
 