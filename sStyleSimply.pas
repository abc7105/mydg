unit sStyleSimply;
{$I sDefs.inc}

interface

uses
  Windows, Graphics, Classes, Controls, acntUtils, SysUtils, StdCtrls,  Dialogs, Forms,
  Messages, sConst, extctrls, IniFiles;

type
  TsSkinData = class (TObject)
    SkinPath : string;
    Active : boolean;

    Version : real;
    Author : string;
    Description : string;

    Shadow1Color : TColor;
    Shadow1Offset : smallint;
    Shadow1Blur : smallint;
    Shadow1Transparency : smallint;

    // Extended borders
    ExBorderWidth : smallint;
    ExTitleHeight : smallint;
    ExMaxHeight : smallint;
    ExContentOffs : smallint;
    ExShadowOffs : smallint;
    ExCenterOffs : smallint;
    ExDrawMode : smallint;

    FXColor : TColor;
    BorderColor : TColor;

    BISpacing : smallint;
    BIVAlign : smallint; // 0 - center, 1 - top, 2 - bottom
    BIRightMargin : smallint;
    BILeftMargin : smallint;
    BITopMargin : smallint;
    BIKeepHUE : smallint; // 0 - variable HUE, 1 - keep unchanged

    // Glow Effects for border icons props
    BICloseGlow : smallint;
    BICloseGlowMargin : smallint;
    BIMaxGlow : smallint;
    BIMaxGlowMargin : smallint;
    BIMinGlow : smallint;
    BIMinGlowMargin : smallint;
  public
    destructor Destroy; override;
  end;

  TConstantSkinData = record
    // Index GLobalInfo
    IndexGLobalInfo : smallint;
    // Extended borders
    ExBorder : smallint;
    // Tabs indexes
    IndexTabTop : smallint;
    IndexTabBottom : smallint;
    IndexTabLeft : smallint;
    IndexTabRight : smallint;
    // Masks
    MaskTabTop : smallint;
    MaskTabBottom : smallint;
    MaskTabLeft : smallint;
    MaskTabRight : smallint;
    // ScrollButtons
    IndexScrollTop : smallint;
    IndexScrollBottom : smallint;
    IndexScrollLeft : smallint;
    IndexScrollRight : smallint;
    MaskScrollTop : smallint;
    MaskScrollBottom : smallint;
    MaskScrollLeft : smallint;
    MaskScrollRight : smallint;
    IndexBGScrollTop : smallint;
    IndexBGScrollBottom : smallint;
    IndexBGScrollLeft : smallint;
    IndexBGScrollRight : smallint;
    IndexBGHotScrollTop : smallint;
    IndexBGHotScrollBottom : smallint;
    IndexBGHotScrollLeft : smallint;
    IndexBGHotScrollRight : smallint;
    // Arrows masks
    MaskArrowTop : smallint;
    MaskArrowBottom : smallint;
    MaskArrowLeft : smallint;
    MaskArrowRight : smallint;
    // ScrollSliders
    IndexSliderVert : smallint;
    IndexSliderHorz : smallint;
    MaskSliderVert : smallint;
    MaskSliderHorz : smallint;
    MaskSliderGlyphVert : smallint;
    MaskSliderGlyphHorz : smallint;
    // Sliders patterns
    ScrollSliderBGHorz : smallint;
    ScrollSliderBGHotHorz : smallint;
    ScrollSliderBGVert : smallint;
    ScrollSliderBGHotVert : smallint;
    //ScrollBars
    IndexScrollBar1H : smallint;
    IndexScrollBar1V : smallint;
    IndexScrollBar2H : smallint;
    IndexScrollBar2V : smallint;
    MaskScrollBar1H : smallint;
    MaskScrollBar1V : smallint;
    MaskScrollBar2H : smallint;
    MaskScrollBar2V : smallint;
    BGScrollBar1H : smallint;
    BGScrollBar1V : smallint;
    BGScrollBar2H : smallint;
    BGScrollBar2V : smallint;
    BGHotScrollBar1H : smallint;
    BGHotScrollBar1V : smallint;
    BGHotScrollBar2H : smallint;
    BGHotScrollBar2V : smallint;
    // CheckBoxes and RadioButtons // Normal
    CheckBoxChecked : smallint;
    CheckBoxUnChecked : smallint;
    CheckBoxGrayed : smallint;
    RadioButtonChecked : smallint;
    RadioButtonUnChecked : smallint;
    RadioButtonGrayed : smallint;
    // Small
    SmallCheckBoxChecked : smallint;
    SmallCheckBoxUnChecked : smallint;
    SmallCheckBoxGrayed : smallint;
    // ComboBoxes
    ComboBtnIndex : integer;
    ComboBtnBorder : integer;
    ComboBtnBG : integer;
    ComboBtnBGHot : integer;
    ComboGlyph : integer;
  end;

