unit frmcash;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, ZcUniClass, ZJGrid, ZcDataGrid, ZcDBGrids,
  ushare, ShellAPI, EXCEL2000, DB, ADODB, ZcGridClasses, StdCtrls, frmkmtocash;

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
    qrykmyeb: TADOQuery;
    btn4: TButton;
    btn5: TButton;
    tskmyeb: TTabSheet;
    ejunkmyeb: TEjunDBGrid;
    tbcalccash: TADOTable;
    Button1: TButton;
    dlgSave1: TSaveDialog;
    ejuncashsheet: TEjunDBGrid;
    qryCASHSHEET: TADOTable;
    Button2: TButton;
    Button3: TButton;
    Panel1: TPanel;
    Button4: TButton;
    Button5: TButton;
    procedure FormShow(Sender: TObject);
    procedure ejunpzallMouseDown(Sender: TObject; Button: TMouseButton; Shift:
      TShiftState; X, Y: Integer);
    procedure ejunpzallDblClick(Sender: TObject);
    procedure openpzone();
    procedure qrypzbAfterScroll(DataSet: TDataSet);
    procedure formatcash();
    procedure FormCreate(Sender: TObject);
    procedure ejunpzallCellGetColor(Sender: TObject; ACoord: TPoint; var AColor:
      TColor);
    procedure OPENCASHSHEET();
    procedure btnupdatesheetClick(Sender: TObject);
    procedure pgc1Change(Sender: TObject);
    procedure openkmyeb();
    procedure ejunkmyebDblClick(Sender: TObject);
    procedure ejunpzoneMouseDown(Sender: TObject; Button: TMouseButton; Shift:
      TShiftState; X, Y: Integer);
    procedure btn4Click(Sender: TObject);
    procedure btn5Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure calcfit();
    procedure lookforother();
    procedure lookfordf(je: double; const sxh: integer);
    procedure lookforjf(je: double; const sxh: integer);
    procedure cleararr;
    procedure UPDATRARR;
    procedure dofx();
    procedure ejuncashsheetCellGetColor(Sender: TObject; ACoord: TPoint; var
      AColor: TColor);
    procedure ejuncashsheetDblClick(Sender: TObject);
    procedure ejunpzoneCellGetColor(Sender: TObject; ACoord: TPoint; var AColor:
      TColor);
    function tableexists(con: TADOConnection; tablename: string): boolean;
  private
    fxmid: string;
    Fexcelapp: VARIANT;
    procedure cashfx_other_ok;
    procedure cashFX_pzb_reset;
    procedure cashfx_tableLOOP;
    procedure cashpzb_add_blankline;
    procedure cash_complete_ok_;
    procedure eachcashxm_mx_pzb;
    procedure ejunpzb_refresh(PZBsqlstr: string);
    procedure ejunpzb_toexcel;
    procedure mark_XJPZ;
    procedure opencashcalcsheet;
    procedure open_ejuncashsheet;
    procedure xjjesum;
    procedure xjsum();
    function firstlevel_length: integer;
    procedure OnlySee_Pzb_flatdata;
    procedure pzb_calc_onlycash_at_aSide;
    procedure see_allpz;

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
  qrykmyeb.connection := con1;
  qrycashsheet.Connection := con1;

end;

procedure Tfmcash.FormShow(Sender: TObject);
var
  STEXT: string;
begin

  fxmid := axm.xmid;
  formatcash;

  STEXT := 'select * from 凭证表  where  (fitnum<>"不适用" ) and xjpz=true  ' +
    'order by 全凭证号,fitnum';
  ejunpzb_refresh(stext);

  open_ejuncashsheet;
  openpzone;
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
//
//  if ejunPZALL.tag <= 17 then
//  begin
//    icol := ejunPZALL.CurCol;
//    if ejunPZALL.Columns[icol].Tag = 'Z' then
//    begin
//      ejunPZALL.SortRow(icol, true);
//      ejunPZALL.Columns[icol].Tag := 'A'
//    end
//    else
//    begin
//      ejunPZALL.SortRow(icol, false);
//      ejunPZALL.Columns[icol].Tag := 'Z'
//    end;
//    Exit;
//  end;
//
  openpzone;

end;

