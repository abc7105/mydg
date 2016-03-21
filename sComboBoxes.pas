unit sComboBoxes;
{$I sDefs.inc}
{.$DEFINE LOGGED}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, ComCtrls, sConst, acntUtils, sGraphUtils{$IFNDEF DELPHI5}, types{$ENDIF}, Dialogs,
  sCommonData, ImgList, sDefaults, sComboBox, {$IFNDEF DELPHI6UP}acD5Ctrls, {$ENDIF} acSBUtils{$IFDEF LOGGED}, sDebugMsgs{$ENDIF};

type
{$IFDEF DELPHI6UP}
  TsCustomComboBoxEx = class(TCustomComboBoxEx)
{$IFNDEF NOTFORHELP}
  private
    FDisabledKind: TsDisabledKind;
    FCommonData: TsCtrlSkinData;
    FBoundLabel: TsBoundLabel;
    FReadOnly: boolean;
    FShowButton: boolean;
    ExHandle : hwnd;
    procedure SetDisabledKind(const Value: TsDisabledKind);
    procedure WMDrawItem(var Message: TWMDrawItem); virtual;
    procedure SetReadOnly(const Value: boolean);
    procedure WMPaint(var Message: TWMPaint);
    procedure SetShowButton(const Value: boolean);
    function GetSelectedItem: TComboExItem;
  protected
    FDropDown : boolean;
    lboxhandle : hwnd;
    ListSW : TacScrollWnd;
    function BrdWidth : integer;
    function DrawSkinItem(aIndex: Integer; aRect: TRect; aState: TOwnerDrawState; aDC : hdc) : boolean; virtual;
    function ButtonHeight : integer;
    function ButtonRect: TRect;
    procedure PaintButton;
    procedure PrepareCache;
    procedure ComboWndProc(var Message: TMessage; ComboWnd: HWnd; ComboProc: Pointer); override;
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure CreateWnd; override;
    destructor Destroy; override;
    procedure WndProc(var Message: TMessage); override;
{$ENDIF} // NOTFORHELP
    property SelectedItem : TComboExItem read GetSelectedItem;
  published
    property BoundLabel : TsBoundLabel read FBoundLabel write FBoundLabel;
    property DisabledKind : TsDisabledKind read FDisabledKind write SetDisabledKind default DefDisabledKind;
    property ShowButton : boolean read FShowButton write SetShowButton default True;
    property SkinData : TsCtrlSkinData read FCommonData write FCommonData;
    property ReadOnly : boolean read FReadOnly write SetReadOnly default False;
  end;
{$ENDIF}

  TsComboBoxEx = class(TsCustomComboBoxEx)
  published
{$IFNDEF NOTFORHELP}
{$IFDEF DELPHI7UP}
    property AutoCompleteOptions;
{$ENDIF}
    property ItemsEx;
    property Style;
{$IFDEF DELPHI6UP}
    property StyleEx;
{$ENDIF}
    property Action;
    property Align;
    property Anchors;
    property BiDiMode;
    property Color;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ImeMode;
    property ImeName;
    property ItemHeight;
    property MaxLength;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
{$IFDEF DELPHI6UP}
    property OnBeginEdit;
{$ENDIF}
    property OnChange;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDropDown;
{$IFDEF DELPHI6UP}
    property OnEndEdit;
{$ENDIF}
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnSelect;
    property OnStartDock;
    property OnStartDrag;
    property Images;
    property DropDownCount;
{$ENDIF} // NOTFORHELP
  end;

{$IFNDEF NOTFORHELP}
{$IFDEF DELPHI6UP}
  TsColorBoxStyles = (cbStandardColors, cbExtendedColors, cbSystemColors, cbIncludeNone, cbIncludeDefault, cbCustomColor, cbPrettyNames, cbCustomColors, cbSavedColors);
  TsColorBoxStyle = set of TsColorBoxStyles;

  TsCustomColorBox = class;
  TGetColorsEvent = procedure(Sender: TsCustomColorBox; Items: TStrings) of object;
  TOnColorName = procedure(Sender: TsCustomColorBox; Value : TColor; var ColorName: string) of object;
  TsCustomColorBox = class(TsCustomComboBoxEx)
  private
    FStyle: TsColorBoxStyle;
    FNeedToPopulate: Boolean;
    FListSelected: Boolean;
    FDefaultColorColor: TColor;
    FNoneColorColor: TColor;
    FSelectedColor: TColor;
    FShowColorName: boolean;
    FMargin: integer;
    FOnGetColors: TGetColorsEvent;
    FOnColorName: TOnColorName;
    function GetColor(Index: Integer): TColor;
    function GetColorName(Index: Integer): string;
    function GetSelected: TColor;
    procedure SetSelected(const AColor: TColor);
    procedure ColorCallBack(const AName: string);
    procedure SetDefaultColorColor(const Value: TColor);
    procedure SetNoneColorColor(const Value: TColor);
    procedure SetShowColorName(const Value: boolean);
    procedure SetMargin(const Value: integer);
    procedure WMDrawItem(var Message: TWMDrawItem); override;
  protected
    procedure CloseUp; override;
    function ColorRect(SourceRect : TRect; State: TOwnerDrawState) : TRect;
    function DrawSkinItem(aIndex: Integer; aRect: TRect; aState: TOwnerDrawState; aDC : hdc) : boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    function PickCustomColor: Boolean; virtual;
    procedure PopulateList;
    procedure Select; override;
    procedure SetStyle(AStyle: TsColorBoxStyle); reintroduce;
  public
    constructor Create(AOwner: TComponent); override;
    procedure WndProc(var Message: TMessage); override;
    procedure CreateWnd; override;
    property ColorNames[Index: Integer]: string read GetColorName;
    property Colors[Index: Integer]: TColor read GetColor;
  published
    property Style: TsColorBoxStyle read FStyle write SetStyle default [cbStandardColors, cbExtendedColors, cbSystemColors];
    property Margin : integer read FMargin write SetMargin default 0;
    property Selected: TColor read GetSelected write SetSelected default clBlack;
    property ShowColorName : boolean read FShowColorName write SetShowColorName default True;
    property DefaultColorColor: TColor read FDefaultColorColor write SetDefaultColorColor default clBlack;
    property NoneColorColor: TColor read FNoneColorColor write SetNoneColorColor default clBlack;
    property OnColorName: TOnColorName read FOnColorName write FOnColorName;
    property OnGetColors: TGetColorsEvent read FOnGetColors write FOnGetColors;
  end;
{$ENDIF}
{$ENDIF} // NOTFORHELP

  TsColorBox = class(TsCustomColorBox)
{$IFNDEF NOTFORHELP}
  published