procedure CopyExForms(SkinManager : TComponent);
procedure LockForms(SkinManager : TComponent);
procedure UnLockForms(SkinManager : TComponent; Repaint : boolean = True);
procedure AppBroadCastS(var Message);
procedure SendToHooked(var Message);
procedure IntSkinForm(Form : TCustomForm);
procedure IntUnSkinForm(Form : TCustomForm);

var
  GlobalSectionName : string;
  AppIcon, AppIconLarge : TIcon;
  aSkinChanging : boolean = False;
  HookedComponents : array of TComponent;

implementation

uses
  sStoreUtils, sVclUtils, sMessages, sMaskData, sSkinProvider, comctrls, sSkinProps, ShellAPI, sSkinManager, acDials, sGraphUtils;

type
  TAccessSkinProvider = class(TsSkinProvider);

procedure CopyExForms(SkinManager : TComponent);
var
  i: integer;
  sp : TAccessSkinProvider;
begin
  if IsIconic(Application.Handle) or (csDesigning in SkinManager.ComponentState) or (csLoading in SkinManager.ComponentState) or (csReading in SkinManager.ComponentState) then Exit;
  i := 0;
  if TsSkinManager(SkinManager).IsDefault and (TsSkinManager(SkinManager).AnimEffects.SkinChanging.Active) then InAnimationProcess := True;
  while i <= Length(HookedComponents) - 1 do begin
    if (HookedComponents[i] <> nil) and (HookedComponents[i] is TCustomForm) and (TCustomForm(HookedComponents[i]).WindowState <> wsMinimized) and
         (TForm(HookedComponents[i]).FormStyle <> fsMDIChild) and (TForm(HookedComponents[i]).Parent = nil) and TControl(HookedComponents[i]).Visible then begin
      sp := TAccessSkinProvider(SendAMessage(TWinControl(HookedComponents[i]), AC_GETPROVIDER));
      if (sp <> nil) and (sp.SkinData.SkinManager = SkinManager) then begin
        if (sp.BorderForm <> nil) and (sp.BorderForm.AForm <> nil) then begin
          sp.FormState := sp.FormState or FS_CHANGING;
          if sp.CoverBmp = nil then sp.CoverBmp := CreateBmp32(sp.SkinData.FCacheBmp.Width, sp.SkinData.FCacheBmp.Height);
          PaintFormTo(sp.CoverBmp, sp);
        end;
        sp.FInAnimation := True;
      end;
    end;
    inc(i);
  end;
end;

procedure LockForms;
var
  i: integer;
  sp : TAccessSkinProvider;
  Alpha : integer;
begin
  if IsIconic(Application.Handle) then Exit;
  i := 0;
  if TsSkinManager(SkinManager).IsDefault and (TsSkinManager(SkinManager).AnimEffects.SkinChanging.Active) then InAnimationProcess := True;
  while i <= Length(HookedComponents) - 1 do begin
    if (HookedComponents[i] <> nil) and (HookedComponents[i] is TCustomForm) and (TCustomForm(HookedComponents[i]).WindowState <> wsMinimized) and
         (TForm(HookedComponents[i]).FormStyle <> fsMDIChild) and (TForm(HookedComponents[i]).Parent = nil) and TControl(HookedComponents[i]).Visible then begin
      sp := TAccessSkinProvider(SendAMessage(TWinControl(HookedComponents[i]), AC_GETPROVIDER));
      if (sp <> nil) and (sp.SkinData.SkinManager = SkinManager) then begin
        sp.FInAnimation := True;
        if (sp.BorderForm <> nil) and (sp.BorderForm.AForm <> nil) then begin
          if sp.CoverBmp <> nil then begin
{$IFDEF DELPHI7UP}
            if sp.Form.AlphaBlend then Alpha := sp.Form.AlphaBlendValue else
{$ENDIF}
            Alpha := MaxByte;
            SetFormBlendValue(sp.BorderForm.AForm.Handle, sp.CoverBmp, Alpha);
          end;
          SetWindowRgn(sp.BorderForm.AForm.Handle, sp.BorderForm.MakeRgn, False);
        end;
        SendMessage(TWinControl(HookedComponents[i]).Handle, WM_SETREDRAW, 0, 0);
      end;
    end;
    inc(i);
  end;
