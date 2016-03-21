unit lxyjm;

interface

uses Windows, SysUtils, registry, IniFiles, dialogs,ushare;

//===========以上是加密常量
type
  tlxyjm = class
  private

    fsn1, fsn2, fsn3: string;
    REGKEY: string;
    diskserial: string;
    fusersn: string;
    FCHK1: Boolean;
    FCHK3: Boolean;
    FCHK2: Boolean;
    fregsn: string;
    fpath: string;

    function jm1(): string;
    function jm2(): string;
    function jm3(): string;

  published
    property usersn: string read fusersn write fusersn;
    property chk1: Boolean read FCHK1;
    property chk2: Boolean read FCHK2;
    property chk3: Boolean read FCHK3;
    //   property exepath: string read fpath write fpath;

  public
    constructor CREATE(programpath: string);
    function check1(): Boolean;
    function check2(): Boolean;
    function check3(): Boolean;
    function checkerr(): Boolean;
    function thispc_MachineNumber(): string;
    function thispc_regNumber(): string;
    function GET_REG_NUMBER(): string;
    function TOKH_machinenumber(machinenumber: string): string;
    procedure writeToReg();
    procedure CHECK();
    procedure SaveParamToFile(sn: string);
    function LoadParamFromFile(): string;
  end;

implementation

uses
  UnitHardInfo, Crc32, md5, lxyjmA;

{ tlxyjm }

function tlxyjm.LoadParamFromFile(): string;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(fpath + 'reg.ini');
  if not fileexists(fpath + 'reg.ini') then
  begin
    result := '';
  end
  else
  begin
    result := Ini.ReadString('项目信息', 'ID', '');
  end;
  Ini.Free;

end;

procedure tlxyjm.SaveParamToFile(sn: string);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(fpath + 'reg.ini');
  Ini.WriteString('项目信息', 'ID', sn);
  Ini.Free;
end;

procedure tlxyjm.CHECK;
begin
  //
  FCHK1 := check1();
  FCHK2 := check2();
  FCHK3 := check3();
end;

function tlxyjm.check1(): Boolean;
var
  S1, S2: string;
  reg: TRegistry;
begin

  RESULT := FALSE;

  S2 := uppercase(crc32.GetCrc32Str(diskserial + jmtmp1, 12));
  S2 := UpperCase(Copy(uppercase(crc32.GetCrc32Str(S2 + jmtmp1, 12)), 1, 8));

  if md5.MD5Match(md5.MD5String(fsn1), md5.MD5String(s2)) then
    RESULT := TRUE;

end;

function tlxyjm.check2(): Boolean;
var
  S1, S2: string;

begin
  RESULT := FALSE;

  S2 := uppercase(crc32.GetCrc32Str(diskserial + jmtmp2, 12));
  S2 := UpperCase(Copy(uppercase(crc32.GetCrc32Str(S2 + jmtmp2, 12)), 1, 8));

  if md5.MD5Match(md5.MD5String(fsn2), md5.MD5String(s2)) then
    RESULT := TRUE;

end;

function tlxyjm.check3(): Boolean;
var
  S1, S2: string;
  reg: TRegistry;
begin
  //
  RESULT := FALSE;

  S2 := uppercase(crc32.GetCrc32Str(diskserial + jmtmp3, 12));
  S2 := UpperCase(Copy(uppercase(crc32.GetCrc32Str(S2 + jmtmp3, 12)), 1, 8));

  if md5.MD5Match(md5.MD5String(fsn3), md5.MD5String(s2)) then
    RESULT := TRUE;

end;

function tlxyjm.checkerr: Boolean;

var
  S1, S2: string;
  reg: TRegistry;
begin
  //
  RESULT := FALSE;

  S2 := UpperCase(uppercase(crc32.GetCrc32Str(S2 + jmtmp3 + 'ab698221', 12)));

  if md5.MD5Match(md5.MD5String(fsn3), md5.MD5String(s2)) then
    RESULT := TRUE;

end;

constructor tlxyjm.CREATE(programpath: string);
var
  reg: TRegistry;
  openkeyok: Boolean;
