unit sPanel;
{$I sDefs.inc}
{.$DEFINE LOGGED}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, sCommonData, sConst
  {$IFDEF TNTUNICODE} , TntExtCtrls {$ENDIF};

type
{$IFDEF TNTUNICODE}
  TsPanel = class(TTntPanel)
{$ELSE}
  TsPanel = class(TPanel)
{$ENDIF}
{$IFNDEF NOTFORHELP}
  private
    FCommonData: TsCommonData;
    FOnPaint: TPaintEvent;
    FOnMouseLeave: TNotifyEvent;
    FOnMouseEnter: TNotifyEvent;
    FOldBevel : TPanelBevel;
  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    procedure AfterConstruction; override;
    procedure Loaded; override;
    procedure Paint; override;
    procedure OurPaint(DC : HDC = 0; SendUpdated : boolean = True); virtual;
    procedure PrepareCache;
    procedure WndProc (var Message: TMessage); override;
    procedure WriteText(R : TRect; aCanvas : TCanvas = nil; aDC : hdc = 0); virtual;
    procedure PaintWindow(DC: HDC); override;
  published
{$ENDIF} // NOTFORHELP
    property SkinData : TsCommonData read FCommonData write FCommonData;
    property OnPaint : TPaintEvent read FOnPaint write FOnPaint;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
  end;

  TsDragBar = class(TsPanel)
{$IFNDEF NOTFORHELP}
  private
    FDraggedControl : TControl;
    procedure WMActivateApp(var Message: TWMActivateApp); message WM_ACTIVATEAPP;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    procedure ReadState(Reader: TReader); override;
    constructor Create (AOwner: TComponent); override;
    procedure WndProc (var Message: TMessage); override;
  published
    property Alignment;
    property Align default alTop;
    property Color default clActiveCaption;
{$ENDIF} // NOTFORHELP
    property DraggedControl : TControl read FDraggedControl write FDraggedControl;
  end;

