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

{$DEFINE GL_INTEROP}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ExtCtrls,
  Dialogs,
  dglOpenGL,
  cl_platform,CL,cl_gl,DelphiCL;

type
  TfMain = class(TForm)
    tRecalculate: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tRecalculateTimer(Sender: TObject);
  private
    { Private declarations }
    FDC: HDC;
    FRC: HGLRC;
    procedure InitGL();
    procedure IdleHandler(Sender : TObject; var Done : Boolean);
    procedure Render();
    procedure CreateVBO(const VBO: PGLuint);
    procedure DeleteVBO(const VBO: PGLuint);
    procedure Motion(x,y: Integer);
    procedure CleanUp();
    procedure DisplayGL();
    procedure runKernel();
  public
    { Public declarations }
  end;

var
  fMain: TfMain;

  Platforms: TDCLPlatforms;
  Device: PDCLDevice;
  Command: TDCLCommandQueue;
  Pro: TDCLProgram;
  Kernel: TDCLKernel;
  vbo_cl: TDCLBuffer;

  vbo: TGLuint;
  rotate_x: TCL_float = 0.0;
  rotate_y: TCL_float = 0.0;
  translate_z: TCL_float = -3.0;
  anim: TCL_float = 0.0;

  iFrameCount: Integer = 0;
  iFrameTrigger: Integer = 90;
  iFramePerSec: Integer = 0;
  iTestSets: Integer = 3;

  mouse_old_x, mouse_old_y: Integer;
  mouse_buttons: Integer = 0;

const
  iRefFrameNumber: Integer = 4;

var
  g_Index: Integer = 0;
  bQATest: Boolean = False;
  g_bFBODisplay: Boolean = False;
  bNoPrompt: Boolean = False;

const window_width = 512;
const window_height = 512;
const mesh_width: TCL_uint = 256;
const mesh_height: TCL_uint = 256;

implementation

{$R *.dfm}

procedure TfMain.FormCreate(Sender: TObject);
begin
  FDC:= GetDC(Handle);
  if (not InitOpenGL)or(not InitOpenCL)  then Application.Terminate;
  ReadExtensions;
  InitCL_GL;
  FRC:= CreateRenderingContext(FDC, [opDoubleBuffered], 32, 24,
                               0,0,0,0);
  ActivateRenderingContext(FDC, FRC);
  InitGL();

  Platforms := TDCLPlatforms.Create();
  Device := Platforms.Platforms[0]^.DeviceWithMaxClockFrequency;
  Command := Device.CreateCommandQueue({$IFDEF GL_INTEROP}Device.CreateContextGL(){$ENDIF});
  Pro := Device.CreateProgram(ExtractFilePath(Application.ExeName)+'simpleGL.cl');
  Kernel := Pro.CreateKernel('sine_wave');
  CreateVBO(@vbo);
  Kernel.SetArg(0,vbo_cl);
  Kernel.SetArg(1,SizeOf(TCL_uint),@mesh_width);
  Kernel.SetArg(2,SizeOf(TCL_uint),@mesh_height);
  Command.Execute(Kernel,[mesh_width,mesh_height]);
  tRecalculate.Enabled := True;
  Application.OnIdle := IdleHandler;
end;

procedure TfMain.IdleHandler(Sender: TObject; var Done: Boolean);
begin
  Render;
  Sleep(1);
  Done := False;
end;

procedure TfMain.InitGL;
begin
  glClearColor(0.0, 0.0, 0.0, 1.0);
  glDisable(GL_DEPTH_TEST);
  glViewport(0, 0, window_width, window_height);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective(60.0, window_width /  window_height, 0.1, 10.0);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  glTranslatef(0.0, 0.0, translate_z);
  glRotatef(rotate_x, 1.0, 0.0, 0.0);
  glRotatef(rotate_y, 0.0, 1.0, 0.0);
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
  tRecalculate.Enabled := False;
  CleanUp();
  DeactivateRenderingContext;
  DestroyRenderingContext(FRC);
  ReleaseDC(Handle, FDC);
end;

procedure TfMain.Render;
begin
  DisplayGL();
  SwapBuffers(FDC);
