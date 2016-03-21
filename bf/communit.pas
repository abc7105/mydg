unit communit;

interface
uses
  Windows, Classes, SysUtils, Variants, adxAddIn, Forms,
  excel2000, lxyjm, StrUtils, IniFiles,   ushare,
  Dialogs, Controls,
  ExtCtrls, DB, ADODB;

type

  cellxy = record
    zdname: string;
    liking: Single;
    row: integer;
    column: integer;
    sheetname: string;
  end;

  mxbPOS = record
    qc: integer;
    jffs: integer;
    dffs: integer;
    qm: integer;
    kmmc: Integer;
    top: integer;
    bottom: Integer;
    tzjf: integer; //调整借方
    tzdf: integer;
    tzfzjf: integer; //负值调整借方
    tzfzdf: Integer;
    nosd: Integer; //未审数
    sd: integer; //审定数
    maxwidth: integer;
    maxheight: integer;
    fx: integer; //方向
    dm: integer;
    memo1: integer;
    memo2: integer;
    memo3: integer;
  end;

type
  xminfo = record
    xmid: string;
    xmname: string;
    dwmc: string;
    xmpath: string;
    startrq: tdatetime;
    endrq: tdatetime;
    yeard: string;
    kmlen: Integer;
    //模板
    mbid: string;
    MBNAME: string;
    mbpath: string;

    //原XMINFO
    editor: string;
    checkor: string;
    editrq: tdatetime;
    checkRQ: TDATETIME;

    //扩展
    xmyear: Integer;

  end;
var
  mainpath: string;
  axm: xminfo;

function sheetexists(excelapp: excel2000.TExcelApplication; aname: string):
  boolean;
function Reverse(S: string): string;
function rat(const SubStr: string; const S: string): Integer;
procedure printasheet(asheet: _worksheet);
procedure previewone(asheet: _worksheet);
procedure pagesetup(asheet: _Worksheet);
function CompareStr(str1, str2: string): SINGLE;
function Comparezd(str1, str2: string): SINGLE;
procedure uformulaurltovalue(asheet: _Worksheet);
procedure uformulatovalue(asheet: _Worksheet);
function IntTo26(iInt: integer): string;
function TOEXCELPOS(I, J: INTEGER): string;
function padrightblank(str: string; alen: Integer): string;
function str2float(str: string): double;
function getposition(_mxb: _worksheet): mxbPOS;
function isasheet(excelapp: _Application; aname: string): boolean;
function CentimetersToPoints(xCentimeters: real): Real;
function trimalpha(str: string): string;
function isempty(str: string): Boolean;
function SPACE(N: Integer): string;
function repl(str: string; n: Integer): string;
function leftpad(str: string; n: Integer): string;
function rightpad(str: string; n: Integer): string;
function getCHINESE(S: string): string;
function betweenstr(sourcestr: string; astr: string; bstr: string): string;
procedure LoadParamFromFile(const AFileName: TFileName);
procedure SaveParamToFile(const AFileName: TFileName);
function RunProgram(ProgramName: string; Wait: Boolean = False): Cardinal;
function IsProgram_Runing(hProcess: Cardinal): Boolean;

var
  exportexcel: string;
  ajm: tlxyjm;
  bookname: string;
  sheetchange: boolean;
  OLDSHEETNAME: string;
  isruning: boolean;

implementation



function RunProgram(ProgramName: string; Wait: Boolean = False): Cardinal;
var
  StartInfo: STARTUPINFO;
  ProcessInfo: PROCESS_INFORMATION;
begin
  //执行外部程序,失败返回0,成功返回进程句柄
  Result := 0;
  if ProgramName = '' then
    exit;
  GetStartupInfo(StartInfo);
  StartInfo.dwFlags := StartInfo.dwFlags or STARTF_FORCEONFEEDBACK;
  if not CreateProcess(nil, PChar(ProgramName), nil, nil, false, 0,
    nil, nil, StartInfo, ProcessInfo) then
    exit;
  Result := ProcessInfo.hProcess;
  //建立进程成功
  //如果异步执行则退出
  if not wait then
    exit;
  while IsProgram_Runing(Result) do
    Application.ProcessMessages;
