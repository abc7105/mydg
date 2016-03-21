unit sPageControl;
{$I sDefs.inc}
{.$DEFINE LOGGED}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs{$IFNDEF DELPHI5}, Types{$ENDIF},
  ComCtrls, sCommonData, sConst, sFade, sUpDown, extctrls, sSpeedButton, acSBUtils
  {$IFDEF TNTUNICODE}, TntComCtrls, TntGraphics{$ENDIF};

type
{$IFNDEF NOTFORHELP}
  TacCloseAction = (acaHide, acaFree);
  TacCloseBtnClick = procedure(Sender: TComponent; TabIndex : integer; var CanClose: boolean; var Action: TacCloseAction) of object;

  TsPageControl = class;

  TsTabSkinData = class(TPersistent)
  private
    FCustomColor: boolean;
    FCustomFont: boolean;
    FSkinSection: string;
    procedure SetCustomColor(const Value: boolean);
    procedure SetCustomFont(const Value: boolean);
    procedure SetSkinSection(const Value: string);
  published
    property CustomColor : boolean read FCustomColor write SetCustomColor;
    property CustomFont : boolean read FCustomFont write SetCustomFont;
    property SkinSection : TsSkinSection read FSkinSection write SetSkinSection;
  end;

  TsTabSheet = class;

  TsTabBtn = class(TsSpeedButton)
  public
    Page : TsTabSheet;
    constructor Create(AOwner:TComponent); override;
    procedure Paint; override;
    procedure UpdateGlyph;
  end;

{$IFDEF TNTUNICODE}
  TsTabSheet = class(TTntTabSheet)
{$ELSE}
  TsTabSheet = class(TTabSheet)
{$ENDIF}
  private
    FTabSkin: TsSkinSection;
    FButtonSkin: TsSkinSection;
    FUseCloseBtn: boolean;
    FCommonData: TsTabSkinData;
    procedure SetUseCloseBtn(const Value: boolean);
    procedure SetButtonSkin(const Value: TsSkinSection);
    procedure SetTabSkin(const Value: TsSkinSection);
  public
    Btn : TsTabBtn;
    constructor Create(AOwner:TComponent); override;
    procedure CreateParams(var Params: TCreateParams); override;
    destructor Destroy; override;
    procedure WMEraseBkGnd (var Message: TWMPaint); message WM_ERASEBKGND;
    procedure WMNCPaint (var Message: TWMPaint); message WM_NCPAINT;
    procedure WndProc (var Message: TMessage); override;
  published
    property SkinData : TsTabSkinData read FCommonData write FCommonData;
    property ButtonSkin : TsSkinSection read FButtonSkin write SetButtonSkin;
    property TabSkin : TsSkinSection read FTabSkin write SetTabSkin;
    property UseCloseBtn : boolean read FUseCloseBtn write SetUseCloseBtn default True;
  end;
{$ENDIF}

{$IFDEF TNTUNICODE}
  TsPageControl = class(TTntPageControl)
{$ELSE}
  TsPageControl = class(TPageControl)
{$ENDIF}
{$IFNDEF NOTFORHELP}
  private
    StoredVisiblePageCount : integer;
    ChangedSkinSection : string;
    FCommonData: TsCommonData;
    FAnimatEvents: TacAnimatEvents;
    FShowCloseBtns: boolean;
    FOnCloseBtnClick: TacCloseBtnClick;
    FCloseBtnSkin: TsSkinSection;
    FNewDockSheet: TsTabSheet;
    procedure CheckUpDown;
    procedure CMHintShow(var Message: TMessage); message CM_HINTSHOW;
    procedure CNNotify(var Message: TWMNotify); message CN_NOTIFY;
    procedure AcPaint(var Message: TWMPaint);
    procedure DrawSkinTabs(CI : TCacheInfo);
    procedure DrawSkinTab(PageIndex: Integer; State : integer; Bmp : TBitmap; OffsetPoint : TPoint); overload;
    procedure DrawSkinTab(PageIndex: Integer; State : integer; DC : hdc); overload;
    function PageRect: TRect;
    function TabsRect: TRect;
    function SkinTabRect(Index : integer; Active : boolean) : TRect;
    function TabRow(TabIndex : integer) : integer;
    function GetActivePage: TsTabSheet;
    procedure SetActivePage(const Value: TsTabSheet);
    procedure UpdateBtnData;
    procedure PaintButtonEx(PageIndex : integer; BtnState : integer; TabState : integer);
    procedure PaintButtons(DC : hdc);
    function BtnRect(TabIndex : integer) : TRect;
    procedure SetShowCloseBtns(const Value: boolean);
    procedure SetCloseBtnSkin(const Value: TsSkinSection);
    function SpinSection : string;
    procedure CMDockClient(var Message: TCMDockClient); message CM_DOCKCLIENT;
  private
    FShowUpDown: boolean;
    FShowFocus: boolean;
    procedure SetShowUpDown(const Value: boolean);
    procedure SetShowFocus(const Value: boolean);
  protected
    SpinWnd : TacSpinWnd;
    CurItem : integer;
    BtnIndex : integer;
    BtnWidth : integer;
    BtnHeight : integer;
    procedure DoAddDockClient(Client: TControl; const ARect: TRect); override;
    procedure PaintButton(DC : hdc; TabRect : TRect; State : integer; BG : TCacheInfo); virtual;
    function GetTabUnderMouse(p : TPoint) : integer;
    procedure RepaintTab(i, State : integer; TabDC : hdc = 0);
    procedure RepaintTabs(DC : HDC; ActiveTabNdx : integer);
    function VisibleTabsCount : integer;
  public
    property ShowUpDown : boolean read FShowUpDown write SetShowUpDown default True;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure WndProc (var Message: TMessage); override;
    procedure Loaded; override;
    procedure AfterConstruction; override;
    procedure UpdateActivePage; override;
    procedure CloseClick(Sender: TObject);
    procedure ArrangeButtons;
  published
    property ActivePage: TsTabSheet read GetActivePage write SetActivePage;
    property AnimatEvents : TacAnimatEvents read FAnimatEvents write FAnimatEvents default [aeGlobalDef];
    property Style;
{$ENDIF}
    property CloseBtnSkin : TsSkinSection read FCloseBtnSkin write SetCloseBtnSkin;
    property ShowCloseBtns : boolean read FShowCloseBtns write SetShowCloseBtns default False;
    property ShowFocus : boolean read FShowFocus write SetShowFocus default True;
    property SkinData : TsCommonData read FCommonData write FCommonData;
    property OnCloseBtnClick: TacCloseBtnClick read FOnCloseBtnClick write FOnCloseBtnClick;
  end;

procedure DeletePage(Page : TsTabSheet); // Page removing without switching to the first page

implementation

uses sMessages, sVclUtils, acntUtils, sMaskData, sStyleSimply, math, Commctrl, sSkinProps, sAlphaGraph, Buttons,
  sGraphUtils, sTabControl{$IFDEF DELPHI7UP}, Themes{$ENDIF}, sSkinManager {$IFDEF LOGGED}, sDebugMsgs{$ENDIF};

{ TsPageControl }

const
  BtnOffs = 1;
  iBtnWidth = 15;
  iBtnHeight = 15;

var
  acBtnPressed : boolean = False;

procedure DeletePage(Page : TsTabSheet);
begin
  if (Page <> nil) and (Page.PageIndex > 0) then begin
    Page.PageIndex := Page.PageIndex - 1;
    Page.Free
  end;
end;

procedure TsPageControl.AfterConstruction;
begin
  inherited;
  SkinData.Loaded;
end;

procedure TsPageControl.CheckUpDown;
var
  Wnd : HWND;
begin
  if (csLoading in ComponentState) or (csCreating in ControlState) then Exit;
  if FCommonData.Skinned then begin
    Wnd := FindWindowEx(Handle, 0, UPDOWN_CLASS, nil);
    if Wnd <> 0 then begin
      if FShowUpDown then begin
        if SpinWnd <> nil then begin
          if SpinWnd.CtrlHandle <> Wnd
            then FreeAndNil(SpinWnd);
        end;
        if SpinWnd = nil then SpinWnd := TacSpinWnd.Create(Wnd, nil, SkinData.SkinManager, SpinSection);
        InitCtrlData(Wnd, SpinWnd.ParentWnd, SpinWnd.WndRect, SpinWnd.ParentRect, SpinWnd.WndSize, SpinWnd.WndPos, SpinWnd.Caption);
      end
      else DestroyWindow(Wnd);
    end;
  end
  else if SpinWnd <> nil then FreeAndNil(SpinWnd);
end;

procedure TsPageControl.CMDockClient(var Message: TCMDockClient);
var
  IsVisible: Boolean;
  DockCtl: TControl;
  I: Integer;
begin
  with Message do begin
    Result := 0;
    DockCtl := DockSource.Control;
    for I := 0 to PageCount - 1 do begin
      if DockCtl.Parent = Pages[I] then begin
        Pages[I].PageIndex := PageCount - 1;
        Exit;
      end;
    end;
    FNewDockSheet := TsTabSheet.Create(Self);
    try
      try
        if DockCtl is TCustomForm then FNewDockSheet.Caption := TCustomForm(DockCtl).Caption;
        FNewDockSheet.PageControl := Self;
        DockCtl.Dock(Self, DockSource.DockRect);
      except
        FNewDockSheet.Free;
        raise;
      end;
      IsVisible := DockCtl.Visible;
      FNewDockSheet.TabVisible := IsVisible;
      if IsVisible then ActivePage := FNewDockSheet;
      DockCtl.Align := alClient;
    finally
      FNewDockSheet := nil;
    end;
  end;
end;

