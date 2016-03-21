unit sComboBox;
{$I sDefs.inc}
{.$DEFINE LOGGED}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  {$IFDEF TNTUNICODE}TntControls, TntClasses, TntActnList, TntStdCtrls, TntGraphics, {$ENDIF}
  StdCtrls, sConst, sDefaults, acSBUtils, sCommonData{$IFDEF LOGGED}, sDebugMsgs{$ENDIF};

type
{$IFDEF TNTUNICODE}
  TsCustomComboBox = class(TTntCustomComboBox)
{$ELSE}
  TsCustomComboBox = class(TCustomComboBox)
{$ENDIF}
{$IFNDEF NOTFORHELP}
  private
    FAlignment : TAlignment;
    FReadOnly: boolean;
    FDisabledKind: TsDisabledKind;
    FCommonData: TsCtrlSkinData;
    FBoundLabel: TsBoundLabel;
    FShowButton: boolean;
    procedure SetAlignment(const Value: TAlignment);
    procedure SetReadOnly(const Value: boolean);
    procedure SetDisabledKind(const Value: TsDisabledKind);
    procedure SetShowButton(const Value: boolean);
  protected
    lboxhandle : hwnd;
    ListSW : TacScrollWnd;
    OldDropcountValue : integer;
    procedure PrepareCache;
    procedure CNDrawItem(var Message: TWMDrawItem); message CN_DRAWITEM;
    procedure OurPaintHandler(iDC : hdc);
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;

    procedure WndProc (var Message: TMessage); override;
    procedure ComboWndProc(var Message: TMessage; ComboWnd: HWnd; ComboProc: Pointer); override;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonDblClk(var Message: TMessage); message WM_LBUTTONDBLCLK;
{$IFNDEF DELPHI5}
    procedure SetDropDownCount(const Value: Integer); override;
{$ENDIF}
    procedure CreateParams(var Params: TCreateParams); override;
  public
    FDefListProc: Pointer;
    FDropDown : boolean;
    bFormHandle : hwnd;
    bFormDefProc: Pointer;
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    function IndexOf(const s : acString) : integer;
    procedure Invalidate; override;
    function ButtonRect: TRect;
    procedure PaintButton;
    function ButtonHeight : integer;
    procedure CreateWnd; override;
    function Focused: Boolean; override;
    property ShowButton : boolean read FShowButton write SetShowButton default True;
  published
{$IFDEF D2007}
    property AutoCloseUp;
    property AutoDropDown;
{$ENDIF}
    property Align;
    property Anchors;
    property Alignment : TAlignment read FAlignment write SetAlignment;
{$IFDEF D2005}
    property AutoCompleteDelay;
{$ENDIF}
    property BoundLabel : TsBoundLabel read FBoundLabel write FBoundLabel;
    property DisabledKind : TsDisabledKind read FDisabledKind write SetDisabledKind default DefDisabledKind;
    property DropDownCount default 16;
    property SkinData : TsCtrlSkinData read FCommonData write FCommonData;
{$IFDEF D2010}
    property TextHint;
    property Touch;
{$ENDIF}
    property ReadOnly : boolean read FReadOnly write SetReadOnly default False;
{$ENDIF} // NOTFORHELP
  end;

  TsComboBox = class(TsCustomComboBox)
{$IFNDEF NOTFORHELP}
    property Style; {Must be published before Items}
{$IFDEF DELPHI7UP}
    property AutoComplete;
{$ENDIF}
    property BiDiMode;
    property CharCase;
    property Color;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property DropDownCount;
    property Enabled;
    property Font;
    property ImeMode;
    property ImeName;
    property ItemHeight;
    property ItemIndex;
    property MaxLength;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
{$IFDEF TNTUNICODE}
    property SelText;
    property SelStart;
    property SelLength;
{$ENDIF}
    property ShowHint;
    property Sorted;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
{$IFDEF DELPHI6UP}
    property AutoDropDown;
    property OnCloseUp;
    property OnSelect;
{$ENDIF}
    property OnChange;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawItem;
    property OnDropDown;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMeasureItem;
    property OnStartDock;
    property OnStartDrag;
    property Items; { Must be published after OnMeasureItem }
{$ENDIF} // NOTFORHELP
    property BoundLabel;
    property DisabledKind;
    property SkinData;
    property ReadOnly;
  end;


