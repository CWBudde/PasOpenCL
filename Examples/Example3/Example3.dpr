(************************************************************************)
(*                                                                      *)
(*                       OpenCL1.2 and Delphi                           *)
(*                                                                      *)
(*      project site    : http://code.google.com/p/delphi-opencl/       *)
(*                                                                      *)
(*      file name       : Example5.dpr                                  *)
(*      last modify     : 24.12.11                                      *)
(*      license         : BSD                                           *)
(*                                                                      *)
(*      created by      : Maksym Tymkovych (niello)                     *)
(*      Site            : www.niello.org.ua                             *)
(*      e-mail          : muxamed13@ukr.net                             *)
(*      ICQ             : 446-769-253                                   *)
(*                                                                      *)
(*      and             : Alexander Kiselev (Igroman)                   *)
(*      Site            : http://Igroman14.livejournal.com              *)
(*      e-mail          : Igroman14@yandex.ru                           *)
(*      ICQ             : 207-381-695                                   *)
(*                                                                      *)
(************************delphi-opencl2010-2011**************************)

program Example3;

{$APPTYPE CONSOLE}
{$INCLUDE ..\..\Source\OpenCL.inc}

uses
  CL_Platform in '..\..\Source\CL_Platform.pas',
  CL in '..\..\Source\CL.pas',
  CL_GL in '..\..\Source\CL_GL.pas',
  DelphiCL in '..\..\Source\DelphiCL.pas',
  Graphics,
  SysUtils;

var
  Width,
  Height : TCL_int;

type
  PAByte = ^TAByte;
  TAByte = array of Byte;

var
  HostImageIn,
  HostImageOut: TAByte;

{$IFNDEF DEFINE_REGION_NOT_IMPLEMENTED}{$REGION 'Load and Save'}{$ENDIF}
procedure LoadFromFile(const FileName: string);
type
  TRGBTriple = packed record
    rgbtBlue: Byte;
    rgbtGreen: Byte;
    rgbtRed: Byte;
  end;
  PRGBTripleArray = ^TRGBTripleArray;
  TRGBTripleArray = array [0..0] of TRGBTriple;
var
  bmp: Graphics.TBitmap;
  i, j, pos: integer;
  row: PRGBTripleArray;
begin
  bmp := Graphics.TBitmap.Create;
  bmp.LoadFromFile(FileName);
  bmp.PixelFormat := pf24bit;
  Width := bmp.Width;
  Height := bmp.Height;

  pos := 0;
  SetLength(HostImageIn, Width * Height * 4 * SizeOf(Byte));
  SetLength(HostImageOut, Width * Height * 4 * SizeOf(Byte));
  for i := Height - 1 downto 0 do
  begin
    row := bmp.ScanLine[i];
    for j := 0 to Width - 1 do
    begin
      HostImageIn[pos] := row[j].rgbtBlue;
      inc(pos);
      HostImageIn[pos] := row[j].rgbtGreen;
      inc(pos);
      HostImageIn[pos] := row[j].rgbtRed;
      inc(pos);
      HostImageIn[pos] := 0;
      inc(pos);
    end;
  end;
  bmp.Free;
end;

procedure SaveToFile(const FileName: string);
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
  Assign(F, FileName);
  Rewrite(F, 1);
  FillChar(BFH, SizeOf(BFH), 0);
  FillChar(BIH, SizeOf(BIH), 0);
  with BFH do
  begin
    bfType := $4D42;
    bfSize := SizeOf(BFH) + SizeOf(BIH) + Width * Height * 4;
    bfOffBits := SizeOf(BIH) + SizeOf(BFH);
  end;
  BlockWrite(F, BFH, SizeOf(BFH));
  with BIH do
  begin
    biSize := SizeOf(BIH);
    biWidth := Width;
    biHeight := Height;
    biPlanes := 1;
    biBitCount := 32;
    biCompression := BI_RGB;
    biSizeImage := Width * Height * 4;
  end;
  BlockWrite(F, BIH, SizeOf(BIH));
  BlockWrite(F, HostImageOut[0], Width * Height * 4 * SizeOf(Byte));
  Close(F);
end;
{$IFNDEF DEFINE_REGION_NOT_IMPLEMENTED}{$ENDREGION}{$ENDIF}

var
  Platforms: TDCLPlatforms;
  CommandQueue: TDCLCommandQueue;
  MainProgram: TDCLProgram;
  Kernel : TDCLKernel;
  InputBuffer, OutputBuffer: TDCLBuffer;
  FilterType: Byte;
  SourceName: string;
  FileName: TFileName;
begin
  // specify & load image resource
  FileName := ExtractFilePath(ParamStr(0)) + '..\..\Resources\Lena.bmp';
  Assert(FileExists(FileName));
  LoadFromFile(FileName);

  Writeln('Select filter kenel:');
  Writeln(' 0 - Filter01.cl - "Mask 3x3"');
  Writeln(' 1 - Filter02.cl - "RGB->Gray"');
  Writeln(' 2 - Filter03.cl - "RGB<->BGR"');
  Writeln(' 3 - Filter04.cl - "if (c>value) then 255 else 0"');
  Writeln(' 4 - Filter05.cl - "invert"');
  Writeln(' 5 - Filter06.cl - "log"');
  Writeln(' 6 - Filter07.cl - "rotation"');
  Writeln(' 7 - Filter08.cl - "Kuwahara (5x5)"');
  Writeln(' 8 - Filter09.cl - "Kuwahara (13x13)"');

  Readln(FilterType);

  case FilterType of
    0:
      SourceName := 'Filter01.cl';
    1:
      SourceName := 'Filter02.cl';
    2:
      SourceName := 'Filter03.cl';
    3:
      SourceName := 'Filter04.cl';
    4:
      SourceName := 'Filter05.cl';
    5:
      SourceName := 'Filter06.cl';
    6:
      SourceName := 'Filter07.cl';
    7:
      SourceName := 'Filter08.cl';
    8:
      SourceName := 'Filter09.cl';
  else
    SourceName := 'Filter09.cl';
  end;

  // specify source name
  FileName := ExtractFilePath(ParamStr(0)) + '..\..\Resources\' + SourceName;
  Assert(FileExists(FileName));

  InitOpenCL;

  Platforms := TDCLPlatforms.Create;
  with Platforms.Platforms[0]^.DeviceWithMaxClockFrequency^ do
  try
    CommandQueue := CreateCommandQueue;
    try
      InputBuffer := CreateBuffer(Width * Height * 4 * SizeOf(TCL_Char), nil,
        [mfReadOnly]);
      CommandQueue.WriteBuffer(InputBuffer, Width * Height * 4 * SizeOf(TCL_Char),
        @HostImageIn[0]);
      OutputBuffer := CreateBuffer(Width * Height * 4 * SizeOf(TCL_Char), nil,
        [mfWriteOnly]);
      MainProgram := CreateProgram(FileName);

      // create kernel and specify arguments
      Kernel := MainProgram.CreateKernel('render');
      Kernel.SetArg(0, InputBuffer);
      Kernel.SetArg(1, OutputBuffer);
      Kernel.SetArg(2, SizeOf(@Width), @Width);
      Kernel.SetArg(3, SizeOf(@Height), @Height);

      // execute kernel
      CommandQueue.Execute(Kernel, Width * Height);

      CommandQueue.ReadBuffer(OutputBuffer, Width * Height * 4 * SizeOf(Byte),
        @HostImageOut[0]);
      SaveToFile(ExtractFilePath(ParamStr(0)) + 'Example3.bmp');
      FreeAndNil(Kernel);
      FreeAndNil(MainProgram);
      FreeAndNil(OutputBuffer);
      FreeAndNil(InputBuffer);
    finally
      FreeAndNil(CommandQueue);
    end;
  finally
    FreeAndNil(Platforms);
  end;

  Writeln('press any key...');
  Readln;
end.