{$IFNDEF NOTFORHELP}
  TsContainer = class(TsPanel)
  end;

  TsGrip = class(TsPanel)
  public
    Transparent : boolean;
    LinkedControl : TWinControl;
    constructor Create (AOwner: TComponent); override;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  end;

  TsColInfo = record
    Index : integer;
    Color : TColor;
    R : TRect;
    Selected : boolean;
  end;

  TsColorsPanel = class(TsPanel)
  private
    FColors: TStrings;
    FItemIndex: integer;
    FItemWidth: integer;
    FItemHeight: integer;
    FItemMargin: integer;
    FColCount: integer;
    FRowCount: integer;
    FOnChange: TNotifyEvent;
    procedure SetColors(const Value: TStrings);
    procedure SetItemIndex(const Value: integer);
    procedure SetItemHeight(const Value: integer);
    procedure SetItemWidth(const Value: integer);
    procedure SetItemMargin(const Value: integer);
    procedure SetColCount(const Value: integer);
    procedure SetRowCount(const Value: integer);
  public
    OldSelected : integer;
    ColorsArray : array of TsColInfo;
    constructor Create (AOwner: TComponent); override;
    destructor Destroy; override;
    procedure GenerateColors;
    procedure AfterConstruction; override;
    procedure Loaded; override;
    procedure OurPaint(DC : HDC = 0; SendUpdated : boolean = True); override;
    procedure PaintColors(const DC: hdc);
    function Count : integer;
    function GetItemByCoord(p : TPoint) : integer;
    procedure WndProc (var Message: TMessage); override;
    procedure MouseDown (Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function ColorValue : TColor;
  published
    property ColCount : integer read FColCount write SetColCount default 5;
    property Colors : TStrings read FColors write SetColors;
    property ItemIndex : integer read FItemIndex write SetItemIndex default -1;
    property ItemHeight : integer read FItemHeight write SetItemHeight default 21;
    property ItemWidth : integer read FItemWidth write SetItemWidth default 21;
    property ItemMargin : integer read FItemMargin write SetItemMargin default 6;
    property Height default 60;
    property RowCount : integer read FRowCount write SetRowCount default 2;
    property Width default 140;
    property OnChange : TNotifyEvent read FOnChange write FOnChange;
  end;

  TsStdColorsPanel = class(TsColorsPanel)
  end;

{$ENDIF} // NOTFORHELP

implementation

uses sMessages, sGraphUtils, sVCLUtils, sMaskData, sStyleSimply, sSkinManager, sBorders,
  acntUtils{$IFDEF LOGGED}, sDebugMsgs{$ENDIF}, sAlphaGraph, sSkinProps;

{ TsPanel }

procedure TsPanel.AfterConstruction;
begin
  inherited;
  FCommonData.Loaded;
end;

constructor TsPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCommonData := TsCommonData.Create(Self, True);
  FCommonData.COC := COC_TsPanel;
end;

destructor TsPanel.Destroy;
begin
  if Assigned(FCommonData) then FreeAndNil(FCommonData);
  inherited Destroy;
end;

procedure TsPanel.Loaded;
begin
  inherited;
  FCommonData.Loaded;
  FOldBevel := BevelOuter;
end;

procedure TsPanel.OurPaint;
var
  b : boolean;
  SavedDC, NewDC : HDC;
  R : TRect;
  i : integer;
  ParentBG : TacBGInfo;
  C : TColor;
  TmpCanvas : TCanvas;
begin
  if Showing and Assigned(FCommonData) and FCommonData.Skinned {and not acGraphPainting }then begin
    if DC <> 0 then NewDC := DC else NewDC := Canvas.Handle;

    if IsCached(FCommonData) and not SkinData.CustomColor or (Self is TsColorsPanel) or InAnimationProcess then begin
      FCommonData.FUpdating := FCommonData.Updating;
      if not FCommonData.FUpdating then begin
        // If transparent and parent is resized
        b := FCommonData.HalfVisible or FCommonData.BGChanged;

        if SkinData.RepaintIfMoved then begin

          FCommonData.HalfVisible := (WidthOf(R) <> Width) or (HeightOf(R) <> Height)
        end
        else FCommonData.HalfVisible := False;

        if b and not FCommonData.UrgentPainting then PrepareCache;
        CopyWinControlCache(Self, FCommonData, Rect(0, 0, 0, 0), Rect(0, 0, Width, Height), NewDC, False);
        sVCLUtils.PaintControls(NewDC, Self, b and SkinData.RepaintIfMoved, Point(0, 0));
      end;
    end
    else begin
      FCommonData.Updating := False;
      i := SkinBorderMaxWidth(FCommonData);
      R := Rect(0, 0, Width, Height);
      SavedDC := SaveDC(NewDC);

      ExcludeControls(NewDC, Self, actGraphic, 0, 0);
      ParentBG.PleaseDraw := False;
      if not SkinData.CustomColor then GetBGInfo(@ParentBG, Self.Parent) else begin
        ParentBG.Color := ColorToRGB(Color);
        ParentBG.BgType := btFill;
      end;
      if FCommonData.FCacheBmp.Empty then begin
        FCommonData.FCacheBmp.Width := 1;
        FCommonData.FCacheBmp.Height := 1;
      end;
      if (FCommonData.SkinManager.gd[FCommonData.SkinIndex].Transparency = 100) and (ParentBG.BgType = btCache) then begin
        FCommonData.FUpdating := FCommonData.Updating;
        if not FCommonData.FUpdating then begin
          if i = 0 then begin
            BitBlt(NewDC, 0, 0, Width, Height, ParentBG.Bmp.Canvas.Handle, ParentBG.Offset.X, ParentBG.Offset.Y, SRCCOPY);
          end
          else begin
            if FCommonData.FCacheBmp = nil then FCommonData.FCacheBmp := CreateBmp32(Width, Height);
            R := PaintBorderFast(NewDC, R, i, FCommonData, 0);
            if FCommonData.SkinManager.gd[FCommonData.SkinIndex].Transparency = 100 then FillDC(NewDC, R, ParentBG.Color) else FillDC(NewDC, R, GetBGColor(SkinData, 0));
            if i > 0 then BitBltBorder(NewDC, 0, 0, Width, Height, FCommonData.FCacheBmp.Canvas.Handle, 0, 0, i);
            BitBlt(NewDC, i, i, Width - 2 * i, Height - 2 * i, ParentBG.Bmp.Canvas.Handle, ParentBG.Offset.X + i, ParentBG.Offset.Y + i, SRCCOPY);
          end;
        end;
      end
      else begin
        case FCommonData.SkinManager.gd[FCommonData.SkinIndex].Transparency of
          0 : C := iffi(FCommonData.CustomColor, Color, FCommonData.SkinManager.gd[FCommonData.SkinIndex].Color);
          100 : C := ParentBG.Color;
          else C := MixColors(ParentBG.Color, iffi(FCommonData.CustomColor, Color, FCommonData.SkinManager.gd[FCommonData.SkinIndex].Color), FCommonData.SkinManager.gd[FCommonData.SkinIndex].Transparency / 100);
        end;
        if i = 0 then FillDC(DC, R, C) else begin
          if FCommonData.FCacheBmp = nil then FCommonData.FCacheBmp := CreateBmp32(Width, Height);
          R := PaintBorderFast(NewDC, R, i, FCommonData, 0);
          FillDC(NewDC, R, C);
          if i > 0 then BitBltBorder(NewDC, 0, 0, Width, Height, FCommonData.FCacheBmp.Canvas.Handle, 0, 0, i);
        end;
      end;
      R := ClientRect;
      i := BorderWidth + integer(BevelInner <> bvNone) * BevelWidth + integer(BevelOuter <> bvNone) * BevelWidth;
      InflateRect(R, -i, -i);

      if DC = 0 then TmpCanvas := Canvas else begin
        TmpCanvas := TCanvas.Create;
        TmpCanvas.Handle := DC;
        TmpCanvas.Font.Assign(Font);
        TmpCanvas.Brush.Style := bsClear;
      end;

      WriteText(R, TmpCanvas);
      if Assigned(FOnPaint) then FOnPaint(Self, TmpCanvas);

      if DC <> 0 then FreeAndNil(TmpCanvas);

      FCommonData.BGChanged := False;
      RestoreDC(NewDC, SavedDC);
      sVCLUtils.PaintControls(NewDC, Self, True, Point(0, 0));
//      if FCommonData.FCacheBmp <> nil then FreeAndNil(FCommonData.FCacheBmp);
    end;
    if SendUpdated and not (csPaintCopy in ControlState) then SetParentUpdated(Self);
  end;
end;

procedure TsPanel.Paint;
begin
  inherited;
  if Showing and Assigned(FOnPaint) then FOnPaint(Self, Canvas)
end;

procedure TsPanel.PaintWindow(DC: HDC);
begin
  if not (csPaintCopy in ControlState) or not SkinData.Skinned then begin
    inherited;
  end;
  OurPaint(DC);
end;

procedure TsPanel.PrepareCache;
var
  w : integer;
  R : TRect;
begin
  if IsCached(FCommonData) or InAnimationProcess or (Self is TsColorsPanel) then begin
    InitCacheBmp(SkinData);
    PaintSkinControl(FCommonData, Parent, True, 0, Rect(0, 0, Width, Height), Point(Left, Top), FCommonData.FCacheBMP, True);
    R := ClientRect;
    w := BorderWidth + integer(BevelInner <> bvNone) * BevelWidth + integer(BevelOuter <> bvNone) * BevelWidth;
    InflateRect(R, -w, -w);
    WriteText(R, FCommonData.FCacheBmp.Canvas);
    if Assigned(FOnPaint) then FOnPaint(Self, FCommonData.FCacheBmp.Canvas);
    FCommonData.BGChanged := False;
  end;
end;

procedure TsPanel.WndProc(var Message: TMessage);
var
  SaveIndex: Integer;
  DC: HDC;
  PS: TPaintStruct;
begin
{$IFDEF LOGGED}
  AddToLog(Message);
{$ENDIF}
  if Message.Msg = SM_ALPHACMD
    then case Message.WParamHi of
    AC_CTRLHANDLED : begin Message.Result := 1; Exit end;
    AC_GETAPPLICATION : begin Message.Result := longint(Application); Exit end;
    AC_REMOVESKIN : begin
      ControlStyle := ControlStyle - [csOpaque];
      if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
        CommonWndProc(Message, FCommonData);
        Invalidate;
      end;
      AlphaBroadCast(Self, Message);
      exit
    end;
    AC_SETNEWSKIN : begin
      ControlStyle := ControlStyle - [csOpaque];
      AlphaBroadCast(Self, Message);
      if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
        CommonWndProc(Message, FCommonData);
      end;
      exit
    end;
    AC_REFRESH : begin
      if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
        CommonWndProc(Message, FCommonData);
        if HandleAllocated and not (csLoading in ComponentState) and Visible then begin
          InvalidateRect(Handle, nil, True);
          RedrawWindow(Handle, nil, 0, RDW_FRAME or RDW_INVALIDATE or RDW_UPDATENOW or RDW_ERASE);
        end;
        AlphaBroadCast(Self, Message);
      end
      else AlphaBroadCast(Self, Message);
      exit
    end;
    AC_GETBG : if (SkinData.SkinManager <> nil) and SkinData.SkinManager.IsValidSkinIndex(SkinData.SkinIndex) then begin
{      if (SkinData.BGChanged or SkinData.HalfVisible) and not SkinData.Updating then begin
        if not ((SkinData.SkinManager.gd[SkinData.SkinIndex].Transparency = 100) and (not SkinData.SkinManager.IsValidImgIndex(SkinData.BorderIndex) or (SkinData.SkinManager.ma[SkinData.BorderIndex].DrawMode and BDM_ACTIVEONLY = BDM_ACTIVEONLY)))
            then begin
//          if IsWindowVisible(Handle) then
          PrepareCache;
        end;
      end;}
      InitBGInfo(FCommonData, PacBGInfo(Message.LParam), 0);
      if (WidthOf(ClientRect) <> Width) and (PacBGInfo(Message.LParam)^.BgType = btCache) and not PacBGInfo(Message.LParam)^.PleaseDraw then begin
        inc(PacBGInfo(Message.LParam)^.Offset.X, BorderWidth + BevelWidth * (integer(BevelInner <> bvNone) + integer(BevelOuter <> bvNone)));
        inc(PacBGInfo(Message.LParam)^.Offset.Y, BorderWidth + BevelWidth * (integer(BevelInner <> bvNone) + integer(BevelOuter <> bvNone)));
      end;
      Exit;
    end;
  end;
  if not ControlIsReady(Self) or not FCommonData.Skinned then begin
    case Message.Msg of
      WM_PRINT : if Assigned(OnPaint) then begin
        OnPaint(Self, Canvas);
        if TWMPaint(Message).DC <> 0
          then BitBlt(TWMPaint(Message).DC, 0, 0, Width, Height, Canvas.Handle, 0, 0, SRCCOPY);
      end;
      WM_ERASEBKGND : begin
        if not Assigned(FOnPaint) then inherited;
      end
      else inherited;
    end;
  end
  else begin
    if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
      AC_ENDPARENTUPDATE : begin
        if FCommonData.FUpdating then begin
          FCommonData.FUpdating := False;
          FCommonData.FUpdating := FCommonData.Updating;
          if not FCommonData.FUpdating
            then RedrawWindow(Handle, nil, 0, RDW_INVALIDATE or RDW_ERASE or RDW_FRAME or RDW_UPDATENOW);
        end;
        SetParentUpdated(Self);
        Exit;
      end;
      AC_PREPARING : begin
        Message.Result := integer(FCommonData.Updating or FCommonData.FCacheBmp.Empty);
        Exit;
      end
      else if CommonMessage(Message, FCommonData) then Exit;
    end
    else begin
      case Message.Msg of
        WM_PRINT : begin
          FCommonData.FUpdating := False;
          if ControlIsReady(Self) then begin
            if not (IsCached(FCommonData) or (Self is TsColorsPanel)) and not Assigned(FCommonData.FCacheBMP) then FCommonData.FCacheBMP := CreateBmp32(0, 0);
            DC := TWMPaint(Message).DC;
            PrepareCache;
            OurPaint(DC, False);
          end;
          Exit;
        end;
        WM_PAINT : if Visible or (csDesigning in ComponentState) then begin
          DC := BeginPaint(Handle, PS);
          FCommonData.FUpdating := FCommonData.Updating;
          if IsCached(SkinData) and not FCommonData.FUpdating then begin
            if TWMPAINT(Message).DC = 0 then DC := GetDC(Handle) else DC := TWMPAINT(Message).DC;
            try
              SaveIndex := SaveDC(DC);
              ControlState := ControlState + [csCustomPaint];
              Canvas.Lock;
              try
                Canvas.Handle := DC;
                try
                  TControlCanvas(Canvas).UpdateTextFlags;
                  OurPaint(DC);
                finally
                  Canvas.Handle := 0;
                end;
              finally
                Canvas.Unlock;
              end;
              RestoreDC(DC, SaveIndex);
            finally
              ControlState := ControlState - [csCustomPaint];
              if TWMPaint(Message).DC = 0 then ReleaseDC(Handle, DC);
            end;
          end
          else {$IFDEF DELPHI7UP}if not ParentBackground then{$ENDIF} begin // If BG is not redrawn automatically
            OurPaint(DC) // Repainting of graphic controls
          end;
          EndPaint(Handle, PS);
          Message.Result := 0;
          Exit;
        end;
        CM_TEXTCHANGED : begin
          if Parent <> nil then FCommonData.Invalidate;
          Exit;
        end;
        WM_ERASEBKGND : begin
          if (Message.WParam <> Message.LParam {PerformEraseBackground, TntSpeedButtons}) then begin
            FCommonData.FUpdating := FCommonData.Updating;
            if not IsCached(SkinData) and not FCommonData.FUpdating then OurPaint(TWMPaint(Message).DC); // TODO : drawing of graphic controls must be added also
            Message.Result := 1;
          end
          else if (Message.WParam <> 0) then begin // From PaintTo
            if FCommonData.BGChanged then PrepareCache;
            if not FCommonData.BGChanged then begin
              if IsCached(FCommonData)
                then BitBlt(TWMPaint(Message).DC, 0, 0, Width, Height, FCommonData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY)
                else FillDC(TWMPaint(Message).DC, Rect(0, 0, Width, Height), GetControlColor(Handle));
            end;
            Message.Result := 1;
          end;
          Exit;
        end;
        {CM_SHOWINGCHANGED, }CM_VISIBLECHANGED : begin
          FCommonData.BGChanged := True;
          FCommonData.FUpdating := False;
          inherited;
          Exit;
        end;
        CM_INVALIDATE : begin
          if FOldBevel <> BevelOuter then begin
            case FOldBevel of
              bvRaised : begin
                if FCommonData.SkinSection = s_Panel then begin
                  case BevelOuter of
                    bvNone : FCommonData.SkinSection := s_CheckBox; 
                    bvLowered : FCommonData.SkinSection := s_PanelLow;
                  end;
                end;
              end;
              bvLowered : begin
                if FCommonData.SkinSection = s_PanelLow then begin
                  case BevelOuter of
                    bvNone : FCommonData.SkinSection := s_CheckBox;
                    bvRaised : FCommonData.SkinSection := s_Panel;
                  end;
                end;
              end;
              bvNone : begin
                if FCommonData.SkinSection = s_CheckBox then begin
                  case BevelOuter of
                    bvRaised : FCommonData.SkinSection := s_Panel;
                    bvLowered : FCommonData.SkinSection := s_PanelLow;
                  end;
                end;
              end;
            end;
            FOldBevel := BevelOuter;
          end;
        end;
        CM_COLORCHANGED : if SkinData.CustomColor then SkinData.BGChanged := True;
        WM_KILLFOCUS, WM_SETFOCUS: begin inherited; exit end;
        WM_WINDOWPOSCHANGING : if SkinData.SkinManager.gd[SkinData.SkinIndex].Transparency <> 0 then FCommonData.BGChanged := True;
        WM_SIZE : FCommonData.BGChanged := True;
      end;
      CommonWndProc(Message, FCommonData);
      inherited;
      case Message.Msg of
        CM_ENABLEDCHANGED : FCommonData.Invalidate;
        WM_SETFONT : begin
          if Caption <> '' then begin
            FCommonData.BGChanged := True;
            Repaint;
          end;
        end;
      end;
    end;
  end;
  case Message.Msg of
    CM_MOUSEENTER : if Assigned(FOnMouseEnter) then FOnMouseEnter(Self);
    CM_MOUSELEAVE : if Assigned(FOnMouseLeave) then FOnMouseLeave(Self);
  end;
end;

procedure TsPanel.WriteText(R: TRect; aCanvas : TCanvas = nil; aDC : hdc = 0);
var
  C : TCanvas;
  TmpRect : TRect;
  Flags : Cardinal;
begin
{$IFDEF D2009}
  if not ShowCaption then Exit;
{$ENDIF}
  if (aCanvas = nil) then begin
    if aDC <> 0 then begin
      C := TCanvas.Create;
      C.Handle := aDC;
    end
    else Exit;
  end
  else C := aCanvas;

  TmpRect := R;
  Flags := GetStringFlags(Self, alignment) or DT_WORDBREAK;
  C.Font.Assign(Font);
  acDrawText(C.Handle, Caption, TmpRect, Flags or DT_CALCRECT);

  R.Top := (HeightOf(R) - HeightOf(TmpRect, True)) div 2 + BorderWidth;
  R.Bottom := R.Top + HeightOf(TmpRect, True);
  acWriteTextEx(C, PacChar(Caption), Enabled, R, Flags, FCommonData, False);

  if (aCanvas = nil) and (C <> nil) then FreeAndNil(C);
end;

{ TsDragBar }

constructor TsDragBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SkinData.COC := COC_TsDragBar;
  Caption := ' ';
  Align := alTop;
  Height := 20;
  Font.Color := clCaptionText;
  Font.Style := [fsBold];
  Color := clActiveCaption;
  Cursor := crHandPoint;
{$IFDEF DELPHI7UP}
  ParentBackGround := False;
{$ENDIF}
end;

procedure TsDragBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, x, y);
  if (Button = mbLeft) and (FDraggedControl <> nil) then begin
    ReleaseCapture;
    FDraggedControl.Perform(WM_SYSCOMMAND, SC_DRAGMOVE, 0);
    if Assigned(OnClick) then OnClick(Self);
    if Assigned(OnMouseUp) then OnMouseUp(Self, Button, Shift, X, Y);
  end
