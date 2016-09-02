unit u_xzh;

interface
uses
  Forms, Windows, Messages, Graphics, Controls,
  SysUtils, ComObj, Variants, ushare,
  TLhelp32, ExtCtrls, Word2000, ShellAPI,
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
    dataSheetName: array of string;
    xlsdata: VARIANT;
    KeyWordList: TStringList;
    mbword: Variant;
    oneword, targetword: Variant;
    DocFilename: string;
    wordkey, wordvalue: tstringlist;
  private
    function sheetexists(aname: string): boolean;
    function ColumnNo_insheet(keyname: string; columnnames: array of string):
      integer;
    function Firstdatacell_OfWordtable(AWordtable: Variant): CellXY;
    function MaxColumnCount_InAllsheets: Integer;

    function Text_To_Sheetname_AND_ColumnNo(acell: string):
      Sheetname_AND_ColumnNo;

    procedure Baseinfo_FromBaseSheet(xWORD: VARIANT);
    procedure replaceword(sourceSTR, targetSTR: string);
    procedure replacewordlike(sourceSTR, targetSTR: string); //通配符查找
    function Othertype_InExcelcell_ToString(asheet: Variant): string;

    procedure TterminateOLE(Prossname: string);
    procedure aWORDTable_FromExcelSHEET(TableOrderNO: integer);
    function GetOopposiftsheet(atable: Variant): Variant;

    function CreateaTemplateSheet(): Variant;
    procedure general_keywordlist();

    procedure copy_asheet_to_bsheet(asheet, bsheet: Variant);
    procedure bsheet_into_keywordlist(datasheet: Variant);

    procedure general_all_word_page();
    procedure general_one_word_page(akeyword: string);
    procedure general_one_word_tabel(atable: Variant; const akeyword: string);
    function columeIndexof(asheet: Variant; ColumeName: string): integer;
    procedure replace_keyvalue();
  public
    constructor create(ExcelApplication: OleVariant; xlsfilename: string);
    procedure ALLsheetdata_intoDOC();

  end;

implementation

uses
  communit, Udebug;

{ xzh }

//=======================================================================
//        设计思路
//   1 先从word中将每个表格引用的EXCEL的SHEET作个统计，然后将这些sheet中的第一列数据作为关键字取不重复值放入KEYWORDLIST
//   2 循环取每个KEYWORD，每个KEYWORD作为一页处理
//   3 每一页循环复制模板，对每个表格进行处理 ，然后复制到最终表格中去。
//
//=======================================================================

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

  DebugReset;
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
  setlength(dataSheetName, tablesCount);

  general_keywordlist;
  general_all_word_page;

 // ShellExecute(0, 'open', PChar(mainpath + 'test.txt'), nil, nil, 1);
  SHOWMESSAGE('函证的WORD文档生成完毕');
end;

procedure xzh.general_all_word_page();
var
  i: Integer;
  keyword: string;
begin
  //debugto('开始处理所有页');
  wordkey := tstringlist.create();
  wordvalue := tstringlist.create();

  //debugto('’取得基本信息');
  Baseinfo_FromBaseSheet(mbword);
  //debugto('取得基本信息结束 ！');

  if KeyWordList.Count < 1 then
  begin
    //   SHOWMESSAGE('主关键字为空，请检查您的数据填写是否正确！');
    EXIT;
  end;

  //debugto(inttostr(KeyWordList.Count));
  for i := 0 to KeyWordList.Count - 1 do
  begin
    //debugto('=====================================');
    //debugto('162开始 处理 ' + inttostr(i) + '关键词');
    //debugto('=====================================');
    mbword.ACTIVATE;
    WordApp.Selection.WholeStory;
    WordApp.Selection.Copy;

    ONEWORD.ACTIVATE;
    WordApp.Selection.WholeStory;
    WordApp.Selection.DELETE;
    WordApp.Selection.Paste;
    WordApp.Selection.HOMEKey(wdStory);

    keyword := keywordlist[i];
    general_one_word_page(keyword);

    ONEWORD.ACTIVATE;
    WordApp.Selection.WholeStory;
    WordApp.Selection.Copy;

    targetword.ACTIVATE;
    WordApp.Selection.EndKey(wdStory);
    WordApp.Selection.Paste;
    //  if i > 0 then
    WordApp.Selection.InsertBreak(type := wdPageBreak);
  end;

  MBWORD.CLOSE(FALSE);
  ONEWORD.CLOSE(FALSE);
  targetword.ACTIVATE;
  WordApp.Selection.HOMEKey(wdStory);

  replacewordlike('【*】', '');
  targetword.saveas(extractfilepath(ExcelApp.activeworkbook.fullname) +
    trim('temp') + '.doc');

  ExcelApp.activeworkbook.sheets['总表'].delete;
  ExcelApp.activeworkbook.save;
