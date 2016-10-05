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
  tbcashsheet.TableName := '�ֽ���������Ŀ';

end;
//================��

procedure Tfmcash.openpzsheet;
var
  STRLIST: tstringlist;
  stext: string;
  i: Integer;
begin
  //
  stext :=
    'ȫƾ֤��,һ������,��Ŀ����, ��Ŀ����, ժҪ, �跽, ����,fitnum ,�ֽ�����,��Ӫ����, �Է���Ŀ,�ж�����,id,�ֽ��';
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
  qrypzb.sql.Add('select * from ƾ֤��  where xjpz=true');
  qrypzb.open;
  qrypzb.First;

  showint(qrypzb.RecordCount);

  for I := 0 to qrypzb.Fields.Count - 1 do
  begin
    if (qrypzb.Fields[i].Name <> '�ֽ�����') and (qrypzb.Fields[i].Name <>
      '��Ӫ����') then
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
    'ȫƾ֤��,һ������,��Ŀ����, ��Ŀ����, ժҪ, �跽, ����,fitnum ,�ֽ�����,��Ӫ����, �Է���Ŀ,�ж�����,id,�ֽ��';
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
  qryQRYonepz.sql.Add('select * from ƾ֤��  where (xmid=''' +
    trim(qrypzb.fieldbyname('xmid').asstring) +
    ''')  and trim(ȫƾ֤��) ='''
    + trim(qrypzb.fieldbyname('ȫƾ֤��').asstring) + '''');
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
  //    '�ֽ�����, �跽 ,����';
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
  //  qrycash.sql.Add('select max(�ֽ�����) as �ֽ�����,SUM(�跽) as �跽 ,SUM(����) as ����');
  //  qrycash.sql.Add(' from ƾ֤��    where (xmid=''' + trim(fxmid) +
  //    ''')  and �ֽ��');
  //  qrycash.sql.Add(' group by �ֽ����� ');
  //  qrycash.open;
  //  qrycash.first;

end;

procedure Tfmcash.ejunbankDblClick(Sender: TObject);
begin
  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('select * from ƾ֤��  where (xmid=''' + fxmid +
    ''')  and trim(ȫƾ֤��) = '''
    + trim(qrybank.fieldbyname('ƾ֤��').asstring) + '''  ');
  qrypzb.open;
  qrypzb.First;
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

  //  qrypzb.Close;
  //  qrypzb.SQL.Clear;
  //  qrypzb.sql.Add('update  ƾ֤��  set �ֽ��=true  where xmid=''' + fxmid +
  //    ''' and һ������="1003"');
  //  qrypzb.ExecSQL;

end;

procedure Tfmcash.ejun1DblClick(Sender: TObject);
begin
  //
  qrypzb.Edit;
  //qrypzb.FieldByName('�ֽ�����').AsString :=
//    tb2.fieldbyname('�ֽ��������').AsString;
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
    '�ֽ�������Ŀ	,��� ,�ֽ��������,	ID	,	��ʶ ';
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
  qrytmp.sql.Add('update �ֽ���������Ŀ a');
  qrytmp.sql.Add(' set a.���=0 '); // where (xmid=''' + fxmid + ''') ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.sql.Add('DELETE FROM  XYZ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.sql.Add('INSERT INTO XYZ(PZH,JE)');
  qrytmp.sql.Add('select max(�ֽ�����) as PZH,SUM(�跽)-SUM(����) as JE');
  qrytmp.sql.Add(' from ƾ֤��    where  �ֽ��');
  qrytmp.sql.Add(' group by �ֽ�����');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.sql.Add('update �ֽ���������Ŀ a,XYZ B');
  qrytmp.sql.Add(' set a.���=b.JE');
  qrytmp.sql.Add(' where  TRIM(a.�ֽ��������)=TRIM(b.PZH)  and INSTR("ACE",A.��ʶ)>0');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.sql.Add('update �ֽ���������Ŀ a,XYZ B');
  qrytmp.sql.Add(' set a.���=-b.JE');
  qrytmp.sql.Add(' where  TRIM(a.�ֽ��������)=TRIM(b.PZH) and INSTR("BDF",A.��ʶ)>0');
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
    if Pos('С��', tbCASHSHEET.fieldbyname('�ֽ�������Ŀ').AsString) > 0 then
    begin
      tbCASHSHEET.edit;
      tbCASHSHEET.fieldbyname('���').asfloat := asum;
      tbCASHSHEET.post;

      if i = 0 then
      begin
        bsum := asum;
        asum := 0;
        i := i + 1;
      end;
    end
    else if Pos('�ֽ���������', tbCASHSHEET.fieldbyname('�ֽ�������Ŀ').AsString)
      > 0 then
    begin
      tbCASHSHEET.edit;
      tbCASHSHEET.fieldbyname('���').asfloat := bsum - asum;
      tbCASHSHEET.post;
      //   bsum :=
      asum := 0;
      bsum := 0;
      i := 0;
    end
    else
      asum := asum + tbCASHSHEET.fieldbyname('���').asfloat;

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
  qrykmyeb.sql.Add('select * from dg7  order by ����,һ����Ŀ����,����');
  qrykmyeb.open;
  ejunkmyeb.DataSet := qrykmyeb;
  ejunkmyeb.Active := true;
end;

procedure Tfmcash.ejunkmyebDblClick(Sender: TObject);
begin

  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('select * from ƾ֤��  where �ֽ�� and �ֽ�����<>''ok''   and ȫƾ֤�� in ');
  qrypzb.sql.Add('(select ȫƾ֤�� from ƾ֤��  where  ��Ŀ���� like :dm )');
  qrypzb.Parameters.ParamByName('dm').value :=
    qrykmyeb.fieldbyname('����').asstring + '%';
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

  //  qrypzb.FieldByName('�ֽ�����').AsString := listbox1.Items[listbox1.ItemIndex];
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

  //�����
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
  qrytmp.SQL.Add(' update ƾ֤�� a,�ֽ��������Ӧ    b');
  qrytmp.SQL.Add(' set a.�ֽ�����=b.�ֽ�������� ,a.��Ӫ����=trim(b.����) ');
  qrytmp.SQL.Add('where trim(a.һ������)=trim(b.�Է���Ŀ)  and (TRIM(b.ժҪ�ؼ���)="" OR (b.ժҪ�ؼ��� IS NULL) )');
  qrytmp.SQL.Add('  and (a.fitnum<>"") ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  //  qrytmp.Connection := con1;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update ƾ֤�� a, �ֽ��������Ӧ  b');
  qrytmp.SQL.Add(' set a.�ֽ�����=b.�ֽ��������,a.��Ӫ����=trim(b.���� )');
  qrytmp.SQL.Add(' where trim(a.һ������)=trim(b.�Է���Ŀ) and  trim(a.��Ŀ����)=trim(b.ժҪ�ؼ���) ');
  qrytmp.SQL.Add('  and (trim(a.fitnum)<>"" )  and (TRIM(b.ժҪ�ؼ���)<>"") ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  //  qrytmp.Connection := con1;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update ƾ֤�� a');
  qrytmp.SQL.Add(' set a.�ֽ�����=''XX''');
  qrytmp.SQL.Add(' WHERE �ֽ��');
  qrytmp.ExecSQL;

  qrytmp.Close;
  //  qrytmp.Connection := con1;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update ƾ֤�� a');
  qrytmp.SQL.Add(' set a.�ֽ�����=''N/A''');
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
    'ȫƾ֤��,��Ŀ����,һ������, ��Ŀ����,�ֽ�����,��Ӫ����,  �跽, ����,fitnum ,ժҪ, id,�ֽ��';
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
  qrypzb.sql.Add('select * from ƾ֤��  where  (fitnum<>"" ) and xjpz=true ');
  qrypzb.sql.Add('order by ȫƾ֤��');

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

    ejunpzall.SaveToExcel(FILENAMEXLS, '�ֽ���', true, false);
    mymessage('�����ɹ�!');
    Close;
    ShellExecute(Handle, 'open', PChar(FILENAMEXLS),
      'C:\Windows', nil, 1);
  end
  else
  begin
    mymessage('ȡ������!');
  end;

end;

procedure Tfmcash.cashfx_export_toexcel;
var
  FILENAMEXLS: string;
begin
  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('select * from ƾ֤��  where    ');
  qrypzb.sql.Add('where xjpz=true  order by ȫƾ֤��');

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

    ejunpzall.SaveToExcel(FILENAMEXLS, '�ֽ���', true, false);

    mymessage('�����ɹ�!');
    Close;
    ShellExecute(Handle, 'open', PChar(FILENAMEXLS),
      'C:\Windows', nil, 1);
  end
  else
  begin
    mymessage('ȡ������!');
  end;
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

procedure Tfmcash.cashpzb_display_to_ejungird;
var
  i: integer;
  STRLIST: tstringlist;
  stext: string;
begin
  stext :=
    'ȫƾ֤��,��Ŀ����,һ������, ��Ŀ����,�ֽ�����,��Ӫ����,  �跽, ����,fitnum ,ժҪ, id,�ֽ��';
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

  //����
  create_cashview_table;
  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('insert into  xjview  select  max(ȫƾ֤��) as ƾ֤��,max(�ֽ��) as �ֽ�,1 as ���� from ƾ֤�� where ����<>0  group by ȫƾ֤��,�ֽ�� ');
  qrytmp.ExecSQL;
  updatePZB_from_cashview;

  //�跽
  create_cashview_table;
  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('insert into  xjview  select  max(ȫƾ֤��) as ƾ֤��,max(�ֽ��) as �ֽ�,1 as ���� from ƾ֤�� where �跽<>0  group by ȫƾ֤��,�ֽ�� ');
  qrytmp.ExecSQL;
  updatePZB_from_cashview;

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

procedure Tfmcash.create_cashview_table;
begin
  if not tableexists(con1, 'xjview') then
  begin
    qrytmp.close;
    qrytmp.sql.clear;
    qrytmp.sql.add('create table xjview(ƾ֤�� char(40), �ֽ� bit, ���� double,��Ŀ char(7))');
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
    qrytmp.sql.add('create table xjcount(ƾ֤�� char(40),һ������ char(7))');
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
  qrytmp.sql.add('insert into  xjcount  select ƾ֤�� from xjview  where (ƾ֤�� not  in (select ƾ֤�� from xjview where �ֽ�<>true))');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update ƾ֤�� A set A.fitnum=''OKall'' WHERE  A.ȫƾ֤�� IN (SELECT ƾ֤�� FROM xjcount) ');
  qrytmp.ExecSQL;
end;

procedure Tfmcash.cashfx_other_ok;
begin
  // TODO -cMM: Tfmcash.cashfx_other_ok default body inserted
  //���㲻�����ֽ����ͬһƾ֤�����ȵĿ�Ŀ��Ȼ�����XJCOUNT,�����Ŀ���ֽ�����
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
  qrytmp.sql.add('create view cashother as select  max(ȫƾ֤��) as ƾ֤��,max(һ������) as һ������,');
  qrytmp.sql.add(' sum(�跽) as ��,sum(�跽) as �� from ƾ֤��  ');
  qrytmp.sql.add(' where not �ֽ�� and trim(fitnum)=''''   group by ȫƾ֤��,һ������ ');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('insert into  xjcount  select  ƾ֤�� ,һ������  from cashother where ��=��  ');
  qrytmp.ExecSQL;

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update ƾ֤�� A ,XJCOUNT b set A.fitnum=''N/A'' ');
  qrytmp.sql.add(' WHERE  A.ȫƾ֤��=B.ƾ֤�� and a.һ������=b.һ������  and trim(fitnum)=''''  ');
  qrytmp.ExecSQL;

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

end.

