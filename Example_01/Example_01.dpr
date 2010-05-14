program Example_01;

{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  dglOpenGL,
  CL,
  cl_platform,
  oclUtils;

{$REGION 'GetDriver: AnsiString'}
function GetDriver: AnsiString;
const
  nvd: AnsiString = 'NVIDIA Corporation';
  ati_amdd: AnsiString = 'ATI Technologies Inc.';

  NV_DRIVER = 'OpenCL.dll';
  ATI_AMD_DRIVER = 'atiocl.dll';//'OpenCL.dll'
var
  SysDir: array [0..(MAX_PATH - 1)] of AnsiChar;
  l: Cardinal;
  FVendor: AnsiString;
  FRC: HGLRC;
  FDC: HDC;
  pfd: TPixelFormatDescriptor;
begin
  Result := '';
  l := MAX_PATH;
  GetSystemDirectoryA(@SysDir[0], l);

  if FileExists(AnsiString(SysDir) + '\' + NV_DRIVER) then
   Result := NV_DRIVER
  else
   Result := ATI_AMD_DRIVER;
end;
{$ENDREGION}

const
 SIZE = 2048;

var
  CPS: array [0..2] of PCL_context_properties = (
                                                  pcl_context_properties(cl_context_platform),
                                                  nil,
                                                  nil
                                                );
  Context: PCL_context;
  Current_device: PPCL_device_id;
  Current_indevice: Integer;
  Status: TCL_int;
  Dev_num: TCL_int;
  Platform_: PCL_platform_id;
  CommandQueue: PCL_command_queue;
  SrcA, SrcB: PCL_mem;
  Dst: PCL_mem;
  Source: PAnsiChar;
  program_length: TSize_t;
  Program_: PCL_program;
  Kernel: PCL_kernel;
//  WorkSize: PSize_t;
  i: Integer;
  N: TCL_int = 512;
  Data: array of TCL_float;
  mem: array [0..1] of PCL_mem;
  Log: AnsiString;
  LogSize: Integer;
begin
//  SIZE := 2048;
//  for i := 0 to SIZE - 1 do begin
//    HostVector1[i]:=InitialData1[i mod 20];
//    HostVector2[i]:=InitialData2[i mod 20];
//  end;
  if not InitOpenCL(GetDriver) then Exit;

  Status := clGetPlatformIDs(1, @Platform_, nil);
  if Status <> CL_SUCCESS then begin
    Writeln(GetString(Status));
    Exit;
  end;

  CPS[1] := pcl_context_properties(Platform_);
  Context:=clCreateContextFromType(@CPS, CL_DEVICE_TYPE_ALL, nil, nil, @Status);
  if Status <> CL_SUCCESS then begin
    Writeln(GetString(Status));
    Exit;
  end;

  Status := clGetContextInfo(Context, CL_CONTEXT_DEVICES, 0, nil, @Dev_num);
  if Status <> CL_SUCCESS then begin
    Writeln(GetString(Status));
    Exit;
  end;

  if Dev_num <= 0 then begin
    Writeln(GetString(Status));
    Exit;
  end;

  Current_device := oclGetDev(context, 0);
  Current_indevice := Integer(current_device^);
//  Status := clGetDeviceInfo(PCL_device_id(Current_indevice), CL_DEVICE_NAME, SizeOf(FBuf), @FBuf, nil);
  if Status <> CL_SUCCESS then begin
    Writeln(GetString(Status));
    Exit;
  end;

  CommandQueue :=clCreateCommandQueue(Context, PCL_device_id(Current_indevice), 0, @Status);
  if Status <> CL_SUCCESS then begin
    Writeln(GetString(Status));
    Exit;
  end;

  Source := oclLoadProgSource(ExtractFilePath(ParamStr(0)) + 'test.cl', '', @program_length);

  Program_ := clCreateProgramWithSource(Context, 1, @Source, @program_length, @Status);
  if Status <> CL_SUCCESS then begin
    Writeln(GetString(Status));
    Exit;
  end;

  Status := clBuildProgram(Program_, 0, nil, nil, nil, nil);
  if Status <> CL_SUCCESS then begin
    Writeln(GetString(Status));
//    Exit;
//    Readln;
    Status := clGetProgramBuildInfo(Program_, PCL_device_id(Current_indevice), CL_PROGRAM_BUILD_LOG, 0, nil, @LogSize);
    if Status <> CL_SUCCESS then begin
      Writeln(GetString(Status));
      Exit;
    end;

    SetLength(Log, LogSize);
    Status := clGetProgramBuildInfo(Program_, PCL_device_id(Current_indevice), CL_PROGRAM_BUILD_LOG, LogSize, PAnsiChar(Log), nil);
    if Status <> CL_SUCCESS then begin
      Writeln(GetString(Status));
      Exit;
    end;
    Writeln(Log);
  end;

  Kernel := clCreateKernel(Program_, 'Simple', @Status);
  if Status <> CL_SUCCESS then begin
    Writeln(GetString(Status));
    Exit;
  end;

  SetLength(Data, N);
  mem[0] := clCreateBuffer(Context, CL_MEM_WRITE_ONLY, N * SizeOf(tcl_float), nil, nil);
  clSetKernelArg(Kernel, 0, SizeOf(pcl_mem), @mem);
  clSetKernelArg(Kernel, 1, SizeOf(tcl_int), @n);
  clEnqueueNDRangeKernel(CommandQueue, Kernel, 1, nil, @n, @n, 0, nil, nil);
  clEnqueueReadBuffer(CommandQueue, mem[0], CL_TRUE, 0, N * SizeOf(tcl_float), Data, 0, nil, nil);

  FreeMemory(Current_device);

  clReleaseMemObject(mem[0]);
  clReleaseKernel(Kernel);
  clReleaseProgram(Program_);
  clReleaseCommandQueue(CommandQueue);
  clReleaseContext(Context);
  clReleaseMemObject(SrcA);
  clReleaseMemObject(SrcB);
  clReleaseMemObject(Dst);

  Writeln('Please, press any key.');
  Readln;
end.