end;

procedure xzh.general_one_word_page(akeyword: string);
var
  i: Integer;
  atable: Variant;
begin
  wordkey.clear;
  wordvalue.clear;

  for i := 1 to oneword.tables.count do
  begin
    //debugto(inttostr(i) + ' 表 ' + akeyword);
    atable := oneword.tables.ITEM(i);
    general_one_word_tabel(atable, AKEYWORD);
  end;

  replace_keyvalue();
end;

procedure xzh.replace_keyvalue();
var
  i: Integer;
begin
  oneword.activate;
  for i := 0 to wordkey.count - 1 do
  begin
    //debugto('226行 ' + inttostr(i) + '次' +
  //    Trim(wordkey.strings[i]) + ' 227行  xx  ' + Trim(wordvalue.strings[i]));
    replaceword(Trim(wordkey.strings[i]), Trim(wordvalue.strings[i]));
  end;

end;

procedure xzh.general_one_word_tabel(atable: Variant; const akeyword: string);
var
  celltext, asheetname: string;
  i, J, datarow, currow, curcol, columncounts: integer;
  firstMBcell: CellXY;
  aSheetname_AND_ColumnNo: Sheetname_AND_ColumnNo;
  TABLECOLUMN_TO_EXCELCOLUMN: array of Integer;
  linecount: Integer;
  asheet: Variant;
begin

  firstMBcell := Firstdatacell_OfWordtable(atable);
  if (firstMBcell.row = -1) or (firstMBcell.COLUMN = -1) then
    exit;

  celltext := atable.cell(firstMBcell.row, firstMBcell.COLUMN).range.text;
  aSheetname_AND_ColumnNo := Text_To_Sheetname_AND_ColumnNo(celltext);
  asheetname := aSheetname_AND_ColumnNo.SheetName;
  if trim(asheetname) = '' then
    exit;

  try
    asheet := excelapp.activeworkbook.sheets.item[asheetname];
    //debugto(asheetname + '267 ok');
  except
    //debugto(asheetname + '267无对应的数据表sheet  ERR');
    exit;

  end;
  columncounts := atable.columns.count;
  datarow := firstMBcell.row;

  SetLength(TABLECOLUMN_TO_EXCELCOLUMN, columncounts);
  for i := 0 to columncounts - 1 do
  begin
    try
      celltext := atable.cell(datarow, I + 1).range.text;
      aSheetname_AND_ColumnNo := Text_To_Sheetname_AND_ColumnNo(celltext);
      TABLECOLUMN_TO_EXCELCOLUMN[I] := columeIndexof(asheet,
        aSheetname_AND_ColumnNo.columnname);
    except
    end;
  end;

  LINECOUNT := 1;
  for I := 1 to VarArrayHighBound(xlsdata, 1) do //1时为行数，2为列数
  begin
    if ((xlsdata[i, 2] = akeyword) and (xlsdata[i, 1] = asheetname)) then
    begin

      if LINECOUNT > 1 then //不是第一行，在word表中增加一行
      begin
        ATABLE.CELL(datarow + LINECOUNT - 1, 1).range.Select;
        WordApp.Selection.InsertRowsBelow(1);
      end;

      if LINECOUNT = 1 then
      begin
        //替换唯一值
        for j := 1 to asheet.columns.count do
        begin
          try
            if trim(asheet.cells.item[2, j].text) <> '' then
            begin
              wordkey.add('【' + trim(asheet.name) + '.' +
                trim(asheet.cells.item[2, j].text) + '】');
              wordvalue.add(xlsdata[i, j + 1]);
            end;
          except
          end;
        end;
      end;

      for J := 0 to columncounts - 1 do
      begin
        try
          if TABLECOLUMN_TO_EXCELCOLUMN[j] <> 0 then
            atable.cell(datarow + LINECOUNT - 1, j + 1).RANGE.text :=
              xlsdata[i, TABLECOLUMN_TO_EXCELCOLUMN[j]];

          //debugto('303 行:' + inttostr(datarow + LINECOUNT - 1) +
    //        ' 列:' + inttostr(j + 1) +
