(************************************************************************)
(*                                                                      *)
(*                 OpenCL1.0 and Delphi and Windows                     *)
(*                                                                      *)
(*      project site    : http://code.google.com/p/delphi-opencl/       *)
(*                                                                      *)
(*      file name       : Filter.pas                                    *)
(*      last modify     : 29.01.11                                      *)
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
program Filter;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$APPTYPE CONSOLE}

uses
  cl_platform, oclUtils,
  CL,
  SysUtils,
  Graphics,
  ShellAPI,//oclGetFirstDevice...
  {$IFDEF FPC}
  Interfaces,
  {$ENDIF}
  Windows;

var
  Width,
  Height : TCL_int;

type
  PAByte = ^TAByte;
  TAByte = Array of Byte;

var
  host_image_in,
  host_image_out: TAByte;


procedure SliceFromFile(const FileName: AnsiString);
var
  BMP: Graphics.TBitmap;
  i,j,pos: integer;
  c: TColor;
begin
  BMP:=Graphics.TBitmap.Create;
  BMP.LoadFromFile(FileName);
  Width:=BMP.Width;
  Height:=BMP.Height;

  pos:=0;
  SetLength(host_image_in,Width*Height*4*SizeOf(Byte));
  SetLength(host_image_out,Width*Height*4*SizeOf(Byte));
  for i:=Height-1 downto 0 do
    for j:=0 to Width-1  do
    begin

      c:=BMP.Canvas.Pixels[j,i];
      host_image_in[pos]:=GetBValue(c);
      inc(pos);
      host_image_in[pos]:=GetGValue(c);
      inc(pos);
      host_image_in[pos]:=GetRValue(c);
      inc(pos);
      host_image_in[pos]:=0;
      inc(pos);
    end;
    BMP.Free;
end;


procedure SliceToFile(const FileName: AnsiString);

var
  F: File;
  BFH: TBitmapFileHeader;
  BIH: TBitmapInfoHeader;
begin
  Assign(F,FileName);
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
  BlockWrite(F,host_image_out[0],Width*Height*4*SizeOf(Byte));
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

  Image_in, Image_out : PCL_Mem;

  properties: array [0..2] of PCL_context_properties = (
                                                  PCL_context_properties(CL_CONTEXT_PLATFORM),
                                                  nil,
                                                  nil
                                                );
  platforms: PCL_platform_id;

  Size: TSize_t;

  filtertype: Byte;
  SourceName: String;

  Dir: String;
begin
InitOpenCL('OpenCL.dll');

Dir:=ExtractFilePath(paramstr(0));//Get dir


SliceFromFile(Dir+'lena.bmp');//load bmp file

Writeln('Select filter kenel:');//select filter code
Writeln(' 0 - filter01.cl - "Mask 3x3"');
Writeln(' 1 - filter02.cl - "RGB->Gray"');
Writeln(' 2 - filter03.cl - "RGB<->BGR"');
Writeln(' 3 - filter04.cl - "if (c>value) then 255 else 0"');
Writeln(' 4 - filter05.cl - "invert"');
Writeln(' 5 - filter06.cl - "log"');
Writeln(' 6 - filter07.cl - "rotation"');
Readln(filtertype);

case filtertype of
  0: SourceName:='filter01.cl';
  1: SourceName:='filter02.cl';
  2: SourceName:='filter03.cl';
  3: SourceName:='filter04.cl';
  4: SourceName:='filter05.cl';
  5: SourceName:='filter06.cl';
  6: SourceName:='filter07.cl';
  else SourceName:='filter07.cl';
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


sProgramSource:=oclLoadProgSource(SourceName,'',nil);
hProgram := clCreateProgramWithSource(hContext, 1,@sProgramSource, nil, @Status);
Writeln('clCreateProgramWithSource - '+GetString(Status));

Status:=clBuildProgram(hProgram, 0, nil, nil, nil, nil);
Writeln('clBuildProgram - '+GetString(Status));

Image_in:=  clCreateBuffer(hContext,CL_MEM_READ_ONLY or CL_MEM_COPY_HOST_PTR,Width*Height*4*SizeOf(TCL_Char),@host_image_in[0],@Status);
Writeln('clCreateBuffer - '+GetString(Status));
Status:=clEnqueueWriteBuffer(hCmdQueue, image_in, CL_FALSE, 0,
                              SizeOf(TCL_Char)*Width*Height*4,
                              @host_image_in[0], 0, nil, nil);
Writeln('clEnqueueWriteBuffer - '+GetString(Status));


Image_out:= clCreateBuffer(hContext,CL_MEM_WRITE_ONLY,Width*Height*4*SizeOf(TCL_Char),nil,@Status);
Writeln('clCreateBuffer - '+GetString(Status));

hKernel := clCreateKernel(hProgram, 'render', @Status);
Writeln('clCreateKernel - '+GetString(Status));

Status:=clSetKernelArg(hKernel,0,SizeOf(PCL_Mem),@image_in);
Writeln('clSetKernelArg - '+GetString(Status));

Status:=clSetKernelArg(hKernel,1,SizeOf(PCL_Mem),@image_out);
Writeln('clSetKernelArg - '+GetString(Status));

Status:=clSetKernelArg(hKernel,2,SizeOf(PCL_Int),@Width);
Writeln('clSetKernelArg - '+GetString(Status));

Status:=clSetKernelArg(hKernel,3,SizeOf(PCL_Int),@Height);
Writeln('clSetKernelArg - '+GetString(Status));



Size:=Width*Height;

//execute
Status:=clEnqueueNDRangeKernel(hCmdQueue,hkernel,1,nil,@Size,nil,0,nil,nil);
Writeln('clEnqueueNDRangeKernel - '+GetString(Status));

Status:=clFinish(hCmdQueue);
Writeln('clFinish - '+GetString(Status));

//read out bmp
Status:=clEnqueueReadBuffer(hCmdQueue, image_out, CL_TRUE, 0,
                              SizeOf(TCL_Char)*Width*Height*4,
                              @host_image_out[0], 0, nil, nil);
Writeln('clEnqueueReadBuffer - '+GetString(Status));


Status:=clReleaseCommandQueue(hCmdQueue);
Writeln('clReleaseCommandQueue - '+GetString(Status));

Status:=clReleaseContext(hContext);
Writeln('clReleaseContext - '+GetString(Status));

SliceToFile(Dir+'OpenCLfilter.bmp');//write out bmp to file
ShellExecute(0,'Open',PAnsiChar(Dir+'OpenCLfilter.bmp'),'','',SW_SHOWMAXIMIZED);//open

end.
 