procedure TsPageControl.CMHintShow(var Message: TMessage);
var
  Item : integer;
  P : TPoint;
begin
  with TCMHintShow(Message) do begin
    Item := GetTabUnderMouse(Point(HintInfo.CursorPos.X, HintInfo.CursorPos.Y));
    if Item <> -1 then with HintInfo^ do begin
      P := ClientToScreen(HintInfo.CursorPos);
      P.X := P.X + GetSystemMetrics(SM_CXCURSOR) div 2;
      P.Y := P.Y + GetSystemMetrics(SM_CYCURSOR) div 2;
      HintInfo.HintPos := P;
      HintInfo.HintStr := Pages[Item].Hint;
      Message.Result := 0;
    end;
  end;
end;

procedure TsPageControl.CNNotify(var Message: TWMNotify);
begin
  if FCommonData.Skinned then case Message.NMHdr^.code of
    TCN_SELCHANGE : begin
      inherited;
      if not (csDesigning in ComponentState) and FCommonData.SkinManager.AnimEffects.PageChange.Active and (ow <> nil) then begin
        AnimShowControl(Self, FCommonData.SkinManager.AnimEffects.PageChange.Time);
        if ActivePage <> nil then RedrawWindow(ActivePage.Handle, nil, 0, RDW_ERASE or RDW_INVALIDATE or RDW_ALLCHILDREN);
      end;
      Exit;
    end;
    TCN_SELCHANGING : begin
      if not (csDesigning in ComponentState) and FCommonData.SkinManager.AnimEffects.PageChange.Active then PrepareForAnimation(Self);
    end;
  end;
  inherited;
  if FCommonData.Skinned then case Message.NMHdr^.code of
    TCN_SELCHANGING : if (Message.Result = 1) or (ow = nil) {Animation cancelled} then begin
      SendMessage(Handle, WM_SETREDRAW, 1, 0);
      if ow <> nil then FreeAndNil(ow);
      SendMessage(Handle, WM_MOUSEMOVE, 0, 0);
    end;
  end;
end;

constructor TsPageControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCommonData := TsCommonData.Create(Self, True);
  FCommonData.COC := COC_TsPageControl;
  FAnimatEvents := [aeGlobalDef];
  FShowCloseBtns := False;
  FShowUpDown := True;
  FShowFocus := True;
  SpinWnd := nil;
  CurItem := -1;
end;

destructor TsPageControl.Destroy;
begin
  if Assigned(SpinWnd) then FreeAndNil(SpinWnd);
  if Assigned(FCommonData) then FreeAndNil(FCommonData);
  inherited Destroy;
end;

procedure TsPageControl.DoAddDockClient(Client: TControl; const ARect: TRect);
begin
  if FNewDockSheet <> nil then Client.Parent := FNewDockSheet;
end;

procedure TsPageControl.DrawSkinTab(PageIndex, State: integer; Bmp : TBitmap; OffsetPoint : TPoint);
const
  Spacing = 7;
var
  rText, aRect, imgRect, R : TRect;
  VertFont : TLogFont;
  pFont : PLogFontA;
  i, h, w : integer;
  CI : TCacheInfo;
  TabIndex, TabMask, TabState : integer;
  TabSection : string;
  TempBmp : Graphics.TBitmap;
  SavedDC, DC : hdc;
  lCaption: ACString;
  Flags : Cardinal;
  procedure MakeVertFont(Orient : integer);
  begin
    pFont := PLogFontA(@VertFont);
    GetObject(Bmp.Canvas.Handle, SizeOf(TLogFont), pFont);
    VertFont.lfEscapement := Orient;
    VertFont.lfHeight := Font.Height;
    VertFont.lfStrikeOut := integer(fsStrikeOut in Font.Style);
    VertFont.lfItalic := integer(fsItalic in Font.Style);
    VertFont.lfUnderline := integer(fsUnderline	in Font.Style);
    VertFont.lfWeight := FW_NORMAL;
    VertFont.lfCharSet := Font.Charset;

    VertFont.lfWidth := 0;
    Vertfont.lfOutPrecision := OUT_DEFAULT_PRECIS;
    VertFont.lfClipPrecision := CLIP_DEFAULT_PRECIS;
    VertFont.lfOrientation := VertFont.lfEscapement;
    VertFont.lfPitchAndFamily := Default_Pitch;
    VertFont.lfQuality := Default_Quality;
    if Font.Name <> 'MS Sans Serif' then StrPCopy(VertFont.lfFaceName, Font.Name) else VertFont.lfFaceName := 'Arial';
    Bmp.Canvas.Font.Handle := CreateFontIndirect(VertFont);
    if State <> 0
      then Bmp.Canvas.Font.Color := FCommonData.SkinManager.gd[TabIndex].HotFontColor[1]
      else Bmp.Canvas.Font.Color := FCommonData.SkinManager.gd[TabIndex].FontColor[1];
  end;
  procedure KillVertFont; begin Bmp.Canvas.Font.Assign(Font) end;
begin
  R := SkinTabRect(Pages[PageIndex].TabIndex, PageIndex = ActivePageIndex);
  if (PageIndex = -1) or ((State = 1) and (R.Left < 0)) then Exit;
  if not Pages[PageIndex].TabVisible then Exit;

  rText := SkinTabRect(Pages[PageIndex].TabIndex, (State = 2) and (Pages[PageIndex] = ActivePage));
  aRect := rText;

  // Tabs drawing
  if FCommonData.SkinManager.ConstData.IndexTabTop > 0 then begin // new style
    TabState := State;
    case Style of
      tsTabs : begin
        if TsTabSheet(Pages[PageIndex]).TabSkin <> '' then begin
          TabSection := TsTabSheet(Pages[PageIndex]).TabSkin;
          TabIndex := FCommonData.SkinManager.GetSkinIndex(TabSection);
          TabMask := FCommonData.SkinManager.GetMaskIndex(TabSection, s_BordersMask);
          if (TabMask = -1) and (SkinData.SkinManager.gd[TabIndex].ParentClass <> '') then begin
            TabMask := FCommonData.SkinManager.GetMaskIndex(SkinData.SkinManager.gd[TabIndex].ParentClass, s_BordersMask);
          end;
        end
        else case TabPosition of // Init of skin data
          tpTop : begin TabIndex := FCommonData.SkinManager.ConstData.IndexTabTop; TabMask := FCommonData.SkinManager.ConstData.MaskTabTop; TabSection := s_TabTop end;
          tpLeft : begin TabIndex := FCommonData.SkinManager.ConstData.IndexTabLeft; TabMask := FCommonData.SkinManager.ConstData.MaskTabLeft; TabSection := s_TabLeft end;
          tpBottom : begin TabIndex := FCommonData.SkinManager.ConstData.IndexTabBottom; TabMask := FCommonData.SkinManager.ConstData.MaskTabBottom; TabSection := s_TabBottom end
          else begin TabIndex := FCommonData.SkinManager.ConstData.IndexTabRight; TabMask := FCommonData.SkinManager.ConstData.MaskTabRight; TabSection := s_TabRight end;
        end;
      end;
      tsButtons : begin
        if TsTabSheet(Pages[PageIndex]).TabSkin <> '' then TabSection := TsTabSheet(Pages[PageIndex]).TabSkin else TabSection := s_Button;
        TabIndex := FCommonData.SkinManager.GetSkinIndex(TabSection);
        TabMask := FCommonData.SkinManager.GetMaskIndex(TabSection, s_BordersMask);
      end
      else begin
        if TsTabSheet(Pages[PageIndex]).TabSkin <> '' then TabSection := TsTabSheet(Pages[PageIndex]).TabSkin else TabSection := s_ToolButton;
        TabIndex := FCommonData.SkinManager.GetSkinIndex(TabSection);
        TabMask := FCommonData.SkinManager.GetMaskIndex(TabSection, s_BordersMask);
      end;
    end;
    if TabIndex <> -1 then if FCommonData.SkinManager.gd[TabIndex].States <= TabState then TabState := FCommonData.SkinManager.gd[TabIndex].States - 1;

    if FCommonData.SkinManager.IsValidImgIndex(TabMask) then begin // Drawing of tab
      TempBmp := CreateBmp32(WidthOf(aRect), HeightOf(aRect));
      try
        if (State = 2) and (Pages[PageIndex] = ActivePage) then begin
          // Restore BG for Active tab
          BitBlt(TempBmp.Canvas.Handle, aRect.Left + OffsetPoint.x, aRect.Top + OffsetPoint.y, TempBmp.Width, TempBmp.Height,
                   FCommonData.FCacheBmp.Canvas.Handle, aRect.Left, aRect.Top, SRCCOPY);
          OffsetRect(R, OffsetPoint.X, OffsetPoint.Y);
          BitBlt(TempBmp.Canvas.Handle, 0, 0, TempBmp.Width, TempBmp.Height,
                 SkinData.FCacheBmp.Canvas.Handle, SkinTabRect(Pages[PageIndex].TabIndex, PageIndex = ActivePageIndex).Left,
                 SkinTabRect(Pages[PageIndex].TabIndex, PageIndex = ActivePageIndex).Top, SRCCOPY);
          // Paint active tab
          BitBlt(Bmp.Canvas.Handle, aRect.Left + OffsetPoint.x, aRect.Top + OffsetPoint.y, TempBmp.Width, TempBmp.Height, TempBmp.Canvas.Handle, 0, 0, SRCCOPY);
          CI := MakeCacheInfo(TempBmp);
          PaintItem(TabIndex, TabSection, CI, True, TabState, Rect(0, 0, TempBmp.Width, TempBmp.Height),
                           Point(0, 0), Bmp, FCommonData.SkinManager);
        end
        else begin
          CI := MakeCacheInfo(FCommonData.FCacheBmp);
          if State = 1 then CI.X := 0;
          PaintItem(TabIndex, TabSection, CI, True, TabState, Rect(0, 0, TempBmp.Width, TempBmp.Height),
                           Point(aRect.Left, aRect.Top), TempBmp, FCommonData.SkinManager);

          SavedDC := SaveDC(Bmp.Canvas.Handle);
          R := PageRect;
          if TabPosition in [tpLeft, tpTop] then ExcludeClipRect(Bmp.Canvas.Handle, R.Left, R.Top, R.Right, R.Bottom);
          BitBlt(Bmp.Canvas.Handle, aRect.Left + OffsetPoint.x, aRect.Top + OffsetPoint.y, TempBmp.Width, TempBmp.Height, TempBmp.Canvas.Handle, 0, 0, SRCCOPY);
          RestoreDC(Bmp.Canvas.Handle, SavedDC);
        end;
      finally
        FreeAndNil(TempBmp);
      end;
    end;
  end;

  // End of tabs drawing
  if not OwnerDraw then begin
    // Drawing of the tab content
    OffsetRect(rText, OffsetPoint.x, OffsetPoint.y);
    Flags := DT_SINGLELINE or DT_VCENTER;
    if UseRightToLeftReading then Flags := Flags or DT_RTLREADING;

