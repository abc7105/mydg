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

  STEXT := 'select * from ƾ֤��  where  (fitnum<>"������" ) and xjpz=true  ' +
    'order by ȫƾ֤��,fitnum';
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
  qryQRYonepz.sql.Add('select * from ƾ֤��  where (xmid=''' +
    trim(qrypzb.fieldbyname('xmid').asstring) + ''')  and trim(ȫƾ֤��) =''' +
    trim(qrypzb.fieldbyname('ȫƾ֤��').asstring) + '''');
  qryQRYonepz.open;
  qryQRYonepz.First;

  if qryQRYonepz.RecordCount > 6 then
    pnl7.Height := 350
  else
    pnl7.Height := 180;

  stext :=
    'ȫƾ֤��,��Ŀ����,һ������, ��Ŀ����,�ֽ�����,��Ӫ����,  �跽, ����,fitnum ,ժҪ, id,�ֽ��';
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
    if (ejunpzall.DATAColumns.Items[i - 1].FieldName = '�ֽ�����') or
      (ejunpzall.DATAColumns.Items[i - 1].FieldName = '��Ӫ����') then
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
  qrypzb.sql.Add('update  ƾ֤��  set �ֽ��=false  where xmid=''' + fxmid +
    '''');
  qrypzb.ExecSQL;

  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('update  ƾ֤��  set �ֽ��=true  where xmid=''' + fxmid +
    '''  and һ������="1001"');
  qrypzb.ExecSQL;

  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('update  ƾ֤��  set �ֽ��=true  where xmid=''' + fxmid +
    ''' and һ������="1002"');
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
  qrytmp.sql.Add('update �ֽ���������Ŀ a');
  qrytmp.sql.Add(' set a.���=0 '); // where (xmid=''' + fxmid + ''') ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.sql.Add('DELETE FROM  XYZ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.sql.Add(' INSERT INTO XYZ(PZH,JE)');
  qrytmp.sql.Add(' select max(�ֽ�����) as PZH,SUM(�跽)-SUM(����) as JE');
  qrytmp.sql.Add(' from ƾ֤��    where xjpz=true and trim(fitnum)<>"������"');
  qrytmp.sql.Add(' group by �ֽ�����');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.sql.Add(' update �ֽ���������Ŀ a,XYZ B');
  qrytmp.sql.Add(' set a.���=-b.JE');
  qrytmp.sql.Add(' where  TRIM(a.�ֽ��������)=TRIM(b.PZH)  and INSTR("ACE",A.��ʶ)>0');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.sql.Add('update �ֽ���������Ŀ a,XYZ B');
  qrytmp.sql.Add(' set a.���=b.JE');
  qrytmp.sql.Add(' where  TRIM(a.�ֽ��������)=TRIM(b.PZH) and INSTR("BDF",A.��ʶ)>0');
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
    if Pos('С��', qrycashsheet.fieldbyname('�ֽ�������Ŀ').AsString) > 0 then
    begin
      qrycashsheet.edit;
      qrycashsheet.fieldbyname('���').asfloat := asum;
      qrycashsheet.post;

      if i = 0 then
      begin
        bsum := asum;
        asum := 0;
        i := i + 1;
      end;
    end
    else if Pos('�ֽ���������',
      qrycashsheet.fieldbyname('�ֽ�������Ŀ').AsString) > 0 then
    begin
      qrycashsheet.edit;
      qrycashsheet.fieldbyname('���').asfloat := bsum - asum;
      qrycashsheet.post;
      //   bsum :=
      asum := 0;
      bsum := 0;
      i := 0;
    end
    else
      asum := asum + qrycashsheet.fieldbyname('���').asfloat;

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

  stext := '����,��Ŀ����, �������,�ڳ�,	�跽����,	��������,��ĩ,ID ';

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
  qrykmyeb.sql.Add('select * from dg7   where len(TRIM(����))=:lena order by ����,һ����Ŀ����');
  qrykmyeb.Parameters.ParamByName('lena').Value := firstlevel_length;
  qrykmyeb.open;
  ejunkmyeb.DataSet := qrykmyeb;
  ejunkmyeb.Active := true;
end;

procedure Tfmcash.ejunkmyebDblClick(Sender: TObject);
var
  STEXT: string;
begin

  STEXT := 'select * from ƾ֤��  where  ' +        // �ֽ�����<>''ok'' 
    '   trim(��Ŀ����) like "' +        //xjpz=true and
    Trim(qrykmyeb.fieldbyname('����').asstring) + '%"';
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
      qrytmp.sql.add('update ƾ֤�� set  fitnum=:FITNUM WHERE ID=:ID');
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

  //�����
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

  //  if trim(pz[sxh].km) = '1899_ 12_����340.0000' then
  //    showmessage(floattostr(pz[sxh].df) + '��');

    //������
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
            //   if trim(pz[sxh].km) = '1899_ 12_����340.0000' then
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

  //  if trim(pz[sxh].km) = '1899_ 12_����340.0000' then
  //    showmessage(floattostr(pz[sxh].df) + '��');

    //������
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

  //if trim(pz[sxh].km) = '1899_ 12_����340.0000' then
//    showmessage(floattostr(pz[sxh].df) + 'ȫ��');
  //  //   ȫ����
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
  //   �ֽ�ϼ�������
  //�跽�ϼ��Ҵ���
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

        pz[cc].fitnum := 'OK�跽';
        for dd := 1 to 500 do
        begin
          if pz[dd].km = 'over' then
            break;

          if (pz[dd].iscash) and (pz[dd].FITNUM = '') and (pz[dd].jf <> 0) then
            pz[dd].fitnum := 'OK�跽';
        end;
        break;
      end;
    end;
  ////==========   �����ϼ��ҽ跽

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

        pz[cc].fitnum := '����OK';
        for dd := 1 to 500 do
        begin
          if pz[dd].km = 'over' then
            break;

          if (pz[dd].iscash) and (pz[dd].FITNUM = '') and (pz[dd].df <> 0) then
            pz[dd].fitnum := '����OK';
        end;
        break;
      end;
    end;

  //�����ϼ����ֽ�****************************
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
        pz[cc].fitnum := 'OK�����ϼƽ跽';
        for dd := 1 to 500 do
        begin
          if pz[dd].km = 'over' then
            break;

          if (not pz[dd].iscash) and (pz[dd].FITNUM = '') and (pz[dd].jf <> 0)
            then
            pz[dd].fitnum := 'OK�����ϼƽ跽';
        end;
        break;
      end;
    end;
  ////==========   �����ϼ��ҽ跽

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

        pz[cc].fitnum := '�����ϼƴ���OK';
        for dd := 1 to 500 do
        begin
          if pz[dd].km = 'over' then
            break;

          if (not pz[dd].iscash) and (pz[dd].FITNUM = '') and (pz[dd].df <> 0)
            then
            pz[dd].fitnum := '�����ϼƴ���OK';
        end;
        break;
      end;
    end;
  //�����ֽ���������Ŀȫ����Ϊ�ֽ�����

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
          pz[dd].FITNUM := 'OK��ƽ����'
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
  //  qrytmp.SQL.Add(' delete from  ƾ֤��  where trim(ȫƾ֤��)<>"2016_ 1_��121"');
  //  qrytmp.ExecSQL;

  //  qrytmp.Close;
  //  qrytmp.SQL.Clear;
  //  qrytmp.SQL.Add(' delete from  ƾ֤�� ');
  //  qrytmp.ExecSQL;
  //
  //  qrytmp.Close;
  //  qrytmp.SQL.Clear;
  //  qrytmp.SQL.Add(' insert into ƾ֤�� select *  from  ƾ֤��1');
  //  qrytmp.ExecSQL;

  see_allpz;
  cash_complete_ok_;
  cashfx_tableLOOP;
  cashfx_other_ok;
  pzb_calc_onlycash_at_aSide;
  cashpzb_add_blankline;

  lena := firstlevel_length;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update dg7 set һ����Ŀ����=left(����,:lena) ');
  qrytmp.Parameters.ParamByName('lena').Value := lena;
  qrytmp.ExecSQL;

  try
    qrytmp.SQL.Clear;
    qrytmp.SQL.Add(' DROP view  dg7A  ');
    qrytmp.ExecSQL;
  except
  end;

  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' create view  dg7A  AS select ����,��Ŀ���� from dg7  ' +
    ' where len(trim(����))=' + inttostr(lena));
  qrytmp.ExecSQL;

  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update dg7 A , dg7A B  set a.һ����Ŀ����=B.��Ŀ���� where a.һ����Ŀ����=B.���� ');
  qrytmp.ExecSQL;

  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update ƾ֤�� A,�ֽ��������Ӧ B  set A.�ֽ�����=B.�ֽ�������� ');
  qrytmp.SQL.Add(' where  A.һ������=B.�Է���Ŀ');
  qrytmp.ExecSQL;

  STEXT := 'select * from ƾ֤��  where  xjpz=true  ' +
    'order by ȫƾ֤��,fitnum';
  ejunpzb_refresh(stext);
  ShowMessage('����ƾ֤��ʼ����ϣ����Խ��к����ֽ�����������');

end;

procedure Tfmcash.dofx;
begin
  //
  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update ƾ֤�� a,�ֽ��������Ӧ    b');
  qrytmp.SQL.Add(' set a.�ֽ�����=b.�ֽ�������� ,a.��Ӫ����=trim(b.����) ');
  qrytmp.SQL.Add('where trim(a.һ������)=trim(b.�Է���Ŀ)  and (TRIM(b.������Ŀ)="" OR (b.������Ŀ IS NULL) )');
  qrytmp.SQL.Add('  and (a.fitnum<>"") ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update ƾ֤�� a, �ֽ��������Ӧ  b');
  qrytmp.SQL.Add(' set a.�ֽ�����=b.�ֽ��������,a.��Ӫ����=trim(b.���� )');
  qrytmp.SQL.Add(' where trim(a.һ������)=trim(b.�Է���Ŀ) and  trim(a.��Ŀ����)=trim(b.������Ŀ) ');
  qrytmp.SQL.Add('  and (trim(a.fitnum)<>"" )  and (TRIM(b.������Ŀ)<>"") ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update ƾ֤�� a');
  qrytmp.SQL.Add(' set a.�ֽ�����=''XX''');
  qrytmp.SQL.Add(' WHERE �ֽ��');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update ƾ֤�� a');
  qrytmp.SQL.Add(' set a.�ֽ�����=''������''');
  qrytmp.SQL.Add(' WHERE fitnum=''������''');
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

  STEXT := 'select * from ƾ֤��  where  xjpz=true  ' +
    'order by ȫƾ֤��,fitnum';
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
  STEXT := 'select * from ƾ֤��  where  (fitnum<>"������" ) and xjpz=true  ' +
    'order by ȫƾ֤��,fitnum';
  ejunpzb_refresh(stext);
  *)
  see_allpz;

