library mydg;

uses
  ComServ,
  mydg_TLB in 'mydg_TLB.pas',
  untselectdg in 'untselectdg.pas' {fmselectdg},
  frminfo in 'frminfo.pas' {fminfo},
  fmnewdw in 'fmnewdw.pas' {fmadddw},
  frmopendw in 'frmopendw.pas' {fmopendw},
  frm_manysheet in 'frm_manysheet.pas' {fmmanysheet},
  u_xzh in 'u_xzh.pas',
  frmcash in 'frmcash.pas' {fmcash},
  jm in 'jm.pas',
  clslxy in 'clslxy.pas',
  CLSexcel in 'CLSexcel.pas',
  ushare in 'ushare.pas',
  Crc32 in '..\ShareUnit\Crc32.pas',
  lxyjm in '..\ShareUnit\lxyjm.pas',
  md5 in '..\ShareUnit\md5.pas',
  UnitHardInfo in '..\ShareUnit\UnitHardInfo.pas',
  reg in 'reg.pas' {fmreg},
  communit in 'communit.pas',
  mydg_IMPL in 'mydg_IMPL.pas' {AddInModule: TadxCOMAddInModule};

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}

{$R *.RES}

begin
end.

