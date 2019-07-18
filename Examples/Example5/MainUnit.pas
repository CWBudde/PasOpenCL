(************************************************************************)
(*                                                                      *)
(*                       OpenCL1.2 and Delphi                           *)
(*                                                                      *)
(*      project site    : http://code.google.com/p/delphi-opencl/       *)
(*                                                                      *)
(*      file name       : MainUnit.pas                                  *)
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

unit MainUnit;

interface

{-$DEFINE GL_INTEROP}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, ExtCtrls,
  Dialogs, dglOpenGL, CL_Platform, CL, CL_GL, DelphiCL;

type
  TFormMain = class(TForm)
    TimerRecalculate: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TimerRecalculateTimer(Sender: TObject);
  private
    FDC: HDC;
    FRC: HGLRC;

    FPlatforms: TDCLPlatforms;
    FDevice: PDCLDevice;
    FCommand: TDCLCommandQueue;
    FProgram: TDCLProgram;
    FKernel: TDCLKernel;

    FRotateX, FRotateY: TCL_float;
    FTranslateZ: TCL_float;
    FAnim: TCL_float;

    FMouseOldX, FMouseOldy: Integer;
    FMouseButtons: Integer;

    procedure InitGL;
    procedure IdleHandler(Sender : TObject; var Done : Boolean);
    procedure Render;
    procedure CreateVBO(const VBO: PGLuint);
    procedure DeleteVBO(const VBO: PGLuint);
    procedure Motion(x,y: Integer);
    procedure CleanUp;
    procedure DisplayGL;
    procedure RunKernel;
  public
  end;

var
  FormMain: TFormMain;

  vbo_cl: TDCLBuffer;
  vbo: TGLuint;

  iFrameCount: Integer = 0;
  iFrameTrigger: Integer = 90;
  iFramePerSec: Integer = 0;
  iTestSets: Integer = 3;

  g_Index: Integer = 0;
  bQATest: Boolean = False;
  g_bFBODisplay: Boolean = False;
  bNoPrompt: Boolean = False;

const
  iRefFrameNumber: Integer = 4;
  window_width = 512;
  window_height = 512;
  mesh_width: TCL_uint = 256;
  mesh_height: TCL_uint = 256;

implementation

{$R *.dfm}

procedure TFormMain.FormCreate(Sender: TObject);
var
  FileName: TFileName;
begin
  FDC := GetDC(Handle);
  if (not InitOpenGL)or(not InitOpenCL) then
    Application.Terminate;
  ReadExtensions;
  InitCL_GL;
  FRC := CreateRenderingContext(FDC, [opDoubleBuffered], 32, 24, 0, 0, 0, 0);
  ActivateRenderingContext(FDC, FRC);
  InitGL;

  FRotateX := 0.0;
  FRotateY := 0.0;
  FTranslateZ := -3.0;
  FAnim := 0.0;
  FMouseButtons := 0;

  // specify program
  FileName := ExtractFilePath(ParamStr(0)) +  '..\..\Resources\SimpleGL.cl';
  Assert(FileExists(FileName));

  FPlatforms := TDCLPlatforms.Create;
  FDevice := FPlatforms.Platforms[0]^.DeviceWithMaxClockFrequency;
  FCommand := FDevice.CreateCommandQueue({$IFDEF GL_INTEROP}FDevice.CreateContextGL{$ENDIF});
  FProgram := FDevice.CreateProgram(FileName);
  FKernel := FProgram.CreateKernel('sine_wave');

  CreateVBO(@vbo);

  FKernel.SetArg(0, vbo_cl);
  FKernel.SetArg(1, SizeOf(TCL_uint), @mesh_width);
  FKernel.SetArg(2, SizeOf(TCL_uint), @mesh_height);
  FCommand.Execute(FKernel, [mesh_width, mesh_height]);

  TimerRecalculate.Enabled := True;
  Application.OnIdle := IdleHandler;
end;

procedure TFormMain.IdleHandler(Sender: TObject; var Done: Boolean);
begin
  Render;
  Sleep(1);
  Done := False;
end;

procedure TFormMain.InitGL;
begin
  glClearColor(0.0, 0.0, 0.0, 1.0);
  glDisable(GL_DEPTH_TEST);
  glViewport(0, 0, window_width, window_height);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(60.0, window_width / window_height, 0.1, 10.0);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glTranslatef(0.0, 0.0, FTranslateZ);
  glRotatef(FRotateX, 1.0, 0.0, 0.0);
  glRotatef(FRotateY, 0.0, 1.0, 0.0);
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  TimerRecalculate.Enabled := False;
  CleanUp;
  DeactivateRenderingContext;
  DestroyRenderingContext(FRC);
  ReleaseDC(Handle, FDC);
end;

procedure TFormMain.Render;
begin
  DisplayGL;
  SwapBuffers(FDC);
end;

procedure TFormMain.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #27) or (Key = 'Q') or (Key = 'q') then
    Application.Terminate;
end;

procedure TFormMain.CreateVBO(const VBO: PGLuint);
var
  Size: TGLsizei;
begin
  glGenBuffers(1, vbo);
  glBindBuffer(GL_ARRAY_BUFFER, vbo^);
  Size := mesh_width * mesh_height * 4 * SizeOf(TCL_float);
  glBufferData(GL_ARRAY_BUFFER, Size, nil, GL_DYNAMIC_DRAW);
{$IFDEF GL_INTEROP}
  vbo_cl := FDevice.CreateFromGLBuffer(vbo, [mfWriteOnly]);
{$ELSE}
  vbo_cl := FDevice.CreateBuffer(Size, nil, [mfWriteOnly]);
{$ENDIF}
end;

procedure TFormMain.DeleteVBO(const VBO: PGLuint);
begin
  FreeAndNil(vbo_cl);
  glBindBuffer(1, vbo^);
  glDeleteBuffers(1, vbo);
  vbo^ := 0;
end;

procedure TFormMain.CleanUp;
begin
  DeleteVBO(@vbo);
  FreeAndNil(FKernel);
  FreeAndNil(FProgram);
  FreeAndNil(FCommand);
  FreeAndNil(FPlatforms);
end;

procedure TFormMain.Motion(x, y: Integer);
var
  dx, dy: TCL_float;
begin
  dx := x - FMouseOldX;
  dy := y - FMouseOldy;
  if (FMouseButtons and 1) <> 0 then
  begin
    FRotateX := FRotateX + dy * 0.2;
    FRotateY := FRotateY + dx * 0.2;
  end
  else
    if (FMouseButtons and 4) <> 0 then
      FTranslateZ := FTranslateZ + dy * 0.01;
  FMouseOldX := x;
  FMouseOldy := y;
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glTranslatef(0.0, 0.0, FTranslateZ);
  glRotatef(FRotateX, 1.0, 0.0, 0.0);
  glRotatef(FRotateY, 0.0, 1.0, 0.0);
end;

procedure TFormMain.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FMouseButtons := FMouseButtons or (1 shl Integer(button));
  FMouseOldX := x;
  FMouseOldy := y;
end;

procedure TFormMain.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FMouseButtons := 0;
  FMouseOldX := x;
  FMouseOldy := y;
end;

procedure TFormMain.DisplayGL;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  glVertexPointer(4, GL_FLOAT, 0, nil);
  glEnableClientState(GL_VERTEX_ARRAY);
  glColor3f(1.0, 0.0, 0.0);
  glDrawArrays(GL_POINTS, 0, mesh_width * mesh_height);
  glDisableClientState(GL_VERTEX_ARRAY);
end;

procedure TFormMain.RunKernel;
var
  szGlobalWorkSize: Array [0..1] of TSize_t;
{$IFNDEF GL_INTEROP}
  ptr: PGLvoid;
{$ENDIF}
begin
{$IFDEF GL_INTEROP}
  FCommand.AcquireGLObject(vbo_cl);
{$ENDIF}
  szGlobalWorkSize[0] := mesh_width;
  szGlobalWorkSize[1] := mesh_height;
  FKernel.SetArg(3, SizeOf(TCL_float), @FAnim);
  FCommand.Execute(FKernel, szGlobalWorkSize);
{$IFDEF GL_INTEROP}
  FCommand.ReleaseGLObject(vbo_cl);
{$ELSE}
  glBindBufferARB(GL_ARRAY_BUFFER, vbo);
  ptr := glMapBufferARB(GL_ARRAY_BUFFER, GL_WRITE_ONLY_ARB);
  FCommand.ReadBuffer(vbo_cl, SizeOf(TCL_float) * 4 * mesh_height * mesh_width,ptr);
  glUnmapBufferARB(GL_ARRAY_BUFFER);
{$ENDIF}
end;

procedure TFormMain.TimerRecalculateTimer(Sender: TObject);
begin
  Motion(Mouse.CursorPos.X, Mouse.CursorPos.Y);
  FAnim := FAnim + 0.1;
  RunKernel;
end;

end.
