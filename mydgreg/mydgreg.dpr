program mydgreg;

uses
  Forms,
  reg in 'reg_lhhtool\reg.pas' {fmreg},
  shareunit in 'reg_lhhtool\shareunit.pas',
  lxyjm in 'reg_lhhtool\lxyjm.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tfmreg, fmreg);
  Application.Run;
end.