{$IFDEF TNTUNICODE}
    if Pages[PageIndex] is TTntTabSheet then lCaption := TTntTabSheet(Pages[PageIndex]).Caption else
{$ENDIF}
    lCaption := Pages[PageIndex].Caption;

    case TabPosition of
      tpTop, tpBottom : begin
        Bmp.Canvas.Font.Assign(Font);
        dec(rText.Bottom);

        if (Images <> nil) and (Pages[PageIndex].ImageIndex > -1) and (Pages[PageIndex].ImageIndex <= Images.Count - 1) then begin
          imgRect.Left := rText.Left + (WidthOf(rText) - (acTextWidth(Bmp.Canvas, lCaption) + Images.Width + Spacing)) div 2 + 1;
          imgRect.Top := rText.Top + (HeightOf(rText) - Images.Height) div 2 - 1;
          imgRect.Right := imgRect.Left + Images.Width;
          Images.Draw(Bmp.Canvas, imgRect.Left, imgRect.Top, Pages[PageIndex].ImageIndex, True);
          rText.Left := imgRect.Right + Spacing - 1;
          acWriteTextEx(Bmp.Canvas, PacChar(lCaption), Enabled, rText, Flags or DT_LEFT, TabIndex, TabState <> 0, FCommonData.SkinManager);
        end
        else begin
          acWriteTextEx(Bmp.Canvas, PacChar(lCaption), True, rText, Flags or DT_CENTER, TabIndex, TabState <> 0, FCommonData.SkinManager);
        end;
        if Focused and (State = 2) and (Pages[PageIndex].Caption <> '') then begin
          R := rText;
          acDrawText(Bmp.Canvas.Handle, PACChar(lCaption), R, DT_CALCRECT);
          rText.Left := (WidthOf(aRect) - WidthOf(R)) div 2;
          rText.Top := (HeightOf(aRect) - HeightOf(R)) div 2;
          rText.Right := rText.Left + WidthOf(R);
          rText.Bottom := rText.Top + HeightOf(R);
          InflateRect(rText, 2, 1);
          if (Images <> nil) and (Pages[PageIndex].ImageIndex > -1) and (Pages[PageIndex].ImageIndex <= Images.Count - 1) then OffsetRect(rText, Images.Width div 2, 0);
          if FShowFocus then FocusRect(Bmp.Canvas, rText);
        end;

      end;
      tpLeft : begin
        Bmp.Canvas.Brush.Style := bsClear;
        MakeVertFont(-2700);
        with acTextExtent(bmp.Canvas, lCaption) do begin
          h := cx;
          w := cy;
        end;
        if not Enabled then Bmp.Canvas.Font.Color := clGray;
        if (Images <> nil) and (Pages[PageIndex].ImageIndex > -1) and (Pages[PageIndex].ImageIndex <= Images.Count - 1) then begin
          if Pages[PageIndex] = ActivePage then OffsetRect(rText, 2, 0);
          i := rText.Bottom - (HeightOf(rText) - (Images.Height + 4 + h)) div 2 - Images.Height;
          Images.Draw(Bmp.Canvas, rText.Left + (WidthOf(rText) - Images.Width) div 2, i, Pages[PageIndex].ImageIndex, Enabled);
          Bmp.Canvas.Brush.Style := bsClear;
          acTextRect(bmp.Canvas, rText, rText.Left + (WidthOf(rText) - w) div 2, i - 4, lCaption);
          InflateRect(rText, (w - WidthOf(rText)) div 2, (h - HeightOf(rText)) div 2 + 2);
          OffsetRect(rText, 0, - (4 + Images.Height) div 2);
        end
        else begin
          Bmp.Canvas.Brush.Style := bsClear;
          acTextRect(Bmp.Canvas, rText, rText.Left + (WidthOf(rText) - w) div 2, rText.Bottom - (HeightOf(rText) - h) div 2, lCaption);
          InflateRect(rText, (w - WidthOf(rText)) div 2, (h - HeightOf(rText)) div 2);
        end;
        if FShowFocus and Focused and (State <> 0) then FocusRect(Bmp.Canvas, rText);
        KillVertFont;
      end;

      tpRight : begin
        Bmp.Canvas.Brush.Style := bsClear;
        MakeVertFont(-900);
        OffsetRect(rText, -2, -1);
        with acTextExtent(bmp.Canvas, lCaption) do begin
          h := cx;
          w := cy;
        end;
        if not Enabled then Bmp.Canvas.Font.Color := clGray;
        if (Images <> nil) and (Pages[PageIndex].ImageIndex > -1) and (Pages[PageIndex].ImageIndex <= Images.Count - 1) then begin
          if Pages[PageIndex] = ActivePage then OffsetRect(rText, 2, 0);
          i := rText.Top + (HeightOf(rText) - (Images.Height + 4 + h)) div 2;
          Images.Draw(Bmp.Canvas, rText.Left + (WidthOf(rText) - Images.Width) div 2, i, Pages[PageIndex].ImageIndex, Enabled);
          Bmp.Canvas.Brush.Style := bsClear;
          acTextRect(Bmp.Canvas, rText, rText.Left + (WidthOf(rText) - w) div 2 + Bmp.Canvas.TextHeight(lCaption), i + 4 + Images.Height, lCaption);

          InflateRect(rText, (w - WidthOf(rText)) div 2, (h - HeightOf(rText)) div 2 + 2);
          OffsetRect(rText, 0, + (4 + Images.Height) div 2);
        end
        else begin
          Bmp.Canvas.Brush.Style := bsClear;
{$IFDEF TNTUNICODE}
          if Pages[PageIndex] is TTntTabSheet
            then TextRectW(Bmp.Canvas, rText, rText.Left + (WidthOf(rText) - w) div 2 + Bmp.Canvas.TextHeight(Pages[PageIndex].Caption),
                              rText.Top + (HeightOf(rText) - h) div 2, PWideChar(TTntTabSheet(Pages[PageIndex]).Caption))
            else
{$ENDIF}
          Bmp.Canvas.TextRect(rText, rText.Left + (WidthOf(rText) - w) div 2 + Bmp.Canvas.TextHeight(Pages[PageIndex].Caption),
                              rText.Top + (HeightOf(rText) - h) div 2, PChar(Pages[PageIndex].Caption));

          InflateRect(rText, (w - WidthOf(rText)) div 2, (h - HeightOf(rText)) div 2 + 2);
        end;
        KillVertFont;
        if FShowFocus and Focused and (State <> 0) then FocusRect(Bmp.Canvas, rText);
      end;
    end;
  end
  else if Assigned(OnDrawTab) then begin
    DC := Canvas.Handle;
    Canvas.Handle := Bmp.Canvas.Handle;
    SavedDC := SaveDC(Canvas.Handle);
    if Bmp <> FCommonData.FCacheBmp then MoveWindowOrg(Canvas.Handle, -aRect.Left, -aRect.Top);
    OnDrawTab(Self, Pages[PageIndex].TabIndex, aRect, State <> 0);
    if Bmp <> FCommonData.FCacheBmp then MoveWindowOrg(Canvas.Handle,  aRect.Left, aRect.Top);
    RestoreDC(Canvas.Handle, SavedDC);
    Canvas.Handle := DC;
  end;
end;

procedure TsPageControl.DrawSkinTab(PageIndex, State: integer; DC: hdc);
var
  aRect : TRect;
  TempBmp : TBitmap;
begin
  if (PageIndex < 0) or (Pages[PageIndex].TabIndex < 0) then Exit;
  aRect := SkinTabRect(Pages[PageIndex].TabIndex, State = 2);
  TempBmp := CreateBmp32(WidthOf(aRect), HeightOf(aRect));

  DrawSkinTab(PageIndex, State, TempBmp, Point(-aRect.Left, -aRect.Top));
  BitBlt(DC, aRect.Left, aRect.Top, WidthOf(aRect), HeightOf(aRect), TempBmp.Canvas.Handle, 0, 0, SRCCOPY);
  if FShowCloseBtns and TsTabSheet(Pages[PageIndex]).UseCloseBtn then PaintButton(DC, aRect, 0, MakeCacheInfo(TempBmp));

  FreeAndNil(TempBmp);
end;

procedure TsPageControl.DrawSkinTabs(CI: TCacheInfo);
var
  i, Row, rc : integer;
  aRect: TRect;
