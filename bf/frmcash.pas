unit frmcash;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, ZcUniClass, ZJGrid, ZcDataGrid, ZcDBGrids, ushare,
  DB, ADODB, ZcGridClasses, StdCtrls;

type
  Tfmcash = class(TForm)
    pnl1: TPanel;
    pnl2: TPanel;
    pgc1: TPageControl;
    ts1: TTabSheet;
    pnl3: TPanel;
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
    pgc2: TPageControl;
    ts5: TTabSheet;
    pnl5: TPanel;
    ejuncashtotal: TEjunDBGrid;
    pnl6: TPanel;
    ejunpzall: TEjunDBGrid;
    pnl7: TPanel;
    ejunpzone: TEjunDBGrid;
    spl2: TSplitter;
    qryQRYonepz: TADOQuery;
    qrycash: TADOQuery;
    ts6: TTabSheet;
    ejunbank: TEjunDBGrid;
    qrybank: TADOQuery;
    btn3: TButton;
    spl3: TSplitter;
    tbkey: TADOTable;
    cbb1: TComboBox;
    cbb2: TComboBox;
    cbb3: TComboBox;
    ejuncashsheet: TEjunDBGrid;
    tbCASHSHEET: TADOTable;
    pnl8: TPanel;
    btnupdatesheet: TButton;
    pgc3: TPageControl;
    ts4: TTabSheet;
    ejun1: TEjunDBGrid;
    ts7: TTabSheet;
    qrykmyeb: TADOQuery;
    ejunkmyeb: TEjunDBGrid;
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
    procedure btn3Click(Sender: TObject);
    procedure ejun3DblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ejunpzallCellGetColor(Sender: TObject; ACoord: TPoint;
      var AColor: TColor);
    procedure cbb1Change(Sender: TObject);
    procedure cbb2Change(Sender: TObject);
    procedure cbb3Change(Sender: TObject);
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
  private
    fxmid: string;
    { Private declarations }
  public
    { Public declarations }
  published
    property xmid: string read fxmid write fxmid;
  end;

var
  fmcash: Tfmcash;

implementation

uses
  communit, frmopendw, CLSexcel;

{$R *.dfm}

procedure Tfmcash.openpzsheet;
var
  STRLIST: tstringlist;
  stext: string;
  i: Integer;