end;

function IsProgram_Runing(hProcess: Cardinal): Boolean;
var
  ExitCode: Cardinal;
begin
  //查看进程是否正在运行
  GetExitCodeProcess(hProcess, ExitCode);
  if ExitCode = STILL_ACTIVE then
    Result := True
  else
    Result := False;
end;

procedure LoadParamFromFile(const AFileName: TFileName);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(AFileName);
  if not fileexists(afilename) then
  begin
    axm.xmid := '';

  end
  else
  begin
    try
      axm.xmid := Ini.ReadString('项目信息', 'ID', '');
      axm.xmname := Ini.ReadString('项目信息', 'xmname', '');
      axm.xmpath := Ini.ReadString('项目信息', 'xmpath', '');
      axm.mbname := Ini.ReadString('项目信息', 'mbname', '');
      axm.mbpath := Ini.ReadString('项目信息', 'mbpath', '');
      axm.dwmc := Ini.ReadString('项目信息', 'dwmc', '');
      axm.mbid := Ini.ReadString('项目信息', 'mbid', '');
      axm.MBNAME := Ini.ReadString('项目信息', 'MBNAME', '');

      axm.dwmc := Ini.ReadString('项目信息', 'dwmc', '');
      axm.startrq := Ini.ReadDate('项目信息', 'startrq', strtodate('1900-1-1'));
      axm.endrq := Ini.ReadDate('项目信息', 'endrq', strtodate('1900-1-1'));
      axm.yeard := Ini.ReadString('项目信息', 'yeard', '');
      axm.editor := Ini.ReadString('项目信息', 'editor', '');
      axm.checkor := Ini.ReadString('项目信息', 'checkor', '');
      axm.editrq := Ini.ReadDate('项目信息', 'editrq', strtodate('1900-1-1'));
      axm.checkRQ := Ini.ReadDate('项目信息', 'checkRQ', strtodate('1900-1-1'));

    except
    end;
  end;
  Ini.Free;

end;

procedure SaveParamToFile(const AFileName: TFileName);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(AFileName);
  Ini.WriteString('项目信息', 'ID', axm.XMID);
  Ini.WriteString('项目信息', 'xmname', axm.xmname);
  Ini.WriteString('项目信息', 'xmpath', axm.xmpath);
  Ini.WriteString('项目信息', 'mbname', axm.mbname);
  Ini.WriteString('项目信息', 'mbpath', axm.mbpath);
  Ini.WriteString('项目信息', 'dwmc', axm.dwmc);
  Ini.WriteString('项目信息', 'mbid', axm.mbid);
  Ini.WriteString('项目信息', 'MBNAME', axm.MBNAME);

  Ini.WriteString('项目信息', 'dwmc', axm.dwmc);
  Ini.WriteDate('项目信息', 'startrq', axm.startrq);
  Ini.WriteDate('项目信息', 'endrq', axm.endrq);
  Ini.WriteString('项目信息', 'yeard', axm.yeard);
  Ini.WriteString('项目信息', 'editor', axm.editor);
  Ini.WriteString('项目信息', 'checkor', axm.checkor);
  Ini.WriteDate('项目信息', 'editrq', axm.editrq);
  Ini.WriteDate('项目信息', 'checkRQ', axm.checkRQ);

  Ini.Free;
end;

function betweenstr(sourcestr: string; astr: string; bstr: string): string;
var
  pos1, pos2: integer;