procedure Tfmcash.openpzone;
var
  STRLIST: tstringlist;
  stext: string;
  i: Integer;
begin

  qryQRYonepz.Close;
  qryQRYonepz.SQL.Clear;
  qryQRYonepz.sql.Add('select * from 凭证表  where (xmid=''' +
    trim(qrypzb.fieldbyname('xmid').asstring) + ''')  and trim(全凭证号) =''' +
    trim(qrypzb.fieldbyname('全凭证号').asstring) + '''');
  qryQRYonepz.open;
  qryQRYonepz.First;

  if qryQRYonepz.RecordCount > 6 then
    pnl7.Height := 350
  else
    pnl7.Height := 180;

  stext :=
    '全凭证号,科目编码,一级名称, 科目名称,现金流量,经营其他,  借方, 贷方,fitnum ,摘要, id,现金否';
  STRLIST := tstringlist.create();
  STRLIST.Delimiter := ',';
  STRLIST.DelimitedText := stext;
  ejunpzone.ClearAll;
  for i := 1 to strlist.Count do
  begin
    if I >= ejunpzone.DataColumns.Count then
      ejunpzone.DataColumns.Add;
    ejunpzone.DATAColumns.Items[i - 1].FieldName := strlist[i - 1];
    ejunpzone.DATAColumns.Items[I - 1].Title := STRLIST[I - 1];
    if (ejunpzall.DATAColumns.Items[i - 1].FieldName = '现金流量') or
      (ejunpzall.DATAColumns.Items[i - 1].FieldName = '经营其他') then
      qrypzb.FieldByName(Trim(strlist[i - 1])).ReadOnly := False
    else
      qrypzb.FieldByName(Trim(strlist[i - 1])).ReadOnly := true;
  end;

  ejunpzone.Columns[1].Width := 100;
  ejunpzone.Columns[2].Width := 90;
  ejunpzone.Columns[3].Width := 90;
  ejunpzone.Columns[4].Width := 90;
  ejunpzone.Columns[5].Width := 160;
  ejunpzone.Columns[6].Width := 100;
  ejunpzone.Columns[7].Width := 90;
  ejunpzone.Columns[8].Width := 90;
  ejunpzone.Columns[9].Width := 50;
  ejunpzone.Columns[10].Width := 180;
  ejunpzone.Columns[11].Visible := False;
  ejunpzone.Columns[12].Visible := False;
  ejunpzone.Columns[13].Visible := False;

  ejunpzone.DataColumns.Items[6].Style.FormatString := '#,##0.00';
  ejunpzone.DataColumns.Items[7].Style.FormatString := '#,##0.00';

  ejunpzone.Activate(true);
end;

procedure Tfmcash.qrypzbAfterScroll(DataSet: TDataSet);
begin
  openpzone;
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

end;

procedure Tfmcash.ejunpzallCellGetColor(Sender: TObject; ACoord: TPoint; var
  AColor: TColor);
begin

  if ejunpzall.Cells[12, ACoord.Y].AsBoolean then
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

  qrytmp.Close;
  qrytmp.Connection := con1;

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
  qrytmp.sql.Add(' INSERT INTO XYZ(PZH,JE)');
  qrytmp.sql.Add(' select max(现金流量) as PZH,SUM(借方)-SUM(贷方) as JE');
  qrytmp.sql.Add(' from 凭证表    where xjpz=true and trim(fitnum)<>"不适用"');
  qrytmp.sql.Add(' group by 现金流量');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.sql.Add(' update 现金流量表项目 a,XYZ B');
  qrytmp.sql.Add(' set a.金额=-b.JE');
  qrytmp.sql.Add(' where  TRIM(a.现金流量简称)=TRIM(b.PZH)  and INSTR("ACE",A.标识)>0');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.sql.Add('update 现金流量表项目 a,XYZ B');
  qrytmp.sql.Add(' set a.金额=b.JE');
  qrytmp.sql.Add(' where  TRIM(a.现金流量简称)=TRIM(b.PZH) and INSTR("BDF",A.标识)>0');
  qrytmp.ExecSQL;

  xjsum;

  qrycashsheet.DisableControls;

  open_ejuncashsheet;

  qrycashsheet.First;
  asum := 0;
  bsum := 0;
  i := 0;

  while not qrycashsheet.Eof do
  begin
    if Pos('小计', qrycashsheet.fieldbyname('现金流量项目').AsString) > 0 then
    begin
      qrycashsheet.edit;
      qrycashsheet.fieldbyname('金额').asfloat := asum;
      qrycashsheet.post;

      if i = 0 then
      begin
        bsum := asum;
        asum := 0;
        i := i + 1;
      end;
    end
    else if Pos('现金流量净额',
      qrycashsheet.fieldbyname('现金流量项目').AsString) > 0 then
    begin
      qrycashsheet.edit;
      qrycashsheet.fieldbyname('金额').asfloat := bsum - asum;
      qrycashsheet.post;
      //   bsum :=
      asum := 0;
      bsum := 0;
      i := 0;
    end
    else
      asum := asum + qrycashsheet.fieldbyname('金额').asfloat;

    qrycashsheet.Next;
  end;

  xjjesum;
  try
    qrycashsheet.Close;
  except
  end;
  qrycashsheet.Open;

  qrycashsheet.First;
  qrycashsheet.EnableControls;
end;

procedure Tfmcash.btnupdatesheetClick(Sender: TObject);
begin
  OPENCASHSHEET;
end;

procedure Tfmcash.pgc1Change(Sender: TObject);
begin
  //  if pgc1.ActivePageIndex = 0 then
  //    OPENCASHSHEET
  //  else if pgc1.ActivePageIndex = 1 then
  //    OPENCASHSHEET;
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
  qrykmyeb.sql.Add('select * from dg7   where len(TRIM(代码))=:lena order by 代码,一级科目代码');
  qrykmyeb.Parameters.ParamByName('lena').Value := firstlevel_length;
  qrykmyeb.open;
  ejunkmyeb.DataSet := qrykmyeb;
  ejunkmyeb.Active := true;
end;

procedure Tfmcash.ejunkmyebDblClick(Sender: TObject);
var
  STEXT: string;
begin

  STEXT := 'select * from 凭证表  where  ' +        // 现金流量<>''ok'' 
    '   trim(科目编码) like "' +        //xjpz=true and
    Trim(qrykmyeb.fieldbyname('代码').asstring) + '%"';
//  ShowMessage(stext);
   ejunpzb_refresh(stext);
  pgc1.ActivePageIndex := 0;
  ejunpzall.Activate(true);

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

      if (round((pz[j].df - je) * 100) = 0) and (pz[j].fitnum = '') then
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

      if (round(pz[j].jf * 100) = round(je * 100)) and (pz[j].fitnum = '') then
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
        break;
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
        break;
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
        break;
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
        break;
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
  stext: string;
  aform: tfmkmtocash;
  lena: integer;
begin
  mark_XJPZ;
  //  qrytmp.Close;
  //  qrytmp.SQL.Clear;
  //  qrytmp.SQL.Add(' delete from  凭证表  where trim(全凭证号)<>"2016_ 1_记121"');
  //  qrytmp.ExecSQL;

  //  qrytmp.Close;
  //  qrytmp.SQL.Clear;
  //  qrytmp.SQL.Add(' delete from  凭证表 ');
  //  qrytmp.ExecSQL;
  //
  //  qrytmp.Close;
  //  qrytmp.SQL.Clear;
  //  qrytmp.SQL.Add(' insert into 凭证表 select *  from  凭证表1');
  //  qrytmp.ExecSQL;

  see_allpz;
  cash_complete_ok_;
  cashfx_tableLOOP;
  cashfx_other_ok;
  pzb_calc_onlycash_at_aSide;
  cashpzb_add_blankline;

  lena := firstlevel_length;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update dg7 set 一级科目代码=left(代码,:lena) ');
  qrytmp.Parameters.ParamByName('lena').Value := lena;
  qrytmp.ExecSQL;

  try
    qrytmp.SQL.Clear;
    qrytmp.SQL.Add(' DROP view  dg7A  ');
    qrytmp.ExecSQL;
  except
  end;

  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' create view  dg7A  AS select 代码,科目名称 from dg7  ' +
    ' where len(trim(代码))=' + inttostr(lena));
  qrytmp.ExecSQL;

  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update dg7 A , dg7A B  set a.一级科目名称=B.科目名称 where a.一级科目代码=B.代码 ');
  qrytmp.ExecSQL;

  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 A,现金流量表对应 B  set A.现金流量=B.现金流量简称 ');
  qrytmp.SQL.Add(' where  A.一级名称=B.对方科目');
  qrytmp.ExecSQL;

  STEXT := 'select * from 凭证表  where  xjpz=true  ' +
    'order by 全凭证号,fitnum';
  ejunpzb_refresh(stext);
  ShowMessage('记账凭证初始化完毕，可以进行后续现金流量分析！');

end;

procedure Tfmcash.dofx;
begin
  //
  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 a,现金流量表对应    b');
  qrytmp.SQL.Add(' set a.现金流量=b.现金流量简称 ,a.经营其他=trim(b.其他) ');
  qrytmp.SQL.Add('where trim(a.一级名称)=trim(b.对方科目)  and (TRIM(b.二级科目)="" OR (b.二级科目 IS NULL) )');
  qrytmp.SQL.Add('  and (a.fitnum<>"") ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 a, 现金流量表对应  b');
  qrytmp.SQL.Add(' set a.现金流量=b.现金流量简称,a.经营其他=trim(b.其他 )');
  qrytmp.SQL.Add(' where trim(a.一级名称)=trim(b.对方科目) and  trim(a.科目名称)=trim(b.二级科目) ');
  qrytmp.SQL.Add('  and (trim(a.fitnum)<>"" )  and (TRIM(b.二级科目)<>"") ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 a');
  qrytmp.SQL.Add(' set a.现金流量=''XX''');
  qrytmp.SQL.Add(' WHERE 现金否');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update 凭证表 a');
  qrytmp.SQL.Add(' set a.现金流量=''不适用''');
  qrytmp.SQL.Add(' WHERE fitnum=''不适用''');
  qrytmp.ExecSQL;

