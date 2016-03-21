unit sVclUtils;
{$I sDefs.inc}
{.$DEFINE LOGGED}

interface

uses
  Classes, Controls, SysUtils, StdCtrls, windows, Dialogs, Graphics, Forms, Messages, extctrls, sSkinProvider, acSBUtils,
  comctrls, sConst, Menus, inifiles, registry, acntUtils, sCommonData, acDials, acThdTimer,
{$IFNDEF ALITE}
  sEdit, sMemo, sComboBox, sToolEdit, sCurrEdit, sDateUtils,
  sCustomComboEdit, sRadioButton, sMonthCalendar,
{$ENDIF}
  {$IFDEF USEDB}db, dbgrids, dbCtrls, {$ENDIF}
  sCheckBox, sGraphUtils, buttons{$IFDEF LOGGED}, sDebugMsgs{$ENDIF};

const
  AlignToInt: array[TAlignment] of Longint = (DT_LEFT, DT_RIGHT, DT_CENTER);

function acMousePos : TPoint;
function LeftToRight(Control : TControl; NormalAlignment : boolean = True) : boolean;
procedure AddToAdapter(Frame : TWinControl);
procedure BroadCastMsg(Ctrl : hwnd; Message : TMessage);

procedure SkinPaintTo(const Bmp : TBitmap; const Ctrl : TControl; Left : integer = 0; Top : integer = 0; SkinProvider : TComponent = nil);
procedure PrepareForAnimation(Ctrl : TWinControl);

procedure AnimShowDlg(ListSW : TacDialogWnd; wTime : word = 0; MaxTransparency : integer = MaxByte; AnimType : TacAnimType = atAero);
procedure AnimShowForm(sp : TsSkinProvider; wTime : word = 0; MaxTransparency : integer = MaxByte; AnimType : TacAnimType = atAero);
procedure AnimShowControl(Ctrl : TWinControl; wTime : word = 0; MaxTransparency : integer = MaxByte; AnimType : TacAnimType = atFading);

procedure AnimHideForm(SkinProvider : TObject);
procedure PrindDlgClient(ListSW : TacDialogWnd; acDstBmp : TBitmap; CopyScreen : boolean = False);
procedure AnimHideDlg(ListSW : TacDialogWnd);

procedure SetParentUpdated(wc : TWinControl); overload;
procedure SetParentUpdated(pHwnd : hwnd); overload;
function GetControlColor(Control : TControl) : TColor; overload;
function GetControlColor(Handle : THandle) : TColor; overload;
function AllEditSelected(Ctrl : TCustomEdit): Boolean;

procedure PaintControls(DC: HDC; OwnerControl : TWinControl; ChangeCache : boolean; Offset : TPoint; AHandle : THandle = 0; CheckVisible : boolean = True);

function SendAMessage(Handle : hwnd; Cmd : Integer; LParam : longint = 0) : longint; overload; // may be removed later
function SendAMessage(Control : TControl; Cmd : Integer; LParam : longword = 0) : longint; overload;
procedure SetBoolMsg(Handle : hwnd; Cmd : Cardinal; Value : boolean);
function GetBoolMsg(Control : TWinControl; Cmd : Cardinal) : boolean; overload;
function GetBoolMsg(CtrlHandle : hwnd; Cmd : Cardinal) : boolean; overload;
procedure RepaintsGraphicControls(WinControl : TWinControl); {$IFDEF WARN_DEPRECATED} deprecated; {$ENDIF}
function ControlIsReady(Control : TControl) : boolean;
function GetOwnerForm(Component: TComponent) : TCustomForm;
function GetOwnerFrame(Component: TComponent) : TCustomFrame;
procedure SetPanelFocus(Panel : TWinControl); {$IFDEF WARN_DEPRECATED} deprecated; {$ENDIF}
procedure SetControlsEnabled(Parent:TWinControl; Value: boolean);
function CheckPanelFilled(Panel:TCustomPanel):boolean; {$IFDEF WARN_DEPRECATED} deprecated; {$ENDIF}
function GetStringFlags(Control: TControl; al: TAlignment): longint;
procedure RepaintsControls(Owner: TWinControl; BGChanged : boolean);
function GetControlByName(ParentControl : TWinControl; const CtrlName : string) : TControl; {$IFDEF WARN_DEPRECATED} deprecated; {$ENDIF}
procedure AlphaBroadCast(Control : TWinControl; var Message); overload;
procedure AlphaBroadCast(Handle : hwnd; var Message); overload;
procedure SendToProvider(Form : TCustomform; var Message);
function GetCtrlRange(Ctl : TWinControl; nBar : integer) : integer;
function ACClientRect(Handle : hwnd): TRect;
function GetAlignShift(Ctrl : TWinControl; Align : TAlign; GraphCtrlsToo : boolean = False) : integer;
function GetParentFormHandle(const CtrlHandle: hwnd): hwnd;
procedure TrySetSkinSection(Control : TControl; const SectionName : string); 

type
  TOutputWindow = class(TCustomControl)
  private
    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd); message WM_ERASEBKGND;
    procedure WMNCPaint(var Message: TWmEraseBkgnd); message WM_NCPAINT;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AOwner: TComponent); override;
    property Canvas;
  end;

  TacHideTimer = class(TacThreadedTimer)
  public
    Dlg : TacDialogWnd;
    sp : TsSkinProvider;

    DC : hdc;
    Form : TForm;
    FBmpSize: TSize;
    FBmpTopLeft: TPoint;
    FBlend: TBlendFunction;
    dx, dy : real;
    l, t, r, b : real;
    StartBlendValue, i : integer;
    StepCount : integer;
    AnimType : TacAnimType;
    DelayValue : integer;

    Trans : real;
    p : real;
    SrcBmp : TBitmap;
    DstBmp : TBitmap;
    procedure Anim_Init;
    procedure Anim_DoNext;
    procedure Anim_GoToNext;
    procedure OnTimerProc(Sender: TObject);
    destructor Destroy; override;
  end;

var
  ow : TOutPutwindow = nil;
  InAnimationProcess : boolean = False;
  acGraphPainting : boolean = False;
  uxthemeLib : Cardinal = 0;
  Ac_SetWindowTheme : function(hwnd: HWND; pszSubAppName: LPCWSTR; pszSubIdList: LPCWSTR): HRESULT; stdcall;
  acHideTimer : TacHideTimer = nil;

implementation

uses
  {$IFNDEF ALITE} sStatusBar, sPageControl, sSpinEdit, sGroupBox, sGauge, sScrollBox, sComboBoxes, sSplitter,{$ENDIF} sPanel, sStyleSimply,
  sMessages, sMaskData, math, ShellAPI, sSkinManager, sThirdParty, sAlphaGraph, acGlow;

function acMousePos : TPoint;
begin
  GetCursorPos(Result);
end;

function LeftToRight(Control : TControl; NormalAlignment : boolean = True) : boolean;
begin
  if NormalAlignment
    then Result := (Control.BidiMode = bdLeftToRight) or not SysLocale.MiddleEast
    else Result := (Control.BidiMode <> bdLeftToRight) and SysLocale.MiddleEast;
end;

procedure AddToAdapter(Frame : TWinControl);
var
  c : TWinControl;
begin
  if (csDesigning in Frame.ComponentState) or (csLoading in Frame.ComponentState) then Exit;
  c := GetParentForm(Frame);
  if c <> nil then SendMessage(c.Handle, SM_ALPHACMD, MakeWParam(0, AC_CONTROLLOADED), longword(Frame));
end;

procedure BroadCastMsg(Ctrl : hwnd; Message : TMessage);
var
  hCtrl : THandle;
begin
  hCtrl := GetTopWindow(Ctrl);
  while hCtrl <> 0 do begin
    if (GetWindowLong(hCtrl, GWL_STYLE) and WS_CHILD) = WS_CHILD then SendMessage(hCtrl, Message.Msg, Message.WParam, Message.LParam);
    hCtrl := GetNextWindow(hCtrl, GW_HWNDNEXT);
  end;
end;

procedure SkinPaintTo(const Bmp : TBitmap; const Ctrl : TControl; Left : integer = 0; Top : integer = 0; SkinProvider : TComponent = nil);
var
  I : Integer;
  SaveIndex : hdc;
  cR : TRect;
  DC : hdc;
  ParentBG : TacBGInfo;
