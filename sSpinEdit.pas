unit sSpinEdit;
{$I sDefs.inc}
{.$DEFINE LOGGED}

interface

uses Windows, Classes, StdCtrls, ExtCtrls, Controls, Messages, SysUtils,
  Forms, Graphics, Menus, sEdit, acntUtils, sConst, buttons, sGraphUtils, sSpeedButton;

{$IFNDEF NOTFORHELP}
const
  InitRepeatPause = 400;  { pause before repeat timer (ms) }
  RepeatPause     = 100;  { pause before hint window displays (ms)}
{$ENDIF} // NOTFORHELP

type
{$IFNDEF NOTFORHELP}
  TNumGlyphs = Buttons.TNumGlyphs;

  TsTimerSpeedButton = class;
  TsSpinEdit = class;

  TsSpinButton = class(TWinControl)
  private
    FOwner : TsSpinEdit;
    FUpButton: TsTimerSpeedButton;
    FDownButton: TsTimerSpeedButton;
    FFocusedButton: TsTimerSpeedButton;
    FFocusControl: TWinControl;
    FOnUpClick: TNotifyEvent;
    FOnDownClick: TNotifyEvent;
    function CreateButton: TsTimerSpeedButton;
    function GetUpGlyph: TBitmap;
    function GetDownGlyph: TBitmap;
    procedure SetUpGlyph(Value: TBitmap);
    procedure SetDownGlyph(Value: TBitmap);
    procedure BtnClick(Sender: TObject);
    procedure BtnMouseDown (Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SetFocusBtn (Btn: TsTimerSpeedButton);
    procedure AdjustSize(var W, H: Integer); reintroduce;
    procedure WMSize(var Message: TWMSize);  message WM_SIZE;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
  protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure WndProc (var Message: TMessage); override;
  public
    procedure PaintTo(DC : hdc; P : TPoint);
    constructor Create(AOwner: TComponent); override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
  published
    property Align;
    property Anchors;
    property Constraints;
    property Ctl3D;
    property DownGlyph: TBitmap read GetDownGlyph write SetDownGlyph;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FocusControl: TWinControl read FFocusControl write FFocusControl;
    property ParentCtl3D;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property UpGlyph: TBitmap read GetUpGlyph write SetUpGlyph;
    property Visible;
    property OnDownClick: TNotifyEvent read FOnDownClick write FOnDownClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnStartDock;
    property OnStartDrag;
    property OnUpClick: TNotifyEvent read FOnUpClick write FOnUpClick;
  end;
{$ENDIF} // NOTFORHELP

  TsBaseSpinEdit = class(TsEdit)
{$IFNDEF NOTFORHELP}
   private
    FButton: TsSpinButton;
    FEditorEnabled: Boolean;
    FOnUpClick: TNotifyEvent;
    FOnDownClick: TNotifyEvent;
    FAlignment: TAlignment;
    function GetMinHeight: Integer;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMPaste(var Message: TWMPaste);  message WM_PASTE;
    procedure WMCut(var Message: TWMCut);  message WM_CUT;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure SetAlignment(const Value: TAlignment);
  protected
    procedure SetEditRect;
    function IsValidChar(var Key: AnsiChar): Boolean; virtual;
    procedure UpClick (Sender: TObject); virtual; abstract;
    procedure DownClick (Sender: TObject); virtual; abstract;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure PaintText; override;
    procedure PrepareCache; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    destructor Destroy; override;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    property Button: TsSpinButton read FButton;
    property CharCase;
    procedure Loaded; override;
    procedure WndProc (var Message: TMessage); override;
  published
{$ENDIF} // NOTFORHELP
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property EditorEnabled: Boolean read FEditorEnabled write FEditorEnabled default True;
    property OnDownClick: TNotifyEvent read FOnDownClick write FOnDownClick;
    property OnUpClick: TNotifyEvent read FOnUpClick write FOnUpClick;
  end;


  TsSpinEdit = class(TsBaseSpinEdit)
{$IFNDEF NOTFORHELP}
  private
    FMinValue: LongInt;
    FMaxValue: LongInt;
    FIncrement: LongInt;
    function GetValue: LongInt;
    function CheckValue (NewValue: LongInt): Longint;
    procedure SetValue (NewValue: LongInt);
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure CMMouseWheel(var Message: TCMMouseWheel); message CM_MOUSEWHEEL;
  protected
    procedure WMPaste(var Message: TWMPaste);  message WM_PASTE;
    function IsValidChar(var Key: AnsiChar): Boolean; override;
    procedure UpClick (Sender: TObject); override;
    procedure DownClick (Sender: TObject); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
{$ENDIF} // NOTFORHELP
    property Increment: LongInt read FIncrement write FIncrement default 1;
    property MaxValue: LongInt read FMaxValue write FMaxValue;
    property MinValue: LongInt read FMinValue write FMinValue;
    property Value: LongInt read GetValue write SetValue;
  end;

  TsDecimalSpinEdit = class(TsBaseSpinEdit)
{$IFNDEF NOTFORHELP}
  private
    FValue : Extended;
    FMinValue: Extended;
    FMaxValue: Extended;
    FIncrement: Extended;
    fDecimalPlaces:Integer;
    FUseSystemDecSeparator: boolean;
    function CheckValue (NewValue: Extended): Extended;
    procedure SetValue (NewValue: Extended);
    procedure SetDecimalPlaces(New:Integer);
    procedure CMExit(var Message: TCMExit);  message CM_EXIT;
    procedure FormatText;
    procedure CMChanged(var Message: TMessage); message CM_CHANGED;
    procedure CMMouseWheel(var Message: TCMMouseWheel); message CM_MOUSEWHEEL;
    function GetValue: Extended;
  protected
    ValueChanging : boolean;
    TextChanging : boolean;
    procedure WMPaste(var Message: TWMPaste);  message WM_PASTE;
    function IsValidChar(var Key: AnsiChar): Boolean; override;
    procedure UpClick (Sender: TObject); override;
    procedure DownClick (Sender: TObject); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure CreateWnd; override;
  published
{$ENDIF} // NOTFORHELP
    property Increment: Extended read FIncrement write FIncrement;
    property MaxValue: Extended read FMaxValue write FMaxValue;
    property MinValue: Extended read FMinValue write FMinValue;
    property Value: Extended read GetValue write SetValue;
    property DecimalPlaces:Integer read fDecimalPlaces write SetDecimalPlaces default 2;
    property UseSystemDecSeparator : boolean read FUseSystemDecSeparator write FUseSystemDecSeparator default True;
  end;

{$IFNDEF NOTFORHELP}
{ TsTimerSpeedButton }

  TTimeBtnState = set of (tbFocusRect, tbAllowTimer);

  TsTimerSpeedButton = class(TsSpeedButton)
  private
    FOwner : TsSpinButton;
    FRepeatTimer: TTimer;
    FTimeBtnState: TTimeBtnState;
    procedure TimerExpired(Sender: TObject);
  protected
    procedure Paint; override;
    procedure DrawGlyph; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    Up : boolean;
    constructor Create (AOwner: TComponent); override;
    destructor Destroy; override;
    procedure PaintTo(DC : hdc; P : TPoint);
    property TimeBtnState: TTimeBtnState read FTimeBtnState write FTimeBtnState;
  end;

  TacTimePortion = (tvHours, tvMinutes, tvSeconds);

  TsTimePicker = class(TsBaseSpinEdit)
  private
    fHour, fMin, fSec: word;
    FDoBeep: boolean;
    FShowSeconds: boolean;
    FUse12Hour: boolean;
    function GetValue: TDateTime;
    procedure SetValue (NewValue: TDateTime);
    function CheckValue (NewValue: TDateTime): TDateTime;
    procedure CMExit(var Message: TCMExit);  message CM_EXIT;
    procedure SetShowSeconds(const Value: boolean);
    procedure SetUse12Hour(const Value: boolean);
  protected
    FPos : integer;
    function IsValidChar(var Key: AnsiChar): Boolean; override;
    procedure UpClick (Sender: TObject); override;
    procedure DownClick (Sender: TObject); override;

    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure SetHour(NewHour : integer);
    procedure SetMin(NewMin : integer);
    procedure SetSec(NewSec : integer);
    procedure DecodeValue;
    function Portion : TacTimePortion;
    procedure SetPos(NewPos : integer; Highlight : boolean = True);
    procedure IncPos;
    procedure ReplaceAtPos(APos : integer; AChar : Char);
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure HighlightPos(APos : integer);
    procedure Change; override;

    function EmptyText : acString;
    function TextLength : integer;
    function Sec : word;
  public
    MaxHour : integer;
    constructor Create(AOwner: TComponent); override;
    procedure Loaded; override;
  published
    property Date: TDateTime read GetValue write SetValue;
    property DoBeep : boolean read FDoBeep write FDoBeep default False;
    property Value: TDateTime read GetValue write SetValue;
    property Time: TDateTime read GetValue write SetValue;
    property ShowSeconds : boolean read FShowSeconds write SetShowSeconds default True;
    property Use12Hour : boolean read FUse12Hour write SetUse12Hour default False;
  end;
{$ENDIF} // NOTFORHELP

implementation

uses sStyleSimply, Math, sSkinProps, sMessages, sCommonData, sSkinManager, sVCLUtils, sDefaults,
  sAlphaGraph {$IFDEF LOGGED}, sDebugMsgs{$ENDIF};

{ TsSpinButton }

constructor TsSpinButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csAcceptsControls, csSetCaption];
  FOwner := TsSpinEdit(AOwner);

  FUpButton := CreateButton;
  FUpButton.Up := True;
  FDownButton := CreateButton;
  FDownButton.Up := False;
  UpGlyph := nil;
  DownGlyph := nil;
  Width := 18;
  FFocusedButton := FUpButton;