begin
  result := '';
  pos1 := Pos(astr, sourcestr);
  pos1 := pos1 + length(astr);

  pos2 := Pos(bstr, sourcestr);
  pos2 := pos2 - pos1;

  if (pos1 > 0) and (pos2 > 0) then
  begin
    result := Copy(sourcestr, pos1, pos2);
    result := stringreplace(Result, ':', '', [rfReplaceAll]);
    result := stringreplace(Result, '：', '', [rfReplaceAll]);
    result := stringreplace(Result, '期间', '', [rfReplaceAll]);
    result := stringreplace(Result, '截止日', '', [rfReplaceAll]);
    result := stringreplace(Result, ' ', '', [rfReplaceAll]);
  end;
end;

function getCHINESE(S: string): string;
var

  P: ^Byte;
  Dest: string;
  Index: Integer;
begin

  Result := '';

  P := Pointer(@S[1]);
  Dest := '';
  Index := 1;
  while Index < Length(S) do
  begin

    if P^ >= 48 then //去除 0-127 字母与数据
    begin
      if P^ > 163 then // 是 汉字
      begin
        Dest := Dest + Chr(P^);
        Inc(Index);
        Inc(P);
        Dest := Dest + Chr(P^);
      end
      else if ((P^ <= 128) and (P^ >= 65)) or ((P^ <= 57) and (P^ >= 48)) then
      begin
        Dest := Dest + Chr(P^);
        //' Inc(Index);
        // 'Inc(P);
      end;
    end;
    Inc(Index);
    Inc(P);
  end;

  Result := Dest;
end;

function leftpad(str: string; n: Integer): string;
var
  len1: integer;
  hzlength: integer;
begin
  if Length(Trim(str)) > n then
  begin
    result := str;
    exit;
  end;

  hzlength := Length(getCHINESE(str));
  hzlength := round((length(str) - hzlength) * 4.445510) + round((hzlength / 2 *
    9.052042));
  //   *1.05769
  result := Trim(str) + repl(' ', round((n - hzlength) / 4.445510));

end;

function rightpad(str: string; n: Integer): string;
var
  hzlength: integer;

begin
  if Length(Trim(str)) > n then
  begin
    result := str;
    exit;
  end;

  hzlength := Length(getCHINESE(str));
  hzlength := round((length(str) - hzlength) * 4.445510) + round((hzlength / 2 *
    9.052042));
  result := repl(' ', round((n - hzlength) / 4.445510)) + Trim(str);

end;

function repl(str: string; n: Integer): string;
var
  I: Integer;
begin
  RESULT := '';
  if N > 1 then
    for I := 1 to N do
      RESULT := RESULT + trim(str);
end;

function SPACE(N: Integer): string;
var
  I: Integer;
begin
  RESULT := '';
  if N > 1 then
    for I := 1 to N do
      RESULT := RESULT + ' ';
end;

function isempty(str: string): Boolean;
var
  ss: string;

