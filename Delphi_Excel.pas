{****************************************************
//
Description :
  把一个表或Query或StringGrid中的数据保存到一个Execl文件中
Function List :
  创建接口
  procedure CreateExcelInstance;
  把表内容放到Excel文件中
  procedure TableToExcel( const Table: TTable );
  把Query内容放到Excel文件中
  procedure QueryToExcel( const Query: TQuery );
  把StringGrid内容放到Excel文件中
  procedure StringGridToExcel( const StringGrid: TStringGrid );
  保存为Execl文件
  procedure SaveToExcel( const FileName: String);

调用实例如下：
  OLEExcel1.CreateExcelInstance;
  OLEExcel1.QuerytoExcel((CurRep.DataSet as TQuery));
  OLEExcel1.SaveToExcel(SaveDlg1.FileName);
****************************************************}
unit OleExcel;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  comobj, DBTables, Grids,OleCtnrs,OleServer,Excel2000,Variants;
type
  FileCheckResult = (fcrNotExistend,fcrNotXSLFile,fcrValidXSL); //文件不存在,不是XSL文件,合法的XSL文件
  TOLEExcel = class(TComponent)
  private
    FExcelCreated: Boolean;
    FVisible: Boolean;
    FExcel: Variant;      //Excel程序对象
    FWorkBook: Variant;   //Excel工作簿对象
    FWorkSheet: Variant;  //Excel工作簿 工作表对象
    FCellFont: TFont;     //单元格字体对象
    FTitleFont: TFont;    //
    FFontChanged: Boolean;
    FIgnoreFont: Boolean;
    FFileName: TFileName;

    //********************************************自己添加*****************************//
    FCreateFromFile:Boolean;  //指示是否打开已有文件
    FExcelCaption:string;     //用程序打开Excel的窗体标

    //*********************************来自U_Report*****************************//
    FRCPrePage:Integer; //每页显示的记录数
    FMax:Integer;       //最大的数组个数

    procedure SetExcelCellFont(var Cell: Variant);
    procedure SetExcelTitleFont(var Cell: Variant);
    procedure GetTableColumnName(const Table: TTable; var Cell: Variant);
    procedure GetQueryColumnName(const Query: TQuery; var Cell: Variant);
    procedure GetFixedCols(const StringGrid: TStringGrid; var Cell: Variant);
    procedure GetFixedRows(const StringGrid: TStringGrid; var Cell: Variant);
    procedure GetStringGridBody(const StringGrid: TStringGrid; var Cell: Variant);

  protected
    procedure SetCellFont(NewFont: TFont);
    procedure SetTitleFont(NewFont: TFont);
    procedure SetVisible(DoShow: Boolean);
    function GetCell( ARow,ACol: Integer): string;
    procedure SetCell(ACol, ARow: Integer; const Value: string);

    function GetDateCell(ACol, ARow: Integer): TDateTime;
    procedure SetDateCell(ACol, ARow: Integer; const Value: TDateTime);

    //*********************************************自己添加************************************//
    procedure SetCaption(ACaption:string);//设置打开文件后,Excel主程序的窗体标题
    function GetCapiton:string;//返回打开文件后,Excel主程序的窗体标题

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CreateExcelInstance;
    property Cell[ACol, ARow: Integer]: string read GetCell write SetCell;
    property DateCell[ACol, ARow: Integer]: TDateTime read GetDateCell write SetDateCell;
    function IsCreated: Boolean;
    procedure TableToExcel(const Table: TTable);
    procedure QueryToExcel(const Query: TQuery);
    procedure StringGridToExcel(const StringGrid: TStringGrid);
    procedure SaveToExcel(const FileName: string);

    //*********************************来自U_Report*****************************//
    function  GetRepRange(x,y:integer):String;//将(x,y)坐标形式改为Excel区域(A1:B1)形式
    procedure CellMerge(x1,y1,x2,y2:integer);//合并指定单元格
    procedure SetRepLine(x1,x2,y1,y2:Integer); //加边框线
    procedure CellWrite(RepData:String;x,y:Integer);//单元格写数据
    procedure CellFormat(x1,y1,x2,y2:integer);//指定单元格格式
    procedure CellGS(x1,y1,x2,y2,f:integer);//灵活单元格格式

    procedure CreatRepSheet(SheetName:String;PageSize,PageLay:Integer);//给当前工作表重命名、进行页面设置 
    procedure SetAddMess(H_Mess1,H_Mess2,H_Mess3,F_Mess1,F_Mess2,F_Mess3:String);//设置附加信息
    procedure SetRepBody(x,ch:Integer;cw:Double;cf:String);//设置整体各列数据格式
    procedure CreatTitle(TitleName:String;y:Integer);//设置标题
    procedure CreatSubHead(SubTitle:Array of String); //设置常规子表头
    procedure SubHeadFormat(y,r:Integer);//设置子表头格式
    procedure DTSubHeadGS(x,y,r:Integer);//设置动态子表头格式
    procedure WriteData(RepData:String;x,y:Integer;flag:Integer=0); //写入数据
    procedure RepPageBreak(x,y,r:Integer);//分页、复制表头
    procedure RepSaveAs(FileName:String); //保存为*.xls文
    procedure RepPrivew;//预览

    //*********************************************自己添加************************************//
    function FileCheck:FileCheckResult;//检查文件
    function GetRowCount:Integer;
  published
    property TitleFont: TFont read FTitleFont write SetTitleFont;
    property CellFont: TFont read FCellFont write SetCellFont;
    property Visible: Boolean read FVisible write SetVisible;
    property IgnoreFont: Boolean read FIgnoreFont write FIgnoreFont;
    property FileName: TFileName read FFileName write FFileName;
    //*********************************来自U_Report*****************************//
    property RCPrePage:Integer read FRCPrePage write FRCPrePage;
    property MaxAC:Integer  read FMax write FMax;


    //*********************************************自己添加************************************//
    property CreateFromFile:Boolean read FCreateFromFile write FCreateFromFile;
    property Caption:string read GetCapiton write SetCaption;
  end;

