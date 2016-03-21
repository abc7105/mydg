unit sBevel;
{$I sDefs.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs{$IFNDEF DELPHI5}, Types{$ENDIF},
  ExtCtrls, sCommonData;

type
  TsBevel = class(TBevel)
{$IFNDEF NOTFORHELP}
  private
    FCommonData: TsCommonData;
  protected
    StoredBevel : TBevelStyle;
    StoredShape : TBevelShape;
    procedure Paint; override;
    property SkinData : TsCommonData read FCommonData write FCommonData;
  public
    constructor Create(AOwner:TComponent); override;
    destructor Destroy; override;
    procedure AfterConstruction; override;
    procedure Invalidate; override;
    procedure CheckSkinSection;
    procedure Loaded; override;
    procedure WndProc (var Message: TMessage); override;
{$ENDIF}
  end;

implementation

uses sConst, sMessages, sVCLUtils, sGraphUtils, sSkinProps;

{ TsBevel }

procedure TsBevel.AfterConstruction;
begin
  inherited;
  CheckSkinSection;
  FCommonData.Loaded;
end;

procedure TsBevel.CheckSkinSection;
begin
  if Shape = bsFrame then FCommonData.SkinSection := s_GroupBox else begin
    if Style = bsLowered then FCommonData.SkinSection := s_PanelLow else FCommonData.SkinSection := s_Panel;
  end;
end;

constructor TsBevel.Create(AOwner: TComponent);
begin
  inherited;
  FCommonData := TsCommonData.Create(Self, True);
  FCommonData.COC := COC_TsSPEEDBUTTON;
end;

destructor TsBevel.Destroy;
begin
  if Assigned(FCommonData) then FreeAndNil(FCommonData);
  inherited;
end;

procedure TsBevel.Invalidate;
begin
  if StoredBevel <> Style then begin
    StoredBevel := Style;
    CheckSkinSection;
    FCommonData.BGChanged := True;
  end;
  if StoredShape <> Shape then begin
    StoredShape := Shape;
    CheckSkinSection;
    FCommonData.BGChanged := True;
  end;
  inherited;
end;

procedure TsBevel.Loaded;
begin
  inherited;
  CheckSkinSection;
  FCommonData.Loaded;
end;

procedure TsBevel.Paint;
const
  BorderWidth = 3;
var
  ParentBG : TacBGInfo;
begin
  if SkinData.Skinned then begin
    if SkinData.BGChanged then begin
      InitCacheBmp(SkinData);
      ParentBG.PleaseDraw := False;
      GetBGInfo(@ParentBG, PArent);
      PaintItem(SkinData.SkinIndex, SkinData.SkinSection, BGInfoToCI(@ParentBG), False, 0, Rect(0, 0, Width, Height), Point(Left, Top), SkinData.FCacheBmp, SkinData.SkinManager);
    end;
    case Shape of
      bsBox, bsFrame : begin
        BitBltBorder(Canvas.Handle, 0, 0, Width, Height, SkinData.FCacheBmp.Canvas.Handle, 0, 0, BorderWidth);
      end;
      bsTopLine : begin
        BitBlt(Canvas.Handle, BorderWidth, 0, Width - 2 * BorderWidth, BorderWidth, SkinData.FCacheBmp.Canvas.Handle, BorderWidth, 0, SRCCOPY);
      end;
      bsLeftLine : begin
        BitBlt(Canvas.Handle, 0, BorderWidth, BorderWidth, Height - 2 * BorderWidth, SkinData.FCacheBmp.Canvas.Handle, 0, BorderWidth, SRCCOPY);
      end;
      bsRightLine : begin
        BitBlt(Canvas.Handle, Width - BorderWidth, BorderWidth, BorderWidth, Height - 2 * BorderWidth, SkinData.FCacheBmp.Canvas.Handle, Width - BorderWidth, 0, SRCCOPY);
      end;
      bsBottomLine : begin
        BitBlt(Canvas.Handle, BorderWidth, Height - BorderWidth, Width - 2 * BorderWidth, BorderWidth, SkinData.FCacheBmp.Canvas.Handle, BorderWidth, Height - BorderWidth, SRCCOPY);
      end;
      bsSpacer : {if csDesigning in ComponentState then }begin
        inherited;
      end;
    end;
  end
  else inherited;
end;

procedure TsBevel.WndProc(var Message: TMessage);
begin
{$IFDEF LOGGED}
  AddToLog(Message);
{$ENDIF}
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_CTRLHANDLED : begin Message.Result := 1; Exit end;
    AC_GETAPPLICATION : begin Message.Result := longint(Application); Exit end;
    AC_SETNEWSKIN : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
      CommonWndProc(Message, FCommonData);
      Exit;
    end;
    AC_REMOVESKIN : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) and not (csDestroying in ComponentState) then begin
      CommonWndProc(Message, FCommonData);
      if Visible then Repaint;
    end;
    AC_REFRESH : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
      CommonWndProc(Message, FCommonData);
      if Visible then Repaint;
      exit
    end;
    AC_INVALIDATE : begin
      FCommonData.FUpdating := False;
      FCommonData.BGChanged := True;
      Repaint;
    end;
  end;
  if not ControlIsReady(Self) or not FCommonData.Skinned then inherited else begin
    case Message.Msg of
      WM_ERASEBKGND : Exit;
      WM_WINDOWPOSCHANGED, WM_SIZE : if Visible then FCommonData.BGChanged := True;
    end;
    CommonWndProc(Message, FCommonData);
    inherited;
  end;
end;

end.
