unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dglOpenGL, ExtCtrls, ImgList, ImageList, StdCtrls, ComCtrls, JPEG,
  CL, CL_Platform, CLExt, CL_D3D9, CL_GL, CL_Ext, oclUtils;

type
  TFormOpenCLInfo = class(TForm)
    ButtonClose: TButton;
    ComboBoxDevice: TComboBox;
    GroupBoxAbout: TGroupBox;
    GroupBoxInfo: TGroupBox;
    GroupBoxPlatform: TGroupBox;
    ImageAMD: TImage;
    ImageList: TImageList;
    ImageNV: TImage;
    LabelCommonPlatform: TLabel;
    LabelCommonType: TLabel;
    LabelCommonVendor: TLabel;
    LabelCommonVersion: TLabel;
    LabelExtensions: TLabel;
    LabelPlatform: TLabel;
    LabelProfile: TLabel;
    LabelVendor: TLabel;
    LabelVersion: TLabel;
    MemoCommonExt: TMemo;
    MemoInfo: TMemo;
    PageControl: TPageControl;
    TabSheetAbout: TTabSheet;
    TabSheetInfo: TTabSheet;
    TabSheetPlatform: TTabSheet;
    TreeView: TTreeView;
    procedure FormCreate(Sender: TObject);
    procedure ComboBoxDeviceChange(Sender: TObject);
    procedure ButtonCloseClick(Sender: TObject);
  public
    FCurrentDevice: PCL_device_id;
    FCurrentInDevice: PCL_device_id;
    FContext: PCL_context;
    FStatus: TCL_int;
    FDevNum: TCL_int;
    FBuf: array [0..1023] of AnsiChar;
    FSize: TSize_t;
    FBool: Tcl_bool;
    FuLong: TCL_ulong;
    FLong: TCL_uint;
    FVecs: array [0..4] of TSize_t;
    FVecl: array [0..4] of TCL_uint;
    FPlatform: PCL_platform_id;
  end;

const
  Nvd: AnsiString = 'NVIDIA Corporation';
  ATI_AMDd: AnsiString = 'ATI Technologies Inc.';

  NV_DRIVER = 'OpenCL.dll';
  ATI_AMD_DRIVER = 'atiocl.dll';//'OpenCL.dll'

var
  FormOpenCLInfo: TFormOpenCLInfo;

implementation

{$R *.dfm}

var
  CPS: array [0..2] of PCL_context_properties = (
    pcl_context_properties(cl_context_platform), nil, nil);

procedure TFormOpenCLInfo.ComboBoxDeviceChange(Sender: TObject);
var
  node: TTreeNode;
  node2: TTreeNode;

  procedure ParseExtensions(const Ext: AnsiString);
  var
    i: Integer;
    OldStep: Integer;
  begin
    node2 := TreeView.Items.AddChild(node, 'Extensions:');
    OldStep := 1;
    for i := 1 to Length(Ext) do
     if Ext[i] = ' ' then begin
       TreeView.Items.AddChild(node2, Copy(Ext, OldStep, i));
       OldStep := i;
     end;
  end;

begin
  FCurrentDevice := oclGetDev(FContext, ComboBoxDevice.ItemIndex);
  FCurrentInDevice := FCurrentDevice;

  //first page - platform
  TreeView.Items.Clear;
  node := TreeView.Items.Add(nil, 'Platform');
  FStatus := clGetPlatformInfo(FPlatform, CL_PLATFORM_NAME, SizeOf(FBuf), @FBuf, nil);
  LabelCommonPlatform.Caption := string(FBuf);
  TreeView.Items.AddChild(node, 'Name: ' + FBuf);

  FStatus := clGetPlatformInfo(FPlatform, CL_PLATFORM_VERSION, SizeOf(FBuf), @FBuf, nil);
  LabelCommonVersion.Caption := string(FBuf);
  TreeView.Items.AddChild(node, 'Version: ' + FBuf);

  FStatus := clGetPlatformInfo(FPlatform, CL_PLATFORM_VENDOR, SizeOf(FBuf), @FBuf, nil);
  LabelCommonVendor.Caption := string(FBuf);
  TreeView.Items.AddChild(node, 'Vendor: ' + FBuf);

  FStatus := clGetPlatformInfo(FPlatform, CL_PLATFORM_PROFILE, SizeOf(FBuf), @FBuf, nil);
  LabelCommonType.Caption := string(FBuf);
  TreeView.Items.AddChild(node, 'Type: ' + FBuf);

  FStatus := clGetPlatformInfo(FPlatform, CL_PLATFORM_EXTENSIONS, SizeOf(FBuf), @FBuf, nil);
  MemoCommonExt.Text := string(FBuf);
  ParseExtensions(FBuf);

  //Device
  node := TreeView.Items.Add(nil, 'Device');

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_NAME, SizeOf(FBuf), @FBuf, nil);
  TreeView.Items.AddChild(node, 'Name: ' + FBuf);

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_VERSION, SizeOf(FBuf), @FBuf, nil);
  TreeView.Items.AddChild(node, 'Version: ' + FBuf);

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_VENDOR, SizeOf(FBuf), @FBuf, nil);
  TreeView.Items.AddChild(node, 'Vendor: ' + FBuf);

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_TYPE, SizeOf(FuLong), @FuLong, nil);
  if (FuLong and CL_DEVICE_TYPE_CPU) <> 0 then
   TreeView.Items.AddChild(node, 'Type: CPU');
  if (FuLong and CL_DEVICE_TYPE_GPU) <> 0 then
   TreeView.Items.AddChild(node, 'Type: GPU');
  if (FuLong and CL_DEVICE_TYPE_ACCELERATOR) <> 0 then
   TreeView.Items.AddChild(node, 'Type: Accelerator');
  if (FuLong and CL_DEVICE_TYPE_Default) <> 0 then
   TreeView.Items.AddChild(node, 'Type: Default');