procedure Register;

implementation

constructor TOLEExcel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FIgnoreFont := True;
  FCellFont := TFont.Create;
  FTitleFont := TFont.Create;
  FExcelCreated := False;
  FVisible := False;//暂时不显示Excel窗体
  FCreateFromFile := False;//默认不是打开已有xls文件
  FFontChanged := False;
  FFileName := '';//默认文件名为空
end;

procedure TOLEExcel.CreateExcelInstance;
var
  myFileCheckResult:FileCheckResult;
begin
  if not FCreateFromFile then //启动Excel,打开一个空Excel表格
  begin
    try
      FExcel := CreateOLEObject('Excel.Application');
      if FExcel.WorkBooks.Count = 0 then
        FWorkBook := FExcel.WorkBooks.Add
      else
        FWorkBook := FExcel.WorkBooks[1];
        //FWorkSheet := FWorkBook.WorkSheets.Add;
      if FExcel.Sheets.Count = 0 then FWorkSheet := FWorkBook.WorkSheets.Add  //如果没有工作表,则创建一个
      else //FWorkSheet := FExcel.ActiveSheet;//否则使用当前工作表
        FWorkSheet := FExcel.worksheets[1];//否则使用当前工作簿第一个工作表
      FWorkSheet.Activate;
      //FWorkSheet := FExcel.WorkBooks[1].Sheets[1];
      FExcelCreated := True;
    except
      MessageDlg('打开Exce失败,请确定您的机器里已安装MicrosoftExcel后,再使用本功能！',mtError,[mbOk],0);;
      FExcelCreated := False;
    end;
  end
  else //根据FFileName指定的文件名,打开文件
  begin
    myFileCheckResult := FileCheck;
    case myFileCheckResult of
      fcrNotExistend:
      begin
        ShowMessage('指定的文件不存在,无法打开,请重新选择文件!');
      end;
      fcrNotXSLFile:
      begin
        ShowMessage('指定的文件不是合法的Excel格式文件,请重新选择文件!');
      end;
      fcrValidXSL:
      begin
        try
          FExcel := CreateOLEObject('Excel.Application');
          FWorkBook := FExcel.WorkBooks.Open(FFileName);

          if FExcel.Sheets.Count = 0 then FWorkSheet := FWorkBook.WorkSheets.Add  //如果没有工作表,则创建一个
          else //FWorkSheet := FExcel.ActiveSheet;//否则使用当前工作表
          FWorkSheet := FExcel.worksheets[1];//否则使用当前工作簿第一个工作表
          //FWorkSheet := FExcel.WorkBooks[1].Sheets[1];
          FWorkSheet.Activate;
          FExcelCreated := True;
        except
          MessageDlg('打开文件失败,可能是您的电脑没有安装Excel软件,请先安装Excel软件！',mtError,[mbOk],0);;
          FExcelCreated := False;
        end;
      end;  
    end;
  end;  
