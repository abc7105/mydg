unit sCurrEdit;
{$I sDefs.inc}

interface

uses SysUtils, Windows,  Messages, Classes, Graphics, Controls, Menus, Forms,
  StdCtrls, Mask, Buttons, sCustomComboEdit, acntUtils,
{$IFNDEF ALITE}
  sCalcUnit,
{$ENDIF}
  sConst;

type

{ TsCustomNumEdit }

{$IFNDEF NOTFORHELP}
  TsCustomNumEdit = class(TsCustomComboEdit)
  private
    FCanvas: TControlCanvas;
    FAlignment: TAlignment;
    FFocused: Boolean;
    FValue: Extended;
    FMinValue, FMaxValue: Extended;
    FDecimalPlaces: Cardinal;
    FBeepOnError: Boolean;
    FCheckOnExit: Boolean;
    FFormatOnEditing: Boolean;
    FFormatting: Boolean;
    FDisplayFormat: POldString;
    procedure SetFocused(Value: Boolean);
    procedure SetAlignment(Value: TAlignment);
    procedure SetBeepOnError(Value: Boolean);
    procedure SetDisplayFormat(const Value: string);
    function GetDisplayFormat: string;
    procedure SetDecimalPlaces(Value: Cardinal);
    function GetValue: Extended;
    procedure SetValue(AValue: Extended);
    function GetAsInteger: Longint;
    procedure SetMaxValue(AValue: Extended);
    procedure SetMinValue(AValue: Extended);
    function GetText: string;
    procedure SetText(const AValue: string);
    function TextToValText(const AValue: string): string;
    function CheckValue(NewValue: Extended; RaiseOnError: Boolean): Extended;
    function IsFormatStored: Boolean;
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure WMPaste(var Message: TMessage); message WM_PASTE;
    procedure CalcWindowClose(Sender: TObject; var Action: TCloseAction);          //KJS
  protected
    procedure Change; override;
    procedure ReformatEditText; dynamic;
    procedure DataChanged; virtual;
    function DefFormat: string; virtual;
    procedure KeyPress(var Key: Char); override;
    function IsValidChar(Key: Char): Boolean; virtual;
    function FormatDisplayText(Value: Extended): string;
    function GetDisplayText: string; virtual;
    procedure Reset; override;
    procedure CheckRange;
    procedure UpdateData;
    property Formatting: Boolean read FFormatting;
    property Alignment: TAlignment read FAlignment write SetAlignment default taRightJustify;
    property BeepOnError: Boolean read FBeepOnError write SetBeepOnError default True;
    property CheckOnExit: Boolean read FCheckOnExit write FCheckOnExit default False;
    property DecimalPlaces: Cardinal read FDecimalPlaces write SetDecimalPlaces default 2;
    property DisplayFormat: string read GetDisplayFormat write SetDisplayFormat stored IsFormatStored;
    property MaxValue: Extended read FMaxValue write SetMaxValue;
    property MinValue: Extended read FMinValue write SetMinValue;
    property Text: string read GetText write SetText stored False;
    property MaxLength default 0;
    procedure PopupWindowShow; override;
    property ClickKey;
    procedure PaintText; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear; override;
    procedure WndProc (var Message: TMessage); override;
    property AsInteger: Longint read GetAsInteger;
    property DisplayText: string read GetDisplayText;
    property DroppedDown;
    property Value: Extended read GetValue write SetValue;
  end;
{$ENDIF} // NOTFORHELP

{ TsCalcEdit }

  TsCalcEdit = class(TsCustomNumEdit)
  public
    property AsInteger;
{$IFNDEF NOTFORHELP}
    constructor Create(AOwner: TComponent); override;
  published
    property ClickKey;
    property AutoSelect;
    property BeepOnError;
    property DirectInput;
    property DragCursor;
    property Enabled;
    property Font;
    property HideSelection;
    property ImeMode;
    property ImeName;
    property MaxLength;
    property ParentFont;
    property ParentShowHint;
    property PopupAlign;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnButtonClick;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
{$ENDIF} // NOTFORHELP
    property Alignment;
    property CheckOnExit;
    property DecimalPlaces;
    property DisplayFormat;
    property MaxValue;
    property MinValue;
    property Text;
    property Value;
  end;

implementation

