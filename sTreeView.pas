unit sTreeView;
{$I sDefs.inc}
{.$DEFINE LOGGED}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ComCtrls, sConst, sCommonData,
  sMessages, Commctrl{$IFNDEF DELPHI5}, Types{$ENDIF}, acSBUtils {$IFDEF TNTUNICODE}, TntComCtrls{$ENDIF};

type
{$IFDEF TNTUNICODE}
  TsTreeView = class(TTntTreeView)
{$ELSE}
  TsTreeView = class(TTreeView)
{$ENDIF}
{$IFNDEF NOTFORHELP}
  private
    FCommonData: TsCtrlSkinData;
    FBoundLabel: TsBoundLabel;
    FOldDrawItem: TTVAdvancedCustomDrawItemEvent;
  protected
    procedure WndProc (var Message: TMessage); override;
    procedure Loaded; override;
    procedure SkinCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
  public
    ListSW : TacScrollWnd;
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    procedure AfterConstruction; override;
  published
{$ENDIF} // NOTFORHELP
    property BoundLabel : TsBoundLabel read FBoundLabel write FBoundLabel;
    property SkinData : TsCtrlSkinData read FCommonData write FCommonData;
  end;

function GetNodeByText(const TreeView : TCustomTreeView; const s : acString) : TTreeNode;

implementation

uses sMaskData, sVclUtils, sStyleSimply, acntUtils, sGraphUtils, math, sAlphaGraph,
  sSkinProps{$IFDEF LOGGED}, sDebugMsgs{$ENDIF}, sSKinManager;

{ TsTreeView }

function GetNodeByText(const TreeView : TCustomTreeView; const s : acString) : TTreeNode;
var
  i, l : integer;
begin
  Result := nil;
  l := TTreeView(TreeView).Items.Count - 1;
  for i := 0 to l do if acSameText(TTreeView(TreeView).Items[i].Text, s) then begin
    Result := TTreeView(TreeView).Items[i];
    Break;
  end;
end;

procedure TsTreeView.AfterConstruction;
begin
  inherited;
  SkinData.Loaded;
end;

constructor TsTreeView.Create(AOwner: TComponent);
begin
  inherited;
  FCommonData := TsCtrlSkinData.Create(Self, True);
  FCommonData.COC := COC_TsTreeView;
  if FCommonData.SkinSection = '' then FCommonData.SkinSection := s_Edit;
  FBoundLabel := TsBoundLabel.Create(Self, FCommonData);
end;

destructor TsTreeView.Destroy;
begin
  if ListSW <> nil then FreeAndNil(ListSW);
  FreeAndNil(FBoundLabel);
  if Assigned(FCommonData) then FreeAndNil(FCommonData);
  inherited Destroy;
end;

procedure TsTreeView.Loaded;
begin
  inherited Loaded;
  FCommonData.Loaded;
  RefreshTreeScrolls(SkinData, ListSW);
  if not (csDesigning in ComponentState) then begin
    if Assigned(OnAdvancedCustomDrawItem) then FOldDrawItem := OnAdvancedCustomDrawItem;
    OnAdvancedCustomDrawItem := SkinCustomDrawItem;
  end;
end;

procedure TsTreeView.SkinCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
var
  Bmp : TBitmap;
  nRect, aRect : TRect;
  sNdx : integer;
  CI : TCacheInfo;
  DrawStyle : longint;
  DisabledKind : TsDisabledKind;
begin
  if (csDesigning in ComponentState) then Exit;
  DefaultDraw := True;
  if Assigned(FOldDrawItem) then FOldDrawItem(Sender, Node, State, Stage, PaintImages, DefaultDraw);
  if not DefaultDraw then Exit;

  if SkinData.Skinned and (Selected = Node) and (Stage in [cdPostPaint]) then begin
    nRect := Node.DisplayRect(True);
    Bmp := CreateBmp32(WidthOf(nRect), HeightOf(nRect));

    CI.Bmp := nil;
    CI.Ready := False;
    CI.FillColor := ColorToRGB(Color);

    sNdx := SkinData.SkinManager.GetSkinIndex(s_Selection);
    if sNdx < 0
      then FillDC(Bmp.Canvas.Handle, Classes.Rect(0, 0, Bmp.Width, Bmp.Height), SkinData.SkinManager.GetHighLightColor(cdsFocused in State))
      else PaintItem(sNdx, s_Selection, CI, True, integer(Focused), Classes.Rect(0, 0, Bmp.Width, Bmp.Height), Point(0, 0), Bmp, SkinData.SkinManager);

    Bmp.Canvas.Font.Assign(Canvas.Font);
    aRect := Classes.Rect(0, 0, Bmp.Width, Bmp.Height);
    InflateRect(aRect, -1, 0);
    aRect.Left := aRect.Left + 1;
    DrawStyle := DT_NOPREFIX or DT_EXPANDTABS or DT_SINGLELINE or DT_VCENTER or DT_NOCLIP;
    if sNdx = -1 then begin
      if Selected = Node then Bmp.Canvas.Font.Color := SkinData.SkinManager.GetHighLightFontColor(cdsFocused in State) else Bmp.Canvas.Font.Color := Font.Color;
      Bmp.Canvas.Brush.Style := bsClear;
      AcDrawText(Bmp.Canvas.Handle, Node.Text, aRect, DrawStyle);
    end
    else begin
{$IFDEF TNTUNICODE}
      acWriteTextEx(Bmp.Canvas, PacChar(TTntTreeNode(Node).Text), True, aRect, DrawStyle, sNdx, Focused, SkinData.SkinManager);
{$ELSE}
      acWriteTextEx(Bmp.Canvas, PacChar(Node.Text), True, aRect, DrawStyle, sNdx, Focused, SkinData.SkinManager);
{$ENDIF}
    end;
    if (Focused) and (sNdx < 0) then begin
      InflateRect(aRect, 1, 0);
      aRect.Left := 0;
      DrawFocusRect(Bmp.Canvas.Handle, aRect);
    end;

    if not Enabled then begin
      DisabledKind := [dkBlended];
      BmpDisabledKind(Bmp, DisabledKind, Parent, CI, Point(nRect.Left + 3, nRect.Top + 3));
    end;

    BitBlt(Sender.Canvas.Handle, nRect.Left, nRect.Top, Bmp.Width, Bmp.Height, Bmp.Canvas.Handle, 0, 0, SRCCOPY);
    FreeAndNil(Bmp);
    DefaultDraw := False;
  end;