end;

destructor TOLEExcel.Destroy;
begin
  FCellFont.Free;
  FTitleFont.Free;
  try
    FExcel.Quit;
  finally
    FExcel := Unassigned;
  end;
  inherited Destroy;
end;

procedure TOLEExcel.SetExcelCellFont(var Cell: Variant);
begin
  if FIgnoreFont then exit;
  with FCellFont do
  begin
    Cell.Font.Name := Name;
    Cell.Font.Size := Size;
    Cell.Font.Color := Color;
    Cell.Font.Bold := fsBold in Style;
    Cell.Font.Italic := fsItalic in Style;
    Cell.Font.UnderLine := fsUnderline in Style;
    Cell.Font.Strikethrough := fsStrikeout in Style;
  end;
end;

procedure TOLEExcel.SetExcelTitleFont(var Cell: Variant);
begin
  if FIgnoreFont then exit;
  with FTitleFont do
  begin
    Cell.Font.Name := Name;
    Cell.Font.Size := Size;
    Cell.Font.Color := Color;
    Cell.Font.Bold := fsBold in Style;
    Cell.Font.Italic := fsItalic in Style;
    Cell.Font.UnderLine := fsUnderline in Style;
    Cell.Font.Strikethrough := fsStrikeout in Style;
  end;
end;


procedure TOLEExcel.SetVisible(DoShow: Boolean);
begin
  if not FExcelCreated then exit;
  if DoShow then
    FExcel.Visible := True
  else
    FExcel.Visible := False;
end;

function TOLEExcel.GetCell( ARow,ACol: Integer): string;
begin
  if not FExcelCreated then exit;
  result := FWorkSheet.Cells[ARow, ACol];
end;

procedure TOLEExcel.SetCell(ACol, ARow: Integer; const Value: string);
var
  Cell: Variant;
begin
  if not FExcelCreated then exit;
  Cell := FWorkSheet.Cells[ARow, ACol];
  SetExcelCellFont(Cell);
  Cell.Value := Value;
end;


function TOLEExcel.GetDateCell(ACol, ARow: Integer): TDateTime;
begin
  if not FExcelCreated then
  begin
    result := 0;
    exit;
  end;
  result := StrToDateTime(FWorkSheet.Cells[ARow, ACol]);
end;

procedure TOLEExcel.SetDateCell(ACol, ARow: Integer; const Value: TDateTime);
var
  Cell: Variant;
