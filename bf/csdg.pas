unit csdg;

interface
uses SysUtils, Variants, StrUtils, IniFiles,
  mydg_TLB, DateUtils, ShellAPI, communit, clslxy,
  Dialogs, Excel2000, ADODB, Classes;
const
  KM7sheet = '科目表样7列';
  KM9sheet = '科目表样9列';
  PZsheet = '凭证表';

  sdsheet = '审定表';
  MXsheet = '明细表';
  AFILENAME = '';

  zdlength = '4';
type
  SDB_COLUMN = record //科目在审定表中的顺序号
    KMDM: Integer;
    kmname: integer;
    kmdirect: Integer;
    qc: integer;
    sdqc: integer;
    qm: integer;
    sdqm: integer;
    fs: integer;
    sdfs: Integer;
    qmtzjf: Integer;
    qmtzdf: Integer;
    qmcfljf: Integer;
    qmcfldf: Integer;
  end;

  MXB_COLUMN = record
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

  auditdg = class
  private
    con: TADOConnection;
    tabletmp: TADOTable;
    varrykm: Variant;
    sheettmp: Variant;
    TARGETPATH: string;
    mxsheet, sdbsheet: Variant;
    qrytmp: tadoquery;
    fxlsapp: Variant;
    colscount, rowscount: Integer;
    fieldlength: integer;
    //  axm: XMINFO;
    mydllpath: string;
    axmID: string;
    FMBID: string;
    axm: xminfo;
    procedure GENE_MXKM(); //生成明细级次 mdb中
    procedure GENE_onelevel_km(); //生成一级科目 mdb中
    function getfieldlength(): integer; //生成一级科目的长度
    function mxb_NAME(workbook: variant): string;
    function getxm: xminfo;
    procedure setxm(const Value: xminfo);
  public
    procedure create_PZB;
    procedure dbfromexcel_column7();
    procedure dbfromexcel_column9();
    procedure dbfrom_dxnxmyeb(); //项目余额表
    procedure dbfrom_dxnxmpzb(); //项目凭证表
    procedure DBFROMEXCEL();
    procedure dbfromexcel_pzb;
    procedure PZBtoexcel(rows, cols: Integer);
    constructor create(con1: tadoconnection; xlsapp: OleVariant; dllpath:
      string);
    procedure create_KM7sheet(); //7列的科目余额表
    procedure create_KM9sheet(); //9列的科目余额表
    function sheetexists(aname: string): boolean;
    procedure insertintodbf(rows, cols: Integer);
    procedure create_sdb(dgfilename: string; MYdirect: string);
    procedure create_mxb(asheet: Variant; dgname: string; mydirect: string);
    function sdb_xmcolumn_num(asheet: Variant; commandline: Integer;
      columncount: integer): SDB_COLUMN;
    function MXB_xmcolumn_num(asheet: Variant; commandline: Integer;
      columncount: integer): MXB_COLUMN;
    function sdb_commandline_num(asheet: Variant): integer;
    function GET_XMINFO(): XMINFO;
    procedure replace_allsheet(WORKBOOKA: VARIANT);
    procedure sheetreplace(AWORKBOOK: VARIANT; iorder: integer; ssource, starget: string);
    procedure replace_asheet(WORKBOOK: VARIANT; sorder: integer);
    procedure datebase_toexcel();
    procedure database_select_toexcel(kmlist: tstringlist);
    procedure limit_database_toexcel();
    procedure limit_database_select_toexcel(kmlist: tstringlist);
    function spendtime(sj: tdatetime): string;
    procedure saveinfo(axm: XMINFO);
    function getinfo(): XMINFO;
    function space(count: Integer): string;
    function UNDIRECT(STR: string): string;
    procedure cellsumformula(sheettmp: Variant; row, column, directcolumn,
      baseline: Integer; mydirect: string);
    procedure mxb_cellsumformula(sheettmp: Variant; row, column, directcolumn,
      baseline: Integer;
      mydirect: string);
    procedure fillPZB();
    procedure fillzero(asheet: Variant; ncolumn: integer);
    procedure formatsheetdate(asheet: Variant);
  published
    property XMID: string read axmID write axmID;
    property MBID: string read FMBID write FMBID;
    property xm: xminfo read getxm write setxm;
  end;

implementation

uses
  CLSexcel;

{ auditdg }

function auditdg.sheetexists(aname: string): boolean;
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

constructor auditdg.create(con1: tadoconnection; xlsapp: OleVariant; dllpath:
  string);

begin
  //
  fxlsapp := xlsapp;
  con := con1;
  tabletmp := TADOTable.Create(nil);
  tabletmp.Connection := con;
  qrytmp := tadoquery.Create(nil);
  qrytmp.Connection := con;
  mydllpath := dllpath;
  fxlsapp.DisplayAlerts := false;
  fxlsapp.AskToUpdateLinks := false;
end;

procedure auditdg.create_KM7sheet;
begin
  //
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

procedure auditdg.create_KM9sheet;
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

procedure auditdg.DBFROMEXCEL;
begin

end;

procedure auditdg.dbfromexcel_column7;
var
  i, j: integer;
begin
  if not sheetexists(km7sheet) then
  begin
    ShowMessage('活动工作簿中无7列的科目余额表！');
    exit;
  end;

  if Trim(XMID) = '' then
  begin
    ShowMessage('請先建立項目或打開項目后再導入數據！');
    exit;

  end;

  // dbfrom_dxnxmpzb;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('delete from dg7  where xmid=''' + trim(xmid) + '''');
  qrytmp.ExecSQL;
  qrytmp.close;
  if sheetexists('dxnxmyeb') then
  begin
    for i := 1 to fxlsapp.activeworkbook.sheets.count do
    begin
      sheettmp := fxlsapp.activeworkbook.sheets.item[i];
      formatsheetdate(sheettmp);
    end;
    dbfrom_dxnxmpzb;
    //   EXIT;
  end
  else
  begin
    sheettmp := fxlsapp.activeworkbook.sheets.item[km7sheet];
    //  sheettmp.active;
    sheettmp.select;
    fillzero(sheettmp, 4);
    fillzero(sheettmp, 5);
    fillzero(sheettmp, 6);
    fillzero(sheettmp, 7);
    rowscount := sheettmp.usedrange.rows.count;
    colscount := sheettmp.usedrange.columns.count;

    varrykm := sheettmp.Range[sheettmp.cells.Item[2, 1],
      sheettmp.cells.Item[rowscount, colscount]].Value;

    insertintodbf(rowscount, colscount);
  end;
  GENE_MXKM;

  ShowMessage('鼎信诺数据导入成功，OK！');

end;

procedure auditdg.dbfromexcel_column9;
var
  i, j: integer;
