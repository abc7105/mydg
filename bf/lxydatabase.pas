unit lxydatabase;

interface

uses
  SysUtils, Classes, DB, ADODB;

type
  TDataModule4 = class(TDataModule)
    conxm: TADOConnection;
    conmain: TADOConnection;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataModule4: TDataModule4;

implementation

{$R *.dfm}

end.