begin
  if not FExcelCreated then exit;
  Cell := FWorkSheet.Cells[ARow, ACol];
  SetExcelCellFont(Cell);
  Cell.Value := '''' + DateTimeToStr(Value);
end;

function TOLEExcel.IsCreated: Boolean;
begin
  result := FExcelCreated;
end;

procedure TOLEExcel.SetTitleFont(NewFont: TFont);
begin
  if NewFont <> FTitleFont then
    FTitleFont.Assign(NewFont);
end;

procedure TOLEExcel.SetCellFont(NewFont: TFont);
begin
  if NewFont <> FCellFont then
    FCellFont.Assign(NewFont);
end;

procedure TOLEExcel.GetTableColumnName(const Table: TTable; var Cell: Variant);
var
  Col: integer;
begin
  for Col := 0 to Table.FieldCount - 1 do
    begin
      Cell := FWorkSheet.Cells[1, Col + 1];
      SetExcelTitleFont(Cell);
      Cell.Value := Table.Fields[Col].FieldName;
    end;
end;

procedure TOLEExcel.TableToExcel(const Table: TTable);
var
  Col, Row: LongInt;
  Cell: Variant;
begin
  if not FExcelCreated then exit;
  if Table.Active = False then exit;

  GetTableColumnName(Table, Cell);
  Row := 2;
  with Table do
    begin
      first;
      while not EOF do
        begin
          for Col := 0 to FieldCount - 1 do
            begin
              Cell := FWorkSheet.Cells[Row, Col + 1];
              SetExcelCellFont(Cell);
              Cell.Value := Fields[Col].AsString;
            end;
          next;
          Inc(Row);
        end;
    end;
end;


procedure TOLEExcel.GetQueryColumnName(const Query: TQuery; var Cell: Variant);
var
  Col: integer;
begin
  for Col := 0 to Query.FieldCount - 1 do
    begin
      Cell := FWorkSheet.Cells[1, Col + 1];
      SetExcelTitleFont(Cell);
      Cell.Value := Query.Fields[Col].FieldName;
    end;
end;


procedure TOLEExcel.QueryToExcel(const Query: TQuery);
var
  Col, Row: LongInt;
  Cell: Variant;
begin
  if not FExcelCreated then exit;
  if Query.Active = False then exit;

  GetQueryColumnName(Query, Cell);
  Row := 2;
  with Query do
    begin
      first;
      while not EOF do
        begin
          for Col := 0 to FieldCount - 1 do
            begin
              Cell := FWorkSheet.Cells[Row, Col + 1];
              SetExcelCellFont(Cell);
              Cell.Value := Fields[Col].AsString;
            end;
          next;
          Inc(Row);
        end;
    end;
end;

procedure TOLEExcel.GetFixedCols(const StringGrid: TStringGrid; var Cell: Variant);
var
  Col, Row: LongInt;
begin
  for Col := 0 to StringGrid.FixedCols - 1 do
    for Row := 0 to StringGrid.RowCount - 1 do
      begin
        Cell := FWorkSheet.Cells[Row + 1, Col + 1];
        SetExcelTitleFont(Cell);
        Cell.Value := StringGrid.Cells[Col, Row];
      end;
end;

procedure TOLEExcel.GetFixedRows(const StringGrid: TStringGrid; var Cell: Variant);
var
  Col, Row: LongInt;
begin
  for Row := 0 to StringGrid.FixedRows - 1 do
    for Col := 0 to StringGrid.ColCount - 1 do
      begin
        Cell := FWorkSheet.Cells[Row + 1, Col + 1];
        SetExcelTitleFont(Cell);
        Cell.Value := StringGrid.Cells[Col, Row];
      end;
end;

procedure TOLEExcel.GetStringGridBody(const StringGrid: TStringGrid; var Cell: Variant);
var
  Col, Row, x, y: LongInt;
begin
  Col := StringGrid.FixedCols;
  Row := StringGrid.FixedRows;
  for x := Row to StringGrid.RowCount - 1 do
    for y := Col to StringGrid.ColCount - 1 do
      begin
        Cell := FWorkSheet.Cells[x + 1, y + 1];
        SetExcelCellFont(Cell);
        Cell.Value := StringGrid.Cells[y, x];
      end;
end;

procedure TOLEExcel.StringGridToExcel(const StringGrid: TStringGrid);
var
  Cell: Variant;
begin
  if not FExcelCreated then exit;
  GetFixedCols(StringGrid, Cell);
  GetFixedRows(StringGrid, Cell);
  GetStringGridBody(StringGrid, Cell);
end;

procedure TOLEExcel.SaveToExcel(const FileName: string);
begin
  if not FExcelCreated then exit;
  FWorkSheet.SaveAs(FileName);
  //FExcel.Application.quit;
  //FExcel:=Unassigned;
end;

procedure Register;
begin
  RegisterComponents('OleExcel', [TOLEExcel]);
end;

function TOLEExcel.GetRepRange(x, y: integer): String;{将(x,y)坐标形式改为Excel区域(A1:B1)形式}
var
  fX,fY:string;
begin   
  if y<=0 then  fX:='A';
  if  y<=26 then  fX := chr(64+y);
  if y>26 then  fX:=chr(64+(y div 26))+chr(64+(y mod 26));

  fY:=IntToStr(x);
  Result:=fX+fY;
end;

procedure TOLEExcel.CellMerge(x1, y1, x2, y2: integer);{合并指定单元格}
Var
  RepSpace:String;
begin
  if not FExcelCreated then exit;
  RepSpace:=GetRepRange(x1,y1)+':'+GetRepRange(x2,y2);
  FExcel.Range[RepSpace].Select;
  FExcel.Selection.Merge;
end;

procedure TOLEExcel.SetRepLine(x1,x2,y1,y2:Integer);{加边框线}
Var   
  RepSpace:String;
begin
  if not FExcelCreated then exit;
  RepSpace:=GetRepRange(x1,y1)+':'+GetRepRange(x2,y2);
  FExcel.ActiveSheet.Range[RepSpace].Borders.LineStyle:=xlContinuous;
end;

procedure TOLEExcel.CellWrite(RepData: String; x, y: Integer);
begin
  if not FExcelCreated then exit;
  FExcel.cells(x,y):=RepData;
end;

procedure TOLEExcel.CellFormat(x1, y1, x2, y2: integer);{指定单元格格式}
Var   
  RepSpace:String;
begin
  if not FExcelCreated then exit;
  RepSpace:=GetRepRange(x1,y1)+':'+GetRepRange(x2,y2);
  FExcel.Range[RepSpace].Select;
  FExcel.Selection.NumberFormat :='G/通用格式';
  FExcel.Selection.Font.Bold:=True;
  FExcel.Selection.HorizontalAlignment:=3; //水平方向对齐方式:居中
end;
procedure TOLEExcel.CellGS(x1, y1, x2, y2, f: integer); {灵活单元格格式}
Var   
  RepSpace:String;
begin
  if not FExcelCreated then exit;
  RepSpace:=GetRepRange(x1,y1)+':'+GetRepRange(x2,y2);
  FExcel.Range[RepSpace].Select;
  FExcel.Selection.NumberFormat :='G/通用格式';
  FExcel.Selection.HorizontalAlignment:=f;//水平方向对齐方式:居中
end;

procedure TOLEExcel.CreatRepSheet(SheetName: String; PageSize,PageLay: Integer);
{给当前工作表重命名、进行页面设置}
begin
  if not FExcelCreated then exit;
  FExcel.ActiveSheet.Name:=SheetName; //重命名当前工作表
  //设置页面
  if PageSize=1 then FExcel.ActiveSheet.PageSetup.PaperSize:=xlPaperA3; //纸张大小:A3
  if PageSize=2 then FExcel.ActiveSheet.PageSetup.PaperSize:=xlPaperA4; //纸张大小   :A4
  if PageSize=3 then FExcel.ActiveSheet.PageSetup.PaperSize:=xlPaperB5; //纸张大小   :B5
  if PageLay=1  then FExcel.ActiveSheet.PageSetup.Orientation:=xlportrait; //页面放置方向：纵向
  if PageLay=2  then FExcel.ActiveSheet.PageSetup.Orientation:=xlLandscape;//页面放置方向：横向
    
  //设置页宽自动适应   
  FExcel.ActiveSheet.PageSetup.Zoom := False;
  FExcel.ActiveSheet.PageSetup.FitToPagesWide := 1;
  FExcel.ActiveSheet.PageSetup.FitToPagesTall := False;   
    
  //设置页眉、页脚(即：页标题、页号)   
  FExcel.ActiveSheet.PageSetup.RightFooter := '打印时间:   '+'&D   &T';
  FExcel.ActiveSheet.PageSetup.CenterFooter:= '第&''&P&''页，共&''&N&''页';   
    
  //设置页边距:   
  FExcel.ActiveSheet.PageSetup.TopMargin:=1.5/0.035;   
  FExcel.ActiveSheet.PageSetup.BottomMargin:=1.5/0.035;   
  FExcel.ActiveSheet.PageSetup.LeftMargin:=1/0.035;   
  FExcel.ActiveSheet.PageSetup.RightMargin:=1/0.035;   
  FExcel.ActiveSheet.PageSetup.HeaderMargin:=0.5/0.035;   
  FExcel.ActiveSheet.PageSetup.FooterMargin:=0.5/0.035;   
    
  //设置页面对齐方式   
  FExcel.ActiveSheet.PageSetup.CenterHorizontally := True;          //页面水平居中
  //FExcel.ActiveSheet.PageSetup.CenterVertically := True;          //页面垂直居中
    
  //设置整体字体格式   
  FExcel.Cells.Font.Name:='宋体';//字体
  FExcel.Cells.Font.Size:=12;//字号
  FExcel.Cells.RowHeight:=16;//行高
  FExcel.Cells.VerticalAlignment:=2;//垂直方向对齐方式:居中   
end;

procedure TOLEExcel.SetAddMess(H_Mess1, H_Mess2, H_Mess3, F_Mess1, F_Mess2,F_Mess3: String);
//用户自定义页眉、页脚（即：页标题、页号）
begin
  if not FExcelCreated then exit;
  FExcel.ActiveSheet.PageSetup.LeftHeader   :=  H_Mess1;
  FExcel.ActiveSheet.PageSetup.CenterHeader :=  H_Mess2;
  FExcel.ActiveSheet.PageSetup.RightHeader  :=  H_Mess3;
end;

procedure TOLEExcel.SetRepBody(x, ch: Integer; cw: Double; cf: String); //设置整体各列数据格式
begin
  if not FExcelCreated then exit;
  FExcel.ActiveSheet.Columns[x].ColumnWidth:=cw;  //列宽
  FExcel.ActiveSheet.Columns[x].NumberFormat:=Cf; //单元格数据格式
  FExcel.ActiveSheet.Columns[x].HorizontalAlignment:=ch;//水平方向对齐方式
end;

procedure TOLEExcel.CreatTitle(TitleName: String; y: Integer);{设置标题}
Var
  RepSpace:String;
begin
  if not FExcelCreated then exit;
  CellMerge(1,1,1,y);
  FExcel.cells(1,1) :=  TitleName;
  RepSpace  :=  'A1'  + ':' + GetRepRange(1,y);
  FExcel.Range[RepSpace].Select;
  FExcel.Selection.NumberFormat :='G/通用格式';
  FExcel.Selection.Font.Size:=22;
  FExcel.Selection.Font.Name:='黑体';
  FExcel.Selection.Font.Bold:=True;
  FExcel.Selection.HorizontalAlignment:=3;             //水平方向对齐方式:居中
  FExcel.Rows[1].RowHeight:=28;   
end;

function TOLEExcel.FileCheck: FileCheckResult; //检查文件
begin
  if not (FileExists(FFileName)) then
  begin
    Result := fcrNotExistend;
    Exit;
  end
  else
  begin
    if UpperCase(ExtractFileExt(FFileName))<> '.XLS' then Result := fcrNotXSLFile
    else Result := fcrValidXSL;
  end;

end;

procedure TOLEExcel.SetCaption(ACaption: string);
begin
  if not FExcelCreated then exit;
  FExcel.Caption := ACaption;
end;

function TOLEExcel.GetCapiton: string;
begin
  if not FExcelCreated then exit;
  Result := FExcel.Caption;
end;

procedure TOLEExcel.CreatSubHead(SubTitle: array of String);{设置常规子表头}
Var   
  i,j:Integer;
begin
  if not FExcelCreated then exit;
  j:=0;
  for i:=Low(SubTitle) to High(SubTitle)   do
  begin
    Inc(j);
    FExcel.cells(2,j):=SubTitle[i];
  end;
end;

procedure TOLEExcel.SubHeadFormat(y, r: Integer);{设置子表头格式}
Var
  RepSpace:String;
  n:Integer;
begin
  if not FExcelCreated then exit;
  RepSpace:='A2'+':'+GetRepRange(1+r,y);
  FExcel.Range[RepSpace].Select;
  FExcel.Selection.NumberFormat   :='G/通用格式';
  FExcel.Selection.HorizontalAlignment:=3;//表头水平对齐方式:居中
  FExcel.Selection.Font.Bold:=True;
  for n:=1 to r do
  begin
    FExcel.Rows[1+n].RowHeight:=18;
    SetRepLine(1+n,y,1+n,y);
  end;
end;

procedure TOLEExcel.DTSubHeadGS(x, y, r: Integer);{设置动态子表头格式}
Var
  RepSpace:String;
  n:Integer;
begin
  if not FExcelCreated then exit;
  RepSpace:=GetRepRange(x,1)+':'+GetRepRange(x+r-1,y);
  FExcel.Range[RepSpace].Select;
  FExcel.Selection.NumberFormat   :='G/通用格式';   
  FExcel.Selection.HorizontalAlignment:=3;                 //表头水平对齐方式:居中
  FExcel.Selection.Font.Bold:=True;   
  for n:=0 to r-1 do
  begin
    FExcel.Rows[x+n].RowHeight:=18;
    SetRepLine(x+n,y,x+n,y);
  end;
end;

procedure TOLEExcel.WriteData(RepData: String; x, y:Integer;flag: Integer = 0);{写数据}
begin
  if not FExcelCreated then exit;
  if flag=1 then //flag = 1 表示写入日期型数据
    FExcel.cells(x,y):=StrToDate(RepData)
  else
  FExcel.cells(x,y):=RepData;
end;

procedure TOLEExcel.RepPageBreak(x, y, r: Integer);//分页、复制表头
Var   
  RepSpace:String;
  n:Integer;
begin
  if not FExcelCreated then exit;
  FExcel.ActiveSheet.Rows[x].PageBreak   :=   1;
  RepSpace:='A1'+':'+GetRepRange(r+1,y);
  FExcel.ActiveSheet.Range[RepSpace].Copy;
  RepSpace:='A'+IntToStr(x);
  FExcel.ActiveSheet.Range[RepSpace].PasteSpecial;
  FExcel.Rows[x].RowHeight:=28;
  for n:=2 to r do
    FExcel.Rows[x+n].RowHeight:=18;
end;

procedure TOLEExcel.RepSaveAs(FileName: String);
{保存为*.xls文件}   
begin
  if not FExcelCreated then exit;
  try
    FWorkBook.saveas(FileName);
  except
    MessageDlg('不能访问文件，请关闭Microsoft Excel后再运行本程序！',mtError,[mbOk],0);
  end;
end;

procedure TOLEExcel.RepPrivew;{打印预览当前工作簿的当前工作表}
begin
  if not FExcelCreated then exit;
  FExcel.ActiveSheet.PrintPreview;
end;

function TOLEExcel.GetRowCount: Integer;
begin
  if not FExcelCreated then Result := 0
  else Result := FWorkSheet.UsedRange.Rows.Count;
end;

end.

