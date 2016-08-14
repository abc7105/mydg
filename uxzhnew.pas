unit uxzhnew;

interface
uses
  Forms, Windows, Messages, Graphics, Controls,
  SysUtils, ComObj, Variants, ushare,
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
  Sheetname_AND_ColumnNo = record
    SheetName: string;
    columnname: string;
  end;

  CellXY = record
    row: integer;
    column: integer;
  end;

  xzh = class
    ExcelApp: Variant;
    WordApp: Variant;
    columnpos: array of array of integer;
    SheetName: array of string;
    xlsdata: VARIANT;
    KeyWordList: TStringList;
    mbword, oneword, targetword: Variable;

    DocFilename: string;
  private
    function sheetexists(aname: string): boolean;
    function ColumnNo_insheet(keyname: string; columnnames: array of string):
      integer;
    function Firstdatacell_OfWordtable(AWordtable: Variant): CellXY;
    function MaxColumnCount_InAllsheets: Integer;

    procedure TableData_fromOneTable(tableorder: Integer; aWordTable: Variant);
    function Text_To_Sheetname_AND_ColumnNo(acell: string):
      Sheetname_AND_ColumnNo;
    procedure arraytoword;

    procedure Baseinfo_FromBaseSheet(xWORD: VARIANT);
    procedure replaceword(sourceSTR, targetSTR: string);
    procedure replacewordlike(sourceSTR, targetSTR: string); //通配符查找
    function Othertype_InExcelcell_ToString(asheet: Variant): string;

    procedure TterminateOLE(Prossname: string);
    procedure xlstoarray();
    procedure aWORDTable_FromExcelSHEET(TableOrderNO:integer);

  public
    constructor create(ExcelApplication: OleVariant; xlsfilename: string);
    procedure ALLsheetdata_intoDOC();

  end;

implementation

uses
  communit;

{ xzh }

constructor xzh.create(ExcelApplication: OleVariant; xlsfilename: string);
begin
  //
  KeyWordList := TStringList.Create;
  DocFilename := stringreplace(xlsfilename, '.xlsx', '.doc', []);
  DocFilename := stringreplace(DocFilename, '.xls', '.doc', []);
  if not FileExists(DocFilename) then
  begin
    mymessage('没有找到对应的WORD模板文件[*.doc]，不能进行后续生成操作！');
    exit;
  end;
  ExcelApp := ExcelApplication;
  ExcelApp.workbooks.open(xlsfilename);

  TterminateOLE('winword.exe');
  try
    WordApp := CreateOleObject('Word.Application');
    WordApp.Visible := true;
    WordApp.DisplayAlerts := false;
    mbword := WordApp.documents.open(DocFilename);

    oneword := WordApp.Documents.Add();
    targetword := WordApp.Documents.Add();
  except
    mymessage('创建word对象失败！');
    Exit;
  end;
end;

procedure xzh.ALLsheetdata_intoDOC;
var
  i, tablesCount: integer;
begin
  if not FileExists(DocFilename) then
    exit;

  tablesCount := mbword.tables.count;
  setlength(columnpos, tablesCount, MaxColumnCount_InAllsheets + 2);
  setlength(SheetName, tablesCount);

  for i := 1 to tablesCount do
  begin
    aWORDTable_FromExcelSHEET(i);
  end;

  //    xlstoarray;
  //    arraytoword;
end;

procedure xzh.aWORDTable_FromExcelSHEET(TableOrderNO:integer);
var
  atable: Variant;
begin
  atable:=mbword.

end;

procedure xzh.TableData_fromOneTable(tableorder: Integer; aWordTable: Variant);
var
  i, icolumncount: integer;
  startcell: CellXY;
  aSheetname_AND_ColumnNo: Sheetname_AND_ColumnNo;
  atext: string;
  sheetcolumnscount: integer;
  sheetcolumnsname: array of string;
