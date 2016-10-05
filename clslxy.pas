unit clslxy;

interface

uses

  SysUtils, Variants, StrUtils, IniFiles, windows,
  mydg_TLB, DateUtils, ShellAPI, ushare, communit,
  Dialogs, Excel2000, ADODB, Classes;

type
  lxyexcel = class
    class function intto26(excelcolumn: integer): string;
    class function JFsymbol(direction: string): string;
    class function DFSymbol(direction: string): string;
    class function rowSUM(SOURCE, JFA, DFA, JFB, DFB, currentROW: INTEGER;
      DIRECTION: string): string;
    class function fillacell(Asheet: Variant; column, row: integer; value:
      variant): Boolean;
    class function sdb_commandline_num(asheet: Variant): integer;
    class procedure columnsum(asheet: Variant; row, column, directioncol,
      startline: Integer; mydirect: string);
    class procedure mxbcolumnsum(asheet: Variant; row, column, directioncol,
      startline: Integer; mydirect: string);

    class function UNDIRECT(STR: string): string;
    class procedure replace_asheet(WORKBOOK: VARIANT; sorder: integer);
    class procedure sheetreplace(AWORKBOOK: VARIANT; iorder: integer; ssource,
      starget: string);
    class procedure replace_allsheet(WORKBOOKA: VARIANT; axm: xminfo);
    class procedure fillzero(asheet: Variant; ncolumn: integer);
    class function filldate(asheet: Variant; ncolumn: integer): boolean;
    class function str8todate(str: string): TDateTime;
    class function IsDigit(str: string): Boolean;
    class function datefrom_YEARMONTH(STR: string): TDATETIME;
    class function datefrom_ALPHA(STR: string): TDATETIME;
    class function datefrom_8BIT(STR: string): TDATETIME;

  end;

implementation

{ lxyexcel }

class procedure lxyexcel.fillzero(asheet: Variant; ncolumn: integer);
var
  i, ncount: integer;
  acol: Variant;
begin
  //
  ncount := asheet.usedrange.rows.count;

  acol := asheet.Range[asheet.cells.Item[2, ncolumn],
    asheet.cells.Item[ncount, ncolumn]].Value;

  for i := 1 to ncount - 1 do
  begin
    try
      if VarIsNull(acol[i, 1]) then
        acol[i, 1] := 0
      else if VarIsEmpty(acol[i, 1]) then
        acol[i, 1] := 0
      else if VarIsStr(acol[i, 1]) then
        if (acol[i, 1] = '-') or (Trim(acol[i, 1]) = '') then
          acol[i, 1] := 0;

    except
    end;
  end;
  asheet.Range[asheet.cells.Item[2, ncolumn],
    asheet.cells.Item[ncount, ncolumn]].Value := acol;

end;

class function lxyexcel.filldate(asheet: Variant; ncolumn: integer): boolean;
var
  kk, ncount: integer;
  acol: Variant;
begin
  //
  result := False;
  ncount := asheet.usedrange.rows.count;

  acol := asheet.Range[asheet.cells.Item[2, ncolumn],
    asheet.cells.Item[ncount, ncolumn]].value;

  kk := 1;
  while kk <= ncount - 1 do
  begin

    if VarIsNumeric(acol[kk, 1]) then
      acol[kk, 1] := str8todate(IntToStr(acol[kk, 1]))
    else if VarIsStr(acol[kk, 1]) then
      acol[kk, 1] := str8todate(acol[kk, 1]);
    kk := kk + 1;
  end;
  asheet.Range[asheet.cells.Item[2, ncolumn],
    asheet.cells.Item[ncount, ncolumn]].Value := acol;
  result := True;
end;

class procedure lxyexcel.replace_allsheet(WORKBOOKA: VARIANT; axm: xminfo);
var
  i: Integer;
  XBOOk: variant;
begin
  xbook := workbooka;
  if axm.dwmc <> '' then
    for i := 1 to xbook.Sheets.Count do
      replace_asheet(xbook, i);
end;

class procedure lxyexcel.replace_asheet(WORKBOOK: VARIANT; sorder: integer);
var
  ABK: VARIANT;
begin
  ABK := WORKBOOK;
  //
