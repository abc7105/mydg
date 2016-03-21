unit sListBox;
{$I sDefs.inc}
{.$DEFINE LOGGED}

interface

uses StdCtrls, controls, classes, forms, graphics, messages, windows, sysutils, consts, sCommonData, {$IFDEF LOGGED}sDebugMsgs,{$ENDIF}
  sConst, sDefaults, commctrl, acSBUtils{$IFDEF TNTUNICODE}, TntStdCtrls, TntClasses{$ENDIF};

type
{$IFDEF TNTUNICODE}
  TsCustomListBox = class(TTntListBox)
{$ELSE}
  TsCustomListBox = class(TListBox)
{$ENDIF}
{$IFNDEF NOTFORHELP}
  private
    FBoundLabel: TsBoundLabel;
    procedure SetDisabledKind(const Value: TsDisabledKind);
    procedure CNDrawItem(var Message: TWMDrawItem); message CN_DRAWITEM;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMEraseBkGnd(var Message: TWMPaint);
  protected
    FAutoHideScroll: boolean;
    FCommonData: TsCtrlSkinData;
    FAutoCompleteDelay: Word;
    FDisabledKind: TsDisabledKind;
    procedure SetAutoHideScroll(const Value: boolean);
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
    procedure CreateParams(var Params: TCreateParams); override;
  public
    ListSW : TacScrollWnd;
    constructor Create(AOwner: TComponent); override;
    procedure CreateWnd; override;
    destructor Destroy; override;
    procedure WndProc (var Message: TMessage); override;
{$IFNDEF DELPHI6UP}
    function Count : integer;
{$ENDIF}
  published
{$ENDIF} // NOTFORHELP
    property AutoCompleteDelay : Word read FAutoCompleteDelay write FAutoCompleteDelay default 500;
    property AutoHideScroll : boolean read FAutoHideScroll write SetAutoHideScroll default True;
    property BoundLabel : TsBoundLabel read FBoundLabel write FBoundLabel;
    property SkinData : TsCtrlSkinData read FCommonData write FCommonData;
    property DisabledKind : TsDisabledKind read FDisabledKind write SetDisabledKind default DefDisabledKind;
  end;

  TsListBox = class(TsCustomListBox);

implementation


uses sVCLUtils, sMessages, sGraphUtils, sAlphaGraph, sSkinProps, acntUtils, math;

{ TsCustomListBox }

procedure TsCustomListBox.CNDrawItem(var Message: TWMDrawItem);
var
  State: TOwnerDrawState;
begin
  with Message.DrawItemStruct^ do begin
    State := TOwnerDrawState(LongRec(itemState).Lo);
    Canvas.Handle := hDC;
    DrawItem(integer(itemID), rcItem, State);
    Canvas.Handle := 0;
  end;
end;

constructor TsCustomListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csOpaque];
  FCommonData := TsCtrlSkinData.Create(Self, {$IFDEF DYNAMICCACHE} False {$ELSE} True {$ENDIF});
  FCommonData.COC := COC_TsCustomListBox;
  FAutoCompleteDelay := 500;
  FAutoHideScroll := True;
  if FCommonData.SkinSection = '' then FCommonData.SkinSection := s_Edit;
  FDisabledKind := DefDisabledKind;
  FBoundLabel := TsBoundLabel.Create(Self, FCommonData);
  DoubleBuffered := False;
end;

procedure TsCustomListBox.CreateParams(var Params: TCreateParams);
begin
  inherited;
  if Style = lbStandard
    then Params.Style := Params.Style or LBS_OWNERDRAWFIXED and not LBS_OWNERDRAWVARIABLE;
  if not FAutoHideScroll then Params.Style := Params.Style or LBS_DISABLENOSCROLL;
end;

procedure TsCustomListBox.CreateWnd;
begin
  inherited;
  FCommonData.Loaded;
  if HandleAllocated then RefreshEditScrolls(SkinData, ListSW);
end;