begin
  if (SkinProvider = nil) and (Ctrl.Parent <> nil) and not Ctrl.Visible then begin
    ParentBG.DrawDC := 0;
    ParentBG.PleaseDraw := False;
    GetBGInfo(@ParentBG, Ctrl.Parent);
    if ParentBG.BgType = btCache
      then BitBlt(Bmp.Canvas.Handle, Left, Top, Ctrl.Width, Ctrl.Height, ParentBG.Bmp.Canvas.Handle, ParentBG.Offset.X + Ctrl.Left, ParentBG.Offset.Y + Ctrl.Top, SRCCOPY)
      else FillDC(Bmp.Canvas.Handle, Rect(Left, Top, Ctrl.Width, Ctrl.Height), ParentBG.Color);
  end
  else begin
    DC := Bmp.Canvas.Handle;
    if (SkinProvider = nil) or (TsSkinProvider(SkinProvider).BorderForm = nil) then begin
      GetWindowRect(TWinControl(Ctrl).Handle, cR);
      IntersectClipRect(DC, 0, 0, Ctrl.Width, Ctrl.Height);
    end;
    if Ctrl is TWinControl then begin
      if (Ctrl is TForm) and (TForm(Ctrl).FormStyle = fsMDIForm) then for I := 0 to TForm(Ctrl).MDIChildCount - 1 do begin
        SaveIndex := SaveDC(DC);
        MoveWindowOrg(DC, TForm(Ctrl).MDIChildren[i].Left, TForm(Ctrl).MDIChildren[i].Top);
        SkinPaintTo(Bmp, TForm(Ctrl).MDIChildren[i], TForm(Ctrl).MDIChildren[i].Left, TForm(Ctrl).MDIChildren[i].Top);
        RestoreDC(DC, SaveIndex);
      end;

      if (Ctrl is TTabsheet) and (TTabSheet(Ctrl).BorderWidth <> 0) then MoveWindowOrg(DC, TTabSheet(Ctrl).BorderWidth, TTabSheet(Ctrl).BorderWidth);

      if GetBoolMsg(TWinControl(Ctrl), AC_CTRLHANDLED) then begin
        SendAMessage(TWinControl(Ctrl).Handle, AC_PRINTING, Longint(DC));
        SendMessage(TWinControl(Ctrl).Handle, WM_PRINT, longint(DC), 0);
        SendAMessage(TWinControl(Ctrl).Handle, AC_PRINTING, 0);
      end
      else TWinControl(Ctrl).PaintTo(DC, 0, 0);
      for I := 0 to TWinControl(Ctrl).ControlCount - 1 do if (TWinControl(Ctrl).Controls[I] is TWinControl) and TWinControl(Ctrl).Controls[I].Visible then begin
        SaveIndex := SaveDC(DC);
        if not (TWinControl(Ctrl).Controls[I] is TCustomForm) or (TWinControl(Ctrl).Controls[I].Parent <> nil) then begin
          MoveWindowOrg(DC, TWinControl(Ctrl).Controls[I].Left, TWinControl(Ctrl).Controls[I].Top);
        end;
        SkinPaintTo(Bmp, TWinControl(Ctrl).Controls[I], TWinControl(Ctrl).Controls[I].Left, TWinControl(Ctrl).Controls[I].Top);
        RestoreDC(DC, SaveIndex);
      end;
      if (SkinProvider <> nil) and (TsSkinProvider(SkinProvider).BorderForm <> nil) then begin // Remove it later !!
        cR := Ctrl.ClientRect;
        OffsetRect(cR, TsSkinProvider(SkinProvider).OffsetX, TsSkinProvider(SkinProvider).OffsetY);
        if cR.Bottom >= Bmp.Height then cR.Bottom := Bmp.Height - 1;
        FillAlphaRect(Bmp, cR, MaxByte); // Fill AlphaChannell in client area
      end;
      if (Ctrl is TTabsheet) and (TTabSheet(Ctrl).BorderWidth <> 0) then MoveWindowOrg(DC, -TTabSheet(Ctrl).BorderWidth, -TTabSheet(Ctrl).BorderWidth);
    end
    else begin
      SendAMessage(Ctrl, AC_PRINTING, Longint(DC));
      Ctrl.Perform(WM_PRINT, longint(DC), 0);
      SendAMessage(Ctrl, AC_PRINTING, 0);
    end;
  end;
end;

type
  TacWinControl = class(TWinControl);

procedure SetChildOrderAfter(Child: TWinControl; Control: TControl);
var
  i: Integer;
begin
  for i := 0 to Child.Parent.ControlCount do if Child.Parent.Controls[i] = Control then begin
    TacWinControl(Child.Parent).SetChildOrder(Child, i + 1);
    break;
  end;
end;

type
  TAccessProvider = class(TsSkinProvider);

const
  acwDivider = 8;

procedure AnimShowForm(sp : TsSkinProvider; wTime : word = 0; MaxTransparency : integer = MaxByte; AnimType : TacAnimType = atAero);
var
  DC : hdc;
  acDstBmp : TBitmap;
  i, StepCount : integer;
  h : hwnd;
  fR : TRect;
  cy, cx : integer;
  dx, dy, l, t, r, b, trans, p : real;
  Flags : Longint;
  FBmpSize: TSize;
  FBmpTopLeft: TPoint;
  FBlend: TBlendFunction;
  AnimForm : TForm;
  AnimBmp : TBitmap;
  procedure Anim_Init;
  begin
    trans := 0;
    p := MaxTransparency / StepCount;
    case AnimType of
      atAero : begin
        dx := acDstBmp.Width / (StepCount * acwDivider);
        dy := acDstBmp.Height / (StepCount * acwDivider);
        l := acDstBmp.Width / acwDivider;
        t := acDstBmp.Height / acwDivider;
        r := acDstBmp.Width - l;
        b := acDstBmp.Height - t;
      end
      else begin
        dx := 0; dy := 0; l := 0; t := 0; r := 0; b := 0;
      end;
    end
  end;
  procedure Anim_DoNext;
  begin
    trans := min(trans + p, MaxTransparency);
    FBlend.SourceConstantAlpha := Round(trans);
    case AnimType of
      atAero : begin
        if (l < 0) or (t < 0)
          then BitBlt(AnimBmp.Canvas.Handle, 0, 0, acDstBmp.Width, acDstBmp.Height, acDstBmp.Canvas.Handle, 0, 0, SRCCOPY)
          else StretchBlt(AnimBmp.Canvas.Handle, Round(l), Round(t), Round(r - l), Round(b - t), acDstBmp.Canvas.Handle, 0, 0, acDstBmp.Width, acDstBmp.Height, SRCCOPY);
      end
      else if l = 0 then begin
        BitBlt(AnimBmp.Canvas.Handle, 0, 0, acDstBmp.Width, acDstBmp.Height, acDstBmp.Canvas.Handle, 0, 0, SRCCOPY);
        l := 1;
      end
    end
  end;
  procedure Anim_GoToNext;
  begin
    case AnimType of
      atAero : begin
        l := l - dx;
        t := t - dy;
        r := r + dx;
        b := b + dy;
      end
    end
  end;
