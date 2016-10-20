unit CLSexcel;

interface
uses
  Classes, ADODB, dialogs, CLSLXY, Variants, excel2000, communit,
  StrUtils, SysUtils, ushare, windows, DateUtils, IniFiles;

const
  KM7sheet = '科目表样7列';
  KM9sheet = '科目表样9列';
  PZsheet = '凭证表';

  // zdlength = '4';

type
  COLUMNSDB = record
    KMDM: INTEGER;
    KMNAME: Integer;
    KMDIRECT: INTEGER;
    QC: Integer;
    SDQC: Integer;
    JFFS: Integer;
    DFFS: Integer;
    QM: Integer;
    SDQM: Integer;
    fs: integer;
    sdfs: integer;
    qmtzjf: Integer;
    qmtzdf: Integer;
    qmcfljf: Integer;
    qmcfldf: Integer;
  end;

type
  // 记账时间 凭证种类 凭证编号 业务说明 科目名称 对方科目名称 借方发生额 贷方发生额
  column_checksheet = record
    pzdate: Integer;
    pztype: Integer;
    pznumber: Integer;
    pzmemo: Integer;
    pzkm: Integer;
    pzmirrorkm: Integer;
    pzjf: Integer;
    pzdf: Integer;
  end;

type
  createsheet = class
  private
    fxlsapp: Variant;
    function sheetexists(aname: string): boolean;
  public
    constructor create(excelapp: Variant);
    procedure create_KM7sheet(); //7列的科目余额表
    procedure create_KM9sheet(); //9列的科目余额表
    procedure create_pzb();
  end;

type
  dgsystem = class
  private
    axm: xminfo;
    CONsys: TADOConnection;
    qrytmp: tadoquery;
    syspath: string;
    function getxminfo(xmid: string): xminfo;
    procedure writetoini();
    procedure readfromini();
  public
    function OPENXM(XMID: string): XMINFO;
    procedure newxm(xm: xminfo);
    function OPENLAST(): xminfo;
    function writetomdb_baseinfo(axm: xminfo): Boolean;
    function writetomdb_EXTinfo(axm: xminfo): Boolean;
    function writetomdb_kmlen(axm: xminfo): Boolean;
    function GETALLXM(): TADOQuery;
    function getmaxxmid: string;
    function connection: TADOConnection;
  published
    property xm: xminfo read axm write axm;
    constructor create(XPATH: string);
  end;

var
  ADGSYSTEM: DGSYSTEM;

type
  dgworkbook = class
  private
    fxlsapp: variant;
    fxm: xminfo;
    fcon: TADOConnection;
    qrytmp: TADOQuery;
    TABLETMP: TADOTable;
    sheettmp: Variant;
    function getxmid: xminfo;
    procedure setXM(const Value: xminfo);
    function sheetexists(aname: string): boolean;
    function getconnection: TADOConnection;
    procedure changeconnection();
  public
    function getkmlist(): TStringList;
    procedure fill(kmlist: tstringlist);
    procedure fillall();
    procedure filltrial;
    procedure import_KMYEB7column;
    procedure import_KMYEB9column;
    procedure import_pzsheet;
    procedure import_DXNSHEET;
    constructor create();
  published
    property excelapp: variant read fxlsapp write fxlsapp;
    property xm: xminfo read getxmid write setXM;
    property connection: TADOConnection read getconnection;
  end;

type
  fillsheet = interface //填充一个表格
    ['{7F2FC1B8-E414-4304-9920-5CD6E391A3FC}']
    procedure fill();
    procedure query();
  end;

type
  importsheet = interface //填充一个表格
    ['{9B52ADBA-8A3D-4440-AA8D-67B567E53604}']
    procedure import();
  end;

type
  tomdb = class(TInterfacedObject, importsheet)

  private
    qrytmp: TADOQuery;
    tabletmp: TADOTable;
    fxlsapp: Variant;
    axm: xminfo;
    lengthof_onelevel: Integer;
    function getquery: TADOQuery;
    procedure setquery(const Value: TADOQuery);
    function getxlsapp: Variant;
    procedure setxlsapp(const Value: Variant);
    function getxm: xminfo;
    procedure setxm(const Value: xminfo);
    function getfieldlength: integer;
    procedure LONGkmname();
  published
    property adoquery: TADOQuery read getquery write setquery;
    property excelapp: Variant read getxlsapp write setxlsapp;
    property xm: xminfo read getxm write setxm;
  public
    procedure import();
    constructor create(xlsapp: Variant; qry: TADOQuery; TB: TADOTABLE);
  end;

type
  import_kmyeb7 = class(tomdb, importsheet)

  private
    procedure import7col();

  public
    procedure import();
  end;

type
  import_kmyeb9 = class(tomdb, importsheet)
  private
    procedure import9col();
  public
    procedure import();
  end;

type
  import_dxn = class(tomdb, importsheet)
  private
    procedure importdxn();
    procedure DOsql(sqltext: string);
  public
    procedure import();
  end;

type
  import_PZB = class(tomdb, importsheet)
  private
    procedure importPZB();
    procedure editFILEDSTR(ATABLE: TADOTable; FIELDNAME: string; VALUE:
      Variant);
    procedure editFILEDnumber(ATABLE: TADOTable; FIELDNAME: string; VALUE:
      Variant);
  public
    procedure import();
  end;

type
  dgsheet = class(TInterfacedObject, fillsheet)
  private
    qrytmp: tadoquery;
    fxlsapp: Variant;
    fxm: xminfo;
    FDGfilename: string;
    mydirect: string;
    procedure setadoquery(const Value: tadoquery);
    procedure setEXCELapp(const Value: Variant);
  public
    procedure fill(); virtual;
    procedure query();
  published
    property adoquery: tadoquery write setadoquery;
    property excelapp: Variant write setEXCELapp;
    property xm: xminfo read fxm write fxm;
    property DGFILENAME: string write fdgFILENAME;
    property direction: string read mydirect write mydirect;
  end;

type
  SDSHEET = class(dgsheet, fillsheet)
  private
    function sdb_xmcolumn_num(asheet: Variant;
      commandline: Integer; columncount: integer): COLUMNsdb;
  public
    procedure fill();
    procedure query();
  published
  end;

type
  MXBSHEET = class(dgsheet, fillsheet)
  private
    function MXB_xmcolumn_num(asheet: Variant;
      commandline: Integer; columncount: integer): COLUMNSDB;
  public
    procedure fill();
    procedure query();
  published
  end;

type
  checkSHEET = class(dgsheet, fillsheet)
  private
    function check_xmcolumn_num(asheet: Variant;
      commandline: Integer; columncount: integer): column_checksheet;
  public
    procedure fill();
    procedure query();
  published
  end;

implementation

{ dgsystem }

function dgsystem.getmaxxmid: string;
var
  xid: integer;
begin
  //
  result := '0001';
  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('select max(xmid) as xid from 底稿单位');
  qrytmp.Open;

  if qrytmp.RecordCount > 0 then
  begin
    xid := StrToInt(qrytmp.fieldbyname('xid').AsString) + 1;
    result := rightstr('0000' + trim(IntToStr(xid)), 4);
  end
  else
    result := '0001';
end;

constructor dgsystem.create(xpath: string);
var
  ausername, apassword, filename: string;
begin
  syspath := XPATH;
  ausername := 'admin';
  apassword := '';
  if RightStr(Trim(xpath), 1) = '\' then
    filename := xpath + 'dg.mdb'
  else
    filename := xpath + '\dg.mdb';

  CONsys := TADOConnection.Create(nil);
  CONsys.LoginPrompt := FALSE;
  consys.ConnectionString := 'Provider=Microsoft.Jet.OLEDB.4.0;' +
    'User ID=' + AUserName + ';' +
    'Jet OLEDB:Database Password=' + APassword + ';' +
    'Data Source=' + filename + ';' +
    'Mode=ReadWrite;' +
    'Extended Properties="";';
  consys.Connected := true;

  qrytmp := TADOQuery.Create(nil);
  qrytmp.Connection := CONsys;
  qrytmp.Close;
end;

function dgsystem.writetomdb_baseinfo(axm: xminfo): Boolean;
var
  tb: TADOTable;
