unit fmpzb;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, ExtCtrls, communit, ZcGridClasses, NxEdit, CLSexcel,
  StdCtrls, ZcUniClass, ZJGrid, ZcDataGrid, ZcDBGrids, ComCtrls, csdg,  ShellAPI,
  Menus, cxGraphics, cxDataStorage, cxEdit, Word2000, Excel2000, ComObj,
  cxDBData, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxControls, cxGridCustomView, cxGrid, FileCtrl;

type
  Tfrmpzh = class(TForm)
    ds1: TDataSource;
    pnl2: TPanel;
    qrykmb: TADOQuery;
    qryONEpz: TADOQuery;
    dskmb: TDataSource;
    dsonepz: TDataSource;
    spl2: TSplitter;
    pgc1: TPageControl;
    ts1: TTabSheet;
    ts2: TTabSheet;
    pnl1: TPanel;
    ts3: TTabSheet;
    ejundbgrid2: TEjunDBGrid;
    ejnlcns1: TEjunLicense;
    qrymxlist: TADOQuery;
    qrypzb: TADOQuery;
    ejunpzall: TEjunDBGrid;
    ts4: TTabSheet;
    tbdw: TADOTable;
    dsdw: TDataSource;
    mmo1: TMemo;
    pgc2: TPageControl;
    pnl3: TPanel;
    pnl4: TPanel;
    Label1: TLabel;
    ts5: TTabSheet;
    ts6: TTabSheet;
    pgc3: TPageControl;
    ts7: TTabSheet;
    ts8: TTabSheet;
    ts9: TTabSheet;
    ts10: TTabSheet;
    pnl5: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    lblALLcount: TLabel;
    lblselectCOUNT: TLabel;
    lblpercentcount: TLabel;
    lblJFall: TLabel;
    lblJFselect: TLabel;
    LBLJFpercent: TLabel;
    lblDFall: TLabel;
    lbldfSELECT: TLabel;
    LBLDFpercent: TLabel;
    qryTMP: TADOQuery;
    btn3: TButton;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    btn4: TButton;
    lblLBLCOUNT4: TLabel;
    lblLBLCOUNT5: TLabel;
    lblLBLCOUNT6: TLabel;
    LBLCOUNT1: TLabel;
    lblLBLCOUNT2: TLabel;
    lblLBLCOUNT3: TLabel;
    edtsystem: TNxNumberEdit;
    edtsystembegin: TNxNumberEdit;
    edtlev1: TNxNumberEdit;
    edtlev2: TNxNumberEdit;
    edtlev3: TNxNumberEdit;
    edtlev4: TNxNumberEdit;
    edtlev5: TNxNumberEdit;
    edtlev6: TNxNumberEdit;
    pnl6: TPanel;
    btn1: TButton;
    lbl1: TLabel;
    lbl2: TLabel;
    lblTITLE1: TLabel;
    lblTITLE2BZ: TLabel;
    mmo2: TMemo;
    pnl7: TPanel;
    rb1: TRadioButton;
    rb2: TRadioButton;
    btn2: TButton;
    edtRNDsl: TNxNumberEdit;
    edtRNDpercent: TNxNumberEdit;
    btn5: TButton;
    ejunonepz: TEjunDBGrid;
    btn6: TButton;
    lblid: TLabel;
    lblname: TLabel;
    btnok: TButton;
    btn8: TButton;
    mm1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    shp1: TShape;
    lbl3: TLabel;
    btndgfalse: TButton;
    btn7: TButton;
    btn9: TButton;
    pnl8: TPanel;
    pnl9: TPanel;
    ejunkmyeb: TEjunDBGrid;
    fllst1: TFileListBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ejundbgrid2DblClick(Sender: TObject);
    procedure ejunkmyebDblClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure pgc2Change(Sender: TObject);
    procedure displaystatus();
    procedure displaylevelstatus();
    procedure btn3Click(Sender: TObject);
    procedure ejunpzallDblClick(Sender: TObject);
    procedure listKMYEBmx();
    procedure listpzb(kmdm: string);
    procedure pgc3Change(Sender: TObject);
    procedure ejundbgrid2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pzfromlevel();
    procedure btn4Click(Sender: TObject);
    procedure main_detail(ismain: boolean);
    procedure lbl1Click(Sender: TObject);
    procedure pgc1Change(Sender: TObject);
    procedure lbl1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lbl1MouseLeave(Sender: TObject);
    procedure lbl1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ejunpzallMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btn5Click(Sender: TObject);
    procedure openonepz();
    procedure btn6Click(Sender: TObject);
    procedure btnokClick(Sender: TObject);
    procedure btn8Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure btndgfalseClick(Sender: TObject);
    procedure btn7Click(Sender: TObject);
    procedure btn9Click(Sender: TObject);
    procedure fllst1DblClick(Sender: TObject);

  private
    fxmid: string;
    { Private declarations }
  public
    { Public declarations }
    property xmid: string read fxmid write fxmid;
  end;

var
  frmpzh: Tfrmpzh;
  //  adgsystem: dgsystem;
  adgbook: dgworkbook;
  xmcon: TADOConnection;

implementation

uses
  XMmanager, lxydatabase, frmopendw, lxyjm;

{$R *.dfm}

