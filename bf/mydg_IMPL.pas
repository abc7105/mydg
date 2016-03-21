unit mydg_IMPL;

interface

uses
  SysUtils, ComObj, ComServ, Variants, adxAddIn, mydg_TLB, communit, USHARE,
  Classes,
  Dialogs, Excel2000, lxyjm, ShellAPI, controls, windows, Forms,
  DB, ADODB, StdVcl;

type
  Tmydgs = class(TadxAddin, Imydgs)
  end;

  TAddInModule = class(TadxCOMAddInModule)
    //   con1: TADOConnection;
    adxCommandBar1: TadxCommandBar;
    adxRibbonTab1: TadxRibbonTab;
    procedure adxCOMAddInModuleAddInInitialize(Sender: TObject);
    function mydllpath(): string;
    procedure adxRibbonTab1Controls0Controls1Click(Sender: TObject;
      const RibbonControl: IRibbonControl);
    procedure adxRibbonTab1Controls0Controls5Click(Sender: TObject;
      const RibbonControl: IRibbonControl);
    procedure fitkm(Sender: TObject);
    procedure adxCommandBar1Controls0Controls9Click(Sender: TObject);
    procedure adxCommandBar1Controls0Controls12Click(Sender: TObject);
    procedure adxCommandBar1Controls0Controls10Click(Sender: TObject);
    procedure adxCommandBar1Controls0Controls13Click(Sender: TObject);
    procedure adxCOMAddInModuleAddInStartupComplete(Sender: TObject);
    procedure adxCommandBar1Controls0Controls11Click(Sender: TObject);
    procedure adxCommandBar1Controls0Controls14Click(Sender: TObject);
    procedure import9column(Sender: TObject);
    procedure import7column(Sender: TObject);
    procedure create9column(Sender: TObject);
    procedure create7column(Sender: TObject);
    procedure adxRibbonTab1Controls0Controls0Controls0Click(
      Sender: TObject; const RibbonControl: IRibbonControl);
    procedure create9col(
      Sender: TObject; const RibbonControl: IRibbonControl);
    procedure create7col(
      Sender: TObject; const RibbonControl: IRibbonControl);
    procedure dbfrom9col(
      Sender: TObject; const RibbonControl: IRibbonControl);
    procedure alltoexcel(
      Sender: TObject; const RibbonControl: IRibbonControl);
    procedure selecttoexcel(
      Sender: TObject; const RibbonControl: IRibbonControl);
    procedure lmtalltoexcel(
      Sender: TObject; const RibbonControl: IRibbonControl);
    procedure lmtselecttoexcel(
      Sender: TObject; const RibbonControl: IRibbonControl);
    procedure creatpzb(Sender: TObject;
      const RibbonControl: IRibbonControl);
    procedure adxRibbonTab1Controls1Controls1Click(Sender: TObject;
      const RibbonControl: IRibbonControl);
    procedure adxRibbonTab1Controls1Controls2Click(Sender: TObject;
      const RibbonControl: IRibbonControl);
    procedure newdw(
      Sender: TObject; const RibbonControl: IRibbonControl);
    procedure opendw(Sender: TObject; const RibbonControl: IRibbonControl);
    procedure dbfrom7col(
      Sender: TObject; const RibbonControl: IRibbonControl);
    procedure fitkmB(Sender: TObject; const RibbonControl: IRibbonControl);
    function hasopenxm(): Boolean;
    function excelver(): string;
    procedure openpath(Sender: TObject;
      const RibbonControl: IRibbonControl);
    procedure adxRibbonTab1Controls0Controls5Controls0Click(
      Sender: TObject; const RibbonControl: IRibbonControl);
    procedure adxRibbonTab1Controls0Controls5Controls1Click(
      Sender: TObject; const RibbonControl: IRibbonControl);
    procedure adxRibbonTab1Controls0Controls5Controls3Click(
      Sender: TObject; const RibbonControl: IRibbonControl);
    procedure adxRibbonTab1Controls0Controls5Controls4Click(
      Sender: TObject; const RibbonControl: IRibbonControl);
    procedure adxRibbonTab1Controls0Controls6Controls1Click(
      Sender: TObject; const RibbonControl: IRibbonControl);
    procedure adxRibbonTab1Controls0Controls6Controls2Click(
      Sender: TObject; const RibbonControl: IRibbonControl);
    procedure prevPZ(
      Sender: TObject; const RibbonControl: IRibbonControl);
    procedure adxRibbonTab1Controls0Controls6Controls4Click(
      Sender: TObject; const RibbonControl: IRibbonControl);
    procedure adxRibbonTab1Controls0Controls6Controls5Click(
      Sender: TObject; const RibbonControl: IRibbonControl);
    procedure adxRibbonTab1Controls2Controls2Click(Sender: TObject;
      const RibbonControl: IRibbonControl);
    procedure adxRibbonTab1Controls2Controls1Click(Sender: TObject;
      const RibbonControl: IRibbonControl);
    procedure procnewdw();
    function procopendw(): boolean;
    procedure adxCommandBar1Controls0Controls1Click(Sender: TObject);
    procedure adxCommandBar1Controls0Controls2Click(Sender: TObject);
    procedure proc_create9col();
    procedure proc_dbfrom9col();
    procedure proc_create7col();
    procedure proc_dbfrom7col();
    procedure proc_fitkmB();
    procedure proc_alltoexcel();
    procedure proc_selecttoexcel();
    procedure proc_lmtalltoexcel();
    procedure proc_lmtselecttoexcel();
    procedure adxCommandBar1Controls0Controls17Click(Sender: TObject);
    procedure adxCommandBar1Controls0Controls21Click(Sender: TObject);
    procedure proc_openpath();
    procedure prev(Sender: TObject; const RibbonControl: IRibbonControl);
    procedure dbfrompzb(Sender: TObject;
      const RibbonControl: IRibbonControl);
    procedure pzb_toexcel(Sender: TObject;
      const RibbonControl: IRibbonControl);
    procedure moneysheet(Sender: TObject;
      const RibbonControl: IRibbonControl);
    procedure adxCOMAddInModuleCreate(Sender: TObject);
    procedure adxRibbonTab1Controls0Controls5Controls2Click(
      Sender: TObject; const RibbonControl: IRibbonControl);
    procedure adxRibbonTab1Controls0Controls1Controls4Click(
      Sender: TObject; const RibbonControl: IRibbonControl);
    procedure adxRibbonTab1Controls0Controls2Controls2Click(
      Sender: TObject; const RibbonControl: IRibbonControl);
    procedure adxRibbonTab1Controls1Controls5Controls0Click(
      Sender: TObject; const RibbonControl: IRibbonControl);
    procedure adxRibbonTab1Controls1Controls5Controls1Click(
      Sender: TObject; const RibbonControl: IRibbonControl);
    procedure adxRibbonTab1Controls2Controls2Controls3Click(
      Sender: TObject; const RibbonControl: IRibbonControl);
  private
  protected
  public
  end;