end;

procedure UnlockForms;
var
  i, l: integer;
  sp : TsSkinProvider;
  Flags : longint;
  ActWnd : hwnd;
  AlphaValue : byte;
begin
  if IsIconic(Application.Handle) then Exit;
  if TsSkinManager(SkinManager).IsDefault then InAnimationProcess := False;
  i := 0;
  l := Length(HookedComponents) - 1;
  while i <= l do begin
    if (HookedComponents[i] <> nil) and (HookedComponents[i] is TCustomForm) and (TForm(HookedComponents[i]).FormStyle <> fsMDIChild) and (TForm(HookedComponents[i]).Parent = nil) and
         TControl(HookedComponents[i]).Visible then begin
      sp := TAccessSkinProvider(SendAMessage(TWinControl(HookedComponents[i]), AC_GETPROVIDER));
      if (sp <> nil) and (sp.SkinData.SkinManager = SkinManager) then begin
        SendMessage(TWinControl(HookedComponents[i]).Handle, WM_SETREDRAW, 1, 0);
      end;
    end;
    inc(i);
  end;

  i := 0;
  while i <= Length(HookedComponents) - 1 do begin
    if (HookedComponents[i] <> nil) and (HookedComponents[i] is TCustomForm) and (TForm(HookedComponents[i]).FormStyle <> fsMDIChild) and (TForm(HookedComponents[i]).Parent = nil) and
         TControl(HookedComponents[i]).Visible then begin
      sp := TsSkinProvider(SendAMessage(TWinControl(HookedComponents[i]), AC_GETPROVIDER));
      if (TCustomForm(HookedComponents[i]).WindowState <> wsMinimized) then begin
        if (sp <> nil) and (sp.SkinData.SkinManager = SkinManager) then begin
          if Repaint then begin
            if sp.SkinData.SkinManager.AnimEffects.SkinChanging.Active then begin
{$IFDEF DELPHI7UP}
              if sp.Form.AlphaBlend then AlphaValue := sp.Form.AlphaBlendValue else
{$ENDIF}
              AlphaValue := MaxByte;

              if sp.DrawNonClientArea
                then AnimShowControl(TWinControl(HookedComponents[i]), sp.SkinData.SkinManager.AnimEffects.SkinChanging.Time, AlphaValue, sp.SkinData.SkinManager.AnimEffects.SkinChanging.Mode)
                else AnimShowControl(TWinControl(HookedComponents[i]), 0);

            end;
            sp.FormState := sp.FormState and not FS_CHANGING;
            if (sp.BorderForm <> nil) and (sp.Form.WindowState = wsMaximized) then begin // Title height may be changed
              SetWindowLong(TWinControl(HookedComponents[i]).Handle, GWL_STYLE, GetWindowLong(TWinControl(HookedComponents[i]).Handle, GWL_STYLE) and not WS_VISIBLE);
              ActWnd := GetActiveWindow;
              ShowWindow(TWinControl(HookedComponents[i]).Handle, SW_SHOWMAXIMIZED);
              SetWindowLong(TWinControl(HookedComponents[i]).Handle, GWL_STYLE, GetWindowLong(TWinControl(HookedComponents[i]).Handle, GWL_STYLE) or WS_VISIBLE);
              if ActWnd <> 0 then SetActiveWindow(ActWnd);
            end;

//            SendMessage(TWinControl(HookedComponents[i]).Handle, WM_SETREDRAW, 1, 0); v7.21
            sp.FInAnimation := False;

            if sp.DrawNonClientArea then begin
              if Win32MajorVersion < 6 then SetWindowRgn(TWinControl(HookedComponents[i]).Handle, 0, False); // Fixing of Aero bug
              sSkinProvider.FillArOR(sp); // Update rgn data for skin
              sSkinProvider.UpdateRgn(sp, True);
              Flags := RDW_ERASE or RDW_UPDATENOW or RDW_INVALIDATE or RDW_ALLCHILDREN;
              RedrawWindow(TWinControl(HookedComponents[i]).Handle, nil, 0, Flags);
              if TAccessSkinProvider(sp).BorderForm <> nil then TAccessSkinProvider(sp).BorderForm.UpdateExBordersPos;
            end
            else RedrawWindow(TWinControl(HookedComponents[i]).Handle, nil, 0, RDW_ERASE or RDW_UPDATENOW or RDW_INVALIDATE or RDW_ALLCHILDREN or RDW_FRAME);
          end
          else begin
            sp.FormState := sp.FormState and not FS_CHANGING;
            SendMessage(TWinControl(HookedComponents[i]).Handle, WM_SETREDRAW, 1, 0);
            if Repaint then RedrawWindow(TWinControl(HookedComponents[i]).Handle, nil, 0, RDW_NOERASE or RDW_UPDATENOW or RDW_INVALIDATE or RDW_ALLCHILDREN or RDW_FRAME);
          end
        end;
      end
    end;
    inc(i);
  end;