procedure Tfrmpzh.FormCreate(Sender: TObject);
begin

  ajm := tlxyjm.create(ExtractFilePath(Application.ExeName));
  btndgfalse.Left := btnok.Left;
  btndgfalse.Top := btnok.top;
  if ajm.check3 then
  begin
    btnok.Visible := true;
    btndgfalse.Visible := false;
  end
  else
  begin
    btnok.Visible := false;
    btndgfalse.Visible := true;
  end;

  ADGSYSTEM := dgsystem.create(ExtractFilePath(Application.ExeName));
  axm := adgsystem.OPENLAST;

  fxmid := axm.xmid;
  lblid.Caption := axm.xmid;
  lblname.Caption := axm.xmname;

  adgbook := dgworkbook.create;
  // adgbook.
  adgbook.xm := axm;
  xmcon := TADOConnection.Create(nil);
  try
    if DirectoryExists(axm.xmpath) then
    begin
      xmcon := adgbook.connection;
      xmcon.LoginPrompt := false;
      if xmcon.Connected = false then
        xmcon.Connected := True;

      fllst1.Directory := axm.xmpath;
      

    end;
  except
  end;

  qrykmb.Connection := xmcon;
  qryONEpz.Connection := xmcon;
  qrymxlist.Connection := xmcon;
  qrypzb.Connection := xmcon;
  qryTMP.Connection := xmcon;
  try
    tbdw.Connection := adgsystem.connection;

  except
  end;
  pgc1.ActivePageIndex := 0;
  pgc2.ActivePageIndex := 0;
  rb1.Checked := true;

end;

procedure Tfrmpzh.FormShow(Sender: TObject);
var
  STRLIST: tstringlist;
  stext: string;
  i: Integer;
begin
  //

  try
    tbdw.TableName := '底稿单位';
    tbdw.Open;
    tbdw.Filtered := false;
    tbdw.Filter := 'xmid=''' + fxmid + '''';
    tbdw.Filtered := True;
    mmo1.Text := tbdw.FieldByName('项目备注').AsString;
    tbdw.Close;

    stext := '代码,科目名称,借贷方向,期初,借方发生,贷方发生,期末';
    STRLIST := tstringlist.create();
    STRLIST.Delimiter := ',';
    STRLIST.DelimitedText := stext;

    // ejundbgrid2.DataColumns.Clear;

    for i := 1 to strlist.Count do
    begin
      if I >= ejunkmyeb.DataColumns.Count - 1 then
        ejunkmyeb.DataColumns.Add;
      ejunkmyeb.DATAColumns.Items[i - 1].FieldName := strlist[i - 1];
      ejunkmyeb.DATAColumns.Items[I - 1].Title := STRLIST[I - 1];
    end;

    ejunkmyeb.Columns[1].Width := 45;
    ejunkmyeb.Columns[2].Width := 200;
    ejunkmyeb.Columns[3].Width := 30;
    ejunkmyeb.Columns[4].Width := 120;
    ejunkmyeb.Columns[5].Width := 120;
    ejunkmyeb.Columns[6].Width := 120;
    ejunkmyeb.Columns[7].Width := 120;
    ejunkmyeb.Columns[8].Width := 60;

    ejunkmyeb.DataColumns.Items[3].Style.FormatString := '#,##0.00';
    ejunkmyeb.DataColumns.Items[4].Style.FormatString := '#,##0.00';
    ejunkmyeb.DataColumns.Items[5].Style.FormatString := '#,##0.00';
    ejunkmyeb.DataColumns.Items[6].Style.FormatString := '#,##0.00';

    if not FileExists(axm.xmpath + '\DG.MDB') then
      EXIT;

    qrykmb.Close;
    qrykmb.SQL.Clear;
    qrykmb.SQL.Add('select * from dg7 where  (trim(核算项目名称)="" or (核算项目名称 is null) ) and (xmid=''' + fxmid +
      ''') and len(代码)=' + trim(inttostr(axm.kmlen)) + ' order by 代码');
    qrykmb.Open;
    qrykmb.First;

    pgc1.ActivePageIndex := 0;
    try
      main_detail(True);
    except
    end;
  except
  end;

end;

procedure Tfrmpzh.ejundbgrid2DblClick(Sender: TObject);
var
  STRLIST: tstringlist;
  stext: string;
  i: Integer;
  icol: Integer;
begin
  //
  if ejundbgrid2.tag <= 17 then
  begin
    //    if ejundbgrid2.CurRow < 1 then
    //    begin
    icol := ejundbgrid2.CurCol;
    if ejundbgrid2.Columns[icol].Tag = 'Z' then
    begin
      ejundbgrid2.SortRow(icol, true);
      ejundbgrid2.Columns[icol].Tag := 'A'
    end
    else
    begin
      ejundbgrid2.SortRow(icol, false);
      ejundbgrid2.Columns[icol].Tag := 'Z'
    end;
    Exit;
    //    end;
  end;
  stext :=
    '日期, 月份, 凭证类型, 凭证编号, 科目编码,一级名称, 科目名称, 摘要,抽凭标志, 借方, 贷方, 对方科目, 项目核算类型, 项目核算代码,项目核算名称,全凭证号,一级编码';
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

  ejunpzall.Columns[1].Width := 60;
  ejunpzall.Columns[2].Width := 40;
  ejunpzall.Columns[3].Width := 40;
  ejunpzall.Columns[4].Width := 40;
  ejunpzall.Columns[5].Width := 70;
  ejunpzall.Columns[6].Width := 70;
  ejunpzall.Columns[7].Width := 150;
  ejunpzall.Columns[8].Width := 270;
  ejunpzall.Columns[9].Width := 60;
  ejunpzall.Columns[10].Width := 100;
  ejunpzall.Columns[11].Width := 120;
  ejunpzall.Columns[12].Width := 130;
  ejunpzall.DataColumns.Items[9].Style.FormatString := '#,##0.00';
  ejunpzall.DataColumns.Items[10].Style.FormatString := '#,##0.00';
  ejunpzall.DataColumns.Items[11].Style.FormatString := '#,##0.00';

  if qrymxlist.fieldbyname('核算项目代码').asstring <> '' then
  begin
    qrypzb.Close;
    qrypzb.SQL.Clear;
    qrypzb.sql.Add('select * from 项目凭证表  where (xmid=''' + fxmid + ''')  and  科目编码 like '''
      + Trim(qrymxlist.fieldbyname('代码').asstring) + '%''' + ' and  trim(项目核算代码)=''' +
      trim(qrymxlist.fieldbyname('核算项目代码').asstring) + '''');
    qrypzb.open;
    qrypzb.First;
  end
  else
  begin
    qrypzb.Close;
    qrypzb.SQL.Clear;
    qrypzb.sql.Add('select * from 凭证表  where (xmid=''' + fxmid + ''')  and trim(科目编码) like '''
      + Trim(qrymxlist.fieldbyname('代码').asstring) + '%''');
    qrypzb.open;
    qrypzb.First;
  end;

  // ejunpzall.Refresh;
  ejunpzall.Activate(TRUE);

  displaystatus;

  pgc1.ActivePageIndex := 2;
  pgc3.ActivePageIndex := 0;

