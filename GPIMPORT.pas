unit GPIMPORT;

interface
uses
  SysUtils, ComObj, ComServ, Variants, mydg_TLB, communit, USHARE,
  Classes, adxAddIn, URLMon, StrUtils, IniFiles,
  Dialogs, Excel2000, lxyjm, ShellAPI, controls, windows, Forms,
  DB, ADODB, StdVcl;

type
  tgpimport = class
    SourceSheet, TargetSheet: Variant;
    excelapp: Variant;
    columnscount, rowscount: LongInt;
    sheetdata: Variant;
    congp: tadoconnection;
    tbtmp: TADOTable;
    qrytmp: tadoquery;
    Hash: THashedStringList;
  private
    function Download(SourceFile, DestFile: string): Boolean;
    procedure openmdb();
    procedure closemdb();
    procedure OpenHash();

  public
    procedure HXtoZX(codeid: string; xlsfile: string);
    constructor create(aExcelapp: Variant);
    destructor destroy();
    procedure downloadALL();
    procedure downloadfile(codeid: string);
    function maxid(): string;
    procedure adddm(kmdm, kmmc: string);

  end;
implementation

uses
  Udebug, UTPROGRESS;

{ tgpimport }

function tgpimport.Download(SourceFile, DestFile: string): Boolean;
begin
  try
    Result := UrlDownloadToFile(nil, PChar(SourceFile), PChar(DestFile), 0, nil)
      = 0;
  except
    Result := False;
  end;
end;

constructor tgpimport.create(aexcelapp: Variant);
begin
  excelapp := aexcelapp;
  //debugreset;
  // openmdb;
end;

procedure tgpimport.downloadALL();
var
  CODE: string;
  XCOUNT: Integer;
  INPUTDM: string;
  STARTBZ: BOOLEAN;
  afile, bfile: string;
begin
  openmdb;
  DebugReset;
  afile := mainpath + 'test.txt';

  //  qrytmp.Close;
  //  qrytmp.SQL.Clear;
  //  qrytmp.SQL.Add('delete from cwinfo');
  //  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('select * from gpdm');
  qrytmp.open;

  // //  if qrytmp.recordcount > 10 then
  initProgressBar(qrytmp.recordcount, '生成进度');
  // else
 //    initProgressBar(10, '生成进度');

  //debugto(' 科目对比OK' + codeid + ' ' + xlsfile);
  try
    if tbtmp.Active = False then
      tbtmp.open;
    //debugto('tbtmp打开成功!');
  except
    //debugto('tbtmp打开失败!');
  end;

  //  INPUTDM := inputbox('开始代码', ' 请输入账号', '');

  QRYTMP.FIRST;
  XCOUNT := 1;
  while not QRYTMP.EOF do
  begin
    //    if TRIM(qrytmp.FIELDBYNAME('CODEID').AsString) = INPUTDM then
    //    begin
    //      STARTBZ := TRUE;
    //      xcount := 1;
    //    end;

        //    if XCOUNT > 1000 then
        //      STARTBZ := TRUE;

  //  if STARTBZ then
    begin
      CODE := qrytmp.FIELDBYNAME('CODEID').AsString;
      downloadfile(CODE);
      try

        if ProgressStep() then
          Break;
      except
      end;

    end;
    qrytmp.Next;

    bfile := mainpath + 'testA' + formatdatetime('hhmmss', Now()) + '.txt';

    XCOUNT := XCOUNT + 1;
    if (XCOUNT mod 50) = 0 then
    begin
      RenameFile(afile, bfile);
      DebugReset;
    end;
  end;

  try
    FreeProgressStep();
  except
  end;

  closemdb;

  //debuglist;
  showmessage('下载完毕！');

end;

procedure tgpimport.downloadfile(codeid: string);
var
  U1, U2, U3, B1, B2, B3: string;
