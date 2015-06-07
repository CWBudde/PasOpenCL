(************************************************************************)
(*                                                                      *)
(*                       OpenCL1.2 and Delphi                           *)
(*                                                                      *)
(*      project site    : http://code.google.com/p/delphi-opencl/       *)
(*                                                                      *)
(*      file name       : Example1.dpr                                  *)
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
program Example1;

{$APPTYPE CONSOLE}
{$INCLUDE ..\Libs\OpenCL\OpenCL.inc}

uses
  CL_platform in '..\Libs\OpenCL\CL_platform.pas',
  CL in '..\Libs\OpenCL\CL.pas',
  CL_GL in '..\Libs\OpenCL\CL_GL.pas',
  DelphiCL in '..\Libs\OpenCL\DelphiCL.pas',
  dglOpenGL in '..\Libs\dglOpenGL.pas',
  SysUtils;

const
  COUNT = 100;
  SIZE = COUNT*SizeOf(TCL_int);

var
  Platforms: TDCLPlatforms;
  CommandQueue: TDCLCommandQueue;
  SimpleProgram: TDCLProgram;
  Kernel : TDCLKernel;
  Input,Output: Array [0..COUNT-1]of TCL_int;
  InputBuffer,OutputBuffer: TDCLBuffer;
  i: Integer;
begin
  InitOpenCL();
  Platforms := TDCLPlatforms.Create();
  with Platforms.Platforms[0]^.DeviceWithMaxClockFrequency^ do
  begin
    CommandQueue := CreateCommandQueue();
    for i:=0 to COUNT-1 do Input[i]:= i;
    InputBuffer := CreateBuffer(SIZE,@Input,[mfReadOnly,mfUseHostPtr]);//If dynamical array @Input[0]
    OutputBuffer := CreateBuffer(SIZE,nil,[mfWriteOnly]);
    SimpleProgram := CreateProgram(ExtractFilePath(ParamStr(0))+'Example1.cl');
    SimpleProgram.SaveToFile('example1.bin');
    Kernel := SimpleProgram.CreateKernel('somekernel');
    Kernel.SetArg(0,InputBuffer);
    Kernel.SetArg(1,OutputBuffer);
    CommandQueue.Execute(Kernel,COUNT);
    Writeln('Execution time: ',CommandQueue.ExecuteTime,' ns.');
    CommandQueue.ReadBuffer(OutputBuffer,SIZE,@Output);//If dynamical array @Output[0]
    FreeAndNil(Kernel);
    FreeAndNil(SimpleProgram);
    FreeAndNil(OutputBuffer);
    FreeAndNil(InputBuffer);
    FreeAndNil(CommandQueue);
  end;
  FreeAndNil(Platforms);

  for i:=0 to COUNT-1 do Writeln(Output[i],' ');

  Writeln('press any key...');
  Readln;
end.
