unit dg;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Variants,
  ActiveX, AxCtrls, mydg_TLB, mydg_IMPL, adxAddIn, ComCtrls, excel2000,

  DB, ADODB, ZcGridClasses, ZcUniClass, ZJGrid, ZcDataGrid, ZcDBGrids,
  StdCtrls,
  StdVcl, ExtCtrls
  ;

type
  Tdg = class(TActiveForm, Idg)
    Label1: TLabel;
    EjunLicense1: TEjunLicense;
    con1: TADOConnection;
    EjunLicense2: TEjunLicense;
    pnl1: TPanel;
    pgc1: TPageControl;
    ts1: TTabSheet;
    EjunDBGrid1: TEjunDBGrid;
    qry1: TADOQuery;
    procedure ActiveFormActivate(Sender: TObject);
    procedure tbldglistAfterScroll(DataSet: TDataSet);
    procedure EjunDBGrid1DblClick(Sender: TObject);
    procedure pnl1Click(Sender: TObject);
    procedure ActiveFormCreate(Sender: TObject);
  private
    FEvents: IdgEvents;
    procedure ActivateEvent(Sender: TObject);
    procedure ClickEvent(Sender: TObject);
    procedure CreateEvent(Sender: TObject);
    procedure DblClickEvent(Sender: TObject);
    procedure DeactivateEvent(Sender: TObject);
    procedure DestroyEvent(Sender: TObject);
    procedure KeyPressEvent(Sender: TObject; var Key: Char);
    procedure PaintEvent(Sender: TObject);
    procedure WMMouseActivate(var Message: TWMMouseActivate); message
      WM_MOUSEACTIVATE;
  protected
    procedure DefinePropertyPages(DefinePropertyPage: TDefinePropertyPage);
      override;
    procedure EventSinkChanged(const EventSink: IUnknown); override;
    function Get_Active: WordBool; safecall;
    function Get_AutoScroll: WordBool; safecall;
    function Get_AutoSize: WordBool; safecall;
    function Get_AxBorderStyle: TxActiveFormBorderStyle; safecall;
    function Get_Caption: WideString; safecall;
    function Get_Color: Integer; safecall;
    function Get_Cursor: Smallint; safecall;
    function Get_DoubleBuffered: WordBool; safecall;
    function Get_DropTarget: WordBool; safecall;
    function Get_Enabled: WordBool; safecall;
    function Get_HelpFile: WideString; safecall;
    function Get_KeyPreview: WordBool; safecall;
    function Get_PixelsPerInch: Integer; safecall;
    function Get_PrintScale: TxPrintScale; safecall;
    function Get_Scaled: WordBool; safecall;
    function Get_Visible: WordBool; safecall;
    function Get_VisibleDockClientCount: Integer; safecall;
    procedure Set_AutoScroll(Value: WordBool); safecall;
    procedure Set_AutoSize(Value: WordBool); safecall;
    procedure Set_AxBorderStyle(Value: TxActiveFormBorderStyle); safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    procedure Set_Color(Value: Integer); safecall;
    procedure Set_Cursor(Value: Smallint); safecall;
    procedure Set_DoubleBuffered(Value: WordBool); safecall;
    procedure Set_DropTarget(Value: WordBool); safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    procedure Set_HelpFile(const Value: WideString); safecall;
    procedure Set_KeyPreview(Value: WordBool); safecall;
    procedure Set_PixelsPerInch(Value: Integer); safecall;
    procedure Set_PrintScale(Value: TxPrintScale); safecall;
    procedure Set_Scaled(Value: WordBool); safecall;
    procedure Set_Visible(Value: WordBool); safecall;
  public
    procedure Initialize; override;
    destructor Destroy; override;
  end;

implementation

uses ComObj, ComServ;

{$R *.DFM}
var
  axlsname, axlssheetname: string;

  { Tdg }

procedure Tdg.DefinePropertyPages(DefinePropertyPage: TDefinePropertyPage);
begin
  { Define property pages here.  Property pages are defined by calling
    DefinePropertyPage with the class id of the page.  For example,
      DefinePropertyPage(Class_dg); }
end;

procedure Tdg.EventSinkChanged(const EventSink: IUnknown);
begin
  FEvents := EventSink as IdgEvents;
end;

procedure Tdg.Initialize;
begin
  inherited Initialize;
  OnActivate := ActivateEvent;
  OnClick := ClickEvent;
  OnCreate := CreateEvent;
  OnDblClick := DblClickEvent;
  OnDeactivate := DeactivateEvent;
  OnDestroy := DestroyEvent;
  OnKeyPress := KeyPressEvent;
  OnPaint := PaintEvent;
end;

function Tdg.Get_Active: WordBool;
begin
  Result := Active;
end;

function Tdg.Get_AutoScroll: WordBool;
begin
  Result := AutoScroll;
end;

function Tdg.Get_AutoSize: WordBool;
begin
  Result := AutoSize;
end;