//  if axm.dwmc <> '' then
//  begin
  sheetreplace(ABK, sorder, '单位单位单位单位单位单位单位单', axm.dwmc);
  sheetreplace(ABK, sorder, 'lxylxy  ', axm.editor);
  sheetreplace(ABK, sorder, '1999-10-10', DateToStr(axm.editrq));
  sheetreplace(ABK, sorder, '1999/10/10', DateToStr(axm.editrq));
  sheetreplace(ABK, sorder, 'abcabc  ', axm.checkor);
  sheetreplace(ABK, sorder, '1999-11-11', DateToStr(axm.checkRQ));
  sheetreplace(ABK, sorder, '1999/11/11', DateToStr(axm.checkRQ));
  sheetreplace(ABK, sorder, '1997年12月31日', DateToStr(axm.endrq));
  sheetreplace(ABK, sorder, '1997年01月—1997年12月', axm.yeard);
  //  end;
end;

class procedure lxyexcel.sheetreplace(AWORKBOOK: VARIANT; iorder: integer;
  ssource, starget: string);
var
  aa, bb: OleVariant;
  len1: Integer;
  BK: VARIANT;
begin
  //
  Bk := AWORKBOOK;
  aa := ssource;
  len1 := length(aa);
  bb := Trim(starget);
  if len1 - length(bb) >= 0 then
    bb := bb + space(len1 - length(bb));

  try
    Bk.Sheets[iorder].Cells.Replace(aa, bb, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam);
  except
  end;
end;

class function lxyexcel.UNDIRECT(STR: string): string;
begin
  //
  result := '';
  if (Trim(STR) = '借') then
    RESULT := '贷'
  else if Trim(STR) = '贷' then
    result := '借';

end;

class procedure lxyexcel.columnsum(asheet: Variant; row, column, directioncol,
  startline: Integer; mydirect: string);
var
  str: string;
begin
  //
  if (column > 0) and (directioncol > 0) then
  begin
    str := '=sumif(' +
      intto26(directioncol) + trim(inttostr(startline + 1)) + ':' +
      intto26(directioncol) + trim(inttostr(row))
      + ',"' + MYdirect + '" ,' +
      intto26(column) + trim(inttostr(startline + 1)) + ':' +
      intto26(column) + trim(inttostr(row)) + ')' +
      '-sumif(' +
      intto26(directioncol) + trim(inttostr(startline + 1)) + ':' +
      intto26(directioncol) + trim(inttostr(row))
      + ',"' + UNDIRECT(mydirect) + '",' +
      intto26(column) + trim(inttostr(startline + 1)) + ':' +
      intto26(column) + trim(inttostr(row)) + ')';
    asheet.cells.item[row + 2, column].value := str;
    asheet.cells.item[row + 4, column].value := '=' +
      intto26(column) + trim(inttostr(row + 2));
  end
end;

class procedure lxyexcel.mxbcolumnsum(asheet: Variant; row, column,
  directioncol,
  startline: Integer; mydirect: string);
var
  str: string;
begin
  //
  if (column > 0) and (directioncol > 0) then
  begin
    str := '=sumif(' +
      intto26(directioncol) + trim(inttostr(startline + 1)) + ':' +
      intto26(directioncol) + trim(inttostr(row))
      + ',"' + MYdirect + '" ,' +
      intto26(column) + trim(inttostr(startline + 1)) + ':' +
      intto26(column) + trim(inttostr(row)) + ')' +
      '-sumif(' +
      intto26(directioncol) + trim(inttostr(startline + 1)) + ':' +
      intto26(directioncol) + trim(inttostr(row))
      + ',"' + UNDIRECT(mydirect) + '",' +
      intto26(column) + trim(inttostr(startline + 1)) + ':' +
      intto26(column) + trim(inttostr(row)) + ')';
    asheet.cells.item[row + 2, column].value := str;
  end
end;

class function lxyexcel.rowSUM(source, JFA, DFA, JFB, DFB, currentROW: INTEGER;
  DIRECTION: string): string;
//参数含义   期末审定数=source(期末未审）+jfa-dfa+jfb-dfb,
var
  FORMULAstring: string;
