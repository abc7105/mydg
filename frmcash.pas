unit frmcash;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, ZcUniClass, ZJGrid, ZcDataGrid, ZcDBGrids,
  ushare, ShellAPI, EXCEL2000,
  DB, ADODB, ZcGridClasses, StdCtrls, frmkmtocash;
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
    tsbank: TTabSheet;
    pnl4: TPanel;
    con1: TADOConnection;
    qrypzb: TADOQuery;
    ejnlcns1: TEjunLicense;
    tscashtable: TTabSheet;
    qrytmp: TADOQuery;
    pnl6: TPanel;
    ejunpzall: TEjunDBGrid;
    pnl7: TPanel;
    ejunpzone: TEjunDBGrid;
    spl2: TSplitter;
    qryQRYonepz: TADOQuery;
    qrycash: TADOQuery;
    qrybank: TADOQuery;
    tbCASHSHEET: TADOTable;
    qrykmyeb: TADOQuery;
    btn4: TButton;
    btn5: TButton;
    tskmyeb: TTabSheet;
    ejunkmyeb: TEjunDBGrid;
    tbcalccash: TADOTable;
    Button1: TButton;
    dlgSave1: TSaveDialog;
    ejuncashsheet: TEjunDBGrid;
    procedure openpzsheet();
    procedure opencashtotal();
    procedure FormShow(Sender: TObject);
    procedure ejunpzallMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ejunpzallDblClick(Sender: TObject);
    procedure openpzone();
    procedure qrypzbAfterScroll(DataSet: TDataSet);
    procedure ejunbankDblClick(Sender: TObject);
    procedure formatcash();
    procedure ejun1DblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ejunpzallCellGetColor(Sender: TObject; ACoord: TPoint;
      var AColor: TColor);
    procedure OPENCASHSHEET();
    procedure btnupdatesheetClick(Sender: TObject);
    procedure pgc1Change(Sender: TObject);
    procedure openkmyeb();
    procedure ejunkmyebDblClick(Sender: TObject);
    procedure ejunpzoneMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
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
    function tableexists(con: TADOConnection; tablename: string): boolean;
  private
    fxmid: string;
    Fexcelapp: VARIANT;
    procedure cashfx_export_toexcel;
    procedure cashfx_other_ok;
    procedure cashFX_pzb_reset;
    procedure cashfx_tableLOOP;
    procedure cashpzb_display_to_ejungird;
    procedure cash_complete_ok_;
    procedure create_cashview_table;
    procedure mark_XJPZ;
    procedure updatePZB_from_cashview;

    { Private declarations }
  public
  published

    property excelapp: VARIANT read Fexcelapp write Fexcelapp;
    { Public declarations }
 // published
//    property xmid: string read fxmid write fxmid;
  end;

procedure cashfx_other_ok;

var
  fmcash: Tfmcash;
  pz: array[1..ALLREC] of pzrec;

implementation

uses
  communit, frmopendw, CLSexcel, Udebug;

{$R *.dfm}

procedure cashfx_other_ok;
begin
  // TODO -cMM: cashfx_other_ok default body inserted
end;

procedure Tfmcash.FormCreate(Sender: TObject);
var
  abook: dgworkbook;
begin
  pgc1.ActivePageIndex := 0;
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

  mark_XJPZ;

  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('select * from 凭证表  where xjpz=true');
  qrypzb.open;
  qrypzb.First;

  showint(qrypzb.RecordCount);

  for I := 0 to qrypzb.Fields.Count - 1 do
  begin
    if (qrypzb.Fields[i].Name <> '现金流量') and (qrypzb.Fields[i].Name <>
      '经营其他') then
      qrypzb.Fields[i].ReadOnly := true;
  end;

  ejunpzall.DataSet := qrypzb;

  ejunpzall.Activate(true);

end;

