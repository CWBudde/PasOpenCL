program OpenCL_Info;

uses
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
