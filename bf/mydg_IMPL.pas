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
  //重要的地方
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

    adxRibbonTab1.Controls[0].AsRibbonGroup.controls[4].AsRibbonMenu.Visible := true; //不生成底稿的按钮
    adxRibbonTab1.Controls[0].AsRibbonGroup.controls[5].AsRibbonMenu.Visible := false; //生成底稿的按钮
    adxRibbonTab1.Controls[2].AsRibbonGroup.controls[1].AsRibbonMenu.controls[3].AsRibbonbutton.Enabled := false;
    //生成底稿的按钮

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
  ShellExecute(0, 'open', PChar(mydllpath + '底稿生成视频.exe'), nil, nil, 1);
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
    mymessage('无正在使用的EXCEL文件，请打开文件后继续');
    Exit;
  end;

  if not sheetexists(ExcelApp, '凭证表') then
  begin

    mymessage('使用提示：' + chr(10) + chr(13) + chr(10) + chr(13) +
      '工作簿中无【凭证表】表格，无法导入数据！  建议您打开【初次使用者指南】-【科目余额表导入的范例表】，' + chr(10) +
      chr(13) +
      '  看系统需要导入的科目余额表是怎样的格式，！' + chr(10) + chr(13)
      );
    Exit;
  end;

  try
    axm := adgsystem.OPENLAST;
    adgworkbook := dgworkbook.create();
    adgworkbook.xm := axm;
    adgworkbook.excelapp := ExcelApp.Application;

    case Application.MessageBox(PChar('您确认将数据导入账套 [' + axm.xmid + ' ' + axm.xmname + ']，您继续吗？'),
      '附注提示', MB_YESNO + MB_ICONQUESTION) of
      IDYES:
        begin
          case Application.MessageBox('本操作将删除项目的原有数据，您继续吗？',
            '附注提示', MB_YESNO + MB_ICONQUESTION) of
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
  //打开初始模板
  try
    excelapp.Workbooks.Open(mydllpath + '底稿基本信息.xls'
      , EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, adxLCID
      );
  except
    mymessage('打开文件失败，请检查文件是否存在！');
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
    mymessage('无正在使用的EXCEL文件，请打开文件后继续');
    Exit;
  end;

  if not sheetexists(ExcelApp, '凭证表') then
  begin

    mymessage('使用提示：' + chr(10) + chr(13) + chr(10) + chr(13) +
      '工作簿中无【凭证表】表格，无法导入数据！  建议您打开【初次使用者指南】-【科目余额表导入的范例表】，' + chr(10) +
      chr(13) +
      '  看系统需要导入的科目余额表是怎样的格式，！' + chr(10) + chr(13)
      );
    exit;

  end;

  try
    axm := adgsystem.OPENLAST;
    adgworkbook := dgworkbook.create();
    adgworkbook.xm := axm;
    adgworkbook.excelapp := ExcelApp.Application;

    case Application.MessageBox(PChar('您确认将数据导入账套 [' + axm.xmid + ' ' + axm.xmname + ']，您继续吗？'),
      '附注提示', MB_YESNO + MB_ICONQUESTION) of
      IDYES:
        begin
          case Application.MessageBox('本操作将删除项目的原有数据，您继续吗？',
            '附注提示', MB_YESNO + MB_ICONQUESTION) of
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
    mymessage('对不起，您没有打开任何项目，请进入第一步打开某个项目再继续！');
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
  //自适应打印预览当前表
  if ExcelApp.Workbooks.count < 1 then
  begin
    mymessage('无正在使用的EXCEL文件，请打开文件后继续');
    Exit;
  end;
  previewone(ExcelApp.ActiveCell.Worksheet);
end;