begin
  if (sp.SkinData = nil) then Exit;
  InAnimationProcess := True;

  if sp.BorderForm <> nil then begin
    AnimForm := sp.BorderForm.AForm;
    SetWindowRgn(AnimForm.Handle, 0, False);
    sp.BorderForm.PaintAll;
  end
  else begin
    TAccessProvider(sp).PaintAll;
    AnimForm := TForm.Create(Application);
    AnimForm.Tag := ExceptTag;
    AnimForm.BorderStyle := bsNone;
    SetWindowLong(AnimForm.Handle, GWL_EXSTYLE, GetWindowLong(AnimForm.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW or WS_EX_NOACTIVATE);
  end;
  
  if (sp.SkinData.FCacheBmp = nil) then Exit;

  acDstBmp := CreateBmp32(sp.SkinData.FCacheBmp.Width, sp.SkinData.FCacheBmp.Height);

  acDstBmp.Canvas.Lock;
  SkinPaintTo(acDstBmp, sp.Form, 0, 0, sp);

  if sp.BorderForm = nil then FillAlphaRect(acDstBmp, Rect(0, 0, acDstBmp.Width, acDstBmp.Height), MaxByte);
  if acDstBmp = nil then Exit;
  acDstBmp.Canvas.UnLock;

  FBmpSize.cx := acDstBmp.Width;
  FBmpSize.cy := acDstBmp.Height;

  StepCount := wTime div acTimerInterval;

  Flags := SWP_NOACTIVATE or SWP_NOREDRAW or SWP_NOCOPYBITS or SWP_NOOWNERZORDER or SWP_NOSENDCHANGING;

  FBmpTopLeft := Point(0, 0);
  if StepCount > 0 then FBlend.SourceConstantAlpha := 0 else FBlend.SourceConstantAlpha := MaxTransparency;
  FBlend.BlendOp := AC_SRC_OVER;
  FBlend.BlendFlags := 0;
  FBlend.AlphaFormat := AC_SRC_ALPHA;

  cy := 0;
  cx := 0;
  if sp.BorderForm <> nil then begin
    fr := Rect(sp.Form.Left, sp.Form.Top, sp.Form.Left + sp.Form.Width, sp.Form.Top + sp.Form.Height);
    TAccessProvider(sp).FSysExHeight := IsZoomed(sp.Form.Handle) and (sp.CaptionHeight < SysCaptHeight(sp.Form) + 4);

    if TAccessProvider(sp).FSysExHeight
      then cy := sp.ShadowSize.Top + DiffTitle(sp.BorderForm) + SysBorderWidth(sp.Form.Handle, sp.BorderForm, False) //  4
      else cy := sp.BorderForm.OffsetY;

    cx := SkinBorderWidth(sp.BorderForm) - SysBorderWidth(sp.Form.Handle, sp.BorderForm, False) + sp.ShadowSize.Left;
  end
  else GetWindowRect(sp.Form.Handle, fR);

  AnimForm.SetBounds(fR.Left - cx, fR.Top - cy, acDstBmp.Width, acDstBmp.Height);

  if GetWindowLong(sp.Form.Handle, GWL_EXSTYLE) and WS_EX_TOPMOST = WS_EX_TOPMOST then begin
    AnimForm.FormStyle := fsStayOnTop;
    h := HWND_TOPMOST
  end
  else begin
    h := GetWindow(sp.Form.Handle, GW_HWNDPREV);
  end;

  DC := GetDC(0);
  SetWindowLong(AnimForm.Handle, GWL_EXSTYLE, GetWindowLong(AnimForm.Handle, GWL_EXSTYLE) or WS_EX_LAYERED or WS_EX_NOACTIVATE);
  UpdateLayeredWindow(AnimForm.Handle, DC, nil, @FBmpSize, acDstBmp.Canvas.Handle, @FBmpTopLeft, clNone, @FBlend, ULW_ALPHA);
  ShowWindow(AnimForm.Handle, SW_SHOWNOACTIVATE);

  SetWindowPos(AnimForm.Handle, h, AnimForm.Left, AnimForm.Top, FBmpSize.cx, FBmpSize.cy, Flags or SWP_NOREDRAW);
  AnimBmp := CreateBmp32(FBmpSize.cx, FBmpSize.cy);
  FillDC(AnimBmp.Canvas.Handle, Rect(0, 0, AnimBmp.Width, AnimBmp.Height), 0);
  SetStretchBltMode(AnimBmp.Canvas.Handle, COLORONCOLOR);

  if StepCount > 0 then begin
    Anim_Init;
    i := 0;
    while i <= StepCount do begin
      Anim_DoNext;
      UpdateLayeredWindow(AnimForm.Handle, DC, nil, @FBmpSize, AnimBmp.Canvas.Handle, @FBmpTopLeft, clNone, @FBlend, ULW_ALPHA);
      Anim_GoToNext;
      inc(i);
      if StepCount > 0 then Sleep(acTimerInterval);
    end;
    FBlend.SourceConstantAlpha := MaxTransparency;
  end;
  SetWindowPos(AnimForm.Handle, 0, fR.Left - cx, fr.Top - cy, FBmpSize.cx, FBmpSize.cy, Flags or SWP_NOZORDER);
  UpdateLayeredWindow(AnimForm.Handle, DC, nil, @FBmpSize, acDstBmp.Canvas.Handle, @FBmpTopLeft, clNone, @FBlend, ULW_ALPHA);

  FreeAndNil(AnimBmp);
  ReleaseDC(0, DC);
  if (sp <> nil) then begin
    sp.FInAnimation := False;
{$IFDEF DELPHI7UP}
    if sp.Form.AlphaBlend then sp.Form.AlphaBlendValue := MaxTransparency;
{$ENDIF}
  end;

  SetWindowPos(sp.Form.Handle, AnimForm.Handle, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOREDRAW or SWP_NOACTIVATE or SWP_NOSENDCHANGING or SWP_NOOWNERZORDER);
  SendMessage(sp.Form.Handle, WM_SETREDRAW, 1, 0); // Vista
  InAnimationProcess := False;
  RedrawWindow(sp.Form.Handle, nil, 0, RDW_FRAME or RDW_ALLCHILDREN or RDW_INVALIDATE or RDW_ERASE or RDW_UPDATENOW or RDW_ERASENOW);
  FreeAndNil(acDstBmp);
  if AeroIsEnabled then Sleep(acTimerInterval); // Blinking in Aero removing
  SetWindowPos(AnimForm.Handle, sp.Form.Handle, fR.Left - cx, fr.Top - cy, FBmpSize.cx, FBmpSize.cy, Flags or SWP_NOSIZE or SWP_NOMOVE);
  if sp.BorderForm = nil then FreeAndNil(AnimForm) else SetWindowRgn(AnimForm.Handle, sp.BorderForm.MakeRgn, False);
  if Assigned(sp.OnAfterAnimation) then sp.OnAfterAnimation(aeShowing);
end;

procedure HideAnimForm(Form : TForm; SrcBmp : TBitmap; ATime : integer; StartBlendValue : integer; AnimType : TacAnimType);
begin
  if (acHideTimer <> nil) and (acHideTimer.Form <> nil) then FreeAndNil(acHideTimer.Form);
  if ATime div acTimerInterval = 0 then begin
    if Form <> nil then Form.Free;
    if SrcBmp <> nil then SrcBmp.Free;
    Exit;
  end;
  if acHideTimer = nil then acHideTimer := TacHideTimer.Create(Application);
  acHideTimer.i := 0;
  if (acHideTimer.SrcBmp <> nil) and (acHideTimer.SrcBmp <> SrcBmp) then FreeAndNil(acHideTimer.SrcBmp);
  acHideTimer.SrcBmp := SrcBmp;
  acHideTimer.StartBlendValue := StartBlendValue;
  acHideTimer.Form := Form;
  acHideTimer.AnimType := AnimType;
  acHideTimer.Interval := acTimerInterval;

  acHideTimer.DelayValue := acTimerInterval;

  acHideTimer.StepCount := ATime div acTimerInterval;

  acHideTimer.FBmpSize.cx := acHideTimer.SrcBmp.Width;
  acHideTimer.FBmpSize.cy := acHideTimer.SrcBmp.Height;
  acHideTimer.FBmpTopLeft := Point(0, 0);

  acHideTimer.FBlend.SourceConstantAlpha := StartBlendValue;// div 2;
  acHideTimer.FBlend.BlendOp := AC_SRC_OVER;
  acHideTimer.FBlend.BlendFlags := 0;
  acHideTimer.FBlend.AlphaFormat := AC_SRC_ALPHA;

  acHideTimer.DC := GetDC(0);

  SetWindowLong(Form.Handle, GWL_EXSTYLE, GetWindowLong(Form.Handle, GWL_EXSTYLE) or WS_EX_LAYERED or WS_EX_NOACTIVATE);

  UpdateLayeredWindow(Form.Handle, acHideTimer.DC, nil, @acHideTimer.FBmpSize, SrcBmp.Canvas.Handle, @acHideTimer.FBmpTopLeft, clNone, @acHideTimer.FBlend, ULW_ALPHA);
  ShowWindow(Form.Handle, SW_SHOWNOACTIVATE);

  SetWindowPos(Form.Handle, HWND_TOPMOST, Form.Left, Form.Top, acHideTimer.FBmpSize.cx, acHideTimer.FBmpSize.cy, SWP_NOACTIVATE or SWP_NOREDRAW or SWP_NOCOPYBITS or SWP_NOOWNERZORDER or SWP_NOREDRAW);
  if acHideTimer.DstBmp <> nil then FreeAndNil(acHideTimer.DstBmp);
  acHideTimer.DstBmp := CreateBmp32(acHideTimer.FBmpSize.cx, acHideTimer.FBmpSize.cy);

  ReleaseDC(0, acHideTimer.DC);

  acHideTimer.Anim_Init;
  if not Application.Terminated then begin
    acHideTimer.OnTimer := acHideTimer.OnTimerProc;
    acHideTimer.i := 0;
    acHideTimer.OnTimerProc(acHideTimer);
    acHideTimer.Enabled := True;
  end
  else begin
    while acHideTimer.i <= acHideTimer.StepCount do begin
      acHideTimer.OnTimerProc(acHideTimer);
      Sleep(acTimerInterval);
    end;
  end;
end;

procedure AnimHideForm(SkinProvider : TObject);
var
  sp : TAccessProvider;
  AnimForm : TForm;
  acDstBmp : TBitmap;
begin
  ClearGlows(True);
  sp := TAccessProvider(SkinProvider);
  if (sp = nil) or (sp.Form.FormStyle = fsMDIChild) {or not sp.SkinData.Skinned} then Exit;
  if sp.SkinData.FCacheBmp = nil then Exit;
  

  InAnimationProcess := True;
  if sp.FormState and FS_ANIMCLOSING <> FS_ANIMCLOSING then sp.PaintAll;
  if sp.BorderForm <> nil then begin
    if sp.BorderForm.AForm = nil then sp.BorderForm.CreateNewForm;
    AnimForm := sp.BorderForm.AForm;
    if sp.BorderForm.ParentHandle <> 0 then SetWindowLong(sp.BorderForm.AForm.Handle, GWL_HWNDPARENT, LongInt(sp.BorderForm.ParentHandle));
    AnimForm.WindowProc := sp.BorderForm.OldBorderProc;
    acDstBmp := CreateBmp32(sp.SkinData.FCacheBmp.Width, sp.SkinData.FCacheBmp.Height);
    BitBlt(acDstBmp.Canvas.Handle, 0, 0, sp.SkinData.FCacheBmp.Width, sp.SkinData.FCacheBmp.Height, sp.SkinData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
    sp.BorderForm.AForm := nil;
  end
  else begin
    if sp.CoverForm <> nil then begin
      AnimForm := sp.CoverForm;
      sp.CoverForm := nil;
    end
    else AnimForm := MakeCoverForm(sp.Form.Handle);
    acDstBmp := CreateBmp32(sp.SkinData.FCacheBmp.Width, sp.SkinData.FCacheBmp.Height);
    BitBlt(acDstBmp.Canvas.Handle, 0, 0, sp.SkinData.FCacheBmp.Width, sp.SkinData.FCacheBmp.Height, sp.SkinData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
    FillAlphaRect(acDstBmp, Rect(0, 0, acDstBmp.Width, acDstBmp.Height), MaxByte);
  end;
  ////////////////////////////////
  HideAnimForm(AnimForm, acDstBmp, sp.SkinData.SkinManager.AnimEffects.FormHide.Time, MaxByte, sp.SkinData.SkinManager.AnimEffects.FormHide.Mode);
  if (sp.BorderForm <> nil) then begin
    if Application.Terminated
      then FreeAndNil(sp.BorderForm)
      else if (sp.BorderForm.AForm <> nil) then FreeAndNil(sp.BorderForm.AForm);
  end;
  ////////////////////////////////
  InAnimationProcess := False;
end;

procedure PrindDlgClient(ListSW : TacDialogWnd; acDstBmp : TBitmap; CopyScreen : boolean = False);

var
  SavedDC, DC : hdc;
  R, cR, fR : TRect;
begin
  if CopyScreen then begin
    DC := GetWindowDC(ListSW.CtrlHandle);
    SavedDC := SaveDC(DC);
    try
      R := ACClientRect(ListSW.CtrlHandle);
      BitBlt(acDstBmp.Canvas.Handle, ListSW.OffsetX{ + R.Left}, ListSW.OffsetY{ + R.Top}, WidthOf(R), HeightOf(R), DC, R.Left, R.Top, SRCCOPY);
      FillAlphaRect(acDstBmp, Rect(ListSW.OffsetX, ListSW.OffsetY, ListSW.OffsetX + WidthOf(R), ListSW.OffsetY + HeightOf(R)), MaxByte);
    finally
      RestoreDC(DC, SavedDC);
      ReleaseDC(ListSW.CtrlHandle, DC);
    end;
  end
  else begin
    GetClientRect(ListSW.CtrlHandle, cR);

    acDstBmp.Canvas.Lock;
    SavedDC := SaveDC(acDstBmp.Canvas.Handle);

    fR.TopLeft := Point(ListSW.OffsetX, ListSW.OffsetY);

    MoveWindowOrg(acDstBmp.Canvas.Handle, fR.Left, fR.Top);

    IntersectClipRect(acDstBmp.Canvas.Handle, 0, 0, WidthOf(cR), HeightOf(cR));

    ListSW.Provider.PrintHwndControls(ListSW.CtrlHandle, acDstBmp.Canvas.Handle);

    if ListSW.BorderForm <> nil then begin
      fR.TopLeft := Point(ListSW.OffsetX, ListSW.OffsetY);
      fR.Right := fR.Left + WidthOf(cR);
      fR.Bottom := fR.Top + HeightOf(cR);

      FillAlphaRect(acDstBmp, fR, MaxByte);
    end
    else FillAlphaRect(acDstBmp, Rect(0, 0, acDstBmp.Width, acDstBmp.Height), MaxByte);

    RestoreDC(acDstBmp.Canvas.Handle, SavedDC);
    acDstBmp.Canvas.UnLock;
  end;
end;

procedure AnimHideDlg(ListSW : TacDialogWnd);
var
  AnimForm : TForm;
  acDstBmp : TBitmap;
begin
  InAnimationProcess := True;
  ClearGlows;

  if ListSW.BorderForm <> nil then begin
    AnimForm := ListSW.BorderForm.AForm;
    if ListSW.BorderForm.ParentHandle <> 0 then SetWindowLong(ListSW.BorderForm.AForm.Handle, GWL_HWNDPARENT, LongInt(ListSW.BorderForm.ParentHandle));
    AnimForm.WindowProc := ListSW.BorderForm.OldBorderProc;
    acDstBmp := CreateBmp32(ListSW.SkinData.FCacheBmp.Width, ListSW.SkinData.FCacheBmp.Height);
    BitBlt(acDstBmp.Canvas.Handle, 0, 0, ListSW.SkinData.FCacheBmp.Width, ListSW.SkinData.FCacheBmp.Height, ListSW.SkinData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
  end
  else begin
    if ListSW.CoverForm <> nil then AnimForm := ListSW.CoverForm else AnimForm := MakeCoverForm(ListSW.CtrlHandle);
    acDstBmp := CreateBmp32(ListSW.SkinData.FCacheBmp.Width, ListSW.SkinData.FCacheBmp.Height);
    BitBlt(acDstBmp.Canvas.Handle, 0, 0, acDstBmp.Width, acDstBmp.Height, ListSW.SkinData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
  end;

  HideAnimForm(AnimForm, acDstBmp, ListSW.SkinData.SkinManager.AnimEffects.DialogHide.Time, MaxByte, ListSW.SkinData.SkinManager.AnimEffects.DialogHide.Mode);
  if ListSW.BorderForm <> nil then begin
    ListSW.BorderForm.AForm := nil;
    FreeAndNil(ListSW.BorderForm);
  end;
  InAnimationProcess := False;
end;

procedure AnimShowDlg(ListSW : TacDialogWnd; wTime : word = 0; MaxTransparency : integer = MaxByte; AnimType : TacAnimType = atAero);
var
  PrintDC, DC : hdc;
  DstBmp : TBitmap;
  i, StepCount : integer;
  h : hwnd;
  fR, cR : TRect;
  cy, cx : integer;
  dx, dy, l, t, r, b, trans, p : real;
  Flags : Longint;
  FBmpSize: TSize;
  FBmpTopLeft: TPoint;
  FBlend: TBlendFunction;

  AnimForm : TForm;

  AnimBmp : TBitmap;
  procedure Anim_Init;
  begin
    trans := 0;
    p := MaxTransparency / (StepCount + 1);
    case AnimType of
      atAero : begin
        dx := DstBmp.Width / (StepCount * acwDivider);
        dy := DstBmp.Height / (StepCount * acwDivider);
        l := DstBmp.Width / acwDivider;
        t := DstBmp.Height / acwDivider;
        r := DstBmp.Width - l;
        b := DstBmp.Height - t;
      end
      else begin
        dx := 0;
        dy := 0;
        l := 0;
        t := 0;
        r := 0;
        b := 0;
      end;
    end
  end;
  procedure Anim_DoNext;
  begin
    trans := min(trans + p, MaxTransparency);
    FBlend.SourceConstantAlpha := Round(trans);

    case AnimType of
      atAero : begin
        if (l < 0) or (t < 0)
          then BitBlt(AnimBmp.Canvas.Handle, 0, 0, DstBmp.Width, DstBmp.Height, DstBmp.Canvas.Handle, 0, 0, SRCCOPY)
          else StretchBlt(AnimBmp.Canvas.Handle, Round(l), Round(t), Round(r - l), Round(b - t), DstBmp.Canvas.Handle, 0, 0, DstBmp.Width, DstBmp.Height, SRCCOPY);
      end
      else begin
        if l = 0 then begin
          BitBlt(AnimBmp.Canvas.Handle, 0, 0, DstBmp.Width, DstBmp.Height, DstBmp.Canvas.Handle, 0, 0, SRCCOPY);
          l := 1;
        end;
      end
    end
  end;
  procedure Anim_GoToNext;
  begin
    case AnimType of
      atAero : begin
        l := l - dx;
        t := t - dy;
        r := r + dx;
        b := b + dy;
      end
    end
  end;
begin
  InAnimationProcess := True;

  if ListSW.BorderForm <> nil then begin
    AnimForm := ListSW.BorderForm.AForm;
  end
  else begin
    AnimForm := TForm.Create(Application);
    AnimForm.Tag := ExceptTag;
    AnimForm.BorderStyle := bsNone;
    SetWindowLong(AnimForm.Handle, GWL_EXSTYLE, GetWindowLong(AnimForm.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW or WS_EX_NOACTIVATE);
  end;

  ListSW.PaintAll;
  GetClientRect(ListSW.CtrlHandle, cR);

  DstBmp := CreateBmp32(ListSW.SkinData.FCacheBmp.Width, ListSW.SkinData.FCacheBmp.Height);
  BitBlt(DstBmp.Canvas.Handle, 0, 0, DstBmp.Width, DstBmp.Height, ListSW.SkinData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);

  DstBmp.Canvas.Lock;
  PrintDC := DstBmp.Canvas.Handle;

  DC := SaveDC(PrintDC);

  fR.TopLeft := Point(ListSW.OffsetX, ListSW.OffsetY);

  MoveWindowOrg(PrintDC, fR.Left, fR.Top);

  IntersectClipRect(PrintDC, 0, 0, WidthOf(cR), HeightOf(cR));
  ListSW.Provider.PrintHwndControls(ListSW.CtrlHandle, PrintDC);

  if ListSW.BorderForm <> nil then begin
    fR.TopLeft := Point(ListSW.OffsetX, ListSW.OffsetY);
    fR.Right := fR.Left + WidthOf(cR);
    fR.Bottom := fR.Top + HeightOf(cR);

    FillAlphaRect(DstBmp, fR, MaxByte);
  end
  else FillAlphaRect(DstBmp, Rect(0, 0, DstBmp.Width, DstBmp.Height), MaxByte);

  RestoreDC(PrintDC, DC);

  if DstBmp = nil then Exit;
  DstBmp.Canvas.UnLock;

  FBmpSize.cx := DstBmp.Width;
  FBmpSize.cy := DstBmp.Height;

  StepCount := wTime div acTimerInterval;

  Flags := SWP_NOACTIVATE or SWP_NOREDRAW or SWP_NOCOPYBITS or SWP_NOSENDCHANGING or SWP_NOOWNERZORDER;

  FBmpTopLeft := Point(0, 0);
  if StepCount > 0 then FBlend.SourceConstantAlpha := 0 else FBlend.SourceConstantAlpha := MaxTransparency;
  FBlend.BlendOp := AC_SRC_OVER;
  FBlend.BlendFlags := 0;
  FBlend.AlphaFormat := AC_SRC_ALPHA;

  if ListSW.BorderForm <> nil then begin
    cy := SkinTitleHeight(ListSW.BorderForm) + ListSW.ShadowSize.Top - ListSW.CaptionHeight(False) - SysBorderWidth(ListSW.CtrlHandle, ListSW.BorderForm, False);
    cx := SkinBorderWidth(ListSW.BorderForm) - SysBorderWidth(ListSW.CtrlHandle, ListSW.BorderForm, False) + ListSW.ShadowSize.Left;
  end
  else begin
    cy := 0;
    cx := 0;
  end;

  GetWindowRect(ListSW.CtrlHandle, fR);

  AnimForm.SetBounds(fR.Left - cx, fR.Top - cy, DstBmp.Width, DstBmp.Height);

  if GetWindowLong(ListSW.CtrlHandle, GWL_EXSTYLE) and WS_EX_TOPMOST = WS_EX_TOPMOST then begin
    AnimForm.FormStyle := fsStayOnTop;
    h := HWND_TOPMOST
  end
  else begin
    h := GetWindow(ListSW.CtrlHandle, GW_HWNDPREV);
  end;

  DC := GetDC(0);
  SetWindowLong(AnimForm.Handle, GWL_EXSTYLE, GetWindowLong(AnimForm.Handle, GWL_EXSTYLE) or WS_EX_LAYERED or WS_EX_NOACTIVATE);
  UpdateLayeredWindow(AnimForm.Handle, DC, nil, @FBmpSize, DstBmp.Canvas.Handle, @FBmpTopLeft, clNone, @FBlend, ULW_ALPHA);
  ShowWindow(AnimForm.Handle, SW_SHOWNOACTIVATE);

  SetWindowPos(AnimForm.Handle, h, AnimForm.Left, AnimForm.Top, FBmpSize.cx, FBmpSize.cy, Flags or SWP_NOREDRAW);
  AnimBmp := CreateBmp32(FBmpSize.cx, FBmpSize.cy);
  FillDC(AnimBmp.Canvas.Handle, Rect(0, 0, AnimBmp.Width, AnimBmp.Height), 0);
  SetStretchBltMode(AnimBmp.Canvas.Handle, COLORONCOLOR);

  if StepCount > 0 then begin
    Anim_Init;
    i := 0;
    while i <= StepCount do begin
      Anim_DoNext;
      UpdateLayeredWindow(AnimForm.Handle, DC, nil, @FBmpSize, AnimBmp.Canvas.Handle, @FBmpTopLeft, clNone, @FBlend, ULW_ALPHA);
      Anim_GoToNext;
      inc(i);
      if StepCount > 0 then Sleep(acTimerInterval);
    end;
    FBlend.SourceConstantAlpha := MaxTransparency;
  end;

  SetWindowRgn(AnimForm.Handle, 0, False);
  SetWindowPos(AnimForm.Handle, 0, 0, 0, 0, 0, Flags or {SWP_NOZORDER or }SWP_NOSIZE or SWP_NOMOVE);
  UpdateLayeredWindow(AnimForm.Handle, DC, nil, @FBmpSize, DstBmp.Canvas.Handle, @FBmpTopLeft, clNone, @FBlend, ULW_ALPHA);

  FreeAndNil(AnimBmp);
  ReleaseDC(0, DC);

  SendMessage(ListSW.CtrlHandle, WM_SETREDRAW, 1, 0); // Vista
  InAnimationProcess := False;

  if ListSW.BorderForm <> nil then begin
    ListSW.BorderForm.ExBorderShowing := True;
    RedrawWindow(ListSW.CtrlHandle, nil, 0, RDW_FRAME or RDW_ALLCHILDREN or RDW_INVALIDATE{ or RDW_ERASE} or RDW_UPDATENOW);
    UpdateRgn(ListSW, False);
    ListSW.BorderForm.ExBorderShowing := False;
  end
  else RedrawWindow(ListSW.CtrlHandle, nil, 0, RDW_FRAME or RDW_ALLCHILDREN or RDW_INVALIDATE or RDW_ERASE or RDW_UPDATENOW);

  SetWindowPos(AnimForm.Handle, ListSW.CtrlHandle, 0, 0, 0, 0, Flags or SWP_NOSIZE or SWP_NOMOVE);

  FreeAndNil(DstBmp);
  if ListSW.BorderForm = nil then FreeAndNil(AnimForm);
end;

var
  acAnimBmp : TBitmap = nil;

procedure PrepareForAnimation(Ctrl : TWinControl);
var
  Flags : dword;
  R : TRect;
  ScrDC : hdc;
begin
  GetWindowRect(Ctrl.Handle, R);
  if acAnimBmp = nil then acAnimBmp := CreateBmp32(Ctrl.width, Ctrl.Height);
  ScrDC := GetDC(0);
  BitBlt(acAnimBmp.Canvas.Handle, 0, 0, Ctrl.width, Ctrl.Height, ScrDC, R.Left, R.Top, SRCCOPY);
  ReleaseDC(0, ScrDC);

  if ow = nil then ow := TOutPutWindow.Create(Ctrl);
  if Ctrl.Parent <> nil then begin
    ow.Parent := Ctrl.Parent;
    if ow = nil then Exit;
    SetChildOrderAfter(ow, Ctrl);
    ow.BoundsRect := Ctrl.BoundsRect;
  end
  else begin
    ow.BoundsRect := R;
  end;
  if ow.Parent = nil then begin
    Flags := SWP_NOZORDER or SWP_SHOWWINDOW or SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE;
    SetWindowPos(ow.Handle, GetWindow(TWinControl(Ctrl).Handle, GW_HWNDPREV), 0, 0, 0, 0, Flags);
  end
  else ShowWindow(ow.Handle, SW_SHOWNA);
end;

procedure AnimShowControl(Ctrl : TWinControl; wTime : word = 0; MaxTransparency : integer = MaxByte; AnimType : TacAnimType = atFading);
var
  NewBmp : TBitmap;
  SavedDC, DC : hdc;
  i, StepCount, prc : integer;
  h : hwnd;
  Percent : integer;
  fR : TRect;
  sp : TAccessProvider;
  cy, cx : integer;
  bExtendedBorders : Boolean;
  Flags : Longint;
  FBmpSize: TSize;
  FBmpTopLeft: TPoint;
  FBlend: TBlendFunction;
  dx, dy, l, t, r, b, trans, p : real;
  AnimBmp : TBitmap;
  acDstBmp : TBitmap;
  OldAlphaForm : TForm;
  OldAlphaBmp : TBitmap;
  procedure Anim_Init;
  begin
    trans := 0;
    p := MaxTransparency / StepCount;
    case AnimType of
      atAero : begin
        dx := acDstBmp.Width / (StepCount * acwDivider);
        dy := acDstBmp.Height / (StepCount * acwDivider);
        l := acDstBmp.Width / acwDivider;
        t := acDstBmp.Height / acwDivider;
        r := acDstBmp.Width - l;
        b := acDstBmp.Height - t;
      end
      else begin
        dx := 0;
        dy := 0;
        l := 0;
        t := 0;
        r := 0;
        b := 0;
      end;
    end
  end;
  procedure Anim_DoNext;
  begin
    trans := min(trans + p, MaxTransparency);
    FBlend.SourceConstantAlpha := Round(trans); 
    case AnimType of
      atAero : begin
        if (l < 0) or (t < 0)
          then BitBlt(AnimBmp.Canvas.Handle, 0, 0, acDstBmp.Width, acDstBmp.Height, acDstBmp.Canvas.Handle, 0, 0, SRCCOPY)
          else StretchBlt(AnimBmp.Canvas.Handle, Round(l), Round(t), Round(r - l), Round(b - t), acDstBmp.Canvas.Handle, 0, 0, acDstBmp.Width, acDstBmp.Height, SRCCOPY);
      end
      else begin
        if l = 0 then begin
          BitBlt(AnimBmp.Canvas.Handle, 0, 0, acDstBmp.Width, acDstBmp.Height, acDstBmp.Canvas.Handle, 0, 0, SRCCOPY);
          l := 1;
        end;
      end
    end
  end;
  procedure Anim_GoToNext;
  begin
    case AnimType of
      atAero : begin
        l := l - dx;
        t := t - dy;
        r := r + dx;
        b := b + dy;
      end
    end
  end;
begin
  InAnimationProcess := True;
  if Ctrl is TCustomForm then sp := TAccessProvider(SendMessage(Ctrl.Handle, SM_ALPHACMD, MakeWParam(0, AC_GETPROVIDER), 0)) else sp := nil;
  if (sp <> nil) and (sp.BorderForm <> nil) and acLayered then bExtendedBorders := True else bExtendedBorders := False;

  if acLayered and (Ctrl is TCustomForm) then begin
    if sp.BorderForm <> nil then begin
      if sp.CoverBmp <> nil then begin
        OldAlphaBmp := sp.CoverBmp;
        sp.CoverBmp := nil;              
      end
      else begin
        OldAlphaBmp := CreateBmp32(0, 0);
        OldAlphaBmp.Assign(sp.SkinData.FCacheBmp);
      end;
    end;
    sp.PaintAll;
    acDstBmp := CreateBmp32(sp.SkinData.FCacheBmp.Width, sp.SkinData.FCacheBmp.Height);

    acDstBmp.Canvas.Lock;
    SkinPaintTo(acDstBmp, Ctrl, 0, 0, sp);

    if acDstBmp = nil then Exit;
    if sp.BorderForm = nil then begin
      FillAlphaRect(acDstBmp, Rect(0, 0, acDstBmp.Width, acDstBmp.Height), MaxByte);
    end;

    acDstBmp.Canvas.UnLock;

    StepCount := wTime div acTimerInterval;

    Flags := SWP_NOACTIVATE or SWP_NOREDRAW or SWP_NOCOPYBITS or SWP_NOSIZE or SWP_NOMOVE; // or SWP_NOZORDER;

    FBmpSize.cx := acDstBmp.Width;
    FBmpSize.cy := acDstBmp.Height;
    FBmpTopLeft := Point(0, 0);
    if StepCount > 0 then FBlend.SourceConstantAlpha := 0 else FBlend.SourceConstantAlpha := MaxTransparency;
    FBlend.BlendOp := AC_SRC_OVER;
    FBlend.BlendFlags := 0;
    FBlend.AlphaFormat := AC_SRC_ALPHA;

    if sp.BorderForm <> nil then begin
      sp.BorderForm.AForm.WindowProc := sp.BorderForm.OldBorderProc;
      if sp.BorderForm.ParentHandle <> 0 then SetWindowLong(sp.BorderForm.AForm.Handle, GWL_HWNDPARENT, LongInt(sp.BorderForm.ParentHandle)); // Patch for ReportBuilder and similar windows
      OldAlphaForm := sp.BorderForm.AForm;
      sp.BorderForm.CreateNewForm;

      if sp.FSysExHeight then cy := sp.ShadowSize.Top else begin
        if IsZoomed(sp.Form.Handle) and (sp.SkinData.SkinManager.SkinData.ExMaxHeight <> sp.SkinData.SkinManager.SkinData.ExTitleHeight)
          then cy := SkinTitleHeight(sp.BorderForm) + sp.ShadowSize.Top - SysCaptHeight(sp.Form) - SysBorderWidth(sp.Form.Handle, sp.BorderForm, False) + sp.SkinData.SkinManager.SkinData.ExTitleHeight - sp.SkinData.SkinManager.SkinData.ExMaxHeight
          else cy := SkinTitleHeight(sp.BorderForm) + sp.ShadowSize.Top - SysCaptHeight(sp.Form) - SysBorderWidth(sp.Form.Handle, sp.BorderForm, False);
      end;
      cx := SkinBorderWidth(sp.BorderForm) - SysBorderWidth(sp.Form.Handle, sp.BorderForm, False) + sp.ShadowSize.Left;

      GetWindowRect(Ctrl.Handle, fR);

      sp.BorderForm.AForm.Left := fR.Left - cx;
      sp.BorderForm.AForm.Top := fr.Top - cy;
      sp.BorderForm.AForm.Width := FBmpSize.cx;
      sp.BorderForm.AForm.Height := FBmpSize.cy;

      h := GetNextWindow(sp.Form.Handle, GW_HWNDPREV);

      SetWindowPos(sp.BorderForm.AForm.Handle, h, fR.Left - cx, fr.Top - cy, FBmpSize.cx, FBmpSize.cy, Flags);

      DC := GetDC(0);
      UpdateLayeredWindow(sp.BorderForm.AForm.Handle, DC, nil, @FBmpSize, acDstBmp.Canvas.Handle, @FBmpTopLeft, clNone, @FBlend, ULW_ALPHA);
      ShowWindow(sp.BorderForm.AForm.Handle, SW_SHOWNOACTIVATE);

      AnimBmp := CreateBmp32(FBmpSize.cx, FBmpSize.cy);
      FillDC(AnimBmp.Canvas.Handle, Rect(0, 0, AnimBmp.Width, AnimBmp.Height), 0);

      if StepCount > 0 then begin
        Anim_Init;
        i := 0;
        while i <= StepCount do begin
          Anim_DoNext;
          UpdateLayeredWindow(sp.BorderForm.AForm.Handle, DC, nil, @FBmpSize, AnimBmp.Canvas.Handle, @FBmpTopLeft, clNone, @FBlend, ULW_ALPHA);
          SetFormBlendValue(OldAlphaForm.Handle, OldAlphaBmp, min(MaxByte, max(0, 3 * (MaxTransparency - FBlend.SourceConstantAlpha))));
          Anim_GoToNext;
          inc(i);
          if StepCount > 0 then Sleep(acTimerInterval);
        end;
        FBlend.SourceConstantAlpha := MaxTransparency;
      end;

      ReleaseDC(0, DC);
      InAnimationProcess := False;
  {$IFDEF DELPHI7UP}
      if sp.Form.AlphaBlend then begin
        sp.Form.AlphaBlendValue := MaxTransparency;
      end;
  {$ENDIF}
      SendMessage(Ctrl.Handle, WM_SETREDRAW, 1, 0); // Vista

      RedrawWindow(Ctrl.Handle, nil, 0, RDW_ERASE or RDW_FRAME or RDW_ALLCHILDREN or RDW_INVALIDATE or RDW_UPDATENOW);
      SetWindowRgn(sp.BorderForm.AForm.Handle, sp.BorderForm.MakeRgn, False);
      SetWindowPos(sp.BorderForm.AForm.Handle, 0, fR.Left - cx, fr.Top - cy, FBmpSize.cx, FBmpSize.cy, Flags or SWP_NOZORDER);
      sp.BorderForm.UpdateExBordersPos(False);
      FreeAndNil(OldAlphaBmp);
      FreeAndNil(OldAlphaForm);
    end
    else begin
      GetWindowRect(Ctrl.Handle, fR);

      TForm(ow) := TForm.Create(nil);
      TForm(ow).Tag := ExceptTag;
      TForm(ow).BorderStyle := bsNone;

      ow.Left := Ctrl.Left;
      ow.Top := Ctrl.Top;
      ow.Width := Ctrl.Width;
      ow.Height := Ctrl.Height;
      if GetWindowLong(Ctrl.Handle, GWL_EXSTYLE) and WS_EX_TOPMOST = WS_EX_TOPMOST then begin
        TForm(ow).FormStyle := fsStayOnTop;
        h := HWND_TOPMOST
      end
      else begin
        h := GetWindow(sp.Form.Handle, GW_HWNDPREV); // 0;
      end;

      SetWindowPos(ow.Handle, h, ow.Left, ow.Top, FBmpSize.cx, FBmpSize.cy, Flags and not SWP_NOMOVE);

      DC := GetDC(0);
      SetWindowLong(ow.Handle, GWL_EXSTYLE, GetWindowLong(ow.Handle, GWL_EXSTYLE) or WS_EX_LAYERED or WS_EX_NOACTIVATE);
      UpdateLayeredWindow(ow.Handle, DC, nil, @FBmpSize, acDstBmp.Canvas.Handle, @FBmpTopLeft, clNone, @FBlend, ULW_ALPHA);
      ShowWindow(ow.Handle, SW_SHOWNOACTIVATE);

      AnimBmp := CreateBmp32(FBmpSize.cx, FBmpSize.cy);
      FillDC(AnimBmp.Canvas.Handle, Rect(0, 0, AnimBmp.Width, AnimBmp.Height), 0);

      if StepCount > 0 then begin
        Anim_Init;
        i := 0;
        while i <= StepCount do begin
          Anim_DoNext;
          UpdateLayeredWindow(ow.Handle, DC, nil, @FBmpSize, AnimBmp.Canvas.Handle, @FBmpTopLeft, clNone, @FBlend, ULW_ALPHA);
          Anim_GoToNext;
          inc(i);
          if StepCount > 0 then Sleep(acTimerInterval);
        end;
        FBlend.SourceConstantAlpha := MaxTransparency;
      end;

      ReleaseDC(0, DC);
      InAnimationProcess := False;
  {$IFDEF DELPHI7UP}
      if sp.Form.AlphaBlend then begin
        sp.Form.AlphaBlendValue := MaxTransparency;
      end;
  {$ENDIF}
      SendMessage(Ctrl.Handle, WM_SETREDRAW, 1, 0); // Vista
      RedrawWindow(Ctrl.Handle, nil, 0, RDW_ERASE or RDW_FRAME or RDW_ALLCHILDREN or RDW_INVALIDATE or RDW_UPDATENOW);
      FreeAndNil(ow);
    end;

    FreeAndNil(AnimBmp);
    FreeAndNil(acDstBmp);
  end
  else begin
    if ow = nil then PrepareForAnimation(Ctrl);
    if ow = nil then Exit;

    acDstBmp := CreateBmp32(Ctrl.width, Ctrl.Height);

    acDstBmp.Canvas.Lock;
    SavedDC := SaveDC(acDstBmp.Canvas.Handle);
    SkinPaintTo(acDstBmp, Ctrl);
    if acDstBmp = nil then Exit;
    RestoreDC(acDstBmp.Canvas.Handle, SavedDC);
    acDstBmp.Canvas.UnLock;

    NewBmp := CreateBmp32(Ctrl.width, Ctrl.Height);
    StepCount := wTime div acTimerInterval;

    if not bExtendedBorders and (sp <> nil) then begin
      sSkinProvider.FillArOR(TsSkinProvider(sp));
      if ow = nil then Exit;
      SetWindowRgn(ow.Handle, sSkinProvider.GetRgnFromArOR(TsSkinProvider(sp)), False);
    end;
    DC := GetWindowDC(ow.Handle);

    if StepCount > 0 then begin
      prc := MaxByte div StepCount;
      Percent := MaxByte;
      i := 0;
      while i <= StepCount do begin
        SumBitmapsByMask(NewBmp, acAnimBmp, acDstBmp, nil, max(0, Percent));
        BitBlt(DC, 0, 0, Ctrl.Width, Ctrl.Height, NewBmp.Canvas.Handle, 0, 0, SRCCOPY);
        if Assigned(acMagnForm) then SendMessage(acMagnForm.Handle, SM_ALPHACMD, MakeWParam(0, AC_REFRESH), 0);
        inc(i);
        dec(Percent, prc);
        if (i > StepCount) then Break;
        if StepCount > 0 then Sleep(acTimerInterval);
      end;
    end;
    BitBlt(DC, 0, 0, Ctrl.width, Ctrl.Height, acDstBmp.Canvas.Handle, 0, 0, SRCCOPY);

    if Assigned(acMagnForm) then SendMessage(acMagnForm.Handle, SM_ALPHACMD, MakeWParam(0, AC_REFRESH), 0);
    InAnimationProcess := False;

    if Ctrl.Visible then begin
      SendMessage(Ctrl.Handle, WM_SETREDRAW, 1, 0); // Vista
      if Win32MajorVersion >= 6
        then RedrawWindow(Ctrl.Handle, nil, 0, RDW_ERASE or RDW_FRAME or RDW_ALLCHILDREN or RDW_INVALIDATE or RDW_UPDATENOW);
      if not (Ctrl is TCustomForm) or (DWord(GetWindowLong(Ctrl.Handle, GWL_EXSTYLE)) and WS_EX_LAYERED <> WS_EX_LAYERED)
        then SetWindowPos(ow.Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or SWP_HIDEWINDOW or SWP_NOREDRAW or {SWP_NOCOPYBITS or }SWP_NOACTIVATE);
    end;
    ReleaseDC(ow.Handle, DC);
    FreeAndnil(ow);
    FreeAndNil(NewBmp);

    FreeAndNil(acAnimBmp);
    FreeAndNil(acDstBmp);
  end;
end;

procedure SetParentUpdated(wc : TWinControl); overload;
var
  i : integer;
begin
  if not InAnimationProcess then begin
    i := 0;
    while i < wc.ControlCount do begin
      if not (wc.Controls[i] is TGraphicControl) and not (csDestroying in wc.Controls[i].ComponentState) then begin
        if wc.Controls[i] is TWinControl then begin
          if TWinControl(wc.Controls[i]).HandleAllocated and TWinControl(wc.Controls[i]).Showing then SendAMessage(TWinControl(wc.Controls[i]).Handle, AC_ENDPARENTUPDATE)
        end
        else if wc.Controls[i] is TControl then SendAMessage(wc.Controls[i], AC_ENDPARENTUPDATE);
      end;
      inc(i);
    end;
  end;
end;

procedure SetParentUpdated(pHwnd : hwnd); overload
var
  hCtrl : THandle;
begin
  hCtrl := GetTopWindow(pHwnd);
  while hCtrl <> 0 do begin
    if (GetWindowLong(hCtrl, GWL_STYLE) and WS_CHILD) = WS_CHILD then SendAMessage(hCtrl, AC_ENDPARENTUPDATE);
    hCtrl := GetNextWindow(hCtrl, GW_HWNDNEXT);
  end;
end;

function GetControlColor(Control : TControl) : TColor;
begin
  Result := clFuchsia;
  if Control = nil then Exit;
  if SendAMessage(Control, AC_CTRLHANDLED) = 1
    then Result := ColorToRGB(Control.Perform(SM_ALPHACMD, MakeWParam(0, AC_GETCONTROLCOLOR), Result))
    else Result := ColorToRGB(TsHackedControl(Control).Color); // message is not supported by parent control
end;

function GetControlColor(Handle : THandle) : TColor; overload;
begin
  Result := clFuchsia;
  if Handle = 0 then Exit;
  Result := ColorToRGB(SendMessage(Handle, SM_ALPHACMD, MakeWParam(0, AC_GETCONTROLCOLOR), Result));
end;

function AllEditSelected(Ctrl : TCustomEdit): Boolean;
type
  TSelection = record
    StartPos, EndPos: Integer;
  end;
var
  Selection: TSelection;
begin
  SendMessage(Ctrl.Handle, EM_GETSEL, Longint(@Selection.StartPos), Longint(@Selection.EndPos));
  Result := (Selection.EndPos = Ctrl.GetTextLen) and (Ctrl.SelLength = Length(Ctrl.Text));
end;

function GetControlByName(ParentControl : TWinControl; const CtrlName : string) : TControl;
var
  i, j : integer;
  FrameName, cName : string;
  cf : TCustomFrame;
begin
  Result := nil;
  if ParentControl = nil then Exit;
  if pos('.', CtrlName) < 1 then for i := 0 to ParentControl.ComponentCount - 1 do begin
    if UpperCase(ParentControl.Components[i].Name) = UpperCase(CtrlName) then begin
      Result := TControl(ParentControl.Components[i]);
      Exit;
    end;
  end
  else begin
    FrameName := ExtractWord(1, CtrlName, ['.']);
    cName := ExtractWord(2, CtrlName, ['.']);
    if (FrameName = '') or (cName = '') then Exit;
    for i := 0 to ParentControl.ComponentCount - 1 do if (UpperCase(ParentControl.Components[i].Name) = UpperCase(FrameName)) then begin
      if (ParentControl.Components[i] is TCustomFrame) then begin
        cf := TCustomFrame(ParentControl.Components[i]);
        for j := 0 to cf.ComponentCount - 1 do if UpperCase(cf.Components[j].Name) = UpperCase(cName) then begin
          Result := TControl(cf.Components[j]);
          Exit;
        end
      end;
      Exit
    end;
  end;
end;

procedure PaintControls(DC: HDC; OwnerControl : TWinControl; ChangeCache : boolean; Offset : TPoint; AHandle : THandle = 0; CheckVisible : boolean = True);
var
  SaveIndex : hdc;
  I, J, Count : Integer;
  R : TRect;
  tDC, MemDC: HDC;
  MemBitmap, OldBitmap: HBITMAP;
  MemDCExists : boolean;
  BGInfo : TacBGInfo;
  function ControlIsReady(Control : TControl) : boolean; begin
    Result := (Control.Visible or (csDesigning in Control.ComponentState)) and (Control is TGraphicControl) and (Control.Width > 0) and (Control.Height > 0) and
           not (csNoDesignVisible in Control.ControlStyle) and not (csDestroying in Control.ComponentState) and
             not ((Control is TToolButton) and (TToolButton(Control).Style in [tbsCheck, tbsButton, tbsDropDown])) and
               RectVisible(DC, Control.BoundsRect);
  end;
begin
  if acGraphPainting {or (csPaintCopy in OwnerControl.ControlState) }then Exit;
  acGraphPainting := True;
  MemDCExists := False;
  MemDC := 0;
  MemBitmap := 0;
  OldBitmap := 0;
  if (OwnerControl.Visible or (csDesigning in OwnerControl.ComponentState) or not CheckVisible) and (OwnerControl.ControlCount > 0) then try
    if (GetClipBox(DC, R) = NULLREGION) or (R.Left = R.Right) or (R.Top = R.Bottom) then begin
      SendAMessage(OwnerControl.Handle, AC_SETHALFVISIBLE);
      acGraphPainting := False;
      Exit;
    end;

    BGInfo.BgType := btUnknown;
    BGInfo.PleaseDraw := False;
    GetBGInfo(@BGInfo, OwnerControl);

    I := 0; Count := OwnerControl.ControlCount;

    while I < Count do begin
      if ControlIsReady(OwnerControl.Controls[I]) then begin
        if (OwnerControl is TForm) and (TForm(OwnerControl).FormStyle = fsMDIForm) and
              (OwnerControl.Controls[I].Align <> alNone) and (OwnerControl.Controls[I] is TGraphicControl) then begin

          OwnerControl.Controls[I].Perform(SM_ALPHACMD, MakeWParam(0, AC_INVALIDATE), 0);
{          SendMessage(OwnerControl.Handle, SM_ALPHACMD, MakeWParam(0, AC_SETGRAPHCONTROL), longint(OwnerControl.Controls[I]));
          OwnerControl.Controls[I].Repaint;
          SendMessage(OwnerControl.Handle, SM_ALPHACMD, MakeWParam(0, AC_SETGRAPHCONTROL), 0);}
        end;

        if not MemDCExists then begin
          tDC := GetDC(0);
          MemBitmap := CreateCompatibleBitmap(tDC, OwnerControl.Width, OwnerControl.Height);
          ReleaseDC(0, tDC);
          MemDC := CreateCompatibleDC(0); OldBitmap := SelectObject(MemDC, MemBitmap);
          MemDCExists := True;
          for j := 0 to Count - 1 do // Copy parent BG
            if ControlIsReady(OwnerControl.Controls[J]) then begin
              if not (csOpaque in OwnerControl.Controls[J].ControlStyle) {???or (OwnerControl.Controls[J] is TGraphicControl)} then begin
                if BGInfo.BgType = btFill // If without cache
                  then FillDC(MemDC, OwnerControl.Controls[J].BoundsRect, BGInfo.Color)
                  else BitBlt(MemDC, OwnerControl.Controls[J].Left, OwnerControl.Controls[J].Top, OwnerControl.Controls[J].Width, OwnerControl.Controls[J].Height, BGInfo.Bmp.Canvas.Handle, OwnerControl.Controls[J].Left + BGInfo.Offset.X, OwnerControl.Controls[J].Top + BGInfo.Offset.Y, SRCCOPY)
              end
              else FillDC(MemDC, OwnerControl.Controls[J].BoundsRect, GetControlColor(OwnerControl.Controls[J]));
            end;
        end;

        SaveIndex := SaveDC(MemDC);

        if not RectVisible(DC, OwnerControl.Controls[I].BoundsRect) then begin
          SendAMessage(OwnerControl.Controls[I], AC_SETHALFVISIBLE);
        end;

        MoveWindowOrg(MemDC, OwnerControl.Controls[I].Left, OwnerControl.Controls[I].top);
        IntersectClipRect(MemDC, 0, 0, OwnerControl.Controls[I].Width, OwnerControl.Controls[I].Height);

        if csPaintCopy in OwnerControl.ControlState then begin
          OwnerControl.Controls[I].ControlState := OwnerControl.Controls[I].ControlState + [csPaintCopy];
        end;
        try // <- Do not remove, external errors in dialogs are possible
          OwnerControl.Controls[I].Perform(WM_PAINT, longint(MemDC), 0);
        except
        end;        
        if csPaintCopy in OwnerControl.ControlState then begin
          OwnerControl.Controls[I].ControlState := OwnerControl.Controls[I].ControlState - [csPaintCopy];
        end;

        MoveWindowOrg(MemDC, - OwnerControl.Controls[I].Left, - OwnerControl.Controls[I].Top);

        RestoreDC(MemDC, SaveIndex);
      end;
      Inc(i);
    end;
    if MemDCExists then begin
      J := 0;
      while J < Count do begin // Copy graphic controls
        if ControlIsReady(OwnerControl.Controls[J]) then begin
          if GetPixel(MemDC, OwnerControl.Controls[J].Left + Offset.X, OwnerControl.Controls[J].Top + Offset.Y) <> DWord(clFuchsia) then
            BitBlt(DC, OwnerControl.Controls[J].Left + Offset.X, OwnerControl.Controls[J].Top + Offset.Y, OwnerControl.Controls[J].Width, OwnerControl.Controls[J].Height,
                   MemDC, OwnerControl.Controls[J].Left, OwnerControl.Controls[J].Top, SRCCOPY);
        end;
        inc(J);
      end;
    end;
  finally if MemDCExists then begin
    SelectObject(MemDC, OldBitmap);
    DeleteDC(MemDC);
    DeleteObject(MemBitmap);
  end; end;
  acGraphPainting := False;
end;

function SendAMessage(Handle : hwnd; Cmd : Integer; LParam : longint = 0) : longint; overload;
begin
  Result := SendMessage(Handle, SM_ALPHACMD, MakeWParam(0, Word(Cmd)), LParam);
end;

function SendAMessage(Control : TControl; Cmd : Integer; LParam : longword = 0) : longint; overload;
begin
  Result := 0;
  if (Control is TWinControl) then begin
    if not (csDestroying in Control.ComponentState) and TWinControl(Control).HandleAllocated
      then Result := SendMessage(TWinControl(Control).Handle, SM_ALPHACMD, MakeWParam(0, Word(Cmd)), LParam)
  end
  else Result := Control.Perform(SM_ALPHACMD, MakeWParam(0, Word(Cmd)), LParam)
end;

procedure SetBoolMsg(Handle : hwnd; Cmd : Cardinal; Value : boolean);
var
  m : TMessage;
begin
  m.Msg := SM_ALPHACMD;
  m.WParam := MakeWParam(Word(Value), Cmd);
  m.Result := 0;
  SendMessage(Handle, m.Msg, m.wParam, m.lParam);
end;

function GetBoolMsg(Control : TWinControl; Cmd : Cardinal) : boolean;
begin
  Result := boolean(SendAMessage(Control, Cmd));
end;

function GetBoolMsg(CtrlHandle : hwnd; Cmd : Cardinal) : boolean; overload;
var
  LParam : cardinal;
begin
  LParam := 0;
  if SendMessage(CtrlHandle, SM_ALPHACMD, MakeWParam(0, Cmd), LParam) = 1 then Result := True else Result := LParam = 1;
end;

procedure RepaintsGraphicControls(WinControl : TWinControl);
var
  i : integer;
begin
  for i := 0 to WinControl.ControlCount - 1 do
    if (WinControl.Controls[i] is TGraphicControl) then
      if ControlIsReady(WinControl.Controls[i]) then WinControl.Controls[i].Repaint;
end;

function ControlIsReady(Control : TControl) : boolean;
begin
  Result := False;
  if (Control = nil) or ((Control is TWinControl) and not TWinControl(Control).HandleAllocated) then Exit;

  Result := not (csCreating in Control.ControlState) and
              not (csReadingState in Control.ControlState) and //not (csAlignmentNeeded in Control.ControlState) and
                not (csLoading in Control.ComponentState) and not (csDestroying in Control.ComponentState) and
                  (Control.Parent <> nil);
end;

function GetOwnerForm(Component: TComponent) : TCustomForm;
var
  c: TComponent;
begin
  Result := nil;
  c := Component;
  while Assigned(c) and not (c is TCustomForm) do c := c.Owner;
  if (c is TCustomForm) then Result := TCustomForm(c);
end;

function GetOwnerFrame(Component: TComponent) : TCustomFrame;
var
  c: TComponent;
begin
  Result := nil;
  c := Component;
  while Assigned(c) and not (c is TCustomFrame) do c := c.Owner;
  if (c is TCustomFrame) then Result := TCustomFrame(c);
end;

procedure SetPanelFocus(Panel : TWinControl);
var
  List : TList;
  i : integer;
begin
  List := TList.Create;
  Panel.GetTabOrderList(List);
  if List.Count > 0 then for i:=0 to List.Count-1 do begin
    if TWinControl(List[i]).Enabled and TWinControl(List[i]).TabStop then begin
      TWinControl(List[i]).SetFocus;
      Break;
    end;
  end;
  FreeAndNil(List);
end;

procedure SetControlsEnabled(Parent : TWinControl; Value: boolean);
var
   i : integer;
begin
  for i:=0 to Parent.ControlCount-1 do begin
    if not (Parent.Controls[i] is TCustomPanel) then Parent.Controls[i].Enabled := Value;
  end;
end;

function CheckPanelFilled(Panel:TCustomPanel):boolean;
var
   i:integer;
begin
  Result:=False;
  for i:=0 to Panel.ControlCount-1 do begin
    if (Panel.Controls[i] is TEdit) and (TEdit(Panel.Controls[i]).Text='') then begin exit; end;
    if (Panel.Controls[i] is TComboBox) and (TComboBox(Panel.Controls[i]).Text='') then begin exit; end;
  end;
  Result:=True;
end;

function GetStringFlags(Control: TControl; al: TAlignment): longint;
begin
  Result := Control.DrawTextBiDiModeFlags(DT_EXPANDTABS or DT_VCENTER or AlignToInt[al]);
end;

procedure RepaintsControls(Owner: TWinControl; BGChanged : boolean);
var
  i: Integer;
begin
  i := 0;
  while i <= Owner.ControlCount - 1 do begin
    if ControlIsReady(Owner.Controls[i]) then begin
      if not (Owner.Controls[i] is TGraphicControl) then Owner.Controls[i].Invalidate;
    end;
    inc(i);
  end;
end;

procedure AlphaBroadCast(Control : TWinControl; var Message);
var
  i : integer;
begin
  i := 0;
  while i < Control.ControlCount do begin
    if (i >= Control.ControlCount) or (csDestroying in Control.Controls[i].ComponentState) then Exit;
    if (Control.Controls[i] is TWincontrol) then begin
      if not TWinControl(Control.Controls[i]).HandleAllocated then begin
        Control.Controls[i].Perform(TMessage(Message).Msg, TMessage(Message).Wparam, TMessage(Message).LParam);
      end
      else if GetBoolMsg(TWinControl(Control.Controls[i]), AC_CTRLHANDLED) then begin
        SendMessage(TWinControl(Control.Controls[i]).Handle, TMessage(Message).Msg, TMessage(Message).WParam, TMessage(Message).LParam)
      end
      else begin
        if not Assigned(CheckDevEx) or not CheckDevEx(Control.Controls[i]) then AlphaBroadCast(TWinControl(Control.Controls[i]), Message);
      end;
    end
    else Control.Controls[i].Perform(TMessage(Message).Msg, TMessage(Message).Wparam, TMessage(Message).LParam);
    inc(i);
  end;
end;

type
  TacMsgInfo = record
    Sender : hwnd;
    Message : TMessage;
  end;

  PacMsgInfo = ^TacMsgInfo;

function SendToChildren(Child: HWND; Data: LParam): BOOL; stdcall;
var
  MsgI : TacMsgInfo;
begin
  MsgI := PacMsgInfo(Data)^;
  if GetParent(Child) = MsgI.Sender then begin
    SendMessage(Child, MsgI.Message.Msg, MsgI.Message.WParam, MsgI.Message.LParam);
  end;
  Result := True;
end;

procedure AlphaBroadCast(Handle : hwnd; var Message); overload;
var
  MsgI : TacMsgInfo;
begin
  MsgI.Sender := Handle;
  MsgI.Message := TMessage(Message);
  EnumChildWindows(Handle, @SendToChildren, LPARAM(@MsgI));
end;

procedure SendToProvider(Form : TCustomform; var Message);
var
  i : integer;
begin
  i := 0;
  while i < Form.ComponentCount do begin
    if i >= Form.ComponentCount then Exit;
    if (Form.Components[i] is TsSkinProvider) and not (csDestroying in Form.Components[i].ComponentState) then begin
      TsSkinProvider(Form.Components[i]).DsgnWndProc(TMessage(Message));
      exit
    end;
    inc(i);
  end;
end;

function GetCtrlRange(Ctl : TWinControl; nBar : integer) : integer;
var
  i, iMin, iMax : integer;
begin
  iMax := 0;
  iMin := 0;
  case nBar of
    SB_VERT : begin
      iMin := Ctl.Height;
      for i := 0 to Ctl.ControlCount - 1 do begin
        iMin := Min(iMin, Ctl.Controls[i].Top);
        iMax := Max(iMax, Ctl.Controls[i].Top + Ctl.Controls[i].Height);
      end;
    end;
    SB_HORZ : begin
      iMin := Ctl.Width;
      for i := 0 to Ctl.ControlCount - 1 do begin
        iMin := Min(iMin, Ctl.Controls[i].Left);
        iMax := Max(iMax, Ctl.Controls[i].Left + Ctl.Controls[i].Width);
      end;
    end;
  end;
  if iMin < iMax then Result := iMax - iMin else Result := 0
end;

function ACClientRect(Handle : hwnd): TRect;
var
  R: TRect;
  P : TPoint;
begin
  GetWindowRect(Handle, R);
  P := Point(0, 0);
  ClientToScreen(Handle, P);
  GetClientRect(Handle, Result);
  OffsetRect(Result, P.X - R.Left, P.Y - R.Top);
end;

procedure TrySetSkinSection(Control : TControl; const SectionName : string); 
var
  si : TacSectionInfo;
begin
  if Control <> nil then begin
    si.Name := SectionName;
//    if Control is TWinControl
    Control.Perform(SM_ALPHACMD, MakeWParam(0, AC_SETSECTION), LongInt(@si));
  end;
end;

{
function ACClientRect(Handle : hwnd): TRect;
var
  R: TRect;
begin
  Windows.GetClientRect(Handle, Result);
  GetWindowRect(Handle, R);
  MapWindowPoints(0, Handle, R, 2);
  OffsetRect(Result, -R.Left, -R.Top);
end;
}
{ TOutputWindow }

constructor TOutputWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Caption := 'acOutputWindow';
  Visible := False;
  Color   := clFuchsia;
  Tag := ExceptTag;
end;

procedure TOutputWindow.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do begin
    if (Parent = nil) and (ParentWindow = 0) then begin
      Params.Style := WS_POPUP;
      if(Owner is TWinControl) and ((DWord(GetWindowLong(TWinControl(Owner).Handle, GWL_EXSTYLE)) and WS_EX_TOPMOST) <> 0)
        then Params.ExStyle := ExStyle or WS_EX_TOPMOST;
      WndParent := Application.Handle;
    end;
  end;
end;

procedure TOutputWindow.WMEraseBkgnd(var Message: TWmEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TOutputWindow.WMNCPaint(var Message: TWmEraseBkgnd);
begin
  Message.Result := 0;
end;

function GetAlignShift(Ctrl : TWinControl; Align : TAlign; GraphCtrlsToo : boolean = False) : integer;
var
  i : integer;
begin
  Result := 0;
  for i := 0 to Ctrl.ControlCount - 1 do if Ctrl.Controls[i].Visible and (Ctrl.Controls[i].Align = Align) and (GraphCtrlsToo or not (Ctrl.Controls[i] is TGraphicControl)) then begin
    case Align of
      alLeft, alRight : inc(Result, Ctrl.Controls[i].Width);
      alTop, alBottom : inc(Result, Ctrl.Controls[i].Height);
    end;
  end;
end;

function GetParentFormHandle(const CtrlHandle: hwnd): hwnd;
var
  ph : hwnd;
begin
  ph := GetParent(CtrlHandle);
  if ph = 0 then Result := CtrlHandle else Result := GetParentFormHandle(ph);
end;

{ TacHideTimer }

procedure TacHideTimer.Anim_DoNext;
begin
  Trans := max(Trans - p, 0);
  FBlend.SourceConstantAlpha := Round(trans);
  case AnimType of
    atAero : begin
      if (l < 0) or (t < 0) then BitBlt(DstBmp.Canvas.Handle, 0, 0, SrcBmp.Width, SrcBmp.Height, SrcBmp.Canvas.Handle, 0, 0, SRCCOPY) else begin
        FillDC(DstBmp.Canvas.Handle, Rect(0, 0, DstBmp.Width, DstBmp.Height), 0);
        SetStretchBltMode(DstBmp.Canvas.Handle, COLORONCOLOR);
        StretchBlt(DstBmp.Canvas.Handle, Round(l), Round(t), Round(r - l), Round(b - t), SrcBmp.Canvas.Handle, 0, 0, SrcBmp.Width, SrcBmp.Height, SRCCOPY);
      end;
    end
    else begin
      if l = 0 then begin
        BitBlt(DstBmp.Canvas.Handle, 0, 0, SrcBmp.Width, SrcBmp.Height, SrcBmp.Canvas.Handle, 0, 0, SRCCOPY);
        l := 1;
      end;
    end
  end
end;

procedure TacHideTimer.Anim_GoToNext;
begin
  case AnimType of
    atAero : begin
      l := l - dx;
      t := t - dy;
      r := r + dx;
      b := b + dy;
    end
  end
end;

procedure TacHideTimer.Anim_Init;
begin
//  SetStretchBltMode(DstBmp.Canvas.Handle, COLORONCOLOR);
  Trans := StartBlendValue;
  p := StartBlendValue / (StepCount);
  case AnimType of
    atAero : begin
      dx := -SrcBmp.Width / (StepCount * acwDivider);
      dy := -SrcBmp.Height / (StepCount * acwDivider);
      l := 0; t := 0;
      r := SrcBmp.Width;
      b := SrcBmp.Height;
    end
    else begin
      dx := 0; dy := 0; l := 0; t := 0; r := 0; b := 0;
    end;
  end
end;

destructor TacHideTimer.Destroy;
begin
  inherited;
  FreeAndNil(SrcBmp);
  FreeAndNil(DstBmp);
  FreeAndNil(Form);
end;

procedure TacHideTimer.OnTimerProc(Sender: TObject);
begin
  if i <= StepCount then begin
    Anim_DoNext;
    DC := GetDC(0);
    UpdateLayeredWindow(Form.Handle, DC, nil, @FBmpSize, DstBmp.Canvas.Handle, @FBmpTopLeft, clNone, @FBlend, ULW_ALPHA);
    ReleaseDC(0, DC);
    Anim_GoToNext;
    inc(i);
  end
  else begin
    Interval := MaxWord;
    OnTimer := nil;
    FreeAndNil(Form);
    FreeAndNil(SrcBmp);
    FreeAndNil(DstBmp);
  end;
end;

initialization
  uxthemeLib := LoadLibrary('UXTHEME');
  if uxthemeLib <> 0 then Ac_SetWindowTheme := GetProcAddress(uxthemeLib, 'SetWindowTheme');

finalization
  if uxthemeLib <> 0 then FreeLibrary(uxthemeLib);

end.