end;

procedure Tfmcash.btn4Click(Sender: TObject);
begin

  ejunpzb_toexcel;

end;

procedure Tfmcash.Button2Click(Sender: TObject);
begin
  OPENCASHSHEET;
  PGC1.ActivePageIndex := 1;
end;

procedure Tfmcash.Button3Click(Sender: TObject);
var
  stext: string;
  aform: tfmkmtocash;
begin
  cashpzb_add_blankline;

  aform := tfmkmtocash.FormCreate(self, null, con1);
  aform.ShowModal;

  STEXT := 'select * from 凭证表  where  xjpz=true  ' +
    'order by 全凭证号,fitnum';
  ejunpzb_refresh(stext);
end;

procedure Tfmcash.Button4Click(Sender: TObject);
begin
  //
  OnlySee_Pzb_flatdata;
end;

procedure Tfmcash.Button5Click(Sender: TObject);
var
  stext: string;
begin
  // TODO -cMM: Tfmcash.OnlySee_Pzb_flatdata default body inserted
  (*TODO: extracted code
  STEXT := 'select * from 凭证表  where  (fitnum<>"不适用" ) and xjpz=true  ' +
    'order by 全凭证号,fitnum';
  ejunpzb_refresh(stext);
  *)
  see_allpz;

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

procedure Tfmcash.cash_complete_ok_;
begin
  cashFX_pzb_reset;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('delete from   xjcount   ');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('insert into  xjcount  select distinct 全凭证号 as 凭证号 ,一级编码 as 一级代码 from 凭证表 ');
  qrytmp.sql.add(' where 现金否=true and 借方<>0 and xjpz');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('delete from   xjcount  where  凭证号 in ');
  qrytmp.sql.add('(select 全凭证号 from 凭证表  where 现金否<>true and 借方<>0 and xjpz)');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update 凭证表 A set A.fitnum=''OKall'' WHERE  A.全凭证号 IN (SELECT 凭证号 FROM xjcount) ');
  qrytmp.ExecSQL;

  //==============     贷方发生只有现金科目
  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('delete from   xjcount   ');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('insert into  xjcount  select distinct 全凭证号 as 凭证号 ,一级编码 as 一级代码 from 凭证表');
  qrytmp.sql.add(' where 现金否=true and 贷方<>0 and xjpz');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('delete from   xjcount  where  凭证号 in ');
  qrytmp.sql.add('(select 全凭证号 from 凭证表  where 现金否<>true and 贷方<>0 and xjpz)');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update 凭证表 A set A.fitnum=''OKall'' WHERE  A.全凭证号 IN (SELECT 凭证号 FROM xjcount) ');
  qrytmp.ExecSQL;

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

