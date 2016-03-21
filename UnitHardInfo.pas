unit UnitHardInfo;
interface

uses
  Windows, SysUtils,
  NB30, WinSock, Registry, DateUtils;

const
  ID_BIT = $200000; // EFLAGS ID bit

type
  TCPUID = array[1..4] of Longint;
  TVendor = array[0..11] of char;
function GetIdeNum: string;
function IsCPUID_Available: Boolean; register; //判断CPU序列号是否可用函数
function GetCPUID: TCPUID; assembler; register; //获取CPU序列号函数
function GetCPUVendor: TVendor; assembler; register; //获取CPU生产厂家函数
function GetCPUInfo: string; //CPU序列号(格式化成字符串)
function GetCPUSpeed: Double; //获取CPU速度函数
function GetDisplayFrequency: Integer; //获取显示器刷新率
function GetMemoryTotalSize: DWORD; //获取内存总量
function Getmac: string;
function GetHostName: string;
function NameToIP(Name: string): string;
function GetDiskSize: string;
function GetCPUName: string;
function GetIdeSerialNumber(): PChar; stdcall;
function spendtime(sj: tdatetime): string;
function GetCPUSN(InfoID: Byte): string;

type
  PASTAT = ^TASTAT;
  TASTAT = record
    adapter: TAdapterStatus;
    name_buf: TNameBuffer;
  end;

implementation

//-----------------------------------------------------------------------
//获取CPU硬件信息
//-----------------------------------------------------------------------
//参数：
// InfoID:=1 获取CPU序列号
// InfoID:=2 获取CPU 频率
// InfoID:=3 获取CPU厂商
//-----------------------------------------------------------------------

function GetCPUSN(InfoID: Byte): string;
var
  _eax, _ebx, _ecx, _edx: Longword;
  i: Integer;
  b: Byte;
  b1: Word;
  s, s1, s2, s3, s_all: string;
begin
  case InfoID of //获取CPU序列号
    1:
      begin
        asm
    mov eax,1
    db $0F,$A2
    mov _eax,eax
    mov _ebx,ebx
    mov _ecx,ecx
    mov _edx,edx
        end;
        s := IntToHex(_eax, 8);
        s1 := IntToHex(_edx, 8);
        s2 := IntToHex(_ecx, 8);
        Insert('-', s, 5);
        Insert('-', s1, 5);
        Insert('-', s2, 5);
        result := s + '-' + s1 + '-' + s2;
      end;
    2: //获取 CPU 频率
      begin
        asm     //execute the extended CPUID inst.
    mov eax,$80000000   //sub. func call
    db $0F,$A2
    mov _eax,eax
        end;
        if _eax > $80000000 then //any other sub. funct avail. ?
        begin
          asm     //get brand ID
      mov eax,$80000002
      db $0F
      db $A2
      mov _eax,eax
      mov _ebx,ebx
      mov _ecx,ecx
      mov _edx,edx
          end;
          s := '';
          s1 := '';
          s2 := '';
          s3 := '';
          for i := 0 to 3 do
          begin
            b := lo(_eax);
            s3 := s3 + chr(b);
            b := lo(_ebx);
            s := s + chr(b);
            b := lo(_ecx);
            s1 := s1 + chr(b);
            b := lo(_edx);
            s2 := s2 + chr(b);
            _eax := _eax shr 8;
            _ebx := _ebx shr 8;
            _ecx := _ecx shr 8;
            _edx := _edx shr 8;
          end;
          s_all := trim(s3 + s + s1 + s2);
          asm
      mov eax,$80000003
      db $0F
      db $A2
      mov _eax,eax
      mov _ebx,ebx
      mov _ecx,ecx
    mov _edx,edx
          end;
          s := '';
          s1 := '';
          s2 := '';
          s3 := '';
          for i := 0 to 3 do
          begin
            b := lo(_eax);
            s3 := s3 + chr(b);
            b := lo(_ebx);
            s := s + chr(b);
            b := lo(_ecx);
            s1 := s1 + chr(b);
            b := lo(_edx);
            s2 := s2 + chr(b);
            _eax := _eax shr 8;
            _ebx := _ebx shr 8;
            _ecx := _ecx shr 8;
            _edx := _edx shr 8;
          end;
          s_all := s_all + s3 + s + s1 + s2;
          asm
      mov eax,$80000004
      db $0F
      db $A2
      mov _eax,eax
      mov _ebx,ebx
      mov _ecx,ecx
      mov _edx,edx
          end;
          s := '';
          s1 := '';
          s2 := '';
          s3 := '';
          for i := 0 to 3 do
          begin
            b := lo(_eax);
            s3 := s3 + chr(b);
            b := lo(_ebx);
            s := s + chr(b);
            b := lo(_ecx);
            s1 := s1 + chr(b);
            b := lo(_edx);
            s2 := s2 + chr(b);
            _eax := _eax shr 8;
            _ebx := _ebx shr 8;
            _ecx := _ecx shr 8;
            _edx := _edx shr 8;
          end;
          if s2[Length(s2)] = #0 then
            setlength(s2, Length(s2) - 1);
          result := s_all + s3 + s + s1 + s2;
        end
        else
          result := '';

      end;
    3: //获取 CPU厂商
      begin
        asm                //asm call to the CPUID inst.
    mov eax,0         //sub. func call
    db $0F,$A2         //db $0F,$A2 = CPUID instruction
    mov _ebx,ebx
    mov _ecx,ecx
    mov _edx,edx
        end;
        for i := 0 to 3 do //extract vendor id
        begin
          b := lo(_ebx);
          s := s + chr(b);
          b := lo(_ecx);
          s1 := s1 + chr(b);
          b := lo(_edx);
          s2 := s2 + chr(b);
          _ebx := _ebx shr 8;
          _ecx := _ecx shr 8;
          _edx := _edx shr 8;
        end;
        result := s + s2 + s1;
      end;
  else
    result := '错误的信息标识!';
  end;