end;

procedure Tfrmpzh.ejunkmyebDblClick(Sender: TObject);

begin
  //

  listpzb(qrykmb.fieldbyname('代码').AsString);
  listKMYEBmx();
  lblTITLE2BZ.Caption := '科目明细账';

  main_detail(false);

end;

procedure Tfrmpzh.btn1Click(Sender: TObject);
begin
  tbdw.Open;
  tbdw.Filtered := false;
  tbdw.Filter := 'xmid=''' + axm.xmid + '''';
  tbdw.Filtered := True;
  tbdw.Edit;
  tbdw.FieldByName('项目备注').AsString := mmo1.Text;
  tbdw.Post;
  tbdw.Close;

end;

procedure Tfrmpzh.btn2Click(Sender: TObject);
var
  icount, iall: LongInt;
begin

  if rb1.Checked then
    try
      icount := StrToInt(edtRNDsl.text);
    except
      icount := 30;
    end;

  if rb2.Checked then
  begin

    qryTMP.Close;
    qryTMP.SQL.Clear;
    qryTMP.sql.Add('select count(*) as reccount  from 凭证表  where (xmid=''' + fxmid +
      ''')  and trim(科目编码) like '''
      + Trim(qrymxlist.fieldbyname('代码').asstring) + '%'' ');
    qryTMP.Open;
    if qryTMP.RecordCount > 0 then
      iall := qryTMP.fieldbyname('reccount').AsInteger
    else
      iall := 0;

    icount := Round(iall * strtofloat(edtRNDpercent.text) / 100);
  end;

  qryTMP.Close;
  qryTMP.SQL.Clear;
  qryTMP.SQL.Add('delete from 抽凭表');
  qryTMP.ExecSQL;

  qryTMP.Close;
  qryTMP.SQL.Clear;
  qryTMP.SQL.Add(' update 凭证表 set 抽凭标志=false');
  qryTMP.SQL.Add(' WHERE  xmid=''' + fxmid + '''' + ' and  trim(科目编码) like '''
    + Trim(qrymxlist.fieldbyname('代码').asstring) + '%'' ');
  qryTMP.ExecSQL;

  qryTMP.Close;
  qryTMP.SQL.Clear;
  qryTMP.SQL.Add(' INSERT INTO 抽凭表(id, 借方, 贷方, 抽凭标志)');
  qryTMP.SQL.Add(' SELECT TOP ' + inttostr(icount) + '  凭证表.id, 凭证表.借方, 凭证表.贷方, 凭证表.抽凭标志');
  qryTMP.SQL.Add(' FROM 凭证表 ');
  qryTMP.SQL.Add(' WHERE  xmid=''' + fxmid + '''' + ' and  trim(科目编码) like '''
    + Trim(qrymxlist.fieldbyname('代码').asstring) + '%'' ');
  qryTMP.SQL.Add(' ORDER BY Rnd(id)');
  qryTMP.ExecSQL;

  qryTMP.Close;
  qryTMP.SQL.Clear;
  qryTMP.SQL.Add('update 凭证表 a,抽凭表 b  set a.抽凭标志=true where a.id=B.id');
  qryTMP.ExecSQL;

  qrypzb.DisableControls;
  qrypzb.Close;
  qrypzb.Open;
  QRYPZB.FIRST;
  qrypzb.EnableControls;
  displaystatus;

  ShowMessage('ok');

end;

procedure Tfrmpzh.pgc2Change(Sender: TObject);
var

  jfje, jfselect, dfje, dfselect: Double;
  all_count, select_count: LongInt;

begin
  if pgc2.ActivePageIndex = 1 then
  begin
    displaystatus;

  end;

  pgc3.ActivePageIndex := 0;

end;

procedure Tfrmpzh.displaystatus;
var

  jfje, jfselect, dfje, dfselect: Double;
  all_count, select_count: LongInt;
