unit csdg;

interface
uses SysUtils, Variants, StrUtils, IniFiles,
  mydg_TLB, DateUtils, ShellAPI, communit, clslxy,
  Dialogs, Excel2000, ADODB, Classes;
const
  KM7sheet = '��Ŀ����7��';
  KM9sheet = '��Ŀ����9��';
  PZsheet = 'ƾ֤��';

  sdsheet = '�󶨱�';
  MXsheet = '��ϸ��';
  AFILENAME = '';

  zdlength = '4';
type
  SDB_COLUMN = record //��Ŀ���󶨱��е�˳���
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
    procedure GENE_MXKM(); //������ϸ���� mdb��
    procedure GENE_onelevel_km(); //����һ����Ŀ mdb��
    function getfieldlength(): integer; //����һ����Ŀ�ĳ���
    function mxb_NAME(workbook: variant): string;
    function getxm: xminfo;
    procedure setxm(const Value: xminfo);
  public
    procedure create_PZB;
    procedure dbfromexcel_column7();
    procedure dbfromexcel_column9();
    procedure dbfrom_dxnxmyeb(); //��Ŀ����
    procedure dbfrom_dxnxmpzb(); //��Ŀƾ֤��
    procedure DBFROMEXCEL();
    procedure dbfromexcel_pzb;
    procedure PZBtoexcel(rows, cols: Integer);
    constructor create(con1: tadoconnection; xlsapp: OleVariant; dllpath:
      string);
    procedure create_KM7sheet(); //7�еĿ�Ŀ����
    procedure create_KM9sheet(); //9�еĿ�Ŀ����
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

procedure auditdg.DBFROMEXCEL;
begin

end;

procedure auditdg.dbfromexcel_column7;
var
  i, j: integer;
begin
  if not sheetexists(km7sheet) then
  begin
    ShowMessage('�����������7�еĿ�Ŀ����');
    exit;
  end;

  if Trim(XMID) = '' then
  begin
    ShowMessage('Ո�Ƚ����Ŀ����_�Ŀ���ٌ��딵����');
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

  ShowMessage('����ŵ���ݵ���ɹ���OK��');

end;

procedure auditdg.dbfromexcel_column9;
var
  i, j: integer;
begin
  //
  if not sheetexists(km9sheet) then
  begin
    ShowMessage('�����������7�еĿ�Ŀ����');
    exit;
  end;

  if Trim(XMID) = '' then
  begin
    ShowMessage('Ո�Ƚ����Ŀ����_�Ŀ���ٌ��딵����');
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
    if Trim(varrykm[i, 3]) = '��' then
    begin
      varrykm[i, 4] := varrykm[i, 4] - varrykm[i, 5];
    end
    else
    begin
      varrykm[i, 4] := varrykm[i, 5] - varrykm[i, 4];
    end;

    varrykm[i, 5] := varrykm[i, 6];
    varrykm[i, 6] := varrykm[i, 7];

    if Trim(varrykm[i, 3]) = '��' then
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

procedure auditdg.GENE_MXKM; //����(����Ŀ����
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
  len1 := Length(trim(tabletmp.fieldbyname('����').AsString));
  onelevel_KM := '';
  while not tabletmp.eof do
  begin
    if len1 = fieldlength then
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

  GENE_onelevel_km;
  // ShowMessage('����ok');
end;

procedure auditdg.GENE_onelevel_km;
var
  strkm: string;
