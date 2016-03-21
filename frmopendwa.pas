unit frmopendwa;

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
    function GETMBNAME: string;
    procedure btn3Click(Sender: TObject);
    procedure btn4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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
  communit,  mainmdb, lxydatabase;

{$R *.dfm}

procedure Tfmopendw.setfcon(const Value: TADOConnection);
begin
  //
//  fcon := value;
//  qry1.Connection := fcon;
//  if fcon.Connected = false then
//    fcon.Open;

  qry1.Close;
  qry1.SQL.Clear;
  qry1.SQL.Add('select * from 底稿单位');
  qry1.Open;

  dbgrid2.Columns[0].FieldName := 'xmid';
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
var
  ausername, apassword, filename: string;
begin
  //
  axm.xmid := qry1.fieldbyname('xmid').asstring;
  // ShowMessage(qry1.fieldbyname('xmid').asstring + '  +=' + axm.xmid);
  axm.xmname := qry1.fieldbyname('xmmc').asstring;
  axm.dwname := qry1.fieldbyname('dwmc').asstring;
  axm.xmmbpath := qry1.fieldbyname('mbpath').asstring;
  axm.mbid := qry1.fieldbyname('mbid').asstring;
  axm.xmpath := qry1.fieldbyname('path').asstring;
  axm.MBNAME := GETMBNAME;
  // adg.xm := axm;
  SaveParamToFile(mainpath + 'sys.ini');
  filename := mainpath + axm.xmpath + '\dg.mdb';
  ausername := 'admin';
  apassword := '';

  lxydatabase.DataModule4.conxm.Close;
  lxydatabase.DataModule4.conxm.ConnectionString := 'Provider=Microsoft.Jet.OLEDB.4.0;' +
    'User ID=' + AUserName + ';' +
    'Jet OLEDB:Database Password=' + APassword + ';' +
    'Data Source=' + filename + ';' +
    'Mode=ReadWrite;' +
    'Extended Properties="";';
  lxydatabase.DataModule4.conxm.Connected := true;
  ShowMessage('项目已建立完毕，请进入下一步操作！');

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
//var
// AFORM: Tfrmpzh;
begin

  //  try
  //    aform := tfrmpzh.create(nil);
  //    aform.showmodal;
  //    self.close;
  //  finally
  //    aform.close;
  //    aform.free;
  //    aform := nil;
  //
  //  end;

end;

procedure Tfmopendw.btn4Click(Sender: TObject);
var
  xid: string;
begin
  case Application.MessageBox('本操作将删除项目的所有数据，您继续吗？',
    '附注提示', MB_YESNO + MB_ICONQUESTION) of
    IDYES:

      case Application.MessageBox('本操作将删除项目的所有数据，您继续吗？',
        '附注提示', MB_YESNO + MB_ICONQUESTION) of
        IDYES:
          begin
            xid := qry1.fieldbyname('xmid').asstring;

            qrytmp.Close;
            qrytmp.SQL.Clear;
            qrytmp.SQL.Add('delete from 凭证表 where xmid=''' + xid + '''');
            qrytmp.ExecSQL;

            qrytmp.Close;
            qrytmp.SQL.Clear;
            qrytmp.SQL.Add('delete from 项目凭证表 where xmid=''' + xid + '''');
            qrytmp.ExecSQL;

            qrytmp.Close;
            qrytmp.SQL.Clear;
            qrytmp.SQL.Add('delete from 凭证表 where xmid=''' + xid + '''');
            qrytmp.ExecSQL;

            qrytmp.Close;
            qrytmp.SQL.Clear;
            qrytmp.SQL.Add('delete from DG7 where xmid=''' + xid + '''');
            qrytmp.ExecSQL;

            qrytmp.Close;
            qrytmp.SQL.Clear;
            qrytmp.SQL.Add('delete from 底稿单位  where xmid=''' + xid + '''');
            qrytmp.ExecSQL;

            qry1.Requery();
            ShowMessage('删除完毕!');

          end;

      end;

  end;
end;

procedure Tfmopendw.FormCreate(Sender: TObject);
var
  ausername, apassword, filename: string;
begin

  filename := mainpath + axm.xmpath + '\dg.mdb';
  ausername := 'admin';
  apassword := '';

  lxydatabase.DataModule4.conmain.Close;

  lxydatabase.DataModule4.conmain.ConnectionString := 'Provider=Microsoft.Jet.OLEDB.4.0;' +
    'User ID=' + AUserName + ';' +
    'Jet OLEDB:Database Password=' + APassword + ';' +
    'Data Source=' + filename + ';' +
    'Mode=ReadWrite;' +
    'Extended Properties="";';
  lxydatabase.DataModule4.conmain.Connected := true;

  qry1.Close;
  qry1.SQL.Clear;
  qry1.SQL.Add('select * from 底稿单位');
  qry1.Open;

  dbgrid2.Columns[0].FieldName := 'xmid';
  dbgrid2.Columns[1].FieldName := 'xmmc';
  dbgrid2.Columns[2].FieldName := 'dwmc';
  // openxm;
end;

end.