begin
  //
  edtrndsl.text := '30';
  edtRNDpercent.text := '30';

  all_count := 0;
  jfje := 0;
  dfje := 0;
  jfselect := 0;
  dfselect := 0;
  select_count := 0;

  qryTMP.Close;
  qryTMP.SQL.Clear;
  qryTMP.sql.Add('select count(*) as reccount,sum(借方) as jf  from 凭证表  where (xmid=''' + fxmid +
    ''')  and trim(科目编码) like '''
    + Trim(qrymxlist.fieldbyname('代码').asstring) + '%'' and 借方<>0 ');
  qryTMP.Open;
  if qryTMP.RecordCount > 0 then
  begin
    jfje := qryTMP.fieldbyname('jf').AsFloat;
    all_count := qryTMP.fieldbyname('reccount').AsInteger;
  end;

  qryTMP.Close;
  qryTMP.SQL.Clear;
  qryTMP.sql.Add('select count(*) as reccount,sum(贷方) as df from 凭证表  where (xmid=''' + fxmid +
    ''')  and trim(科目编码) like '''
    + Trim(qrymxlist.fieldbyname('代码').asstring) + '%'' and 贷方<>0 ');
  qryTMP.Open;
  if qryTMP.RecordCount > 0 then
  begin
    dfje := qryTMP.fieldbyname('df').AsFloat;
    all_count := all_count + qryTMP.fieldbyname('reccount').AsInteger;
  end;

  qryTMP.Close;
  qryTMP.SQL.Clear;
  qryTMP.sql.Add('select count(*) as reccount,sum(借方) as jf,sum(贷方) as df from 凭证表  where (xmid=''' + fxmid +
    ''')  and trim(科目编码) like '''
    + Trim(qrymxlist.fieldbyname('代码').asstring) + '%'' and 借方<>0  and 抽凭标志=true');
  qryTMP.Open;
  if qryTMP.RecordCount > 0 then
  begin
    jfselect := qryTMP.fieldbyname('jf').AsFloat;
    select_count := qryTMP.fieldbyname('reccount').AsInteger;
  end;

  qryTMP.Close;
  qryTMP.SQL.Clear;
  qryTMP.sql.Add('select count(*) as reccount,sum(贷方) as df from 凭证表  where (xmid=''' + fxmid +
    ''')  and trim(科目编码) like '''
    + Trim(qrymxlist.fieldbyname('代码').asstring) + '%'' and 贷方<>0  and 抽凭标志=true ');
  qryTMP.Open;
  if qryTMP.RecordCount > 0 then
  begin
    dfselect := qryTMP.fieldbyname('df').AsFloat;
    select_count := select_count + qryTMP.fieldbyname('reccount').AsInteger;
  end;

  lbldfSELECT.Caption := FormatFloat('#,###', dfselect);
  lbldFall.Caption := FormatFloat('#,###', dfje);
  try
    if dfje <> 0 then
      LBLdFpercent.Caption := FormatFloat('###.##%', dfselect / dfje * 100)
    else
      LBLdFpercent.Caption := '';

  except
  end;
  lblJFselect.Caption := FormatFloat('#,###', jfselect);
  lblJFall.Caption := FormatFloat('#,###', jfje);
  try
    if jfje <> 0 then
      LBLJFpercent.Caption := FormatFloat('###.##%', jfselect / jfje * 100)
    else
      LBLJFpercent.Caption := '';

  except
  end;
  lblALLcount.Caption := IntToStr(all_count);
  lblselectCOUNT.Caption := IntToStr(select_count);
  try
    if all_count <> 0 then
      lblpercentcount.Caption := FormatFloat('###.##%', select_count / all_count * 100)
    else
      lblpercentcount.Caption := '';

  except
  end;
end;

procedure Tfrmpzh.btn3Click(Sender: TObject);
var
  icount, iall, ilevel: LongInt;
begin

  try
    icount := StrToInt(edtsystem.text);
  except
    icount := 30;
    edtsystem.text := '30';
  end;

  qryTMP.Close;
  qryTMP.SQL.Clear;
  qryTMP.sql.Add('select count(*) as reccount  from 凭证表  where (xmid=''' + fxmid +
    ''')  and trim(科目编码) like '''
    + Trim(qrymxlist.fieldbyname('代码').asstring) + '%'' ');
  qryTMP.Open;
  if qryTMP.RecordCount > 0 then
    iall := qryTMP.fieldbyname('reccount').AsInteger
  else
    iall := 0;

  ilevel := Round(iall / icount);

  qryTMP.Close;
  qryTMP.SQL.Clear;
  qryTMP.SQL.Add('delete from 抽凭表');
  qryTMP.ExecSQL;

  qryTMP.Close;
  qryTMP.SQL.Clear;
  qryTMP.SQL.Add(' update 凭证表 set 抽凭标志=false');
  qryTMP.SQL.Add(' WHERE  xmid=''' + fxmid + '''' + ' and  trim(科目编码) like '''
    + Trim(qrymxlist.fieldbyname('代码').asstring) + '%'' ');
  qryTMP.ExecSQL;

  qryTMP.Close;
  qryTMP.SQL.Clear;
  qryTMP.SQL.Add(' INSERT INTO 抽凭表(id, 借方, 贷方, 抽凭标志)');
  qryTMP.SQL.Add(' SELECT  凭证表.id, 凭证表.借方, 凭证表.贷方, 凭证表.抽凭标志');
  qryTMP.SQL.Add(' FROM 凭证表 ');
  qryTMP.SQL.Add(' WHERE  xmid=''' + fxmid + '''' + ' and  trim(科目编码) like '''
    + Trim(qrymxlist.fieldbyname('代码').asstring) + '%'' ');
  qryTMP.SQL.Add(' ORDER BY Rnd(id)');
  qryTMP.ExecSQL;

  qryTMP.Close;
  qryTMP.SQL.Clear;
  qryTMP.SQL.Add(' update 抽凭表  set 抽凭标志=true');
  qryTMP.SQL.Add(' WHERE  (RECORDNO MOD ' + INTTOSTR(ilevel) + ')=' + EDTSYSTEMBEGIN.TEXT);
  qryTMP.ExecSQL;

  qryTMP.Close;
  qryTMP.SQL.Clear;
  qryTMP.SQL.Add(' DELETE FROM 抽凭表  WHERE 抽凭标志=FALSE');
  qryTMP.ExecSQL;

  qryTMP.Close;
  qryTMP.SQL.Clear;
  qryTMP.SQL.Add('update 凭证表 a,抽凭表 b  set a.抽凭标志=true where a.id=B.id');
  qryTMP.ExecSQL;

  qrypzb.DisableControls;
  qrypzb.Close;
  qrypzb.Open;
  QRYPZB.FIRST;
  qrypzb.EnableControls;

  displaystatus;

  ShowMessage('ok');