begin

  fpath := programpath;
  //  mymessage(fpath);

  fregsn := LoadParamFromFile();
  // mymessage('从注册表中读取数据:  sn:' +programpath+ fregsn);

  if Trim(fregsn) = '' then
  begin
    REGKEY := 'software\' + SOFTNAME;
    reg := TRegistry.Create;
    reg.RootKey := HKEY_LOCAL_MACHINE;

    openkeyok := false;
    try
      openkeyok := reg.OpenKey(regkey, True);
    except
    end;

    fregsn := '';
    if openkeyok then
    begin
      try
        fregsn := reg.READstring('SN');
      except

      end;
    end;

  end;

  diskserial := '';
  try
    diskserial := GetIdeSerialNumber;
  except
  end;

  try
    if Trim(diskserial) = '' then
      diskserial := GetCPUSN(1);
  except
  end;

  try
    if Trim(diskserial) = '' then
      diskserial := Getmac;
  except
  end;

  diskserial := uppercase(copy(MD5Print(md5.MD5String(trim(diskserial) + jmstring)), 1,
    12));

  fsn1 := Copy(fregsn, 1, 8);
  fsn2 := Copy(fregsn, 9, 8);
  fsn3 := Copy(fregsn, 17, 8);

end;

function tlxyjm.GET_REG_NUMBER: string;
begin
  RESULT := JM1 + JM2 + JM3;
end;

function tlxyjm.jm1(): string;
var
  s1: string;
begin

  result := '';
  S1 := uppercase(crc32.GetCrc32Str(diskserial + jmtmp1, 12));
  result := UpperCase(Copy(uppercase(crc32.GetCrc32Str(S1 + jmtmp1, 12)), 1, 8));
end;

function tlxyjm.jm2: string;
var
  s1: string;
begin
  result := '';
  S1 := uppercase(crc32.GetCrc32Str(diskserial + jmtmp2, 12));
  result := UpperCase(Copy(uppercase(crc32.GetCrc32Str(S1 + jmtmp2, 12)), 1, 8));
end;

function tlxyjm.jm3: string;
var
  s1: string;
begin
  result := '';
  S1 := uppercase(crc32.GetCrc32Str(diskserial + jmtmp3, 12));
  result := UpperCase(Copy(uppercase(crc32.GetCrc32Str(S1 + jmtmp3, 12)), 1, 8));
end;

function tlxyjm.thispc_MachineNumber: string;
begin
  //
  RESULT := diskserial;
end;

function tlxyjm.thispc_regNumber: string;
var
  reg: TRegistry;
  S1, S2, S3: string;
  openkeyok: Boolean;
begin

  RESULT := '';
  // fpath := programpath;

  //  mymessage('从注册表中读取数据:  sn:' + fregsn);
  //==========因为DLL文件读注册表在一些系统里有限制，故改为读写INI文件
  try
    REGKEY := 'software\' + SOFTNAME;
    reg := TRegistry.Create;
    reg.RootKey := HKEY_LOCAL_MACHINE;

    openkeyok := false;
    try
      openkeyok := reg.OpenKey(regkey, True);
    except
    end;

    fregsn := '';
    if openkeyok then
    begin
      try
        fregsn := reg.READstring('SN');
      except
      end;
    end;
  except
    fregsn := '';
  end;

  if Trim(fregsn) = '' then
  begin
    fregsn := LoadParamFromFile();
  end;
  result := fregsn;

end;

function tlxyjm.TOKH_machinenumber(machinenumber: string): string;
var
  S1, S2: string;
begin
  //
  RESULT := '';
  S1 := uppercase(crc32.GetCrc32Str(machinenumber + jmtmp1, 12));
  S1 := UpperCase(Copy(uppercase(crc32.GetCrc32Str(S1 + jmtmp1, 12)), 1, 8));
  S2 := S1;
  S1 := uppercase(crc32.GetCrc32Str(machinenumber + jmtmp2, 12));
  S1 := UpperCase(Copy(uppercase(crc32.GetCrc32Str(S1 + jmtmp2, 12)), 1, 8));
  S2 := S2 + S1;
  S1 := uppercase(crc32.GetCrc32Str(machinenumber + jmtmp3, 12));
  S1 := UpperCase(Copy(uppercase(crc32.GetCrc32Str(S1 + jmtmp3, 12)), 1, 8));
  S2 := S2 + S1;
  RESULT := S2;
end;

procedure tlxyjm.writeToReg();
var
  reg: TRegistry;
begin
  if Trim(fusersn) = '' then
    exit;

  try
    reg := TRegistry.Create;
    reg.RootKey := HKEY_LOCAL_MACHINE;

    if reg.OpenKey(regkey, True) then
    begin
      reg.writestring('SN', fusersn);
    end
    else
    begin
      reg.CreateKey(regkey);
      if reg.OpenKey(regkey, True) then
      begin
        reg.writestring('SN', fusersn);
      end
    end;

  except
    try
      SaveParamToFile(fusersn);
    except
      mymessage('保存ini文件失败！');
    end;
  end;

end;

end.
