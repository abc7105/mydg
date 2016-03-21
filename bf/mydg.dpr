library mydg;

uses
  ComServ,
  mydg_TLB in 'mydg_TLB.pas',
  mydg_IMPL in 'mydg_IMPL.pas' {AddInModule: TAddInModule} {mydgs: CoClass},
  dg in 'dg.pas' {dg: TActiveForm} {dg: CoClass},
  lxyjm in 'lxyjm.pas',
  reg in 'reg.pas' {fmreg},
  untselectdg in 'untselectdg.pas' {fmselectdg},
  communit in 'communit.pas',
  frminfo in 'frminfo.pas' {fminfo},
  fmnewdw in 'fmnewdw.pas' {fmadddw},
  frmopendw in 'frmopendw.pas' {fmopendw},
  frm_manysheet in 'frm_manysheet.pas' {fmmanysheet},
  u_xzh in 'u_xzh.pas',
  UnitHardInfo in 'UnitHardInfo.pas',
  frmcash in 'frmcash.pas' {fmcash},
  jm in 'jm.pas',
  clslxy in 'clslxy.pas',
  CLSexcel in 'CLSexcel.pas',
  ushare in 'ushare.pas';

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}

{$R *.RES}

begin
end.