//            ' 值' + xlsdata[i, TABLECOLUMN_TO_EXCELCOLUMN[j]]);

        except
        end;

      end;
      Inc(LINECOUNT);
    end;
  end;
end;

function xzh.columeIndexof(asheet: Variant; ColumeName: string): integer;
var
  i: Integer;
begin
  result := 0;
  for i := 1 to asheet.usedrange.columns.Count do
  begin
    if trim(asheet.usedrange.cells.item[2, i].text) = Trim(ColumeName) then
    begin
      result := i + 1;
      break;
    end;
  end;
end;

procedure xzh.general_keywordlist();
var
  asheetname: string;
  atable, asheet, bsheet: Variant;
  rows, cols: integer;
  i: integer;
  acell: CellXY;
  atext: string;
  aSheetname_AND_ColumnNo: Sheetname_AND_ColumnNo;
begin
  bsheet := CreateaTemplateSheet;
  //debugto('general_keywordlist  ===========' + bsheet.name);

  for i := 1 to mbword.tables.count do
  begin
    atable := mbword.tables.item(i);
    acell := Firstdatacell_OfWordtable(atable);
    if (acell.row < 1) or (acell.column < 1) then
      Break;

    atext := atable.cell(acell.row, acell.column).range.text;
    aSheetname_AND_ColumnNo := Text_To_Sheetname_AND_ColumnNo(atext);

    //   datasheetname[i] := aSheetname_AND_ColumnNo.SheetName;
    try
      asheet :=
        excelapp.activeworkbook.sheets.item[aSheetname_AND_ColumnNo.SheetName];
      //debugto('general_keywordlist:' + IntToStr(i) + asheet.name);
      copy_asheet_to_bsheet(asheet, bsheet);
    except
      //debugto('error' + inttostr(i));
    end;
  end;

  try
    Othertype_InExcelcell_ToString(bsheet);
  except
  end;
  try
    //debugto('general_keywordlist:LAST :*****' + bsheet.name);
    bsheet_into_keywordlist(bsheet);
  except
  end;
  ExcelApp.ActiveWorkbook.Save;

end;

procedure xzh.bsheet_into_keywordlist(datasheet: Variant);
var
  i, rows, cols, allrec: integer;
begin
  try

    datasheet.Activate;
    //debugto('385 bsheet_into_keywordlist:' + datasheet.name);
    ROWS := datasheet.usedrange.rows.count;
    cols := datasheet.usedrange.columns.count;

    xlsdata :=
      datasheet.Range[datasheet.cells.Item[1, 1], datasheet.cells.Item[rows,
      cols]].Value;

    KeyWordList.Clear;
    allrec := 0;

    //从总表中将所有关键值加入到keywordlist;             第二列必须是关键字
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
  except
  end;
end;

procedure xzh.copy_asheet_to_bsheet(asheet, bsheet: variant);
var
  allrec: Integer;
begin
  allrec := bsheet.usedrange.rows.count + 1;
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

  //  allrec := allrec + asheet.usedrange.rows.count - 2;
end;

procedure xzh.aWORDTable_FromExcelSHEET(TableOrderNO: integer);
var
  atable: Variant;
  OppositeSheet: Variant; //对应的

begin
  atable := mbword.tables.item(TableOrderNO);
  OppositeSheet := GetOopposiftsheet(atable);
  OppositeSheet.activate;

end;

function xzh.GetOopposiftsheet(atable: Variant): Variant;
//word表对应的EXCEL中的sheet
var
  celltext, asheetname: string;
  wordcellXY: CellXY;
begin
  result := null;
  try
    wordcellXY := Firstdatacell_OfWordtable(atable);
    celltext := atable.cell(wordcellXY.row, wordcellXY.column).range.text;
    asheetname := Trim(Text_To_Sheetname_AND_ColumnNo(celltext).SheetName);
    result := ExcelApp.activeworkbook.sheets[asheetname];
  except

  end;
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

  for j := 1 to icolcount do
    for i := 1 to irowcount do
      try
        if xtabel.cell(i, j).rowindex > 0 then
        begin
          if Pos('【', xtabel.cell(i, j).range.text) > 0 then
          begin
            //           ShowMessage('486:' + xtabel.cell(i, j).range.text);
            result.row := i;
            Result.column := j;
            exit;
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
  try
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
      replaceword(baseinfo[i, 1], baseinfo[i, 2]);
      //debugto('【基本情况.' + trim(baseinfo[i, 1]) + '】  ==' + baseinfo[i, 2]);
    end;
  except

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
