unit frmcash;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, ZcUniClass, ZJGrid, ZcDataGrid, ZcDBGrids,
  ushare, ShellAPI,
  DB, ADODB, ZcGridClasses, StdCtrls;
const
  ALLREC = 500;

type
  pzrec = record
    km: string;
    jf: double;
    df: double;
    iscash: boolean;
    cashtype: string;
    fitnum: string;
    id: longint;
  end;

type
  Tfmcash = class(TForm)
    pnl1: TPanel;
    pnl2: TPanel;
    pgc1: TPageControl;
    ts1: TTabSheet;
    pnl4: TPanel;
    ts2: TTabSheet;
    con1: TADOConnection;
    qrypzb: TADOQuery;
    ejnlcns1: TEjunLicense;
    tb1: TADOTable;
    spl1: TSplitter;
    ts3: TTabSheet;
    ejun2: TEjunDBGrid;
    tb2: TADOTable;
    btn1: TButton;
    qrytmp: TADOQuery;
    pnl6: TPanel;
    ejunpzall: TEjunDBGrid;
    pnl7: TPanel;
    ejunpzone: TEjunDBGrid;
    spl2: TSplitter;
    qryQRYonepz: TADOQuery;
    qrycash: TADOQuery;
    qrybank: TADOQuery;
    tbkey: TADOTable;
    ejuncashsheet: TEjunDBGrid;
    tbCASHSHEET: TADOTable;
    pnl8: TPanel;
    btnupdatesheet: TButton;
    qrykmyeb: TADOQuery;
    ts8: TTabSheet;
    tbdw: TADOTable;
    ts9: TTabSheet;
    pnl9: TPanel;
    btn2: TButton;
    mmo1: TMemo;
    qryother: TADOQuery;
    ejunOTHER: TEjunDBGrid;
    btn4: TButton;
    btn5: TButton;
    TabSheet1: TTabSheet;
    pgc2: TPageControl;
    ts5: TTabSheet;
    spl3: TSplitter;
    ejuncashtotal: TEjunDBGrid;
    pgc3: TPageControl;
    ts4: TTabSheet;
    ejun1: TEjunDBGrid;
    ts7: TTabSheet;
    ts6: TTabSheet;
    ejunbank: TEjunDBGrid;
    TabSheet2: TTabSheet;
    ejunkmyeb: TEjunDBGrid;
    Panel1: TPanel;
    ListBox1: TListBox;
    tbcalccash: TADOTable;
    Button1: TButton;
    dlgSave1: TSaveDialog;
    procedure openpzsheet();
    procedure opencashtotal();
    procedure FormShow(Sender: TObject);
    procedure ejunpzallMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ejunpzallDblClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure openpzone();
    procedure qrypzbAfterScroll(DataSet: TDataSet);
    procedure pgc2Change(Sender: TObject);
    procedure ejuncashtotalDblClick(Sender: TObject);
    procedure openbank(STR: string);
    procedure ejunbankDblClick(Sender: TObject);
    procedure formatcash();
    procedure btn2Click(Sender: TObject);
    procedure ejun1DblClick(Sender: TObject);
    procedure ejun3DblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ejunpzallCellGetColor(Sender: TObject; ACoord: TPoint;
      var AColor: TColor);
    procedure OPENCASHSHEET();
    procedure btnupdatesheetClick(Sender: TObject);
    procedure pgc1Change(Sender: TObject);
    procedure openkmyeb();
    procedure pgc3Change(Sender: TObject);
    procedure ejunkmyebDblClick(Sender: TObject);
    procedure ejunpzoneDblClick(Sender: TObject);
    procedure ejunpzoneMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure openother();
    procedure ejunOTHERDblClick(Sender: TObject);
    procedure ejunpzallSelectionChange(Sender: TObject;
      const ARange: TRect);
    procedure btn4Click(Sender: TObject);
    procedure btn5Click(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure calcfit();
    procedure lookforother();
    procedure lookfordf(je: double; const sxh: integer);
    procedure lookforjf(je: double; const sxh: integer);
    procedure cleararr;
    procedure UPDATRARR;
    procedure dofx();
  private
    fxmid: string;
    { Private declarations }
  public
    { Public declarations }
 // published
//    property xmid: string read fxmid write fxmid;
  end;

var
  fmcash: Tfmcash;
  pz: array[1..ALLREC] of pzrec;

implementation

uses
  communit, frmopendw, CLSexcel;

{$R *.dfm}

procedure Tfmcash.FormCreate(Sender: TObject);
var
  abook: dgworkbook;
begin
  pgc1.ActivePageIndex := 0;
  pgc2.ActivePageIndex := 0;
  axm := ADGSYSTEM.OPENLAST;
  abook := dgworkbook.create();
  abook.xm := axm;
  con1 := abook.connection;
  con1.Connected := true;
  fxmid := axm.xmid;

  qrycash.Connection := con1;

  qrytmp.Connection := con1;
  qryQRYonepz.Connection := con1;
  qrypzb.Connection := con1;
  qrybank.Connection := con1;
  qrykmyeb.connection := con1;
  tbcashsheet.close;
  tbcashsheet.Connection := con1;
  tbcashsheet.TableName := '现金流量表项目';
  tbkey.Connection := con1;
  tb1.Connection := con1;
  tb2.Connection := con1;

end;
//================打开

procedure Tfmcash.openpzsheet;
var
  STRLIST: tstringlist;
  stext: string;
  i: Integer;
begin
  //
  stext :=
    '全凭证号,一级名称,科目编码, 科目名称, 摘要, 借方, 贷方,fitnum ,现金流量,经营其他, 对方科目,判断依据,id,现金否';
  STRLIST := tstringlist.create();
  STRLIST.Delimiter := ',';
  STRLIST.DelimitedText := stext;

  for i := 1 to strlist.Count do
  begin
    if I >= ejunpzall.DataColumns.Count - 1 then
      ejunpzall.DataColumns.Add;
    ejunpzall.DATAColumns.Items[i - 1].FieldName := strlist[i - 1];
    ejunpzall.DATAColumns.Items[I - 1].Title := STRLIST[I - 1];
  end;

  ejunpzall.Columns[1].Width := 120;
  ejunpzall.Columns[2].Width := 50;
  ejunpzall.Columns[3].Width := 50;
  ejunpzall.Columns[4].Width := 50;
  ejunpzall.Columns[5].Width := 200;
  ejunpzall.Columns[6].Width := 80;
  ejunpzall.Columns[7].Width := 80;
  ejunpzall.Columns[8].Width := 70;
  ejunpzall.Columns[9].Width := 70;
  ejunpzall.Columns[10].Width := 90;
  ejunpzall.Columns[11].Width := 160;
  ejunpzall.Columns[12].Width := 60;

  ejunpzall.DataColumns.Items[7].Style.FormatString := '#,##0.00';
  ejunpzall.DataColumns.Items[8].Style.FormatString := '#,##0.00';

  begin
    qrypzb.Close;
    qrypzb.SQL.Clear;
    qrypzb.sql.Add('select * from 凭证表  where trim(科目编码) like '''
      + '100%' + '''');
    qrypzb.open;
    qrypzb.First;
  end;

  for I := 0 to qrypzb.Fields.Count - 1 do
  begin
    if (qrypzb.Fields[i].Name <> '现金流量') and (qrypzb.Fields[i].Name <>
      '经营其他') then
      qrypzb.Fields[i].ReadOnly := true;
  end;

  //=============以下单张凭证

end;

procedure Tfmcash.FormShow(Sender: TObject);
begin

  fxmid := axm.xmid;

  formatcash;
  openpzsheet;
  openpzone;
  opencashtotal;
  openkmyeb;
  pgc3.ActivePageIndex := 0;
  pgc2.ActivePageIndex := 0;
  pgc1.ActivePageIndex := 0;

  tbdw.TableName := '底稿单位';
  tbdw.Open;
  tbdw.Filtered := false;
  tbdw.Filter := 'xmid=''' + fxmid + '''';
  tbdw.Filtered := True;
  mmo1.Text := tbdw.FieldByName('项目备注').AsString;
  tbdw.Close;

  if tbkey.Active = false then
    tbkey.Open;

  if not tb1.Active then
    tb1.Open;

  if not tb2.Active then
    tb2.Open;
end;

procedure Tfmcash.ejunpzallMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ejunPZALL.tag := y;
end;

procedure Tfmcash.ejunpzallDblClick(Sender: TObject);
var
  ICOL: LongInt;
begin
  //

  if ejunPZALL.tag <= 17 then
  begin
    icol := ejunPZALL.CurCol;
    if ejunPZALL.Columns[icol].Tag = 'Z' then
    begin
      ejunPZALL.SortRow(icol, true);
      ejunPZALL.Columns[icol].Tag := 'A'
    end
    else
    begin
      ejunPZALL.SortRow(icol, false);
      ejunPZALL.Columns[icol].Tag := 'Z'
    end;
    Exit;
    //    end;
  end;

  openpzone;

end;

procedure Tfmcash.btn1Click(Sender: TObject);
begin
  case
    Application.MessageBox('本操作将重新整理所有的现金流量，原有的分类将不保存，您继续吗？',
    '附注提示', MB_YESNO + MB_ICONQUESTION) of
    IDYES:
      begin
        if Application.MessageBox('按YES将继续，否则退出！',
          '附注提示', MB_YESNO + MB_ICONQUESTION) = IDYES then
        else
          exit;
      end;
    IDNO:
      begin
        exit;
      end;
  end;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 a,dg7 b');
  qrytmp.SQL.Add(' set a.一级名称=trim(b.科目名称) ');
  qrytmp.SQL.Add('where a.一级编码=b.代码 ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 a');
  qrytmp.SQL.Add(' set a.借贷="借" ');
  qrytmp.SQL.Add('where 借方<>0 and not (借方 is null) ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 a');
  qrytmp.SQL.Add(' set a.借贷="贷" ');
  qrytmp.SQL.Add('where 贷方<>0 and not (贷方 is null) ');
  //  qrytmp.SQL.Add(' and   (xmid=''' + fxmid + ''') ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 a');
  qrytmp.SQL.Add(' set a.现金流量="" ');
  //  qrytmp.SQL.Add(' where   (xmid=''' + fxmid + ''') ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 ');
  qrytmp.SQL.Add(' set 金额=ABS(借方+贷方) ');
  //  qrytmp.SQL.Add(' where   (xmid=''' + fxmid + ''') ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 a,(select * from 现金流量表对应 where (trim(摘要关键字)="") or  (摘要关键字 is null))   b');
  qrytmp.SQL.Add(' set a.现金流量=b.现金流量简称 ');
  qrytmp.SQL.Add('where trim(a.对方科目)=trim(b.对方科目)  and  trim(a.借贷)=trim(b.借贷) and a.现金否');
  //  qrytmp.SQL.Add(' and   (xmid=''' + fxmid + ''') ');
    // and 现金否  and b.摘要关键字=""
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' DELETE FROM xyz');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('INSERT INTO XYZ(PZH,JE,SL) select max(全凭证号) as pzh,max(金额) as je,count(*) as sl from 凭证表  ');
  qrytmp.SQL.Add('where ');
  qrytmp.SQL.Add('  (xmid=''' + fxmid + ''')  and 现金否  ');
  qrytmp.SQL.Add(' and  ( trim(对方科目) like ''' + '%现金%' +
    '''  or  trim(对方科目) like ''' + '%银行存款%' +
    '''');
  qrytmp.SQL.Add(' or  trim(对方科目) like ''' + '%货币资金%' + '''  )');
  qrytmp.SQL.Add(' group  by 全凭证号,金额 ');
  qrytmp.SQL.Add(' having count(*) >=2');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 a,xyz b');
  qrytmp.SQL.Add(' set a.现金流量="OK" WHERE  a.全凭证号=b.pzh  ');
  qrytmp.SQL.Add('AND  A.金额=b.je  and b.sl=2');
  //  qrytmp.SQL.Add(' and   (xmid=''' + fxmid + ''') ');

  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 a,xyz b');
  qrytmp.SQL.Add(' set a.经营其他="XA" WHERE  a.全凭证号=b.pzh  ');
  qrytmp.SQL.Add('AND  A.金额=b.je  and b.sl>2');
  //  qrytmp.SQL.Add(' and   (xmid=''' + fxmid + ''') ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 a');
  qrytmp.SQL.Add(' set a.现金流量="OK"   WHERE  a.经营其他="XA"   and a.现金否 ');
  qrytmp.SQL.Add('AND  (a.摘要 like "%转%" or  a.摘要 like "%现%"  or a.摘要 like "%行%") ');
  //  qrytmp.SQL.Add(' and   (xmid=''' + fxmid + ''') ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.sql.Clear;
  qrytmp.SQL.Add('delete from xyz');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.sql.Add('insert into xyz(pzh,je)');
  qrytmp.sql.Add('select max(全凭证号) as pzh,max(金额) as je ');
  qrytmp.sql.Add(' from 凭证表    where (xmid=''' + fxmid +
    ''')  and 现金流量="OK"  and 现金否');
  qrytmp.sql.Add(' group by  全凭证号,金额');
  qrytmp.sql.Add(' having (sum(借方)-sum(贷方))<>0');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 a,xyz b');
  qrytmp.SQL.Add(' set a.现金流量="" WHERE  a.全凭证号=b.pzh  ');
  qrytmp.SQL.Add('AND  A.金额=b.je  ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update  凭证表 a,');
  qrytmp.SQL.Add('(SELECT 全凭证号, 贷方,一级名称  FROM 凭证表  WHERE (trim(xmid)=''' + fxmid + ''')) b');
  qrytmp.SQL.Add('  set a.判断依据=b.一级名称 ');
  qrytmp.SQL.Add('where a.全凭证号=b.全凭证号');
  qrytmp.SQL.Add(' and a.借方=b.贷方 and a.现金否  ');
  qrytmp.SQL.Add(' and  a.借方<>0 '); //and (trim(xmid)=''' + fxmid + ''')');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update  凭证表 a,');
  qrytmp.SQL.Add('(SELECT 全凭证号, 借方,一级名称  FROM 凭证表  WHERE (trim(xmid)=''' + fxmid + ''')) b');
  qrytmp.SQL.Add('  set a.判断依据=b.一级名称   ');
  qrytmp.SQL.Add('where a.全凭证号=b.全凭证号');
  qrytmp.SQL.Add(' and a.贷方=b.借方 and a.现金否  ');
  qrytmp.SQL.Add(' and  a.贷方<>0 '); //and (trim(xmid)=''' + fxmid + ''')');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 a,现金流量表对应  b');
  qrytmp.SQL.Add(' set a.现金流量=b.现金流量简称 ');
  qrytmp.SQL.Add('where trim(a.判断依据)=trim(b.对方科目)  and  trim(a.借贷)=trim(b.借贷) ');
  qrytmp.SQL.Add('  and 现金否 and trim(现金流量)="" ');
  qrytmp.ExecSQL;

  tb1.DisableControls;
  tb1.First;
  while not tb1.Eof do
  begin
    if tb1.FieldByName('摘要关键字').AsString <> '' then
    begin
      qrytmp.Close;
      qrytmp.SQL.Clear;
      qrytmp.SQL.Add(' update 凭证表 a');
      qrytmp.SQL.Add(' set a.现金流量= ''' +
        tb1.fieldbyname('现金流量简称').asstring + '''');
      qrytmp.SQL.Add('where trim(a.对方科目) like ''%' +
        trim(tb1.fieldbyname('对方科目').asstring) + '%''');
      qrytmp.SQL.Add(' and  trim(a.摘要) like ''%' +
        trim(tb1.fieldbyname('摘要关键字').asstring) + '%''');
      qrytmp.SQL.Add(' and   (xmid=''' + fxmid + ''')  and 现金否 ');
      if not tb1.FieldByName('全局替换').AsBoolean then
        qrytmp.SQL.Add('     and (trim(现金流量)="" or 现金流量 is null)  ');
      if tb1.fieldbyname('借贷').asstring <> '' then
        qrytmp.SQL.Add(' and  trim(a.借贷)= ''' +
          trim(trim(tb1.fieldbyname('借贷').asstring)) + '''');
      qrytmp.ExecSQL;
    end;
    tb1.Next;
  end;
  tb1.EnableControls;

  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.SQL.Add(' select * from 凭证表  ');
  qrypzb.SQL.Add('where ');
  qrypzb.SQL.Add(' 现金否 ');
  qrypzb.SQL.Add('order by 全凭证号,金额');
  qrypzb.open;

  opencashtotal;

  mymessage('现金流量处理完毕！');
end;

procedure Tfmcash.openpzone;
var
  STRLIST: tstringlist;
  stext: string;
  i: Integer;
begin

  stext :=
    '全凭证号,一级名称,科目编码, 科目名称, 摘要, 借方, 贷方,fitnum ,现金流量,经营其他, 对方科目,判断依据,id,现金否';
  STRLIST := tstringlist.create();
  STRLIST.Delimiter := ',';
  STRLIST.DelimitedText := stext;

  for i := 1 to strlist.Count do
  begin
    if I >= ejunpzone.DataColumns.Count - 1 then
      ejunpzone.DataColumns.Add;
    ejunpzone.DATAColumns.Items[i - 1].FieldName := strlist[i - 1];
    ejunpzone.DATAColumns.Items[I - 1].Title := STRLIST[I - 1];
  end;

  ejunpzone.Columns[1].Width := 120;
  ejunpzone.Columns[2].Width := 50;
  ejunpzone.Columns[3].Width := 50;
  ejunpzone.Columns[4].Width := 50;
  ejunpzone.Columns[5].Width := 200;
  ejunpzone.Columns[6].Width := 100;
  ejunpzone.Columns[7].Width := 100;
  ejunpzone.Columns[8].Width := 70;
  ejunpzone.Columns[9].Width := 70;
  ejunpzone.Columns[10].Width := 90;

  ejunpzone.DataColumns.Items[7].Style.FormatString := '#,##0.00';
  ejunpzone.DataColumns.Items[6].Style.FormatString := '#,##0.00';

  qryQRYonepz.Close;
  qryQRYonepz.SQL.Clear;
  qryQRYonepz.sql.Add('select * from 凭证表  where (xmid=''' + fxmid +
    ''')  and trim(全凭证号) ='''
    + trim(qrypzb.fieldbyname('全凭证号').asstring) + '''');
  qryQRYonepz.open;
  qryQRYonepz.First;
end;

procedure Tfmcash.qrypzbAfterScroll(DataSet: TDataSet);
begin
  openpzone;
end;

procedure Tfmcash.pgc2Change(Sender: TObject);
begin
  if pgc2.ActivePageIndex = 0 then
  begin
    opencashtotal;
  end;
end;

procedure Tfmcash.opencashtotal;
var
  STRLIST: tstringlist;
  stext: string;
  i: Integer;
begin

  stext :=
    '现金流量, 借方 ,贷方';
  STRLIST := tstringlist.create();
  STRLIST.Delimiter := ',';
  STRLIST.DelimitedText := stext;

  for i := 1 to strlist.Count do
  begin
    if I >= ejuncashtotal.DataColumns.Count - 1 then
      ejuncashtotal.DataColumns.Add;
    ejuncashtotal.DATAColumns.Items[i - 1].FieldName := strlist[i - 1];
    ejuncashtotal.DATAColumns.Items[I - 1].Title := STRLIST[I - 1];
  end;

  ejuncashtotal.Columns[1].Width := 90;
  ejuncashtotal.Columns[2].Width := 80;
  ejuncashtotal.Columns[3].Width := 80;
  ejuncashtotal.Columns[4].Width := 0;

  ejuncashtotal.DataColumns.Items[1].Style.FormatString := '#,##0.00';
  ejuncashtotal.DataColumns.Items[3].Style.FormatString := '#,##0.00';
  ejuncashtotal.DataColumns.Items[2].Style.FormatString := '#,##0.00';

  qrycash.Close;
  qrycash.SQL.Clear;
  qrycash.sql.Add('select max(现金流量) as 现金流量,SUM(借方) as 借方 ,SUM(贷方) as 贷方');
  qrycash.sql.Add(' from 凭证表    where (xmid=''' + trim(fxmid) +
    ''')  and 现金否');
  qrycash.sql.Add(' group by 现金流量 ');
  qrycash.open;
  qrycash.first;

end;

procedure Tfmcash.openbank(STR: string);
var
  STRLIST: tstringlist;
  stext: string;
  i: Integer;
begin

  stext :=
    '凭证号,借方,贷方 ,金额 ';
  STRLIST := tstringlist.create();
  STRLIST.Delimiter := ',';
  STRLIST.DelimitedText := stext;

  for i := 1 to strlist.Count do
  begin
    if I >= ejunbank.DataColumns.Count - 1 then
      ejunbank.DataColumns.Add;
    ejunbank.DATAColumns.Items[i - 1].FieldName := strlist[i - 1];
    ejunbank.DATAColumns.Items[I - 1].Title := STRLIST[I - 1];
  end;

  ejunbank.Columns[1].Width := 90;
  ejunbank.Columns[2].Width := 80;
  ejunbank.Columns[3].Width := 80;
  ejunbank.Columns[4].Width := 80;

  ejunbank.DataColumns.Items[1].Style.FormatString := '#,##0.00';
  ejunbank.DataColumns.Items[2].Style.FormatString := '#,##0.00';

  qrybank.Close;
  qrybank.SQL.Clear;
  qrybank.sql.Add('select max(全凭证号) as 凭证号 ,max(金额) as 金额,sum(借方) AS 借方,sum(贷方) as 贷方 ');
  qrybank.sql.Add(' from 凭证表    where trim(现金流量)=''' + STR +
    ''' and 现金否');
  qrybank.sql.Add(' group by  全凭证号');
  qrybank.open;

end;

procedure Tfmcash.ejuncashtotalDblClick(Sender: TObject);
begin

  if UpperCase(trim(qrycash.fieldbyname('现金流量').asstring)) = 'OK' then
  begin
    pgc2.ActivePageIndex := 1;
    openbank('OK');
  end
  else if UpperCase(trim(qrycash.fieldbyname('现金流量').asstring)) = 'X' then
  begin
    pgc2.ActivePageIndex := 1;
    openbank('X');
  end;

  if trim(qrycash.fieldbyname('现金流量').asstring) = '' then
  begin
    qrypzb.Close;
    qrypzb.SQL.Clear;
    qrypzb.sql.Add('select * from 凭证表  where (xmid=''' + fxmid +
      ''')  and 现金否   and (trim(现金流量)="" or 现金流量 is null)');
    qrypzb.open;
    qrypzb.First;
  end

  else
  begin
    qrypzb.Close;
    qrypzb.SQL.Clear;
    qrypzb.sql.Add('select * from 凭证表  where (xmid=''' + fxmid +
      ''')  and 现金否  and trim(现金流量) = '''
      + trim(qrycash.fieldbyname('现金流量').asstring) + '''');
    qrypzb.open;
    qrypzb.First;
  end;
  ejunpzall.Active := true;
  pgc1.ActivePageIndex := 0;
end;

procedure Tfmcash.ejunbankDblClick(Sender: TObject);
begin
  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('select * from 凭证表  where (xmid=''' + fxmid +
    ''')  and trim(全凭证号) = '''
    + trim(qrybank.fieldbyname('凭证号').asstring) + '''  ');
  qrypzb.open;
  qrypzb.First;
end;

procedure Tfmcash.formatcash;
begin

  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('update  凭证表  set 现金否=false  where xmid=''' + fxmid +
    '''');
  qrypzb.ExecSQL;

  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('update  凭证表  set 现金否=true  where xmid=''' + fxmid +
    '''  and 一级编码="1001"');
  qrypzb.ExecSQL;

  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('update  凭证表  set 现金否=true  where xmid=''' + fxmid +
    ''' and 一级编码="1002"');
  qrypzb.ExecSQL;

//  qrypzb.Close;
//  qrypzb.SQL.Clear;
//  qrypzb.sql.Add('update  凭证表  set 现金否=true  where xmid=''' + fxmid +
//    ''' and 一级编码="1003"');
//  qrypzb.ExecSQL;

end;

procedure Tfmcash.btn2Click(Sender: TObject);
begin
  tbdw.Open;
  tbdw.Filtered := false;
  tbdw.Filter := 'xmid=''' + fxmid + '''';
  tbdw.Filtered := True;
  tbdw.Edit;
  tbdw.FieldByName('项目备注').AsString := mmo1.Text;
  tbdw.Post;
  tbdw.Close;
end;

procedure Tfmcash.ejun1DblClick(Sender: TObject);
begin
  //
  qrypzb.Edit;
  qrypzb.FieldByName('现金流量').AsString :=
    tb2.fieldbyname('现金流量简称').AsString;
  qrypzb.Post;
  qrypzb.Refresh;
end;

procedure Tfmcash.ejun3DblClick(Sender: TObject);
begin
  //

  if Trim(tbkey.fieldbyname('关键字').asstring) <> '' then
  begin
    qrypzb.Close;
    qrypzb.SQL.Clear;
    qrypzb.sql.Add('select * from 凭证表  where (xmid=''' + fxmid +
      ''')  and 现金否 and 现金流量<>"ok" ');
    qrypzb.sql.Add('and 摘要 like ''%' + tbkey.fieldbyname('关键字').asstring +
      '%'' ');
    qrypzb.open;
    qrypzb.First;
  end;

end;

procedure Tfmcash.ejunpzallCellGetColor(Sender: TObject; ACoord: TPoint;
  var AColor: TColor);
begin

  if ejunpzall.Cells[14, ACoord.Y].AsBoolean then
    AColor := cl3DLight
  else
    AColor := clWindow;

end;

procedure Tfmcash.OPENCASHSHEET;
var
  STRLIST: tstringlist;
  stext: string;
  i: Integer;
  asum, bsum: Double;
begin

  stext :=
    '现金流量项目	,金额 ,现金流量简称,	ID	,	标识 ';
  STRLIST := tstringlist.create();
  STRLIST.Delimiter := ',';
  STRLIST.DelimitedText := stext;

  for i := 1 to strlist.Count do
  begin
    if I >= ejuncashsheet.DataColumns.Count - 1 then
      ejuncashsheet.DataColumns.Add;
    ejuncashsheet.DATAColumns.Items[i - 1].FieldName := strlist[i - 1];
    ejuncashsheet.DATAColumns.Items[I - 1].Title := STRLIST[I - 1];
  end;

  ejuncashsheet.Columns[1].Width := 270;
  ejuncashsheet.Columns[2].Width := 100;
  ejuncashsheet.Columns[3].Width := 100;
  ejuncashsheet.Columns[4].Width := 0;
  ejuncashsheet.Columns[5].Width := 0;

  ejuncashsheet.DataColumns.Items[1].Style.FormatString := '#,##0.00';

  qrytmp.Connection := con1;
  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.sql.Add('update 现金流量表项目 a');
  qrytmp.sql.Add(' set a.金额=0 '); // where (xmid=''' + fxmid + ''') ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.sql.Add('DELETE FROM  XYZ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.sql.Add('INSERT INTO XYZ(PZH,JE)');
  qrytmp.sql.Add('select max(现金流量) as PZH,SUM(借方)-SUM(贷方) as JE');
  qrytmp.sql.Add(' from 凭证表    where  现金否');
  qrytmp.sql.Add(' group by 现金流量');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.sql.Add('update 现金流量表项目 a,XYZ B');
  qrytmp.sql.Add(' set a.金额=b.JE');
  qrytmp.sql.Add(' where  TRIM(a.现金流量简称)=TRIM(b.PZH)  and INSTR("ACE",A.标识)>0');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.sql.Add('update 现金流量表项目 a,XYZ B');
  qrytmp.sql.Add(' set a.金额=-b.JE');
  qrytmp.sql.Add(' where  TRIM(a.现金流量简称)=TRIM(b.PZH) and INSTR("BDF",A.标识)>0');
  qrytmp.ExecSQL;

  if tbCASHSHEET.Active = FALSE then
  begin
    tbCASHSHEET.open;
  end
  else
  begin

    tbCASHSHEET.Close;
    tbCASHSHEET.open;

  end;
  tbCASHSHEET.DisableControls;
  tbcashsheet.First;
  asum := 0;
  bsum := 0;
  i := 0;

  while not tbCASHSHEET.Eof do
  begin
    if Pos('小计', tbCASHSHEET.fieldbyname('现金流量项目').AsString) > 0 then
    begin
      tbCASHSHEET.edit;
      tbCASHSHEET.fieldbyname('金额').asfloat := asum;
      tbCASHSHEET.post;

      if i = 0 then
      begin
        bsum := asum;
        asum := 0;
        i := i + 1;
      end;
    end
    else if Pos('现金流量净额', tbCASHSHEET.fieldbyname('现金流量项目').AsString)
      > 0 then
    begin
      tbCASHSHEET.edit;
      tbCASHSHEET.fieldbyname('金额').asfloat := bsum - asum;
      tbCASHSHEET.post;
      //   bsum :=
      asum := 0;
      bsum := 0;
      i := 0;
    end
    else
      asum := asum + tbCASHSHEET.fieldbyname('金额').asfloat;

    tbCASHSHEET.Next;
  end;
  tbcashsheet.First;
  tbCASHSHEET.EnableControls;
end;

procedure Tfmcash.btnupdatesheetClick(Sender: TObject);
begin
  OPENCASHSHEET;
end;

procedure Tfmcash.pgc1Change(Sender: TObject);
begin
  if pgc1.ActivePageIndex = 2 then
    OPENCASHSHEET
  else if pgc1.ActivePageIndex = 3 then
    OPENOTHER;
end;

procedure Tfmcash.openkmyeb;
var
  STRLIST: tstringlist;
  stext: string;
  i: Integer;
  asum, bsum: Double;
begin

  stext := '代码,科目名称, 借货方向,期初,	借方发生,	贷方发生,期末,ID ';

  STRLIST := tstringlist.create();
  STRLIST.Delimiter := ',';
  STRLIST.DelimitedText := stext;

  for i := 1 to strlist.Count do
  begin
    if I >= ejunkmyeb.DataColumns.Count - 1 then
      ejunkmyeb.DataColumns.Add;
    ejunkmyeb.DATAColumns.Items[i - 1].FieldName := strlist[i - 1];
    ejunkmyeb.DATAColumns.Items[I - 1].Title := STRLIST[I - 1];
  end;

  ejunkmyeb.Columns[0].Width := 10;
  ejunkmyeb.Columns[1].Width := 70;
  ejunkmyeb.Columns[2].Width := 150;
  ejunkmyeb.Columns[3].Width := 60;
  ejunkmyeb.Columns[4].Width := 100;
  ejunkmyeb.Columns[5].Width := 100;
  ejunkmyeb.Columns[6].Width := 100;
  ejunkmyeb.Columns[7].Width := 100;
  ejunkmyeb.Columns[8].Width := 0;

  ejunkmyeb.DataColumns.Items[4].Style.FormatString := '#,##0.00';
  ejunkmyeb.DataColumns.Items[5].Style.FormatString := '#,##0.00';
  ejunkmyeb.DataColumns.Items[6].Style.FormatString := '#,##0.00';
  ejunkmyeb.DataColumns.Items[7].Style.FormatString := '#,##0.00';

  qrykmyeb.Close;
  qrykmyeb.SQL.Clear;
  qrykmyeb.sql.Add('select * from dg7  order by 代码,一级科目代码,代码');
  qrykmyeb.open;
  ejunkmyeb.DataSet := qrykmyeb;
  ejunkmyeb.Active := true;
end;

procedure Tfmcash.pgc3Change(Sender: TObject);
begin
  if pgc3.ActivePageIndex = 1 then
    openkmyeb;
end;

procedure Tfmcash.ejunkmyebDblClick(Sender: TObject);
begin

  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('select * from 凭证表  where 现金否 and 现金流量<>''ok''   and 全凭证号 in ');
  qrypzb.sql.Add('(select 全凭证号 from 凭证表  where  科目编码 like :dm )');
  qrypzb.Parameters.ParamByName('dm').value :=
    qrykmyeb.fieldbyname('代码').asstring + '%';
  qrypzb.open;
  qrypzb.First;

  pgc1.ActivePageIndex := 0;
  ejunpzall.active := true;

end;

procedure Tfmcash.ejunpzoneDblClick(Sender: TObject);
var
  icol: LongInt;
begin
  //
  if ejunpzone.tag <= 17 then
  begin

    icol := ejunpzone.CurCol;
    if ejunpzone.Columns[icol].Tag = 'Z' then
    begin
      ejunpzone.SortRow(icol, true);
      ejunpzone.Columns[icol].Tag := 'A'
    end
    else
    begin
      ejunpzone.SortRow(icol, false);
      ejunpzone.Columns[icol].Tag := 'Z'
    end;
    Exit;
  end;

  ejunpzone.Columns[1].Width := 60;
  ejunpzone.Columns[2].Width := 40;
  ejunpzone.Columns[3].Width := 200;
  ejunpzone.Columns[4].Width := 100;
  ejunpzone.Columns[5].Width := 40;
  ejunpzone.Columns[6].Width := 90;
  ejunpzone.Columns[7].Width := 90;
  ejunpzone.Columns[8].Width := 90;
  ejunpzone.Columns[9].Width := 90;
  ejunpzone.Columns[10].Width := 160;

  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('select * from 凭证表  where (xmid=''' + fxmid +
    ''')  and trim(全凭证号) ='''
    + trim(qryQRYonepz.fieldbyname('全凭证号').asstring) + '''');
  qrypzb.open;
  qrypzb.First;
end;

procedure Tfmcash.ejunpzoneMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ejunpzone.tag := y;
end;

procedure Tfmcash.openother;
var
  STRLIST: tstringlist;
  stext: string;
  i: Integer;
  asum, bsum: Double;
begin

  stext := '现金流量,	其他流量明细,	金额';

  STRLIST := tstringlist.create();
  STRLIST.Delimiter := ',';
  STRLIST.DelimitedText := stext;

  for i := 1 to strlist.Count do
  begin
    if I >= EJUNOTHER.DataColumns.Count - 1 then
      EJUNOTHER.DataColumns.Add;
    EJUNOTHER.DATAColumns.Items[i - 1].FieldName := strlist[i - 1];
    EJUNOTHER.DATAColumns.Items[I - 1].Title := STRLIST[I - 1];
  end;

  EJUNOTHER.Columns[0].Width := 30;
  EJUNOTHER.Columns[1].Width := 100;
  EJUNOTHER.Columns[2].Width := 200;
  EJUNOTHER.Columns[2].Width := 100;

  EJUNOTHER.DataColumns.Items[1].Style.FormatString := '#,##0.00';
  EJUNOTHER.DataColumns.Items[2].Style.FormatString := '#,##0.00';

  qryother.Connection := con1;
  QRYOTHER.Close;
  QRYOTHER.SQL.Clear;
  QRYOTHER.sql.Add('select max(现金流量) as 现金流量,max(经营其他) as 其他流量明细,SUM(借方)-sum(贷方) as 金额 from 凭证表');
  QRYOTHER.sql.Add('WHERE INSTR(现金流量,"其他")>0');
  QRYOTHER.sql.Add('  GROUP BY 现金流量,经营其他');
  QRYOTHER.open;
end;

procedure Tfmcash.ejunOTHERDblClick(Sender: TObject);
begin
  //

  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('select * from 凭证表  where (xmid=''' + fxmid +
    ''')  and 现金否 ');
  qrypzb.sql.Add(' and 现金流量=''' + qryother.fieldbyname('现金流量').asstring
    +
    ''' ');
  if Trim(qryother.fieldbyname('其他流量明细').asstring) <> '' then
  begin
    qrypzb.sql.Add(' and 经营其他=''' +
      qryother.fieldbyname('其他流量明细').asstring + '''');
  end
  else
    qrypzb.sql.Add(' and (trim(经营其他)="" or 经营其他 is  null) ');

  qrypzb.open;
  //  mymessage(INTTOSTR(QRYPZB.RECORDCOUNT));
  qrypzb.First;
  pgc1.ActivePageIndex := 0;

end;

procedure Tfmcash.ejunpzallSelectionChange(Sender: TObject;
  const ARange: TRect);
begin
  //

end;

procedure Tfmcash.btn5Click(Sender: TObject);
var
  aform: Tfmopendw;
begin
  aform := tfmopendw.Create(nil);
  aform.con1 := con1;
  aform.ShowModal;

  // LoadParamFromFile();

end;

procedure Tfmcash.ListBox1DblClick(Sender: TObject);
begin
  qrypzb.Edit;

  qrypzb.FieldByName('现金流量').AsString := listbox1.Items[listbox1.ItemIndex];
  qrypzb.Post;
  qrypzb.Refresh;

end;

procedure Tfmcash.UPDATRARR;
var
  QQX: integer;
begin
  QQX := 1;
  while QQX <= ALLREC do
  begin

    if pz[QQX].km = 'over' then
      break;

    if PZ[QQX].FITNUM <> '' then
    begin
      qrytmp.close;
      qrytmp.sql.clear;
      qrytmp.sql.add('update 凭证表 set  fitnum=:FITNUM WHERE ID=:ID');
      QRYTMP.Parameters.ParamByName('ID').VALUE := PZ[QQX].id;
      QRYTMP.Parameters.ParamByName('FITNUM').VALUE := PZ[QQX].FITNUM;
      qrytmp.ExecSQL;
    end;
    QQX := QQX + 1;
  end;
end;

procedure Tfmcash.cleararr;
var
  RECD: integer;
begin
  for RECD := 1 to ALLREC do
  begin
    pz[RECD].km := '';
    pz[RECD].jf := 0;
    pz[RECD].df := 0;
    pz[RECD].FITNUM := '';
    pz[RECD].iscash := false;
    pz[RECD].cashtype := '';
  end;
end;

procedure Tfmcash.calcfit;
var
  i: integer;

begin
  //
  I := 1;
  while I <= ALLREC do
  begin
    if pz[i].km = 'over' then
      break;

    if pz[i].iscash then
    begin
      if pz[i].jf <> 0 then
      begin
        lookforDf(pz[i].Jf, i);
      end
      else
      begin
        lookforJf(pz[i].Df, i);
      end;
    end;

    I := I + 1;
  end;

  lookforother();
end;

procedure Tfmcash.lookfordf(je: double; const sxh: integer);
var
  j, k: integer;
  suma: double;
begin
  //
  J := 1;

  if pz[sxh].fitnum = '' then
    while J <= ALLREC do
    begin
      if pz[j].km = 'over' then
        break;

      if (round((pz[j].df - je) * 100) = 0) and (pz[j].fitnum =
        '') then
      begin
        pz[j].fitnum := 'xj' + inttostr(sxh);
        pz[sxh].fitnum := 'xj' + inttostr(sxh);
        break;
      end;
      J := J + 1;
    end;

  if pz[sxh].fitnum = '' then
  begin
    suma := 0;
    for j := sxh to 1 do
    begin
      if pz[j].km = 'over' then
        break;

      if pz[j].fitnum = '' then
      begin
        suma := suma + pz[j].df;

        if suma = je then
        begin
          for k := sxh downto j do
          begin

            if (pz[k].fitnum = '') and (pz[k].df <> 0) then
              pz[k].fitnum := 'xj' + inttostr(sxh);
          end;
          pz[sxh].fitnum := 'xj' + inttostr(sxh);
          break;
        end;
      end;
    end;
  end;

  if pz[sxh].fitnum = '' then
  begin
    suma := 0;
    for j := sxh to ALLREC do
    begin

      if pz[j].km = 'over' then
        break;

      if pz[j].fitnum = '' then
      begin
        if pz[j].km = 'over' then
          break;

        suma := suma + pz[j].df;
        if round((suma - je) * 100) = 0 then
        begin
          for k := sxh to j do
          begin

            if (pz[k].fitnum = '') and (pz[k].df <> 0) then
              pz[k].fitnum := 'xj' + inttostr(sxh);
          end;
          pz[sxh].fitnum := 'xj' + inttostr(sxh);
          break;
        end;
      end;
    end;
  end;

  if pz[sxh].fitnum = '' then
  begin
    suma := 0;
    for j := 1 to ALLREC do
    begin

      if pz[j].km = 'over' then
        break;

      if pz[j].fitnum = '' then
      begin
        if pz[j].km = 'over' then
          break;

        suma := suma + pz[j].df;
        if round((suma - je) * 100) = 0 then
        begin
          for k := 1 to j do
          begin
            if (pz[k].fitnum = '') and (pz[k].df <> 0) then
              pz[k].fitnum := 'xj' + inttostr(sxh);
          end;
          pz[sxh].fitnum := 'xj' + inttostr(sxh);
          break;
        end;
      end;
    end;
  end;
end;

procedure Tfmcash.lookforjf(je: double; const sxh: integer);
var
  j, k: integer;
  suma: double;
begin
  //  //

  //找相等
  j := 1;
  if pz[sxh].fitnum = '' then
    while j <= ALLREC do
    begin
      if pz[j].km = 'over' then
        break;

      if (round(pz[j].jf * 100) = round(je * 100)) and (pz[j].fitnum =
        '') then
      begin
        pz[j].fitnum := 'xj' + inttostr(sxh);
        pz[sxh].fitnum := 'xj' + inttostr(sxh);
        break;
      end;
      j := j + 1;
    end;

  //  if trim(pz[sxh].km) = '1899_ 12_记账340.0000' then
  //    showmessage(floattostr(pz[sxh].df) + '上');

    //往上找
  if pz[sxh].fitnum = '' then
  begin
    suma := 0;
    for j := sxh downto 1 do
    begin
      if pz[j].fitnum = '' then
      begin
        suma := suma + pz[j].jf;

        if ROUND((suma - je) * 100) = 0 then
        begin
          for k := sxh downto j do
          begin
            //   if trim(pz[sxh].km) = '1899_ 12_记账340.0000' then
   //              showmessage(inttostr(j) + '-' + floattostr(pz[k].jf));
            if (pz[k].fitnum = '') and (pz[k].jf <> 0) then
              pz[k].fitnum := 'xj' + inttostr(sxh);
          end;
          pz[sxh].fitnum := 'xj' + inttostr(sxh);
          break;
        end;
      end;
    end;
  end;

  //  if trim(pz[sxh].km) = '1899_ 12_记账340.0000' then
  //    showmessage(floattostr(pz[sxh].df) + '下');

    //往下找
  if pz[sxh].fitnum = '' then
  begin
    suma := 0;
    for j := sxh to ALLREC do
    begin
      if pz[j].fitnum = '' then
      begin
        if pz[j].km = 'over' then
          break;

        suma := suma + pz[j].jf;
        if ROUND((suma - je) * 100) = 0 then
        begin
          for k := sxh to j do
          begin
            if (pz[k].fitnum = '') and (pz[k].jf <> 0) then
              pz[k].fitnum := 'xj' + inttostr(sxh);
          end;
          pz[sxh].fitnum := 'xj' + inttostr(sxh);
          break;
        end;
      end;
    end;
  end;

  //if trim(pz[sxh].km) = '1899_ 12_记账340.0000' then
//    showmessage(floattostr(pz[sxh].df) + '全部');
  //  //   全部找
  if pz[sxh].fitnum = '' then
  begin
    suma := 0;
    for j := 1 to ALLREC do
    begin
      if pz[j].fitnum = '' then
      begin
        if pz[j].km = 'over' then
          break;

        suma := suma + pz[j].jf;
        if ROUND((suma - je) * 100) = 0 then
        begin
          for k := 1 to j do
          begin
            if (pz[k].fitnum = '') and (pz[k].jf <> 0) then
              pz[k].fitnum := 'xj' + inttostr(sxh);
          end;
          pz[sxh].fitnum := 'xj' + inttostr(sxh);
          break;
        end;
      end;
    end;
  end;
end;

procedure Tfmcash.lookforother;
var
  SUMA: DOUBLE;
  cc, dd: integer;
begin
  //   现金合计找其他
  //借方合计找贷方
  suma := 0;

  for cc := 1 to ALLREC do
  begin
    if pz[cc].km = 'over' then
      break;

    if (pz[cc].iscash) and (pz[cc].FITNUM = '') and (pz[cc].jf <> 0) then
      suma := suma + pz[cc].jf;

  end;

  if suma <> 0 then
    for cc := 1 to ALLREC do
    begin
      if (pz[cc].fitnum = '') and (round((pz[cc].dF - suma) * 100) = 0) then
      begin

        pz[cc].fitnum := '借方OK';
        for dd := 1 to 500 do
        begin
          if pz[dd].km = 'over' then
            break;

          if (pz[dd].iscash) and (pz[dd].FITNUM = '') and (pz[dd].jf <> 0) then
            pz[dd].fitnum := '借方OK';
        end;
      end;
    end;
  ////==========   贷方合计找借方

  suma := 0;

  for cc := 1 to ALLREC do
  begin
    if pz[cc].km = 'over' then
      break;

    if (pz[cc].iscash) and (pz[cc].FITNUM = '') and (pz[cc].df <> 0) then
      suma := suma + pz[cc].df;

  end;
  if suma <> 0 then
    for cc := 1 to ALLREC do
    begin
      if (pz[cc].fitnum = '') and (round((pz[cc].jF - suma) * 100) = 0) then
      begin

        pz[cc].fitnum := '贷方OK';
        for dd := 1 to 500 do
        begin
          if pz[dd].km = 'over' then
            break;

          if (pz[dd].iscash) and (pz[dd].FITNUM = '') and (pz[dd].df <> 0) then
            pz[dd].fitnum := '贷方OK';
        end;
      end;
    end;

  //其他合计找现金****************************
  suma := 0;

  for cc := 1 to ALLREC do
  begin
    if pz[cc].km = 'over' then
      break;

    if (not pz[cc].iscash) and (pz[cc].FITNUM = '') and (pz[cc].jf <> 0) then
      suma := suma + pz[cc].jf;

  end;

  if suma <> 0 then
    for cc := 1 to ALLREC do
    begin
      if (pz[cc].fitnum = '') and (round((pz[cc].dF - suma) * 100) = 0) and
        (pz[cc].iscash) then
      begin
        pz[cc].fitnum := '其他合计借方OK';
        for dd := 1 to 500 do
        begin
          if pz[dd].km = 'over' then
            break;

          if (not pz[dd].iscash) and (pz[dd].FITNUM = '') and (pz[dd].jf <> 0)
            then
            pz[dd].fitnum := '其他合计借方OK';
        end;
      end;
    end;
  ////==========   贷方合计找借方

  suma := 0;

  for cc := 1 to ALLREC do
  begin
    if pz[cc].km = 'over' then
      break;

    if (not pz[cc].iscash) and (pz[cc].FITNUM = '') and (pz[cc].df <> 0) then
      suma := suma + pz[cc].df;

  end;
  if suma <> 0 then
    for cc := 1 to ALLREC do
    begin
      if (pz[cc].fitnum = '') and (round((pz[cc].jF - suma) * 100) = 0) and
        (pz[cc].iscash) then
      begin

        pz[cc].fitnum := '其他合计贷方OK';
        for dd := 1 to 500 do
        begin
          if pz[dd].km = 'over' then
            break;

          if (not pz[dd].iscash) and (pz[dd].FITNUM = '') and (pz[dd].df <> 0)
            then
            pz[dd].fitnum := '其他合计贷方OK';
        end;
      end;
    end;
  //仍有现金则将其他科目全部视为现金流量

  for cc := 1 to ALLREC do
  begin
    if pz[cc].km = 'over' then
      break;

    if (pz[cc].iscash) and (pz[cc].FITNUM = '') then
    begin
      for dd := 1 to ALLREC do
      begin

        if pz[dd].km = 'over' then
          break;

        if (pz[dd].FITNUM = '') then
          pz[dd].FITNUM := '挤平数据'
      end;
      break;
    end;
  end;
end;

procedure Tfmcash.Button1Click(Sender: TObject);
var
  newpzh: string;
  FILENAMEXLS, oldpzh: string;
 oldrec: longint;

  i, x, rec: integer;
  bk, bk1: tbookmark;
  STRLIST: tstringlist;
  stext: string;
begin
  //
  stext :=
    '全凭证号,科目编码,一级名称, 科目名称,现金流量,经营其他,  借方, 贷方,fitnum ,摘要, id,现金否';
  STRLIST := tstringlist.create();
  STRLIST.Delimiter := ',';
  STRLIST.DelimitedText := stext;
  ejunpzall.ClearAll;
  for i := 1 to strlist.Count do
  begin
    if I >= ejunpzall.DataColumns.Count - 1 then
      ejunpzall.DataColumns.Add;
    ejunpzall.DATAColumns.Items[i - 1].FieldName := strlist[i - 1];
    ejunpzall.DATAColumns.Items[I - 1].Title := STRLIST[I - 1];
  end;

  ejunpzall.Columns[1].Width := 120;
  ejunpzall.Columns[2].Width := 120;
  ejunpzall.Columns[3].Width := 120;
  ejunpzall.Columns[4].Width := 120;
  ejunpzall.Columns[5].Width := 80;
  ejunpzall.Columns[6].Width := 100;
  ejunpzall.Columns[7].Width := 100;
  ejunpzall.Columns[8].Width := 70;
  ejunpzall.Columns[9].Width := 70;
  ejunpzall.Columns[10].Width := 70;
  ejunpzall.Columns[11].Width := 70;
  ejunpzall.Columns[12].Width := 60;

  ejunpzall.DataColumns.Items[7].Style.FormatString := '#,##0.00';
  ejunpzall.DataColumns.Items[8].Style.FormatString := '#,##0.00';

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update 凭证表 set  fitnum=''''');
  qrytmp.ExecSQL;

  tbcalccash.Connection := con1;
  tbcalccash.TableName := '凭证表';

  tbcalccash.Open;
  tbcalccash.Sort := '全凭证号';

  tbcalccash.First;
  oldpzh := '';
  i := 0;

  while not tbcalccash.Eof do
  begin
    newpzh := tbcalccash.fieldbyname('全凭证号').asstring;
    if newpzh = oldpzh then //不是新凭证
    begin
      i := i + 1;
      pz[i].km := tbcalccash.fieldbyname('全凭证号').asstring;
      pz[i].jf := tbcalccash.fieldbyname('借方').asfloat;
      pz[i].df := tbcalccash.fieldbyname('贷方').asfloat;
      pz[i].iscash := tbcalccash.fieldbyname('现金否').asboolean;
      pz[i].ID := tbcalccash.fieldbyname('ID').ASINTEGER;
      pz[i].cashtype := '';
    end
    else
    begin //是新凭证
      //先处理老凭证号
      i := i + 1;
      pz[i].km := 'over';
      calcfit();
      UPDATRARR;
      //开始新凭证
      cleararr;
      oldpzh := newpzh;
      i := 1;
      pz[i].km := tbcalccash.fieldbyname('全凭证号').asstring;
      pz[i].jf := tbcalccash.fieldbyname('借方').asfloat;
      pz[i].df := tbcalccash.fieldbyname('贷方').asfloat;
      pz[i].iscash := tbcalccash.fieldbyname('现金否').asboolean;
      pz[i].cashtype := '';
      pz[i].ID := tbcalccash.fieldbyname('ID').ASINTEGER;

      if i > 500 then
        showmessage('ERR:单笔凭证超500行，不能处理！');
    end;

    tbcalccash.next;
  end;
  i := i + 1;
  pz[i].km := 'over';
  calcfit();
  UPDATRARR;
  dofx();

  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('select * from 凭证表  where  (fitnum<>"" ) and 全凭证号 in  ');
  qrypzb.sql.Add('(select 全凭证号 from 凭证表  where  现金否  ) order by 全凭证号');

  qrypzb.open;
  qrypzb.First;

  pgc1.ActivePageIndex := 0;
  ejunpzall.active := true;

  dlgSave1.InitialDir := mainpath;
  dlgSave1.Execute;
  if dlgSave1.FileName <> '' then
  begin
    if Pos('.', dlgSave1.FileName) < 1 then
      FILENAMEXLS := dlgSave1.FileName + '.XLS'
    else
      FILENAMEXLS := dlgSave1.FileName;

    ejunpzall.SaveToExcel(FILENAMEXLS, '现金流',true,false);
  //  ejunpzall.SaveToExcel();
    mymessage('导出成功!');
    Close;
    ShellExecute(Handle, 'open', PChar(FILENAMEXLS),
      'C:\Windows', nil, 1);
  end
  else
  begin
    mymessage('取消保存!');
  end;
end;

procedure Tfmcash.dofx;
begin
  //
  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 a,现金流量表对应    b');
  qrytmp.SQL.Add(' set a.现金流量=b.现金流量简称 ,a.经营其他=trim(b.其他) ');
  qrytmp.SQL.Add('where trim(a.一级名称)=trim(b.对方科目)  and (TRIM(b.摘要关键字)="" OR (b.摘要关键字 IS NULL) )');
  qrytmp.SQL.Add('  and (a.fitnum<>"") ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.Connection := con1;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 a, 现金流量表对应  b');
  qrytmp.SQL.Add(' set a.现金流量=b.现金流量简称,a.经营其他=trim(b.其他 )');
  qrytmp.SQL.Add(' where trim(a.一级名称)=trim(b.对方科目) and  trim(a.科目名称)=trim(b.摘要关键字) ');
  qrytmp.SQL.Add('  and (trim(a.fitnum)<>"" )  and (TRIM(b.摘要关键字)<>"") ');
  qrytmp.ExecSQL;

end;

procedure Tfmcash.btn4Click(Sender: TObject);
var
  STRLIST: tstringlist;
  stext: string;
  i: Integer;
  FILENAMEXLS: string;
begin
  //
  stext :=
    '全凭证号,科目编码,一级名称, 科目名称,现金流量,经营其他,  借方, 贷方,fitnum ,摘要, id,现金否';
  STRLIST := tstringlist.create();
  STRLIST.Delimiter := ',';
  STRLIST.DelimitedText := stext;
  ejunpzall.ClearAll;
  for i := 1 to strlist.Count do
  begin
    if I >= ejunpzall.DataColumns.Count - 1 then
      ejunpzall.DataColumns.Add;
    ejunpzall.DATAColumns.Items[i - 1].FieldName := strlist[i - 1];
    ejunpzall.DATAColumns.Items[I - 1].Title := STRLIST[I - 1];
  end;

 ejunpzall.Columns[1].Width := 120;
  ejunpzall.Columns[2].Width := 80;
  ejunpzall.Columns[3].Width := 80;
  ejunpzall.Columns[4].Width := 140;
  ejunpzall.Columns[5].Width := 100;
  ejunpzall.Columns[6].Width := 100;
  ejunpzall.Columns[7].Width := 100;
  ejunpzall.Columns[8].Width := 70;
  ejunpzall.Columns[9].Width := 70;
  ejunpzall.Columns[10].Width := 70;
  ejunpzall.Columns[11].Width := 70;
  ejunpzall.Columns[12].Width := 60;

  ejunpzall.DataColumns.Items[5].Style.FormatString := '#,##0.00';
  ejunpzall.DataColumns.Items[6].Style.FormatString := '#,##0.00';
  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('select * from 凭证表  where  (fitnum<>"" ) and 全凭证号 in  ');
  qrypzb.sql.Add('(select 全凭证号 from 凭证表  where  现金否  ) order by 全凭证号');

  qrypzb.open;
  qrypzb.First;

  pgc1.ActivePageIndex := 0;
  ejunpzall.active := true;
  dlgSave1.InitialDir := mainpath;
  dlgSave1.Execute;
  if dlgSave1.FileName <> '' then
  begin
    if Pos('.', dlgSave1.FileName) < 1 then
      FILENAMEXLS := dlgSave1.FileName + '.XLS'
    else
      FILENAMEXLS := dlgSave1.FileName;

    ejunpzall.SaveToExcel(FILENAMEXLS, '现金流',true,false);
    mymessage('导出成功!');
    Close;
    ShellExecute(Handle, 'open', PChar(FILENAMEXLS),
      'C:\Windows', nil, 1);
  end
  else
  begin
    mymessage('取消保存!');
  end;

end;

end.

