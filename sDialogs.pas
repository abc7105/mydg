unit sDialogs;
{$I sDefs.inc}

interface

uses
 Windows, Dialogs, Forms, Classes, SysUtils, Graphics, ExtDlgs, Controls, sConst, FileCtrl
 {$IFDEF TNTUNICODE} ,TntDialogs, TntExtDlgs, TntFileCtrl, MultiMon {$ENDIF};


type
{$IFNDEF NOTFORHELP}
  TsZipShowing = (zsAsFolder, zsAsFile);
{$ENDIF} // NOTFORHELP

{ TsOpenDialog }
{$IFDEF TNTUNICODE}
  TsOpenDialog = class(TTntOpenDialog)
{$else}
  TsOpenDialog = class(TOpenDialog)
{$ENDIF}
  private
    FZipShowing: TsZipShowing;
{$IFNDEF NOTFORHELP}
  public
    constructor Create(AOwner: TComponent); override;
{$ENDIF} // NOTFORHELP
  published
    property ZipShowing: TsZipShowing read FZipShowing write FZipShowing default zsAsFolder;
  end;

{ TsOpenPictureDialog }
{$IFDEF TNTUNICODE}
  TsOpenPictureDialog = class(TTntOpenPictureDialog)
{$else}
  TsOpenPictureDialog = class(TOpenPictureDialog)
{$ENDIF}
{$IFNDEF NOTFORHELP}
  private
    FPicture: TPicture;
    function IsFilterStored: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DoSelectionChange; override;
    procedure DoShow; override;
  published
    property Filter stored IsFilterStored;
{$ENDIF} // NOTFORHELP
  end;

{ TsSaveDialog }
{$IFDEF TNTUNICODE}
  TsSaveDialog = class(TTntSaveDialog)
{$else}
  TsSaveDialog = class(TSaveDialog)
{$ENDIF}
{$IFNDEF NOTFORHELP}
  public
{$ENDIF} // NOTFORHELP
  end;

{ TsSavePictureDialog }
{$IFDEF TNTUNICODE}
  TsSavePictureDialog = class(TTntSavePictureDialog)
{$else}
  TsSavePictureDialog = class(TSavePictureDialog)
{$ENDIF}
{$IFNDEF NOTFORHELP}
  private
    FPicture: TPicture;
    function IsFilterStored: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Filter stored IsFilterStored;
{$ENDIF} // NOTFORHELP
  end;

  TsColorDialog = class(TColorDialog)
{$IFNDEF NOTFORHELP}
  private
    FMainColors: TStrings;
    FStandardDlg : boolean;
    procedure SetMainColors(const Value: TStrings);
  public
    function Execute: Boolean; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DoShow; override;
    procedure DoClose; override;
  published
    property Options default [cdFullOpen];
{$ENDIF} // NOTFORHELP
    property MainColors: TStrings read FMainColors write SetMainColors;
    property StandardDlg : boolean read FStandardDlg write FStandardDlg default False; 
  end;

  TsPathDialog = class(TComponent)
{$IFNDEF NOTFORHELP}
  private
    FPath: TsDirectory;
    FRoot: TacRoot;
    FCaption: acString;
    FNoChangeDir: Boolean;
    FShowRootBtns: Boolean;
    FOptions: TSelectDirOpts;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
{$ENDIF} // NOTFORHELP
    function Execute: Boolean;
  published
    property Path : TsDirectory read FPath write FPath;
    property Root : TacRoot read FRoot write FRoot;
    property Caption : acString read FCaption write FCaption;
    property NoChangeDir : Boolean read FNoChangeDir write FNoChangeDir default False;
    property ShowRootBtns : boolean read FShowRootBtns write FShowRootBtns default False;
{$IFNDEF NOTFORHELP}
    property DialogOptions: TSelectDirOpts read FOptions write FOptions default [sdAllowCreate, sdPerformCreate, sdPrompt];
{$ENDIF} // NOTFORHELP
  end;

{$IFNDEF NOTFORHELP}
{ Message dialog }
function sCreateMessageDialog(const Title, Msg: acString; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons): TForm;
{$ENDIF} // NOTFORHELP