end;

function spendtime(sj: tdatetime): string;
var
  sj3: tdatetime;
  secondcount: integer;
begin
  //
  result := '';
  sj3 := now;
  secondcount := SecondsBetween(sj, now);
  // lbl6.Caption := '系统生成完毕';
  result := inttostr(secondcount div 60) + '分钟' + inttostr(secondcount mod 60) + '秒';
end;

function IsCPUID_Available: Boolean; register;
asm
    PUSHFD {direct access to flags no possible, only via stack}
    POP EAX {flags to EAX}
    MOV EDX,EAX {save current flags}
    XOR EAX,ID_BIT {not ID bit}
    PUSH EAX {onto stack}
    POPFD {from stack to flags, with not ID bit}
    PUSHFD {back to stack}
    POP EAX {get back to EAX}
    XOR EAX,EDX {check if ID bit affected}
    JZ @exit {no, CPUID not availavle}
    MOV AL,True {Result=True}
    @exit:
end;

function GetCPUID: TCPUID; assembler; register;
asm
    PUSH    EBX         {Save affected register}
    PUSH    EDI
    MOV     EDI,EAX     {@Resukt}
    MOV     EAX,1
    DW      $A20F       {CPUID Command}
    STOSD                {CPUID[1]}
    MOV     EAX,EBX
    STOSD               {CPUID[2]}
    MOV     EAX,ECX
    STOSD               {CPUID[3]}
    MOV     EAX,EDX
    STOSD               {CPUID[4]}
    POP     EDI         {Restore registers}
    POP     EBX
end;

function GetCPUVendor: TVendor; assembler; register;
//获取CPU生产厂家函数
//调用方法:EDIT.TEXT:='Current CPU Vendor:'+GetCPUVendor;
asm
      PUSH EBX {Save affected register}
      PUSH EDI
      MOV EDI,EAX {@Result (TVendor)}
      MOV EAX,0
      DW $A20F {CPUID Command}
      MOV EAX,EBX
      XCHG EBX,ECX {save ECX result}
      MOV ECX,4
      @1:
      STOSB
      SHR EAX,8
      LOOP @1
      MOV EAX,EDX
      MOV ECX,4
      @2:
      STOSB
      SHR EAX,8
      LOOP @2
      MOV EAX,EBX
      MOV ECX,4
      @3:
      STOSB
      SHR EAX,8
      LOOP @3
      POP EDI {Restore registers}
      POP EBX
end;

function GetCPUInfo: string;
var
  CPUID: TCPUID;
  I: Integer;
  S: TVendor;
begin
  for I := Low(CPUID) to High(CPUID) do
    CPUID[I] := -1;
  if IsCPUID_Available then
  begin
    CPUID := GetCPUID;
    S := GetCPUVendor;
    Result := IntToHex(CPUID[1], 8)
      + '-' + IntToHex(CPUID[2], 8)
      + '-' + IntToHex(CPUID[3], 8)
      + '-' + IntToHex(CPUID[4], 8);
  end
  else
    Result := 'CPUID not available';