end;

procedure Tfmcash.cashFX_pzb_reset;
begin
  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update ƾ֤�� set  fitnum='''',�ж�����=''''');
  qrytmp.ExecSQL;

end;

procedure Tfmcash.cashfx_tableLOOP;
var
  newpzh: string;
  oldpzh: string;
  i: integer;
begin
  tbcalccash.Connection := con1;
  tbcalccash.TableName := 'ƾ֤��';

  tbcalccash.Open;
  tbcalccash.Filtered := false;
  tbcalccash.Filter := '�ж�����=''''';
  tbcalccash.Filtered := true;

  tbcalccash.Sort := 'ȫƾ֤��';

  tbcalccash.First;
  oldpzh := '';
  i := 0;

  while not tbcalccash.Eof do
  begin
    newpzh := tbcalccash.fieldbyname('ȫƾ֤��').asstring;
    if newpzh = oldpzh then //������ƾ֤
    begin
      i := i + 1;
      pz[i].km := tbcalccash.fieldbyname('ȫƾ֤��').asstring;
      pz[i].jf := tbcalccash.fieldbyname('�跽').asfloat;
      pz[i].df := tbcalccash.fieldbyname('����').asfloat;
      pz[i].iscash := tbcalccash.fieldbyname('�ֽ��').asboolean;
      pz[i].ID := tbcalccash.fieldbyname('ID').ASINTEGER;
      pz[i].cashtype := '';
    end
    else
    begin //����ƾ֤
      //�ȴ�����ƾ֤��
      i := i + 1;
      pz[i].km := 'over';
      calcfit();
      UPDATRARR;
      //��ʼ��ƾ֤
      cleararr;
      oldpzh := newpzh;
      i := 1;
      pz[i].km := tbcalccash.fieldbyname('ȫƾ֤��').asstring;
      pz[i].jf := tbcalccash.fieldbyname('�跽').asfloat;
      pz[i].df := tbcalccash.fieldbyname('����').asfloat;
      pz[i].iscash := tbcalccash.fieldbyname('�ֽ��').asboolean;
      pz[i].cashtype := '';
      pz[i].ID := tbcalccash.fieldbyname('ID').ASINTEGER;

      if i > 500 then
        showmessage('ERR:����ƾ֤��500�У����ܴ���');
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
  qrytmp.sql.add('insert into  xjcount  select distinct ȫƾ֤�� as ƾ֤�� ,һ������ as һ������ from ƾ֤�� ');
  qrytmp.sql.add(' where �ֽ��=true and �跽<>0 and xjpz');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('delete from   xjcount  where  ƾ֤�� in ');
  qrytmp.sql.add('(select ȫƾ֤�� from ƾ֤��  where �ֽ��<>true and �跽<>0 and xjpz)');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update ƾ֤�� A set A.fitnum=''OKall'' WHERE  A.ȫƾ֤�� IN (SELECT ƾ֤�� FROM xjcount) ');
  qrytmp.ExecSQL;

  //==============     ��������ֻ���ֽ��Ŀ
  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('delete from   xjcount   ');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('insert into  xjcount  select distinct ȫƾ֤�� as ƾ֤�� ,һ������ as һ������ from ƾ֤��');
  qrytmp.sql.add(' where �ֽ��=true and ����<>0 and xjpz');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('delete from   xjcount  where  ƾ֤�� in ');
  qrytmp.sql.add('(select ȫƾ֤�� from ƾ֤��  where �ֽ��<>true and ����<>0 and xjpz)');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update ƾ֤�� A set A.fitnum=''OKall'' WHERE  A.ȫƾ֤�� IN (SELECT ƾ֤�� FROM xjcount) ');
  qrytmp.ExecSQL;

  //===ȫ������
  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update ƾ֤�� A set A.fitnum=''ALLNO'' WHERE NOT  xjpz=true');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update  ƾ֤��  set  �ж�����=''1'' where trim(fitnum)<>'''' ');
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
  //���㲻�����ֽ����ͬһƾ֤�����ȵĿ�Ŀ��Ȼ�����XJCOUNT,�����Ŀ���ֽ�����
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
  qrytmp.sql.add('create view cashother as select  max(ȫƾ֤��) as ƾ֤��,max(һ������) as һ������,');
  qrytmp.sql.add(' sum(�跽) as ��,sum(����) as �� from ƾ֤��  ');
  qrytmp.sql.add(' where not �ֽ�� and (trim(fitnum)='''' or trim(fitnum)="OK��ƽ����"  and xjpz) group by ȫƾ֤��,һ������ ');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('delete from xjcount  ');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('insert into  xjcount  select  ƾ֤�� ,һ������  from cashother where ��=��  ');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update ƾ֤�� A ,XJCOUNT b set A.fitnum=''������'' ');
  qrytmp.sql.add(' WHERE  A.ȫƾ֤��=B.ƾ֤�� and a.һ������=b.һ������ and (trim(fitnum)='''' or trim(fitnum)="OK��ƽ����" ) ');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update ƾ֤��  set fitnum=''������'' ');
  qrytmp.sql.add(' WHERE trim(fitnum)=""  and xjpz=true');
  qrytmp.ExecSQL;