// Overloaded versions added RS 31/10/05 to allow title and message
function sMessageDlg(const Msg: acString; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: LongInt): Integer; overload;
function sMessageDlg(const Title, Msg: acString; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: LongInt): Integer; overload;
function sMessageDlgPos(const Msg: acString; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: LongInt; X, Y: Integer): Integer; overload;
function sMessageDlgPos(const Title, Msg: acString; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: LongInt; X, Y: Integer): Integer; overload;
function sMessageDlgPosHelp(const Title, Msg: acString; DlgType: TMsgDlgType; Buttons:
  TMsgDlgButtons; HelpCtx: LongInt; X, Y: Integer; const HelpFileName: acString): Integer;

procedure sShowMessage(const Msg: acString); overload;
procedure sShowMessage(const Title, Msg: acString); overload;
procedure sShowMessageFmt(const Msg: acString; const Params: array of const); overload;
procedure sShowMessageFmt(const Title, Msg: acString; const Params: array of const); overload;
procedure sShowMessagePos(const Msg: acString; X, Y: Integer); overload;
procedure sShowMessagePos(const Title, Msg: acString; X, Y: Integer); overload;

{ Input dialog }
function sInputBox(const ACaption, APrompt, ADefault: acString): acString;
function sInputQuery(const ACaption, APrompt: acString; var Value: acString): Boolean;


{$IFDEF TNTUNICODE}
function Application_MessageBoxW(const Text, Caption: PWideChar; Flags: Longint): Integer;
{$ENDIF}

implementation

uses
  Consts, sColorDialog, acPathDialog, acShellCtrls, sSkinManager, ShlObj, acDials,
  acntUtils;

var
{.$IFNDEF D2006
  Captions: array[TMsgDlgType] of Pointer = (@SMsgDlgWarning, @SMsgDlgError, @SMsgDlgInformation, @SMsgDlgConfirm, nil);
$ELSE}
  Captions: array[TMsgDlgType] of acString = ('Warning', 'Error', 'Information', 'Confirm', '');
{.$ENDIF}

function sCreateMessageDialog(const Title, Msg: acString; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons): TForm;
begin
  {$IFDEF TNTUNICODE}
  Result := WideCreateMessageDialog(Msg, DlgType, Buttons);
  {$else}
  Result := CreateMessageDialog(Msg, DlgType, Buttons);
  {$ENDIF}
end;

function sMessageDlg(const Msg: acString; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: LongInt): Integer;
begin
  Result := sMessageDlgPosHelp('', Msg, DlgType, Buttons, HelpCtx, -1, -1, '');
end;

function sMessageDlg(const Title, Msg: acString; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: LongInt): Integer;
begin
  Result := sMessageDlgPosHelp(Title, Msg, DlgType, Buttons, HelpCtx, -1, -1, '');
end;

function sMessageDlgPos(const Msg: acString; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: LongInt; X, Y: Integer): Integer;
begin
  Result := sMessageDlgPosHelp('', Msg, DlgType, Buttons, HelpCtx, X, Y, '');
end;

function sMessageDlgPos(const Title, Msg: acString; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: LongInt; X, Y: Integer): Integer;
begin
  Result := sMessageDlgPosHelp(Title, Msg, DlgType, Buttons, HelpCtx, X, Y, '');
end;

{$IFDEF TNTUNICODE}
function Application_MessageBoxW(const Text, Caption: PWideChar; Flags: Longint): Integer;
var
  ActiveWindow, TaskActiveWindow: HWnd;
  WindowList: Pointer;
  MBMonitor, AppMonitor: HMonitor;
  MonInfo: TMonitorInfo;
  Rect: TRect;
  FocusState: TFocusState;