end;

procedure TfMain.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key=#27)or(Key='Q')or(Key='q')then Application.Terminate;
end;

procedure TfMain.CreateVBO(const VBO: PGLuint);
var
  size: TGLsizei;
begin
  glGenBuffers(1, vbo);
  glBindBuffer(GL_ARRAY_BUFFER, vbo^);
  size := mesh_width * mesh_height * 4 * sizeof(TCL_float);
  glBufferData(GL_ARRAY_BUFFER, size, nil, GL_DYNAMIC_DRAW);
{$IFDEF GL_INTEROP}
  vbo_cl := Device.CreateFromGLBuffer(vbo,[mfWriteOnly]);
{$ELSE}
  vbo_cl := Device.CreateBuffer(size,nil,[mfWriteOnly]);
{$ENDIF}
end;

procedure TfMain.DeleteVBO(const VBO: PGLuint);
begin
  FreeAndNil(vbo_cl);
  glBindBuffer(1, vbo^);
  glDeleteBuffers(1, vbo);
  vbo^ := 0;
end;

procedure TfMain.CleanUp;
begin
  DeleteVBO(@vbo);
  FreeAndNil(Kernel);
  FreeAndNil(Pro);
  FreeAndNil(Command);
  FreeAndNil(Platforms);
end;

procedure TfMain.Motion(x, y: Integer);
var
  dx,dy: TCL_float;
begin
  dx := x - mouse_old_x;
  dy := y - mouse_old_y;
  if (mouse_buttons and 1)<>0 then
  begin
    rotate_x := rotate_x + dy * 0.2;
    rotate_y := rotate_y + dx * 0.2;
  end
  else
    if (mouse_buttons and 4)<>0 then
    begin
      translate_z := translate_z + dy * 0.01;
    end;
  mouse_old_x := x;
  mouse_old_y := y;
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  glTranslatef(0.0, 0.0, translate_z);
  glRotatef(rotate_x, 1.0, 0.0, 0.0);
  glRotatef(rotate_y, 0.0, 1.0, 0.0);
end;

procedure TfMain.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  mouse_buttons := mouse_buttons or (1 shl Integer(button));
  mouse_old_x := x;
  mouse_old_y := y;
end;

procedure TfMain.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  mouse_buttons := 0;
  mouse_old_x := x;
  mouse_old_y := y;
end;

procedure TfMain.DisplayGL;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  glVertexPointer(4, GL_FLOAT, 0, nil);
  glEnableClientState(GL_VERTEX_ARRAY);
  glColor3f(1.0, 0.0, 0.0);
  glDrawArrays(GL_POINTS, 0, mesh_width * mesh_height);
  glDisableClientState(GL_VERTEX_ARRAY);
end;

procedure TfMain.runKernel;
var
  szGlobalWorkSize: Array [0..1] of TSize_t;
{$IFNDEF GL_INTEROP}
  ptr: PGLvoid;
{$ENDIF}
begin
{$IFDEF GL_INTEROP}
  Command.AcquireGLObject(vbo_cl);
{$ENDIF}
  szGlobalWorkSize[0] := mesh_width;
  szGlobalWorkSize[1] := mesh_height;
  Kernel.SetArg(3,SizeOf(TCL_float),@anim);
  Command.Execute(Kernel,szGlobalWorkSize);
{$IFDEF GL_INTEROP}
  Command.ReleaseGLObject(vbo_cl);
{$ELSE}
  glBindBufferARB(GL_ARRAY_BUFFER, vbo);
  ptr := glMapBufferARB(GL_ARRAY_BUFFER,GL_WRITE_ONLY_ARB);
  Command.ReadBuffer(vbo_cl,SizeOf(TCL_float)*4 * mesh_height * mesh_width,ptr);
  glUnmapBufferARB(GL_ARRAY_BUFFER);
{$ENDIF}
end;

procedure TfMain.tRecalculateTimer(Sender: TObject);
begin
  Motion(Mouse.CursorPos.X,Mouse.CursorPos.Y);
  anim := anim + 0.1;
  runKernel();
end;

end.
 