begin
  if (csDestroying in ComponentState) then Exit;
  aRect := TabsRect;
  if not ci.Ready then begin
    FCommonData.FCacheBmp.Canvas.Brush.Style := bsSolid;
    FCommonData.FCacheBmp.Canvas.Brush.Color := CI.FillColor;
    FCommonData.FCacheBmp.Canvas.FillRect(aRect);
  end
  else BitBlt(FCommonData.FCacheBmp.Canvas.Handle, aRect.Left, aRect.Top, min(WidthOf(aRect), ci.Bmp.Width), min(HeightOf(aRect), ci.Bmp.Height),
         ci.Bmp.Canvas.Handle, ci.X + Left + aRect.Left, ci.Y + Top + aRect.Top, SRCCOPY);
  // Draw tabs in special order
  rc := RowCount;
  for Row := 1 to rc do
    for i := 0 to PageCount - 1 do if Pages[i].TabVisible and (Pages[i] <> ActivePage) and (TabRow(Pages[i].TabIndex) = Row)
      then DrawSkinTab(i, 0, FCommonData.FCacheBmp, Point(0, 0));
end;

function TsPageControl.GetActivePage: TsTabSheet;
begin
  Result := TsTabSheet(inherited ActivePage);
end;

function TsPageControl.GetTabUnderMouse(p: TPoint): integer;
var
  i : integer;
  R : TRect;
begin
  Result := -1;
  for i := 0 to Self.PageCount - 1 do begin
    R := SkinTabRect(Pages[i].TabIndex, False);
    if PtInRect(R, p) then begin
      Result := i;
      Exit;
    end;
  end;
end;

procedure TsPageControl.Loaded;
begin
  inherited;
  SkinData.Loaded;
  if ActivePage <> nil then AddToAdapter(ActivePage);
  CheckUpDown;
  ArrangeButtons;
end;

function TsPageControl.PageRect: TRect;
var
  r : TRect;
begin
  Result := Rect(0, 0, Width, Height);
  if Tabs.Count > 0 then begin
    AdjustClientRect(r);
    case TabPosition of
      tpTop : Result.Top := R.Top - TopOffset;
      tpBottom : Result.Bottom := R.Bottom + BottomOffset;
      tpLeft : Result.Left := R.Left - LeftOffset;
      tpRight : Result.Right := R.Right + RightOffset;
    end;
  end;
end;

procedure TsPageControl.RepaintTab(i, State: integer; TabDC : hdc = 0);
var
  DC, SavedDC : hdc;
  R : TRect;
  PS : TPaintStruct;
begin
  BeginPaint(Handle, PS);
  if TabDC = 0 then DC := GetDC(Handle) else DC := TabDC;
  SavedDC := SaveDC(DC);
  try
    R := TabRect(Pages[i].TabIndex); 
    if TabDC <> 0 then OffsetRect(R, - R.Left, - R.Top) else if ActivePage <> nil then begin
      InterSectClipRect(DC, R.Left, R.Top, R.Right, R.Bottom);
      R := SkinTabRect(ActivePage.TabIndex, True);
      ExcludeClipRect(DC, R.Left, R.Top, R.Right, R.Bottom);
    end;
    DrawSkinTab(i, State, DC);
  finally
    RestoreDC(DC, SavedDC);
    if TabDC = 0 then ReleaseDC(Handle, DC);
    EndPaint(Handle, PS);
  end;
end;

procedure TsPageControl.RepaintTabs(DC : HDC; ActiveTabNdx : integer);
var
  R : TRect;
  CI : TCacheInfo;
begin
  if not ((csDesigning in ComponentState) or not SkinData.SkinManager.AnimEffects.PageChange.Active) then Exit;
  CI := GetParentCache(FCommonData);
  if Tabs.Count > 0 then DrawSkinTabs(CI);
  R := TabsRect;
  BitBlt(DC, R.Left, R.Top, WidthOf(R), HeightOf(R) + 2, FCommonData.FCacheBmp.Canvas.Handle, R.Left, R.Top, SRCCOPY);
  PaintButtons(DC);
end;

procedure TsPageControl.SetActivePage(const Value: TsTabSheet);
begin
  inherited ActivePage := Value;
end;

function TsPageControl.SkinTabRect(Index: integer; Active : boolean): TRect;
begin
  Result := Rect(0, 0, 0, 0);
  if (Index > PageCount - 1) or (Index < 0) or (PageCount < 1) then Exit;
  Result := TabRect(Index); 
  if (Style <> tsTabs) or (Result.Left = Result.Right) then Exit;
  if Active then begin
    dec(Result.Bottom, 1);
  end
  else begin
    inc(Result.Bottom, 3);
    dec(Result.Right, 1);
  end;
  case TabPosition of
    tpTop : begin
      InflateRect(Result, 2 * Integer(Active), 2 * Integer(Active));
      inc(Result.Bottom, 1);
    end;
    tpBottom : begin
      InflateRect(Result, 2 * Integer(Active), Integer(Active));
      dec(Result.Top, 2);
      if Active then inc(Result.Bottom) else dec(Result.Bottom, 3);
    end;
    tpLeft : begin
      InflateRect(Result, 0, 1);
      inc(Result.Right, 2);
      if Active then InflateRect(Result, 1, 1) else begin
        dec(Result.Bottom, 4);
        inc(Result.Right, 2);
      end;
    end;
    tpRight : begin
      InflateRect(Result, 1, 0);
      OffsetRect(Result, -1, -1);
      if Active then begin
        InflateRect(Result, 1, 1);
        inc(Result.Bottom, 3);
      end
      else dec(Result.Bottom, 2);
    end;
  end;
end;

function TsPageControl.SpinSection: string;
begin
  if SkinData.SkinManager.GetSkinIndex(s_UpDown) < 0 then Result := s_Button else Result := s_UpDown;
end;

function TsPageControl.TabRow(TabIndex: integer): integer;
var
  h, w : integer;
  R, tR : TRect;
begin
  if RowCount > 1 then begin
    R := TabRect(TabIndex);
    tR := TabsRect;
    w := WidthOf(R);
    h := HeightOf(R);
    case TabPosition of
      tpTop   : Result := (R.Bottom + h div 2) div h;
      tpLeft  : Result := (R.Right + w div 2) div w;
      tpRight : Result := RowCount - (R.Right - tR.Left + w div 2) div w + 1
      else      Result := RowCount - (R.Bottom - tR.Top + h div 2) div h + 1;
    end;
  end
  else Result := 1;
end;

function TsPageControl.TabsRect: TRect;
var
  r : TRect;
begin
  Result := Rect(0, 0, Width, Height);
  if Tabs.Count > 0 then begin
    AdjustClientRect(r);
    case TabPosition of
      tpTop : Result.Bottom := R.Top - TopOffset;
      tpBottom : Result.Top := R.Bottom + BottomOffset;
      tpLeft : Result.Right := R.Left - LeftOffset;
      tpRight : Result.Left := R.Right + RightOffset;
    end;
  end;
end;

procedure TsPageControl.UpdateActivePage;
var
  DC, SavedDC : hdc;
begin
  Curitem := -1;
  inherited;
  if FCommonData.Skinned and not SkinData.SkinManager.AnimEffects.PageChange.Active then begin
    if FCommonData.Updating then Exit;
    if StoredVisiblePageCount <> VisibleTabsCount then begin
      Perform(WM_PAINT, 0, 0);
      if Assigned(ActivePage) then ActivePage.Repaint
    end
    else begin
      if ActivePage <> nil then begin // Active tab repainting
        DC := GetDC(Handle);
        SavedDC := SaveDC(DC);
        SkinData.BGChanged := True;
        RepaintTabs(DC, ActivePage.PageIndex);
        try
          DrawSkinTab(ActivePage.PageIndex, 2, DC)
        finally
          RestoreDC(DC, SavedDC);
          ReleaseDC(Handle, DC);
        end;
      end
      else FCommonData.Invalidate;
    end;
  end;
end;

function TsPageControl.VisibleTabsCount: integer;
var
  i : integer;
begin
  Result := 0;
  for i := 0 to PageCount - 1 do if Pages[i].TabVisible then inc(Result);
end;

procedure TsPageControl.AcPaint(var Message: TWMPaint);
var
  DC, SavedDC, SavedDC2, TabDC : hdc;
  ci : TCacheInfo;
  R : TRect;
  i : integer;
  b : boolean;