begin
  with Application do begin
  {$IFDEF D2006}
    ActiveWindow := ActiveFormHandle;
  {$ELSE}
    ActiveWindow := GetActiveWindow;
  {$ENDIF}

    if ActiveWindow = 0 then
      TaskActiveWindow := Handle
    else
      TaskActiveWindow := ActiveWindow;

    MBMonitor := MonitorFromWindow(ActiveWindow, MONITOR_DEFAULTTONEAREST);
    AppMonitor := MonitorFromWindow(Handle, MONITOR_DEFAULTTONEAREST);
    if MBMonitor <> AppMonitor then
    begin
      MonInfo.cbSize := Sizeof(TMonitorInfo);
      GetMonitorInfo(MBMonitor, @MonInfo);
      GetWindowRect(Handle, Rect);
      SetWindowPos(Handle, 0,
        MonInfo.rcMonitor.Left + ((MonInfo.rcMonitor.Right - MonInfo.rcMonitor.Left) div 2),
        MonInfo.rcMonitor.Top + ((MonInfo.rcMonitor.Bottom - MonInfo.rcMonitor.Top) div 2),
        0, 0, SWP_NOACTIVATE or SWP_NOREDRAW or SWP_NOSIZE or SWP_NOZORDER);
    end;
    WindowList := DisableTaskWindows(ActiveWindow);
    FocusState := SaveFocusState;
    if UseRightToLeftReading then Flags := Flags or MB_RTLREADING;
    try
{$IFDEF DELPHI7UP}
      Application.ModalStarted;
{$ENDIF}      
      Result := MessageBoxW(TaskActiveWindow, Text, Caption, Flags);
{$IFDEF DELPHI7UP}
      Application.ModalFinished;
{$ENDIF}      
    finally
      if MBMonitor <> AppMonitor then
        SetWindowPos(Handle, 0,
          Rect.Left + ((Rect.Right - Rect.Left) div 2),
          Rect.Top + ((Rect.Bottom - Rect.Top) div 2),
          0, 0, SWP_NOACTIVATE or SWP_NOREDRAW or SWP_NOSIZE or SWP_NOZORDER);
      EnableTaskWindows(WindowList);
      SetActiveWindow(ActiveWindow);
      RestoreFocusState(FocusState);
    end;
  end;
end;
{$ENDIF}

procedure MsgBoxCallback(var lpHelpInfo: THelpInfo); stdcall;
begin
  if lpHelpInfo.dwContextId <> 0 then Application.HelpContext(lpHelpInfo.dwContextId);
end;

function sMessageDlgPosHelp(const Title, Msg: acString; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: LongInt; X, Y: Integer; const HelpFileName: acString): Integer;
const
  MB_HELP = $4000;
  MB_YESTOALL = $A000;
var
  Flags : Cardinal;
  Caption : acString;
{$IFDEF TNTUNICODE}
  mParams : TMsgBoxParamsW;
{$ELSE}
  mParams : TMsgBoxParams;
{$ENDIF}
begin
  case DlgType of
    mtWarning : Flags := MB_ICONWARNING;
    mtError : Flags := MB_ICONERROR;
    mtInformation : Flags := MB_ICONINFORMATION;
    mtConfirmation : Flags := MB_ICONQUESTION
    else Flags := 0;
  end;
//  Flags := Flags or MB_SYSTEMMODAL;
  if Title = '' then Caption := Captions[DlgType] else Caption := Title;

  if mbOk in Buttons then begin
    if mbCancel in Buttons then Flags := Flags or MB_OKCANCEL else Flags := Flags or MB_OK;
  end
  else if (mbAbort in Buttons) or (mbIgnore in Buttons) then Flags := Flags or MB_ABORTRETRYIGNORE
  else if (mbYes in Buttons) or (mbNo in Buttons) then begin
    if mbCancel in Buttons then Flags := Flags or MB_YESNOCANCEL else Flags := Flags or MB_YESNO;
  end
  else if mbRetry in Buttons then Flags := Flags or MB_RETRYCANCEL;

  if mbHelp in Buttons then Flags := Flags or MB_HELP;

  DlgLeft := X; DlgTop := Y;
{$IFDEF DELPHI7UP}
  Application.ModalStarted;
{$ENDIF}

  FillChar(mParams, SizeOf(mParams), 0);
  mParams.cbSize := SizeOf(mParams);
  mParams.dwContextHelpId := HelpCtx;
  mParams.dwStyle := Flags;
  mParams.lpszCaption := PacChar(Caption);
  mParams.lpszText := PacChar(Msg);
  mParams.hwndOwner := Application.Handle;
{$T-}
  mParams.lpfnMsgBoxCallback := @MsgBoxCallback;
{$T+}

{$IFDEF TNTUNICODE}
  Result := integer(MessageBoxIndirectW(mParams));
{$ELSE}
  Result := integer(MessageBoxIndirect(mParams));
{$ENDIF}

