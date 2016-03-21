unit sDBListBox;
{$I sDefs.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls, sConst, acSBUtils, sCommonData, sDefaults;

type
  TsDBListBox = class(TDBListBox)
  private
    FBoundLabel: TsBoundLabel;
    FCommonData: TsCommonData;
    FDisabledKind: TsDisabledKind;
    procedure SetDisabledKind(const Value: TsDisabledKind);
  protected
    procedure WndProc (var Message: TMessage); override;
  public
    ListSW : TacScrollWnd;
    procedure AfterConstruction; override;
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;
  published
    property DisabledKind : TsDisabledKind read FDisabledKind write SetDisabledKind default DefDisabledKind;
    property SkinData : TsCommonData read FCommonData write FCommonData;
    property BoundLabel : TsBoundLabel read FBoundLabel write FBoundLabel;
  end;

implementation

uses sVclUtils, sStyleSimply, acntUtils, sMaskData, sMessages, sSkinProps, sGraphUtils, sAlphaGraph;

{ TsDBListBox }

procedure TsDBListBox.AfterConstruction;
begin
  inherited AfterConstruction;
  FCommonData.Loaded;
end;

constructor TsDBListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCommonData := TsCommonData.Create(Self, {$IFDEF DYNAMICCACHE} False {$ELSE} True {$ENDIF});
  FCommonData.COC := COC_TsEdit;
  ControlStyle := ControlStyle + [csReplicatable];
  if FCommonData.SkinSection = '' then FCommonData.SkinSection := s_Edit;
  FDisabledKind := DefDisabledKind;
  FBoundLabel := TsBoundLabel.Create(Self, FCommonData);
end;

destructor TsDBListBox.Destroy;
begin
  if ListSW <> nil then FreeAndNil(ListSW);
  FreeAndNil(FBoundLabel);
  if Assigned(FCommonData) then FreeAndNil(FCommonData);
  inherited Destroy;
end;

procedure TsDBListBox.Loaded;
begin
  inherited Loaded;
  FCommonData.Loaded;
end;

procedure TsDBListBox.SetDisabledKind(const Value: TsDisabledKind);
begin
  if FDisabledKind <> Value then begin
    FDisabledKind := Value;
    FCommonData.Invalidate;
  end;
end;

procedure TsDBListBox.WndProc(var Message: TMessage);
begin
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_CTRLHANDLED : begin Message.Result := 1; Exit end; // AlphaSkins supported
    AC_REMOVESKIN : if Message.LParam = LongInt(SkinData.SkinManager) then begin
      if ListSW <> nil then FreeAndNil(ListSW);
      CommonWndProc(Message, FCommonData);
      if not FCommonData.CustomColor then Color := clWindow;
      if not FCommonData.CustomFont then Font.Color := clWindowText;
      RecreateWnd;
      exit
    end;
    AC_REFRESH : if (Message.LParam = LongInt(SkinData.SkinManager)) then begin
      CommonWndProc(Message, FCommonData);
      if FCommonData.Skinned then begin
        if not FCommonData.CustomColor then Color := FCommonData.SkinManager.gd[FCommonData.SkinIndex].Color;
        if not FCommonData.CustomFont then Font.Color := FCommonData.SkinManager.gd[FCommonData.SkinIndex].FontColor[1];
      end;
      Repaint;
      RefreshEditScrolls(SkinData, ListSW);
      exit
    end;
    AC_ENDPARENTUPDATE : if FCommonData.Updating then begin
      FCommonData.Updating := False;
      Repaint;
      Exit;
    end;
    AC_SETNEWSKIN : if (Message.LParam = LongInt(SkinData.SkinManager)) then begin
      CommonWndProc(Message, FCommonData);
      exit
    end
  end;
  if not ControlIsReady(Self) or not FCommonData.Skinned(True) then inherited else begin
    case Message.Msg of
      CN_DRAWITEM : Exit;
      WM_SETFOCUS, CM_ENTER : if CanFocus then begin
        inherited;
        if Focused then begin
          FCommonData.FFocused := True;
          FCommonData.FMouseAbove := False;
          FCommonData.BGChanged := True;
        end;
      end;
      WM_KILLFOCUS, CM_EXIT: begin
        FCommonData.FFocused := False;
        FCommonData.FMouseAbove := False;
        FCommonData.BGChanged := True;
      end;
    end;
    CommonWndProc(Message, FCommonData);
    inherited;
    case Message.Msg of
      CM_SHOWINGCHANGED : RefreshEditScrolls(SkinData, ListSW);
      CM_VISIBLECHANGED, CM_ENABLEDCHANGED, WM_SETFONT : begin
        FCommonData.Invalidate;
      end;
    end;
  end;
  // Aligning of the bound label
  if Assigned(BoundLabel) and Assigned(BoundLabel.FtheLabel) then case Message.Msg of
    WM_SIZE, WM_WINDOWPOSCHANGED : BoundLabel.AlignLabel;
    CM_VISIBLECHANGED : begin BoundLabel.FtheLabel.Visible := Visible; BoundLabel.AlignLabel end;
    CM_ENABLEDCHANGED : begin BoundLabel.FtheLabel.Enabled := Enabled or not (dkBlended in DisabledKind); BoundLabel.AlignLabel end;
    CM_BIDIMODECHANGED : begin BoundLabel.FtheLabel.BiDiMode := BiDiMode; BoundLabel.AlignLabel end;
  end;
end;

end.