//  if (FuLong and CL_DEVICE_TYPE_All) <> 0 then
//   TreeView.Items.AddChild(node, 'Type: All');

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_EXTENSIONS, SizeOf(FBuf), @FBuf, nil);
  ParseExtensions(FBuf);

  //compute unit
  node := TreeView.Items.Add(nil, 'Compute Unit');

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_MAX_COMPUTE_UNITS, SizeOf(FSize), @FSize, nil);
  TreeView.Items.AddChild(node, 'Cores: ' + IntToStr(FSize));

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_MAX_CLOCK_FREQUENCY, SizeOf(FSize), @FSize, nil);
  TreeView.Items.AddChild(node, 'Clock: ' + IntToStr(FSize) + 'Mhz');

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_ADDRESS_BITS, SizeOf(FSize), @FSize, nil);
  TreeView.Items.AddChild(node, 'BitsWidth: ' + IntToStr(FSize));

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_MAX_WORK_GROUP_SIZE, SizeOf(FSize), @FSize, nil);
  TreeView.Items.AddChild(node, 'GroupSize: ' + IntToStr(FSize));

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_MAX_WORK_ITEM_SIZES , SizeOf(FSize), @FSize, nil);
  TreeView.Items.AddChild(node, 'ItemSize: ' + IntToStr(FSize));

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS, SizeOf(FSize), @FSize, nil);
  TreeView.Items.AddChild(node, 'GridDimansions: ' + IntToStr(FSize));

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_MAX_MEM_ALLOC_SIZE, SizeOf(FSize), @FSize, nil);
  TreeView.Items.AddChild(node, 'MemoryAllocSize: ' + IntToStr(FSize));

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_GLOBAL_MEM_SIZE, SizeOf(FuLong), @FuLong, nil);
  TreeView.Items.AddChild(node, 'GlobalMemorySize: ' + IntToStr(Round(FuLong / (1024 * 1024))) + ' MByte');

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE, SizeOf(FuLong), @FuLong, nil);
  TreeView.Items.AddChild(node, 'GlobalMemoryCacheLineSize: ' + IntToStr(Round(FuLong / 1024)) + ' KByte');

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_GLOBAL_MEM_CACHE_SIZE, SizeOf(FuLong), @FuLong, nil);
  TreeView.Items.AddChild(node, 'GlobalMemoryCacheSize: ' + IntToStr(Round(FuLong / 1024)) + ' KByte');

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_GLOBAL_MEM_SIZE, SizeOf(FuLong), @FuLong, nil);
  TreeView.Items.AddChild(node, 'GlobalMemorySize: ' + IntToStr(Round(FuLong / (1024 * 1024))) + ' MByte');

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_ERROR_CORRECTION_SUPPORT, SizeOf(FBool), @FBool, nil);
  if FBool = 0 then
   TreeView.Items.AddChild(node, 'ErrorCorrectionSupport: False')
  else
   TreeView.Items.AddChild(node, 'ErrorCorrectionSupport: True');

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_LOCAL_MEM_TYPE, SizeOf(FSize), @FSize, nil);
  if FSize = 1 then
   TreeView.Items.AddChild(node, 'LocalMemoryType: Local')
  else
   TreeView.Items.AddChild(node, 'LocalMemoryType: Global');

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_LOCAL_MEM_SIZE, SizeOf(FuLong), @FuLong, nil);
  TreeView.Items.AddChild(node, 'LocalMemorySize: ' + IntToStr(Round(FuLong / 1024)) + ' KByte');

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_QUEUE_PROPERTIES, SizeOf(FuLong), @FuLong, nil);
  if (FuLong and CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE) <> 0 then
   TreeView.Items.AddChild(node, 'QueueProperties: CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE');
  if (FuLong and CL_QUEUE_PROFILING_ENABLE) <> 0 then
   TreeView.Items.AddChild(node, 'QueueProperties: CL_QUEUE_PROFILING_ENABLE');

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_IMAGE_SUPPORT, SizeOf(FBool), @FBool, nil);
  if FBool = 0 then
   TreeView.Items.AddChild(node, 'ImageSupport: False');
  if FBool = 1 then
   TreeView.Items.AddChild(node, 'ImageSupport: True');

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_MAX_READ_IMAGE_ARGS, SizeOf(FuLong), @FuLong, nil);
  TreeView.Items.AddChild(node, 'MaxReadImageARGS: ' + IntToStr(FuLong));

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_MAX_WRITE_IMAGE_ARGS, SizeOf(FuLong), @FuLong, nil);
  TreeView.Items.AddChild(node, 'MaxWriteImageARGS: ' + IntToStr(FuLong));

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_MAX_READ_IMAGE_ARGS, SizeOf(FuLong), @FuLong, nil);
  TreeView.Items.AddChild(node, 'MaxReadImageARGS: ' + IntToStr(FuLong));

  node2 := TreeView.Items.AddChild(node, 'PreferredVectorWidth:');
  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR, SizeOf(FLong), @FLong, nil);
  TreeView.Items.AddChild(node2, 'Char: ' + IntToStr(FLong));

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT, SizeOf(FLong), @FLong, nil);
  TreeView.Items.AddChild(node2, 'Short: ' + IntToStr(FLong));

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT, SizeOf(FLong), @FLong, nil);
  TreeView.Items.AddChild(node2, 'Int: ' + IntToStr(FLong));

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG, SizeOf(FLong), @FLong, nil);
  TreeView.Items.AddChild(node2, 'Long: ' + IntToStr(FLong));

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT, SizeOf(FLong), @FLong, nil);
  TreeView.Items.AddChild(node2, 'Float: ' + IntToStr(FLong));

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE, SizeOf(FLong), @FLong, nil);
  TreeView.Items.AddChild(node2, 'Double: ' + IntToStr(FLong));

  //DeviceImage
  node := TreeView.Items.Add(nil, 'Image');

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_IMAGE2D_MAX_WIDTH, SizeOf(FVecs[0]), @FVecs[0], nil);
  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_IMAGE2D_MAX_HEIGHT, SizeOf(FVecs[0]), @FVecs[1], nil);
  TreeView.Items.AddChild(node, '2DMax: ' + IntToStr(FVecs[0]) + 'x' + IntToStr(FVecs[1]));

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_IMAGE3D_MAX_WIDTH, SizeOf(FVecs[0]), @FVecs[0], nil);
  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_IMAGE3D_MAX_HEIGHT, SizeOf(FVecs[0]), @FVecs[1], nil);
  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_IMAGE3D_MAX_HEIGHT, SizeOf(FVecs[0]), @FVecs[2], nil);
  TreeView.Items.AddChild(node, '3DMax: ' + IntToStr(FVecs[0]) + 'x' + IntToStr(FVecs[1]) + 'x' + IntToStr(FVecs[2]));

  //NV Device
  node := TreeView.Items.Add(nil, 'NV');

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_NV_DEVICE_COMPUTE_CAPABILITY_MAJOR, SizeOf(FVecl[0]), @FVecl[0], nil);
  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_NV_DEVICE_COMPUTE_CAPABILITY_MINOR, SizeOf(FVecl[0]), @FVecl[1], nil);
  TreeView.Items.AddChild(node, 'ComputeCapability: ' + IntToStr(FVecl[0]) + '.' + IntToStr(FVecl[1]));

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_NV_DEVICE_REGISTERS_PER_BLOCK, SizeOf(FLong), @FLong, nil);
  TreeView.Items.AddChild(node, 'RegistersPerBlock: ' + IntToStr(FLong));

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_NV_DEVICE_WARP_SIZE, SizeOf(FLong), @FLong, nil);
  TreeView.Items.AddChild(node, 'WarpSize: ' + IntToStr(FLong));

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_NV_DEVICE_GPU_OVERLAP, SizeOf(FBool), @FBool, nil);
  TreeView.Items.AddChild(node, 'GPU_Overlap: ' + IntToStr(FBool));

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_NV_DEVICE_KERNEL_EXEC_TIMEOUT, SizeOf(FBool), @FBool, nil);
  TreeView.Items.AddChild(node, 'KernelExecTimeOut: ' + IntToStr(FBool));

  FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_NV_DEVICE_INTEGRATED_MEMORY, SizeOf(FBool), @FBool, nil);
  TreeView.Items.AddChild(node, 'IntegratedMemory: ' + IntToStr(FBool));