begin
  //
  startcell := Firstdatacell_OfWordtable(aWordTable);
  atext := aWordTable.cell(startcell.row, startcell.column).range.text;
  aSheetname_AND_ColumnNo := Text_To_Sheetname_AND_ColumnNo(atext);
  SheetName[tableorder] := aSheetname_AND_ColumnNo.SheetName;

  if not sheetexists(aSheetname_AND_ColumnNo.SheetName) then
    exit;

  ExcelApp.activeworkbook.sheets[aSheetname_AND_ColumnNo.SheetName].activate;
  sheetcolumnscount :=
    ExcelApp.activeworkbook.activesheet.usedrange.columns.count;
  SetLength(sheetcolumnsname, sheetcolumnscount);
  columnpos[tableorder, 0] := startcell.row;

  for i := 1 to sheetcolumnscount do
    sheetcolumnsname[i - 1] := ExcelApp.activeworkbook.activesheet.cells[2, i];

  for i := 1 to aWordTable.columns.count do
  begin
    atext := aWordTable.cell(startcell.row, i).range.text;
    aSheetname_AND_ColumnNo := Text_To_Sheetname_AND_ColumnNo(atext);
    columnpos[tableorder, i + 1] :=
      ColumnNo_insheet(aSheetname_AND_ColumnNo.columnname,
      sheetcolumnsname) + 1;
  end;

  columnpos[tableorder, 1] := aWordTable.columns.count;

end;

function xzh.MaxColumnCount_InAllsheets: Integer;
var
  i: integer;
begin
  //
  result := 0;
  for i := 1 to ExcelApp.activeworkbook.sheets.count do
  begin
    ExcelApp.activeworkbook.sheets[i].activate;
    if result < ExcelApp.activeworkbook.sheets[i].usedrange.columns.count then
      result := ExcelApp.activeworkbook.sheets[i].usedrange.columns.count;
  end;
end;

