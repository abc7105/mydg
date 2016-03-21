unit u_xzh;

interface
uses
  Forms, Windows, Messages, Graphics, Controls,
  SysUtils, ComObj, Variants,
  TLhelp32, ExtCtrls, Word2000,
  Dialogs, StrUtils, ADODB, Classes;

const
  wdCharacter = $00000001;
  wdWord = $00000002;
  wdSentence = $00000003;
  wdParagraph = $00000004;
  wdLine = $00000005;
  wdStory = $00000006;
  wdScreen = $00000007;
  wdSection = $00000008;
  wdColumn = $00000009;
  wdRow = $0000000A;
  wdWindow = $0000000B;
  wdCell = $0000000C;
  wdCharacterFormatting = $0000000D;
  wdParagraphFormatting = $0000000E;
  wdTable = $0000000F;
  wdItem = $00000010;

type
  cellrec = record
    sheetname: string;
    columnname: string;
  end;

  cellxy = record
    row: integer;
    column: integer;
  end;

  xzh = class
    xlsapp: Variant;
    docapp: Variant;
    fdoc: Variant;
    columnpos: array of array of integer;
    sheetname: array of string;
    xlsdata: VARIANT;
    keystr: TStringList;
    docfilename: string;
  private
    function thistable_beginrow(ATABLE: Variant): cellxy;
    function orderinsheet(keyname: string; columnnames: array of string):
      integer;
    function maxcolumncount: Integer;
    procedure tablecolumnname_tonumber(tableorder: Integer; ATABLE: Variant);
    function split_tocellrec(acell: string): cellrec;
    function sheetexists(aname: string): boolean;
    procedure arraytoword;
    procedure TterminateOLE(Prossname: string);
    procedure REPLACEBASEINFO(xWORD: VARIANT);
    procedure replaceword(sourceSTR, targetSTR: string);
    procedure replacewordlike(sourceSTR, targetSTR: string); //通配符查找
    function othertostring(asheet: Variant): string;
  public
    constructor create(xlsapplication: OleVariant; xlsfilename: string);
    procedure alltables_tonumber();
    procedure xlstoarray();
  end;

implementation

{ xzh }

procedure xzh.alltables_tonumber;
var
  i, tablescount: integer;
begin
  if not FileExists(docfilename) then exit;
  tablescount := docapp.activedocument.tables.count;
  setlength(columnpos, tablescount, maxcolumncount + 2);
  setlength(sheetname, tablescount);
  for i := 1 to tablescount do
  begin
    tablecolumnname_tonumber(i - 1, docapp.activedocument.tables.item(i));
  end;

  xlstoarray;
  arraytoword;
end;

procedure xzh.tablecolumnname_tonumber(tableorder: Integer; ATABLE: Variant);
var
  i, icolumncount: integer;
  startcell: cellxy;
  acellrec: cellrec;
  atext: string;
  sheetcolumnscount: integer;
  sheetcolumnsname: array of string;
begin
  //
  startcell := thistable_beginrow(atable);
  atext := ATABLE.cell(startcell.row, startcell.column).range.text;
  acellrec := split_tocellrec(atext);
  sheetname[tableorder] := acellrec.sheetname;

  if not sheetexists(acellrec.sheetname) then
    exit;

  xlsapp.activeworkbook.sheets[acellrec.sheetname].activate;
  sheetcolumnscount :=
    xlsapp.activeworkbook.activesheet.usedrange.columns.count;
  SetLength(sheetcolumnsname, sheetcolumnscount);
  columnpos[tableorder, 0] := startcell.row;

  for i := 1 to sheetcolumnscount do
    sheetcolumnsname[i - 1] := xlsapp.activeworkbook.activesheet.cells[2, i];

  for i := 1 to ATABLE.columns.count do
  begin
    atext := ATABLE.cell(startcell.row, i).range.text;
    acellrec := split_tocellrec(atext);
    columnpos[tableorder, i + 1] := orderinsheet(acellrec.columnname,
      sheetcolumnsname) + 1;
  end;
  columnpos[tableorder, 1] := ATABLE.columns.count;

end;