end;

procedure TFormOpenCLInfo.FormCreate(Sender: TObject);
var
  SysDir: array [0..(MAX_PATH - 1)] of AnsiChar;
  l: Cardinal;
  FVendor: AnsiString;
  FRC: HGLRC;
  FDC: HDC;
  pfd: TPixelFormatDescriptor;
  FOCL: AnsiString;
  i: Integer;
begin
  l := MAX_PATH;
  GetSystemDirectoryA(@SysDir[0], l);

{$IFNDEF VER150}
{$REGION 'GetVendor'}
{$ENDIF}
  FillChar(pfd, SizeOf(pfd), 0);
  with pfd do
  begin
    nSize := SizeOf(pfd);
    nVersion := 1;
    dwFlags := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
    iPixelType := PFD_TYPE_RGBA;
    cColorBits := 32;
    cDepthBits := 24;
    cStencilBits := 8;
    iLayerType := PFD_MAIN_PLANE;
  end;

  InitOpenGL;
  DeactivateRenderingContext;
  FDC := GetDC(FormOpenCLInfo.Handle);

  SetPixelFormat(FDC, ChoosePixelFormat(FDC, @pfd), @pfd);

  FRC := dglOpenGL.wglCreateContext(FDC);
  wglMakeCurrent(FDC, FRC);
  ReadImplementationProperties;
  ReadExtensions;
  FVendor     := glGetString(GL_VERSION);
  FVendor := glGetString(GL_VENDOR);
  wglMakeCurrent(0, 0);
  wglDeleteContext(FRC);
  ReleaseDC(FormOpenCLInfo.Handle, FDC);
{$IFNDEF VER150}
{$ENDREGION}
{$ENDIF}

  if FVendor = Nvd then
   FOCL := NV_DRIVER
  else
   if FVendor = ATI_AMDd then
    FOCL := ATI_AMD_DRIVER;

  if FVendor = Nvd then
   ImageNV.Visible := True
  else
   if FVendor = ATI_AMDd then
    ImageAMD.Visible := True;

  if not InitOpenCL(string(FOCL)) then begin
    MessageBoxA(Handle, 'InitOpenCL - fail', 'Error', MB_OK or MB_ICONERROR);
    Exit;
  end;

  InitCL_EXT;