end;

procedure Tfrmpzh.ejunpzallDblClick(Sender: TObject);
var
  ICOL: LongInt;
begin

  if ejunpzall.tag <= 17 then
  begin
    icol := ejunpzall.CurCol;
    if ejunpzall.Columns[icol].Tag = 'Z' then
    begin
      ejunpzall.SortRow(icol, true);
      ejunpzall.Columns[icol].Tag := 'A'
    end
    else
    begin
      ejunpzall.SortRow(icol, false);
      ejunpzall.Columns[icol].Tag := 'Z'
    end;
    Exit;
  end;

  openonepz;

  if pgc2.ActivePageIndex = 1 then
    try
      qrypzb.Edit;
      if qrypzb.FieldByName('抽凭标志').AsBoolean = false then
        qrypzb.FieldByName('抽凭标志').AsBoolean := True
      else
        qrypzb.FieldByName('抽凭标志').AsBoolean := false;
      qrypzb.Post;
      //  qrypzb.Refresh;
    except
      ShowMessage('加入抽凭失败！');
    end;

end;

procedure Tfrmpzh.listKMYEBmx;
var
  STRLIST: tstringlist;
  stext: string;
  i: Integer;
begin
  stext := '代码,科目名称,核算项目名称,借贷方向,期初,借方发生,贷方发生,期末,一级科目代码,一级科目名称,长科目名';
  STRLIST := tstringlist.create();
  STRLIST.Delimiter := ',';
  STRLIST.DelimitedText := stext;

  for i := 1 to strlist.Count do
  begin
    if I >= ejundbgrid2.DataColumns.Count - 1 then
      ejundbgrid2.DataColumns.Add;
    ejundbgrid2.DATAColumns.Items[i - 1].FieldName := strlist[i - 1];
    ejundbgrid2.DATAColumns.Items[I - 1].Title := STRLIST[I - 1];
  end;

  ejundbgrid2.Columns[1].Width := 65;
  ejundbgrid2.Columns[2].Width := 200;
  ejundbgrid2.Columns[3].Width := 150;
  ejundbgrid2.Columns[4].Width := 30;
  ejundbgrid2.Columns[5].Width := 120;
  ejundbgrid2.Columns[6].Width := 120;
  ejundbgrid2.Columns[7].Width := 120;
  ejundbgrid2.Columns[8].Width := 120;
  ejundbgrid2.Columns[9].Width := 60;
  ejundbgrid2.Columns[10].Width := 60;
  ejundbgrid2.Columns[11].Width := 60;
  ejundbgrid2.DataColumns.Items[4].Style.FormatString := '#,##0.00';
  ejundbgrid2.DataColumns.Items[5].Style.FormatString := '#,##0.00';
  ejundbgrid2.DataColumns.Items[6].Style.FormatString := '#,##0.00';
  ejundbgrid2.DataColumns.Items[7].Style.FormatString := '#,##0.00';

  ejundbgrid2.dataset := qrymxlist;
  //  qrytmp.close;
  //  qrytmp.sql.Clear;
  //  qrytmp.sql.Add('update dg7 set  一级科目代码=left(trim(代码),'+trim(inttostr(axm.kmlen))+')');
  //  qrytmp.ExecSQL;

  qrymxlist.Close;
  qrymxlist.SQL.Clear;
  qrymxlist.SQL.Add('select * from  dg7  where ((一级科目代码)=''' + (qrykmb.fieldbyname('代码').asstring) +
    ''')');
  qrymxlist.SQL.Add('AND (xmid=''' + fxmid + ''')  order by  代码,科目名称  desc');
  QRYMXLIST.OPEN;

  QRYMXLIST.First;

  pgc1.ActivePageIndex := 1;
end;

procedure Tfrmpzh.listpzb(kmdm: string);
var
  STRLIST: tstringlist;
  stext: string;
  i: Integer;
begin
  //
  stext :=
    '日期, 月份, 凭证类型, 凭证编号, 科目编码,一级名称,科目名称, 摘要,抽凭标志, 借方, 贷方, 对方科目, 项目核算类型, 项目核算代码,项目核算名称,全凭证号';
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

  ejunpzall.Columns[1].Width := 60;
  ejunpzall.Columns[2].Width := 40;
  ejunpzall.Columns[3].Width := 40;
  ejunpzall.Columns[4].Width := 40;
  ejunpzall.Columns[5].Width := 70;
  ejunpzall.Columns[6].Width := 70;
  ejunpzall.Columns[7].Width := 150;
  ejunpzall.Columns[8].Width := 350;
  ejunpzall.Columns[9].Width := 100;
  ejunpzall.Columns[10].Width := 100;
  ejunpzall.Columns[11].Width := 120;
  ejunpzall.Columns[12].Width := 30;
  //   ejunpzall.DataColumns.Items[9].

  ejunpzall.DataColumns.Items[9].Style.FormatString := '#,##0.00';
  ejunpzall.DataColumns.Items[10].Style.FormatString := '#,##0.00';
  ejunpzall.DataColumns.Items[11].Style.FormatString := '#,##0.00';

  ejunpzall.DataSet := qrypzb;
  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('select * from 凭证表  where (xmid=''' + fxmid + ''')  and trim(科目编码) like '''
    + kmdm + '%''');
  qrypzb.open;
  qrypzb.First;

  openonepz;
  pgc1.ActivePageIndex := 2;
