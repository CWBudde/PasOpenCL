program OpenCL_Info;

uses
  CL_Platform in '..\..\Source\CL_Platform.pas',
  CL in '..\..\Source\CL.pas',
  CL_GL in '..\..\Source\CL_GL.pas',
  CLExt in '..\..\Source\CLExt.pas',
  CL_D3D9 in '..\..\Source\CL_D3D9.pas',
  CL_Ext in '..\..\Source\CL_Ext.pas',
  Forms,
  Main in 'Main.pas' {FormOpenCLInfo},
  oclUtils in 'oclUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormOpenCLInfo, FormOpenCLInfo);
  Application.Run;
end.