implementation

uses sStyleSimply, sSkinProps, sVCLUtils, sMessages, sAlphaGraph, acntUtils, sGraphUtils, sSkinManager, acGlow, sMaskData{$IFDEF DELPHI7UP}, Themes{$ENDIF};

function IsOwnerDraw(Ctrl : TsCustomComboBox) : boolean;
begin
  Result := (Ctrl.Style in [csOwnerDrawFixed, csOwnerDrawVariable]) and Assigned(Ctrl.OnDrawItem)
end;

{ TsCustomComboBox }

function TsCustomComboBox.ButtonHeight: integer;
begin
  if FCommonData.Skinned and (FCommonData.SkinManager.ConstData.ComboGlyph > -1)
    then Result := HeightOfImage(FCommonData.SkinManager.ma[FCommonData.SkinManager.ConstData.ComboGlyph])
    else Result := 16;
end;

function TsCustomComboBox.ButtonRect: TRect;
const
  iMargin = 2;
var
  w : integer;
begin
  if (Style <> csSimple) and FShowButton then w := GetSystemMetrics(SM_CXVSCROLL) else w := 0;
  if UseRightToLeftAlignment then Result.Left := iMargin else Result.Left := Width - w - iMargin;// - 1;
  Result.Top := iMargin;
  Result.Right := Result.Left + w;
  Result.Bottom := Height - iMargin;
end;

procedure TsCustomComboBox.ComboWndProc(var Message: TMessage; ComboWnd: HWnd; ComboProc: Pointer);
var
  ps : TPaintStruct;
begin
{$IFDEF LOGGED}
//  AddToLog(Message);
{$ENDIF}
  if ReadOnly then begin
    case Message.Msg of
      WM_KEYDOWN, WM_CHAR, WM_KEYUP, WM_SYSKEYUP, CN_KEYDOWN, CN_CHAR, CN_SYSKEYDOWN, CN_SYSCHAR, WM_PASTE, WM_CUT, WM_CLEAR, WM_UNDO: Exit
      else
{$IFDEF TNTUNICODE}
//      if not TntCombo_ComboWndProc(Self, Message, ComboWnd, ComboProc, DoEditCharMsg) then
{$ENDIF}
    end
  end;
{$IFDEF TNTUNICODE}
//  if not TntCombo_ComboWndProc(Self, Message, ComboWnd, ComboProc, DoEditCharMsg) then
{$ENDIF}
  begin
    if not (csDestroying in ComponentState) and FCommonData.Skinned then case Message.Msg of
      WM_ERASEBKGND, WM_NCPAINT : if (Style <> csSimple) and (not (Focused or FCommonData.FFocused) or not Enabled or ReadOnly) then begin
        Message.Result := 1;
        Exit;
      end;
      WM_PAINT : if (Style <> csSimple) and (not (Focused or FCommonData.FFocused) or not Enabled or ReadOnly) then begin
        BeginPaint(ComboWnd, PS);
        EndPaint(ComboWnd, PS);
        Exit;
      end;
    end;
    inherited;
  end;
end;

constructor TsCustomComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  DropDownCount := 16;
  FCommonData := TsCtrlSkinData.Create(Self, True);
  FCommonData.COC := COC_TsEdit;
  if FCommonData.SkinSection = '' then FCommonData.SkinSection := s_ComboBox;
  FDisabledKind := DefDisabledKind;

  FBoundLabel := TsBoundLabel.Create(Self, FCommonData);
  FDropDown := False;

  FReadOnly := False;
  FShowButton := True;

  FDefListProc := nil;
end;

destructor TsCustomComboBox.Destroy;
begin
  if lBoxHandle <> 0 then begin
    SetWindowLong(lBoxHandle, GWL_STYLE, GetWindowLong(lBoxHandle, GWL_STYLE) and not WS_THICKFRAME or WS_BORDER);
    UninitializeACScroll(lBoxHandle, True, False, ListSW);
    lBoxHandle := 0;
  end;
  FreeAndNil(FBoundLabel);
  if Assigned(FCommonData) then FreeAndNil(FCommonData);
  inherited Destroy;