begin
  //
  stext :=
    '全凭证号,一级名称,科目编码, 科目名称, 摘要, 借方, 贷方,现金流量,经营其他, 对方科目,判断依据,id,现金否';
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

  ejunpzall.Columns[1].Width := 80;
  ejunpzall.Columns[2].Width := 50;
  ejunpzall.Columns[3].Width := 50;
  ejunpzall.Columns[4].Width := 50;
  ejunpzall.Columns[5].Width := 140;
  ejunpzall.Columns[6].Width := 80;
  ejunpzall.Columns[7].Width := 80;
  ejunpzall.Columns[8].Width := 70;
  ejunpzall.Columns[9].Width := 70;
  ejunpzall.Columns[10].Width := 90;
  ejunpzall.Columns[11].Width := 160;
  ejunpzall.Columns[12].Width := 60;

  ejunpzall.DataColumns.Items[7].Style.FormatString := '#,##0.00';
  ejunpzall.DataColumns.Items[6].Style.FormatString := '#,##0.00';
  // qrypzb.FieldByName('id').ReadOnly := true;

  begin
    qrypzb.Close;
    qrypzb.SQL.Clear;
    qrypzb.sql.Add('select * from 凭证表  where (xmid=''' + fxmid + ''')  and trim(科目编码) like '''
      + '100%' + '''');
    qrypzb.open;
    //  mymessage(INTTOSTR(QRYPZB.RECORDCOUNT));
    qrypzb.First;
  end;

  for I := 0 to qrypzb.Fields.Count - 1 do
  begin
    if (qrypzb.Fields[i].Name <> '现金流量') and (qrypzb.Fields[i].Name <> '经营其他') then
      qrypzb.Fields[i].ReadOnly := true;
  end;

  //=============以下单张凭证

end;

procedure Tfmcash.FormShow(Sender: TObject);
begin

  //  axm := ADGSYSTEM.OPENLAST;
  //  con1.Connected := true;
  fxmid := axm.xmid;

  formatcash;
  openpzsheet;
  openpzone;
  opencashtotal;
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
    //    if ejundbgrid2.CurRow < 1 then
    //    begin
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
  qrytmp.SQL.Add(' and   (xmid=''' + fxmid + ''') ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 a');
  qrytmp.SQL.Add(' set a.现金流量="" ');
  qrytmp.SQL.Add(' where   (xmid=''' + fxmid + ''') ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 ');
  qrytmp.SQL.Add(' set 金额=ABS(借方+贷方) ');
  qrytmp.SQL.Add(' where   (xmid=''' + fxmid + ''') ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 a,(select * from 现金流量表对应 where (trim(摘要关键字)="") or  (摘要关键字 is null))   b');
  qrytmp.SQL.Add(' set a.现金流量=b.现金流量简称 ');
  qrytmp.SQL.Add('where trim(a.对方科目)=trim(b.对方科目)  and  trim(a.借贷)=trim(b.借贷) and a.现金否');
  qrytmp.SQL.Add(' and   (xmid=''' + fxmid + ''') '); // and 现金否  and b.摘要关键字=""
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
  qrytmp.SQL.Add(' and  ( trim(对方科目) like ''' + '%现金%' + '''  or  trim(对方科目) like ''' + '%银行存款%' +
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
  qrytmp.SQL.Add(' and   (xmid=''' + fxmid + ''') ');

  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 a,xyz b');
  qrytmp.SQL.Add(' set a.经营其他="XA" WHERE  a.全凭证号=b.pzh  ');
  qrytmp.SQL.Add('AND  A.金额=b.je  and b.sl>2');
  qrytmp.SQL.Add(' and   (xmid=''' + fxmid + ''') ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 a');
  qrytmp.SQL.Add(' set a.现金流量="OK"   WHERE  a.经营其他="XA"   and a.现金否 ');
  qrytmp.SQL.Add('AND  (a.摘要 like "%转%" or  a.摘要 like "%现%"  or a.摘要 like "%行%") ');
  qrytmp.SQL.Add(' and   (xmid=''' + fxmid + ''') ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.sql.Clear;
  qrytmp.SQL.Add('delete from xyz');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.sql.Add('insert into xyz(pzh,je)');
  qrytmp.sql.Add('select max(全凭证号) as pzh,max(金额) as je ');
  qrytmp.sql.Add(' from 凭证表    where (xmid=''' + fxmid + ''')  and 现金流量="OK"  and 现金否');
  qrytmp.sql.Add(' group by  全凭证号,金额');
  qrytmp.sql.Add(' having (sum(借方)-sum(贷方))<>0');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 a,xyz b');
  qrytmp.SQL.Add(' set a.现金流量="" WHERE  a.全凭证号=b.pzh  ');
  qrytmp.SQL.Add('AND  A.金额=b.je  ');
  qrytmp.ExecSQL;
  //
  //  update  凭证表 a,(SELECT 全凭证号, 贷方,科目名称
  //FROM 凭证表  WHERE (trim(xmid)="0011") ) b set a.判断依据=b.科目名称  where a.全凭证号=b.全凭证号 and a.借方=b.贷方
  // and a.现金否 and  a.借方<>0 and (trim(xmid)="0011")

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update  凭证表 a,');
  qrytmp.SQL.Add('(SELECT 全凭证号, 贷方,一级名称  FROM 凭证表  WHERE (trim(xmid)=''' + fxmid + ''')) b');
  qrytmp.SQL.Add('  set a.判断依据=b.一级名称 ');
  qrytmp.SQL.Add('where a.全凭证号=b.全凭证号');
  qrytmp.SQL.Add(' and a.借方=b.贷方 and a.现金否  ');
  qrytmp.SQL.Add(' and  a.借方<>0 and (trim(xmid)=''' + fxmid + ''')');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update  凭证表 a,');
  qrytmp.SQL.Add('(SELECT 全凭证号, 借方,一级名称  FROM 凭证表  WHERE (trim(xmid)=''' + fxmid + ''')) b');
  qrytmp.SQL.Add('  set a.判断依据=b.一级名称   ');
  qrytmp.SQL.Add('where a.全凭证号=b.全凭证号');
  qrytmp.SQL.Add(' and a.贷方=b.借方 and a.现金否  ');
  qrytmp.SQL.Add(' and  a.贷方<>0 and (trim(xmid)=''' + fxmid + ''')');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 a,现金流量表对应  b');
  qrytmp.SQL.Add(' set a.现金流量=b.现金流量简称 ');
  qrytmp.SQL.Add('where trim(a.判断依据)=trim(b.对方科目)  and  trim(a.借贷)=trim(b.借贷) ');
  qrytmp.SQL.Add(' and   (xmid=''' + fxmid + ''')  and 现金否 and trim(现金流量)="" ');
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
      qrytmp.SQL.Add(' set a.现金流量= ''' + tb1.fieldbyname('现金流量简称').asstring + '''');
      qrytmp.SQL.Add('where trim(a.对方科目) like ''%' + trim(tb1.fieldbyname('对方科目').asstring) + '%''');
      qrytmp.SQL.Add(' and  trim(a.摘要) like ''%' + trim(tb1.fieldbyname('摘要关键字').asstring) + '%''');
      qrytmp.SQL.Add(' and   (xmid=''' + fxmid + ''')  and 现金否 ');
      if not tb1.FieldByName('全局替换').AsBoolean then
        qrytmp.SQL.Add('     and (trim(现金流量)="" or 现金流量 is null)  ');
      if tb1.fieldbyname('借贷').asstring <> '' then
        qrytmp.SQL.Add(' and  trim(a.借贷)= ''' + trim(trim(tb1.fieldbyname('借贷').asstring)) + '''');
      qrytmp.ExecSQL;
    end;
    tb1.Next;
  end;
  tb1.EnableControls;

  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.SQL.Add(' select * from 凭证表  ');
  qrypzb.SQL.Add('where ');
  qrypzb.SQL.Add('  (xmid=''' + fxmid + ''')  and 现金否 ');
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
    '全凭证号,一级名称,科目编码, 科目名称, 摘要, 借方, 贷方,现金流量,经营其他, 对方科目,判断依据,id,现金否';
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

  ejunpzone.Columns[1].Width := 80;
  ejunpzone.Columns[2].Width := 50;
  ejunpzone.Columns[3].Width := 50;
  ejunpzone.Columns[4].Width := 50;
  ejunpzone.Columns[5].Width := 140;
  ejunpzone.Columns[6].Width := 80;
  ejunpzone.Columns[7].Width := 80;
  ejunpzone.Columns[8].Width := 70;
  ejunpzone.Columns[9].Width := 70;
  ejunpzone.Columns[10].Width := 90;

  ejunpzone.DataColumns.Items[7].Style.FormatString := '#,##0.00';
  ejunpzone.DataColumns.Items[6].Style.FormatString := '#,##0.00';

  qryQRYonepz.Close;
  qryQRYonepz.SQL.Clear;
  qryQRYonepz.sql.Add('select * from 凭证表  where (xmid=''' + fxmid + ''')  and trim(全凭证号) ='''
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
  pnl3.Width := 320;

  ejuncashtotal.DataColumns.Items[1].Style.FormatString := '#,##0.00';
  ejuncashtotal.DataColumns.Items[3].Style.FormatString := '#,##0.00';
  ejuncashtotal.DataColumns.Items[2].Style.FormatString := '#,##0.00';

  qrycash.Close;
  qrycash.SQL.Clear;
  qrycash.sql.Add('select max(现金流量) as 现金流量,SUM(借方) as 借方 ,SUM(贷方) as 贷方');
  qrycash.sql.Add(' from 凭证表    where (xmid=''' + trim(fxmid) + ''')  and 现金否');
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
  pnl3.Width := 320;

  ejunbank.DataColumns.Items[1].Style.FormatString := '#,##0.00';
  ejunbank.DataColumns.Items[2].Style.FormatString := '#,##0.00';

  qrybank.Close;
  qrybank.SQL.Clear;
  qrybank.sql.Add('select max(全凭证号) as 凭证号 ,max(金额) as 金额,sum(借方) AS 借方,sum(贷方) as 贷方 ');
  qrybank.sql.Add(' from 凭证表    where (xmid=''' + fxmid + ''')  and trim(现金流量)=''' + STR + ''' and 现金否');
  qrybank.sql.Add(' group by  全凭证号,金额');
  qrybank.open;

end;

procedure Tfmcash.ejuncashtotalDblClick(Sender: TObject);
begin

  if UpperCase(trim(qrycash.fieldbyname('现金流量').asstring)) = 'OK' then
  begin
    pgc2.ActivePageIndex := 1;
    pnl3.Width := 400;
    openbank('OK');

  end
  else if UpperCase(trim(qrycash.fieldbyname('现金流量').asstring)) = 'X' then
  begin
    pgc2.ActivePageIndex := 1;
    pnl3.Width := 400;
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
    qrypzb.sql.Add('select * from 凭证表  where (xmid=''' + fxmid + ''')  and 现金否  and trim(现金流量) = '''
      + trim(qrycash.fieldbyname('现金流量').asstring) + '''');
    qrypzb.open;
    qrypzb.First;
  end;
end;

procedure Tfmcash.ejunbankDblClick(Sender: TObject);
begin
  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('select * from 凭证表  where (xmid=''' + fxmid + ''')  and trim(全凭证号) = '''
    + trim(qrybank.fieldbyname('凭证号').asstring) + '''  ');
  qrypzb.open;
  qrypzb.First;
end;

procedure Tfmcash.formatcash;
begin

  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('update  凭证表  set 现金否=false  where xmid=''' + fxmid + '''');
  qrypzb.ExecSQL;

  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('update  凭证表  set 现金否=true  where xmid=''' + fxmid + '''  and 一级编码="1001"');
  qrypzb.ExecSQL;

  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('update  凭证表  set 现金否=true  where xmid=''' + fxmid + ''' and 一级编码="1002"');
  qrypzb.ExecSQL;

  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('update  凭证表  set 现金否=true  where xmid=''' + fxmid + ''' and 一级编码="1003"');
  qrypzb.ExecSQL;

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
  qrypzb.FieldByName('现金流量').AsString := tb2.fieldbyname('现金流量简称').AsString;
  qrypzb.Post;
  //  qrypzb.DisableControls;
  //  qrypzb.Close;
  //  qrypzb.Open;
  //  qrypzb.EnableControls;
  qrypzb.Refresh;
end;

procedure Tfmcash.btn3Click(Sender: TObject);
begin
  qrypzb.Refresh;
  //  qrycash.DisableControls;
  //  qrycash.Close;
  //  qrycash.Open;
  //  qrycash.EnableControls;

end;

procedure Tfmcash.ejun3DblClick(Sender: TObject);
begin
  //

  if Trim(tbkey.fieldbyname('关键字').asstring) <> '' then
  begin
    qrypzb.Close;
    qrypzb.SQL.Clear;
    qrypzb.sql.Add('select * from 凭证表  where (xmid=''' + fxmid + ''')  and 现金否 ');
    qrypzb.sql.Add('and 摘要 like ''%' + tbkey.fieldbyname('关键字').asstring + '%'' ');
    qrypzb.open;
    //  mymessage(INTTOSTR(QRYPZB.RECORDCOUNT));
    qrypzb.First;
  end;

end;

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
  qrycash.Connection := con1;
  qrytmp.Connection := con1;
  qryQRYonepz.Connection := con1;
  qrypzb.Connection := con1;
  qrybank.Connection := con1;
  tbkey.Connection := con1;
  tb1.Connection := con1;
  tb2.Connection := con1;

end;

procedure Tfmcash.ejunpzallCellGetColor(Sender: TObject; ACoord: TPoint;
  var AColor: TColor);
begin

  if ejunpzall.Cells[14, ACoord.Y].AsBoolean then
    AColor := cl3DLight
  else
    AColor := clWindow;

end;

procedure Tfmcash.cbb1Change(Sender: TObject);
begin
  //

  qrypzb.Edit;
  qrypzb.FieldByName('现金流量').AsString := cbb1.text;
  qrypzb.Post;
  qrypzb.Refresh;

end;

procedure Tfmcash.cbb2Change(Sender: TObject);
begin
  qrypzb.Edit;
  qrypzb.FieldByName('现金流量').AsString := cbb2.text;
  qrypzb.Post;
  qrypzb.Refresh;
end;

procedure Tfmcash.cbb3Change(Sender: TObject);
begin
  qrypzb.Edit;
  qrypzb.FieldByName('现金流量').AsString := cbb3.text;
  qrypzb.Post;
  qrypzb.Refresh;
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

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.sql.Add('update 现金流量表项目 a');
  qrytmp.sql.Add(' set a.金额=0 where (xmid=''' + fxmid + ''') ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.sql.Add('DELETE FROM  XYZ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.sql.Add('INSERT INTO XYZ(PZH,JE)');
  qrytmp.sql.Add('select max(现金流量) as PZH,SUM(借方)-SUM(贷方) as JE');
  qrytmp.sql.Add(' from 凭证表    where (xmid=''' + trim(fxmid) + ''')  and 现金否');
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
    else if Pos('现金流量净额', tbCASHSHEET.fieldbyname('现金流量项目').AsString) > 0 then
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

  stext := '科目名称,	借方发生,	贷方发生,ID,代码';

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

  ejunkmyeb.Columns[0].Width := 0;
  ejunkmyeb.Columns[1].Width := 70;
  ejunkmyeb.Columns[2].Width := 85;
  ejunkmyeb.Columns[3].Width := 85;
  ejunkmyeb.Columns[4].Width := 0;
  ejunkmyeb.Columns[5].Width := 0;

  ejunkmyeb.DataColumns.Items[1].Style.FormatString := '#,##0.00';
  ejunkmyeb.DataColumns.Items[2].Style.FormatString := '#,##0.00';

  qrykmyeb.Close;
  qrykmyeb.SQL.Clear;
  qrykmyeb.sql.Add('select * from dg7 where len(trim(代码))=4 and (核算项目名称 is null)  and (xmid=''' + fxmid +
    ''') order by 代码');
  qrykmyeb.open;
end;

procedure Tfmcash.pgc3Change(Sender: TObject);
begin
  if pgc3.ActivePageIndex = 1 then
    openkmyeb;
end;

procedure Tfmcash.ejunkmyebDblClick(Sender: TObject);
begin
  qryQRYonepz.DisableControls;
  qryQRYonepz.Close;
  qryQRYonepz.SQL.Clear;

  qryQRYonepz.sql.Add('select * from 凭证表  where (xmid=''' + fxmid + ''') ');
  qryQRYonepz.sql.Add(' and  trim(一级编码)=''' + qrykmyeb.fieldbyname('代码').asstring + '''');
  qryQRYonepz.open;

  qryQRYonepz.First;
  qryQRYonepz.EnableControls;
end;

procedure Tfmcash.ejunpzoneDblClick(Sender: TObject);
var
  icol: LongInt;
begin
  //
  if ejunpzone.tag <= 17 then
  begin
    //    if ejundbgrid2.CurRow < 1 then
    //    begin
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
    //    end;
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
  qrypzb.sql.Add('select * from 凭证表  where (xmid=''' + fxmid + ''')  and trim(全凭证号) ='''
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
  qrypzb.sql.Add('select * from 凭证表  where (xmid=''' + fxmid + ''')  and 现金否 ');
  qrypzb.sql.Add(' and 现金流量=''' + qryother.fieldbyname('现金流量').asstring + ''' ');
  if Trim(qryother.fieldbyname('其他流量明细').asstring) <> '' then
  begin
    qrypzb.sql.Add(' and 经营其他=''' + qryother.fieldbyname('其他流量明细').asstring + '''');
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

procedure Tfmcash.btn4Click(Sender: TObject);
var
  STRLIST: tstringlist;
  stext: string;
  i: Integer;
begin
  //
  stext :=
    '全凭证号,一级名称,科目编码, 科目名称, 摘要, 借方, 贷方,现金流量,经营其他, 对方科目,判断依据,id,现金否';
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

  ejunpzall.Columns[1].Width := 80;
  ejunpzall.Columns[2].Width := 50;
  ejunpzall.Columns[3].Width := 50;
  ejunpzall.Columns[4].Width := 50;
  ejunpzall.Columns[5].Width := 140;
  ejunpzall.Columns[6].Width := 80;
  ejunpzall.Columns[7].Width := 80;
  ejunpzall.Columns[8].Width := 70;
  ejunpzall.Columns[9].Width := 70;
  ejunpzall.Columns[10].Width := 90;
  ejunpzall.Columns[11].Width := 160;
  ejunpzall.Columns[12].Width := 60;

  ejunpzall.DataColumns.Items[7].Style.FormatString := '#,##0.00';
  ejunpzall.DataColumns.Items[6].Style.FormatString := '#,##0.00';

  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('select * from 凭证表  where (xmid=''' + fxmid + ''')  and 现金否');
  qrypzb.open;
  qrypzb.First;

  ejunpzall.SaveToExcel(mainpath + '\' + fxmid + '_现金流量表' + formatdatetime('yymmddhhmmss', Now) + '.xls',
    '现金流量表');
  mymessage('导出成功!');
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

end.