begin
  //

  RESULT := '';
  try
    formulastring := '=';
    if SOURCE > 0 then
      formulastring := formulastring + intto26(source) +
        trim(inttostr(currentROW));
    if JFA > 0 then
      formulastring := formulastring + JFsymbol(DIRECTION) + intto26(JFA) +
        trim(inttostr(currentROW));
    if DFA > 0 then
      formulastring := formulastring + DFsymbol(DIRECTION) + intto26(DFA) +
        trim(inttostr(currentROW));
    if JFB > 0 then
      formulastring := formulastring + JFsymbol(DIRECTION) + intto26(JFB) +
        trim(inttostr(currentROW));
    if DFB > 0 then
      formulastring := formulastring + DFsymbol(DIRECTION) + intto26(DFB) +
        trim(inttostr(currentROW));
    RESULT := formulastring;
  except
  end;

end;

class function lxyexcel.fillacell(Asheet: Variant; column, row: integer; value:
  variant): Boolean;
begin
  //
  if column > 0 then
    Asheet.cells.item[row, column].value := value;

end;

class function lxyexcel.intto26(excelcolumn: integer): string;
var
  iTemp, iIndex, I: integer;
  arr: array[0..2521] of char;
  str: string;
begin
  iTemp := excelcolumn;
  str := '';
  iIndex := 1;
  repeat
    arr[iIndex] := char((iTemp mod 26) + 64);
    if iTemp mod 26 = 0 then
    begin
      arr[iIndex] := 'Z';
      arr[iIndex + 1] := char(integer(arr[iIndex + 1]) - 1);
      iTemp := iTemp - 26;
    end;
    inc(iIndex);
    iTemp := iTemp div 26;
  until iTemp < 1;
  for i := iIndex - 1 downto 1 do
    str := str + arr[i];
  result := str;
end;

class function lxyexcel.DFSymbol(direction: string): string;
begin
  result := '';
  if TRIM(direction) = '借' then
    result := '-'
  else if TRIM(direction) = '贷' then
    result := '+';
end;

class function lxyexcel.JFsymbol(direction: string): string;
begin
  result := '';
  if TRIM(direction) = '借' then
    result := '+'
  else if TRIM(direction) = '贷' then
    result := '-';
end;

class function lxyexcel.sdb_commandline_num(asheet: Variant): integer;
var
  i, icount, commandline: Integer;
  sheettmp: variant;