begin

  try
    if not FILEEXISTS('C:\TEMP\') then
      MKDIR('C:\TEMP');
  except
  end;

  B1 := 'C:\TEMP\' + CODEID + 'ZCB.XLS';
  B2 := 'C:\TEMP\' + CODEID + 'NRB.XLS';
  B3 := 'C:\TEMP\' + CODEID + 'XJB.XLS';
  U1 := 'http://money.finance.sina.com.cn/corp/go.php/vDOWN_BalanceSheet/displaytype/4/stockid/'
    + TRIM(CODEID) + '/ctrl/all.phtml';
  U2 := 'http://money.finance.sina.com.cn/corp/go.php/vDOWN_ProfitStatement/displaytype/4/stockid/'
    + TRIM(CODEID) + '/ctrl/all.phtml';
  U3 := 'http://money.finance.sina.com.cn/corp/go.php/vDOWN_CashFlow/displaytype/4/stockid/'
    + TRIM(CODEID) + '/ctrl/all.phtml';
  try
    if fileexists(b1) then
      //   if DOWNLOAD(U1, B1) then
      HXtoZX(codeid, B1);
  except
  end;

  //  try
  if fileexists(b2) then
    //      if DOWNLOAD(U2, B2) then
    HXtoZX(codeid, B2);
  //  except
  //  end;
  //  try
  if fileexists(b3) then
    //      if DOWNLOAD(U3, B3) then
    HXtoZX(codeid, B3);
  //  except
  //  end;

end;

procedure tgpimport.HXtoZX(codeid: string; xlsfile: string);
var
  CurLineNum, i, j: LongInt;
  JE: Double;
  dm: string;
begin
  //debugto(' begin hxTOZX' + codeid + ' ' + xlsfile);
  try
    excelapp.workbooks.open(xlsfile);
  except
    //debugto('open err!');
    //
  end;

  SourceSheet := excelapp.activeworkBOOK.activesheet;
  columnscount := SourceSheet.usedrange.columns.count;
  rowscount := SourceSheet.usedrange.rows.count;
  sheetdata := SourceSheet.range[SourceSheet.cells[1, 1],
    sourcesheet.cells[rowscount, columnscount]].value;

  for i := 1 to rowscount do
  begin
    dm := Hash.Values[sheetdata[i, 1]];
    if Trim(dm) <> '' then
      sheetdata[i, 1] := Hash.Values[sheetdata[i, 1]]
    else
    begin
      dm := maxid;
      Hash.Add(sheetdata[i, 1] + '=' + sheetdata[i, 1]);
      adddm(dm, sheetdata[i, 1]);
      sheetdata[i, 1] := dm;
    end;
    //  //debugto(inttostr(i) + ' ' + sheetdata[i, 1]);
  end;

  for i := 1 to columnscount - 1 do
  begin
    for j := 1 to rowscount do
    begin

      try
        JE := sheetdata[j, I + 1];
      except
        JE := 0;
      end;
      if JE <> 0 then
      begin

        debugto(leftstr(sheetdata[1, I + 1], 4) + ' '
          + COPY(sheetdata[1, I + 1], 5, 2) + ' '
          + leftstr(sheetdata[J, 1], 4) + ' '
          + floattostr(sheetdata[j, I + 1]) + ' '
          + CODEID + CHR(10) + chr(13)
          );
        //        tbtmp.Append;
        //        try
        //          tbtmp.FieldByName('年').AsString := leftstr(sheetdata[1, I + 1], 4);
        //        except
        //        end;
        //        try
        //          tbtmp.FieldByName('月').AsString := COPY(sheetdata[1, I + 1], 5, 2);
        //        except
        //        end;
        //        try
        //          tbtmp.FieldByName('项目').AsString := leftstr(sheetdata[J, 1], 4);
        //        except
        //        end;
        //        try
        //          tbtmp.FieldByName('金额').AsFloat := sheetdata[j, I + 1];
        //        except
        //        end;
        //        try
        //          tbtmp.FieldByName('DW').AsString := CODEID;
        //        except
        //        end;
        //        tbtmp.Post;
      end;

    end;
  end;

  // //debugto('END HXTOZX  ' + CODEID + '' + xlsfile);

 //  if tbtmp.Active = true then
 //    tbtmp.close;

  excelapp.activeworkbook.close(false);
end;

procedure tgpimport.openmdb;
var
  AUSERNAME, APASSWORD: string;
begin
  try
    if congp = nil then
    begin
      ausername := 'admin';
      apassword := '';
      congp := TADOConnection.Create(nil);
      congp.ConnectionString := 'Provider=Microsoft.Jet.OLEDB.4.0;' +
        'User ID=' + AUserName + ';' +
        'Jet OLEDB:Database Password=' + APassword + ';' +
        'Data Source=' + MAINPATH + 'gpmdb.mdb' + ';' +
        'Mode=ReadWrite;' +
        'Extended Properties="";';
      congp.LoginPrompt := false;
      congp.Connected := true;
    end;

    tbtmp := TADOTable.Create(nil);
    tbtmp.Connection := congp;
    tbtmp.TableName := 'cwinfo';

    qrytmp := TADOQuery.Create(nil);
    qrytmp.Connection := congp;

  except
  end;

  OpenHash;
end;

destructor tgpimport.destroy;
begin
  //
  closemdb;
end;

procedure tgpimport.closemdb;
begin
  try
    if tbtmp.Active then
      tbtmp.Close;
  except
  end;
  tbtmp.Free;
  tbtmp := nil;

  try
    if qrytmp.Active then
      qrytmp.Close;
  except
  end;
  qrytmp.Free;
  qrytmp := nil;

  try
    congp.Close;
  except
  end;
  congp.Free;
  congp := nil;

  Hash.Free;
  hash := nil;
end;

procedure tgpimport.OpenHash;
var
  i: integer;
begin
  //
  hash := THashedStringList.Create;
  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('select * from  kmdm');
  qrytmp.Open;

  qrytmp.First;
  while not qrytmp.Eof do
  begin
    Hash.Add(qrytmp.fieldbyname('mc').AsString + '=' +
      qrytmp.fieldbyname('dm').AsString);
    qrytmp.Next;
  end;

  // for i := 0 to hash.Count - 1 do
 //    //debugto(IntToStr(i) + Hash.Strings[i]);
end;

function tgpimport.maxid: string;
var
  adm: LongInt;
begin
  //

  result := '';
  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('select max(dm) as xdm from  kmdm');
  qrytmp.Open;

  adm := qrytmp.fieldbyname('xdm').AsInteger;
  if adm < 4000 then
    adm := 4000;

  result := IntToStr(adm + 1);

end;

procedure tgpimport.adddm(kmdm, kmmc: string);
begin
  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('insert into kmdm( dm,mc) values(:dm,:mc)');
  qrytmp.Parameters.ParamByName('dm').value := kmdm;
  qrytmp.Parameters.ParamByName('mc').value := kmmc;
  qrytmp.ExecSQL;

end;

end.