constructor xzh.create(xlsapplication: OleVariant; xlsfilename: string);
begin
  //
  keystr := TStringList.Create;
  docfilename := stringreplace(xlsfilename, '.xlsx', '.doc', []);
  docfilename := stringreplace(docfilename, '.xls', '.doc', []);
  if not FileExists(docfilename) then
  begin
    mymessage('没有找到对应的WORD模板文件，不能进行后续生成操作！');
    exit;
  end;
  xlsapp := xlsapplication;
  xlsapp.workbooks.open(xlsfilename);

  TterminateOLE('winword.exe');
  try
    docapp := CreateOleObject('Word.Application');
    docapp.Visible := true;
    docapp.DisplayAlerts := false;
    fdoc := docapp.documents.open(docfilename);
  except
    mymessage('创建word对象失败！');
    Exit;
  end;
end;

function xzh.maxcolumncount: Integer;
var
  i: integer;
begin
  //
  result := 0;
  for i := 1 to xlsapp.activeworkbook.sheets.count do
  begin
    xlsapp.activeworkbook.sheets[i].activate;
    if result < xlsapp.activeworkbook.sheets[i].usedrange.columns.count then
      result := xlsapp.activeworkbook.sheets[i].usedrange.columns.count;
  end;
end;

function xzh.orderinsheet(keyname: string;
  columnnames: array of string): integer;
var
  i: integer;
begin
  result := -1;
  for i := 1 to High(columnnames) do
  begin
    if trim(columnnames[i]) = trim(keyname) then
    begin
      result := i;
      break;
    end;
  end;
end;

function xzh.thistable_beginrow(ATABLE: Variant): cellxy;
var
  I, j, irowcount, icolcount: integer;
  xtabel: Variant;
begin
  result.row := -1;
  Result.column := -1;
  xtabel := ATABLE;
  irowcount := xtabel.rows.count;
  icolcount := xtabel.columns.count;

  for j := 1 to icolcount do
    for i := 1 to irowcount do
      if xtabel.cell(i, j).rowindex <> -1 then
      begin
        if Pos('【', xtabel.cell(i, j).range.text) > 0 then
        begin
          result.row := i;
          Result.column := j;
          break;
        end;
      end;
end;

function xzh.split_tocellrec(acell: string): cellrec;
var
  pos1, pos2: integer;
begin
  //
  Result.sheetname := '';
  Result.columnname := '';
  pos1 := Pos('【', acell);
  pos2 := Pos('.', acell);
  Result.sheetname := Copy(acell, pos1 + 2, pos2 - pos1 - 2);

  pos1 := Pos('】', acell);
  Result.columnname := Copy(acell, pos2 + 1, pos1 - pos2 - 1);

end;

function xzh.sheetexists(aname: string): boolean;
var
  xstr: string;
begin
  //  表名是否存在
  result := False;
  if trim(aname) = '' then
    exit;
  try

    try
      xstr := xlsapp.ActiveWorkbook.Sheets.Item[aname].name;
      result := true;
    except
      result := False;
    end;

  except
  end;
end;

procedure xzh.xlstoarray;
var
  i, j: integer;
  thissheet: Variant;
  asheet, bsheet: Variant;
  allrec, rows, cols: Integer;
begin
  //
  if not sheetexists('总表') then
  begin
    bsheet := xlsapp.activeworkbook.sheets.add;
    bsheet.name := '总表';
  end
  else
  begin
    bsheet := xlsapp.activeworkbook.sheets['总表'];
    bsheet.cells.delete;
  end;

  allrec := 1;

  for i := 0 to High(sheetname) do //   - 1
  begin
    if (sheetname[i] <> '') and (sheetexists(sheetname[i])) then
    begin

      asheet := xlsapp.activeworkbook.sheets[sheetname[i]];

      //     if asheet.Visible = xlSheetVisible then
      begin
        try
          asheet.Activate;
          asheet.cells.select;
          asheet.cells.UnMerge;
          bsheet.Activate;
          asheet.usedrange.copy(bsheet.range['b' + trim(inttostr(allrec)),
            emptyparam]);
          bsheet.range['a' + trim(inttostr(allrec)), 'a' + trim(inttostr(allrec
            + asheet.usedrange.rows.count - 1))].value := asheet.Name;
          bsheet.range['a' + trim(inttostr(allrec)), 'a' + trim(inttostr(allrec
            + 1))].EntireRow.DELETE;

          allrec := allrec + asheet.usedrange.rows.count - 2;
        except
        end;
      end;
    end;
  end;

  othertostring(bsheet);

  bsheet.Activate;
  ROWS := BSHEET.usedrange.rows.count;

  cols := bsheet.usedrange.columns.count;
  xlsdata :=
    bsheet.Range[bsheet.cells.Item[1, 1], bsheet.cells.Item[rows, cols]].Value;

  keystr.Clear;
  allrec := 0;

  try
    for i := 1 to rows do
    begin
      if Trim(xlsdata[i, 2]) <> '' then
        if keystr.IndexOf(xlsdata[i, 2]) = -1 then
        begin
          keystr.Add(xlsdata[i, 2]);
        end;
    end;
  except
  end;
  // mymessage(xlsdata[2, 1]);
  xlsapp.ActiveWorkbook.Save;

  //  mymessage('OK');