uses Consts, sVclUtils, sStyleSimply, sMessages, sMaskData, sGraphUtils, sCommonData, sGlyphUtils, sSKinManager;

{ TsCustomNumEdit }

constructor TsCustomNumEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAlignment := taRightJustify;
  FDisplayFormat := NewStr(DefFormat);
  MaxLength := 0;
  FDecimalPlaces := 2;
  FBeepOnError := True;
  inherited Text := '';
  inherited Alignment := taLeftJustify;
  DataChanged;
  PopupWidth := 213;
  PopupHeight := 149;
end;

destructor TsCustomNumEdit.Destroy;
begin
  if FPopupWindow <> nil then FreeAndNil(FPopupWindow);
  if Assigned(FCanvas) then FreeAndNil(FCanvas);
  DisposeStr(FDisplayFormat);
  inherited Destroy;
end;

function TsCustomNumEdit.DefFormat: string;
begin
  Result := '### ### ##0.00;-### ### ##0.00;0';
end;

function TsCustomNumEdit.IsFormatStored: Boolean;
begin
  Result := (DisplayFormat <> DefFormat);
end;

function TsCustomNumEdit.IsValidChar(Key: Char): Boolean;
var
  S: string;
  SelStart, SelStop, DecPos: Integer;
  RetValue: Extended;
begin
  Result := False;
  if (Key = '-') and ((MinValue >= 0) and (MaxValue <> MinValue))  then Exit;
  S := EditText;
  GetSel(SelStart, SelStop);
  System.Delete(S, SelStart + 1, SelStop - SelStart);
  System.Insert(Key, S, SelStart + 1);
  S := TextToValText(S);
  DecPos := Pos(DecimalSeparator, S);
  if (DecPos > 0) then begin
    SelStart := Pos('E', UpperCase(S));
    if (SelStart > DecPos) then DecPos := SelStart - DecPos else DecPos := Length(S) - DecPos;
    if DecPos > Integer(FDecimalPlaces) then Exit;
  end;
  Result := IsValidFloat(S, RetValue);
  if Result and (FMinValue >= 0) and (FMaxValue > 0) and (RetValue < 0) then Result := False;
end;

