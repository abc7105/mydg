unit XMmanager;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBTables, ZcUniClass, ZJGrid, ZcDataGrid, ZcDBGrids, ADODB, CLSexcel,
  ExtCtrls, StdCtrls;

type
  Tfmxmgl = class(TForm)
    qry1: TADOQuery;
    pnl1: TPanel;
    pnl2: TPanel;
    ejunonexm: TEjunDBGrid;
    spl1: TSplitter;
    ejunallxm: TEjunDBGrid;
    pnl3: TPanel;
    btn1: TButton;
    qry2: TADOQuery;
    qrytmp: TADOQuery;
    procedure btn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure qry1AfterScroll(DataSet: TDataSet);
    procedure ejunonexmDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmxmgl: Tfmxmgl;
//  adgsystem: dgsystem;

implementation

uses
  lxydatabase;

{$R *.dfm}

procedure Tfmxmgl.btn1Click(Sender: TObject);
begin
  //
end;

procedure Tfmxmgl.FormCreate(Sender: TObject);
var
  STRLIST: tstringlist;
  stext: string;
  i: Integer;
begin
  //
  stext :=
    'ID,xid	,dm	,mc	,����, ����ʾ�� ,	�Ƿ����';
  STRLIST := tstringlist.create();
  STRLIST.Delimiter := ',';
  STRLIST.DelimitedText := stext;

  for i := 1 to strlist.Count do
  begin
    if I >= ejunallxm.DataColumns.Count - 1 then
      ejunallxm.DataColumns.Add;
    ejunallxm.DATAColumns.Items[i - 1].FieldName := strlist[i - 1];
    ejunallxm.DATAColumns.Items[I - 1].Title := STRLIST[I - 1];

    if I >= ejunonexm.DataColumns.Count - 1 then
      ejunonexm.DataColumns.Add;
    ejunonexm.DATAColumns.Items[i - 1].FieldName := strlist[i - 1];
    ejunonexm.DATAColumns.Items[I - 1].Title := STRLIST[I - 1];

  end;

  ejunallxm.Columns[1].Width := 0;
  ejunallxm.Columns[2].Width := 0;
  ejunallxm.Columns[3].Width := 60;
  ejunallxm.Columns[4].Width := 80;
  ejunallxm.Columns[5].Width := 0;
  ejunallxm.Columns[6].Width := 0;
  ejunallxm.Columns[7].Width := 0;

  ejunonexm.Columns[1].Width := 0;
  ejunonexm.Columns[2].Width := 0;
  ejunonexm.Columns[3].Width := 0;
  ejunonexm.Columns[4].Width := 0;
  ejunonexm.Columns[5].Width := 120;
  ejunonexm.Columns[6].Width := 250;
  ejunonexm.Columns[7].Width := 60;
  ejunonexm.Columns[7].CellType := cellCheckBox;

  if false then
  begin
    qrytmp.Close;
    qrytmp.SQL.CLEAR;
    qrytmp.SQL.Add('create table TMP������Ŀ(xid string(40),dm string(60),mc string(100),���� string(60), ����ʾ��  string(100))');
    qrytmp.execsql;
  end;

  qrytmp.Close;
  qrytmp.SQL.CLEAR;
  qrytmp.SQL.Add('delete from  TMP������Ŀ ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.CLEAR;
  qrytmp.SQL.Add('INSERT INTO TMP������Ŀ(xid	,dm	,mc	,����, ����ʾ�� ) ');
  qrytmp.SQL.Add('SELECT Max(��Ŀƾ֤��.xmid) AS xid, Max(��Ŀƾ֤��.��Ŀ����) AS dm, ');
  qrytmp.SQL.Add(' Max(��Ŀƾ֤��.��Ŀ����) AS mc, Max(��Ŀƾ֤��.��Ŀ��������) AS ����,');
  qrytmp.SQL.Add('Max(��Ŀƾ֤��.��Ŀ��������) AS ����ʾ�� ');

  qrytmp.SQL.Add('FROM ��Ŀƾ֤�� ');
  qrytmp.SQL.Add('WHERE (((��Ŀƾ֤��.[xmid])="0019")) ');
  qrytmp.SQL.Add('GROUP BY ��Ŀƾ֤��.��Ŀ����, ��Ŀƾ֤��.��Ŀ��������');
  qrytmp.SQL.Add('ORDER BY ��Ŀƾ֤��.��Ŀ����; ');
  qrytmp.ExecSQL;

  qry1.Close;
  qry1.SQL.Clear;
  qry1.SQL.add('select  MAX(xid) AS XID	, MAX(dm) AS DM	,MAX(mc) AS MC	,MAX(����) AS ����, max(����ʾ��) as ����ʾ�� ');
  qry1.SQL.add('   from   TMP������Ŀ group by dm ');
  qry1.Open;

end;

procedure Tfmxmgl.qry1AfterScroll(DataSet: TDataSet);
begin

  qry2.Close;
  qry2.SQL.Clear;
  qry2.SQL.Add('select * from tmp������Ŀ');
  qry2.SQL.Add(' where trim(dm)=''' + trim(qry1.fieldbyname('dm').asstring) + '''');
  qry2.Open;

end;

procedure Tfmxmgl.ejunonexmDblClick(Sender: TObject);
begin
  try
    qry2.Edit;
    if qry2.FieldByName('�Ƿ����').AsBoolean then
      qry2.FieldByName('�Ƿ����').AsBoolean := false
    else
      qry2.FieldByName('�Ƿ����').AsBoolean := True;
    qry2.Post;
  except
  end;

end;

end.