end;

procedure xzh.arraytoword;
var
  aword, baseword, lastword: variant;
  i, j, k, m: integer;
  tmp: integer;
  wordcolumn_inxlscolumn: integer;
  current_row_inwordtable, current_col_inwordtable, current_table_inword:
  integer;
  xzperson: string;
  curtable: Variant;
  linecount: integer;
  oldsheetname: string;
begin
  //
  baseword := docapp.activedocument;
  REPLACEBASEINFO(baseword);

  docapp.Selection.WholeStory;
  docapp.Selection.Copy;
  LASTWORD := docapp.Documents.Add();
  aword := docapp.Documents.Add();
  docapp.Selection.Paste;

  for i := 0 to keystr.count - 1 do
  begin
    //=======
    xzperson := keystr[i];
    linecount := 0;
    oldsheetname := '';
    for j := 1 to VarArrayHighBound(xlsdata, 1) do
    begin
      if xlsdata[j, 2] = keystr[i] then
      begin


        for current_table_inword := 0 to High(sheetname) do
        begin
          if xlsdata[j, 1] = sheetname[current_table_inword] then
          begin
            if sheetname[current_table_inword] <> oldsheetname
              then linecount := 0 else linecount := linecount + 1;

            oldsheetname := sheetname[current_table_inword];
            curtable := aword.tables.item(current_table_inword + 1);
            current_row_inwordtable := columnpos[current_table_inword, 0] + linecount;
            curtable.cell(current_row_inwordtable, 1).range.Select;
            docapp.Selection.InsertRowsBelow(1);

            for current_col_inwordtable := 1 to columnpos[current_table_inword, 1] do
             //word表格中的第一列到最后一列 ，columnpos[k,1]中是其总列数
            begin
              wordcolumn_inxlscolumn := columnpos[current_table_inword, current_col_inwordtable + 1];
              try
                if wordcolumn_inxlscolumn > 0 then
                  curtable.cell(current_row_inwordtable, current_col_inwordtable).range.text := xlsdata[j, wordcolumn_inxlscolumn + 1]
                else
                  curtable.cell(current_row_inwordtable, current_col_inwordtable).range.text := '';
              except
                curtable.cell(current_row_inwordtable, current_col_inwordtable).range.text := '';
              end;
            end;

          //  columnpos[current_table_inword, 0] := columnpos[current_table_inword, 0] + 1;
          end;
        end;
      end;
    end;
    //========
    AWORD.ACTIVATE;
    replaceword('【询证对象】', Trim(xzperson));

    docapp.Selection.WholeStory;
    docapp.Selection.Copy;
    LASTWORD.ACTIVATE;
    docapp.Selection.EndKey(wdStory);
    docapp.Selection.Paste;

    BASEWORD.ACTIVATE;
    docapp.Selection.WholeStory;
    docapp.Selection.Copy;
    AWORD.ACTIVATE;
    docapp.Selection.WholeStory;
    docapp.Selection.DELETE;
    docapp.Selection.Paste;
  end;


  BASEWORD.CLOSE(false);
  AWORD.CLOSE(false);
  lastword.activate;
  replacewordlike('【*】', '');
  lastword.saveas(extractfilepath(xlsapp.activeworkbook.fullname) + trim(xzperson) + '.doc');

  xlsapp.activeworkbook.sheets['总表'].delete;
  xlsapp.activeworkbook.save;
  mymessage('OK');