end;

procedure TsDragBar.ReadState(Reader: TReader);
begin
  if (Reader.Parent <> nil) and (DraggedControl = nil) then DraggedControl := GetParentForm(TControl(Reader.Parent));
  inherited ReadState(Reader);
end;

procedure TsDragBar.WMActivateApp(var Message: TWMActivateApp);
begin
  if Message.Active then Font.Color := clActiveCaption else Font.Color := clInActiveCaption;
end;

procedure TsDragBar.WndProc(var Message: TMessage);
begin
  inherited;
  if Message.Msg = SM_ALPHACMD
    then case Message.WParamHi of
    AC_REMOVESKIN : begin
      Color := clActiveCaption;
{$IFDEF DELPHI7UP}
      ParentBackGround := False;
{$ENDIF}
    end;
  end;
end;

{ TsGrip }

constructor TsGrip.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Caption := ' ';
  SkinData.SkinSection := 'CHECKBOX';
  Align := alNone;
  Height := 20;
  Width := 20;
end;

procedure TsGrip.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
end;

procedure TsGrip.Paint;
var
  CI : TCacheInfo;
  BG : TacBGInfo;
begin
  if not ControlIsReady(Self) then Exit;
  SkinData.BGChanged := False;
  CI.Ready := False;
  if Transparent and (LinkedControl <> nil) then begin
    BG.PleaseDraw := False;
    GetBGInfo(@BG, LinkedControl);
    CI := BGInfoToCI(@BG);
  end;
  if CI.Ready then begin
    BitBlt(Canvas.Handle, 0, 0, Width, Height, CI.Bmp.Canvas.Handle, CI.Bmp.Width - Width + CI.X, CI.Bmp.Height - Height + CI.Y, SRCCOPY);
  end
  else FillDC(Canvas.Handle, Rect(0, 0, Width, Height), CI.FillColor); 