end;

procedure Tfmcash.cashpzb_add_blankline;
begin
  // TODO -cMM: Tfmcash.cashpzb_add_blankline default body inserted

  try
    qrytmp.CLOSE;
    qrytmp.SQL.Clear;
    qrytmp.SQL.Add('DELETE  from ƾ֤�� WHERE len(TRIM(��Ŀ����))=0  ');
    qrytmp.execsql;

    qrytmp.CLOSE;
    qrytmp.SQL.Clear;
    qrytmp.SQL.Add('DELETE  from ƾ֤�� WHERE (�跽 is null) and (���� is null) ');
    qrytmp.execsql;

  except
  end;

  qrytmp.Close;
  qrytmp.sql.Clear;
  qrytmp.SQL.Add('delete from  ƾ֤�� where (��Ŀ���� is null) or (trim(��Ŀ����)="") ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.sql.Clear;
  qrytmp.SQL.Add('insert into ƾ֤��(ȫƾ֤��) ');
  qrytmp.SQL.Add(' select  max(ȫƾ֤��) from ƾ֤�� ');
  qrytmp.SQL.Add(' where xjpz=true group by ȫƾ֤��');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.sql.Clear;
  qrytmp.SQL.Add('update ƾ֤�� set xjpz=true,fitnum="" ');
  qrytmp.SQL.Add(' where (��Ŀ���� is null) or (trim(��Ŀ����)="") ');
  qrytmp.ExecSQL;

end;

procedure Tfmcash.eachcashxm_mx_pzb;
var
  stext: string;
begin
  try
    STEXT := 'select * from ƾ֤��  where   xjpz=true AND trim(�ֽ�����)=''' +
      qrycashsheet.fieldbyname('�ֽ��������').asstring + '''' +
      'order by һ������,��Ŀ����,fitnum';
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
    'ȫƾ֤��,��Ŀ����,һ������, ��Ŀ����,�ֽ�����,��Ӫ����,  �跽, ����,fitnum ,ժҪ, id,�ֽ��';
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
    if (ejunpzall.DATAColumns.Items[i - 1].FieldName = '�ֽ�����') or
      (ejunpzall.DATAColumns.Items[i - 1].FieldName = '��Ӫ����') then
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
  STEXT := 'select * from ƾ֤��  where  (fitnum<>"" ) and xjpz=true  ' +
    'order by ȫƾ֤��,fitnum';
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
    ejunpzall.SaveToExcel(FILENAMEXLS, '�ֽ�ƾ֤', true, false);
    OPENCASHSHEET;
    ejuncashsheet.SaveToExcel(FILENAMEXLS2, '�ֽ�������', true, false);

    mymessage('�����ɹ�!');
    Close;
    ShellExecute(Handle, 'open', PChar(FILENAMEXLS), 'C:\Windows', nil, 1);
  end
  else
  begin
    mymessage('ȡ������!');
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
  qrytmp.sql.add('UPDATE ƾ֤�� set xjpz=false ');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('UPDATE ƾ֤�� set xjpz=true where  (ȫƾ֤�� IN (SELECT ȫƾ֤�� FROM ƾ֤�� where  �ֽ�� ))');
  qrytmp.ExecSQL;
end;

procedure Tfmcash.opencashcalcsheet;
begin
  { TODO : ����ƾ֤����ֽ����� }
  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('create view cashcalctable  as ');
  qrytmp.sql.add(' select 0  as id,max(�ֽ���������) as �ֽ��������� ,max(�ֽ��������) as �ֽ��������,sum(���) as ���,"" AS ��ʶ  ');
  qrytmp.sql.add('   FROM ƾ֤��');
  qrytmp.sql.add(' group by �ֽ��������� ');
  qrytmp.sql.add(' union  ');
  qrytmp.sql.add(' select id,�ֽ��������� �ֽ��������, ���, ��ʶ  ');
  qrytmp.sql.add('   FROM �ֽ���������Ŀ');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update �ֽ���������Ŀ set �Ƿ�ԭʼ=true');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('insert into �ֽ���������Ŀ(id,�ֽ���������, �ֽ��������, ���, ��ʶ)');
  qrytmp.sql.add(' select max( id),max(�ֽ���������),max( �ֽ��������), sum(���),max( ��ʶ)  ');
  qrytmp.sql.add('   FROM cashcalctable');
  qrytmp.sql.add(' group by �ֽ��������� ');
  qrytmp.sql.add(' order  by id ');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('delete from  �ֽ���������Ŀ where �Ƿ�ԭʼ=true');
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
    qrycashsheet.TableName := '�ֽ���������Ŀ';
    qrycashsheet.open;
  end
  else
  begin
    qrycashsheet.Close;
    qrycashsheet.TableName := '�ֽ���������Ŀ';
    qrycashsheet.open;
  end;

  stext := '�ֽ�������Ŀ	,��� ,�ֽ��������,	ID	,	��ʶ ';
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
  qrytmp.sql.add('select sum(�ڳ�) as QC FROM DG7 WHERE IS�ֽ�');
  qrytmp.open;

  if QRYTMP.RECORDCOUNT > 0 then
  begin
    QCQM := QRYTMP.FIELDBYNAME('QC').ASFLOAT;

    qrytmp.close;
    qrytmp.sql.clear;
    qrytmp.sql.add('UPDATE �ֽ���������Ŀ set ���=:JE WHERE trim(�ֽ�������Ŀ)="��:�ڳ��ֽ��ֽ�ȼ������"');
    qrytmp.Parameters.ParamByName('JE').value := QCQM;
    qrytmp.ExecSQL;
  end;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('select sum(��ĩ) as QC FROM DG7 WHERE IS�ֽ�');
  qrytmp.open;

  if QRYTMP.RECORDCOUNT > 0 then
  begin
    QCQM := QRYTMP.FIELDBYNAME('QC').ASFLOAT;
    qrytmp.close;
    qrytmp.sql.clear;
    qrytmp.sql.add('UPDATE �ֽ���������Ŀ set ���=:JE WHERE trim(�ֽ�������Ŀ)="������ĩ�ֽ��ֽ�ȼ������"');
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
  qrytmp.sql.add('select sum(���) as QC FROM �ֽ���������Ŀ WHERE INSTR(�ֽ�������Ŀ,"����")>0');
  qrytmp.open;

  if QRYTMP.RECORDCOUNT > 0 then
  begin
    QCQM := QRYTMP.FIELDBYNAME('QC').ASFLOAT;
    qrytmp.close;
    qrytmp.sql.clear;
    qrytmp.sql.add('UPDATE �ֽ���������Ŀ set ���=:JE WHERE trim(�ֽ�������Ŀ)="�塢�ֽ��ֽ�ȼ��ﾻ���Ӷ�"');
    qrytmp.Parameters.ParamByName('JE').value := QCQM;
    qrytmp.ExecSQL;
  end;

  a1 := qcqm;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('select sum(���) as QC FROM �ֽ���������Ŀ WHERE trim(�ֽ�������Ŀ)="��:�ڳ��ֽ��ֽ�ȼ������"');
  qrytmp.open;

  if QRYTMP.RECORDCOUNT > 0 then
    a2 := QRYTMP.FIELDBYNAME('QC').ASFLOAT;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('select sum(���) as QC FROM �ֽ���������Ŀ WHERE trim(�ֽ�������Ŀ)="������ĩ�ֽ��ֽ�ȼ������"');
  qrytmp.open;

  if QRYTMP.RECORDCOUNT > 0 then
    a3 := QRYTMP.FIELDBYNAME('QC').ASFLOAT;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('UPDATE �ֽ���������Ŀ set ���=:JE WHERE INSTR(�ֽ�������Ŀ,"====")>0');
  qrytmp.Parameters.ParamByName('JE').value := a1 + a2 - a3;
  qrytmp.ExecSQL;

end;

function Tfmcash.firstlevel_length: integer;
begin
  result := 4;

  try
    qrytmp.CLOSE;
    qrytmp.SQL.Clear;
    qrytmp.SQL.Add('select min(len(TRIM(��Ŀ����))) as һ����Ŀ���� from ƾ֤�� where trim(��Ŀ����)<>""');
    qrytmp.open;
    result := qrytmp.fieldbyname('һ����Ŀ����').ASINTEGER;
  except
  end;
end;

procedure Tfmcash.OnlySee_Pzb_flatdata;
var
  stext: string;
begin
  // TODO -cMM: Tfmcash.OnlySee_Pzb_flatdata default body inserted
  STEXT := 'select * from ƾ֤��  where   ' +
    ' ȫƾ֤�� in (select distinct ȫƾ֤�� from ƾ֤�� where fitnum="OK��ƽ����" )' +
    ' and (fitnum="OK��ƽ����" or trim(fitnum)="" or (fitnum is null))  order by ȫƾ֤��,fitnum ';
  ejunpzb_refresh(stext);

end;

procedure Tfmcash.pzb_calc_onlycash_at_aSide;
begin
  // TODO -cMM: Tfmcash.pzb_calc_onlycash_at_aSide default body inserted
  //==�跽����ֻ���ֽ��Ŀ
  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('delete from   xjcount   ');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('insert into  xjcount  select distinct ȫƾ֤�� as ƾ֤�� ,һ������ as һ������ from ƾ֤�� ');
  qrytmp.sql.add(' where �ֽ��=true and �跽<>0 and trim(fitnum)="OK��ƽ����"');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('delete from   xjcount  where  ƾ֤�� in ');
  qrytmp.sql.add('(select ȫƾ֤�� from ƾ֤��  where �ֽ��<>true and �跽<>0 and trim(fitnum)="OK��ƽ����")');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update ƾ֤�� A set A.fitnum=''OKall'' WHERE  A.ȫƾ֤�� IN (SELECT ƾ֤�� FROM xjcount) and  trim(a.fitnum)="OK��ƽ����" ');
  qrytmp.ExecSQL;

  //==============     ��������ֻ���ֽ��Ŀ
  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('delete from   xjcount   ');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('insert into  xjcount  select distinct ȫƾ֤�� as ƾ֤�� ,һ������ as һ������ from ƾ֤��');
  qrytmp.sql.add(' where �ֽ��=true and ����<>0 and trim(fitnum)="OK��ƽ����"');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('delete from   xjcount  where  ƾ֤�� in ');
  qrytmp.sql.add('(select ȫƾ֤�� from ƾ֤��  where �ֽ��<>true and ����<>0 and trim(fitnum)="OK��ƽ����")');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update ƾ֤�� A set A.fitnum=''OKall'' WHERE  A.ȫƾ֤�� IN (SELECT ƾ֤�� FROM xjcount ) and  trim(a.fitnum)="OK��ƽ����" ');
  qrytmp.ExecSQL;

  //==============     ��������ֻ���ֽ��Ŀ

end;

procedure Tfmcash.see_allpz;
var
  stext: string;
begin
  STEXT := 'select * from ƾ֤��  where ( not trim(fitnum)="������" ) and xjpz=true  '
    //
  + ' order by ȫƾ֤��,fitnum';
  ejunpzb_refresh(stext);
end;

end.