destructor TsCustomListBox.Destroy;
begin
  if ListSW <> nil then FreeAndNil(ListSW);
  FreeAndNil(FBoundLabel);
  if Assigned(FCommonData) then FreeAndNil(FCommonData);
  inherited Destroy;
end;

procedure TsCustomListBox.DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  Bmp : Graphics.TBitmap;
  aRect : TRect;
  TmpColor : TColor;
  sNdx : integer;
  CI : TCacheInfo;
  DrawStyle : longint;
  bSelected : boolean;
  SavedDC, TmpDC : hdc;
begin
  DrawStyle := DT_NOPREFIX or DT_EXPANDTABS or DT_SINGLELINE or DT_VCENTER or DT_NOCLIP;
  bSelected := (odSelected in State);// or Selected[Index];
  if SkinData.Skinned then begin
    Bmp := CreateBmp32(WidthOf(Rect), HeightOf(Rect));
    CI := MakeCacheInfo(SkinData.FCacheBmp, 2, 2);
    BitBlt(Bmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, SkinData.FCacheBmp.Canvas.Handle, Rect.Left + CI.X, Rect.Top + CI.Y, SRCCOPY);

    if Assigned(OnDrawItem) then begin
      TmpDC := Canvas.Handle;
      Canvas.Handle := Bmp.Canvas.Handle;
      Bmp.Canvas.Lock;
      SavedDC := SaveDC(Canvas.Handle);
      MoveWindowOrg(Canvas.Handle, -Rect.Left, -Rect.Top);
      OnDrawItem(Self, Index, Rect, State);
      MoveWindowOrg(Canvas.Handle, Rect.Left, Rect.Top);
      RestoreDC(Canvas.Handle, SavedDC);
      Bmp.Canvas.UnLock;
      Canvas.Handle := TmpDC;
    end
    else begin

      if bSelected then begin
        sNdx := SkinData.SkinManager.GetSkinIndex(s_Selection);
        if sNdx < 0
          then FillDC(Bmp.Canvas.Handle, Classes.Rect(0, 0, Bmp.Width, Bmp.Height), SkinData.SkinManager.GetHighLightColor)
          else PaintItem(sNdx, s_Selection, CI, True, integer(odFocused in State), Classes.Rect(0, 0, Bmp.Width, Bmp.Height), Point(Rect.Left, Rect.Top), Bmp, SkinData.SkinManager)
      end
      else begin
        sNdx := -1;
      end;

      if (Index > -1) and (Index < Items.Count) then begin
        Bmp.Canvas.Font.Assign(Font);
        aRect := Classes.Rect(0, 0, Bmp.Width, Bmp.Height);
        InflateRect(aRect, -1, 0);
        if sNdx = -1 then begin
          if bSelected then Bmp.Canvas.Font.Color := SkinData.SkinManager.GetHighLightFontColor(odFocused in State) else begin
            if ControlIsActive(SkinData) and (SkinData.SkinManager.gd[SkinData.SkinIndex].States > 1)
              then Bmp.Canvas.Font.Color := SkinData.SkinManager.gd[SkinData.SkinIndex].HotFontColor[1]
              else Bmp.Canvas.Font.Color := SkinData.SkinManager.gd[SkinData.SkinIndex].FontColor[1];
          end;
          Bmp.Canvas.Brush.Style := bsClear;
          AcDrawText(Bmp.Canvas.Handle, Items[Index], aRect, DrawStyle);
        end
        else begin
{$IFDEF TNTUNICODE}
          acWriteTextEx(Bmp.Canvas, PacChar(TTntStrings(Items)[Index]), True, aRect, DrawStyle, sNdx, (odFocused in State), SkinData.SkinManager);
{$ELSE}
          acWriteTextEx(Bmp.Canvas, PacChar(Items[Index]), True, aRect, DrawStyle, sNdx, (odFocused in State), SkinData.SkinManager);
{$ENDIF}
        end;
        if (odFocused in State) and (sNdx < 0) then begin
          InflateRect(aRect, 1, 0);
          DrawFocusRect(Bmp.Canvas.Handle, aRect);
        end;
      end;
      if not Enabled
        then BmpDisabledKind(Bmp, DisabledKind, Parent, CI, Point(Rect.Left, Rect.Top));
    end;
    BitBlt(Canvas.Handle, Rect.Left, Rect.Top, Bmp.Width, Bmp.Height, Bmp.Canvas.Handle, 0, 0, SRCCOPY);
    FreeAndNil(Bmp);
  end
  else begin
    Canvas.Font.Assign(Font);
    if bSelected then begin
      TmpColor := ColorToRGB(clHighLight);
      Canvas.Font.Color := ColorToRGB(clHighLightText);
    end
    else begin
      TmpColor := ColorToRGB(Color);
      Canvas.Font.Color := ColorToRGB(Font.Color);
    end;
    FillDC(Canvas.Handle, Rect, TmpColor);
    if Assigned(OnDrawItem) then begin
      OnDrawItem(Self, Index, Rect, State);
    end
    else begin
      InflateRect(Rect, -1, 0);
      if (Index > -1) and (Index < Items.Count) then begin
        Canvas.Brush.Style := bsClear;
        AcDrawText(Canvas.Handle, Items[Index], Rect, DrawStyle);
        if (odFocused in State) then begin
          InflateRect(Rect, 1, 0);
          DrawFocusRect(Canvas.Handle, Rect);
        end;
      end;
    end;
  end;
