{****************************************************
//
Description :
  ��һ�����Query��StringGrid�е����ݱ��浽һ��Execl�ļ���
Function List :
  �����ӿ�
  procedure CreateExcelInstance;
  �ѱ����ݷŵ�Excel�ļ���
  procedure TableToExcel( const Table: TTable );
  ��Query���ݷŵ�Excel�ļ���
  procedure QueryToExcel( const Query: TQuery );
  ��StringGrid���ݷŵ�Excel�ļ���
  procedure StringGridToExcel( const StringGrid: TStringGrid );
  ����ΪExecl�ļ�
  procedure SaveToExcel( const FileName: String);

����ʵ�����£�
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
  FileCheckResult = (fcrNotExistend,fcrNotXSLFile,fcrValidXSL); //�ļ�������,����XSL�ļ�,�Ϸ���XSL�ļ�
  TOLEExcel = class(TComponent)
  private
    FExcelCreated: Boolean;
    FVisible: Boolean;
    FExcel: Variant;      //Excel�������
    FWorkBook: Variant;   //Excel����������
    FWorkSheet: Variant;  //Excel������ ���������
    FCellFont: TFont;     //��Ԫ���������
    FTitleFont: TFont;    //
    FFontChanged: Boolean;
    FIgnoreFont: Boolean;
    FFileName: TFileName;

    //********************************************�Լ����*****************************//
    FCreateFromFile:Boolean;  //ָʾ�Ƿ�������ļ�
    FExcelCaption:string;     //�ó����Excel�Ĵ����

    //*********************************����U_Report*****************************//
    FRCPrePage:Integer; //ÿҳ��ʾ�ļ�¼��
    FMax:Integer;       //�����������

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

    //*********************************************�Լ����************************************//
    procedure SetCaption(ACaption:string);//���ô��ļ���,Excel������Ĵ������
    function GetCapiton:string;//���ش��ļ���,Excel������Ĵ������

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

    //*********************************����U_Report*****************************//
    function  GetRepRange(x,y:integer):String;//��(x,y)������ʽ��ΪExcel����(A1:B1)��ʽ
    procedure CellMerge(x1,y1,x2,y2:integer);//�ϲ�ָ����Ԫ��
    procedure SetRepLine(x1,x2,y1,y2:Integer); //�ӱ߿���
    procedure CellWrite(RepData:String;x,y:Integer);//��Ԫ��д����
    procedure CellFormat(x1,y1,x2,y2:integer);//ָ����Ԫ���ʽ
    procedure CellGS(x1,y1,x2,y2,f:integer);//��Ԫ���ʽ

    procedure CreatRepSheet(SheetName:String;PageSize,PageLay:Integer);//����ǰ������������������ҳ������ 
    procedure SetAddMess(H_Mess1,H_Mess2,H_Mess3,F_Mess1,F_Mess2,F_Mess3:String);//���ø�����Ϣ
    procedure SetRepBody(x,ch:Integer;cw:Double;cf:String);//��������������ݸ�ʽ
    procedure CreatTitle(TitleName:String;y:Integer);//���ñ���
    procedure CreatSubHead(SubTitle:Array of String); //���ó����ӱ�ͷ
    procedure SubHeadFormat(y,r:Integer);//�����ӱ�ͷ��ʽ
    procedure DTSubHeadGS(x,y,r:Integer);//���ö�̬�ӱ�ͷ��ʽ
    procedure WriteData(RepData:String;x,y:Integer;flag:Integer=0); //д������
    procedure RepPageBreak(x,y,r:Integer);//��ҳ�����Ʊ�ͷ
    procedure RepSaveAs(FileName:String); //����Ϊ*.xls��
    procedure RepPrivew;//Ԥ��

    //*********************************************�Լ����************************************//
    function FileCheck:FileCheckResult;//����ļ�
    function GetRowCount:Integer;
  published
    property TitleFont: TFont read FTitleFont write SetTitleFont;
    property CellFont: TFont read FCellFont write SetCellFont;
    property Visible: Boolean read FVisible write SetVisible;
    property IgnoreFont: Boolean read FIgnoreFont write FIgnoreFont;
    property FileName: TFileName read FFileName write FFileName;
    //*********************************����U_Report*****************************//
    property RCPrePage:Integer read FRCPrePage write FRCPrePage;
    property MaxAC:Integer  read FMax write FMax;


    //*********************************************�Լ����************************************//
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
  FVisible := False;//��ʱ����ʾExcel����
  FCreateFromFile := False;//Ĭ�ϲ��Ǵ�����xls�ļ�
  FFontChanged := False;
  FFileName := '';//Ĭ���ļ���Ϊ��
end;

procedure TOLEExcel.CreateExcelInstance;
var
  myFileCheckResult:FileCheckResult;
begin
  if not FCreateFromFile then //����Excel,��һ����Excel���
  begin
    try
      FExcel := CreateOLEObject('Excel.Application');
      if FExcel.WorkBooks.Count = 0 then
        FWorkBook := FExcel.WorkBooks.Add
      else
        FWorkBook := FExcel.WorkBooks[1];
        //FWorkSheet := FWorkBook.WorkSheets.Add;
      if FExcel.Sheets.Count = 0 then FWorkSheet := FWorkBook.WorkSheets.Add  //���û�й�����,�򴴽�һ��
      else //FWorkSheet := FExcel.ActiveSheet;//����ʹ�õ�ǰ������
        FWorkSheet := FExcel.worksheets[1];//����ʹ�õ�ǰ��������һ��������
      FWorkSheet.Activate;
      //FWorkSheet := FExcel.WorkBooks[1].Sheets[1];
      FExcelCreated := True;
    except
      MessageDlg('��Exceʧ��,��ȷ�����Ļ������Ѱ�װMicrosoftExcel��,��ʹ�ñ����ܣ�',mtError,[mbOk],0);;
      FExcelCreated := False;
    end;
  end
  else //����FFileNameָ�����ļ���,���ļ�
  begin
    myFileCheckResult := FileCheck;
    case myFileCheckResult of
      fcrNotExistend:
      begin
        ShowMessage('ָ�����ļ�������,�޷���,������ѡ���ļ�!');
      end;
      fcrNotXSLFile:
      begin
        ShowMessage('ָ�����ļ����ǺϷ���Excel��ʽ�ļ�,������ѡ���ļ�!');
      end;
      fcrValidXSL:
      begin
        try
          FExcel := CreateOLEObject('Excel.Application');
          FWorkBook := FExcel.WorkBooks.Open(FFileName);

          if FExcel.Sheets.Count = 0 then FWorkSheet := FWorkBook.WorkSheets.Add  //���û�й�����,�򴴽�һ��
          else //FWorkSheet := FExcel.ActiveSheet;//����ʹ�õ�ǰ������
          FWorkSheet := FExcel.worksheets[1];//����ʹ�õ�ǰ��������һ��������
          //FWorkSheet := FExcel.WorkBooks[1].Sheets[1];
          FWorkSheet.Activate;
          FExcelCreated := True;
        except
          MessageDlg('���ļ�ʧ��,���������ĵ���û�а�װExcel���,���Ȱ�װExcel�����',mtError,[mbOk],0);;
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

function TOLEExcel.GetRepRange(x, y: integer): String;{��(x,y)������ʽ��ΪExcel����(A1:B1)��ʽ}
var
  fX,fY:string;
begin   
  if y<=0 then  fX:='A';
  if  y<=26 then  fX := chr(64+y);
  if y>26 then  fX:=chr(64+(y div 26))+chr(64+(y mod 26));

  fY:=IntToStr(x);
  Result:=fX+fY;
end;

procedure TOLEExcel.CellMerge(x1, y1, x2, y2: integer);{�ϲ�ָ����Ԫ��}
Var
  RepSpace:String;
begin
  if not FExcelCreated then exit;
  RepSpace:=GetRepRange(x1,y1)+':'+GetRepRange(x2,y2);
  FExcel.Range[RepSpace].Select;
  FExcel.Selection.Merge;
end;

procedure TOLEExcel.SetRepLine(x1,x2,y1,y2:Integer);{�ӱ߿���}
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

procedure TOLEExcel.CellFormat(x1, y1, x2, y2: integer);{ָ����Ԫ���ʽ}
Var   
  RepSpace:String;
begin
  if not FExcelCreated then exit;
  RepSpace:=GetRepRange(x1,y1)+':'+GetRepRange(x2,y2);
  FExcel.Range[RepSpace].Select;
  FExcel.Selection.NumberFormat :='G/ͨ�ø�ʽ';
  FExcel.Selection.Font.Bold:=True;
  FExcel.Selection.HorizontalAlignment:=3; //ˮƽ������뷽ʽ:����
end;
procedure TOLEExcel.CellGS(x1, y1, x2, y2, f: integer); {��Ԫ���ʽ}
Var   
  RepSpace:String;
begin
  if not FExcelCreated then exit;
  RepSpace:=GetRepRange(x1,y1)+':'+GetRepRange(x2,y2);
  FExcel.Range[RepSpace].Select;
  FExcel.Selection.NumberFormat :='G/ͨ�ø�ʽ';
  FExcel.Selection.HorizontalAlignment:=f;//ˮƽ������뷽ʽ:����
end;

procedure TOLEExcel.CreatRepSheet(SheetName: String; PageSize,PageLay: Integer);
{����ǰ������������������ҳ������}
begin
  if not FExcelCreated then exit;
  FExcel.ActiveSheet.Name:=SheetName; //��������ǰ������
  //����ҳ��
  if PageSize=1 then FExcel.ActiveSheet.PageSetup.PaperSize:=xlPaperA3; //ֽ�Ŵ�С:A3
  if PageSize=2 then FExcel.ActiveSheet.PageSetup.PaperSize:=xlPaperA4; //ֽ�Ŵ�С   :A4
  if PageSize=3 then FExcel.ActiveSheet.PageSetup.PaperSize:=xlPaperB5; //ֽ�Ŵ�С   :B5
  if PageLay=1  then FExcel.ActiveSheet.PageSetup.Orientation:=xlportrait; //ҳ����÷�������
  if PageLay=2  then FExcel.ActiveSheet.PageSetup.Orientation:=xlLandscape;//ҳ����÷��򣺺���
    
  //����ҳ���Զ���Ӧ   
  FExcel.ActiveSheet.PageSetup.Zoom := False;
  FExcel.ActiveSheet.PageSetup.FitToPagesWide := 1;
  FExcel.ActiveSheet.PageSetup.FitToPagesTall := False;   
    
  //����ҳü��ҳ��(����ҳ���⡢ҳ��)   
  FExcel.ActiveSheet.PageSetup.RightFooter := '��ӡʱ��:   '+'&D   &T';
  FExcel.ActiveSheet.PageSetup.CenterFooter:= '��&''&P&''ҳ����&''&N&''ҳ';   
    
  //����ҳ�߾�:   
  FExcel.ActiveSheet.PageSetup.TopMargin:=1.5/0.035;   
  FExcel.ActiveSheet.PageSetup.BottomMargin:=1.5/0.035;   
  FExcel.ActiveSheet.PageSetup.LeftMargin:=1/0.035;   
  FExcel.ActiveSheet.PageSetup.RightMargin:=1/0.035;   
  FExcel.ActiveSheet.PageSetup.HeaderMargin:=0.5/0.035;   
  FExcel.ActiveSheet.PageSetup.FooterMargin:=0.5/0.035;   
    
  //����ҳ����뷽ʽ   
  FExcel.ActiveSheet.PageSetup.CenterHorizontally := True;          //ҳ��ˮƽ����
  //FExcel.ActiveSheet.PageSetup.CenterVertically := True;          //ҳ�洹ֱ����
    
  //�������������ʽ   
  FExcel.Cells.Font.Name:='����';//����
  FExcel.Cells.Font.Size:=12;//�ֺ�
  FExcel.Cells.RowHeight:=16;//�и�
  FExcel.Cells.VerticalAlignment:=2;//��ֱ������뷽ʽ:����   
end;

procedure TOLEExcel.SetAddMess(H_Mess1, H_Mess2, H_Mess3, F_Mess1, F_Mess2,F_Mess3: String);
//�û��Զ���ҳü��ҳ�ţ�����ҳ���⡢ҳ�ţ�
begin
  if not FExcelCreated then exit;
  FExcel.ActiveSheet.PageSetup.LeftHeader   :=  H_Mess1;
  FExcel.ActiveSheet.PageSetup.CenterHeader :=  H_Mess2;
  FExcel.ActiveSheet.PageSetup.RightHeader  :=  H_Mess3;
end;

procedure TOLEExcel.SetRepBody(x, ch: Integer; cw: Double; cf: String); //��������������ݸ�ʽ
begin
  if not FExcelCreated then exit;
  FExcel.ActiveSheet.Columns[x].ColumnWidth:=cw;  //�п�
  FExcel.ActiveSheet.Columns[x].NumberFormat:=Cf; //��Ԫ�����ݸ�ʽ
  FExcel.ActiveSheet.Columns[x].HorizontalAlignment:=ch;//ˮƽ������뷽ʽ
end;

procedure TOLEExcel.CreatTitle(TitleName: String; y: Integer);{���ñ���}
Var
  RepSpace:String;
begin
  if not FExcelCreated then exit;
  CellMerge(1,1,1,y);
  FExcel.cells(1,1) :=  TitleName;
  RepSpace  :=  'A1'  + ':' + GetRepRange(1,y);
  FExcel.Range[RepSpace].Select;
  FExcel.Selection.NumberFormat :='G/ͨ�ø�ʽ';
  FExcel.Selection.Font.Size:=22;
  FExcel.Selection.Font.Name:='����';
  FExcel.Selection.Font.Bold:=True;
  FExcel.Selection.HorizontalAlignment:=3;             //ˮƽ������뷽ʽ:����
  FExcel.Rows[1].RowHeight:=28;   
end;

function TOLEExcel.FileCheck: FileCheckResult; //����ļ�
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

procedure TOLEExcel.CreatSubHead(SubTitle: array of String);{���ó����ӱ�ͷ}
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

procedure TOLEExcel.SubHeadFormat(y, r: Integer);{�����ӱ�ͷ��ʽ}
Var
  RepSpace:String;
  n:Integer;
begin
  if not FExcelCreated then exit;
  RepSpace:='A2'+':'+GetRepRange(1+r,y);
  FExcel.Range[RepSpace].Select;
  FExcel.Selection.NumberFormat   :='G/ͨ�ø�ʽ';
  FExcel.Selection.HorizontalAlignment:=3;//��ͷˮƽ���뷽ʽ:����
  FExcel.Selection.Font.Bold:=True;
  for n:=1 to r do
  begin
    FExcel.Rows[1+n].RowHeight:=18;
    SetRepLine(1+n,y,1+n,y);
  end;
end;

procedure TOLEExcel.DTSubHeadGS(x, y, r: Integer);{���ö�̬�ӱ�ͷ��ʽ}
Var
  RepSpace:String;
  n:Integer;
begin
  if not FExcelCreated then exit;
  RepSpace:=GetRepRange(x,1)+':'+GetRepRange(x+r-1,y);
  FExcel.Range[RepSpace].Select;
  FExcel.Selection.NumberFormat   :='G/ͨ�ø�ʽ';   
  FExcel.Selection.HorizontalAlignment:=3;                 //��ͷˮƽ���뷽ʽ:����
  FExcel.Selection.Font.Bold:=True;   
  for n:=0 to r-1 do
  begin
    FExcel.Rows[x+n].RowHeight:=18;
    SetRepLine(x+n,y,x+n,y);
  end;
end;

procedure TOLEExcel.WriteData(RepData: String; x, y:Integer;flag: Integer = 0);{д����}
begin
  if not FExcelCreated then exit;
  if flag=1 then //flag = 1 ��ʾд������������
    FExcel.cells(x,y):=StrToDate(RepData)
  else
  FExcel.cells(x,y):=RepData;
end;

procedure TOLEExcel.RepPageBreak(x, y, r: Integer);//��ҳ�����Ʊ�ͷ
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
{����Ϊ*.xls�ļ�}   
begin
  if not FExcelCreated then exit;
  try
    FWorkBook.saveas(FileName);
  except
    MessageDlg('���ܷ����ļ�����ر�Microsoft Excel�������б�����',mtError,[mbOk],0);
  end;
end;

procedure TOLEExcel.RepPrivew;{��ӡԤ����ǰ�������ĵ�ǰ������}
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

