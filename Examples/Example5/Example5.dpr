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
program Example5;

uses
  CL_platform in '..\Libs\OpenCL\CL_platform.pas',
  CL in '..\Libs\OpenCL\CL.pas',
  CL_GL in '..\Libs\OpenCL\CL_GL.pas',
  DelphiCL in '..\Libs\OpenCL\DelphiCL.pas',
  SimpleImageLoader in '..\Libs\OpenCL\SimpleImageLoader.pas',
  dglOpenGL in '..\Libs\dglOpenGL.pas',
  Forms,
  MainUnit in 'MainUnit.pas' {fMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.