end;

function TsCustomComboBox.Focused: Boolean;
var
  FocusedWnd: HWND;
begin
  Result := False;
  if HandleAllocated then begin
    FocusedWnd := GetFocus;
    Result := (FocusedWnd <> 0) and ((FocusedWnd = EditHandle) or (FocusedWnd = ListHandle)) or (Assigned(FCommonData) and FCommonData.FFocused);
  end;
end;

function TsCustomComboBox.IndexOf(const s: acString): integer;
var
  i : integer;
begin
  Result := -1;
  for i := 0 to Items.Count - 1 do if Items[i] = s then begin
    Result := i;
    Exit;
  end;
end;

procedure TsCustomComboBox.Invalidate;
begin
  if Focused then FCommonData.FFocused := True;
  inherited Invalidate;
end;

procedure TsCustomComboBox.OurPaintHandler(iDC : hdc);
const
  BordWidth = 3;
var
  DC : hdc;
  R : TRect;
begin
  if not Showing or not HandleAllocated then Exit;
  if iDC = 0 then DC := GetDC(Handle) else DC := iDC;
  R := ButtonRect;
  try
    FCommonData.FUpdating := FCommonData.Updating;
    if not (InAnimationProcess and (DC <> SkinData.PrintDC) and (SkinData.PrintDC <> 0)) and not FCommonData.FUpdating then begin
      FCommonData.BGChanged := FCommonData.BGChanged or FCommonData.HalfVisible or GetBoolMsg(Parent, AC_GETHALFVISIBLE) or IsOwnerDraw(Self);
      FCommonData.HalfVisible := not RectInRect(Parent.ClientRect, BoundsRect);

      if FCommonData.BGChanged then PrepareCache;
      UpdateCorners(FCommonData, 0);

      case Style of
        csSimple : begin
          BitBltBorder(DC, 0, 0, Width, FCommonData.FCacheBmp.Height, FCommonData.FCacheBmp.Canvas.Handle, 0, 0, BordWidth);
        end;
        csDropDown : begin
          if Focused then begin
            BitBltBorder(DC, 0, 0, Width, FCommonData.FCacheBmp.Height, FCommonData.FCacheBmp.Canvas.Handle, 0, 0, BordWidth);
            R := ButtonRect;
            BitBlt(DC, R.Left, R.Top, WidthOf(R), HeightOf(R), FCommonData.FCacheBmp.Canvas.Handle, R.Left, R.Top, SRCCOPY);
          end
          else BitBlt(DC, 0, 0, Width, FCommonData.FCacheBmp.Height, FCommonData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
        end;
        csDropDownList, csOwnerDrawFixed, csOwnerDrawVariable : begin
          BitBlt(DC, 0, 0, Width, Height, FCommonData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
          Canvas.Handle := 0;
        end;
      end;

{$IFDEF DYNAMICCACHE}
    if Assigned(FCommonData.FCacheBmp) then FreeAndNil(FCommonData.FCacheBmp);
{$ENDIF}
    end;
  finally
    if iDC = 0 then ReleaseDC(Handle, DC);
  end;
end;

procedure TsCustomComboBox.PaintButton;
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
    if ControlIsActive(FCommonData) then c.C := FCommonData.SkinManager.gd[FCommonData.SkinIndex].HotColor else c.C := FCommonData.SkinManager.gd[FCommonData.SkinIndex].Color;

    DrawSkinGlyph(FCommonData.FCacheBmp,
      Point(R.Left + (WidthOf(R) - WidthOfImage(FCommonData.SkinManager.ma[glIndex])) div 2,
            (Height - ButtonHeight) div 2), Mode, 1, FCommonData.SkinManager.ma[FCommonData.SkinManager.ConstData.ComboGlyph], MakeCacheInfo(SkinData.FCacheBmp));
  end;
end;

procedure TsCustomComboBox.PrepareCache;
const
  BordWidth = 3;
var
  R, bRect : TRect;
  State : TOwnerDrawState;
begin
  InitCacheBmp(SkinData);
  if Style <> csSimple then begin
    PaintItem(FCommonData, GetParentCache(FCommonData), True, integer(ControlIsActive(FCommonData)), Rect(0, 0, Width, Height), Point(Left, top), FCommonData.FCacheBmp, False);
  end
  else begin
    FCommonData.FCacheBmp.Height := ItemHeight + 8;
    PaintItem(FCommonData, GetParentCache(FCommonData), True, integer(ControlIsActive(FCommonData)), Rect(0, 0, Width, FCommonData.FCacheBmp.Height), Point(Left, top), FCommonData.FCacheBmp, False);
  end;
  case Style of
    csDropDown, csDropDownList, csOwnerDrawFixed, csOwnerDrawVariable : begin
      bRect := ButtonRect;
      if UseRightToLeftAlignment
        then R := Rect(bRect.Right + 1, BordWidth, Width - BordWidth, FCommonData.FCacheBmp.Height - BordWidth)
        else R := Rect(BordWidth, BordWidth, bRect.Left - 1, FCommonData.FCacheBmp.Height - BordWidth);
      State := [odComboBoxEdit];
      if (Focused or SkinData.FFocused) and not (Style in [csDropDown, csSimple]) then State := State + [odFocused, odSelected];
      Canvas.Handle := FCommonData.FCacheBmp.Canvas.Handle;
      FCommonData.FCacheBmp.Canvas.Lock;
      DrawItem(ItemIndex, R, State);
      FCommonData.FCacheBmp.Canvas.Unlock;
      Canvas.Handle := 0;
      if FShowButton then PaintButton;
    end;
  end;
  if not Enabled and not IsOwnerDraw(Self) then BmpDisabledKind(FCommonData.FCacheBmp, FDisabledKind, Parent, GetParentCache(FCommonData), Point(Left, Top));
  FCommonData.BGChanged := False;
end;

procedure TsCustomComboBox.SetAlignment(const Value: TAlignment);
begin
  if FAlignment <> Value then begin
    FAlignment := Value;
    FCommonData.Invalidate;
  end;
end;

procedure TsCustomComboBox.SetDisabledKind(const Value: TsDisabledKind);
begin
  if FDisabledKind <> Value then begin
    FDisabledKind := Value;
    FCommonData.Invalidate;
  end;
end;

procedure TsCustomComboBox.SetReadOnly(const Value: boolean);
begin
  if FReadOnly <> Value then FReadOnly := Value;
end;

procedure TsCustomComboBox.WMLButtonDblClk(var Message: TMessage);
begin
  if FReadOnly then begin
    SetFocus;
    if Assigned(OnDblClick) then OnDblClick(Self);
  end
  else inherited;
end;

procedure TsCustomComboBox.WMLButtonDown(var Message: TWMLButtonDown);
begin
  if FReadOnly then SetFocus else inherited
end;

procedure TsCustomComboBox.SetShowButton(const Value: boolean);
begin
  if FShowButton <> Value then begin
    FShowButton := Value;
    FCommonData.Invalidate;
  end;
end;

procedure TsCustomComboBox.WndProc(var Message: TMessage);
var
  PS : TPaintStruct;
  DC : hdc;
  R : TRect;
  P : TPoint;
begin
{$IFDEF LOGGED}
  AddToLog(Message);
{$ENDIF}
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_CTRLHANDLED : begin Message.Result := 1; Exit end; // AlphaSkins supported
    AC_GETAPPLICATION : begin Message.Result := longint(Application); Exit end;
    AC_REMOVESKIN : if LongWord(Message.LParam) = LongWord(SkinData.SkinManager) then begin
      CommonWndProc(Message, FCommonData);
      if not FCommonData.CustomColor then Color := clWindow;
      if not FCommonData.CustomFont then Font.Color := clWindowText;
      if lBoxHandle <> 0 then begin
        SetWindowLong(lBoxHandle, GWL_STYLE, GetWindowLong(lBoxHandle, GWL_STYLE) and not WS_THICKFRAME or WS_BORDER);
        UninitializeACScroll(lBoxHandle, True, False, ListSW);
        lBoxHandle := 0;
      end;
{
      if Assigned(ListSW) then begin
        FreeAndNil(ListSW);
        lBoxHandle := 0;
      end;
      RecreateWnd;
}
      exit
    end;
    AC_REFRESH : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
      CommonWndProc(Message, FCommonData);
{
      if FCommonData.Skinned then begin
        if not FCommonData.CustomColor then Color := FCommonData.SkinManager.gd[FCommonData.SkinIndex].Color;
        if not FCommonData.CustomFont  then Font.Color := ColorToRGB(FCommonData.SkinManager.gd[FCommonData.SkinIndex].FontColor[1]);
      end;
}
      Repaint;
      exit
    end;
    AC_SETNEWSKIN : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
      CommonWndProc(Message, FCommonData);
      if ListSW <> nil then ListSW.acWndProc(Message);
      exit
    end;
    AC_ENDPARENTUPDATE : if FCommonData.Updating then begin
      FCommonData.Updating := False;
      Repaint;
      Exit
    end;
    AC_MOUSELEAVE : SendMessage(Handle, CM_MOUSELEAVE, 0, 0);
  end
  else case Message.Msg of
    WM_SYSCHAR, WM_SYSKEYDOWN, CN_SYSCHAR, CN_SYSKEYDOWN, WM_KEYDOWN, CN_KEYDOWN : case TWMKey(Message).CharCode of
      VK_SPACE..VK_DOWN, $39..$39, $41..$5A :
      if ReadOnly then Exit;
    end;
    WM_CHAR : if ReadOnly then Exit;
    WM_COMMAND, CN_COMMAND : if (Message.WParam = CBN_DROPDOWN) and ReadOnly then Exit;
  end;
  if not ControlIsReady(Self) or not FCommonData.Skinned then inherited else begin
    case Message.Msg of
      CM_COLORCHANGED, CM_MOUSEWHEEL : FCommonData.BGChanged := True;
      CN_COMMAND : case TWMCommand(Message).NotifyCode of
        CBN_CLOSEUP : begin
          FDropDown := False;
          FCommonData.BGChanged := True;
          OurPaintHandler(0);
        end;
        CBN_DROPDOWN : FDropDown := True;
      end;
      WM_SETFOCUS, CM_ENTER : if CanFocus then begin
        FCommonData.FFocused := True;
        FCommonData.FMouseAbove := False;
        FCommonData.BGChanged := True;
        inherited;
        Repaint;
        Exit
      end;
      WM_KILLFOCUS, CM_EXIT: begin
        DroppedDown := False;
        FCommonData.FFocused := False;
        FCommonData.FMouseAbove := False;
        FCommonData.BGChanged := True;
        inherited;
        Repaint;
        Exit
      end;
      WM_NCPAINT : begin
        if InanimationProcess then OurPaintHandler(0);
        Exit
      end;
      WM_PAINT : begin
        BeginPaint(Handle, PS);
        if not InAnimationProcess then begin
          if TWMPaint(Message).DC = 0 then DC := GetDC(Handle) else DC := TWMPaint(Message).DC;
          OurPaintHandler(DC);
          if TWMPaint(Message).DC = 0 then ReleaseDC(Handle, DC);
        end;
        EndPaint(Handle, PS);
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
          Repaint;
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
      WM_COMMAND : if ReadOnly then Exit else begin
        FDropDown := False;
        OurPaintHandler(0);
      end;
{$IFNDEF TNTUNICODE}
      WM_CTLCOLORLISTBOX : if not (csLoading in ComponentState) and (lBoxHandle = 0) then begin
        if Items.Count > DropDownCount then begin
          lBoxHandle := hwnd(Message.LParam);
          ListSW := TacComboListWnd.CreateEx(lboxhandle, nil, SkinData.SkinManager, s_Edit, True, Style = csSimple);
        end;
      end;
{$ENDIF}
      CM_VISIBLECHANGED, CM_ENABLEDCHANGED, WM_SETFONT : begin
        FCommonData.BGChanged := True;
      end;
      WM_PRINT : begin
        SkinData.Updating := False;
        OurPaintHandler(TWMPaint(Message).DC);
        Exit;
      end;
    end;
    CommonWndProc(Message, FCommonData);
    inherited;
    if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
      AC_DROPPEDDOWN : Message.Result := integer(DroppedDown);
    end
    else case Message.Msg of
      CM_ENABLEDCHANGED, WM_SETFONT : begin
        Repaint
      end;
      CB_SETCURSEL : begin
        FCommonData.BGChanged := True;
        Repaint
      end;
      CM_CHANGED, CM_TEXTCHANGED : begin
        FCommonData.BGChanged := True;
        Repaint;
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

procedure TsCustomComboBox.CreateWnd;
begin
  inherited;
{$IFDEF DELPHI7UP}
{$IFNDEF D2009}
  if CheckWin32Version(5, 1) and ThemeServices.ThemesEnabled then SendMessage(Handle, $1701{CB_SETMINVISIBLE}, WPARAM(DropDownCount), 0);
{$ENDIF}
{$ENDIF}
  FCommonData.Loaded;
{  if HandleAllocated and FCommonData.Skinned then begin
    if not FCommonData.CustomColor then Color := FCommonData.SkinManager.gd[FCommonData.SkinIndex].Color;
    if not FCommonData.CustomFont then Font.Color := FCommonData.SkinManager.gd[FCommonData.SkinIndex].FontColor[1];
  end;}
end;

{$IFNDEF DELPHI5}    
procedure TsCustomComboBox.SetDropDownCount(const Value: Integer);
begin
  if Value <> DropDownCount then begin
    inherited;
{$IFDEF DELPHI7UP}
{$IFNDEF D2009}
    if CheckWin32Version(5, 1) and ThemeServices.ThemesEnabled and HandleAllocated then SendMessage(Handle, $1701{CB_SETMINVISIBLE}, WPARAM(DropDownCount), 0);
{$ENDIF}
{$ENDIF}
  end;
end;
{$ENDIF}

procedure TsCustomComboBox.CreateParams(var Params: TCreateParams);
begin
  inherited;
  if Style in [csDropDown, csDropDownList] then Params.Style := Params.Style or CBS_OWNERDRAWVARIABLE and not CBS_OWNERDRAWFIXED;
end;

procedure TsCustomComboBox.CNDrawItem(var Message: TWMDrawItem);
var
  State: TOwnerDrawState;
begin
  with Message.DrawItemStruct^ do begin
    State := TOwnerDrawState(LongRec(itemState).Lo);
    if itemState and ODS_COMBOBOXEDIT <> 0 then Include(State, odComboBoxEdit);
    if itemState and ODS_DEFAULT <> 0 then Include(State, odDefault);
    Canvas.Handle := hDC;
    DrawItem(integer(itemID), rcItem, State);
    Canvas.Handle := 0;
  end;
end;

procedure TsCustomComboBox.DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  Bmp : TBitmap;
  aRect : TRect;
  TmpColor : TColor;
  sNdx : integer;
  CI : TCacheInfo;
  DrawStyle : longint;
  OldDC, SavedDC : hdc;
  C : TColor;
begin
  aRect := Classes.Rect(0, 0, WidthOf(Rect), HeightOf(Rect));
  DrawStyle := DT_NOPREFIX or DT_EXPANDTABS or DT_SINGLELINE or DT_VCENTER or DT_NOCLIP;
  if SkinData.Skinned then begin
    Bmp := CreateBmp32(WidthOf(Rect, True), HeightOf(Rect, True));
    Bmp.Canvas.Font.Assign(Font);
    if odComboBoxEdit in State then CI := MakeCacheInfo(FCommonData.FCacheBmp, Rect.Left, Rect.Top) else begin
      CI.Bmp := nil;
      CI.Ready := False;
      CI.FillColor := Color;
    end;
    if (odSelected in State) then begin
      sNdx := SkinData.SkinManager.GetSkinIndex(s_Selection);
      C := SkinData.SkinManager.GetHighLightColor(odFocused in State);
      if sNdx < 0
        then FillDC(Bmp.Canvas.Handle, Classes.Rect(0, 0, Bmp.Width, Bmp.Height), C)
        else PaintItem(sNdx, s_Selection, CI, True, integer((odFocused in State) or (Style = csDropDown)), Classes.Rect(0, 0, Bmp.Width, Bmp.Height), Point(0, 0), Bmp, SkinData.SkinManager)
    end
    else begin
      sNdx := -1;
      if CI.Ready then BitBlt(Bmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, CI.Bmp.Canvas.Handle, CI.X, CI.Y, SRCCOPY) else begin
        if (odComboBoxEdit in State) then C := Color else C := SkinData.SkinManager.GetActiveEditColor;
        FillDC(Bmp.Canvas.Handle, Classes.Rect(0, 0, Bmp.Width, Bmp.Height), C);
      end;
    end;
    if Assigned(OnDrawItem) and (Style in [csOwnerDrawFixed, csOwnerDrawVariable]) then begin
      if (Index > -1) and (Index < Items.Count) then begin
        OldDC := Canvas.Handle;
        Canvas.Handle := Bmp.Canvas.Handle;
        Bmp.Canvas.Lock;
        SavedDC := SaveDC(Canvas.Handle);
        try
          MovewindowOrg(Canvas.Handle, -Rect.Left, -Rect.Top);
          OnDrawItem(Self, Index, Rect, State);
        finally
          RestoreDC(Canvas.Handle, SavedDC);
          Bmp.Canvas.UnLock;
        end;
        Canvas.Handle := OldDC;
      end
    end
    else begin
      if UseRightToLeftAlignment then DrawStyle := DrawStyle or DT_RIGHT;
      if UseRightToLeftReading then DrawStyle := DrawStyle or DT_RTLREADING;
      if (csDropDown = Style) and (odComboBoxEdit in State) then begin
        Bmp.Canvas.Brush.Style := bsClear;
        AcDrawText(Bmp.Canvas.Handle, Text, aRect, DrawStyle);
      end
      else begin
        InflateRect(aRect, -2, 0);

        if sNdx = -1 then begin
          if odSelected in State then Bmp.Canvas.Font.Color := SkinData.SkinManager.GetHighLightFontColor(odFocused in State) else begin
            if (odComboBoxEdit in State) then Bmp.Canvas.Font.Color := Font.Color else Bmp.Canvas.Font.Color := SkinData.SkinManager.GetActiveEditFontColor;
          end;
          Bmp.Canvas.Brush.Style := bsClear;
          AcDrawText(Bmp.Canvas.Handle, Items[Index], aRect, DrawStyle);
        end
        else acWriteTextEx(Bmp.Canvas, PacChar(Items[Index]), True, aRect, DrawStyle, sNdx, True, SkinData.SkinManager);
        if (odFocused in State) and (sNdx < 0) then begin
          Bmp.Canvas.Brush.Style := bsSolid;
          InflateRect(aRect, 2, 0);
          DrawFocusRect(Bmp.Canvas.Handle, aRect);
        end;
      end;
    end;
    BitBlt(Canvas.Handle, Rect.Left, Rect.Top, Bmp.Width, Bmp.Height, Bmp.Canvas.Handle, 0, 0, SRCCOPY);
    FreeAndNil(Bmp);
  end
  else begin
    if (odSelected in State) then begin
      TmpColor := ColorToRGB(clHighLight);
      Canvas.Font.Color := ColorToRGB(clHighLightText);
    end
    else begin
      TmpColor := ColorToRGB(Color);
      Canvas.Font.Color := ColorToRGB(Font.Color);
    end;
    FillDC(Canvas.Handle, Rect, TmpColor);
    if (Index > -1) and (Index < Items.Count) then begin
      if Assigned(OnDrawItem) and (Style in [csOwnerDrawFixed, csOwnerDrawVariable]) then OnDrawItem(Self, Index, Rect, State) else begin
        Canvas.Brush.Style := bsClear;
        AcDrawText(Canvas.Handle, Items[Index], Rect, DrawStyle);
      end;
      if (odFocused in State) then DrawFocusRect(Canvas.Handle, Rect);
    end;
  end;
end;

end.