(*
  if GetActiveWindow = 0 then begin // Application will not be set foreground if haven't actve window still
{$IFDEF TNTUNICODE}
    Result := MessageBoxW(Application.Handle, PWideChar(Msg), PWideChar(Caption), Flags);
{$ELSE}
    Result := MessageBox(Application.Handle, PacChar(Msg), PacChar(Caption), Flags);
{$ENDIF}
  end
  else begin
{$IFDEF TNTUNICODE}
    Result := Application_MessageBoxW(PWideChar(Msg), PWideChar(Caption), Flags);
{$ELSE}
    Result := Application.MessageBox(PacChar(Msg), PacChar(Caption), Flags);
{$ENDIF}
  end;
*)
{$IFDEF DELPHI7UP}
  Application.ModalFinished;
{$ENDIF}
  DlgLeft := -1; DlgTop := -1;
end;


procedure sShowMessage(const Msg: acString);
begin
  sShowMessagePos(Msg, -1, -1);
end;

procedure sShowMessage(const Title, Msg: acString);
begin
  sShowMessagePos(Title, Msg, -1, -1);
end;

procedure sShowMessageFmt(const Msg: acString; const Params: array of const);
begin
  sShowMessage(Format(Msg, Params));
end;

procedure sShowMessageFmt(const Title, Msg: acString; const Params: array of const);
begin
  sShowMessage(Title, Format(Msg, Params));
end;

procedure sShowMessagePos(const Msg: acString; X, Y: Integer);
begin
  sMessageDlgPos(Msg, mtCustom, [mbOK], 0, X, Y);
end;

procedure sShowMessagePos(const Title, Msg: acString; X, Y: Integer);
begin
  sMessageDlgPos(Title, Msg, mtCustom, [mbOK], 0, X, Y);
end;

{ Input dialog }

function sInputQuery(const ACaption, APrompt: acString; var Value: acString): Boolean;
begin
{$IFDEF TNTUNICODE}
  Result := WideInputQuery(ACaption, APrompt, Value);
{$ELSE}
  Result := InputQuery(ACaption, APrompt, Value);
{$ENDIF}
end;

function sInputBox(const ACaption, APrompt, ADefault: acString): acString;
begin
  Result := ADefault;
  sInputQuery(ACaption, APrompt, Result);
end;

{ TsOpenDialog }

constructor TsOpenDialog.Create(AOwner: TComponent);
begin
  inherited;
  FZipShowing := zsAsFolder;
end;

{ TsOpenPictureDialog }

constructor TsOpenPictureDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Filter := GraphicFilter(TGraphic);
end;

destructor TsOpenPictureDialog.Destroy;
begin
  if Assigned(FPicture) then FreeAndNil(FPicture);
  inherited;
end;

procedure TsOpenPictureDialog.DoSelectionChange;
begin
  if csDestroying in ComponentState then Exit;
  inherited DoSelectionChange;
end;

procedure TsOpenPictureDialog.DoShow;
begin
  inherited DoShow;
end;

function TsOpenPictureDialog.IsFilterStored: Boolean;
begin
  Result := not (Filter = GraphicFilter(TGraphic));
end;

{ TsSavePictureDialog }

constructor TsSavePictureDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Filter := GraphicFilter(TGraphic);
end;

destructor TsSavePictureDialog.Destroy;
begin
  if Assigned(FPicture) then FreeAndNil(FPicture);
  inherited;
end;

function TsSavePictureDialog.IsFilterStored: Boolean;
begin
  Result := not (Filter = GraphicFilter(TGraphic));
end;

{ TsColorDialog }

constructor TsColorDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMainColors := TStringList.Create;
  FStandardDlg := False;
  Options := [cdFullOpen];
end;

destructor TsColorDialog.Destroy;
begin
  FreeAndNil(FMainColors);
  inherited Destroy;
end;

procedure TsColorDialog.DoClose;
begin
  inherited;
end;

procedure TsColorDialog.DoShow;
begin
  inherited;
end;

function TsColorDialog.Execute: Boolean;
const
  MaxWidth = 545;
  MinWidth = 235;