end;

procedure TsCustomListBox.SetAutoHideScroll(const Value: boolean);
begin
  if FAutoHideScroll <> Value then begin
    FAutoHideScroll := Value;
    if not (csLoading in ComponentState) then RecreateWnd;
  end;
end;

procedure TsCustomListBox.SetDisabledKind(const Value: TsDisabledKind);
begin
  if FDisabledKind <> Value then begin
    FDisabledKind := Value;
    FCommonData.Invalidate;
  end;
end;

procedure TsCustomListBox.WMEraseBkGnd(var Message: TWMPaint);
begin
  Message.Result := 1;
end;

procedure TsCustomListBox.WMPaint(var Message: TWMPaint);
var
  DC : hdc;
  PS : TPaintStruct;
  procedure PaintListBox;
  var
    DrawItemMsg: TWMDrawItem;
    DrawItemStruct: TDrawItemStruct;
    MeasureItemStruct: TMeasureItemStruct;
    R: TRect;
    MaxBottom, I: Integer;
  begin
    R := Rect(0, 0, Width, 0);
    MaxBottom := 0;
    for i := max(0, TopIndex) to Items.Count - 1 do begin
      R := ItemRect(i);
      if RectIsVisible(ClientRect, R) then begin
        MaxBottom := Max(R.Bottom, MaxBottom);
        DrawItemMsg.Msg := CN_DRAWITEM;
        DrawItemMsg.DrawItemStruct := @DrawItemStruct;
        DrawItemMsg.Ctl := Handle;
        DrawItemStruct.CtlType := ODT_LISTBOX;
        DrawItemStruct.itemAction := ODA_DRAWENTIRE;
        if MultiSelect then begin
          if Selected[i]
            then DrawItemStruct.itemState := ODS_SELECTED
            else DrawItemStruct.itemState := 0;
          if (ItemIndex = i) and Focused then DrawItemStruct.itemState := DrawItemStruct.itemState or ODS_FOCUS;
        end
        else if ItemIndex = i then begin
          DrawItemStruct.itemState := ODS_SELECTED;
          if Focused then DrawItemStruct.itemState := DrawItemStruct.itemState or ODS_FOCUS;
        end
        else DrawItemStruct.itemState := 0;
        DrawItemStruct.hDC := DC;
        DrawItemStruct.CtlID := Handle;
        DrawItemStruct.hwndItem := Handle;
        DrawItemStruct.rcItem := R;

        MeasureItemStruct.itemWidth := WidthOf(R);
        MeasureItemStruct.itemHeight := ItemHeight;
        if (i >= 0) and (i < Items.Count) then DrawItemStruct.itemData := Longint(Pointer(Items.Objects[I])) else DrawItemStruct.itemData := 0;
        DrawItemStruct.itemID := I;
        Dispatch(DrawItemMsg);
      end
      else Break;
    end;
    if R.Bottom < Height - 4 then BitBlt(DC, R.Left, R.Bottom, Width, Height - R.Bottom - 2, FCommonData.FCacheBmp.Canvas.Handle, R.Left + 2, R.Bottom + 2, SRCCOPY);
    if R.Right < Width - 4 then BitBlt(DC, R.Right, 0, Width - 2 - R.Right, R.Bottom, FCommonData.FCacheBmp.Canvas.Handle, R.Right, 2, SRCCOPY);
    if R.Left > 2 then BitBlt(DC, 0, MaxBottom, R.Left, Height - MaxBottom - 2, FCommonData.FCacheBmp.Canvas.Handle, 2, MaxBottom + 2, SRCCOPY);
  end;