end;

procedure xzh.TterminateOLE(Prossname: string);
var
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
  Ret: BOOL;
  ProcessID: integer;
  s: string;
begin
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := Sizeof(FProcessEntry32);
  Ret := Process32First(FSnapshotHandle, FProcessEntry32);
  while Ret do
  begin
    s := ExtractFileName(FProcessEntry32.szExeFile);
    if uppercase(s) = uppercase(prossname) then
    begin
      ProcessID := FProcessEntry32.th32ProcessID;
      TerminateProcess(OpenProcess(PROCESS_TERMINATE, false, ProcessID), 1);
      s := '';
    end;
    Ret := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
end;

procedure xzh.REPLACEBASEINFO(xWORD: VARIANT);
var baseinfo: Variant;
  i, rows, cols: integer;
  asheet: Variant;
begin
//
  asheet := XLSAPP.ACTIVEWORKbook.sheets['基本情况'];
  asheet.activate;
  othertostring(asheet);
  rows := asheet.usedrange.rows.count;
 // cols := asheet.usedrange.columns.count;
  xword.activate;
  baseinfo := asheet.range[asheet.cells.Item[1, 1], asheet.cells.Item[rows, 2]].value;
  for i := 1 to rows do
  begin
    baseinfo[i, 1] := '【基本情况.' + trim(baseinfo[i, 1]) + '】';
    replaceword(baseinfo[i, 1], Trim(baseinfo[i, 2]));
  end;
end;



procedure xzh.replaceword(sourceSTR, targetSTR: string);
begin
//   替换
  docapp.Selection.homeKey(unit := wdStory);

  docapp.Selection.Find.ClearFormatting;
  docapp.Selection.Find.Replacement.ClearFormatting;
  docapp.Selection.Find.Text := sourceSTR;
  docapp.Selection.Find.Replacement.Text := targetSTR;
  docapp.Selection.Find.Forward := True;
 // docapp.Selection.Find.Wrap := wdFindAsk;
  docapp.Selection.Find.Format := False;
  docapp.Selection.Find.MatchCase := False;
  docapp.Selection.Find.MatchWholeWord := False;
  docapp.Selection.Find.MatchByte := True;
  docapp.Selection.Find.MatchWildcards := False;
  docapp.Selection.Find.MatchSoundsLike := False;
  docapp.Selection.Find.MatchAllWordForms := False;
  docapp.Selection.Find.Execute(Replace := wdReplaceAll);
end;

procedure xzh.replacewordlike(sourceSTR, targetSTR: string);
begin
//   替换
  docapp.Selection.homeKey(unit := wdStory);

  docapp.Selection.Find.ClearFormatting;
  docapp.Selection.Find.Replacement.ClearFormatting;
  docapp.Selection.Find.Text := sourceSTR;
  docapp.Selection.Find.Replacement.Text := targetSTR;
  docapp.Selection.Find.Forward := True;
 // docapp.Selection.Find.Wrap := wdFindAsk;
  docapp.Selection.Find.Format := False;
  docapp.Selection.Find.MatchCase := False;
  docapp.Selection.Find.MatchWholeWord := False;
  docapp.Selection.Find.MatchByte := True;
  docapp.Selection.Find.MatchWildcards := true;
  docapp.Selection.Find.MatchSoundsLike := False;
  docapp.Selection.Find.MatchAllWordForms := False;
  docapp.Selection.Find.Execute(Replace := wdReplaceAll);
end;

function xzh.othertostring(asheet: Variant): string;
var
  i, j: Integer;

  strval: string;
begin
//
  asheet.activate;
  for j := 1 to asheet.usedrange.columns.count do
    asheet.columns.item[j].AutoFit;


  for i := 1 to asheet.usedrange.rows.count do
    for j := 1 to asheet.usedrange.columns.count do
    begin
      if Trim(asheet.cells.item[i, j].Text) <> '' then
        if leftstr(Trim(asheet.cells.item[i, j].Text), 1) <> '"' then
        begin
          strval := '''' + Trim(asheet.cells.Item[i, j].text);
          asheet.cells.item[i, j].value := strval;
        end;
    end;


end;



end.