end;

procedure Tfrmpzh.displaylevelstatus;
var
  STRLIST: tstringlist;
  //  stext: string;
  i: Integer;
  levcount: array[1..6] of integer;

begin
  STRLIST := tstringlist.create();
  STRLIST.Add('  借方+贷方<0');
  STRLIST.Add('借方+贷方>0 and  借方+贷方<9999');
  STRLIST.Add('借方 + 贷方 >= 10000 and 借方 + 贷方 <100000');
  STRLIST.Add('借方 + 贷方 >= 100000 and 借方 + 贷方 < 1000000');
  STRLIST.Add('借方 + 贷方 >= 1000000 and 借方 + 贷方 < 10000000');
  STRLIST.Add('借方 + 贷方 >= 10000000');

  for i := 1 to strlist.Count do
  begin

    qryTMP.Close;
    qryTMP.SQL.Clear;
    qryTMP.sql.Add('select count(*) as reccount from 凭证表  where (xmid=''' + fxmid +
      ''')  and trim(科目编码) like '''
      + Trim(qrykmb.fieldbyname('代码').asstring) + '%''  and  ' + strlist[i - 1]);
    //    showmessage(qrytmp.sql.text);
    qryTMP.Open;

    if qryTMP.RecordCount > 0 then
      levcount[i] := qryTMP.fieldbyname('reccount').asinteger
    else
      levcount[i] := 0;
  end;

  lblcount1.caption := IntToStr(levcount[1]);
  lbllblcount2.caption := IntToStr(levcount[2]);
  lbllblcount3.caption := IntToStr(levcount[3]);
  lbllblcount4.caption := IntToStr(levcount[4]);
  lbllblcount5.caption := IntToStr(levcount[5]);
  lbllblcount6.caption := IntToStr(levcount[6]);
  if edtlev1.Value > levcount[1] then
    edtlev1.Value := levcount[1];
  if edtlev2.Value > levcount[2] then
    edtlev2.Value := levcount[2];
  if edtlev3.Value > levcount[3] then
    edtlev3.Value := levcount[3];
  if edtlev4.Value > levcount[4] then
    edtlev5.Value := levcount[4];
  if edtlev5.Value > levcount[5] then
    edtlev5.Value := levcount[5];
  if edtlev6.Value > levcount[6] then
    edtlev6.Value := levcount[6];

end;

procedure Tfrmpzh.pgc3Change(Sender: TObject);
begin
  if pgc3.ActivePageIndex = 2 then
    displaylevelstatus;
end;

procedure Tfrmpzh.ejundbgrid2MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ejundbgrid2.tag := y;
end;

procedure Tfrmpzh.pzfromlevel;
var
  STRLIST: tstringlist;
  //  stext: string;
  i: Integer;
  levcount: array[1..6] of integer;

begin
  STRLIST := tstringlist.create();
  STRLIST.Add('  借方+贷方<0');
  STRLIST.Add('借方+贷方>0 and  借方+贷方<9999');
  STRLIST.Add('借方 + 贷方 >= 10000 and 借方 + 贷方 <100000');
  STRLIST.Add('借方 + 贷方 >= 100000 and 借方 + 贷方 < 1000000');
  STRLIST.Add('借方 + 贷方 >= 1000000 and 借方 + 贷方 < 10000000');
  STRLIST.Add('借方 + 贷方 >= 10000000');

  levcount[1] := round(edtlev1.Value);
  levcount[2] := round(edtlev2.Value);
  levcount[3] := round(edtlev3.Value);
  levcount[4] := round(edtlev4.Value);
  levcount[5] := Round(edtlev5.Value);
  levcount[6] := Round(edtlev6.Value);

  qryTMP.Close;
  qryTMP.SQL.Clear;
  qryTMP.SQL.Add('delete from 抽凭表');
  qryTMP.ExecSQL;

  qryTMP.Close;
  qryTMP.SQL.Clear;
  qryTMP.SQL.Add(' update 凭证表 set 抽凭标志=false');
  qryTMP.SQL.Add(' WHERE  xmid=''' + fxmid + '''' + ' and  trim(科目编码) like '''
    + Trim(qrymxlist.fieldbyname('代码').asstring) + '%'' ');
  qryTMP.ExecSQL;

  for i := 1 to strlist.Count do
  begin

    if levcount[i] > 0 then
    begin
      qryTMP.Close;
      qryTMP.SQL.Clear;
      qryTMP.SQL.Add(' INSERT INTO 抽凭表(id, 借方, 贷方, 抽凭标志)');
      qryTMP.SQL.Add(' SELECT  top ' + IntToStr(levcount[i]) +
        '  凭证表.id, 凭证表.借方, 凭证表.贷方, 凭证表.抽凭标志');
      qryTMP.SQL.Add(' FROM 凭证表 ');
      qryTMP.sql.Add(' where (xmid=''' + fxmid +
        ''')  and trim(科目编码) like '''
        + Trim(qrykmb.fieldbyname('代码').asstring) + '%''  and  ' + strlist[i - 1]);
      qryTMP.SQL.Add(' ORDER BY Rnd(id)');
      qryTMP.ExecSQL;
    end;

  end;

  qryTMP.Close;
  qryTMP.SQL.Clear;
  qryTMP.SQL.Add('update 凭证表 a,抽凭表 b  set a.抽凭标志=true where a.id=B.id');
  qryTMP.ExecSQL;

  qrypzb.DisableControls;
  qrypzb.Close;
  qrypzb.Open;
  QRYPZB.FIRST;
  qrypzb.EnableControls;

  displaystatus;
  ShowMessage('分层抽样执行完毕！');