end;

function TsSpinButton.CreateButton: TsTimerSpeedButton;
begin
  Result := TsTimerSpeedButton.Create(Self);
  Result.SkinData.SkinSection := s_SpeedButton_Small;
  Result.Parent := Self;
  Result.OnClick := BtnClick;
  Result.NumGlyphs := 1;
  Result.OnMouseDown := BtnMouseDown;
  Result.Visible := True;
  Result.Enabled := True;
  Result.Flat := False;
  Result.Transparent := True;
  Result.TimeBtnState := [tbAllowTimer];
end;

procedure TsSpinButton.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FFocusControl) then FFocusControl := nil;
end;

procedure TsSpinButton.AdjustSize(var W, H: Integer);
begin
  if (FUpButton = nil) or (csLoading in ComponentState) or (H = 0) then Exit;
  if W < 15 then W := 15;
  FUpButton.SetBounds(0, 0, W, H div 2);
  FDownButton.SetBounds(0, FUpButton.Height, W, H - FUpButton.Height);
end;

procedure TsSpinButton.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
var
  W, H: Integer;
begin
  W := AWidth;
  H := AHeight;
  AdjustSize (W, H);
  inherited SetBounds (ALeft, ATop, W, H);
end;

procedure TsSpinButton.WMSize(var Message: TWMSize);
var
  W, H: Integer;
begin
  inherited;
  W := Width;
  H := Height;
  AdjustSize(W, H);
  if (W <> Width) or (H <> Height) then inherited SetBounds(Left, Top, W, H);
  Message.Result := 0;
end;

procedure TsSpinButton.WMSetFocus(var Message: TWMSetFocus);
begin
  FFocusedButton.TimeBtnState := FFocusedButton.TimeBtnState + [tbFocusRect];
  FFocusedButton.Invalidate;
end;

procedure TsSpinButton.WMKillFocus(var Message: TWMKillFocus);
begin
  FFocusedButton.TimeBtnState := FFocusedButton.TimeBtnState - [tbFocusRect];
  FFocusedButton.Invalidate;
end;

procedure TsSpinButton.BtnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then begin
    SetFocusBtn (TsTimerSpeedButton (Sender));
    if (FFocusControl <> nil) and FFocusControl.TabStop and FFocusControl.CanFocus and (GetFocus <> FFocusControl.Handle)
      then FFocusControl.SetFocus
      else if TabStop and (GetFocus <> Handle) and CanFocus then SetFocus;
  end;
end;

