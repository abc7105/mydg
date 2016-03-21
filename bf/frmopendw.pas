unit frmopendw;

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
    btn4: TButton;
    qrytmp: TADOQuery;
    procedure dbgrid2DblClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure openxm();
    procedure btn2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btn4Click(Sender: TObject);
  private

    CONSYS: TADOCONNECTION;
    { Private declarations }
  public
    { Public declarations }

  end;

var
  fmopendw: Tfmopendw;

implementation

uses
  communit, mainmdb, lxydatabase, CLSexcel;

{$R *.dfm}

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
var
  AID: string;
begin
  HIDE;
  AID := qry1.FIELDBYNAME('XMID').ASSTRING;
  AXM := ADGSYSTEM.OPENXM(AID);
  CLOSE;
end;

procedure Tfmopendw.btn2Click(Sender: TObject);
begin
  close;
end;

procedure Tfmopendw.FormShow(Sender: TObject);
begin

  QRY1.CLOSE;
  CONSYS := ADGSYSTEM.connection;
  qry1.Connection := CONSYS;
//  ADGSYSTEM.GETALLXM;
  qry1.Connection := CONsys;
  qry1.Close;
  qry1.sql.Clear;
  qry1.SQL.add('select * from 底稿单位');
  qry1.open;
  qry1.Open;
  DS1.DataSet := qry1;
  dbgrid2.DataSource := ds1;

  dbgrid2.Columns[0].FieldName := 'xmid';
  dbgrid2.Columns[1].FieldName := 'xmmc';
  dbgrid2.Columns[2].FieldName := 'dwmc';
end;

procedure Tfmopendw.btn4Click(Sender: TObject);
begin
  if MessageDlg('将要删除该项目及其相应的底稿，请确定！',
    mtInformation, mbOKCancel, 0) = mrOk then
    if MessageDlg('按确定后将会开始删除并无法恢复，您继续吗？',
      mtInformation, mbOKCancel, 0) = mrOk then
    begin
      qrytmp.Connection := CONSYS; // qry1.Connection;
      qrytmp.Close;
      qrytmp.SQL.Clear;
      qrytmp.SQL.Add('delete from 底稿单位 where xmid=:xmid');
      qrytmp.Parameters.ParamByName('xmid').value := qry1.fieldbyname('xmid').asstring;
      qrytmp.ExecSQL;

      qry1.Requery([]);
    end;
end;

end.