end;

procedure Tfrmpzh.btn4Click(Sender: TObject);
begin
  pzfromlevel;
end;

procedure Tfrmpzh.main_detail(ismain: boolean);
begin
  //
  if ismain then
  begin
    pgc1.ActivePageIndex := 0;
    pgc1.Pages[0].TabVisible := TRUE;
    pgc1.Pages[1].TabVisible := FALSE;
    pgc1.Pages[2].TabVisible := FALSE;
    lblTITLE1.Caption := '';
    lblTITLE2BZ.Caption := '';
  end
  else
  begin
    pgc1.ActivePageIndex := 1;
    pgc1.Pages[0].TabVisible := FALSE;
    pgc1.Pages[1].TabVisible := TRUE;
    pgc1.Pages[2].TabVisible := TRUE;

    lblTITLE1.Caption := qrykmb.FIELDBYNAME('科目名称').ASSTRING;
    lblTITLE2BZ.Caption := '>>';
    pgc2.ActivePageIndex := 0;

  end;
end;

procedure Tfrmpzh.lbl1Click(Sender: TObject);
begin
  main_detail(True);
end;

procedure Tfrmpzh.pgc1Change(Sender: TObject);
begin
  if pgc1.ActivePageIndex = 1 then
    lblTITLE2BZ.Caption := '科目明细账'
  else if pgc1.ActivePageIndex = 2 then
  begin
    lblTITLE2BZ.Caption := '全部凭证清单';
    displaystatus;
    pgc3.ActivePageIndex := 0;
  end
  else if pgc1.ActivePageIndex = 3 then
    lblTITLE2BZ.Caption := '项目备忘录';

end;

procedure Tfrmpzh.lbl1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  LBL1.Color := clYellow; //clBtnFace
end;

procedure Tfrmpzh.lbl1MouseLeave(Sender: TObject);
begin
  LBL1.Color := clBtnFace;
end;

procedure Tfrmpzh.lbl1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  LBL1.Color := clYellow; //clBtnFace
end;

procedure Tfrmpzh.ejunpzallMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ejunPZALL.tag := y;
end;

procedure Tfrmpzh.btn5Click(Sender: TObject);
begin
  //

end;

procedure Tfrmpzh.openonepz;
var
  ICOL: LongInt;
  STRLIST: tstringlist;
  stext: string;
  i: Integer;
