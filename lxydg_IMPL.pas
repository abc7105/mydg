unit lxydg_IMPL;

interface

uses
  SysUtils, ComObj, ComServ, ActiveX, Variants, Office2000, adxAddIn, lxydg_TLB, StdVcl;

type
  Tlxydgs = class(TadxAddin, Ilxydgs)
  end;

  TAddInModule = class(TadxCOMAddInModule)
    procedure adxCOMAddInModuleAddInInitialize(Sender: TObject);
    procedure adxCOMAddInModuleAddInFinalize(Sender: TObject);
  private
  protected
  public
  end;

var
  adxlxydgs: TAddInModule;

implementation

{$R *.dfm}

procedure TAddInModule.adxCOMAddInModuleAddInInitialize(Sender: TObject);
begin
  adxlxydgs := Self;

end;

procedure TAddInModule.adxCOMAddInModuleAddInFinalize(Sender: TObject);
begin

  adxlxydgs := nil;
end;

initialization
  TadxFactory.Create(ComServer, Tlxydgs, CLASS_lxydgs, TAddInModule);

end.