var
  adxmydgs: TAddInModule;
  commandline: integer;
  // adg: auditdg;
//  ajm: tlxyjm;

implementation

uses
  frminfo, untselectdg, reg, fmnewdw, frmopendw,
  frm_manysheet, u_xzh, frmcash, jm, CLSexcel;

{$R *.dfm}

procedure TAddInModule.adxCOMAddInModuleAddInInitialize(Sender: TObject);
var
  ausername, apassword, filename: string;
begin

  axm.xmid := '';
  axm.xmname := '';
  axm.mbname := '';
  axm.xmpath := '';
  axm.mbpath := '';
  axm.dwmc := '';
  axm.mbid := '';
  axm.MBNAME := '';

  //  filename := mydllpath + 'dg.mdb';

  //    ausername, apassword, filename: string;
  //  ausername := 'admin';
  //  apassword := '';
  //  mainmdb.DataModule3.conmain.ConnectionString := 'Provider=Microsoft.Jet.OLEDB.4.0;' +
  //    'User ID=' + AUserName + ';' +
  //    'Jet OLEDB:Database Password=' + APassword + ';' +
  //    'Data Source=' + filename + ';' +
  //    'Mode=ReadWrite;' +
  //    'Extended Properties="";';
  //  mainmdb.DataModule3.conmain.Connected := true;
  //  ExcelApp.DisplayAlerts[adxLCID] := false;

  adxmydgs := Self;
  //
    // mainpath := mydllpath;
     //  if StrToFloat(excelver) > 11 then
     //  begin
     //    adxCommandBar1.Visible := FALSE;
     //    adxRibbonTab1.Visible := FALSE;
     //  end
     //  else
     //  begin
     //    adxCommandBar1.Visible := FALSE;
     //    adxRibbonTab1.Visible := False;
     //  end;

end;

function TAddInModule.mydllpath: string;
begin
  result := COMAddInClassFactory.FilePath;
end;

procedure TAddInModule.adxRibbonTab1Controls0Controls1Click(
  Sender: TObject; const RibbonControl: IRibbonControl);
var
  aform: tfminfo;
begin
  mainpath := mydllpath;
  aform := Tfminfo.Create(nil);
  //  aform.xlsapp := ExcelApp.Application;
  try
    aform.ShowModal;
  finally
    aform.Close;
    aform.Free;
    aform := nil;
  end;
end;

