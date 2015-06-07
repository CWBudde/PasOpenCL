(************************************************************************)
(*                                                                      *)
(*                       OpenCL1.2 and Delphi                           *)
(*                                                                      *)
(*      project site    : http://code.google.com/p/delphi-opencl/       *)
(*                                                                      *)
(*      file name       : Example3.dpr                                  *)
(*      last modify     : 10.12.11                                      *)
(*      license         : BSD                                           *)
(*                                                                      *)
(*      created by      : Maksym Tymkovych                              *)
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
program Example3;

{$APPTYPE CONSOLE}
{$INCLUDE ..\Libs\OpenCL\OpenCL.inc}

uses
  CL_platform in '..\Libs\OpenCL\CL_platform.pas',
  CL in '..\Libs\OpenCL\CL.pas',
  CL_GL in '..\Libs\OpenCL\CL_GL.pas',
  DelphiCL in '..\Libs\OpenCL\DelphiCL.pas',
  dglOpenGL in '..\Libs\dglOpenGL.pas',
  Graphics,
  SysUtils;

var
  Width,
  Height : TCL_int;

type
  PAByte = ^TAByte;
  TAByte = Array of Byte;

var
  host_image_in,
  host_image_out: TAByte;

{$IFNDEF DEFINE_REGION_NOT_IMPLEMENTED}{$REGION 'Load and Save'}{$ENDIF}
procedure LoadFromFile(const FileName: String);
type
  TRGBTriple = packed record
    rgbtBlue: Byte;
    rgbtGreen: Byte;
    rgbtRed: Byte;
  end;
  PRGBTripleArray = ^TRGBTripleArray;
  TRGBTripleArray = Array [0..0] of TRGBTriple;
var
  bmp: Graphics.TBitmap;
  i,j,pos: integer;
  row: PRGBTripleArray;
begin
  bmp:=Graphics.TBitmap.Create;
  bmp.LoadFromFile(FileName);
  bmp.PixelFormat := pf24bit;
  Width:=BMP.Width;
  Height:=BMP.Height;

  pos:=0;
  SetLength(host_image_in,Width*Height*4*SizeOf(Byte));
  SetLength(host_image_out,Width*Height*4*SizeOf(Byte));
  for i:=Height-1 downto 0 do
  begin
    row := bmp.ScanLine[i];
    for j:=0 to Width-1  do
    begin
      host_image_in[pos] := row[j].rgbtBlue;
      inc(pos);
      host_image_in[pos] := row[j].rgbtGreen;
      inc(pos);
      host_image_in[pos] := row[j].rgbtRed;
      inc(pos);
      host_image_in[pos] := 0;
      inc(pos);
    end;
  end;
  bmp.Free;
end;

procedure SaveToFile(const FileName: String);
type
  DWORD = LongWord;

  TBitmapFileHeader = packed record
    bfType: Word;
    bfSize: DWORD;
    bfReserved1: Word;
    bfReserved2: Word;
    bfOffBits: DWORD;
  end;

  TBitmapInfoHeader = packed record
    biSize: DWORD;
    biWidth: Longint;
    biHeight: Longint;
    biPlanes: Word;
    biBitCount: Word;
    biCompression: DWORD;
    biSizeImage: DWORD;
    biXPelsPerMeter: Longint;
    biYPelsPerMeter: Longint;
    biClrUsed: DWORD;
    biClrImportant: DWORD;
  end;
const
  BI_RGB = 0;
var
  F: File;
  BFH: TBitmapFileHeader;
  BIH: TBitmapInfoHeader;
begin
  Assign(F,FileName);
  Rewrite(F,1);
  FillChar(BFH,SizeOf(BFH),0);
  FillChar(BIH,SizeOf(BIH),0);
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
{$IFNDEF DEFINE_REGION_NOT_IMPLEMENTED}{$ENDREGION}{$ENDIF}

var
  Platforms: TDCLPlatforms;
  CommandQueue: TDCLCommandQueue;
  MainProgram: TDCLProgram;
  Kernel : TDCLKernel;
  InputBuffer,OutputBuffer: TDCLBuffer;
  filtertype: Byte;
  SourceName: String;
begin
  InitOpenCL();
  LoadFromFile(ExtractFilePath(ParamStr(0))+'Lena.bmp');

  Writeln('Select filter kenel:');
  Writeln(' 0 - filter01.cl - "Mask 3x3"');
  Writeln(' 1 - filter02.cl - "RGB->Gray"');
  Writeln(' 2 - filter03.cl - "RGB<->BGR"');
  Writeln(' 3 - filter04.cl - "if (c>value) then 255 else 0"');
  Writeln(' 4 - filter05.cl - "invert"');
  Writeln(' 5 - filter06.cl - "log"');
  Writeln(' 6 - filter07.cl - "rotation"');
  Writeln(' 7 - filter08.cl - "Kuwahara (5x5)"');
  Writeln(' 8 - filter09.cl - "Kuwahara (13x13)"');

  Readln(filtertype);

  case filtertype of
    0: SourceName:='filter01.cl';
    1: SourceName:='filter02.cl';
    2: SourceName:='filter03.cl';
    3: SourceName:='filter04.cl';
    4: SourceName:='filter05.cl';
    5: SourceName:='filter06.cl';
    6: SourceName:='filter07.cl';
    7: SourceName:='filter08.cl';
    8: SourceName:='filter09.cl';
    else SourceName:='filter09.cl';
  end;

  Platforms := TDCLPlatforms.Create;
  with Platforms.Platforms[0]^.DeviceWithMaxClockFrequency^ do
  begin
    CommandQueue := CreateCommandQueue();
    InputBuffer := CreateBuffer(Width*Height*4*SizeOf(TCL_Char),nil,[mfReadOnly]);
    CommandQueue.WriteBuffer(InputBuffer,Width*Height*4*SizeOf(TCL_Char),@host_image_in[0]);
    OutputBuffer := CreateBuffer(Width*Height*4*SizeOf(TCL_Char),nil,[mfWriteOnly]);
    MainProgram := CreateProgram(ExtractFilePath(ParamStr(0))+SourceName);
    Kernel := MainProgram.CreateKernel('render');
    Kernel.SetArg(0,InputBuffer);
    Kernel.SetArg(1,OutputBuffer);
    Kernel.SetArg(2,SizeOf(@Width),@Width);
    Kernel.SetArg(3,SizeOf(@Height),@Height);
    CommandQueue.Execute(Kernel,Width*Height);
    CommandQueue.ReadBuffer(OutputBuffer,Width*Height*4*SizeOf(Byte),@host_image_out[0]);
    SaveToFile(ExtractFilePath(ParamStr(0))+'Example3.bmp');
    FreeAndNil(Kernel);
    FreeAndNil(MainProgram);
    FreeAndNil(OutputBuffer);
    FreeAndNil(InputBuffer);
    FreeAndNil(CommandQueue);
  end;
  FreeAndNil(Platforms);
  Writeln('press any key...');
  Readln;
end.