procedure TsCustomNumEdit.KeyPress(var Key: Char);
begin
  if CharInSet(AnsiChar(Key), ['.', ','] - [ThousandSeparator]) then Key := DecimalSeparator;
  inherited KeyPress(Key);
  if not CharInSet(Key, [#8]) and not IsValidChar(Key) then begin
    if BeepOnError then MessageBeep(0);
    Key := #0;
  end
  else if Key = #27 then begin
    Reset;
    Key := #0;
  end;
end;

procedure TsCustomNumEdit.Reset;
begin
  DataChanged;
  SelectAll;
end;

procedure TsCustomNumEdit.SetBeepOnError(Value: Boolean);
begin
  if FBeepOnError <> Value then begin
    FBeepOnError := Value;
  end;
end;

procedure TsCustomNumEdit.SetAlignment(Value: TAlignment);
begin
  if FAlignment <> Value then begin
    FAlignment := Value;
    SkinData.Invalidate;
  end;
end;

procedure TsCustomNumEdit.SetDisplayFormat(const Value: string);
begin
  if DisplayFormat <> Value then begin
    AssignStr(FDisplayFormat, Value);
    SkinData.Invalidate;
    DataChanged;
  end;
end;

function TsCustomNumEdit.GetDisplayFormat: string;
begin
  Result := FDisplayFormat^;
end;

procedure TsCustomNumEdit.SetFocused(Value: Boolean);
begin
  if FFocused <> Value then begin
    FFocused := Value;
    if not Focused or not AutoSelect then SkinData.Invalidate;
    FFormatting := True;
    try
      DataChanged;
    finally
      FFormatting := False;
    end;
  end;
end;

procedure TsCustomNumEdit.SetDecimalPlaces(Value: Cardinal);
begin
  if FDecimalPlaces <> Value then begin
    FDecimalPlaces := Value;
    DataChanged;
    SkinData.Invalidate;
  end;
end;

function TsCustomNumEdit.FormatDisplayText(Value: Extended): string;
begin
  if DisplayFormat <> '' then begin
    Result := FormatFloat(DisplayFormat, Value)
  end
  else begin
    Result := FloatToStr(Value);
  end;
end;

function TsCustomNumEdit.GetDisplayText: string;
begin
  if not Focused then Result := FormatDisplayText(StrToFloat(TextToValText(Text))) else Result := EditText;
end;

procedure TsCustomNumEdit.Clear;
begin
  Text := '';
end;

procedure TsCustomNumEdit.DataChanged;
var
  EditFormat : string;
begin
  if EditMask = '' then begin
    EditFormat := '0';
    if FDecimalPlaces > 0 then EditFormat := EditFormat + '.' + MakeStr('#', FDecimalPlaces);
    EditText := FormatFloat(EditFormat, FValue);
  end;
end;

function TsCustomNumEdit.CheckValue(NewValue: Extended; RaiseOnError: Boolean): Extended;
begin
  Result := NewValue;
  if (FMaxValue <> FMinValue) then begin
    if (FMaxValue > FMinValue) then begin
      if NewValue < FMinValue
        then Result := FMinValue
        else if NewValue > FMaxValue then Result := FMaxValue;
    end
    else begin
      if FMaxValue = 0 then begin
        if NewValue < FMinValue then Result := FMinValue;
      end
      else if FMinValue = 0 then begin
        if NewValue > FMaxValue then Result := FMaxValue;
      end;
    end;
  end;
end;

procedure TsCustomNumEdit.CheckRange;
begin
  if not (csDesigning in ComponentState) and CheckOnExit then CheckValue(StrToFloat(TextToValText(EditText)), True);
end;

procedure TsCustomNumEdit.UpdateData;
var
  s : string;
  Minus : integer;
begin
  s := Text;
  if pos('-', s) = 1 then begin
    Delete(s, 1, 1);
    Minus := -1
  end
  else Minus := 1;
  FValue := CheckValue(StrToFloat(TextToValText('0' + s)), False) * Minus;
  Exit;
  Text := DelChars(Text, '?');
  Text := DelChars(Text, #13);
  Text := DelChars(Text, #10);
  FValue := CheckValue(StrToFloat(TextToValText('0' + Text)), False);
end;

function TsCustomNumEdit.GetValue: Extended;
begin
  if not (csDesigning in ComponentState) then
    try
      UpdateData;
    except
      FValue := FMinValue;
    end;
  Result := FValue;
end;

procedure TsCustomNumEdit.SetValue(AValue: Extended);
begin
  FValue := CheckValue(AValue, False);
  DataChanged;
  SkinData.Invalidate;
end;

function TsCustomNumEdit.GetAsInteger: Longint;
begin
  Result := Trunc(Value);
end;

procedure TsCustomNumEdit.SetMinValue(AValue: Extended);
begin
  if FMinValue <> AValue then begin
    FMinValue := AValue;
    Value := FValue;
  end;
end;

procedure TsCustomNumEdit.SetMaxValue(AValue: Extended);
begin
  if FMaxValue <> AValue then begin
    FMaxValue := AValue;
    Value := FValue;
  end;
end;

function TsCustomNumEdit.GetText: string;
begin
  Result := inherited Text;
  Result := DelChars(Result, '?');
  Result := DelChars(Result, #13);
  Result := DelChars(Result, #10);
end;

function TsCustomNumEdit.TextToValText(const AValue: string): string;
begin
  Result := DelRSpace(AValue);
  if DecimalSeparator <> ThousandSeparator then Result := DelChars(Result, ThousandSeparator);
  if (DecimalSeparator <> '.') and (ThousandSeparator <> '.') then Result := ReplaceStr(Result, '.', DecimalSeparator);
  if (DecimalSeparator <> ',') and (ThousandSeparator <> ',') then Result := ReplaceStr(Result, ',', DecimalSeparator);
  if Result = '' then Result := '0' else if Result = '-' then Result := '-0';
end;

procedure TsCustomNumEdit.SetText(const AValue: string);
begin
  if not (csReading in ComponentState) then begin
    FValue := CheckValue(StrToFloat(TextToValText(AValue)), False);
    DataChanged;
    SkinData.Invalidate;
  end;
end;

procedure TsCustomNumEdit.ReformatEditText;
var
  S: string;
  IsEmpty: Boolean;
  OldLen, SelStart, SelStop: Integer;
begin
  FFormatting := True;
  try
    S := inherited Text;
    OldLen := Length(S);
    IsEmpty := (OldLen = 0) or (S = '-');
    if HandleAllocated then GetSel(SelStart, SelStop);
    if not IsEmpty then S := TextToValText(S);
    S := FormatFloatStr(S, Pos(',', DisplayFormat) > 0);
    inherited Text := S;
    if HandleAllocated and (GetFocus = Handle) and not (csDesigning in ComponentState) then begin
      Inc(SelStart, Length(S) - OldLen);
      SetCursor(SelStart);
    end;
  finally
    FFormatting := False;
  end;
end;

procedure TsCustomNumEdit.Change;
begin
  if not FFormatting then begin
    if FFormatOnEditing and FFocused then ReformatEditText;
    inherited Change;
  end;
end;

procedure TsCustomNumEdit.WMPaste(var Message: TMessage);
var
  S: string;
begin
  S := EditText;
  try
    inherited;
    UpdateData;
  except
    EditText := S;
    SelectAll;
    if CanFocus then SetFocus;
    if BeepOnError then MessageBeep(0);
  end;
end;

procedure TsCustomNumEdit.CMEnter(var Message: TCMEnter);
begin
  SetFocused(True);
  if FFormatOnEditing then ReformatEditText;
  inherited;
end;

procedure TsCustomNumEdit.CMExit(var Message: TCMExit);
begin
  try
    CheckRange;
    UpdateData;
  except
    SelectAll;
    if CanFocus then SetFocus;
    raise;
  end;
  SetFocused(False);
  SetCursor(0);
  DoExit;
end;

procedure TsCustomNumEdit.PopupWindowShow;
begin
  FadingForbidden := True;
  if not Assigned(FPopupWindow) then begin
    FPopupWindow := TsCalcForm.Create(Self);
    TsCalcForm(FPopupWindow).Height := TsCalcForm(FPopupWindow).Height - 24;
  end;
  TsCalcForm(FPopupWindow).Position := poDefault;
  if TsCalcForm(FPopupWindow).sDragBar1 <> nil then TsCalcForm(FPopupWindow).sDragBar1.Visible := False;

  TsCalcForm(FPopupWindow).FPrecision := 16;
  TsCalcForm(FPopupWindow).FEditor := Self;
  TsCalcForm(FPopupWindow).SetText(Text);
  TsCalcForm(FPopupWindow).OnClose := CalcWindowClose;
  inherited;
  FadingForbidden := False;
end;

procedure TsCustomNumEdit.CalcWindowClose(Sender: TObject; var Action: TCloseAction);
begin
  Inherited;
end;

procedure TsCustomNumEdit.PaintText;
var
  R : TRect;
  s : string;
  bw : integer;
  al : TAlignment;
begin
  SkinData.FCacheBMP.Canvas.Font.Assign(Font);
  bw := BorderWidth;
  R := Rect(bw, bw, Width - bw - integer(ShowButton) * Button.Width, Height - bw);

  if IsActive then al := taLeftJustify else al := Alignment;
  if PasswordChar = #0 then
    WriteTextEx(SkinData.FCacheBMP.Canvas, PChar(DisplayText), True, R, DT_TOP or GetStringFlags(Self, al) or DT_NOPREFIX,
              SkinData, ControlIsActive(SkinData))
  else begin
    SetLength(s, Length(EditText));
    FillChar(s[1], Length(s), PasswordChar);
    WriteTextEx(SkinData.FCacheBMP.Canvas, PChar(s), True, R, DT_TOP or DT_SINGLELINE or DT_WORDBREAK or GetStringFlags(Self, al) or DT_NOPREFIX,
              SkinData, ControlIsActive(SkinData));
  end;
end;

procedure TsCustomNumEdit.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    CM_MOUSEENTER : if not (csDesigning in ComponentState) and SkinData.Skinned then begin // Preventing of client area repainting
      SkinData.FMouseAbove := True;
      DefaultManager.ActiveControl := Handle;
      ShowGlowingIfNeeded(SkinData);
      SkinData.BGChanged := True;
      SendMessage(Handle, WM_NCPAINT, 0, 0);
      Exit
    end;
  end;
  inherited;   
end;

{ TsCalcEdit }

constructor TsCalcEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDefBmpID := iBTN_CALC;
end;

end.