//    property AutoComplete;
//    property AutoDropDown;
    property DisabledKind;
    property Anchors;
    property BevelEdges;
    property BevelInner;
    property BevelKind;
    property BevelOuter;
    property BiDiMode;
    property Color;
    property Constraints;
    property Ctl3D;
    property DropDownCount;
    property Enabled;
    property Font;
    property ItemHeight;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnChange;
    property OnCloseUp;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDropDown;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseUp;
    property OnSelect;
    property OnStartDock;
    property OnStartDrag;
{$ENDIF} // NOTFORHELP
    property Style;
    property Margin;
    property Selected;
    property ShowColorName;
    property DefaultColorColor;
    property NoneColorColor;
    property SkinData;
  end;

{$IFNDEF NOTFORHELP}
var
  ColDlg : TColorDialog = nil;
{$ENDIF} // NOTFORHELP

implementation

uses sAlphaGraph, sMaskData, sSkinProps, sMessages, sVCLUtils, acGlow{$IFDEF DELPHI7UP}, Themes{$ENDIF}, sDialogs, math, sColorDialog;

const
  StandardColorsCount = 16;
  ExtendedColorsCount = 4;
  NoColorSelected = TColor($FF000000);

{ TsCustomComboBoxEx }

{$IFDEF DELPHI6UP}
function TsCustomComboBoxEx.BrdWidth: integer;
begin
  Result := 2;
end;

function TsCustomComboBoxEx.ButtonHeight: integer;
begin
  if FCommonData.Skinned and (FCommonData.SkinManager.ConstData.ComboGlyph > -1)
    then Result := HeightOfImage(FCommonData.SkinManager.ma[FCommonData.SkinManager.ConstData.ComboGlyph])
    else Result := 16;
end;

function TsCustomComboBoxEx.ButtonRect: TRect;
var
  w : integer;
begin
  if (Style <> csExSimple) and FShowButton then w := GetSystemMetrics(SM_CXVSCROLL) else w := 0;
  if UseRightToLeftAlignment then Result.Left := BrdWidth else Result.Left := Width - w - BrdWidth;
  Result.Top := BrdWidth;
  Result.Right := Result.Left + w;
  Result.Bottom := Height - BrdWidth;
end;

procedure TsCustomComboBoxEx.WMDrawItem(var Message: TWMDrawItem);
var
  ds : TDrawItemStruct;
  State : TOwnerDrawState;
begin
  if SkinData.Skinned then begin
    ds :=  Message.DrawItemStruct^;
    if ds.itemState and ODS_COMBOBOXEDIT = ODS_COMBOBOXEDIT then State := [odComboBoxEdit] else State := [];
    if ds.itemState and ODS_FOCUS = ODS_FOCUS then State := State + [odFocused];
    if ds.itemState and ODS_SELECTED = ODS_SELECTED then State := State + [odSelected];
    if ds.itemState and ODS_HOTLIGHT = ODS_HOTLIGHT then State := State + [odSelected];
    if ds.itemState and ODS_DISABLED = ODS_DISABLED then State := State + [odDisabled];

    Message.Result := integer(DrawSkinItem(integer(ds.itemID), ds.rcItem, State, ds.hDC));
  end;
end;

procedure TsCustomComboBoxEx.ComboWndProc(var Message: TMessage; ComboWnd: HWnd; ComboProc: Pointer);
var
  ps : TPaintStruct;
  DC : hdc;
  R, cR: TRect;
begin
  if FReadOnly then case Message.Msg of
    WM_KEYDOWN, WM_CHAR, WM_KEYUP, WM_SYSKEYUP, CN_KEYDOWN, CN_CHAR, CN_SYSKEYDOWN, CN_SYSCHAR, WM_PASTE, WM_CUT, WM_CLEAR, WM_UNDO: Exit;
    WM_DRAWITEM : begin
      WMDrawItem(TWMDrawItem(Message));
      if Message.Result = 1 then Exit
    end;
  end;

 if not (csDestroying in ComponentState) and FCommonData.Skinned then case Message.Msg of
    WM_SETFOCUS : begin
      SendMessage(ExHandle, WM_SETREDRAW, 0, 0);
      inherited;
      SendMessage(ExHandle, WM_SETREDRAW, 1, 0);
      Exit;
    end;
    WM_KILLFOCUS : begin
      SendMessage(ExHandle, WM_SETREDRAW, 0, 0);
      inherited;
      SendMessage(ExHandle, WM_SETREDRAW, 1, 0);
      Exit;
    end;
    WM_ERASEBKGND : begin
      Message.Result := 0;
      Exit;
    end;
    WM_NCPAINT : begin
      Message.Result := 1;
      Exit;
    end;
    WM_PAINT : begin
      if ComboWnd = ExHandle then begin
        if (TWMPaint(Message).DC = 0) then begin
          DC := BeginPaint(ComboWnd, PS);
          SkinData.FUpdating := SkinData.Updating;
          if not SkinData.FUpdating then begin
            TWMPaint(Message).DC := DC;
            WMPaint(TWMPaint(Message));
          end;
          EndPaint(ComboWnd, PS);
        end
        else WMPaint(TWMPaint(Message));
      end
      else if Enabled then inherited else begin
        DC := BeginPaint(ComboWnd, PS);
        if not SkinData.BGChanged then begin
          GetWindowRect(Handle, R);
          GetWindowRect(ComboWnd, cR);
          BitBlt(DC, 0, 0, Width, Height, SkinData.FCacheBmp.Canvas.Handle, cR.Left - R.Left, cR.Top - R.Top, SRCCOPY);
        end;
        EndPaint(ComboWnd, PS);
      end;
      Message.Result := 0;
      Exit;
    end;
  end;
  inherited;
end;