begin
  if SkinData.Skinned then begin
    if Message.DC <> 0 then DC := Message.DC else begin
      BeginPaint(Handle, PS);
      DC := GetDC(Handle);
    end;
    SkinData.FUpdating := SkinData.Updating;
    if not SkinData.FUpdating then begin
      PaintListBox;
    end;
    if Message.DC <> DC then begin
      ReleaseDC(Handle, DC);
      EndPaint(Handle, PS);
    end;
  end
  else inherited;
end;

procedure TsCustomListBox.WndProc(var Message: TMessage);
begin
{$IFDEF LOGGED}
  AddToLog(Message);
{$ENDIF}
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_CTRLHANDLED : begin Message.Result := 1; Exit end;
    AC_GETAPPLICATION : begin Message.Result := longint(Application); Exit end;
    AC_REMOVESKIN : if LongWord(Message.LParam) = LongWord(SkinData.SkinManager) then begin
      if ListSW <> nil then FreeAndNil(ListSW);
      CommonWndProc(Message, FCommonData);
      Color := clWindow;
      exit
    end;
    AC_REFRESH : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
      CommonWndProc(Message, FCommonData);
      if not InAnimationProcess then RedrawWindow(Handle, nil, 0, RDW_INVALIDATE or RDW_ERASE or RDW_FRAME);
      exit
    end;
    AC_SETNEWSKIN : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
      CommonWndProc(Message, FCommonData);
      if HandleAllocated then RefreshEditScrolls(SkinData, ListSW);
      exit
    end;
    AC_GETCONTROLCOLOR : if not FCommonData.Skinned then begin
      Message.Result := ColorToRGB(Color);
      Exit
    end;
  end;
  if not ControlIsReady(Self) or not FCommonData.Skinned then inherited else begin
    case Message.Msg of
      WM_VSCROLL, WM_HSCROLL : begin
        SendMessage(Handle, WM_SETREDRAW, 0, 0);
        SkinData.FUpdating := True;
      end;
      WM_ERASEBKGND : begin
        if SkinData.FUpdating then Exit;
        if TWMPaint(Message).DC <> 0 then WMEraseBkGnd(TWMPaint(Message));
        if Message.Result = 1 then Exit;
      end;
      WM_MOUSEWHEEL : begin
        SendMessage(Handle, WM_SETREDRAW, 0, 0);
      end;
    end;
    CommonWndProc(Message, FCommonData);
    inherited;
    case Message.Msg of
      WM_MOUSEWHEEL : begin
        SendMessage(Handle, WM_SETREDRAW, 1, 0);
        InvalidateRect(Handle, nil, False);
      end;
      WM_VSCROLL, WM_HSCROLL : begin
        SendMessage(Handle, WM_SETREDRAW, 1, 0);
        SkinData.FUpdating := False;
        RedrawWindow(Handle, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW);
      end;
      WM_ENABLE : if Visible and not (csLoading in ComponentState) then begin
        FCommonData.BGChanged := True;
        RedrawWindow(Handle, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW or RDW_ERASE);
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

{$IFNDEF DELPHI6UP}
function TsCustomListBox.Count: integer;
begin
  Result := Items.Count;
end;
{$ENDIF}

end.