begin
  //
  if not sheetexists(km9sheet) then
  begin
    ShowMessage('活动工作簿中无7列的科目余额表！');
    exit;
  end;

  if Trim(XMID) = '' then
  begin
    ShowMessage('請先建立項目或打開項目后再導入數據！');
    exit;

  end;
  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('delete from dg7  where xmid=''' + trim(xmid) + '''');
  qrytmp.ExecSQL;
  qrytmp.close;

  sheettmp := fxlsapp.activeworkbook.sheets.item[km9sheet];
  sheettmp.select();
  rowscount := sheettmp.usedrange.rows.count;
  colscount := sheettmp.usedrange.columns.count;

  fillzero(sheettmp, 4);
  fillzero(sheettmp, 5);
  fillzero(sheettmp, 6);
  fillzero(sheettmp, 7);
  fillzero(sheettmp, 8);
  fillzero(sheettmp, 9);

  varrykm := sheettmp.Range[sheettmp.cells.Item[2, 1],
    sheettmp.cells.Item[rowscount, colscount]].Value;

  for i := 1 to rowscount - 1 do
  begin
    if Trim(varrykm[i, 3]) = '借' then
    begin
      varrykm[i, 4] := varrykm[i, 4] - varrykm[i, 5];
    end
    else
    begin
      varrykm[i, 4] := varrykm[i, 5] - varrykm[i, 4];
    end;

    varrykm[i, 5] := varrykm[i, 6];
    varrykm[i, 6] := varrykm[i, 7];

    if Trim(varrykm[i, 3]) = '借' then
    begin
      varrykm[i, 7] := varrykm[i, 8] - varrykm[i, 9];
    end
    else
    begin
      varrykm[i, 7] := varrykm[i, 9] - varrykm[i, 8];
    end;
  end;

  insertintodbf(rowscount, colscount);
  GENE_MXKM;
end;

procedure auditdg.GENE_MXKM; //生成(长科目名）
var
  len1, len2: integer;
  str: string;
  iseof: Boolean;
  onelevel_km: string;
begin
  //
  fieldlength := getfieldlength;
  if tabletmp.Active then
    tabletmp.Close;
  tabletmp.TableName := 'dg7';
  tabletmp.Filter := 'xmid=''' + xmid + '''';

  tabletmp.open;
  tabletmp.Sort := 'id';
  tabletmp.Filtered := true;
  tabletmp.first;
  iseof := false;
  len1 := Length(trim(tabletmp.fieldbyname('代码').AsString));
  onelevel_KM := '';
  while not tabletmp.eof do
  begin
    if len1 = fieldlength then
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

  GENE_onelevel_km;
  // ShowMessage('处理ok');
end;

procedure auditdg.GENE_onelevel_km;
var
  strkm: string;
begin
  //

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('delete from 项目对应关系 where xmid=''' + trim(xmid) + '''');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('delete from  dg7  where  代码  in (');
  qrytmp.SQL.Add(' select 代码 from dg7 where len(trim(代码)) =' +
    inttostr(fieldlength) +
    'and  核算项目名称 is null and 期初=0 and 期末=0 and 借方发生=0 and 贷方发生=0 and xmid=''' + trim(xmid) + '''');
  qrytmp.SQL.Add(')');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('insert into 项目对应关系(xmid,代码,科目名称,借贷方向)');
  qrytmp.SQL.Add('  select  xmid,代码,科目名称,借贷方向 from dg7 where len(代码)=' + inttostr(fieldlength));
  qrytmp.SQL.Add(' AND  xmid=''' + trim(xmid) + '''');
  qrytmp.ExecSQL;
  qrytmp.Close;

  if tabletmp.Active then
    tabletmp.Close;
  tabletmp.TableName := '项目对应关系';
  tabletmp.Filter := 'xmid=''' + trim(xmid) + '''';
  tabletmp.open;
  tabletmp.Filtered := true;

  tabletmp.First;
  while not tabletmp.Eof do
  begin
    strkm := Trim(tabletmp.fieldbyname('科目名称').AsString);
    qrytmp.Close;
    qrytmp.SQL.Clear;
    qrytmp.SQL.Add('select 底稿名称  from  科目底稿对应表 where 科目名称 like ''%' + strkm + '%'' ');
    qrytmp.SQL.Add('and MBid=''' + trim(MBid) + '''');
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

procedure auditdg.insertintodbf(rows, cols: Integer);
var
  i, j: integer;
begin
  //
  if tabletmp.Active then
    tabletmp.Close;
  tabletmp.TableName := 'dg7';
  tabletmp.open;
  for i := 1 to rows - 1 do
  begin
    if Trim(varrykm[i, 1]) <> '' then
    begin

      tabletmp.Append;

      try
        tabletmp.FieldByName('xmid').AsString := xmid;
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

function auditdg.getfieldlength: integer;
var
  flen: integer;

begin
  //
  result := -1;
  try
    qrytmp.Close;
    qrytmp.SQL.Clear;
    qrytmp.SQL.Add('select min(len(代码)) as zdlen from dg7 ');
    qrytmp.SQL.Add(' WHERE xmid=''' + trim(xmid) + '''');
    qrytmp.open;
    result := qrytmp.fieldbyname('zdlen').AsInteger;
    flen := qrytmp.fieldbyname('zdlen').AsInteger;
    qrytmp.close;

  except
    result := -1;
  end;

end;

procedure auditdg.create_mxb(asheet: Variant; dgname: string; mydirect: string);
var
  bsheet: Variant;
  bmxb_column: MXB_COLUMN;
  icount: Integer;
  commandline: Integer;
  currentline: Integer;
begin
  bsheet := asheet;

  icount := bsheet.usedrange.columns.count;
  commandline := sdb_commandline_num(bsheet);
  bmxb_column := MXB_xmcolumn_num(bsheet, commandline, icount);

  qrytmp.close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.add('select A.* from dg7 a,项目对应关系 B ');
  qrytmp.SQL.add(' where (not A.长科目名 is null)  and A.一级科目代码=B.代码 and ');
  qrytmp.SQL.add(' a.xmid=b.xmid and a.xmid=''' + xmid + '''');
  qrytmp.SQL.add(' and  trim(B.底稿名称)=''' + Trim(dgname) + '''');
  qrytmp.SQL.Add(' AND  A.xmid=''' + trim(xmid) + '''');
  qrytmp.Open;
  qrytmp.First;

  currentline := commandline + 2;
  sheettmp.rows.item[commandline + 1, EmptyParam].rowheight := 15.75;
  sheettmp.rows.item[commandline + 2, EmptyParam].rowheight := 15.75;

  while not qrytmp.Eof do
  begin

    bsheet.rows.item[currentline, EmptyParam].select;
    fxlsapp.Selection.Insert(xlDown);
    bsheet.rows.item[currentline, EmptyParam].rowheight := 15.75;
    if bmxb_column.KMDM > 0 then
      bsheet.cells.item[currentline, bmxb_COLUMN.KMDM].value := '''' +
        qrytmp.fieldbyname('代码').asstring;
    if bmxb_column.kmname > 0 then
      bsheet.cells.item[currentline, bmxb_COLUMN.kmname].value :=
        qrytmp.fieldbyname('长科目名').asstring;
    if bmxb_column.KMDIRECT > 0 then
    begin
      bsheet.cells.item[currentline, bmxb_COLUMN.KMDIRECT].value :=
        qrytmp.fieldbyname('借贷方向').asstring;
      bsheet.columns.item[bmxb_column.KMDIRECT].AutoFit;
    end;
    if bmxb_column.QC > 0 then
    begin
      bsheet.cells.item[currentline, bmxb_COLUMN.qc].value :=
        qrytmp.fieldbyname('期初').asstring;
      mxb_cellsumformula(bsheet, currentline, bmxb_COLUMN.qc,
        bmxb_COLUMN.kmdirect, commandline, mydirect);
    end;
    if bmxb_column.sdqc > 0 then
    begin
      bsheet.cells.item[currentline, bmxb_COLUMN.sdqc].value :=
        qrytmp.fieldbyname('期初').asstring;
      mxb_cellsumformula(bsheet, currentline, bmxb_COLUMN.sdqc,
        bmxb_COLUMN.kmdirect, commandline, mydirect);

    end;
    if bmxb_column.qm > 0 then
    begin
      bsheet.cells.item[currentline, bmxb_COLUMN.qm].value :=
        qrytmp.fieldbyname('期末').asstring;
      mxb_cellsumformula(bsheet, currentline, bmxb_COLUMN.qm,
        bmxb_COLUMN.kmdirect, commandline, mydirect);
    end;

    if bmxb_column.sdqm > 0 then
    begin
      bsheet.cells.item[currentline, bmxb_COLUMN.sdqm].value :=
        qrytmp.fieldbyname('期末').asstring;

      mxb_cellsumformula(bsheet, currentline, bmxb_COLUMN.sdqm,
        bmxb_COLUMN.kmdirect, commandline, mydirect);

    end;

    if bmxb_column.jffs > 0 then
      bsheet.cells.item[currentline, bmxb_COLUMN.jffs].value :=
        qrytmp.fieldbyname('借方发生').asstring;

    if bmxb_column.dffs > 0 then
      bsheet.cells.item[currentline, bmxb_COLUMN.dffs].value :=
        qrytmp.fieldbyname('贷方发生').asstring;

    if bmxb_column.sdFS > 0 then
    begin
      bsheet.cells.item[currentline, bmxb_COLUMN.sdFS].value :=
        qrytmp.fieldbyname('贷方发生').asstring;

      mxb_cellsumformula(bsheet, currentline, bmxb_COLUMN.sdfs,
        bmxb_COLUMN.kmdirect, commandline, mydirect);

      bsheet.cells.item[currentline, bmxb_COLUMN.FS].value :=
        qrytmp.fieldbyname('贷方发生').asstring;

      mxb_cellsumformula(bsheet, currentline, bmxb_COLUMN.fs,
        bmxb_COLUMN.kmdirect, commandline, mydirect);
    end;

    currentline := currentline + 1;

    QRYTMP.NEXT;
  end;
  if bmxb_column.kmname > 0 then
    bsheet.columns.item[bmxb_column.kmname].AutoFit;

  sheettmp.rows.item[commandline + 1, EmptyParam].rowheight := 0;
end;

procedure auditdg.create_sdb(dgfilename: string; MYdirect: string);
var
  km: array of array of string;
  i, j, kmrowcount: integer;
  k, icount, commandline, direct, currentline: Integer;
  bSDB_COLUMN: SDB_COLUMN;
  isover: Boolean;
  cellformula: string;
  sheetname: string;
begin
  //
  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('select B.代码,B.科目名称,B.底稿名称,A.借贷方向,A.期初,A.借方发生,A.贷方发生,A.期末 ');
  qrytmp.SQL.Add(' from dg7 A,项目对应关系 B ');
  qrytmp.sql.Add(' where (A.代码=B.代码) and ');
  qrytmp.SQL.add(' a.xmid=b.xmid and a.xmid=''' + xmid + '''');
  qrytmp.SQL.add('and   (UCASE(trim(B.底稿名称))=''' + UpperCase(Trim(dgfilename)) + ''') ');
  //  qrytmp.SQL.Add(' AND  A.xmid=''' + trim(xmid) + '''');
  qrytmp.SQL.Add('  order by B.代码');

  qrytmp.Open;
  //  showmessage(qrytmp.sql.text + chr(13) + INTTOSTR(qrytmp.RecordCount));

  if not qrytmp.RecordCount > 0 then
  begin
    ShowMessage('项目对应关系表中无内容，请重新设置！！');
    exit;
  end;

  kmrowcount := qrytmp.RecordCount;
  SetLength(km, qrytmp.RecordCount, 8);

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

  fxlsapp.workbooks.open(axm.mbpath + '\' + trim(km[0, 0]), EmptyParam, EmptyParam, EmptyParam, EmptyParam,
    EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, 0);
  sheettmp := fxlsapp.activeworkbook.sheets.item['审定表'];
  sheettmp.Activate;

  commandline := sdb_commandline_num(sheettmp);
  sheettmp.rows.item[commandline + 1, EmptyParam].rowheight := 15.75;
  currentline := commandline + 2;

  if commandline < 1 then
  begin
    showmessage('文件的[审定表]中不是符合规则的表格，不能进行操作！' +
      fxlsapp.ActiveWorkbook.name);
    exit;
  end;

  isover := false;
  for i := 0 to kmrowcount - 1 do
  begin
    if i >= kmrowcount - 1 then
      isover := true;

    sheettmp.rows.item[currentline, EmptyParam].select;
    fxlsapp.Selection.Insert(xldown);

    //  ShowMessage(FXLSAPP.activeworkbook.Sheets.item[1].name);

    sheettmp.rows.item[currentline, EmptyParam].rowheight := 15.75;
    sheettmp.rows.item[commandline + 1, EmptyParam].rowheight := 0;
    icount := sheettmp.UsedRange.Columns.count;
    bSDB_COLUMN := sdb_xmcolumn_num(sheettmp, commandline, icount);

    if bSDB_COLUMN.kmname > 0 then
    begin
      if bSDB_COLUMN.kmdm > 0 then
        sheettmp.cells.item[currentline, bSDB_COLUMN.KMDM].value := km[i, 2];
      if bSDB_COLUMN.kmname > 0 then
        sheettmp.cells.item[currentline, bSDB_COLUMN.kmname].value := km[i, 1];
      if bSDB_COLUMN.kmdirect > 0 then
      begin
        sheettmp.cells.item[currentline, bSDB_COLUMN.kmdirect].value := km[i,
          3];
        sheettmp.columns.item[bSDB_COLUMN.kmdirect].AutoFit;
      end;
      if bSDB_COLUMN.qc > 0 then
        sheettmp.cells.item[currentline, bSDB_COLUMN.qc].value := km[i, 4];
      if bSDB_COLUMN.sdqc > 0 then
        sheettmp.cells.item[currentline, bSDB_COLUMN.sdqc].value := km[i, 4];
      if bSDB_COLUMN.qm > 0 then
        sheettmp.cells.item[currentline, bSDB_COLUMN.qm].value := km[i, 7];

      if bSDB_COLUMN.sdqm > 0 then
      begin
        if Pos('借', km[i, 3]) > 0 then
        begin
          cellformula := '=' + intto26(bSDB_COLUMN.qm) +
            trim(inttostr(currentline));
          if bSDB_COLUMN.qmtzjf > 0 then
            cellformula := cellformula + '+' + intto26(bSDB_COLUMN.qmtzjf) +
              trim(inttostr(currentline));
          if bSDB_COLUMN.qmtzdf > 0 then
            cellformula := cellformula + '-' + intto26(bSDB_COLUMN.qmtzdf) +
              trim(inttostr(currentline));
          if bSDB_COLUMN.qmcfljf > 0 then
            cellformula := cellformula + '+' + intto26(bSDB_COLUMN.qmcfljf) +
              trim(inttostr(currentline));
          if bSDB_COLUMN.qmcfldf > 0 then
            cellformula := cellformula + '-' + intto26(bSDB_COLUMN.qmcfldf) +
              trim(inttostr(currentline));
          sheettmp.cells.item[currentline, bSDB_COLUMN.sdqm].value :=
            cellformula;

        end
        else if Pos('贷', km[i, 3]) > 0 then
        begin
          cellformula := '=' + intto26(bSDB_COLUMN.qm) +
            trim(inttostr(currentline));
          if bSDB_COLUMN.qmtzjf > 0 then
            cellformula := cellformula + '-' + intto26(bSDB_COLUMN.qmtzjf) +
              trim(inttostr(currentline));
          if bSDB_COLUMN.qmtzdf > 0 then
            cellformula := cellformula + '+' + intto26(bSDB_COLUMN.qmtzdf) +
              trim(inttostr(currentline));
          if bSDB_COLUMN.qmcfljf > 0 then
            cellformula := cellformula + '-' + intto26(bSDB_COLUMN.qmcfljf) +
              trim(inttostr(currentline));
          if bSDB_COLUMN.qmcfldf > 0 then
            cellformula := cellformula + '+' + intto26(bSDB_COLUMN.qmcfldf) +
              trim(inttostr(currentline));
          sheettmp.cells.item[currentline, bSDB_COLUMN.sdqm].value :=
            cellformula;
        end;
        if isover then
        begin
          cellsumformula(sheettmp, currentline, bSDB_COLUMN.qm,
            bSDB_COLUMN.kmdirect, commandline, MYdirect);
          cellsumformula(sheettmp, currentline, bSDB_COLUMN.sdqm,
            bSDB_COLUMN.kmdirect, commandline, mydirect);
          cellsumformula(sheettmp, currentline, bSDB_COLUMN.qc,
            bSDB_COLUMN.kmdirect, commandline, mydirect);
          cellsumformula(sheettmp, currentline, bSDB_COLUMN.sdqc,
            bSDB_COLUMN.kmdirect, commandline, mydirect);

          if bSDB_COLUMN.qm > 0 then
            sheettmp.columns.item[bSDB_COLUMN.qm].AutoFit;
          if bSDB_COLUMN.sdqm > 0 then
            sheettmp.columns.item[bSDB_COLUMN.sdqm].AutoFit;
          if bSDB_COLUMN.sdqc > 0 then
            sheettmp.columns.item[bSDB_COLUMN.sdqc].AutoFit;
        end;
      end;

      if bSDB_COLUMN.fs > 0 then
        sheettmp.cells.item[currentline, bSDB_COLUMN.fs].value := km[i, 6];
      if bSDB_COLUMN.sdfs > 0 then
        sheettmp.cells.item[currentline, bSDB_COLUMN.sdfs].value := km[i, 6];

      cellformula := '=0';
      if bSDB_COLUMN.sdfs > 0 then
      begin
        if Pos('借', km[i, 3]) > 0 then
        begin

          cellformula := '=' + intto26(bSDB_COLUMN.fs) +
            trim(inttostr(currentline));
          if bSDB_COLUMN.qmtzjf > 0 then
            cellformula := cellformula + '+' + intto26(bSDB_COLUMN.qmtzjf) +
              trim(inttostr(currentline));
          if bSDB_COLUMN.qmtzdf > 0 then
            cellformula := cellformula + '-' + intto26(bSDB_COLUMN.qmtzdf) +
              trim(inttostr(currentline));
          if bSDB_COLUMN.qmcfljf > 0 then
            cellformula := cellformula + '+' + intto26(bSDB_COLUMN.qmcfljf) +
              trim(inttostr(currentline));
          if bSDB_COLUMN.qmcfldf > 0 then
            cellformula := cellformula + '-' + intto26(bSDB_COLUMN.qmcfldf) +
              trim(inttostr(currentline));
          sheettmp.cells.item[currentline, bSDB_COLUMN.sdfs].value :=
            cellformula;
        end
        else if Pos('贷', km[i, 3]) > 0 then
        begin
          cellformula := '=' + intto26(bSDB_COLUMN.fs) +
            trim(inttostr(currentline));
          if bSDB_COLUMN.qmtzjf > 0 then
            cellformula := cellformula + '-' + intto26(bSDB_COLUMN.qmtzjf) +
              trim(inttostr(currentline));
          if bSDB_COLUMN.qmtzdf > 0 then
            cellformula := cellformula + '+' + intto26(bSDB_COLUMN.qmtzdf) +
              trim(inttostr(currentline));
          if bSDB_COLUMN.qmcfljf > 0 then
            cellformula := cellformula + '-' + intto26(bSDB_COLUMN.qmcfljf) +
              trim(inttostr(currentline));
          if bSDB_COLUMN.qmcfldf > 0 then
            cellformula := cellformula + '+' + intto26(bSDB_COLUMN.qmcfldf) +
              trim(inttostr(currentline));
          sheettmp.cells.item[currentline, bSDB_COLUMN.sdfs].value :=
            cellformula;

        end;
        if isover then
        begin

          cellsumformula(sheettmp, currentline, bSDB_COLUMN.sdfs,
            bSDB_COLUMN.kmdirect, commandline, mydirect);
          cellsumformula(sheettmp, currentline, bSDB_COLUMN.fs,
            bSDB_COLUMN.kmdirect, commandline, mydirect);

        end;
      end;

    end;

    if isover then
    begin
      sheetname := mxb_name(fxlsapp.activeworkbook);

      if sheetname = '' then
      begin
        showmessage(fxlsapp.activeworkbook.name +
          '中无相应的明细表表格，不能进行处理。');
      end
      else
      begin
        sheettmp := fxlsapp.activeworkbook.sheets.item[sheetname];
        sheettmp.Activate;
        create_mxb(sheettmp, km[0, 0], MYdirect);
      end;
      replace_allsheet(fxlsapp.activeworkbook);

      fxlsapp.ActiveWorkbook.SaveAs(TARGETPATH + '\' + trim(km[0, 0]), EmptyParam, EmptyParam, EmptyParam,
        EmptyParam, EmptyParam, xlExclusive, EmptyParam, EmptyParam, EmptyParam, EmptyParam, 0);

      fxlsapp.ActiveWorkbook.CLOSE;
    end;
    currentline := currentline + 1;

  end;

  SetLength(km, 1, 1);

end;

function auditdg.mxb_NAME(workbook: variant): string;
var
  h: integer;
  mworkbook, msheet: variant;
begin
  result := '';

  mworkbook := workbook;
  for h := 1 to mworkbook.Sheets.Count do
  begin
    msheet := mworkbook.Sheets[h];
    //   showmessage(msheet.name);
    try
      if Pos('明细表', msheet.name) > 0 then
      begin
        result := mworkbook.Sheets.item[h].name;
        exit;
      end;
    except

    end;
  end;

end;

function auditdg.sdb_xmcolumn_num(asheet: Variant;
  commandline: Integer; columncount: integer): SDB_COLUMN;
var
  j: Integer;
  aSDB_COLUMN: SDB_COLUMN;
  str: string;
begin
  sheettmp := asheet;
  for j := 1 to columncount do
    //在明细表中的所有列进行循环 ，如果是期初就填入期初，依此类推。
  begin
    str := sheettmp.cells.item[commandline, j].value;

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

function auditdg.sdb_commandline_num(asheet: Variant): integer;
var
  i, icount, commandline: Integer;
  sheettmp: variant;
begin
  //
  sheettmp := asheet;
  icount := sheettmp.UsedRange.Columns.count;
  // SHOWMESSAGE(SHEETTMP.NAME);
  commandline := -1;

  //   取得标志行的所有行的数字
  try
    for i := 4 to 10 do
    begin

      if
        ((trim(sheettmp.cells.item[i + 1, 2].text) = '') or
        (trim(sheettmp.cells.item[i + 1, 2].text) = '\'))
        and
        (sheettmp.rows.item[i, EmptyParam].rowheight < 1)
        {//and (sheettmp.rows.item[i + 1, EmptyParam].rowheight < 1)}then
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

function auditdg.MXB_xmcolumn_num(asheet: Variant; commandline,
  columncount: integer): MXB_COLUMN;
var
  j: Integer;
  aMXB_COLUMN: MXB_COLUMN;
  str: string;
  csheet: variant;
begin
  csheet := asheet;
  for j := 1 to columncount do
    //在明细表中的所有列进行循环 ，如果是期初就填入期初，依此类推。
  begin
    str := csheet.cells.item[commandline, j].value;
    if Pos('科目编号', str) > 0 then
      aMXB_COLUMN.KMDM := j
    else if Pos('科目名称', str) > 0 then
      aMXB_COLUMN.KMNAME := j
    else if Pos('方向', str) > 0 then
      aMXB_COLUMN.kmdirect := j
    else if (Pos('审定期初', str) > 0) then
      aMXB_COLUMN.SDQC := j
    else if (Pos('未审期初', str) > 0) then
      aMXB_COLUMN.QC := j
    else if (Pos('审定发生', str) > 0) then
      aMXB_COLUMN.FS := j
    else if (Pos('未审发生', str) > 0) then
      aMXB_COLUMN.SDFS := j
    else if (Pos('账面借方', str) > 0) or (Pos('未审借方发生', str) > 0) then
      aMXB_COLUMN.JFFS := j
    else if (Pos('账面贷方', str) > 0) or (Pos('未审贷方发生', str) > 0) then
      aMXB_COLUMN.DFFS := j
    else if Pos('未审期末', str) > 0 then
      aMXB_COLUMN.QM := j
    else if (Pos('审定期末', str) > 0) then
      aMXB_COLUMN.SDQM := j
    else if Pos('期末调整借方', str) > 0 then
      aMXB_COLUMN.qmtzjf := j
    else if Pos('期末调整贷方', str) > 0 then
      aMXB_COLUMN.qmtzdf := j
    else if Pos('期末重分类借方', str) > 0 then
      aMXB_COLUMN.qmcfljf := j
    else if Pos('期末重分类贷方', str) > 0 then
      aMXB_COLUMN.qmcfldf := j;
  end;
  result := aMXB_COLUMN;

end;

function auditdg.GET_XMINFO: XMINFO;
begin
  //
  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('SELECT * FROM 底稿单位');
  qrytmp.SQL.Add(' WHERE  xmid=''' + trim(xmid) + '''');
  qrytmp.Open;
  if qrytmp.RecordCount > 0 then
  begin
    Result.dwmc := qrytmp.fieldbyname('dwmc').AsString;
    Result.startrq := qrytmp.fieldbyname('startrq').AsDateTime;
    Result.endrq := qrytmp.fieldbyname('endrq').AsDateTime;
    Result.yeard := qrytmp.fieldbyname('起止时间').AsString;
    Result.editor := qrytmp.fieldbyname('编制人').AsString;
    Result.editrq := qrytmp.fieldbyname('编制日期').AsDateTime;
    Result.checkor := qrytmp.fieldbyname('审核人').AsString;
    Result.checkRQ := qrytmp.fieldbyname('审核日期').AsDateTime;
    Result.xmpath := qrytmp.fieldbyname('path').AsString;
    TARGETPATH := qrytmp.fieldbyname('path').AsString;
    try
      if not DirectoryExists(TARGETPATH) then
        forceDirectories(TARGETPATH);
    except
      //      showmessage('保存的文件夹位置设置');
      //      exit;
    end;

  end
  else
  begin
    Result.dwmc := '';
    exit;
  end;
end;

procedure auditdg.replace_allsheet(WORKBOOKA: VARIANT);
var
  i: Integer;
  XBOOk: variant;
begin
  xbook := workbooka;
  if axm.dwmc <> '' then
    for i := 1 to xbook.Sheets.Count do
      replace_asheet(xbook, i);
end;

procedure auditdg.replace_asheet(WORKBOOK: VARIANT; sorder: integer);
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
  sheetreplace(ABK, sorder, '1997年12月31日', DateToStr(axm.editrq));
  sheetreplace(ABK, sorder, '1997年01月—1997年12月', axm.yeard);
  //  end;
end;

procedure auditdg.sheetreplace(AWORKBOOK: VARIANT; iorder: integer; ssource, starget: string);
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
    Bk.Sheets[iorder].Cells.Replace(aa, bb, EmptyParam, EmptyParam, EmptyParam, EmptyParam);
  except
  end;
end;

function auditdg.spendtime(sj: tdatetime): string;
var
  secondcount: integer;
begin
  //
  result := '';
  secondcount := SecondsBetween(sj, now);
  result := inttostr(secondcount div 60) + '分钟' + inttostr(secondcount mod 60)
    + '秒';
end;

function auditdg.getinfo: XMINFO;
begin
  //
  qrytmp.Close;
  qrytmp.sql.Clear;
  qrytmp.SQL.add('select * from 底稿单位');
  qrytmp.SQL.Add(' WHERE  A.xmid=''' + trim(xmid) + '''');
  qrytmp.open;
  if qrytmp.RecordCount > 0 then
  begin
    result.dwmc := qrytmp.fieldbyname('dwmc').AsString;
    result.startrq := qrytmp.fieldbyname('dwmc').AsDateTime;
    result.endrq := qrytmp.fieldbyname('dwmc').AsDateTime;
    result.yeard := qrytmp.fieldbyname('dwmc').AsString;
    result.editor := qrytmp.fieldbyname('dwmc').AsString;
    result.checkor := qrytmp.fieldbyname('dwmc').AsString;
    result.editrq := qrytmp.fieldbyname('dwmc').AsDateTime;
    result.checkRQ := qrytmp.fieldbyname('dwmc').AsDateTime;
  end
  else
    result.dwmc := '';
end;

procedure auditdg.saveinfo(axm: XMINFO);
begin
  //
  qrytmp.Close;
  qrytmp.sql.Clear;
  qrytmp.SQL.add('select * from 底稿单位');
  qrytmp.SQL.Add(' WHERE  xmid=''' + trim(xmid) + '''');
  qrytmp.open;

  if qrytmp.RecordCount > 0 then
  begin
    qrytmp.Close;
    qrytmp.sql.Clear;
    qrytmp.SQL.add('update  底稿单位 set 	dwmc=:dwmc ,	startrq=	:startrq,endrq=:endrq,');
    qrytmp.SQL.add('	起止时间=:yeard ,	编制人=:editor,	审核人=:checkor,	编制日期 =:editrq,	审核日期=:checkrq');
    qrytmp.SQL.Add(' WHERE  xmid=''' + trim(xmid) + '''');
    qrytmp.Parameters.ParamByName('dwmc').Value := axm.dwmc;
    qrytmp.Parameters.ParamByName('startrq').Value := axm.startrq;
    qrytmp.Parameters.ParamByName('endrq').Value := axm.endrq;
    qrytmp.Parameters.ParamByName('yeard').Value := axm.yeard;
    qrytmp.Parameters.ParamByName('editor').Value := axm.editor;
    qrytmp.Parameters.ParamByName('checkor').Value := axm.checkor;
    qrytmp.Parameters.ParamByName('editrq').Value := axm.editrq;
    qrytmp.Parameters.ParamByName('checkrq').Value := axm.checkRQ;
    qrytmp.ExecSQL;
  end
  else
  begin
    qrytmp.Close;
    qrytmp.sql.Clear;
    qrytmp.SQL.add('insert into 底稿单位 (	dwmc,	startrq,endrq,	起止时间 ,	编制人,	审核人,	编制日期 ,	审核日期) values(');
    qrytmp.SQL.add('  :dwmc , :startrq ,:endrq , :yeard, :editor , :checkor, :editrq ,:checkrq ');
    qrytmp.SQL.add(' ) ');
    qrytmp.Parameters.ParamByName('dwmc').Value := axm.dwmc;
    qrytmp.Parameters.ParamByName('startrq').Value := axm.startrq;
    qrytmp.Parameters.ParamByName('endrq').Value := axm.endrq;
    qrytmp.Parameters.ParamByName('yeard').Value := axm.yeard;
    qrytmp.Parameters.ParamByName('editor').Value := axm.editor;
    qrytmp.Parameters.ParamByName('checkor').Value := axm.checkor;
    qrytmp.Parameters.ParamByName('editrq').Value := axm.editrq;
    qrytmp.Parameters.ParamByName('checkrq').Value := axm.checkRQ;
    qrytmp.ExecSQL;
  end;
end;

function auditdg.space(count: Integer): string;
var
  i: integer;
begin
  //

  result := '';
  for i := 1 to count do
    result := result + ' ';

end;

function auditdg.UNDIRECT(STR: string): string;
begin
  //
  result := '';
  if (Trim(STR) = '借') then
    RESULT := '贷'
  else if Trim(STR) = '贷' then
    result := '借';

end;

procedure auditdg.cellsumformula(sheettmp: Variant; row, column, directcolumn,
  baseline: Integer;
  mydirect: string);
var
  asheet: variant;
  str: string;
begin
  asheet := sheettmp;
  //
  str := '=sumif(' +
    intto26(directcolumn) + trim(inttostr(baseline + 1)) + ':' +
    intto26(directcolumn) + trim(inttostr(row))
    + ',"' + MYdirect + '" ,' +
    intto26(column) + trim(inttostr(baseline + 1)) + ':' +
    intto26(column) + trim(inttostr(row)) + ')' +
    '-sumif(' +
    intto26(directcolumn) + trim(inttostr(baseline + 1)) + ':' +
    intto26(directcolumn) + trim(inttostr(row))
    + ',"' + UNDIRECT(mydirect) + '",' +
    intto26(column) + trim(inttostr(baseline + 1)) + ':' +
    intto26(column) + trim(inttostr(row)) + ')';
  // showmessage(str);
 //  =SUMIF(D8:D9,"贷",G8:G9)
  asheet.cells.item[row + 2, column].value := str;
  asheet.cells.item[row + 4, column].value := '=' +
    intto26(column) + trim(inttostr(row + 2));
end;

procedure auditdg.mxb_cellsumformula(sheettmp: Variant; row, column, directcolumn,
  baseline: Integer;
  mydirect: string);
var
  asheet: variant;
  str: string;
begin
  asheet := sheettmp;
  //
  str := '=sumif(' +
    intto26(directcolumn) + trim(inttostr(baseline + 1)) + ':' +
    intto26(directcolumn) + trim(inttostr(row))
    + ',"' + MYdirect + '" ,' +
    intto26(column) + trim(inttostr(baseline + 1)) + ':' +
    intto26(column) + trim(inttostr(row)) + ')' +
    '-sumif(' +
    intto26(directcolumn) + trim(inttostr(baseline + 1)) + ':' +
    intto26(directcolumn) + trim(inttostr(row))
    + ',"' + UNDIRECT(mydirect) + '",' +
    intto26(column) + trim(inttostr(baseline + 1)) + ':' +
    intto26(column) + trim(inttostr(row)) + ')';
  asheet.cells.item[row + 2, column].value := str;

end;

procedure auditdg.limit_database_toexcel;
var
  qrylist: TADOQuery;
  dgname: string;
  sj1: tdatetime;
  i: integer;
begin
  //
   //==================
  SJ1 := NOW();
  axm := GET_XMINFO;
  if not DirectoryExists(TARGETPATH) then
  begin
    ShowMessage('保存文件的路径未设置，请进入【填列底稿表头信息】中进行设置。');
    exit;
  end;
  qrylist := TADOQuery.Create(nil);
  qrylist.Connection := self.con;
  qrylist.Close;
  qrylist.SQL.Add('select  TOP 4 MIN(底稿名称) AS 底稿名称,min(借贷方向) as 借贷方向  from 项目对应关系 ');
  qrylist.SQL.Add(' where  (not 底稿名称 is null) AND  xmid=''' +
    trim(xmid) + ''' group by 底稿名称  ');

  qrylist.Open;
  i := 1;

  while (not qrylist.Eof) and (i <= 4) do
  begin
    dgname := qrylist.fieldbyname('底稿名称').AsString;
    create_sdb(dgname, qrylist.fieldbyname('借贷方向').AsString);
    qrylist.next;
    inc(i);
  end;
  fxlsapp.DISPLAYALERTS := false;
  SHOWMESSAGE('未注册版本，将只会显示有限的几个报表项目的底稿！' + chr(13) + '注册请联系 QQ:179930269');
  ShellExecute(0, 'open', PChar(TARGETPATH), 'C:\Windows', nil, 1);
end;

procedure auditdg.limit_database_select_toexcel(kmlist: tstringlist);
var
  qrylist: TADOQuery;
  dgname: string;
  sj1: tdatetime;
  i: integer;
begin
  //
   //==================
  SJ1 := NOW();
  axm := GET_XMINFO;
  if not DirectoryExists(TARGETPATH) then
  begin
    ShowMessage('保存文件的路径未设置，请进入【填列底稿表头信息】中进行设置。');
    exit;
  end;
  qrylist := TADOQuery.Create(nil);
  qrylist.Connection := self.con;
  qrylist.Close;
  qrylist.SQL.Add('select TOP 4  MIN(底稿名称) AS 底稿名称,min(借贷方向) as 借贷方向  from 项目对应关系 ');
  qrylist.SQL.Add(' where  (not 底稿名称 is null) AND  xmid=''' +
    trim(xmid) + ''' group by 底稿名称  ');

  qrylist.Open;
  i := 1;

  while (not qrylist.Eof) and (i <= 4) do
  begin
    dgname := qrylist.fieldbyname('底稿名称').AsString;
    create_sdb(dgname, qrylist.fieldbyname('借贷方向').AsString);
    qrylist.next;
    inc(i);
  end;
  fxlsapp.DISPLAYALERTS := false;
  SHOWMESSAGE('未注册版本，将只会显示有限的几个报表项目的底稿！' + chr(13) + '注册请联系 QQ:179930269');
  ShellExecute(0, 'open', PChar(TARGETPATH), 'C:\Windows', nil, 1);

end;

procedure auditdg.datebase_toexcel;
var
  qrylist: TADOQuery;
  dgname: string;
  sj1: tdatetime;
begin
  //
  SJ1 := NOW();
  axm := GET_XMINFO;
  if not DirectoryExists(TARGETPATH) then
  begin
    ShowMessage('保存文件的路径未设置，请进入【填列底稿表头信息】中进行设置。');
    exit;
  end;
  qrylist := TADOQuery.Create(nil);
  qrylist.Connection := self.con;
  qrylist.Close;
  qrylist.SQL.Add('select  MIN(底稿名称) AS 底稿名称,min(借贷方向) as 借贷方向  from 项目对应关系 ');
  qrylist.SQL.Add(' where  (not 底稿名称 is null) AND  xmid=''' +
    trim(xmid) + ''' group by 底稿名称  ');

  qrylist.Open;
  while not qrylist.Eof do
  begin
    dgname := qrylist.fieldbyname('底稿名称').AsString;
    create_sdb(dgname, qrylist.fieldbyname('借贷方向').AsString);
    qrylist.next;
  end;

  fxlsapp.DISPLAYALERTS := false;
  SHOWMESSAGE('生成底稿总费时：' + spendtime(sj1));
  ShellExecute(0, 'open', PChar(TARGETPATH), 'C:\Windows', nil, 1);

end;

procedure auditdg.database_select_toexcel(kmlist: tstringlist);
var
  i: integer;
  dgname, dgfx: string;
  SJ1: tdatetime;
  pos1: integer;

begin
  //
  SJ1 := NOW();
  axm := GET_XMINFO;
  if not DirectoryExists(TARGETPATH) then
  begin
    ShowMessage('保存文件的路径未设置，请进入【填列底稿表头信息】中进行设置。');
    exit;
  end;

  for i := 0 to kmlist.Count - 1 do
  begin
    pos1 := Pos('>>', kmlist[i]);
    dgname := Trim(Copy(kmlist[i], 1, pos1 - 1));
    dgfx := Trim(Copy(kmlist[i], pos1 + 2, Length(kmlist[i])));
    create_sdb(dgname, dgfx);
  end;
  fxlsapp.DISPLAYALERTS := true;

end;

procedure auditdg.create_PZB;
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
  sheettmp.cells[1, 2] := '年';
  sheettmp.cells[1, 3] := '月';
  sheettmp.cells[1, 4] := '凭证类型';
  sheettmp.cells[1, 5] := '凭证号';
  sheettmp.cells[1, 6] := '摘要';
  sheettmp.cells[1, 7] := '科目代码';
  sheettmp.cells[1, 8] := '科目名称';
  sheettmp.cells[1, 9] := '借方';
  sheettmp.cells[1, 10] := '贷方';
  sheettmp.cells[1, 11] := '对方科目';
  sheettmp.COLUMNS[1].COLUMNWIDTH := 10;
  sheettmp.COLUMNS[2].COLUMNWIDTH := 4;
  sheettmp.COLUMNS[3].COLUMNWIDTH := 4;
  sheettmp.COLUMNS[4].COLUMNWIDTH := 4;
  sheettmp.COLUMNS[5].COLUMNWIDTH := 4;
  sheettmp.COLUMNS[6].COLUMNWIDTH := 30;
  sheettmp.COLUMNS[7].COLUMNWIDTH := 12;
  sheettmp.COLUMNS[8].COLUMNWIDTH := 12;
  sheettmp.COLUMNS[9].COLUMNWIDTH := 12;
  sheettmp.COLUMNS[10].COLUMNWIDTH := 12;
  sheettmp.COLUMNS[11].COLUMNWIDTH := 30;
  sheettmp.Range['A1', 'k1'].Interior.Color := #15769326;
end;

procedure auditdg.dbfromexcel_pzb;
var
  m: integer;
begin
  if not sheetexists(PZsheet) then
  begin
    ShowMessage('活动工作簿中无【凭证表】！');
    exit;
  end;

  if Trim(XMID) = '' then
  begin
    ShowMessage('请先打开项目后再导入凭证！');
    exit;

  end;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('delete from 凭证表  where xmid=''' + trim(xmid) + '''');
  qrytmp.ExecSQL;
  qrytmp.close;
  sheettmp := fxlsapp.activeworkbook.sheets.item[PZsheet];
  sheettmp.select;

  rowscount := sheettmp.usedrange.rows.count;
  colscount := sheettmp.usedrange.columns.count;

  if tabletmp.Active then
    tabletmp.Close;
  tabletmp.TableName := '凭证表';
  tabletmp.open;

  fillPZB;

  m := 1;
  while m <= Int(rowscount / 1000) + 1 do
  begin

    varrykm := sheettmp.Range[sheettmp.cells.Item[2 + (m - 1) * 1000, 1],
      sheettmp.cells.Item[2 + m * 1000 - 1, colscount]].Value;

    PZBtoexcel(1000, colscount);
    m := m + 1;
  end;
  tabletmp.close;

  GENE_MXKM;

end;

procedure auditdg.PZBtoexcel(rows, cols: Integer);
var
  i, j: integer;
  icount: integer;
begin
  //

  i := 1;
  icount := rows;
  for i := 1 to icount do
  begin
    if Trim(varrykm[i, 7]) <> '' then
    begin

      tabletmp.Append;

      //日期	年	月	凭证号	摘要	科目代码	科目名称	 借方 	 贷方 	对方科目

      try
        tabletmp.FieldByName('xmid').AsString := xmid;
      except
      end;

      try
        tabletmp.FieldByName('日期').AsString := varrykm[i, 1];
      except
      end;
      try
        tabletmp.FieldByName('年份').AsString := varrykm[i, 2];
      except
      end;

      try
        tabletmp.FieldByName('月份').AsString := varrykm[i, 3];
      except
      end;

      try
        tabletmp.FieldByName('凭证类型').AsString := varrykm[i, 4];
      except
      end;
      try
        tabletmp.FieldByName('凭证编号').AsString := varrykm[i, 5];
      except
      end;
      try
        tabletmp.FieldByName('摘要').AsString := varrykm[i, 6];
      except
      end;

      try
        tabletmp.FieldByName('科目编码').AsString := varrykm[i, 7];
      except
      end;

      try
        tabletmp.FieldByName('科目名称').AsString := varrykm[i, 8];
      except
      end;

      try
        tabletmp.FieldByName('借方').asfloat := varrykm[i, 9];
      except
      end;
      try
        tabletmp.FieldByName('贷方').asfloat := varrykm[i, 10];
      except

      end;

      try
        tabletmp.FieldByName('对方科目').AsString := varrykm[i, 11];
      except
      end;

      tabletmp.post;
    end;
  end;

end;

procedure auditdg.fillPZB;
var
  IROWS, ICOLS: INTEGER;
  I, J, K: INTEGER;
  LASTREC: INTEGER;
  STRVALUE: Variant;
begin

  IROWS := sheettmp.usedrange.rows.count;
  ICOLS := sheettmp.usedrange.columns.count;

  for I := 1 to 6 do
  begin
    J := 1;
    VarClear(STRVALUE);
    while J <= INT(IROWS / 3000) + 1 do
    begin

      varrykm := sheettmp.Range[sheettmp.cells.Item[2 + (J - 1) * 3000, I],
        sheettmp.cells.Item[2 + J * 3000 - 1, I]].Value;

      if VarIsEmpty(STRVALUE) then
        STRVALUE := VARRYKM[1, 1];
      K := 1;
      while K <= 3000 do
      begin

        if not VarIsEmpty(VARRYKM[K, 1]) then
          STRVALUE := VARRYKM[K, 1]
        else if not VarIsEmpty(STRVALUE) then
          VARRYKM[K, 1] := STRVALUE;

        if (2 + (J - 1) * 3000 + K - 1 > IROWS) then
          BREAK;

        K := K + 1;
      end;

      sheettmp.Range[sheettmp.cells.Item[2 + (J - 1) * 3000, I],
        sheettmp.cells.Item[2 + J * 3000 - 1, I]].Value := varrykm;

      J := J + 1;
    end;
  end;
end;

procedure auditdg.dbfrom_dxnxmpzb;
var
  sqltext: string;
begin
  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('delete from  DG7 where  trim(XMID)=''' + XMID + '''');
  qrytmp.ExecSQL;
  qrytmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('delete from  DG7 where  xmid is null');
  qrytmp.ExecSQL;
  qrytmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('delete from  凭证表 where  trim(XMID)=''' + XMID + '''');
  qrytmp.ExecSQL;
  qrytmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('delete from  凭证表 where  xmid is null');
  qrytmp.ExecSQL;
  qrytmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('delete from  项目凭证表 where  trim(XMID)=''' + XMID + '''');
  qrytmp.ExecSQL;
  qrytmp.close;

  sqltext :=
    'INSERT INTO  dg7 (代码 ,科目名称,借贷方向,期初 ,借方发生,贷方发生,期末)' + //prd_no, SPC, UT, DFU_UT, KND, IDX1, NAME, SUP1
  ' SELECT' +
    ' 科目编号,科目名称,借贷方向,账面期初数,账面借方发生额,账面贷方发生额,账面期末数' +
    ' FROM [excel 8.0;database=' + fxlsapp.ACTIVEWORKBOOK.fullname + '].[DXNKMYEB$]';

  // SHOWMESSAGE(SQLTEXT);
  qrytmp.Close;
  qrytmp.Parameters.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(sqltext);
  qrytmp.ExecSQL;
  qrytmp.close;

  sqltext :=
    'INSERT INTO  dg7 (代码,科目名称,核算项目类型,核算项目代码 ,核算项目名称,借贷方向,期初 ,借方发生,贷方发生,期末)' +
    ' SELECT' +
    ' 科目编号,"    "+科目名称,核算项目类型名称,核算项目编号,核算项目名称,借贷方向,账面期初数,账面借方发生额,账面贷方发生额,账面期末数 ' +
    ' FROM [excel 8.0;database=' + fxlsapp.ACTIVEWORKBOOK.fullname + '].[dxnxmyeb$]';

  qrytmp.Close;
  qrytmp.Parameters.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(sqltext);
  qrytmp.ExecSQL;
  qrytmp.close;

  sqltext :=
    'INSERT INTO  凭证表 (全凭证号, 年份, 月份, 凭证类型, 凭证编号,内编号, 科目编码, 科目名称, 摘要, 借方, 贷方,对方科目)' +
    ' SELECT' +
    ' 记账时间,会计年,会计月, 凭证种类 ,凭证编号,编号,科目编号, 科目名称,业务说明  ,借方发生额 ,贷方发生额,对方科目名称 ' +
    ' FROM [excel 8.0;database=' + fxlsapp.ACTIVEWORKBOOK.fullname + '].[dxnpzb$]';

  qrytmp.Close;
  qrytmp.Parameters.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(sqltext);
  qrytmp.ExecSQL;
  qrytmp.close;

  sqltext :=
    'INSERT INTO  项目凭证表(全凭证号,  月份, 凭证类型, 凭证编号,内编号, 科目编码, 科目名称, 摘要, 借方, 贷方,项目核算类型,项目核算代码,项目核算名称,对方科目)' +
    ' SELECT' +
    '  记账时间,会计月, 凭证种类 ,凭证编号,编号,科目编号, 科目名称,业务说明,借方发生额 ,贷方发生额,核算项目类型编号,核算项目ID,核算项目名称,对方科目名称 '
    + ' FROM [excel 8.0;database=' + fxlsapp.ACTIVEWORKBOOK.fullname + '].[dxnxmpzb$]';

  qrytmp.Close;
  qrytmp.Parameters.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(sqltext);
  qrytmp.ExecSQL;
  qrytmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('UPDATE DG7 SET  一级科目代码=left(代码,4) WHERE XMID is NULL');
  qrytmp.ExecSQL;
  qrytmp.close;

  // 全凭证号

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('UPDATE DG7 SET  XMID=''' + XMID + '''' + ' WHERE XMID is NULL');
  qrytmp.ExecSQL;
  qrytmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('UPDATE 项目凭证表 SET 年份 =val(left(trim(全凭证号),4)) WHERE XMID is NULL and TRIM(全凭证号)<>""');
  qrytmp.ExecSQL;
  qrytmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('UPDATE 项目凭证表 SET 月份 =val(mid(trim(全凭证号),5,2)) WHERE XMID is NULL and TRIM(全凭证号)<>"" ');
  qrytmp.ExecSQL;
  qrytmp.close;

  try
    qrytmp.Close;
    qrytmp.SQL.Clear;
    qrytmp.ParamCheck := false;
    qrytmp.SQL.Add('UPDATE 项目凭证表  SET 日期 =DateSerial(年份,月份,1) WHERE XMID is NULL  ');
    qrytmp.ExecSQL;
    qrytmp.close;
  except
  end;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('UPDATE 项目凭证表 SET 全凭证号 =str(年份)+"_"+str(月份)+"_"+left(凭证类型,2)+凭证编号 WHERE XMID is NULL');
  qrytmp.ExecSQL;
  qrytmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('UPDATE 项目凭证表 SET  XMID=''' + XMID + '''' + ' WHERE XMID is NULL');
  qrytmp.ExecSQL;
  qrytmp.close;

  ///==============项目凭证表结束

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('UPDATE 凭证表 SET 年份 =val(mid(trim(全凭证号),1,4)) WHERE (XMID is NULL) ');
  qrytmp.ExecSQL;
  qrytmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('UPDATE 凭证表 SET 月份 =val(mid(trim(全凭证号),5,2)) WHERE XMID is NULL ');
  qrytmp.ExecSQL;
  qrytmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('UPDATE 凭证表 SET 日期 =DateSerial(年份,月份,1) WHERE XMID is NULL  and ( 日期 is null)');
  qrytmp.ExecSQL;
  qrytmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('UPDATE 凭证表 SET 全凭证号 =str(年份)+"_"+str(月份)+"_"+left(凭证类型,2)+凭证编号 WHERE XMID is NULL');
  qrytmp.ExecSQL;
  qrytmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update  dg7  set 一级科目代码=left(代码,' + zdlength + ')');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update  凭证表  set 一级编码=left(科目编码,' + zdlength + ')');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update  凭证表  set  年份=year(日期)  where XMID is NULL  and (年份=0 or 年份 is null)');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update  凭证表  set  月份=month(日期) where XMID is NULL  and (年份=0 or 年份 is null)');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update  凭证表  set  借方=0 where 借方  is null');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update  凭证表  set  贷方=0 where 贷方  is null');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('UPDATE 凭证表 SET  XMID=''' + XMID + '''' + ' WHERE XMID is NULL');
  qrytmp.ExecSQL;
  qrytmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update  凭证表  set  全凭证号=str(年份)+"_"+str(月份)+"_"+left(凭证类型,2)+凭证编号');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('delete from  dg7  where  not (核算项目名称 is null) ');
  qrytmp.SQL.Add('   and 期初=0 and 期末=0 and 借方发生=0 and 贷方发生=0 and xmid=''' + trim(xmid) + '''');
  qrytmp.ExecSQL;

end;

procedure auditdg.dbfrom_dxnxmyeb;
begin
  //
end;

procedure auditdg.fillzero(asheet: Variant; ncolumn: integer);
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

procedure auditdg.formatsheetdate(asheet: Variant);
var
  i, j, ncount, ncolcount, ncolumn: integer;
  acol: Variant;
  strx, STRA, STRB, STRC: string;

begin

  ncount := asheet.usedrange.rows.count;
  ncolcount := asheet.usedrange.columns.count;

  for ncolumn := 1 to ncolcount do
  begin

    if asheet.cells.Item[1, ncolumn].TEXT = '记账时间' then
    begin
      acol := asheet.Range[asheet.cells.Item[2, ncolumn],
        asheet.cells.Item[ncount, ncolumn]].value;

      for i := 1 to ncount - 1 do
      begin
        strx := (acol[i, 1]);
        if pos(' ', strx) > 0 then
          strx := StringReplace(strx, ' ', '.', [rfreplaceall]);

        if pos('/', strx) > 0 then
          strx := StringReplace(strx, '/', '.', [rfreplaceall]);
        if pos('-', strx) > 0 then
          strx := StringReplace(strx, '-', '.', [rfreplaceall]);

        if Pos('.', strx) > 0 then
        begin
          StrA := '0';
          STRB := '0';
          STRC := '0';

          STRA := Copy(strx, 1, Pos('.', strx) - 1);
          strx := TRIM(COPY(strx, Pos('.', strx) + 1, 20));
          if Pos('.', strx) > 0 then
          begin
            STRB := Copy(strx, 1, Pos('.', strx) - 1);
            STRC := TRIM(COPY(strx, Pos('.', strx) + 1, 20));
          end;

          try
            if strtoint(StrA) > 1990 then
              acol[i, 1] := STRA + RIGHTSTR('00' + STRB, 2) + RIGHTSTR('00' + STRC, 2)
            else if strtoint(Strc) > 1990 then
              acol[i, 1] := STRC + RIGHTSTR('00' + STRA, 2) + RIGHTSTR('00' + STRB, 2)
          except
          end;
        end;

      end;
      asheet.Range[asheet.cells.Item[2, ncolumn],
        asheet.cells.Item[ncount, ncolumn]].Value := acol;
    end;
  end;
end;

function auditdg.getxm: xminfo;
begin
  //
  result := axm;
end;

procedure auditdg.setxm(const Value: xminfo);
begin
  axm := Value;
  xmid := axm.xmid;
  mbid := axm.mbname;
end;

end.