begin
  //
  sheettmp := asheet;
  icount := sheettmp.UsedRange.Columns.count;
  commandline := -1;
  //   取得标志行的所有行的数字
  try
    for i := 4 to 10 do
    begin

      if
        ((trim(sheettmp.cells.item[i + 1, 2].text) = '') or
        (trim(sheettmp.cells.item[i + 1, 2].text) = '\'))
        and
        (sheettmp.rows.item[i, EmptyParam].rowheight < 1) then
      begin
        commandline := i;
        break;
      end;
    end;
    result := commandline;
  except
    result := -1;
  end;

end;

class function lxyexcel.datefrom_8BIT(STR: string): TDATETIME;
begin
  //
  try
    RESULT := EncodeDate(StrToInt(copy(STR, 1, 4)), StrToInt(copy(STR, 5, 2)),
      StrToInt(copy(STR, 7, 2)));
  except
    RESULT := EncodeDate(1900, 1, 1);
  end;
end;

class function lxyexcel.datefrom_ALPHA(STR: string): TDATETIME;
var
  str1, stmp: string;
  len1: integer;
  slist: TStringList;
begin
  //
  RESULT := EncodeDate(1900, 1, 1);
  str1 := StringReplace(STR, '.', '-', [rfreplaceall]);
  str1 := StringReplace(STR1, '/', '-', [rfReplaceAll]);
  str1 := StringReplace(STR1, ' ', '', [rfreplaceall]);
  // str1 := Trim(str1);
  len1 := Length(STR1) - length(StringReplace(STR1, '-', '', [rfreplaceall]));

  if (len1 = 2) and (rightstr(str1, 1) = '-') then
    str1 := (str1 + '1')
  else if len1 = 1 then
    str1 := (str1 + '-1');

  slist := TStringList.Create;
  try
    slist.Delimiter := '-';
    slist.DelimitedText := str1;
    result := EncodeDate(StrToInt(slist[0]), StrToInt(slist[1]),
      StrToInt(slist[2]));
  finally
    FreeAndNil(slist);
    //
  end;
end;

class function lxyexcel.datefrom_YEARMONTH(STR: string): TDATETIME;
var
  str1: string;
  slist: TStringList;
  len1: integer;
begin
  //
  RESULT := EncodeDate(1900, 1, 1);
  str1 := StringReplace(STR, ' ', '', [rfReplaceAll]);
  str1 := StringReplace(STR1, '/', '-', [rfReplaceAll]);
  str1 := StringReplace(STR1, '.', '-', [rfReplaceAll]);
  str1 := StringReplace(STR1, '年', '-', [rfReplaceAll]);
  str1 := StringReplace(STR1, '月', '-', [rfReplaceAll]);
  str1 := StringReplace(STR1, '日', '', [rfReplaceAll]);

  len1 := Length(STR) - length(StringReplace(STR1, '-', '', [rfreplaceall]));

  if (len1 = 2) and (rightstr(str, 1) = '-') then
    str1 := (str1 + '1')
  else if len1 = 1 then
    str1 := (str1 + '-1');

  slist := TStringList.Create;
  try
    slist.Delimiter := '-';
    slist.DelimitedText := str1;
    result := EncodeDate(StrToInt(slist[0]), StrToInt(slist[1]),
      StrToInt(slist[2]));
  finally
    FreeAndNil(slist);
  end;

end;

class function lxyexcel.str8todate(str: string): tdatetime;
begin
  //
  try
    if Pos('.', str) > 0 then
      result := datefrom_ALPHA(str)
    else if Pos('/', str) > 0 then
      result := datefrom_ALPHA(str)
    else if Pos('-', str) > 0 then
      result := datefrom_ALPHA(str)
    else if (Pos('年', str) > 0) and (Pos('月', str) > 0) then
      result := datefrom_YEARMONTH(str)
    else if IsDigit(str) and (Length(str) = 8) then
      result := datefrom_8BIT(str);
  except
  end;
end;

class function lxyexcel.IsDigit(str: string): Boolean;
var
  i: integer;
  judnorm: smallint;
begin
  for i := 0 to length(str) do
  begin
    judnorm := Byte(str[i]); //取得每一个字符的asc码
    if (judnorm < 48) or (judnorm > 57) then
    begin
      Result := False;
      break;
    end;
  end;

  result := True;

end;

procedure fillzero(asheet: Variant; ncolumn: integer);
var
  i, ncount: integer;
  acol: Variant;
begin
  //
  ncount := asheet.usedrange.rows.count;

  acol := asheet.Range[asheet.cells.Item[2, ncolumn],
    asheet.cells.Item[ncount, ncolumn]].Value;

  for i := 1 to ncount - 1 do
  begin
    try
      if VarIsNull(acol[i, 1]) then
        acol[i, 1] := 0
      else if VarIsEmpty(acol[i, 1]) then
        acol[i, 1] := 0
      else if VarIsStr(acol[i, 1]) then
        if (acol[i, 1] = '-') or (Trim(acol[i, 1]) = '') then
          acol[i, 1] := 0;

    except
    end;
  end;
  asheet.Range[asheet.cells.Item[2, ncolumn],
    asheet.cells.Item[ncount, ncolumn]].Value := acol;

end;

//function lxyexcel.filldate(asheet: Variant; ncolumn: integer): boolean;
//var
//  kk, ncount: integer;
//  acol: Variant;
//begin
//  //
//  result := False;
//  ncount := asheet.usedrange.rows.count;
//
//  acol := asheet.Range[asheet.cells.Item[2, ncolumn],
//    asheet.cells.Item[ncount, ncolumn]].value;
//
//  kk := 1;
//  while kk <= ncount - 1 do
//  begin
//
//    if VarIsNumeric(acol[kk, 1]) then
//      acol[kk, 1] := str8todate(IntToStr(acol[kk, 1]))
//    else if VarIsStr(acol[kk, 1]) then
//      acol[kk, 1] := str8todate(acol[kk, 1]);
//    kk := kk + 1;
//  end;
//  asheet.Range[asheet.cells.Item[2, ncolumn],
//    asheet.cells.Item[ncount, ncolumn]].Value := acol;
//  result := True;
//end;

{ lxydate }

end.