begin
  if not FStandardDlg and Assigned(DefaultManager) then begin
    sColorDialogForm := TsColorDialogForm.Create(Application);
    sColorDialogForm.InitLngCaptions;
    sColorDialogForm.Owner := Self;
    if CustomColors.Count > 0 then begin
      sColorDialogForm.AddPal.Colors.Assign(CustomColors);
      sColorDialogForm.AddPal.GenerateColors;
    end;
    if MainColors.Count > 0 then begin
      sColorDialogForm.MainPal.Colors.Assign(MainColors);
      sColorDialogForm.MainPal.GenerateColors;
    end;

    sColorDialogForm.ModalResult := mrCancel;
    sColorDialogForm.BorderStyle := bsSingle;

    sColorDialogForm.sBitBtn4.Enabled := not (cdFullOpen in Options);
    if sColorDialogForm.sBitBtn4.Enabled then sColorDialogForm.Width := MinWidth else sColorDialogForm.Width := MaxWidth;
    if (cdPreventFullOpen in Options) then
      sColorDialogForm.sBitBtn4.Enabled := False;
    sColorDialogForm.sBitBtn5.Visible := (cdShowHelp in Options);

    sColorDialogForm.sSkinProvider1.PrepareForm;
    sColorDialogForm.SelectedPanel.Brush.Color := Color;
    sColorDialogForm.ShowModal;
    Result := sColorDialogForm.ModalResult = mrOk;
    CustomColors.Assign(sColorDialogForm.AddPal.Colors);
    DoClose;
    if Result then Color := sColorDialogForm.SelectedPanel.Brush.Color;

    if sColorDialogForm <> nil then sColorDialogForm.Free;
  end
  else Result := inherited Execute;
end;

procedure TsColorDialog.SetMainColors(const Value: TStrings);
begin
  FMainColors.Assign(Value);
end;

{ TsPathDialog }

constructor TsPathDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRoot := SRFDesktop;
  FNoChangeDir := False;
  FShowRootBtns := False;
  FOptions := [sdAllowCreate, sdPerformCreate, sdPrompt];
end;

destructor TsPathDialog.Destroy;
begin
  inherited;
end;

function TsPathDialog.Execute: Boolean;
var
  s: acString;
  bw : integer;
begin
  Result := False;
  s := Path;
  if not acDirExists(s) or (s = '.') then s := '';
  if not NoChangeDir and (s <> '') then acSetCurrentDir(s);

  PathDialogForm := TPathDialogForm.Create(Application);
  PathDialogForm.InitLngCaptions;
  PathDialogForm.sBitBtn3.Visible := sdAllowCreate in DialogOptions;
  if ShowRootBtns then begin
    PathDialogForm.sScrollBox1.Visible := True;
    PathDialogForm.sLabel1.Visible := True;
    bw := GetSystemMetrics(SM_CXSIZEFRAME);
    PathDialogForm.sShellTreeView1.Left := PathDialogForm.sShellTreeView1.Left + PathDialogForm.sScrollBox1.Width + 4;
    PathDialogForm.sBitBtn1.Left := PathDialogForm.sBitBtn1.Left + PathDialogForm.sScrollBox1.Width + 4;
    PathDialogForm.sBitBtn2.Left := PathDialogForm.sBitBtn2.Left + PathDialogForm.sScrollBox1.Width + 4;

    PathDialogForm.Width := PathDialogForm.Width + PathDialogForm.sScrollBox1.Width + 4 + bw;

    PathDialogForm.GenerateButtons;
  end
  else begin
    PathDialogForm.sScrollBox1.Visible := False;
    PathDialogForm.sLabel1.Visible := False;
  end;
  PathDialogForm.UpdateAnchors;
  try
    PathDialogForm.sShellTreeView1.BoundLabel.Caption := Caption;
    PathDialogForm.sShellTreeView1.Root := FRoot;
    if (s = '') then begin
      if PathDialogForm.sShellTreeView1.Items.Count > 0 then PathDialogForm.sShellTreeView1.Items[0].Selected := True;
    end
    else begin
      PathDialogForm.sShellTreeView1.Path := s;
    end;
    if PathDialogForm.ShowModal = mrOk then begin
      s := PathDialogForm.sShellTreeView1.Path;
      if (s <> '') and acDirExists(s) then Path := s;
      Result := True
    end;
  finally
    FreeAndNil(PathDialogForm);
  end;
end;

end.