procedure Tfmcash.FormShow(Sender: TObject);
begin

  fxmid := axm.xmid;

  formatcash;
  openpzsheet;
  openpzone;
  opencashtotal;
  openkmyeb;

  pgc1.ActivePageIndex := 0;
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
  qryQRYonepz.sql.Add('select * from 凭证表  where (xmid=''' +
    trim(qrypzb.fieldbyname('xmid').asstring) +
    ''')  and trim(全凭证号) ='''
    + trim(qrypzb.fieldbyname('全凭证号').asstring) + '''');
  qryQRYonepz.open;
  qryQRYonepz.First;
  ejunpzone.Activate(true);
end;

procedure Tfmcash.qrypzbAfterScroll(DataSet: TDataSet);
begin
  openpzone;
end;

procedure Tfmcash.opencashtotal;
var
  STRLIST: tstringlist;
  stext: string;
  i: Integer;
begin

  //  stext :=
  //    '现金流量, 借方 ,贷方';
  //  STRLIST := tstringlist.create();
  //  STRLIST.Delimiter := ',';
  //  STRLIST.DelimitedText := stext;
  //
  //  for i := 1 to strlist.Count do
  //  begin
  //    if I >= ejuncashtotal.DataColumns.Count - 1 then
  //      ejuncashtotal.DataColumns.Add;
  //    ejuncashtotal.DATAColumns.Items[i - 1].FieldName := strlist[i - 1];
  //    ejuncashtotal.DATAColumns.Items[I - 1].Title := STRLIST[I - 1];
  //  end;
  //
  //  ejuncashtotal.Columns[1].Width := 90;
  //  ejuncashtotal.Columns[2].Width := 80;
  //  ejuncashtotal.Columns[3].Width := 80;
  //  ejuncashtotal.Columns[4].Width := 0;
  //
  //  ejuncashtotal.DataColumns.Items[1].Style.FormatString := '#,##0.00';
  //  ejuncashtotal.DataColumns.Items[3].Style.FormatString := '#,##0.00';
  //  ejuncashtotal.DataColumns.Items[2].Style.FormatString := '#,##0.00';
  //
  //  qrycash.Close;
  //  qrycash.SQL.Clear;
  //  qrycash.sql.Add('select max(现金流量) as 现金流量,SUM(借方) as 借方 ,SUM(贷方) as 贷方');
  //  qrycash.sql.Add(' from 凭证表    where (xmid=''' + trim(fxmid) +
  //    ''')  and 现金否');
  //  qrycash.sql.Add(' group by 现金流量 ');
  //  qrycash.open;
  //  qrycash.first;

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

procedure Tfmcash.ejun1DblClick(Sender: TObject);
begin
  //
  qrypzb.Edit;
  //qrypzb.FieldByName('现金流量').AsString :=
//    tb2.fieldbyname('现金流量简称').AsString;
  qrypzb.Post;
  qrypzb.Refresh;
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
  if pgc1.ActivePageIndex = 1 then
    OPENCASHSHEET;
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

procedure Tfmcash.ejunpzoneMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ejunpzone.tag := y;
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

  //  qrypzb.FieldByName('现金流量').AsString := listbox1.Items[listbox1.ItemIndex];
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
        pz[j].fitnum := 'ok' + inttostr(sxh);
        pz[sxh].fitnum := 'ok' + inttostr(sxh);
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
              pz[k].fitnum := 'ok' + inttostr(sxh);
          end;
          pz[sxh].fitnum := 'ok' + inttostr(sxh);
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
              pz[k].fitnum := 'ok' + inttostr(sxh);
          end;
          pz[sxh].fitnum := 'ok' + inttostr(sxh);
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
              pz[k].fitnum := 'ok' + inttostr(sxh);
          end;
          pz[sxh].fitnum := 'ok' + inttostr(sxh);
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
        pz[j].fitnum := 'ok' + inttostr(sxh);
        pz[sxh].fitnum := 'ok' + inttostr(sxh);
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
              pz[k].fitnum := 'ok' + inttostr(sxh);
          end;
          pz[sxh].fitnum := 'ok' + inttostr(sxh);
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
              pz[k].fitnum := 'ok' + inttostr(sxh);
          end;
          pz[sxh].fitnum := 'ok' + inttostr(sxh);
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
              pz[k].fitnum := 'ok' + inttostr(sxh);
          end;
          pz[sxh].fitnum := 'ok' + inttostr(sxh);
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

        pz[cc].fitnum := 'OK借方';
        for dd := 1 to 500 do
        begin
          if pz[dd].km = 'over' then
            break;

          if (pz[dd].iscash) and (pz[dd].FITNUM = '') and (pz[dd].jf <> 0) then
            pz[dd].fitnum := 'OK借方';
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
        pz[cc].fitnum := 'OK其他合计借方';
        for dd := 1 to 500 do
        begin
          if pz[dd].km = 'over' then
            break;

          if (not pz[dd].iscash) and (pz[dd].FITNUM = '') and (pz[dd].jf <> 0)
            then
            pz[dd].fitnum := 'OK其他合计借方';
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
          pz[dd].FITNUM := 'OK挤平数据'
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
  aform: tfmkmtocash;
begin

  mark_XJPZ;

  cashpzb_display_to_ejungird;

  cash_complete_ok_;

  cashfx_tableLOOP;

  cashfx_other_ok;

  aform := tfmkmtocash.FormCreate(self, null, con1);
  aform.ShowModal;
  exit;

  cashfx_export_toexcel;

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
  //  qrytmp.Connection := con1;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 a, 现金流量表对应  b');
  qrytmp.SQL.Add(' set a.现金流量=b.现金流量简称,a.经营其他=trim(b.其他 )');
  qrytmp.SQL.Add(' where trim(a.一级名称)=trim(b.对方科目) and  trim(a.科目名称)=trim(b.摘要关键字) ');
  qrytmp.SQL.Add('  and (trim(a.fitnum)<>"" )  and (TRIM(b.摘要关键字)<>"") ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  //  qrytmp.Connection := con1;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 a');
  qrytmp.SQL.Add(' set a.现金流量=''XX''');
  qrytmp.SQL.Add(' WHERE 现金否');
  qrytmp.ExecSQL;

  qrytmp.Close;
  //  qrytmp.Connection := con1;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 a');
  qrytmp.SQL.Add(' set a.现金流量=''N/A''');
  qrytmp.SQL.Add(' WHERE fitnum=''N/A''');
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
  qrypzb.sql.Add('select * from 凭证表  where  (fitnum<>"" ) and xjpz=true ');
  qrypzb.sql.Add('order by 全凭证号');

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

    ejunpzall.SaveToExcel(FILENAMEXLS, '现金流', true, false);
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

procedure Tfmcash.cashfx_export_toexcel;
var
  FILENAMEXLS: string;
begin
  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('select * from 凭证表  where    ');
  qrypzb.sql.Add('where xjpz=true  order by 全凭证号');

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

    ejunpzall.SaveToExcel(FILENAMEXLS, '现金流', true, false);

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

procedure Tfmcash.cashFX_pzb_reset;
begin
  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update 凭证表 set  fitnum='''',判断依据=''''');
  qrytmp.ExecSQL;
