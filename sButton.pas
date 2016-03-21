unit sButton;
{$I sDefs.inc}
{.$DEFINE LOGGED}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ImgList,
  StdCtrls, sCommonData, Buttons, sConst, sDefaults, sFade{$IFDEF LOGGED}, sDebugMsgs{$ENDIF}
  {$IFDEF TNTUNICODE}, TntStdCtrls {$ENDIF};

type
{$IFNDEF NOTFORHELP}
  TButtonStyle = (bsPushButton, bsCommandLink, bsSplitButton);
{$ENDIF}

{$IFNDEF D2009}
{$IFNDEF NOTFORHELP}
  TImageAlignment = (iaLeft, iaRight, iaTop, iaBottom, iaCenter);
{$ENDIF}

  TImageMargins = class(TPersistent)
  private
    FRight: Integer;
    FBottom: Integer;
    FTop: Integer;
    FLeft: Integer;
    FOnChange: TNotifyEvent;
    procedure SetMargin(Index, Value: Integer);
  protected
    procedure Change; virtual;
  public
    procedure Assign(Source: TPersistent); override;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property Left: Integer index 0 read FLeft write SetMargin default 0;
    property Top: Integer index 1 read FTop write SetMargin default 0;
    property Right: Integer index 2 read FRight write SetMargin default 0;
    property Bottom: Integer index 3 read FBottom write SetMargin default 0;
  end;

  TPushButtonActionLink = class(TButtonActionLink)
  protected
    function IsImageIndexLinked: Boolean; override;
    procedure SetImageIndex(Value: Integer); override;
  end;

{$ENDIF}

{$IFDEF TNTUNICODE}
  TsButton = class(TTntButton)
{$ELSE}
  TsButton = class(TButton)
{$ENDIF}
{$IFNDEF NOTFORHELP}
  private
    FCommonData: sCommonData.TsCtrlSkinData;
    FMouseClicked : boolean;
    FDown: boolean;
    RegionChanged : boolean;
    FFocusMargin: integer;
    FDisabledKind: TsDisabledKind;
    FOnMouseEnter: TNotifyEvent;
    FOnMouseLeave: TNotifyEvent;
    FadeTimer : TsFadeTimer;
    FAnimatEvents: TacAnimatEvents;
    LastRect : TRect;
    FShowFocus: boolean;
    FReflected : boolean;
    FStyle: TButtonStyle;
    FContentMargin: integer;
{$IFNDEF D2009}
    FCommandLinkHint: acString;
    FImageChangeLink: TChangeLink;
    FImages: TCustomImageList;
    FImageAlignment: TImageAlignment;
    FSelectedImageIndex: TImageIndex;
    FDisabledImageIndex: TImageIndex;
    FHotImageIndex: TImageIndex;
    FImageIndex: TImageIndex;
    FPressedImageIndex: TImageIndex;
    FImageMargins: TImageMargins;
{$ENDIF}
{$IFNDEF DELPHI7UP}
    FWordWrap : boolean;
    procedure SetWordWrap(const Value: boolean);
{$ENDIF}
    procedure SetDown(const Value: boolean);
    procedure SetFocusMargin(const Value: integer);
    procedure SetDisabledKind(const Value: TsDisabledKind);
    procedure WMKeyUp (var Message: TWMKey); message WM_KEYUP;
    procedure CNMeasureItem(var Message: TWMMeasureItem); message CN_MEASUREITEM;
    function GetDown: boolean;
    procedure SetShowFocus(const Value: boolean);
    procedure SetReflected(const Value: boolean);
    procedure CNDrawItem(var Message: TWMDrawItem); message CN_DRAWITEM;
    procedure SetStyle(const Value: TButtonStyle);
    procedure SetContentMargin(const Value: integer);