end;

{ TsColorsPanel }

procedure TsColorsPanel.AfterConstruction;
begin
  inherited;
  GenerateColors;
end;

function TsColorsPanel.ColorValue: TColor;
begin
  if FItemIndex = -1 then Result := clWhite else Result := ColorsArray[FItemIndex].Color;
end;

function TsColorsPanel.Count: integer;
begin
  Result := FColors.Count;
end;

constructor TsColorsPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Caption := ' ';
  FColors := TStringList.Create;
  FItemIndex := -1;
  ItemHeight := 21;
  ItemWidth := 21;
  FColCount := 5;
  FRowCount := 2;
  FItemMargin := 6;
  Height := 60;
  Width := 140;
end;

destructor TsColorsPanel.Destroy;
begin
  FreeAndNil(FColors);
  inherited Destroy;
end;

procedure TsColorsPanel.GenerateColors;
var
  i, x, y : integer;
  s : string;
begin
  SetLength(ColorsArray, 0);
  i := 0;
  for y := 0 to RowCount - 1 do for x := 0 to ColCount - 1 do begin
    SetLength(ColorsArray, i + 1);
    if i < FColors.Count then begin
      s := ExtractWord(1, FColors[i], [#13, #10, ' ']);
      ColorsArray[i].Color := SwapInteger(HexToInt(s));
    end
    else begin
      ColorsArray[i].Color := SwapInteger(ColorToRgb(clWhite));
      FColors.Add('FFFFFF');
    end;
    ColorsArray[i].Index := i;
    ColorsArray[i].Selected := i = FItemIndex;
    ColorsArray[i].R.Left := ItemMargin + x * (ItemWidth + ItemMargin);
    ColorsArray[i].R.Top := ItemMargin + y * (ItemHeight + ItemMargin);
    ColorsArray[i].R.Right := ColorsArray[i].R.Left + ItemWidth;
    ColorsArray[i].R.Bottom := ColorsArray[i].R.Top + ItemHeight;
    inc(i);
  end;
end;

function TsColorsPanel.GetItemByCoord(p : TPoint): integer;
var
  i : integer;
  R : TRect;
begin
  Result := - 1;
  for i := 0 to Count - 1 do begin
    R := ColorsArray[i].R;
    InflateRect(R, ItemMargin, ItemMargin);
    if PtInRect(R, p) then begin
      Result := i;
      Exit;
    end
  end;
end;

procedure TsColorsPanel.Loaded;
begin
  inherited;
  GenerateColors;
end;

procedure TsColorsPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  SetFocus;
  ItemIndex := GetItemByCoord(Point(x, y));
end;

procedure TsColorsPanel.OurPaint;
var
  b : boolean;
  R : TRect;
  NewDC : hdc;
  Brush : TBrush;
begin
  if DC <> 0 then NewDC := DC else NewDC := Canvas.Handle;
  if (csDestroying in ComponentState) or (csCreating in Parent.ControlState) or not Assigned(FCommonData) then Exit;
  if FCommonData.Skinned then begin
    FCommonData.Updating := FCommonData.Updating;

    if not FCommonData.Updating then begin
      InitCacheBmp(SkinData);
      // If transparent and in a form resizing 
      b := True or FCommonData.BGChanged or FCommonData.HalfVisible or GetBoolMsg(Parent, AC_GETHALFVISIBLE);
      FCommonData.HalfVisible := not (PtInRect(Parent.ClientRect, Point(Left, Top)) and
                             PtInRect(Parent.ClientRect, Point(Left + Width, Top + Height)));
      if b and not FCommonData.UrgentPainting then begin

        PaintItem(FCommonData, GetParentCache(FCommonData), False, 0, Rect(0, 0, width, Height), Point(Left, Top), FCommonData.FCacheBMP, False);
        WriteText(ClientRect);
        FCommonData.BGChanged := False;
        if not Assigned(FOnPaint)
          then PaintColors(FCommonData.FCacheBmp.Canvas.Handle);
      end;
      if Assigned(FOnPaint)
        then FOnPaint(Self, FCommonData.FCacheBmp.Canvas);

      CopyWinControlCache(Self, FCommonData, Rect(0, 0, 0, 0), Rect(0, 0, Width, Height), NewDC, True);
      sVCLUtils.PaintControls(NewDC, Self, b, Point(0, 0));
      if SendUpdated then SetParentUpdated(Self);
    end;

  end
  else begin
    inherited;
    Perform(WM_NCPAINT, 0, 0);
    if not Assigned(FOnPaint) then PaintColors(NewDC);
  end;
  // Selected item
  if (FItemIndex <> -1) and not Assigned(FOnPaint) then begin
    R := ColorsArray[FItemIndex].R;

    Brush := TBrush.Create;
    Brush.Style := bsSolid;
    Brush.Color := clWhite;
    InflateRect(R, 1, 1);
    FrameRect(NewDC, R, Brush.Handle);

    InflateRect(R, 1, 1);
    Brush.Color := 0;
    FrameRect(NewDC, R, Brush.Handle);

    if Focused then begin
      Brush.Color := clWhite;
      InflateRect(R, 2, 2);
      DrawFocusRect(NewDC, R);
    end;
    FreeAndNil(Brush);
  end;
end;

procedure TsColorsPanel.PaintColors(const DC: hdc);
var
  i : integer;
begin
  for i := 0 to Count - 1 do FillDC(DC, ColorsArray[i].R, ColorsArray[i].Color);
end;

procedure TsColorsPanel.SetColCount(const Value: integer);
begin
  if FColCount <> Value then begin
    FColCount := Value;
    GenerateColors;
    SkinData.Invalidate;
  end;
end;

procedure TsColorsPanel.SetColors(const Value: TStrings);
begin
  FColors.Assign(Value);
  GenerateColors;
  SkinData.Invalidate;
end;

procedure TsColorsPanel.SetItemHeight(const Value: integer);
begin
  if FItemHeight <> Value then begin
    FItemHeight := Value;
    GenerateColors;
    SkinData.Invalidate;
  end;
end;

procedure TsColorsPanel.SetItemIndex(const Value: integer);
begin
  if FItemIndex > Count - 1 then FItemIndex := - 1;
  if FItemIndex <> Value then begin
    if FItemIndex <> -1 then ColorsArray[FItemIndex].Selected := False;
    OldSelected := FItemIndex;
    FItemIndex := Value;
    if FItemIndex <> -1 then ColorsArray[FItemIndex].Selected := True;
    if Assigned(FOnChange) then FOnChange(Self);
    Repaint;
  end;
end;

procedure TsColorsPanel.SetItemMargin(const Value: integer);
begin
  if FItemMargin <> Value then begin
    FItemMargin := Value;
    GenerateColors;
    SkinData.Invalidate;
  end;
end;

procedure TsColorsPanel.SetItemWidth(const Value: integer);
begin
  if FItemWidth <> Value then begin
    FItemWidth := Value;
    GenerateColors;
    SkinData.Invalidate;
  end;
end;

procedure TsColorsPanel.SetRowCount(const Value: integer);
begin
  if FRowCount <> Value then begin
    FRowCount := Value;
    GenerateColors;
    SkinData.Invalidate;
  end;
end;

procedure TsColorsPanel.WndProc(var Message: TMessage);
begin
  inherited;
  case Message.Msg of
    WM_SETFOCUS, WM_KILLFOCUS : begin
      if FItemIndex <> -1 then Repaint;
    end;
  end;
end;

end.