end;

procedure Tfmcash.cashfx_tableLOOP;
var
  newpzh: string;
  oldpzh: string;
  i: integer;
begin
  tbcalccash.Connection := con1;
  tbcalccash.TableName := '凭证表';

  tbcalccash.Open;
  tbcalccash.Filtered := false;
  tbcalccash.Filter := '判断依据=''''';
  tbcalccash.Filtered := true;

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
end;

procedure Tfmcash.cashpzb_display_to_ejungird;
var
  i: integer;
  STRLIST: tstringlist;
  stext: string;
begin
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
end;

procedure Tfmcash.cash_complete_ok_;
begin
  cashFX_pzb_reset;

  //贷方
  create_cashview_table;
  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('insert into  xjview  select  max(全凭证号) as 凭证号,max(现金否) as 现金,1 as 数量 from 凭证表 where 贷方<>0  group by 全凭证号,现金否 ');
  qrytmp.ExecSQL;
  updatePZB_from_cashview;

  //借方
  create_cashview_table;
  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('insert into  xjview  select  max(全凭证号) as 凭证号,max(现金否) as 现金,1 as 数量 from 凭证表 where 借方<>0  group by 全凭证号,现金否 ');
  qrytmp.ExecSQL;
  updatePZB_from_cashview;

  //===全部处理
  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update 凭证表 A set A.fitnum=''ALLNO'' WHERE NOT  xjpz=true');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update  凭证表  set  判断依据=''1'' where trim(fitnum)<>'''' ');
  qrytmp.ExecSQL;