procedure TsSpinButton.BtnClick(Sender: TObject);
begin
  if Sender = FUpButton then begin
    if Assigned(FOnUpClick) then FOnUpClick(Self);
  end
  else if Assigned(FOnDownClick) then FOnDownClick(Self);
end;

procedure TsSpinButton.SetFocusBtn(Btn: TsTimerSpeedButton);
begin
  if TabStop and CanFocus and  (Btn <> FFocusedButton) then begin
    FFocusedButton.TimeBtnState := FFocusedButton.TimeBtnState - [tbFocusRect];
    FFocusedButton := Btn;
    if (GetFocus = Handle) then begin
      FFocusedButton.TimeBtnState := FFocusedButton.TimeBtnState + [tbFocusRect];
      Invalidate;
    end;
  end;
end;

procedure TsSpinButton.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTARROWS;
end;

procedure TsSpinButton.Loaded;
var
  W, H: Integer;
begin
  inherited Loaded;
  W := Width;
  H := Height;
  AdjustSize (W, H);
  if (W <> Width) or (H <> Height) then inherited SetBounds (Left, Top, W, H);
  FUpButton.SkinData.SkinManager := FOwner.SkinData.FSkinManager;
  FDownButton.SkinData.SkinManager := FOwner.SkinData.FSkinManager;
end;

function TsSpinButton.GetUpGlyph: TBitmap;
begin
  Result := FUpButton.Glyph;
end;

procedure TsSpinButton.SetUpGlyph(Value: TBitmap);
begin
  FUpButton.Glyph := Value
end;

function TsSpinButton.GetDownGlyph: TBitmap;
begin
  Result := FDownButton.Glyph;
end;

procedure TsSpinButton.SetDownGlyph(Value: TBitmap);
begin
  FDownButton.Glyph := Value
end;

procedure TsSpinButton.WndProc(var Message: TMessage);
var
  PS : TPaintStruct;
begin
  if Message.MSG = SM_ALPHACMD then case Message.WParamHi of
    AC_GETBG : begin
      PacBGInfo(Message.LParam).BgType := btFill;
      PacBGInfo(Message.LParam).Color := SendMessage(FOwner.Handle, SM_ALPHACMD, MakeWParam(0, AC_GETCONTROLCOLOR), 0); //FOwner.Color;
      Exit
    end;
    AC_PREPARING : begin
      Message.Result := integer(FOwner.SkinData.FUpdating);
      Exit
    end;
    AC_ENDPARENTUPDATE : exit;
  end
  else case Message.Msg of
    WM_PAINT : if not FOwner.Enabled then begin
      BeginPaint(Handle, PS);
      EndPaint(Handle, PS);
      Exit;
    end;
    WM_ERASEBKGND : if not FOwner.Enabled then Exit;
  end;
  inherited;
  case Message.Msg of
    CM_ENABLEDCHANGED : begin
      SetUpGlyph(nil);
      SetDownGlyph(nil);
    end;
  end;
end;

procedure TsSpinButton.PaintTo(DC: hdc; P: TPoint);
begin
  FUpButton.PaintTo(DC, P);
  inc(P.Y, FUpButton.Height);
  FDownButton.PaintTo(DC, P);
end;

{ TsSpinEdit }

constructor TsBaseSpinEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csSetCaption] + [csAcceptsControls];
  FButton := TsSpinButton.Create(Self);
  FButton.Visible := False;
  FButton.Parent := Self;
  FButton.FocusControl := Self;
  FButton.OnUpClick := UpClick;
  FButton.OnDownClick := DownClick;
  FButton.SetUpGlyph(nil);
  FButton.SetDownGlyph(nil);
  FButton.Visible := True;
  ControlStyle := ControlStyle - [csAcceptsControls];
  FAlignment := taLeftJustify;
  FEditorEnabled := True;
end;

destructor TsBaseSpinEdit.Destroy;
begin
  FButton := nil;
  inherited Destroy;
end;

procedure TsBaseSpinEdit.GetChildren(Proc: TGetChildProc; Root: TComponent);
begin
end;

procedure TsBaseSpinEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  case Key of
    VK_UP: UpClick(Self);
    VK_DOWN: DownClick(Self);
  end;
  if Key <> 0 then SetEditRect;
end;

procedure TsBaseSpinEdit.KeyPress(var Key: Char);
var
  C : AnsiChar;
  err : boolean;