function Tdg.Get_AxBorderStyle: TxActiveFormBorderStyle;
begin
  Result := Ord(AxBorderStyle);
end;

function Tdg.Get_Caption: WideString;
begin
  Result := WideString(Caption);
end;

function Tdg.Get_Color: Integer;
begin
  Result := Integer(Color);
end;

function Tdg.Get_Cursor: Smallint;
begin
  Result := Smallint(Cursor);
end;

function Tdg.Get_DoubleBuffered: WordBool;
begin
  Result := DoubleBuffered;
end;

function Tdg.Get_DropTarget: WordBool;
begin
  Result := DropTarget;
end;

function Tdg.Get_Enabled: WordBool;
begin
  Result := Enabled;
end;

function Tdg.Get_HelpFile: WideString;
begin
  Result := WideString(HelpFile);
end;

function Tdg.Get_KeyPreview: WordBool;
begin
  Result := KeyPreview;
end;

function Tdg.Get_PixelsPerInch: Integer;
begin
  Result := PixelsPerInch;
end;

function Tdg.Get_PrintScale: TxPrintScale;
begin
  Result := Ord(PrintScale);
end;

function Tdg.Get_Scaled: WordBool;
begin
  Result := Scaled;
end;

function Tdg.Get_Visible: WordBool;
begin
  Result := Visible;
end;

function Tdg.Get_VisibleDockClientCount: Integer;
begin
  Result := VisibleDockClientCount;
end;

procedure Tdg.ActivateEvent(Sender: TObject);
begin
  if FEvents <> nil then
    FEvents.OnActivate;
end;

procedure Tdg.ClickEvent(Sender: TObject);
begin
  if FEvents <> nil then
    FEvents.OnClick;
end;

procedure Tdg.CreateEvent(Sender: TObject);
begin
  if FEvents <> nil then
    FEvents.OnCreate;
end;

procedure Tdg.DblClickEvent(Sender: TObject);
begin
  if FEvents <> nil then
    FEvents.OnDblClick;
end;

procedure Tdg.DeactivateEvent(Sender: TObject);
begin
  if FEvents <> nil then
    FEvents.OnDeactivate;
end;

procedure Tdg.DestroyEvent(Sender: TObject);
begin
  if FEvents <> nil then
    FEvents.OnDestroy;
end;

procedure Tdg.KeyPressEvent(Sender: TObject; var Key: Char);
var
  TempKey: Smallint;
begin
  TempKey := Smallint(Key);
  if FEvents <> nil then
    FEvents.OnKeyPress(TempKey);
  Key := Char(TempKey);
end;

procedure Tdg.PaintEvent(Sender: TObject);
begin
  if FEvents <> nil then
    FEvents.OnPaint;
end;

procedure Tdg.Set_AutoScroll(Value: WordBool);
begin
  AutoScroll := Value;
end;

procedure Tdg.Set_AutoSize(Value: WordBool);
begin
  AutoSize := Value;
end;

procedure Tdg.Set_AxBorderStyle(Value: TxActiveFormBorderStyle);
begin
  AxBorderStyle := TActiveFormBorderStyle(Value);
end;

procedure Tdg.Set_Caption(const Value: WideString);
begin
  Caption := TCaption(Value);
end;

procedure Tdg.Set_Color(Value: Integer);
begin
  Color := TColor(Value);
end;

procedure Tdg.Set_Cursor(Value: Smallint);
begin
  Cursor := TCursor(Value);
end;

procedure Tdg.Set_DoubleBuffered(Value: WordBool);
begin
  DoubleBuffered := Value;
end;

procedure Tdg.Set_DropTarget(Value: WordBool);
begin
  DropTarget := Value;
end;

procedure Tdg.Set_Enabled(Value: WordBool);
begin
  Enabled := Value;
end;

procedure Tdg.Set_HelpFile(const Value: WideString);
begin
  HelpFile := string(Value);
end;

procedure Tdg.Set_KeyPreview(Value: WordBool);
begin
  KeyPreview := Value;
end;

procedure Tdg.Set_PixelsPerInch(Value: Integer);
begin
  PixelsPerInch := Value;
end;

procedure Tdg.Set_PrintScale(Value: TxPrintScale);
begin
  PrintScale := TPrintScale(Value);
end;

procedure Tdg.Set_Scaled(Value: WordBool);
begin
  Scaled := Value;
end;

procedure Tdg.Set_Visible(Value: WordBool);
begin
  Visible := Value;
end;

destructor Tdg.Destroy;
var
  ParkingHandle: HWND;
begin
  ParkingHandle := FindWindowEx(0, 0, 'DAXParkingWindow', nil);
  if ParkingHandle <> 0 then
    SendMessage(ParkingHandle, WM_CLOSE, 0, 0);
  inherited Destroy;
end;

function SearchForHWND(const AControl: TWinControl; Focused: HWND): boolean;
var
  i: Integer;
