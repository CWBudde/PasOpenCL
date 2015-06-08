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

program Example1;

{$APPTYPE CONSOLE}
{$INCLUDE ..\..\Source\OpenCL.inc}

uses
  CL_Platform in '..\..\Source\CL_Platform.pas',
  CL in '..\..\Source\CL.pas',
  CL_GL in '..\..\Source\CL_GL.pas',
  DelphiCL in '..\..\Source\DelphiCL.pas',
  SysUtils;

const
  COUNT = 100;
  SIZE = COUNT * SizeOf(TCL_int);

var
  Platforms: TDCLPlatforms;
  CommandQueue: TDCLCommandQueue;
  SimpleProgram: TDCLProgram;
  Kernel: TDCLKernel;
  Input, Output: array [0 .. COUNT - 1] of TCL_int;
  InputBuffer, OutputBuffer: TDCLBuffer;
  i: Integer;
begin
  InitOpenCL;
  Platforms := TDCLPlatforms.Create;
  with Platforms.Platforms[0]^.DeviceWithMaxClockFrequency^ do
  begin
    CommandQueue := CreateCommandQueue;
    try
      for i := 0 to COUNT - 1 do
        Input[i] := i;
      InputBuffer := CreateBuffer(SIZE, @Input, [mfReadOnly, mfUseHostPtr]); // If dynamical array @Input[0]
      OutputBuffer := CreateBuffer(SIZE, nil, [mfWriteOnly]);
      SimpleProgram := CreateProgram(ExtractFilePath(ParamStr(0)) +
        'Example1.cl');
      SimpleProgram.SaveToFile('Example1.bin');

      // create program and set arguments
      Kernel := SimpleProgram.CreateKernel('somekernel');
      Kernel.SetArg(0, InputBuffer);
      Kernel.SetArg(1, OutputBuffer);

      // execute kernel (and write execution time)
      CommandQueue.Execute(Kernel, COUNT);
      Writeln('Execution time: ', CommandQueue.ExecuteTime, ' ns.');

      // read buffer
      CommandQueue.ReadBuffer(OutputBuffer, SIZE, @Output); // If dynamical array @Output[0]

      FreeAndNil(Kernel);
      FreeAndNil(SimpleProgram);
      FreeAndNil(OutputBuffer);
      FreeAndNil(InputBuffer);
    finally
      FreeAndNil(CommandQueue);
    end;
  end;
  FreeAndNil(Platforms);

  for i := 0 to COUNT - 1 do
    Writeln(Output[i], ' ');

  Writeln('press any key...');
  Readln;
end.