constructor TsCustomComboBoxEx.Create(AOwner: TComponent);
begin
  inherited;
  FDisabledKind := DefDisabledKind;
  FCommonData := TsCtrlSkinData.Create(Self, True);
  FCommonData.COC := COC_TsCustom;
  if FCommonData.SkinSection = '' then FCommonData.SkinSection := s_ComboBox;
  FBoundLabel := TsBoundLabel.Create(Self, FCommonData);
  FReadOnly := False;
  FDropDown := False;
  FShowButton := True;
end;

procedure TsCustomComboBoxEx.CreateWnd;
begin
  inherited;
  FCommonData.Loaded;
  ExHandle := GetWindow(Handle, GW_CHILD);
{$IFDEF DELPHI7UP}
{$IFNDEF D2009}
  if CheckWin32Version(5, 1) and ThemeServices.ThemesEnabled then SendMessage(Handle, $1701{CB_SETMINVISIBLE}, WPARAM(DropDownCount), 0);
{$ENDIF}
{$ENDIF}
  if HandleAllocated and FCommonData.Skinned then begin
    if not FCommonData.CustomColor then begin
      Color := GetControlColor(Self);
//      Color := FCommonData.SkinManager.gd[FCommonData.SkinIndex].Color;
    end;
    if not FCommonData.CustomFont then Font.Color := FCommonData.SkinManager.gd[FCommonData.SkinIndex].FontColor[1];
  end;
end;

destructor TsCustomComboBoxEx.Destroy;
begin
  if lBoxHandle <> 0 then begin
    SetWindowLong(lBoxHandle, GWL_STYLE, GetWindowLong(lBoxHandle, GWL_STYLE) and not WS_THICKFRAME or WS_BORDER);
    UninitializeACScroll(lBoxHandle, True, False, ListSW);
    lBoxHandle := 0;
  end;
  FreeAndNil(FBoundLabel);
  if Assigned(FCommonData) then FreeAndNil(FCommonData);
  inherited;
end;

function TsCustomComboBoxEx.DrawSkinItem(aIndex: Integer; aRect: TRect; aState: TOwnerDrawState; aDC : hdc) : boolean;
var
  R, gRect, rText : TRect;
  DC : hdc;
  i, sNdx, imgNdx : integer;
  bSelected, bEdit : boolean;
  Bmp : TBitmap;
  CI : TCacheInfo;
  DrawStyle : longint;
  Size : TSize;
begin
  Result := True;
  if aDC <> 0 then DC := aDC else DC := SkinData.FCacheBmp.Canvas.Handle;
  bSelected := False;
  bEdit := (odComboBoxEdit in aState);
  CI.Ready := False;
  if bEdit then CI := MakeCacheInfo(FCommonData.FCacheBmp, aRect.Left, aRect.Top) else begin
    CI.Bmp := nil;
    CI.Ready := False;
    CI.FillColor := Color;
  end;
  if odSelected in aState then begin
    if bEdit and (Style <> csExDropDownList) then begin
      sNdx := SkinData.SkinIndex
    end
    else begin
      bSelected := True;
      sNdx := SkinData.SkinManager.GetSkinIndex(s_Selection);
    end;
  end
  else begin
    if bEdit then sNdx := SkinData.SkinIndex else begin
      sNdx := SkinData.SkinManager.GetSkinIndex(s_Edit);
    end;
  end;

  Bmp := CreateBmp32(WidthOf(aRect, True), HeightOf(aRect, True));
  Bmp.Canvas.Font.Assign(Font);
  rText := Rect(0, 0, Bmp.Width, Bmp.Height);

  if not bEdit and (aIndex >-1) then begin
    if ItemsEx.ComboItems[aIndex].Indent > -1 then begin
      i := 10 * ItemsEx.ComboItems[aIndex].Indent;
      FillDC(Bmp.Canvas.Handle, Rect(rText.Left, 0, rText.Left + i, Bmp.Height), Color);
      rText.Left := rText.Left + i;
    end;
    if IsRectEmpty(rText) then Exit;
  end;

  if bSelected then begin
    if (Style = csExDropDown) then begin
      FillDC(Bmp.Canvas.Handle, Rect(0, 0, Bmp.Width, Bmp.Height), Color);

      GetTextExtentPoint32(Bmp.Canvas.Handle, PChar(Items[aIndex]), Length(Items[aIndex]), Size);
      R := rText;
      if Images <> nil then R.Left := rText.Left + Images.Width + 2;
      R.Right := R.Left + Size.cx + 8;

      if sNdx < 0
        then FillDC(Bmp.Canvas.Handle, Rect(0, 0, Bmp.Width, Bmp.Height), SkinData.SkinManager.GetHighLightColor)
        else PaintItem(sNdx, s_Selection, CI, True, integer(odFocused in aState), R, Point(0, 0), Bmp, SkinData.SkinManager);
    end
    else begin
      if sNdx < 0
        then FillDC(Bmp.Canvas.Handle, Rect(0, 0, Bmp.Width, Bmp.Height), SkinData.SkinManager.GetHighLightColor)
        else PaintItem(sNdx, s_Selection, CI, True, integer(odFocused in aState), Rect(0, 0, Bmp.Width, Bmp.Height), Point(0, 0), Bmp, SkinData.SkinManager);
    end;
  end
  else begin
    if CI.Ready then BitBlt(Bmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, CI.Bmp.Canvas.Handle, CI.X, CI.Y, SRCCOPY) else FillDC(Bmp.Canvas.Handle, rText, Color);
  end;
  DrawStyle := DT_NOPREFIX or DT_EXPANDTABS or DT_SINGLELINE or DT_VCENTER or DT_NOCLIP;

  InflateRect(rText, -2, 0);
  if Images <> nil then begin
    gRect := rText;
    gRect.Right := gRect.Left + Images.Width;
    rText.Left := gRect.Right + 4;
    if (aIndex > -1) then begin
      if bEdit and (ItemsEx.ComboItems[aIndex].SelectedImageIndex > -1) then imgNdx := ItemsEx.ComboItems[aIndex].SelectedImageIndex else imgNdx := ItemsEx.ComboItems[aIndex].ImageIndex;
      if (imgNdx > -1) and (imgNdx < Images.Count) then begin
        i := (HeightOf(gRect) - Images.Height) div 2;
        Images.Draw(Bmp.Canvas, gRect.Left, gRect.Top + i, imgNdx, True);
      end;
    end;
  end;

  if bEdit and (Style = csExDropDown) then begin
    InflateRect(rText, 2, -1);
    DrawStyle := DrawStyle and not DT_VCENTER or DT_BOTTOM;
    WriteTextEx(Bmp.Canvas, PChar(Text), True, rText, DrawStyle, sNdx, (odFocused in aState), SkinData.SkinManager);
  end
  else begin
    if (aIndex >= 0) and (aIndex < Items.Count) then begin
      if sNdx < 0 then begin
        if odSelected in aState then Bmp.Canvas.Font.Color := SkinData.SkinManager.GetHighLightFontColor(odFocused in aState) else Bmp.Canvas.Font.Color := Font.Color;
        Bmp.Canvas.Brush.Style := bsClear;
        AcDrawText(Bmp.Canvas.Handle, Items[aIndex], rText, DrawStyle);
      end
      else WriteTextEx(Bmp.Canvas, PChar(Items[aIndex]), True, rText, DrawStyle, sNdx, (odFocused in aState), SkinData.SkinManager);
    end;
  end;

  BitBlt(DC, aRect.Left, aRect.Top, Bmp.Width, Bmp.Height, Bmp.Canvas.Handle, 0, 0, SRCCOPY);
  if (odFocused in aState) and (sNdx < 0) then DrawFocusRect(DC, aRect);
  FreeAndNil(Bmp);