function xzh.ColumnNo_insheet(keyname: string;
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

function xzh.Firstdatacell_OfWordtable(AWordtable: Variant): CellXY;
var
  I, j, irowcount, icolcount: integer;
  xtabel: Variant;
begin
  result.row := -1;
  Result.column := -1;
  xtabel := AWordtable;
  irowcount := xtabel.rows.count;
  icolcount := xtabel.columns.count;

  try
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
  except
  end;
end;

function xzh.Text_To_Sheetname_AND_ColumnNo(acell: string):
  Sheetname_AND_ColumnNo;
var
  pos1, pos2: integer;
begin
  //
  Result.SheetName := '';
  Result.columnname := '';
  pos1 := Pos('【', acell);
  pos2 := Pos('.', acell);
  Result.SheetName := Copy(acell, pos1 + 2, pos2 - pos1 - 2);

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
      xstr := ExcelApp.ActiveWorkbook.Sheets.Item[aname].name;
      result := true;
    except
      result := False;
    end;
  except
  end;
end;

function xzh.CreateaTemplateSheet(): Variant;
var
  BSHEET: Variant;
begin
  //思路建一个总表
  RESULT := null;
  if not sheetexists('总表') then
  begin
    bsheet := ExcelApp.activeworkbook.sheets.add;
    bsheet.name := '总表';
  end
  else
  begin
    bsheet := ExcelApp.activeworkbook.sheets['总表'];
    bsheet.cells.delete;
  end;
  RESULT := BSHEET;
end;

procedure xzh.xlstoarray;
var
  i, j: integer;
  thissheet: Variant;
  asheet, bsheet: Variant;
  allrec, rows, cols: Integer;
begin

  //将所有表的关键值复制到总表中
  bsheet := CreateaTemplateSheet;

  allrec := 1;
  for i := 0 to High(SheetName) do
  begin
    if (SheetName[i] <> '') and (sheetexists(SheetName[i])) then
    begin
      asheet := ExcelApp.activeworkbook.sheets[SheetName[i]];
      try
        asheet.Activate;
        asheet.cells.select;
        asheet.cells.UnMerge;
        bsheet.Activate;

        //将每一个数据表的内容复制到临时表 总表中
        asheet.usedrange.copy(bsheet.range['b' + trim(inttostr(allrec)),
          emptyparam]);

        //将第一列改为数据所对应表的表格
        bsheet.range['a' + trim(inttostr(allrec)), 'a' + trim(inttostr(allrec
          + asheet.usedrange.rows.count - 1))].value := asheet.Name;
        bsheet.range['a' + trim(inttostr(allrec)), 'a' + trim(inttostr(allrec
          + 1))].EntireRow.DELETE;

        allrec := allrec + asheet.usedrange.rows.count - 2;
      except
      end;
    end;
  end;

  Othertype_InExcelcell_ToString(bsheet);

  bsheet.Activate;
  ROWS := BSHEET.usedrange.rows.count;
  cols := bsheet.usedrange.columns.count;
  xlsdata :=
    bsheet.Range[bsheet.cells.Item[1, 1], bsheet.cells.Item[rows, cols]].Value;

  KeyWordList.Clear;
  allrec := 0;

  //从总表中将所有关键值加入到keywordlist;
  //取得需打印的所有表中不重复的关键值到KEYWORDLIST;
  try
    for i := 1 to rows do
    begin
      if Trim(xlsdata[i, 2]) <> '' then
        if KeyWordList.IndexOf(xlsdata[i, 2]) = -1 then
        begin
          KeyWordList.Add(xlsdata[i, 2]);
        end;
    end;
  except
  end;

  ExcelApp.ActiveWorkbook.Save;
end;

procedure XZH.GeneralOnePage(keyorder: Integer);
begin
  xzperson := KeyWordList[i];
  linecount := 0;
  oldSheetName := '';
  for j := 1 to VarArrayHighBound(xlsdata, 1) do
  begin
    if xlsdata[j, 2] = KeyWordList[keyorder] then
    begin
      GeneralOneLine;
    end;
  end;
end;
//========
AWORD.ACTIVATE;
replaceword('【询证对象】', Trim(xzperson));

end;

procedure xzh.GeneralOneLine()
begin
  for WordTableNo := 0 to High(SheetName) do
  begin
    if xlsdata[j, 1] = SheetName[WordTableNo] then
    begin
      if SheetName[WordTableNo] <> oldSheetName then
        linecount := 0
      else
        linecount := linecount + 1;

      oldSheetName := SheetName[WordTableNo];
      curtable := aword.tables.item(WordTableNo + 1);
      current_row_inwordtable := columnpos[WordTableNo, 0] +
        linecount;
      curtable.cell(current_row_inwordtable, 1).range.Select;
      WordApp.Selection.InsertRowsBelow(1);

      for current_col_inwordtable := 1 to columnpos[WordTableNo,
        1] do
        //word表格中的第一列到最后一列 ，columnpos[k,1]中是其总列数
      begin
        wordcolumn_inxlscolumn := columnpos[WordTableNo,
          current_col_inwordtable + 1];
        try
          if wordcolumn_inxlscolumn > 0 then
            curtable.cell(current_row_inwordtable,
              current_col_inwordtable).range.text := xlsdata[j,
              wordcolumn_inxlscolumn + 1]
          else
            curtable.cell(current_row_inwordtable,
              current_col_inwordtable).range.text := '';
        except
          curtable.cell(current_row_inwordtable,
            current_col_inwordtable).range.text := '';
        end;
      end;
    end;

  end;

procedure xzh.arraytoword;
var
  aword, baseword, lastword: variant;
  i, j, k, m: integer;
  tmp: integer;
  wordcolumn_inxlscolumn: integer;
  current_row_inwordtable, current_col_inwordtable, WordTableNo:
    integer;
  xzperson: string;
  curtable: Variant;
  linecount: integer;
  oldSheetName: string;
begin
  //
  baseword := WordApp.activedocument;
  Baseinfo_FromBaseSheet(baseword);

  //复制模板版-> aword->lastword文档中
  WordApp.Selection.WholeStory;
  WordApp.Selection.Copy;
  LASTWORD := WordApp.Documents.Add();
  aword := WordApp.Documents.Add();
  WordApp.Selection.Paste;

  for i := 0 to KeyWordList.count - 1 do
  begin

    GeneralOnePage;

    WordApp.Selection.WholeStory;
    WordApp.Selection.Copy;
    LASTWORD.ACTIVATE;
    WordApp.Selection.EndKey(wdStory);
    WordApp.Selection.Paste;

    BASEWORD.ACTIVATE;
    WordApp.Selection.WholeStory;
    WordApp.Selection.Copy;
    AWORD.ACTIVATE;
    WordApp.Selection.WholeStory;
    WordApp.Selection.DELETE;
    WordApp.Selection.Paste;
  end;

  BASEWORD.CLOSE(false);
  AWORD.CLOSE(false);
  lastword.activate;
  replacewordlike('【*】', '');
  lastword.saveas(extractfilepath(ExcelApp.activeworkbook.fullname) +
    trim(xzperson) + '.doc');

  ExcelApp.activeworkbook.sheets['总表'].delete;
  ExcelApp.activeworkbook.save;
  mymessage('OK');
end;

procedure xzh.fillonetable(aword: Variant; wordtableno: Integer; linecount:
  integer);
var
  curtable: Variant;
  wordtableROW, wordtableCOL: Integer;

begin

  curtable := aword.tables.item(WordTableNo + 1);
  wordtableROW := columnpos[WordTableNo, 0] + linecount;
  curtable.cell(wordtableROW, 1).range.Select;
  WordApp.Selection.InsertRowsBelow(1);

  //word表格中的第一列到最后一列 ，columnpos[k,1]中是其总列数
  for wordtableCOL := 1 to columnpos[WordTableNo, 1] do
  begin
    wordcolumn_inxlscolumn := columnpos[WordTableNo, wordtableCOL + 1];
    try
      if wordcolumn_inxlscolumn > 0 then
        curtable.cell(wordtableROW, wordtableCOL).range.text := xlsdata[j,
          wordcolumn_inxlscolumn + 1]
      else
        curtable.cell(wordtableROW, wordtableCOL).range.text := '';
    except
      curtable.cell(wordtableROW, wordtableCOL).range.text := '';
    end;
  end;

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

procedure xzh.Baseinfo_FromBaseSheet(xWORD: VARIANT);
var
  baseinfo: Variant;
  i, rows, cols: integer;
  asheet: Variant;
begin
  asheet := ExcelApp.ACTIVEWORKbook.sheets['基本情况'];
  asheet.activate;

  Othertype_InExcelcell_ToString(asheet);

  rows := asheet.usedrange.rows.count;
  xword.activate;
  baseinfo := asheet.range[asheet.cells.Item[1, 1], asheet.cells.Item[rows,
    2]].value;
  for i := 1 to rows do
  begin
    baseinfo[i, 1] := '【基本情况.' + trim(baseinfo[i, 1]) + '】';
    replaceword(baseinfo[i, 1], Trim(baseinfo[i, 2]));
  end;
end;

procedure xzh.replaceword(sourceSTR, targetSTR: string);
begin
  //   替换
  WordApp.Selection.homeKey(unit := wdStory);

  WordApp.Selection.Find.ClearFormatting;
  WordApp.Selection.Find.Replacement.ClearFormatting;
  WordApp.Selection.Find.Text := sourceSTR;
  WordApp.Selection.Find.Replacement.Text := targetSTR;
  WordApp.Selection.Find.Forward := True;
  // WordApp.Selection.Find.Wrap := wdFindAsk;
  WordApp.Selection.Find.Format := False;
  WordApp.Selection.Find.MatchCase := False;
  WordApp.Selection.Find.MatchWholeWord := False;
  WordApp.Selection.Find.MatchByte := True;
  WordApp.Selection.Find.MatchWildcards := False;
  WordApp.Selection.Find.MatchSoundsLike := False;
  WordApp.Selection.Find.MatchAllWordForms := False;
  WordApp.Selection.Find.Execute(Replace := wdReplaceAll);
end;

procedure xzh.replacewordlike(sourceSTR, targetSTR: string);
begin
  //   替换
  WordApp.Selection.homeKey(unit := wdStory);

  WordApp.Selection.Find.ClearFormatting;
  WordApp.Selection.Find.Replacement.ClearFormatting;
  WordApp.Selection.Find.Text := sourceSTR;
  WordApp.Selection.Find.Replacement.Text := targetSTR;
  WordApp.Selection.Find.Forward := True;
  // WordApp.Selection.Find.Wrap := wdFindAsk;
  WordApp.Selection.Find.Format := False;
  WordApp.Selection.Find.MatchCase := False;
  WordApp.Selection.Find.MatchWholeWord := False;
  WordApp.Selection.Find.MatchByte := True;
  WordApp.Selection.Find.MatchWildcards := true;
  WordApp.Selection.Find.MatchSoundsLike := False;
  WordApp.Selection.Find.MatchAllWordForms := False;
  WordApp.Selection.Find.Execute(Replace := wdReplaceAll);
end;

function xzh.Othertype_InExcelcell_ToString(asheet: Variant): string;
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
 