begin

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('select * from mb where mbid=''' + Trim(axm.mbid) + '''');
  qrytmp.Open;
  axm.MBNAME := qrytmp.FIELDBYNAME('MBNAME').AsString;

  if RightStr(Trim(syspath), 1) = '\' then
    axm.mbpath := syspath + qrytmp.FIELDBYNAME('MBPATH').AsString
  else
    axm.mbpath := syspath + '\' + qrytmp.FIELDBYNAME('MBPATH').AsString;

  tb := TADOTable.Create(nil);
  tb.Connection := CONsys;

  tb.TableName := '底稿单位';
  tb.Open;

  tb.Append;
  tb.FieldByName('xmid').AsString := axm.xmid;
  tb.FieldByName('xmmc').AsString := axm.XMNAME;
  tb.FieldByName('dwmc').AsString := axm.dwmc;

  tb.FieldByName('startrq').AsDateTime := axm.startrq;
  tb.FieldByName('endrq').AsDateTime := axm.endrq;
  tb.FieldByName('path').AsString := axm.xmpath;

  if (MonthOf(axm.startrq) = 1) and (MonthOf(axm.endrq) = 12)
    and (YEAROf(axm.startrq) = YEAROf(axm.endrq)) then
    axm.yeard := IntToStr(YEAROf(axm.endrq)) + '年度'
  else
    axm.yeard := IntToStr(YEAROf(axm.startrq)) + '年' +
      IntToStr(monthOf(axm.startrq)) + '月' + '至' +
      IntToStr(YEAROf(axm.endrq)) + '年' + IntToStr(monthOf(axm.endrq)) + '月';

  tb.FieldByName('起止时间').AsString := axm.yeard;

  tb.FieldByName('mbid').AsString := axm.mbid;
  tb.FieldByName('mbNAME').AsString := axm.MBNAME;
  tb.FieldByName('mbPATH').AsString := axm.MBPATH;
  //  tb.FieldByName('isbusy').AsBoolean := true;
  tb.Post;

  try
    if not DirectoryExists(axm.xmpath) then
      forceDirectories(axm.xmpath);
  except
  end;

  qrytmp.Close;
  qrytmp.sql.Clear;
  qrytmp.SQL.add('UPDATE  底稿单位 SET ISBUSY=FALSE');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.sql.Clear;
  qrytmp.SQL.add('UPDATE  底稿单位 SET ISBUSY=TRUE');
  qrytmp.SQL.Add(' WHERE  trim(xmid)=''' + trim(axm.xmid) + '''');
  qrytmp.ExecSQL;

  tb.Close;
  tb.Free;
  tb := nil;
end;

function dgsystem.writetomdb_EXTinfo(axm: xminfo): BOOLEAN;
begin

  RESULT := FALSE;
  //  ID	XMID	xmmc	dwdm	dwmc	startrq	endrq	mbid	起止时间	编制人	审核人	编制日期	审核日期	path	mbpath	项目备注
//27	0015	新汇尔杰2014		襄阳汇尔玻璃纤维有限责任公司
  try
    qrytmp.Close;
    qrytmp.sql.Clear;
    qrytmp.SQL.add('select * from 底稿单位');
    qrytmp.SQL.Add(' WHERE  xmid=''' + trim(axm.xmid) + '''');
    qrytmp.open;

    if qrytmp.RecordCount > 0 then
    begin
      qrytmp.Close;
      qrytmp.sql.Clear;
      qrytmp.SQL.add('update  底稿单位 set 	dwmc=:dwmc,startrq= :startrq,endrq=:endrq,');
      qrytmp.SQL.add('	起止时间=:yeard ,	编制人=:editor,	审核人=:checkor,	编制日期 =:editrq,	审核日期=:checkrq');
      qrytmp.SQL.Add(' WHERE  xmid=''' + trim(axm.xmid) + '''');
      qrytmp.Parameters.ParamByName('dwmc').Value := axm.dwmc;
      qrytmp.Parameters.ParamByName('startrq').Value := axm.startrq;
      qrytmp.Parameters.ParamByName('endrq').Value := axm.endrq;
      qrytmp.Parameters.ParamByName('yeard').Value := axm.yeard;
      qrytmp.Parameters.ParamByName('editor').Value := axm.editor;
      qrytmp.Parameters.ParamByName('checkor').Value := axm.checkor;
      qrytmp.Parameters.ParamByName('editrq').Value := axm.editrq;
      qrytmp.Parameters.ParamByName('checkrq').Value := axm.checkRQ;
      qrytmp.ExecSQL;
      RESULT := TRUE;
    end
  except
    RESULT := False;
  end;
end;

function dgsystem.getxminfo(xmid: string): xminfo;
begin
  //
//  ID	XMID	xmmc	dwdm	dwmc	startrq	endrq	mbid	起止时间	编制人	审核人	编制日期	审核日期	path	mbpath	项目备注
//27	0015	新汇尔杰2014		襄阳汇尔玻璃纤维有限责任公司

  qrytmp.Close;
  qrytmp.sql.Clear;
  qrytmp.SQL.add('select * from 底稿单位');
  qrytmp.SQL.Add(' WHERE  xmid=''' + trim(xmid) + '''');
  qrytmp.open;
  if qrytmp.RecordCount > 0 then
  begin
    axm.xmid := qrytmp.fieldbyname('xmid').AsString;
    axm.XMNAME := qrytmp.fieldbyname('XMMC').AsString;
    axm.dwmc := qrytmp.fieldbyname('dwmc').AsString;
    axm.kmlen := qrytmp.fieldbyname('kmlen').AsInteger;

    axm.startrq := qrytmp.fieldbyname('startrq').AsDateTime;
    axm.endrq := qrytmp.fieldbyname('ENDrq').AsDateTime;
    axm.yeard := qrytmp.fieldbyname('起止时间').AsString;
    axm.xmpath := qrytmp.fieldbyname('path').ASSTRING;

    axm.MBID := qrytmp.fieldbyname('MBID').AsString;
    axm.MBNAME := qrytmp.fieldbyname('MBNAME').AsString;
    axm.mbpath := qrytmp.fieldbyname('mbpath').AsString;

    axm.editor := qrytmp.fieldbyname('编制人').AsString;
    axm.checkor := qrytmp.fieldbyname('审核人').AsString;
    axm.editrq := qrytmp.fieldbyname('编制日期').AsDateTime;
    axm.checkRQ := qrytmp.fieldbyname('审核日期').AsDateTime;
  end
  else
    axm.dwmc := '';
  RESULT := axm;
end;

procedure dgsystem.newxm(xm: xminfo);
begin
  //
  AXM := XM;
  writetomdb_baseinfo(axm);
end;

procedure dgsystem.readfromini;
var
  Ini: TIniFile;
  afilename: string;
begin
  afilename := axm.xmpath + '\reg.ini';
  Ini := TIniFile.Create(AFileName);
  if not fileexists(afilename) then
  begin
    axm.xmid := '';
  end
  else
  begin
    try
      //      axm.xmid := Ini.ReadString('项目信息', 'ID', '');
      //      axm.xmname := Ini.ReadString('项目信息', 'xmname', '');
      //      axm.xmpath := Ini.ReadString('项目信息', 'xmpath', '');
      //      axm.mbname := Ini.ReadString('项目信息', 'mbname', '');
      //      axm.mbpath := Ini.ReadString('项目信息', 'mbpath', '');
      //      axm.dwmc := Ini.ReadString('项目信息', 'dwmc', '');
      //      axm.mbid := Ini.ReadString('项目信息', 'mbid', '');
      //      axm.MBNAME := Ini.ReadString('项目信息', 'MBNAME', '');
      //      axm.dwmc := Ini.ReadString('项目信息', 'dwmc', '');
      //      axm.startrq := Ini.ReadDate('项目信息', 'startrq', StartOfAYear(YearOf(now) - 1));
      //      axm.endrq := Ini.ReadDate('项目信息', 'endrq', endOfAYear(YearOf(now) - 1));
      //      axm.yeard := Ini.ReadString('项目信息', 'yeard', '');
      //      axm.editor := Ini.ReadString('项目信息', 'editor', '');
      //      axm.checkor := Ini.ReadString('项目信息', 'checkor', '');
      //      axm.editrq := Ini.ReadDate('项目信息', 'editrq', today());
      //      axm.checkRQ := Ini.ReadDate('项目信息', 'checkRQ', today());
    except
    end;
  end;
  Ini.Free;

end;

function dgsystem.OPENXM(XMID: string): XMINFO;
begin
  //
  RESULT := AXM;
  qrytmp.Close;
  qrytmp.sql.Clear;
  qrytmp.SQL.add('UPDATE  底稿单位 SET ISBUSY=FALSE');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.sql.Clear;
  qrytmp.SQL.add('UPDATE  底稿单位 SET ISBUSY=TRUE');
  qrytmp.SQL.Add(' WHERE  xmid=''' + trim(xmid) + '''');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.sql.Clear;
  qrytmp.SQL.add('select * from 底稿单位');
  qrytmp.SQL.Add(' WHERE  xmid=''' + trim(xmid) + '''');
  qrytmp.open;

  if qrytmp.RecordCount > 0 then
  begin
    getxminfo(XMID);

    RESULT := AXM;
  end;
end;

procedure dgsystem.writetoini;
//var
//  Ini: TIniFile;
//  AFileName: string;
begin
  //  AFileName := AXM.XMPATH + '\REG.INI';
  //  Ini := TIniFile.Create(AFileName);
  //  Ini.WriteString('项目信息', 'ID', axm.XMID);
  //  Ini.WriteString('项目信息', 'xmname', axm.xmname);
  //  Ini.WriteString('项目信息', 'xmpath', axm.xmpath);
  //  Ini.WriteString('项目信息', 'mbname', axm.mbname);
  //  Ini.WriteString('项目信息', 'mbpath', axm.mbpath);
  //  Ini.WriteString('项目信息', 'dwmc', axm.dwmc);
  //  Ini.WriteString('项目信息', 'mbid', axm.mbid);
  //
  //  Ini.WriteString('项目信息', 'dwmc', axm.dwmc);
  //  Ini.WriteDate('项目信息', 'startrq', axm.startrq);
  //  Ini.WriteDate('项目信息', 'endrq', axm.endrq);
  //  Ini.WriteString('项目信息', 'yeard', axm.yeard);
  //  Ini.WriteString('项目信息', 'editor', axm.editor);
  //  Ini.WriteString('项目信息', 'checkor', axm.checkor);
  //  Ini.WriteDate('项目信息', 'editrq', axm.editrq);
  //  Ini.WriteDate('项目信息', 'checkRQ', axm.checkRQ);
  //  Ini.Free;
end;

function dgsystem.OPENLAST(): xminfo;
begin
  //
  RESULT := AXM;
  qrytmp.Close;
  qrytmp.sql.Clear;
  qrytmp.SQL.add('select * from 底稿单位');
  qrytmp.SQL.Add(' WHERE ISBUSY=TRUE');
  qrytmp.open;

  if qrytmp.RecordCount > 0 then
    RESULT := getxminfo(qrytmp.FIELDBYNAME('XMID').AsString);
end;

function dgsystem.GETALLXM: TADOQuery;
begin
  //

  if qrytmp = nil then
    qrytmp := TADOQUERY.CREATE(nil);
  if qrytmp.ACTIVE then
    qrytmp.CLOSE;
  qrytmp.Connection := CONsys;
  qrytmp.Close;
  qrytmp.sql.Clear;
  qrytmp.SQL.add('select * from 底稿单位');
  qrytmp.open;
  RESULT := qrytmp;
end;

function dgsystem.connection: TADOConnection;
begin
  //
  result := CONsys;
end;

function dgsystem.writetomdb_kmlen(axm: xminfo): Boolean;
begin
  RESULT := FALSE;

  try
    qrytmp.Close;
    qrytmp.sql.Clear;
    qrytmp.SQL.add('select * from 底稿单位');
    qrytmp.SQL.Add(' WHERE  xmid=''' + trim(axm.xmid) + '''');
    qrytmp.open;

    if qrytmp.RecordCount > 0 then
    begin
      qrytmp.Close;
      qrytmp.sql.Clear;
      qrytmp.SQL.add('update  底稿单位 set 	kmlen=:kmlen');
      qrytmp.SQL.Add(' WHERE  xmid=''' + trim(axm.xmid) + '''');
      qrytmp.Parameters.ParamByName('kmlen').Value := axm.kmlen;
      qrytmp.ExecSQL;
      RESULT := TRUE;
    end
  except
    RESULT := False;
  end;
end;

{ dgworkbook }

procedure dgworkbook.setXM(const Value: xminfo);

begin
  fxm := VALUE;
  changeconnection;

end;

function dgworkbook.getxmid: xminfo;
begin
  result := fxm;
end;

procedure dgworkbook.fill(kmlist: tstringlist);
var
  i, j: integer;
  dgname, dgfx: string;
  SJ1: tdatetime;
  pos1: integer;
  aworkbook: Variant;
  asdsheet: sdsheet;
  AMXBSHEET: MXBSHEET;
  achecksheet: checkSHEET;
begin
  //
  qrytmp.Connection := fcon;

  SJ1 := NOW();
  if not DirectoryExists(fxm.xmpath) then
  begin
    forceDirectories(fxm.xmpath);
  end;
  asdsheet := sdsheet.create;
  asdsheet.fxm := fxm;
  asdsheet.fxlsapp := fxlsapp;
  asdsheet.qrytmp := qrytmp;

  AMXBSHEET := MXBSHEET.Create;
  AMXBSHEET.fxm := fxm;
  AMXBSHEET.fxlsapp := fxlsapp;
  AMXBSHEET.qrytmp := qrytmp;

  achecksheet := checkSHEET.Create;
  achecksheet.fxm := fxm;
  achecksheet.fxlsapp := fxlsapp;
  achecksheet.qrytmp := qrytmp;

  fxlsapp.DISPLAYALERTS := false;
  for i := 0 to kmlist.Count - 1 do
  begin
    pos1 := Pos('>>', kmlist[i]);
    dgname := Trim(Copy(kmlist[i], 1, pos1 - 1));
    dgfx := Trim(Copy(kmlist[i], pos1 + 2, Length(kmlist[i])));

    aworkbook := fxlsapp.workbooks.open(fxm.mbpath + '\' + dgname, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, 0);

    for j := 1 to aworkbook.sheets.count do
    begin

      if trim(fxlsapp.activeworkbook.sheets.item[j].name) = '审定表' then
      begin
        fxlsapp.activeworkbook.sheets.item[j].activate;
        //     sheettmp := fxlsapp.activeworkbook.sheets.item['审定表'];
        sheettmp := fxlsapp.activeworkbook.activesheet;

        asdsheet.FDGfilename := dgname;
        asdsheet.mydirect := dgfx;
        asdsheet.query;
        asdsheet.fill;
      end;

      if (Pos('账项明细表', fxlsapp.activeworkbook.sheets.item[j].name) > 0)
        or (trim(fxlsapp.activeworkbook.sheets.item[j].name) = '明细表') then
      begin
        fxlsapp.activeworkbook.sheets.item[j].activate;
        sheettmp := fxlsapp.activeworkbook.activesheet;
        AMXBSHEET.FDGfilename := dgname;
        AMXBSHEET.mydirect := dgfx;
        AMXBSHEET.query;
        AMXBSHEET.fill;
      end;

      if (Pos('检查情况表', fxlsapp.activeworkbook.sheets.item[j].name) > 0)
        then
      begin
        fxlsapp.activeworkbook.sheets.item[j].activate;
        sheettmp := fxlsapp.activeworkbook.activesheet;
        achecksheet.FDGfilename := dgname;
        achecksheet.mydirect := dgfx;
        achecksheet.query;
        achecksheet.fill;
      end;

    end;

    lxyexcel.replace_allsheet(fxlsapp.activeworkbook, fxm);

    fxlsapp.ActiveWorkbook.SaveAs(fxm.xmpath + '\' + dgname, EmptyParam,
      EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, xlExclusive, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, 0);
    fxlsapp.ActiveWorkbook.CLOSE;
  end;
  fxlsapp.DISPLAYALERTS := true;

  asdsheet.free;
  AMXBSHEET.free;
  achecksheet.free;
end;

constructor dgworkbook.create;
begin
  qrytmp := TADOQuery.Create(nil);
  FCON := TADOConnection.Create(nil);
  qrytmp.CONNECTION := FCON;
  TABLETMP := TADOTable.Create(nil);
  TABLETMP.Connection := fcon;
end;

function dgworkbook.getkmlist: TStringList;
var
  qrytmp: tadoquery;
  dgnames: TStringList;
begin
  dgnames := TStringList.Create;
  RESULT := dgnames;

  if fcon.Connected = false then
    exit;

  qrytmp := tadoquery.create(nil);
  qrytmp.connection := fcon;
  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('select  min(底稿名称) as 底稿名称 ,min(借贷方向) as 借贷方向  from 项目对应关系  where  not 底稿名称 is null ');
  qrytmp.SQL.Add('  and xmid=''' + trim(axm.xmid) +
    '''  group by 底稿名称 order by 底稿名称');
  qrytmp.Open;

  qrytmp.First;
  while not qrytmp.Eof do
  begin
    dgnames.Add(qrytmp.fieldbyname('底稿名称').AsString + '  >>' +
      trim(qrytmp.fieldbyname('借贷方向').AsString));
    qrytmp.Next;
  end;
  qrytmp.close;
  RESULT := dgnames;
end;

function dgworkbook.sheetexists(aname: string): boolean;
var
  i: Integer;
begin
  //  表名是否存在
  result := False;
  for i := 1 to fxlsapp.ActiveWorkbook.Sheets.count do
  begin
    if aname = Trim(fxlsapp.ActiveWorkbook.Sheets.Item[i].name) then
    begin
      Result := true;
      Exit;
    end;
  end;

end;

procedure dgworkbook.import_KMYEB7column;
var
  AIMPORT: import_kmyeb7;
begin
  //

  TABLETMP.Connection := fcon;
  AIMPORT := import_kmyeb7.create(fxlsapp, qrytmp, TABLETMP);
  AIMPORT.xm := fxm;
  AIMPORT.import;
end;

function dgworkbook.getconnection: TADOConnection;
begin
  //
  result := fcon;
end;

procedure dgworkbook.import_KMYEB9column;
var
  AIMPORT: import_kmyeb9;
begin
  //
  TABLETMP.Connection := fcon;
  AIMPORT := import_kmyeb9.create(fxlsapp, qrytmp, TABLETMP);
  AIMPORT.xm := fxm;
  AIMPORT.import;
end;

procedure dgworkbook.fillall;
var
  i, j: integer;
  dgname, dgfx: string;
  SJ1: tdatetime;
  pos1: integer;
  aworkbook: Variant;
  asdsheet: sdsheet;
  AMXBSHEET: MXBSHEET;
  qrydg: tadoquery;
begin
  if fcon.Connected = false then
    exit;

  qrydg := tadoquery.create(nil);
  qrydg.connection := fcon;
  qrydg.Close;
  qrydg.SQL.Clear;
  qrydg.SQL.Add('select  min(底稿名称) as 底稿名称,min(借贷方向) as 借贷方向  from 项目对应关系  where  not 底稿名称 is null ');
  qrydg.SQL.Add('  and xmid=''' + trim(fxm.xmid) +
    '''  group by 底稿名称 order by 底稿名称');
  qrydg.Open;

  SJ1 := NOW();
  if not DirectoryExists(fxm.xmpath) then
  begin
    forceDirectories(fxm.xmpath);
  end;
  asdsheet := sdsheet.create;
  asdsheet.fxm := fxm;
  asdsheet.fxlsapp := fxlsapp;
  asdsheet.qrytmp := qrytmp;

  AMXBSHEET := MXBSHEET.Create;
  AMXBSHEET.fxm := fxm;
  AMXBSHEET.fxlsapp := fxlsapp;
  AMXBSHEET.qrytmp := qrytmp;

  fxlsapp.DISPLAYALERTS := false;
  qrydg.First;
  for i := 1 to qrydg.RecordCount do
  begin
    dgname := qrydg.fieldbyname('底稿名称').asstring;
    dgfx := qrydg.fieldbyname('借贷方向').asstring;

    aworkbook := fxlsapp.workbooks.open(fxm.mbpath + '\' + dgname, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, 0);

    for j := 1 to aworkbook.sheets.count do
    begin

      try
        if trim(fxlsapp.activeworkbook.sheets.item[j].name) = '审定表' then
        begin
          fxlsapp.activeworkbook.sheets.item[j].activate;
          sheettmp := fxlsapp.activeworkbook.activesheet;

          asdsheet.FDGfilename := dgname;
          asdsheet.mydirect := dgfx;
          asdsheet.query;
          asdsheet.fill;
        end;
      except
      end;

      try
        if (Pos('账项明细表', fxlsapp.activeworkbook.sheets.item[j].name) > 0)
          or (trim(fxlsapp.activeworkbook.sheets.item[j].name) = '明细表') then
        begin
          fxlsapp.activeworkbook.sheets.item[j].activate;
          sheettmp := fxlsapp.activeworkbook.activesheet;
          AMXBSHEET.FDGfilename := dgname;
          AMXBSHEET.mydirect := dgfx;
          AMXBSHEET.query;
          AMXBSHEET.fill;
        end;
      except
      end;

    end;

    try
      lxyexcel.replace_allsheet(fxlsapp.activeworkbook, fxm);
    except
    end;

    fxlsapp.ActiveWorkbook.SaveAs(fxm.xmpath + '\' + dgname, EmptyParam,
      EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, xlExclusive, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, 0);
    fxlsapp.ActiveWorkbook.CLOSE;

    qrydg.Next;
  end;
  fxlsapp.DISPLAYALERTS := true;
  qrydg.close;
  qrydg.free;
  qrydg := nil;
end;

procedure dgworkbook.filltrial;
var
  i, j: integer;
  dgname, dgfx: string;
  SJ1: tdatetime;
  pos1: integer;
  aworkbook: Variant;
  asdsheet: sdsheet;
  AMXBSHEET: MXBSHEET;
  qrydg: tadoquery;
begin
  if fcon.Connected = false then
    exit;

  qrydg := tadoquery.create(nil);
  qrydg.connection := fcon;
  qrydg.Close;
  qrydg.SQL.Clear;
  qrydg.SQL.Add('select  min(底稿名称) as 底稿名称,min(借贷方向) as 借贷方向  from 项目对应关系  where  not 底稿名称 is null ');
  qrydg.SQL.Add('  and xmid=''' + trim(fxm.xmid) +
    '''  group by 底稿名称 order by 底稿名称');
  qrydg.Open;

  SJ1 := NOW();
  if not DirectoryExists(fxm.xmpath) then
  begin
    forceDirectories(fxm.xmpath);
  end;
  asdsheet := sdsheet.create;
  asdsheet.fxm := fxm;
  asdsheet.fxlsapp := fxlsapp;
  asdsheet.qrytmp := qrytmp;

  AMXBSHEET := MXBSHEET.Create;
  AMXBSHEET.fxm := fxm;
  AMXBSHEET.fxlsapp := fxlsapp;
  AMXBSHEET.qrytmp := qrytmp;

  fxlsapp.DISPLAYALERTS := false;
  qrydg.First;
  for i := 1 to 4 do
  begin
    dgname := qrydg.fieldbyname('底稿名称').asstring;
    dgfx := qrydg.fieldbyname('借贷方向').asstring;

    aworkbook := fxlsapp.workbooks.open(fxm.mbpath + '\' + dgname, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, 0);

    for j := 1 to aworkbook.sheets.count do
    begin

      try
        if trim(fxlsapp.activeworkbook.sheets.item[j].name) = '审定表' then
        begin
          fxlsapp.activeworkbook.sheets.item[j].activate;
          sheettmp := fxlsapp.activeworkbook.activesheet;

          asdsheet.FDGfilename := dgname;
          asdsheet.mydirect := dgfx;
          asdsheet.query;
          asdsheet.fill;
        end;
      except
      end;

      try
        if (Pos('账项明细表', fxlsapp.activeworkbook.sheets.item[j].name) > 0)
          or (trim(fxlsapp.activeworkbook.sheets.item[j].name) = '明细表') then
        begin
          fxlsapp.activeworkbook.sheets.item[j].activate;
          sheettmp := fxlsapp.activeworkbook.activesheet;
          AMXBSHEET.FDGfilename := dgname;
          AMXBSHEET.mydirect := dgfx;
          AMXBSHEET.query;
          AMXBSHEET.fill;
        end;
      except
      end;

    end;

    try
      lxyexcel.replace_allsheet(fxlsapp.activeworkbook, fxm);
    except
    end;

    fxlsapp.ActiveWorkbook.SaveAs(fxm.xmpath + '\' + dgname, EmptyParam,
      EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, xlExclusive, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, 0);
    fxlsapp.ActiveWorkbook.CLOSE;

    qrydg.Next;
  end;
  fxlsapp.DISPLAYALERTS := true;
  qrydg.close;
  qrydg.free;
  qrydg := nil;
end;

procedure dgworkbook.import_pzsheet;
var
  AIMPORT: import_PZB;
begin
  //
  TABLETMP.Connection := fcon;
  AIMPORT := import_PZB.create(fxlsapp, qrytmp, TABLETMP);
  AIMPORT.xm := fxm;
  AIMPORT.import;
end;

procedure dgworkbook.changeconnection;
var
  ausername, apassword, filename: string;
begin
  ausername := 'admin';
  apassword := '';
  if RightStr(Trim(fxm.xmpath), 1) = '\' then
    filename := fxm.xmpath + 'dg.mdb'
  else
    filename := fxm.xmpath + '\dg.mdb';

  if FileExists(FILENAME) then
  begin
    fcon.Connected := false;
    fcon := TADOConnection.Create(nil);
    fcon.LoginPrompt := FALSE;
    fcon.ConnectionString := 'Provider=Microsoft.Jet.OLEDB.4.0;' +
      'User ID=' + AUserName + ';' +
      'Jet OLEDB:Database Password=' + APassword + ';' +
      'Data Source=' + filename + ';' +
      'Mode=ReadWrite;' +
      'Extended Properties="";';
    fcon.Connected := true;
    qrytmp.Connection := fcon;
    TABLETMP.Connection := fcon;
  end
  else
  begin
    mymessage('数据库不存在，或者项目建立错误 ');
    exit;
  end;
end;

procedure dgworkbook.import_DXNSHEET;
var
  AIMPORT: IMPORT_DXN;
begin
  //
  TABLETMP.Connection := fcon;
  AIMPORT := IMPORT_DXN.create(fxlsapp, qrytmp, TABLETMP);
  AIMPORT.xm := fxm;
  AIMPORT.import;
end;

{dgsheet}

procedure dgsheet.query;
begin
  //
end;

procedure dgSHEET.fill;
begin
  //
end;

procedure dgsheet.setadoquery(const Value: tadoquery);
begin
  qrytmp := value;
end;

procedure dgsheet.setEXCELapp(const Value: Variant);
begin
  fxlsapp := value;
end;

{ tomdb }

constructor tomdb.create(xlsapp: Variant; qry: TADOQuery; TB: TADOTABLE);
begin
  //
  fxlsapp := xlsapp;
  qrytmp := qry;
  tabletmp := TB;
end;

function tomdb.getquery: TADOQuery;
begin
  result := qrytmp;
end;

function tomdb.getxlsapp: Variant;
begin
  result := fxlsapp;
end;

function tomdb.getxm: xminfo;
begin
  result := axm;
end;

procedure tomdb.import;
begin

end;

procedure tomdb.setquery(const Value: TADOQuery);
begin
  qrytmp := value;
end;

procedure tomdb.setxlsapp(const Value: Variant);
begin
  fxlsapp := value;
end;

procedure tomdb.setxm(const Value: xminfo);
begin
  axm := value;
end;

function tomdb.getfieldlength: integer;
var
  flen: integer;

begin
  //
  result := -1;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('delete from dg7 where   len(trim(代码))=0  ');
  qrytmp.execsql;

  try
    qrytmp.Close;
    qrytmp.SQL.Clear;
    qrytmp.SQL.Add('select min(len(代码)) as zdlen from dg7 ');
    qrytmp.SQL.Add(' WHERE xmid=''' + trim(axm.xmid) + '''  and len(代码)>0');
    qrytmp.open;
    result := qrytmp.fieldbyname('zdlen').AsInteger;
    flen := qrytmp.fieldbyname('zdlen').AsInteger;
    qrytmp.close;
    axm.kmlen := flen;
  except
    result := -1;
  end;

end;

procedure tomdb.LONGkmname;
var
  len1, len2: integer;
  str: string;
  iseof: Boolean;
  onelevel_km: string;
  strkm: string;
begin
  //
  lengthof_onelevel := getfieldlength;
  if tabletmp.Active then
    tabletmp.Close;
  tabletmp.TableName := 'dg7';
  tabletmp.Filter := 'xmid=''' + axm.xmid + '''';

  tabletmp.open;
  tabletmp.Sort := 'id';
  tabletmp.Filtered := true;
  tabletmp.Sort := '代码';
  tabletmp.first;
  iseof := false;
  len1 := Length(trim(tabletmp.fieldbyname('代码').AsString));
  onelevel_KM := '';
  while not tabletmp.eof do
  begin
    if (len1 = lengthof_onelevel) then
    begin
      onelevel_KM := trim(tabletmp.fieldbyname('代码').AsString);
    end;

    tabletmp.Next;
    len2 := Length(trim(tabletmp.fieldbyname('代码').AsString));
    if tabletmp.eof then
    begin
      len2 := -1;
      iseof := true;
    end;

    tabletmp.Prior;

    if (len2 < len1) then
    begin
      try
        tabletmp.edit;
        tabletmp.fieldbyname('长科目名').AsString := str + '\' +
          trim(tabletmp.fieldbyname('科目名称').AsString);
        tabletmp.Post;
      except
      end;
      str := '';
    end
    else if (len2 > len1) then
    begin
      str := str + '\' + trim(tabletmp.fieldbyname('科目名称').AsString);
    end
    else if (len2 = len1) then
    begin
      try
        tabletmp.edit;
        tabletmp.fieldbyname('长科目名').AsString := str + '\' +
          trim(tabletmp.fieldbyname('科目名称').AsString);
        tabletmp.Post;
      except
      end;
    end;

    try
      tabletmp.edit;
      tabletmp.fieldbyname('一级科目代码').AsString := onelevel_KM;
      tabletmp.Post;
    except
    end;

    if iseof then
      Break;
    tabletmp.next;
    len1 := Length(trim(tabletmp.fieldbyname('代码').AsString));
  end;

  //

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('delete from 项目对应关系 where xmid=''' + trim(axm.xmid) +
    '''');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('delete from  dg7  where  代码  in (');
  qrytmp.SQL.Add(' select 代码 from dg7 where len(trim(代码)) =' +
    inttostr(lengthof_onelevel) +
    'and  核算项目名称 is null and 期初=0 and 期末=0 and 借方发生=0 and 贷方发生=0 and xmid=''' +
    trim(axm.xmid) +
    '''');
  qrytmp.SQL.Add(')');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('insert into 项目对应关系(xmid,代码,科目名称,借贷方向)');
  qrytmp.SQL.Add('  select  xmid,代码,科目名称,借贷方向 from dg7 where len(代码)=' + inttostr(lengthof_onelevel));
  qrytmp.SQL.Add(' AND  xmid=''' + trim(axm.xmid) + '''');
  qrytmp.ExecSQL;
  qrytmp.Close;

  if tabletmp.Active then
    tabletmp.Close;
  tabletmp.TableName := '项目对应关系';
  tabletmp.Filter := 'xmid=''' + trim(axm.xmid) + '''';
  tabletmp.open;
  tabletmp.Filtered := true;

  tabletmp.First;
  while not tabletmp.Eof do
  begin
    strkm := Trim(tabletmp.fieldbyname('科目名称').AsString);
    qrytmp.Close;
    qrytmp.SQL.Clear;
    qrytmp.SQL.Add('select 底稿名称  from  科目底稿对应表 where 科目名称 like ''%' + strkm + '%'' ');
    qrytmp.SQL.Add('and MBid=''' + trim(axm.MBid) + '''');
    qrytmp.open;
    if qrytmp.RecordCount > 0 then
    begin
      try
        tabletmp.Edit;
        tabletmp.FieldByName('底稿名称').AsString :=
          qrytmp.FieldByName('底稿名称').AsString;
        tabletmp.Post;
      except
      end;
    end;
    tabletmp.Next;
  end;

end;

{ import_kmyeb7 }

procedure import_kmyeb7.import;
begin
  //
  import7col;
  LONGkmname;
  getfieldlength;
  mymessage('导入成功！');
end;

procedure import_kmyeb7.import7col;
var
  rowscount, colscount: Integer;
  varrykm: Variant;
  i, j: integer;
  sheettmp: Variant;
begin
  //
  try
    sheettmp := fxlsapp.activeworkbook.sheets.item[km7sheet];
    sheettmp.select;
  except
    mymessage('对不起，您的工作簿中无【科目表样9列】表，请执行第二步进行建立！');
    exit;
  end;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('delete from dg7  where xmid=''' + trim(axm.xmid) + '''');
  qrytmp.ExecSQL;
  qrytmp.close;

  lxyexcel.fillzero(sheettmp, 4);
  lxyexcel.fillzero(sheettmp, 5);
  lxyexcel.fillzero(sheettmp, 6);
  lxyexcel.fillzero(sheettmp, 7);
  rowscount := sheettmp.usedrange.rows.count;
  colscount := sheettmp.usedrange.columns.count;

  varrykm := sheettmp.Range[sheettmp.cells.Item[2, 1],
    sheettmp.cells.Item[rowscount, colscount]].Value;

  if tabletmp.Active then
    tabletmp.Close;
  tabletmp.TableName := 'dg7';
  tabletmp.open;
  for i := 1 to rowscount - 1 do
  begin
    if Trim(varrykm[i, 1]) <> '' then
    begin
      tabletmp.Append;
      try
        tabletmp.FieldByName('xmid').AsString := axm.xmid;
      except
      end;

      try
        tabletmp.FieldByName('代码').AsString := varrykm[i, 1];
      except
      end;
      try
        tabletmp.FieldByName('科目名称').AsString := varrykm[i, 2];
      except
      end;
      try
        tabletmp.FieldByName('借贷方向').AsString := varrykm[i, 3];
      except
      end;
      try
        tabletmp.FieldByName('期初').asfloat := varrykm[i, 4];
      except
      end;
      try
        tabletmp.FieldByName('借方发生').asfloat := varrykm[i, 5];
      except
      end;
      try
        tabletmp.FieldByName('贷方发生').asfloat := varrykm[i, 6];
      except
      end;
      try
        tabletmp.FieldByName('期末').asfloat := varrykm[i, 7];
      except
      end;
      tabletmp.post;
    end;
  end;
  tabletmp.close;

end;

{ import_kmyeb9 }

procedure import_kmyeb9.import;
begin
  //
  import9col;
  LONGkmname;
  getfieldlength;
  mymessage('科目余额表已成功导入数据库中！');
end;

procedure import_kmyeb9.import9col;
var
  rowscount, colscount: Integer;
  varrykm: Variant;
  i, j: integer;
  sheettmp: Variant;
begin
  //
  try
    sheettmp := fxlsapp.activeworkbook.sheets.item[km9sheet];
    sheettmp.select();
  except
    mymessage('对不起，您的工作簿中无【科目表样9列】表，请执行第二步进行建立！');
    exit;
  end;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('delete from dg7  where xmid=''' + trim(axm.xmid) + '''');
  qrytmp.ExecSQL;
  qrytmp.close;

  rowscount := sheettmp.usedrange.rows.count;
  colscount := sheettmp.usedrange.columns.count;

  lxyexcel.fillzero(sheettmp, 4);
  lxyexcel.fillzero(sheettmp, 5);
  lxyexcel.fillzero(sheettmp, 6);
  lxyexcel.fillzero(sheettmp, 7);
  lxyexcel.fillzero(sheettmp, 8);
  lxyexcel.fillzero(sheettmp, 9);

  varrykm := sheettmp.Range[sheettmp.cells.Item[2, 1],
    sheettmp.cells.Item[rowscount, colscount]].Value;

  for i := 1 to rowscount - 1 do
  begin
    try
      if Trim(varrykm[i, 3]) = '借' then
      begin
        varrykm[i, 4] := varrykm[i, 4] - varrykm[i, 5];
      end
      else
      begin
        varrykm[i, 4] := varrykm[i, 5] - varrykm[i, 4];
      end;
    except
    end;

    varrykm[i, 5] := varrykm[i, 6];
    varrykm[i, 6] := varrykm[i, 7];
    try
      if Trim(varrykm[i, 3]) = '借' then
      begin
        varrykm[i, 7] := varrykm[i, 8] - varrykm[i, 9];
      end
      else
      begin
        varrykm[i, 7] := varrykm[i, 9] - varrykm[i, 8];
      end;
    except
    end;
  end;

  if tabletmp.Active then
    tabletmp.Close;
  tabletmp.TableName := 'dg7';
  tabletmp.open;
  for i := 1 to rowscount - 1 do
  begin
    if Trim(varrykm[i, 1]) <> '' then
    begin
      tabletmp.Append;
      try
        tabletmp.FieldByName('xmid').AsString := axm.xmid;
      except
      end;

      try
        tabletmp.FieldByName('代码').AsString := varrykm[i, 1];
      except
      end;
      try
        tabletmp.FieldByName('科目名称').AsString := varrykm[i, 2];
      except

      end;
      try
        tabletmp.FieldByName('借贷方向').AsString := varrykm[i, 3];
      except
      end;
      try
        tabletmp.FieldByName('期初').asfloat := varrykm[i, 4];
      except
      end;
      try
        tabletmp.FieldByName('借方发生').asfloat := varrykm[i, 5];
      except
      end;
      try
        tabletmp.FieldByName('贷方发生').asfloat := varrykm[i, 6];
      except
      end;
      try
        tabletmp.FieldByName('期末').asfloat := varrykm[i, 7];
      except
      end;
      tabletmp.post;
    end;
  end;
  tabletmp.close;
end;
{ createsheet }

constructor createsheet.create(excelapp: Variant);
begin
  //
  fxlsapp := excelapp;
end;

procedure createsheet.create_KM7sheet;
var
  sheettmp: Variant;
begin
  if not sheetexists(km7sheet) then
  begin
    sheettmp := fxlsapp.activeworkbook.sheets.add;
    sheettmp.name := km7sheet;
  end
  else
  begin
    sheettmp := fxlsapp.activeworkbook.sheets.item[km7sheet];
    sheettmp.select;
  end;

  sheettmp.cells[1, 1] := '代码';
  sheettmp.cells[1, 2] := '科目名称';
  sheettmp.cells[1, 3] := '借贷方向';
  sheettmp.cells[1, 4] := '期初';
  sheettmp.cells[1, 5] := '借方发生';
  sheettmp.cells[1, 6] := '贷方发生';
  sheettmp.cells[1, 7] := '期末';
  sheettmp.COLUMNS[1].COLUMNWIDTH := 10;
  sheettmp.COLUMNS[2].COLUMNWIDTH := 25;
  sheettmp.COLUMNS[3].COLUMNWIDTH := 8;
  sheettmp.COLUMNS[4].COLUMNWIDTH := 12;
  sheettmp.COLUMNS[5].COLUMNWIDTH := 12;
  sheettmp.COLUMNS[6].COLUMNWIDTH := 12;
  sheettmp.COLUMNS[7].COLUMNWIDTH := 12;
  sheettmp.Range['A1', 'G1'].Interior.Color := #15769326;
end;

procedure createsheet.create_KM9sheet;
var
  sheettmp: Variant;
begin
  //
  if not sheetexists(km9sheet) then
  begin
    sheettmp := fxlsapp.activeworkbook.sheets.add;
    sheettmp.name := km9sheet;
  end
  else
  begin
    sheettmp := fxlsapp.activeworkbook.sheets.item[km9sheet];
    sheettmp.select;
  end;

  sheettmp.cells[1, 1] := '代码';
  sheettmp.cells[1, 2] := '科目名称';
  sheettmp.cells[1, 3] := '借贷方向';
  sheettmp.cells[1, 4] := '期初借方';
  sheettmp.cells[1, 5] := '期初贷方';
  sheettmp.cells[1, 6] := '借方发生';
  sheettmp.cells[1, 7] := '贷方发生';
  sheettmp.cells[1, 8] := '期末借方';
  sheettmp.cells[1, 9] := '期末贷方';

  sheettmp.COLUMNS[1].COLUMNWIDTH := 10;
  sheettmp.COLUMNS[2].COLUMNWIDTH := 25;
  sheettmp.COLUMNS[3].COLUMNWIDTH := 8;
  sheettmp.COLUMNS[4].COLUMNWIDTH := 12;
  sheettmp.COLUMNS[5].COLUMNWIDTH := 12;
  sheettmp.COLUMNS[6].COLUMNWIDTH := 12;
  sheettmp.COLUMNS[7].COLUMNWIDTH := 12;
  sheettmp.COLUMNS[8].COLUMNWIDTH := 12;
  sheettmp.COLUMNS[9].COLUMNWIDTH := 12;
  sheettmp.Range['A1', 'i1'].Interior.Color := #15769326;
end;

procedure createsheet.create_pzb;
var
  sheettmp: Variant;
begin
  //

  if not sheetexists(PZsheet) then
  begin
    sheettmp := fxlsapp.activeworkbook.sheets.add;
    sheettmp.name := PZsheet;
  end
  else
  begin
    sheettmp := fxlsapp.activeworkbook.sheets.item[PZsheet];
    sheettmp.select;
  end;

  sheettmp.cells[1, 1] := '日期';
  sheettmp.cells[1, 2] := '凭证类型';
  sheettmp.cells[1, 3] := '凭证号';
  sheettmp.cells[1, 4] := '摘要';
  sheettmp.cells[1, 5] := '科目代码';
  sheettmp.cells[1, 6] := '科目名称';
  sheettmp.cells[1, 7] := '借方';
  sheettmp.cells[1, 8] := '贷方';
  sheettmp.cells[1, 9] := '对方科目';
  sheettmp.COLUMNS[1].COLUMNWIDTH := 10;
  sheettmp.COLUMNS[2].COLUMNWIDTH := 10;
  sheettmp.COLUMNS[3].COLUMNWIDTH := 10;
  sheettmp.COLUMNS[4].COLUMNWIDTH := 30;
  sheettmp.COLUMNS[5].COLUMNWIDTH := 12;
  sheettmp.COLUMNS[6].COLUMNWIDTH := 12;
  sheettmp.COLUMNS[7].COLUMNWIDTH := 14;
  sheettmp.COLUMNS[8].COLUMNWIDTH := 14;
  sheettmp.COLUMNS[9].COLUMNWIDTH := 30;
  sheettmp.Range['A1', 'I1'].Interior.Color := #15769326;
end;

function createsheet.sheetexists(aname: string): boolean;
var
  i: Integer;
begin
  //  表名是否存在
  result := False;
  for i := 1 to fxlsapp.ActiveWorkbook.Sheets.count do
  begin
    if aname = Trim(fxlsapp.ActiveWorkbook.Sheets.Item[i].name) then
    begin
      Result := true;
      Exit;
    end;
  end;

end;

{ MXBSHEET }

procedure MXBSHEET.fill;
var
  sheettmp: Variant;
  Bcolumnsdb: COLUMNSDB;
  icount: Integer;
  commandline: Integer;
  currentline: Integer;

begin
  try
    sheettmp := fxlsapp.activeworkbook.activesheet;
    icount := sheettmp.usedrange.columns.count;
    commandline := LXYEXCEL.sdb_commandline_num(sheettmp);
    Bcolumnsdb := MXB_xmcolumn_num(sheettmp, commandline, icount);

    currentline := commandline + 2;
    sheettmp.rows.item[commandline + 1, EmptyParam].rowheight := 15.75;
    sheettmp.rows.item[commandline + 2, EmptyParam].rowheight := 15.75;

    while not qrytmp.Eof do
    begin

      sheettmp.rows.item[currentline, EmptyParam].select;
      fxlsapp.Selection.Insert(xlDown);

      sheettmp.rows.item[currentline, EmptyParam].rowheight := 15.75;

      lxyexcel.fillacell(sheettmp, bColumnSDB.kmdm, currentline,
        qrytmp.fieldbyname('代码').asstring);
      lxyexcel.fillacell(sheettmp, bColumnSDB.kmname, currentline,
        qrytmp.fieldbyname('长科目名').asstring);
      lxyexcel.fillacell(sheettmp, bColumnSDB.KMDIRECT, currentline,
        qrytmp.fieldbyname('借贷方向').asstring);
      lxyexcel.fillacell(sheettmp, bColumnSDB.qc, currentline,
        qrytmp.fieldbyname('期初').asstring);
      lxyexcel.fillacell(sheettmp, bColumnSDB.SDqc, currentline,
        qrytmp.fieldbyname('期初').asstring);
      lxyexcel.fillacell(sheettmp, bColumnSDB.qM, currentline,
        qrytmp.fieldbyname('期末').asstring);
      lxyexcel.fillacell(sheettmp, bColumnSDB.SDqM, currentline,
        qrytmp.fieldbyname('期末').asstring);
      lxyexcel.fillacell(sheettmp, bColumnSDB.jffs, currentline,
        qrytmp.fieldbyname('借方发生').asstring);
      lxyexcel.fillacell(sheettmp, bColumnSDB.dffs, currentline,
        qrytmp.fieldbyname('贷方发生').asstring);
      lxyexcel.fillacell(sheettmp, bColumnSDB.sdFS, currentline,
        qrytmp.fieldbyname('贷方发生').asstring);

      currentline := currentline + 1;

      qrytmp.NEXT;
    end;

    lxyexcel.mxbcolumnsum(sheettmp, currentline - 1, bColumnSDB.qc,
      bColumnSDB.kmdirect, commandline, mydirect);
    lxyexcel.mxbcolumnsum(sheettmp, currentline - 1, bColumnSDB.sdqc,
      bColumnSDB.kmdirect, commandline, mydirect);
    lxyexcel.mxbcolumnsum(sheettmp, currentline - 1, bColumnSDB.qm,
      bColumnSDB.kmdirect, commandline, mydirect);
    lxyexcel.mxbcolumnsum(sheettmp, currentline - 1, bColumnSDB.SDqM,
      bColumnSDB.kmdirect, commandline, mydirect);
    lxyexcel.mxbcolumnsum(sheettmp, currentline - 1, bColumnSDB.jffs,
      bColumnSDB.kmdirect, commandline, mydirect);
    lxyexcel.mxbcolumnsum(sheettmp, currentline - 1, bColumnSDB.dffs,
      bColumnSDB.kmdirect, commandline, mydirect);
    lxyexcel.mxbcolumnsum(sheettmp, currentline - 1, bColumnSDB.sdFS,
      bColumnSDB.kmdirect, commandline, mydirect);

    if Bcolumnsdb.kmname > 0 then
      sheettmp.columns.item[Bcolumnsdb.kmname].columnwidth := 50;

    sheettmp.rows.item[commandline + 1, EmptyParam].rowheight := 0;
  except
  end;
end;

function MXBSHEET.MXB_xmcolumn_num(asheet: Variant; commandline,
  columncount: integer): COLUMNSDB;
var
  j: Integer;
  aSDB_COLUMN: COLUMNsdb;
  str: string;
begin
  // sheettmp := asheet;
  try
    for j := 1 to columncount do
      //在明细表中的所有列进行循环 ，如果是期初就填入期初，依此类推。
    begin
      str := asheet.cells.item[commandline, j].value;

      if Pos('科目编号', str) > 0 then
        aSDB_COLUMN.kmdm := j
      else if Pos('科目名称', str) > 0 then
        aSDB_COLUMN.kmname := j
      else if Pos('方向', str) > 0 then
        aSDB_COLUMN.kmdirect := j
      else if (Pos('未审期末数', str) > 0) then
        aSDB_COLUMN.qm := j
      else if (Pos('审定期末数', str) > 0) then
        aSDB_COLUMN.sdqm := j
      else if Pos('未审期初数', str) > 0 then
        aSDB_COLUMN.qc := j
      else if (Pos('账面借方', str) > 0) or (Pos('未审借方发生', str) > 0) then
        aSDB_COLUMN.JFFS := j
      else if (Pos('账面贷方', str) > 0) or (Pos('未审贷方发生', str) > 0) then
        aSDB_COLUMN.DFFS := j
      else if Pos('审定期初数', str) > 0 then
        aSDB_COLUMN.sdqc := j
      else if ((Pos('审定发生', str) > 0)
        and (Pos('上', str) < 1)) then
        aSDB_COLUMN.sdfs := j
      else if ((Pos('未审发生', str) > 0)
        and (Pos('上', str) < 1)) then
        aSDB_COLUMN.fs := j
      else if Pos('期末调整借方', str) > 0 then
        aSDB_COLUMN.qmtzjf := j
      else if Pos('期末调整贷方', str) > 0 then
        aSDB_COLUMN.qmtzdf := j
      else if Pos('期末重分类借方', str) > 0 then
        aSDB_COLUMN.qmcfljf := j
      else if Pos('期末重分类贷方', str) > 0 then
        aSDB_COLUMN.qmcfldf := j;
    end;
    result := aSDB_COLUMN;
  except
  end;
end;

procedure MXBSHEET.query;
begin
  //

  qrytmp.close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.add('select A.* from dg7 a,项目对应关系 B ');
  qrytmp.SQL.add(' where (not A.长科目名 is null)  and A.一级科目代码=B.代码 and ');
  qrytmp.SQL.add(' a.xmid=b.xmid and a.xmid=''' + trim(fxm.xmid) + '''');
  qrytmp.SQL.add('and  UCASE(trim(B.底稿名称))=''' + UpperCase(Trim(fdgfilename))
    + ''' ');
  qrytmp.Open;
  qrytmp.First;

end;

{ SDSHEET }

function SDSHEET.sdb_xmcolumn_num(asheet: Variant;
  commandline: Integer; columncount: integer): COLUMNsdb;
var
  j: Integer;
  aSDB_COLUMN: COLUMNsdb;
  str: string;
begin
  // sheettmp := asheet;
  for j := 1 to columncount do
    //在明细表中的所有列进行循环 ，如果是期初就填入期初，依此类推。
  begin
    str := asheet.cells.item[commandline, j].value;

    if Pos('科目编号', str) > 0 then
      aSDB_COLUMN.kmdm := j
    else if Pos('科目名称', str) > 0 then
      aSDB_COLUMN.kmname := j
    else if Pos('方向', str) > 0 then
      aSDB_COLUMN.kmdirect := j
    else if (Pos('未审期末数', str) > 0) then
      aSDB_COLUMN.qm := j
    else if (Pos('审定期末数', str) > 0) then
      aSDB_COLUMN.sdqm := j
    else if Pos('未审期初数', str) > 0 then
      aSDB_COLUMN.qc := j
    else if Pos('审定期初数', str) > 0 then
      aSDB_COLUMN.sdqc := j
    else if ((Pos('审定发生', str) > 0)
      and (Pos('上', str) < 1)) then
      aSDB_COLUMN.sdfs := j
    else if ((Pos('未审发生', str) > 0)
      and (Pos('上', str) < 1)) then
      aSDB_COLUMN.fs := j
    else if Pos('期末调整借方', str) > 0 then
      aSDB_COLUMN.qmtzjf := j
    else if Pos('期末调整贷方', str) > 0 then
      aSDB_COLUMN.qmtzdf := j
    else if Pos('期末重分类借方', str) > 0 then
      aSDB_COLUMN.qmcfljf := j
    else if Pos('期末重分类贷方', str) > 0 then
      aSDB_COLUMN.qmcfldf := j;
  end;
  result := aSDB_COLUMN;
end;

procedure SDSHEET.fill;
var
  sheettmp: Variant;
  km: array of array of string;
  i, j, recCount: integer;
  k, icount, commandline, direct, currentline: Integer;
  bColumnSDB: ColumnSDB;
  ISlastline: Boolean;
  cellformula: string;
  sheetname: string;
begin
  try
    if qrytmp = nil then
      exit;

    if not qrytmp.RecordCount > 0 then
    begin
      mymessage('项目对应关系表中无内容，请重新设置！！');
      exit;
    end;

    recCount := qrytmp.RecordCount;
    SetLength(km, recCount, 8);

    qrytmp.First;
    i := 0;
    while not qrytmp.Eof do
    begin
      km[i, 0] := qrytmp.fieldbyname('底稿名称').AsString;
      km[i, 1] := qrytmp.fieldbyname('科目名称').AsString;
      km[i, 2] := qrytmp.fieldbyname('代码').AsString;
      km[i, 3] := qrytmp.fieldbyname('借贷方向').AsString;
      km[i, 4] := qrytmp.fieldbyname('期初').AsString;
      km[i, 5] := qrytmp.fieldbyname('借方发生').AsString;
      km[i, 6] := qrytmp.fieldbyname('贷方发生').AsString;
      km[i, 7] := qrytmp.fieldbyname('期末').AsString;
      Inc(i);
      qrytmp.Next;
    end;

    sheettmp := fxlsapp.activeworkbook.activesheet;
    commandline := lxyexcel.sdb_commandline_num(sheettmp);
    sheettmp.rows.item[commandline + 1, EmptyParam].rowheight := 15.75;
    currentline := commandline + 2;

    icount := sheettmp.UsedRange.Columns.count;
    bColumnSDB := sdb_xmcolumn_num(sheettmp, commandline, icount);
    ISlastline := false;
    for i := 0 to recCount - 1 do
    begin
      if i >= recCount - 1 then
        ISlastline := true;

      sheettmp.rows.item[currentline, EmptyParam].select;
      fxlsapp.Selection.Insert(xldown);

      sheettmp.rows.item[currentline, EmptyParam].rowheight := 15.75;
      sheettmp.rows.item[commandline + 1, EmptyParam].rowheight := 0;
      icount := sheettmp.UsedRange.Columns.count;

      if bColumnSDB.kmname > 0 then
      begin
        lxyexcel.fillacell(sheettmp, bColumnSDB.kmdm, currentline, km[i, 2]);
        lxyexcel.fillacell(sheettmp, bColumnSDB.kmname, currentline, km[i, 1]);
        lxyexcel.fillacell(sheettmp, bColumnSDB.kmdirect, currentline, km[i,
          3]);
        lxyexcel.fillacell(sheettmp, bColumnSDB.qc, currentline, km[i, 4]);
        lxyexcel.fillacell(sheettmp, bColumnSDB.sdqc, currentline, km[i, 4]);
        lxyexcel.fillacell(sheettmp, bColumnSDB.qm, currentline, km[i, 7]);
        lxyexcel.fillacell(sheettmp, bColumnSDB.fs, currentline, km[i, 6]);
        lxyexcel.fillacell(sheettmp, bColumnSDB.sdfs, currentline, km[i, 6]);

        cellformula := '=0';
        if bColumnSDB.sdqm > 0 then
        begin
          cellformula := lxyexcel.rowSUM(bColumnSDB.qm, bColumnSDB.qmtzjf,
            bColumnSDB.qmtzdf, bColumnSDB.qmcfljf,
            bColumnSDB.qmcfldf,
            currentline, mydirect);
          sheettmp.cells.item[currentline, bColumnSDB.sdqm].value :=
            cellformula;

          if ISlastline then
          begin
            lxyexcel.columnsum(sheettmp, currentline, bColumnSDB.qm,
              bColumnSDB.kmdirect, commandline, MYdirect);
            lxyexcel.columnsum(sheettmp, currentline, bColumnSDB.sdqm,
              bColumnSDB.kmdirect, commandline, mydirect);
            lxyexcel.columnsum(sheettmp, currentline, bColumnSDB.qc,
              bColumnSDB.kmdirect, commandline, mydirect);
            lxyexcel.columnsum(sheettmp, currentline, bColumnSDB.sdqc,
              bColumnSDB.kmdirect, commandline, mydirect);

            if bColumnSDB.qm > 0 then
              sheettmp.columns.item[bColumnSDB.qm].AutoFit;
            if bColumnSDB.sdqm > 0 then
              sheettmp.columns.item[bColumnSDB.sdqm].AutoFit;
            if bColumnSDB.sdqc > 0 then
              sheettmp.columns.item[bColumnSDB.sdqc].AutoFit;
          end;
        end;

        cellformula := '=0';
        if bColumnSDB.sdfs > 0 then
        begin
          cellformula := lxyexcel.rowSUM(bColumnSDB.fs, bColumnSDB.qmtzjf,
            bColumnSDB.qmtzdf, bColumnSDB.qmcfljf,
            bColumnSDB.qmcfldf,
            currentline, km[i, 3]);
          sheettmp.cells.item[currentline, bColumnSDB.sdfs].value :=
            cellformula;

          if ISlastline then
          begin
            lxyexcel.columnsum(sheettmp, currentline, bColumnSDB.sdfs,
              bColumnSDB.kmdirect, commandline, mydirect);
            lxyexcel.columnsum(sheettmp, currentline, bColumnSDB.fs,
              bColumnSDB.kmdirect, commandline, mydirect);
          end;
        end;
      end;

      currentline := currentline + 1;
    end;

    SetLength(km, 1, 1);
  except
  end;
end;

procedure SDSHEET.query;
begin
  //
  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('select B.代码,B.科目名称,B.底稿名称,A.借贷方向,A.期初,A.借方发生,A.贷方发生,A.期末 ');
  qrytmp.SQL.Add(' from dg7 A,项目对应关系 B ');
  qrytmp.sql.Add(' where (A.代码=B.代码) and ');
  qrytmp.SQL.add(' a.xmid=b.xmid and a.xmid=''' + trim(fxm.xmid) + '''');
  qrytmp.SQL.add('and  UCASE(trim(B.底稿名称))=''' + UpperCase(Trim(fdgfilename))
    + ''' ');
  qrytmp.SQL.Add('  order by B.代码');
  // mymessage(qrytmp.SQL.TEXT);
  qrytmp.Open;
end;

{ import_PZB }

procedure import_PZB.editFILEDnumber(ATABLE: TADOTable; FIELDNAME: string;
  VALUE: Variant);
begin
  try
    ATABLE.FieldByName(FIELDNAME).asfloat := VALUE;
  except
  end;
end;

procedure import_PZB.editFILEDSTR(ATABLE: TADOTable; FIELDNAME: string; VALUE:
  Variant);
begin
  //
  try
    ATABLE.FieldByName(FIELDNAME).AsString := VALUE;
  except
  end;
end;

procedure import_PZB.import;
begin
  //
  importPZB;
  getfieldlength;
end;

procedure import_PZB.importPZB;
var
  m: integer;
  varrykm, sheettmp: Variant;
  rowscount, colscount: longint;
  i, j: integer;
  icount: integer;
begin

  if Trim(axm.xmid) = '' then
  begin
    mymessage('请先打开项目后再导入凭证！');
    exit;
  end;

  try
    sheettmp := fxlsapp.activeworkbook.sheets.item[PZsheet];
  except
    mymessage('活动工作簿中无【凭证表】！');
    EXIT;
  end;
  sheettmp.select;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('delete from 凭证表  where xmid=''' + trim(axm.xmid) + '''');
  qrytmp.ExecSQL;
  qrytmp.close;

  rowscount := sheettmp.usedrange.rows.count;
  colscount := sheettmp.usedrange.columns.count;

  if tabletmp.Active then
    tabletmp.Close;
  tabletmp.TableName := '凭证表';
  tabletmp.open;

  if lxyexcel.filldate(sheettmp, 1) = false then
  begin
    mymessage('第一列的日期型数据有错，不能继续');
    Exit;
  end;
  lxyexcel.fillzero(sheettmp, 7);
  lxyexcel.fillzero(sheettmp, 7);

  m := 1;
  while m <= Int(rowscount / 1000) + 1 do
  begin

    varrykm := sheettmp.Range[sheettmp.cells.Item[2 + (m - 1) * 1000, 1],
      sheettmp.cells.Item[2 + m * 1000 - 1, colscount]].Value;
    i := 1;
    for i := 1 to 1000 do
    begin
      if Trim(varrykm[i, 7]) <> '' then
      begin

        tabletmp.Append;
        //    日期	年	月	凭证号	摘要	科目代码	科目名称	 借方 	 贷方 	对方科目
        editFILEDSTR(tabletmp, 'xmid', axm.xmid);
        //     editFILEDSTR(tabletmp, '日期', varrykm[i, 0]);
        try
          tabletmp.FieldByName('日期').AsDateTime := varrykm[i, 1];
        except
        end;
        editFILEDSTR(tabletmp, '凭证类型', varrykm[i, 2]);
        editFILEDSTR(tabletmp, '凭证编号', varrykm[i, 3]);
        editFILEDSTR(tabletmp, '摘要', varrykm[i, 4]);
        editFILEDSTR(tabletmp, '科目编码', varrykm[i, 5]);
        editFILEDSTR(tabletmp, '科目名称', varrykm[i, 6]);
        editFILEDSTR(tabletmp, '对方科目', varrykm[i, 9]);
        try
          tabletmp.FieldByName('借方').asfloat := varrykm[i, 7];
        except
        end;

        try
          tabletmp.FieldByName('贷方').asfloat := varrykm[i, 8];
        except
        end;

        tabletmp.post;
      end;
    end;

    m := m + 1;
  end;
  tabletmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update 凭证表  set 年份=year(日期),月份=MONTH(日期)');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('UPDATE 凭证表 SET  一级编码=left(科目编码,4) ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('UPDATE 凭证表 SET 全凭证号 =str(年份)+"_"+str(月份)+"_"+left(凭证类型,2)+凭证编号');
  qrytmp.ExecSQL;
  qrytmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update 凭证表 A,DG7 B   set A.一级名称=b.科目名称 where TRIM(a.一级编码)=TRIM(b.代码)');
  qrytmp.ExecSQL;

  mymessage('导入成功！');

end;

{ checkSHEET }

procedure checkSHEET.fill;
var
  sheettmp: Variant;
  Bcolumnsdb: column_checksheet;
  icount: Integer;
  commandline: Integer;
  currentline: Integer;

begin

  sheettmp := fxlsapp.activeworkbook.activesheet;
  icount := sheettmp.usedrange.columns.count;
  commandline := LXYEXCEL.sdb_commandline_num(sheettmp);
  Bcolumnsdb := check_xmcolumn_num(sheettmp, commandline, icount);

  currentline := commandline + 2;
  sheettmp.rows.item[commandline + 1, EmptyParam].rowheight := 15.75;
  sheettmp.rows.item[commandline + 2, EmptyParam].rowheight := 15.75;

  while not qrytmp.Eof do
  begin
    sheettmp.rows.item[currentline, EmptyParam].select;
    fxlsapp.Selection.Insert(xlDown);

    sheettmp.rows.item[currentline, EmptyParam].rowheight := 15.75;
    // 记账时间 凭证种类 凭证编号 业务说明 科目名称 对方科目名称 借方发生额 贷方发生额

    lxyexcel.fillacell(sheettmp, bColumnSDB.pzdate, currentline,
      qrytmp.fieldbyname('日期').asstring);
    lxyexcel.fillacell(sheettmp, bColumnSDB.pztype, currentline,
      qrytmp.fieldbyname('凭证类型').asstring);
    lxyexcel.fillacell(sheettmp, bColumnSDB.pznumber, currentline,
      qrytmp.fieldbyname('凭证编号').asstring);
    lxyexcel.fillacell(sheettmp, bColumnSDB.pzmemo, currentline,
      qrytmp.fieldbyname('摘要').asstring);
    lxyexcel.fillacell(sheettmp, bColumnSDB.pzkm, currentline,
      qrytmp.fieldbyname('科目名称').asstring);
    lxyexcel.fillacell(sheettmp, bColumnSDB.pzmirrorkm, currentline,
      qrytmp.fieldbyname('对方科目').asstring);
    lxyexcel.fillacell(sheettmp, bColumnSDB.pzjf, currentline,
      qrytmp.fieldbyname('借方').asstring);
    lxyexcel.fillacell(sheettmp, bColumnSDB.pzdf, currentline,
      qrytmp.fieldbyname('贷方').asstring);
    currentline := currentline + 1;

    qrytmp.NEXT;
  end;

  sheettmp.rows.item[commandline + 1, EmptyParam].rowheight := 0;
end;

function checkSHEET.check_xmcolumn_num(asheet: Variant; commandline,
  columncount: integer): column_checksheet;
var
  j: Integer;
  aSDB_COLUMN: column_checksheet;
  str: string;
begin
  // sheettmp := asheet;
  for j := 1 to columncount do
    //在明细表中的所有列进行循环 ，如果是期初就填入期初，依此类推。
  begin
    str := asheet.cells.item[commandline, j].value;

    // 记账时间 凭证种类 凭证编号 业务说明 科目名称 对方科目名称 借方发生额 贷方发生额

    if Pos('记账时间', str) > 0 then
      aSDB_COLUMN.pzdate := j
    else if Pos('凭证种类', str) > 0 then
      aSDB_COLUMN.pztype := j
    else if Pos('凭证编号', str) > 0 then
      aSDB_COLUMN.pznumber := j
    else if (Pos('业务说明', str) > 0) then
      aSDB_COLUMN.pzmemo := j
    else if Pos('对方科目名称', str) > 0 then
      aSDB_COLUMN.pzmirrorkm := j
    else if (Pos('科目名称', str) > 0) then
      aSDB_COLUMN.pzkm := j
    else if (Pos('借方发生额', str) > 0) then
      aSDB_COLUMN.pzjf := j
    else if (Pos('贷方发生额', str) > 0) then
      aSDB_COLUMN.pzdf := j;
  end;
  result := aSDB_COLUMN;
end;

procedure checkSHEET.query;
begin
  //
  qrytmp.close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.add('select A.* from 凭证表 a,项目对应关系 B ');
  qrytmp.SQL.add(' where A.一级编码=B.代码 and ');
  qrytmp.SQL.add(' a.xmid=b.xmid and a.xmid=''' + trim(fxm.xmid) + '''');
  qrytmp.SQL.add('and  UCASE(trim(B.底稿名称))=''' + UpperCase(Trim(fdgfilename))
    + ''' ');
  qrytmp.SQL.add('and  a.抽凭标志 ');
  qrytmp.Open;
  qrytmp.First;
end;

{ import_dxn }

procedure import_dxn.DOsql(sqltext: string);
begin
  //
  try
    qrytmp.Close;
    qrytmp.SQL.Clear;
    qrytmp.ParamCheck := false;
    qrytmp.SQL.Add(sqltext);
    qrytmp.ExecSQL;
    qrytmp.close;
  except
    showmessage(sqltext);
  end;
end;

procedure import_dxn.import;
begin
  importdxn();
  LONGkmname;
  getfieldlength;
  mymessage('导入完成！');
end;

procedure import_dxn.importdxn;
var
  sqltext: string;
  sheettmp: Variant;
  XMID: string;
begin
  //
  XMID := axm.xmid;
  try
    sheettmp := fxlsapp.activeworkbook.sheets.item['dxnpzb'];
    sheettmp.select();

  except
    mymessage('对不起，您的工作簿中无【dxnpzb】表，无法导入！');
    exit;
  end;
  try
    lxyexcel.filldate(sheettmp, 4);
  except
  end;

  //  try
  //    sheettmp := fxlsapp.activeworkbook.sheets.item['dxnxmpzb'];
  //    sheettmp.select();
  //  except
  //    mymessage('对不起，您的工作簿中无【dxnxmpzb】表，无法导入！');
  //    exit;
  //  end;

    // lxyexcel.filldate(sheettmp, 24);

  DOSQL('delete from  DG7 where  trim(XMID)=''' + XMID + '''');
  DOSQL('delete from  DG7 where  xmid is null');
  DOSQL('delete from  凭证表 '); //where  trim(XMID)=''' + XMID + '''');
  DOSQL('delete from  凭证表 where  xmid is null');
  DOSQL('delete from  项目凭证表'); // where  trim(XMID)=''' + XMID + '''');

  try
    sqltext :=
      'INSERT INTO  dg7 (代码 ,科目名称,借贷方向,期初 ,借方发生,贷方发生,期末)' + //prd_no, SPC, UT, DFU_UT, KND, IDX1, NAME, SUP1
    ' SELECT' +
      ' 科目编号,科目名称,借贷方向,账面期初数,账面借方发生额,账面贷方发生额,账面期末数' +
      ' FROM [excel 8.0;database=' + fxlsapp.ACTIVEWORKBOOK.fullname +
      '].[DXNKMYEB$]';
    DOSQL(sqltext);
  except
    ShowMessage('科目余额表导入出错');
  end;

  //  try
  //    sqltext :=
  //      'INSERT INTO  dg7 (代码,科目名称,核算项目类型,核算项目代码 ,核算项目名称,借贷方向,期初 ,借方发生,贷方发生,期末)' +
  //      ' SELECT' +
  //      ' 科目编号,"    "+科目名称,核算项目类型名称,核算项目编号,核算项目名称,借贷方向,账面期初数,账面借方发生额,账面贷方发生额,账面期末数 ' +
  //      ' FROM [excel 8.0;database=' + fxlsapp.ACTIVEWORKBOOK.fullname +
  //      '].[dxnxmyeb$]';
  //    DOSQL(sqltext);
  //  except
  //    ShowMessage('项目余额表导入出错');
  //  end;

  try
    sqltext :=
      'INSERT INTO  凭证表 (日期, 凭证类型, 凭证编号,内编号, 科目编码, 科目名称, 摘要, 借方, 贷方,对方科目)' +
      ' SELECT' +
      ' 记账时间, 凭证种类 ,凭证编号,编号,科目编号, 科目名称,业务说明  ,借方发生额 ,贷方发生额,对方科目名称 ' +
      ' FROM [excel 8.0;database=' + fxlsapp.ACTIVEWORKBOOK.fullname +
      '].[dxnpzb$]';
    DOSQL(sqltext);
  except
    ShowMessage('凭证表导入出错');
  end;

  //  try
  //    sqltext :=
  //      'INSERT INTO  项目凭证表( 凭证类型, 凭证编号,内编号, 科目编码, 科目名称, 摘要, 借方, 贷方,项目核算类型,项目核算代码,项目核算名称,对方科目)' +
  //      ' SELECT' +
  //      '  凭证种类 ,凭证编号,编号,科目编号, 科目名称,业务说明,借方发生额 ,贷方发生额,核算项目类型编号,核算项目ID,核算项目名称,对方科目名称 '
  //      + ' FROM [excel 8.0;database=' + fxlsapp.ACTIVEWORKBOOK.fullname +
  //      '].[dxnxmpzb$]';
  //    DOSQL(sqltext);
  //  except
  //    ShowMessage('项目凭证表导入出错');
  //  end;

  DOSQL('UPDATE DG7 SET  XMID=''' + XMID + '''' + ' WHERE XMID is NULL');
  DOSQL('delete from dg7 where trim(代码)=""');
  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('select min(len(代码)) as zdlen from dg7 ');
  qrytmp.SQL.Add(' WHERE xmid=''' + trim(xmid) + ''' and  len(代码)>0');
  qrytmp.open;
  if qrytmp.RecordCount > 0 then
    axm.kmlen := qrytmp.fieldbyname('zdlen').AsInteger;
  DOSQL('UPDATE DG7 SET  一级科目代码=left(代码,' + Trim(IntToStr(axm.kmlen)) +
    ') WHERE  XMID=''' + XMID + '''');

  DOSQL('UPDATE 项目凭证表 SET 年份 =year(日期) ,月份=month(日期)  ');
  DOSQL('UPDATE 项目凭证表 SET 全凭证号 =str(年份)+"_"+str(月份)+"_"+left(凭证类型,2)+凭证编号 ');
  DOSQL('UPDATE 项目凭证表 SET  XMID=''' + XMID + '''' + ' WHERE XMID is NULL');

  DOSQL('UPDATE 凭证表 SET 年份 =year(日期),月份=month(日期)   ');
  DOSQL('UPDATE 凭证表 SET  XMID=''' + XMID + '''' + ' WHERE XMID is NULL');

  DOSQL('update  凭证表  set 一级编码=left(科目编码,' + Trim(IntToStr(axm.kmlen))
    + ')');
  DOSQL('update  凭证表  set  借方=0 where 借方  is null');
  DOSQL('update  凭证表  set  贷方=0 where 贷方  is null');
  DOSQL('update  凭证表  set  全凭证号=str(年份)+"_"+str(月份)+"_"+left(凭证类型,2)+凭证编号');

  // sqltext := 'delete from  dg7  where  not (核算项目名称 is null) '
 //    + '  and 期初=0 and 期末=0 and 借方发生=0 and 贷方发生=0 and xmid=''' + trim(xmid) + '''';

  sqltext := 'delete from  dg7  where  '
    + '   期初=0 and 期末=0 and 借方发生=0 and 贷方发生=0 ';
  DOSQL(sqltext);

  DOSQL('update 凭证表 A,DG7 B   set A.一级名称=b.科目名称 where TRIM(a.一级编码)=TRIM(b.代码)');

end;

end.

