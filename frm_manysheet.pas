unit frm_manysheet;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, umb, ExtCtrls, StdCtrls, CheckLst, Buttons, adxAddIn, Clipbrd,
  ushare,
  vbide2000, StrUtils,
  excel2000
  ;

type
  Tfmmanysheet = class(Tfm_mb)
    CheckListBox1: TCheckListBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    BitBtn8: TBitBtn;
    SaveDialog1: TSaveDialog;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    OpenDialog1: TOpenDialog;
    Button5: TButton;
    Button6: TButton;
    btn1: TButton;
    btn2: TButton;
    edt1: TEdit;
    procedure BitBtn7Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn8Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure CheckListBox1DblClick(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure edt1KeyPress(Sender: TObject; var Key: Char);

  private
    xlsapp: excel2000.TExcelApplication;
    ftype: Integer;
    procedure setbook(const Value: excel2000._Application);
    procedure setlist;
    procedure settype(const Value: Integer);
    { Private declarations }
  public
    { Public declarations }
  published
    property aworkbook: excel2000._Application write setbook;
    property cztype: Integer read ftype write settype;
  end;

var
  fmmanysheet: Tfmmanysheet;

implementation

uses communit;

{$R *.dfm}

procedure Tfmmanysheet.setbook(const Value: excel2000._Application);
begin

  xlsapp := TExcelApplication.Create(nil);
  xlsapp.ConnectTo(Value);

end;

procedure Tfmmanysheet.setlist;
var
  i: integer;
  asheet: ExcelWorksheet;
begin
  if xlsapp.Workbooks.Count < 1 then
    exit;

  try
    CheckListBox1.Clear;
    for i := 1 to xlsapp.ActiveWorkbook.Sheets.Count do
    begin
      asheet := _Worksheet(xlsapp.ActiveWorkbook.Worksheets[i]);
      CheckListBox1.Items.Add(asheet.name);
    end;
  except
  end;

end;

procedure Tfmmanysheet.BitBtn7Click(Sender: TObject);
var
  i: Integer;
begin
  inherited;

  for i := 0 to CheckListBox1.Items.Count - 1 do
  begin
    CheckListBox1.Checked[i] := True;
  end;
end;

procedure Tfmmanysheet.FormActivate(Sender: TObject);
begin
  inherited;
  if xlsapp.Workbooks.Count < 1 then
    exit;

  setlist;
end;

procedure Tfmmanysheet.BitBtn1Click(Sender: TObject);
var
  i: integer;
  asheet: ExcelWorksheet;
begin
  inherited;
  for i := 1 to xlsapp.ActiveWorkbook.Sheets.Count do
  begin
    asheet := _Worksheet(xlsapp.ActiveWorkbook.Worksheets[i]);

    if asheet.Visible[adxLCID] <> xlSheetVisible then
      asheet.Visible[adxLCID] := xlSheetVisible;

    if CheckListBox1.Checked[i - 1] then
      asheet.Select(False, adxLCID);
  end;

  xlsapp.ActiveWindow.SelectedSheets.PrintOut(EmptyParam, EmptyParam,
    EmptyParam, false,
    true, false, EmptyParam, EmptyParam, 0);
  mymessage('后台打印完毕！');
  close;
end;

procedure Tfmmanysheet.BitBtn8Click(Sender: TObject);
var
  i: Integer;
begin
  inherited;

  for i := 0 to CheckListBox1.Items.Count - 1 do
  begin
    CheckListBox1.Checked[i] := false;
  end;
end;

procedure Tfmmanysheet.BitBtn3Click(Sender: TObject);
var
  i: integer;
  asheet: ExcelWorksheet;
begin
  inherited;
  try
    for i := 1 to xlsapp.ActiveWorkbook.Sheets.Count do
    begin
      asheet := _Worksheet(xlsapp.ActiveWorkbook.Worksheets[i]);
      if CheckListBox1.Checked[i - 1] then
        asheet.Visible[0] := xlSheetHidden;
    end;
  except
  end;
end;

procedure Tfmmanysheet.BitBtn4Click(Sender: TObject);
var
  i: integer;
  asheet: ExcelWorksheet;
begin
  inherited;
  try
    for i := 1 to xlsapp.ActiveWorkbook.Sheets.Count do
    begin
      asheet := _Worksheet(xlsapp.ActiveWorkbook.Worksheets[i]);
      if CheckListBox1.Checked[i - 1] then
        asheet.Visible[0] := xlSheetVisible;
    end;
  except
  end;
end;

procedure Tfmmanysheet.CheckListBox1DblClick(Sender: TObject);
begin
  inherited;
  CheckListBox1.Checked[CheckListBox1.ItemIndex] := true;
end;

procedure Tfmmanysheet.BitBtn5Click(Sender: TObject);
var
  i: integer;
  asheet: ExcelWorksheet;
begin
  inherited;
  case MessageDlg('确定要删除选定的文件吗，按确定将开始删除？' + #13#10,
    mtConfirmation, mbOKCancel, 0) of
    mrOk:
      begin

      end;
    mrCancel:
      begin
        exit;
      end;
  end;

  xlsapp.DisplayAlerts[adxLCID] := False;
  try
    for i := xlsapp.ActiveWorkbook.Sheets.Count downto 1 do
    begin
      asheet := _Worksheet(xlsapp.ActiveWorkbook.Worksheets[i]);
      if CheckListBox1.Checked[i - 1] then
        asheet.Delete(0);
    end;
  except
  end;

  CheckListBox1.Clear;
  for i := 1 to xlsapp.ActiveWorkbook.Sheets.Count do
  begin
    asheet := _Worksheet(xlsapp.ActiveWorkbook.Worksheets[i]);
    CheckListBox1.Items.Add(asheet.name);
  end;

  xlsapp.DisplayAlerts[adxLCID] := true;
end;

procedure Tfmmanysheet.BitBtn2Click(Sender: TObject);
var
  i: integer;
  asheet: ExcelWorksheet;
  hiddenbz: Boolean;
  sheetnames: array of string;
begin
  inherited;
  for i := 1 to xlsapp.ActiveWorkbook.Sheets.Count do
  begin
    asheet := _Worksheet(xlsapp.ActiveWorkbook.Worksheets[i]);
    if CheckListBox1.Checked[i - 1] then
    begin
      hiddenbz := False;
      if asheet.Visible[adxLCID] <> xlSheetVisible then
      begin

        asheet.Visible[adxLCID] := xlSheetVisible;
        hiddenbz := True;
      end;

      asheet.Select(False, adxlcid); //增加到表的选区中
      asheet.activate(adxLCID);

      printasheet(asheet);

    end;

  end;
  xlsapp.ShowToolTips := TRUE;

  xlsapp.ActiveWindow.SelectedSheets.PrintOut(EmptyParam, EmptyParam,
    EmptyParam, false,
    true, false, EmptyParam, EmptyParam, 0);

  mymessage('后台打印完毕！');
  close;
end;

procedure Tfmmanysheet.BitBtn6Click(Sender: TObject);
var
  afilename: string;
  xbook, ybook: _Workbook;
  asheet: _Worksheet;
  i: Integer;
begin
  //当前表另存为文件

  SaveDialog1.Filter := '*.xlsx|*.xlsx';
  SaveDialog1.InitialDir := ExtractFilePath(xlsapp.ActiveWorkbook.Name);
  if SaveDialog1.Execute then
    afilename := savedialog1.filename;

  if Trim(afilename) = '' then
    exit;

  if Pos('.', afilename) < 1 then
    afilename := afilename + '.xlsx';

  xbook := xlsapp.ActiveWorkbook;
  ybook := xlsapp.Workbooks.Add(EmptyParam, adxLCID);

  for i := 0 to checklistbox1.Count - 1 do
  begin
    if CheckListBox1.Checked[i] then
    begin
      xbook.Activate(adxLCID);
      _worksheet(xbook.Sheets.Item[CheckListBox1.Items[i]]).Activate(adxlcid);
      _worksheet(xlsapp.ActiveCell.Worksheet).Cells.select;
      excelrange(xlsapp.ActiveWindow.Selection).Copy(EmptyParam);

      ybook.Activate(adxlcid);
      asheet := _Worksheet(xlsapp.ActiveWorkbook.Sheets.Add(EmptyParam,
        EmptyParam, 1, xlWorksheet, 0));
      asheet.Name := CheckListBox1.Items[i];
      asheet.cells.Select;
      excel2000.ExcelRange(xlsapp.ActiveWindow.Selection).PasteSpecial(xlPasteAll, xlNone, False, False);

    end;
  end;

  xlsapp.ActiveWorkbook.SaveAs(afilename, EmptyParam, EmptyParam, EmptyParam,
    EmptyParam, EmptyParam,
    xlExclusive, EmptyParam, EmptyParam, EmptyParam, EmptyParam, adxLCID);

  close;
end;

procedure Tfmmanysheet.Button1Click(Sender: TObject);
var
  i, j, k: integer;
  asheet: ExcelWorksheet;
  irowcount, icolcount: integer;
begin
  inherited;
  case MessageDlg('确定要继续将所选表格内的所有公式转化为值吗》',
    mtConfirmation, mbOKCancel, 0) of
    mrOk:
      begin

      end;
    mrCancel:
      begin
        exit;
      end;
  end;

  for k := 1 to xlsapp.ActiveWorkbook.Sheets.Count do
  begin

    asheet := _Worksheet(xlsapp.ActiveWorkbook.Worksheets[k]);
    irowcount := asheet.UsedRange[adxLCID].Rows.Count;
    icolcount := asheet.UsedRange[adxlcid].Columns.Count;

    if CheckListBox1.Checked[k - 1] then
    begin
      //      asheet.PrintOut(EmptyParam, EmptyParam, EmptyParam, false,
      //        true, false, EmptyParam, EmptyParam, 0);

      for i := 1 to Irowcount do
        for j := 1 to icolcount do
        begin
          if (ASHEET.Cells.Item[i, j].hasformula) then
          begin
            ASHEET.Cells.Item[i, j].value := ASHEET.Cells.Item[i, j].value;
          end;
        end;
    end;
  end;
  mymessage('所选文件中所有公式已全部转化为值了');
  close;
end;

procedure Tfmmanysheet.Button2Click(Sender: TObject);
var
  i, j, k: integer;
  asheet: ExcelWorksheet;
  irowcount, icolcount: integer;
begin
  inherited;
  case MessageDlg('确定要继续将所选表格内的所有公式转化为值吗》',
    mtConfirmation, mbOKCancel, 0) of
    mrOk:
      begin

      end;
    mrCancel:
      begin
        exit;
      end;
  end;
  for k := 1 to xlsapp.ActiveWorkbook.Sheets.Count do
  begin

    asheet := _Worksheet(xlsapp.ActiveWorkbook.Worksheets[k]);
    irowcount := asheet.UsedRange[adxLCID].Rows.Count;
    icolcount := asheet.UsedRange[adxlcid].Columns.Count;

    if CheckListBox1.Checked[k - 1] then
    begin
      //      asheet.PrintOut(EmptyParam, EmptyParam, EmptyParam, false,
      //        true, false, EmptyParam, EmptyParam, 0);

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
  end;
  mymessage('所选文件中的所有含表外链接的公式已全部转化为值了');
  close;
end;

procedure Tfmmanysheet.Button3Click(Sender: TObject);
var
  i: integer;
  asheet: ExcelWorksheet;
begin
  inherited;
  for i := 1 to xlsapp.ActiveWorkbook.Sheets.Count do
  begin
    asheet := _Worksheet(xlsapp.ActiveWorkbook.Worksheets[i]);
    if asheet.Visible[adxLCID] = xlSheetVisible then
    begin
      asheet.Activate(adxlcid);
      printasheet(asheet);
    end;

  end;

  for i := 1 to xlsapp.ActiveWorkbook.Sheets.Count do
  begin
    asheet := _Worksheet(xlsapp.ActiveWorkbook.Worksheets[i]);
    if asheet.Visible[adxLCID] = xlSheetVisible then
    begin
      asheet.Select(False, adxLCID);
    end;

  end;

  xlsapp.ActiveWindow.SelectedSheets.PrintOut(EmptyParam, EmptyParam,
    EmptyParam, false,
    true, false, EmptyParam, EmptyParam, 0);
  Hide;
  mymessage('后台打印完毕！');
  close;
end;

procedure Tfmmanysheet.Button4Click(Sender: TObject);
var
  i, j: integer;
  asheet: ExcelWorksheet;
  xbook: _Workbook;
begin
  inherited;
  xlsapp.DisplayAlerts[adxLCID] := False;
  OpenDialog1.Filter := '*.xls|*.xlsx;*.xls;*.xlsm';
  OpenDialog1.Execute;
  if OpenDialog1.Files.count > 0 then
  begin
    for j := 0 to OpenDialog1.Files.Count - 1 do
    begin
      // mymessage(OpenDialog1.files.names[j]);
      xbook := xlsapp.Workbooks.Open(OpenDialog1.Files[j]
        , EmptyParam, EmptyParam, EmptyParam, EmptyParam,
        EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
        EmptyParam, EmptyParam, EmptyParam, adxLCID
        );

      xbook.Activate(adxLCID);
      for i := 1 to xlsapp.ActiveWorkbook.Sheets.Count do
      begin
        asheet := _Worksheet(xlsapp.ActiveWorkbook.Worksheets[i]);
        if asheet.Visible[adxLCID] = xlSheetVisible then
        begin
          asheet.Activate(adxlcid);
          printasheet(asheet);
        end;
      end;

      xbook.Close(False, EmptyParam, EmptyParam, adxlcid);
    end;
  end;

  xlsapp.DisplayAlerts[adxLCID] := true;
  mymessage('后台打印完毕！');
  close;
end;

procedure Tfmmanysheet.Button5Click(Sender: TObject);
var
  i: integer;
  asheet, bsheet: ExcelWorksheet;
  afilename, bfilename: string;
  pos1: Integer;
  abook: _Workbook;
  ROWS, COLS: INTEGER;

  allrec: integer;
begin
  inherited;

  //当前表另存为文件
  abook := xlsapp.ActiveWorkbook;
  afilename := xlsapp.ActiveWorkbook.FullName[adxlcid];
  pos1 := Pos('.', afilename);
  afilename := Copy(afilename, 1, pos1 - 1) + '_合并.xlsx';

  if FileExists(afilename) then
  begin
    bfilename := extractfilename(afilename);
    bfilename := StringReplace(bfilename, '.xlsx',
      FormatDateTime('yyyymmdd_hhmmss', now()) + '.xlsx', []);
    RenameFile(afilename, bfilename);
  end;

  xlsapp.Workbooks.Add(EmptyParam, adxLCID);
  bsheet := _worksheet(xlsapp.ActiveCell.Worksheet);

  allrec := 1;

  for i := 1 to abook.Sheets.Count do
  begin
    asheet := _Worksheet(abook.Worksheets[i]);
    if CheckListBox1.Checked[i - 1] then
      if asheet.Visible[adxLCID] = xlSheetVisible then
      begin
        try
          asheet.Activate(adxlcid);
          asheet.cells.select;
          asheet.cells.UnMerge;
          //  excelrange(xlsapp.ActiveWindow.Selection).Copy(EmptyParam);
          ROWS :=
            asheet.UsedRange[adxLCID].ROWS.ITEM[asheet.UsedRange[adxLCID].ROWS.Count, EmptyParam].Row;
          COLS :=
            asheet.UsedRange[adxLCID].Columns.ITEM[asheet.UsedRange[adxLCID].Columns.Count, EmptyParam].Column;
          asheet.Range[asheet.Cells.Item[1, 1], asheet.Cells.ITEM[ROWS,
            COLS]].Select;
          // //    asheet.usedrange[0]
          excelrange(xlsapp.ActiveWindow.Selection).copy(bsheet.range['b' +
            trim(inttostr(allrec)),
              emptyparam]);
          bsheet.range['a' + trim(inttostr(allrec)), 'a' + trim(inttostr(allrec
            + asheet.usedrange[0].rows.count - 1))].value := asheet.Name;
          allrec := allrec + asheet.usedrange[0].rows.count;
        except
        end;
      end;
  end;
  bsheet.Activate(adxlcid);
  xlsapp.ActiveWorkbook.SaveAs(afilename, EmptyParam, EmptyParam, EmptyParam,
    EmptyParam, EmptyParam,
    xlExclusive, EmptyParam, EmptyParam, EmptyParam, EmptyParam, adxLCID);

  Hide;
  mymessage('表格合并完毕！');
  close;

end;

//==============================================================================
// 将选定的多个XLS文件合并一个XLS文件
//==============================================================================

procedure Tfmmanysheet.Button6Click(Sender: TObject);
var
  i, j: integer;
  asheet, bsheet: ExcelWorksheet;
  afilename: string;
  xbook, ybook: _Workbook;
  ASTR: string;

begin
  inherited;
  xlsapp.DisplayAlerts[adxLCID] := false;
  OpenDialog1.Filter := '*.xls|*.xlsx;*.xls;*.xlsm';
  OpenDialog1.Execute;
  ybook := xlsapp.Workbooks.Add(EmptyParam, adxLCID);

  if OpenDialog1.Files.count > 0 then
  begin
    for j := 0 to OpenDialog1.Files.Count - 1 do
    begin
      xbook := xlsapp.Workbooks.Open(OpenDialog1.Files[j]
        , EmptyParam, EmptyParam, EmptyParam, EmptyParam,
        EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
        EmptyParam, EmptyParam, EmptyParam, adxLCID,
        );

      xbook.Activate(adxLCID);

      for i := 1 to xbook.Sheets.Count do
      begin
        xbook.Activate(adxLCID);
        asheet := _Worksheet(xbook.Worksheets[i]);

        if asheet.Visible[adxLCID] = xlSheetVisible then
        begin
          try
            ybook.Activate(adxLCID);
            bsheet := _Worksheet(ybook.Sheets.add(EmptyParam,
              _worksheet(ybook.Sheets.Item[ybook.Sheets.count]), 1, EmptyParam,
              adxLCID));
            try
              ASTR := StringReplace(XBOOK.NAME, '.xlsx', '', [rfreplaceall]);
              ASTR := StringReplace(ASTR, '.xls', '', [rfreplaceall]);
              ASTR := StringReplace(ASTR, ':', '', [rfreplaceall]);
              ASTR := StringReplace(ASTR, '。', '', [rfreplaceall]);
              ASTR := StringReplace(ASTR, '.', '', [rfreplaceall]);
              ASTR := StringReplace(ASTR, '，', '', [rfreplaceall]);
              ASTR := StringReplace(ASTR, '：', '', [rfreplaceall]);
              ASTr := leftstr(Trim(ASTR), 16) + '_' +
                leftstr(Trim(asheet.name), 6);
              bsheet.name := ASTR;
            except
            end;
            asheet.Cells.copy(EmptyParam);

            bsheet.Paste(EmptyParam, EmptyParam, adxLCID);
            Clipboard.Clear;
          except
          end;
        end;
      end;

      xbook.Close(False, EmptyParam, EmptyParam, adxlcid);
    end;
  end;

  afilename := '';
  SaveDialog1.Filter := '*.xlsx|*.xlsx;';
  SaveDialog1.Execute;

  afilename := SaveDialog1.FileName;
  if afilename <> '' then
  begin
    ybook.SaveAs(afilename, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam,
      xlExclusive, EmptyParam, EmptyParam, EmptyParam, EmptyParam, adxLCID);
  end;
  Hide;
  xlsapp.DisplayAlerts[adxLCID] := true;
  mymessage('多文件已合并为一个文件，完毕！');
  close;

end;

procedure Tfmmanysheet.settype(const Value: Integer);
begin
  ftype := Value;
  case ftype of
    1: //打印
      begin
        BitBtn7.Visible := true; //全选
        BitBtn8.Visible := true; //全不选

        BitBtn1.Visible := true;
        BitBtn2.Visible := true;
        Button3.Visible := true;
        Button4.Visible := true;

      end;
    2: //文件合并  表格合并
      begin
        BitBtn7.Visible := true; //全选
        BitBtn8.Visible := true; //全不选

        Button6.Visible := true;
        Button6.Left := BitBtn2.Left;
        Button6.Top := BitBtn2.Top;
      end;

    3: //批量操作
      begin
        BitBtn7.Visible := true; //全选
        BitBtn8.Visible := true; //全不选

        Button1.Visible := true;
        Button2.Visible := true;
        BitBtn3.Visible := true;
        BitBtn4.Visible := true;
        BitBtn5.Visible := true;
        BitBtn6.Visible := true;
      end;

    4: //表格合并
      begin
        BitBtn7.Visible := true; //全选
        BitBtn8.Visible := true; //全不选

        Button5.Visible := true;
        Button5.Left := BitBtn1.Left;
        Button5.Top := BitBtn1.Top;

      end;
  end;
end;

procedure Tfmmanysheet.FormCreate(Sender: TObject);
begin
  inherited;
  edt1.Clear;
  bitbtn1.Visible := False;
  bitbtn2.Visible := False;
  bitbtn3.Visible := False;
  bitbtn4.Visible := False;
  bitbtn5.Visible := False;
  bitbtn6.Visible := False;
  Button1.Visible := false;
  Button2.Visible := false;
  Button3.Visible := false;
  Button4.Visible := false;
  Button5.Visible := false;
  Button6.Visible := false;
  pnl1.Height := 73;
end;

procedure Tfmmanysheet.btn1Click(Sender: TObject);
var
  i, j: integer;
  asheet: ExcelWorksheet;
  xbook: _Workbook;
  v: _VBComponent;
  hascolor: Boolean;
  aname: string;
begin
  inherited;
  xlsapp.DisplayAlerts[adxLCID] := False;
  OpenDialog1.Filter := '*.xls|*.xlsx;*.xls;*.xlsm';
  OpenDialog1.Execute;

  xbook :=
    xlsapp.Workbooks.Open(mainpath + 'aa.xla'
    , EmptyParam, EmptyParam, EmptyParam, EmptyParam,
    EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
    EmptyParam, EmptyParam, EmptyParam, adxLCID
    );

  if OpenDialog1.Files.count > 0 then
  begin
    for j := 0 to OpenDialog1.Files.Count - 1 do
    begin
      xbook := xlsapp.Workbooks.Open(OpenDialog1.Files[j]
        , EmptyParam, EmptyParam, EmptyParam, EmptyParam,
        EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
        EmptyParam, EmptyParam, EmptyParam, adxLCID
        );

      xbook.Activate(adxLCID);
      for i := 1 to xlsapp.ActiveWorkbook.Sheets.Count do
      begin
        asheet := _Worksheet(xlsapp.ActiveWorkbook.Worksheets[i]);
        if (asheet.Visible[adxLCID] = xlSheetVisible) then
        begin
          hascolor := xlsapp.Run('aa.XLa!iscolorful', i);

          if hascolor then
          begin

            asheet.Activate(adxlcid);
            aname := asheet.Name;
            printasheet(asheet);
          end;
        end;
      end;
      xbook.Close(False, EmptyParam, EmptyParam, adxlcid);
    end;
  end;

  mymessage('后台打印完毕！');
  close;
end;

procedure Tfmmanysheet.btn2Click(Sender: TObject);
var
  i: Integer;
  xbook: _Workbook;
  v: _VBComponent;
  hascolor: Boolean;
begin
  inherited;

  xlsapp.DisplayAlerts[adxLCID] := False;

  xbook :=
    xlsapp.Workbooks.Open(mainpath + 'aa.xla'
    , EmptyParam, EmptyParam, EmptyParam, EmptyParam,
    EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
    EmptyParam, EmptyParam, EmptyParam, adxLCID
    );

  for i := 1 to CheckListBox1.Items.Count do
  begin
    hascolor := xlsapp.Run('aa.XLa!iscolorful', i);
    if hascolor then
      CheckListBox1.Checked[i - 1] := True;
  end;
end;

procedure Tfmmanysheet.edt1KeyPress(Sender: TObject; var Key: Char);
var
  i: Integer;
begin
  inherited;
  if Key = #13 then
  begin

    for i := 0 to CheckListBox1.Items.Count - 1 do
    begin
      if Pos(Trim(edt1.Text), CheckListBox1.Items[i]) > 0 then
        CheckListBox1.Checked[i] := True
      else
        CheckListBox1.Checked[i] := false;
    end;

  end;

end;

end.