procedure TAddInModule.adxRibbonTab1Controls0Controls5Controls1Click(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  //自适应打印当前表
  if ExcelApp.Workbooks.count < 1 then
  begin
    mymessage('无正在使用的EXCEL文件，请打开文件后继续');
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
  //自适应打印当前文件中可见表

  if ExcelApp.Workbooks.count < 1 then
  begin
    mymessage('无正在使用的EXCEL文件，请打开文件后继续');
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
    ExcelApp.Workbooks.Open(mydllpath + '银行函证.xlsx', EmptyParam,
      EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, adxLCID
      );
    mymessage('按表头规定的内容填写列表，然后在菜单中选【第二步 列表生成相应的函证或信封】来生成WORD版的函证！');
  end;
end;

procedure TAddInModule.adxRibbonTab1Controls0Controls6Controls2Click(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  ExcelApp.Workbooks.Open(mydllpath + '往来询证函.xlsx', EmptyParam,
    EmptyParam, EmptyParam, EmptyParam,
    EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
    EmptyParam, EmptyParam, EmptyParam, adxLCID
    );
  mymessage('按表头规定的内容填写列表，然后在菜单中选【第二步 列表生成相应的函证或信封】来生成WORD版的函证！');
end;

procedure TAddInModule.adxRibbonTab1Controls0Controls6Controls4Click(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  ExcelApp.Workbooks.Open(mydllpath + '信件封面.xls', EmptyParam,
    EmptyParam, EmptyParam, EmptyParam,
    EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
    EmptyParam, EmptyParam, EmptyParam, adxLCID
    );
  mymessage('按表头规定的内容填写列表，然后在菜单中选【第二步 列表生成相应的函证或信封】来生成WORD版的函证！');
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
    mymessage('无正在使用的EXCEL文件，请打开文件后继续');
    Exit;
  end;
  if
    MessageDlg('本程序会自动关闭全部WORD文档，因此操作前请您将需要保存的WORD文档进行保存',
    mtInformation, mbOKCancel, 0) = mrOk then
    if MessageDlg('按确定后会自动关闭所有WORD文档，您继续吗',
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
        mymessage('当前文件未保存或无活动的工作簿文件！请检查。');
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
  ShellExecute(Application.Handle, 'Open', PChar(mydllpath + '科目余额表生成底稿演示视频.exe'),
    '', '', SW_SHOWNORMAL); //Application.Handle

end;

procedure TAddInModule.prevPZ(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin

  ShellExecute(Application.Handle, 'Open', PChar(mydllpath + '凭证导入抽凭演示.exe'),
    '', '', SW_SHOWNORMAL); //Application.Handle

end;

procedure TAddInModule.dbfrompzb(Sender: TObject;
  const RibbonControl: IRibbonControl);
var
  adgworkbook: dgworkbook;
begin
  if ExcelApp.Workbooks.count < 1 then
  begin
    mymessage('无正在使用的EXCEL文件，请打开文件后继续');
    Exit;
  end;

  if not sheetexists(ExcelApp, '凭证表') then
  begin

    mymessage('使用提示：' + chr(10) + chr(13) + chr(10) + chr(13) +
      '工作簿中无【凭证表】表格，无法导入数据！  建议您打开【初次使用者指南】-【凭证导入的范例表】，' + chr(10) +
      chr(13) +
      '  看系统需要导入的凭证表是怎样的格式，！' + chr(10) + chr(13)
      );
    exit;

  end;

  try
    axm := adgsystem.OPENLAST;
    adgworkbook := dgworkbook.create();
    adgworkbook.xm := axm;
    adgworkbook.excelapp := ExcelApp.Application;

    case Application.MessageBox(PChar('您确认将数据导入账套 [' + axm.xmid + ' ' + axm.xmname + ']，您继续吗？'),
      '附注提示', MB_YESNO + MB_ICONQUESTION) of
      IDYES:
        begin
          case Application.MessageBox('本操作将删除项目的原有数据，您继续吗？',
            '附注提示', MB_YESNO + MB_ICONQUESTION) of
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
  //打开初始模板
  try
    excelapp.Workbooks.Open(mydllpath + '科目余额表模板.xls'
      , EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, adxLCID
      );
  except
    mymessage('打开文件失败，请检查文件是否存在！');
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
    mymessage('无正在使用的EXCEL文件，请打开文件后继续');
    Exit;
  end;
  try
    axm := adgsystem.OPENLAST;
    adgworkbook := dgworkbook.create();
    adgworkbook.xm := axm;
    adgworkbook.excelapp := ExcelApp.Application;

    case Application.MessageBox(PChar('您确认将数据导入账套 [' + axm.xmid + ' ' + axm.xmname + ']，您继续吗？'),
      '附注提示', MB_YESNO + MB_ICONQUESTION) of
      IDYES:
        begin
          case Application.MessageBox('本操作将删除项目的原有数据，您继续吗？',
            '附注提示', MB_YESNO + MB_ICONQUESTION) of
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
  //打开初始模板
  mymessage('使用提示：' + chr(10) + chr(13) + chr(10) + chr(13) +
    '您应该将您的科目余额表调整成如下的格式后，再进入导入操作！' + chr(10) + chr(13)
    );
  try
    excelapp.Workbooks.Open(mydllpath + '科目余额表导入模板.xls'
      , EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, adxLCID
      );
  except
    mymessage('打开文件失败，请检查文件是否存在！');
    exit;
  end;
end;

procedure TAddInModule.adxRibbonTab1Controls1Controls5Controls1Click(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  //打开初始模板
  mymessage('使用提示：' + chr(10) + chr(13) + chr(10) + chr(13) +
    '您应该将您的凭证导入表调整成如下的格式后，再进入导入操作。' + chr(10) +
    chr(13)

    );

  try
    excelapp.Workbooks.Open(mydllpath + '凭证导入模板.xls'
      , EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, adxLCID
      );
  except
    mymessage('打开文件失败，请检查文件是否存在！');
    exit;
  end;
end;

procedure TAddInModule.adxRibbonTab1Controls2Controls2Controls3Click(
  Sender: TObject; const RibbonControl: IRibbonControl);
begin
  ExcelApp.Workbooks.Open(mydllpath + '交易询证函.xls', EmptyParam,
    EmptyParam, EmptyParam, EmptyParam,
    EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
    EmptyParam, EmptyParam, EmptyParam, adxLCID
    );
  mymessage('按表头规定的内容填写列表，然后在菜单中选【第二步 列表生成相应的函证或信封】来生成WORD版的函证！');
end;

initialization
  TadxFactory.Create(ComServer, Tmydgs, CLASS_mydgs, TAddInModule);

end.
