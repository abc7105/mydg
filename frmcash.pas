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
  tbcashsheet.TableName := '�ֽ���������Ŀ';
  tbkey.Connection := con1;
  tb1.Connection := con1;
  tb2.Connection := con1;

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

  begin
    qrypzb.Close;
    qrypzb.SQL.Clear;
    qrypzb.sql.Add('select * from ƾ֤��  where trim(��Ŀ����) like '''
      + '100%' + '''');
    qrypzb.open;
    qrypzb.First;
  end;

  for I := 0 to qrypzb.Fields.Count - 1 do
  begin
    if (qrypzb.Fields[i].Name <> '�ֽ�����') and (qrypzb.Fields[i].Name <>
      '��Ӫ����') then
      qrypzb.Fields[i].ReadOnly := true;
  end;

  //=============���µ���ƾ֤

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

  tbdw.TableName := '�׸嵥λ';
  tbdw.Open;
  tbdw.Filtered := false;
  tbdw.Filter := 'xmid=''' + fxmid + '''';
  tbdw.Filtered := True;
  mmo1.Text := tbdw.FieldByName('��Ŀ��ע').AsString;
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
    Application.MessageBox('�������������������е��ֽ�������ԭ�еķ��ཫ�����棬��������',
    '��ע��ʾ', MB_YESNO + MB_ICONQUESTION) of
    IDYES:
      begin
        if Application.MessageBox('��YES�������������˳���',
          '��ע��ʾ', MB_YESNO + MB_ICONQUESTION) = IDYES then
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
  qrytmp.SQL.Add(' update ƾ֤�� a,dg7 b');
  qrytmp.SQL.Add(' set a.һ������=trim(b.��Ŀ����) ');
  qrytmp.SQL.Add('where a.һ������=b.���� ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update ƾ֤�� a');
  qrytmp.SQL.Add(' set a.���="��" ');
  qrytmp.SQL.Add('where �跽<>0 and not (�跽 is null) ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update ƾ֤�� a');
  qrytmp.SQL.Add(' set a.���="��" ');
  qrytmp.SQL.Add('where ����<>0 and not (���� is null) ');
  //  qrytmp.SQL.Add(' and   (xmid=''' + fxmid + ''') ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update ƾ֤�� a');
  qrytmp.SQL.Add(' set a.�ֽ�����="" ');
  //  qrytmp.SQL.Add(' where   (xmid=''' + fxmid + ''') ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update ƾ֤�� ');
  qrytmp.SQL.Add(' set ���=ABS(�跽+����) ');
  //  qrytmp.SQL.Add(' where   (xmid=''' + fxmid + ''') ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update ƾ֤�� a,(select * from �ֽ��������Ӧ where (trim(ժҪ�ؼ���)="") or  (ժҪ�ؼ��� is null))   b');
  qrytmp.SQL.Add(' set a.�ֽ�����=b.�ֽ�������� ');
  qrytmp.SQL.Add('where trim(a.�Է���Ŀ)=trim(b.�Է���Ŀ)  and  trim(a.���)=trim(b.���) and a.�ֽ��');
  //  qrytmp.SQL.Add(' and   (xmid=''' + fxmid + ''') ');
    // and �ֽ��  and b.ժҪ�ؼ���=""
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' DELETE FROM xyz');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('INSERT INTO XYZ(PZH,JE,SL) select max(ȫƾ֤��) as pzh,max(���) as je,count(*) as sl from ƾ֤��  ');
  qrytmp.SQL.Add('where ');
  qrytmp.SQL.Add('  (xmid=''' + fxmid + ''')  and �ֽ��  ');
  qrytmp.SQL.Add(' and  ( trim(�Է���Ŀ) like ''' + '%�ֽ�%' +
    '''  or  trim(�Է���Ŀ) like ''' + '%���д��%' +
    '''');
  qrytmp.SQL.Add(' or  trim(�Է���Ŀ) like ''' + '%�����ʽ�%' + '''  )');
  qrytmp.SQL.Add(' group  by ȫƾ֤��,��� ');
  qrytmp.SQL.Add(' having count(*) >=2');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update ƾ֤�� a,xyz b');
  qrytmp.SQL.Add(' set a.�ֽ�����="OK" WHERE  a.ȫƾ֤��=b.pzh  ');
  qrytmp.SQL.Add('AND  A.���=b.je  and b.sl=2');
  //  qrytmp.SQL.Add(' and   (xmid=''' + fxmid + ''') ');

  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update ƾ֤�� a,xyz b');
  qrytmp.SQL.Add(' set a.��Ӫ����="XA" WHERE  a.ȫƾ֤��=b.pzh  ');
  qrytmp.SQL.Add('AND  A.���=b.je  and b.sl>2');
  //  qrytmp.SQL.Add(' and   (xmid=''' + fxmid + ''') ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update ƾ֤�� a');
  qrytmp.SQL.Add(' set a.�ֽ�����="OK"   WHERE  a.��Ӫ����="XA"   and a.�ֽ�� ');
  qrytmp.SQL.Add('AND  (a.ժҪ like "%ת%" or  a.ժҪ like "%��%"  or a.ժҪ like "%��%") ');
  //  qrytmp.SQL.Add(' and   (xmid=''' + fxmid + ''') ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.sql.Clear;
  qrytmp.SQL.Add('delete from xyz');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.sql.Add('insert into xyz(pzh,je)');
  qrytmp.sql.Add('select max(ȫƾ֤��) as pzh,max(���) as je ');
  qrytmp.sql.Add(' from ƾ֤��    where (xmid=''' + fxmid +
    ''')  and �ֽ�����="OK"  and �ֽ��');
  qrytmp.sql.Add(' group by  ȫƾ֤��,���');
  qrytmp.sql.Add(' having (sum(�跽)-sum(����))<>0');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update ƾ֤�� a,xyz b');
  qrytmp.SQL.Add(' set a.�ֽ�����="" WHERE  a.ȫƾ֤��=b.pzh  ');
  qrytmp.SQL.Add('AND  A.���=b.je  ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update  ƾ֤�� a,');
  qrytmp.SQL.Add('(SELECT ȫƾ֤��, ����,һ������  FROM ƾ֤��  WHERE (trim(xmid)=''' + fxmid + ''')) b');
  qrytmp.SQL.Add('  set a.�ж�����=b.һ������ ');
  qrytmp.SQL.Add('where a.ȫƾ֤��=b.ȫƾ֤��');
  qrytmp.SQL.Add(' and a.�跽=b.���� and a.�ֽ��  ');
  qrytmp.SQL.Add(' and  a.�跽<>0 '); //and (trim(xmid)=''' + fxmid + ''')');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update  ƾ֤�� a,');
  qrytmp.SQL.Add('(SELECT ȫƾ֤��, �跽,һ������  FROM ƾ֤��  WHERE (trim(xmid)=''' + fxmid + ''')) b');
  qrytmp.SQL.Add('  set a.�ж�����=b.һ������   ');
  qrytmp.SQL.Add('where a.ȫƾ֤��=b.ȫƾ֤��');
  qrytmp.SQL.Add(' and a.����=b.�跽 and a.�ֽ��  ');
  qrytmp.SQL.Add(' and  a.����<>0 '); //and (trim(xmid)=''' + fxmid + ''')');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update ƾ֤�� a,�ֽ��������Ӧ  b');
  qrytmp.SQL.Add(' set a.�ֽ�����=b.�ֽ�������� ');
  qrytmp.SQL.Add('where trim(a.�ж�����)=trim(b.�Է���Ŀ)  and  trim(a.���)=trim(b.���) ');
  qrytmp.SQL.Add('  and �ֽ�� and trim(�ֽ�����)="" ');
  qrytmp.ExecSQL;

  tb1.DisableControls;
  tb1.First;
  while not tb1.Eof do
  begin
    if tb1.FieldByName('ժҪ�ؼ���').AsString <> '' then
    begin
      qrytmp.Close;
      qrytmp.SQL.Clear;
      qrytmp.SQL.Add(' update ƾ֤�� a');
      qrytmp.SQL.Add(' set a.�ֽ�����= ''' +
        tb1.fieldbyname('�ֽ��������').asstring + '''');
      qrytmp.SQL.Add('where trim(a.�Է���Ŀ) like ''%' +
        trim(tb1.fieldbyname('�Է���Ŀ').asstring) + '%''');
      qrytmp.SQL.Add(' and  trim(a.ժҪ) like ''%' +
        trim(tb1.fieldbyname('ժҪ�ؼ���').asstring) + '%''');
      qrytmp.SQL.Add(' and   (xmid=''' + fxmid + ''')  and �ֽ�� ');
      if not tb1.FieldByName('ȫ���滻').AsBoolean then
        qrytmp.SQL.Add('     and (trim(�ֽ�����)="" or �ֽ����� is null)  ');
      if tb1.fieldbyname('���').asstring <> '' then
        qrytmp.SQL.Add(' and  trim(a.���)= ''' +
          trim(trim(tb1.fieldbyname('���').asstring)) + '''');
      qrytmp.ExecSQL;
    end;
    tb1.Next;
  end;
  tb1.EnableControls;

  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.SQL.Add(' select * from ƾ֤��  ');
  qrypzb.SQL.Add('where ');
  qrypzb.SQL.Add(' �ֽ�� ');
  qrypzb.SQL.Add('order by ȫƾ֤��,���');
  qrypzb.open;

  opencashtotal;

  mymessage('�ֽ�����������ϣ�');
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
  qryQRYonepz.sql.Add('select * from ƾ֤��  where (xmid=''' + fxmid +
    ''')  and trim(ȫƾ֤��) ='''
    + trim(qrypzb.fieldbyname('ȫƾ֤��').asstring) + '''');
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
    '�ֽ�����, �跽 ,����';
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
  qrycash.sql.Add('select max(�ֽ�����) as �ֽ�����,SUM(�跽) as �跽 ,SUM(����) as ����');
  qrycash.sql.Add(' from ƾ֤��    where (xmid=''' + trim(fxmid) +
    ''')  and �ֽ��');
  qrycash.sql.Add(' group by �ֽ����� ');
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
    'ƾ֤��,�跽,���� ,��� ';
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
  qrybank.sql.Add('select max(ȫƾ֤��) as ƾ֤�� ,max(���) as ���,sum(�跽) AS �跽,sum(����) as ���� ');
  qrybank.sql.Add(' from ƾ֤��    where trim(�ֽ�����)=''' + STR +
    ''' and �ֽ��');
  qrybank.sql.Add(' group by  ȫƾ֤��');
  qrybank.open;

end;

procedure Tfmcash.ejuncashtotalDblClick(Sender: TObject);
begin

  if UpperCase(trim(qrycash.fieldbyname('�ֽ�����').asstring)) = 'OK' then
  begin
    pgc2.ActivePageIndex := 1;
    openbank('OK');
  end
  else if UpperCase(trim(qrycash.fieldbyname('�ֽ�����').asstring)) = 'X' then
  begin
    pgc2.ActivePageIndex := 1;
    openbank('X');
  end;

  if trim(qrycash.fieldbyname('�ֽ�����').asstring) = '' then
  begin
    qrypzb.Close;
    qrypzb.SQL.Clear;
    qrypzb.sql.Add('select * from ƾ֤��  where (xmid=''' + fxmid +
      ''')  and �ֽ��   and (trim(�ֽ�����)="" or �ֽ����� is null)');
    qrypzb.open;
    qrypzb.First;
  end

  else
  begin
    qrypzb.Close;
    qrypzb.SQL.Clear;
    qrypzb.sql.Add('select * from ƾ֤��  where (xmid=''' + fxmid +
      ''')  and �ֽ��  and trim(�ֽ�����) = '''
      + trim(qrycash.fieldbyname('�ֽ�����').asstring) + '''');
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

procedure Tfmcash.btn2Click(Sender: TObject);
begin
  tbdw.Open;
  tbdw.Filtered := false;
  tbdw.Filter := 'xmid=''' + fxmid + '''';
  tbdw.Filtered := True;
  tbdw.Edit;
  tbdw.FieldByName('��Ŀ��ע').AsString := mmo1.Text;
  tbdw.Post;
  tbdw.Close;
end;

procedure Tfmcash.ejun1DblClick(Sender: TObject);
begin
  //
  qrypzb.Edit;
  qrypzb.FieldByName('�ֽ�����').AsString :=
    tb2.fieldbyname('�ֽ��������').AsString;
  qrypzb.Post;
  qrypzb.Refresh;
end;

procedure Tfmcash.ejun3DblClick(Sender: TObject);
begin
  //

  if Trim(tbkey.fieldbyname('�ؼ���').asstring) <> '' then
  begin
    qrypzb.Close;
    qrypzb.SQL.Clear;
    qrypzb.sql.Add('select * from ƾ֤��  where (xmid=''' + fxmid +
      ''')  and �ֽ�� and �ֽ�����<>"ok" ');
    qrypzb.sql.Add('and ժҪ like ''%' + tbkey.fieldbyname('�ؼ���').asstring +
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

procedure Tfmcash.pgc3Change(Sender: TObject);
begin
  if pgc3.ActivePageIndex = 1 then
    openkmyeb;
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
  qrypzb.sql.Add('select * from ƾ֤��  where (xmid=''' + fxmid +
    ''')  and trim(ȫƾ֤��) ='''
    + trim(qryQRYonepz.fieldbyname('ȫƾ֤��').asstring) + '''');
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

  stext := '�ֽ�����,	����������ϸ,	���';

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
  QRYOTHER.sql.Add('select max(�ֽ�����) as �ֽ�����,max(��Ӫ����) as ����������ϸ,SUM(�跽)-sum(����) as ��� from ƾ֤��');
  QRYOTHER.sql.Add('WHERE INSTR(�ֽ�����,"����")>0');
  QRYOTHER.sql.Add('  GROUP BY �ֽ�����,��Ӫ����');
  QRYOTHER.open;
end;

procedure Tfmcash.ejunOTHERDblClick(Sender: TObject);
begin
  //

  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('select * from ƾ֤��  where (xmid=''' + fxmid +
    ''')  and �ֽ�� ');
  qrypzb.sql.Add(' and �ֽ�����=''' + qryother.fieldbyname('�ֽ�����').asstring
    +
    ''' ');
  if Trim(qryother.fieldbyname('����������ϸ').asstring) <> '' then
  begin
    qrypzb.sql.Add(' and ��Ӫ����=''' +
      qryother.fieldbyname('����������ϸ').asstring + '''');
  end
  else
    qrypzb.sql.Add(' and (trim(��Ӫ����)="" or ��Ӫ���� is  null) ');

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

  qrypzb.FieldByName('�ֽ�����').AsString := listbox1.Items[listbox1.ItemIndex];
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
        pz[j].fitnum := 'xj' + inttostr(sxh);
        pz[sxh].fitnum := 'xj' + inttostr(sxh);
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
              pz[k].fitnum := 'xj' + inttostr(sxh);
          end;
          pz[sxh].fitnum := 'xj' + inttostr(sxh);
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
              pz[k].fitnum := 'xj' + inttostr(sxh);
          end;
          pz[sxh].fitnum := 'xj' + inttostr(sxh);
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

        pz[cc].fitnum := '�跽OK';
        for dd := 1 to 500 do
        begin
          if pz[dd].km = 'over' then
            break;

          if (pz[dd].iscash) and (pz[dd].FITNUM = '') and (pz[dd].jf <> 0) then
            pz[dd].fitnum := '�跽OK';
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
        pz[cc].fitnum := '�����ϼƽ跽OK';
        for dd := 1 to 500 do
        begin
          if pz[dd].km = 'over' then
            break;

          if (not pz[dd].iscash) and (pz[dd].FITNUM = '') and (pz[dd].jf <> 0)
            then
            pz[dd].fitnum := '�����ϼƽ跽OK';
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
          pz[dd].FITNUM := '��ƽ����'
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

  qrytmp.close;
  qrytmp.sql.clear;
  qrytmp.sql.add('update ƾ֤�� set  fitnum=''''');
  qrytmp.ExecSQL;

  tbcalccash.Connection := con1;
  tbcalccash.TableName := 'ƾ֤��';

  tbcalccash.Open;
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

  qrypzb.Close;
  qrypzb.SQL.Clear;
  qrypzb.sql.Add('select * from ƾ֤��  where  (fitnum<>"" ) and ȫƾ֤�� in  ');
  qrypzb.sql.Add('(select ȫƾ֤�� from ƾ֤��  where  �ֽ��  ) order by ȫƾ֤��');

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

    ejunpzall.SaveToExcel(FILENAMEXLS, '�ֽ���',true,false);
  //  ejunpzall.SaveToExcel();
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
  qrytmp.Connection := con1;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' update ƾ֤�� a, �ֽ��������Ӧ  b');
  qrytmp.SQL.Add(' set a.�ֽ�����=b.�ֽ��������,a.��Ӫ����=trim(b.���� )');
  qrytmp.SQL.Add(' where trim(a.һ������)=trim(b.�Է���Ŀ) and  trim(a.��Ŀ����)=trim(b.ժҪ�ؼ���) ');
  qrytmp.SQL.Add('  and (trim(a.fitnum)<>"" )  and (TRIM(b.ժҪ�ؼ���)<>"") ');
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
  qrypzb.sql.Add('select * from ƾ֤��  where  (fitnum<>"" ) and ȫƾ֤�� in  ');
  qrypzb.sql.Add('(select ȫƾ֤�� from ƾ֤��  where  �ֽ��  ) order by ȫƾ֤��');

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

    ejunpzall.SaveToExcel(FILENAMEXLS, '�ֽ���',true,false);
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

end.

