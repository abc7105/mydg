unit sRichEdit;
{$I sDefs.inc}
{.$DEFINE LOGGED}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, sConst, sCommonData, sDefaults, acSBUtils
  {$IFDEF TNTUNICODE}, TntComCtrls {$ENDIF} ;

type
{$IFDEF TNTUNICODE}
  TsRichEdit = class(TTntRichEdit)
{$ELSE}
  TsRichEdit = class(TRichEdit)
{$ENDIF}
{$IFNDEF NOTFORHELP}
  private
    FCommonData: TsCtrlSkinData;
    FDisabledKind: TsDisabledKind;
    FBoundLabel: TsBoundLabel;
    procedure SetDisabledKind(const Value: TsDisabledKind);
    procedure WMPrint(var Message: TWMPaint); message WM_PRINT;
  public
    ListSW : TacScrollWnd;
    procedure AfterConstruction; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;
    procedure WndProc (var Message: TMessage); override;
  published
    property Text;
{$ENDIF} // NOTFORHELP
    property BoundLabel : TsBoundLabel read FBoundLabel write FBoundLabel;
    property SkinData : TsCtrlSkinData read FCommonData write FCommonData;
    property DisabledKind : TsDisabledKind read FDisabledKind write SetDisabledKind default DefDisabledKind;
  end;

implementation

uses sStyleSimply, sVCLUtils, sMessages, sMaskData, acntUtils, sGraphUtils, sAlphaGraph,
  sSkinProps, RichEdit {$IFDEF LOGGED}, sDebugMsgs{$ENDIF}, CommCtrl;

{ TsRichEdit }

procedure TsRichEdit.AfterConstruction;
begin
  inherited AfterConstruction;
  UpdateData(FCommonData);
end;

constructor TsRichEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCommonData := TsCtrlSkinData.Create(Self, {$IFDEF DYNAMICCACHE} False {$ELSE} True {$ENDIF});
  FCommonData.COC := COC_TsMemo;
  if FCommonData.SkinSection = '' then FCommonData.SkinSection := s_Edit;
  FDisabledKind := DefDisabledKind;
  FBoundLabel := TsBoundLabel.Create(Self, FCommonData);
  Perform(WM_USER + 53{EM_EXLIMITTEXT}, 0, $7FFFFFF0);
end;

destructor TsRichEdit.Destroy;
begin
  if ListSW <> nil then FreeAndNil(ListSW);
  FreeAndNil(FBoundLabel);
  if Assigned(FCommonData) then FreeAndNil(FCommonData);
  inherited Destroy;
end;

procedure TsRichEdit.Loaded;
begin
  inherited Loaded;
  FCommonData.Loaded;
end;

procedure TsRichEdit.SetDisabledKind(const Value: TsDisabledKind);
begin
  if FDisabledKind <> Value then begin
    FDisabledKind := Value;
    FCommonData.Invalidate;
  end;
end;

procedure TsRichEdit.WMPrint(var Message: TWMPaint);
var
  SavedDC : hdc;
  Range: TFormatRange;