begin
  //
  stext :=
    '日期, 月份, 凭证类型, 凭证编号, 科目编码,一级名称, 科目名称, 摘要,借方, 贷方,  项目核算类型, 项目核算代码,项目核算名称';
  STRLIST := tstringlist.create();
  STRLIST.Delimiter := ',';
  STRLIST.DelimitedText := stext;

  for i := 1 to strlist.Count do
  begin
    if I >= ejunonepz.DataColumns.Count - 1 then
      ejunonepz.DataColumns.Add;
    ejunonepz.DATAColumns.Items[i - 1].FieldName := strlist[i - 1];
    ejunonepz.DATAColumns.Items[I - 1].Title := STRLIST[I - 1];
  end;

  ejunonepz.Columns[1].Width := 60;
  ejunonepz.Columns[2].Width := 40;
  ejunonepz.Columns[3].Width := 40;
  ejunonepz.Columns[4].Width := 40;
  ejunonepz.Columns[5].Width := 70;
  ejunonepz.Columns[6].Width := 80;
  ejunonepz.Columns[7].Width := 200;
  ejunonepz.Columns[8].Width := 150;
  ejunonepz.Columns[9].Width := 150;
  ejunonepz.Columns[10].Width := 100;
  ejunonepz.Columns[11].Width := 100;

  ejunonepz.DataColumns.Items[7].Style.FormatString := '#,##0.00';
  ejunonepz.DataColumns.Items[8].Style.FormatString := '#,##0.00';
  ejunonepz.DataColumns.Items[9].Style.FormatString := '#,##0.00';

  qryONEpz.DisableControls;
  ejunonepz.DataSet := qryONEpz;
  qryONEpz.Close;
  qryONEpz.SQL.Clear;
  qryONEpz.SQL.Add('select * from 凭证表 where trim(xmid)=''' + trim(fxmid) + '''  and trim(全凭证号)=''' +
    trim(qrypzb.fieldbyname('全凭证号').asstring) + '''');
  qryONEpz.Open;
  ejunonepz.Activate(TRUE);

end;

procedure Tfrmpzh.btn6Click(Sender: TObject);
begin

  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('select * from 凭证表  where  全凭证号 IN ');
  qrypzb.sql.Add(' (select 全凭证号  from 凭证表 where  (xmid=''' + fxmid + ''')  and  科目编码 like '''
    + Trim(qrymxlist.fieldbyname('代码').asstring) + '%'')  and  (xmid=''' + fxmid + ''')  order by 全凭证号 ');
  qrypzb.open;
  qrypzb.First;
end;

procedure Tfrmpzh.btnokClick(Sender: TObject);
var
  adg: auditdg;
  excelapp: OleVariant;
  kmdmlist: tstringlist;
begin
  try
    excelapp := createoleobject('excel.application');
    excelapp.DisplayAlerts := false;
    excelapp.visible := true;
    adgbook.excelapp := excelapp;
    qryTMP.Close;
    qryTMP.SQL.Clear;
    qryTMP.SQL.Add('select * from 项目对应关系 where xmid=''' + axm.xmid + '''  and trim(代码)=''' +
      trim(qrykmb.fieldbyname('代码').AsString) + '''');
    qryTMP.Open;
    if qrytmp.recordcount > 0 then
    begin
      kmdmlist := TStringList.Create;
      kmdmlist.Add(qryTMP.fieldbyname('底稿名称').AsString + '>>' + qryTMP.fieldbyname('借贷方向').AsString);
      adgbook.fill(kmdmlist);
      excelapp.workbooks.open(axm.xmpath + '\' + qryTMP.fieldbyname('底稿名称').AsString);
    end
    else
    begin
      showmessage('未发现对应底稿');
    end;
  finally
    //    excelapp.quit;
    //    excelapp.UnSigned;

  end;

end;

procedure Tfrmpzh.btn8Click(Sender: TObject);
var
  aform: Tfmopendw;
  ausername, apassword, filename: string;
begin
  try
    AXM := adgsystem.OPENLAST;
    aform := Tfmopendw.Create(nil);
    aform.ShowModal;

    adgbook.xm := axm;

    fxmid := axm.xmid;
    lblid.Caption := axm.xmid;
    lblname.Caption := axm.xmname;

    if xmcon = nil then
      xmcon := TADOConnection.Create(nil);

    try
      if xmcon.Connected = true then
        xmcon.Connected := false;
    except
    end;

    xmcon := adgbook.connection;

    xmcon.LoginPrompt := false;
    xmcon.Connected := true;

    qrykmb.Connection := xmcon;
    qryONEpz.Connection := xmcon;
    qrymxlist.Connection := xmcon;
    qrypzb.Connection := xmcon;
    qryTMP.Connection := xmcon;
    //  tbdw.Connection := xmcon;

    if axm.kmlen < 1 then
    begin
      qrykmb.Close;
      qrykmb.SQL.Clear;
      qrykmb.SQL.Add('select min(len(代码)) as zdlen from dg7 ');
      qrykmb.SQL.Add(' WHERE xmid=''' + trim(axm.xmid) + '''');
      qrykmb.open;
      axm.kmlen := qrykmb.fieldbyname('zdlen').AsInteger;
      ADGSYSTEM.writetomdb_kmlen(axm);
      qrykmb.close;
    end;

    try
      fllst1.Directory := axm.xmpath;
    except
    end;

    qrykmb.Close;
    qrykmb.SQL.Clear;
    qrykmb.SQL.Add('select * from dg7 where   (trim(核算项目名称)="" or (核算项目名称 is null) ) and (xmid=''' + fxmid
      +
      ''') and len(代码)=' + inttostr(axm.kmlen) + ' order by 代码');
    qrykmb.Open;
    qrykmb.First;
    ejunkmyeb.Activate(true);

    pgc1.ActivePageIndex := 0;
    main_detail(True);

    pgc1.ActivePageIndex := 0;
    pgc2.ActivePageIndex := 0;
    rb1.Checked := true;

    if tbdw.Active then
      tbdw.Close;

    tbdw.TableName := '底稿单位';
    tbdw.Open;
    tbdw.Filtered := false;
    tbdw.Filter := 'xmid=''' + fxmid + '''';
    tbdw.Filtered := True;
    try
      mmo1.Lines.Clear;
      mmo1.Lines.Add(tbdw.FieldByName('项目备注').AsString);
    except
    end;
    tbdw.Close;

  except
    aform.Close;
    aform.free;
    aform := nil;
  end;

end;

procedure Tfrmpzh.N3Click(Sender: TObject);
var
  aform: Tfmxmgl;
begin
  //
  aform := Tfmxmgl.Create(nil);
  aform.ShowModal;

end;

procedure Tfrmpzh.btndgfalseClick(Sender: TObject);
begin
  //

  ShowMessage('非注册版，不能生成底稿，请联系QQ:179930269注册！');
end;

procedure Tfrmpzh.btn7Click(Sender: TObject);
begin
  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('select * from 凭证表  where  全凭证号 IN ');
  qrypzb.sql.Add(' (select 全凭证号  from 凭证表 where  (xmid=''' + fxmid + ''')  and  科目编码 like '''
    + Trim(qrymxlist.fieldbyname('代码').asstring) + '%''  and 借方<>0 )  and  (xmid=''' + fxmid +
    ''')  order by 全凭证号 ');
  qrypzb.open;
  qrypzb.First;
end;

procedure Tfrmpzh.btn9Click(Sender: TObject);
begin
  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('select * from 凭证表  where  全凭证号 IN ');
  qrypzb.sql.Add(' (select 全凭证号  from 凭证表 where  (xmid=''' + fxmid + ''')  and  科目编码 like '''
    + Trim(qrymxlist.fieldbyname('代码').asstring) + '%''  and 贷方<>0)  and  (xmid=''' + fxmid +
    ''')  order by 全凭证号 ');
  qrypzb.open;
  qrypzb.First;
end;

procedure Tfrmpzh.fllst1DblClick(Sender: TObject);
begin
//
  ShellExecute(0, 'open', PChar(fllst1.FileName), 'C:\Windows', nil, 1);
end;

end.

