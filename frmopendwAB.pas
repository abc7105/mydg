unit frmopendwAB;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, DBGrids, DB, ADODB;

type
  Tfmopendw = class(TForm)
    dbgrid2: TDBGrid;
    btn1: TButton;
    btn2: TButton;
    ds1: TDataSource;
    qry1: TADOQuery;
    btn3: TButton;
    con1: TADOConnection;
    procedure dbgrid2DblClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure openxm();
    procedure btn2Click(Sender: TObject);
    function GETMBNAME: string;
    procedure btn3Click(Sender: TObject);
  private
    fcon: TADOConnection;
    procedure setfcon(const Value: TADOConnection);

    { Private declarations }
  public
    { Public declarations }
  published
    property connection: TADOConnection write setfcon;
  end;

var
  fmopendw: Tfmopendw;

implementation

uses
  communit, fmpzb;

{$R *.dfm}

procedure Tfmopendw.setfcon(const Value: TADOConnection);
begin
  //
  fcon := value;
  qry1.Connection := fcon;

  qry1.Close;
  qry1.SQL.Clear;
  qry1.SQL.Add('select * from �׸嵥λ');
  qry1.Open;

  dbgrid2.Columns[0].FieldName := 'id';
  dbgrid2.Columns[1].FieldName := 'xmmc';
  dbgrid2.Columns[2].FieldName := 'dwmc';
end;

procedure Tfmopendw.dbgrid2DblClick(Sender: TObject);
begin
  //
  openxm;
end;

procedure Tfmopendw.btn1Click(Sender: TObject);
begin
  openxm;
end;

procedure Tfmopendw.openxm;
begin
  //
  axm.xmid := qry1.fieldbyname('xmid').asstring;
  axm.xmname := qry1.fieldbyname('xmmc').asstring;
  axm.dwname := qry1.fieldbyname('dwmc').asstring;
  axm.xmmbpath := qry1.fieldbyname('mbpath').asstring;
  axm.mbid := qry1.fieldbyname('mbid').asstring;
  axm.xmpath := qry1.fieldbyname('path').asstring;
  axm.MBNAME := GETMBNAME;
  close;
end;

procedure Tfmopendw.btn2Click(Sender: TObject);
begin
  close;
end;

function Tfmopendw.GETMBNAME: string;
begin
  //
  RESULT := '';
  QRY1.Close;
  qry1.Close;
  qry1.SQL.Clear;
  qry1.SQL.Add('select * from MB  WHERE  MBID=''' + TRIM(axm.mbid) + '''');
  qry1.Open;
  if qry1.RecordCount > 0 then
  begin
    RESULT := QRY1.FIELDBYNAME('MBNAME').AsString;
  end;

end;

procedure Tfmopendw.btn3Click(Sender: TObject);
var
  AFORM: Tfrmpzh;
begin

  try
    aform := tfrmpzh.create(nil);
    aform.showmodal;
    self.close;
  finally
    aform.close;
    aform.free;
    aform := nil;

  end;

end;

end.