//  InitCL_OGL;
  InitCL_D3D9;
//  InitCL_D3D10;

  FStatus := clGetPlatformIDs(1, @FPlatform, nil);
  if FStatus <> CL_SUCCESS then begin
    MessageBoxA(Handle, PAnsiChar(GetString(FStatus)), 'Error', MB_OK or MB_ICONERROR);
    Close;
    Exit;
  end;

  CPS[1] := pcl_context_properties(FPlatform);
  FContext := clCreateContextFromType(@CPS, CL_DEVICE_TYPE_ALL, nil, nil, @Fstatus);
  if FStatus <> CL_SUCCESS then begin
    MessageBoxA(Handle, PAnsiChar(GetString(FStatus)), 'Error', MB_OK or MB_ICONERROR);
    Close;
    Exit;
  end;

  FStatus := clGetContextInfo(FContext, CL_CONTEXT_DEVICES, 0, nil, @FDevNum);
  if FStatus <> CL_SUCCESS then begin
    MessageBoxA(0, PAnsiChar(GetString(FStatus)), 'Error', MB_OK or MB_ICONERROR);
    Close;
    Exit;
  end;

  if FDevNum <= 0 then
  begin
    MessageBox(Handle, PWideChar(string(GetString(FStatus))), 'Error', MB_OK or MB_ICONERROR);
    Close;
    Exit;
  end;

  for i := 0 to Round(FDevNum / 4) - 1 do
  begin
    FCurrentDevice := oclGetDev(FContext, i);
    FCurrentInDevice := FCurrentDevice;
    FStatus := clGetDeviceInfo(PCL_device_id(FCurrentInDevice), CL_DEVICE_NAME, SizeOf(FBuf), @FBuf, nil);
    if FStatus <> CL_SUCCESS then
    begin
      MessageBox(Handle, PWideChar(string(GetString(FStatus))), 'Error', MB_OK or MB_ICONERROR);
      Close;
      Exit;
    end;
    ComboBoxDevice.Items.Add('[' + IntToStr(i) + '] ' + string(FBuf));
  end;
  ComboBoxDevice.ItemIndex := 0;
  ComboBoxDeviceChange(Sender);
end;

procedure TFormOpenCLInfo.ButtonCloseClick(Sender: TObject);
begin
  Close;
end;

end.