begin
  //

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('delete from ��Ŀ��Ӧ��ϵ where xmid=''' + trim(xmid) + '''');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('delete from  dg7  where  ����  in (');
  qrytmp.SQL.Add(' select ���� from dg7 where len(trim(����)) =' +
    inttostr(fieldlength) +
    'and  ������Ŀ���� is null and �ڳ�=0 and ��ĩ=0 and �跽����=0 and ��������=0 and xmid=''' + trim(xmid) + '''');
  qrytmp.SQL.Add(')');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('insert into ��Ŀ��Ӧ��ϵ(xmid,����,��Ŀ����,�������)');
  qrytmp.SQL.Add('  select  xmid,����,��Ŀ����,������� from dg7 where len(����)=' + inttostr(fieldlength));
  qrytmp.SQL.Add(' AND  xmid=''' + trim(xmid) + '''');
  qrytmp.ExecSQL;
  qrytmp.Close;

  if tabletmp.Active then
    tabletmp.Close;
  tabletmp.TableName := '��Ŀ��Ӧ��ϵ';
  tabletmp.Filter := 'xmid=''' + trim(xmid) + '''';
  tabletmp.open;
  tabletmp.Filtered := true;

  tabletmp.First;
  while not tabletmp.Eof do
  begin
    strkm := Trim(tabletmp.fieldbyname('��Ŀ����').AsString);
    qrytmp.Close;
    qrytmp.SQL.Clear;
    qrytmp.SQL.Add('select �׸�����  from  ��Ŀ�׸��Ӧ�� where ��Ŀ���� like ''%' + strkm + '%'' ');
    qrytmp.SQL.Add('and MBid=''' + trim(MBid) + '''');
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

function auditdg.getfieldlength: integer;
var
  flen: integer;

begin
  //
  result := -1;
  try
    qrytmp.Close;
    qrytmp.SQL.Clear;
    qrytmp.SQL.Add('select min(len(����)) as zdlen from dg7 ');
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
  qrytmp.SQL.add('select A.* from dg7 a,��Ŀ��Ӧ��ϵ B ');
  qrytmp.SQL.add(' where (not A.����Ŀ�� is null)  and A.һ����Ŀ����=B.���� and ');
  qrytmp.SQL.add(' a.xmid=b.xmid and a.xmid=''' + xmid + '''');
  qrytmp.SQL.add(' and  trim(B.�׸�����)=''' + Trim(dgname) + '''');
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
        qrytmp.fieldbyname('����').asstring;
    if bmxb_column.kmname > 0 then
      bsheet.cells.item[currentline, bmxb_COLUMN.kmname].value :=
        qrytmp.fieldbyname('����Ŀ��').asstring;
    if bmxb_column.KMDIRECT > 0 then
    begin
      bsheet.cells.item[currentline, bmxb_COLUMN.KMDIRECT].value :=
        qrytmp.fieldbyname('�������').asstring;
      bsheet.columns.item[bmxb_column.KMDIRECT].AutoFit;
    end;
    if bmxb_column.QC > 0 then
    begin
      bsheet.cells.item[currentline, bmxb_COLUMN.qc].value :=
        qrytmp.fieldbyname('�ڳ�').asstring;
      mxb_cellsumformula(bsheet, currentline, bmxb_COLUMN.qc,
        bmxb_COLUMN.kmdirect, commandline, mydirect);
    end;
    if bmxb_column.sdqc > 0 then
    begin
      bsheet.cells.item[currentline, bmxb_COLUMN.sdqc].value :=
        qrytmp.fieldbyname('�ڳ�').asstring;
      mxb_cellsumformula(bsheet, currentline, bmxb_COLUMN.sdqc,
        bmxb_COLUMN.kmdirect, commandline, mydirect);

    end;
    if bmxb_column.qm > 0 then
    begin
      bsheet.cells.item[currentline, bmxb_COLUMN.qm].value :=
        qrytmp.fieldbyname('��ĩ').asstring;
      mxb_cellsumformula(bsheet, currentline, bmxb_COLUMN.qm,
        bmxb_COLUMN.kmdirect, commandline, mydirect);
    end;

    if bmxb_column.sdqm > 0 then
    begin
      bsheet.cells.item[currentline, bmxb_COLUMN.sdqm].value :=
        qrytmp.fieldbyname('��ĩ').asstring;

      mxb_cellsumformula(bsheet, currentline, bmxb_COLUMN.sdqm,
        bmxb_COLUMN.kmdirect, commandline, mydirect);

    end;

    if bmxb_column.jffs > 0 then
      bsheet.cells.item[currentline, bmxb_COLUMN.jffs].value :=
        qrytmp.fieldbyname('�跽����').asstring;

    if bmxb_column.dffs > 0 then
      bsheet.cells.item[currentline, bmxb_COLUMN.dffs].value :=
        qrytmp.fieldbyname('��������').asstring;

    if bmxb_column.sdFS > 0 then
    begin
      bsheet.cells.item[currentline, bmxb_COLUMN.sdFS].value :=
        qrytmp.fieldbyname('��������').asstring;

      mxb_cellsumformula(bsheet, currentline, bmxb_COLUMN.sdfs,
        bmxb_COLUMN.kmdirect, commandline, mydirect);

      bsheet.cells.item[currentline, bmxb_COLUMN.FS].value :=
        qrytmp.fieldbyname('��������').asstring;

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
  qrytmp.SQL.Add('select B.����,B.��Ŀ����,B.�׸�����,A.�������,A.�ڳ�,A.�跽����,A.��������,A.��ĩ ');
  qrytmp.SQL.Add(' from dg7 A,��Ŀ��Ӧ��ϵ B ');
  qrytmp.sql.Add(' where (A.����=B.����) and ');
  qrytmp.SQL.add(' a.xmid=b.xmid and a.xmid=''' + xmid + '''');
  qrytmp.SQL.add('and   (UCASE(trim(B.�׸�����))=''' + UpperCase(Trim(dgfilename)) + ''') ');
  //  qrytmp.SQL.Add(' AND  A.xmid=''' + trim(xmid) + '''');
  qrytmp.SQL.Add('  order by B.����');

  qrytmp.Open;
  //  showmessage(qrytmp.sql.text + chr(13) + INTTOSTR(qrytmp.RecordCount));

  if not qrytmp.RecordCount > 0 then
  begin
    ShowMessage('��Ŀ��Ӧ��ϵ���������ݣ����������ã���');
    exit;
  end;

  kmrowcount := qrytmp.RecordCount;
  SetLength(km, qrytmp.RecordCount, 8);

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

  fxlsapp.workbooks.open(axm.mbpath + '\' + trim(km[0, 0]), EmptyParam, EmptyParam, EmptyParam, EmptyParam,
    EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, 0);
  sheettmp := fxlsapp.activeworkbook.sheets.item['�󶨱�'];
  sheettmp.Activate;

  commandline := sdb_commandline_num(sheettmp);
  sheettmp.rows.item[commandline + 1, EmptyParam].rowheight := 15.75;
  currentline := commandline + 2;

  if commandline < 1 then
  begin
    showmessage('�ļ���[�󶨱�]�в��Ƿ��Ϲ���ı�񣬲��ܽ��в�����' +
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
        if Pos('��', km[i, 3]) > 0 then
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
        else if Pos('��', km[i, 3]) > 0 then
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
        if Pos('��', km[i, 3]) > 0 then
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
        else if Pos('��', km[i, 3]) > 0 then
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
          '������Ӧ����ϸ���񣬲��ܽ��д���');
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
      if Pos('��ϸ��', msheet.name) > 0 then
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
    //����ϸ���е������н���ѭ�� ��������ڳ��������ڳ����������ơ�
  begin
    str := sheettmp.cells.item[commandline, j].value;

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

  //   ȡ�ñ�־�е������е�����
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
    //����ϸ���е������н���ѭ�� ��������ڳ��������ڳ����������ơ�
  begin
    str := csheet.cells.item[commandline, j].value;
    if Pos('��Ŀ���', str) > 0 then
      aMXB_COLUMN.KMDM := j
    else if Pos('��Ŀ����', str) > 0 then
      aMXB_COLUMN.KMNAME := j
    else if Pos('����', str) > 0 then
      aMXB_COLUMN.kmdirect := j
    else if (Pos('���ڳ�', str) > 0) then
      aMXB_COLUMN.SDQC := j
    else if (Pos('δ���ڳ�', str) > 0) then
      aMXB_COLUMN.QC := j
    else if (Pos('�󶨷���', str) > 0) then
      aMXB_COLUMN.FS := j
    else if (Pos('δ����', str) > 0) then
      aMXB_COLUMN.SDFS := j
    else if (Pos('����跽', str) > 0) or (Pos('δ��跽����', str) > 0) then
      aMXB_COLUMN.JFFS := j
    else if (Pos('�������', str) > 0) or (Pos('δ���������', str) > 0) then
      aMXB_COLUMN.DFFS := j
    else if Pos('δ����ĩ', str) > 0 then
      aMXB_COLUMN.QM := j
    else if (Pos('����ĩ', str) > 0) then
      aMXB_COLUMN.SDQM := j
    else if Pos('��ĩ�����跽', str) > 0 then
      aMXB_COLUMN.qmtzjf := j
    else if Pos('��ĩ��������', str) > 0 then
      aMXB_COLUMN.qmtzdf := j
    else if Pos('��ĩ�ط���跽', str) > 0 then
      aMXB_COLUMN.qmcfljf := j
    else if Pos('��ĩ�ط������', str) > 0 then
      aMXB_COLUMN.qmcfldf := j;
  end;
  result := aMXB_COLUMN;

end;

function auditdg.GET_XMINFO: XMINFO;
begin
  //
  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('SELECT * FROM �׸嵥λ');
  qrytmp.SQL.Add(' WHERE  xmid=''' + trim(xmid) + '''');
  qrytmp.Open;
  if qrytmp.RecordCount > 0 then
  begin
    Result.dwmc := qrytmp.fieldbyname('dwmc').AsString;
    Result.startrq := qrytmp.fieldbyname('startrq').AsDateTime;
    Result.endrq := qrytmp.fieldbyname('endrq').AsDateTime;
    Result.yeard := qrytmp.fieldbyname('��ֹʱ��').AsString;
    Result.editor := qrytmp.fieldbyname('������').AsString;
    Result.editrq := qrytmp.fieldbyname('��������').AsDateTime;
    Result.checkor := qrytmp.fieldbyname('�����').AsString;
    Result.checkRQ := qrytmp.fieldbyname('�������').AsDateTime;
    Result.xmpath := qrytmp.fieldbyname('path').AsString;
    TARGETPATH := qrytmp.fieldbyname('path').AsString;
    try
      if not DirectoryExists(TARGETPATH) then
        forceDirectories(TARGETPATH);
    except
      //      showmessage('������ļ���λ������');
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
  sheetreplace(ABK, sorder, '��λ��λ��λ��λ��λ��λ��λ��', axm.dwmc);
  sheetreplace(ABK, sorder, 'lxylxy  ', axm.editor);
  sheetreplace(ABK, sorder, '1999-10-10', DateToStr(axm.editrq));
  sheetreplace(ABK, sorder, '1999/10/10', DateToStr(axm.editrq));
  sheetreplace(ABK, sorder, 'abcabc  ', axm.checkor);
  sheetreplace(ABK, sorder, '1999-11-11', DateToStr(axm.checkRQ));
  sheetreplace(ABK, sorder, '1999/11/11', DateToStr(axm.checkRQ));
  sheetreplace(ABK, sorder, '1997��12��31��', DateToStr(axm.editrq));
  sheetreplace(ABK, sorder, '1997��01�¡�1997��12��', axm.yeard);
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
  result := inttostr(secondcount div 60) + '����' + inttostr(secondcount mod 60)
    + '��';
end;

function auditdg.getinfo: XMINFO;
begin
  //
  qrytmp.Close;
  qrytmp.sql.Clear;
  qrytmp.SQL.add('select * from �׸嵥λ');
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
  qrytmp.SQL.add('select * from �׸嵥λ');
  qrytmp.SQL.Add(' WHERE  xmid=''' + trim(xmid) + '''');
  qrytmp.open;

  if qrytmp.RecordCount > 0 then
  begin
    qrytmp.Close;
    qrytmp.sql.Clear;
    qrytmp.SQL.add('update  �׸嵥λ set 	dwmc=:dwmc ,	startrq=	:startrq,endrq=:endrq,');
    qrytmp.SQL.add('	��ֹʱ��=:yeard ,	������=:editor,	�����=:checkor,	�������� =:editrq,	�������=:checkrq');
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
    qrytmp.SQL.add('insert into �׸嵥λ (	dwmc,	startrq,endrq,	��ֹʱ�� ,	������,	�����,	�������� ,	�������) values(');
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
  if (Trim(STR) = '��') then
    RESULT := '��'
  else if Trim(STR) = '��' then
    result := '��';

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
 //  =SUMIF(D8:D9,"��",G8:G9)
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
    ShowMessage('�����ļ���·��δ���ã�����롾���е׸��ͷ��Ϣ���н������á�');
    exit;
  end;
  qrylist := TADOQuery.Create(nil);
  qrylist.Connection := self.con;
  qrylist.Close;
  qrylist.SQL.Add('select  TOP 4 MIN(�׸�����) AS �׸�����,min(�������) as �������  from ��Ŀ��Ӧ��ϵ ');
  qrylist.SQL.Add(' where  (not �׸����� is null) AND  xmid=''' +
    trim(xmid) + ''' group by �׸�����  ');

  qrylist.Open;
  i := 1;

  while (not qrylist.Eof) and (i <= 4) do
  begin
    dgname := qrylist.fieldbyname('�׸�����').AsString;
    create_sdb(dgname, qrylist.fieldbyname('�������').AsString);
    qrylist.next;
    inc(i);
  end;
  fxlsapp.DISPLAYALERTS := false;
  SHOWMESSAGE('δע��汾����ֻ����ʾ���޵ļ���������Ŀ�ĵ׸壡' + chr(13) + 'ע������ϵ QQ:179930269');
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
    ShowMessage('�����ļ���·��δ���ã�����롾���е׸��ͷ��Ϣ���н������á�');
    exit;
  end;
  qrylist := TADOQuery.Create(nil);
  qrylist.Connection := self.con;
  qrylist.Close;
  qrylist.SQL.Add('select TOP 4  MIN(�׸�����) AS �׸�����,min(�������) as �������  from ��Ŀ��Ӧ��ϵ ');
  qrylist.SQL.Add(' where  (not �׸����� is null) AND  xmid=''' +
    trim(xmid) + ''' group by �׸�����  ');

  qrylist.Open;
  i := 1;

  while (not qrylist.Eof) and (i <= 4) do
  begin
    dgname := qrylist.fieldbyname('�׸�����').AsString;
    create_sdb(dgname, qrylist.fieldbyname('�������').AsString);
    qrylist.next;
    inc(i);
  end;
  fxlsapp.DISPLAYALERTS := false;
  SHOWMESSAGE('δע��汾����ֻ����ʾ���޵ļ���������Ŀ�ĵ׸壡' + chr(13) + 'ע������ϵ QQ:179930269');
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
    ShowMessage('�����ļ���·��δ���ã�����롾���е׸��ͷ��Ϣ���н������á�');
    exit;
  end;
  qrylist := TADOQuery.Create(nil);
  qrylist.Connection := self.con;
  qrylist.Close;
  qrylist.SQL.Add('select  MIN(�׸�����) AS �׸�����,min(�������) as �������  from ��Ŀ��Ӧ��ϵ ');
  qrylist.SQL.Add(' where  (not �׸����� is null) AND  xmid=''' +
    trim(xmid) + ''' group by �׸�����  ');

  qrylist.Open;
  while not qrylist.Eof do
  begin
    dgname := qrylist.fieldbyname('�׸�����').AsString;
    create_sdb(dgname, qrylist.fieldbyname('�������').AsString);
    qrylist.next;
  end;

  fxlsapp.DISPLAYALERTS := false;
  SHOWMESSAGE('���ɵ׸��ܷ�ʱ��' + spendtime(sj1));
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
    ShowMessage('�����ļ���·��δ���ã�����롾���е׸��ͷ��Ϣ���н������á�');
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

  sheettmp.cells[1, 1] := '����';
  sheettmp.cells[1, 2] := '��';
  sheettmp.cells[1, 3] := '��';
  sheettmp.cells[1, 4] := 'ƾ֤����';
  sheettmp.cells[1, 5] := 'ƾ֤��';
  sheettmp.cells[1, 6] := 'ժҪ';
  sheettmp.cells[1, 7] := '��Ŀ����';
  sheettmp.cells[1, 8] := '��Ŀ����';
  sheettmp.cells[1, 9] := '�跽';
  sheettmp.cells[1, 10] := '����';
  sheettmp.cells[1, 11] := '�Է���Ŀ';
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
    ShowMessage('����������ޡ�ƾ֤����');
    exit;
  end;

  if Trim(XMID) = '' then
  begin
    ShowMessage('���ȴ���Ŀ���ٵ���ƾ֤��');
    exit;

  end;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('delete from ƾ֤��  where xmid=''' + trim(xmid) + '''');
  qrytmp.ExecSQL;
  qrytmp.close;
  sheettmp := fxlsapp.activeworkbook.sheets.item[PZsheet];
  sheettmp.select;

  rowscount := sheettmp.usedrange.rows.count;
  colscount := sheettmp.usedrange.columns.count;

  if tabletmp.Active then
    tabletmp.Close;
  tabletmp.TableName := 'ƾ֤��';
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

      //����	��	��	ƾ֤��	ժҪ	��Ŀ����	��Ŀ����	 �跽 	 ���� 	�Է���Ŀ

      try
        tabletmp.FieldByName('xmid').AsString := xmid;
      except
      end;

      try
        tabletmp.FieldByName('����').AsString := varrykm[i, 1];
      except
      end;
      try
        tabletmp.FieldByName('���').AsString := varrykm[i, 2];
      except
      end;

      try
        tabletmp.FieldByName('�·�').AsString := varrykm[i, 3];
      except
      end;

      try
        tabletmp.FieldByName('ƾ֤����').AsString := varrykm[i, 4];
      except
      end;
      try
        tabletmp.FieldByName('ƾ֤���').AsString := varrykm[i, 5];
      except
      end;
      try
        tabletmp.FieldByName('ժҪ').AsString := varrykm[i, 6];
      except
      end;

      try
        tabletmp.FieldByName('��Ŀ����').AsString := varrykm[i, 7];
      except
      end;

      try
        tabletmp.FieldByName('��Ŀ����').AsString := varrykm[i, 8];
      except
      end;

      try
        tabletmp.FieldByName('�跽').asfloat := varrykm[i, 9];
      except
      end;
      try
        tabletmp.FieldByName('����').asfloat := varrykm[i, 10];
      except

      end;

      try
        tabletmp.FieldByName('�Է���Ŀ').AsString := varrykm[i, 11];
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
  qrytmp.SQL.Add('delete from  ƾ֤�� where  trim(XMID)=''' + XMID + '''');
  qrytmp.ExecSQL;
  qrytmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('delete from  ƾ֤�� where  xmid is null');
  qrytmp.ExecSQL;
  qrytmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('delete from  ��Ŀƾ֤�� where  trim(XMID)=''' + XMID + '''');
  qrytmp.ExecSQL;
  qrytmp.close;

  sqltext :=
    'INSERT INTO  dg7 (���� ,��Ŀ����,�������,�ڳ� ,�跽����,��������,��ĩ)' + //prd_no, SPC, UT, DFU_UT, KND, IDX1, NAME, SUP1
  ' SELECT' +
    ' ��Ŀ���,��Ŀ����,�������,�����ڳ���,����跽������,�������������,������ĩ��' +
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
    'INSERT INTO  dg7 (����,��Ŀ����,������Ŀ����,������Ŀ���� ,������Ŀ����,�������,�ڳ� ,�跽����,��������,��ĩ)' +
    ' SELECT' +
    ' ��Ŀ���,"    "+��Ŀ����,������Ŀ��������,������Ŀ���,������Ŀ����,�������,�����ڳ���,����跽������,�������������,������ĩ�� ' +
    ' FROM [excel 8.0;database=' + fxlsapp.ACTIVEWORKBOOK.fullname + '].[dxnxmyeb$]';

  qrytmp.Close;
  qrytmp.Parameters.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(sqltext);
  qrytmp.ExecSQL;
  qrytmp.close;

  sqltext :=
    'INSERT INTO  ƾ֤�� (ȫƾ֤��, ���, �·�, ƾ֤����, ƾ֤���,�ڱ��, ��Ŀ����, ��Ŀ����, ժҪ, �跽, ����,�Է���Ŀ)' +
    ' SELECT' +
    ' ����ʱ��,�����,�����, ƾ֤���� ,ƾ֤���,���,��Ŀ���, ��Ŀ����,ҵ��˵��  ,�跽������ ,����������,�Է���Ŀ���� ' +
    ' FROM [excel 8.0;database=' + fxlsapp.ACTIVEWORKBOOK.fullname + '].[dxnpzb$]';

  qrytmp.Close;
  qrytmp.Parameters.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(sqltext);
  qrytmp.ExecSQL;
  qrytmp.close;

  sqltext :=
    'INSERT INTO  ��Ŀƾ֤��(ȫƾ֤��,  �·�, ƾ֤����, ƾ֤���,�ڱ��, ��Ŀ����, ��Ŀ����, ժҪ, �跽, ����,��Ŀ��������,��Ŀ�������,��Ŀ��������,�Է���Ŀ)' +
    ' SELECT' +
    '  ����ʱ��,�����, ƾ֤���� ,ƾ֤���,���,��Ŀ���, ��Ŀ����,ҵ��˵��,�跽������ ,����������,������Ŀ���ͱ��,������ĿID,������Ŀ����,�Է���Ŀ���� '
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
  qrytmp.SQL.Add('UPDATE DG7 SET  һ����Ŀ����=left(����,4) WHERE XMID is NULL');
  qrytmp.ExecSQL;
  qrytmp.close;

  // ȫƾ֤��

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('UPDATE DG7 SET  XMID=''' + XMID + '''' + ' WHERE XMID is NULL');
  qrytmp.ExecSQL;
  qrytmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('UPDATE ��Ŀƾ֤�� SET ��� =val(left(trim(ȫƾ֤��),4)) WHERE XMID is NULL and TRIM(ȫƾ֤��)<>""');
  qrytmp.ExecSQL;
  qrytmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('UPDATE ��Ŀƾ֤�� SET �·� =val(mid(trim(ȫƾ֤��),5,2)) WHERE XMID is NULL and TRIM(ȫƾ֤��)<>"" ');
  qrytmp.ExecSQL;
  qrytmp.close;

  try
    qrytmp.Close;
    qrytmp.SQL.Clear;
    qrytmp.ParamCheck := false;
    qrytmp.SQL.Add('UPDATE ��Ŀƾ֤��  SET ���� =DateSerial(���,�·�,1) WHERE XMID is NULL  ');
    qrytmp.ExecSQL;
    qrytmp.close;
  except
  end;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('UPDATE ��Ŀƾ֤�� SET ȫƾ֤�� =str(���)+"_"+str(�·�)+"_"+left(ƾ֤����,2)+ƾ֤��� WHERE XMID is NULL');
  qrytmp.ExecSQL;
  qrytmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('UPDATE ��Ŀƾ֤�� SET  XMID=''' + XMID + '''' + ' WHERE XMID is NULL');
  qrytmp.ExecSQL;
  qrytmp.close;

  ///==============��Ŀƾ֤�����

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('UPDATE ƾ֤�� SET ��� =val(mid(trim(ȫƾ֤��),1,4)) WHERE (XMID is NULL) ');
  qrytmp.ExecSQL;
  qrytmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('UPDATE ƾ֤�� SET �·� =val(mid(trim(ȫƾ֤��),5,2)) WHERE XMID is NULL ');
  qrytmp.ExecSQL;
  qrytmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('UPDATE ƾ֤�� SET ���� =DateSerial(���,�·�,1) WHERE XMID is NULL  and ( ���� is null)');
  qrytmp.ExecSQL;
  qrytmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('UPDATE ƾ֤�� SET ȫƾ֤�� =str(���)+"_"+str(�·�)+"_"+left(ƾ֤����,2)+ƾ֤��� WHERE XMID is NULL');
  qrytmp.ExecSQL;
  qrytmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update  dg7  set һ����Ŀ����=left(����,' + zdlength + ')');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update  ƾ֤��  set һ������=left(��Ŀ����,' + zdlength + ')');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update  ƾ֤��  set  ���=year(����)  where XMID is NULL  and (���=0 or ��� is null)');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update  ƾ֤��  set  �·�=month(����) where XMID is NULL  and (���=0 or ��� is null)');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update  ƾ֤��  set  �跽=0 where �跽  is null');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update  ƾ֤��  set  ����=0 where ����  is null');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.ParamCheck := false;
  qrytmp.SQL.Add('UPDATE ƾ֤�� SET  XMID=''' + XMID + '''' + ' WHERE XMID is NULL');
  qrytmp.ExecSQL;
  qrytmp.close;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update  ƾ֤��  set  ȫƾ֤��=str(���)+"_"+str(�·�)+"_"+left(ƾ֤����,2)+ƾ֤���');
  qrytmp.ExecSQL;

  qrytmp.Close;
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('delete from  dg7  where  not (������Ŀ���� is null) ');
  qrytmp.SQL.Add('   and �ڳ�=0 and ��ĩ=0 and �跽����=0 and ��������=0 and xmid=''' + trim(xmid) + '''');
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

    if asheet.cells.Item[1, ncolumn].TEXT = '����ʱ��' then
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