begin
  Result := (AControl.Handle = Focused);
  if not Result then
    for i := 0 to AControl.ControlCount - 1 do
      if AControl.Controls[i] is TWinControl then
      begin
        if TWinControl(AControl.Controls[i]).Handle = Focused then
        begin
          Result := True;
          Break;
        end
        else if TWinControl(AControl.Controls[i]).ControlCount > 0 then
        begin
          Result := SearchForHWND(TWinControl(AControl.Controls[i]), Focused);
          if Result then
            Break;
        end;
      end;
end;

procedure Tdg.WMMouseActivate(var Message: TWMMouseActivate);
var
  FocusedWindow: HWND;
  CursorPos: TPoint;
begin
  inherited;
  FocusedWindow := Windows.GetFocus;
  if not SearchForHWND(Self, FocusedWindow) then
  begin
    Windows.GetCursorPos(CursorPos);
    FocusedWindow := WindowFromPoint(CursorPos);
    Windows.SetFocus(FocusedWindow);
    Message.Result := MA_ACTIVATE;
  end;
end;

procedure Tdg.ActiveFormActivate(Sender: TObject);
begin
  axlsname := '';
  axlssheetname := '';

end;

procedure Tdg.tbldglistAfterScroll(DataSet: TDataSet);
var
  i: Integer;
begin
  //  SHOWMESSAGE('开始');

//  axlsname := 'd:\dgnew\mb\' + tbldglist.fieldbyname('xlsfilename').AsString;
//  aXLSsheetname := tbldglist.fieldbyname('sheetname').AsString;
//
//  mydg_IMPL.adxmydgs.ExcelApp.Workbooks.Open(axlsname, EmptyParam,
//    EmptyParam, EmptyParam, EmptyParam,
//    EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
//    EmptyParam, EmptyParam, EmptyParam, adxLCID
//    );
// // SHOWMESSAGE('打开了' + axlsname);
//
//  for i := 1 to mydg_IMPL.adxmydgs.ExcelApp.ActiveWorkbook.Sheets.Count do
//  begin
//    if
//      Trim(_WORKSHEET(mydg_IMPL.adxmydgs.ExcelApp.ActiveWorkbook.Sheets.Item[i]).NAME) =
//      Trim(aXLSsheetname) then
//    begin
//  //    SHOWMESSAGE('找到' + aXLSsheetname);
//      _WORKSHEET(mydg_IMPL.adxmydgs.ExcelApp.ActiveWorkbook.Sheets.Item[i]).ACTIVATE(ADXLCID);
//      Break;
//    end;
//
//  end;

end;

procedure Tdg.EjunDBGrid1DblClick(Sender: TObject);
var
  i: Integer;
begin
  try
    //    for i := 1 to mydg_IMPL.adxmydgs.ExcelApp.Workbooks.Count do
    //    begin
    //      if Trim(mydg_IMPL.adxmydgs.ExcelApp.Workbooks.Item[i].Name) =
    //        Trim(axlsname) then
    //      begin
    //        mydg_IMPL.adxmydgs.ExcelApp.Workbooks.Item[i].Save(adxlcid);
    //        SHOWMESSAGE('保存了' +
    //          mydg_IMPL.adxmydgs.ExcelApp.Workbooks.Item[i].Name);
    //        Break;
    //      end;
    //    end;

    axlsname := 'd:\dgnew\mb\' + qry1.fieldbyname('xlsfilename').AsString;
    aXLSsheetname := qry1.fieldbyname('sheetname').AsString;
    //  ShowMessage(axlsname);
    mydg_IMPL.adxmydgs.ExcelApp.Workbooks.Open(axlsname, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, adxLCID);

    for i := 1 to mydg_IMPL.adxmydgs.ExcelApp.ActiveWorkbook.Sheets.Count do
    begin
      if
        Trim(_WORKSHEET(mydg_IMPL.adxmydgs.ExcelApp.ActiveWorkbook.Sheets.Item[i]).NAME) =
        Trim(aXLSsheetname) then
      begin
        _WORKSHEET(mydg_IMPL.adxmydgs.ExcelApp.ActiveWorkbook.Sheets.Item[i]).ACTIVATE(ADXLCID);
        Break;
      end;

    end;
  except
  end;
end;

procedure Tdg.pnl1Click(Sender: TObject);
begin
  if mydg_IMPL.adxmydgs.TaskPanes.Items[0].Width > 100 then
    mydg_IMPL.adxmydgs.TaskPanes.Items[0].Width := 10
  else
    mydg_IMPL.adxmydgs.TaskPanes.Items[0].Width := 270;

  // self.Repaint;
end;

procedure Tdg.ActiveFormCreate(Sender: TObject);
begin

  qry1.close;
  qry1.sql.clear;
  qry1.sql.add('select * from 综合表格 order by id  asc');
  qry1.open;

end;

initialization
  TActiveFormFactory.Create(
    ComServer,
    TActiveFormControl,
    Tdg,
    Class_dg,
    1,
    '',
    OLEMISC_SIMPLEFRAME or OLEMISC_ACTSLIKELABEL,
    tmApartment);
end.