begin
  Result := False;
  ss := Trim(str);
  if (str = '') then
  begin
    result := True;
    exit;
  end;

  ss := StringReplace(SS, '-', '0', [rfReplaceAll]);
  ss := StringReplace(SS, ',', '', [rfReplaceAll]);
  ss := StringReplace(SS, '''', '', [rfReplaceAll]);
  try
    if StrToFLOAT(SS) = 0 then
    begin
      Result := TRUE;
      EXIT;
    end;
  except

  end;

end;

function trimalpha(str: string): string;
var
  pos1: Integer;
  ss: string;
begin
  result := str;
  ss := StringReplace(str, '。', '.', [rfReplaceAll]);
  ss := StringReplace(ss, '、', '.', [rfReplaceAll]);
  ss := StringReplace(ss, '\', '.', [rfReplaceAll]);
  ss := StringReplace(ss, ',', '.', [rfReplaceAll]);
  ss := StringReplace(ss, '，', '.', [rfReplaceAll]);
  pos1 := Pos('.', ss);
  if pos1 < 10 then
    result := Copy(ss, pos1 + 1, Length(ss))

end;

function CentimetersToPoints(xCentimeters: real): Real;
begin
  result := xCentimeters * 28.35;
end;

function getposition(_mxb: _worksheet): mxbPOS;
var
  i, j: Integer;
  amxbpos: mxbPOS;
  commentstr, valuestr: string;
begin
  _mxb.Activate(adxLCID);
  i := _mxb.UsedRange[0].columns.Count;
  amxbpos.maxwidth := _mxb.UsedRange[0].columns.Item[i, EmptyParam].column;

  i := _mxb.UsedRange[0].rows.Count;
  amxbpos.maxheight := _mxb.UsedRange[0].Rows.Item[i, EmptyParam].row;

  amxbpos.bottom := 0;
  for j := 2 to 7 do
  begin
    for i := 3 to amxbpos.maxheight do
    begin
      try
        if (Pos('科目名称', _mxb.Cells.Item[i, j].text) > 0) then
        begin
          amxbpos.kmmc := j;
          amxbpos.top := i;
        end;
      except
        amxbpos.kmmc := 2;
        amxbpos.top := 7;
      end;

      if Trim(_mxb.Cells.Item[i, j].text) = '合计' then
        amxbpos.bottom := i;

      if Pos('审计说明', _mxb.Cells.Item[i, j].text) > 0 then
        amxbpos.bottom := i - 2;

    end;

  end;
  if amxbpos.bottom = 0 then
  begin
    amxbpos.kmmc := 2;
    amxbpos.top := 7;
  end;
  amxbpos.tzjf := 0;
  amxbpos.tzdf := 0;
  amxbpos.tzfzjf := 0;
  amxbpos.tzfzdf := 0;
  amxbpos.nosd := 0;
  amxbpos.sd := 0;
  amxbpos.fx := 0;
  amxbpos.dm := 0;
  amxbpos.memo1 := 0;
  amxbpos.memo2 := 0;
  amxbpos.memo3 := 0;

  for j := 2 to amxbpos.maxwidth do
  begin
    try
      commentstr := _mxb.Cells.Item[amxbpos.top, j].comment.text; //批注的字符串
    except
      commentstr := '';
    end;
    valuestr := uppercase(_mxb.Cells.Item[amxbpos.top, j].text); //单元格内字符串

    try
      if (Pos('MEMO1', valuestr) > 0) then
        amxbpos.MEMO1 := j
      else if (Pos('MEMO2', valuestr) > 0) then
        amxbpos.MEMO2 := j
      else if (Pos('MEMO3', valuestr) > 0) then
        amxbpos.MEMO3 := j
      else if (Pos('代码', valuestr) > 0) then
        amxbpos.dm := j
      else if (Pos('期末调整数', commentstr) > 0) and (Pos('期末调整数',
        valuestr) > 0) then
        amxbpos.tzjf := j
      else if (Pos('期末调整借方', commentstr) > 0) and (Pos('期末调整借方',
        valuestr) > 0) then
        amxbpos.tzjf := j
      else if (Pos('期末调整贷方', commentstr) > 0) and (Pos('期末调整贷方',
        valuestr) > 0) then
        amxbpos.tzdf := j
      else if (Pos('期末重分类借方', commentstr) > 0) and (Pos('期末重分类借方',
        valuestr) > 0) then
        amxbpos.tzfzjf := j
      else if (Pos('期末重分类贷方', commentstr) > 0) and (Pos('期末重分类贷方',
        valuestr) > 0) then
        amxbpos.tzfzdf := j
      else if (Pos('审定期末数', commentstr) > 0) and (Pos('审定期末数',
        valuestr) > 0) then
        amxbpos.sd := j
      else if (Pos('未审期末数', commentstr) > 0) and (Pos('未审期末数',
        valuestr) > 0) then
        amxbpos.nosd := j
      else if (Pos('未审发生额', commentstr) > 0) and (Pos('未审发生额',
        valuestr) > 0) then
        amxbpos.nosd := j
      else if (Pos('审定发生额', commentstr) > 0) and (Pos('审定发生额',
        valuestr) > 0) then
        amxbpos.sd := j
      else if (Pos('借贷方向', valuestr) > 0) then
        amxbpos.fx := j
          //后来增加

      else if (Pos('未审贷方发生额', commentstr) > 0) and (Pos('未审贷方发生额',
        valuestr) > 0) then
        amxbpos.dffs := j
      else if (Pos('账面借方发生额', commentstr) > 0) and (Pos('账面借方发生额',
        valuestr) > 0) then
        amxbpos.jffs := j
      else if (Pos('未审借方发生额', commentstr) > 0)
        and (Pos('未审借方发生额', valuestr) > 0) then
        amxbpos.jffs := j

      else if (Pos('审定期初数', commentstr) > 0) and (Pos('审定期初数',
        valuestr) > 0) then
        amxbpos.qc := j

      else if (Pos('账面贷方发生额', commentstr) > 0) and (Pos('账面贷方发生额',
        valuestr) > 0) then
        amxbpos.dffs := j
      else if (Pos('未审贷方发生额', commentstr) > 0) and (Pos('未审贷方发生额',
        valuestr) > 0) then
        amxbpos.dffs := j

        ;
    except
    end;
  end;
  result := amxbpos;
end;

function str2float(str: string): double;
begin
  //
  str := StringReplace(str, ',', '', [rfReplaceAll]);
  str := StringReplace(str, '''', '', [rfReplaceAll]);
  try
    result := strtofloatdef(str, 0);
  except
    result := 0;
    exit;
  end;
end;

function padrightblank(str: string; alen: Integer): string;
var
  tmpstr: string;
begin
  tmpstr := str + DupeString(' ', alen);
  result := Copy(str, 1, alen);

end;

function TOEXCELPOS(I, J: INTEGER): string;
begin
  RESULT := Trim(INTTO26(J)) + TRIM(INTTOSTR(I));
end;

function IntTo26(iInt: integer): string;
var
  iTemp, iIndex, I: integer;
  arr: array[0..2521] of char;
  str: string;
begin
  iTemp := iInt;
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
  result := Trim(str);
end;

procedure uformulaurltovalue(asheet: _Worksheet);
var
  i, j, Irowcount, icolcount: integer;
begin //所有外部链接的公式转化为值

  irowcount := asheet.UsedRange[adxLCID].rows.count;
  icolcount := asheet.UsedRange[adxLCID].columns.count;

  for i := 1 to Irowcount do
    for j := 1 to icolcount do
    begin
      if (ASHEET.Cells.Item[i, j].hasformula) then
        if (Pos('!', ASHEET.Cells.Item[i, j].formula) > 0) then
        begin
          ASHEET.Cells.Item[i, j].value := ASHEET.Cells.Item[i, j].value;
        end;
    end;

end;

procedure uformulatovalue(asheet: _Worksheet);
var
  i, j, Irowcount, icolcount: integer;
begin //所有外部链接的公式转化为值

  irowcount := asheet.UsedRange[adxLCID].rows.count;
  icolcount := asheet.UsedRange[adxLCID].columns.count;

  for i := 1 to Irowcount do
    for j := 1 to icolcount do
    begin
      if (ASHEET.Cells.Item[i, j].hasformula) then
      begin
        ASHEET.Cells.Item[i, j].value := ASHEET.Cells.Item[i, j].value;
      end;
    end;

end;

function CompareStr(str1, str2: string): SINGLE;
var
  SS, ss2: string;
  count1: double;
  i: integer;
  d1: double;
  onestr: string;
  INT1, INT2: INTEGER;

begin
  result := 0;

  if Length(str1) < 1 then
  begin
    result := 0;
    exit;
  end;

  if Length(str2) < 1 then
  begin
    result := 0;
    exit;
  end;

  if Trim(str1) = Trim(str2) then
  begin
    result := 2;
    Exit;
  end;

  SS := TRIM(STR1);
  SS := StringReplace(SS, '省', '', [rfReplaceAll]);
  SS := StringReplace(SS, '市', '', [rfReplaceAll]);

  SS := StringReplace(SS, '县', '', [rfReplaceAll]);
  SS := StringReplace(SS, '职员', '', [rfReplaceAll]);
  SS := StringReplace(SS, '单位', '', [rfReplaceAll]);
  SS := StringReplace(SS, '客户', '', [rfReplaceAll]);
  SS := StringReplace(SS, '供应商', '', [rfReplaceAll]);
  SS := StringReplace(SS, '客商', '', [rfReplaceAll]);
  SS := StringReplace(SS, '辅助核算', '', [rfReplaceAll]);
  SS := StringReplace(SS, ':', '', [rfReplaceAll]);
  SS := StringReplace(SS, '_', '', [rfReplaceAll]);
  SS := StringReplace(SS, '-', '', [rfReplaceAll]);
  SS := StringReplace(SS, '\', '', [rfReplaceAll]);
  SS := StringReplace(SS, '其他', '', [rfReplaceAll]);
  SS := StringReplace(SS, '应收款', '', [rfReplaceAll]);
  SS := StringReplace(SS, '应付款', '', [rfReplaceAll]);
  SS := StringReplace(SS, '管理', '', [rfReplaceAll]);
  SS := StringReplace(SS, '费用', '', [rfReplaceAll]);
  SS := StringReplace(SS, '应付', '', [rfReplaceAll]);
  SS := StringReplace(SS, '预付', '', [rfReplaceAll]);
  SS := StringReplace(SS, '预收', '', [rfReplaceAll]);
  SS := StringReplace(SS, '应收', '', [rfReplaceAll]);
  SS := StringReplace(SS, '账款', '', [rfReplaceAll]);
  SS := StringReplace(SS, '帐款', '', [rfReplaceAll]);
  SS := StringReplace(SS, '应交', '', [rfReplaceAll]);
  SS := StringReplace(SS, '税费', '', [rfReplaceAll]);

  SS2 := TRIM(STR2);
  ss2 := StringReplace(ss2, '省', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '市', '', [rfReplaceAll]);

  ss2 := StringReplace(ss2, '县', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '职员', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '单位', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '客户', '', [rfReplaceAll]);

  ss2 := StringReplace(ss2, '供应商', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '客商', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '辅助核算', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, ':', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '_', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '-', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '其他', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '应收款', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '应付款', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '管理', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '费用', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '应付', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '预付', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '预收', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '应收', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '\', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '账款', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '帐款', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '应交', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '税费', '', [rfReplaceAll]);
  count1 := 0;

  if (Length(Trim(SS)) < 2) or (Length(Trim(SS2)) < 2) then
  begin
    RESULT := 0;
    EXIT;
  end;

  i := 1;

  INT1 := LENGTH(SS);
  while i <= INT1 do
  begin

    if ByteType(ss, i) = mbLeadByte then
    begin
      onEstr := Copy(SS, I, 2);
      I := I + 2;
      if Pos(ONESTR, ss2) > 0 then
        count1 := count1 + 2;
    end;

    if ByteType(ss, i) = mbSingleByte then
    begin
      onEstr := Copy(SS, I, 1);
      I := I + 1;
      if Pos(ONESTR, ss2) > 0 then
        count1 := count1 + 1;
    end;
  end;

  INT2 := LENGTH(SS);
  d1 := count1 / INT2;
  if d1 = 100 then
    d1 := 0.98;
  result := d1;
end;

function Comparezd(str1, str2: string): SINGLE;
var
  SS, ss2: string;
  count1: double;
  i: integer;
  d1: double;
  onestr: string;
  INT1, INT2: INTEGER;

begin
  result := 0;

  if Length(str1) < 1 then
  begin
    result := 0;
    exit;
  end;

  if Length(str2) < 1 then
  begin
    result := 0;
    exit;
  end;

  if Trim(str1) = Trim(str2) then
  begin
    result := 2;
    Exit;
  end;

  SS := TRIM(STR1);

  SS := StringReplace(SS, ':', '', [rfReplaceAll]);
  SS := StringReplace(SS, '_', '', [rfReplaceAll]);
  SS := StringReplace(SS, '-', '', [rfReplaceAll]);
  SS := StringReplace(SS, '\', '', [rfReplaceAll]);

  SS2 := TRIM(STR2);

  ss2 := StringReplace(ss2, ':', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '_', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '-', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '\', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '其中：', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '加：', '', [rfReplaceAll]);
  ss2 := StringReplace(ss2, '减：', '', [rfReplaceAll]);

  count1 := 0;
  if Trim(SS) = Trim(SS2) then
  begin
    RESULT := 2;
    EXIT;
  end;

  if (Length(Trim(SS)) < 2) or (Length(Trim(SS2)) < 2) then
  begin
    RESULT := 0;
    EXIT;
  end;

  i := 1;

  INT1 := LENGTH(SS);
  while i <= INT1 do
  begin

    if ByteType(ss, i) = mbLeadByte then
    begin
      onEstr := Copy(SS, I, 2);
      I := I + 2;
      if Pos(ONESTR, ss2) > 0 then
        count1 := count1 + 2;
    end;

    if ByteType(ss, i) = mbSingleByte then
    begin
      onEstr := Copy(SS, I, 1);
      I := I + 1;
      if Pos(ONESTR, ss2) > 0 then
        count1 := count1 + 1;
    end;
  end;

  INT2 := LENGTH(SS);
  d1 := count1 / INT2;
  if d1 = 100 then
    d1 := 0.98;
  result := d1;
end;

procedure printasheet(asheet: _worksheet);
begin
  try
    pagesetup(asheet);
    //   asheet.PrintOut(EmptyParam, EmptyParam, EmptyParam, false,
   //      true, false, EmptyParam, EmptyParam, 0);
  except
  end;
end;

procedure previewone(asheet: _worksheet);
begin
  pagesetup(asheet);
  asheet.PrintPreview(True, adxLCID);
end;

procedure pagesetup(asheet: _Worksheet);
var
  i, endline: integer;
  maxrow, maxcol: integer;
  mywide: single;
  rangestr: string;
  arange: ExcelRange;
  excelapp: excel2000._application;
  hpages: integer;
  lastpagehs: integer;
begin

  excelapp := asheet.Application;
  //
  endline := 0;

  // asheet := _worksheet(excelapp.ActiveCell.Worksheet);

  maxcol := asheet.UsedRange[0].Columns.count;
  maxcol := asheet.UsedRange[0].Cells.Item[1, maxcol].column;

  maxrow := asheet.UsedRange[0].rows.count;
  maxrow := asheet.UsedRange[0].Cells.Item[maxrow, 1].row;

  //求表格总宽度
  mywide := 0;
  for i := 1 to maxcol do
  begin
    arange := ExcelApp.Range[asheet.Cells.item[1, i], asheet.Cells.item[2, i]];
    mywide := mywide + Int(arange.Width);
  end;
  //
  if (mywide > 700) and (Pos('检查', asheet.Name) < 1) then
  begin //横向
    //     mymessage(floatToStr(mywide));
    with asheet.PageSetup do
    begin
      LeftMargin := CentimetersToPoints(2);
      RightMargin := CentimetersToPoints(1.4);
      TopMargin := CentimetersToPoints(1.8);
      BottomMargin := CentimetersToPoints(1.4);
      HeaderMargin := CentimetersToPoints(1.3);
      FooterMargin := CentimetersToPoints(1.3);
      PaperSize := xlPaperA4;
      Orientation := xlLandscape; //横向
      FitToPagesWide := 1;
      FitToPagesTall := 10;
      PrintGridlines := false;

      PrintHeadings := False;
      PrintComments := xlPrintNoComments;
      CenterHorizontally := true;
      CenterVertically := False;
      Orientation := xlLandscape;
      Draft := False;
      PaperSize := xlPaperA4;
      FirstPageNumber := xlAutomatic;
      Order := xlDownThenOver;
      BlackAndWhite := true;
      Zoom := False;
      FitToPagesWide := 1;
      FitToPagesTall := False;
    end
  end
  else
  begin //纵向
    //    mymessage(floatToStr(mywide));
    with asheet.PageSetup do
    begin
      PaperSize := xlPaperA4;
      Orientation := xlLandscape; //纵向
      FitToPagesWide := 1;
      FitToPagesTall := 10;
      LeftMargin := CentimetersToPoints(2);
      RightMargin := CentimetersToPoints(1.4);
      TopMargin := CentimetersToPoints(1.8);
      BottomMargin := CentimetersToPoints(1.4);
      HeaderMargin := CentimetersToPoints(1.3);
      FooterMargin := CentimetersToPoints(1.3);
      PrintHeadings := False;
      PrintGridlines := false;
      PrintComments := xlPrintNoComments;
      CenterHorizontally := true;
      CenterVertically := False;
      Orientation := xlPortrait;
      Draft := False;
      PaperSize := xlPaperA4;
      FirstPageNumber := xlAutomatic;
      Order := xlDownThenOver;
      BlackAndWhite := true; //设单色打印
      Zoom := False;
      FitToPagesWide := 1;
      FitToPagesTall := False;
    end

  end;

  for i := 1 to 10 do
  begin

    if (asheet.Cells.item[i, 1].Interior.Color <> 16777215) or
      (asheet.Cells.item[i, 1].Interior.Color <> 16777215) then
    begin
      ;
      endline := i;
      Break;
    end;
  end;

  if endline > 1 then
  begin
    rangestr := '$1:$' + inttostr(endline);
    asheet.PageSetup.PrintTitleRows := rangestr;
    asheet.PageSetup.PrintTitleColumns := '';
  end;

  asheet.DisplayAutomaticPageBreaks[adxLCID] := false;
  asheet.DisplayAutomaticPageBreaks[adxLCID] := True;
  hpages := asheet.HPageBreaks.Count + 1;

  try
    if hpages > 1 then
    begin
      asheet.name;
      lastpagehs := asheet.HPageBreaks.Item[hpages - 1].Location.Row;

      if maxrow - lastpagehs < 3 then
      begin
        with asheet.PageSetup do
        begin
          FitToPagesWide := 1;
          FitToPagesTall := hpages - 1;
        end;
      end;

    end;
  except
  end;
  asheet.DisplayAutomaticPageBreaks[adxLCID] := false;
end;

function isasheet(excelapp: _Application; aname: string): boolean;
var
  xstr: string;
begin
  //  表名是否存在
  result := False;
  try

    try
      xstr := _Worksheet(excelapp.ActiveWorkbook.Sheets.Item[aname]).name;
      result := true;
    except
      result := False;
    end;

  except
  end;
end;

function sheetexists(excelapp: excel2000.TExcelApplication; aname: string):
  boolean;
var
  xstr: string;
begin
  //  表名是否存在
  result := False;
  try

    try
      xstr := _Worksheet(excelapp.ActiveWorkbook.Sheets.Item[aname]).name;
      result := true;
    except
      result := False;
    end;

  except
  end;
end;

function Reverse(S: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := Length(S) downto 1 do
  begin
    Result := Result + Copy(S, i, 1);
  end;
end;
//取最后一个字串的位置

function rat(const SubStr: string; const S: string): Integer;
begin
  result := Pos(Reverse(SubStr), Reverse(S));
  if (result <> 0) then
    result := ((Length(S) - Length(SubStr)) + 1) - result + 1;
end;

end.
