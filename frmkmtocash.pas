unit frmkmtocash;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, DB,
  ADODB,
  Dialogs, ExtCtrls, ZcUniClass, ZJGrid, ZcDataGrid, ZcDBGrids,
  ZcGridClasses, StdCtrls;

type
  Tfmkmtocash = class(TForm)
    ejunkmlist: TEjunDBGrid;
    ejuncashlist: TEjunDBGrid;
    Splitter1: TSplitter;
    tbkmlist: TADOTable;
    qrycashlist: TADOQuery;
    qrytmp: TADOQuery;
    EjunLicense1: TEjunLicense;
    Panel1: TPanel;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure ejuncashlistDblClick(Sender: TObject);
  private
    conthis: tadoconnection;
    excelapp: variant;
    procedure openkmlist();
    procedure openCASHLIST();
    procedure update_cashlist;
    procedure UPDATE_pzb;
    function firstlevel_length(): integer;
    procedure MARK_CASHFIELD();

    { Private declarations }
  public
    { Public declarations }
    constructor FormCreate(Sender: TObject; xlsapp: variant; con:
      tadoconnection);
  end;

var
  fmkmtocash: Tfmkmtocash;

implementation

{$R *.dfm}

{ TForm6 }

constructor Tfmkmtocash.FormCreate(Sender: TObject; xlsapp: variant; con:
  tadoconnection);
begin
  inherited Create(Application); //很重要
  excelapp := xlsapp;
  conthis := con;
  qrytmp.Connection := conthis;
  tbkmlist.Connection := conthis;
  qrycashlist.Connection := conthis;
  openkmlist;
  openCASHLIST;
end;

procedure Tfmkmtocash.Button1Click(Sender: TObject);
begin
  //
  UPDATE_pzb;
  update_cashlist;
  MARK_CASHFIELD;
  close;    
end;

procedure Tfmkmtocash.ejuncashlistDblClick(Sender: TObject);
begin
  try
    tbkmlist.Edit;
    tbkmlist.FieldByName('对应现金流量名称').asstring :=
      qrycashlist.fieldbyname('现金流量简称').asstring;
    tbkmlist.Post;
  except
  end;
end;

procedure Tfmkmtocash.openCASHLIST;
var
  STRLIST: tstringlist;
  stext: string;
  i: Integer;
begin
  if qrytmp.Active = true then
    qrytmp.close;

  //  qrytmp.Connection := conthis;

  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('UPDATE 现金流量表项目 set 现金流量简称=trim(现金流量项目) where trim(现金流量简称)<>""');
  qrytmp.ExecSQL;

  qrycashlist.close;
  qrycashlist.SQL.Clear;
  qrycashlist.SQL.Add('select  现金流量简称 from  现金流量表项目 where trim(现金流量简称)<>"" order by id');
  qrycashlist.open;

  stext := '现金流量简称';
  STRLIST := tstringlist.create();
  STRLIST.Delimiter := ',';
  STRLIST.DelimitedText := stext;

  ejuncashlist.DataSet := tbkmlist;
  for i := 1 to strlist.Count do
  begin
    if I >= ejuncashlist.DataColumns.Count then
      ejuncashlist.DataColumns.Add;
    ejuncashlist.DATAColumns.Items[i - 1].FieldName := strlist[i - 1];
    ejuncashlist.DATAColumns.Items[I - 1].Title := STRLIST[I - 1];
  end;

  ejuncashlist.Columns[1].Width := 200;

  ejuncashlist.DataSet := qrycashlist;

  ejuncashlist.Activate(true);

end;

procedure Tfmkmtocash.openkmlist;
var
  STRLIST: tstringlist;
  stext: string;
  i: Integer;