begin
  C := AnsiChar(Key);
  err := not IsValidChar(C);
  if err or (C = #0) then begin
    if (C = #0) then Key := #0;
    if err then MessageBeep(0);
  end
  else inherited KeyPress(Key);
end;

function TsBaseSpinEdit.IsValidChar(var Key: AnsiChar): Boolean;
begin
  Result := CharInSet(Key, [DecimalSeparator, '+', '-', '0'..'9']) or ((Key < #32) and (Key <> Chr(VK_RETURN)));
  if not FEditorEnabled and Result and ((Key >= #32) or (Key = Char(VK_BACK)) or (Key = Char(VK_DELETE))) then Result := False;
end;

procedure TsBaseSpinEdit.CreateParams(var Params: TCreateParams);
const
  Alignments: array[TAlignment] of Longword = (ES_LEFT, ES_RIGHT, ES_CENTER);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or ES_MULTILINE or WS_CLIPCHILDREN or Alignments[FAlignment] and not WS_BORDER;
end;

procedure TsBaseSpinEdit.CreateWnd;
begin
  inherited CreateWnd;
  SetEditRect;
end;

procedure TsBaseSpinEdit.SetEditRect;
var
  Loc: TRect;
begin
  SendMessage(Handle, EM_GETRECT, 0, LongInt(@Loc));
  Loc.Bottom := ClientHeight + 1;  {+1 is workaround for windows paint bug}
  Loc.Right := Width - FButton.Width - 3;
  Loc.Top := 0;
  Loc.Left := 0;
  SendMessage(Handle, EM_SETRECTNP, 0, LongInt(@Loc));
  SendMessage(Handle, EM_GETRECT, 0, LongInt(@Loc));  {debug}
end;

procedure TsBaseSpinEdit.WMSize(var Message: TWMSize);
var
  MinHeight: Integer;
begin
  inherited;
  MinHeight := GetMinHeight;
  if Height < MinHeight then Height := MinHeight else if FButton <> nil then begin
    FButton.SetBounds(Width - FButton.Width - 4, 0, FButton.Width, Height - 4);
    SetEditRect;
  end;
end;

function TsBaseSpinEdit.GetMinHeight: Integer;
begin
  Result := 0;
end;

procedure TsBaseSpinEdit.WMPaste(var Message: TWMPaste);
begin
  if not FEditorEnabled or ReadOnly then Exit;
  inherited;
end;

procedure TsBaseSpinEdit.WMCut(var Message: TWMPaste);
begin
  if not FEditorEnabled or ReadOnly then Exit;
  inherited;
end;

procedure TsBaseSpinEdit.Loaded;
begin
  inherited;
  FButton.SetUpGlyph(nil);
  FButton.SetDownGlyph(nil);
  SetEditRect;
end;

constructor tsSpinEdit.Create(AOwner:TComponent);
begin
  inherited create(AOwner);
  FIncrement := 1;
end;

procedure TsSpinEdit.CMExit(var Message: TCMExit);
begin
  inherited;
  if (Text = '-0') or (Text = '-') then Text := '0';
  if CheckValue(Value) <> Value then SetValue(Value);
end;

procedure TsSpinEdit.UpClick (Sender: TObject);
begin
  if ReadOnly then MessageBeep(0) else begin
    if Assigned(FOnUpClick)
      then FOnUpClick(Self)
      else Value := Value + FIncrement;
  end;
end;

procedure TsSpinEdit.DownClick (Sender: TObject);
begin
  if ReadOnly then MessageBeep(0) else begin
    if Assigned(FOnDownClick)
      then FOnDownClick(Self)
      else Value := Value - FIncrement;
  end;
end;


function TsSpinEdit.GetValue: LongInt;
begin
  if Text <> '' then begin
    try
      Result := StrToInt(Text);
    except
      Result := FMinValue;
    end;
  end
  else Result := 0;
end;

procedure TsSpinEdit.SetValue (NewValue: LongInt);
begin
  if not (csLoading in ComponentState) then Text := IntToStr(CheckValue(NewValue));
end;

function TsSpinEdit.CheckValue(NewValue: LongInt): LongInt;
begin
  Result := NewValue;
  if ((FMinValue <> 0) or (FMinValue <> FMaxValue)) and (NewValue < FMinValue)
    then Result := FMinValue
    else if (FMaxValue <> 0) and (NewValue > FMaxValue) then Result := FMaxValue;
end;

function TsSpinEdit.IsValidChar(var Key: AnsiChar): Boolean;
begin
  Result := False;
  case Key of
    Chr(VK_RETURN) : begin
      Key := #0;
      Exit;
    end;
    Char(VK_BACK), Chr(VK_ESCAPE) : Exit;
    '-' : if (Pos('-', Text) <= 0) or (SelLength >= Length(Text) - 1) then begin
      if (DWord(SendMessage(Handle, EM_GETSEL, 0, 0)) mod $10000 = 0) then begin
        if (MinValue <= 0) then Result := True else Result := False;
        Exit;
      end;
    end;
  end;
  Result := FEditorEnabled and CharInSet(Key, ['0'..'9']) or (Key < #32);
  if not Result then Key := #0;
end;

procedure TsSpinEdit.CMMouseWheel(var Message: TCMMouseWheel);
begin
  inherited;
  if not ReadOnly and (Message.Result = 0) then begin
    Value := Value + Increment * (Message.WheelDelta div 120);
    Message.Result := 1
  end;
end;

procedure TsSpinEdit.WMPaste(var Message: TWMPaste);
{$IFDEF DELPHI6UP}
var
  OldValue, NewValue : integer;
{$ENDIF}
begin
  if not FEditorEnabled or ReadOnly then Exit;
{$IFDEF DELPHI6UP}
  OldValue := Value;
{$ENDIF}
  inherited;
{$IFDEF DELPHI6UP}
  if not TryStrToInt(Text, NewValue) then Text := IntToStr(OldValue);
{$ENDIF}
end;

{tsDecimalSpinEdit}

constructor TsDecimalSpinEdit.Create(AOwner:TComponent);
begin
   inherited create(AOwner);
   ValueChanging := False;
   TextChanging := False;
   FUseSystemDecSeparator := True;
   FIncrement := 1.0;
   FDecimalPlaces := 2;
end;

procedure TsDecimalSpinEdit.CMExit(var Message: TCMExit);
begin
  inherited;
  if CheckValue(Value) <> Value then SetValue(Value);
  FormatText;
end;

procedure tsDecimalSpinEdit.UpClick(Sender: TObject);
var
  CurValue : real;
begin
  if ReadOnly then MessageBeep(0) else begin
    CurValue := Value;
    if Assigned(FOnUpClick)
      then FOnUpClick(Self)
      else Value := CurValue + FIncrement;
  end;
end;

procedure tsDecimalSpinEdit.DownClick (Sender: TObject);
var
  CurValue : real;
begin
  if ReadOnly then MessageBeep(0) else begin
    CurValue := Value;
    if Assigned(FOnDownClick)
      then FOnDownClick(Self)
      else Value := CurValue - FIncrement;
  end;
end;

procedure tsDecimalSpinEdit.SetDecimalPlaces(New : Integer);
begin
  if fDecimalPlaces <> New then begin
    fDecimalPlaces := New;
    Value := CheckValue(Value);
  end;
end;

procedure tsDecimalSpinEdit.SetValue(NewValue: Extended);
begin
  if MaxValue > MinValue then FValue := max(min(NewValue, MaxValue), MinValue) else FValue := NewValue;
  ValueChanging := True;
  if not TextChanging then begin
    SendMessage(Handle, WM_SETTEXT, 0, Longint(PChar(FloatToStrF(CheckValue(FValue), ffFixed, 18, fDecimalPlaces))));
    if not (csLoading in ComponentState) and Assigned(OnChange) then OnChange(Self);
  end;
  ValueChanging := False;
end;

function tsDecimalSpinEdit.CheckValue (NewValue: Extended): Extended;
begin
  Result := NewValue;
  if (FMinValue <> 0) and (NewValue < FMinValue)
    then Result := FMinValue
    else if (FMaxValue <> 0) and (NewValue > FMaxValue) then Result := FMaxValue;
end;

function tsDecimalSpinEdit.IsValidChar(var Key: AnsiChar): Boolean;
var
  bIsDecSeparator : boolean;
begin
  Result := False;
  case Key of
    Chr(VK_RETURN) : begin
      Key := #0;
      Exit;
    end;
    Char(VK_BACK), Chr(VK_ESCAPE) : Exit;
  end;

  if FUseSystemDecSeparator then bIsDecSeparator := Key = AnsiChar(DecimalSeparator) else bIsDecSeparator := CharInSet(Key, ['.', ',']);
  Result := bIsDecSeparator or CharInSet(Key, ['+', '-', '0'..'9']) or (Key < #32);

  if (bIsDecSeparator and (DecimalPlaces <= 0))
    then Result := False
    else if (bIsDecSeparator and (Pos(Key, Text) <> 0))
      then Result := False
      else if (bIsDecSeparator and ((Pos('+', Text) - 1 >= SelStart) or (Pos('-', Text) - 1 >= SelStart)))
        then Result := False
        else if (CharInSet(Key, ['+', '-']) and ((SelStart <> 0) or (Pos('+', Text) <> 0) or (Pos('-', Text) <> 0))) and (SelLength <= Length(Text) - 1)
          then Result := False
          else if not FEditorEnabled and Result
            then Result := False;

  if not Result then Key := #0;
end;

procedure TsDecimalSpinEdit.CMMouseWheel(var Message: TCMMouseWheel);
begin
  inherited;
  if not ReadOnly and (Message.Result = 0) then begin
    Value := Value + Increment * (Message.WheelDelta div 120);
    Message.Result := 1
  end;
end;

function TsDecimalSpinEdit.GetValue: Extended;
{$IFDEF DELPHI6UP}
var
  v : Extended;
{$ENDIF}
begin
  if not TextChanging then Result := FValue else
{$IFDEF DELPHI6UP}
    if TryStrToFloat(Text, V)
      then Result := V
      else Result := 0;
{$ELSE}
  try
    if Text = '' then Result := 0 else Result := StrToFloat(Text);
  except
    Result := 0;
  end;
{$ENDIF}
end;

procedure TsDecimalSpinEdit.CreateWnd;
begin
  inherited;
  if HandleAllocated then FormatText;
end;

procedure TsDecimalSpinEdit.CMChanged(var Message: TMessage);
begin
  inherited;
  if not (csLoading in ComponentState) and not ValueChanging then begin
    TextChanging := True;
    if (Text = '') or (Text = '-') then Value := 0 else Value := StrToFloat(Text);
    TextChanging := False;
  end;
end;

procedure TsDecimalSpinEdit.FormatText;
begin
  ValueChanging := True;
  if not TextChanging then begin
    SendMessage(Handle, WM_SETTEXT, 0, Longint(PChar(FloatToStrF(CheckValue(FValue), ffFixed, 18, FDecimalPlaces))));
  end;
  ValueChanging := False;
end;

procedure TsDecimalSpinEdit.WMPaste(var Message: TWMPaste);
{$IFDEF DELPHI6UP}
var
  OldValue, NewValue : extended;
{$ENDIF}  
begin
  if not FEditorEnabled or ReadOnly then Exit;
{$IFDEF DELPHI6UP}
  OldValue := Value;
{$ENDIF}
  inherited;
{$IFDEF DELPHI6UP}
  if not TryStrToFloat(Text, NewValue) then Text := FloatToStr(OldValue);
{$ENDIF}
end;

{TsTimerSpeedButton}

destructor TsTimerSpeedButton.Destroy;
begin
  if FRepeatTimer <> nil then FreeAndNil(FRepeatTimer);
  inherited Destroy;
end;

procedure TsTimerSpeedButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  Down := True;
  if tbAllowTimer in FTimeBtnState then begin
    if FRepeatTimer = nil then FRepeatTimer := TTimer.Create(Self);

    FRepeatTimer.OnTimer := TimerExpired;
    FRepeatTimer.Interval := InitRepeatPause;
    FRepeatTimer.Enabled  := True;
  end;
end;

procedure TsTimerSpeedButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Down := False;
  inherited MouseUp (Button, Shift, X, Y);
  if FRepeatTimer <> nil then FRepeatTimer.Enabled  := False;
end;

procedure TsTimerSpeedButton.TimerExpired(Sender: TObject);
begin
  FRepeatTimer.Interval := RepeatPause;
  if MouseCapture then begin
    try
      Click;
    except
      FRepeatTimer.Enabled := False;
      raise;
    end;
  end;
end;

procedure TsTimerSpeedButton.Paint;
var
  R: TRect;
begin
  if (csDestroying in ComponentState) or (csLoading in ComponentState) then Exit;
  inherited Paint;
  if tbFocusRect in FTimeBtnState then begin
    R := Bounds(0, 0, Width, Height);
    InflateRect(R, -3, -3);
    if Down then OffsetRect(R, 1, 1);
    DrawFocusRect(Canvas.Handle, R);
  end;
end;

constructor TsTimerSpeedButton.Create(AOwner: TComponent);
begin
  FOwner := TsSpinButton(AOwner);
  inherited Create(AOwner);
end;

procedure TsBaseSpinEdit.WndProc(var Message: TMessage);
begin
{$IFDEF LOGGED}
  AddToLog(Message);
{$ENDIF}
  inherited;
  if Message.MSG = SM_ALPHACMD then case Message.WParamHi of
    AC_REMOVESKIN, AC_SETNEWSKIN, AC_REFRESH : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
      FButton.FUpButton.Perform(Message.Msg, Message.WParam, Message.LParam);
      FButton.FdownButton.Perform(Message.Msg, Message.WParam, Message.LParam);
      if Message.WParamHi in [AC_REFRESH, AC_REMOVESKIN] then begin
        FButton.FUpButton.Invalidate;
        FButton.FDownButton.Invalidate;
      end
      else begin
        FButton.FUpButton.Enabled := True;
        FButton.FDownButton.Enabled := True;
      end;
      FButton.SetUpGlyph(nil);
      FButton.SetDownGlyph(nil);
      SetEditRect;
    end;
    AC_ENDPARENTUPDATE : FButton.Repaint;
    AC_GETBG : InitBGInfo(SkinData, PacBGInfo(Message.LParam), 0);
    AC_GETCONTROLCOLOR : begin
      Message.Result := GetBGColor(SkinData, 0);
{
      if not Enabled then begin
        TColor(Message.Result) := MixColors(GetControlColor(Parent), TColor(Message.Result), 0.5);
      end;
}
    end;
  end
  else case Message.MSG of
    CM_MOUSEENTER, CM_MOUSELEAVE : begin
      FButton.FUpButton.SkinData.FMouseAbove := False;
      FButton.FUpButton.SkinData.BGChanged := True;
      FButton.FUpButton.Perform(SM_ALPHACMD, MakeWParam(0, AC_STOPFADING), 0);
      FButton.FUpButton.GraphRepaint;
      FButton.FDownButton.SkinData.FMouseAbove := False;
      FButton.FDownButton.SkinData.BGChanged := True;
      FButton.FDownButton.Perform(SM_ALPHACMD, MakeWParam(0, AC_STOPFADING), 0);
      FButton.FDownButton.GraphRepaint;
    end;
    CM_ENABLEDCHANGED : begin
      FButton.Enabled := Enabled;
      if SkinData.Skinned then FButton.Visible := Enabled else begin
        FButton.FUpButton.Enabled := Enabled;
        FButton.FDownButton.Enabled := Enabled;
      end
    end;
    WM_PAINT : if SkinData.Skinned then begin
      SkinData.Updating := SkinData.Updating;
      if not SkinData.Updating and Enabled then begin
        Button.FUpButton.Perform(SM_ALPHACMD, MakeWParam(0, AC_STOPFADING), 0);
        Button.FUpButton.SkinData.BGChanged := True;
        Button.FDownButton.Perform(SM_ALPHACMD, MakeWParam(0, AC_STOPFADING), 0);
        Button.FDownButton.SkinData.BGChanged := True;
      end;
    end;
    WM_SIZE, CM_FONTCHANGED : SetEditRect;
    WM_SETFOCUS : if AutoSelect then begin
      Self.SelectAll
    end;
    CM_COLORCHANGED : begin
      if SkinData.CustomColor then PrepareCache;
      RedrawWindow(Handle, nil, 0, RDW_FRAME or RDW_INVALIDATE);
    end;
  end;
end;

procedure TsTimerSpeedButton.PaintTo(DC: hdc; P: TPoint);
begin
  PrepareCache;
  BitBlt(DC, P.X, P.Y, Width, Height, SkinData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure TsTimerSpeedButton.DrawGlyph;
var
  C : TColor;
  P : TPoint;
  aCanvas : TCanvas;
begin
  if (Glyph = nil) or Glyph.Empty then begin
    if (SkinData.SkinIndex > -1) and not FOwner.FOwner.SkinData.CustomFont then begin
      if CurrentState = 0 then C := ColorToRGB(SkinData.SkinManager.gd[FOwner.FOwner.SkinData.SkinIndex].FontColor[1]) else begin
        if SkinData.SkinManager.gd[SkinData.SkinIndex].States > 1
          then C := ColorToRGB(SkinData.SkinManager.gd[SkinData.SkinIndex].HotFontColor[1])
          else C := ColorToRGB(SkinData.SkinManager.gd[SkinData.SkinIndex].FontColor[1])
      end;
    end
    else begin
      if Enabled then C := ColorToRGB(Font.Color) else C := ColorToRGB(clGrayText)
    end;
    if SkinData.Skinned then aCanvas := SkinData.FCacheBmp.Canvas else aCanvas := Canvas;

    aCanvas.Pen.Color := C;

    aCanvas.Brush.Style := bsSolid;
    aCanvas.Brush.Color := clFuchsia;
    aCanvas.FillRect(Rect(0, 0, Glyph.Width, Glyph.Height));

    aCanvas.Pen.Style := psSolid;
    aCanvas.Brush.Color := C;

    P.X := (Width - 9) div 2;
    P.Y := (Height - 5) div 2;

    if Up
      then aCanvas.Polygon([Point(P.X + 1, P.Y + 4), Point(P.X + 7, P.Y + 4), Point(P.X + 4, P.Y + 1)])
      else aCanvas.Polygon([Point(P.X + 1, P.Y + 1), Point(P.X + 7, P.Y + 1), Point(P.X + 4, P.Y + 4)]);
  end
  else inherited;
end;

{ TsSpinButton }

constructor TsTimePicker.Create(AOwner:TComponent);
begin
  inherited create(AOwner);
  MaxHour := 24;
  FShowSeconds := True;
  FDoBeep := False;
  fHour := 0;
  fMin := 0;
  fSec := 0;
end;

procedure TsTimePicker.CMExit(var Message: TCMExit);
begin
  inherited;
  if CheckValue(Value) <> Value then SetValue(Value);
end;

procedure TsTimePicker.UpClick (Sender: TObject);
var
  cPortion : TacTimePortion;
begin
  cPortion := Portion;
  if ReadOnly then begin if FDoBeep then MessageBeep(0); end else if length(Text) = TextLength then begin
    DecodeValue;
    case Portion of
      tvHours : SetHour(FHour + 1);
      tvMinutes : SetMin(FMin + 1);
      tvSeconds : SetSec(FSec + 1);
    end;
    if ShowSeconds
      then Text := Format('%0.2d:%0.2d:%0.2d', [fHour, fMin, fSec])
      else Text := Format('%0.2d:%0.2d', [fHour, fMin]);
    if (not (csLoading in ComponentState)) then begin
      case cPortion of
        tvHours : SelStart := 0;
        tvMinutes : SelStart := 3;
        tvSeconds : SelStart := 6;
      end;
      FPos := SelStart + 2;
      SelLength := 2;
    end;
  end;
end;

procedure TsTimePicker.DownClick (Sender: TObject);
var
  cPortion : TacTimePortion;
begin
  cPortion := Portion;
  if ReadOnly then begin if FDoBeep then MessageBeep(0); end else if length(Text) = TextLength then begin
    DecodeValue;
    case Portion of
      tvHours : SetHour(FHour - 1);
      tvMinutes : SetMin(FMin - 1);
      tvSeconds : SetSec(FSec - 1);
    end;
    if ShowSeconds
      then Text := Format('%0.2d:%0.2d:%0.2d', [fHour, fMin, fSec])
      else Text := Format('%0.2d:%0.2d', [fHour, fMin]);
    if (not (csLoading in ComponentState)) then begin
      case cPortion of
        tvHours : SelStart := 0;
        tvMinutes : SelStart := 3;
        tvSeconds : SelStart := 6;
      end;
      FPos := SelStart + 2;
      SelLength := 2;
    end;
  end;
end;

function TsTimePicker.GetValue: TDateTime;
begin
  Result := 0;
  if length(Text) = TextLength then try
    DecodeValue;
    Result := EncodeTime(FHour, FMin, Sec, 0)
  except
    Result := 0;
  end;
end;

procedure TsTimePicker.SetValue(NewValue: TDateTime);
var
  NewText: String;
  dMSec: Word;
begin
  DecodeTime(NewValue, FHour, FMin, FSec, dMSec);
  if ShowSeconds
    then NewText := Format('%0.2d:%0.2d:%0.2d', [FHour, FMin, FSec])
    else NewText := Format('%0.2d:%0.2d', [FHour, FMin]);
  if not (csLoading in ComponentState) then Text := NewText;
end;

function TsTimePicker.CheckValue (NewValue: TDateTime): TDateTime;
begin
  if NewValue < 0 then Result := 0 else Result := NewValue;
end;

function TsTimePicker.IsValidChar(var Key: AnsiChar): Boolean;
var
  i : integer;
{$IFDEF TNTUNICODE}
  c : PWideChar;
{$ENDIF}
  s : string;
begin
  Result := False;
  i := 0;
  if not FEditorEnabled or CharInSet(Key, [Chr(VK_ESCAPE), Chr(VK_RETURN), #0]) then begin
    Key := #0;
    Exit;
  end;
  Result := CharInSet(Key, ['0'..'9']);
  if Result then begin
{$IFDEF TNTUNICODE}
    c := PWideChar(Text);
    s := WideCharToString(c);
{$ELSE}
    s := Text;
{$ENDIF}
    case FPos of
      1 : i := StrToInt(Key + s[2]);
      2 : i := StrToInt(s[1] + Key);
      4 : i := StrToInt(Key + s[4]);
      5 : i := StrToInt(s[4] + Key);
      7 : i := StrToInt(Key + s[8]);
      8 : i := StrToInt(s[7] + Key)
      else if not (Key in ['0', '1']) then i := 99; // If selected all, then ignored
    end;
    if FPos in [1, 2] then begin
      if i > 23 then Result := False;
    end
    else if i > 59 then Result := False;
  end;
  if not Result then Key := #0;
end;

procedure TsBaseSpinEdit.PrepareCache;
var
  bw : integer;
begin
  InitCacheBmp(SkinData);
  PaintItem(SkinData, GetParentCache(SkinData), True, integer(ControlIsActive(SkinData)), Rect(0, 0, Width, Height), Point(Left, top), SkinData.FCacheBmp, False);
  PaintText;

  if not Enabled then begin
    bw := integer(BorderStyle <> bsNone) * (1 + integer(Ctl3d));
    SkinData.FCacheBmp.Canvas.Lock;
    FButton.PaintTo(SkinData.FCacheBmp.Canvas.Handle, Point(FButton.Left + bw, FButton.Top + bw));
    SkinData.FCacheBmp.Canvas.UnLock;
    BmpDisabledKind(SkinData.FCacheBmp, DisabledKind, Parent, GetParentCache(SkinData), Point(Left, Top));
  end;
  SkinData.BGChanged := False;
end;

procedure TsTimePicker.KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_UP : UpClick (Self);
    VK_DOWN : DownClick (Self);
    VK_RIGHT : if (Shift = []) then IncPos else begin
      FPos := min(TextLength, FPos + 1);
      inherited;
      exit;
    end;
    VK_LEFT : if (Shift = []) then SetPos(max(1, FPos - 1 - integer(FPos in [4, 7])), (Shift = [])) else begin
      FPos := max(1, FPos - 1);
      inherited;
      exit;
    end;
    VK_BACK, VK_DELETE : if not AllEditSelected(Self) then begin
      ReplaceAtPos(FPos, '0');
      if Key = VK_BACK then begin
        Key := VK_LEFT;
        KeyDown(Key, Shift);
      end
      else begin
        HighlightPos(FPos);
        Key := 0;
      end
    end
    else begin
      if (not (csLoading in ComponentState)) and not (csDesigning in ComponentState) and Visible then begin
        SelStart := 0;
        SelLength := 0;
      end;
      Text := EmptyText;
      SetPos(1);
    end;
  end;
  if Key in [VK_BACK, VK_SPACE, VK_LEFT..VK_DOWN, VK_DELETE] then Key := 0;
  inherited;
  case Key of
    VK_END : begin
      FPos := TextLength;
      if (Shift = []) then begin
        if (not (csLoading in ComponentState)) and not (csDesigning in ComponentState) and Visible then begin
          SelStart := TextLength - 1;
          SelLength := 1;
        end;
        Key := 0;
      end;
    end;
    VK_HOME : begin
      if (Shift = []) then begin
        if (not (csLoading in ComponentState)) and not (csDesigning in ComponentState) and Visible then begin
          SelStart := 0;
          SelLength := 1;
        end;
        Key := 0;
      end
      else SelStart := FPos;
      FPos := 1;
    end;
  end
end;

procedure TsTimePicker.KeyPress(var Key: Char);
var
  C : AnsiChar;
begin
  C := AnsiChar(Key);
  if not IsValidChar(C) then begin
    if C = #0 then begin
      Key := #0;
      if FDoBeep then MessageBeep(0);
    end
    else begin
      inherited;
    end;
    Exit;
  end;
  if AllEditSelected(Self) then SetPos(1);
  inherited;
  ReplaceAtPos(FPos, Key);
  Key := #0;
  IncPos;
end;

procedure TsTimePicker.HighlightPos(APos: integer);
begin
  if (not (csLoading in ComponentState)) and not (csDesigning in ComponentState) and Visible then begin
    SelStart := APos - 1;
    SelLength := 1;
  end
end;

procedure TsTimePicker.SetPos(NewPos: integer; Highlight: boolean);
begin
  FPos := NewPos;
  if FPos in [3, 6] then dec(FPos);
  if Highlight then HighlightPos(FPos);
end;

procedure TsTimePicker.ReplaceAtPos(APos : integer; AChar : Char);
var
  s : string;
begin
  if FEditorEnabled and (APos <= Length(Text)) then begin
    s := Text;
    s[APos] := AChar;
    Text := s;
  end;
end;

procedure TsTimePicker.IncPos;
begin
  SetPos(min(TextLength, FPos + 1 + integer(FPos in [2, 5])));
end;

function TsTimePicker.Portion: TacTimePortion;
var
  FCurPos: DWord;
begin
  FCurPos := DWord(SendMessage(Handle, EM_GETSEL, 0, 0)) mod $10000;
  case FCurPos of
    0..2 : Result := tvHours;
    3..5 : Result := tvMinutes
    else Result := tvSeconds;
  end
end;

procedure TsTimePicker.DecodeValue;
var
  s : string;
begin
  s := Text;
  FHour := StrToInt(copy(s, 1, 2));
  FMin := StrToInt(copy(s, 4, 2));
  if (TextLength <= Length(Text)) and ShowSeconds
    then FSec := StrToInt(copy(s, 7, 2))
    else FSec := 0;
end;

procedure TsTimePicker.SetHour(NewHour: integer);
begin
  if NewHour >= MaxHour then SetHour(NewHour - MaxHour) else if NewHour < 0 then SetHour(NewHour + MaxHour) else FHour := NewHour;
end;

procedure TsTimePicker.SetMin(NewMin: integer);
begin
  if NewMin >= 60 then begin
    SetHour(FHour + 1);
    SetMin(NewMin - 60);
  end
  else if NewMin < 0 then begin
    SetHour(FHour - 1);
    SetMin(NewMin + 60);
  end
  else FMin := NewMin
end;

procedure TsTimePicker.SetSec(NewSec: integer);
begin
  if NewSec >= 60 then begin
    SetMin(FMin + 1);
    SetSec(NewSec - 60);
  end
  else if NewSec < 0 then begin
    SetMin(FMin - 1);
    SetSec(NewSec + 60);
  end
  else FSec := NewSec
end;

procedure TsTimePicker.Change;
begin
  inherited;
end;

procedure TsTimePicker.Loaded;
begin
  inherited;
  if AllEditSelected(Self) then FPos := TextLength + 1 else SetPos(1);
  if Text = '' then Text := EmptyText;
end;

procedure TsTimePicker.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  FCurPos: DWord;
begin
  inherited;
  if SelLength = 0 then begin
    FCurPos := DWord(SendMessage(Handle, EM_GETSEL, 0, 0)) mod $10000;
    SetPos(min(TextLength, FCurPos + 1))
  end;
end;

procedure TsTimePicker.SetShowSeconds(const Value: boolean);
var
  CurValue : TDateTime;
begin
  if FShowSeconds <> Value then begin
    CurValue := Self.Value;
    FShowSeconds := Value;
    SetValue(CurValue);
    if not (csLoading in ComponentState) and Visible then Repaint;
  end;
end;

function TsTimePicker.EmptyText: acString;
begin
  if not ShowSeconds then Result := '00:00' else Result := '00:00:00';
end;

function TsTimePicker.TextLength: integer;
begin
  if not ShowSeconds then Result := 5 else Result := 8;
end;

function TsTimePicker.Sec: word;
begin
  if FShowSeconds then Result := FSec else Result := 0;
end;

procedure TsTimePicker.SetUse12Hour(const Value: boolean);
begin
  FUse12Hour := Value;
  if Value then MaxHour := 12 else MaxHour := 24;
end;

procedure TsBaseSpinEdit.SetAlignment(const Value: TAlignment);
begin
  if FAlignment <> Value then begin
    FAlignment := Value;
    RecreateWnd;
  end;
end;

procedure TsBaseSpinEdit.PaintText;
var
  R : TRect;
  s : acString;
  i : integer;
  BordWidth : integer;
  Flags : Cardinal;
begin
  if Alignment = taLeftJustify then inherited else begin
    SkinData.FCacheBMP.Canvas.Font.Assign(Font);
    if BorderStyle <> bsNone then BordWidth := 1 + integer(Ctl3D) else BordWidth := 0;
    BordWidth := BordWidth {$IFDEF DELPHI7UP} + integer(BevelKind <> bkNone) * (integer(BevelOuter <> bvNone) + integer(BevelInner <> bvNone)) {$ENDIF};
    Flags := DT_TOP or DT_NOPREFIX or DT_SINGLELINE;
    R := Rect(BordWidth + 1, BordWidth + 1, Width - BordWidth - FButton.Width, Height - BordWidth);
  {$IFDEF TNTUNICODE}
    if PasswordChar <> #0
      then for i := 1 to Length(Text) do s := s + PasswordChar
      else s := Text;
    dec(R.Bottom);
    dec(R.Top);
    sGraphUtils.WriteUniCode(SkinData.FCacheBmp.Canvas, s, True, R, Flags or GetStringFlags(Self, Alignment) and not DT_VCENTER, SkinData, ControlIsActive(SkinData) and not ReadOnly);
  {$ELSE}
    if PasswordChar <> #0 then begin
      for i := 1 to Length(Text) do s := s + PasswordChar;
    end
    else s := Text;
    acWriteTextEx(SkinData.FCacheBMP.Canvas, PacChar(s), True, R, Flags or Cardinal(GetStringFlags(Self, Alignment)) and not DT_VCENTER, SkinData, ControlIsActive(SkinData));
  {$ENDIF}
  end;
end;

procedure TsBaseSpinEdit.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := Message.Result and not DLGC_WANTALLKEYS;
end;

end.