procedure TAddInModule.adxRibbonTab1Controls0Controls5Click(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  // adg.datebase_toexcel;
end;

procedure TAddInModule.create7column(
  Sender: TObject);
begin
  proc_create7col;

end;

procedure TAddInModule.create9column(
  Sender: TObject);
begin
  proc_create9col;
end;

procedure TAddInModule.import7column(
  Sender: TObject);
begin
  proc_dbfrom7col;
end;

procedure TAddInModule.import9column(
  Sender: TObject);
begin
  proc_dbfrom9col;
end;

procedure TAddInModule.fitkm(
  Sender: TObject);
begin
  proc_fitkmB;
end;

procedure TAddInModule.adxCommandBar1Controls0Controls9Click(
  Sender: TObject);
begin
  proc_alltoexcel;
end;

procedure TAddInModule.adxCommandBar1Controls0Controls12Click(
  Sender: TObject);
begin
  proc_lmtselecttoexcel;
end;

procedure TAddInModule.adxCommandBar1Controls0Controls10Click(
  Sender: TObject);
begin
  proc_selecttoexcel;
end;

procedure TAddInModule.adxCommandBar1Controls0Controls13Click(
  Sender: TObject);
var
  aform: Tfmreg;
begin
  //
  try
    aform := Tfmreg.Create(nil);
    aform.ShowModal;
  finally
    aform.close;
    aform.Free;
    aform := nil;
  end;
end;

procedure TAddInModule.adxCOMAddInModuleAddInStartupComplete(
  Sender: TObject);
var
  ausername, apassword, filename: string;
begin
  adxmydgs := nil;
  if StrToFloat(excelver) > 11 then
  begin
    adxCommandBar1.Visible := TRUE;
    adxRibbonTab1.Visible := FALSE;
  end;

  mainpath := mydllpath;
  //��Ҫ�ĵط�
  ADGSYSTEM := dgsystem.create(mainpath);
  ADGSYSTEM.OPENLAST;

  ExcelApp.DisplayAlerts[adxLCID] := false;

  // adg := auditdg.create(ADGSYSTEM.connection, ExcelApp.Application, mydllpath);

  ajm := tlxyjm.create(mainpath);
  if ajm.check3 then
  begin
    adxCommandBar1.Controls[0].AsPopup.Controls[12].AsButton.visible := True;
    adxCommandBar1.Controls[0].AsPopup.Controls[13].AsButton.visible := True;
    adxCommandBar1.Controls[0].AsPopup.Controls[14].AsButton.visible := false;
    adxCommandBar1.Controls[0].AsPopup.Controls[15].AsButton.visible := false;

    adxRibbonTab1.Controls[0].AsRibbonGroup.controls[4].AsRibbonMenu.Visible := false;
    adxRibbonTab1.Controls[0].AsRibbonGroup.controls[5].AsRibbonMenu.Visible := true;
    adxRibbonTab1.Controls[2].AsRibbonGroup.controls[1].AsRibbonMenu.controls[3].AsRibbonbutton.Enabled := true;
    //
  end
  else
  begin
    adxCommandBar1.Controls[0].AsPopup.Controls[12].AsButton.visible := false;
    adxCommandBar1.Controls[0].AsPopup.Controls[13].AsButton.visible := false;
    adxCommandBar1.Controls[0].AsPopup.Controls[14].AsButton.visible := True;
    adxCommandBar1.Controls[0].AsPopup.Controls[15].AsButton.visible := True;

    adxRibbonTab1.Controls[0].AsRibbonGroup.controls[4].AsRibbonMenu.Visible := true; //�����ɵ׸�İ�ť
    adxRibbonTab1.Controls[0].AsRibbonGroup.controls[5].AsRibbonMenu.Visible := false; //���ɵ׸�İ�ť
    adxRibbonTab1.Controls[2].AsRibbonGroup.controls[1].AsRibbonMenu.controls[3].AsRibbonbutton.Enabled := false;
    //���ɵ׸�İ�ť

  end;
end;

procedure TAddInModule.adxCommandBar1Controls0Controls11Click(
  Sender: TObject);
begin
  proc_lmtalltoexcel;
end;

procedure TAddInModule.adxCommandBar1Controls0Controls14Click(
  Sender: TObject);
begin
  //
  ShellExecute(0, 'open', PChar(mydllpath + '�׸�������Ƶ.exe'), nil, nil, 1);
end;

procedure TAddInModule.adxRibbonTab1Controls0Controls0Controls0Click(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  //adg.create_KM7sheet;
end;

procedure TAddInModule.create9col(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  proc_create9col();
end;

procedure TAddInModule.proc_create9col();
var
  acreatesheet: createsheet;
begin
  if ExcelApp.Workbooks.count < 1 then
  begin
    ExcelApp.Workbooks.Add(EmptyParam, adxLCID);
  end;

  acreatesheet := createsheet.create(ExcelApp.Application);
  acreatesheet.create_KM9sheet;
  acreatesheet.Free;
end;

procedure TAddInModule.proc_create7col();
var
  acreatesheet: createsheet;
begin
  if ExcelApp.Workbooks.count < 1 then
  begin
    ExcelApp.Workbooks.Add(EmptyParam, adxLCID);
  end;
  acreatesheet := createsheet.create(ExcelApp.Application);
  acreatesheet.create_KM7sheet;
  acreatesheet.Free;

end;

procedure TAddInModule.create7col(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  proc_create7col();
end;

procedure TAddInModule.proc_dbfrom9col();
var
  adgworkbook: dgworkbook;
begin
  if ExcelApp.Workbooks.count < 1 then
  begin
    mymessage('������ʹ�õ�EXCEL�ļ�������ļ������');
    Exit;
  end;

  if not sheetexists(ExcelApp, 'ƾ֤��') then
  begin

    mymessage('ʹ����ʾ��' + chr(10) + chr(13) + chr(10) + chr(13) +
      '���������ޡ�ƾ֤������޷��������ݣ�  �������򿪡�����ʹ����ָ�ϡ�-����Ŀ������ķ�������' + chr(10) +
      chr(13) +
      '  ��ϵͳ��Ҫ����Ŀ�Ŀ�����������ĸ�ʽ����' + chr(10) + chr(13)
      );
    Exit;
  end;

  try
    axm := adgsystem.OPENLAST;
    adgworkbook := dgworkbook.create();
    adgworkbook.xm := axm;
    adgworkbook.excelapp := ExcelApp.Application;

    case Application.MessageBox(PChar('��ȷ�Ͻ����ݵ������� [' + axm.xmid + ' ' + axm.xmname + ']����������'),
      '��ע��ʾ', MB_YESNO + MB_ICONQUESTION) of
      IDYES:
        begin
          case Application.MessageBox('��������ɾ����Ŀ��ԭ�����ݣ���������',
            '��ע��ʾ', MB_YESNO + MB_ICONQUESTION) of
            IDYES:
              begin
                adgworkbook.import_KMYEB9column;
                axm.kmlen := adgworkbook.xm.kmlen;
                ADGSYSTEM.writetomdb_kmlen(axm);
              end;
          end;
        end;
    end;

  finally
    adgworkbook.Free;
    adgworkbook := nil;
  end;

end;

procedure TAddInModule.dbfrom9col(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  if not hasopenxm then
  begin
    procopendw;
  end;

  proc_dbfrom9col();
end;

procedure TAddInModule.proc_alltoexcel();
var

  adgworkbook: dgworkbook;
begin
  try
    axm := adgsystem.OPENLAST;
    adgworkbook := dgworkbook.create();
    adgworkbook.xm := axm;
    adgworkbook.excelapp := ExcelApp.Application;
    adgworkbook.fillall;

    ShellExecute(0, 'open', PChar(axm.xmpath), 'C:\Windows', nil, 1);

  finally
    adgworkbook.Free;
    adgworkbook := nil;
  end;
end;

procedure TAddInModule.alltoexcel(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  if not hasopenxm then
  begin
    procopendw;
  end;

  proc_alltoexcel();
end;

procedure TAddInModule.selecttoexcel(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  // mymessage(ADGSYSTEM.xm.xmname);
  if ADGSYSTEM.xm.XMID = '' then
  begin
    procopendw;
  end;

  proc_selecttoexcel;
end;

procedure TAddInModule.proc_selecttoexcel();
var
  aform: Tfmselectdg;
  dglist1: TStringList;
  adgworkbook: dgworkbook;
begin
  try
    axm := adgsystem.OPENLAST;
    adgworkbook := dgworkbook.create();
    adgworkbook.xm := axm;
    adgworkbook.excelapp := ExcelApp.Application;

    aform := Tfmselectdg.Create(nil);
    aform.kmlist := adgworkbook.getkmlist;
    aform.ShowModal;
    dglist1 := aform.kmlist;

    adgworkbook.fill(dglist1);

    ShellExecute(0, 'open', PChar(axm.xmpath), 'C:\Windows', nil, 1);

  finally
    adgworkbook.Free;
    adgworkbook := nil;
    aform.close;
    aform.Free;
    aform := nil;
  end;
end;

procedure TAddInModule.proc_lmtalltoexcel();
begin
  if not hasopenxm then
  begin
    procopendw;
  end;

  //  adg.xmid := axm.xmid;
  //  adg.MBID := axm.mbid;
  //  adg.limit_database_toexcel;
end;

procedure TAddInModule.lmtalltoexcel(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  proc_lmtalltoexcel;
end;

procedure TAddInModule.proc_lmtselecttoexcel();
var
  aform: Tfmselectdg;
  dglist1: TStringList;
begin
  if not hasopenxm then
    exit;

  try
    aform := Tfmselectdg.Create(nil);
    aform.ShowModal;

    dglist1 := aform.kmlist;
    //    adg.xmid := axm.xmid;
    //    adg.MBID := axm.mbid;
    //    adg.limit_database_select_toexcel(dglist1);
  finally
    aform.close;
    aform.Free;
    aform := nil;
  end;
end;

procedure TAddInModule.lmtselecttoexcel(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  proc_lmtselecttoexcel;
end;

procedure TAddInModule.creatpzb(
  Sender: TObject; const RibbonControl: IRibbonControl);
var
  acreatesheet: createsheet;
begin
  if ExcelApp.Workbooks.count < 1 then
  begin
    ExcelApp.Workbooks.Add(EmptyParam, adxLCID);
  end;
  acreatesheet := createsheet.create(ExcelApp.Application);
  acreatesheet.create_pzb;
  acreatesheet.Free;
end;

procedure TAddInModule.adxRibbonTab1Controls1Controls1Click(
  Sender: TObject; const RibbonControl: IRibbonControl);
var
  aform: Tfmreg;
begin
  //
  try
    aform := Tfmreg.Create(nil);
    aform.ShowModal;
  finally
    aform.close;
    aform.Free;
    aform := nil;
  end;
end;

procedure TAddInModule.adxRibbonTab1Controls1Controls2Click(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  //�򿪳�ʼģ��
  try
    excelapp.Workbooks.Open(mydllpath + '�׸������Ϣ.xls'
      , EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, adxLCID
      );
  except
    mymessage('���ļ�ʧ�ܣ������ļ��Ƿ���ڣ�');
    exit;
  end;
end;

procedure TAddInModule.newdw(
  Sender: TObject; const RibbonControl: IRibbonControl);

begin
  procnewdw;
end;

procedure TAddInModule.opendw(Sender: TObject;
  const RibbonControl: IRibbonControl);

begin
  procopendw;
end;

procedure TAddInModule.proc_dbfrom7col();
var
  aform: Tfmselectdg;
  dglist1: TStringList;
  adgworkbook: dgworkbook;
begin
  if ExcelApp.Workbooks.count < 1 then
  begin
    mymessage('������ʹ�õ�EXCEL�ļ�������ļ������');
    Exit;
  end;

  if not sheetexists(ExcelApp, 'ƾ֤��') then
  begin

    mymessage('ʹ����ʾ��' + chr(10) + chr(13) + chr(10) + chr(13) +
      '���������ޡ�ƾ֤������޷��������ݣ�  �������򿪡�����ʹ����ָ�ϡ�-����Ŀ������ķ�������' + chr(10) +
      chr(13) +
      '  ��ϵͳ��Ҫ����Ŀ�Ŀ�����������ĸ�ʽ����' + chr(10) + chr(13)
      );
    exit;

  end;

  try
    axm := adgsystem.OPENLAST;
    adgworkbook := dgworkbook.create();
    adgworkbook.xm := axm;
    adgworkbook.excelapp := ExcelApp.Application;

    case Application.MessageBox(PChar('��ȷ�Ͻ����ݵ������� [' + axm.xmid + ' ' + axm.xmname + ']����������'),
      '��ע��ʾ', MB_YESNO + MB_ICONQUESTION) of
      IDYES:
        begin
          case Application.MessageBox('��������ɾ����Ŀ��ԭ�����ݣ���������',
            '��ע��ʾ', MB_YESNO + MB_ICONQUESTION) of
            IDYES:
              begin
                adgworkbook.import_KMYEB7column;
                axm.kmlen := adgworkbook.xm.kmlen;
                ADGSYSTEM.writetomdb_kmlen(axm);
              end;
          end;
        end;
    end;

  finally
    adgworkbook.Free;
    adgworkbook := nil;
  end;

end;

procedure TAddInModule.dbfrom7col(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  if not hasopenxm then
  begin
    procopendw;
  end;

  proc_dbfrom7col();
end;

procedure TAddInModule.proc_fitkmB();
var
  aform: Tfminfo;
begin
  //
  try
    aform := Tfminfo.Create(nil);
    aform.ShowModal;
  finally
  end;
end;

procedure TAddInModule.fitkmB(Sender: TObject;
  const RibbonControl: IRibbonControl);

begin
  if not hasopenxm then
  begin
    if not procopendw() then
      exit;
  end;

  proc_fitkmB;
end;

function TAddInModule.hasopenxm: Boolean;
begin
  result := false;
  if Trim(axm.xmid) = '' then
    exit;
  result := true;
end;

function TAddInModule.excelver: string;
begin
  RESULT := ExcelApp.Application.Version[adxLCID];
end;

procedure TAddInModule.proc_openpath();
begin
  //
  if axm.xmpath = '' then
  begin
    mymessage('�Բ�����û�д��κ���Ŀ��������һ����ĳ����Ŀ�ټ�����');
    exit;
  end;
  ShellExecute(0, 'open', PChar(axm.xmpath), 'C:\Windows', nil, 1);
end;

procedure TAddInModule.openpath(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  proc_openpath;
end;

procedure TAddInModule.adxRibbonTab1Controls0Controls5Controls0Click(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  //����Ӧ��ӡԤ����ǰ��
  if ExcelApp.Workbooks.count < 1 then
  begin
    mymessage('������ʹ�õ�EXCEL�ļ�������ļ������');
    Exit;
  end;
  previewone(ExcelApp.ActiveCell.Worksheet);
end;

procedure TAddInModule.adxRibbonTab1Controls0Controls5Controls1Click(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  //����Ӧ��ӡ��ǰ��
  if ExcelApp.Workbooks.count < 1 then
  begin
    mymessage('������ʹ�õ�EXCEL�ļ�������ļ������');
    Exit;
  end;
  printasheet(ExcelApp.ActiveCell.Worksheet);
end;

procedure TAddInModule.adxRibbonTab1Controls0Controls5Controls3Click(
  Sender: TObject; const RibbonControl: IRibbonControl);

var
  i: Integer;
  sname: string;
  asheet: _Worksheet;
begin
  //����Ӧ��ӡ��ǰ�ļ��пɼ���

  if ExcelApp.Workbooks.count < 1 then
  begin
    mymessage('������ʹ�õ�EXCEL�ļ�������ļ������');
    Exit;
  end;

  sname := ExcelApp.ActiveWindow.ActiveCell.Worksheet.Name;

  for i := 1 to ExcelApp.ActiveWorkbook.Sheets.Count do
  begin
    asheet := _Worksheet(ExcelApp.ActiveWorkbook.Worksheets[i]);
    if asheet.Visible[adxLCID] = xlSheetVisible then
    begin
      asheet.Activate(adxlcid);
      printasheet(asheet);
    end;

  end;

  for i := 1 to ExcelApp.ActiveWorkbook.Sheets.Count do
  begin
    asheet := _Worksheet(ExcelApp.ActiveWorkbook.Worksheets[i]);
    if asheet.Visible[adxLCID] = xlSheetVisible then
    begin
      asheet.Select(False, adxLCID);
    end;

  end;

  ExcelApp.ActiveWindow.SelectedSheets.PrintOut(EmptyParam, EmptyParam, EmptyParam, false,
    true, false, EmptyParam, EmptyParam, 0);
  _worksheet(ExcelApp.ActiveWorkbook.Sheets.Item[sname]).Activate(adxLCID);

end;

procedure TAddInModule.adxRibbonTab1Controls0Controls5Controls4Click(
  Sender: TObject; const RibbonControl: IRibbonControl);
var
  aform: Tfmmanysheet;
begin
  try
    aform := Tfmmanysheet.Create(nil);
    aform.BitBtn1.Visible := true;
    aform.BitBtn2.Visible := true;
    aform.aworkbook := ExcelApp.Application;
    aform.cztype := 1;
    aform.ShowModal;
  except
  end;
end;

{ xzh }

procedure TAddInModule.adxRibbonTab1Controls0Controls6Controls1Click(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  begin
    ExcelApp.Workbooks.Open(mydllpath + '���к�֤.xlsx', EmptyParam,
      EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, adxLCID
      );
    mymessage('����ͷ�涨��������д�б�Ȼ���ڲ˵���ѡ���ڶ��� �б�������Ӧ�ĺ�֤���ŷ⡿������WORD��ĺ�֤��');
  end;
end;

procedure TAddInModule.adxRibbonTab1Controls0Controls6Controls2Click(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  ExcelApp.Workbooks.Open(mydllpath + '����ѯ֤��.xlsx', EmptyParam,
    EmptyParam, EmptyParam, EmptyParam,
    EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
    EmptyParam, EmptyParam, EmptyParam, adxLCID
    );
  mymessage('����ͷ�涨��������д�б�Ȼ���ڲ˵���ѡ���ڶ��� �б�������Ӧ�ĺ�֤���ŷ⡿������WORD��ĺ�֤��');
end;

procedure TAddInModule.adxRibbonTab1Controls0Controls6Controls4Click(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  ExcelApp.Workbooks.Open(mydllpath + '�ż�����.xls', EmptyParam,
    EmptyParam, EmptyParam, EmptyParam,
    EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
    EmptyParam, EmptyParam, EmptyParam, adxLCID
    );
  mymessage('����ͷ�涨��������д�б�Ȼ���ڲ˵���ѡ���ڶ��� �б�������Ӧ�ĺ�֤���ŷ⡿������WORD��ĺ�֤��');
end;

procedure TAddInModule.adxRibbonTab1Controls0Controls6Controls5Click(
  Sender: TObject; const RibbonControl: IRibbonControl);
var
  axzh: xzh;
  pathstr: string;
begin
  //
  if ExcelApp.Workbooks.count < 1 then
  begin
    mymessage('������ʹ�õ�EXCEL�ļ�������ļ������');
    Exit;
  end;
  if
    MessageDlg('��������Զ��ر�ȫ��WORD�ĵ�����˲���ǰ��������Ҫ�����WORD�ĵ����б���',
    mtInformation, mbOKCancel, 0) = mrOk then
    if MessageDlg('��ȷ������Զ��ر�����WORD�ĵ�����������',
      mtInformation, mbOKCancel, 0) = mrOk then
    begin

      pathstr := '';
      try
        pathstr := ExcelApp.ActiveWorkbook.FullName[adxLCID];
      except
        pathstr := '';
      end;

      if Pos(':', pathstr) < 1 then
      begin
        mymessage('��ǰ�ļ�δ������޻�Ĺ������ļ������顣');
        exit;
      end;

      axzh := xzh.create(ExcelApp.Application, pathstr);
      axzh.alltables_tonumber;
    end

end;

procedure TAddInModule.adxRibbonTab1Controls2Controls2Click(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  ShellExecute(Application.Handle, 'Open', 'IEXPLORE.EXE',
    'http://hi.baidu.com/hbwhzysoft/item/623f58c468164d46a9ba9482', '', SW_SHOWNORMAL);

end;

procedure TAddInModule.adxRibbonTab1Controls2Controls1Click(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  ShellExecute(Application.Handle, 'Open', 'IEXPLORE.EXE',
    'http://hi.baidu.com/hbwhzysoft/item/623f58c468164d46a9ba9482', '', SW_SHOWNORMAL); //Application.Handle

end;

procedure TAddInModule.procnewdw;
var
  aform: Tfmadddw;
begin
  //
  try

    aform := Tfmadddw.Create(nil);
    aform.connection := ADGSYSTEM.connection;
    //    aform.connection := mainmdb.DataModule3.conmain;
        //    aform.xlsapp := ExcelApp.Application;

    aform.ShowModal;
  finally
    aform.Close;
    aform.Free;
    aform := nil;
  end;
end;

//procedure TAddInModule.procopendw;

function TAddInModule.procopendw(): boolean;
var
  aform: Tfmopendw;
begin
  //
  result := false;
  try
    aform := Tfmopendw.Create(nil);
    aform.ShowModal;
    if axm.xmid <> '' then
    begin
      //     mymessage(axm.xmname);
      result := True;
    end;
  finally
    aform.Close;
    aform.Free;
    aform := nil;
  end;
end;

procedure TAddInModule.adxCommandBar1Controls0Controls1Click(
  Sender: TObject);
begin
  procnewdw;
end;

procedure TAddInModule.adxCommandBar1Controls0Controls2Click(
  Sender: TObject);
begin
  procopendw;
end;

procedure TAddInModule.adxCommandBar1Controls0Controls17Click(
  Sender: TObject);
begin
  proc_openpath;
end;

procedure TAddInModule.adxCommandBar1Controls0Controls21Click(
  Sender: TObject);
begin
  ShellExecute(Application.Handle, 'Open', 'IEXPLORE.EXE',
    'http://hi.baidu.com/hbwhzysoft/item/623f58c468164d46a9ba9482', '', SW_SHOWNORMAL); //Application.Handle
end;

procedure TAddInModule.prev(Sender: TObject;
  const RibbonControl: IRibbonControl);
begin
  //
  ShellExecute(Application.Handle, 'Open', PChar(mydllpath + '��Ŀ�������ɵ׸���ʾ��Ƶ.exe'),
    '', '', SW_SHOWNORMAL); //Application.Handle

end;

procedure TAddInModule.prevPZ(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin

  ShellExecute(Application.Handle, 'Open', PChar(mydllpath + 'ƾ֤�����ƾ��ʾ.exe'),
    '', '', SW_SHOWNORMAL); //Application.Handle

end;

procedure TAddInModule.dbfrompzb(Sender: TObject;
  const RibbonControl: IRibbonControl);
var
  adgworkbook: dgworkbook;
begin
  if ExcelApp.Workbooks.count < 1 then
  begin
    mymessage('������ʹ�õ�EXCEL�ļ�������ļ������');
    Exit;
  end;

  if not sheetexists(ExcelApp, 'ƾ֤��') then
  begin

    mymessage('ʹ����ʾ��' + chr(10) + chr(13) + chr(10) + chr(13) +
      '���������ޡ�ƾ֤������޷��������ݣ�  �������򿪡�����ʹ����ָ�ϡ�-��ƾ֤����ķ�������' + chr(10) +
      chr(13) +
      '  ��ϵͳ��Ҫ�����ƾ֤���������ĸ�ʽ����' + chr(10) + chr(13)
      );
    exit;

  end;

  try
    axm := adgsystem.OPENLAST;
    adgworkbook := dgworkbook.create();
    adgworkbook.xm := axm;
    adgworkbook.excelapp := ExcelApp.Application;

    case Application.MessageBox(PChar('��ȷ�Ͻ����ݵ������� [' + axm.xmid + ' ' + axm.xmname + ']����������'),
      '��ע��ʾ', MB_YESNO + MB_ICONQUESTION) of
      IDYES:
        begin
          case Application.MessageBox('��������ɾ����Ŀ��ԭ�����ݣ���������',
            '��ע��ʾ', MB_YESNO + MB_ICONQUESTION) of
            IDYES:
              begin
                adgworkbook.import_pzsheet;
                axm.kmlen := adgworkbook.xm.kmlen;
                ADGSYSTEM.writetomdb_kmlen(axm);
              end;
          end;
        end;
    end;

  finally
    adgworkbook.Free;
    adgworkbook := nil;
  end;

end;

procedure TAddInModule.pzb_toexcel(Sender: TObject;
  const RibbonControl: IRibbonControl);

begin

 // if DirectoryExists(axm.xmpath) then
    ShellExecute(0, 'open', PChar(mydllpath + 'sjprog.exe'), nil, nil, 1);

end;

procedure TAddInModule.moneysheet(
  Sender: TObject; const RibbonControl: IRibbonControl);
var
  aform: tfmcash;
begin
  //
  if not hasopenxm then
  begin
    procopendw;
  end;

  try
    aform := tfmcash.Create(nil);
    ////   LoadParamFromFile(mainpath + 'sys.ini');
   //    aform.xmid := axm.xmid;
    aform.showmodal;
  finally
  end;

end;

procedure TAddInModule.adxCOMAddInModuleCreate(Sender: TObject);
var
  i: integer;
begin
  //

end;

procedure TAddInModule.adxRibbonTab1Controls0Controls5Controls2Click(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  if not hasopenxm then
  begin
    procopendw;
  end;

  proc_alltoexcel();
end;

procedure TAddInModule.adxRibbonTab1Controls0Controls1Controls4Click(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  //�򿪳�ʼģ��
  try
    excelapp.Workbooks.Open(mydllpath + '��Ŀ����ģ��.xls'
      , EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, adxLCID
      );
  except
    mymessage('���ļ�ʧ�ܣ������ļ��Ƿ���ڣ�');
    exit;
  end;
end;

procedure TAddInModule.adxRibbonTab1Controls0Controls2Controls2Click(
  Sender: TObject; const RibbonControl: IRibbonControl);
var
  aform: Tfmselectdg;
  dglist1: TStringList;
  adgworkbook: dgworkbook;
begin
  if ExcelApp.Workbooks.count < 1 then
  begin
    mymessage('������ʹ�õ�EXCEL�ļ�������ļ������');
    Exit;
  end;
  try
    axm := adgsystem.OPENLAST;
    adgworkbook := dgworkbook.create();
    adgworkbook.xm := axm;
    adgworkbook.excelapp := ExcelApp.Application;

    case Application.MessageBox(PChar('��ȷ�Ͻ����ݵ������� [' + axm.xmid + ' ' + axm.xmname + ']����������'),
      '��ע��ʾ', MB_YESNO + MB_ICONQUESTION) of
      IDYES:
        begin
          case Application.MessageBox('��������ɾ����Ŀ��ԭ�����ݣ���������',
            '��ע��ʾ', MB_YESNO + MB_ICONQUESTION) of
            IDYES:
              begin
                adgworkbook.import_DXNSHEET;
              end;
          end;
        end;
    end;

  finally
    adgworkbook.Free;
    adgworkbook := nil;
  end;

end;

procedure TAddInModule.adxRibbonTab1Controls1Controls5Controls0Click(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  //�򿪳�ʼģ��
  mymessage('ʹ����ʾ��' + chr(10) + chr(13) + chr(10) + chr(13) +
    '��Ӧ�ý����Ŀ�Ŀ������������µĸ�ʽ���ٽ��뵼�������' + chr(10) + chr(13)
    );
  try
    excelapp.Workbooks.Open(mydllpath + '��Ŀ������ģ��.xls'
      , EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, adxLCID
      );
  except
    mymessage('���ļ�ʧ�ܣ������ļ��Ƿ���ڣ�');
    exit;
  end;
end;

procedure TAddInModule.adxRibbonTab1Controls1Controls5Controls1Click(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  //�򿪳�ʼģ��
  mymessage('ʹ����ʾ��' + chr(10) + chr(13) + chr(10) + chr(13) +
    '��Ӧ�ý�����ƾ֤�������������µĸ�ʽ���ٽ��뵼�������' + chr(10) +
    chr(13)

    );

  try
    excelapp.Workbooks.Open(mydllpath + 'ƾ֤����ģ��.xls'
      , EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, adxLCID
      );
  except
    mymessage('���ļ�ʧ�ܣ������ļ��Ƿ���ڣ�');
    exit;
  end;
end;

procedure TAddInModule.adxRibbonTab1Controls2Controls2Controls3Click(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  ExcelApp.Workbooks.Open(mydllpath + '����ѯ֤��.xls', EmptyParam,
    EmptyParam, EmptyParam, EmptyParam,
    EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
    EmptyParam, EmptyParam, EmptyParam, adxLCID
    );
  mymessage('����ͷ�涨��������д�б�Ȼ���ڲ˵���ѡ���ڶ��� �б�������Ӧ�ĺ�֤���ŷ⡿������WORD��ĺ�֤��');
end;

initialization
  TadxFactory.Create(ComServer, Tmydgs, CLASS_mydgs, TAddInModule);

end.