begin
  if not FCommonData.Skinned or (csDestroying in Parent.ComponentState) or (csLoading in ComponentState) then begin inherited; Exit end;
  SavedDC := 0;
  TabDC := 0;

  FCommonData.FUpdating := FCommonData.Updating;
  if not FCommonData.FUpdating then FCommonData.FUpdating := GetBoolMsg(Parent, AC_PREPARING); // Transparent BG may be not ready if PageControl haven't cached BG
  if not FCommonData.FUpdating then begin
    if (SkinData.CtrlSkinState and ACS_PRINTING = ACS_PRINTING) and (Message.DC = SkinData.PrintDC) then DC := Message.DC else begin
      DC := GetDC(Handle);
      SavedDC := SaveDC(DC);
    end;
    try
      // If transparent and form resizing processed
      b := FCommonData.BGChanged or FCommonData.HalfVisible or GetBoolMsg(Parent, AC_GETHALFVISIBLE);

      GetClipBox(DC, R);
      FCommonData.HalfVisible := (WidthOf(R) <> Width) or (HeightOf(R) <> Height);

      if (FCommonData.SkinSection = s_PageControl) and (TabPosition <> tpTop) then begin
        case TabPosition of
          tpLeft :   ChangedSkinSection := s_PageControl + 'LEFT';
          tpRight :  ChangedSkinSection := s_PageControl + 'RIGHT';
          tpBottom : ChangedSkinSection := s_PageControl + 'BOTTOM';
        end;
        FCommonData.SkinIndex := FCommonData.SkinManager.GetSkinIndex(ChangedSkinSection);
      end
      else ChangedSkinSection := FCommonData.SkinSection;

      CI := GetParentCache(FCommonData);

      InitCacheBmp(SkinData);
      if b then begin
        if Tabs.Count > 0 then DrawSkinTabs(CI);
        R := PageRect;
        PaintItem(FCommonData.SkinIndex, ChangedSkinSection, CI, False, 0, R, Point(Left + R.Left, Top + r.Top), FCommonData.FCacheBmp, FCommonData.SkinManager);
        FCommonData.BGChanged := False;
      end;
      if (Tabs.Count > 0) and (ActivePage <> nil) then begin
        R := SkinTabRect(ActivePage.TabIndex, True);
        TabDC := SaveDC(DC);
        ExcludeClipRect(DC, R.Left, R.Top, R.Right, R.Bottom);
      end;
      SavedDC2 := 0;
      if FShowCloseBtns then begin
        SavedDC2 := SaveDC(DC);
        for i := 0 to PageCount - 1 do if Pages[i].TabVisible and TsTabSheet(Pages[i]).UseCloseBtn and (Pages[i] <> ActivePage) then begin
          R := SkinTabRect(Pages[i].TabIndex, False);
          ExcludeClipRect(DC, R.Right - BtnWidth - BtnOffs, R.Top + BtnOffs, R.Right - BtnOffs, R.Top + BtnHeight + BtnOffs);
        end;
      end;
      CopyWinControlCache(Self, FCommonData,  Rect(0, 0, 0, 0), Rect(0, 0, Width, Height), DC, True);
      if FShowCloseBtns then RestoreDC(DC, SavedDC2);
      PaintButtons(DC);
      sVCLUtils.PaintControls(DC, Self, True, Point(0, 0)); // Painting of the skinned TGraphControls
      if (Tabs.Count > 0) and (ActivePage <> nil) then begin
        RestoreDC(DC, TabDC);
        if Message.Unused <> 1 then begin
          RestoreDC(DC, SavedDC);
          SavedDC := SaveDC(DC);
        end;
        DrawSkinTab(ActivePage.PageIndex, 2, DC);
        if Message.Unused = 1 then begin
          SavedDC := SaveDC(TWMPaint(Message).DC);
          MoveWindowOrg(TWMPaint(Message).DC, ActivePage.Left, ActivePage.Top);
        end;
{$IFDEF D2005}
        if (csDesigning in ComponentState)
          then begin
            RedrawWindow(ActivePage.Handle, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW or RDW_ERASE);
            SetParentUpdated(ActivePage);
          end
          else
{$ENDIF}
        if (ActivePage.BorderWidth > 0) then ActivePage.Perform(WM_NCPAINT, 0, 0);
        if Message.Unused = 1 then begin
          RestoreDC(TWMPaint(Message).DC, SavedDC);
        end;
      end;
    finally
      if DC <> Message.DC then begin
        RestoreDC(DC, SavedDC);
        ReleaseDC(Handle, DC);
      end;
    end;
  end;
  StoredVisiblePageCount := VisibleTabsCount;
  Message.Result := 1;
end;

procedure TsPageControl.WndProc(var Message: TMessage);
var
  DC, SavedDC : hdc;
  R : TRect;
  p : TPoint;
  NewItem, i, j : integer;
  b : boolean;
  Act : TacCloseAction;
  aMsg : tagMsg;
  PS : TPaintStruct;