begin
  if qrytmp.Active = true then
    qrytmp.close;

  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('delete from  现金流量统计');
  qrytmp.ExecSQL;

  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' insert into 现金流量统计(科目代码,一级科目,二级科目,金额 ,对应现金流量名称,其他的明细)');
  qrytmp.SQL.Add(' select max(科目编码) AS  科目代码 ,MAX(一级名称)  AS 一级科目 ,MAX(科目名称) AS 二级科目 ,0,');
  qrytmp.SQL.Add(' MAX(现金流量) as 对应现金流量名称,max(经营其他) AS 其他的明细 ');
  qrytmp.SQL.Add(' FROM 凭证表 where xjpz  and  trim(科目名称)<>"" and not (科目名称 is null)  and trim(fitnum)<>"N/A" '); //
  qrytmp.SQL.Add(' GROUP BY 科目编码,科目名称');
  qrytmp.SQL.Add(' order by 科目编码 ');
  qrytmp.ExecSQL;

  tbkmlist.Close;
  tbkmlist.TableName := '现金流量统计';
  tbkmlist.open;

  stext :=
    '科目代码,一级科目,二级科目,金额 ,对应现金流量名称,其他的明细,ID';
  STRLIST := tstringlist.create();
  STRLIST.Delimiter := ',';
  STRLIST.DelimitedText := stext;

  ejunkmlist.DataSet := tbkmlist;
  for i := 1 to strlist.Count do
  begin
    if I >= ejunkmlist.DataColumns.Count then
      ejunkmlist.DataColumns.Add;
    ejunkmlist.DATAColumns.Items[i - 1].FieldName := strlist[i - 1];
    ejunkmlist.DATAColumns.Items[I - 1].Title := STRLIST[I - 1];
  end;

  ejunkmlist.Columns[1].Width := 50;
  ejunkmlist.Columns[2].Width := 70;
  ejunkmlist.Columns[3].Width := 100;
  ejunkmlist.Columns[4].Width := 70;
  ejunkmlist.Columns[5].Width := 200;
  ejunkmlist.Columns[6].Width := 150;

  ejunkmlist.DataColumns.Items[4].Style.FormatString := '#,##0.00';
  //  ejunkmlist.DataColumns.Items[6].Style.FormatString := '#,##0.00';

  ejunkmlist.Activate(true);

end;

procedure Tfmkmtocash.update_cashlist;
begin
  // TODO -cMM: Tfmkmtocash.update_cashlist default body inserted

  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('delete from  现金流量表对应');
  qrytmp.ExecSQL;

  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('insert into 现金流量表对应(现金流量简称,对方科目,二级科目,其他,科目编码)  select max(对应现金流量名称)');
  qrytmp.SQL.Add(' ,max(一级科目)  ,max(二级科目),max(其他的明细),MAX(科目代码) from 现金流量统计 group by 一级科目,二级科目 ');
  qrytmp.ExecSQL;

end;

procedure Tfmkmtocash.UPDATE_pzb;
begin
  // TODO -cMM: Tfmkmtocash.UPDATE_pzb default body inserted
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update 凭证表 set 现金流量="" ');
  qrytmp.ExecSQL;

  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update 凭证表 A,现金流量统计 B  set A.现金流量=B.对应现金流量名称 where A.xjpz=true   AND  Trim(FITNUM)<>"N/A" and A.科目编码=B.科目代码');
  qrytmp.ExecSQL;
end;

function Tfmkmtocash.firstlevel_length: integer;
begin
  result := 4;
  try
    qrytmp.SQL.Clear;
    qrytmp.SQL.Add('select min(len(科目编码)) as 一级科目长度 from 凭证表 ');
    qrytmp.open;
    result := qrytmp.fieldbyname('一级科目长度').ASINTEGER;
  except
  end;
end;

procedure Tfmkmtocash.MARK_CASHFIELD;
var
  ZDLEN: INTEGER;
begin
  ZDLEN := firstlevel_length;

  try
    qrytmp.close;
    qrytmp.SQL.Clear;
    qrytmp.SQL.Add('drop view XJfield ');
    qrytmp.ExecSQL;
  except
  end;

  qrytmp.close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('CREATE view XJfield  as select  left(科目编码,' +
    inttostr(zdlen) +
    ') as 科目  from 现金流量表对应  where TRIM(现金流量简称)="XX"');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update dg7 set is现金=false');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update dg7 set is现金=true where 代码 in (select 科目 from xjfield   )');
  qrytmp.ExecSQL;

end;

end.

