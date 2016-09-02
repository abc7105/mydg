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
  Udebug;

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
  debugreset;
  // openmdb;
end;

procedure tgpimport.downloadALL();
var
  CODE: string;
  XCOUNT: Integer;
begin
  openmdb;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('delete from cwinfo');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('select * from gpdm');
  qrytmp.open;

  QRYTMP.FIRST;
  XCOUNT := 1;
  while not QRYTMP.EOF do
  begin

    CODE := qrytmp.FIELDBYNAME('CODEID').AsString;
    debugto(' ');
    debugto('code:' + CODE);
    downloadfile(CODE);
    debugto('download ok :code ' + CODE);
    qrytmp.Next;

    XCOUNT := XCOUNT + 1;
    if XCOUNT > 2 then
      Break;
  end;

  closemdb;

  debuglist;
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
  //http://money.finance.sina.com.cn/corp/go.php/vDOWN_BalanceSheet/displaytype/4/stockid/000678/ctrl/all.phtml
 //  //  http://money.finance.sina.com.cn/corp/go.php/vDOWN_CashFlow/displaytype/4/stockid/000678/ctrl/all.phtml
 //  http://money.finance.sina.com.cn/corp/go.php/vDOWN_ProfitStatement/displaytype/4/stockid/000678/ctrl/all.phtml
  try
    if fileexists(b1) then
      //   if DOWNLOAD(U1, B1) then
      HXtoZX(codeid, B1);
  except
  end;

  //  try
  if fileexists(b3) then
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
  try
    excelapp.workbooks.open(xlsfile);
  except
    debugto('open err!');
    //
  end;

  SourceSheet := excelapp.activeworkBOOK.activesheet;
  columnscount := SourceSheet.usedrange.columns.count;
  rowscount := SourceSheet.usedrange.rows.count;
  sheetdata := SourceSheet.range[SourceSheet.cells[1, 1],
    sourcesheet.cells[rowscount, columnscount]].value;

  for i := 1 to rowscount do
  begin
    // showmessage(sheetdata[i, 1]);
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
    //  debugto(inttostr(i) + ' ' + sheetdata[i, 1]);
  end;

  //  debugto('列数' + inttostr(columnscount));
  //  debugto('行数' + inttostr(rowscount));
  //
  //  TargetSheet := excelapp.activeworkBOOK.sheets.add;
  //
  //  TargetSheet.ACTIVATE;

  if tbtmp.Active = False then
    tbtmp.open;
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
        //     try
        tbtmp.Append;
        try
          tbtmp.FieldByName('年').AsString := leftstr(sheetdata[1, I + 1], 4);
        except
        end;
        try
          tbtmp.FieldByName('月').AsString := COPY(sheetdata[1, I + 1], 5, 2);
        except
        end;
        try
          tbtmp.FieldByName('项目').AsString := leftstr(sheetdata[J, 1], 4);
        except
        end;
        try
          tbtmp.FieldByName('金额').AsFloat := sheetdata[j, I + 1];
        except
        end;
        try
          tbtmp.FieldByName('DW').AsString := CODEID;
        except
        end;
        tbtmp.Post;
      end;
      //      except
      //      end;

            //    CurLineNum := (i - 1) * rowscount + j;
            //         TargetSheet.cells[curlinenum, 1] := sheetdata[1, I + 1];
            //     TargetSheet.cells[curlinenum, 2] := sheetdata[J, 1];
            //       TargetSheet.cells[curlinenum, 3] := sheetdata[j, I + 1];

    end;
  end;

  if tbtmp.Active = true then
    tbtmp.close;

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
  tbtmp.Close;
  tbtmp.Free;
  tbtmp := nil;

  qrytmp.Close;
  qrytmp.Free;
  qrytmp := nil;

  congp.Close;
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
 //    debugto(IntToStr(i) + Hash.Strings[i]);
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