begin
{$IFDEF LOGGED}
//  AddToLog(Message);
{$ENDIF}
  if (Message.Msg = cardinal(SM_ALPHACMD)) and Assigned(FCommonData) then case Message.WParamHi of
    AC_GETAPPLICATION : begin 
      Message.Result := longint(Application); 
      Exit; 
    end;
    AC_REMOVESKIN : if LongWord(Message.LParam) = LongWord(SkinData.SkinManager) then begin
      if Message.LParam = LongInt(SkinData.SkinManager) then begin
        CommonWndProc(Message, FCommonData);
        if (SpinWnd <> nil) then b := True else b := False;
        CheckUpDown;
        ArrangeButtons;
        if b then RecreateWnd else RedrawWindow(Handle, nil, 0, RDW_ERASE + RDW_INVALIDATE + RDW_UPDATENOW + RDW_FRAME);
      end;
      AlphaBroadcast(Self, Message);
    end;
    AC_REFRESH : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
      if (Message.LParam = LongInt(SkinData.SkinManager)) then begin
        CommonWndProc(Message, FCommonData);
        if Showing then begin
          RedrawWindow(Handle, nil, 0, RDW_ERASE + RDW_INVALIDATE + RDW_FRAME);
        end;
        if ActivePage <> nil then AddToAdapter(ActivePage);
        CheckUpDown;
        ArrangeButtons;
        if (SpinWnd <> nil) then SendMessage(SpinWnd.CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
      end;
      AlphaBroadcast(Self, Message);
      Exit;
    end;
    AC_SETNEWSKIN : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
      AlphaBroadcast(Self, Message);
      if (Message.LParam = LongInt(SkinData.SkinManager)) then CommonWndProc(Message, FCommonData);
      UpdateBtnData;
      ArrangeButtons;
      Exit;
    end;
    AC_PREPARING : begin
      Message.Result := integer(FCommonData.FUpdating);
      Exit;
    end;
    AC_ENDPARENTUPDATE : if FCommonData.Updating then begin
      FCommonData.Updating := False;
      RedrawWindow(Handle, nil, 0, RDW_INVALIDATE or RDW_ALLCHILDREN or RDW_UPDATENOW or RDW_ERASE or RDW_FRAME);
      if Assigned(ActivePage) then SendMessage(ActivePage.Handle, Message.Msg, Message.WParam, Message.LParam);
    end;
    AC_PREPARECACHE : ;
    AC_GETSKINSTATE : begin
      if Message.LParam = 1 then begin
        if (Parent <> nil) and Parent.HandleAllocated then begin
          UpdateSkinState(FCommonData, False); // Copy Skin state from Parent
          if ActivePage <> nil then for i := 0 to ActivePage.ControlCount - 1 do SendAMessage(ActivePage.Controls[i], AC_GETSKINSTATE, 1); // !!!
        end;
      end
      else Message.Result := FCommonData.CtrlSkinState;
      Exit;
    end
    else if CommonMessage(Message, FCommonData) then Exit;
  end
  else if (FCommonData <> nil) and FCommonData.Skinned(True) then case Message.Msg of
    4871 : FCommonData.BGChanged := True; // Items were added
    WM_KILLFOCUS, WM_SETFOCUS : if not (csDesigning in ComponentState) then begin
      b := FCommonData.BGChanged;
      inherited;
      FCommonData.BGChanged := b;
      if (WM_KILLFOCUS = Message.Msg) and (ActivePage <> nil) then begin
        DC := GetDC(Handle);
        try
          DrawSkinTab(ActivePage.PageIndex, 2, DC);
        finally
          ReleaseDC(Handle, DC);
        end;
      end;
      Exit;
    end else exit;
    WM_MOUSELEAVE, CM_MOUSELEAVE : if not (csDesigning in ComponentState) and (HotTrack or FShowCloseBtns) then begin
      inherited;
      if (CurItem <> -1) and (Pages[CurItem] <> ActivePage) then begin
        if HotTrack then RepaintTab(CurItem, 0);
        if FShowCloseBtns then begin
          if TsTabSheet(Pages[CurItem]).UseCloseBtn then PaintButtonEx(CurItem, 0, 0);
          if ActivePage <> nil then PaintButtonEx(ActivePage.PageIndex, 0, 2);
        end;
      end
      else if ActivePage <> nil then PaintButtonEx(ActivePage.PageIndex, 0, 2);
      acBtnPressed := False;
      CurItem := -1;
      Exit;
    end;
    WM_MOUSEMOVE : if not (csDesigning in ComponentState) then begin
      if (DefaultManager <> nil) and not (csDesigning in DefaultManager.ComponentState) then DefaultManager.ActiveControl := 0;
      b := (HotTrack or (Style <> tsTabs));
      if b or FShowCloseBtns then begin
        p.x := TCMHitTest(Message).XPos; p.y := TCMHitTest(Message).YPos;
        if PtInRect(TabsRect, p) then begin
          PeekMessage(aMsg, Handle, WM_PAINT, WM_PAINT, PM_REMOVE);
          if not (csDesigning in ComponentState) then Application.ProcessMessages;
          NewItem := GetTabUnderMouse(p);
          if (NewItem <> CurItem) then begin // if changed
            if (CurItem <> -1) then begin
              if (HotTrack or FShowCloseBtns) then begin
                if b then RepaintTab(CurItem, 0);
                PaintButtonEx(CurItem, 0, 0);
              end;
            end
            else if FShowCloseBtns and (ActivePage <> nil) and (NewItem <> ActivePage.PageIndex) then PaintButtonEx(ActivePage.PageIndex, 0, 2);
            inherited;
            CurItem := NewItem;
            if (CurItem <> -1) and (HotTrack or FShowCloseBtns) then begin
              if (Pages[CurItem] <> ActivePage) then begin
                if b then begin
                  RepaintTab(CurItem, integer(HotTrack));
                end;
              end
              else begin
                CurItem := -1;
                if FShowCloseBtns and (ActivePage <> nil) and PtInRect(BtnRect(ActivePage.PageIndex), p) then begin
                  PaintButtonEx(ActivePage.PageIndex, 1, 2);
                  Exit;
                end
                else begin
                  if ActivePage <> nil then PaintButtonEx(ActivePage.PageIndex, 0, 2);
                end;
              end;
            end;
            if FShowCloseBtns and (CurItem <> -1) then begin
              R := BtnRect(Pages[CurItem].TabIndex);
              if PtInRect(R, p) then begin
                PaintButtonEx(CurItem, 1, 1);
                if ActivePage <> nil then PaintButtonEx(ActivePage.PageIndex, 0, 2);
                Exit;
              end;
            end;
            Exit;
          end
          else begin
            if FShowCloseBtns and (CurItem <> -1) then begin
              PaintButtonEx(Pages[CurItem].PageIndex, integer(PtInRect(BtnRect(Pages[CurItem].TabIndex), p)), integer(HotTrack));
              Exit;
            end;
          end;
        end
        else if (CurItem <> -1) then begin
          if b then RepaintTab(CurItem, 0);
          PaintButtonEx(CurItem, 0, 0);
          CurItem := -1;
          acBtnPressed := False;
        end;
      end;
    end;
    WM_LBUTTONUP, WM_LBUTTONDOWN : if not (csDesigning in ComponentState) and FShowCloseBtns then begin
      p.x := TCMHitTest(Message).XPos; p.y := TCMHitTest(Message).YPos;
      if PtInRect(TabsRect, p) then begin
        j := 0;
        for i := 0 to PageCount - 1 do if Pages[i].TabVisible then begin
          R := SkinTabRect(j, Pages[i] = ActivePage);
          if PtInRect(R, p) then begin
            if TsTabSheet(Pages[i]).UseCloseBtn then begin
              if PtInRect(Rect(R.Right - BtnWidth - BtnOffs, R.Top + BtnOffs, R.Right - BtnOffs, R.Top + BtnHeight + BtnOffs), p) then begin
                PaintButtonEx(i, 1 + integer(WM_LBUTTONDOWN = Message.Msg), integer(HotTrack) + (2 - integer(HotTrack)) * integer(ActivePage = Pages[i]));
                if (WM_LBUTTONUP = Message.Msg) then begin
                  if not acBtnPressed then Exit;
                  b := True;
                  Act := acaFree;
                  if Assigned(OnCloseBtnClick) then OnCloseBtnClick(Self, i, b, Act);
                  if b and (Pages[i] <> nil) then begin
                    NewItem := ActivePageIndex;
                    Perform(WM_SETREDRAW, 0, 0);
                    if Act = acaFree then Pages[i].Free else Pages[i].TabVisible := False;
                    if NewItem <> 0 then ActivePageIndex := min(NewItem, PageCount - 1);
                    Perform(WM_SETREDRAW, 1, 0);
                    FCommonData.BGChanged := True;
                    RedrawWindow(Handle, nil, 0, RDW_ERASE or RDW_INVALIDATE or RDW_UPDATENOW or RDW_FRAME);
                  end;
                  acBtnPressed := False;
                end
                else acBtnPressed := True;
                Exit;
              end;
            end;
          end;
          inc(j);
        end;
      end;
    end;
  end;
  if Assigned(FCommonData) and FCommonData.Skinned then begin
    if CommonWndProc(Message, FCommonData) then Exit;
    case Message.Msg of
      WM_PRINT : begin
        CheckUpDown;
        ArrangeButtons;
        SkinData.Updating := False;
        AcPaint(TWMPaint(Message));
        if (SpinWnd <> nil) and IsWindowVisible(SpinWnd.CtrlHandle) then begin
          SavedDC := SaveDC(TWMPaint(Message).DC);
          try
            MoveWindowOrg(TWMPaint(Message).DC, SpinWnd.WndPos.X, SpinWnd.WndPos.Y);
            SendMessage(SpinWnd.CtrlHandle, WM_PAINT, Message.WParam, Message.LParam);
          finally
            RestoreDC(TWMPaint(Message).DC, SavedDC);
          end;
        end;
        Exit;
      end;
      WM_NCPAINT : begin
        if InAnimationProcess or (not IsCached(FCommonData) {and not acInScrolling}) then Exit;
        if ActivePage <> nil then begin
          FCommonData.FUpdating := FCommonData.Updating;
          if FCommonData.FUpdating then Exit;
          DC := GetDC(Handle);
          SavedDC := SaveDC(DC);
          try
            R := TabsRect;
            ExcludeClipRect(DC, R.Left, R.Top, R.Right, R.Bottom);
            R := ActivePage.BoundsRect;
            ExcludeClipRect(DC, R.Left, R.Top, R.Right, R.Bottom);
            if (Tabs.Count > 0) and (ActivePage <> nil) then begin
              R := SkinTabRect(ActivePage.TabIndex, True);
              ExcludeClipRect(DC, R.Left, R.Top, R.Right, R.Bottom);
            end;
            CopyWinControlCache(Self, FCommonData,  Rect(0, 0, 0, 0), Rect(0, 0, Width, Height), DC, True);
          finally
            RestoreDC(DC, SavedDC);
            ReleaseDC(Handle, DC);
          end;
        end;
        if SpinWnd <> nil then SendMessage(SpinWnd.CtrlHandle, WM_PAINT, 0, 0);
        Message.Result := 0;
      end;
      WM_ERASEBKGND : begin
        if not (InAnimationProcess or (SkinData.CtrlSkinState and ACS_FAST <> ACS_FAST)) and not InAnimationProcess then begin
          AcPaint(TWMPaint(Message));
        end;
        Message.Result := 1;
        Exit
      end;
      WM_PAINT : if Visible or (csDesigning in ComponentState) then begin
        DC := BeginPaint(Handle, PS);
        if IsCached(FCommonData) and not InAnimationProcess then begin
          Message.WParam := Longint(DC);
          AcPaint(TWMPaint(Message));
        end;
        EndPaint(Handle, PS);
        Message.Result := 0;
        Exit
      end
      else inherited;
      WM_STYLECHANGED, WM_STYLECHANGING, WM_HSCROLL : if not (csLoading in ComponentState) then begin
        FCommonData.BGChanged := True;
        RedrawWindow(Handle, nil, 0, RDW_ERASE or RDW_INVALIDATE or RDW_FRAME);
      end;
      TCM_SETCURSEL : begin // Remove in the v7.3
        if ActivePage <> nil then for i := 0 to ActivePage.ControlCount - 1 do SendAMessage(ActivePage.Controls[i], AC_GETSKINSTATE, 1);
        SkinData.BGChanged := True;
      end;
      WM_PARENTNOTIFY : if not ((csDesigning in ComponentState) or (csLoading in ComponentState)) and ((Message.WParam and $FFFF = WM_CREATE) or (Message.WParam and $FFFF = WM_DESTROY)) then begin
        i := PageCount;
        inherited;
        if (Message.WParamLo = WM_CREATE) and (srThirdParty in SkinData.SkinManager.SkinningRules) and (i <> PageCount) then AddToAdapter(Self);
        Exit;
      end;
      CM_CONTROLLISTCHANGE : begin
        i := PageCount;
        inherited;
        if i <> PageCount then begin
          CheckUpDown;
          ArrangeButtons;
          if (srThirdParty in SkinData.SkinManager.SkinningRules) then AddToAdapter(Self);
        end;
        Exit;
      end;
    end
  end;
  inherited;
  if Assigned(FCommonData) and FCommonData.Skinned then begin
    case Message.Msg of
      CM_DIALOGCHAR, TCM_SETCURSEL : begin
        FCommonData.BGChanged := True;
        RedrawWindow(Handle, nil, 0, RDW_ERASE or RDW_INVALIDATE or RDW_FRAME);
        SetParentUpdated(Self);
      end;
      WM_SIZE : if not (csLoading in ComponentState) then begin
        CheckUpDown;
        ArrangeButtons;
      end;
      TCM_DELETEITEM : if not SkinData.Updating then SkinData.BGChanged := True;
      WM_LBUTTONDOWN : if (Style <> tsTabs) and (CurItem <> -1) then RepaintTab(CurItem, 1);
    end;
  end
  else case Message.Msg of
    WM_WINDOWPOSCHANGING, CM_INVALIDATE : ArrangeButtons;
  end;
end;

procedure TsPageControl.ArrangeButtons;
var
  i : integer;
  Page : TsTabSheet;
  rTab : TRect;
  function TabHeight : integer; begin
    case TabPosition of
      tpTop, tpBottom : Result := HeightOf(rTab)
      else Result := WidthOf(rTab);
    end;
  end;
begin
  if (csLoading in ComponentState) or (csCreating in ControlState) then Exit;
  if FShowCloseBtns and not SkinData.Skinned then begin
    for i := 0 to PageCount - 1 do begin
      Page := TsTabSheet(Pages[i]);
      if Page.Btn <> nil then Page.Btn.Visible := Page.TabVisible;
      if not Page.TabVisible or not Page.UseCloseBtn then Continue;
      rTab := TabRect(Page.TabIndex);
      if Page.Btn = nil then begin
        Page.Btn := TsTabBtn.Create(Self);
        Page.Btn.OnClick := CloseClick;
        Page.Btn.Page := Page;
        Page.Btn.Visible := False;
        Page.Btn.Height := iBtnHeight;
        Page.Btn.Width := iBtnWidth;
        Page.Btn.Parent := Self;
      end;
      case TabPosition of
        tpTop, tpBottom : begin
          Page.Btn.Left := rTab.Right - Page.Btn.Width - BtnOffs;
          Page.Btn.Top := rTab.Top + BtnOffs;
        end;
        tpLeft : begin
          Page.Btn.Left := rTab.Left + BtnOffs;
          Page.Btn.Top := rTab.Top + BtnOffs;
        end
        else begin
          Page.Btn.Left := rTab.Right - Page.Btn.Width - BtnOffs;
          Page.Btn.Top := rTab.Top + BtnOffs;
        end
      end;
      Page.Btn.Visible := True;
    end;
  end
  else for i := 0 to PageCount - 1 do begin
    if (Pages[i] is TsTabSheet) and (TsTabSheet(Pages[i]).Btn <> nil) then FreeAndNil(TsTabSheet(Pages[i]).Btn);
  end;
end;

procedure TsPageControl.SetShowCloseBtns(const Value: boolean);
begin
  if FShowCloseBtns <> Value then begin
    FShowCloseBtns := Value;
    if SkinData.Skinned and Value then UpdateBtnData;
    ArrangeButtons;
    if SkinData.Skinned then RedrawWindow(Handle, nil, 0, RDW_ERASE or RDW_INVALIDATE or RDW_UPDATENOW);
  end;
end;

procedure TsPageControl.CloseClick(Sender: TObject);
var
  ToClose : boolean;
  Act : TacCloseAction;
  i : integer;
begin
  ToClose := True;
  Act := acaFree;
  if Assigned(OnCloseBtnClick) then OnCloseBtnClick(Self, TsTabBtn(Sender).Page.TabIndex, ToClose, Act);
  if ToClose then begin
    i := ActivePageIndex;
    if Act = acaFree then FreeAndNil(TsTabBtn(Sender).Page) else TsTabBtn(Sender).Page.TabVisible := False;
    if (i < PageCount) and (i <> 0) then begin
      ActivePageIndex := i;
    end;
    TsTabBtn(Sender).Visible := False;
    ArrangeButtons;
    RedrawWindow(Handle, nil, 0, RDW_ERASE or RDW_INVALIDATE or RDW_UPDATENOW);
  end;
end;

procedure TsPageControl.PaintButton(DC: hdc; TabRect: TRect; State: integer; BG : TCacheInfo);
const
  sx = 'X';
var
  BtnRect : TRect;
  TmpBmp : TBitmap;
  x, y : integer;
begin
  if BtnIndex < 0 then Exit;
  BG.Ready := True;
  BG.FillColor := clFuchsia;
  BtnRect.Left := TabRect.Right - BtnWidth - BtnOffs;
  BtnRect.Top := TabRect.Top + BtnOffs;
  BtnRect.Right := TabRect.Right - BtnOffs;
  BtnRect.Bottom := TabRect.Top + BtnHeight + BtnOffs;

  TmpBmp := CreateBmp32(BtnWidth, BtnHeight);
  BitBlt(TmpBmp.Canvas.Handle, 0, 0, BtnWidth, BtnHeight, BG.Bmp.Canvas.Handle, BG.X + WidthOf(TabRect) - BtnWidth - BtnOffs, BG.Y + BtnOffs, SRCCOPY);

  if CloseBtnSkin = '' then DrawSkinGlyph(TmpBmp, Point(0, 0), State, 1, FCommonData.SkinManager.ma[BtnIndex], MakeCacheInfo(BG.Bmp, BG.X + WidthOf(TabRect) - BtnWidth - BtnOffs, BG.Y + BtnOffs)) else begin

    PaintItem(BtnIndex, CloseBtnSkin, MakeCacheInfo(FCommonData.FCacheBmp, BtnRect.Left, BtnRect.Top), True, State, Rect(0, 0, TmpBmp.Width, TmpBmp.Height),
      Point(0, 0), TmpBmp, SkinData.SkinManager);

    TmpBmp.Canvas.Brush.Style := bsClear;
    TmpBmp.Canvas.Font.Style := [fsBold];
    TmpBmp.Canvas.Font.Color := clRed;
    x := (iBtnWidth - TmpBmp.Canvas.TextWidth(sx)) div 2;
    y := (iBtnHeight - TmpBmp.Canvas.TextHeight(sx)) div 2;
    TmpBmp.Canvas.TextOut(x + integer(State = 2), y + integer(State = 2), 'X');
  end;

  BitBlt(DC, BtnRect.Left, BtnRect.Top, BtnWidth, BtnHeight, TmpBmp.Canvas.Handle, 0, 0, SRCCOPY);
  FreeAndNil(TmpBmp);
end;

procedure TsPageControl.PaintButtons(DC: hdc);
var
  i, j : integer;
  R : TRect;
begin
  if not FShowCloseBtns then Exit;
  j := 0;
  for i := 0 to PageCount - 1 do if Pages[i].TabVisible then begin
    if TsTabSheet(Pages[i]).UseCloseBtn then begin
      R := SkinTabRect(j, Pages[i] = ActivePage);
      PaintButton(DC, R, 2 * integer(Pages[i] = ActivePage), MakeCacheInfo(SkinData.FCacheBmp, R.Left, R.Top));
    end;
    inc(j);
  end;
end;

procedure TsPageControl.UpdateBtnData;
begin
  if FCommonData.SkinManager = nil then Exit;
  if CloseBtnSkin <> '' then begin
    BtnIndex := FCommonData.SkinManager.GetSkinIndex(CloseBtnSkin);
    if BtnIndex > -1 then begin
      BtnWidth := iBtnWidth;
      BtnHeight := iBtnWidth;
    end;
  end
  else begin
    BtnIndex := FCommonData.SkinManager.GetMaskIndex(FCommonData.SkinManager.ConstData.IndexGlobalInfo, s_GlobalInfo, s_SmallIconClose);
    if BtnIndex < 0 then BtnIndex := FCommonData.SkinManager.GetMaskIndex(FCommonData.SkinManager.ConstData.IndexGlobalInfo, s_GlobalInfo, s_BorderIconClose);
    if BtnIndex > -1 then begin
      BtnWidth := WidthOf(FCommonData.SkinManager.ma[BtnIndex].R) div FCommonData.SkinManager.ma[BtnIndex].ImageCount;
      BtnHeight := HeightOf(FCommonData.SkinManager.ma[BtnIndex].R) div (1 + FCommonData.SkinManager.ma[BtnIndex].MaskType);
    end;
  end;
end;

function TsPageControl.BtnRect(TabIndex: integer): TRect;
var
  R : TRect;
begin
  if SkinData.Skinned or (TabIndex < 0) then begin
    R := SkinTabRect(TabIndex, Pages[TabIndex] = ActivePage);
    Result := Rect(R.Right - BtnWidth - BtnOffs, R.Top + BtnOffs, R.Right - BtnOffs, R.Top + BtnHeight + BtnOffs);
  end
  else Result := Rect(0, 0, 0, 0)
end;

procedure TsPageControl.PaintButtonEx(PageIndex : integer; BtnState: integer; TabState : integer);
var
  DC : hdc;
  R : TRect;
  TmpBmp : TBitmap;
begin
  if (PageIndex < 0) or not FShowCloseBtns or not TsTabSheet(Pages[PageIndex]).UseCloseBtn then Exit;
  R := SkinTabRect(Pages[PageIndex].TabIndex, Pages[PageIndex] = ActivePage);
  TmpBmp := CreateBmp32(WidthOf(R), HeightOf(R));

  DrawSkinTab(PageIndex, TabState, TmpBmp, Point(-R.Left, -R.Top));
  if TabState <> 2 then begin
    BitBlt(TmpBmp.Canvas.Handle, 0, TmpBmp.Height - 5, TmpBmp.Width, 5, FCommonData.FCacheBmp.Canvas.Handle, R.Left, R.Bottom - 5, SRCCOPY);
  end;

  DC := GetDC(Handle);
  PaintButton(DC, R, BtnState, MakeCacheInfo(TmpBmp));
  ReleaseDC(Handle, DC);

  FreeAndNil(TmpBmp);
end;

procedure TsPageControl.SetCloseBtnSkin(const Value: TsSkinSection);
begin
  if FCloseBtnSkin <> Value then begin
    FCloseBtnSkin := Value;
    FCommonData.Invalidate;
  end;
end;

procedure TsPageControl.SetShowUpDown(const Value: boolean);
var
  Wnd : THandle;
begin
  FShowUpDown := Value;
  if not FShowUpDown then begin
    if (SpinWnd <> nil) then begin
      Wnd := SpinWnd.CtrlHandle;
      FreeAndNil(SpinWnd);
    end
    else Wnd := FindWindowEx(Handle, 0, UPDOWN_CLASS, nil);
    if Wnd <> 0 then DestroyWindow(Wnd);
  end
  else if not (csLoading in ComponentState) then RecreateWnd;
end;

procedure TsPageControl.SetShowFocus(const Value: boolean);
begin
  if FShowFocus <> Value then begin
    FShowFocus := Value;
    SkinData.Invalidate;
  end; 
end;

{ TsTabSheet }

constructor TsTabSheet.Create(AOwner: TComponent);
begin
  inherited;
  FCommonData := TsTabSkinData.Create;
  Btn := nil;
  FUseCloseBtn := True;
end;

procedure TsTabSheet.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params.WindowClass do style := style and not (CS_HREDRAW or CS_VREDRAW);
end;

destructor TsTabSheet.Destroy;
begin
  FreeAndNil(FCommonData);
  inherited;
end;

procedure TsTabSheet.SetButtonSkin(const Value: TsSkinSection);
begin
  if FButtonSkin <> Value then begin
    FButtonSkin := Value;
    if PageControl <> nil then TsPageControl(PageControl).SkinData.Invalidate;
  end;
end;

procedure TsTabSheet.SetTabSkin(const Value: TsSkinSection);
begin
  if FTabSkin <> Value then begin
    FTabSkin := Value;
    if (PageControl <> nil) and not (csLoading in PageControl.ComponentState) and PageControl.Visible then begin
      TsPageControl(PageControl).SkinData.BGChanged := True;
      RedrawWindow(PageControl.Handle, nil, 0, RDW_ERASE or RDW_FRAME or RDW_INVALIDATE);
    end;
  end;
end;

procedure TsTabSheet.SetUseCloseBtn(const Value: boolean);
begin
  if FUseCloseBtn <> Value then begin
    FUseCloseBtn := Value;
    if PageControl <> nil then TsPageControl(PageControl).SkinData.Invalidate;
  end;
end;

procedure TsTabSheet.WMEraseBkGnd(var Message: TWMPaint);
begin
  if not (csDestroying in ComponentState) and (PageControl <> nil) and not (csDestroying in PageControl.ComponentState) and TsPageControl(PageControl).SkinData.Skinned and Showing then begin
    TsPageControl(PageControl).SkinData.FUpdating := TsPageControl(PageControl).SkinData.Updating;
    if (Message.DC = 0) or (TsPageControl(PageControl).SkinData.CtrlSkinState and ACS_PRINTING = ACS_PRINTING) and (Message.DC <> TsPageControl(PageControl).SkinData.PrintDC) then Exit;
    if not TsPageControl(PageControl).SkinData.FUpdating then begin
      CopyWinControlCache(Self, TsPageControl(PageControl).SkinData, Rect(Left + BorderWidth, Top + BorderWidth, 0, 0), Rect(0, 0, Width, Height), Message.DC, False);
      sVCLUtils.PaintControls(Message.DC, Self, True, Point(0, 0));
    end;
    Message.Result := 1;
  end
  else inherited;
end;

procedure TsTabSheet.WMNCPaint(var Message: TWMPaint);
var
  DC : hdc;
begin
  if not (csDestroying in ComponentState) and (BorderWidth > 0) and Showing then begin
    if TsPageControl(PageControl).SkinData.Skinned then begin
      TsPageControl(PageControl).SkinData.FUpdating := TsPageControl(PageControl).SkinData.Updating;
      if not TsPageControl(PageControl).SkinData.FUpdating then begin
        if (TsPageControl(PageControl).SkinData.CtrlSkinState and ACS_PRINTING = ACS_PRINTING) and (Message.DC = TsPageControl(PageControl).SkinData.PrintDC) then DC := Message.DC else DC := GetWindowDC(Handle);
        BitBltBorder(DC, 0, 0, Width, Height, TsPageControl(PageControl).SkinData.FCacheBmp.Canvas.Handle, Left, Top, BorderWidth);
        if DC <> Message.DC then ReleaseDC(Handle, DC);
      end;
    end
    else begin
{$IFDEF DELPHI7UP}
      if ThemeServices.ThemesEnabled then inherited else
{$ENDIF}
      begin
        DC := GetWindowDC(Handle);
        FillDCBorder(DC, Rect(0, 0, Width, Height), BorderWidth, BorderWidth, BorderWidth, BorderWidth, Color);
        if DC <> Message.DC then ReleaseDC(Handle, DC);
      end;
    end;
    Message.Result := 1;
  end;
end;

procedure TsTabSheet.WndProc(var Message: TMessage);
var
  i : integer;
  PS : TPaintStruct;
begin
{$IFDEF LOGGED}
  AddToLog(Message);
{$ENDIF}
  if PageControl <> nil then begin
    if (Message.Msg = SM_ALPHACMD) then case Message.WParamHi of
      AC_CTRLHANDLED : begin Message.Result := 1; Exit end;
      AC_GETAPPLICATION : begin Message.Result := longint(Application); Exit end;
      AC_REMOVESKIN : begin
        if Message.LParam = LongInt(TsPageControl(PageControl).SkinData.SkinManager) then Repaint;
        AlphaBroadCast(Self, Message);
      end;
      AC_SETNEWSKIN : begin
        AlphaBroadCast(Self, Message);
      end;
      AC_REFRESH : begin
        if (Message.LParam = LongInt(TsPageControl(PageControl).SkinData.SkinManager)) and Visible then Repaint;
        AlphaBroadCast(Self, Message);
      end;
      AC_GETBG : if TsPageControl(PageControl).SkinData.Skinned then begin
        InitBGInfo(TsPageControl(PageControl).SkinData, PacBGInfo(Message.LParam), 0);
        if (PacBGInfo(Message.LParam)^.BgType = btCache) and not PacBGInfo(Message.LParam)^.PleaseDraw then begin
          PacBGInfo(Message.LParam)^.Offset.X := PacBGInfo(Message.LParam)^.Offset.X + Left + BorderWidth;
          PacBGInfo(Message.LParam)^.Offset.Y := PacBGInfo(Message.LParam)^.Offset.Y + Top + BorderWidth;
        end;
        Exit;
      end;
      AC_GETCONTROLCOLOR : if TsPageControl(PageControl).SkinData.Skinned then begin
        Message.Result := SendMessage(PageControl.Handle, SM_ALPHACMD, MakeWParam(0, AC_GETCONTROLCOLOR), 0);
        Exit;
      end;
      AC_PREPARING : if TsPageControl(PageControl).SkinData.Skinned then begin
        Message.Result := integer(TsPageControl(PageControl).SkinData.FUpdating);// SendAMessage(PageControl, AC_PREPARING);
        Exit;
      end;
      AC_CHILDCHANGED : if TsPageControl(PageControl).SkinData.Skinned then begin
        Message.LParam := integer((TsPageControl(PageControl).SkinData.SkinManager.gd[TsPageControl(PageControl).SkinData.SkinIndex].GradientPercent + TsPageControl(PageControl).SkinData.SkinManager.gd[TsPageControl(PageControl).SkinData.SkinIndex].ImagePercent > 0) or TsPageControl(PageControl).SkinData.RepaintIfMoved);
        Message.Result := Message.LParam;
        Exit;
      end;
      AC_GETSKININDEX : begin
        PacSectionInfo(Message.LParam)^.SkinIndex := TsPageControl(PageControl).SkinData.SkinIndex;
        Exit
      end;
      AC_ENDPARENTUPDATE : begin
        RedrawWindow(Handle, nil, 0, RDW_ERASE or RDW_INVALIDATE);
        SetParentUpdated(Self);
        Exit;
      end;
      AC_GETSKINSTATE : begin
        if Message.LParam = 1 then begin
          for i := 0 to ControlCount - 1 do SendAMessage(Controls[i], AC_GETSKINSTATE, 1);
        end
        else begin
          Message.Result := TsPageControl(PageControl).SkinData.CtrlSkinState;
        end;
        Exit;
      end;
    end
    else if TsPageControl(PageControl).SkinData.Skinned then case Message.Msg of
      WM_MOUSEMOVE : if not (csDesigning in ComponentState) then begin
        if (DefaultManager <> nil) and not (csDesigning in DefaultManager.ComponentState) then DefaultManager.ActiveControl := 0;
      end;
      WM_PARENTNOTIFY : if not ((csDesigning in ComponentState) or (csLoading in ComponentState)) and ((Message.WParam and $FFFF = WM_CREATE) or (Message.WParam and $FFFF = WM_DESTROY)) then begin
        inherited;
        if Message.WParamLo = WM_CREATE then begin
          AddToAdapter(Self);
          if Message.LParam <> 0 then SendAMessage(THandle(Message.LParam), AC_GETSKINSTATE, 1);
        end;
        Exit;
      end;
      WM_PAINT : if Visible then begin
        if not (csDestroying in ComponentState) and (Parent <> nil) then begin // Background update
          InvalidateRect(Handle, nil, True); // Background update (for repaint of graphic controls and for tansheets refreshing)
        end;
        BeginPaint(Handle, PS);
        EndPaint(Handle, PS);
        Message.Result := 0;
        Exit
      end;
      WM_PRINT : begin
        WMEraseBkGnd(TWMPaint(Message));
        Message.Result := 0;
        Exit
      end;
      CM_TEXTCHANGED : begin
        TsPageControl(PageControl).SkinData.BGChanged := True;
{
        inherited;
        RedrawWindow(PageControl.Handle, nil, 0, RDW_ERASE or RDW_INVALIDATE or RDW_FRAME or RDW_UPDATENOW);
        Exit;
}
      end;
    end;
  end;
  inherited;
end;

{ TsTabSkinData }

procedure TsTabSkinData.SetCustomColor(const Value: boolean);
begin
  FCustomColor := Value;
end;

procedure TsTabSkinData.SetCustomFont(const Value: boolean);
begin
  FCustomFont := Value;
end;

procedure TsTabSkinData.SetSkinSection(const Value: string);
begin
  FSkinSection := Value;
end;

{ TsTabBtn }

constructor TsTabBtn.Create(AOwner: TComponent);
begin
  inherited;
  Flat := True;
  UpdateGlyph;
end;

procedure TsTabBtn.Paint;
{$IFDEF DELPHI7UP}
var
  PaintRect: TRect;
  Button: TThemedWindow;
  Details: TThemedElementDetails;
{$ENDIF}
begin
{$IFDEF DELPHI7UP}
  if ThemeServices.ThemesEnabled then begin
    if FState in [bsDown, bsExclusive]
      then Button := twSmallCloseButtonPushed
      else if MouseInControl then Button := twSmallCloseButtonHot else Button := twSmallCloseButtonNormal;
    Details := ThemeServices.GetElementDetails(Button);
    PerformEraseBackground(Self, Canvas.Handle);
    PaintRect := Rect(0, 0, Width, Height);
    ThemeServices.DrawElement(Canvas.Handle, Details, PaintRect);
  end
  else
{$ENDIF}
  inherited
end;

procedure TsTabBtn.UpdateGlyph;
begin
  Caption := 'X';
  Font.Style := [fsBold];
  Font.Color := clRed;
end;

end.
