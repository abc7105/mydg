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
    'ID,xid	,dm	,mc	,类型, 名称示例 ,	是否关联';
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
    qrytmp.SQL.Add('create table TMP核算项目(xid string(40),dm string(60),mc string(100),类型 string(60), 名称示例  string(100))');
    qrytmp.execsql;
  end;

  qrytmp.Close;
  qrytmp.SQL.CLEAR;
  qrytmp.SQL.Add('delete from  TMP核算项目 ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.CLEAR;
  qrytmp.SQL.Add('INSERT INTO TMP核算项目(xid	,dm	,mc	,类型, 名称示例 ) ');
  qrytmp.SQL.Add('SELECT Max(项目凭证表.xmid) AS xid, Max(项目凭证表.科目编码) AS dm, ');
  qrytmp.SQL.Add(' Max(项目凭证表.科目名称) AS mc, Max(项目凭证表.项目核算类型) AS 类型,');
  qrytmp.SQL.Add('Max(项目凭证表.项目核算名称) AS 名称示例 ');

  qrytmp.SQL.Add('FROM 项目凭证表 ');
  qrytmp.SQL.Add('WHERE (((项目凭证表.[xmid])="0019")) ');
  qrytmp.SQL.Add('GROUP BY 项目凭证表.科目编码, 项目凭证表.项目核算类型');
  qrytmp.SQL.Add('ORDER BY 项目凭证表.科目编码; ');
  qrytmp.ExecSQL;

  qry1.Close;
  qry1.SQL.Clear;
  qry1.SQL.add('select  MAX(xid) AS XID	, MAX(dm) AS DM	,MAX(mc) AS MC	,MAX(类型) AS 类型, max(名称示例) as 名称示例 ');
  qry1.SQL.add('   from   TMP核算项目 group by dm ');
  qry1.Open;

end;

procedure Tfmxmgl.qry1AfterScroll(DataSet: TDataSet);
begin

  qry2.Close;
  qry2.SQL.Clear;
  qry2.SQL.Add('select * from tmp核算项目');
  qry2.SQL.Add(' where trim(dm)=''' + trim(qry1.fieldbyname('dm').asstring) + '''');
  qry2.Open;

end;

procedure Tfmxmgl.ejunonexmDblClick(Sender: TObject);
begin
  try
    qry2.Edit;
    if qry2.FieldByName('是否关联').AsBoolean then
      qry2.FieldByName('是否关联').AsBoolean := false
    else
      qry2.FieldByName('是否关联').AsBoolean := True;
    qry2.Post;
  except
  end;

end;

end.