function Tfmcash.tableexists(con: tadoconnection; tablename: string): boolean;
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

procedure Tfmcash.cashfx_other_ok;
begin
  // TODO -cMM: Tfmcash.cashfx_other_ok default body inserted
  //计算不属于现金的在同一凭证借贷相等的科目，然后放入XJCOUNT,这类科目无现金流量
//  create_cashview_table;

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
  qrytmp.sql.add(' sum(借方) as 借,sum(贷方) as 贷 from 凭证表  ');
  qrytmp.sql.add(' where not 现金否 and (trim(fitnum)='''' or trim(fitnum)="OK挤平数据"  and xjpz) group by 全凭证号,一级编码 ');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('delete from xjcount  ');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('insert into  xjcount  select  凭证号 ,一级代码  from cashother where 贷=借  ');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update 凭证表 A ,XJCOUNT b set A.fitnum=''不适用'' ');
  qrytmp.sql.add(' WHERE  A.全凭证号=B.凭证号 and a.一级编码=b.一级代码 and (trim(fitnum)='''' or trim(fitnum)="OK挤平数据" ) ');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update 凭证表  set fitnum=''不适用'' ');
  qrytmp.sql.add(' WHERE trim(fitnum)=""  and xjpz=true');
  qrytmp.ExecSQL;