end;

procedure Tfmcash.create_cashview_table;
begin
  if not tableexists(con1, 'xjview') then
  begin
    qrytmp.close;
    qrytmp.sql.clear;
    qrytmp.sql.add('create table xjview(凭证号 char(40), 现金 bit, 数量 double,科目 char(7))');
    qrytmp.ExecSQL;
  end
  else
  begin
    qrytmp.close;
    qrytmp.sql.clear;
    qrytmp.sql.add('delete from  xjview ');
    qrytmp.ExecSQL;
  end;

  if not tableexists(con1, 'xjcount') then
  begin
    qrytmp.close;
    qrytmp.sql.clear;
    qrytmp.sql.add('create table xjcount(凭证号 char(40),一级代码 char(7))');
    qrytmp.ExecSQL;
  end
  else
  begin
    qrytmp.close;
    qrytmp.sql.clear;
    qrytmp.sql.add('delete from  xjcount ');
    qrytmp.ExecSQL;
  end;

end;

function Tfmcash.tableexists(con: tadoconnection;
  tablename: string): boolean;
var
  tablelist: TStringList;
  i: integer;
begin
  //
  result := false;
  tablelist := TStringList.Create;
  con1.GetTableNames(tablelist, false);
  //  tablelist := con1.
  for i := 0 to tablelist.Count - 1 do
  begin
    if Trim(tablelist[i]) = Trim(tablename) then
    begin
      result := True;
      exit;
    end;
  end;
end;

procedure Tfmcash.updatePZB_from_cashview;
begin
  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('insert into  xjcount  select 凭证号 from xjview  where (凭证号 not  in (select 凭证号 from xjview where 现金<>true))');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update 凭证表 A set A.fitnum=''OKall'' WHERE  A.全凭证号 IN (SELECT 凭证号 FROM xjcount) ');
  qrytmp.ExecSQL;
end;

procedure Tfmcash.cashfx_other_ok;
begin
  // TODO -cMM: Tfmcash.cashfx_other_ok default body inserted
  //计算不属于现金的在同一凭证借贷相等的科目，然后放入XJCOUNT,这类科目无现金流量
  create_cashview_table;

  try
    qrytmp.close;
    qrytmp.sql.clear;
    qrytmp.sql.add('drop view cashother ');
    qrytmp.ExecSQL;

  except
  end;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('create view cashother as select  max(全凭证号) as 凭证号,max(一级编码) as 一级代码,');
  qrytmp.sql.add(' sum(借方) as 借,sum(借方) as 贷 from 凭证表  ');
  qrytmp.sql.add(' where not 现金否 and trim(fitnum)=''''   group by 全凭证号,一级编码 ');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('insert into  xjcount  select  凭证号 ,一级代码  from cashother where 贷=借  ');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update 凭证表 A ,XJCOUNT b set A.fitnum=''N/A'' ');
  qrytmp.sql.add(' WHERE  A.全凭证号=B.凭证号 and a.一级编码=b.一级代码  and trim(fitnum)=''''  ');
  qrytmp.ExecSQL;

end;

procedure Tfmcash.mark_XJPZ;
begin
  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('UPDATE 凭证表 set xjpz=false ');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('UPDATE 凭证表 set xjpz=true where  (全凭证号 IN (SELECT 全凭证号 FROM 凭证表 where  现金否 ))');
  qrytmp.ExecSQL;
end;

end.