begin
  if SkinData.Skinned then begin
    FillChar(Range, SizeOf(TFormatRange), 0);

    Range.rc.Left := 0;
    Range.rc.Top := 0;
    Range.rc.Right := (Width - 6) * 1440 div Screen.PixelsPerInch;
    Range.rc.Bottom := (Height - 6) * 1440 div Screen.PixelsPerInch;

    Range.hdc := Message.DC;
    Range.hdcTarget := Message.DC;
    Range.chrg.cpMax := -1;
    Range.chrg.cpMin := 0;

    SavedDC := SaveDC(Message.DC);
    try
      MoveWindowOrg(Message.DC, ListSW.cxLeftEdge, ListSW.cxLeftEdge);
      SendMessage(Handle, WM_ERASEBKGND, Longint(Message.DC), Message.Unused);
      MoveWindowOrg(Message.DC, 1, 1);

      IntersectClipRect(Message.DC, 0, 0,
        SkinData.FCacheBmp.Width - 2 * ListSW.cxLeftEdge - integer(ListSW.sBarVert.fScrollVisible) * GetScrollMetric(ListSW.sBarVert, SM_CXVERTSB),
        SkinData.FCacheBmp.Height - 2 * ListSW.cxLeftEdge - integer(ListSW.sBarHorz.fScrollVisible) * GetScrollMetric(ListSW.sBarHorz, SM_CYHORZSB));

      SendMessage(Handle, EM_FORMATRANGE, 1, Longint(@Range));
    finally
      RestoreDC(Message.DC, SavedDC);
    end;
    SendMessage(Handle, EM_FORMATRANGE, 0, 0);

    ControlState := ControlState + [csPaintCopy];

    SkinData.FUpdating := False;
    if SkinData.BGChanged then begin
      if SkinData = nil then Exit;
      PrepareCache(SkinData, Handle, False);
    end;
    if BorderStyle <> bsNone then begin
      UpdateCorners(SkinData, 0);
      BitBltBorder(TWMPaint(Message).DC, 0, 0, SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height, SkinData.FCacheBmp.Canvas.Handle, 0, 0, 2);
      Ac_NCPaint(ListSW, Handle, Longint(Message.DC), Message.Unused, -1, TWMPaint(Message).DC);
    end;
    Message.Result := 2;
  end;
end;

procedure TsRichEdit.WndProc(var Message: TMessage);
begin
{$IFDEF LOGGED}
  AddToLog(Message);
{$ENDIF}
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_CTRLHANDLED : begin Message.Result := 1; Exit end; // AlphaSkins supported
    AC_GETAPPLICATION : begin Message.Result := longint(Application); Exit end;
    AC_REMOVESKIN : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) and not (csDestroying in ComponentState) then begin
      if ListSW <> nil then FreeAndNil(ListSW);
      CommonWndProc(Message, FCommonData);
      if not FCommonData.CustomFont then begin
        DefAttributes.Color := Font.Color;
      end;
      RecreateWnd;
      exit
    end;
    AC_REFRESH : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) and Visible then begin
      CommonWndProc(Message, FCommonData);
      if FCommonData.Skinned then begin
        if not FCommonData.CustomFont and (DefAttributes.Color <> FCommonData.SkinManager.gd[FCommonData.SkinIndex].FontColor[1]) then begin
          DefAttributes.Color := FCommonData.SkinManager.gd[FCommonData.SkinIndex].FontColor[1];
        end;
      end;
      RefreshEditScrolls(SkinData, ListSW);
      SendMessage(Handle, WM_NCPaint, 0, 0);
      exit
    end;
    AC_SETNEWSKIN : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
      CommonWndProc(Message, FCommonData);
      exit
    end;
    AC_GETDISKIND : if Message.LParam <> 0 then begin
      PsDisabledKind(Message.LParam)^ := DisabledKind;
    end;
  end;
  if not ControlIsReady(Self) or not Assigned(FCommonData) or not FCommonData.Skinned then inherited else begin
    if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
      AC_ENDPARENTUPDATE : if FCommonData.Updating then begin
        FCommonData.Updating := False;
        Perform(WM_NCPAINT, 0, 0);
        Exit;
      end;
    end;
    CommonWndProc(Message, FCommonData);
    inherited;
    case Message.Msg of
      TB_SETANCHORHIGHLIGHT, WM_SIZE : SendMessage(Handle, WM_NCPAINT, 0, 0);
      CM_SHOWINGCHANGED : RefreshEditScrolls(SkinData, ListSW);
      CM_ENABLEDCHANGED : begin
        if not FCommonData.CustomColor then begin
          Color := FCommonData.SkinManager.gd[FCommonData.SkinIndex].Color;
          if not Enabled then begin
            Font.Color := AverageColor(FCommonData.SkinManager.gd[FCommonData.SkinIndex].FontColor[1], Color);
            DefAttributes.Color := Font.Color;
          end
          else begin
            Font.Color := FCommonData.SkinManager.gd[FCommonData.SkinIndex].FontColor[1];
            DefAttributes.Color := FCommonData.SkinManager.gd[FCommonData.SkinIndex].FontColor[1];
          end;
        end;
        FCommonData.Invalidate
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

end.
