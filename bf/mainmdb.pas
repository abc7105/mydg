unit mainmdb;

interface

uses
  SysUtils, Classes, DB, ADODB;

type
  TDataModule3 = class(TDataModule)
    conxm: TADOConnection;
    conmain: TADOConnection;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataModule3: TDataModule3;

implementation

uses
  communit;

{$R *.dfm}

end.
