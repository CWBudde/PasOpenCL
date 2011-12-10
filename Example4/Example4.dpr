(************************************************************************)
(*                                                                      *)
(*                       OpenCL1.2 and Delphi                           *)
(*                                                                      *)
(*      project site    : http://code.google.com/p/delphi-opencl/       *)
(*                                                                      *)
(*      file name       : Example4.pas                                  *)
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
program Example4;

{$APPTYPE CONSOLE}
{$INCLUDE ..\..\Libs\OpenCL\OpenCL.inc}

uses
  CL_platform in '..\Libs\OpenCL\CL_platform.pas',
  CL in '..\Libs\OpenCL\CL.pas',
  DelphiCL in '..\Libs\OpenCL\DelphiCL.pas',
  SimpleImageLoader in '..\Libs\OpenCL\SimpleImageLoader.pas',
  Graphics,
  SysUtils;

const
  InputFileName = 'Lena.bmp';
  OutputFileName = 'Example4.bmp';

var
  CommandQueue: TDCLCommandQueue;
  MainProgram: TDCLProgram;
  Kernel : TDCLKernel;
  InputImage,OutputImage: TDCLImage2D;
  ImageLoader: TImageLoader;
begin
  InitOpenCL();

  with TDCLPlatforms.Create().Platforms[0].DeviceWithMaxClockFrequency do
  begin
    CommandQueue:= CreateCommandQueue();
    ImageLoader:= TImageLoader.Create(ExtractFilePath(ParamStr(0))+InputFileName);
    with ImageLoader do InputImage:= CreateImage2D(Format,Width,Height,0,ImageLoader.Pointer,[mfReadOnly, mfUseHostPtr]);
    with ImageLoader do OutputImage:= CreateImage2D(Format,Width,Height,0,nil,[mfReadWrite, mfAllocHostPtr]);
    MainProgram := CreateProgram(ExtractFilePath(ParamStr(0))+'Example4.cl');
    Kernel := MainProgram.CreateKernel('main');
    Kernel.SetArg(0,InputImage);
    Kernel.SetArg(1,OutputImage);
    CommandQueue.Execute(Kernel,[ImageLoader.Width,ImageLoader.Height]);
    ImageLoader.Resize(ImageLoader.Width,ImageLoader.Height);//Dispose and Get Memory
    CommandQueue.ReadImage2D(OutputImage,ImageLoader.Width,ImageLoader.Height,ImageLoader.Pointer);
    ImageLoader.SaveToFile(ExtractFilePath(ParamStr(0))+OutputFileName);
    ImageLoader.Free();
    Kernel.Free();
    MainProgram.Free();
    InputImage.Free();
    OutputImage.Free();
    CommandQueue.Free();
  end;

  Writeln('press any key...');
  Readln;
end.