end;

function GetCPUSpeed: Double;
//获取CPU速率函数
//调用方法:EDIT.TEXT:='Current CPU Speed:'+floattostr(GetCPUSpeed)+'MHz';
const
  DelayTime = 500; // 时间单位是毫秒
var
  TimerHi, TimerLo: DWORD;
  PriorityClass, Priority: Integer;
begin
  PriorityClass := GetPriorityClass(GetCurrentProcess);
  Priority := GetThreadPriority(GetCurrentThread);
  SetPriorityClass(GetCurrentProcess, REALTIME_PRIORITY_CLASS);
  SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_TIME_CRITICAL);
  Sleep(10);
  asm
        dw 310Fh // rdtsc
        mov TimerLo, eax
        mov TimerHi, edx
  end;
  Sleep(DelayTime);
  asm
        dw 310Fh // rdtsc
        sub eax, TimerLo
        sbb edx, TimerHi
        mov TimerLo, eax
        mov TimerHi, edx
  end;

  SetThreadPriority(GetCurrentThread, Priority);
  SetPriorityClass(GetCurrentProcess, PriorityClass);
  Result := TimerLo / (1000.0 * DelayTime);
end;

function GetDisplayFrequency: Integer;
// 这个函数返回的显示刷新率是以Hz为单位的
//调用方法:EDIT.TEXT:='Current DisplayFrequency:'+inttostr(GetDisplayFrequency)+' Hz';
var
  DeviceMode: TDeviceMode;
begin
  EnumDisplaySettings(nil, Cardinal(-1), DeviceMode);
  Result := DeviceMode.dmDisplayFrequency;
end;

function GetMemoryTotalSize: DWORD; //获取内存总量
var
  msMemory: TMemoryStatus;
  iPhysicsMemoryTotalSize: DWORD;
begin
  msMemory.dwLength := SizeOf(msMemory);
  GlobalMemoryStatus(msMemory);
  iPhysicsMemoryTotalSize := msMemory.dwTotalPhys;
  Result := iPhysicsMemoryTotalSize;
end;
//
//  type
//      PASTAT =^TASTAT;
//      TASTAT = record
//          adapter:TAdapterStatus;
//          name_buf:TNameBuffer;
//  end;

function Getmac: string;
var
  ncb: TNCB;
  s: string;
  adapt: TASTAT;
  lanaEnum: TLanaEnum;
  i, j, m: integer;
  strPart, strMac: string;
begin
  FillChar(ncb, SizeOf(TNCB), 0);
  ncb.ncb_command := Char(NCBEnum);
  ncb.ncb_buffer := PChar(@lanaEnum);
  ncb.ncb_length := SizeOf(TLanaEnum);
  s := Netbios(@ncb);
  for i := 0 to integer(lanaEnum.length) - 1 do
  begin
    FillChar(ncb, SizeOf(TNCB), 0);
    ncb.ncb_command := Char(NCBReset);
    ncb.ncb_lana_num := lanaEnum.lana[i];
    Netbios(@ncb);
    Netbios(@ncb);
    FillChar(ncb, SizeOf(TNCB), 0);
    ncb.ncb_command := Chr(NCBAstat);
    ncb.ncb_lana_num := lanaEnum.lana[i];
    ncb.ncb_callname := '*';
    ncb.ncb_buffer := PChar(@adapt);
    ncb.ncb_length := SizeOf(TASTAT);
    m := 0;
    if (Win32Platform = VER_PLATFORM_WIN32_NT) then
      m := 1;
    if m = 1 then
    begin
      if Netbios(@ncb) = Chr(0) then
        strMac := '';
      for j := 0 to 5 do
      begin
        strPart := IntToHex(integer(adapt.adapter.adapter_address[j]), 2);
        strMac := strMac + strPart + '-';
      end;
      SetLength(strMac, Length(strMac) - 1);
    end;
    if m = 0 then
      if Netbios(@ncb) <> Chr(0) then
      begin
        strMac := '';
        for j := 0 to 5 do
        begin
          strPart := IntToHex(integer(adapt.adapter.adapter_address[j]), 2);
          strMac := strMac + strPart + '-';
        end;
        SetLength(strMac, Length(strMac) - 1);
      end;
  end;
  result := strmac;
end;

function GetHostName: string;
var
  ComputerName: array[0..MAX_COMPUTERNAME_LENGTH + 1] of char;
  Size: Cardinal;