end;

procedure Tfmcash.cashpzb_add_blankline;
begin
  // TODO -cMM: Tfmcash.cashpzb_add_blankline default body inserted

  try
    qrytmp.CLOSE;
    qrytmp.SQL.Clear;
    qrytmp.SQL.Add('DELETE  from 凭证表 WHERE len(TRIM(科目编码))=0  ');
    qrytmp.execsql;

    qrytmp.CLOSE;
    qrytmp.SQL.Clear;
    qrytmp.SQL.Add('DELETE  from 凭证表 WHERE (借方 is null) and (贷方 is null) ');
    qrytmp.execsql;

  except
  end;

  qrytmp.Close;
  qrytmp.sql.Clear;
  qrytmp.SQL.Add('delete from  凭证表 where (科目名称 is null) or (trim(科目名称)="") ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.sql.Clear;
  qrytmp.SQL.Add('insert into 凭证表(全凭证号) ');
  qrytmp.SQL.Add(' select  max(全凭证号) from 凭证表 ');
  qrytmp.SQL.Add(' where xjpz=true group by 全凭证号');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.sql.Clear;
  qrytmp.SQL.Add('update 凭证表 set xjpz=true,fitnum="" ');
  qrytmp.SQL.Add(' where (科目名称 is null) or (trim(科目名称)="") ');
  qrytmp.ExecSQL;

end;

procedure Tfmcash.eachcashxm_mx_pzb;
var
  stext: string;
begin
  try
    STEXT := 'select * from 凭证表  where   xjpz=true AND trim(现金流量)=''' +
      qrycashsheet.fieldbyname('现金流量简称').asstring + '''' +
      'order by 一级名称,科目名称,fitnum';
    ejunpzb_refresh(stext);
  except
  end;
end;

procedure Tfmcash.ejuncashsheetCellGetColor(Sender: TObject; ACoord: TPoint;
  var AColor: TColor);
begin
  if Trim(ejuncashsheet.Cells[3, ACoord.Y].ASSTRING) = '' then
    AColor := cl3DLight
  else
    AColor := clWindow;

end;

procedure Tfmcash.ejuncashsheetDblClick(Sender: TObject);
begin
  //
  eachcashxm_mx_pzb;
  pgc1.ActivePageIndex := 0;
end;

procedure Tfmcash.ejunpzb_refresh(PZBsqlstr: string);
var
  STRLIST: tstringlist;
  stext: string;
  i: Integer;
begin

  stext :=
    '全凭证号,科目编码,一级名称, 科目名称,现金流量,经营其他,  借方, 贷方,fitnum ,摘要, id,现金否';
  STRLIST := tstringlist.create();
  STRLIST.Delimiter := ',';
  STRLIST.DelimitedText := stext;

  //  ejunpzall.ClearAll;
  for i := 1 to strlist.Count do
  begin
    if I > ejunpzall.DataColumns.Count then
      ejunpzall.DataColumns.Add;
    ejunpzall.DATAColumns.Items[i - 1].FieldName := strlist[i - 1];
    ejunpzall.DATAColumns.Items[I - 1].Title := STRLIST[I - 1];
  end;

  ejunpzall.Columns[1].Width := 100;
  ejunpzall.Columns[2].Width := 90;
  ejunpzall.Columns[3].Width := 90;
  ejunpzall.Columns[4].Width := 90;
  ejunpzall.Columns[5].Width := 160;
  ejunpzall.Columns[6].Width := 100;
  ejunpzall.Columns[7].Width := 90;
  ejunpzall.Columns[8].Width := 90;
  ejunpzall.Columns[9].Width := 50;
  ejunpzall.Columns[10].Width := 180;
  ejunpzall.Columns[11].Visible := False;
  ejunpzall.Columns[12].Visible := False;
  ejunpzall.Columns[13].Visible := False;

  ejunpzall.DataColumns.Items[6].Style.FormatString := '#,##0.00';
  ejunpzall.DataColumns.Items[7].Style.FormatString := '#,##0.00';

  qrypzb.DisableControls;
  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add(PZBsqlstr);
  qrypzb.open;
  qrypzb.First;

  for i := 1 to strlist.Count do
  begin
    if (ejunpzall.DATAColumns.Items[i - 1].FieldName = '现金流量') or
      (ejunpzall.DATAColumns.Items[i - 1].FieldName = '经营其他') then
      qrypzb.FieldByName(Trim(strlist[i - 1])).ReadOnly := False
    else
      qrypzb.FieldByName(Trim(strlist[i - 1])).ReadOnly := true;
  end;

  pgc1.ActivePageIndex := 0;
  qrypzb.EnableControls;
  //  ejunpzall.Activate(true);
end;

procedure Tfmcash.ejunpzb_toexcel;
var
  STEXT, FILENAMEXLS, FILENAMEXLS2: string;
begin
  STEXT := 'select * from 凭证表  where  (fitnum<>"" ) and xjpz=true  ' +
    'order by 全凭证号,fitnum';
  ejunpzb_refresh(stext);
  dlgSave1.InitialDir := mainpath;
  dlgSave1.Execute;
  if dlgSave1.FileName <> '' then
  begin
    if Pos('.', dlgSave1.FileName) < 1 then
      FILENAMEXLS := dlgSave1.FileName + '.XLS'
    else
      FILENAMEXLS := dlgSave1.FileName;

    FILENAMEXLS2 := StringReplace(FILENAMEXLS, '.XLS', '1.XLS', [rfReplaceAll]);
    ejunpzall.SaveToExcel(FILENAMEXLS, '现金凭证', true, false);
    OPENCASHSHEET;
    ejuncashsheet.SaveToExcel(FILENAMEXLS2, '现金流量表', true, false);

    mymessage('导出成功!');
    Close;
    ShellExecute(Handle, 'open', PChar(FILENAMEXLS), 'C:\Windows', nil, 1);
  end
  else
  begin
    mymessage('取消保存!');
  end;
end;

procedure Tfmcash.ejunpzoneCellGetColor(Sender: TObject; ACoord: TPoint; var
  AColor: TColor);
begin
  if ejunpzone.Cells[12, ACoord.Y].AsBoolean then
    AColor := cl3DLight
  else
    AColor := clWindow;
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

procedure Tfmcash.opencashcalcsheet;
begin
  { TODO : 汇总凭证表的现金流量 }
  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('create view cashcalctable  as ');
  qrytmp.sql.add(' select 0  as id,max(现金流量名称) as 现金流量名称 ,max(现金流量简称) as 现金流量简称,sum(金额) as 金额,"" AS 标识  ');
  qrytmp.sql.add('   FROM 凭证表');
  qrytmp.sql.add(' group by 现金流量名称 ');
  qrytmp.sql.add(' union  ');
  qrytmp.sql.add(' select id,现金流量名称 现金流量简称, 金额, 标识  ');
  qrytmp.sql.add('   FROM 现金流量表项目');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update 现金流量表项目 set 是否原始=true');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('insert into 现金流量表项目(id,现金流量名称, 现金流量简称, 金额, 标识)');
  qrytmp.sql.add(' select max( id),max(现金流量名称),max( 现金流量简称), sum(金额),max( 标识)  ');
  qrytmp.sql.add('   FROM cashcalctable');
  qrytmp.sql.add(' group by 现金流量名称 ');
  qrytmp.sql.add(' order  by id ');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('delete from  现金流量表项目 where 是否原始=true');
  qrytmp.ExecSQL;

end;

procedure Tfmcash.open_ejuncashsheet;
var
  STRLIST: tstringlist;
  stext: string;
  i: Integer;
begin

  if qrycashsheet.Active = FALSE then
  begin
    qrycashsheet.TableName := '现金流量表项目';
    qrycashsheet.open;
  end
  else
  begin
    qrycashsheet.Close;
    qrycashsheet.TableName := '现金流量表项目';
    qrycashsheet.open;
  end;

  stext := '现金流量项目	,金额 ,现金流量简称,	ID	,	标识 ';
  STRLIST := tstringlist.create();
  STRLIST.Delimiter := ',';
  STRLIST.DelimitedText := stext;

  for i := 1 to strlist.Count do
  begin
    if I >= ejuncashsheet.DataColumns.Count + 1 then
      ejuncashsheet.DataColumns.Add;
    ejuncashsheet.DATAColumns.Items[i - 1].FieldName := strlist[i - 1];
    ejuncashsheet.DATAColumns.Items[I - 1].Title := STRLIST[I - 1];
  end;

  ejuncashsheet.Columns[1].Width := 370;
  ejuncashsheet.Columns[2].Width := 180;
  ejuncashsheet.Columns[3].Visible := FALSE;
  ejuncashsheet.Columns[4].Visible := FALSE;
  ejuncashsheet.Columns[5].Visible := FALSE;

  ejuncashsheet.DataColumns.Items[1].Style.FormatString := '#,##0.00';
  ejuncashsheet.Activate(true);
end;

procedure Tfmcash.xjsum;
var
  QCQM: double;
begin
  //
  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('select sum(期初) as QC FROM DG7 WHERE IS现金');
  qrytmp.open;

  if QRYTMP.RECORDCOUNT > 0 then
  begin
    QCQM := QRYTMP.FIELDBYNAME('QC').ASFLOAT;

    qrytmp.close;
    qrytmp.sql.clear;
    qrytmp.sql.add('UPDATE 现金流量表项目 set 金额=:JE WHERE trim(现金流量项目)="加:期初现金及现金等价物余额"');
    qrytmp.Parameters.ParamByName('JE').value := QCQM;
    qrytmp.ExecSQL;
  end;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('select sum(期末) as QC FROM DG7 WHERE IS现金');
  qrytmp.open;

  if QRYTMP.RECORDCOUNT > 0 then
  begin
    QCQM := QRYTMP.FIELDBYNAME('QC').ASFLOAT;
    qrytmp.close;
    qrytmp.sql.clear;
    qrytmp.sql.add('UPDATE 现金流量表项目 set 金额=:JE WHERE trim(现金流量项目)="六、期末现金及现金等价物余额"');
    qrytmp.Parameters.ParamByName('JE').value := QCQM;
    qrytmp.ExecSQL;
  end;
end;

procedure Tfmcash.xjjesum;
var
  a1, a2, a3, QCQM: double;

begin
  // TODO -cMM: Tfmcash.xjjesum default body inserted

  a1 := 0;
  a2 := 0;
  a3 := 0;
  qcqm := 0;
  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('select sum(金额) as QC FROM 现金流量表项目 WHERE INSTR(现金流量项目,"净额")>0');
  qrytmp.open;

  if QRYTMP.RECORDCOUNT > 0 then
  begin
    QCQM := QRYTMP.FIELDBYNAME('QC').ASFLOAT;
    qrytmp.close;
    qrytmp.sql.clear;
    qrytmp.sql.add('UPDATE 现金流量表项目 set 金额=:JE WHERE trim(现金流量项目)="五、现金及现金等价物净增加额"');
    qrytmp.Parameters.ParamByName('JE').value := QCQM;
    qrytmp.ExecSQL;
  end;

  a1 := qcqm;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('select sum(金额) as QC FROM 现金流量表项目 WHERE trim(现金流量项目)="加:期初现金及现金等价物余额"');
  qrytmp.open;

  if QRYTMP.RECORDCOUNT > 0 then
    a2 := QRYTMP.FIELDBYNAME('QC').ASFLOAT;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('select sum(金额) as QC FROM 现金流量表项目 WHERE trim(现金流量项目)="六、期末现金及现金等价物余额"');
  qrytmp.open;

  if QRYTMP.RECORDCOUNT > 0 then
    a3 := QRYTMP.FIELDBYNAME('QC').ASFLOAT;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('UPDATE 现金流量表项目 set 金额=:JE WHERE INSTR(现金流量项目,"====")>0');
  qrytmp.Parameters.ParamByName('JE').value := a1 + a2 - a3;
  qrytmp.ExecSQL;

end;

function Tfmcash.firstlevel_length: integer;
begin
  result := 4;

  try
    qrytmp.CLOSE;
    qrytmp.SQL.Clear;
    qrytmp.SQL.Add('select min(len(TRIM(科目编码))) as 一级科目长度 from 凭证表 where trim(科目编码)<>""');
    qrytmp.open;
    result := qrytmp.fieldbyname('一级科目长度').ASINTEGER;
  except
  end;
end;

procedure Tfmcash.OnlySee_Pzb_flatdata;
var
  stext: string;
begin
  // TODO -cMM: Tfmcash.OnlySee_Pzb_flatdata default body inserted
  STEXT := 'select * from 凭证表  where   ' +
    ' 全凭证号 in (select distinct 全凭证号 from 凭证表 where fitnum="OK挤平数据" )' +
    ' and (fitnum="OK挤平数据" or trim(fitnum)="" or (fitnum is null))  order by 全凭证号,fitnum ';
  ejunpzb_refresh(stext);

end;

procedure Tfmcash.pzb_calc_onlycash_at_aSide;
begin
  // TODO -cMM: Tfmcash.pzb_calc_onlycash_at_aSide default body inserted
  //==借方发生只有现金科目
  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('delete from   xjcount   ');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('insert into  xjcount  select distinct 全凭证号 as 凭证号 ,一级编码 as 一级代码 from 凭证表 ');
  qrytmp.sql.add(' where 现金否=true and 借方<>0 and trim(fitnum)="OK挤平数据"');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('delete from   xjcount  where  凭证号 in ');
  qrytmp.sql.add('(select 全凭证号 from 凭证表  where 现金否<>true and 借方<>0 and trim(fitnum)="OK挤平数据")');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update 凭证表 A set A.fitnum=''OKall'' WHERE  A.全凭证号 IN (SELECT 凭证号 FROM xjcount) and  trim(a.fitnum)="OK挤平数据" ');
  qrytmp.ExecSQL;

  //==============     贷方发生只有现金科目
  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('delete from   xjcount   ');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('insert into  xjcount  select distinct 全凭证号 as 凭证号 ,一级编码 as 一级代码 from 凭证表');
  qrytmp.sql.add(' where 现金否=true and 贷方<>0 and trim(fitnum)="OK挤平数据"');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('delete from   xjcount  where  凭证号 in ');
  qrytmp.sql.add('(select 全凭证号 from 凭证表  where 现金否<>true and 贷方<>0 and trim(fitnum)="OK挤平数据")');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update 凭证表 A set A.fitnum=''OKall'' WHERE  A.全凭证号 IN (SELECT 凭证号 FROM xjcount ) and  trim(a.fitnum)="OK挤平数据" ');
  qrytmp.ExecSQL;

  //==============     贷方发生只有现金科目

end;

procedure Tfmcash.see_allpz;
var
  stext: string;
begin
  STEXT := 'select * from 凭证表  where ( not trim(fitnum)="不适用" ) and xjpz=true  '
    //
  + ' order by 全凭证号,fitnum';
  ejunpzb_refresh(stext);
end;

end.