end;

procedure AppBroadCastS(var Message);
var
  i: integer;
begin
(*Research for optimizing*)
  i := Application.ComponentCount - 1;
  while i >= 0 do begin // Order has been changed (Z-order is valuable now in skins changing or activating)
    if i >= Application.ComponentCount then Exit; // JACOB
    // Sending a message to all forms (non-MDIChild first)
    if (Application.Components[i] is TForm) and (TForm(Application.Components[i]).FormStyle <> fsMDIChild) then begin
      if not (csDestroying in Application.Components[i].ComponentState) and not (csLoading in Application.Components[i].ComponentState) and not GetBoolMsg(TForm(Application.Components[i]).Handle, AC_CTRLHANDLED) then begin
        // Form must be handled first
        SendMessage(TWinControl(Application.Components[i]).Handle, TMessage(Message).Msg, TMessage(Message).WParam, TMessage(Message).LParam);
        AlphaBroadCast(TWinControl(Application.Components[i]), Message);
        // Message sending to client if form is a MDIForm
        if (Application.Components[i] is TForm) and (TForm(Application.Components[i]).FormStyle = fsMDIForm)
          then SendMessage(TForm(Application.Components[i]).ClientHandle, TMessage(Message).Msg, TMessage(Message).WParam, TMessage(Message).LParam);
      end
    end;
    dec(i);
  end;                 
  SendToHooked(Message);
end;

procedure SendToHooked(var Message);
var
  i: integer;
  Cmp : TComponent;
  ap : TacProvider;
begin
  i := 0;
  while i <= Length(HookedComponents) - 1 do begin
    Cmp := HookedComponents[i];
    if (Cmp <> nil) and not (csDestroying in Cmp.ComponentState) and (Cmp is TCustomForm) then begin
      SendMessage(TWinControl(Cmp).Handle, TMessage(Message).Msg, TMessage(Message).WParam, TMessage(Message).LParam);
      AlphaBroadCast(TWinControl(Cmp), Message);
      if (Cmp is TForm) then if (TForm(Cmp).FormStyle = fsMDIForm) then SendMessage(TForm(Cmp).ClientHandle, TMessage(Message).Msg, TMessage(Message).WParam, TMessage(Message).LParam);
    end;
    inc(i);
  end;

  if acSupportedList <> nil then for i := 0 to acSupportedList.Count - 1 do begin
    ap := TacProvider(acSupportedList[i]);
    if (ap <> nil) and (ap.ListSW <> nil) and IsWindowVisible(ap.ListSW.CtrlHandle) then SendMessage(ap.ListSW.CtrlHandle, TMessage(Message).Msg, TMessage(Message).WParam, TMessage(Message).LParam);
  end;
end;

procedure IntSkinForm(Form : TCustomForm);
begin
  SetLength(HookedComponents, Length(HookedComponents) + 1);
  HookedComponents[Length(HookedComponents) - 1] := Form;
end;

procedure IntUnSkinForm(Form : TCustomForm);
var
  i, l : integer;
begin
  l := Length(HookedComponents) - 1;
  for i := 0 to l do if HookedComponents[i] = Form then begin
    HookedComponents[i] := HookedComponents[l];
    HookedComponents[l] := nil;
  end;
  if (l >= 0) then if HookedComponents[l] = nil then SetLength(HookedComponents, l)
end;

{ TsSkinData }

destructor TsSkinData.Destroy;
begin
  if Assigned(SkinFile) then FreeAndNil(SkinFile);
  inherited;
end;

initialization
  AppIcon := GetIconForFile(Application.ExeName, SHGFI_SMALLICON);
  AppIconLarge := GetIconForFile(Application.ExeName, SHGFI_LARGEICON);

finalization
  if Assigned(AppIcon) then begin
    AppIcon.ReleaseHandle;
    FreeAndNil(AppIcon);
  end;
  if Assigned(AppIconLarge) then begin
    AppIconLarge.ReleaseHandle;
    FreeAndNil(AppIconLarge);
  end;
  SetLength(HookedComponents, 0);

end.





