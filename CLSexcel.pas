unit CLSexcel;

interface
uses
  Classes, ADODB, dialogs, CLSLXY, Variants, excel2000, communit,
  StrUtils, SysUtils, ushare, windows, DateUtils, IniFiles;

const
  KM7sheet = '��Ŀ����7��';
  KM9sheet = '��Ŀ����9��';
  PZsheet = 'ƾ֤��';

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
  // ����ʱ�� ƾ֤���� ƾ֤��� ҵ��˵�� ��Ŀ���� �Է���Ŀ���� �跽������ ����������
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
    procedure create_KM7sheet(); //7�еĿ�Ŀ����
    procedure create_KM9sheet(); //9�еĿ�Ŀ����
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
  fillsheet = interface //���һ�����
    ['{7F2FC1B8-E414-4304-9920-5CD6E391A3FC}']
    procedure fill();
    procedure query();
  end;

type
  importsheet = interface //���һ�����
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
  qrytmp.SQL.Add('select max(xmid) as xid from �׸嵥λ');
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

  tb.TableName := '�׸嵥λ';
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
    axm.yeard := IntToStr(YEAROf(axm.endrq)) + '���'
  else
    axm.yeard := IntToStr(YEAROf(axm.startrq)) + '��' +
      IntToStr(monthOf(axm.startrq)) + '��' + '��' +
      IntToStr(YEAROf(axm.endrq)) + '��' + IntToStr(monthOf(axm.endrq)) + '��';

  tb.FieldByName('��ֹʱ��').AsString := axm.yeard;

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
  qrytmp.SQL.add('UPDATE  �׸嵥λ SET ISBUSY=FALSE');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.sql.Clear;
  qrytmp.SQL.add('UPDATE  �׸嵥λ SET ISBUSY=TRUE');
  qrytmp.SQL.Add(' WHERE  trim(xmid)=''' + trim(axm.xmid) + '''');
  qrytmp.ExecSQL;

  tb.Close;
  tb.Free;
  tb := nil;
end;

function dgsystem.writetomdb_EXTinfo(axm: xminfo): BOOLEAN;
begin

  RESULT := FALSE;
  //  ID	XMID	xmmc	dwdm	dwmc	startrq	endrq	mbid	��ֹʱ��	������	�����	��������	�������	path	mbpath	��Ŀ��ע
//27	0015	�»����2014		�������������ά�������ι�˾
  try
    qrytmp.Close;
    qrytmp.sql.Clear;
    qrytmp.SQL.add('select * from �׸嵥λ');
    qrytmp.SQL.Add(' WHERE  xmid=''' + trim(axm.xmid) + '''');
    qrytmp.open;

    if qrytmp.RecordCount > 0 then
    begin
      qrytmp.Close;
      qrytmp.sql.Clear;
      qrytmp.SQL.add('update  �׸嵥λ set 	dwmc=:dwmc,startrq= :startrq,endrq=:endrq,');
      qrytmp.SQL.add('	��ֹʱ��=:yeard ,	������=:editor,	�����=:checkor,	�������� =:editrq,	�������=:checkrq');
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
//  ID	XMID	xmmc	dwdm	dwmc	startrq	endrq	mbid	��ֹʱ��	������	�����	��������	�������	path	mbpath	��Ŀ��ע
//27	0015	�»����2014		�������������ά�������ι�˾

  qrytmp.Close;
  qrytmp.sql.Clear;
  qrytmp.SQL.add('select * from �׸嵥λ');
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
    axm.yeard := qrytmp.fieldbyname('��ֹʱ��').AsString;
    axm.xmpath := qrytmp.fieldbyname('path').ASSTRING;

    axm.MBID := qrytmp.fieldbyname('MBID').AsString;
    axm.MBNAME := qrytmp.fieldbyname('MBNAME').AsString;
    axm.mbpath := qrytmp.fieldbyname('mbpath').AsString;

    axm.editor := qrytmp.fieldbyname('������').AsString;
    axm.checkor := qrytmp.fieldbyname('�����').AsString;
    axm.editrq := qrytmp.fieldbyname('��������').AsDateTime;
    axm.checkRQ := qrytmp.fieldbyname('�������').AsDateTime;
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
      //      axm.xmid := Ini.ReadString('��Ŀ��Ϣ', 'ID', '');
      //      axm.xmname := Ini.ReadString('��Ŀ��Ϣ', 'xmname', '');
      //      axm.xmpath := Ini.ReadString('��Ŀ��Ϣ', 'xmpath', '');
      //      axm.mbname := Ini.ReadString('��Ŀ��Ϣ', 'mbname', '');
      //      axm.mbpath := Ini.ReadString('��Ŀ��Ϣ', 'mbpath', '');
      //      axm.dwmc := Ini.ReadString('��Ŀ��Ϣ', 'dwmc', '');
      //      axm.mbid := Ini.ReadString('��Ŀ��Ϣ', 'mbid', '');
      //      axm.MBNAME := Ini.ReadString('��Ŀ��Ϣ', 'MBNAME', '');
      //      axm.dwmc := Ini.ReadString('��Ŀ��Ϣ', 'dwmc', '');
      //      axm.startrq := Ini.ReadDate('��Ŀ��Ϣ', 'startrq', StartOfAYear(YearOf(now) - 1));
      //      axm.endrq := Ini.ReadDate('��Ŀ��Ϣ', 'endrq', endOfAYear(YearOf(now) - 1));
      //      axm.yeard := Ini.ReadString('��Ŀ��Ϣ', 'yeard', '');
      //      axm.editor := Ini.ReadString('��Ŀ��Ϣ', 'editor', '');
      //      axm.checkor := Ini.ReadString('��Ŀ��Ϣ', 'checkor', '');
      //      axm.editrq := Ini.ReadDate('��Ŀ��Ϣ', 'editrq', today());
      //      axm.checkRQ := Ini.ReadDate('��Ŀ��Ϣ', 'checkRQ', today());
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
  qrytmp.SQL.add('UPDATE  �׸嵥λ SET ISBUSY=FALSE');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.sql.Clear;
  qrytmp.SQL.add('UPDATE  �׸嵥λ SET ISBUSY=TRUE');
  qrytmp.SQL.Add(' WHERE  xmid=''' + trim(xmid) + '''');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.sql.Clear;
  qrytmp.SQL.add('select * from �׸嵥λ');
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
  //  Ini.WriteString('��Ŀ��Ϣ', 'ID', axm.XMID);
  //  Ini.WriteString('��Ŀ��Ϣ', 'xmname', axm.xmname);
  //  Ini.WriteString('��Ŀ��Ϣ', 'xmpath', axm.xmpath);
  //  Ini.WriteString('��Ŀ��Ϣ', 'mbname', axm.mbname);
  //  Ini.WriteString('��Ŀ��Ϣ', 'mbpath', axm.mbpath);
  //  Ini.WriteString('��Ŀ��Ϣ', 'dwmc', axm.dwmc);
  //  Ini.WriteString('��Ŀ��Ϣ', 'mbid', axm.mbid);
  //
  //  Ini.WriteString('��Ŀ��Ϣ', 'dwmc', axm.dwmc);
  //  Ini.WriteDate('��Ŀ��Ϣ', 'startrq', axm.startrq);
  //  Ini.WriteDate('��Ŀ��Ϣ', 'endrq', axm.endrq);
  //  Ini.WriteString('��Ŀ��Ϣ', 'yeard', axm.yeard);
  //  Ini.WriteString('��Ŀ��Ϣ', 'editor', axm.editor);
  //  Ini.WriteString('��Ŀ��Ϣ', 'checkor', axm.checkor);
  //  Ini.WriteDate('��Ŀ��Ϣ', 'editrq', axm.editrq);
  //  Ini.WriteDate('��Ŀ��Ϣ', 'checkRQ', axm.checkRQ);
  //  Ini.Free;
end;

function dgsystem.OPENLAST(): xminfo;
begin
  //
  RESULT := AXM;
  qrytmp.Close;
  qrytmp.sql.Clear;
  qrytmp.SQL.add('select * from �׸嵥λ');
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
  qrytmp.SQL.add('select * from �׸嵥λ');
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
    qrytmp.SQL.add('select * from �׸嵥λ');
    qrytmp.SQL.Add(' WHERE  xmid=''' + trim(axm.xmid) + '''');
    qrytmp.open;

    if qrytmp.RecordCount > 0 then
    begin
      qrytmp.Close;
      qrytmp.sql.Clear;
      qrytmp.SQL.add('update  �׸嵥λ set 	kmlen=:kmlen');
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

      if trim(fxlsapp.activeworkbook.sheets.item[j].name) = '�󶨱�' then
      begin
        fxlsapp.activeworkbook.sheets.item[j].activate;
        //     sheettmp := fxlsapp.activeworkbook.sheets.item['�󶨱�'];
        sheettmp := fxlsapp.activeworkbook.activesheet;

        asdsheet.FDGfilename := dgname;
        asdsheet.mydirect := dgfx;
        asdsheet.query;
        asdsheet.fill;
      end;

      if (Pos('������ϸ��', fxlsapp.activeworkbook.sheets.item[j].name) > 0)
        or (trim(fxlsapp.activeworkbook.sheets.item[j].name) = '��ϸ��') then
      begin
        fxlsapp.activeworkbook.sheets.item[j].activate;
        sheettmp := fxlsapp.activeworkbook.activesheet;
        AMXBSHEET.FDGfilename := dgname;
        AMXBSHEET.mydirect := dgfx;
        AMXBSHEET.query;
        AMXBSHEET.fill;
      end;

      if (Pos('��������', fxlsapp.activeworkbook.sheets.item[j].name) > 0)
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
  qrytmp.SQL.Add('select  min(�׸�����) as �׸����� ,min(�������) as �������  from ��Ŀ��Ӧ��ϵ  where  not �׸����� is null ');
  qrytmp.SQL.Add('  and xmid=''' + trim(axm.xmid) +
    '''  group by �׸����� order by �׸�����');
  qrytmp.Open;

  qrytmp.First;
  while not qrytmp.Eof do
  begin
    dgnames.Add(qrytmp.fieldbyname('�׸�����').AsString + '  >>' +
      trim(qrytmp.fieldbyname('�������').AsString));
    qrytmp.Next;
  end;
  qrytmp.close;
  RESULT := dgnames;
end;

function dgworkbook.sheetexists(aname: string): boolean;
var
  i: Integer;
begin
  //  �����Ƿ����
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
  qrydg.SQL.Add('select  min(�׸�����) as �׸�����,min(�������) as �������  from ��Ŀ��Ӧ��ϵ  where  not �׸����� is null ');
  qrydg.SQL.Add('  and xmid=''' + trim(fxm.xmid) +
    '''  group by �׸����� order by �׸�����');
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
    dgname := qrydg.fieldbyname('�׸�����').asstring;
    dgfx := qrydg.fieldbyname('�������').asstring;

    aworkbook := fxlsapp.workbooks.open(fxm.mbpath + '\' + dgname, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, 0);

    for j := 1 to aworkbook.sheets.count do
    begin

      try
        if trim(fxlsapp.activeworkbook.sheets.item[j].name) = '�󶨱�' then
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
        if (Pos('������ϸ��', fxlsapp.activeworkbook.sheets.item[j].name) > 0)
          or (trim(fxlsapp.activeworkbook.sheets.item[j].name) = '��ϸ��') then
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
  qrydg.SQL.Add('select  min(�׸�����) as �׸�����,min(�������) as �������  from ��Ŀ��Ӧ��ϵ  where  not �׸����� is null ');
  qrydg.SQL.Add('  and xmid=''' + trim(fxm.xmid) +
    '''  group by �׸����� order by �׸�����');
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
    dgname := qrydg.fieldbyname('�׸�����').asstring;
    dgfx := qrydg.fieldbyname('�������').asstring;

    aworkbook := fxlsapp.workbooks.open(fxm.mbpath + '\' + dgname, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, 0);

    for j := 1 to aworkbook.sheets.count do
    begin

      try
        if trim(fxlsapp.activeworkbook.sheets.item[j].name) = '�󶨱�' then
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
        if (Pos('������ϸ��', fxlsapp.activeworkbook.sheets.item[j].name) > 0)
          or (trim(fxlsapp.activeworkbook.sheets.item[j].name) = '��ϸ��') then
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
    mymessage('���ݿⲻ���ڣ�������Ŀ�������� ');
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
  qrytmp.SQL.Add('delete from dg7 where   len(trim(����))=0  ');
  qrytmp.execsql;

  try
    qrytmp.Close;
    qrytmp.SQL.Clear;
    qrytmp.SQL.Add('select min(len(����)) as zdlen from dg7 ');
    qrytmp.SQL.Add(' WHERE xmid=''' + trim(axm.xmid) + '''  and len(����)>0');
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
  tabletmp.Sort := '����';
  tabletmp.first;
  iseof := false;
  len1 := Length(trim(tabletmp.fieldbyname('����').AsString));
  onelevel_KM := '';
  while not tabletmp.eof do
  begin
    if (len1 = lengthof_onelevel) then
    begin
      onelevel_KM := trim(tabletmp.fieldbyname('����').AsString);
    end;

    tabletmp.Next;
    len2 := Length(trim(tabletmp.fieldbyname('����').AsString));
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
        tabletmp.fieldbyname('����Ŀ��').AsString := str + '\' +
          trim(tabletmp.fieldbyname('��Ŀ����').AsString);
        tabletmp.Post;
      except
      end;
      str := '';
    end
    else if (len2 > len1) then
    begin
      str := str + '\' + trim(tabletmp.fieldbyname('��Ŀ����').AsString);
    end
    else if (len2 = len1) then
    begin
      try
        tabletmp.edit;
        tabletmp.fieldbyname('����Ŀ��').AsString := str + '\' +
          trim(tabletmp.fieldbyname('��Ŀ����').AsString);
        tabletmp.Post;
      except
      end;
    end;

    try
      tabletmp.edit;
      tabletmp.fieldbyname('һ����Ŀ����').AsString := onelevel_KM;
      tabletmp.Post;
    except
    end;

    if iseof then
      Break;
    tabletmp.next;
    len1 := Length(trim(tabletmp.fieldbyname('����').AsString));
  end;

  //

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('delete from ��Ŀ��Ӧ��ϵ where xmid=''' + trim(axm.xmid) +
    '''');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('delete from  dg7  where  ����  in (');
  qrytmp.SQL.Add(' select ���� from dg7 where len(trim(����)) =' +
    inttostr(lengthof_onelevel) +
    'and  ������Ŀ���� is null and �ڳ�=0 and ��ĩ=0 and �跽����=0 and ��������=0 and xmid=''' +
    trim(axm.xmid) +
    '''');
  qrytmp.SQL.Add(')');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('insert into ��Ŀ��Ӧ��ϵ(xmid,����,��Ŀ����,�������)');
  qrytmp.SQL.Add('  select  xmid,����,��Ŀ����,������� from dg7 where len(����)=' + inttostr(lengthof_onelevel));
  qrytmp.SQL.Add(' AND  xmid=''' + trim(axm.xmid) + '''');
  qrytmp.ExecSQL;
  qrytmp.Close;

  if tabletmp.Active then
    tabletmp.Close;
  tabletmp.TableName := '��Ŀ��Ӧ��ϵ';
  tabletmp.Filter := 'xmid=''' + trim(axm.xmid) + '''';
  tabletmp.open;
  tabletmp.Filtered := true;

  tabletmp.First;
  while not tabletmp.Eof do
  begin
    strkm := Trim(tabletmp.fieldbyname('��Ŀ����').AsString);
    qrytmp.Close;
    qrytmp.SQL.Clear;
    qrytmp.SQL.Add('select �׸�����  from  ��Ŀ�׸��Ӧ�� where ��Ŀ���� like ''%' + strkm + '%'' ');
    qrytmp.SQL.Add('and MBid=''' + trim(axm.MBid) + '''');
    qrytmp.open;
    if qrytmp.RecordCount > 0 then
    begin
      try
        tabletmp.Edit;
        tabletmp.FieldByName('�׸�����').AsString :=
          qrytmp.FieldByName('�׸�����').AsString;
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
  mymessage('����ɹ���');
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
    mymessage('�Բ������Ĺ��������ޡ���Ŀ����9�С�����ִ�еڶ������н�����');
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
        tabletmp.FieldByName('����').AsString := varrykm[i, 1];
      except
      end;
      try
        tabletmp.FieldByName('��Ŀ����').AsString := varrykm[i, 2];
      except
      end;
      try
        tabletmp.FieldByName('�������').AsString := varrykm[i, 3];
      except
      end;
      try
        tabletmp.FieldByName('�ڳ�').asfloat := varrykm[i, 4];
      except
      end;
      try
        tabletmp.FieldByName('�跽����').asfloat := varrykm[i, 5];
      except
      end;
      try
        tabletmp.FieldByName('��������').asfloat := varrykm[i, 6];
      except
      end;
      try
        tabletmp.FieldByName('��ĩ').asfloat := varrykm[i, 7];
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
  mymessage('��Ŀ�����ѳɹ��������ݿ��У�');
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
    mymessage('�Բ������Ĺ��������ޡ���Ŀ����9�С�����ִ�еڶ������н�����');
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
      if Trim(varrykm[i, 3]) = '��' then
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
      if Trim(varrykm[i, 3]) = '��' then
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
        tabletmp.FieldByName('����').AsString := varrykm[i, 1];
      except
      end;
      try
        tabletmp.FieldByName('��Ŀ����').AsString := varrykm[i, 2];
      except

      end;
      try
        tabletmp.FieldByName('�������').AsString := varrykm[i, 3];
      except
      end;
      try
        tabletmp.FieldByName('�ڳ�').asfloat := varrykm[i, 4];
      except
      end;
      try
        tabletmp.FieldByName('�跽����').asfloat := varrykm[i, 5];
      except
      end;
      try
        tabletmp.FieldByName('��������').asfloat := varrykm[i, 6];
      except
      end;
      try
        tabletmp.FieldByName('��ĩ').asfloat := varrykm[i, 7];
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

  sheettmp.cells[1, 1] := '����';
  sheettmp.cells[1, 2] := '��Ŀ����';
  sheettmp.cells[1, 3] := '�������';
  sheettmp.cells[1, 4] := '�ڳ�';
  sheettmp.cells[1, 5] := '�跽����';
  sheettmp.cells[1, 6] := '��������';
  sheettmp.cells[1, 7] := '��ĩ';
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

  sheettmp.cells[1, 1] := '����';
  sheettmp.cells[1, 2] := '��Ŀ����';
  sheettmp.cells[1, 3] := '�������';
  sheettmp.cells[1, 4] := '�ڳ��跽';
  sheettmp.cells[1, 5] := '�ڳ�����';
  sheettmp.cells[1, 6] := '�跽����';
  sheettmp.cells[1, 7] := '��������';
  sheettmp.cells[1, 8] := '��ĩ�跽';
  sheettmp.cells[1, 9] := '��ĩ����';

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

  sheettmp.cells[1, 1] := '����';
  sheettmp.cells[1, 2] := 'ƾ֤����';
  sheettmp.cells[1, 3] := 'ƾ֤��';
  sheettmp.cells[1, 4] := 'ժҪ';
  sheettmp.cells[1, 5] := '��Ŀ����';
  sheettmp.cells[1, 6] := '��Ŀ����';
  sheettmp.cells[1, 7] := '�跽';
  sheettmp.cells[1, 8] := '����';
  sheettmp.cells[1, 9] := '�Է���Ŀ';
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
  //  �����Ƿ����
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
        qrytmp.fieldbyname('����').asstring);
      lxyexcel.fillacell(sheettmp, bColumnSDB.kmname, currentline,
        qrytmp.fieldbyname('����Ŀ��').asstring);
      lxyexcel.fillacell(sheettmp, bColumnSDB.KMDIRECT, currentline,
        qrytmp.fieldbyname('�������').asstring);
      lxyexcel.fillacell(sheettmp, bColumnSDB.qc, currentline,
        qrytmp.fieldbyname('�ڳ�').asstring);
      lxyexcel.fillacell(sheettmp, bColumnSDB.SDqc, currentline,
        qrytmp.fieldbyname('�ڳ�').asstring);
      lxyexcel.fillacell(sheettmp, bColumnSDB.qM, currentline,
        qrytmp.fieldbyname('��ĩ').asstring);
      lxyexcel.fillacell(sheettmp, bColumnSDB.SDqM, currentline,
        qrytmp.fieldbyname('��ĩ').asstring);
      lxyexcel.fillacell(sheettmp, bColumnSDB.jffs, currentline,
        qrytmp.fieldbyname('�跽����').asstring);
      lxyexcel.fillacell(sheettmp, bColumnSDB.dffs, currentline,
        qrytmp.fieldbyname('��������').asstring);
      lxyexcel.fillacell(sheettmp, bColumnSDB.sdFS, currentline,
        qrytmp.fieldbyname('��������').asstring);

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
      //����ϸ���е������н���ѭ�� ��������ڳ��������ڳ����������ơ�
    begin
      str := asheet.cells.item[commandline, j].value;

      if Pos('��Ŀ���', str) > 0 then
        aSDB_COLUMN.kmdm := j
      else if Pos('��Ŀ����', str) > 0 then
        aSDB_COLUMN.kmname := j
      else if Pos('����', str) > 0 then
        aSDB_COLUMN.kmdirect := j
      else if (Pos('δ����ĩ��', str) > 0) then
        aSDB_COLUMN.qm := j
      else if (Pos('����ĩ��', str) > 0) then
        aSDB_COLUMN.sdqm := j
      else if Pos('δ���ڳ���', str) > 0 then
        aSDB_COLUMN.qc := j
      else if (Pos('����跽', str) > 0) or (Pos('δ��跽����', str) > 0) then
        aSDB_COLUMN.JFFS := j
      else if (Pos('�������', str) > 0) or (Pos('δ���������', str) > 0) then
        aSDB_COLUMN.DFFS := j
      else if Pos('���ڳ���', str) > 0 then
        aSDB_COLUMN.sdqc := j
      else if ((Pos('�󶨷���', str) > 0)
        and (Pos('��', str) < 1)) then
        aSDB_COLUMN.sdfs := j
      else if ((Pos('δ����', str) > 0)
        and (Pos('��', str) < 1)) then
        aSDB_COLUMN.fs := j
      else if Pos('��ĩ�����跽', str) > 0 then
        aSDB_COLUMN.qmtzjf := j
      else if Pos('��ĩ��������', str) > 0 then
        aSDB_COLUMN.qmtzdf := j
      else if Pos('��ĩ�ط���跽', str) > 0 then
        aSDB_COLUMN.qmcfljf := j
      else if Pos('��ĩ�ط������', str) > 0 then
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
  qrytmp.SQL.add('select A.* from dg7 a,��Ŀ��Ӧ��ϵ B ');
  qrytmp.SQL.add(' where (not A.����Ŀ�� is null)  and A.һ����Ŀ����=B.���� and ');
  qrytmp.SQL.add(' a.xmid=b.xmid and a.xmid=''' + trim(fxm.xmid) + '''');
  qrytmp.SQL.add('and  UCASE(trim(B.�׸�����))=''' + UpperCase(Trim(fdgfilename))
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
    //����ϸ���е������н���ѭ�� ��������ڳ��������ڳ����������ơ�
  begin
    str := asheet.cells.item[commandline, j].value;

    if Pos('��Ŀ���', str) > 0 then
      aSDB_COLUMN.kmdm := j
    else if Pos('��Ŀ����', str) > 0 then
      aSDB_COLUMN.kmname := j
    else if Pos('����', str) > 0 then
      aSDB_COLUMN.kmdirect := j
    else if (Pos('δ����ĩ��', str) > 0) then
      aSDB_COLUMN.qm := j
    else if (Pos('����ĩ��', str) > 0) then
      aSDB_COLUMN.sdqm := j
    else if Pos('δ���ڳ���', str) > 0 then
      aSDB_COLUMN.qc := j
    else if Pos('���ڳ���', str) > 0 then
      aSDB_COLUMN.sdqc := j
    else if ((Pos('�󶨷���', str) > 0)
      and (Pos('��', str) < 1)) then
      aSDB_COLUMN.sdfs := j
    else if ((Pos('δ����', str) > 0)
      and (Pos('��', str) < 1)) then
      aSDB_COLUMN.fs := j
    else if Pos('��ĩ�����跽', str) > 0 then
      aSDB_COLUMN.qmtzjf := j
    else if Pos('��ĩ��������', str) > 0 then
      aSDB_COLUMN.qmtzdf := j
    else if Pos('��ĩ�ط���跽', str) > 0 then
      aSDB_COLUMN.qmcfljf := j
    else if Pos('��ĩ�ط������', str) > 0 then
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
      mymessage('��Ŀ��Ӧ��ϵ���������ݣ����������ã���');
      exit;
    end;

    recCount := qrytmp.RecordCount;
    SetLength(km, recCount, 8);

    qrytmp.First;
    i := 0;
    while not qrytmp.Eof do
    begin
      km[i, 0] := qrytmp.fieldbyname('�׸�����').AsString;
      km[i, 1] := qrytmp.fieldbyname('��Ŀ����').AsString;
      km[i, 2] := qrytmp.fieldbyname('����').AsString;
      km[i, 3] := qrytmp.fieldbyname('�������').AsString;
      km[i, 4] := qrytmp.fieldbyname('�ڳ�').AsString;
      km[i, 5] := qrytmp.fieldbyname('�跽����').AsString;
      km[i, 6] := qrytmp.fieldbyname('��������').AsString;
      km[i, 7] := qrytmp.fieldbyname('��ĩ').AsString;
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
  qrytmp.SQL.Add('select B.����,B.��Ŀ����,B.�׸�����,A.�������,A.�ڳ�,A.�跽����,A.��������,A.��ĩ ');
  qrytmp.SQL.Add(' from dg7 A,��Ŀ��Ӧ��ϵ B ');
  qrytmp.sql.Add(' where (A.����=B.����) and ');
  qrytmp.SQL.add(' a.xmid=b.xmid and a.xmid=''' + trim(fxm.xmid) + '''');
  qrytmp.SQL.add('and  UCASE(trim(B.�׸�����))=''' + UpperCase(Trim(fdgfilename))
    + ''' ');
  qrytmp.SQL.Add('  order by B.����');
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
    mymessage('���ȴ���Ŀ���ٵ���ƾ֤��');
    exit;
  end;

  try
    sheettmp := fxlsapp.activeworkbook.sheets.item[PZsheet];
  except
    mymessage('����������ޡ�ƾ֤����');
    EXIT;
  end;
  sheettmp.select;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('delete from ƾ֤��  where xmid=''' + trim(axm.xmid) + '''');
  qrytmp.ExecSQL;
  qrytmp.close;

  rowscount := sheettmp.usedrange.rows.count;
  colscount := sheettmp.usedrange.columns.count;

  if tabletmp.Active then
    tabletmp.Close;
  tabletmp.TableName := 'ƾ֤��';
  tabletmp.open;

  if lxyexcel.filldate(sheettmp, 1) = false then
  begin
    mymessage('��һ�е������������д����ܼ���');
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
        //    ����	��	��	ƾ֤��	ժҪ	��Ŀ����	��Ŀ����	 �跽 	 ���� 	�Է���Ŀ
        editFILEDSTR(tabletmp, 'xmid', axm.xmid);
        //     editFILEDSTR(tabletmp, '����', varrykm[i, 0]);
        try
          tabletmp.FieldByName('����').AsDateTime := varrykm[i, 1];
        except
        end;
        editFILEDSTR(tabletmp, 'ƾ֤����', varrykm[i, 2]);
        editFILEDSTR(tabletmp, 'ƾ֤���', varrykm[i, 3]);
        editFILEDSTR(tabletmp, 'ժҪ', varrykm[i, 4]);
        editFILEDSTR(tabletmp, '��Ŀ����', varrykm[i, 5]);
        editFILEDSTR(tabletmp, '��Ŀ����', varrykm[i, 6]);
        editFILEDSTR(tabletmp, '�Է���Ŀ', varrykm[i, 9]);
        try
          tabletmp.FieldByName('�跽').asfloat := varrykm[i, 7];
        except
        end;

        try
          tabletmp.FieldByName('����').asfloat := varrykm[i, 8];
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
  qrytmp.SQL.Add('update ƾ֤��  set ���=year(����),�·�=MONTH(����)');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('UPDATE ƾ֤�� SET  һ������=left(��Ŀ����,4) ');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('UPDATE ƾ֤�� SET ȫƾ֤�� =str(���)+"_"+str(�·�)+"_"+left(ƾ֤����,2)+ƾ֤���');
  qrytmp.ExecSQL;
  qrytmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update ƾ֤�� A,DG7 B   set A.һ������=b.��Ŀ���� where TRIM(a.һ������)=TRIM(b.����)');
  qrytmp.ExecSQL;

  mymessage('����ɹ���');

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
    // ����ʱ�� ƾ֤���� ƾ֤��� ҵ��˵�� ��Ŀ���� �Է���Ŀ���� �跽������ ����������

    lxyexcel.fillacell(sheettmp, bColumnSDB.pzdate, currentline,
      qrytmp.fieldbyname('����').asstring);
    lxyexcel.fillacell(sheettmp, bColumnSDB.pztype, currentline,
      qrytmp.fieldbyname('ƾ֤����').asstring);
    lxyexcel.fillacell(sheettmp, bColumnSDB.pznumber, currentline,
      qrytmp.fieldbyname('ƾ֤���').asstring);
    lxyexcel.fillacell(sheettmp, bColumnSDB.pzmemo, currentline,
      qrytmp.fieldbyname('ժҪ').asstring);
    lxyexcel.fillacell(sheettmp, bColumnSDB.pzkm, currentline,
      qrytmp.fieldbyname('��Ŀ����').asstring);
    lxyexcel.fillacell(sheettmp, bColumnSDB.pzmirrorkm, currentline,
      qrytmp.fieldbyname('�Է���Ŀ').asstring);
    lxyexcel.fillacell(sheettmp, bColumnSDB.pzjf, currentline,
      qrytmp.fieldbyname('�跽').asstring);
    lxyexcel.fillacell(sheettmp, bColumnSDB.pzdf, currentline,
      qrytmp.fieldbyname('����').asstring);
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
    //����ϸ���е������н���ѭ�� ��������ڳ��������ڳ����������ơ�
  begin
    str := asheet.cells.item[commandline, j].value;

    // ����ʱ�� ƾ֤���� ƾ֤��� ҵ��˵�� ��Ŀ���� �Է���Ŀ���� �跽������ ����������

    if Pos('����ʱ��', str) > 0 then
      aSDB_COLUMN.pzdate := j
    else if Pos('ƾ֤����', str) > 0 then
      aSDB_COLUMN.pztype := j
    else if Pos('ƾ֤���', str) > 0 then
      aSDB_COLUMN.pznumber := j
    else if (Pos('ҵ��˵��', str) > 0) then
      aSDB_COLUMN.pzmemo := j
    else if Pos('�Է���Ŀ����', str) > 0 then
      aSDB_COLUMN.pzmirrorkm := j
    else if (Pos('��Ŀ����', str) > 0) then
      aSDB_COLUMN.pzkm := j
    else if (Pos('�跽������', str) > 0) then
      aSDB_COLUMN.pzjf := j
    else if (Pos('����������', str) > 0) then
      aSDB_COLUMN.pzdf := j;
  end;
  result := aSDB_COLUMN;
end;

procedure checkSHEET.query;
begin
  //
  qrytmp.close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.add('select A.* from ƾ֤�� a,��Ŀ��Ӧ��ϵ B ');
  qrytmp.SQL.add(' where A.һ������=B.���� and ');
  qrytmp.SQL.add(' a.xmid=b.xmid and a.xmid=''' + trim(fxm.xmid) + '''');
  qrytmp.SQL.add('and  UCASE(trim(B.�׸�����))=''' + UpperCase(Trim(fdgfilename))
    + ''' ');
  qrytmp.SQL.add('and  a.��ƾ��־ ');
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
  mymessage('������ɣ�');
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
    mymessage('�Բ������Ĺ��������ޡ�dxnpzb�����޷����룡');
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
  //    mymessage('�Բ������Ĺ��������ޡ�dxnxmpzb�����޷����룡');
  //    exit;
  //  end;

    // lxyexcel.filldate(sheettmp, 24);

  DOSQL('delete from  DG7 where  trim(XMID)=''' + XMID + '''');
  DOSQL('delete from  DG7 where  xmid is null');
  DOSQL('delete from  ƾ֤�� '); //where  trim(XMID)=''' + XMID + '''');
  DOSQL('delete from  ƾ֤�� where  xmid is null');
  DOSQL('delete from  ��Ŀƾ֤��'); // where  trim(XMID)=''' + XMID + '''');

  try
    sqltext :=
      'INSERT INTO  dg7 (���� ,��Ŀ����,�������,�ڳ� ,�跽����,��������,��ĩ)' + //prd_no, SPC, UT, DFU_UT, KND, IDX1, NAME, SUP1
    ' SELECT' +
      ' ��Ŀ���,��Ŀ����,�������,�����ڳ���,����跽������,�������������,������ĩ��' +
      ' FROM [excel 8.0;database=' + fxlsapp.ACTIVEWORKBOOK.fullname +
      '].[DXNKMYEB$]';
    DOSQL(sqltext);
  except
    ShowMessage('��Ŀ���������');
  end;

  //  try
  //    sqltext :=
  //      'INSERT INTO  dg7 (����,��Ŀ����,������Ŀ����,������Ŀ���� ,������Ŀ����,�������,�ڳ� ,�跽����,��������,��ĩ)' +
  //      ' SELECT' +
  //      ' ��Ŀ���,"    "+��Ŀ����,������Ŀ��������,������Ŀ���,������Ŀ����,�������,�����ڳ���,����跽������,�������������,������ĩ�� ' +
  //      ' FROM [excel 8.0;database=' + fxlsapp.ACTIVEWORKBOOK.fullname +
  //      '].[dxnxmyeb$]';
  //    DOSQL(sqltext);
  //  except
  //    ShowMessage('��Ŀ���������');
  //  end;

  try
    sqltext :=
      'INSERT INTO  ƾ֤�� (����, ƾ֤����, ƾ֤���,�ڱ��, ��Ŀ����, ��Ŀ����, ժҪ, �跽, ����,�Է���Ŀ)' +
      ' SELECT' +
      ' ����ʱ��, ƾ֤���� ,ƾ֤���,���,��Ŀ���, ��Ŀ����,ҵ��˵��  ,�跽������ ,����������,�Է���Ŀ���� ' +
      ' FROM [excel 8.0;database=' + fxlsapp.ACTIVEWORKBOOK.fullname +
      '].[dxnpzb$]';
    DOSQL(sqltext);
  except
    ShowMessage('ƾ֤�������');
  end;

  //  try
  //    sqltext :=
  //      'INSERT INTO  ��Ŀƾ֤��( ƾ֤����, ƾ֤���,�ڱ��, ��Ŀ����, ��Ŀ����, ժҪ, �跽, ����,��Ŀ��������,��Ŀ�������,��Ŀ��������,�Է���Ŀ)' +
  //      ' SELECT' +
  //      '  ƾ֤���� ,ƾ֤���,���,��Ŀ���, ��Ŀ����,ҵ��˵��,�跽������ ,����������,������Ŀ���ͱ��,������ĿID,������Ŀ����,�Է���Ŀ���� '
  //      + ' FROM [excel 8.0;database=' + fxlsapp.ACTIVEWORKBOOK.fullname +
  //      '].[dxnxmpzb$]';
  //    DOSQL(sqltext);
  //  except
  //    ShowMessage('��Ŀƾ֤�������');
  //  end;

  DOSQL('UPDATE DG7 SET  XMID=''' + XMID + '''' + ' WHERE XMID is NULL');
  DOSQL('delete from dg7 where trim(����)=""');
  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('select min(len(����)) as zdlen from dg7 ');
  qrytmp.SQL.Add(' WHERE xmid=''' + trim(xmid) + ''' and  len(����)>0');
  qrytmp.open;
  if qrytmp.RecordCount > 0 then
    axm.kmlen := qrytmp.fieldbyname('zdlen').AsInteger;
  DOSQL('UPDATE DG7 SET  һ����Ŀ����=left(����,' + Trim(IntToStr(axm.kmlen)) +
    ') WHERE  XMID=''' + XMID + '''');

  DOSQL('UPDATE ��Ŀƾ֤�� SET ��� =year(����) ,�·�=month(����)  ');
  DOSQL('UPDATE ��Ŀƾ֤�� SET ȫƾ֤�� =str(���)+"_"+str(�·�)+"_"+left(ƾ֤����,2)+ƾ֤��� ');
  DOSQL('UPDATE ��Ŀƾ֤�� SET  XMID=''' + XMID + '''' + ' WHERE XMID is NULL');

  DOSQL('UPDATE ƾ֤�� SET ��� =year(����),�·�=month(����)   ');
  DOSQL('UPDATE ƾ֤�� SET  XMID=''' + XMID + '''' + ' WHERE XMID is NULL');

  DOSQL('update  ƾ֤��  set һ������=left(��Ŀ����,' + Trim(IntToStr(axm.kmlen))
    + ')');
  DOSQL('update  ƾ֤��  set  �跽=0 where �跽  is null');
  DOSQL('update  ƾ֤��  set  ����=0 where ����  is null');
  DOSQL('update  ƾ֤��  set  ȫƾ֤��=str(���)+"_"+str(�·�)+"_"+left(ƾ֤����,2)+ƾ֤���');

  // sqltext := 'delete from  dg7  where  not (������Ŀ���� is null) '
 //    + '  and �ڳ�=0 and ��ĩ=0 and �跽����=0 and ��������=0 and xmid=''' + trim(xmid) + '''';

  sqltext := 'delete from  dg7  where  '
    + '   �ڳ�=0 and ��ĩ=0 and �跽����=0 and ��������=0 ';
  DOSQL(sqltext);

  DOSQL('update ƾ֤�� A,DG7 B   set A.һ������=b.��Ŀ���� where TRIM(a.һ������)=TRIM(b.����)');

end;

end.