{$IFNDEF D2009}
    procedure ImageListChange(Sender: TObject);
    function IsImageIndexStored: Boolean;
    procedure SetCommandLinkHint(const Value: acString);
    procedure SetDisabledImageIndex(const Value: TImageIndex);
    procedure SetHotImageIndex(const Value: TImageIndex);
    procedure SetImageAlignment(const Value: TImageAlignment);
    procedure SetImageIndex(const Value: TImageIndex);
    procedure SetImageMargins(const Value: TImageMargins);
    procedure SetImages(const Value: TCustomImageList);
    procedure SetPressedImageIndex(const Value: TImageIndex);
    procedure SetSelectedImageIndex(const Value: TImageIndex);
    procedure ImageMarginsChange(Sender: TObject);
{$ENDIF}
  protected
    IsFocused : boolean;
    FRegion : hrgn;
{$IFDEF D2009}
    procedure UpdateImageList; override;
    procedure UpdateImages; override;
{$ENDIF}
    procedure StdDrawItem(const DrawItemStruct: TDrawItemStruct);
    procedure SetButtonStyle(ADefault: Boolean); override;
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); override;
    procedure MouseDown (Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp (Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

    procedure OurPaintHandler(aDC : hdc);
    procedure DrawCaption(Canvas : TCanvas = nil); dynamic;
    function CaptionRect : TRect; dynamic;

    procedure DrawGlyph(Canvas : TCanvas = nil); dynamic;
    function GlyphExist : boolean;

    procedure PrepareCache;
  public
    Active: Boolean;
    constructor Create(AOwner:TComponent); override;
    procedure CreateParams(var Params: TCreateParams); override;
    function CurrentState : integer;
    function GlyphIndex : integer;
    function GlyphRect : TRect;
    destructor Destroy; override;
    procedure AfterConstruction; override;
    procedure Loaded; override;
    procedure WndProc (var Message: TMessage); override;
  published
{$ENDIF} // NOTFORHELP
    property OnMouseEnter : TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave : TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property AnimatEvents : TacAnimatEvents read FAnimatEvents write FAnimatEvents default [aeGlobalDef];
    property SkinData : sCommonData.TsCtrlSkinData read FCommonData write FCommonData;
    property ShowFocus : boolean read FShowFocus write SetShowFocus default True;
    property DisabledKind : TsDisabledKind read FDisabledKind write SetDisabledKind default DefDisabledKind;
    property Down : boolean read GetDown write SetDown default False;
    property FocusMargin : integer read FFocusMargin write SetFocusMargin default 1;

{$IFNDEF D2009}
    property CommandLinkHint: acString read FCommandLinkHint write SetCommandLinkHint;
    property DisabledImageIndex: TImageIndex read FDisabledImageIndex write SetDisabledImageIndex default -1;
    property HotImageIndex: TImageIndex read FHotImageIndex write SetHotImageIndex default -1;
    property Images: TCustomImageList read FImages write SetImages;
    property ImageAlignment: TImageAlignment read FImageAlignment write SetImageAlignment default iaLeft;
    property ImageIndex: TImageIndex read FImageIndex write SetImageIndex stored IsImageIndexStored default -1;
    property ImageMargins: TImageMargins read FImageMargins write SetImageMargins;
    property PressedImageIndex: TImageIndex read FPressedImageIndex write SetPressedImageIndex default -1;
    property SelectedImageIndex: TImageIndex read FSelectedImageIndex write SetSelectedImageIndex default -1;
{$ENDIF}

    property ContentMargin : integer read FContentMargin write SetContentMargin default 6;
    property Style: TButtonStyle read FStyle write SetStyle default bsPushButton;
    property Reflected : boolean read FReflected write SetReflected default False;
    property WordWrap {$IFNDEF DELPHI7UP}: boolean read FWordWrap write SetWordWrap{$ENDIF} default True;
  end;

implementation

uses sVCLUtils, sMessages, acntUtils, sGraphUtils, sAlphaGraph, sBitBtn, sBorders, ActnList, sSkinManager, sThirdParty,
  sStyleSimply, acGlow, acAlphaImageList, math {$IFDEF DELPHI7UP}, Themes{$ENDIF};

{ TsButton }

const
  ContentSpacing = 6;

var
  bFocusChanging : boolean = False;

function MaxContentWidth(Button : TsButton) : integer;
begin
  with Button do {if (Caption <> '') then }Result := Width - 2 * FContentMargin;// else Result := 0
end;

function GetImageSize(Button : TsButton; AddMargins : boolean = True) : TSize;
begin
  with Button do begin
    if (Images <> nil) and (ImageIndex > -1) and (ImageIndex < Images.Count) then begin
      Result.cx := Images.Width;
      Result.cy := Images.Height;
    end
    else begin
      Result.cx := 32;
      Result.cy := 32;
    end;
    if AddMargins then begin
      Result.cx := Result.cx + ImageMargins.Left + ImageMargins.Right;
      Result.cy := Result.cy + ImageMargins.Top + ImageMargins.Bottom;
    end;
  end;
end;

function GetCaptionSize(Button : TsButton) : TSize;
var
  R : TRect;
  Flags : Cardinal;
begin
  with Button do begin
    if (Caption <> '') then begin
      if Style = bsCommandLink then begin
        SkinData.FCacheBmp.Canvas.Font.Style := SkinData.FCacheBmp.Canvas.Font.Style + [fsBold];
        SkinData.FCacheBmp.Canvas.Font.Size := SkinData.FCacheBmp.Canvas.Font.Size + 2;
      end;
      Flags := DT_EXPANDTABS or DT_CENTER or DT_CALCRECT;
      if WordWrap then Flags := Flags or DT_WORDBREAK else Flags := Flags or DT_SINGLELINE;

      if Style = bsPushButton
        then R := Rect(0, 0, Width, 0)
        else R := Rect(0, 0, Width - 2 * FContentMargin - GetImageSize(Button).cx - ContentSpacing, 0);
      acDrawText(SkinData.FCacheBmp.Canvas.Handle, Caption, R, Flags);
      if Style = bsCommandLink then begin
        SkinData.FCacheBmp.Canvas.Font.Style := SkinData.FCacheBmp.Canvas.Font.Style - [fsBold];
        SkinData.FCacheBmp.Canvas.Font.Size := SkinData.FCacheBmp.Canvas.Font.Size - 2;
      end;
      Result.cx := WidthOf(R);
      Result.cy := HeightOf(R);
    end
    else begin
      Result.cx := 0;
      Result.cy := 0;
    end
  end;
end;

function GetHintSize(Button : TsButton) : TSize;
var
  R : TRect;
  Flags : Cardinal;
begin
  with Button do begin
    if (CommandLinkHint <> '') then begin
      Flags := DT_EXPANDTABS or DT_CENTER or DT_CALCRECT or DT_WORDBREAK;
      R := Rect(0, 0, MaxContentWidth(Button) - GetImageSize(Button).cx, 0);
      acDrawText(SkinData.FCacheBmp.Canvas.Handle, CommandLinkHint, R, Flags);
      Result.cx := WidthOf(R);
      Result.cy := HeightOf(R);
    end
    else begin
      Result.cx := 0;
      Result.cy := 0;
    end
  end;
end;

function MaxContentHeight(Button : TsButton) : integer;
begin
  Result := Max(GetHintSize(Button).cy + ContentSpacing + GetCaptionSize(Button).cy, GetImageSize(Button).cy);
end;

procedure TsButton.ActionChange(Sender: TObject; CheckDefaults: Boolean);
begin
  inherited ActionChange(Sender, CheckDefaults);
  if Sender is TCustomAction then Self.Enabled := TCustomAction(Sender).Enabled;
end;

procedure TsButton.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
//  if SkinData.Skinned {$IFNDEF SKININDESIGN}and not ((csDesigning in ComponentState) and (GetOwnerFrame(Self) <> nil)){$ENDIF}
//    then
  Params.Style := Params.Style or BS_OWNERDRAW;
end;
{
procedure TsButton.CreateWnd;
begin
  inherited;
  SetWindowLong(Handle, GCL_STYLE, GetWindowLong(Handle, GCL_STYLE) or BS_OWNERDRAW);
end;
}
procedure TsButton.CNMeasureItem(var Message: TWMMeasureItem);
begin
  with Message.MeasureItemStruct^ do begin
    itemWidth := Width;
    itemHeight := Height;
  end;
end;

procedure TsButton.AfterConstruction;
begin
  inherited;
  FCommonData.Loaded;
end;

procedure TsButton.SetButtonStyle(ADefault: Boolean);
begin
  if ADefault <> IsFocused then IsFocused := ADefault;
  if SkinData <> nil then SkinData.Invalidate
end;

function TsButton.CaptionRect: TRect;
var
  Size, hSize: TSize;
begin
  Size := GetCaptionSize(Self);
  if Style = bsCommandLink then begin
    hSize := GetHintSize(Self);
    Result.Left := FContentMargin + GetImageSize(Self).cx + ContentSpacing;
    Result.Right := Width - FContentMargin;
    Result.Top := FContentMargin;
    Result.Bottom := Result.Top + Size.cy;
  end
  else
  if GlyphExist and (ImageAlignment <> iaCenter) then begin
    case ImageAlignment of
      iaLeft: begin
        Result.Left := ImageMargins.Left + FContentMargin + Images.Width + ImageMargins.Right;
        Result.Right := Width - FContentMargin;
        Result.Top := (Height - Size.cy) div 2;
        Result.Bottom := Height - Result.Top;
      end;
      iaRight: begin
        Result.Right := Width - (ImageMargins.Right + FContentMargin + Images.Width + ImageMargins.Left);
        Result.Left := FContentMargin;
        Result.Top := (Height - Size.cy) div 2;
        Result.Bottom := Height - Result.Top;
      end;
      iaTop: begin
        Result.Top := ImageMargins.Top + 2 * FContentMargin + Images.Height;
        Result.Bottom := Height - FContentMargin;

        Result.Top := Result.Top + ((Result.Bottom - Result.Top) - Size.cy) div 2;
        Result.Bottom := Result.Top + Size.cy;

        Result.Left := FContentMargin;
        Result.Right := Width - FContentMargin;
      end
      else {iaBottom} begin
        Result.Bottom := Height - (ImageMargins.Bottom + FContentMargin + Images.Height + ImageMargins.Top);
        Result.Top := ImageMargins.Top + ((Result.Bottom - ImageMargins.Top) - Size.cy) div 2;
        Result.Bottom := Result.Top + Size.cy;

        Result.Left := FContentMargin;
        Result.Right := Width - FContentMargin;
      end;
    end;
  end
  else begin
    Result.Left := (Width - Size.cx) div 2 - 1;
    Result.Right := Result.Left + Size.cx + 2;
    Result.Top := (Height - Size.cy) div 2;
    Result.Bottom := Height - Result.Top;
  end;
  if CurrentState = 2 then OffsetRect(Result, 1, 1);
end;

constructor TsButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csOpaque, csDoubleClicks];
  FCommonData := sCommonData.TsCtrlSkinData.Create(Self, True);
  FCommonData.COC := COC_TsBUTTON;
  FDisabledKind := DefDisabledKind;
  FFocusMargin := 1;
  FadeTimer := nil;
  FDown := False;
  FRegion := 1;
  FAnimatEvents := [aeGlobalDef];
  FShowFocus := True;
  FReflected := False;
  FContentMargin := 6;
{$IFNDEF DELPHI7UP}
  FWordWrap := True;
{$ELSE}
  WordWrap := True;
{$ENDIF}
  RegionChanged := True;

{$IFNDEF D2009}
  FStyle := bsPushButton;
  FImageChangeLink := TChangeLink.Create;
  FImageChangeLink.OnChange := ImageListChange;
  FImageMargins := TImageMargins.Create;
  FImageMargins.OnChange := ImageMarginsChange;
  FCommandLinkHint := '';
  FDisabledImageIndex := -1;
  FHotImageIndex := -1;
  FImageAlignment := iaLeft;
  FImageIndex := -1;
  FPressedImageIndex := -1;
  FSelectedImageIndex := -1;
{$ENDIF}
end;

function TsButton.CurrentState: integer;
begin
  if ((SendMessage(Handle, BM_GETSTATE, 0, 0) and BST_PUSHED = BST_PUSHED) or fGlobalFlag) and (SkinData.FMouseAbove or not (csLButtonDown in ControlState){ or not SkinData.Skinned}) or FDown
    then Result := 2
    else if IsFocused or ((GetWindowLong(Handle, GWL_STYLE) and $000F) = BS_DEFPUSHBUTTON) or ControlIsActive(FCommonData) or ((csDesigning in ComponentState) and Default)
      then Result := 1
      else Result := 0
end;

destructor TsButton.Destroy;
begin
{$IFNDEF D2009}
  FreeAndNil(FImageChangeLink);
  FreeAndNil(FImageMargins);
{$ENDIF}
  StopFading(FadeTimer, FCommonData);
  if Assigned(FCommonData) then FreeAndNil(FCommonData);
  inherited Destroy;
end;

procedure TsButton.DrawCaption;
var
  R, hR : TRect;
  DrawStyle: Longint;
begin
  if Canvas = nil then Canvas := FCommonData.FCacheBmp.Canvas;
  Canvas.Font.Assign(Font);
  Canvas.Brush.Style := bsClear;
  R := CaptionRect;
  { Calculate vertical layout }

  if Style = bsCommandLink then begin
    Canvas.Font.Style := Canvas.Font.Style + [fsBold];
    Canvas.Font.Size := Canvas.Font.Size + 2;
    DrawStyle := DT_EXPANDTABS or DT_WORDBREAK;
  end
  else begin
    DrawStyle := DT_EXPANDTABS or DT_CENTER or DT_VCENTER;
    if WordWrap then DrawStyle := DrawStyle or DT_WORDBREAK;
  end;
  if UseRightToLeftReading then DrawStyle := DrawStyle or DT_RTLREADING;
  acWriteTextEx(Canvas, PacChar(Caption), Enabled or SkinData.Skinned, R, Cardinal(DrawStyle), FCommonData, CurrentState <> 0);
  if Style = bsCommandLink then begin
    Canvas.Font.Style := Canvas.Font.Style - [fsBold];
    Canvas.Font.Size := Canvas.Font.Size - 2;
    if CommandLinkHint <> '' then begin
      hR := R;
      hR.Top := R.Bottom + ContentSpacing;
      hR.Bottom := Height - FContentMargin;
      acWriteTextEx(Canvas, PacChar(CommandLinkHint), Enabled or SkinData.Skinned, hR, Cardinal(DrawStyle), FCommonData, CurrentState <> 0);
    end;
  end;

  if Focused and Enabled and (Caption <> '') and ShowFocus and FCommonData.Skinned and FCommonData.SkinManager.gd[FCommonData.SkinIndex].ShowFocus then begin
    InflateRect(R, FocusMargin, FocusMargin);
    FocusRect(Canvas, R);
  end;
end;

procedure TsButton.DrawGlyph;
var
  R : TRect;
begin
  if Assigned(Images) and (ImageIndex >= 0) and (ImageIndex < Images.Count) then begin
    R := GlyphRect;
    if Images is TsAlphaImageList then begin
      DrawAlphaImgList(Images, FCommonData.FCacheBmp, R.Left, R.Top, GlyphIndex, 0, clNone, 0, 1, Reflected)
    end
    else Images.Draw(FCommonData.FCacheBmp.Canvas, R.Left, R.Top, GlyphIndex);
  end;
end;

function TsButton.GetDown: boolean;
begin
  Result := FDown;
end;
 
function TsButton.GlyphExist: boolean;
begin
  Result := Assigned(Images) and (ImageIndex >= 0) and (ImageIndex < Images.Count);
end;

function TsButton.GlyphIndex: integer;
var
  State : integer;
begin
  if not Enabled
    then State := 4
    else if CurrentState = 2
      then State := 2
      else if Focused
        then State := 3
        else State := CurrentState;

  case State of
    0 : Result := ImageIndex;
    1 : if (HotImageIndex > -1) and (HotImageIndex < Images.Count) then Result := HotImageIndex else Result := ImageIndex;
    2 : if (PressedImageIndex > -1) and (PressedImageIndex < Images.Count) then Result := PressedImageIndex else Result := ImageIndex;
    3 : if (SelectedImageIndex > -1) and (SelectedImageIndex < Images.Count) then Result := SelectedImageIndex else Result := ImageIndex;
    4 : if (DisabledImageIndex > -1) and (DisabledImageIndex < Images.Count) then Result := DisabledImageIndex else Result := ImageIndex
    else Result := -1;
  end;
end;

function TsButton.GlyphRect: TRect;
begin
  if GlyphExist then begin
    if Style = bsCommandLink then begin
      Result.Left := ImageMargins.Left + FContentMargin;
      Result.Right := Result.Left + Images.Width;

      Result.Top := FContentMargin;
      Result.Bottom := Result.Top + Images.Height;
    end
    else case ImageAlignment of
      iaLeft: begin
        Result.Left := ImageMargins.Left + FContentMargin;
        Result.Right := Result.Left + Images.Width;
        Result.Top := (Height - Images.Height) div 2;
        Result.Bottom := Result.Top + Images.Height;
      end;
      iaRight: begin
        Result.Right := Width - ImageMargins.Right - FContentMargin;
        Result.Left := Result.Right - Images.Width;
        Result.Top := (Height - Images.Height) div 2;
        Result.Bottom := Result.Top + Images.Height;
      end;
      iaTop: begin
        Result.Top := ImageMargins.Bottom + FContentMargin;
        Result.Bottom := Result.Top + Images.Height;
        Result.Left := (Width - Images.Width) div 2;
        Result.Right := Result.Left + Images.Width;
      end;
      iaBottom: begin
        Result.Bottom := Height - ImageMargins.Bottom - FContentMargin;
        Result.Top := Result.Bottom - Images.Height;
        Result.Left := (Width - Images.Width) div 2;
        Result.Right := Result.Left + Images.Width;
      end
      else {iaCenter} begin
        Result.Top := (Height - Images.Height) div 2;
        Result.Bottom := Result.Top + Images.Height;
        Result.Left := (Width - Images.Width) div 2;
        Result.Right := Result.Left + Images.Width;
      end;
    end;
  end
  else Result := Rect(0, 0, 0, 0);
  if CurrentState = 2 then OffsetRect(Result, 1, 1);
end;

procedure TsButton.Loaded;
begin
  inherited;
  FCommonData.FCacheBmp.Canvas.Font.Assign(Font);
  FCommonData.Loaded;
end;

procedure TsButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FCommonData.Skinned and Enabled and not (csDesigning in ComponentState) then begin
    FCommonData.Updating := False;
    if (Button = mbLeft) and not ShowHintStored then begin
      AppShowHint := Application.ShowHint;
      Application.ShowHint := False;
      ShowHintStored := True;
    end;
    FMouseClicked := True;
    if (Button = mbLeft) then begin
      if not Down then begin
        RegionChanged := True;
        FCommonData.Updating := FCommonData.Updating;
        FCommonData.BGChanged := False;
        DoChangePaint(FadeTimer, FCommonData, True, EventEnabled(aeMouseDown, FAnimatEvents));
      end;
    end;
    if ShowHintStored then begin;
      Application.ShowHint := AppShowHint;
      ShowHintStored := False
    end;
  end;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TsButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not (csDestroying in ComponentState) then begin
    if FCommonData.Skinned and Enabled and not (csDesigning in ComponentState) {and FDown} then begin
      if (Button = mbLeft) and ShowHintStored then begin
        Application.ShowHint := AppShowHint;
        ShowHintStored := False;
      end;

      if not FMouseClicked or (csDestroying in ComponentState) then Exit;
      FMouseClicked := False;
      if (Button = mbLeft) and Enabled then begin
        if (FadeTimer <> nil) and (FadeTimer.FadeLevel < FadeTimer.Iterations) then begin
          FadeTimer.Enabled := False;
          FCommonData.BGChanged := True;
          fGlobalFlag := True;
          RedrawWindow(Handle, nil, 0, RDW_UPDATENOW or RDW_INVALIDATE);
          fGlobalFlag := False;
          Sleep(30);
        end;
        FCommonData.Updating := False;

        if (Self <> nil) and not (csDestroying in ComponentState) then begin
          RegionChanged := True;
          FCommonData.BGChanged := False;
          if Assigned(FCommonData) then DoChangePaint(FadeTimer, FCommonData, True, EventEnabled(aeMouseUp, FAnimatEvents), fdUp);
        end;
      end;
    end;
    inherited MouseUp(Button, Shift, X, Y);
  end;
end;

procedure TsButton.OurPaintHandler;
var
  DC, SavedDC : hdc;
  PS : TPaintStruct;
  b : boolean;
  R : TRect;
  l, t, right, bottom : integer;
begin
  if InAnimationProcess and ((aDC <> SkinData.PrintDC) or (aDC = 0)) then Exit;
  if aDC = 0 then DC := GetDC(Handle) else DC := aDC;
  if not InanimationProcess then BeginPaint(Handle, PS);
  try
    FCommonData.FUpdating := FCommonData.Updating;
    if not FCommonData.FUpdating and not (Assigned(FadeTimer) and FadeTimer.Enabled) then begin
      FCommonData.BGChanged := FCommonData.BGChanged or FCommonData.HalfVisible or GetBoolMsg(Parent, AC_GETHALFVISIBLE);
      FCommonData.HalfVisible := not RectInRect(Parent.ClientRect, BoundsRect);
      b := (FRegion = 1) or aSkinChanging;
      FRegion := 0;
      if RegionChanged then FCommonData.BGChanged := True;
      if (FCommonData.BGChanged) then PrepareCache;
      if RegionChanged then begin
        UpdateCorners(FCommonData, CurrentState);
        if FCommonData.SkinManager.IsValidImgIndex(FCommonData.BorderIndex) then begin
          l := FCommonData.SkinManager.MaskWidthLeft(FCommonData.BorderIndex);
          t := FCommonData.SkinManager.MaskWidthTop(FCommonData.BorderIndex);
          right := FCommonData.SkinManager.MaskWidthRight(FCommonData.BorderIndex);
          bottom := FCommonData.SkinManager.MaskWidthBottom(FCommonData.BorderIndex);
          BitBlt(DC, 0, 0, l, t, FCommonData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
          BitBlt(DC, 0, Height - bottom, Width, bottom, FCommonData.FCacheBmp.Canvas.Handle, 0, Height - bottom, SRCCOPY);
          BitBlt(DC, Width - right, Height - bottom, right, bottom, FCommonData.FCacheBmp.Canvas.Handle, Width - right, Height - bottom, SRCCOPY);
          BitBlt(DC, Width - right, 0, right, t, FCommonData.FCacheBmp.Canvas.Handle, Width - right, 0, SRCCOPY);
        end;
        if (DC <> SkinData.PrintDC) and not (csDesigning in ComponentState) and not (csAlignmentNeeded in ControlState) then begin // Set region
          if FRegion <> 0 then begin
            SetWindowRgn(Handle, FRegion, b); // Speed increased if repainting is disabled
            if (Width < WidthOf(LastRect)) or (Height < HeightOf(LastRect)) then begin
              if not GetParentCache(SkinData).Ready then begin
                R := Rect(LastRect.Right - SkinData.SkinManager.ma[SkinData.BorderIndex].WR, LastRect.Top, LastRect.Right, LastRect.Top + SkinData.SkinManager.ma[SkinData.BorderIndex].WT);
                InvalidateRect(Parent.Handle, @R, True); // Top-right
                R := Rect(LastRect.Right - SkinData.SkinManager.ma[SkinData.BorderIndex].WR, LastRect.Bottom - SkinData.SkinManager.ma[SkinData.BorderIndex].WB, LastRect.Right, LastRect.Bottom);
                InvalidateRect(Parent.Handle, @R, True); // Bottom-right
                R := Rect(LastRect.Left, LastRect.Bottom - SkinData.SkinManager.ma[SkinData.BorderIndex].WB, LastRect.Left + SkinData.SkinManager.ma[SkinData.BorderIndex].WL, LastRect.Bottom);
                InvalidateRect(Parent.Handle, @R, True); // Left-bottom
              end;
            end;
            LastRect := BoundsRect;
            FRegion := 0;
          end;
        end;
      end;
      SavedDC := SaveDC(DC);
      try
        BitBlt(DC, 0, 0, Width, Height, FCommonData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
      finally
        RestoreDC(DC, SavedDC);
      end;
    end;
  finally
    if aDC <> DC then ReleaseDC(Handle, DC);
    if not InanimationProcess then EndPaint(Handle, PS);
  end;
end;

procedure TsButton.PrepareCache;
var
  CI : TCacheInfo;
  BGInfo : TacBGInfo;
  State : integer;
begin
  BGInfo.PleaseDraw := False;
  GetBGInfo(@BGInfo, Parent);
  CI := BGInfoToCI(@BGInfo);

  InitCacheBmp(SkinData);
  FCommonData.FCacheBmp.Canvas.Font.Assign(Font);

  State := min(CurrentState, FCommonData.SkinManager.gd[FCommonData.SkinIndex].States - 1);
  PaintItemBG(FCommonData, CI, State, Rect(0, 0, Width, Height), Point(Left, Top), FCommonData.FCacheBMP, 0, 0);
  if RegionChanged and not InAnimationProcess and (FadeTimer = nil) then begin
    if FRegion > 1 then DeleteObject(FRegion);
    FRegion := CreateRectRgn(0, 0, Width, Height);
  end; // Empty region
  if FCommonData.SkinManager.IsValidImgIndex(FCommonData.BorderIndex) then begin
    if (State <> 0) or (FCommonData.SkinManager.ma[FCommonData.BorderIndex].DrawMode and BDM_ACTIVEONLY <> BDM_ACTIVEONLY)
      then PaintRgnBorder(FCommonData.FCacheBmp, FRegion, True, FCommonData.SkinManager.ma[FCommonData.BorderIndex], State);
  end;
  if SkinData.HUEOffset <> 0 then ChangeBmpHUE(FCommonData.FCacheBmp, SkinData.HUEOffset);
  if SkinData.Saturation <> 0 then ChangeBmpSaturation(FCommonData.FCacheBmp, SkinData.Saturation);
  DrawGlyph;
  DrawCaption;
  if not Enabled or ((Action <> nil) and not TAction(Action).Enabled) then begin
    CI := GetParentCache(FCommonData);
    BmpDisabledKind(FCommonData.FCacheBmp, FDisabledKind, Parent, CI, Point(Left, Top));
  end;
  FCommonData.BGChanged := False;
end;

procedure TsButton.SetDisabledKind(const Value: TsDisabledKind);
begin
  if FDisabledKind <> Value then begin
    FDisabledKind := Value;
    if not (csLoading in ComponentState) then FCommonData.Invalidate;
  end;
end;

{$IFNDEF DELPHI7UP}
procedure TsButton.SetWordWrap(const Value: boolean);
begin
  if FWordWrap <> Value then begin
    FWordWrap := Value;
    if not (csLoading in ComponentState) then FCommonData.Invalidate;
  end;
end;
{$ENDIF}

procedure TsButton.SetDown(const Value: boolean);
begin
  if FDown <> Value then begin
    FDown := Value;
    RegionChanged := True;
    if not (csLoading in ComponentState) then FCommonData.Invalidate;
  end;
end;

procedure TsButton.SetFocusMargin(const Value: integer);
begin
  if (FFocusMargin <> Value) then begin
    FFocusMargin := Value;
  end;
end;

procedure TsButton.SetShowFocus(const Value: boolean);
begin
  if FShowFocus <> Value then begin
    FShowFocus := Value;
    FCommonData.Invalidate;
  end;
end;

procedure TsButton.WMKeyUp(var Message: TWMKey);
begin
  inherited;
  if Assigned(FCommonData) and FCommonData.Skinned and (Message.CharCode = 32) then begin
    RegionChanged := True;
    FCommonData.BGChanged := True;
    Repaint;
  end;
end;

procedure TsButton.WndProc(var Message: TMessage);
begin
{$IFDEF LOGGED}
  AddToLog(Message);
{$ENDIF}
  if (Message.Msg = WM_KILLFOCUS) and (csDestroying in ComponentState) then Exit;
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_CTRLHANDLED : begin Message.Result := 1; Exit end; // AlphaSkins supported
    AC_GETAPPLICATION : begin Message.Result := longint(Application); Exit end;
    AC_SETNEWSKIN : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
      RegionChanged := True;    
      {$IFNDEF SKININDESIGN}if not ((csDesigning in ComponentState) and (GetOwnerFrame(Self) <> nil)) then{$ENDIF}
//      SendMessage(Handle, BM_SETSTYLE, (GetWindowLong(Handle, GWL_STYLE) or BS_OWNERDRAW), 1);
      StopFading(FadeTimer, FCommonData);

      CommonWndProc(Message, FCommonData);
      exit
    end;
    AC_REMOVESKIN : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) and not (csDestroying in ComponentState) then begin
      StopFading(FadeTimer, FCommonData);
      CommonWndProc(Message, FCommonData);
//      SendMessage(Handle, BM_SETSTYLE, (GetWindowLong(Handle, GWL_STYLE) and not BS_OWNERDRAW), 1);
      FRegion := 0;
      SetWindowRgn(Handle, 0, False);
      Repaint;
      Exit;
    end;
    AC_REFRESH : if LongWord(Message.LParam) = LongWord(SkinData.SkinManager) then begin
      StopFading(FadeTimer, FCommonData);
      CommonWndProc(Message, FCommonData);
      RegionChanged := True;
      if SkinData.PrintDC = 0 then Repaint;
      exit
    end;
    AC_PREPARECACHE : PrepareCache;
    AC_DRAWANIMAGE : if FRegion > 1 then begin
      DeleteObject(FRegion);
      FRegion := 0;
    end;
    AC_STOPFADING : begin StopFading(FadeTimer, FCommonData); Exit end;
  end;
  if not ControlIsReady(Self) or not FCommonData.Skinned(True) then begin
    if not (csDestroying in ComponentState) then case Message.Msg of
      CM_MOUSEENTER : begin
        SkinData.FMouseAbove := True;
        Repaint;
        if Assigned(FOnMouseEnter) and Enabled and not (csDesigning in ComponentState) then FOnMouseEnter(Self);
      end;
      CM_MOUSELEAVE : begin
        SkinData.FMouseAbove := False;
        Repaint;
        if Assigned(FOnMouseLeave) and Enabled and not (csDesigning in ComponentState) then FOnMouseLeave(Self);
      end;
    end;
    inherited
  end
  else begin
    if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
      AC_ENDPARENTUPDATE : if FCommonData.Updating then begin
        FCommonData.Updating := False;
        Repaint;
        Exit
      end;
      AC_URGENTPAINT : begin
        if FCommonData.UrgentPainting then PrepareCache;
        CommonWndProc(Message, FCommonData);
        Exit
      end;
    end
    else case Message.Msg of
      WM_WINDOWPOSCHANGING : RegionChanged := True;
      WM_WINDOWPOSCHANGED : begin
        RegionChanged := True;
        SkinData.BGChanged := True;
      end;
      CM_UIACTIVATE : SkinData.Updating := False;
      CM_DIALOGCHAR : if (Enabled and Focused and (TCMDialogChar(Message).CharCode = VK_SPACE)) then begin
        StopFading(FadeTimer, FCommonData);
        RegionChanged := True;
        FCommonData.BGChanged := True;
        if (SkinData.GlowID <> -1) then begin
          HideGlow(SkinData.GlowID);
          SkinData.GlowID := -1;
        end;
        Repaint;
      end;
      CM_MOUSEENTER : if Enabled and not (csDesigning in ComponentState) then begin
        if not FCommonData.FMouseAbove and not MouseForbidden then begin
          if Assigned(FOnMouseEnter) then FOnMouseEnter(Self);
          FCommonData.FMouseAbove := True;
          FCommonData.BGChanged := False;
          DoChangePaint(FadeTimer, FCommonData, False, EventEnabled(aeMouseEnter, FAnimatEvents));
        end;
      end;
      CM_MOUSELEAVE : if Enabled and not (csDesigning in ComponentState) then begin
        if Assigned(FOnMouseLeave) then FOnMouseLeave(Self);
        FCommonData.FMouseAbove := False;
        FCommonData.BGChanged := False;
        DoChangePaint(FadeTimer, FCommonData, False, EventEnabled(aeMouseLeave, FAnimatEvents));
      end;
      WM_SIZE : begin
        RegionChanged := True;
        ClearGlows;
      end;
      WM_UPDATEUISTATE, WM_ERASEBKGND : if Visible or (csDesigning in ComponentState) then begin
        Message.Result := 1;
        Exit;
      end;
      CM_TEXTCHANGED : if not (csDestroying in ComponentState) then begin
        FCommonData.Invalidate;
        Exit;
      end;
      WM_PRINT : begin
        RegionChanged := True;
        FCommonData.FUpdating := False;
        OurPaintHandler(TWMPaint(Message).DC);
        Exit;
      end;
      WM_PAINT : if Visible or (csDesigning in ComponentState) then begin
        if (Parent = nil) then Exit;
        OurPaintHandler(TWMPaint(Message).DC);
        if not (csDesigning in ComponentState) then Exit;
      end;
      CN_DRAWITEM : begin Message.WParam := 0; Message.LParam := 0; Message.Result := 1; Exit; end;
      WM_MOVE : if (FCommonData.SkinManager.gd[FCommonData.SkinIndex].Transparency > 0) or ((FCommonData.SkinManager.gd[FCommonData.SkinIndex].HotTransparency > 0) and ControlIsActive(FCommonData)) then begin
        FCommonData.BGChanged := True;
        Repaint
      end;
      WM_SETFOCUS, CM_ENTER : if not (csDesigning in ComponentState) and Visible then begin
        if Enabled and not (csDestroying in ComponentState) and not bFocusChanging then begin
          Perform(WM_SETREDRAW, 0, 0);
          bFocusChanging := True;
          inherited;
          Perform(WM_SETREDRAW, 1, 0);
          bFocusChanging := False;
          if FadeTimer <> nil then FadeTimer.Change {Fast repaint} else FCommonData.Invalidate;
        end else inherited;
        Exit;
      end;
      WM_KILLFOCUS, CM_EXIT: if not (csDesigning in ComponentState) and Visible then begin
        if Enabled and not (csDestroying in ComponentState) then begin
          if FadeTimer <> nil then StopFading(FadeTimer, FCommonData);
          Perform(WM_SETREDRAW, 0, 0);
          inherited;
          Perform(WM_SETREDRAW, 1, 0);
          if FCommonData.Skinned then begin
            FCommonData.FFocused := False;
            RegionChanged := True;
            FCommonData.Invalidate;
            if (SkinData.GlowID <> -1) then begin
              HideGlow(SkinData.GlowID);
              SkinData.GlowID := -1;
            end;
          end;
        end
        else inherited;
        Exit
      end;
      CM_FOCUSCHANGED : if Visible then begin
        if not bFocusChanging then Perform(WM_SETREDRAW, 0, 0);
        inherited;
        if not bFocusChanging then Perform(WM_SETREDRAW, 1, 0);
      end;     // Disabling of blinking
      WM_ENABLE : Exit; // Disabling of blinking when switched
    end;
    CommonWndProc(Message, FCommonData);
    inherited;
    if not (csDestroying in ComponentState) then case Message.Msg of
      CM_CANCELMODE : begin
        if (SkinData.GlowID <> -1) then begin
          HideGlow(SkinData.GlowID);
          SkinData.GlowID := -1;
        end;
      end;
      CM_ENABLEDCHANGED : if (Visible or (csDesigning in ComponentState)) and not (csDestroying in ComponentState) then begin
        if not Enabled then StopFading(FadeTimer, FCommonData);
        FCommonData.Updating := False;
        FCommonData.Invalidate;
      end;
      CM_VISIBLECHANGED : if not (csDestroying in ComponentState) then begin
        FCommonData.BGChanged := True;
        FCommonData.Updating := False;
        if Visible or (csDesigning in ComponentState) then Repaint;
      end;
      WM_SETFONT : if Visible or (csDesigning in ComponentState) then begin
        FCommonData.Updating := False;
        FCommonData.Invalidate;
      end;
      CM_ACTIONUPDATE : begin
        if (Action <> nil) then Enabled := TCustomAction(Action).Enabled;
      end;
    end;
  end;
end;

procedure TsButton.SetReflected(const Value: boolean);
begin
  if FReflected <> Value then begin
    FReflected := Value;
    FCommonData.Invalidate;
  end;
end;

procedure TsButton.CNDrawItem(var Message: TWMDrawItem);
begin
  if not SkinData.Skinned {and (GlyphExists)} then StdDrawItem(Message.DrawItemStruct^) else inherited;
end;

procedure TsButton.StdDrawItem(const DrawItemStruct: TDrawItemStruct);
var
  IsDown, IsDefault: Boolean;
  R: TRect;
  Flags: Longint;
{$IFDEF DELPHI7UP}
  Details: TThemedElementDetails;
  Button: TThemedButton;
  Offset: TPoint;
{$ENDIF}
  Canvas : TCanvas;
begin
  Canvas := TCanvas.Create;
  Canvas.Handle := DrawItemStruct.hDC;
  R := ClientRect;

  with DrawItemStruct do begin
    Canvas.Handle := hDC;
    Canvas.Font := Self.Font;
    IsDown := itemState and ODS_SELECTED <> 0;
    IsDefault := itemState and ODS_FOCUS <> 0;
  end;

{$IFDEF DELPHI7UP}
  if ThemeServices.ThemesEnabled then begin
    if not Enabled then Button := tbPushButtonDisabled else if IsDown
      then Button := tbPushButtonPressed
      else if SkinData.FMouseAbove{ MouseInControl }
        then Button := tbPushButtonHot
        else if IsFocused or IsDefault
          then Button := tbPushButtonDefaulted
          else Button := tbPushButtonNormal;

    Details := ThemeServices.GetElementDetails(Button);
    // Parent background.
    ThemeServices.DrawParentBackground(Handle, DrawItemStruct.hDC, @Details, True);
    // Button shape.
    ThemeServices.DrawElement(DrawItemStruct.hDC, Details, DrawItemStruct.rcItem);
    R := ThemeServices.ContentRect(Canvas.Handle, Details, DrawItemStruct.rcItem);

    if Button = tbPushButtonPressed then Offset := Point(1, 0) else Offset := Point(0, 0);

    if IsFocused and IsDefault then begin
      Canvas.Pen.Color := clWindowFrame;
      Canvas.Brush.Color := clBtnFace;
      DrawFocusRect(Canvas.Handle, R);
    end;
  end
  else
{$ENDIF}
  begin
    Flags := DFCS_BUTTONPUSH or DFCS_ADJUSTRECT;
    if IsDown then Flags := Flags or DFCS_PUSHED;
    if DrawItemStruct.itemState and ODS_DISABLED <> 0 then
      Flags := Flags or DFCS_INACTIVE;

    { DrawFrameControl doesn't allow for drawing a button as the
        default button, so it must be done here. }
    if IsFocused or IsDefault then begin
      Canvas.Pen.Color := clWindowFrame;
      Canvas.Pen.Width := 1;
      Canvas.Brush.Style := bsClear;
      Canvas.Rectangle(R.Left, R.Top, R.Right, R.Bottom);

      { DrawFrameControl must draw within this border }
      InflateRect(R, -1, -1);
    end;

    { DrawFrameControl does not draw a pressed button correctly }
    if IsDown then begin
      Canvas.Pen.Color := clBtnShadow;
      Canvas.Pen.Width := 1;
      Canvas.Brush.Color := clBtnFace;
      Canvas.Rectangle(R.Left, R.Top, R.Right, R.Bottom);
      InflateRect(R, -1, -1);
    end
    else DrawFrameControl(DrawItemStruct.hDC, R, DFC_BUTTON, Flags);

    if IsFocused then begin
      R := ClientRect;
      InflateRect(R, -1, -1);
    end;

    Canvas.Font := Self.Font;
    if IsDown then OffsetRect(R, 1, 1);

    if IsFocused and IsDefault then begin
      R := ClientRect;
      InflateRect(R, -4, -4);
      Canvas.Pen.Color := clWindowFrame;
      Canvas.Brush.Color := clBtnFace;
      DrawFocusRect(Canvas.Handle, R);
    end;
  end;
  DrawCaption(Canvas);
  DrawBtnGlyph(Self, Canvas);

  Canvas.Handle := 0;
  Canvas.Free;
end;

{$IFDEF D2009}
procedure TsButton.UpdateImageList;
begin
  FCommonData.Invalidate
// Ignore inherited;
end;

procedure TsButton.UpdateImages;
begin
// Ignore inherited;
end;
{$ENDIF}

procedure TsButton.SetStyle(const Value: TButtonStyle);
begin
  if FStyle <> Value then begin
    FStyle := Value;
    FCommonData.Invalidate;
  end;
end;

procedure TsButton.SetContentMargin(const Value: integer);
begin
  if FContentMargin <> Value then begin
    FContentMargin := Value;
    FCommonData.Invalidate;
  end;
end;

{$IFNDEF D2009}

function TsButton.IsImageIndexStored: Boolean;
begin
  Result := (ActionLink = nil) or not TPushButtonActionLink(ActionLink).IsImageIndexLinked;
end;

procedure TsButton.SetDisabledImageIndex(const Value: TImageIndex);
begin
  if Value <> FDisabledImageIndex then begin
    FDisabledImageIndex := Value;
    if Images <> nil then FCommonData.Invalidate;
  end;
end;

procedure TsButton.SetHotImageIndex(const Value: TImageIndex);
begin
  if Value <> FHotImageIndex then begin
    FHotImageIndex := Value;
    if Images <> nil then FCommonData.Invalidate;
  end;
end;

procedure TsButton.SetImageAlignment(const Value: TImageAlignment);
begin
  if Value <> FImageAlignment then begin
    FImageAlignment := Value;
    if Images <> nil then FCommonData.Invalidate;
  end;
end;

procedure TsButton.SetImageIndex(const Value: TImageIndex);
begin
  if Value <> FImageIndex then begin
    FImageIndex := Value;
    if Images <> nil then FCommonData.Invalidate;
  end;
end;

procedure TsButton.SetImageMargins(const Value: TImageMargins);
begin
  FImageMargins.Assign(Value);
end;

procedure TsButton.SetImages(const Value: TCustomImageList);
begin
  if Value <> FImages then begin
    if Images <> nil then Images.UnRegisterChanges(FImageChangeLink);
    FImages := Value;
    if Images <> nil then begin
      Images.RegisterChanges(FImageChangeLink);
      Images.FreeNotification(Self);
    end;
    FCommonData.Invalidate;
  end;
end;

procedure TsButton.SetPressedImageIndex(const Value: TImageIndex);
begin
  if Value <> FPressedImageIndex then begin
    FPressedImageIndex := Value;
    if Images <> nil then FCommonData.Invalidate;
  end;
end;

procedure TsButton.SetSelectedImageIndex(const Value: TImageIndex);
begin
  if Value <> FSelectedImageIndex then begin
    FSelectedImageIndex := Value;
    if Images <> nil then FCommonData.Invalidate;
  end;
end;

procedure TsButton.ImageMarginsChange(Sender: TObject);
begin
  if Images <> nil then FCommonData.Invalidate;
end;

procedure TsButton.ImageListChange(Sender: TObject);
begin
  if Images <> nil then FCommonData.Invalidate;
end;

procedure TsButton.SetCommandLinkHint(const Value: acString);
begin
  if FCommandLinkHint <> Value then begin
    FCommandLinkHint := Value;
    FCommonData.Invalidate;
  end;
end;

{ TImageMargins }

procedure TImageMargins.Assign(Source: TPersistent);
begin
  if Source is TImageMargins then
  begin
    FLeft := TImageMargins(Source).Left;
    FTop := TImageMargins(Source).Top;
    FRight := TImageMargins(Source).Right;
    FBottom := TImageMargins(Source).Bottom;
    Change;
  end
  else inherited Assign(Source);
end;

procedure TImageMargins.Change;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TImageMargins.SetMargin(Index, Value: Integer);
begin
  case Index of
    0: if Value <> FLeft then begin
      FLeft := Value;
      Change;
    end;
    1: if Value <> FTop then begin
      FTop := Value;
      Change;
    end;
    2: if Value <> FRight then begin
      FRight := Value;
      Change;
    end;
    3: if Value <> FBottom then begin
      FBottom := Value;
      Change;
    end;
  end;
end;

{ TPushButtonActionLink }

function TPushButtonActionLink.IsImageIndexLinked: Boolean;
begin
  Result := inherited IsImageIndexLinked and (TsButton(FClient).ImageIndex = (Action as TCustomAction).ImageIndex);
end;

procedure TPushButtonActionLink.SetImageIndex(Value: Integer);
begin
  if IsImageIndexLinked then TsButton(FClient).ImageIndex := Value;
end;

{$ENDIF}

end.
