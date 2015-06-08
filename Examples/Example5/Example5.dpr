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
program Example5;

uses
  CL_Platform in '..\..\Source\CL_Platform.pas',
  CL in '..\..\Source\CL.pas',
  CL_GL in '..\..\Source\CL_GL.pas',
  DelphiCL in '..\..\Source\DelphiCL.pas',
  SimpleImageLoader in '..\..\Source\SimpleImageLoader.pas',
  Forms,
  MainUnit in 'MainUnit.pas' {FormMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