end;

procedure TsTreeView.WndProc(var Message: TMessage);
begin
{$IFDEF LOGGED}
  AddToLog(Message);
{$ENDIF}
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_CTRLHANDLED : begin Message.Result := 1; Exit end; // AlphaSkins supported
    AC_GETAPPLICATION : begin Message.Result := longint(Application); Exit end;
    AC_REMOVESKIN : if LongWord(Message.LParam) = LongWord(SkinData.SkinManager) then begin
      UninitializeACScroll(Handle, True, False, ListSW);
//      if ListSW <> nil then FreeAndNil(ListSW); v7.09
      CommonWndProc(Message, FCommonData);
//      RecreateWnd;
      if not FCommonData.CustomColor then Color := clWindow;
      if not FCommonData.CustomFont then Font.Color := clWindowText;
      exit
    end;
    AC_SETNEWSKIN : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
      CommonWndProc(Message, FCommonData);
      exit
    end;
    AC_REFRESH : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
//      CommonWndProc(Message, FCommonData);
      if FCommonData.Skinned then begin
        if not FCommonData.CustomColor then
{$IFDEF DELPHI5}
          TreeView_SetBkColor(Handle, ColorToRGB(FCommonData.SkinManager.gd[FCommonData.SkinIndex].Color));
{$ELSE}
          Color := FCommonData.SkinManager.gd[FCommonData.SkinIndex].Color;
{$ENDIF}
        if not FCommonData.CustomFont then Font.Color := FCommonData.SkinManager.gd[FCommonData.SkinIndex].FontColor[1];
      end;
      RefreshTreeScrolls(SkinData, ListSW);
      exit
    end;
    AC_ENDPARENTUPDATE : if FCommonData.Updating then begin
      FCommonData.Updating := False;
      Perform(WM_NCPAINT, 0, 0);
      Exit
    end;
  end;
  if not ControlIsReady(Self) or not FCommonData.Skinned then inherited else begin
    case Message.Msg of
{      WM_ERASEBKGND : begin
        Message.Result := 1;
        Exit;
      end;}
      CM_VISIBLECHANGED, CM_ENABLEDCHANGED, WM_MOVE : begin
        FCommonData.BGChanged := True;
      end;
      WM_SETREDRAW : FCommonData.FUpdating := Message.WParam <> 1;
{
      WM_VSCROLL, WM_HSCROLL : begin
        SendMessage(Handle, WM_SETREDRAW, 0, 0);
        SkinData.FUpdating := True;
      end;
}
    end;
    CommonWndProc(Message, FCommonData);
    inherited;
    case Message.Msg of
      CM_SHOWINGCHANGED : RefreshTreeScrolls(SkinData, ListSW);
{
      WM_VSCROLL, WM_HSCROLL : if FCommonData.Skinned then begin
        SendMessage(Handle, WM_SETREDRAW, 1, 0);
        SkinData.FUpdating := False;
//        RedrawWindow(Handle, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW);
      end;
      WM_ENABLE : if FCommonData.Skinned and Visible and not (csLoading in ComponentState) then begin
        FCommonData.BGChanged := True;
        RedrawWindow(Handle, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW);// or RDW_ERASE);
      end;
}      
    end;
  end;
  // Aligning of the bound label
  if Assigned(BoundLabel) and Assigned(BoundLabel.FtheLabel) then case Message.Msg of
    WM_SIZE, WM_WINDOWPOSCHANGED : begin BoundLabel.AlignLabel end;
    CM_VISIBLECHANGED : begin BoundLabel.FtheLabel.Visible := Visible; BoundLabel.AlignLabel end;
//    CM_ENABLEDCHANGED : begin BoundLabel.FtheLabel.Enabled := Enabled or not (dkBlended in DisabledKind); BoundLabel.AlignLabel end;
    CM_BIDIMODECHANGED : begin BoundLabel.FtheLabel.BiDiMode := BiDiMode; BoundLabel.AlignLabel end;
  end;
end;

end.