begin
  result := '';
  Size := MAX_COMPUTERNAME_LENGTH + 1;
  GetComputerName(ComputerName, Size);
  Result := StrPas(ComputerName);
end;

function NameToIP(Name: string): string;
var
  WSAData: TWSAData;
  HostEnt: PHostEnt;
begin
  result := '';
  WSAStartup(2, WSAData);
  HostEnt := GetHostByName(PChar(Name));
  if HostEnt <> nil then
  begin
    with HostEnt^ do
      result := Format('%d.%d.%d.%d', [Byte(h_addr^[0]), Byte(h_addr^[1]), Byte(h_addr^[2]), Byte(h_addr^[3])]);
  end;
  WSACleanup;
end;

function GetDiskSize: string;
var
  Available, Total, Free: Int64;
  AvailableT, TotalT: real;
  Drive: Char;
const
  GB = 1024 * 1024 * 1024;

begin
  AvailableT := 0;
  TotalT := 0;
  for Drive := 'C' to 'Z' do
    if GetDriveType(Pchar(Drive + ':\')) = DRIVE_FIXED then
    begin
      GetDiskFreeSpaceEx(PChar(Drive + ':\'), Available, Total, @Free);
      AvailableT := AvailableT + Available;
      TotalT := TotalT + Total;
    end;
  Result := Format('%.2fGB', [TotalT / GB]);

end;

function GetCPUName: string;
var
  myreg: TRegistry;
  CPUInfo: string;
begin
  myreg := TRegistry.Create;
  myreg.RootKey := HKEY_LOCAL_MACHINE;
  if myreg.OpenKey('Hardware\Description\System\CentralProcessor\0', true) then
  begin
    if myreg.ValueExists('ProcessorNameString') then
    begin
      CPUInfo := myreg.ReadString('ProcessorNameString');
      myreg.CloseKey;
    end
    else
      CPUInfo := 'UnKnow';
  end;
  Result := CPUInfo;
end;

function GetIdeSerialNumber: pchar; //获取硬盘的出厂系列号；
const
  IDENTIFY_BUFFER_SIZE = 512;
type
  TIDERegs = packed record
    bFeaturesReg: BYTE;
    bSectorCountReg: BYTE;
    bSectorNumberReg: BYTE;
    bCylLowReg: BYTE;
    bCylHighReg: BYTE;
    bDriveHeadReg: BYTE;
    bCommandReg: BYTE;
    bReserved: BYTE;
  end;
  TSendCmdInParams = packed record
    cBufferSize: DWORD;
    irDriveRegs: TIDERegs;
    bDriveNumber: BYTE;
    bReserved: array[0..2] of Byte;
    dwReserved: array[0..3] of DWORD;
    bBuffer: array[0..0] of Byte;
  end;
  TIdSector = packed record
    wGenConfig: Word;
    wNumCyls: Word;
    wReserved: Word;
    wNumHeads: Word;
    wBytesPerTrack: Word;
    wBytesPerSector: Word;
    wSectorsPerTrack: Word;
    wVendorUnique: array[0..2] of Word;
    sSerialNumber: array[0..19] of CHAR;
    wBufferType: Word;
    wBufferSize: Word;
    wECCSize: Word;
    sFirmwareRev: array[0..7] of Char;
    sModelNumber: array[0..39] of Char;
    wMoreVendorUnique: Word;
    wDoubleWordIO: Word;
    wCapabilities: Word;
    wReserved1: Word;
    wPIOTiming: Word;
    wDMATiming: Word;
    wBS: Word;
    wNumCurrentCyls: Word;
    wNumCurrentHeads: Word;
    wNumCurrentSectorsPerTrack: Word;
    ulCurrentSectorCapacity: DWORD;
    wMultSectorStuff: Word;
    ulTotalAddressableSectors: DWORD;
    wSingleWordDMA: Word;
    wMultiWordDMA: Word;
    bReserved: array[0..127] of BYTE;
  end;
  PIdSector = ^TIdSector;
  TDriverStatus = packed record
    bDriverError: Byte;
    bIDEStatus: Byte;
    bReserved: array[0..1] of Byte;
    dwReserved: array[0..1] of DWORD;
  end;
  TSendCmdOutParams = packed record
    cBufferSize: DWORD;
    DriverStatus: TDriverStatus;
    bBuffer: array[0..0] of BYTE;
  end;
var
  hDevice: Thandle;
  cbBytesReturned: DWORD;
  SCIP: TSendCmdInParams;
  aIdOutCmd: array[0..(SizeOf(TSendCmdOutParams) + IDENTIFY_BUFFER_SIZE - 1) - 1] of Byte;
  IdOutCmd: TSendCmdOutParams absolute aIdOutCmd;
  procedure ChangeByteOrder(var Data; Size: Integer);
  var
    ptr: Pchar;
    i: Integer;
    c: Char;
  begin
    ptr := @Data;
    for I := 0 to (Size shr 1) - 1 do
    begin
      c := ptr^;
      ptr^ := (ptr + 1)^;
      (ptr + 1)^ := c;
      Inc(ptr, 2);
    end;
  end;
begin
  Result := '';
  if SysUtils.Win32Platform = VER_PLATFORM_WIN32_NT then
  begin //   Windows   NT,   Windows   2000
    hDevice := CreateFile('\\.\PhysicalDrive0', GENERIC_READ or GENERIC_WRITE,
      FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
  end
  else //   Version   Windows   95   OSR2,   Windows   98
    hDevice := CreateFile('\\.\SMARTVSD', 0, 0, nil, CREATE_NEW, 0, 0);
  if hDevice = INVALID_HANDLE_VALUE then
    Exit;
  try
    FillChar(SCIP, SizeOf(TSendCmdInParams) - 1, #0);
    FillChar(aIdOutCmd, SizeOf(aIdOutCmd), #0);
    cbBytesReturned := 0;
    with SCIP do
    begin
      cBufferSize := IDENTIFY_BUFFER_SIZE;
      with irDriveRegs do
      begin
        bSectorCountReg := 1;
        bSectorNumberReg := 1;
        bDriveHeadReg := $A0;
        bCommandReg := $EC;
      end;
    end;
    if not DeviceIoControl(hDevice, $0007C088, @SCIP, SizeOf(TSendCmdInParams) - 1,
      @aIdOutCmd, SizeOf(aIdOutCmd), cbBytesReturned, nil) then
      Exit;
  finally
    CloseHandle(hDevice);
  end;
  with PIdSector(@IdOutCmd.bBuffer)^ do
  begin
    ChangeByteOrder(sSerialNumber, SizeOf(sSerialNumber));
    (Pchar(@sSerialNumber) + SizeOf(sSerialNumber))^ := #0;
    Result := Pchar(@sSerialNumber);
  end;
end;

function GetIdeNum: string;
type
  TSrbIoControl = packed record
    HeaderLength: ULONG;
    Signature: array[0..7] of Char;
    Timeout: ULONG;
    ControlCode: ULONG;
    ReturnCode: ULONG;
    Length: ULONG;
  end;
  SRB_IO_CONTROL = TSrbIoControl;
  PSrbIoControl = ^TSrbIoControl;

  TIDERegs = packed record
    bFeaturesReg: Byte;
    bSectorCountReg: Byte;
    bSectorNumberReg: Byte;
    bCylLowReg: Byte;
    bCylHighReg: Byte;
    bDriveHeadReg: Byte;
    bCommandReg: Byte;
    bReserved: Byte;
  end;
  IDEREGS = TIDERegs;
  PIDERegs = ^TIDERegs;

  TSendCmdInParams = packed record
    cBufferSize: DWORD;
    irDriveRegs: TIDERegs;
    bDriveNumber: Byte;
    bReserved: array[0..2] of Byte;
    dwReserved: array[0..3] of DWORD;
    bBuffer: array[0..0] of Byte;
  end;
  SENDCMDINPARAMS = TSendCmdInParams;
  PSendCmdInParams = ^TSendCmdInParams;

  TIdSector = packed record
    wGenConfig: Word;
    wNumCyls: Word;
    wReserved: Word;
    wNumHeads: Word;
    wBytesPerTrack: Word;
    wBytesPerSector: Word;
    wSectorsPerTrack: Word;
    wVendorUnique: array[0..2] of Word;
    sSerialNumber: array[0..19] of Char;
    wBufferType: Word;
    wBufferSize: Word;
    wECCSize: Word;
    sFirmwareRev: array[0..7] of Char;
    sModelNumber: array[0..39] of Char;
    wMoreVendorUnique: Word;
    wDoubleWordIO: Word;
    wCapabilities: Word;
    wReserved1: Word;
    wPIOTiming: Word;
    wDMATiming: Word;
    wBS: Word;
    wNumCurrentCyls: Word;
    wNumCurrentHeads: Word;
    wNumCurrentSectorsPerTrack: Word;
    ulCurrentSectorCapacity: ULONG;
    wMultSectorStuff: Word;
    ulTotalAddressableSectors: ULONG;
    wSingleWordDMA: Word;
    wMultiWordDMA: Word;
    bReserved: array[0..127] of Byte;
  end;
  PIdSector = ^TIdSector;

const
  IDE_ID_FUNCTION = $EC;
  IDENTIFY_BUFFER_SIZE = 512;
  DFP_RECEIVE_DRIVE_DATA = $0007C088;
  IOCTL_SCSI_MINIPORT = $0004D008;
  IOCTL_SCSI_MINIPORT_IDENTIFY = $001B0501;
  DataSize = sizeof(TSendCmdInParams) - 1 + IDENTIFY_BUFFER_SIZE;
  BufferSize = SizeOf(SRB_IO_CONTROL) + DataSize;
  W9xBufferSize = IDENTIFY_BUFFER_SIZE + 16;
var
  hDevice: THandle;
  cbBytesReturned: DWORD;
  pInData: PSendCmdInParams;
  pOutData: Pointer;
  Buffer: array[0..BufferSize - 1] of Byte;
  srbControl: TSrbIoControl absolute Buffer;

  procedure ChangeByteOrder(var Data; Size: Integer);
  var
    ptr: PChar;
    i: Integer;
    c: Char;
  begin
    ptr := @Data;
    for i := 0 to (Size shr 1) - 1 do
    begin
      c := ptr^;
      ptr^ := (ptr + 1)^;
      (ptr + 1)^ := c;
      Inc(ptr, 2);
    end;
  end;

begin
  Result := '';
  FillChar(Buffer, BufferSize, #0);
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    hDevice := CreateFile('.Scsi0', GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil,
      OPEN_EXISTING, 0, 0);
    if hDevice = INVALID_HANDLE_VALUE then
      Exit;
    try
      srbControl.HeaderLength := SizeOf(SRB_IO_CONTROL);
      System.Move('SCSIDISK', srbControl.Signature, 8);
      srbControl.Timeout := 2;
      srbControl.Length := DataSize;
      srbControl.ControlCode := IOCTL_SCSI_MINIPORT_IDENTIFY;
      pInData := PSendCmdInParams(PChar(@Buffer) + SizeOf(SRB_IO_CONTROL));
      pOutData := pInData;
      with pInData^ do
      begin
        cBufferSize := IDENTIFY_BUFFER_SIZE;
        bDriveNumber := 0;
        with irDriveRegs do
        begin
          bFeaturesReg := 0;
          bSectorCountReg := 1;
          bSectorNumberReg := 1;
          bCylLowReg := 0;
          bCylHighReg := 0;
          bDriveHeadReg := $A0;
          bCommandReg := IDE_ID_FUNCTION;
        end;
      end;
      if not DeviceIoControl(hDevice, IOCTL_SCSI_MINIPORT, @Buffer, BufferSize, @Buffer, BufferSize, cbBytesReturned,
        nil) then
        Exit;
    finally
      CloseHandle(hDevice);
    end;
  end
  else
  begin
    hDevice := CreateFile('.SMARTVSD', 0, 0, nil, CREATE_NEW, 0, 0);
    if hDevice = INVALID_HANDLE_VALUE then
      Exit;
    try
      pInData := PSendCmdInParams(@Buffer);
      pOutData := @pInData^.bBuffer;
      with pInData^ do
      begin
        cBufferSize := IDENTIFY_BUFFER_SIZE;
        bDriveNumber := 0;
        with irDriveRegs do
        begin
          bFeaturesReg := 0;
          bSectorCountReg := 1;
          bSectorNumberReg := 1;
          bCylLowReg := 0;
          bCylHighReg := 0;
          bDriveHeadReg := $A0;
          bCommandReg := IDE_ID_FUNCTION;
        end;
      end;
      if not DeviceIoControl(hDevice, DFP_RECEIVE_DRIVE_DATA, pInData, SizeOf(TSendCmdInParams) - 1, pOutData,
        W9xBufferSize, cbBytesReturned, nil) then
        Exit;
    finally
      CloseHandle(hDevice);
    end;
  end;
  with PIdSector(PChar(pOutData) + 16)^ do
  begin
    ChangeByteOrder(sSerialNumber, SizeOf(sSerialNumber));
    SetString(Result, sSerialNumber, SizeOf(sSerialNumber));
  end;
  Result := Trim(Result);
end;

end.