end;

procedure TsCustomComboBoxEx.PaintButton;
var
  R : TRect;
  Mode : integer;
  c : TsColor;
  glIndex : integer;
  TmpBtn : TBitmap;
begin
  if FDropDown then Mode := 2 else if ControlIsActive(FCommonData) then Mode := 1 else Mode := 0;
  R := ButtonRect;

  if FCommonData.SkinManager.ConstData.ComboBtnIndex > -1 then begin
    TmpBtn := CreateBmpLike(FCommonData.FCacheBmp);
    BitBlt(TmpBtn.Canvas.Handle, 0, 0, TmpBtn.Width, TmpBtn.Height, FCommonData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
    PaintItem(FCommonData.SkinManager.ConstData.ComboBtnIndex, s_ComboBtn, MakeCacheInfo(FCommonData.FCacheBmp),
      True, Mode, R, Point(0, 0), FCommonData.FCacheBmp, FCommonData.SkinManager, FCommonData.SkinManager.ConstData.ComboBtnBG, FCommonData.SkinManager.ConstData.ComboBtnBGHot);
    FreeAndNil(TmpBtn);
  end;
  glIndex := FCommonData.SkinManager.ConstData.ComboGlyph;
  if FCommonData.SkinManager.IsValidImgIndex(glIndex) then begin
    if ControlIsActive(FCommonData)
      then c.C := FCommonData.SkinManager.gd[FCommonData.SkinIndex].HotColor
      else c.C := FCommonData.SkinManager.gd[FCommonData.SkinIndex].Color;

    DrawSkinGlyph(FCommonData.FCacheBmp, Point(R.Left + (WidthOf(R) - WidthOfImage(FCommonData.SkinManager.ma[glIndex])) div 2,
      (Height - ButtonHeight) div 2), Mode, 1, FCommonData.SkinManager.ma[FCommonData.SkinManager.ConstData.ComboGlyph], MakeCacheInfo(SkinData.FCacheBmp));
  end;
end;

procedure TsCustomComboBoxEx.PrepareCache;
var
  R : TRect;
  State : TOwnerDrawState;
begin
  InitCacheBmp(SkinData);
  if Style <> csExSimple then begin
    PaintItem(FCommonData, GetParentCache(FCommonData), True, integer(ControlIsActive(FCommonData)), Rect(0, 0, Width, Height), Point(Left, top), FCommonData.FCacheBmp, False);
    if FShowButton then PaintButton;

    if UseRightToLeftAlignment
      then R := Rect(WidthOf(ButtonRect) + BrdWidth + 1, BrdWidth + 1, Width - BrdWidth + 1, Height - BrdWidth - 1)
      else R := Rect(BrdWidth + 1, BrdWidth + 1, ButtonRect.Left - 1, Height - BrdWidth - 1);
    State := [odComboBoxEdit];

    if (GetFocus <> 0) and (Focused or SkinData.FFocused) and (Style = csExDropDownList) and Enabled
      then State := State + [odFocused, odSelected];
    DrawSkinItem(ItemIndex, R, State, 0);
  end
  else begin
    FCommonData.FCacheBmp.Height := ItemHeight + 8;
    PaintItem(FCommonData, GetParentCache(FCommonData), True, integer(ControlIsActive(FCommonData)), Rect(0, 0, Width, FCommonData.FCacheBmp.Height), Point(Left, top), FCommonData.FCacheBmp, False);
  end;
  if not Enabled then BmpDisabledKind(FCommonData.FCacheBmp, FDisabledKind, Parent, GetParentCache(FCommonData), Point(Left, Top));
  FCommonData.BGChanged := False;
end;

procedure TsCustomComboBoxEx.SetDisabledKind(const Value: TsDisabledKind);
begin
  if FDisabledKind <> Value then begin
    FDisabledKind := Value;
    FCommonData.Invalidate;
  end;
end;

procedure TsCustomComboBoxEx.SetReadOnly(const Value: boolean);
begin
  if FReadOnly <> Value then begin
    FReadOnly := Value;
  end;
end;

procedure TsCustomComboBoxEx.SetShowButton(const Value: boolean);
begin
  if FShowButton <> Value then begin
    FShowButton := Value;
    FCommonData.Invalidate;
  end;
end;

procedure TsCustomComboBoxEx.WMPaint(var Message: TWMPaint);
var
  DC : hdc;
  btnRect, clRect : TRect;
begin
  if SkinData.BGChanged then PrepareCache;
  UpdateCorners(FCommonData, 0);

  if Message.DC <> 0 then DC := Message.DC else DC := GetDC(Handle);

  if not FDropDown then begin
    clRect := acClientRect(ExHandle);
    BitBlt(DC, 0, 0, Width, Height, SkinData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
  end
  else begin
    btnRect := ButtonRect;
    BitBlt(DC, btnRect.Left, btnRect.Top, WidthOf(btnRect), HeightOf(btnRect), SkinData.FCacheBmp.Canvas.Handle, btnRect.Left, btnRect.Top, SRCCOPY);
  end;
  if Message.DC <> DC then ReleaseDC(Handle, DC);
end;

procedure TsCustomComboBoxEx.WndProc(var Message: TMessage);
var
  R : TRect;
  P : TPoint;
begin
{$IFDEF LOGGED}
  AddToLog(Message);
{$ENDIF}
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_CTRLHANDLED : begin Message.Result := 1; Exit end; // AlphaSkins supported
    AC_REMOVESKIN : if LongWord(Message.LParam) = LongWord(SkinData.SkinManager) then begin
      CommonWndProc(Message, FCommonData);
      if not FCommonData.CustomColor then Color := clWindow;
      if not FCommonData.CustomFont then Font.Color := clWindowText;
      if lBoxHandle <> 0 then begin
        SetWindowLong(lBoxHandle, GWL_STYLE, GetWindowLong(lBoxHandle, GWL_STYLE) and not WS_THICKFRAME or WS_BORDER);
        UninitializeACScroll(lBoxHandle, True, False, ListSW);
        lBoxHandle := 0;
      end;
      Exit
    end;
    AC_REFRESH : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
      CommonWndProc(Message, FCommonData);
      if FCommonData.Skinned then begin
        if not FCommonData.CustomColor then Color := FCommonData.SkinManager.gd[FCommonData.SkinIndex].Color;
        if not FCommonData.CustomFont then Font.Color := ColorToRGB(FCommonData.SkinManager.gd[FCommonData.SkinIndex].FontColor[1]);
      end;
      if HandleAllocated then RedrawWindow(Handle, nil, 0, RDW_ALLCHILDREN or RDW_INVALIDATE or RDW_UPDATENOW);
      Exit
    end;
    AC_SETNEWSKIN : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
      CommonWndProc(Message, FCommonData);
      if ListSW <> nil then ListSW.acWndProc(Message);
      Exit
    end;
    AC_ENDPARENTUPDATE : if FCommonData.Updating then begin
      FCommonData.Updating := False;
      Repaint;
      Exit
    end;
    AC_INVALIDATE : begin
      SkinData.BGChanged := True;
      RedrawWindow(Handle, nil, 0, RDW_ALLCHILDREN or RDW_INVALIDATE or RDW_UPDATENOW);
    end;
    AC_MOUSELEAVE : SendMessage(Handle, CM_MOUSELEAVE, 0, 0);
  end
  else begin
    case Message.Msg of
      WM_SYSCHAR, WM_SYSKEYDOWN, CN_SYSCHAR, CN_SYSKEYDOWN, WM_KEYDOWN, CN_KEYDOWN : case TWMKey(Message).CharCode of
        VK_SPACE..VK_DOWN, $39..$39, $41..$5A :
        if FReadOnly then Exit;
      end;
      WM_CHAR : if FReadOnly then Exit;
      WM_COMMAND, CN_COMMAND : if (Message.WParamHi in [CBN_DROPDOWN, CBN_SELCHANGE, CBN_EDITCHANGE]) and FReadOnly then begin
        Message.Result := 1;
        Exit;
      end;
      WM_DRAWITEM : begin
        WMDrawItem(TWMDrawItem(Message));
        if Message.Result = 1 then Exit
      end;
    end;
  end;
  if not ControlIsReady(Self) or not FCommonData.Skinned then inherited else begin
    case Message.Msg of
      WM_STYLECHANGED : begin
        lBoxHandle := 0;
        if Assigned(ListSW) then FreeAndNil(ListSW);
      end;
      CM_COLORCHANGED, CM_MOUSEWHEEL : FCommonData.BGChanged := True;
      CN_COMMAND : case TWMCommand(Message).NotifyCode of
        CBN_CLOSEUP : begin
          FCommonData.BGChanged := True;
          FDropDown := False;
          Perform(CM_MOUSELEAVE, 0, 0);
          RedrawWindow(ExHandle, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW);
        end;
        CBN_DROPDOWN : begin
          FDropDown := True;
          FCommonData.BGChanged := True;
        end;
      end;
      WM_SETFOCUS, CM_ENTER : if CanFocus and (FCommonData.CtrlSkinState and ACS_FOCUSCHANGING <> ACS_FOCUSCHANGING) then begin
        FCommonData.CtrlSkinState := FCommonData.CtrlSkinState or ACS_FOCUSCHANGING;
        FCommonData.FFocused := True;
        FCommonData.FMouseAbove := False;
        FCommonData.BGChanged := True;
        inherited;
        FCommonData.CtrlSkinState := FCommonData.CtrlSkinState and not ACS_FOCUSCHANGING;
        RedrawWindow(ExHandle, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW);
        Exit
      end;
      WM_KILLFOCUS, CM_EXIT: if (FCommonData.CtrlSkinState and ACS_FOCUSCHANGING <> ACS_FOCUSCHANGING) then begin
        FCommonData.CtrlSkinState := FCommonData.CtrlSkinState or ACS_FOCUSCHANGING;
        DroppedDown := False;
        FCommonData.FFocused := False;
        FCommonData.FMouseAbove := False;
        FCommonData.BGChanged := True;
        inherited;
        FCommonData.CtrlSkinState := FCommonData.CtrlSkinState and not ACS_FOCUSCHANGING;
        RedrawWindow(ExHandle, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW);
        Exit
      end;
      WM_NCPAINT : begin
        Message.Result := 0;
        Exit;
      end;
      WM_DRAWITEM : begin
        WMDrawItem(TWMDrawItem(Message));
        if Message.Result = 1 then Exit
      end;
      WM_ERASEBKGND : begin
        Message.Result := 1;
        Exit
      end;
      WM_PAINT : begin
        inherited;
        Exit
      end;
      CM_MOUSEENTER, CM_MOUSELEAVE : if not (csDesigning in ComponentState) then begin
        if not DroppedDown then begin
          GetWindowRect(Handle, R);
          if (Message.Msg = CM_MOUSELEAVE) then begin
            P := acMousePos;
            if PtInRect(R, P) then Exit;
          end
          else begin
            if FCommonData.FMouseAbove then Exit;
            SkinData.SkinManager.ActiveControl := Handle;
          end;

          FCommonData.FMouseAbove := Message.Msg = CM_MOUSEENTER;
          FCommonData.BGChanged := True;
          RedrawWindow(ExHandle, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW);
          inherited;
          if FCommonData.FMouseAbove then begin
            if SkinData.GlowID <> -1 then HideGlow(SkinData.GlowID);
            ShowGlowingIfNeeded(SkinData)
          end
          else ClearGlows;
        end
        else inherited;
        Exit;
      end;
      WM_COMMAND : case Message.WParamHi of
        CBN_DROPDOWN : if FReadOnly then Exit;
        CBN_CLOSEUP : begin
          FDropDown := False;
          Repaint;
        end;
      end;
{$IFNDEF TNTUNICODE}
      WM_CTLCOLORLISTBOX : if not (csLoading in ComponentState) and (lBoxHandle = 0) then begin
//        if Items.Count > DropDownCount then begin
          lBoxHandle := hwnd(Message.LParam);
          ListSW := TacComboListWnd.CreateEx(lboxhandle, nil, SkinData.SkinManager, s_Edit, True, Style = csExSimple);
//        end;
      end;
{$ENDIF}
      CB_SETITEMHEIGHT, CM_VISIBLECHANGED, CM_ENABLEDCHANGED, WM_SETFONT : begin
        FCommonData.BGChanged := True;
      end;
      WM_PRINT : begin
        SkinData.Updating := False;
        WMPaint(TWMPaint(Message));
        Exit;
      end;
    end;
    if CommonWndProc(Message, FCommonData) then Exit;
    inherited;
    if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
      AC_DROPPEDDOWN : Message.Result := integer(DroppedDown);
    end
    else case Message.Msg of
      CM_CHANGED, CM_TEXTCHANGED, CB_SETCURSEL : begin
        FCommonData.BGChanged := True;
        RedrawWindow(ExHandle, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW);
      end;
      CM_ENABLEDCHANGED : begin
        FCommonData.BGChanged := True;
        RedrawWindow(ExHandle, nil, 0, RDW_INVALIDATE or RDW_ALLCHILDREN);
      end;
    end;
  end;
  // Aligning of the bound label
  if Assigned(BoundLabel) and Assigned(BoundLabel.FtheLabel) then case Message.Msg of
    WM_SIZE, WM_WINDOWPOSCHANGED : begin BoundLabel.AlignLabel end;
    CM_VISIBLECHANGED : begin BoundLabel.FtheLabel.Visible := Visible; BoundLabel.AlignLabel end;
    CM_ENABLEDCHANGED : begin BoundLabel.FtheLabel.Enabled := Enabled or not (dkBlended in DisabledKind); BoundLabel.AlignLabel end;
    CM_BIDIMODECHANGED : begin BoundLabel.FtheLabel.BiDiMode := BiDiMode; BoundLabel.AlignLabel end;
  end;
end;

procedure TsCustomComboBoxEx.CreateParams(var Params: TCreateParams);
begin
  inherited;
//  Params.Style := Params.Style or CBS_OWNERDRAWFIXED and not CBS_OWNERDRAWVARIABLE;
  Params.Style := Params.Style or CBS_OWNERDRAWVARIABLE and not CBS_OWNERDRAWFIXED;
//  Params.ExStyle := Params.ExStyle or WS_EX_TRANSPARENT;
end;

{ TsCustomColorBox }

procedure TsCustomColorBox.CloseUp;
begin
  inherited CloseUp;
  FListSelected := True;
end;

procedure TsCustomColorBox.ColorCallBack(const AName: string);
var
  I, LStart: Integer;
  LColor: TColor;
  LName: string;
begin
  LColor := StringToColor(AName);
  if Assigned(FOnColorName) then begin
    LName := AName;
    FOnColorName(Self, LColor, LName);
  end
  else if cbPrettyNames in Style then begin if Copy(AName, 1, 2) = 'cl' then LStart := 3 else LStart := 1;
    LName := '';
    for I := LStart to Length(AName) do begin
      case AName[I] of
        'A'..'Z' : if (LName <> '') and (LName <> '3')  then LName := LName + ' ';
      end;
      LName := LName + AName[I];
    end;
  end
  else LName := AName;
  Items.AddObject(LName, TObject(LColor));
end;

function TsCustomColorBox.ColorRect(SourceRect : TRect; State: TOwnerDrawState): TRect;
begin
  Result := SourceRect;
  if ShowColorName then Result.Right := 2 * (Result.Bottom - Result.Top) + Result.Left else Result.Right := Result.Right - WidthOf(ButtonRect) - 3 * integer(FShowButton);
  if odComboBoxEdit in State then InflateRect(Result, - 1 - FMargin, - 1 - FMargin) else InflateRect(Result, - 1, - 1);
end;

constructor TsCustomColorBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  inherited Style := csExDropDownList;
  FStyle := [cbStandardColors, cbExtendedColors, cbSystemColors];
  FSelectedColor := clBlack;
  FDefaultColorColor := clBlack;
  FShowColorName := True;
  FNoneColorColor := clBlack;
  FCommonData.COC := COC_TsColorBox;
  FNeedToPopulate := True;
end;

procedure TsCustomColorBox.CreateWnd;
begin
  inherited CreateWnd;
  if FNeedToPopulate then PopulateList;
end;

function TsCustomColorBox.DrawSkinItem(aIndex: Integer; aRect: TRect; aState: TOwnerDrawState; aDC : hdc) : boolean;
var
  gRect, rText : TRect;
  DC : hdc;
  sNdx : integer;
  bEdit : boolean;
  Bmp : TBitmap;
  CI : TCacheInfo;
  DrawStyle : longint;
  C : TColor;
  Skinned : boolean;
  function ColorToBorderColor(AColor: TColor): TColor; begin
    if (TsColor(AColor).R > 128) or (TsColor(AColor).G > 128) or (TsColor(AColor).B > 128) then Result := clGray else if odSelected in aState then Result := clWhite else Result := AColor;
  end;
begin
  Result := False;
  if aIndex < 0 then Exit;
  Skinned := SkinData.Skinned;
  if aDC <> 0 then DC := aDC else if Skinned and (SkinData.FCacheBmp <> nil) then DC := SkinData.FCacheBmp.Canvas.Handle else Exit;
  Result := True;
  bEdit := (odComboBoxEdit in aState);
  CI.Ready := False;
  if Skinned then begin
    if bEdit then CI := MakeCacheInfo(FCommonData.FCacheBmp, aRect.Left, aRect.Top) else begin
      CI.Bmp := nil;
      CI.Ready := False;
      CI.FillColor := Color;
    end;
    if odSelected in aState then begin
      sNdx := SkinData.SkinManager.GetSkinIndex(s_Selection);
    end
    else begin
      if bEdit then sNdx := SkinData.SkinIndex else begin
        sNdx := SkinData.SkinManager.GetSkinIndex(s_Edit);
      end;
    end;
  end
  else sNdx := -1;
  Bmp := CreateBmp32(WidthOf(aRect), HeightOf(aRect));
  Bmp.Canvas.Font.Assign(Font);
  rText := Rect(0, 0, Bmp.Width, Bmp.Height);
  // Paint BG
  if (odSelected in aState) and (ShowcolorName or not (odComboBoxEdit in aState)) then begin
    if Skinned then begin
      if (sNdx > -1)
        then PaintItem(sNdx, s_Selection, CI, True, integer(odFocused in aState), Rect(0, 0, Bmp.Width, Bmp.Height), Point(0, 0), Bmp, SkinData.SkinManager)
        else FillDC(Bmp.Canvas.Handle, rText, SkinData.SkinManager.GetHighLightColor);
    end
    else FillDC(Bmp.Canvas.Handle, rText, clHighlight);
  end
  else begin
    if CI.Ready
      then BitBlt(Bmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, CI.Bmp.Canvas.Handle, CI.X, CI.Y, SRCCOPY)
      else FillDC(Bmp.Canvas.Handle, rText, Color);
  end;

  C := Colors[aIndex];
  if C = clDefault then C := DefaultColorColor else if C = clNone then C := NoneColorColor;
  gRect := rText;
  if odComboBoxEdit in aState
    then InflateRect(gRect, - 1 - FMargin, - 1 - FMargin)
    else InflateRect(gRect, - 1, - 1);

  if ShowcolorName or not (odComboBoxEdit in aState) then begin
    InflateRect(gRect, -2, 0);
    gRect.Right := gRect.Left + 2 * (gRect.Bottom - gRect.Top);

    FillDC(Bmp.Canvas.Handle, gRect, C);
    Bmp.Canvas.Brush.Color := ColorToBorderColor(ColorToRGB(C));
    Bmp.Canvas.Brush.Style := bsSolid;
    Bmp.Canvas.FrameRect(gRect);

    rText.Left := gRect.Right + 5;

    DrawStyle := DT_NOPREFIX or DT_EXPANDTABS or DT_SINGLELINE or DT_VCENTER or DT_NOCLIP;
    if (aIndex >= 0) and (aIndex < Items.Count) then begin
      if Skinned and (sNdx > -1) then WriteTextEx(Bmp.Canvas, PChar(Items[aIndex]), True, rText, DrawStyle, sNdx, odSelected in aState, SkinData.SkinManager) else begin
        Bmp.Canvas.Brush.Style := bsClear;
        if (odSelected in aState) then begin
          if Skinned
            then Bmp.Canvas.Font.Color := SkinData.SkinManager.GetHighLightFontColor(odFocused in aState)
            else Bmp.Canvas.Font.Color := clHighLightText
        end
        else Bmp.Canvas.Font.Color := Font.Color;
        acDrawText(Bmp.Canvas.Handle, Items[aIndex], rText, DrawStyle);
        if not Skinned and (odFocused in aState) then begin
          rText.Left := 0;
          DrawFocusRect(Bmp.Canvas.Handle, rText);
        end;
      end;
    end;
  end
  else begin
    if odSelected in aState then begin
      gRect := Rect(0, 0, Bmp.Width, Bmp.Height);
      FillDC(Bmp.Canvas.Handle, gRect, C);
      if (odFocused in aState) then DrawFocusRect(Bmp.Canvas.Handle, gRect);
    end
    else begin
      FillDC(Bmp.Canvas.Handle, gRect, C);
      Bmp.Canvas.Brush.Color := ColorToBorderColor(ColorToRGB(C));
      Bmp.Canvas.Brush.Style := bsSolid;
      Bmp.Canvas.FrameRect(gRect);
    end;
  end;

  BitBlt(DC, aRect.Left, aRect.Top, Bmp.Width, Bmp.Height, Bmp.Canvas.Handle, 0, 0, SRCCOPY);
  FreeAndNil(Bmp);
end;

function TsCustomColorBox.GetColor(Index: Integer): TColor;
begin
  if Index < 0 then begin
    Result := clNone;
    Exit;
  end;
  Result := TColor(Items.Objects[Index]);
end;

function TsCustomColorBox.GetColorName(Index: Integer): string;
begin
  Result := Items[Index];
end;

function TsCustomColorBox.GetSelected: TColor;
begin
  if HandleAllocated then
    if ItemIndex <> -1 then Result := Colors[ItemIndex] else Result := NoColorSelected
  else Result := FSelectedColor;
end;

procedure TsCustomColorBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  FListSelected := False;
  inherited KeyDown(Key, Shift);
end;

procedure TsCustomColorBox.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  if (cbCustomColor in Style) and (Key = #13) and (ItemIndex = 0) then begin
    PickCustomColor;
    Key := #0;
  end;
end;

function TsCustomColorBox.PickCustomColor: Boolean;
begin
  if ColDlg = nil then ColDlg := TsColorDialog.Create(nil);
  ColDlg.Color := ColorToRGB(TColor(Items.Objects[0]));
  Result := ColDlg.Execute;
  if Result then begin
    SendMessage(ExHandle, WM_SETREDRAW, 0, 0);
    if (cbSavedColors in Style) then PopulateList;
    SendMessage(ExHandle, WM_SETREDRAW, 1, 0);
    TComboBoxExStrings(Items).ItemsEx[0].Data := TObject(ColDlg.Color);
    Selected := ColDlg.Color;
    ItemIndex := 0;
    Self.Invalidate;
  end;
end;

procedure TsCustomColorBox.PopulateList;
  procedure DeleteRange(const AMin, AMax: Integer); var I: Integer; begin
    for I := AMax downto AMin do Items.Delete(I);
  end;
  procedure DeleteColor(const AColor: TColor); var I: Integer; begin
    I := Items.IndexOfObject(TObject(AColor));
    if I <> -1 then Items.Delete(I);
  end;
var
  lSelectedColor, lCustomColor, C: TColor;
  i : integer;
begin
  if HandleAllocated and not (csDestroying in ComponentState) then begin
    FNeedToPopulate := False;
    Items.BeginUpdate;
    try
      lCustomColor := clBlack;
      if (cbCustomColor in Style) and (Items.Count > 0) then LCustomColor := TColor(Items.Objects[0]);
      LSelectedColor := FSelectedColor;
      while Items.Count > 0 do Items.Delete(0);
//      Items.Clear; Do not recreate a control
      GetColorValues(ColorCallBack);
      if not (cbIncludeNone in Style) then DeleteColor(clNone);
      if not (cbIncludeDefault in Style) then DeleteColor(clDefault);
      if not (cbSystemColors in Style) then DeleteRange(StandardColorsCount + ExtendedColorsCount, Items.Count - 1);
      if not (cbExtendedColors in Style) then DeleteRange(StandardColorsCount, StandardColorsCount + ExtendedColorsCount - 1);
      if not (cbStandardColors in Style) then DeleteRange(0, StandardColorsCount - 1);

      if (cbSavedColors in Style) and (ColDlg <> nil) then begin
        for i := 0 to ColDlg.CustomColors.Count - 1 do if ColDlg.CustomColors[i] <> 'FFFFFF' then begin
          Items.Insert(0, ColDlg.CustomColors[i]);
          C := HexToInt(ColDlg.CustomColors[i]);
          C := SwapRedBlue(C);
          TComboBoxExStrings(Items).ItemsEx[0].Data := TObject(C);
        end;
      end;

      if cbCustomColor in Style then begin
        Items.Insert(0, 'Custom...');
        TComboBoxExStrings(Items).ItemsEx[0].Data := TObject(LCustomColor);
      end;
      if (cbCustomColors in Style) and Assigned(OnGetColors) then OnGetColors(Self, Items);
      Selected := LSelectedColor;
    finally
      Items.EndUpdate;
    end;
  end
  else FNeedToPopulate := True;
end;

procedure TsCustomColorBox.Select;
begin
  if FListSelected then begin
    FListSelected := False;
    if (cbCustomColor in Style) and (ItemIndex = 0) and not PickCustomColor then Exit;
  end;
  inherited Select;
end;

procedure TsCustomColorBox.SetDefaultColorColor(const Value: TColor);
begin
  if Value <> FDefaultColorColor then begin
    FDefaultColorColor := Value;
    FCommonData.Invalidate;
  end;
end;

procedure TsCustomColorBox.SetMargin(const Value: integer);
begin
  if FMargin <> Value then begin
    FMargin := Value;
    FMargin := min(FMargin, Height div 2);
    FCommonData.Invalidate;
  end;
end;

procedure TsCustomColorBox.SetNoneColorColor(const Value: TColor);
begin
  if Value <> FNoneColorColor then
  begin
    FNoneColorColor := Value;
    FCommonData.Invalidate;
  end;
end;

procedure TsCustomColorBox.SetSelected(const AColor: TColor);
var
  I: Integer;
begin
  if HandleAllocated then begin
    I := Items.IndexOfObject(TObject(AColor));
    if AColor <> 0 then begin
      if (I = -1) and (cbCustomColor in Style) and (AColor <> NoColorSelected) then begin
        TComboBoxExStrings(Items).ItemsEx[0].Data := TObject(AColor);
        I := 0;
      end;
      ItemIndex := I;
    end
    else begin
      if (cbCustomColor in Style) then begin
        if (I = -1) and ((AColor <> NoColorSelected)) then begin
          TComboBoxExStrings(Items).ItemsEx[0].Data := TObject(AColor);
          I := 0;
        end;
        if (I = 0) and (Items.Objects[0] = TObject(AColor)) then begin
          ItemIndex := 0;
          for I := 1 to Items.Count - 1 do if Items.Objects[0] = TObject(AColor) then begin
            ItemIndex := I;
            Break;
          end;
        end
        else ItemIndex := I;
      end
      else ItemIndex := I;
    end;
    SendAMessage(Handle, AC_INVALIDATE);
  end;
  FSelectedColor := AColor;
end;

procedure TsCustomColorBox.SetShowColorName(const Value: boolean);
begin
  if FShowColorName <> Value then begin
    FShowColorName := Value;
    FCommonData.Invalidate;
  end;
end;

procedure TsCustomColorBox.SetStyle(AStyle: TsColorBoxStyle);
begin
  if AStyle <> Style then begin
    FStyle := AStyle;
    Enabled := ([cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor] * FStyle) <> [];
    PopulateList;
    SkinData.Invalidate;
  end;
end;

procedure TsCustomColorBox.WMDrawItem(var Message: TWMDrawItem);
var
  ds : TDrawItemStruct;
  State : TOwnerDrawState;
begin
  ds :=  Message.DrawItemStruct^;
  if ds.itemState and ODS_COMBOBOXEDIT = ODS_COMBOBOXEDIT then State := [odComboBoxEdit] else State := [];
  if ds.itemState and ODS_FOCUS = ODS_FOCUS then State := State + [odFocused];
  if ds.itemState and ODS_SELECTED = ODS_SELECTED then State := State + [odSelected];
  if ds.itemState and ODS_HOTLIGHT = ODS_HOTLIGHT then State := State + [odSelected];
  if ds.itemState and ODS_DISABLED = ODS_DISABLED then State := State + [odDisabled];

  if SkinData.Skinned
    then Message.Result := integer(DrawSkinItem(integer(ds.itemID), ds.rcItem, State, ds.hDC))
    else Message.Result := integer(DrawSkinItem(integer(ds.itemID), ds.rcItem, State, ds.hDC))
end;

procedure TsCustomColorBox.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    CN_COMMAND : case TWMCommand(Message).NotifyCode of
      CBN_DROPDOWN : if (cbSavedColors in Style) then PopulateList;
    end;
  end;
  inherited;
end;

function TsCustomComboBoxEx.GetSelectedItem: TComboExItem;
begin
  if ItemIndex > -1 then begin
    Result := ItemsEx.ComboItems[ItemIndex];
  end
  else Result := nil
end;

initialization

finalization
  if ColDlg <> nil then FreeAndNil(ColDlg);
{$ENDIF} // DELPHI6UP

end.
