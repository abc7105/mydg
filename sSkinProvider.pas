unit sSkinProvider;
{$I sDefs.inc}
{.$DEFINE LOGGED}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Forms, Dialogs, sDefaults, menus, sSkinMenus, sSkinManager, acPNG, ExtCtrls, acGlow, Buttons, acThdTimer,
  sConst, sCommondata, Controls, acSBUtils{$IFDEF DELPHI7UP}, Types{$ENDIF}{$IFDEF TNTUNICODE}, TntWideStrUtils, TntMenus, TntStdCtrls, TntControls{$ENDIF};

type
{$IFNDEF NOTFORHELP}
  TacGraphItem = class(TPersistent)
  public
    Ctrl : TControl;
    SkinData : TsCommonData;
    Adapter : TObject;
    Handler : TacSpeedButtonHandler;
    constructor Create; virtual;
    destructor Destroy; override;
    procedure DoHook(Control : TControl); virtual;
  end;

  TacAdapterItem = class(TPersistent)
  public
    WinCtrl : TWinControl;
    SkinData : TsCommonData;
    OldFontColor : integer;
    Adapter : TObject;
    ScrollWnd : TacMainWnd;
    constructor Create; virtual;
    destructor Destroy; override;
    procedure DoHook(Control : TWinControl); virtual;
  end;
{$ENDIF} // NOTFORHELP
                                                                                          
  TAddItemEvent = procedure(Item: TComponent; var CanBeAdded: boolean; var SkinSection: string) of object;
  TsSkinProvider = class;
{$IFNDEF NOTFORHELP}
  TacNCHitTest = procedure(var Msg: TWMNcHitTest) of object;

  TacAnimEvent = (aeShowing, aeHiding, aeSkinChanging);
  TacAfterAnimation = procedure(AnimType : TacAnimEvent) of object;
  TacBorderForm = class;
  TacSBAnimation = class;
{$ENDIF}

  TsGripMode = (gmNone, gmRightBottom);
  TsResizeMode = (rmStandard, rmBorder);

{$IFNDEF NOTFORHELP}
  TsSystemMenu = class;
  TacCtrlAdapter = class;
  TsCaptionButton = record
    State : integer;
    ImageIndex : integer;
    Rect : TRect;
    HaveAlignment : boolean;
    GlowID : integer;
    Timer : TacSBAnimation;
    HitCode : Cardinal;
  end;

  PsCaptionButton = ^TsCaptionButton;

  TacAddedTitle = class(TPersistent)
  private
    FShowMainCaption: boolean;
    procedure SetShowMainCaption(const Value: boolean);
  protected
    FText : acString;
    FFont : TFont;
    procedure SetText(const Value: acString);
    procedure SetFont(const Value: TFont);
    procedure Repaint;
  public
    FOwner : TsSkinProvider;
    constructor Create; virtual;
    destructor Destroy; override;
  published
    property Font : TFont read FFont write SetFont;
    property Text : acString read FText write SetText;
    property ShowMainCaption : boolean read FShowMainCaption write SetShowMainCaption default True;
  end;

{$ENDIF} // NOTFORHELP

  TsTitleButton = class(TCollectionItem)
{$IFNDEF NOTFORHELP}
  private
    FUseSkinData: boolean;
    FName: string;
    FGlyph: TBitmap;
    FOnMouseUp: TMouseEvent;
    FOnMouseDown: TMouseEvent;
    FEnabled: boolean;
    FHint: acString;
    FVisible: boolean;
    procedure SetGlyph(const Value: TBitmap);
    procedure SetName(const Value: string);
    procedure MouseDown(BtnIndex : integer; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MouseUp(BtnIndex : integer; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SetVisible(const Value: boolean);
    procedure OnGlyphChange(Sender: TObject);
  public
{$IFDEF TNTUNICODE}
    HintWnd : TTntHintWindow;
{$ELSE}
    HintWnd : THintWindow;
{$ENDIF}
    BtnData : TsCaptionButton;
    procedure AssignTo(Dest: TPersistent); override;
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    function GetDisplayName: string; override;
  published
{$ENDIF} // NOTFORHELP
    property Enabled : boolean read FEnabled write FEnabled default True;
    property Glyph : TBitmap read FGlyph write SetGlyph;
    property Hint : acString read FHint write FHint;
    property Name : string read FName write SetName;
    property UseSkinData : boolean read FUseSkinData write FUseSkinData default True;
    property Visible : boolean read FVisible write SetVisible default True;
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
  end;

  TsTitleButtons = class(TCollection)
{$IFNDEF NOTFORHELP}
  private
    FOwner: TsSkinProvider;
    function GetItem(Index: Integer): TsTitleButton;
    procedure SetItem(Index: Integer; Value: TsTitleButton);
  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TsSkinProvider);
    destructor Destroy; override;
{$ENDIF} // NOTFORHELP
    property Items[Index: Integer]: TsTitleButton read GetItem write SetItem; default;
  end;

  TsTitleIcon = class (TPersistent)
{$IFNDEF NOTFORHELP}
  private
    FGlyph: TBitmap;
    FHeight: integer;
    FWidth: integer;
    procedure SetGlyph(const Value: TBitmap);
    procedure SetHeight(const Value: integer);
    procedure SetWidth(const Value: integer);
  public
    constructor Create;
    destructor Destroy; override;
  published
{$ENDIF} // NOTFORHELP
    property Glyph : TBitmap read FGlyph write SetGlyph;
    property Height : integer read FHeight write SetHeight default 0;
    property Width : integer read FWidth write SetWidth default 0;
  end;

  TsSkinProvider = class(TComponent)
{$IFNDEF NOTFORHELP}
  private
    ArOR : TAOR;
    RgnChanged : boolean;
    CurrentHT : integer;
    TempBmp : TBitmap;

    FMakeSkinMenu: boolean;
    FShowAppIcon: boolean;
    ControlsChanged : boolean;
    HaveSysMenu : boolean;

    FCaptionAlignment: TAlignment;
    FTitleIcon: TsTitleIcon;
    FTitleButtons: TsTitleButtons;
    FGripMode: TsGripMode;
    FCommonData: TsCommonData;
    FResizeMode: TsResizeMode;
    FirstInitialized : boolean;
    FScreenSnap: boolean;
    FSnapBuffer: integer;
    FUseGlobalColor: boolean;
    FTitleSkin: TsSkinSection;
    FMenuLineSkin: TsSkinSection;
    UserBtnIndex : integer;
    FOnSkinItem: TAddItemEvent;
    FDrawNonClientArea: boolean;
    FAllowExtBorders: boolean;
    FOnExtHitTest: TacNCHitTest;
    FOnAfterAnimation: TacAfterAnimation;
    FAddedTitle: TacAddedTitle;

    FAllowBlendOnMoving: boolean;

    procedure OnChildMnuClick(Sender: TObject);
    procedure SetCaptionAlignment(const Value: TAlignment);
    procedure SetShowAppIcon(const Value: boolean);
    procedure SetTitleButtons(const Value: TsTitleButtons);
    procedure SetUseGlobalColor(const Value: boolean);
    function GetLinesCount : integer; // Returns a count of menu lines
    procedure SetTitleSkin(const Value: TsSkinSection);
    procedure SetMenuLineSkin(const Value: TsSkinSection);
    procedure SetDrawNonClientArea(const Value: boolean);
    procedure SetAllowExtBorders(const Value: boolean);
  protected
    LockCount : integer;
    ClearButtons : boolean;
    MenusInitialized : boolean;
    RegionChanged : boolean;
    CaptChanged : boolean;
    CaptRgnChanged : boolean;

    FGlow1, FGlow2 : TBitmap;
    CoverForm : TForm;
    CoverBmp : TBitmap;
    NormalBounds : TRect;

    ButtonMin : TsCaptionButton;
    ButtonMax : TsCaptionButton;
    ButtonClose : TsCaptionButton;
    ButtonHelp : TsCaptionButton;
    MDIMin : TsCaptionButton;
    MDIMax : TsCaptionButton;
    MDIClose : TsCaptionButton;

    LastClientRect : TRect;
    FSysExHeight : boolean;
    FTitleSkinIndex : integer;
    FCaptionSkinIndex : integer;
    FormTimer : TacThreadedTimer;

    procedure AssignTo(Dest: TPersistent); override;
    procedure AdapterRemove;
    procedure AdapterCreate; virtual;
    procedure SendToAdapter(Message : TMessage);
    // Painting procedures <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    procedure PaintAll;
    procedure PaintForm(DC : hdc; SendUpdated : boolean = True);
    procedure PaintCaption(DC : hdc);
    procedure PaintBorderIcons;
    procedure RepaintButton(i : integer);
    procedure RepaintMenuItem(mi : TMenuItem; R : TRect; State : TOwnerDrawState);
    procedure MakeTitleBG;
    procedure SaveBGForBtns(Full : boolean = False);
    procedure RestoreBtnsBG;

    procedure OurPaintHandler(const Msg : TWMPaint);
    procedure AC_WMEraseBkGnd(aDC: hdc);
    procedure AC_WMNCPaint;
    procedure AC_WMNCCalcSize(var Message : TWMNCCalcSize);
    procedure AC_WMGetMinMaxInfo(var Message : TWMGetMinMaxInfo);
{$IFNDEF ALITE}
    procedure AC_CMMouseWheel(var Message : TCMMouseWheel);
{$ENDIF}
//    procedure AC_WMDrawItem(var Message : TWMDrawItem);
    procedure AC_WMInitMenuPopup(var Message : TWMInitMenuPopup);
//    procedure AC_WMWindowPosChanged(const Msg : TWMWindowPosMsg);

    // Special calculations <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    function HTProcess(var Message : TWMNCHitTest) : integer;
    function CursorToPoint(x, y : integer) : TPoint;
    function MDIButtonsNeeded : boolean;
    function RBGripPoint(ImgIndex : integer) : TPoint;
    function IconRect : TRect;
    function FormLeftTop : TPoint;
    function SysButtonsCount : integer;
    function SmallButtonWidth : integer;
    function ButtonHeight : integer;
    function SmallButtonHeight : integer;

    function SysButtonWidth(Btn : TsCaptionButton) : integer;
    function TitleBtnsWidth : integer;
    function UserButtonWidth(Btn : TsTitleButton) : integer;
    function BarWidth(i : integer) : integer;
    // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    procedure KillAnimations;
    procedure UpdateIconsIndexes;

    procedure StartMove(X, Y: Integer);
    procedure StopMove(X, Y: Integer);
    procedure DrawFormBorder(X, Y: Integer);

    procedure SetHotHT(i : integer; Repaint : boolean = True);
    procedure SetPressedHT(i : integer);

    function FormChanged : boolean;
    function IconVisible : boolean;
    function TitleSkinSection : string;
    function TitleSkinIndex : integer;
    procedure CheckSysMenu(const Skinned : boolean);
    procedure InitExBorders(const Active : boolean);
  public
    RTInit : boolean;
    RTEmpty : boolean;
    InAero : boolean;
    InMenu : boolean;
    FInAnimation : boolean;
    ShowAction : TShowAction;
    SkipAnimation : boolean;

    fAnimating : boolean;
    ListSW : TacScrollWnd;
    Adapter : TacCtrlAdapter;
    FormState : Cardinal;

    RgnChanging : boolean;

    MenuChanged : boolean;
    OldWndProc: TWndMethod;
    MDIForm : TObject;
    FormActive : boolean;

    MenuLineBmp : TBitmap;

    Form : TForm;
    FLinesCount : integer;
    SystemMenu : TsSystemMenu;
    CaptForm : TForm;
    OldCaptFormProc : TWndMethod;
    BorderForm : TacBorderForm;

    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    constructor CreateRT(AOwner : TComponent; InitRT : boolean = True);
    procedure DropSysMenu(x, y : integer);
    procedure AfterConstruction; override;
    procedure Loaded; override;
    procedure LoadInit;
    procedure PrepareForm;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    function OffsetX : integer;
    function OffsetY : integer;
    function ShadowSize : TRect;

    procedure NewWndProc(var Message: TMessage); // Main window procedure hook
    procedure DsgnWndProc(var Message: TMessage); // Main window procedure hook for design-time
    procedure HookMDI(Active : boolean = True);
    function HeaderHeight : integer;  // Height of the header + menu lines
    function BorderHeight(CheckSkin : boolean = True): integer;
    function BorderWidth(CheckSkin : boolean = True): integer;
    function CaptionHeight(CheckSkin : boolean = True) : integer;
    function CaptionWidth : integer;
    function MenuHeight : integer;
    function MenuPresent : boolean;
    function FormColor : TColor;

    procedure MdiIcoFormPaint(Sender : TObject);
    procedure CaptFormPaint(Sender : TObject);
    procedure NewCaptFormProc(var Message: TMessage);


    function UpdateMenu : boolean;
    procedure InitMenuItems(A: boolean);
    procedure RepaintMenu;
    property LinesCount : integer read GetLinesCount;
  published
{$ENDIF} // NOTFORHELP
    property AddedTitle : TacAddedTitle read FAddedTitle write FAddedTitle;
    property AllowExtBorders : boolean read FAllowExtBorders write SetAllowExtBorders default True;
    property AllowBlendOnMoving : boolean read FAllowBlendOnMoving write FAllowBlendOnMoving default True;
    property CaptionAlignment : TAlignment read FCaptionAlignment write SetCaptionAlignment default taLeftJustify;
    property DrawNonClientArea : boolean read FDrawNonClientArea write SetDrawNonClientArea default True;
    property SkinData : TsCommonData read FCommonData write FCommonData;
    property GripMode : TsGripMode read FGripMode write FGripMode default gmNone;
    property MakeSkinMenu : boolean read FMakeSkinMenu write FMakeSkinMenu default DefMakeSkinMenu;
    property MenuLineSkin : TsSkinSection read FMenuLineSkin write SetMenuLineSkin;
    property ResizeMode : TsResizeMode read FResizeMode write FResizeMode default rmStandard; // MarkB
    property ScreenSnap : boolean read FScreenSnap write FScreenSnap default False;
    property SnapBuffer : integer read FSnapBuffer write FSnapBuffer default 10;
    property ShowAppIcon : boolean read FShowAppIcon write SetShowAppIcon default True;
    property TitleButtons : TsTitleButtons read FTitleButtons write SetTitleButtons;
    property TitleIcon : TsTitleIcon read FTitleIcon write FTitleIcon;
    property TitleSkin : TsSkinSection read FTitleSkin write SetTitleSkin;
    property UseGlobalColor : boolean read FUseGlobalColor write SetUseGlobalColor default True;
    property OnAfterAnimation : TacAfterAnimation read FOnAfterAnimation write FOnAfterAnimation;
    property OnExtHitTest : TacNCHitTest read FOnExtHitTest write FOnExtHitTest;
    property OnSkinItem: TAddItemEvent read FOnSkinItem write FOnSkinItem;
  end;

{$IFNDEF NOTFORHELP}

  TacSBAnimation = class(TTimer)
  public
    BorderForm : TacBorderForm;
    SkinData : TsCommonData;
    FormHandle : hwnd;

    PBtnData : PsCaptionButton;
    CurrentLevel : integer;
    CurrentState : integer;
    Up : boolean;
    MaxIterations : integer;
    AForm : TForm;
    ABmp : TBitmap;
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    function GetFormBounds : TRect;
    function Offset : integer;
    function Step : integer;
    procedure MakeForm;
    procedure UpdateForm(const Blend: integer);
    procedure StartAnimation(NewState : integer; ToUp : boolean);
    procedure ChangeState(NewState : integer; ToUp : boolean);
    procedure MakeImg;
    procedure CheckMouseLeave;
    procedure OnAnimTimer(Sender: TObject);
  end;

  TacBorderForm = class(TPersistent)
  protected
    FOwner : TObject;
    sp : TsSkinProvider;
  public
    acInMouseMsg : boolean;
    AForm : TForm;
    OldBorderProc: TWndMethod;
    ExBorderShowing : boolean;
    ShadowTemplate : TBitmap;
    ParentHandle : THandle;
    SkinData : TsCommonData;

    constructor Create(AOwner : TObject);
    procedure CreateNewForm;
    destructor Destroy; override;
    procedure KillAnimations;
    function OffsetX : integer;
    function OffsetY : integer;

    // Access from owners
    function ButtonMin : TsCaptionButton;
    function ButtonMax : TsCaptionButton;
    function ButtonClose : TsCaptionButton;
    function ButtonHelp : TsCaptionButton;
    function OwnerHandle : hwnd;
    function ShadowSize : TRect;
    function CaptionHeight(CheckSkin : boolean = True) : integer;
    function MenuHeight : integer;
    function IconRect : TRect;
    procedure SetHotHT(const i: integer; Repaint : boolean = True);
    procedure PaintAll;
    function MakeRgn(NewWidth : integer = 0; NewHeight : integer = 0) : HRGN;
    function FormState : cardinal;

    function MouseAboveTheShadow(Message : TWMMouse) : boolean;
    procedure BorderProc(var Message : TMessage);

    procedure UpdateExBordersPos(Redraw : boolean = True; Blend : byte = MaxByte);

    function Ex_WMNCHitTest(var Message : TWMNCHitTest) : integer;
    function Ex_WMSetCursor(var Message: TWMSetCursor) : boolean;
  end;

{$IFDEF TNTUNICODE}
  TsCustomSysMenu = class(TTntPopupMenu)
{$ELSE}
  TsCustomSysMenu = class(TPopupMenu)
{$ENDIF}
    function VisibleClose : boolean; virtual; abstract;
    function VisibleMax : boolean; virtual; abstract;
    function VisibleMin : boolean; virtual; abstract;

    function EnabledMax : boolean; virtual; abstract;
    function EnabledMin : boolean; virtual; abstract;
    function EnabledRestore : boolean; virtual; abstract;
  end;

  TsSystemMenu = class(TsCustomSysMenu)
  public
    ExtItemsCount : integer;
    FOwner : TsSkinProvider;
    FForm : TCustomForm;
    ItemRestore : TMenuItem;
    ItemMove : TMenuItem;
    ItemSize : TMenuItem;
    ItemMinimize : TMenuItem;
    ItemMaximize : TMenuItem;
    ItemClose : TMenuItem;

    constructor Create(AOwner : TComponent); override;
    procedure Generate;
    procedure UpdateItems(Full : boolean = False);
    procedure UpdateGlyphs;
    procedure MakeSkinItems;

    function VisibleRestore : boolean;
    function VisibleSize : boolean;
    function VisibleMin : boolean; override;
    function VisibleMax : boolean; override;
    function VisibleClose : boolean; override;

    function EnabledRestore : boolean; override;
    function EnabledMove    : boolean;
    function EnabledSize    : boolean;
    function EnabledMin     : boolean; override;
    function EnabledMax     : boolean; override;

    procedure RestoreClick(Sender: TObject);
    procedure MoveClick(Sender: TObject);
    procedure SizeClick(Sender: TObject);
    procedure MinClick(Sender: TObject);
    procedure MaxClick(Sender: TObject);
    procedure CloseClick(Sender: TObject);
    procedure SkinSelect(Sender: TObject);
    procedure ExtClick(Sender: TObject);
  end;

{$IFNDEF NOTFORHELP}
  TacAdapterItems = array of TacAdapterItem;
  TacGraphItems = array of TacGraphItem;
{$ENDIF}

  TacCtrlAdapter = class(TPersistent)
{$IFNDEF NOTFORHELP}
  public
    CtrlClass : TObject;//sCtrlClass;
    DefaultSection : string;
    Items : TacAdapterItems;
    GraphItems : TacGraphItems;
    Provider : TsSkinProvider;
    function IsControlSupported(Control : TComponent) : boolean; virtual;
    function Count : integer;
    constructor Create(AProvider: TsSkinProvider);
    destructor Destroy; override;
    function GetItem(Index : integer) : TacAdapterItem; virtual;
    function GetCommonData(Index : integer) : TsCommonData; virtual;
    function IndexOf(Ctrl : TWinControl) : integer;
    procedure AfterConstruction; override;
{$ENDIF} // NOTFORHELP
    procedure AddAllItems(OwnerCtrl : TWinControl = nil);// CheckHandle : boolean = True);
    procedure AddNewItem(const Ctrl : TSpeedButton); overload; virtual;
    procedure AddNewItem(const Ctrl : TWinControl); overload; virtual;
    procedure AddNewItem(const Ctrl : TWinControl; const SkinSection : string); overload; virtual;
    procedure RemoveItem(Index : integer); virtual;
    procedure RemoveAllItems;
    procedure CleanItems;
    procedure WndProc(var Message: TMessage); virtual;
  end;

  TacMoveTimer = class(TacThreadedTimer)
  public
    BlendValue : byte;
    CurrentBlendValue : byte;
    BlendStep : byte;
    SP : TsSkinProvider;
    BorderForm : TacBorderForm;
    FormHandle : THandle;
    procedure TimeHandler; override;
  end;

  TacMinTimer = class(TacThreadedTimer)
  public
    RectFrom : TRect;
    RectTo : TRect;

    CurLeft : real;
    CurTop : real;
    CurRight : real;
    CurBottom : real;

    DeltaX : real;
    DeltaY : real;
    XFrom : integer;
    XTo : integer;
    YFrom : integer;
    YTo : integer;
    DeltaW : real;
    DeltaH : real;

    AlphaOrigin : byte;
    AlphaFrom : byte;
    AlphaTo : byte;
    CurrentAlpha : byte;
    BlendStep : real;

    AnimForm : TForm;

    TBPosition : Cardinal;

    sp : TsSkinProvider;
    BorderForm : TacBorderForm;
    FormHandle : THandle;
    SavedImage : TBitmap;
    AlphaBmp : TBitmap;
    Minimized : boolean;
    StepCount : integer;
    AlphaFormWasCreated : boolean;
    constructor Create(AOwner: TComponent); override;
    constructor CreateOwned(AOwner: TComponent; ChangeEvent : boolean); override;
    destructor Destroy; override;
    function GetRectTo : TRect;
    procedure InitData;
    procedure UpdateDstRect;
    procedure TimeHandler; override;
  end;

const
  UserButtonsOffset = 8;
  ScrollWidth = 18;
  IconicHeight = 26;
  HTUDBTN = 1000;
//  HTCHILDSYSMENU = 1001;

  // FormStates
  FS_SIZING = $1;
  FS_BLENDMOVING = $80;
  FS_ANIMMINIMIZING = $100;
  FS_ANIMCLOSING = $200;
  FS_ANIMRESTORING = $400;
  FS_THUMBDRAWING = $800;
  FS_CHANGING = $1000;

  FS_MAXHEIGHT = $2000;
  FS_MAXWIDTH = $4000;
  FS_ACTIVATE = $8000;

  FS_MAXBOUNDS = FS_MAXHEIGHT or FS_MAXWIDTH;

  FS_FULLPAINTING = FS_CHANGING or FS_BLENDMOVING or FS_ANIMMINIMIZING;

var
  Style : LongInt;
  HotItem : TMenuItemData;
  SelectedMenuItem : TMenuItem;
  FSysWndCaptHeight : integer = 0;
  FSysToolCaptHeight : integer = 0;
{$IFNDEF ALITE}
  acTaskBarChanging : boolean = False;
{$ENDIF}

  bInProcess  : boolean = False;
  DoStartMove : boolean = False;
  bCapture    : Boolean = False;
  bFlag       : boolean = False;
  bRemoving   : boolean = False;
  bMode       : Boolean; // True - move, False - size
  deskwnd     : HWND;
  formDC      : HDC;
  ntop, nleft, nbottom, nright, nX, nY, nDirection, nMinHeight, nMinWidth, nDC : Integer;

  hDWMAPI: HMODULE = 0;

function AeroIsEnabled : boolean;
function ForbidSysAnimating : boolean;
//function UseAero : boolean;
procedure InitDwmApi;
procedure InitDwm(const Handle : THandle; const Skinned : boolean; const Repaint : boolean = False);
function DwmSetWindowAttribute(hwnd: HWND; dwAttribute: DWORD; pvAttribute: Pointer; cbAttribute: DWORD): HResult;
procedure DwmInvalidateIconicBitmaps(hwnd: HWND);
function BigButtons(sp : TsSkinProvider) : boolean;
function IsBorderUnchanged(const BorderIndex : integer; const sm : TsSkinManager) : boolean;
function IsGripVisible(const sp : TsSkinProvider) : boolean;
function InAnimation(const sp : TsSkinProvider) : boolean;
procedure PaintGrip(const aDC : hdc; const sp : TsSkinProvider);
function CtrlIsReadyForHook(const Ctrl : TWinControl) : boolean;
procedure UpdateRgn(sp : TsSkinProvider; Repaint : boolean = True);
procedure FillArOR(sp : TsSkinProvider);
function GetRgnFromArOR(sp : TsSkinProvider; X : integer = 0; Y : integer = 0) : hrgn;
procedure UpdateSkinCaption(SkinProvider : TsSkinProvider);
function GetSkinProvider(Cmp : TComponent) : TsSkinProvider;
procedure DrawAppIcon(SkinProvider : TsSkinProvider);
function GetWindowWidth(Handle : hwnd) : integer;
function GetClientWidth(Handle : hwnd) : integer;
function GetWindowHeight(Handle : hwnd) : integer;
function GetClientHeight(Handle : hwnd) : integer;
procedure ForbidDrawing(sp : TsSkinProvider; MDIAlso : boolean = False);
procedure PermitDrawing(sp : TsSkinProvider; MDIAlso : boolean = False);
function HaveBorder(sp : TsSkinProvider) : boolean;
procedure UpdateMainForm(UpdateNow : boolean = True);
function acWorkRect(Form : TForm) : TRect;
function DoLayered(FormHandle : Hwnd; Layered : boolean) : boolean;

function SkinMenuOffset(const sp : TsSkinProvider) : TPoint;
function SkinTitleHeight(const BorderForm : TacBorderForm) : integer;
function SkinBorderWidth(const BorderForm : TacBorderForm) : integer;
function DiffTitle(const BorderForm : TacBorderForm) : integer;
function DiffBorder(const BorderForm : TacBorderForm) : integer;
function SysBorderWidth(const Handle : hwnd; const BorderForm : TacBorderForm; CheckSkin : boolean = True): integer;
function SysBorderHeight(const Handle : hwnd; const BorderForm : TacBorderForm; CheckSkin : boolean = True): integer;
function SysCaptHeight(Form : TForm) : integer;

{$IFNDEF NOWNDANIMATION}
procedure StartMinimizing(sp : TsSkinProvider);
function StartRestoring(sp : TsSkinProvider) : boolean;

procedure StartBlendOnMoving(sp : TsSkinProvider);
procedure FinishBlendOnMoving(sp : TsSkinProvider);
{$ENDIF}

procedure PaintFormTo(DstBmp : TBitmap; sp : TsSkinProvider);
procedure SetFormBlendValue(FormHandle : THandle; Bmp : TBitmap; Value : integer; NewPos : PPoint = nil);
function MakeCoverForm(Wnd : THandle) : TForm;

procedure StartSBAnimation(const Btn: PsCaptionButton; const State: integer; const Iterations : integer; const ToUp : boolean; const SkinProvider : TsSkinProvider; acDialog : pointer = nil);

function ShellTrayWnd : THandle;
{$IFNDEF DELPHI6UP}
function GetWindowThreadProcessId(hWnd: THandle; var dwProcessId: DWORD): DWORD; stdcall; overload;
{$ENDIF}

function SetThumbIcon(Handle : HWND; sp : TsSkinProvider; Width, Height : integer) : boolean;
function SetPreviewBmp(Handle : HWND; sp : TsSkinProvider) : boolean;

{$ENDIF} // NOTFORHELP

implementation

uses math, sVclUtils, sBorders, sGraphUtils, sSkinProps, sGradient, sLabel, FlatSB, StdCtrls,
  sMaskData, acntUtils, sMessages, sStyleSimply, sStrings, {$IFDEF LOGGED} sDebugMsgs,{$ENDIF}
  sMDIForm{$IFDEF CHECKXP}, UxTheme, Themes{$ENDIF}, sAlphaGraph, ComCtrls, Grids, acDials,
  sSpeedButton, CommCtrl{$IFNDEF ALITE}, sFrameAdapter, sScrollBox{$ENDIF};

var
  biClicked : boolean = False;
  MDICreating : boolean = False;
  ChildProvider : TsSkinProvider = nil;
  MDIIconsForm : TForm = nil;

_DwmSetIconicLivePreviewBitmap: function(hwnd: HWND; hbmp: HBITMAP; var pptClient: TPoint; dwSITFlags: DWORD): HResult; stdcall;
_DwmSetIconicThumbnail: function(hwnd: HWND; hbmp: HBITMAP; dwSITFlags: DWORD): HResult; stdcall;

_DwmSetWindowAttribute: function(hwnd: HWND; dwAttribute: DWORD; pvAttribute: Pointer; cbAttribute: DWORD): HResult; stdcall;
_DwmIsCompositionEnabled: function (out pfEnabled: BOOL): HResult; stdcall;
_DwmInvalidateIconicBitmaps: function(hwnd: HWND): HResult; stdcall;

const
  ModName = 'DWMAPI.DLL';

type
  TAccessProvider = class(TsSkinProvider);

function SetThumbIcon(Handle : HWND; sp : TsSkinProvider; Width, Height : integer) : boolean;
Const
  Flag = 0;
var
  Bmp, BmpForm : TBitmap;
  SrcBmp : TBitmap;
  w, h : integer;
begin
  Result := False;
  if (Win32MajorVersion >= 6) and (Width <> 0) and (Height <> 0) then begin
    if not Assigned(_DwmSetIconicThumbnail) then begin
      InitDwmApi;
      if hDWMAPI > 0 then begin
        _DwmSetIconicThumbnail := GetProcAddress(hDWMAPI, 'DwmSetIconicThumbnail');
        if not Assigned(_DwmSetIconicThumbnail) then Exit;
      end
    end;
    if {(sp.Form.WindowState = wsMinimized) and} ({TAccessProvider(sp).}sp.FormTimer <> nil) and (TAccessProvider(sp).FormTimer is TacMintimer) and TacMintimer(TAccessProvider(sp).FormTimer).Minimized
      then SrcBmp := TacMintimer(TAccessProvider(sp).FormTimer).SavedImage
      else SrcBmp := sp.SkinData.FCacheBmp;
    if (SrcBmp = nil) or SrcBmp.Empty then Exit;

    if Width / Height <= SrcBmp.Width / SrcBmp.Height then begin // Width is a main size
      w := Width;
      h := Round(w * SrcBmp.Height / SrcBmp.Width);
    end
    else begin
      h := Height;
      w := Round(h * SrcBmp.Width / SrcBmp.Height);
    end;
    if (w = 0) or (h = 0) then Exit;
    sp.FormState := sp.FormState or FS_THUMBDRAWING;

    Bmp := CreateBmp32(w, h);

    // Fast out
    Stretch(SrcBmp, Bmp, w, h, ftTriangle);
    if _DwmSetIconicThumbnail(Handle, Bmp.Handle, Flag) <> S_OK then begin
      Bmp.Free;
      Exit;
    end
    else Result := True;
    if SrcBmp = sp.SkinData.FCacheBmp then begin
      // Full out
      BmpForm := CreateBmp32(SrcBmp.Width, SrcBmp.Height);
      BmpForm.Assign(sp.SkinData.FCacheBmp);
      PaintFormTo(BmpForm, sp);
      Stretch(BmpForm, Bmp, w, h, ftTriangle);
      _DwmSetIconicThumbnail(Handle, Bmp.Handle, Flag);
      FreeAndNil(BmpForm);
      if sp.BorderForm <> nil then sp.BorderForm.UpdateExBordersPos(False); // Repaint cache
    end;

    FreeAndNil(Bmp);
    sp.FormState := sp.FormState and not FS_THUMBDRAWING;
  end;
end;

function SetPreviewBmp(Handle : HWND; sp : TsSkinProvider) : boolean;
Const
  Flag = 1;
var
  p : TPoint;
  BmpForm : TBitmap;
  SrcBmp : TBitmap;
  w, h : integer;
begin
  Result := False;
  if (Win32MajorVersion >= 6) then begin
    if not Assigned(_DwmSetIconicLivePreviewBitmap) then begin
      InitDwmApi;
      if hDWMAPI > 0 then begin
        _DwmSetIconicLivePreviewBitmap := GetProcAddress(hDWMAPI, 'DwmSetIconicLivePreviewBitmap');
        if not Assigned(_DwmSetIconicLivePreviewBitmap) then Exit;
      end
    end;
    if (TAccessProvider(sp).FormTimer <> nil) and (TAccessProvider(sp).FormTimer is TacMintimer) and TacMintimer(TAccessProvider(sp).FormTimer).Minimized
      then SrcBmp := TacMintimer(TAccessProvider(sp).FormTimer).SavedImage
      else SrcBmp := sp.SkinData.FCacheBmp;
    if (SrcBmp = nil) or SrcBmp.Empty then Exit;
    w := SrcBmp.Width;
    h := SrcBmp.Height;
    if (w = 0) or (h = 0) then Exit;
    sp.FormState := sp.FormState or FS_THUMBDRAWING;
    p := Point(0, 0);

    if SrcBmp = sp.SkinData.FCacheBmp then begin
      // Full out
      BmpForm := CreateBmp32(SrcBmp.Width, SrcBmp.Height);
      BmpForm.Assign(sp.SkinData.FCacheBmp);
      PaintFormTo(BmpForm, sp);
      Result := _DwmSetIconicLivePreviewBitmap(Handle, BmpForm.Handle, p, Flag) = S_OK;
      FreeAndNil(BmpForm);
      if sp.BorderForm <> nil then sp.BorderForm.UpdateExBordersPos(False); // Repaint cache
    end
    else begin
      // Fast out
      Result := _DwmSetIconicLivePreviewBitmap(Handle, SrcBmp.Handle, p, Flag) = S_OK
    end;
    sp.FormState := sp.FormState and not FS_THUMBDRAWING;
  end;
{
  Result := False;
  if (Win32MajorVersion >= 6) then begin
    p := Point(10, 10);
    if Assigned(_DwmSetIconicLivePreviewBitmap) then Result := _DwmSetIconicLivePreviewBitmap(Handle, Bmp.Handle, p, 1) = S_OK else begin
      InitDwmApi;
      if hDWMAPI > 0 then begin
        _DwmSetIconicLivePreviewBitmap := GetProcAddress(hDWMAPI, 'DwmSetIconicLivePreviewBitmap');
        if Assigned(_DwmSetIconicLivePreviewBitmap) then Result := _DwmSetIconicLivePreviewBitmap(Handle, Bmp.Handle, p, 0) = S_OK;
      end
    end;
  end;
}
end;

function GetTopWindow : THandle;
begin
  Result := HWND_TOPMOST;
//  Result := FindWindow('Shell_TrayWnd', nil);
//  if Result = 0 then Result := HWND_TOPMOST
end;

procedure DwmInvalidateIconicBitmaps(hwnd: HWND);
begin
  if (Win32MajorVersion >= 6) then begin
    if Assigned(_DwmInvalidateIconicBitmaps) then _DwmInvalidateIconicBitmaps(hwnd) else if hDWMAPI > 0 then begin
      _DwmInvalidateIconicBitmaps := GetProcAddress(hDWMAPI, 'DwmInvalidateIconicBitmaps');
      if Assigned(_DwmInvalidateIconicBitmaps) then _DwmInvalidateIconicBitmaps(hwnd);
    end;
  end;
end;

procedure SetFormBlendValue(FormHandle : THandle; Bmp : TBitmap; Value : integer; NewPos : PPoint = nil);
var
  DC : hdc;
  FBmpSize: TSize;
  FBmpTopLeft: TPoint;
  FBlend: TBlendFunction;
  R : TRect;
begin
  if Bmp = nil then begin
    GetWindowRect(FormHandle, R);
    Bmp := CreateBmp32(WidthOf(R, True), HeightOf(R, True));
  end
  else R.Right := R.Left;
  FBlend.BlendOp := AC_SRC_OVER;
  FBlend.BlendFlags := 0;
  FBlend.AlphaFormat := AC_SRC_ALPHA;
  FBlend.SourceConstantAlpha := Value;

  FBmpSize.cx := Bmp.Width;
  FBmpSize.cy := Bmp.Height;

  FBmpTopLeft.X := 0;
  FBmpTopLeft.Y := 0;

  DC := GetDC(0);
  try
    if GetWindowLong(FormHandle, GWL_EXSTYLE) and WS_EX_LAYERED <> WS_EX_LAYERED
      then SetWindowLong(FormHandle, GWL_EXSTYLE, GetWindowLong(FormHandle, GWL_EXSTYLE) or WS_EX_LAYERED);

    UpdateLayeredWindow(FormHandle, DC, NewPos, @FBmpSize, Bmp.Canvas.Handle, @FBmpTopLeft, clNone, @FBlend, ULW_ALPHA);
  finally
    ReleaseDC(0, DC);
  end;
  if R.Left <> R.Right then FreeAndNil(Bmp);
end;

function MakeCoverForm(Wnd : THandle) : TForm;
var
  R : TRect;
  DC : hdc;
  Bmp : TBitmap;
  Rgn : hrgn;
begin
  Result := TForm.Create(nil);
  Result.Tag := ExceptTag;
  SetWindowLong(Result.Handle, GWL_EXSTYLE, GetWindowLong(Result.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW or WS_EX_NOACTIVATE);
  Result.Visible := False;
  Result.BorderStyle := bsNone;
  GetWindowRect(Wnd, R);
  Result.SetBounds(R.Left, R.Top, WidthOf(R), HeightOf(R));
  Bmp := CreateBmp32(Result.Width, Result.Height);

  // Copy the window image
  DC := GetWindowDC(Wnd);
  try
    BitBlt(Bmp.Canvas.Handle, 0, 0, Result.Width, Result.Height, DC, 0, 0, SRCCOPY);
    FillAlphaRect(Bmp, Rect(0, 0, Bmp.Width, Bmp.Height), MaxByte);
  finally
    ReleaseDC(Wnd, DC);
  end;

  Rgn := CreateRectRgn(0, 0, 0, 0);
  if GetWindowRgn(Wnd, Rgn) <> ERROR
    then SetWindowRgn(Result.Handle, Rgn, False);
  DeleteObject(Rgn);

  SetFormBlendValue(Result.Handle, Bmp, MaxByte);
  SetWindowPos(Result.Handle, 0 {HWND_TOPMOST}, R.Left, R.Top, 0, 0, SWP_NOSIZE or {SWP_NOMOVE or }SWP_NOACTIVATE or SWP_NOREDRAW or SWP_SHOWWINDOW or SWP_NOSENDCHANGING or SWP_NOOWNERZORDER);
  FreeAndNil(Bmp);
end;

function ShellTrayWnd : THandle;
begin
  Result := FindWindow('Shell_TrayWnd', nil);
end;

{$IFNDEF NOWNDANIMATION}
procedure StartMinimizing(sp : TsSkinProvider);
var
  h : THandle;
begin
  if sp.SkinData.SkinManager.AnimEffects.Minimizing.Active then begin
    sp.KillAnimations;
    if (sp.FormState and FS_ANIMMINIMIZING = FS_ANIMMINIMIZING) then Exit;
    sp.FormState := sp.FormState or FS_ANIMMINIMIZING;
    sp.fAnimating := True;
    if Assigned(sp.FormTimer) and not (sp.FormTimer is TacMintimer) then FreeAndNil(sp.Formtimer);
    if not Assigned(sp.FormTimer) then sp.FormTimer := TacMinTimer.CreateOwned(sp, True) else begin
      if (sp.FormState and FS_ANIMRESTORING <> FS_ANIMRESTORING) then TacMinTimer(sp.FormTimer).InitData;
    end;
    sp.FormState := sp.FormState and not FS_ANIMRESTORING;

    if (TacMinTimer(sp.FormTimer).CurrentAlpha >= TacMinTimer(sp.FormTimer).AlphaFrom) then begin // If not in animation already
      if sp.BorderForm <> nil then begin
        sp.BorderForm.UpdateExBordersPos(False); // Repaint cache
        TacMinTimer(sp.FormTimer).SavedImage.Assign(sp.SkinData.FCacheBmp); // Save cache
        sp.BorderForm.ExBorderShowing := True;
        SetWindowPos(sp.BorderForm.AForm.Handle, GetTopWindow, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSENDCHANGING or SWP_NOOWNERZORDER or SWP_NOSIZE or SWP_NOREDRAW);
        SetWindowRgn(sp.BorderForm.AForm.Handle, 0, False);
      end
      else begin
        TacMinTimer(sp.FormTimer).SavedImage.Assign(sp.SkinData.FCacheBmp); // Save cache
        PaintFormTo(TacMinTimer(sp.FormTimer).SavedImage, sp);
      end;
    end;

    if GetWindowLong(sp.Form.Handle, GWL_EXSTYLE) and WS_EX_LAYERED <> WS_EX_LAYERED
      then SetWindowLong(sp.Form.Handle, GWL_EXSTYLE, GetWindowLong(sp.Form.Handle, GWL_EXSTYLE) or WS_EX_LAYERED);
    SetLayeredWindowAttributes(sp.Form.Handle, clNone, 0, ULW_ALPHA);
    sp.FormTimer.Enabled := True;
  end;
{$IFDEF D2007}
  if not Application.MainFormOnTaskBar then begin
    if sp.Form = Application.MainForm
      then h := Application.Handle
      else h := sp.Form.Handle;
  end else
{$ENDIF}  
  h := sp.Form.Handle;
  UpdatePreview(h, True);
  DwmInvalidateIconicBitmaps(h);
end;

function StartRestoring(sp : TsSkinProvider) : boolean;
var
  h : THandle;
begin
  if not Assigned(sp.FormTimer) or not (sp.FormTimer is TacMinTimer) or not sp.SkinData.SkinManager.AnimEffects.Minimizing.Active then Exit;
  if (sp.FormState and FS_ANIMRESTORING = FS_ANIMRESTORING) then Exit;
  Result := True;
  sp.FormState := sp.FormState and not FS_ANIMMINIMIZING;

  sp.FormState := sp.FormState or FS_ANIMRESTORING;
  sp.fAnimating := True;

  if sp.BorderForm <> nil then begin
    sp.BorderForm.ExBorderShowing := True;
    if sp.BorderForm.AForm = nil then begin
      sp.BorderForm.CreateNewForm;
      SetFormBlendValue(sp.BorderForm.AForm.Handle, TacMinTimer(sp.FormTimer).AlphaBmp, 0);
    end;
    TacMinTimer(sp.FormTimer).AnimForm := sp.BorderForm.AForm;

    SetWindowPos(sp.BorderForm.AForm.Handle, GetTopWindow, 0, 0, 0, 0, SWP_NOSENDCHANGING or SWP_NOOWNERZORDER or SWP_NOSIZE or SWP_NOMOVE or SWP_NOREDRAW);// or SWP_SHOWWINDOW);

{$IFDEF DELPHI7UP}
//    if not sp.Form.AlphaBlend then SetLayeredWindowAttributes(sp.Form.Handle, clNone, sp.Form.AlphaBlendValue, ULW_ALPHA) else
{$ENDIF}
    if GetWindowLong(sp.Form.Handle, GWL_EXSTYLE) and WS_EX_LAYERED <> WS_EX_LAYERED
      then SetWindowLong(sp.Form.Handle, GWL_EXSTYLE, GetWindowLong(sp.Form.Handle, GWL_EXSTYLE) or WS_EX_LAYERED);
    SetLayeredWindowAttributes(sp.Form.Handle, clNone, 0, ULW_ALPHA);
    sp.FormTimer.Enabled := True;
    // Form image update
    sp.FormActive := True;
    sp.SkinData.BGChanged := True;
    sp.PaintAll;
    SetWindowRgn(sp.BorderForm.AForm.Handle, 0, False);
  end
  else begin
    if GetWindowLong(sp.Form.Handle, GWL_EXSTYLE) and WS_EX_LAYERED <> WS_EX_LAYERED
      then SetWindowLong(sp.Form.Handle, GWL_EXSTYLE, GetWindowLong(sp.Form.Handle, GWL_EXSTYLE) or WS_EX_LAYERED);
    SetLayeredWindowAttributes(sp.Form.Handle, clNone, 0, ULW_ALPHA);
    sp.FormTimer.Enabled := True;
  end;
{$IFDEF D2009}
  if not Application.MainFormOnTaskBar then begin
    if sp.Form = Application.MainForm
      then h := Application.Handle
      else h := sp.Form.Handle;
  end else
{$ENDIF}
  h := sp.Form.Handle;
  UpdatePreview(h, False);
end;

procedure StartBlendOnMoving(sp : TsSkinProvider);
var
  TmpForm : TForm;
begin
  if (sp.FormState and FS_BLENDMOVING = FS_BLENDMOVING) then Exit;
  if sp.SkinData.SkinManager.AnimEffects.BlendOnMoving.Active then begin
    sp.FormState := sp.FormState or FS_BLENDMOVING;
    if Assigned(sp.FormTimer) then FreeAndNil(sp.Formtimer);
    sp.FormTimer := TacMoveTimer.CreateOwned(sp, True);
{$IFDEF DELPHI7UP}
    if sp.Form.AlphaBlend then TacMoveTimer(sp.FormTimer).CurrentBlendValue := sp.Form.AlphaBlendValue else
{$ENDIF}
    TacMoveTimer(sp.FormTimer).CurrentBlendValue := MaxByte;
    TacMoveTimer(sp.FormTimer).sp := sp;
    TacMoveTimer(sp.FormTimer).BorderForm := sp.BorderForm;
    TacMoveTimer(sp.FormTimer).FormHandle := sp.Form.Handle;
    if sp.AllowBlendOnMoving
      then TacMoveTimer(sp.FormTimer).BlendValue := sp.SkinData.SkinManager.AnimEffects.BlendOnMoving.BlendValue
      else TacMoveTimer(sp.FormTimer).BlendValue := MaxByte;
    if sp.SkinData.SkinManager.AnimEffects.BlendOnMoving.Time > acTimerInterval
      then TacMoveTimer(sp.FormTimer).BlendStep := round((MaxByte - TacMoveTimer(sp.FormTimer).BlendValue) / (sp.SkinData.SkinManager.AnimEffects.BlendOnMoving.Time / acTimerInterval))
      else  TacMoveTimer(sp.FormTimer).BlendStep := MaxByte - TacMoveTimer(sp.FormTimer).BlendValue;
    TacMoveTimer(sp.FormTimer).Interval := acTimerInterval;
    if sp.BorderForm <> nil then begin
{$IFDEF DELPHI7UP}
      if sp.Form.AlphaBlend and (sp.Form.AlphaBlendValue < MaxByte)
        then SetLayeredWindowAttributes(sp.Form.Handle, clNone, 0, ULW_ALPHA);
{$ENDIF}
      sp.BorderForm.UpdateExBordersPos(False);
      sp.BorderForm.ExBorderShowing := True;
      SetWindowPos(sp.Form.Handle, sp.BorderForm.AForm.Handle, 0, 0, 0, 0, SWP_NOSENDCHANGING or SWP_NOOWNERZORDER or SWP_NOSIZE or SWP_NOMOVE or SWP_NOREDRAW);
      if GetWindowLong(sp.Form.Handle, GWL_EXSTYLE) and WS_EX_LAYERED <> WS_EX_LAYERED
        then SetWindowLong(sp.Form.Handle, GWL_EXSTYLE, GetWindowLong(sp.Form.Handle, GWL_EXSTYLE) or WS_EX_LAYERED);
      SetFormBlendValue(sp.Form.Handle, nil, 0);
      sp.FormTimer.Enabled := True;
      sp.BorderForm.AForm.Perform(WM_SYSCOMMAND, SC_DRAGMOVE, 0);
    end
    else begin
{$IFDEF DELPHI7UP}
      if not sp.Form.AlphaBlend then
{$ENDIF}
      begin
        TmpForm := MakeCoverForm(sp.Form.Handle);
        if GetWindowLong(sp.Form.Handle, GWL_EXSTYLE) and WS_EX_LAYERED <> WS_EX_LAYERED
          then SetWindowLong(sp.Form.Handle, GWL_EXSTYLE, GetWindowLong(sp.Form.Handle, GWL_EXSTYLE) or WS_EX_LAYERED);
        SetLayeredWindowAttributes(sp.Form.Handle, clNone, MaxByte, ULW_ALPHA);
        RedrawWindow(sp.Form.Handle, nil, 0, RDW_ERASE or RDW_INVALIDATE or RDW_ALLCHILDREN or RDW_UPDATENOW);
        FreeAndNil(TmpForm);
      end;
      sp.FormTimer.Enabled := True;
      sp.Form.Perform(WM_SYSCOMMAND, SC_DRAGMOVE, 0);
    end;
    FinishBlendOnMoving(sp);
  end;
end;

procedure FinishBlendOnMoving(sp : TsSkinProvider);
var
  cx, cy : integer;
  TmpForm : TForm;
begin
  if sp.BorderForm <> nil then begin
{$IFDEF DELPHI7UP}
    if sp.Form.AlphaBlend then SetFormBlendValue(sp.BorderForm.AForm.Handle, sp.SkinData.FCacheBmp, sp.Form.AlphaBlendValue) else
{$ENDIF}
    SetFormBlendValue(sp.BorderForm.AForm.Handle, sp.SkinData.FCacheBmp, MaxByte);
    if sp.FSysExHeight
      then cy := sp.ShadowSize.Top + DiffTitle(sp.BorderForm) + SysBorderWidth(sp.Form.Handle, sp.BorderForm, False) //  4 { For MinMax patching }
      else cy := sp.BorderForm.OffsetY;
    cx := SkinBorderWidth(sp.BorderForm) - SysBorderWidth(sp.Form.Handle, sp.BorderForm, False) + sp.ShadowSize.Left;
    SetWindowPos(sp.Form.Handle, 0, sp.BorderForm.AForm.Left + cx, sp.BorderForm.AForm.Top + cy, 0, 0, SWP_NOACTIVATE {Activate later} or SWP_NOSENDCHANGING or SWP_NOREDRAW or SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOSIZE);
    sp.FormState := sp.FormState and not FS_BLENDMOVING;
{$IFDEF DELPHI7UP}
    if sp.Form.AlphaBlend then begin
      sp.BorderForm.ExBorderShowing := False;
      sp.BorderForm.UpdateExBordersPos(True);
      SetLayeredWindowAttributes(sp.Form.Handle, clNone, sp.Form.AlphaBlendValue, ULW_ALPHA);
    end
    else
{$ENDIF}
    SetWindowLong(sp.Form.Handle, GWL_EXSTYLE, GetWindowLong(sp.Form.Handle, GWL_EXSTYLE) and not WS_EX_LAYERED);
    RedrawWindow(sp.Form.Handle, nil, 0, RDW_INVALIDATE or RDW_ERASE or RDW_FRAME or RDW_ALLCHILDREN or RDW_UPDATENOW);
//    if GetWindowLong(sp.Form.Handle, GWL_EXSTYLE) and WS_EX_TOPMOST = WS_EX_TOPMOST
//      then
    // Activate
    SetWindowPos(sp.Form.Handle, 0, 0, 0, 0, 0, SWP_NOSENDCHANGING or SWP_NOREDRAW or SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_NOSIZE or SWP_NOMOVE);
    sp.BorderForm.ExBorderShowing := False;
    sp.BorderForm.UpdateExBordersPos(True); // Redraw and update region and z-order
    if AeroIsEnabled and (sp.Form.Menu <> nil) then begin
      RedrawWindow(sp.Form.Handle, nil, 0, RDW_INVALIDATE or RDW_FRAME or RDW_UPDATENOW);
    end;
  end
  else begin
{$IFDEF DELPHI7UP}
    if sp.Form.AlphaBlend then begin
      SetLayeredWindowAttributes(sp.Form.Handle, clNone, sp.Form.AlphaBlendValue, ULW_ALPHA);
    end
    else
{$ENDIF}
    begin
      TmpForm := MakeCoverForm(sp.Form.Handle);
      SetWindowLong(sp.Form.Handle, GWL_EXSTYLE, GetWindowLong(sp.Form.Handle, GWL_EXSTYLE) and not WS_EX_LAYERED);
      UpdateWindow(sp.Form.Handle);
      if Assigned(sp.FormTimer) then sp.FormTimer.Enabled := False;
      RedrawWindow(sp.Form.Handle, nil, 0, RDW_ERASE or RDW_INVALIDATE or RDW_FRAME or RDW_ALLCHILDREN or RDW_UPDATENOW);
      FreeAndNil(TmpForm);
    end;
    sp.FormState := sp.FormState and not FS_BLENDMOVING;
  end;
  if Assigned(sp.FormTimer) then begin
    TacMoveTimer(sp.FormTimer).CurrentBlendValue := MaxByte;
    FreeAndNil(sp.FormTimer);
  end;
end;
{$ENDIF}

procedure PaintFormTo(DstBmp : TBitmap; sp : TsSkinProvider);
var
  SavedDC : hdc;
  acDstBmp : TBitmap;
begin
  if sp.SkinData.FCacheBmp <> nil then begin
    acDstBmp := CreateBmp32(sp.SkinData.FCacheBmp.Width, sp.SkinData.FCacheBmp.Height);
    try
      acDstBmp.Canvas.Lock;
      SavedDC := SaveDC(acDstBmp.Canvas.Handle);
      SkinPaintTo(acDstBmp, sp.Form, 0, 0, sp);

      RestoreDC(acDstBmp.Canvas.Handle, SavedDC);
      acDstBmp.Canvas.UnLock;

//      Ac_NCPaint(sp.ListSW, sp.Form.Handle, 0, 0, -1, acDstBmp.Canvas.Handle);
      BitBlt(DstBmp.Canvas.Handle, 0, 0, acDstBmp.Width, acDstBmp.Height, acDstBmp.Canvas.Handle, 0, 0, SRCCOPY);

      if sp.BorderForm = nil then begin
        FillAlphaRect(DstBmp, Rect(0, 0, DstBmp.Width, DstBmp.Height), MaxByte);
      end;
    finally
      FreeAndNil(acDstBmp);
    end;
  end
end;

procedure StartSBAnimation(const Btn: PsCaptionButton; const State: integer; const Iterations : integer; const ToUp : boolean; const SkinProvider : TsSkinProvider; acDialog : pointer = nil);
begin
  if Btn^.Timer = nil then begin
    if SkinProvider <> nil then begin
      Btn^.Timer := TacSBAnimation.Create(SkinProvider);
      Btn^.Timer.BorderForm := SkinProvider.BorderForm;
      Btn^.Timer.FormHandle := SkinProvider.Form.Handle;
      Btn^.Timer.SkinData := SkinProvider.SkinData;
    end
    else if acDialog <> nil then with TacDialogWnd(acDialog) do begin
      Btn^.Timer := TacSBAnimation.Create(Application);
      Btn^.Timer.BorderForm := BorderForm;
      Btn^.Timer.FormHandle := CtrlHandle;
      Btn^.Timer.SkinData := SkinData;
    end
    else Exit;
    if Btn^.Timer <> nil then begin
      Btn^.Timer.Enabled := False;
      Btn^.Timer.PBtnData := Btn;
      Btn^.Timer.MaxIterations := Iterations;
      Btn^.Timer.Interval := 12;
      Btn^.Timer.StartAnimation(State, True);
    end;
  end
  else begin
    if ToUp then Btn^.Timer.CurrentState := State;
    Btn^.Timer.MaxIterations := Iterations;
    Btn^.Timer.Up := ToUp;
    Btn^.Timer.Enabled := True;

    if State = 2 then begin
      Btn^.Timer.CurrentLevel := Iterations;
      FreeAndNil(Btn^.Timer.ABmp);
      FreeAndNil(Btn^.Timer.AForm);
      Btn^.Timer.MakeForm;
      Btn^.Timer.MakeImg;
    end;
  end;
end;

function IsMenuVisible(sp : TsSkinProvider) : boolean;
begin
  if (sp.Form.Menu <> nil) and not sp.Form.Menu.AutoMerge then begin
    Result := (sp.Form.Menu.Items.Count > 0) and (sp.Form.FormStyle <> fsMDIChild) and (sp.Form.BorderStyle <> bsDialog);
  end
  else Result := False;
end;

function SysBorderWidth(const Handle : hwnd; const BorderForm : TacBorderForm; CheckSkin : boolean = True): integer;
var
  Style : Longint;
begin
  Result := 0;
  if CheckSkin then Result := SkinBorderWidth(BorderForm);
  if Result = 0 then begin
    Style := GetWindowLong(Handle, GWL_STYLE);
    if (Style and WS_THICKFRAME = WS_THICKFRAME) then Result := GetSystemMetrics(SM_CXSIZEFRAME) else if (Style and WS_BORDER = WS_BORDER) then Result := GetSystemMetrics(SM_CXFIXEDFRAME);
  end
end;

function SysBorderHeight(const Handle : hwnd; const BorderForm : TacBorderForm; CheckSkin : boolean = True): integer;
begin
  Result := 0;
  if BorderForm = nil {Used in caption only when borders are std} then Result := SysBorderWidth(Handle, BorderForm, CheckSkin);
end;

function SysCaptHeight(Form : TForm): integer;
begin
  if (Form = nil) then begin
    if FSysWndCaptHeight = 0 then FSysWndCaptHeight := GetSystemMetrics(SM_CYCAPTION);
    Result := FSysWndCaptHeight;
  end
  else if (Form.BorderStyle in [bsToolWindow, bsSizeToolWin]) and not IsIconic(Form.Handle) then begin
    if FSysToolCaptHeight = 0 then FSysToolCaptHeight := GetSystemMetrics(SM_CYSMCAPTION);
    Result := FSysToolCaptHeight;
  end
  else begin
    if FSysWndCaptHeight = 0 then FSysWndCaptHeight := GetSystemMetrics(SM_CYCAPTION);
    Result := FSysWndCaptHeight;
  end;
end;

function HaveDefShadow(const sp : TsSkinProvider) : boolean;
begin
  Result := True;
end;

function SkinTitleHeight(const BorderForm : TacBorderForm) : integer;
begin
  if BorderForm <> nil then begin
    Result := BorderForm.SkinData.SkinManager.SkinData.ExTitleHeight;
  end
  else Result := 0;
end;

function SkinBorderWidth(const BorderForm : TacBorderForm) : integer;
begin
  if BorderForm <> nil then Result := BorderForm.SkinData.SkinManager.SkinData.ExBorderWidth else Result := 0;
end;

function SkinMenuOffset(const sp : TsSkinProvider) : TPoint;
begin
  if sp.BorderForm <> nil then begin
    Result.Y := sp.CaptionHeight - SysCaptHeight(sp.Form) + SysBorderHeight(sp.Form.Handle, sp.BorderForm) - SysBorderHeight(sp.Form.Handle, sp.BorderForm, False);
    Result.X := SysBorderWidth(sp.Form.Handle, sp.BorderForm) - SysBorderWidth(sp.Form.Handle, sp.BorderForm, False);
  end
  else begin
    Result := Point(0, 0);
  end;
end;

function DiffTitle(const BorderForm : TacBorderForm) : integer;
begin
  if BorderForm <> nil then begin
    Result := BorderForm.CaptionHeight - BorderForm.CaptionHeight(False) - SysBorderWidth(BorderForm.OwnerHandle, BorderForm, False)
  end
  else Result := 0;
end;

function DiffBorder(const BorderForm : TacBorderForm) : integer;
var
  i, j : integer;
begin
  if BorderForm <> nil then begin
    i := SysBorderWidth(BorderForm.OwnerHandle, BorderForm);
    j := SysBorderWidth(BorderForm.OwnerHandle, BorderForm, False);
    Result := i - j
  end
  else Result := 0;
end;

procedure InitDwmApi;
begin
  if hDWMAPI = 0 then hDWMAPI := LoadLibrary(ModName);
end;

function DwmSetWindowAttribute(hwnd: HWND; dwAttribute: DWORD; pvAttribute: Pointer; cbAttribute: DWORD): HResult;
begin
  if Assigned(_DwmSetWindowAttribute) then Result := _DwmSetWindowAttribute(hwnd, dwAttribute, pvAttribute, cbAttribute) else begin
    InitDwmApi;
    Result := E_NOTIMPL;
    if hDWMAPI > 0 then begin
      _DwmSetWindowAttribute := GetProcAddress(hDWMAPI, 'DwmSetWindowAttribute');
      if Assigned(_DwmSetWindowAttribute) then Result := _DwmSetWindowAttribute(hwnd, dwAttribute, pvAttribute, cbAttribute);
    end;
  end;
end;

function AeroIsEnabled : boolean;
var
  b : Longbool;
begin
  Result := False;
  if (Win32MajorVersion >= 6) then begin
    b := False;
    if Assigned(_DwmIsCompositionEnabled) then Result := _DwmIsCompositionEnabled(b) = S_OK else begin
      InitDwmApi;
      if hDWMAPI > 0 then begin
        _DwmIsCompositionEnabled := GetProcAddress(hDWMAPI, 'DwmIsCompositionEnabled');
        if Assigned(_DwmIsCompositionEnabled) then Result := _DwmIsCompositionEnabled(b) = S_OK;
      end
    end;
  end;
  Result := Result and b;
end;

function ForbidSysAnimating : boolean;
begin
  Result := not AeroIsEnabled;
end;

procedure InitDwm(const Handle : THandle; const Skinned : boolean; const Repaint : boolean = False);
var
  Policy : Longint;
begin
  if AeroIsEnabled then begin
    if Skinned then begin
      Policy := 1; // DWMNCRP_DISABLED
      DwmSetWindowAttribute(Handle, 3{DWMWA_TRANSITIONS_FORCEDISABLED}, @Policy, Sizeof(Policy));
    end
    else begin
      Policy := 0; // DWMNCRP_USEWINDOWSTYLE
      DwmSetWindowAttribute(Handle, 3{DWMWA_TRANSITIONS_FORCEDISABLED}, @Policy, Sizeof(Policy));
    end;
(*    Policy := integer(Skinned);
    if DwmSetWindowAttribute(Handle, 10{DWMWA_HAS_ICONIC_BITMAP}, @Policy, 4) <> S_OK then Exit;
    DwmSetWindowAttribute(Handle, 7{DWMWA_FORCE_ICONIC_REPRESENTATION}, @Policy, 4);*)
  end
end;

function BigButtons(sp : TsSkinProvider) : boolean;
begin
  Result := sp.Form.BorderStyle in [bsSingle, bsSizeable]
end;

function IsBorderUnchanged(const BorderIndex : integer; const sm : TsSkinManager) : boolean;
begin
  Result := (BorderIndex < 0) or (sm.ma[BorderIndex].ImageCount = 1)
end;

function IsGripVisible(const sp : TsSkinProvider) : boolean;
begin
  Result := (sp.GripMode = gmRightBottom) and not IsZoomed(sp.Form.Handle) and (GetWindowLong(sp.Form.Handle, GWL_STYLE) and WS_SIZEBOX = WS_SIZEBOX)
end;

function InAnimation(const sp : TsSkinProvider) : boolean;
begin
  Result := sp.FInAnimation; // Will be changed later for optimizing
end;

procedure PaintGrip(const aDC : hdc; const sp : TsSkinProvider);
var
  i, w1, w2, dx, h1, h2, dy : integer;
  Bmp : TBitmap;
  p : TPoint;
  BG : TacBGInfo;
begin
  i := sp.FCommonData.SkinManager.GetMaskIndex(sp.FCommonData.SkinManager.ConstData.IndexGLobalInfo, s_GlobalInfo, s_GripImage);
  if sp.FCommonData.SkinManager.IsValidImgIndex(i) then begin
    Bmp := CreateBmp32(WidthOfImage(sp.FCommonData.SkinManager.ma[i]), HeightOfImage(sp.FCommonData.SkinManager.ma[i]));
    p := sp.RBGripPoint(i);
    BG.R := Rect(0, 0, Bmp.Width, Bmp.Height);
    BG.PleaseDraw := False;
    sp.FCommonData.FCacheBmp.Canvas.Lock;
    GetBGInfo(@BG, sp.Form);
    if BG.BgType = btFill then begin
      FillDC(Bmp.Canvas.Handle, BG.R, BG.Color);
      w1 := sp.SkinData.SkinManager.MaskWidthRight(sp.SkinData.BorderIndex);
      h1 := sp.SkinData.SkinManager.MaskWidthBottom(sp.SkinData.BorderIndex);
      w2 := SysBorderWidth(sp.Form.Handle, sp.BorderForm);
      h2 := w2;
      dx := w1 - w2;
      dy := h1 - h2;
      if (dx > 0) and (dy > 0) then begin
        // Right border
        BitBlt(Bmp.Canvas.Handle, Bmp.Width - dx, 0, dx, Bmp.Height,
          sp.SkinData.FCacheBmp.Canvas.Handle, sp.SkinData.FCacheBmp.Width - w1 - sp.ShadowSize.Right, sp.SkinData.FCacheBmp.Height - h2 - Bmp.Height - sp.ShadowSize.Bottom, SRCCOPY);
        // Bottom border
        BitBlt(Bmp.Canvas.Handle, 0, Bmp.Height - dy, Bmp.Width, dy,
                     sp.SkinData.FCacheBmp.Canvas.Handle, sp.SkinData.FCacheBmp.Width - w2 - Bmp.Width - sp.ShadowSize.Right, sp.SkinData.FCacheBmp.Height - h1 - sp.ShadowSize.Bottom, SRCCOPY);
      end;
    end
    else BitBlt(Bmp.Canvas.Handle, 0, 0, BG.R.Right, BG.R.Bottom,
                     sp.SkinData.FCacheBmp.Canvas.Handle, p.X, p.Y, SRCCOPY);
    sp.FCommonData.FCacheBmp.Canvas.UnLock;
    DrawSkinGlyph(Bmp, Point(0, 0), 0, 1, sp.FCommonData.SkinManager.ma[i], MakeCacheInfo(Bmp));
    BitBlt(aDC, p.X, p.Y, Bmp.Width, Bmp.Height, Bmp.Canvas.Handle, 0, 0, SRCCOPY);

    FreeAndNil(Bmp);
  end;
end;

function CtrlIsReadyForHook(const Ctrl : TWinControl) : boolean;
begin
  Result := Ctrl.HandleAllocated{$IFDEF TNTUNICODE} and Ctrl.Visible and (Ctrl.Parent <> nil){$ENDIF} // Showing is False when Parent changed
end;

procedure MakeCaptForm(sp : TsSkinProvider; Full : boolean = False);
var
  p : TPoint;
  t, h, l, w : integer;
  Flags : Longint;
begin
  if not sp.FDrawNonClientArea or InAnimation(sp) or (sp.LockCount > 0) or ((sp.BorderForm <> nil) and (sp.Form.Menu = nil)) then Exit;
  if (sp.Form.FormStyle = fsMDIChild) and (TsSkinProvider(MDISkinProvider).LockCount > 0) or (sp.FormState and FS_BLENDMOVING = FS_BLENDMOVING) then Exit;

  if sp.CaptForm = nil then begin
    sp.CaptForm := TForm.Create(Application);
    sp.CaptForm.Tag := ExceptTag;
    sp.CaptForm.OnPaint := sp.CaptFormPaint;
    sp.OldCaptFormProc := sp.CaptForm.WindowProc;
    sp.CaptForm.WindowProc := sp.NewCaptFormProc;
    sp.CaptForm.BorderStyle := bsNone;
  end;
  sp.CaptForm.Visible := False;

  if sp.BorderForm <> nil then begin
    h := sp.MenuHeight * sp.LinesCount + 1;
    t := sp.Form.Top + sp.OffsetY - h - sp.ShadowSize.Top - DiffTitle(sp.BorderForm);
    l := sp.Form.Left + SysBorderWidth(sp.Form.Handle, sp.BorderForm, False);
    w := sp.Form.Width - 2 * SysBorderWidth(sp.Form.Handle, sp.BorderForm, False);
    if h <> 0 then inc(h);
  end
  else begin
    h := iffi(Full, sp.Form.Height, sp.HeaderHeight);
    t := sp.Form.Top;
    l := sp.Form.Left;
    w := sp.Form.Width;
  end;

  Flags := SWP_NOACTIVATE or SWP_SHOWWINDOW or SWP_NOREDRAW or SWP_NOSENDCHANGING or SWP_NOOWNERZORDER;

  if (sp.Form.FormStyle = fsMDIChild) then begin
    p := TsSkinProvider(MDISkinProvider).Form.ClientToScreen(Point(sp.Form.Left + GetAlignShift(TsSkinProvider(MDISkinProvider).Form, alLeft, True) + 2, sp.Form.Top + GetAlignShift(TsSkinProvider(MDISkinProvider).Form, alTop, True) + 2));
    SetWindowPos(sp.CaptForm.Handle, 0, p.x, p.y, sp.Form.Width, sp.HeaderHeight, Flags);
  end
  else begin
    if GetWindowLong(sp.Form.Handle, GWL_EXSTYLE) and WS_EX_TOPMOST = WS_EX_TOPMOST
      then SetWindowPos(sp.CaptForm.Handle, HWND_TOPMOST, l, t, w, h, Flags)
      else SetWindowPos(sp.CaptForm.Handle, GetNextWindow(sp.Form.Handle, GW_HWNDPREV), l, t, w, h, Flags);
  end;
end;

procedure KillCaptForm(sp : TsSkinProvider);
begin
  if sp.CaptForm <> nil then begin
    sp.CaptForm.WindowProc := sp.OldCaptFormProc;
    FreeAndNil(sp.CaptForm);
  end;
end;

procedure FillArOR(sp : TsSkinProvider);
var
  i : integer;
begin
  SetLength(sp.ArOR, 0);
  if sp.SkinData.SkinManager.IsValidImgIndex(sp.SkinData.BorderIndex) then begin
    // TopBorderRgn
    AddRgn(sp.ArOR, sp.CaptionWidth, sp.SkinData.SkinManager.ma[sp.SkinData.BorderIndex], 0, False);
    // BottomBorderRgn
    AddRgn(sp.ArOR, sp.CaptionWidth, sp.SkinData.SkinManager.ma[sp.SkinData.BorderIndex], sp.Form.Height - sp.SkinData.SkinManager.ma[sp.SkinData.BorderIndex].WB, True);
  end;

  // TitleRgn
  i := sp.TitleSkinIndex;
  if sp.SkinData.SkinManager.IsValidSkinIndex(i) then begin
    i := sp.SkinData.SkinManager.GetMaskIndex(i, sp.TitleSkinSection, s_BordersMask);
    if sp.SkinData.SkinManager.IsValidImgIndex(i) then AddRgn(sp.ArOR, sp.CaptionWidth, sp.SkinData.SkinManager.ma[i], 0, False);
  end;
end;

function IsSizeBox(Handle : hWnd) : boolean;
var
  Style: LongInt;
begin
  Style := GetWindowLong(Handle, GWL_STYLE);
  Result := Style and WS_SIZEBOX = WS_SIZEBOX;
end;

procedure UpdateRgn(sp : TsSkinProvider; Repaint : boolean = True);
const
  BE_ID = $41A2;
  CM_BEWAIT = CM_BASE + $0C4D;
var
  rgn : HRGN;
  R : TRect;
  sbw, i : integer;
begin
  if sp.DrawNonClientArea and not sp.InMenu and (HaveBorder(sp) or IsIconic(sp.Form.Handle) or IsSizeBox(sp.Form.Handle)) then with sp do begin
    if not FirstInitialized then if SendMessage(Form.Handle, CM_BEWAIT, BE_ID, 0) = BE_ID then Exit; // BE compatibility
    if ((sp.Form.Parent = nil) or (TForm(sp.Form).DragKind <> dkDock)) {regions changing disabled when docking used} then begin
      RgnChanging := True;

      if (BorderForm <> nil) then begin
        sbw := SysBorderWidth(sp.Form.Handle, sp.BorderForm, False);
        if sp.FSysExHeight
          then i := SysCaptHeight(sp.Form) {- 4{SysBorderWidth(sp.Form.Handle, sp.BorderForm, False) }+ SysBorderWidth(sp.Form.Handle, sp.BorderForm, False)
          else i := SysBorderHeight(sp.Form.Handle, sp.BorderForm, False) + SysCaptHeight(sp.Form) + SysBorderWidth(sp.Form.Handle, sp.BorderForm, False);
        rgn := CreateRectRgn(sbw, i, sp.Form.Width - sbw, sp.Form.Height - sbw);
      end
      else
      if IsZoomed(sp.Form.Handle) and (sp.Form.Constraints.MaxWidth = 0) and (sp.Form.Constraints.MaxHeight = 0) and (Form.FormStyle <> fsMDIChild) then begin
        R := Rect(0, 0, sp.Form.Width, sp.Form.Height);
        InflateRect(R, - SysBorderWidth(sp.Form.Handle, sp.BorderForm, False), - SysBorderHeight(sp.Form.Handle, sp.BorderForm, False));
        rgn := CreateRectRgn(R.Left, R.Top, R.Right, R.Bottom);
      end
      else rgn := GetRgnFromArOR(sp);
      sp.RgnChanged := True;
      SetWindowRgn(Form.Handle, rgn, Repaint); // True - repainting is required
      RgnChanging := False;
    end
    else SetWindowRgn(Form.Handle, 0, False);
  end;
end;

function GetRgnFromArOR(sp : TsSkinProvider; X : integer = 0; Y : integer = 0) : hrgn;
var
  l, i : integer;
  subrgn : HRGN;
begin
  l := Length(sp.ArOR);
  Result := CreateRectRgn(X, Y, sp.CaptionWidth + X, sp.Form.Height + Y);
  if l > 0 then for i := 0 to l - 1 do begin
    subrgn := CreateRectRgn(sp.ArOR[i].Left + X, sp.ArOR[i].Top + Y, sp.ArOR[i].Right + X, sp.ArOR[i].Bottom + Y);
    CombineRgn(Result, Result, subrgn, RGN_DIFF);
    DeleteObject(subrgn);
  end;
end;

procedure RefreshFormScrolls(SkinProvider : TsSkinProvider; var ListSW : TacScrollWnd; Repaint : boolean);
begin
  if not (csDestroying in SkinProvider.ComponentState) and SkinProvider.Form.HandleAllocated and TForm(SkinProvider.Form).AutoScroll then begin
    if SkinProvider.SkinData.Skinned then begin
      if Assigned(Ac_UninitializeFlatSB) then Ac_UninitializeFlatSB(SkinProvider.Form.Handle);
      if (ListSW <> nil) and ListSW.Destroyed then FreeAndNil(ListSW);
      if ListSW = nil then ListSW := TacScrollWnd.Create(SkinProvider.Form.Handle, SkinProvider.SkinData, SkinProvider.SkinData.SkinManager, '', False);
    end
    else begin
      if ListSW <> nil then FreeAndNil(ListSW);
      if Assigned(Ac_InitializeFlatSB) then Ac_InitializeFlatSB(SkinProvider.Form.Handle);
    end;
  end;
end;

procedure ForbidDrawing(sp : TsSkinProvider; MDIAlso : boolean = False);
begin
  sp.SkinData.BeginUpdate;
  sp.Form.Perform(WM_SETREDRAW, 0, 0);
  if MDIAlso and (TForm(sp.Form).FormStyle = fsMDIChild) and Assigned(MDISkinProvider) then begin
    TsSkinProvider(MDISkinProvider).SkinData.BeginUpdate;
    TsSkinProvider(MDISkinProvider).Form.Perform(WM_SETREDRAW, 0, 0);
  end;
end;

procedure PermitDrawing(sp : TsSkinProvider; MDIAlso : boolean = False);
begin
  sp.SkinData.EndUpdate;
  sp.Form.Perform(WM_SETREDRAW, 1, 0);
  if MDIAlso and (TForm(sp.Form).FormStyle = fsMDIChild) and Assigned(MDISkinProvider) then begin
    TsSkinProvider(MDISkinProvider).SkinData.EndUpdate;
    TsSkinProvider(MDISkinProvider).Form.Perform(WM_SETREDRAW, 1, 0);
  end;
end;

function HaveBorder(sp : TsSkinProvider) : boolean;
begin
  Result := (sp.Form.BorderStyle <> bsNone) or (GetWindowLong(sp.Form.Handle, GWL_STYLE) and WS_CHILD = WS_CHILD) or (TForm(sp.Form).FormStyle = fsMDIChild) {remove fsMDIChild in Beta} 
end;

procedure UpdateSkinCaption(SkinProvider : TsSkinProvider);
var
  DC, SavedDC : hdc;
begin
  if InAnimation(SkinProvider) or not SkinProvider.Form.visible or not SkinProvider.DrawNonClientArea or (csDestroyingHandle in SkinProvider.Form.ControlState) or not SkinProvider.SkinData.Skinned then Exit;
  with SkinProvider do
  if (TForm(Form).FormStyle = fsMDIChild) and (Form.WindowState = wsMaximized) then begin
    TsSkinProvider(MDISkinProvider).FCommonData.BGChanged := True;
    DC := GetWindowDC(TsSkinProvider(MDISkinProvider).Form.Handle);
    SavedDC := SaveDC(DC);
    try
      TsSkinProvider(MDISkinProvider).PaintCaption(DC);
    finally
      RestoreDC(DC, SavedDC);
      ReleaseDC(TsSkinProvider(MDISkinProvider).Form.Handle, DC);
    end;
  end
  else if SkinProvider.BorderForm = nil then begin
    FCommonData.BGChanged := True;
    DC := GetWindowDC(Form.Handle);
    SavedDC := SaveDC(DC);
    try
     if SkinData.FCacheBmp = nil // Preventing of painting before ExBorders, usually when MainMenu exists
       then InitExBorders(SkinData.SkinManager.ExtendedBorders);
      PaintCaption(DC);
    finally
      RestoreDC(DC, SavedDC);
      ReleaseDC(Form.Handle, DC);
    end;
  end
  else begin
    if SkinProvider.FGlow1 <> nil then FreeAndNil(SkinProvider.FGlow1);
    if SkinProvider.FGlow2 <> nil then FreeAndNil(SkinProvider.FGlow2);
    FCommonData.BGChanged := True;
    SkinProvider.BorderForm.UpdateExBordersPos;
  end
end;

function GetNearestSize(Max : integer) : integer;
begin
  case Max of
    -100..8 : Result := 1;
    9..16 : Result := 8;
    else Result := 16
  end;
end;

function GetSkinProvider(Cmp : TComponent) : TsSkinProvider;
var
  c : TComponent;
  sp : integer;
begin
  Result := nil;
  c := Cmp;
  while Assigned(c) and not (c is TCustomForm) do c := c.Owner;
  if (c is TCustomForm) then begin
    sp := SendMessage(TCustomForm(c).Handle, SM_ALPHACMD, MakeWParam(0, AC_GETPROVIDER), 0);
    if sp <> 0 then Result := TsSkinProvider(sp);
  end;
end;

function TitleIconWidth(SP : TsSkinProvider) : integer;
begin
  if SP.IconVisible then begin
    if SP.TitleIcon.Width <> 0 then Result := SP.TitleIcon.Width else Result := GetNearestSize(SP.CaptionHeight);
  end
  else Result := 0;
end;

function TitleIconHeight(SP : TsSkinProvider) : integer;
begin
  if SP.IconVisible then begin
    if SP.TitleIcon.Height <> 0 then Result := SP.TitleIcon.Height else Result := GetNearestSize(SP.CaptionHeight);
  end
  else Result := 0;
end;

procedure DrawAppIcon(SkinProvider : TsSkinProvider);
var
  iW, iH, x, y : integer;
  R : TRect;
  Ico : hicon;
  Bmp : TBitmap;
  S, D : PRGBAArray;
begin
  with SkinProvider do if IconVisible then begin
    R := IconRect;
    if not TitleIcon.Glyph.Empty then begin
      TitleIcon.Glyph.Transparent := True;
      TitleIcon.Glyph.TransparentColor := clFuchsia;
      iW := iffi(TitleIcon.Width = 0, GetNearestSize(HeaderHeight - 2), TitleIcon.Width);
      iH := iffi(TitleIcon.Width = 0, GetNearestSize(HeaderHeight - 2), TitleIcon.Height);
      if TitleIcon.Glyph.PixelFormat = pf32bit then begin
        CopyByMask(Rect(R.Left, R.Top, R.Left + TitleIcon.Glyph.Width, R.Left + TitleIcon.Glyph.Height),
                   Rect(0, 0, TitleIcon.Glyph.Width, TitleIcon.Glyph.Height), FCommonData.FCacheBmp, TitleIcon.Glyph, EmptyCI, False);
      end
      else FCommonData.FCacheBmp.Canvas.StretchDraw(Rect(R.Left, R.Top, R.Left + iW, R.Top + iH), TitleIcon.Glyph);
    end
    else begin
      Bmp := CreateBmp32(WidthOf(R), HeightOf(R));
      BitBlt(Bmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, FCommonData.FCacheBmp.Canvas.Handle, R.Left, R.Top, SRCCOPY);

      if TForm(Form).Icon.Handle <> 0 then begin
        DrawIconEx(FCommonData.FCacheBmp.Canvas.Handle, R.Left, R.Top, TForm(Form).Icon.Handle, TitleIconWidth(SkinProvider), TitleIconHeight(SkinProvider), 0, 0, DI_NORMAL);
      end
      else if Application.Icon.Handle <> 0 then begin
        Ico := hicon(SendMessage(Application.Handle, WM_GETICON, 2 {ICON_SMALL2}, 0));
        if Ico <> 0 then DrawIconEx(FCommonData.FCacheBmp.Canvas.Handle, R.Left, R.Top, Ico, TitleIconWidth(SkinProvider), TitleIconHeight(SkinProvider), 0, 0, DI_NORMAL);
      end
      else begin
        iW := iffi(TitleIcon.Width = 0, CaptionHeight - R.Top, TitleIcon.Width);
        iH := iffi(TitleIcon.Height = 0, CaptionHeight - R.Top, TitleIcon.Height);
        if (iH > 16) and (AppIconLarge <> nil)
          then DrawIconEx(FCommonData.FCacheBmp.Canvas.Handle, R.Left, R.Top, AppIconLarge.Handle, iW, iH, 0, 0, DI_NORMAL)
          else if (AppIcon <> nil)
            then DrawIconEx(FCommonData.FCacheBmp.Canvas.Handle, R.Left, R.Top, AppIcon.Handle, iW, iH, 0, 0, DI_NORMAL)
            else DrawIconEx(FCommonData.FCacheBmp.Canvas.Handle, R.Left, R.Top, LoadIcon(0, IDI_APPLICATION), TitleIconWidth(SkinProvider), TitleIconHeight(SkinProvider), 0, 0, DI_NORMAL);
      end;

      for y := 0 to Bmp.Height - 1 do begin
        S := Bmp.ScanLine[y];
        D := FCommonData.FCacheBmp.ScanLine[y + R.Top];
        for x := 0 to Bmp.Width - 1 do begin
          if (D[x + R.Left].R <> S[x].R) or (D[x + R.Left].G <> S[x].G) or (D[x + R.Left].B <> S[x].B)
            then D[x + R.Left].A := MaxByte
            else D[x + R.Left] := S[x];
        end;
      end;
      FreeAndNil(Bmp);
    end;
  end;
end;

function GetWindowWidth(Handle : hwnd) : integer;
var
  R : TRect;
begin
  GetWindowRect(Handle, R);
  Result := WidthOf(R)
end;

function GetClientWidth(Handle : hwnd) : integer;
var
  R : TRect;
begin
  GetClientRect(Handle, R);
  Result := WidthOf(R)
end;

function GetWindowHeight(Handle : hwnd) : integer;
var
  R : TRect;
begin
  GetWindowRect(Handle, R);
  Result := HeightOf(R)
end;

function GetClientHeight(Handle : hwnd) : integer;
var
  R : TRect;
begin
  GetClientRect(Handle, R);
  Result := HeightOf(R)
end;

{ TsSkinProvider }

procedure TsSkinProvider.AfterConstruction;
begin
  inherited;
  if not RTEmpty and not RTInit and Assigned(FCommonData.SkinManager) and FCommonData.SkinManager.Active and not (csDesigning in ComponentState) then begin
    PrepareForm;
  end;
end;

function TsSkinProvider.BarWidth(i : integer): integer;
begin
  Result := (WidthOfImage(FCommonData.SkinManager.ma[i])) * 2 + TitleBtnsWidth;
end;

function TsSkinProvider.BorderHeight(CheckSkin : boolean = True): integer;
begin
  Result := SysBorderHeight(Form.Handle, BorderForm, CheckSkin) + Form.BorderWidth
end;

function TsSkinProvider.BorderWidth(CheckSkin : boolean = True): integer;
begin
  Result := SysBorderWidth(Form.Handle, BorderForm, CheckSkin) + Form.BorderWidth;
end;

function TsSkinProvider.ButtonHeight: integer;
begin
  if FCommonData.SkinManager.IsValidImgIndex(ButtonClose.ImageIndex) then begin
    Result := HeightOfImage(FCommonData.SkinManager.ma[ButtonClose.ImageIndex])
  end
  else Result := 21;
end;

function TsSkinProvider.SysButtonsCount: integer;
begin
  Result := 0;
  if Assigned(SystemMenu) and SystemMenu.VisibleClose then begin
    inc(Result);
    if SystemMenu.VisibleMax then inc(Result);
    if SystemMenu.VisibleMin then inc(Result);
    if (biHelp in Form.BorderIcons) then inc(Result);
  end;
end;

function TsSkinProvider.SysButtonWidth(Btn : TsCaptionButton): integer;
begin
  if FCommonData.SkinManager.IsValidImgIndex(Btn.ImageIndex) then begin
    if FCommonData.SkinManager.ma[Btn.ImageIndex].Bmp = nil
     then Result := WidthOfImage(FCommonData.SkinManager.ma[Btn.ImageIndex])
     else Result := FCommonData.SkinManager.ma[Btn.ImageIndex].Bmp.Width div FCommonData.SkinManager.ma[Btn.ImageIndex].ImageCount;
  end
  else Result := 21;
end;

function TsSkinProvider.CaptionHeight(CheckSkin : boolean = True): integer;
begin
{
  if HaveBorder(Self) and (GetWindowLong(Form.Handle, GWL_STYLE) and WS_CAPTION = WS_CAPTION) or IsIconic(Form.Handle) then begin
    if CheckSkin then begin
      Result := SkinTitleHeight(Self.BorderForm);
      if Result = 0 then Result := SysCaptHeight(Form) + 4;
    end
    else Result := SysCaptHeight(Form) + 4;
  end
  else Result := 0;
}
  Result := 0;
  if HaveBorder(Self) and (GetWindowLong(Form.Handle, GWL_STYLE) and WS_CAPTION = WS_CAPTION) or IsIconic(Form.Handle) then begin
    if CheckSkin then Result := SkinTitleHeight(Self.BorderForm);
    if FSysExHeight then begin // Used for GetMinMax message (Y can't be smaller then Zero there)
      if (Form.BorderStyle in [bsToolWindow, bsSizeToolWin]) and not IsIconic(Form.Handle)
        then Result := max(Result, GetSystemMetrics(SM_CYSMCAPTION) + 4) //}SysBorderWidth(Form.Handle, BorderForm, False))
        else Result := max(Result, GetSystemMetrics(SM_CYCAPTION) + 4) //}SysBorderWidth(Form.Handle, BorderForm, False));
    end
    else if Result = 0 then begin
      if (Form.BorderStyle in [bsToolWindow, bsSizeToolWin]) and not IsIconic(Form.Handle)
        then Result := GetSystemMetrics(SM_CYSMCAPTION)
        else Result := GetSystemMetrics(SM_CYCAPTION)
    end;
  end
  else Result := 0;
end;

{$IFNDEF DISABLEPREVIEWMODE}

procedure TrySayHelloToEditor(Handle : THandle);
var
  h : hwnd;
  Count : integer;
begin
  if acPreviewNeeded and (acPreviewHandle = 0) and ((Application.MainForm <> nil) and Application.MainForm.HandleAllocated and (Application.MainForm.Handle = Handle) or (Application.MainForm = nil)) then begin
    acPreviewHandle := Handle;
    acPreviewNeeded := False;
    for Count := 0 to 100 do begin
      h := FindWindow(nil, PChar(s_EditorCapt));
      if (h <> 0) then begin
        if (SendMessage(h, ASE_MSG, ASE_HELLO, LongInt(Handle)) = 1) then Break;
      end
      else Break;
    end;
  end;
end;

{$ENDIF}

constructor TsSkinProvider.Create(AOwner: TComponent);
var
  i : integer;
  sp : TsSkinProvider;
begin
  if not (AOwner is TCustomForm) then Raise EAbort.Create('TsSkinProvider component may be used with forms only!');
{$IFNDEF DISABLEPREVIEWMODE}
  acPreviewNeeded := not (csDesigning in ComponentState) and (ParamCount > 0) and (ParamStr(1) = s_PreviewKey); // If called from the SkinEditor for a skin preview (Skin Edit mode)
{$ENDIF}

  Form := TForm(AOwner);

  RTEmpty := False;
  // Search other SkinProvider
  if (csDesigning in AOwner.ComponentState) then begin
    for i := 0 to Form.ComponentCount - 1 do if (Form.Components[i] is TsSkinProvider) and (Form.Components[i] <> Self) then begin
      Form := nil;
      Raise EAbort.Create('Only one instance of the TsSkinProvider component is allowed!');
    end;
  end
  else begin
    sp := TsSkinProvider(Form.Perform(SM_ALPHACMD, MakeWParam(0, AC_GETPROVIDER), 0));
    if (sp <> nil) then begin
      if sp.RTInit then FreeAndNil(sp) else RTEmpty := True;
    end;
  end;

  inherited Create(AOwner);

  FGlow1 := nil;
  FGlow2 := nil;
  RTInit := False;
  FDrawNonClientArea := True;
  FTitleSkinIndex := -1;
  FCaptionSkinIndex := -1;
  Form := TForm(GetOwnerForm(Self));
  FInAnimation := False;
  FAllowExtBorders := True;
  FAllowBlendOnMoving := True;
  CoverForm := nil;
//  FMouseMovePressed := False;
  OldWndProc := nil;
  FormTimer := nil;

  fAnimating := False;
  HaveSysMenu := False;
  InMenu := False;
  ShowAction := saIgnore;

  FCommonData := TsCommonData.Create(Self, False);
  FCommonData.SkinSection := s_Form;
  FCommonData.COC := COC_TsSkinProvider;
  if Form.ControlState <> [] then FCommonData.Updating := True;

  FAddedTitle := TacAddedTitle.Create;
  FAddedTitle.FOwner := Self;

  FResizeMode := rmStandard;
  FUseGlobalColor := True;
  MDIForm := nil;
  InAero := AeroIsEnabled;

  MenuChanged := True;
  FMakeSkinMenu := DefMakeSkinMenu;
  MenusInitialized := False;
  RgnChanged := True;
  RgnChanging := False;
  FScreenSnap := False;
  FSnapBuffer := 10;

  FShowAppIcon := True;
  FCaptionAlignment := taLeftJustify;
  FTitleIcon := TsTitleIcon.Create;
  FTitleButtons := TsTitleButtons.Create(Self);

  FGripMode := gmNone;
  ClearButtons := False;
  OldCaptFormProc := nil;

  if not (csDesigning in ComponentState) and (Form <> nil) and not RTEmpty then begin
    Form.DoubleBuffered := False;
    TempBmp := TBitmap.Create;
    TempBmp.Canvas.Lock;
    MenuLineBmp := CreateBmp32(0, 0);
    ClearButtons := True;
    SetLength(ArOR, 0);
    FLinesCount := -1;
    OldWndProc := Form.WindowProc;
    Form.WindowProc := NewWndProc;
    IntSkinForm(Form);
    FormActive := True;
  end;
end;

destructor TsSkinProvider.Destroy;
begin
  if Assigned(FAddedTitle) then begin
    InitExBorders(False);
    FreeAndNil(FAddedTitle);
    if not (csDesigning in ComponentState) then begin
      KillAnimations;
      if Form <> nil then begin
        IntUnskinForm(Form);
        Form.WindowProc := OldWndProc;
        if (Form.FormStyle = fsMDIChild) and Assigned(Form.Menu) then begin
          if Assigned(MDISkinProvider) and
               not (csDestroying in TsSkinProvider(MDISkinProvider).ComponentState) and
               not (csDestroying in TsSkinProvider(MDISkinProvider).Form.ComponentState)
                 then begin
            TsSkinProvider(MDISkinProvider).FCommonData.BGChanged := True;
            TsSkinProvider(MDISkinProvider).FLinesCount := -1;
            SendMessage(TsSkinProvider(MDISkinProvider).Form.Handle, WM_NCPAINT, 0, 0);
          end;
        end;
        if MDISkinProvider = Self then begin
          if MDIForm <> nil then HookMDI(False);
          MDISkinProvider := nil;
        end;
      end;
      if Assigned(SystemMenu) then FreeAndNil(SystemMenu);
      if Assigned(TempBmp) then FreeAndnil(TempBmp);
      if Assigned(MenuLineBmp) then FreeAndNil(MenuLineBmp);
//      if TitleBG <> nil then FreeAndNil(TitleBG);
    end;
  end;

  if ChildProvider = Self then ChildProvider := nil;

  if Assigned(FGlow1) then FreeAndNil(FGlow1);
  if Assigned(FGlow2) then FreeAndNil(FGlow2);
  if Assigned(FTitleIcon) then FreeAndNil(FTitleIcon);
  if Assigned(FTitleButtons) then FreeAndNil(FTitleButtons);

  if Assigned(Adapter) then FreeAndNil(Adapter);
  if ListSW <> nil then FreeAndNil(ListSW);
  if FCommonData <> nil then begin
    FreeAndNil(FCommonData);
  end;
  if Assigned(FormTimer) then FreeAndNil(FormTimer);
  inherited Destroy;
end;

procedure TsSkinProvider.RepaintButton(i: integer);
var
  DC, SavedDC : hdc;
  CurButton : PsCaptionButton;
  cx, ind, x, y, addY : integer;
  BtnDisabled : boolean;
  CI : TCacheInfo;
  R : TRect;
begin
  x := 0;
  y := 0;
  CurButton := nil;
  case i of
    HTCLOSE      : CurButton := @ButtonClose;
    HTMAXBUTTON  : CurButton := @ButtonMax;
    HTMINBUTTON  : CurButton := @ButtonMin;
    HTHELP       : CurButton := @ButtonHelp;
    HTCHILDCLOSE : CurButton := @MDIClose;
    HTCHILDMAX   : CurButton := @MDIMax;
    HTCHILDMIN   : CurButton := @MDIMin
    else if Between(i, HTUDBTN, (HTUDBTN + TitleButtons.Count - 1)) and TitleButtons.Items[i - HTUDBTN].Visible then CurButton := @TitleButtons.Items[i - HTUDBTN].BtnData;
  end;
  if (i in [HTCHILDCLOSE]) and not MDIButtonsNeeded then Exit;

  if (i in [HTCHILDCLOSE..HTCHILDMIN]) or (not FCommonData.SkinManager.Effects.AllowGlowing and (BorderForm = nil)) or (FormState <> 0) or (Form.Parent <> nil) or (Form.FormStyle = fsMDIChild) then begin
    if (CurButton <> nil) and (CurButton^.State <> -1) then begin
      BtnDisabled := False;
      if CurButton^.Rect.Left <= IconRect.Right then Exit;
      cx := CaptionWidth - CurButton^.Rect.Left;
      BitBlt(FCommonData.FCacheBmp.Canvas.Handle, // Restore a button BG
        CurButton^.Rect.Left, CurButton^.Rect.Top, SysButtonwidth(CurButton^), ButtonHeight, TempBmp.Canvas.Handle, TempBmp.Width - cx, CurButton^.Rect.Top, SRCCOPY);
      // if Max btn and form is maximized then Norm btn
      if (i = HTMAXBUTTON) and (Form.WindowState = wsMaximized) then ind := FCommonData.SkinManager.GetMaskIndex(FCommonData.SkinIndex, s_GlobalInfo, s_BorderIconNormalize)
      else case i of
        HTCHILDMIN : begin
          ind := CurButton^.ImageIndex;
          if ChildProvider <> nil then BtnDisabled := not ChildProvider.SystemMenu.EnabledMin;
          if BtnDisabled then Exit;
        end;
        HTCHILDMAX : begin // Correction of the Maximize button (may be Normalize)
          if Assigned(Form.ActiveMDIChild) and (Form.ActiveMDIChild.WindowState = wsMaximized) then begin
            ind := FCommonData.SkinManager.GetMaskIndex(FCommonData.SkinManager.ConstData.IndexGlobalInfo, s_GlobalInfo, s_SmallIconNormalize);
            if ind < 0 then ind := FCommonData.SkinManager.GetMaskIndex(FCommonData.SkinIndex, s_GlobalInfo, s_BorderIconNormalize) // For compatibility
          end
          else ind := CurButton^.ImageIndex;
          if ChildProvider <> nil then BtnDisabled := not ChildProvider.SystemMenu.EnabledRestore;
        end
        else if IsIconic(Form.Handle) then begin
          case i of
            HTMINBUTTON : begin
              ind := FCommonData.SkinManager.GetMaskIndex(FCommonData.SkinManager.ConstData.IndexGlobalInfo, s_GlobalInfo, s_BorderIconNormalize);
              if ind < 0 then ind := FCommonData.SkinManager.GetMaskIndex(FCommonData.SkinIndex, FCommonData.SkinSection, s_BorderIconNormalize); // For compatibility
            end;
            HTMAXBUTTON : begin
              ind := FCommonData.SkinManager.GetMaskIndex(FCommonData.SkinManager.ConstData.IndexGlobalInfo, s_GlobalInfo, s_BorderIconMaximize);
              if ind < 0 then ind := FCommonData.SkinManager.GetMaskIndex(FCommonData.SkinIndex, FCommonData.SkinSection, s_BorderIconMaximize); // For compatibility
              if not SystemMenu.EnabledMax then BtnDisabled := True;
            end
            else ind := CurButton^.ImageIndex;
          end
        end else ind := CurButton^.ImageIndex;
      end;
      if FCommonData.SkinManager.IsValidImgIndex(ind) then begin // Drawing of the button from skin
        if i < HTUDBTN // if not user defined
          then DrawSkinGlyph(FCommonData.FCacheBmp, Point(CurButton^.Rect.Left, CurButton^.Rect.Top),
                 CurButton^.State, 1 + integer(not FormActive or BtnDisabled) * integer((CurButton^.State = 0) or BtnDisabled), FCommonData.SkinManager.ma[ind], MakeCacheInfo(SkinData.FCacheBmp))
          else if (TitleButtons.Items[i - HTUDBTN].UseSkinData)
               then DrawSkinGlyph(FCommonData.FCacheBmp, Point(CurButton^.Rect.Left, CurButton^.Rect.Top),
                 CurButton^.State, 1 + integer(not FormActive) * integer(CurButton^.State = 0), FCommonData.SkinManager.ma[ind], MakeCacheInfo(SkinData.FCacheBmp));
      end;
      // If user Glyph is defined
      if (i >= HTUDBTN) and Assigned(TitleButtons.Items[i - HTUDBTN].Glyph) then begin
        if TitleButtons.Items[i - HTUDBTN].Glyph.PixelFormat = pf32bit then begin
          x := CurButton^.Rect.Left + integer(CurButton^.State = 2) + (WidthOf(CurButton^.Rect) - TitleButtons.Items[i - HTUDBTN].Glyph.Width) div 2;
          y := CurButton^.Rect.Top + integer(CurButton^.State = 2) + (HeightOf(CurButton^.Rect) - TitleButtons.Items[i - HTUDBTN].Glyph.Height) div 2;
          CI := MakeCacheInfo(FCommonData.FCacheBmp, x, y);
          CopyByMask(Rect(x, y, x + TitleButtons.Items[i - HTUDBTN].Glyph.Width, y + TitleButtons.Items[i - HTUDBTN].Glyph.Height),
                     Rect(0, 0, TitleButtons.Items[i - HTUDBTN].Glyph.Width, TitleButtons.Items[i - HTUDBTN].Glyph.Height),
                     FCommonData.FCacheBmp,
                     TitleButtons.Items[i - HTUDBTN].Glyph,
                     CI, True);
        end
        else begin
          TitleButtons.Items[i - HTUDBTN].Glyph.PixelFormat := pf32bit;
          CopyTransBitmaps(FCommonData.FCacheBmp, TitleButtons.Items[i - HTUDBTN].Glyph,
               CurButton^.Rect.Left + integer(CurButton^.State = 2) + (WidthOf(CurButton^.Rect) - TitleButtons.Items[i - HTUDBTN].Glyph.Width) div 2,
               CurButton^.Rect.Top + integer(CurButton^.State = 2) + (HeightOf(CurButton^.Rect) - TitleButtons.Items[i - HTUDBTN].Glyph.Height) div 2,
               TsColor(TitleButtons.Items[i - HTUDBTN].Glyph.Canvas.Pixels[0, TitleButtons.Items[i - HTUDBTN].Glyph.Height - 1]));
        end;
      end;
      // Copying to form
      DC := GetWindowDC(Form.Handle);
      SavedDC := SaveDC(DC);
      try
        if BorderForm <> nil then begin
          if IsZoomed(Form.Handle) then begin
            if FSysExHeight
              then addY := ShadowSize.Top + DiffTitle(BorderForm) + 4
              else addY := BorderForm.OffsetY;
            BitBlt(DC, CurButton^.Rect.Left - DiffBorder(Self.BorderForm) - ShadowSize.Left, CurButton^.Rect.Top - addY, WidthOf(CurButton^.Rect), HeightOf(CurButton^.Rect),
                        FCommonData.FCacheBmp.Canvas.Handle, CurButton^.Rect.Left, CurButton^.Rect.Top, SRCCOPY)
          end
          else BitBlt(DC, CurButton^.Rect.Left - DiffBorder(Self.BorderForm) - ShadowSize.Left, CurButton^.Rect.Top - DiffTitle(Self.BorderForm) - ShadowSize.Top, WidthOf(CurButton^.Rect), HeightOf(CurButton^.Rect),
                        FCommonData.FCacheBmp.Canvas.Handle, CurButton^.Rect.Left, CurButton^.Rect.Top, SRCCOPY)
        end
        else BitBlt(DC, CurButton^.Rect.Left, CurButton^.Rect.Top, WidthOf(CurButton^.Rect), HeightOf(CurButton^.Rect),
                        FCommonData.FCacheBmp.Canvas.Handle, CurButton^.Rect.Left, CurButton^.Rect.Top, SRCCOPY);
        if (CurButton^.State = 1) and (i in [HTCLOSE, HTMAXBUTTON, HTMINBUTTON]) then begin
          case i of
            HTCLOSE      : x := FCommonData.SkinManager.SkinData.BICloseGlow;
            HTMAXBUTTON  : x := FCommonData.SkinManager.SkinData.BIMaxGlow;
            HTMINBUTTON  : x := FCommonData.SkinManager.SkinData.BIMinGlow;
          end;
          if x > 0 then begin
            case i of
              HTCLOSE      : y := FCommonData.SkinManager.SkinData.BICloseGlowMargin;
              HTMAXBUTTON  : y := FCommonData.SkinManager.SkinData.BIMaxGlowMargin;
              HTMINBUTTON  : y := FCommonData.SkinManager.SkinData.BIMinGlowMargin;
            end;
            if BorderForm <> nil
              then GetWindowRect(BorderForm.AForm.Handle, R)
              else GetWindowRect(Form.Handle, R);
            OffsetRect(R, CurButton^.Rect.Left, CurButton^.Rect.Top);
            R.Right := R.Left + WidthOf(CurButton^.Rect);
            R.Bottom := R.Top + HeightOf(CurButton^.Rect);

            if SkinData.SkinManager.Effects.AllowGlowing and (Form.Parent = nil) and (Form.FormStyle <> fsMDIChild) then begin
              if BorderForm <> nil
                then CurButton^.GlowID := ShowGlow(R, R, s_GlobalInfo, FCommonData.SkinManager.ma[CurButton.ImageIndex].PropertyName + s_Glow, y, 255, BorderForm.AForm.Handle, FCommonData.SkinManager)
                else CurButton^.GlowID := ShowGlow(R, R, s_GlobalInfo, FCommonData.SkinManager.ma[CurButton.ImageIndex].PropertyName + s_Glow, y, 255, Form.Handle, FCommonData.SkinManager);
            end
          end;
        end
        else if CurButton^.GlowID <> -1 then begin
          HideGlow(CurButton^.GlowID);
          CurButton^.GlowID := -1;
        end;
      finally
        RestoreDC(DC, SavedDC);
        ReleaseDC(Form.Handle, DC);
      end;
    end
    else if (CurButton <> nil) and (CurButton^.GlowID <> -1) then begin
      HideGlow(CurButton^.GlowID);
      CurButton^.GlowID := -1;
    end;
  end
  else begin
    if (CurButton <> nil) and (CurButton^.State <> -1) then begin
      case CurButton^.State of
        1 : StartSBAnimation(CurButton, CurButton^.State, 10, CurButton^.State <> 0, Self);
        2 : StartSBAnimation(CurButton, CurButton^.State, 1, CurButton^.State <> 0, Self);
        else StartSBAnimation(CurButton, CurButton^.State, 10, False, Self);
      end;
    end
  end;
end;

function TsSkinProvider.HTProcess(var Message : TWMNCHitTest): integer;
const
  BtnSpacing = 1;
  DefRESULT = HTCLIENT;
var
  p : TPoint;
  ii, i, sbw, SysBtnCount, BtnIndex : integer;
  GripVisible : boolean;
  R, hrect, vrect : TRect;
  function GetBtnIndex : integer;
  var
    i, c : integer;
  begin
    Result := 0;
    if BorderForm <> nil then Exit;
    c := 0;
    if SystemMenu.VisibleClose and Assigned(SystemMenu) then begin
      inc(c);
      if PtInRect(ButtonClose.Rect, p) then Result := c else begin
        if SystemMenu.VisibleMax then begin
          inc(c);
          if PtInRect(ButtonMax.Rect, p) then begin
            Result := c;
            Exit;
          end;
        end;
        if SystemMenu.VisibleMin then begin
          inc(c);
          if PtInRect(ButtonMin.Rect, p) then Result := c
        end;
        if Result <> 0 then Exit;
        if (biHelp in Form.BorderIcons) then begin
          inc(c);
          if PtInRect(ButtonHelp.Rect, p) then begin
            Result := c;
            Exit;
          end;
        end;
      end;
    end;
    for i := 0 to TitleButtons.Count - 1 do begin
      inc(c);
      if not TitleButtons[i].Visible then Continue;
      if PtInRect(TitleButtons[i].BtnData.Rect, p) then begin
        Result := c;
        Exit;
      end;
    end;
  end;
begin
  p := CursorToPoint(Message.XPos, Message.YPos);
  Result := DefRESULT;

  BtnIndex := GetBtnIndex;
  if (BtnIndex > 0) then begin
    SysBtnCount := 0;
    if SystemMenu.VisibleClose then begin                          
      inc(SysBtnCount);
      if SystemMenu.VisibleMax then inc(SysBtnCount);
      if SystemMenu.VisibleMin or IsIconic(Form.Handle) then inc(SysBtnCount);
      if biHelp in Form.BorderIcons then inc(SysBtnCount);
    end;
    if (BtnIndex <= SysBtnCount) then begin
      case BtnIndex of
        1 : if SystemMenu.VisibleClose then Result := HTCLOSE;
        2 : begin
          if SystemMenu.VisibleMax then begin
            if (SystemMenu.EnabledMax or (SystemMenu.EnabledRestore and not IsIconic(Form.Handle))) then Result := HTMAXBUTTON else Result := HTCAPTION;
          end
          else if (SystemMenu.VisibleMin) or IsIconic(Form.Handle) then begin
            if SystemMenu.EnabledMin then Result := HTMINBUTTON else Result := HTCAPTION;
          end
          else if (biHelp in Form.BorderIcons) then Result := HTHELP;
        end;
        3 : begin
          if (SystemMenu.VisibleMin) or IsIconic(Form.Handle) then begin
            if not IsIconic(Form.Handle) then begin
              if SystemMenu.EnabledMin then Result := HTMINBUTTON else Result := HTCAPTION;
            end
            else Result := HTMINBUTTON;
          end
          else if (biHelp in Form.BorderIcons) then Result := HTHELP;
        end;
        4 : if (biHelp in Form.BorderIcons) and SystemMenu.VisibleMax then Result := HTHELP;
      end;
    end
    else if (BtnIndex <= TitleButtons.Count + SysBtnCount) then begin // UDF button
      BtnIndex := BtnIndex - SysBtnCount - 1;
      if TitleButtons.Items[BtnIndex].Enabled then Result := HTUDBTN + BtnIndex;
    end;
    if Result <> DefRESULT then begin
      SetHotHT(Result);
      Exit;
    end;
  end;

  sbw := SysBorderWidth(Form.Handle, BorderForm);
  if (Form.WindowState <> wsMaximized) and (GetWindowLong(Form.Handle, GWL_STYLE) and WS_SIZEBOX = WS_SIZEBOX) and (BorderForm = nil) then begin
    if (p.Y < SysBorderHeight(Form.Handle, BorderForm, False)) then Result := HTTOP;
    if (p.Y > Form.Height - sbw) then Result := HTBOTTOM;
    if (p.X < sbw) then if Result = HTTOP then Result := HTTOPLEFT else if Result = HTBOTTOM then Result := HTBOTTOMLEFT else Result := HTLEFT;
    if (p.X > Form.Width - sbw) then if Result = HTTOP then Result := HTTOPRIGHT else if Result = HTBOTTOM then Result := HTBOTTOMRIGHT else Result := HTRIGHT;
    if Result <> DefRESULT then begin
      SetHotHT(HTTRANSPARENT);
      Exit;
    end;
  end;

  ii := SysCaptHeight(Form);
  ii := ii + SysBorderHeight(Form.Handle, BorderForm);
  if Between(p.Y, 0, ii) then begin
    if Between(p.Y, SysCaptHeight(Form) + SysBorderHeight(Form.Handle, BorderForm, False), CaptionHeight(False) + SysBorderHeight(Form.Handle, BorderForm, False) + MenuHeight) then begin
      Result := HTMENU;
      Exit;
    end;
    if PtInRect(IconRect, p)
      then Result := HTSYSMENU
      else Result := HTCAPTION;
  end
  else begin
    ii := ii + GetLinesCount * MenuHeight;
    if p.Y <= ii then begin
      // MDI child buttons
      if MDIButtonsNeeded then begin
        if PtInRect(MDICLose.Rect, Point(p.X + ShadowSize.Left + DiffBorder(BorderForm), p.Y + ShadowSize.Top + DiffTitle(BorderForm)))
          then Result := HTCHILDCLOSE
          else if PtInRect(MDIMax.Rect, Point(p.X + ShadowSize.Left + DiffBorder(BorderForm), p.Y + ShadowSize.Top + DiffTitle(BorderForm)))
            then Result := HTCHILDMAX
            else if PtInRect(MDIMin.Rect, Point(p.X + ShadowSize.Left + DiffBorder(BorderForm), p.Y + ShadowSize.Top + DiffTitle(BorderForm))) then Result := HTCHILDMIN else Result := HTMENU;
        if Result <> DefRESULT then SetHotHT(Result) else SetHotHT(0);
      end
      else Result := HTMENU;
    end
    else begin
      if IsGripVisible(Self) then GripVisible := True else
        if Assigned(ListSW) and Assigned(ListSW.sbarVert) and ListSW.sbarVert.fScrollVisible and ListSW.sbarHorz.fScrollVisible then begin
          Ac_GetHScrollRect(ListSW, Form.Handle, hrect);
          Ac_GetVScrollRect(ListSW, Form.Handle, vrect);
          GetWindowRect(Form.Handle, R);
          GripVisible := PtInRect(Rect(hrect.Right - R.Left, hrect.Top - R.Top, vrect.Right - R.Left, hrect.Bottom - R.Top), p)
      end
      else GripVisible := False;
      if GripVisible then begin
        i := FCommonData.SkinManager.GetMaskIndex(FCommonData.SkinManager.ConstData.IndexGLobalInfo, s_GlobalInfo, s_GripImage);
        if FCommonData.SkinManager.IsValidImgIndex(i) then begin
          if (BorderForm <> nil) then begin
            if (p.y > RBGripPoint(i).y - DiffTitle(Self.BorderForm) - ShadowSize.Top) and (p.x > RBGripPoint(i).x - DiffBorder(Self.BorderForm) - ShadowSize.Left) then Result := HTBOTTOMRIGHT;
          end
          else begin
            if (p.y > RBGripPoint(i).y) and (p.x > RBGripPoint(i).x) then Result := HTBOTTOMRIGHT;
          end;
        end;
      end;
      if Result <> DefRESULT
        then SetHotHT(Result)
        else SetHotHT(0);
    end;
  end;
end;

procedure UpdateMainForm;
var
  Flags : Cardinal;
begin
  if Assigned(MDISkinProvider) then with TsSkinProvider(MDISkinProvider) do begin

    TsSkinProvider(MDISkinProvider).FCommonData.BeginUpdate;
    if Assigned(TsSkinProvider(MDISkinProvider).MDIForm) then TsMDIForm(TsSkinProvider(MDISkinProvider).MDIForm).UpdateMDIIconItem;
    TsSkinProvider(MDISkinProvider).FCommonData.BGChanged := True;
    if FGlow1 <> nil then FreeAndNil(FGlow1);
    if FGlow2 <> nil then FreeAndNil(FGlow2);
    TsSkinProvider(MDISkinProvider).MenuChanged := True;
    TsSkinProvider(MDISkinProvider).FLinesCount := -1;
    TsSkinProvider(MDISkinProvider).FCommonData.EndUpdate;

    Flags := RDW_ERASE or RDW_FRAME or RDW_INTERNALPAINT or RDW_INVALIDATE;
    if UpdateNow then Flags := Flags + RDW_UPDATENOW;

    RedrawWindow(TsSkinProvider(MDISkinProvider).Form.ClientHandle, nil, 0, Flags);
    RedrawWindow(TsSkinProvider(MDISkinProvider).Form.Handle, nil, 0, RDW_FRAME or RDW_INVALIDATE);

    if UpdateNow and (TsSkinProvider(MDISkinProvider).BorderForm <> nil) then TsSkinProvider(MDISkinProvider).BorderForm.UpdateExBordersPos;
  end
end;

procedure HandleEdge(var Edge: Integer; SnapToEdge: Integer; ASnapBuffer : integer; SnapDistance: Integer = 0);
begin
  if (Abs(Edge + SnapDistance - SnapToEdge) < ASnapBuffer) then Edge := SnapToEdge - SnapDistance;
end;

function DoLayered(FormHandle : Hwnd; Layered : boolean) : boolean;
begin
  Result := False;
  if Layered and acLayered then begin
    if GetWindowLong(FormHandle, GWL_EXSTYLE) and WS_EX_LAYERED <> WS_EX_LAYERED then begin
      SetWindowLong(FormHandle, GWL_EXSTYLE, GetWindowLong(FormHandle, GWL_EXSTYLE) or WS_EX_LAYERED);
      SetLayeredWindowAttributes(FormHandle, clNone, 1, ULW_ALPHA);
      Result := True;
    end;
  end
  else begin
    SetWindowLong(FormHandle, GWL_STYLE, GetWindowLong(FormHandle, GWL_STYLE) and not WS_VISIBLE); // Avoid a form showing
    SetWindowLong(FormHandle, GWL_EXSTYLE, GetWindowLong(FormHandle, GWL_EXSTYLE) and not WS_EX_LAYERED);
  end;
end;

function acWorkRect(Form : TForm) : TRect;
begin
{$IFDEF DELPHI6UP}
  Result := Form.Monitor.WorkareaRect;
{$ELSE}
  SystemParametersInfo(SPI_GETWORKAREA, 0, @Result, 0)
{$ENDIF}
end;

type
  TAccessForm = class(TForm);

procedure TsSkinProvider.NewWndProc(var Message: TMessage);
var
  DC, SavedDC : hdc;
  mi :  TMenuItem;
  X, Y, i : integer;
  acM : TMessage;
  p : TPoint;
  UpdateClient : boolean;
  cR : TRect;
  PS : TPaintStruct;
  lInted : boolean;
{$IFNDEF NOWNDANIMATION}
  bAnim : boolean;
  AnimType : TacAnimType;
{$ENDIF}
begin
{$IFDEF LOGGED}
  if (Form <> nil) {and (Form.Tag = 1) }then
    AddToLog(Message);
{$ENDIF}
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_REMOVESKIN : begin
      if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
        if ListSW <> nil then FreeAndNil(ListSW);
        InitDwm(Form.Handle, False);
        CommonMessage(Message, FCommonData);
        FLinesCount := -1;
        FTitleSkinIndex := -1;
        FCaptionSkinIndex := -1;
        AlphaBroadCast(Form, Message);
        AdapterRemove;
        if Assigned(SkinData.SkinManager) then begin
          DeleteUnusedBmps(True);
        end;
        if (Form <> nil) and not (csDestroying in Form.ComponentState) then begin
          if Assigned(SkinData.SkinManager) then begin
            InitMenuItems(False);
            CheckSysMenu(False);
            if (Form.FormStyle = fsMDIForm) and (MDIForm <> nil) then HookMDI(False);
            if HaveBorder(Self) and not InMenu then SetWindowRgn(Form.Handle, 0, True); // Return standard kind
            UpdateMenu;
            RedrawWindow(Form.ClientHandle, nil, 0, RDW_FRAME or RDW_INVALIDATE or RDW_ERASE or RDW_ALLCHILDREN);
            InitExBorders(False);
          end;
          for i := 0 to Form.ControlCount - 1 do if Form.Controls[i] is TLabel then begin
            TLabel(Form.Controls[i]).Font.Color := clWindowText;
            if not TLabel(Form.Controls[i]).Transparent then TLabel(Form.Controls[i]).ControlStyle := TLabel(Form.Controls[i]).ControlStyle + [csOpaque];
          end;
          if UseGlobalColor and not SkinData.CustomColor then Form.Color := clBtnFace;
          if FCommonData.FCacheBmp <> nil then FreeAndNil(FCommonData.FCacheBmp);
        end;
      end
      else AlphaBroadCast(Form, Message);
      Exit
    end;
    AC_SETNEWSKIN : if not (csDestroying in Form.ComponentState) and Assigned(SkinData) then begin
      if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) and not Assigned(SystemMenu) then PrepareForm
    end;
    AC_GETAPPLICATION : begin Message.Result := longint(Application); Exit end;
    AC_PARENTCLOFFSET : begin Message.Result := MakeLong(OffsetX, OffsetY); Exit end;
    AC_CTRLHANDLED : begin Message.Result := 1; Exit end;
    AC_ENDUPDATE : begin
      if SkinData.CtrlSkinState and ACS_MNUPDATING = ACS_MNUPDATING then begin
        SkinData.CtrlSkinState := SkinData.CtrlSkinState and not ACS_MNUPDATING;
        SendMessage(Form.Handle, CM_MENUCHANGED, 0, 0);
      end;
    end;
    AC_GETBG : if (FCommonData <> nil) then begin
      PacBGInfo(Message.LParam)^.Offset := Point(0, 0);
      if FCommonData.BGChanged and (not FCommonData.FUpdating or FInAnimation) and IsCached(SkinData) then begin
        PaintAll;
      end;
      if PacBGInfo(Message.LParam)^.PleaseDraw then begin
        inc(PacBGInfo(Message.LParam)^.Offset.X, OffsetX);
        inc(PacBGInfo(Message.LParam)^.Offset.Y, OffsetY);
      end;
      if FCommonData.SkinIndex > -1
        then InitBGInfo(FCommonData, PacBGInfo(Message.LParam), min(integer(FormActive), FCommonData.SkinManager.gd[FCommonData.SkinIndex].States - 1))
        else InitBGInfo(FCommonData, PacBGInfo(Message.LParam), min(integer(FormActive), 0));
      if (PacBGInfo(Message.LParam)^.BgType = btCache) then begin
        if not PacBGInfo(Message.LParam)^.PleaseDraw then begin
          if PacBGInfo(Message.LParam)^.Bmp = nil then begin
            PaintAll;
            PacBGInfo(Message.LParam)^.Bmp := FCommonData.FCacheBmp;
          end;
        end;
      end;
//      if Form.Parent = nil then begin
        PacBGInfo(Message.LParam)^.Offset.X := PacBGInfo(Message.LParam)^.Offset.X + OffsetX;
        PacBGInfo(Message.LParam)^.Offset.Y := PacBGInfo(Message.LParam)^.Offset.Y + OffsetY;
//      end;
      Exit;
    end;
    AC_GETSKINSTATE : begin
      Message.Result := FCommonData.CtrlSkinState;
      Exit;
    end;
  end;

  if (csDestroying in Form.ComponentState) or not FCommonData.Skinned(True) then begin
    if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
      AC_GETPROVIDER : begin Message.Result := longint(Self); Exit end; // Used for menuline init
      AC_SETNEWSKIN : if not (csDestroying in Form.ComponentState) and Assigned(SkinData) then begin
        if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
          KillAnimations;
          DeleteUnusedBmps(True);
          FCommonData.UpdateIndexes;
          FTitleSkinIndex := -1;
          FTitleSkinIndex := TitleSkinIndex;
          FCaptionSkinIndex := FCommonData.SkinManager.GetSkinIndex(s_Caption);

          if (SkinData.SkinManager <> nil) then begin
            if (BorderForm <> nil) and IsZoomed(Form.Handle) then begin
              if SkinData.SkinManager.SkinData.ExMaxHeight <> 0 then i := SkinData.SkinManager.SkinData.ExMaxHeight else i := SkinData.SkinManager.SkinData.ExTitleHeight;
              FSysExHeight := i < SysCaptHeight(Form) + 4;
            end
            else FSysExHeight := False;
            UpdateIconsIndexes;
            CheckSysMenu(True);
            if (Form.FormStyle = fsMDIForm) and (Screen.ActiveForm = Form.ActiveMDIChild) then FormActive := True;
            // Menus skinning
            if not (csLoading in SkinData.SkinManager.ComponentState) then
              InitMenuItems(True); // Update after skinning in run-time
            // Menu Line refresh
            FCommonData.BGChanged := True;
            FLinesCount := -1;
            if (TForm(Form).FormStyle = fsMDIForm) then begin
//              if not Assigned(MDIForm) then
              HookMDI;
            end;
            if UseGlobalColor and not SkinData.CustomColor then Form.Color := SkinData.SkinManager.GetGlobalColor;
            InitDwm(Form.Handle, True);
          end;
          if Adapter = nil then AdapterCreate else TacCtrlAdapter(Adapter).AddAllItems;
        end;
        Exit;
      end;
    end;
    OldWndProc(Message);
    case Message.Msg of
{$IFNDEF NOWNDANIMATION}
      WM_WINDOWPOSCHANGED : if Assigned(SkinData.SkinManager) and acLayered then begin // Patch for BDS
        if (TWMWindowPosChanged(Message).WindowPos.Flags and SWP_HIDEWINDOW = SWP_HIDEWINDOW) {$IFDEF D2011} and not Application.Terminated{$ENDIF} then begin
          if not IsIconic(Form.Handle) and not SkipAnimation and
             SkinData.SkinManager.Active and DrawNonClientArea and (SkinData.SkinManager.AnimEffects.FormHide.Active) {and
               (SkinData.SkinManager.AnimEffects.FormHide.Time > 0) }then begin
            acHideTimer := nil;
            SkipAnimation := True;
            AnimHideForm(Self);
            while InAnimationProcess do Continue;
            DoLayered(Form.Handle, False);
            SkipAnimation := False;
          end
        end;
      end;
{$ENDIF}
      WM_NCDESTROY : if (Form.FormStyle = fsMDIChild) then begin
        if Assigned(MDISkinProvider) and Assigned(TsSkinProvider(MDISkinProvider).MDIForm) and not (csDestroying in TsSkinProvider(MDISkinProvider).ComponentState) and
            not (csDestroying in TsSkinProvider(MDISkinProvider).Form.ComponentState) and TsSkinProvider(MDISkinProvider).SkinData.Skinned(True) then begin
          TsSkinProvider(MDISkinProvider).RepaintMenu;
          if TsSkinProvider(MDISkinProvider).Form.ActiveMDIChild = nil
            then RedrawWindow(TsSkinProvider(MDISkinProvider).Form.ClientHandle, nil, 0, RDW_ERASE or RDW_FRAME or RDW_INTERNALPAINT or RDW_INVALIDATE or RDW_UPDATENOW);
        end;
      end;
{$IFNDEF ALITE}
      CM_MOUSEWHEEL : AC_CMMouseWheel(TCMMouseWheel(Message));
{$ENDIF}
    end;
  end
  else begin
    if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
      AC_CONTROLLOADED : if (Form <> nil) and not (csLoading in Form.ComponentState) then begin
        if (Adapter <> nil) then begin
          if (Message.LParam <> 0) then TacCtrlAdapter(Adapter).AddAllItems(TWinControl(Message.LParam)) else TacCtrlAdapter(Adapter).AddAllItems(Form);
        end;
      end;
      AC_PREPARING : if (FCommonData <> nil) then begin
        Message.Result := integer(not InAnimationProcess{LionDev} and IsCached(FCommonData) and (FCommonData.FUpdating));
        Exit
      end;
      AC_ENDPARENTUPDATE : if FCommonData.FUpdating then begin
        FCommonData.FUpdating := False;
        RedrawWindow(Form.Handle, nil, 0, RDW_FRAME or RDW_INVALIDATE);
        Exit
      end;
      AC_SETBGCHANGED : FCommonData.BGChanged := True;
      AC_UPDATING : begin
        FCommonData.Updating := Message.WParamLo = 1;
        if FCommonData.Updating then FCommonData.BGChanged := True;
      end;
      AC_REFRESH : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
        if Adapter = nil then AdapterCreate else TacCtrlAdapter(Adapter).AddAllItems;
        if FDrawNonClientArea then RefreshFormScrolls(Self, ListSW, False);
        if (Form.Parent <> nil) and (Form.FormStyle <> fsMDIChild) then FCommonData.CtrlSkinState := FCommonData.CtrlSkinState and not ACS_FAST;

        FLinesCount := -1;
        if not (csLoading in SkinData.SkinManager.ComponentState) then begin
          UpdateMenu;
          InitMenuItems(SkinData.Skinned);
        end;
        if HaveBorder(Self) then RgnChanged := True;
        if not Form.Visible then Exit;

        FCommonData.BGChanged := True;
        InitExBorders(SkinData.SkinManager.ExtendedBorders);
        if not InAnimationProcess then begin
          if (Form.FormStyle = fsMDIForm) and Assigned(Form.ActiveMDIChild) and (Form.ActiveMDIChild.WindowState = wsMaximized) then begin
            SendMessage(Form.Handle, WM_NCPAINT, 0, 0);
            InvalidateRect(Form.ActiveMDIChild.Handle, nil, True);
          end
          else begin
            RedrawWindow(Form.Handle, nil, 0, RDW_INVALIDATE or RDW_ERASE or RDW_UPDATENOW or RDW_FRAME or RDW_NOCHILDREN);
            if Form.FormStyle = fsMDIForm then RedrawWindow(Form.ClientHandle, nil, 0, RDW_INVALIDATE or RDW_ERASE or RDW_UPDATENOW or RDW_FRAME or RDW_NOCHILDREN);
          end;
        end;
        if UseGlobalColor and not SkinData.CustomColor then Form.Color := SkinData.SkinManager.GetGlobalColor;
        if MDIForm <> nil then TsMDIForm(MDIForm).ConnectToClient;
        FCommonData.Updating := False;                               // Form image is prepared now
        if SystemMenu <> nil then SystemMenu.UpdateGlyphs;
        SendToAdapter(Message);                                      // Sending message to all child adapted controls
        if (BorderForm <> nil) {and (FormState and FS_CHANGING <> FS_CHANGING) }then BorderForm.UpdateExBordersPos;
      end;
      AC_CHILDCHANGED : begin
        Message.LParam := integer((FCommonData.SkinManager.gd[SkinData.SkinIndex].GradientPercent + FCommonData.SkinManager.gd[SkinData.SkinIndex].ImagePercent > 0));
        Message.Result := Message.LParam;
        Exit;
      end;
      AC_GETCONTROLCOLOR : begin
        Message.Result := GetBGColor(SkinData, 0);
        Exit;
      end;
      AC_GETPROVIDER : begin
        Message.Result := longint(Self);
        Exit
      end; // Used for menuline init
      AC_SETNEWSKIN : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
        DeleteUnusedBmps(True);
        FCommonData.UpdateIndexes;
        FTitleSkinIndex := -1;
        FTitleSkinIndex := TitleSkinIndex;
        FCaptionSkinIndex := FCommonData.SkinManager.GetSkinIndex(s_Caption);
//        if not IsCacheRequired(FCommonData) then FCommonData.CtrlSkinState := FCommonData.CtrlSkinState or ACS_FAST else FCommonData.CtrlSkinState := FCommonData.CtrlSkinState and not ACS_FAST;
        if (SkinData.SkinManager <> nil) then begin
          UpdateIconsIndexes;

          DeleteUnusedBmps(True);
          CheckSysMenu(FDrawNonClientArea);
          SkinData.SkinManager.SkinableMenus.UpdateMenus;

          // Menu Line refresh
          FCommonData.BGChanged := True;
          FLinesCount := -1;
          SendMessage(Form.Handle, WM_NCPaint, 0, 0);
          if (TForm(Form).FormStyle = fsMDIForm) {and not Assigned(MDIForm) }then HookMDI;
        end;
      end;
      AC_BEFORESCROLL : if FCommonData.RepaintIfMoved then SendMessage(Form.Handle, WM_SETREDRAW, 0, 0);
      AC_AFTERSCROLL : if FCommonData.RepaintIfMoved then begin
        SendMessage(Form.Handle, WM_SETREDRAW, 1, 0);
        RedrawWindow(Form.Handle, nil, 0, {RDW_NOERASE or }RDW_UPDATENOW or RDW_INVALIDATE or RDW_ALLCHILDREN or RDW_FRAME or RDW_ERASE);
        if MDISkinProvider = Self then RedrawWindow(Form.ClientHandle, nil, 0, RDW_UPDATENOW or RDW_INVALIDATE or RDW_ALLCHILDREN or RDW_FRAME);
      end;
      AC_URGENTPAINT : begin
        CommonWndProc(Message, FCommonData);
        if FCommonData.UrgentPainting then PaintAll;
        Exit;
      end;
    end
    else case Message.Msg of
{$IFNDEF ALITE}
      CM_MOUSEWHEEL : begin
        OldWndProc(Message);
        AC_CMMouseWheel(TCMMouseWheel(Message));
      end;
{$ENDIF}
{$IFNDEF DISABLEPREVIEWMODE}
      ASE_MSG : begin // Used with ASkinEditor
        case Message.WParam of
          ASE_HELLO : OldWndProc(Message);
          ASE_CLOSE : Form.Close;
          ASE_ALIVE : begin
//            Message.LParam := SkinData.SkinManager.v
            Message.Result := 1;
          end;
        end;
      end;
      WM_COPYDATA : begin
        OldWndProc(Message);
        if (Message.Result = 0) and (acPreviewHandle = Form.Handle) and not acSkinPreviewUpdating then begin // SkinManager is upadated by SkinEditor (Preview mode)
          acSkinPreviewUpdating := True;
          if (Message.LParam <> 0) then ReceiveData(Message, Skindata.SkinManager);
          acSkinPreviewUpdating := False;
        end;
      end;
{$ENDIF}
      WM_DWMSENDICONICLIVEPREVIEWBITMAP : if ac_ChangeThumbPreviews then begin // Task menu support when not MainFormOnTaskBar
        Message.Result := integer(SetPreviewBmp(Form.Handle, Self));
      end;
      WM_DWMSENDICONICTHUMBNAIL : if ac_ChangeThumbPreviews and (Message.LParamHi <> 0) and (Message.LParamLo <> 0) then begin // Task menu support when not MainFormOnTaskBar
        Message.Result := integer(SetThumbIcon(Form.Handle, Self, Message.LParamHi, Message.LParamLo));
      end;
      WM_CONTEXTMENU : begin
        if (Form.PopupMenu <> nil) then SkinData.SkinManager.SkinableMenus.HookPopupMenu(Form.PopupMenu, SkinData.SkinManager.SkinnedPopups);
        OldWndProc(Message);
      end;
      WM_SETREDRAW : begin
        if (Message.WParam = 1) then LockCount := max(0, LockCount - 1) else inc(LockCount);
        OldWndProc(Message);
      end;
      WM_EXITSIZEMOVE : begin
        OldWndProc(Message);
        if (BorderForm <> nil) and (acSupportedList <> nil) then for i := 0 to acSupportedList.Count - 1 do begin
          if acSupportedList[i] <> nil then SendAMessage(TacProvider(acSupportedList[i]).CtrlHandle, AC_INVALIDATE); // Update of some popup Dlgs
        end;
//        if (BorderForm <> nil) and (fsModal in TAccessForm(Form).FormState) then BorderForm.UpdateExBordersPos(False);
      end;
      WM_GETMINMAXINFO : AC_WMGetMinMaxInfo(TWMGetMinMaxInfo(Message));
      WM_SETICON : if not (csLoading in ComponentState) and (Message.LParam <> 0) and not InAnimationProcess and Form.Showing then begin
        if not AeroIsEnabled then SendMessage(Form.Handle, WM_SETREDRAW, 0, 0);
        OldWndProc(Message);
        if not AeroIsEnabled then SendMessage(Form.Handle, WM_SETREDRAW, 1, 0);
        UpdateSkinCaption(Self);
      end
      else OldWndProc(Message);
//      WM_NCCALCSIZE : AC_WMNCCalcSize(TWMNCCalcSize(Message));
      WM_INITMENUPOPUP : AC_WMInitMenuPopup(TWMInitMenuPopup(Message));
      WM_STYLECHANGED : begin
        OldWndProc(Message);
        if (Message.WParam = GWL_EXSTYLE) and (FormState and FS_BLENDMOVING <> FS_BLENDMOVING) and (FormState and FS_ANIMMINIMIZING <> FS_ANIMMINIMIZING) and (FormState and FS_ANIMRESTORING <> FS_ANIMRESTORING) then begin
          if ((PStyleStruct(Message.LParam)^.styleNew and WS_EX_LAYERED) <> (PStyleStruct(Message.LParam)^.styleOld and WS_EX_LAYERED)) and (BorderForm <> nil) {AlphaBlend is changed}
            then BorderForm.UpdateExBordersPos;
        end;
      end;
      787 : DropSysMenu(Mouse.CursorPos.X, Mouse.CursorPos.Y);
{      CM_DEACTIVATE : begin
        if (SkinData.SkinManager.AnimEffects.FormHide.Active) and (SkinData.SkinManager.AnimEffects.FormHide.Time > 0) and DrawNonClientArea and not SkipAnimation then begin
          DoLayered(Form.Handle, True);
        end; // solving the repainting problem with InputQuery and similar wndws
        OldWndProc(Message);
      end;}
{$IFNDEF NOWNDANIMATION}
      CM_SHOWINGCHANGED : begin
        x := MaxByte;
        if FDrawNonClientArea then begin // If first showing
          if Form.Showing then begin

            if (Form.FormStyle = fsMDIChild) and ((MDISkinProvider = nil) or TsSkinProvider(MDISkinProvider).FInAnimation) then begin
              OldWndProc(Message);
              Exit;
            end;

            if (Form.FormStyle = fsMDIForm) then HookMDI;
            FormState := FormState and not FS_ANIMCLOSING;
            if BorderForm <> nil then BorderForm.ExBorderShowing := False;
            if (FormTimer <> nil) and (FormTimer is TacMinTimer) then begin
              FreeAndNil(FormTimer);
            end;

{$IFNDEF DISABLEPREVIEWMODE}
            if acPreviewNeeded and Form.HandleAllocated and ((Application.MainForm = nil) or (Application.MainForm = Form)) then TrySayHelloToEditor(Form.Handle);
{$ENDIF}

            InitMenuItems(SkinData.Skinned);
            if Adapter <> nil then TacCtrlAdapter(Adapter).AddAllItems(Form);
            fAnimating := ((Form.FormStyle = fsMDIChild) or (Form.Parent = nil)) and SkinData.SkinManager.AnimEffects.FormShow.Active{$IFNDEF DISABLEPREVIEWMODE} and (acPreviewHandle <> Form.Handle){$ENDIF};
            lInted := False;
            if fAnimating then begin
              FCommonData.Updating := True; // Don't draw child controls
              FInAnimation := True;
              lInted := DoLayered(Form.Handle, True);
              X := MaxByte;
              if lInted then begin
                UpdateRgn(Self, False);
                RgnChanging := False;
              {$IFDEF DELPHI7UP}
              end
              else begin
                X := Form.AlphaBlendValue;
                Form.AlphaBlendValue := 0;
              {$ENDIF}
              end;
              for i := 0 to Form.ControlCount - 1 do if Form.Controls[i].Visible and not (Form.Controls[i] is TCoolBar) {TCoolBar must have Painting processed for buttons aligning}
                then Form.Controls[i].Perform(WM_SETREDRAW, 0, 0);
            end
            else begin
              SkinData.Updating := False;
            end;
            InitExBorders(SkinData.SkinManager.ExtendedBorders);

            OldWndProc(Message);
            if not SkinData.Skinned then begin // Check - if form is not skinned already
              if fAnimating then begin
                for i := 0 to Form.ControlCount - 1 do if Form.Controls[i].Visible
                  then Form.Controls[i].Perform(WM_SETREDRAW, 1, 0);
                SetWindowLong(Form.Handle, GWL_EXSTYLE, GetWindowLong(Form.Handle, GWL_EXSTYLE) and not WS_EX_LAYERED);
                RedrawWindow(Form.Handle, nil, 0, RDW_ALLCHILDREN or RDW_INVALIDATE);
                RgnChanging := False;
                Exit;
              end;
            end;

            RefreshFormScrolls(Self, ListSW, False);
            if fAnimating then begin
              for i := 0 to Form.ControlCount - 1 do if Form.Controls[i].Visible
                then Form.Controls[i].Perform(WM_SETREDRAW, 1, 0);
              if lInted then DoLayered(Form.Handle, False);
              fAnimating := False;
              i := SkinData.SkinManager.AnimEffects.FormShow.Time;
              AnimType := SkinData.SkinManager.AnimEffects.FormShow.Mode;
              AnimShowForm(Self, i, X, AnimType);
              RgnChanging := False;
            end
            else begin
              RedrawWindow(Form.Handle, nil, 0, RDW_ALLCHILDREN or RDW_INVALIDATE);
            end;
            if (Form.FormStyle = fsMDIChild) and (Form.WindowState = wsMaximized) then UpdateMainForm;
          end
          else begin
            OldWndProc(Message);
            if (BorderForm <> nil) and not SkinData.SkinManager.AnimEffects.FormHide.Active then FreeAndNil(BorderForm);
          end;
        end
        else begin // Backgrounds must be drawn by all controls for a blinking prevent
          OldWndProc(Message);
          if AeroIsEnabled then RedrawWindow(Form.Handle, nil, 0, RDW_ALLCHILDREN or RDW_INVALIDATE or RDW_UPDATENOW);
        end;
      end;
{$ENDIF}
      WM_SHOWWINDOW : begin
        if (Form.FormStyle <> fsMDIChild) then begin
          if (Message.WParam = 1) then begin
            // Updating ExBorders after minimizing by system
            if (BorderForm <> nil) then BorderForm.ExBorderShowing := False;
            if FormState and FS_ANIMRESTORING = FS_ANIMRESTORING then FormState := FS_ANIMRESTORING else FormState := 0;
            // RedrawUnder Aero
            if AeroIsEnabled then begin
              if not InAnimationProcess and (GetWindowLong(Form.Handle, GWL_EXSTYLE) and WS_EX_LAYERED <> WS_EX_LAYERED) then begin
                RedrawWindow(Form.Handle, nil, 0, RDW_FRAME or RDW_ALLCHILDREN or RDW_INVALIDATE);
              end;
            end;
          end;
          case TWMShowWindow(Message).Status of
            SW_PARENTCLOSING : begin
              if ShowAction <> saIgnore then begin
                if IsIconic(Form.Handle) then ShowAction := saMinimize else begin
                  if IsZoomed(Form.Handle) then ShowAction := saMaximize else ShowAction := saRestore;
                end;
              end;
            end;
            SW_PARENTOPENING : if SkinData.SkinManager.AnimEffects.Minimizing.Active and (Application.MainForm = Form) then begin // Restore
//              StartRestoring(Self);
              OldWndProc(Message);
              Exit;
            end;
          end;
(*          if (Message.WParam = 0) and (Message.LParam in [0, SW_PARENTCLOSING]) and (FormState and FS_ANIMCLOSING <> FS_ANIMCLOSING) and
               acLayered and (SkinData.SkinManager.AnimEffects.FormHide.Active) and (SkinData.SkinManager.AnimEffects.FormHide.Time > 0) and DrawNonClientArea then begin
            FormState := FormState or FS_ANIMCLOSING;
            PaintFormTo(SkinData.FCacheBmp, Self);
            if BorderForm <> nil then begin
  {$IFDEF DELPHI7UP}
              if Form.AlphaBlend then i := Form.AlphaBlendValue else
  {$ENDIF}
              i := MaxByte;

              SetWindowRgn(BorderForm.AForm.Handle, BorderForm.MakeRgn, False);
              SetFormBlendValue(BorderForm.AForm.Handle, SkinData.FCacheBmp, i);
              SetWindowPos(BorderForm.AForm.Handle, 0, BorderForm.AForm.Left, BorderForm.AForm.Top, 0, 0, SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE or SWP_NOREDRAW or SWP_SHOWWINDOW or SWP_NOSENDCHANGING or SWP_NOOWNERZORDER);
            end;
          end;*)
        end;
        OldWndProc(Message);
        if (Message.WParam = 1) then begin
          if (Form.FormStyle = fsMDIChild) and (Form.WindowState = wsMaximized) then TsSkinProvider(MDISkinProvider).RepaintMenu;
          if (Form.FormStyle = fsMDIForm) then begin
            for i := 0 to Form.MDIChildCount - 1 do
              if not GetBoolMsg(Form.MDIChildren[i].Handle, AC_CTRLHANDLED)
                then AddSupportedForm(Form.MDIChildren[i].Handle);
          end;
          if (Form.Parent <> nil) and (Form.FormStyle <> fsMDIChild) then begin
            FCommonData.CtrlSkinState := FCommonData.CtrlSkinState and not ACS_FAST;
            FCommonData.BGChanged := True;
          end;
        end;
      end;
      WM_SETTEXT : if Form.Showing and not (csCreating in Form.ControlState) and FDrawNonClientArea then begin
        if Assigned(FGlow1) then FreeAndNil(FGlow1);
        if Assigned(FGlow2) then FreeAndNil(FGlow2);
        if (Form.FormStyle = fsMdiChild) and (Form.WindowState = wsMaximized) then begin
          TsSkinProvider(MDISkinProvider).FCommonData.BGChanged := True;
          MakeCaptForm(TsSkinProvider(MDISkinProvider));
          OldWndProc(Message);
          KillCaptForm(TsSkinProvider(MDISkinProvider));
        end
        else if not AeroIsEnabled then begin
          FCommonData.BGChanged := True;
          MakeCaptForm(Self);
          OldWndProc(Message);
          KillCaptForm(Self);
{$IFDEF DELPHI6UP}
          if Form.AlphaBlend then SendMessage(Form.Handle, WM_NCPAINT, 0, 0);
{$ENDIF}
        end
        else begin
          OldWndProc(Message);
          UpdateSkinCaption(Self);
        end;
        if BorderForm <> nil then BorderForm.UpdateExBordersPos;
      end else OldWndProc(Message);
      CM_ENABLEDCHANGED : begin
        OldWndProc(Message);
        if FDrawNonClientArea then begin
          SkinData.BGChanged := True;
          SendMessage(Form.Handle, WM_NCPAINT, 0, 0);
        end;
      end;
      WM_SYSCOLORCHANGE : begin
        OldWndProc(Message);
        UpdateMenu;
      end;
      WM_CHILDACTIVATE : begin
        OldWndProc(Message);
        UpdateMenu;
        if (MDISkinProvider <> nil) and (TsSkinProvider(MDISkinProvider).Form.ActiveMDIChild <> nil)
          then if TsSkinProvider(MDISkinProvider).Form.ActiveMDIChild.WindowState = wsMaximized
            then TsMDIForm(TsSkinProvider(MDISkinProvider).MDIForm).UpdateMDIIconItem // Repaint of main form icons and menus
            else CheckSysMenu(True); // Reinit of sysmenu
      end;
      WM_SIZE : if not SkinData.FUpdating then begin
        if IsGripVisible(Self) then begin
          i := FCommonData.SkinManager.GetMaskIndex(FCommonData.SkinManager.ConstData.IndexGLobalInfo, s_GlobalInfo, s_GripImage);
          if FCommonData.SkinManager.IsValidImgIndex(i) then begin // If grip image is defined in skin
            X := WidthOf(FCommonData.SkinManager.ma[i].R) div FCommonData.SkinManager.ma[i].ImageCount;
            Y := HeightOf(FCommonData.SkinManager.ma[i].R) div (FCommonData.SkinManager.ma[i].MaskType + 1);

            if ((Form.ClientWidth > WidthOf(LastClientRect)) or (Form.ClientHeight > HeightOf(LastClientRect))) then begin
              if not IsCached(SkinData) then begin // Refresh rect where Grip was drawn
                if (WidthOf(LastClientRect) <> 0) then begin
                  cR := Rect(LastClientRect.Right - X, LastClientRect.Bottom - Y, LastClientRect.Right, LastClientRect.Bottom);
                  InvalidateRect(Form.Handle, @cR, not IsCached(FCommonData));
                end;
              end;
            end;
            if ((Form.ClientWidth < WidthOf(LastClientRect)) or (Form.ClientHeight < HeightOf(LastClientRect))) then begin
              cR := Rect(Form.ClientWidth - X, Form.ClientHeight - Y, Form.ClientWidth, Form.ClientHeight);
              InvalidateRect(Form.Handle, @cR, not IsCached(FCommonData));
            end;
          end;
        end;

        if ((Form.ClientWidth < WidthOf(LastClientRect)) or (Form.ClientHeight < HeightOf(LastClientRect)) or (WidthOf(LastClientRect) = 0)) then begin
          i := FCommonData.SkinManager.GetMaskIndex(FCommonData.SkinIndex, FCommonData.SkinSection, s_ImgTopRight);
          if i > -1 then begin
            X := WidthOf(FCommonData.SkinManager.ma[i].R) div FCommonData.SkinManager.ma[i].ImageCount;
            Y := HeightOf(FCommonData.SkinManager.ma[i].R) div (FCommonData.SkinManager.ma[i].MaskType + 1);
            cR := Rect(LastClientRect.Right - X, LastClientRect.Bottom - Y, LastClientRect.Right, LastClientRect.Bottom);
            InvalidateRect(Form.Handle, @cR, not IsCached(FCommonData));
          end;
          i := FCommonData.SkinManager.GetMaskIndex(FCommonData.SkinIndex, FCommonData.SkinSection, s_ImgBottomRight);
          if i > -1 then begin
            X := WidthOf(FCommonData.SkinManager.ma[i].R) div FCommonData.SkinManager.ma[i].ImageCount;
            Y := HeightOf(FCommonData.SkinManager.ma[i].R) div (FCommonData.SkinManager.ma[i].MaskType + 1);
            cR := Rect(LastClientRect.Right - X, LastClientRect.Bottom - Y, LastClientRect.Right, LastClientRect.Bottom);
            InvalidateRect(Form.Handle, @cR, not IsCached(FCommonData));
          end;
        end;

        if Assigned(FGlow1) then FreeAndNil(FGlow1);
        if Assigned(FGlow2) then FreeAndNil(FGlow2);
        FLinesCount := -1;

        if Form.Parent = nil then begin
          FCommonData.FUpdating := True;
          OldWndProc(Message);
          FCommonData.FUpdating := False
        end
        else OldWndProc(Message);

        if not InAnimationProcess then begin
          if Form.Showing then begin
            if FormChanged and (not (IsIconic(Form.Handle) and InAero)) then begin
              RgnChanged := True;
              FCommonData.BGChanged := True;
              if FCommonData.FCacheBmp <> nil
                then UpdateClient := IsCached(FCommonData) and ((FCommonData.FCacheBmp.Width > Form.Width) or (FCommonData.FCacheBmp.Height > Form.Height))
                else UpdateClient := False;//True;

              if FDrawNonClientArea then begin
                if BorderForm <> nil then begin // Update extended borders
                  if ((ListSW = nil) or (not ListSW.sBarVert.fScrollVisible and not ListSW.sBarHorz.fScrollVisible)) and (ResizeMode = rmStandard)
                    then FormState := FormState or FS_SIZING;
                  BorderForm.UpdateExBordersPos;
                  FormState := FormState and not FS_SIZING;
                end;
                SendMessage(Form.Handle, WM_NCPAINT, 0, 0); // Update region
                if FCommonData.FUpdating then Exit;

                if (SkinData.BGType and BGT_GRADIENTVERT = BGT_GRADIENTVERT) and (HeightOf(LastClientRect) <> Form.ClientHeight) or
                   (SkinData.BGType and BGT_GRADIENTHORZ = BGT_GRADIENTHORZ) and (WidthOf(LastClientRect) <> Form.ClientWidth) then begin
                  acM := MakeMessage(SM_ALPHACMD, MakeWParam(1, AC_SETCHANGEDIFNECESSARY), 0, 0);
                  AlphaBroadCast(Form, acM);
                end;

                SetParentUpdated(Form);
                if (BorderForm <> nil) and ((ListSW = nil) or (ListSW.sBarVert = nil) or (ListSW.sBarHorz = nil) or (not ListSW.sBarVert.fScrollVisible and not ListSW.sBarHorz.fScrollVisible)) then begin // Pre-paint the form while is under the BorderForm
                  if BorderForm.AForm = nil then BorderForm.CreateNewForm;
                  RedrawWindow(Form.Handle, nil, 0, RDW_NOFRAME or RDW_NOERASE or RDW_INVALIDATE or RDW_UPDATENOW);
                  SetWindowPos(BorderForm.AForm.Handle, Form.Handle, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOSENDCHANGING or SWP_NOOWNERZORDER or SWP_NOREDRAW or SWP_NOSIZE or SWP_NOMOVE);
                end
                else RedrawWindow(Form.Handle, nil, 0, RDW_NOFRAME or RDW_NOERASE or RDW_INVALIDATE or RDW_UPDATENOW);
              end;
              if UpdateClient and not InAero then InvalidateRect(Form.Handle, nil, False);
              LastClientRect := Rect(0, 0, Form.ClientWidth, Form.ClientHeight);
              Exit;
            end
            else if (Form.FormStyle = fsMDIForm) and IsCached(SkinData) then begin
              SendMessage(Form.Handle, WM_NCPAINT, 0, 0);
            end
            else begin
              case Message.WParam of
                SIZE_MAXIMIZED : if (Form.FormStyle = fsMDIChild) and (Form.WindowState = wsMaximized) then begin // Repaint MDI child buttons
                  TsSkinProvider(MDISkinProvider).FCommonData.BGChanged := True;
                  TsSkinProvider(MDISkinProvider).MenuChanged := True;
                  RedrawWindow(Form.Handle, nil, 0, RDW_FRAME or RDW_INVALIDATE or RDW_ALLCHILDREN);
                end;
              end;
            end;
          end
          else FCommonData.BGChanged := True;
        end;
        LastClientRect := Rect(0, 0, Form.ClientWidth, Form.ClientHeight);
      end
      else begin
        FCommonData.BGChanged := True;
        OldWndProc(Message);
      end;
      WM_MOVE : begin
        KillAnimations;
        OldWndProc(Message);
      end;
      WM_ENTERMENULOOP : begin
        if (Form.FormStyle = fsMDIForm) and not InMenu and (Form.ActiveMDIChild <> nil) and (Form.ActiveMDIChild.WindowState = wsMaximized) then begin
          InMenu := True;
          if MDIIconsForm = nil then MDIIconsForm := TForm.Create(Application);
          MDIIconsForm.Tag := ExceptTag;
          MDIIconsForm.Visible := False;
          MDIIconsForm.Name := 'acMDIIcons';
          MDIIconsForm.OnPaint := MdiIcoFormPaint;

          MDIIconsForm.BorderStyle := bsNone;
          SetWindowPos(MDIIconsForm.Handle, 0, Form.BoundsRect.Right - 60 - SysBorderWidth(Form.Handle, BorderForm, False),
            Form.Top + SysCaptHeight(Form) + SysBorderWidth(Form.Handle, BorderForm, False), 60,
            GetSystemMetrics(SM_CYMENU) - 1 + 4, SWP_NOACTIVATE or SWP_SHOWWINDOW or SWP_NOREDRAW);
        end;
        OldWndProc(Message);
      end;
      WM_EXITMENULOOP : begin
        InMenu := False;
        if Assigned(MDIIconsForm) then FreeAndNil(MDIIconsForm);
        OldWndProc(Message);
      end;
//      WM_DRAWITEM : if not FDrawNonClientArea then OldWndProc(Message) else AC_WMDrawItem(TWMDrawItem(Message));
      WM_NCHITTEST : begin
        if RTInit then begin
          RTInit := False;
          LoadInit;
        end;
        if (CaptionHeight = 0) or not FDrawNonClientArea then OldWndProc(Message) else begin
          Message.Result := HTProcess(TWMNCHitTest(Message));
          case Message.Result of
            Windows.HTCAPTION, Windows.HTNOWHERE, HTMENU, HTCLIENT : begin
              OldWndProc(Message);
              SetHotHT(0);
              Exit;
            end;
          end;
          if (ResizeMode = rmBorder) and (nDirection = 0) and Form.Enabled and (Message.Result in [HTCAPTION, HTLEFT..HTBOTTOMRIGHT])
            then nDirection := Message.Result;
        end;
      end;
      WM_SIZING : begin
        OldWndProc(Message);
        if BorderForm <> nil then BorderForm.UpdateExBordersPos(False);
      end;
      WM_MOUSELEAVE, CM_MOUSELEAVE : begin
        SetHotHT(0);
        if SkinData.SkinManager.ActiveControl <> 0 then SkinData.SkinManager.ActiveControl := 0;
        OldWndProc(Message);
      end;
      CM_MOUSEENTER : begin
        OldWndProc(Message);
        for i := 0 to Form.ControlCount - 1 do
          if (Form.Controls[i] is TsSpeedButton) and (Form.Controls[i] <> Pointer(Message.LParam)) and TsSpeedButton(Form.Controls[i]).SkinData.FMouseAbove
            then Form.Controls[i].Perform(CM_MOUSELEAVE, 0, 0)
      end;
      WM_NCCREATE : begin
        OldWndProc(Message);
        if Form.FormStyle <> fsMDIChild { Solving the problem with menu } then PrepareForm;
      end;
      WM_NCLBUTTONDOWN : begin
        if FDrawNonClientArea then begin
          if (BorderForm <> nil) and (TWMNCLButtonDown(Message).HitTest = HTOBJECT) then begin
            OldWndProc(Message);
            Exit;
          end;
          if (BorderForm <> nil) and (TWMNCLButtonDown(Message).HitTest = HTTRANSPARENT) then TWMNCLButtonDown(Message).HitTest := BorderForm.Ex_WMNCHitTest(TWMNCHitTest(Message));
          case TWMNCLButtonDown(Message).HitTest of
            HTCLOSE, HTMAXBUTTON, HTMINBUTTON, HTHELP, HTCHILDCLOSE..HTCHILDMIN : begin
              if Assigned(ChildProvider) then begin
                if ((TWMNCLButtonDown(Message).HitTest = HTCHILDMIN) and not ChildProvider.SystemMenu.EnabledMin) or
                     ((TWMNCLButtonDown(Message).HitTest = HTCHILDMAX) and not ChildProvider.SystemMenu.EnabledRestore) then Exit;
              end;
              SetPressedHT(TWMNCLButtonDown(Message).HitTest);
            end;
            HTMENU : begin
              OldWndProc(Message);
            end;
            HTSYSMENU : begin
              Message.Result := 0;
              OldWndProc(Message);
              if Message.Result <> 0 then Exit;
              SetHotHT(0);
              if not SkinData.SkinManager.SkinnedPopups then begin // Check and Exit when DblClick and not SkinnedPopups
                Delay(200);
                if SkinData.FUpdating then Exit;
              end;
              if Form.FormStyle = fsMDIChild then begin
                if Assigned(MDISkinProvider) then begin
                  p := FormLeftTop;
                  DropSysMenu(p.x, p.y + SysCaptHeight(Form) + 4 - integer(IsIconic(Form.Handle)) * 16)
                end;
              end
              else DropSysMenu(FormLeftTop.x + SysBorderWidth(Form.Handle, BorderForm, False), FormLeftTop.y + BorderHeight + HeightOf(IconRect) + SysBorderHeight(Form.Handle, BorderForm, False));
            end
            else if BetWeen(TWMNCLButtonDown(Message).HitTest, HTUDBTN, HTUDBTN + TitleButtons.Count - 1) then begin
              SetPressedHT(TWMNCLButtonDown(Message).HitTest);
              TitleButtons.Items[TWMNCHitMessage(Message).HitTest - HTUDBTN].MouseDown(TWMNCHitMessage(Message).HitTest - HTUDBTN, mbLeft, [], TWMNCHitMessage(Message).XCursor, TWMNCHitMessage(Message).YCursor);
            end
            else begin
              if IsIconic(Form.Handle) then Form.Perform(WM_SYSCOMMAND, SC_DRAGMOVE, 0) else begin
                SetHotHT(0);
                if (Form.WindowState <> wsMaximized) or (CursorToPoint(0, TWMNCLButtonDown(Message).YCursor).y > SysBorderHeight(Form.Handle, BorderForm) + CaptionHeight) then begin
                  SystemParametersInfo(SPI_GETDRAGFULLWINDOWS, 0, @lInted, 0);
                  if lInted then begin
                    if (ResizeMode = rmBorder) and Form.Enabled and not (TWMNCLButtonDown(Message).HitTest in [HTMENU]) then begin // MarkB
                      // If caption pressed then activate form (standard procedure)
                      if (TWMNCLButtonDown(Message).HitTest in [HTMENU, HTCAPTION]) then OldWndProc(Message);
                      bMode := not (TWMNCLButtonDown(Message).HitTest in [HTRIGHT, HTLEFT, HTBOTTOM, HTTOP, HTTOPLEFT, HTTOPRIGHT, HTBOTTOMLEFT, HTBOTTOMRIGHT]);
                      p := Point(TWMNCLButtonDown(Message).XCursor, TWMNCLButtonDown(Message).YCursor);
                      if bMode then SendMessage(Form.Handle, WM_SYSCOMMAND, SC_MOVE, 0) else SendMessage(Form.Handle, WM_SYSCOMMAND, SC_SIZE, 0);
                      StartMove(p.X, p.Y);
                    end
                    else begin
{$IFNDEF NOWNDANIMATION}
                      if (TWMNCLButtonDown(Message).HitTest = HTCAPTION) and (Form.FormStyle <> fsMDIChild) and SkinData.SkinManager.AnimEffects.BlendOnMoving.Active and
                          not IsIconic(Form.Handle) and not ((SkinData.SkinManager.AnimEffects.BlendOnMoving.BlendValue = MaxByte) or not AllowBlendOnMoving{ AlphaMoving is not required then begin}) then begin
                        if not FormActive then begin // If form activating
                          FormActive := True;
                          SkinData.BGChanged := True;
                          UpdateSkinCaption(Self);
                        end;
                        SetFocus(Form.Handle);
                        StartBlendOnMoving(Self);
                        Exit;
                      end;
{$ENDIF}
                      OldWndProc(Message);
                    end
                  end
                  else OldWndProc(Message);
                end
                else begin
                  if not Form.Active then Form.SetFocus; // Focusing if maximized
                end;
              end;
            end
          end
        end
        else begin
          // Skinned sysmenu
          case TWMNCLButtonDown(Message).HitTest of
            HTSYSMENU : begin
              SetHotHT(0);
              if Form.FormStyle = fsMDIChild then begin
                if Assigned(MDISkinProvider) then begin
                  p := FormLeftTop;
                  DropSysMenu(p.x, p.y + CaptionHeight + 4);
                end;
              end
              else DropSysMenu(FormLeftTop.x + SysBorderWidth(Form.Handle, BorderForm), FormLeftTop.y + BorderHeight + HeightOf(IconRect) + SysBorderHeight(Form.Handle, BorderForm, False));
            end
            else OldWndProc(Message);
          end
        end;
      end;
{      CM_ACTIVATE : begin
        OldWndProc(Message);
        if (BorderForm <> nil) then BorderForm.UpdateExBordersPos(False); // Patch for ReportBuilder dialogs and similar windows
      end;}
      WM_SETTINGCHANGE : begin
        FCommonData.BGChanged := True;
        if Message.WParam = SPI_SETWORKAREA then begin
{
          FormState := FormState and not FS_ANIMMINIMIZING;

          if BorderForm <> nil then begin
            BorderForm.ExBorderShowing := False;
//            SetWindowPos(sp.BorderForm.AForm.Handle, GetTopWindow, 0, 0, 0, 0, SWP_NOSENDCHANGING or SWP_NOOWNERZORDER or SWP_NOSIZE or SWP_NOMOVE or SWP_NOREDRAW);// or SWP_SHOWWINDOW);
            FormActive := True;
            SkinData.BGChanged := True;
            BorderForm.UpdateExBordersPos(True);
//            SetWindowRgn(BorderForm.AForm.Handle, 0, False);
          end;        }
          if Assigned(FormTimer) and (FormTimer is TacMinTimer) then begin
            SkinData.BGChanged := True;
            with TacMinTimer(FormTimer) do begin
              UpdateDstRect;
              CurLeft := RectTo.Left;
              CurTop := RectTo.Top;
              CurRight := RectTo.Right;
              CurBottom := RectTo.Bottom;
            end;
//            FreeAndNil(FormTimer);
          end;
        end;
        OldWndProc(Message);
      end;
      WM_MOUSEMOVE : begin // MarkB
        OldWndProc(Message);
        if (DefaultManager <> nil) and not (csDesigning in DefaultManager.ComponentState) then DefaultManager.ActiveControl := 0;
        if (ResizeMode = rmBorder) and Form.Enabled then begin
          p := Form.ClientToScreen(Point(TWMMouseMove(Message).XPos, TWMMouseMove(Message).YPos));
          X := p.X;
          Y := p.Y;
          if bMode then begin //Move section
            if bCapture then bCapture := False;
            if bInProcess then begin
              DrawFormBorder(nleft, ntop);
              nleft := nleft + (X - nX);
              ntop := ntop + (Y - nY);
              nY := Y;
              nX := X;
              DrawFormBorder(nleft, ntop);
            end;
          end
          else begin
            //Size section
            if bCapture then begin
              nX := X;
              nY := Y;
              bCapture := False;
            end;
            if bInProcess then begin
              DrawFormBorder(0, 0);
              case nDirection of
                HTLEFT : begin
                  nleft := Form.left + X - nX;
                  if nright - nleft < nMinWidth then nleft := nright - nMinWidth;
                end;
                HTRIGHT : begin
                  nright := Form.left + Form.width + X - nX;
                  if nright - nleft < nMinWidth then nright := Form.left + nMinWidth;
                end;
                HTBOTTOM : begin
                  nbottom := Form.top + Form.height + Y - nY;
                  if nbottom - ntop < nMinHeight then nbottom := Form.top + nMinHeight;
                end;
                HTTOP : begin
                  ntop := Form.top + Y - nY;
                  if nbottom - ntop < nMinHeight then ntop := nbottom - nMinHeight;
                end;
                HTBOTTOMLEFT : begin
                  nbottom := Form.top + Form.height + Y - nY;
                  if nbottom - ntop < nMinHeight then nbottom := Form.top + nMinHeight;
                  nleft := Form.left + X - nX;
                  if nright - nleft < nMinWidth then nleft := nright - nMinWidth;
                end;
                HTTOPRIGHT : begin
                  ntop := Form.top + Y - nY;
                  if nbottom - ntop < nMinHeight then ntop := nbottom - nMinHeight;
                  nright := Form.left + Form.width + X - nX;
                  if nright - nleft < nMinWidth then nright := Form.left + nMinWidth;
                end;
                HTTOPLEFT : begin
                  ntop := Form.top + Y - nY;
                  if nbottom - ntop < nMinHeight then ntop := nbottom - nMinHeight;
                  nleft := Form.left + X - nX;
                  if nright - nleft < nMinWidth then nleft := nright - nMinWidth;
                end
                else begin
                  nbottom := Form.top + Form.height + Y - nY;
                  if nbottom - ntop < nMinHeight then nbottom := Form.top + nMinHeight;
                  nright := Form.left + Form.width + X - nX;
                  if nright - nleft < nMinWidth then nright := Form.left + nMinWidth;
                end;
              end;
              DrawFormBorder(0, 0);
            end;
          end;
        end;
      end;
      WM_NCRBUTTONDOWN : if not (TWMNCLButtonUp(Message).HitTest in [HTCAPTION, HTSYSMENU]) then OldWndProc(Message);
      WM_NCRBUTTONUP : begin
        if {FDrawNonClientArea Skinned sysmenu and} HaveBorder(Self){SkinData.SkinManager.SkinnedPopups} then begin
          if (BorderForm <> nil) and (TWMNCLButtonDown(Message).HitTest = HTTRANSPARENT)
            then TWMNCLButtonDown(Message).HitTest := BorderForm.Ex_WMNCHitTest(TWMNCHitTest(Message))
            else TWMNCLButtonDown(Message).HitTest := HTProcess(TWMNCHitTest(Message));
          case TWMNCLButtonUp(Message).HitTest of
            HTCAPTION, HTSYSMENU : begin
              SetHotHT(0);
              DropSysMenu(TWMNCLButtonUp(Message).XCursor, TWMNCLButtonUp(Message).YCursor);
            end
          end;
          Exit;
        end
        else OldWndProc(Message);
      end;
      WM_NCLBUTTONUP, WM_LBUTTONUP: if FDrawNonClientArea then begin
        if (BorderForm <> nil) and (TWMNCLButtonDown(Message).HitTest = HTTRANSPARENT)
          then TWMNCLButtonDown(Message).HitTest := BorderForm.Ex_WMNCHitTest(TWMNCHitTest(Message));

        case TWMNCHitMessage(Message).HitTest of
          HTCLOSE : if biClicked then begin
            ButtonClose.State := 0;
            SendMessage(Form.Handle, WM_SYSCOMMAND, SC_CLOSE, 0);
            if csDestroying in Form.ComponentState then Exit;
            KillAnimations;
            if (Form <> nil) and Form.Visible
              then SetHotHT(0);
//            OldWndProc(Message);
//            Exit;
          end;
          HTMAXBUTTON : if (SystemMenu.EnabledMax or (Form.WindowState = wsMaximized) and SystemMenu.EnabledRestore) then begin
            if biClicked then begin
              if Form.FormStyle = fsMDIChild then TsSkinProvider(MDISkinProvider).FCommonData.BeginUpdate;
              SetHotHT(0);
              if Form.WindowState = wsMaximized then begin
                if Form.FormStyle <> fsMDIChild then Form.WindowState := wsNormal else ChildProvider := nil;
                SendMessage(Form.Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
                Form.Repaint
              end
              else begin
                if Form.FormStyle = fsMDIChild
                  then ChildProvider := nil;
                SendMessage(Form.Handle, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
              end;
              if Form.FormStyle = fsMDIChild then TsSkinProvider(MDISkinProvider).FCommonData.EndUpdate;
              SystemMenu.UpdateItems;
            end
            else begin
              SetHotHT(0);
              OldWndProc(Message);
            end;
          end;
          HTMINBUTTON : if biClicked then begin
            if BorderForm <> nil
              then p := Point(TWMMouse(Message).XPos - BorderForm.AForm.Left, TWMMouse(Message).YPos - BorderForm.AForm.Top)
              else p := CursorToPoint(TWMMouse(Message).XPos, TWMMouse(Message).YPos);
            if PtInRect(ButtonMin.Rect, p) then begin
              SetHotHT(0);
              if (Application.MainForm = Form) then begin
                SkipAnimation := True;
{$IFDEF D2005}
//                if Application.MainFormOnTaskBar then SendMessage(Application.Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0) else
{$ENDIF}
                SendMessage(Form.Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
                SkipAnimation := False;
              end
              else if IsIconic(Form.Handle) then begin
                SendMessage(Form.Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
              end
              else SendMessage(Form.Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
              FCommonData.BGChanged := True;
              RegionChanged := True;
            end
            else OldWndProc(Message);
          end
          else begin
            SetHotHT(0);
            OldWndProc(Message);
          end;
          HTHELP : if biClicked then begin
            SendMessage(Form.Handle, WM_SYSCOMMAND, SC_CONTEXTHELP, 0);
            SetHotHT(0);
            SystemMenu.UpdateItems;
            Form.Perform(WM_NCPAINT, 0, 0);
          end else SetHotHT(0);
          // MDI child buttons
          HTCHILDCLOSE : if biClicked then begin
            SendMessage(Form.ActiveMDIChild.Handle, WM_SYSCOMMAND, SC_CLOSE, 0);
            SetHotHT(0, False);
          end;
          HTCHILDMAX : begin
            if biClicked then SendMessage(Form.ActiveMDIChild.Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
            SetHotHT(0, False);
          end;
          HTCHILDMIN : begin
            if biClicked then begin
              TsSkinProvider(MDISkinProvider).FCommonData.BeginUpdate;
              SendMessage(Form.ActiveMDIChild.Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
            end;
            SetHotHT(0);
          end
          else if BetWeen(TWMNCHitMessage(Message).HitTest, HTUDBTN, HTUDBTN + TitleButtons.Count - 1) then begin
            if biClicked then TitleButtons.Items[TWMNCHitMessage(Message).HitTest - HTUDBTN].MouseUp(TWMNCHitMessage(Message).HitTest - HTUDBTN, mbLeft, [], TWMNCHitMessage(Message).XCursor, TWMNCHitMessage(Message).YCursor);
            SetHotHT(0);
          end
          else begin
            if IsIconic(Form.Handle) then begin
              if Assigned(MDISkinProvider) then DropSysMenu(acMousePos.x + FormLeftTop.X, acMousePos.y) else OldWndProc(Message);
            end
            else begin
              if (ResizeMode = rmBorder) and Form.Enabled and (Form.WindowState <> wsMaximized) and bInProcess then begin 
                //Common section
                p := Form.ClientToScreen(Point(TWMNCLButtonDown(Message).XCursor, TWMNCLButtonDown(Message).YCursor));
                StopMove(p.x, p.y);
                ReleaseCapture;
              end
              else OldWndProc(Message);
            end;
          end
        end;
      end
      else OldWndProc(Message);
      WM_ENTERIDLE : begin
        Message.Result := 0;
        Exit;
      end;
      CM_FLOAT : begin
        OldWndProc(Message);
        if ListSW <> nil then FreeAndNil(ListSW);
        SendAMessage(Form.Handle, AC_REFRESH, Cardinal(SkinData.SkinManager));
      end;
      CM_MENUCHANGED : begin
        if not (fsCreating in Form.FormState) and Form.Visible and not InAnimation(Self) then begin
          if SkinData.CtrlSkinState and ACS_LOCKED <> ACS_LOCKED then begin
            FLinesCount := -1;
            MenuChanged := True; // Menu may be invisible after form opening ????
            FCommonData.BGChanged := True;
            OldWndProc(Message);
          end
          else begin
            SkinData.CtrlSkinState := SkinData.CtrlSkinState or ACS_MNUPDATING;
          end;
        end
        else OldWndProc(Message);
      end;
      WM_PRINT : begin
        if (csLoading in ComponentState) or (fsCreating in Form.FormState) or (csDestroying in Form.ComponentState) then Exit;
        InitDwm(Form.Handle, True);
        if ((Form.FormStyle = fsMDIChild) and (MDISkinProvider <> nil) and
                Assigned(TsSkinProvider(MDISkinProvider).Form.ActiveMDIChild) and
                  (TsSkinProvider(MDISkinProvider).Form.ActiveMDIChild.WindowState = wsMaximized)
                    and (Form <> TsSkinProvider(MDISkinProvider).Form.ActiveMDIChild)) then Exit;
        if not MenusInitialized then begin
          if UpdateMenu then MenusInitialized := True;
        end;
        DC := TWMPaint(Message).DC;
        FCommonData.FUpdating := False;
        if BorderForm <> nil then begin
          if FCommonData.BGChanged then PaintAll;
          BitBlt(DC, 0, 0, FCommonData.FCacheBmp.Width, FCommonData.FCacheBmp.Height, FCommonData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
          MoveWindowOrg(DC, OffsetX, OffsetY);
          GetClientRect(Form.Handle, cR);
          IntersectClipRect(DC, 0, 0, WidthOf(cR), HeightOf(cR));
          if (Form.FormStyle <> fsMDIForm) then PaintControls(DC, Form, True, Point(0, 0), 0, not (FormState and FS_ANIMCLOSING = FS_ANIMCLOSING));
        end
        else begin
          if FDrawNonClientArea then begin
            if not HaveBorder(Self) and IsSizeBox(Form.Handle) then begin
              if FCommonData.BGChanged then PaintAll;
              i := Form.BorderWidth + 3;
              BitBlt(DC, 0, 0, Form.Width, i, FCommonData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY); // Title and menu line update
              BitBlt(DC, 0, i, i, FCommonData.FCacheBmp.Height, FCommonData.FCacheBmp.Canvas.Handle, 0, i, SRCCOPY); // Left border update
              BitBlt(DC, i, Form.Height - i, Form.Width - i, i, FCommonData.FCacheBmp.Canvas.Handle, i, Form.Height - i, SRCCOPY); // Bottom border update
              BitBlt(DC, FCommonData.FCacheBmp.Width - i, i, i, FCommonData.FCacheBmp.Height, FCommonData.FCacheBmp.Canvas.Handle, FCommonData.FCacheBmp.Width - i, i, SRCCOPY); // Right border update
            end
            else PaintCaption(DC);
          end;
          MoveWindowOrg(DC, OffsetX, OffsetY);
          GetClientRect(Form.Handle, cR);
          IntersectClipRect(DC, 0, 0, WidthOf(cR), HeightOf(cR));

          if SkinData.CtrlSkinState and ACS_FAST <> ACS_FAST then PaintForm(DC) else begin
            SavedDC := SaveDC(DC);
            ExcludeControls(DC, Form, actGraphic, 0, 0);
            PaintForm(DC);
            RestoreDC(DC, SavedDC);
            if (Form.FormStyle <> fsMDIForm) then PaintControls(DC, Form, True, Point(0, 0), 0, not (FormState and FS_ANIMCLOSING = FS_ANIMCLOSING));
          end;
        end;

        if Form.FormStyle = fsMDIForm then SendMessage(Form.ClientHandle, WM_PRINT, longint(DC), 0);

        if Assigned(Form.OnPaint) then begin
          Form.Canvas.Handle := DC;
          Form.OnPaint(Form);
          Form.Canvas.Handle := 0;
        end;
      end;
      WM_PRINTCLIENT : ;
{      CM_INVALIDATE : begin
        if (Application.MainForm = Form) and ac_ChangeThumbPreviews and (FormState and FS_THUMBDRAWING <> FS_THUMBDRAWING) and
          (SkinData.FCacheBmp <> nil) and not SkinData.FCacheBmp.Empty and not IsIconic(Form.Handle)
            then DwmInvalidateIconicBitmaps(Application.Handle);
        Message.Result := 0;
      end;}
//      147, Std menu haven't captions if disabled
      45132, 48205 : Message.Result := 0;
      WM_NCPAINT : begin
        if (SkinData.CtrlSkinState and ACS_LOCKED = ACS_LOCKED) or (SkinData.CtrlSkinState and ACS_MNUPDATING = ACS_MNUPDATING) or (IsMenuVisible(Self) and (Form.Menu.WindowHandle = 0)) then Exit; {v6.53}
        if RTInit then begin
          RTInit := False;
          LoadInit;
        end;
        if Form.Parent <> nil then begin
          SkinData.FUpdating := SkinData.Updating;
          if SkinData.FUpdating then Exit;
        end;

        if DrawNonClientArea and not (InAnimationProcess and (Form.FormStyle = fsMDIChild){liondev}) then begin
          if IsIconic(Form.Handle) then FCommonData.BGChanged := True;
          if fAnimating or not Form.Showing or (csLoading in ComponentState) or (csDestroyingHandle in Form.ControlState) or (SystemMenu = nil{not initialized}) then Exit;

          if not Assigned(Adapter) then AdapterCreate; // Preventing of std controls BG erasing before hooking

          if SkinData.FCacheBmp = nil // Preventing of painting before ExBorders, usually when MainMenu exists
            then InitExBorders(SkinData.SkinManager.ExtendedBorders);

          AC_WMNCPaint;
          Message.Result := 0;
        end
        else OldWndProc(Message);
      end;
      WM_ERASEBKGND : if Form.Showing then begin
        if (SkinData.CtrlSkinState and ACS_LOCKED = ACS_LOCKED) or FCommonData.FUpdating then Exit;
        if not (csPaintCopy in Form.ControlState) and (Message.WParam <> Message.LParam {PerformEraseBackground, TntSpeedButtons}) then begin

          if not IsCached(FCommonData) {and (Form.Parent = nil) }or ((Form.FormStyle = fsMDIForm) and (Form.ActiveMDIChild <> nil) and (Form.ActiveMDIChild.WindowState = wsMaximized)) then begin
            if (Form.FormStyle = fsMDIChild) and (FCommonData.FCacheBmp <> nil) then begin
              GetClientRect(TsSkinProvider(MDISkinProvider).Form.Handle, cR);
              if (PtInRect(cR, Form.BoundsRect.TopLeft) and PtInRect(cR, Form.BoundsRect.BottomRight)) then begin
                FCommonData.FCacheBmp.Height := min(FCommonData.FCacheBmp.Height, CaptionHeight + SysBorderHeight(Form.Handle, BorderForm) + LinesCount * MenuHeight + 1);
                FCommonData.BGChanged := True;
              end
            end;
            AC_WMEraseBkGnd(TWMPaint(Message).DC);
            if MDICreating then begin
              MDICreating := False;
              if Form.FormStyle = fsMDIChild then begin
                ChildProvider := Self;
              end;
            end;
          end
          else begin
            if not FCommonData.FUpdating then begin
              // If have child control with Align = clClient // If client area is not visible
              if (GetClipBox(TWMPaint(Message).DC, cR) = NULLREGION) or (WidthOf(cR) = 0) or (HeightOf(cR) = 0) then begin
                SetParentUpdated(Form);
                Exit;
              end;
            end
          end;
        end
        else if (Message.WParam <> 0) then begin // From PaintTo
          if not FCommonData.BGChanged then begin
            if IsCached(FCommonData)
              then BitBlt(TWMPaint(Message).DC, 0, 0, Form.Width, Form.Height, FCommonData.FCacheBmp.Canvas.Handle, OffsetX, OffsetY, SRCCOPY)
              else FillDC(TWMPaint(Message).DC, Rect(0, 0, Form.Width, Form.Height), GetBGColor(SkinData, 0));
          end;
        end;
        Message.Result := 1;
      end
      else OldWndProc(Message);
      WM_PAINT : begin
        if (csPaintCopy in Form.ControlState) then Exit; // Implemented in WM_ERASEBKGND
        if (BorderForm <> nil) and not InAnimation(Self) and ((BorderForm.AForm = nil) or not IsWindowVisible(BorderForm.AForm.Handle)) then BorderForm.UpdateExBordersPos(False);

        if IsCached(FCommonData) {or (Form.Parent <> nil)} {!!!and not AeroIsEnabled} then begin
          if Form.Showing then begin
            OurPaintHandler(TWMPaint(Message));
            if MDICreating then begin
              MDICreating := False;
              if Form.FormStyle = fsMDIChild then SendMessage(Form.Handle, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
            end;
            if (Form.FormStyle = fsMDIForm) then begin
              if TWMPaint(Message).DC = 0 then DC := GetDC(Form.Handle);
              PaintControls(DC, Form, True, Point(0, 0));
              if TWMPaint(Message).DC = 0 then ReleaseDC(Form.Handle, DC);
            end;
            Message.Result := 0;
          end
          else (* if (BorderForm <> nil) {$IFDEF DELPHI7UP} or Form.AlphaBlend {$ENDIF} then *) OldWndProc(Message);
        end
        else begin
          if Form.Showing then begin
            if not (csDestroying in ComponentState) and SkinData.BGChanged then begin 
              InvalidateRect(Form.Handle, nil, True); // BG updating (for repainting of graphic controls)
            end;
            BeginPaint(Form.Handle, PS);
            EndPaint(Form.Handle, PS);
            Message.Result := 0;
          end
          else OldWndProc(Message);
        end;
        if (not InAnimation(Self)) and Assigned(Form.OnPaint) then Form.OnPaint(Form);
      end;
      CM_RECREATEWND : begin
        OldWndProc(TMessage(Message));
{$IFNDEF DISABLEPREVIEWMODE}
        if (acPreviewHandle <> 0) and Form.HandleAllocated then TrySayHelloToEditor(Form.Handle);
{$ENDIF}
{$IFDEF D2005}
{$IFNDEF ALITE}
        if acTaskBarChanging then Exit;
{$ENDIF}
{$ENDIF}
      end;
      WM_NCACTIVATE : if not (csDestroying in ComponentState) then begin
        FormState := FormState or FS_ACTIVATE;
        FormActive := TWMNCActivate(Message).Active;
        if not FormActive and (ShowAction = saMaximize) then begin // <<<<< Caption blinking removing
          ShowAction := saIgnore;
        end
        else if not (ShowAction = saMaximize) then begin
          FCommonData.BGChanged := True;
          FCommonData.Updating := False;
        end
        else FCommonData.Updating := BorderForm = nil;             // >>>>> Caption blinking removing

        if Form.Showing then begin
          if FormActive <> (TWMActivate(Message).Active <> WA_INACTIVE) then FCommonData.BGChanged := True;
          if AeroIsEnabled then begin
            if (BorderForm = nil) then
{$IFDEF D2007}
              if Application.MainFormOnTaskBar and (Form <> Application.MainForm) and (Application.MainForm <> nil) and (Application.MainForm.WindowState = wsMinimized) then else
{$ENDIF}
              begin
                SendMessage(Form.Handle, WM_SETREDRAW, 0, 0);
              end;
          end
          else begin
            if fAnimating or RTInit
              then SendMessage(Form.Handle, WM_SETREDRAW, 0, 0)
              else if ((BorderForm = nil) or IsMenuVisible(Self)) and not Assigned(Form.OnPaint) {Problem with specifically handled events} then MakeCaptForm(Self);
          end;
          if (BorderForm <> nil) and not fAnimating { SkinData.SkinManager.AnimEffects.FormShow.Active v6.62} and not AeroIsEnabled then begin // Forbid a borders painting by system
            UpdateRgn(Self, False);
          end;

          OldWndProc(Message);

          if AeroIsEnabled then begin
            if (BorderForm = nil) then
{$IFDEF D2007}
              if Application.MainFormOnTaskBar and (Form <> Application.MainForm) and (Application.MainForm <> nil) and (Application.MainForm.WindowState = wsMinimized) then else
{$ENDIF}
              begin
                SendMessage(Form.Handle, WM_SETREDRAW, 1, 0);
                RedrawWindow(Form.Handle, nil, 0, RDW_ALLCHILDREN or RDW_INVALIDATE or RDW_UPDATENOW);
              end;
          end
          else begin
            if fAnimating or RTInit
              then SendMessage(Form.Handle, WM_SETREDRAW, 1, 0)
              else if (BorderForm = nil) or IsMenuVisible(Self) then KillCaptForm(Self);
            if RTInit then begin
              RedrawWindow(Form.Handle, nil, 0, RDW_ALLCHILDREN or RDW_INVALIDATE or RDW_ERASE or RDW_INVALIDATE);
            end;
          end;
        end
        else OldWndProc(Message);
        if Assigned(Form) and (Form.Visible) and (Form.FormStyle = fsMDIChild) and (fsCreatedMDIChild in Form.FormState) and
                   (fsshowing in Form.FormState) and Assigned(MDISkinProvider) and Assigned(TsSkinProvider(MDISkinProvider).MDIForm) then begin

          if SystemMenu = nil then PrepareForm; // If not intitialized (occurs when Scaled = False)
          TsSkinProvider(MDISkinProvider).FCommonData.BGChanged := True;
          TsSkinProvider(MDISkinProvider).FLinesCount := -1;
          TsMDIForm(TsSkinProvider(MDISkinProvider).MDIForm).UpdateMDIIconItem;

          SendMessage(TsSkinProvider(MDISkinProvider).Form.Handle, WM_NCPAINT, 0, 0);
          SendMessage(TsSkinProvider(MDISkinProvider).Form.ClientHandle, WM_NCPAINT, 0, 0);
        end;
        if (GetWindowLong(Form.Handle, GWL_EXSTYLE) and WS_EX_LAYERED = WS_EX_LAYERED) and (FormTimer = nil)
          then SendMessage(Form.Handle, WM_NCPAINT, 0, 0);

        if (csCreating in Form.ControlState) then Exit;

        if HaveBorder(Self) then begin
          if MDIButtonsNeeded then begin
            if (TWMActivate(Message).Active <> WA_INACTIVE) or (Form.ActiveMDIChild.Active) then begin
              FormActive := (TWMActivate(Message).Active <> WA_INACTIVE) or (Form.ActiveMDIChild.Active);
              FLinesCount := -1;
            end;
          end
          else if FormActive <> (TWMActivate(Message).Active <> WA_INACTIVE) then begin
            FormActive := (TWMActivate(Message).Active <> WA_INACTIVE);
            FLinesCount := -1;
          end;
        end;

        if (FormTimer = nil) or not FormTimer.Enabled then begin
          SendMessage(Form.Handle, WM_NCPAINT, 0, 0);
          if BorderForm <> nil then BorderForm.UpdateExBordersPos;
        end;

        if not (csDesigning in SkinData.SkinManager.ComponentState) then InitMenuItems(SkinData.Skinned); // Update after skinning in run-time
        if not MenusInitialized then begin
          if UpdateMenu then MenusInitialized := True;
        end;
        if FCommonData.Skinned and (Adapter = nil) then AdapterCreate;
        FormState := FormState and not FS_ACTIVATE;
{        if IsIconic(Form.Handle) and not AeroIsEnabled then begin // Aero
//        if IsIconic(Form.Handle) then begin
          FCommonData.BGChanged := True;
          SendMessage(Form.Handle, WM_NCPAINT, 0, 0);
        end;}
//        if IsCached(FCommonData) and not FCommonData.BGChanged then SetParentUpdated(Form); // Updating of frames which are not refreshed
//        if BorderForm <> nil then BorderForm.UpdateExBordersPos(False); // Update z-order ( BDS )
      end
      else OldWndProc(Message);
      WM_ACTIVATEAPP : begin
        OldWndProc(Message);
        if (BorderForm <> nil) and (FormState and FS_ANIMMINIMIZING <> FS_ANIMMINIMIZING) then BorderForm.UpdateExBordersPos(False); // Update z-order ( BDS )
      end;
      WM_MDIACTIVATE, WM_MDIDESTROY : begin
        OldWndProc(Message);
        if (Form.FormStyle = fsMDIChild) and Assigned(MDISkinProvider) and not (csDestroying in TsSkinProvider(MDISkinProvider).ComponentState) then begin
          if (Form.WindowState <> wsMaximized)  then begin
            MenusInitialized := False;
            TsSkinProvider(MDISkinProvider).Menuchanged := True;
            TsSkinProvider(MDISkinProvider).SkinData.BGChanged := True;
            TsSkinProvider(MDISkinProvider).FLinesCount := -1;
            SendMessage(TsSkinProvider(MDISkinProvider).Form.Handle, WM_NCPAINT, 0, 0);
          end
          else begin
            TsSkinProvider(MDISkinProvider).SkinData.BGChanged := True;
            SendMessage(TsSkinProvider(MDISkinProvider).Form.Handle, WM_NCPAINT, 0, 0);
            UpdateMainForm(True);
          end;
        end;
        ChildProvider := Self;
      end;
      WM_ACTIVATE : if Form.Showing then begin
        OldWndProc(Message);
        if (ListSW = nil) and FDrawNonClientArea then RefreshFormScrolls(Self, ListSW, False);
        if not (csCreating in Form.ControlState) then begin
          FLinesCount := -1;
{          if Form.FormStyle = fsMDIChild then begin // System calling enables blinking
            for i := 0 to TsSkinProvider(MDISkinProvider).Form.MDIChildCount - 1 do begin
              if (TsSkinProvider(MDISkinProvider).Form.MDIChildren[i] <> Form) and (TsSkinProvider(MDISkinProvider).Form.MDIChildren[i].Visible)
                then SendMessage(TsSkinProvider(MDISkinProvider).Form.MDIChildren[i].Handle, WM_NCPAINT, 0, 0);
            end;
            TsSkinProvider(MDISkinProvider).FCommonData.BGChanged := True;
          end;}
          if Message.WParamLo = 1 then begin
            if not (csDesigning in SkinData.SkinManager.ComponentState) then InitMenuItems(SkinData.Skinned); // Update after skinning in run-time
            if Assigned(SystemMenu) then SystemMenu.UpdateItems;
            if (Form.BorderStyle = bsNone) then SetParentUpdated(Form);
          end;
        end;
      end
      else OldWndProc(Message);
      CM_VISIBLECHANGED : begin
        if RTInit and (Message.WParam = 1) then begin
          RTInit := False;
          LoadInit;
          InitExBorders(SkinData.SkinManager.ExtendedBorders);
        end;
        OldWndProc(Message);
//        if BorderForm <> nil then BorderForm.UpdateExBordersPos(Message.WParam = 1);
        if (Message.WParam = 0) then begin
          if Assigned(SkinData) and Assigned(SkinData.FCacheBmp) and not (csDestroying in Form.ComponentState) then begin
            SkinData.FCacheBmp.Width := 0;
            SkinData.FCacheBmp.Height := 0;
          end;
          KillAnimations;
        end
        else begin
          if Form.Parent <> nil then SetParentUpdated(Form); // Updating of controls which are not refreshed
        end;
      end;
      WM_NCLBUTTONDBLCLK : begin
        if (ResizeMode = rmBorder) and bInProcess then begin
          p := Form.ClientToScreen(Point(TWMMouse(Message).XPos, TWMMouse(Message).YPos));
          StopMove(p.x, p.y);
          ReleaseCapture;
          bInProcess := False;
        end;
        DoStartMove := False;
        case TWMNCHitMessage(Message).HitTest of
          HTSYSMENU : begin
            if not SkinData.SkinManager.SkinnedPopups then // Check and Exit when DblClick and not SkinnedPopups
              SkinData.FUpdating := True;
            Form.Close;
          end;
          HTCAPTION : begin
            if SystemMenu.VisibleClose and (SystemMenu.EnabledMax or SystemMenu.EnabledRestore) or not HaveBorder(Self) and IsIconic(Form.Handle) then begin
              if (Form.WindowState = wsMaximized) or IsIconic(Form.Handle)
                then SendMessage(Form.Handle, WM_SYSCOMMAND, SC_RESTORE, 0)
                else SendMessage(Form.Handle, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
              SystemMenu.UpdateItems;
            end
            else if IsIconic(Form.Handle) then begin
              SendMessage(Form.Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
              SystemMenu.UpdateItems;
            end;
            TWMNCHitMessage(Message).HitTest := 0;
          end
          else inherited;
        end;
      end;
      WM_MEASUREITEM : begin
        if (Form.FormStyle = fsMDIForm) and (MDISkinProvider = Self) then MDISkinProvider := Self;
        if IsMenuVisible(Self) and Assigned(SkinData.SkinManager) and (PMeasureItemStruct(Message.LParam)^.CtlType = ODT_MENU) then begin
          mi := Form.Menu.FindItem(PMeasureItemStruct(Message.LParam)^.itemID, fkCommand);
          if mi <> nil then SkinData.SkinManager.SkinableMenus.InitItem(mi, True);
        end;
        OldWndProc(Message);
      end;
      WM_SYSCOMMAND : begin
        if Form.FormStyle <> fsMDIChild then case Message.WParamLo of
          SC_DRAGMOVE : Form.Repaint; // Faster switching between a forms (avoid of system delay)
{$IFNDEF NOWNDANIMATION}
          SC_MAXIMIZE : if (Form.Parent = nil) and (FormTimer <> nil) and TacMinTimer(FormTimer).Minimized then begin
            bAnim := acGetAnimation;
            acSetAnimation(False);
            StartRestoring(Self);
            OldWndProc(Message);
            acSetAnimation(bAnim);
            Exit;
          end;
          SC_RESTORE : if FormState and FS_ANIMCLOSING = FS_ANIMCLOSING then begin // If all windows were hidden
            FormState := FormState and not FS_ANIMCLOSING;
            if BorderForm <> nil then begin
              BorderForm.ExBorderShowing := False;
            end;
            bAnim := acGetAnimation;
            acSetAnimation(False);
            OldWndProc(Message);
            acSetAnimation(bAnim);
            Exit;
          end
          else if (Form <> Application.MainForm) then begin
            bAnim := acGetAnimation;
            acSetAnimation(False);
            OldWndProc(Message);
            acSetAnimation(bAnim);
            Exit;
{$IFDEF D2005}
          end
          else if {$IFDEF D2007} Application.MainFormOnTaskBar and {$ENDIF} (Form = Application.MainForm) and IsIconic(Form.Handle) and (Form.Parent = nil) then begin
            if (FormTimer <> nil) then begin
              SendMessage(Application.Handle, Message.Msg, Message.WParam, Message.LParam);
              Exit;
            end
            else if (BorderForm = nil) and AeroIsEnabled then begin
              OldWndProc(Message);
              RedrawWindow(Form.Handle, nil, 0, RDW_FRAME or RDW_INVALIDATE or RDW_ALLCHILDREN);
              InvalidateRect(Form.Handle, nil, True);
              Exit;
            end;
{$ENDIF}
          end;
{$ENDIF}
        end;

        if (ResizeMode = rmBorder) and Form.Enabled and not bInProcess then begin     // MarkB
          if ($FFF0 and Message.WParam = SC_MOVE) then begin         // Move section
            SetCapture(Form.handle);
            bCapture := True; bMode := True;
          end
          else if ($FFF0 and Message.WParam = SC_SIZE) then begin    // Size section
            SetCapture(Form.handle);
            nDirection := 0;
            bCapture := True; bMode := False;
          end;
        end;

        case Form.FormStyle of
          fsMDIChild : begin
            UpdateClient := (Form.WindowState = wsMaximized) and (Message.WParam <> SC_MAXIMIZE) and (Form.WindowState <> wsNormal);
            if UpdateClient then TsSkinProvider(MDISkinProvider).FCommonData.BeginUpdate; // Speed rising
            case $FFF0 and Message.WParam of
              SC_CLOSE : begin
                if (MDISkinProvider <> nil) and Assigned(TsSkinProvider(MDISkinProvider).MDIForm) then begin
                  if UpdateClient then UpdateMainForm;
                end; // If CloseQuery used then must be repainted before

                TsSkinProvider(MDISkinProvider).InMenu := True;
                OldWndProc(Message);
                if not (csDestroying in Form.ComponentState) and not (csDestroying in ComponentState) then SetHotHT(0, False);
                TsSkinProvider(MDISkinProvider).InMenu := False;

                if (MDISkinProvider <> nil) and Assigned(TsSkinProvider(MDISkinProvider).MDIForm) then if UpdateClient then UpdateMainForm;
                Exit;
              end;
              SC_KEYMENU : ;
              SC_RESTORE : begin
                if Form.WindowState = wsMinimized then UpdateClient := True;
                if MDICreating then Exit;
                ForbidDrawing(Self, True);
                OldWndProc(Message);
                SkinData.BGChanged := True;

                SetWindowLong(Form.Handle, GWL_STYLE, GetWindowLong(Form.Handle, GWL_STYLE) and not WS_SYSMENU);
                PermitDrawing(Self, True);
                RedrawWindow(Form.Handle, nil, 0, RDW_FRAME or RDW_ERASE or RDW_INVALIDATE or RDW_UPDATENOW);

                // Updating of childs
                for i := 0 to TsSkinProvider(MDISkinProvider).Form.MDIChildCount - 1 do if TsSkinProvider(MDISkinProvider).Form.MDIChildren[i] <> Form then begin
                  if TsSkinProvider(MDISkinProvider).Form.MDIChildren[i].WindowState = wsMaximized then TsSkinProvider(MDISkinProvider).Form.MDIChildren[i].WindowState := wsNormal;
                  RedrawWindow(TsSkinProvider(MDISkinProvider).Form.MDIChildren[i].Handle, nil, 0, RDW_FRAME or RDW_INTERNALPAINT or RDW_ERASE or RDW_UPDATENOW);
                end;
                if UpdateClient then UpdateMainForm;
                SystemMenu.UpdateItems(True);
                Exit;
              end;
              SC_MINIMIZE : begin
                OldWndProc(Message);
                if UpdateClient then UpdateMainForm;
                SystemMenu.UpdateItems(True);
//                FreeAndNil(TitleBG);
                FCommonData.BGChanged := True;
                UpdateMainForm;
                Exit;
              end;
              SC_MAXIMIZE : begin
                ChildProvider := Self;
                SetWindowLong(Form.Handle, GWL_STYLE, GetWindowLong(Form.Handle, GWL_STYLE) and not WS_VISIBLE);
                OldWndProc(Message);
                SetWindowLong(Form.Handle, GWL_STYLE, GetWindowLong(Form.Handle, GWL_STYLE) or WS_VISIBLE);
                RedrawWindow(Form.Handle, nil, 0, RDW_FRAME or RDW_INTERNALPAINT or RDW_ERASE or RDW_UPDATENOW);

                if Assigned(TsSkinProvider(MDISkinProvider).MDIForm) then UpdateMainForm;
                SystemMenu.UpdateItems(True);
                Exit;
              end
              else OldWndProc(Message);
            end;
            if MDISkinProvider <> nil then TsSkinProvider(MDISkinProvider).FCommonData.EndUpdate;
          end;
          fsMDIForm : begin
            OldWndProc(Message);
            case Message.WParam of
              SC_MAXIMIZE, SC_RESTORE, SC_MINIMIZE : begin
                TsSkinProvider(MDISkinProvider).FCommonData.BGChanged := True;
                TsSkinProvider(MDISkinProvider).FLinesCount := -1;
                SendMessage(TsSkinProvider(MDISkinProvider).Form.Handle, WM_NCPAINT, 0, 0);
                if (Message.WParam = SC_MAXIMIZE) and (BorderForm <> nil) then BorderForm.UpdateExBordersPos(True);
              end;
            end;
          end
          else begin
            OldWndProc(Message);
            case Message.WParam of
              SC_KEYMENU : if (TWMSysCommand(Message).Key = VK_SPACE) and SystemMenu.VisibleClose and HaveBorder(Self) then begin
                if IsIconic(Form.Handle)
                  then DropSysMenu(FormLeftTop.x + SysBorderWidth(Form.Handle, BorderForm), FormLeftTop.y + BorderHeight + HeightOf(IconRect) - 16)
                  else DropSysMenu(FormLeftTop.x + SysBorderWidth(Form.Handle, BorderForm), FormLeftTop.y + BorderHeight + HeightOf(IconRect));
              end;
              SC_MAXIMIZE, SC_RESTORE : begin
                if SystemMenu.VisibleMax then CurrentHT := HTMAXBUTTON;
                SetHotHT(0);
                if (Message.WParam = SC_RESTORE) then begin
                  if not HaveBorder(Self) then begin
                    FCommonData.BGChanged := True;
                    RegionChanged := True;
                    SetWindowRgn(Form.Handle, 0, True);
                  end
                  else begin
                    FCommonData.BGChanged := True;
                    RegionChanged := True;
                    RedrawWindow(Form.Handle, nil, 0, RDW_FRAME or RDW_INVALIDATE or RDW_ALLCHILDREN);
                    if BorderForm <> nil then BorderForm.UpdateExBordersPos;
                  end;
                end;
              end;
              SC_MINIMIZE : if Assigned(FCommonData.FCacheBmp) then begin
                FCommonData.FCacheBmp.Width := 0;
                FCommonData.FCacheBmp.Height := 0;
              end;
            end;
          end;
        end;
        case Message.WParamLo of
          SC_MINIMIZE : begin
            if SkinData.SkinManager.AnimEffects.Minimizing.Active then fAnimating := False; // Reset if was defined in the StartMinAnimation
            if (BorderForm <> nil) and (BorderForm.AForm <> nil) then begin
              if (FormState and FS_ANIMMINIMIZING <> FS_ANIMMINIMIZING) then begin
                BorderForm.ExBorderShowing := True;
                FreeAndNil(BorderForm.AForm);
                BorderForm.ExBorderShowing := False;
              end;
            end;
{$IFDEF D2007}
//            if Application.MainFormOnTaskBar
//              then Application.Minimize;
//              ShowWindow(Application.Handle, SW_MINIMIZE);
{$ENDIF}
          end;
{,$IFDEF D2005
          SC_RESTORE : if Application.MainFormOnTaskBar then begin
              if //( Application.FAppIconic) and
                 (Form = Application.MainForm) then
              begin
                b := Windows.IsIconic(Application.MainForm.Handle);
                OldWndProc(Message);
//                if b then
//                  Application.InternalRestore;
//                Exit;
              end;
          end;
$ENDIF}
        end;
      end;
      WM_WINDOWPOSCHANGING : begin
        if not RgnChanging and not (csLoading in Form.ComponentState) then begin
          if not IsZoomed(Form.Handle) and (TWMWindowPosChanged(Message).WindowPos.Flags and SWP_NOMOVE <> SWP_NOMOVE) and
               ((TWMWindowPosChanging(Message).WindowPos^.X <> 0) or (TWMWindowPosChanging(Message).WindowPos^.Y <> 0)) then with TWMWindowPosChanging(Message).WindowPos^ do begin

            if FScreenSnap and Form.Showing then begin
              cR := acWorkRect(Form);
              if BorderForm <> nil then i := DiffBorder(BorderForm) + BorderForm.SkinData.SkinManager.SkinData.ExShadowOffs else i := 0;
              HandleEdge(x, cR.Right, FSnapBuffer, Form.Width + i);
              HandleEdge(y, cR.Bottom, FSnapBuffer, Form.Height + i);
              HandleEdge(x, cR.Left, FSnapBuffer, - i);
              if BorderForm <> nil
                then HandleEdge(y, cR.Top, FSnapBuffer, - DiffTitle(BorderForm) - BorderForm.SkinData.SkinManager.SkinData.ExShadowOffs)
                else HandleEdge(y, cR.Top, FSnapBuffer);
            end;

            if FormState and FS_MAXBOUNDS <> 0 then begin
              cR := NormalBounds;
              if FormState and FS_MAXHEIGHT = FS_MAXHEIGHT then begin
                if Form.Top = TWMWindowPosChanging(Message).WindowPos^.Y then begin
                  TWMWindowPosChanging(Message).WindowPos^.Y := NormalBounds.Top;
                  TWMWindowPosChanging(Message).WindowPos^.cy := TWMWindowPosChanging(Message).WindowPos^.cy - (NormalBounds.Top - Form.Top);
                end
                else {if Form.Top = TWMWindowPosChanging(Message).WindowPos^.Y then} begin
                  TWMWindowPosChanging(Message).WindowPos^.cy := (NormalBounds.Top + NormalBounds.Bottom);
                end;
                FormState := FormState and not FS_MAXHEIGHT;
              end;
              if FormState and FS_MAXWIDTH = FS_MAXWIDTH then begin
                FormState := FormState and not FS_MAXWIDTH;
//                cR :=
              end;
//              TWMWindowPosChanged(Message).WindowPos.Flags := TWMWindowPosChanged(Message).WindowPos.Flags or SWP_NOSIZE;
              Message.Result := 0;
              Exit;
            end;
          end;


{$IFNDEF NOWNDANIMATION}
          if Assigned(SkinData.SkinManager) and acLayered and DrawNonClientArea then begin
            if not SkipAnimation then begin
              if (TWMWindowPosChanged(Message).WindowPos.Flags and SWP_HIDEWINDOW = SWP_HIDEWINDOW) and (SkinData.FCacheBmp <> nil {it's possible under Aero})  then begin // Window will be hidden
                if not IsIconic(Form.Handle) then begin
                  if SkinData.SkinManager.ShowState <> saMinimize then begin // Closing
                    if (SkinData.SkinManager.AnimEffects.FormHide.Active) and (SkinData.SkinManager.AnimEffects.FormHide.Time > 0) and (FormState and FS_ANIMCLOSING <> FS_ANIMCLOSING) then begin
                      FormState := FormState or FS_ANIMCLOSING;
                      PaintFormTo(SkinData.FCacheBmp, Self);
                      if BorderForm <> nil then begin
                        BorderForm.ExBorderShowing := True;
{$IFDEF DELPHI7UP}
                        if Form.AlphaBlend then i := Form.AlphaBlendValue else
{$ENDIF}
                        i := MaxByte;

                        SetWindowRgn(BorderForm.AForm.Handle, BorderForm.MakeRgn, False);
                        SetFormBlendValue(BorderForm.AForm.Handle, SkinData.FCacheBmp, i);
                        SetWindowPos(BorderForm.AForm.Handle, 0, BorderForm.AForm.Left, BorderForm.AForm.Top, 0, 0, SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE or SWP_NOREDRAW or SWP_SHOWWINDOW or SWP_NOSENDCHANGING or SWP_NOOWNERZORDER);
//                        BorderForm.ExBorderShowing := False;
                      end
                      else begin
                        CoverForm := MakeCoverForm(Form.Handle);
                      end;
                    end;
                  end;
                end;
              end
              else if (BorderForm <> nil) and (BorderForm.AForm <> nil) and (TWMWindowPosChanging(Message).WindowPos^.cx <> 0) and (TWMWindowPosChanging(Message).WindowPos^.cy <> 0) and
                           (TWMWindowPosChanged(Message).WindowPos.Flags and SWP_NOACTIVATE = SWP_NOACTIVATE) and
                           (TWMWindowPosChanged(Message).WindowPos.Flags and SWP_NOMOVE <> SWP_NOMOVE) and
                           (TWMWindowPosChanged(Message).WindowPos.Flags and SWP_NOSIZE <> SWP_NOSIZE) then begin
                if ((TWMWindowPosChanging(Message).WindowPos^.cx < LastClientRect.Right) or (TWMWindowPosChanging(Message).WindowPos^.cy < LastClientRect.Bottom)) and ((ListSW = nil) or (not ListSW.sBarVert.fScrollVisible and not ListSW.sBarHorz.fScrollVisible)) and BorderForm.AForm.HandleAllocated then begin
                  FormState := FormState or FS_SIZING;
                  SetWindowRgn(BorderForm.AForm.Handle, BorderForm.MakeRgn(TWMWindowPosChanging(Message).WindowPos^.cx, TWMWindowPosChanging(Message).WindowPos^.cy), False);
                  SetWindowPos(Form.Handle, BorderForm.AForm.Handle, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE or SWP_NOREDRAW or SWP_NOSENDCHANGING or SWP_NOOWNERZORDER);
                  FormState := FormState and not FS_SIZING;
                end;
              end;
            end;
          end;
{$ENDIF}
        end;
        OldWndProc(Message);
      end;
      WM_QUERYENDSESSION : begin
        FadingForbidden := True;
        while acAnimCount > 0 do Application.ProcessMessages;
        OldWndProc(Message);
      end;
      WM_WINDOWPOSCHANGED : if Assigned(SkinData.SkinManager) and acLayered and DrawNonClientArea then begin
        if (BorderForm <> nil) and IsZoomed(Form.Handle) then begin
          if SkinData.SkinManager.SkinData.ExMaxHeight <> 0 then begin
            i := SkinData.SkinManager.SkinData.ExMaxHeight;
          end
          else i := SkinData.SkinManager.SkinData.ExTitleHeight;
          FSysExHeight := i < SysCaptHeight(Form) + 4;
        end
        else FSysExHeight := False;
{$IFNDEF NOWNDANIMATION}
        if (TWMWindowPosChanged(Message).WindowPos.Flags and SWP_HIDEWINDOW = SWP_HIDEWINDOW) then begin
          if not SkipAnimation{ and (Form = Application.MainForm)} and (SkinData.FCacheBmp <> nil {it's possible under Aero}) then begin // Window will be hidden
            if not IsIconic(Form.Handle) then begin
              if (SkinData.SkinManager.ShowState = saMinimize) and (Form = Application.MainForm) then begin
                if SkinData.SkinManager.AnimEffects.Minimizing.Active and (Application.MainForm = Form) then begin
                  OldWndProc(Message);
                  fAnimating := False;
                  Exit;
                end;
              end
              else if (SkinData.SkinManager.ShowState <> saMinimize) then begin // Closing
                if (SkinData.SkinManager.AnimEffects.FormHide.Active) {and (SkinData.SkinManager.AnimEffects.FormHide.Time > 0) }then begin
                  if AeroIsEnabled then DoLayered(Form.Handle, True);
                  OldWndProc(Message);
                  SkipAnimation := True;
                  AnimHideForm(Self);
                  if not Application.Terminated then begin
                    if AeroIsEnabled then DoLayered(Form.Handle, False);
                    SkipAnimation := False;
                  end;
                  Exit;
                end;
              end
              else begin // Minimize not main form
                if BorderForm <> nil then if BorderForm.AForm <> nil then FreeAndNil(BorderForm.AForm);
              end;
            end;
          end;
        end;
{$ENDIF}
        OldWndProc(Message);
        if (BorderForm <> nil) and Form.Visible and not IsIconic(Form.Handle) then begin
          if (TWMWindowPosChanged(Message).WindowPos^.Flags and SWP_NOREDRAW <> SWP_NOREDRAW) and (TWMWindowPosChanged(Message).WindowPos^.Flags and SWP_DRAWFRAME <> SWP_DRAWFRAME) and (FormState and FS_BLENDMOVING <> FS_BLENDMOVING) then begin
            if (TWMWindowPosChanged(Message).WindowPos^.Flags and 3 = 3) and (BorderForm.AForm <> nil) then begin
              if AeroIsEnabled and (Application.MainForm = Form) and (GetActiveWindow = Form.Handle)
                then SetWindowPos(BorderForm.AForm.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE or SWP_NOREDRAW or SWP_SHOWWINDOW or SWP_NOSENDCHANGING or SWP_NOOWNERZORDER)
                else SetWindowPos(BorderForm.AForm.Handle, Form.Handle, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE or SWP_NOREDRAW or SWP_SHOWWINDOW or SWP_NOSENDCHANGING or SWP_NOOWNERZORDER);
            end
            else BorderForm.UpdateExBordersPos(False); // Update z-order ( BDS )
//              then BorderForm.UpdateExBordersPos(False); // Update z-order ( BDS )
          end;
        end;
      end
      else OldWndProc(Message);
      WM_CLOSE : begin
        if (SkinData.SkinManager.AnimEffects.FormHide.Active) and (SkinData.SkinManager.AnimEffects.FormHide.Time > 0) and DrawNonClientArea and
             (FormState and FS_ANIMCLOSING <> FS_ANIMCLOSING) then begin
          FormState := FormState or FS_ANIMCLOSING;
          PaintFormTo(SkinData.FCacheBmp, Self);
          FormState := FormState and not FS_ANIMCLOSING;
        end;
        OldWndProc(Message);
        if csDestroying in Form.ComponentState then Exit;
        if (SkinData.SkinManager.AnimEffects.FormHide.Active) and (SkinData.SkinManager.AnimEffects.FormHide.Time > 0) and DrawNonClientArea and
             (FormState and FS_ANIMCLOSING <> FS_ANIMCLOSING) then begin
          SkinData.BGChanged := False;
          FormState := FormState or FS_ANIMCLOSING;
          if BorderForm <> nil then BorderForm.ExBorderShowing := True;
          if BorderForm <> nil then begin
{$IFDEF DELPHI7UP}
            if Form.AlphaBlend then i := Form.AlphaBlendValue else
{$ENDIF}
            i := MaxByte;

            SetWindowRgn(BorderForm.AForm.Handle, BorderForm.MakeRgn, False);
            SetFormBlendValue(BorderForm.AForm.Handle, SkinData.FCacheBmp, i);
            SetWindowPos(BorderForm.AForm.Handle, 0, BorderForm.AForm.Left, BorderForm.AForm.Top, 0, 0, SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE or SWP_NOREDRAW or SWP_SHOWWINDOW or SWP_NOSENDCHANGING or SWP_NOOWNERZORDER);
          end;
        end;
        FormState := FormState and not FS_ANIMCLOSING;
      end;
      WM_CREATE : begin
        if (Form.FormStyle = fsMDIChild) then begin
          if (MDISkinProvider = nil) then AddSupportedForm(Application.MainForm.Handle);
          if ((TsSkinProvider(MDISkinProvider).Form.ActiveMDIChild) <> nil) and (TsSkinProvider(MDISkinProvider).Form.ActiveMDIChild.WindowState = wsMaximized)
            then MDICreating := True
            else MDICreating := False;
        end;
        OldWndProc(Message);
        if (Form.FormStyle <> fsMDIChild) then PrepareForm; // Problem with MDI menu solving
      end;
      WM_PARENTNOTIFY : if not (csLoading in ComponentState) and not (csLoading in Form.ComponentState) and ((Message.WParam and $FFFF = WM_CREATE) or (Message.WParam and $FFFF = WM_DESTROY)) then begin
        OldWndProc(Message);
        if Assigned(Adapter) and (Message.WParamLo = WM_CREATE) then TacCtrlAdapter(Adapter).AddAllItems;
        acM := MakeMessage(SM_ALPHACMD, MakeWParam(0, AC_GETSKINSTATE), 1, 0);
        AlphaBroadCast(Form, acM);
        if FDrawNonClientArea
          then UpdateScrolls(ListSW, True);
      end
      else OldWndProc(Message);
      WM_NOTIFY : begin
        OldWndProc(Message);
        case TWMNotify(Message).NMHdr^.code of
          TCN_SELCHANGE : if Adapter <> nil then TacCtrlAdapter(Adapter).AddAllItems;
        end;
      end;
      CM_CONTROLLISTCHANGE : begin
        if (TCMControlListChange(Message).Control <> nil) then begin
          OldWndProc(Message);
          if (TCMControlListChange(Message).Control is TWinControl) then begin
            if Adapter <> nil then TacCtrlAdapter(Adapter).AddNewItem(TWinControl(TCMControlListChange(Message).Control));
            acM := MakeMessage(SM_ALPHACMD, MakeWParam(0, AC_GETSKINSTATE), 1, 0);
            AlphaBroadCast(TWinControl(TCMControlListChange(Message).Control), acM);
          end;
          TCMControlListChange(Message).Control.Perform(SM_ALPHACMD, MakeWParam(0, AC_GETSKINSTATE), 1);
        end
        else OldWndProc(Message);
      end
      else OldWndProc(Message);
    end;
  end;
end;

function MaxBtnOffset(sp : TsSkinProvider) : integer;
var
  yOffs, i1, i2 : integer;
begin
  Result := 0;
  with sp do begin
    i1 := CaptionHeight(True);
    i2 := SysCaptHeight(sp.Form);
    if (i1 > i2 + 4) // If skinned caption height is bigger than unskinned
      then yOffs := i1 - i2 - 4{sbwf} // Get difference between captions
      else yOffs := 0;
    if (SkinData.SkinManager.SkinData.ExDrawMode = 1) then begin // If borders are replaced
      // If max and normal captions sizes are not equal
      if (FCommonData.SkinManager.SkinData.ExTitleHeight <> FCommonData.SkinManager.SkinData.ExMaxHeight)
        // Get vertical offset
        then Result := max(0, (FCommonData.SkinManager.SkinData.ExTitleHeight - FCommonData.SkinManager.SkinData.ExMaxHeight));// + FCommonData.SkinManager.SkinData.ExCenterOffs))
      inc(Result, SkinData.SkinManager.SkinData.BITopMargin);// - sbwf);
    end;
    dec(Result, yOffs);
  end;
end;

procedure TsSkinProvider.PaintBorderIcons;
var
  i, b, index, mi, Offset, x, y, addY : integer;
  CI : TCacheInfo;
  TitleButton : TsTitleButton;
  procedure PaintButton(var Btn : TsCaptionButton; var Index : integer; SkinIndex : integer; BtnEnabled : boolean; UserBtn : TsTitleButton = nil);
  var
    w : integer;
  begin
    if UserBtn = nil then w := SysButtonWidth(Btn) else w := UserButtonWidth(UserBtn);
    Btn.Rect.Left := Btn.Rect.Right - w;
    if Btn.HaveAlignment { If not user button and not small } and (FCommonData.SkinManager.SkinData.BIVAlign = 1) { Top aligning } then begin
      if (BorderForm <> nil) then begin
        if IsZoomed(Form.Handle) then begin
          if AeroIsEnabled then begin
            if FSysExHeight
              then addY := ShadowSize.Top + DiffTitle(BorderForm) + 4 // SysBorderWidth(oWnd, Self, False) // 4 { For MinMax patching }
              else addY := BorderForm.OffsetY;
            Btn.Rect.Top := addY + MaxBtnOffset(Self) + SysBorderWidth(Form.Handle, BorderForm, False);// - 1;
          end
          else begin
            if FSysExHeight
              then addY := ShadowSize.Top + DiffTitle(BorderForm) + 4 // SysBorderWidth(oWnd, Self, False) // 4 { For MinMax patching }
              else addY := BorderForm.OffsetY;
            Btn.Rect.Top := addY + MaxBtnOffset(Self) + SysBorderWidth(Form.Handle, BorderForm, False) - 1;
          end;
        end
        else Btn.Rect.Top := ShadowSize.Top + FCommonData.SkinManager.SkinData.BITopMargin;
      end
      else begin
        if IsZoomed(Form.Handle) then Btn.Rect.Top := 3 else Btn.Rect.Top := 0;
      end;
      Btn.Rect.Bottom := Btn.Rect.Top + ButtonHeight;
    end
    else begin // va_center
      Btn.Rect.Top := (CaptionHeight - ButtonHeight + SysBorderHeight(Form.Handle, BorderForm)) div 2 + ShadowSize.Top;
      if (BorderForm <> nil) {and (SkinData.SkinManager.SkinData.ExDrawMode = 1) }then inc(Btn.Rect.Top, FCommonData.SkinManager.SkinData.ExCenterOffs);
      if IsZoomed(Form.Handle) then begin
        dec(Btn.Rect.Top, 2{4 div 2} - integer(BorderForm = nil) * 2);
        if (BorderForm <> nil) and (FCommonData.SkinManager.SkinData.ExTitleHeight <> FCommonData.SkinManager.SkinData.ExMaxHeight) then begin
          Btn.Rect.Top := Btn.Rect.Top + (FCommonData.SkinManager.SkinData.ExTitleHeight - FCommonData.SkinManager.SkinData.ExMaxHeight - FCommonData.SkinManager.SkinData.ExCenterOffs) div 2 - 2;
        end;
      end;
      if (BorderForm <> nil) and (Form.WindowState = wsMaximized) then inc(Btn.Rect.Top, SysBorderWidth(Form.Handle, BorderForm, False) div 2);
      if BigButtons(Self) and (ButtonHeight < 16) then inc(Btn.Rect.Top, 2);
      Btn.Rect.Bottom := Btn.Rect.Top + ButtonHeight;
    end;
    if SkinIndex > -1 then DrawSkinGlyph(FCommonData.FCacheBmp, Point(Btn.Rect.Left, Btn.Rect.Top),
      Btn.State * integer(Btn.Timer = nil), 1 + integer(not FormActive or not BtnEnabled) * integer((Btn.State = 0) or (Btn.Timer <> nil)), FCommonData.SkinManager.ma[SkinIndex], MakeCacheInfo(SkinData.FCacheBmp));
    inc(Index);
  end;
begin
  if not HaveBorder(Self) then Exit;
  b := 1;
  Offset := CaptionWidth - FCommonData.SkinManager.SkinData.BIRightMargin - ShadowSize.Right;
  dec(Offset, SysBorderWidth(Form.Handle, BorderForm));
  RestoreBtnsBG;
//  addY := MaxBtnOffset(Self);
  if Assigned(SystemMenu) and SystemMenu.VisibleClose then begin // Accommodation of buttons in a special order...
    if FCommonData.SkinManager.IsValidImgIndex(ButtonClose.ImageIndex) then begin
      ButtonClose.Rect.Right := Offset;
      PaintButton(ButtonClose, b, ButtonClose.ImageIndex, True);
      Offset := ButtonClose.Rect.Left - integer(BigButtons(Self)) * FCommonData.SkinManager.SkinData.BISpacing;
    end;
    if SystemMenu.VisibleMax then begin

      if Form.WindowState <> wsMaximized then begin
        ButtonMax.ImageIndex := SkinData.SkinManager.GetMaskIndex(SkinData.SkinManager.ConstData.IndexGLobalInfo, s_GlobalInfo, s_BorderIconMaximize);
        if FCommonData.SkinManager.IsValidImgIndex(ButtonMax.ImageIndex) then begin
          ButtonMax.Rect.Right := Offset;
          PaintButton(ButtonMax, b, ButtonMax.ImageIndex, SystemMenu.EnabledMax);
          Offset := ButtonMax.Rect.Left - integer(BigButtons(Self)) * FCommonData.SkinManager.SkinData.BISpacing;
        end;
      end
      else begin
        ButtonMax.ImageIndex := SkinData.SkinManager.GetMaskIndex(SkinData.SkinManager.ConstData.IndexGLobalInfo, s_GlobalInfo, s_BorderIconNormalize);
        i := ButtonMax.ImageIndex;
        if i < 0 then i := FCommonData.SkinManager.GetMaskIndex(FCommonData.SkinIndex, FCommonData.SkinSection, s_BorderIconNormalize); // For compatibility
        if i > -1 then begin
          ButtonMax.Rect.Right := Offset;
          PaintButton(ButtonMax, b, i, SystemMenu.EnabledRestore);
          Offset := ButtonMax.Rect.Left - integer(BigButtons(Self)) * FCommonData.SkinManager.SkinData.BISpacing;
        end;
      end;

    end;
    if SystemMenu.VisibleMin then begin
      if (Form.WindowState = wsMinimized) and IsIconic(Form.Handle) then begin // If form is minimized then changing to Normalize
        i := FCommonData.SkinManager.GetMaskIndex(FCommonData.SkinManager.ConstData.IndexGLobalInfo, s_GlobalInfo, s_BorderIconNormalize);
        if i < 0 then i := FCommonData.SkinManager.GetMaskIndex(FCommonData.SkinIndex, FCommonData.SkinSection, s_BorderIconNormalize);
        if FCommonData.SkinManager.IsValidImgIndex(i) then begin
          ButtonMin.Rect.Right := Offset;
          PaintButton(ButtonMin, b, i, SystemMenu.EnabledRestore); // For compatibility
          Offset := ButtonMin.Rect.Left - integer(BigButtons(Self)) * FCommonData.SkinManager.SkinData.BISpacing;
        end;
      end
      else begin
        if FCommonData.SkinManager.IsValidImgIndex(ButtonMin.ImageIndex) then begin
          ButtonMin.Rect.Right := Offset;
          PaintButton(ButtonMin, b, ButtonMin.ImageIndex, SystemMenu.EnabledMin);
          Offset := ButtonMin.Rect.Left - integer(BigButtons(Self)) * FCommonData.SkinManager.SkinData.BISpacing;
        end;
      end;
    end;
    if biHelp in Form.BorderIcons then begin
      if FCommonData.SkinManager.IsValidImgIndex(ButtonHelp.ImageIndex) then begin
        ButtonHelp.Rect.Right := Offset;
        PaintButton(ButtonHelp, b, ButtonHelp.Imageindex, True);
        Offset := ButtonHelp.Rect.Left - integer(BigButtons(Self)) * FCommonData.SkinManager.SkinData.BISpacing;
      end;
    end;
  end;

  if TitleButtons.Count > 0 then begin
    mi := UserBtnIndex;
    Offset := Offset - UserButtonsOffset;
    for index := 0 to TitleButtons.Count - 1 do begin
      TitleButton := TitleButtons.Items[index];
      if not TitleButton.Visible then Continue;
      if TitleButton.UseSkinData and FCommonData.SkinManager.IsValidImgIndex(mi) then begin
        TitleButton.BtnData.ImageIndex := mi;
        TitleButton.BtnData.Rect.Right := Offset;
        PaintButton(TitleButton.BtnData, b, mi, TitleButton.Enabled, TitleButton);
        Offset := TitleButton.BtnData.Rect.Left - integer(BigButtons(Self)) * FCommonData.SkinManager.SkinData.BISpacing;
      end
      else begin
        TitleButton.BtnData.ImageIndex := -1;
        TitleButton.BtnData.Rect.Right := Offset;
        PaintButton(TitleButton.BtnData, b, -1, TitleButton.Enabled, TitleButton);
        Offset := TitleButton.BtnData.Rect.Left - integer(BigButtons(Self)) * FCommonData.SkinManager.SkinData.BISpacing;
      end;
      TitleButton.BtnData.HitCode := HTUDBTN + index;
      if Assigned(TitleButton.Glyph) and not TitleButton.Glyph.Empty then begin
        if TitleButton.Glyph.PixelFormat = pf32bit then begin
          x := TitleButton.BtnData.Rect.Left + (UserButtonWidth(TitleButton) - TitleButton.Glyph.Width) div 2;
          y := TitleButton.BtnData.Rect.Top + (ButtonHeight - TitleButton.Glyph.Height) div 2;
          CI := MakeCacheInfo(FCommonData.FCacheBmp, x, y);
          CopyByMask(Rect(x, y, x + TitleButton.Glyph.Width, y + TitleButton.Glyph.Height),
                     Rect(0, 0, TitleButton.Glyph.Width, TitleButton.Glyph.Height),
                     FCommonData.FCacheBmp,
                     TitleButton.Glyph,
                     CI, True);
        end
        else begin
          CopyTransBitmaps(FCommonData.FCacheBmp, TitleButton.Glyph,
                 TitleButton.BtnData.Rect.Left + (UserButtonWidth(TitleButton) - TitleButton.Glyph.Width) div 2,
                 TitleButton.BtnData.Rect.Top + (ButtonHeight - TitleButton.Glyph.Height) div 2,
                 TsColor(TitleButton.Glyph.Canvas.Pixels[0, TitleButton.Glyph.Height - 1]));
        end;
      end;
    end;
  end;

  // Drawing of MDI child buttons if maximized
  if MDIButtonsNeeded then begin
    b := CaptionHeight + SysBorderHeight(Form.Handle, BorderForm) + ShadowSize.Top + (MenuHeight - SmallButtonHeight) div 2 + (GetLinesCount - 1) * MenuHeight; // Buttons top
    if FCommonData.SkinManager.IsValidImgIndex(MDIMin.ImageIndex) then begin
      MDIMin.Rect := Bounds(CaptionWidth - SysBorderWidth(Form.Handle, BorderForm) - 3 * (SmallButtonWidth + 1) - ShadowSize.Right, b, SmallButtonWidth, SmallButtonHeight);
      DrawSkinGlyph(FCommonData.FCacheBmp, Point(MDIMin.Rect.Left, MDIMin.Rect.Top),
                MDIMin.State, 1 + integer(not FormActive or not ChildProvider.SystemMenu.EnabledMin), FCommonData.SkinManager.ma[MDIMin.ImageIndex], MakeCacheInfo(SkinData.FCacheBmp));
    end;
    if Assigned(TsSkinProvider(MDISkinProvider).Form.ActiveMDIChild) and { Draw norm. button when maximized } (TsSkinProvider(MDISkinProvider).Form.ActiveMDIChild.WindowState <> wsMaximized) then begin
      i := MDIMax.ImageIndex
    end
    else begin
      i := FCommonData.SkinManager.GetMaskIndex(FCommonData.SkinManager.ConstData.IndexGlobalInfo, s_GlobalInfo, s_SmallIconNormalize);
      if i < 0 then i := FCommonData.SkinManager.GetMaskIndex(FCommonData.SkinIndex, s_GlobalInfo, s_BorderIconNormalize);
    end;
    MDIMax.Rect := Bounds(CaptionWidth - SysBorderWidth(Form.Handle, BorderForm) - 2 * (SmallButtonWidth + 1) - ShadowSize.Right, b, SmallButtonWidth, SmallButtonHeight);
    if FCommonData.SkinManager.IsValidImgIndex(i) then begin
      DrawSkinGlyph(FCommonData.FCacheBmp, Point(MDIMax.Rect.Left, MDIMax.Rect.Top),
        MDIMax.State, 1 + integer(not FormActive or not ChildProvider.SystemMenu.EnabledRestore), FCommonData.SkinManager.ma[i], MakeCacheInfo(SkinData.FCacheBmp));
    end;
    if FCommonData.SkinManager.IsValidImgIndex(MDIClose.ImageIndex) then begin
      MDIClose.Rect := Bounds(CaptionWidth - SysBorderWidth(Form.Handle, BorderForm) - SmallButtonWidth - 1 - ShadowSize.Right, b, SmallButtonWidth, SmallButtonHeight);
      DrawSkinGlyph(FCommonData.FCacheBmp, Point(MDIClose.Rect.Left, MDIClose.Rect.Top),
        MDIClose.State, 1 + integer(not FormActive), FCommonData.SkinManager.ma[MDIClose.ImageIndex], MakeCacheInfo(SkinData.FCacheBmp));
    end;
  end;
end;

procedure TsSkinProvider.PaintCaption(DC : hdc);
var
  h, hh, bh, bw, hmnu, w : integer;
begin
  h := SysBorderHeight(Form.Handle, BorderForm) + CaptionHeight;
  if IsIconic(Form.Handle) then begin
    inc(h);
  end;
  if FCommonData.BGChanged or not IsCached(FCommonData) then begin
    if MenuChanged or (FCommonData.FCacheBmp = nil) or IsBorderUnchanged(FCommonData.BorderIndex, FCommonData.SkinManager) {or (TitleBG = nil)} or (FCommonData.FCacheBmp.Width <> CaptionWidth) or (FCommonData.FCacheBmp.Height <> Form.Height) or not HaveBorder(Self) then begin// if ready caption BG
      ControlsChanged := not FirstInitialized;
    end;
    PaintAll;
    FCommonData.BGChanged := False;
    FCommonData.Updating := False;
  end;
  hmnu := integer(MenuPresent) * (LinesCount * MenuHeight + 1);
  bh := BorderHeight;
  if GetWindowLong(Form.Handle, GWL_STYLE) and WS_CAPTION = WS_CAPTION then hh := HeaderHeight else hh := bh;
  bw := BorderWidth;
  w := CaptionWidth;
(*
  if (Form.Menu <> nil) and (SystemMenu.WindowHandle = 0 {if not sysmenu opened}) and (Length(MnuArray) > 0) then begin // Do not repaint menu if dropped down
    ExcludeClipRect(DC, bw, h, w - 2 * bw, hh - 1);
  end;
*)
  BitBlt(DC, 0, 0, w, hh, FCommonData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY); // Title and menu line update
  BitBlt(DC, 0, hh, bw, FCommonData.FCacheBmp.Height - hh, FCommonData.FCacheBmp.Canvas.Handle, 0, h + hmnu + TForm(Form).BorderWidth, SRCCOPY); // Left border update
  BitBlt(DC, bw, Form.Height - bh, w - bw, bh, FCommonData.FCacheBmp.Canvas.Handle, // Bottom border update
    SysBorderwidth(Form.Handle, BorderForm) + TForm(Form).BorderWidth, Form.Height - bh, SRCCOPY);
  BitBlt(DC, FCommonData.FCacheBmp.Width - bw, hh, bh, FCommonData.FCacheBmp.Height - bh, FCommonData.FCacheBmp.Canvas.Handle, // Right border update
    FCommonData.FCacheBmp.Width - bw, h + hmnu + TForm(Form).BorderWidth, SRCCOPY);

(* !!!
  if FCommonData.BGChanged or not IsCached(FCommonData) then begin
    if MenuChanged or (FCommonData.FCacheBmp = nil) or IsBorderUnchanged(FCommonData.BorderIndex, FCommonData.SkinManager) or (FCommonData.FCacheBmp.Width <> CaptionWidth) or (FCommonData.FCacheBmp.Height <> Form.Height) or not HaveBorder(Self) then begin
      ControlsChanged := not FirstInitialized;
    end;
    PaintAll;
    FCommonData.BGChanged := False;
    FCommonData.Updating := False;
  end;
  bh := BorderHeight;
  if GetWindowLong(Form.Handle, GWL_STYLE) and WS_CAPTION = WS_CAPTION then hh := HeaderHeight else hh := bh;
  bw := BorderWidth;
  w := CaptionWidth;
  BitBlt(DC, 0, 0, w, hh, FCommonData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY); // Title and menu line update
  BitBlt(DC, 0, hh, bw, FCommonData.FCacheBmp.Height - hh, FCommonData.FCacheBmp.Canvas.Handle, 0, hh{h + hmnu + TForm(Form).BorderWidth}, SRCCOPY); // Left border update
  BitBlt(DC, bw, Form.Height - bh, w - bw, bh, FCommonData.FCacheBmp.Canvas.Handle, // Bottom border update
    SysBorderwidth(Form.Handle, BorderForm) + TForm(Form).BorderWidth, Form.Height - bh, SRCCOPY);
  BitBlt(DC, FCommonData.FCacheBmp.Width - bw, hh, bh, FCommonData.FCacheBmp.Height - bh, FCommonData.FCacheBmp.Canvas.Handle, // Right border update
    FCommonData.FCacheBmp.Width - bw, hh{h + hmnu + TForm(Form).BorderWidth}, SRCCOPY);
*)    
end;

procedure TsSkinProvider.PaintForm(DC : hdc; SendUpdated : boolean = True);
var
  Changed : boolean;
  R : TRect;
begin
  R := Form.ClientRect;
  if (SkinData.CtrlSkinState and ACS_FAST = ACS_FAST) then begin
    if (Form.FormStyle <> fsMDIForm) then FillDC(DC, R, FormColor);
  end
  else begin
    Changed := FCommonData.BGChanged;
    if not FCommonData.UrgentPainting then PaintAll;
    if (Form.FormStyle <> fsMDIForm) then begin
      CopyWinControlCache(Form, FCommonData, Rect(OffsetX, OffsetY, 0, 0), Rect(0, 0, Form.ClientWidth, Form.ClientHeight), DC, False);
      PaintControls(DC, Form, ControlsChanged or Changed, Point(0, 0));
    end;
    if SendUpdated then begin
      SetParentUpdated(Form);
      SendToAdapter(MakeMessage(SM_ALPHACMD, MakeWParam(0, AC_ENDPARENTUPDATE), 0, 0));
    end;
  end;
  ControlsChanged := False;
end;

procedure ShowHint(Btn : TsTitleButton);
var
  R, wR : TRect;
{$IFNDEF DELPHI5}
  Animate: BOOL;
{$ENDIF}    
begin
  if Btn.HintWnd <> nil then FreeAndNil(Btn.HintWnd);
  if Btn.Hint <> '' then begin
{$IFDEF TNTUNICODE}
    Btn.HintWnd := TTntHintWindow.Create(Application);
{$ELSE}
    Btn.HintWnd := THintWindow.Create(Application);
{$ENDIF}
    Btn.HintWnd.Visible := False;
    Btn.HintWnd.Color := clInfoBk;
    R := Btn.HintWnd.CalcHintRect(800, Btn.Hint, nil);
    OffsetRect(R, acMousePos.X + 8, acMousePos.Y + 16);

    wR := acWorkRect(TsTitleButtons(Btn.Collection).FOwner.Form);
    if R.Right > wR.Right then OffsetRect(R, wR.Right - R.Right, 0);
    if R.Bottom > wR.Bottom then OffsetRect(R, 0, wR.Bottom - R.Bottom);

    // < Solving of the "Owner Z-ordering" problem when BorderForm is used
    Btn.HintWnd.Caption := Btn.Hint;
    Inc(R.Bottom, 4);

    Btn.HintWnd.ParentWindow := Application.Handle;
    Btn.HintWnd.SetBounds(R.Left, R.Top, WidthOf(R, True), HeightOf(R, True));
    SetWindowPos(Btn.HintWnd.Handle, HWND_TOPMOST, R.Left, R.Top, Btn.HintWnd.Width, Btn.HintWnd.Height,
      SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOMOVE or SWP_NOOWNERZORDER);
{$IFNDEF DELPHI5}
    if (Length(Btn.Hint) < 100) and Assigned(AnimateWindowProc) then begin
      SystemParametersInfo(SPI_GETTOOLTIPANIMATION, 0, {$IFNDEF CLR}@{$ENDIF}Animate, 0);
      if Animate then begin
        SystemParametersInfo(SPI_GETTOOLTIPFADE, 0, {$IFNDEF CLR}@{$ENDIF}Animate, 0);
        if Animate then AnimateWindowProc(Btn.HintWnd.Handle, 200, AW_BLEND);
      end;
    end;
{$ENDIF}    
    ShowWindow(Btn.HintWnd.Handle, SW_SHOWNOACTIVATE);
    Btn.HintWnd.Invalidate;
    // >
  end;
end;

procedure HideHint(Btn : TsTitleButton);
begin
  if Btn.HintWnd <> nil then FreeAndNil(Btn.HintWnd);
end;

procedure TsSkinProvider.SetHotHT(i: integer; Repaint : boolean = True);
{  procedure ShowCaptionHint(Code: integer); 
  var
    Btn : PsCaptionButton;
  begin
    case Code of
      HTCLOSE : Btn := @ButtonClose;
      HTMAXBUTTON : Btn := @ButtonMax;
      HTMINBUTTON : Btn := @ButtonMin;
      HTHELP : Btn := @ButtonHelp;
      HTCHILDCLOSE : Btn := @MDIClose;
      HTCHILDMAX : Btn := @MDIMax;
      HTCHILDMIN : Btn := @MDIMin;
      else Btn := nil;
    end;
    if Btn <> nil then ...
  end;}
begin
  if not FDrawNonClientArea then Exit;
  if HotItem.Item <> nil then begin
    RepaintMenuItem(HotItem.Item, HotItem.R, []);
    HotItem.Item := nil;
  end;
  if (CurrentHT = i) or (CurrentHT = -1) and (i = 0) then Exit;
  if (CurrentHT > 0) then begin
    case CurrentHT of
      HTCLOSE : ButtonClose.State := 0;
      HTMAXBUTTON : ButtonMax.State := 0;
      HTMINBUTTON : ButtonMin.State := 0;
      HTHELP : ButtonHelp.State := 0;
      HTCHILDCLOSE : MDIClose.State := 0;
      HTCHILDMAX : MDIMax.State := 0;
      HTCHILDMIN : MDIMin.State := 0
      else if BetWeen(CurrentHT, HTUDBTN, HTUDBTN + TitleButtons.Count - 1) then begin
        TitleButtons.Items[CurrentHT - HTUDBTN].BtnData.State := 0;
        HideHint(TitleButtons.Items[CurrentHT - HTUDBTN]);
      end;
    end;
    if Repaint then RepaintButton(CurrentHT);
  end;
  CurrentHT := i;
  case CurrentHT of
    HTCLOSE : ButtonClose.State := 1;
    HTMAXBUTTON : ButtonMax.State := 1;
    HTMINBUTTON : ButtonMin.State := 1;
    HTHELP : ButtonHelp.State := 1;
    HTCHILDCLOSE : MDIClose.State := 1;
    HTCHILDMAX : MDIMax.State := 1;
    HTCHILDMIN : MDIMin.State := 1
    else if BetWeen(CurrentHT, HTUDBTN, HTUDBTN + TitleButtons.Count - 1) then begin
      TitleButtons.Items[CurrentHT - HTUDBTN].BtnData.State := 1;
      ShowHint(TitleButtons.Items[CurrentHT - HTUDBTN]);         
    end;

//    if (CurrentHT < HTUDBTN) and (BorderForm <> nil) then ShowCaptionHint(CurrentHT);
  end;
//  biClicked := False;
  if Repaint then RepaintButton(CurrentHT);
end;

procedure TsSkinProvider.SetPressedHT(i: integer);
begin
  if (CurrentHT <> i) and (CurrentHT <> 0) then begin
    case CurrentHT of
      HTCLOSE : ButtonClose.State := 0;
      HTMAXBUTTON : ButtonMax.State := 0;
      HTMINBUTTON : ButtonMin.State := 0;
      HTHELP : ButtonHelp.State := 0;
      HTCHILDCLOSE : MDIClose.State := 0;
      HTCHILDMAX : MDIMax.State := 0;
      HTCHILDMIN : MDIMin.State := 0
      else if BetWeen(CurrentHT, HTUDBTN, HTUDBTN + TitleButtons.Count - 1) then begin
        TitleButtons.Items[CurrentHT - HTUDBTN].BtnData.State := 0;
        HideHint(TitleButtons.Items[CurrentHT - HTUDBTN]);
      end;
    end;
    RepaintButton(CurrentHT);
  end;
  CurrentHT := i;
  case CurrentHT of
    HTCLOSE : ButtonClose.State := 2;
    HTMAXBUTTON : if SystemMenu.EnabledMax or ((Form.WindowState = wsMaximized) and SystemMenu.EnabledRestore) then ButtonMax.State := 2 else begin
      CurrentHT := 0;
      Exit;
    end;
    HTMINBUTTON : ButtonMin.State := 2;
    HTHELP : ButtonHelp.State := 2;
    HTCHILDCLOSE : MDIClose.State := 2;
    HTCHILDMAX : if SystemMenu.EnabledMax then MDIMax.State := 2;
    HTCHILDMIN : MDIMin.State := 2
    else if BetWeen(CurrentHT, HTUDBTN, HTUDBTN + TitleButtons.Count - 1) then begin
      TitleButtons.Items[CurrentHT - HTUDBTN].BtnData.State := 2;
      HideHint(TitleButtons.Items[CurrentHT - HTUDBTN]);
    end;
  end;
  biClicked := True;
  RepaintButton(CurrentHT);
end;

procedure TsSkinProvider.PaintAll;
var
  VisIndex, Index, i, sbw, TitleIndex, CY : integer;
  x, w, h, y, fHeight, fWidth, fCaptHeight, iDrawMode, iDrawState : integer;
  s : acString;
  r, rForm, rC, ShadowSize : TRect;
  CI : TCacheInfo;
  BG : TacBGInfo;
  CurrentItem : TMenuItem;
  ItemProcessed : integer;
  ChangedIndex : integer;
  Iconic, exBorders : boolean;
  SavedCanvas, SavedDC : hdc;
  ts, tsAdded : TSize;
  P : PRGBAArray;
  C_ : TsColor_;
  rec : real;
  acM : TMessage;
  sMan : TsSkinManager;
  function ProcessMerged(CurrentIndex : integer) : boolean;
  var
    i, j, VisJ, w : integer;
    LocalItem : TMenuItem;
  begin
    Result := False;
    if Assigned(Form.ActiveMDIChild) and Assigned(Form.ActiveMDIChild.Menu) then begin
      for i := ItemProcessed to Form.ActiveMDIChild.Menu.Items.Count - 1 do if Form.ActiveMDIChild.Menu.Items[i].Visible then begin
        LocalItem := Form.ActiveMDIChild.Menu.Items[i];
        // If MDI form and included other
        if (LocalItem.GroupIndex > ChangedIndex) and (LocalItem.GroupIndex <= CurrentIndex) then begin

          if not Assigned(LocalItem.OnMeasureItem) or not Assigned(LocalItem.OnAdvancedDrawItem) then Continue;

          Result := (LocalItem.GroupIndex >= CurrentIndex);
          ChangedIndex := LocalItem.GroupIndex;

          j := i;
          VisJ := j;
          while (j < Form.ActiveMDIChild.Menu.Items.Count) do begin
            LocalItem := Form.ActiveMDIChild.Menu.Items[j];
            if (LocalItem.GroupIndex > CurrentIndex) and (Index <= Form.Menu.Items.Count - 1) then Exit;
            GetMenuItemRect(Form.ActiveMDIChild.Handle, Form.ActiveMDIChild.Menu.Handle, VisJ, R);

            w := WidthOf(R);
            ChangedIndex := LocalItem.GroupIndex;

            if x + w > Form.Width - 2 * sbw - 2 * TForm(Form).BorderWidth then begin
              x := sbw + ShadowSize.Left;
              inc(y, MenuHeight);
            end;

            r := Rect(x, y, x + w, y + MenuHeight);
            LocalItem.OnAdvancedDrawItem(LocalItem, FCommonData.FCacheBmp.Canvas, R, []);
            x := r.Right;
            ItemProcessed := i + 1;
            inc(j);
            inc(VisIndex);
            inc(VisJ);
          end;
        end;
      end;
    end;
  end;
  procedure PaintTitle;
  begin
    if (CaptionHeight <> 0) and FDrawNonClientArea then begin // Paint title
      TitleIndex := TitleSkinIndex;

      if sMan.IsValidSkinIndex(TitleIndex) and not exBorders then begin
        if Iconic
          then PaintItem(TitleIndex, TitleSkinSection, ci, True, min(integer(FormActive), FCommonData.SkinManager.gd[TitleIndex].States - 1), Rect(rForm.Left, rForm.Top, rForm.Right, rForm.Bottom), Point(0, 0), FCommonData.FCacheBmp, sMan)
          else PaintItem(TitleIndex, TitleSkinSection, ci, True, min(integer(FormActive), FCommonData.SkinManager.gd[TitleIndex].States - 1), Rect(rForm.Left, rForm.Top, rForm.Right, fCaptHeight), Point(0, 0), FCommonData.FCacheBmp, sMan);
      end;

      DrawAppIcon(Self); // Draw app icon
      if (SysButtonsCount > 0) then begin // Paint title toolbar if defined in skin
        i := sMan.GetMaskIndex(FCommonData.SkinIndex, FCommonData.SkinSection, s_NormalTitleBar);
        if sMan.IsValidImgIndex(i)
          then DrawSkinRect(FCommonData.FCacheBmp, Rect(CaptionWidth - BarWidth(i), 0, FCommonData.FCacheBmp.Width, h - CY),
                             True, EmptyCI, sMan.ma[i], iDrawState, True);
      end;
    end;
  end;
  procedure PaintText;
  const
    iAddedIndent = 4;
  var
    cRect : TRect;
    Flags : Cardinal;
    sIndex, i : integer;
    C : TColor;
    SavedTitle : TBitmap;
    TextAlign : TAlignment;
  begin
    if (CaptionHeight <> 0) and FDrawNonClientArea then begin // Out the title text
      // Receive a caption rect
      R.Left := SysBorderWidth(Form.Handle, BorderForm) + integer(IconVisible) * WidthOf(IconRect) + 4 + sMan.SkinData.BILeftMargin + ShadowSize.Left + integer(FCaptionSkinIndex > -1) * 2;
      R.Right := FCommonData.FCacheBmp.Width - TitleBtnsWidth - 12 - ShadowSize.Right;
      R.Bottom := fCaptHeight;
      if IsZoomed(Form.Handle) then begin
        if BorderForm <> nil
          then R.Top := ShadowSize.Top + {SysBorderWidth(Form.Handle, BorderForm, False) div 2 +} 1
          else R.Top := 3; // SysBorderWidth(Form.Handle, BorderForm, False) div 2 + 1;
      end
      else R.Top := ShadowSize.Top + 2;
      // Adding a vertical offset
      if (BorderForm <> nil){ExBorders} then begin
        OffsetRect(R, 0, sMan.SkinData.ExCenterOffs);
        if (Form.WindowState = wsMaximized) and (sMan.SkinData.ExMaxHeight <> 0) and (sMan.SkinData.ExTitleHeight <> sMan.SkinData.ExMaxHeight)
          then OffsetRect(R, 0, (sMan.SkinData.ExTitleHeight - sMan.SkinData.ExMaxHeight) div 2)
      end;
      if not IsRectEmpty(R) then begin
        // Receive a size of the added text
        if (FAddedTitle.Text <> '') then begin
          FCommonData.FCacheBmp.Canvas.Font.Assign(FAddedTitle.FFont);
          acGetTextExtent(FCommonData.FCacheBmp.Canvas.Handle, FAddedTitle.Text, tsAdded);
        end
        else tsAdded.cx := 0;

        if AddedTitle.ShowMainCaption then begin
          // Receive a size of the caption text
          FCommonData.FCacheBmp.Canvas.Font.Handle := acGetTitleFont;
          FCommonData.FCacheBmp.Canvas.Font.Height := GetCaptionFontSize;
          FCommonData.FCacheBmp.Canvas.Font.Charset := Form.Font.Charset;
          s := {$IFDEF TNTUNICODE} WideString(GetWndText(Form.Handle)) {$ELSE} Form.Caption {$ENDIF};
          acGetTextExtent(FCommonData.FCacheBmp.Canvas.Handle, s, ts);
        end
        else begin
          ts := tsAdded;
          tsAdded.cx := 0;
        end;
        // Correct a rect with received height of text
        R.Top := R.Top + (HeightOf(R) - ts.cy) div 2;
        R.Bottom := R.Top + ts.cy;

        TextAlign := CaptionAlignment;
        if Form.UseRightToLeftAlignment{ (Form.BiDiMode = bdRightToLeft) and SysLocale.MiddleEast} then begin
          if TextAlign = taLeftJustify then TextAlign := taRightJustify else if TextAlign = taRightJustify then TextAlign := taLeftJustify;
        end;

        case TextAlign of
          taCenter : begin
            R.Left := max(R.Left, R.Left + (WidthOf(R) - ts.cx - tsAdded.cx - iAddedIndent) div 2);
            R.Right := min(R.Left + ts.cx, R.Right);
          end;
          taRightJustify : begin
            i := ts.cx + tsAdded.cx + iAddedIndent;
            if i < WidthOf(R) then begin
              R.Left := R.Right - i;
            end;
          end;
        end;
        Flags := DT_END_ELLIPSIS or DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX;
        if Form.UseRightToLeftReading{ (Form.BiDiMode = bdRightToLeft) and SysLocale.MiddleEast} then begin
          Flags := Flags or DT_RTLREADING;
        end
        else begin
          Flags := Flags or DT_LEFT;
        end;

        if AddedTitle.ShowMainCaption then begin
          cRect := R;
          acDrawText(FCommonData.FCacheBmp.Canvas.Handle, s, cRect, Flags or DT_CALCRECT);
          if FCaptionSkinIndex > -1 then begin // If Caption panel must be drawn
            InflateRect(cRect, 4, 2);

            SavedTitle := CreateBmp32(fWidth, fCaptHeight);
            BitBlt(SavedTitle.Canvas.Handle, 0, 0, fWidth, fCaptHeight, FCommonData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
            CI := MakeCacheInfo(SavedTitle, cRect.Left, cRect.Top);
            PaintItem(FCaptionSkinIndex, s_Caption, CI, True, min(integer(FormActive), FCommonData.SkinManager.gd[FCaptionSkinIndex].States - 1), cRect, Point(0, 0), FCommonData.FCacheBmp, sMan);
            FreeAndNil(SavedTitle);

            sIndex := FCaptionSkinIndex;
          end
          else sIndex := TitleSkinIndex;
          // Draw a text glowing
          if not x64woAero then begin
            i := iffi(FormActive, sMan.gd[sIndex].HotGlowSize, sMan.gd[sIndex].GlowSize);
            if i <> 0 then begin
              C := iffi(FormActive, sMan.gd[sIndex].HotGlowColor, sMan.gd[sIndex].GlowColor);
              if FormActive
                then acDrawGlowForText(FCommonData.FCacheBmp, PacChar(s), R, Flags, BF_RECT, i, C, FGlow1)
                else acDrawGlowForText(FCommonData.FCacheBmp, PacChar(s), R, Flags, BF_RECT, i, C, FGlow2);
            end;
          end;
          // Text output
          FCommonData.FCacheBmp.Canvas.Brush.Style := bsClear;
          if (BorderForm = nil)
            then acWriteTextEx(FCommonData.FCacheBmp.Canvas, PacChar(s), Form.Enabled, R, Flags, sIndex, FormActive, sMan)
            else WriteText32(FCommonData.FCacheBmp, PacChar(s), Form.Enabled, R, Flags, sIndex, FormActive, sMan);
          R.Left := cRect.Right;
        end
        else begin
          tsAdded := ts;
        end;
        // Additional text
        if (FAddedTitle.Text <> '') then begin
          inc(R.Left, iAddedIndent);
          R.Right := R.Left + tsAdded.cx + 4;
          if (R.Left + 8 < R.Right) then begin
            FCommonData.FCacheBmp.Canvas.Font.Assign(FAddedTitle.Font);
            if (FAddedTitle.Font.Color = clNone) or (FAddedTitle.Font.Color = clWindowText)
              then FCommonData.FCacheBmp.Canvas.Font.Color := iffi(FormActive, sMan.gd[TitleSkinIndex].HotFontColor[1], sMan.gd[TitleSkinIndex].FontColor[1])
              else if not FormActive then FCommonData.FCacheBmp.Canvas.Font.Color := MixColors(sMan.gd[TitleSkinIndex].FontColor[1], FAddedTitle.Font.Color, 0.5);
            if (BorderForm = nil) then begin
              FCommonData.FCacheBmp.Canvas.Brush.Style := bsClear;
              acDrawText(FCommonData.FCacheBmp.Canvas.Handle, PacChar(FAddedTitle.Text), R, Flags)
            end
            else WriteText32(FCommonData.FCacheBmp, PacChar(FAddedTitle.Text), True, R, Flags, -1, FormActive, sMan);
          end;
        end;
      end;
    end;
  end;
begin
  if (csCreating in Form.ControlState) or (FormState and FS_BLENDMOVING = FS_BLENDMOVING) or (SkinData.Skinindex < 0) then Exit;
  Iconic := IsIconic(Form.Handle) and (Application.MainForm <> Form);

  CY := SysBorderHeight(Form.Handle, BorderForm, False);
  h := 2 * CY + CaptionHeight;
  ShadowSize := Self.ShadowSize;
  fCaptHeight := CaptionHeight + SysBorderHeight(Form.Handle, BorderForm, False) + ShadowSize.Top;

  if Iconic
    then fHeight := fCaptHeight - ShadowSize.Top + 2
    else fHeight := Form.Height;
  if BorderForm <> nil then fHeight := fHeight + DiffBorder(Self.BorderForm) + DiffTitle(Self.BorderForm) + ShadowSize.Top + ShadowSize.Bottom + integer(MenuHeight <> 0);
  fWidth := CaptionWidth;
  sMan := SkinData.SkinManager;
  iDrawState := min(integer(FormActive), sMan.gd[FCommonData.SkinIndex].States - 1);
  exBorders := (BorderForm <> nil) and (sMan.SkinData.ExDrawMode = 1);

  with FCommonData do if FCacheBmp = nil then begin // If first loading
    if BorderForm <> nil then FCacheBmp := CreateBmp32(fWidth, fHeight) else FCacheBmp := CreateBmp32(fWidth, fHeight);
    FCacheBmp.Canvas.Handle;
    UpdateSkinState(FCommonData, False);
    acM := MakeMessage(SM_ALPHACMD, MakeWParam(0, AC_GETSKINSTATE), 1, 0); // Initialization of all child states
    if not (csLoading in Form.ComponentState) then AlphaBroadCast(Form, acM);
  end;
  if (Form.FormStyle = fsMDIForm) and (Form.ActiveMDIChild <> nil) and (Form.ActiveMDIChild.WindowState = wsMaximized) then begin
    if (fsShowing in Form.ActiveMDIChild.FormState) and MenuChanged then Exit;
  end;
  ItemProcessed := 0;

  sbw := SysBorderWidth(Form.Handle, BorderForm);
  rForm := Rect(ShadowSize.Left, ShadowSize.Top, fWidth - ShadowSize.Right, fHeight - ShadowSize.Bottom);
  if FCommonData.BGChanged then begin
//     if (Form.Parent <> nil) and (Form.FormStyle <> fsMDIChild) then FCommonData.CtrlSkinState := FCommonData.CtrlSkinState and not ACS_FAST; // v7.00

    RgnChanged := True;
    ci.Ready := False;
    FCommonData.FCacheBmp.Width := fWidth;
    FCommonData.FCacheBmp.Height := fHeight;
    if sMan.IsValidSkinIndex(FCommonData.SkinIndex) then begin
      if Form.Parent = nil then CI := EmptyCI else begin
        BG.DrawDC := 0;
        BG.Offset := Point(0, 0);
        BG.PleaseDraw := False;
        GetBGInfo(@BG, Form.Parent, False);
        CI := BGInfoToCI(@BG);
      end;

      // Paint the form with borders
      if (SkinData.CtrlSkinState and ACS_FAST <> ACS_FAST) then begin // If cache is required
        if HaveBorder(Self) or (Form.Parent <> nil) and not exBorders
          then PaintItem(FCommonData, CI, False, iDrawState, rForm, Point(Form.Left, Form.Top), FCommonData.FCacheBmp, Form.Parent <> nil)
          else PaintItemBG(FCommonData.SkinIndex, FCommonData.SkinSection, CI, iDrawState, rForm, Point(Form.Left, Form.Top), FCommonData.FCacheBmp, sMan);
      end
      else begin
        if (BorderForm = nil) then begin // If not extended borders
          FillDC(FCommonData.FCacheBmp.Canvas.Handle, Rect(0, 0, FCommonData.FCacheBmp.Width, CaptionHeight + BorderWidth + LinesCount * MenuHeight + 1), FormColor);
          PaintBorderFast(FCommonData.FCacheBmp.Canvas.Handle, rForm, BorderWidth, FCommonData, iDrawState);
        end
        else begin
          FillRect32(FCommonData.FCacheBmp, Rect(ShadowSize.Left, ShadowSize.Top, FCommonData.FCacheBmp.Width - ShadowSize.Right, FCommonData.FCacheBmp.Height - ShadowSize.Bottom), FormColor);
          if not exBorders then PaintBorderFast(FCommonData.FCacheBmp.Canvas.Handle, rForm, BorderWidth, FCommonData, iDrawState);
        end;
      end;

      if IsGripVisible(Self) and IsCached(FCommonData)then begin
        FCommonData.BGChanged := False;
        PaintGrip(FCommonData.FCacheBmp.Canvas.Handle, Self);
      end;

      ci := MakeCacheInfo(FCommonData.FCacheBmp, OffsetX, OffsetY); // Prepare cache info
      if not exBorders then PaintTitle;

      // Menu line drawing
      if IsMenuVisible(Self) and MenuPresent and (MenuHeight > 0) and DrawNonClientArea and sMan.SkinnedPopups then begin
        i := -1;
        if FMenuLineSkin <> '' then i := sMan.GetSkinIndex(FMenuLineSkin);
        if i < 0 then i := sMan.GetSkinIndex(s_MenuLine); // Paint menu bar
        if sMan.IsValidSkinIndex(i)
          then PaintItem(i, FMenuLineSkin, ci, True, iDrawState,
                 Rect(ShadowSize.Left, fCaptHeight, FCommonData.FCacheBmp.Width - ShadowSize.Right, fCaptHeight + LinesCount * MenuHeight + 1),
                 Point(ShadowSize.Left, fCaptHeight), FCommonData.FCacheBmp, sMan);

        MenuLineBmp.Width := fWidth - ShadowSize.Left - ShadowSize.Right; // Store bg for Menu line
        MenuLineBmp.Height := LinesCount * MenuHeight + 1;
        y := OffsetY - LinesCount * MenuHeight - Form.BorderWidth - 1;
        BitBlt(MenuLineBmp.Canvas.Handle, 0, 0, MenuLineBmp.Width, MenuLineBmp.Height, FCommonData.FCacheBmp.Canvas.Handle, OffsetX - Form.BorderWidth, y, SRCCOPY);

        // Draw maximized child form system icon on menuline
        if ChildIconPresent and (MDISkinProvider = Self) then begin
          if Form.ActiveMDIChild.Icon.Handle <> 0
            then DrawIconEx(FCommonData.FCacheBmp.Canvas.Handle, sbw + 1, fCaptHeight + 1, Form.ActiveMDIChild.Icon.Handle, MenuHeight - 2, MenuHeight - 2, 0, 0, DI_NORMAL)
            else if AppIcon <> nil
              then DrawIconEx(FCommonData.FCacheBmp.Canvas.Handle, sbw + 1 + ShadowSize.Left, fCaptHeight + 1, AppIcon.Handle, MenuHeight - 2, MenuHeight - 2, 0, 0, DI_NORMAL)
              else DrawIconEx(FCommonData.FCacheBmp.Canvas.Handle, sbw + 1 + ShadowSize.Left, fCaptHeight + 1, LoadIcon(0, IDI_APPLICATION), MenuHeight - 2, MenuHeight - 2, 0, 0, DI_NORMAL);
        end;
        // << Menu items >> //
        x := sbw + ShadowSize.Left;
        y := fCaptHeight;
//        if FSysExHeight then inc(y, 4);
        ChangedIndex := -1;
        Index := 0;
        VisIndex := 0;

        if AeroIsEnabled then sMan.SkinableMenus.InitMenuLine(Form.Menu, FDrawNonCLientArea);

        while Index < Form.Menu.Items.Count do begin
          if (x = sbw + ShadowSize.Left) and (MDISkinProvider = Self) and ChildIconPresent then begin // Skip Item with child icon
            GetMenuItemRect(Form.Handle, Form.Menu.Handle, 0, R);
            inc(x, WidthOf(R));
            inc(VisIndex);
            Continue;
          end;
          CurrentItem := Form.Menu.Items[Index];
          if ((CurrentItem.GroupIndex = ChangedIndex) or ProcessMerged(CurrentItem.GroupIndex)) then begin
            inc(Index); Continue;
          end
          else begin
            if not CurrentItem.Visible then begin
              inc(Index);
              Continue;
            end;
            if not Assigned(CurrentItem.OnMeasureItem) or not Assigned(CurrentItem.OnAdvancedDrawItem) then begin
              if not CurrentItem.GetParentMenu.OwnerDraw then begin
                sMan.SkinableMenus.InitMenuLine(Form.Menu, True);
                UpdateMenu;
              end
              else sMan.SkinableMenus.InitMenuLine(Form.Menu, True);
            end;
            GetMenuItemRect(Form.Handle, Form.Menu.Handle, VisIndex, R);
            w := WidthOf(R);
            if FSysExHeight
              then OffsetRect(R, -Form.Left + DiffBorder(Self.BorderForm) + ShadowSize.Left, -Form.Top + DiffTitle(Self.BorderForm) + ShadowSize.Top + 4)
              else OffsetRect(R, -Form.Left + DiffBorder(Self.BorderForm) + ShadowSize.Left, -Form.Top + DiffTitle(Self.BorderForm) + ShadowSize.Top);
//            if Assigned(CurrentItem.OnAdvancedDrawItem) then
            CurrentItem.OnAdvancedDrawItem(CurrentItem, FCommonData.FCacheBmp.Canvas, R, [odNoAccel, odReserved1]);
            inc(x, w);
            inc(Index);
            inc(VisIndex);
          end;
        end;
        ProcessMerged(MaxInt);
      end; // End menu drawing
      if not exBorders and (BorderForm <> nil) then PaintText;
      // Paint MDIArea
      if (Form.FormStyle = fsMDIForm) and Assigned(MDIForm) then begin
        rC.Left := BorderWidth + GetAlignShift(Form, alLeft) + ShadowSize.Left;
        rC.Top := fCaptHeight + LinesCount * MenuHeight * integer(MenuPresent) + Form.BorderWidth + GetAlignShift(Form, alTop);

        if Menuheight <> 0 then inc(rC.Top);
        rC.Right := FCommonData.FCacheBmp.Width - BorderWidth - GetAlignShift(Form, alRight) - ShadowSize.Right;
        rC.Bottom := FCommonData.FCacheBmp.Height - BorderWidth - GetAlignShift(Form, alBottom) - ShadowSize.Bottom;
        CI := MakeCacheInfo(FCommonData.FCacheBmp);
        i := sMan.GetSkinIndex(s_MDIArea);
        PaintItem(i, s_MDIArea, CI, False, 0, Rect(rC.Left, rC.Top, rC.Right, rC.Bottom), rC.TopLeft, FCommonData.FCacheBmp.Canvas.Handle, sMan);
      end;
      if (BorderForm <> nil) then begin // Painting of form shadow if required
        if FormActive
          then BorderForm.ShadowTemplate := sMan.ShdaTemplate
          else BorderForm.ShadowTemplate := sMan.ShdiTemplate;
        if BorderForm.ShadowTemplate <> nil then begin
          i := BorderForm.CaptionHeight;
          if exBorders then with sMan do begin
            ChangedIndex := sMan.ConstData.ExBorder; // Index of extended border in skin
            iDrawMode := sMan.ma[ChangedIndex].DrawMode and BDM_STRETCH;
            PaintControlByTemplate(FCommonData.FCacheBmp, BorderForm.ShadowTemplate, Rect(0, 0, fWidth, fHeight),
                Rect(0, 0, BorderForm.ShadowTemplate.Width, BorderForm.ShadowTemplate.Height),
                Rect(ma[ChangedIndex].WL, min(ma[ChangedIndex].WT, CaptionHeight + (FCommonData.FCacheBmp.Height - CaptionHeight) div 2),
                     ma[ChangedIndex].WR, min(ma[ChangedIndex].WB, (FCommonData.FCacheBmp.Height - CaptionHeight) div 2)),
                Rect(ShadowSize.Left + BorderWidth, ShadowSize.Top + i, ShadowSize.Right + BorderWidth, ShadowSize.Bottom + BorderWidth),
//                Rect(1, 1, 1, 1), False, False);
                Rect(iDrawMode, iDrawMode, iDrawMode, iDrawMode), False, False); // Uncomment in BETA

            PaintTitle;
            PaintText;

            if x64woAero then begin // Fix a problem with glowing glitches on x64 PC w/o Aero
              R := Rect(0, 0, FCommonData.FCacheBmp.Width, FCommonData.FCacheBmp.Height);
              for y := R.Top to R.Bottom - 1 do begin
                P := FCommonData.FCacheBmp.ScanLine[y];
                for x := R.Left to R.Right - 1 do begin
                  C_ := P[X];
                  if (C_.A < MaxByte) then begin
                    i := max(abs(C_.R - C_.G), abs(C_.B - C_.G));
                    i := max(i, abs(C_.R - C_.B));
                    if i = 0 then Continue;
                    rec := MaxByte / i;
                    if rec < 1 then Continue;
                    C_.R := C_.R - C_.R shr 4;
                    C_.G := C_.G - C_.G shr 4;
                    C_.B := C_.B - C_.B shr 4;
                    C_.A := min(MaxByte, Round(C_.A + (2 * (MaxByte - C_.A) / sqrt(rec))));
                    P[X] := C_;
                  end;
                end;
              end;
            end;
          end
          else begin
            PaintControlByTemplate(FCommonData.FCacheBmp, BorderForm.ShadowTemplate, Rect(0, 0, fWidth, fHeight),
              Rect(0, 0, BorderForm.ShadowTemplate.Width, BorderForm.ShadowTemplate.Height),
//              Rect(ShadowSize.Left{ + sMan.SkinData.ExContentOffs}, ShadowSize.Top{ + sMan.SkinData.ExContentOffs}, ShadowSize.Right{ + sMan.SkinData.ExContentOffs}, ShadowSize.Bottom{ + sMan.SkinData.ExContentOffs}),
              Rect(ShadowSize.Left + sMan.SkinData.ExContentOffs, ShadowSize.Top + sMan.SkinData.ExContentOffs, ShadowSize.Right + sMan.SkinData.ExContentOffs, ShadowSize.Bottom + sMan.SkinData.ExContentOffs),
              ShadowSize, Rect(1, 1, 1, 1), False, False); // For internal shadows - stretch only allowed
            // Draw shadows in corners
            if sMan.IsValidImgIndex(TitleIndex) then TitleIndex := sMan.gd[TitleIndex].BorderIndex;
            if sMan.IsValidImgIndex(TitleIndex) then begin // If title mask exists
              x := sMan.MaskWidthRight(TitleIndex);
              // LeftTop
              R := Rect(ShadowSize.Left, ShadowSize.Top, ShadowSize.Left + sMan.MaskWidthLeft(TitleIndex),
                        ShadowSize.Top + sMan.MaskWidthTop(TitleIndex));
              FillTransPixels32(FCommonData.FCacheBmp, BorderForm.ShadowTemplate, R, ShadowSize.TopLeft, TitleIndex, sMan, HTTOPLEFT);
              // RightTop
              R := Rect(FCommonData.FCacheBmp.Width - ShadowSize.Right - x, ShadowSize.Top, FCommonData.FCacheBmp.Width - ShadowSize.Right,
                        ShadowSize.Top + sMan.MaskWidthTop(TitleIndex));
              FillTransPixels32(FCommonData.FCacheBmp, BorderForm.ShadowTemplate, R,
                Point(BorderForm.ShadowTemplate.Width - ShadowSize.Right - x, ShadowSize.Top), TitleIndex, sMan, HTTOPRIGHT);
            end
            else if FCommonData.BorderIndex > -1 then begin
              x := sMan.MaskWidthRight(FCommonData.BorderIndex);
              // LeftTop
              R := Rect(ShadowSize.Left, ShadowSize.Top, ShadowSize.Left + min(sMan.MaskWidthLeft(FCommonData.BorderIndex), 8), ShadowSize.Top + min(sMan.MaskWidthTop(FCommonData.BorderIndex), 8));
              FillTransPixels32(FCommonData.FCacheBmp, BorderForm.ShadowTemplate, R, ShadowSize.TopLeft, FCommonData.BorderIndex, sMan, HTTOPLEFT);
              // RightTop
              R := Rect(FCommonData.FCacheBmp.Width - ShadowSize.Right - x,  ShadowSize.Top, FCommonData.FCacheBmp.Width - ShadowSize.Right,
                        ShadowSize.Top + sMan.MaskWidthTop(FCommonData.BorderIndex));
              FillTransPixels32(FCommonData.FCacheBmp, BorderForm.ShadowTemplate, R,
                                Point(max(0, BorderForm.ShadowTemplate.Width - ShadowSize.Right - x), ShadowSize.Top), FCommonData.BorderIndex, sMan, HTTOPRIGHT);
            end;
            if FCommonData.BorderIndex > -1 then begin
              y := sMan.MaskWidthBottom(FCommonData.BorderIndex);
              x := sMan.MaskWidthRight(FCommonData.BorderIndex);      
              // LeftBottom
              R := Rect(ShadowSize.Left, FCommonData.FCacheBmp.Height - ShadowSize.Bottom - y, ShadowSize.Left + sMan.MaskWidthLeft(FCommonData.BorderIndex),
                        FCommonData.FCacheBmp.Height - ShadowSize.Bottom);
              FillTransPixels32(FCommonData.FCacheBmp, BorderForm.ShadowTemplate, R, Point(ShadowSize.Left, max(0, BorderForm.ShadowTemplate.Height - ShadowSize.Bottom - y)), FCommonData.BorderIndex, sMan, HTBOTTOMLEFT);
              // RightBottom
              R := Rect(FCommonData.FCacheBmp.Width - ShadowSize.Right - x, FCommonData.FCacheBmp.Height - ShadowSize.Bottom - y,
                        FCommonData.FCacheBmp.Width - ShadowSize.Right, FCommonData.FCacheBmp.Height - ShadowSize.Bottom);
              FillTransPixels32(FCommonData.FCacheBmp, BorderForm.ShadowTemplate, R,
                Point(max(0, BorderForm.ShadowTemplate.Width - ShadowSize.Right - x), max(0, BorderForm.ShadowTemplate.Height - ShadowSize.Bottom - y)), FCommonData.BorderIndex, sMan, HTBOTTOMRIGHT);
            end;
          end;
        end;
      end;
//      if IsBorderUnchanged(FCommonData.BorderIndex, FCommonData.SkinManager) and ((TitleBG = nil) or (TitleBG.Width <> CaptionWidth)) then MakeTitleBG;
      if BorderForm = nil then PaintText;
      if (CaptionHeight <> 0) and FDrawNonClientArea then begin
        SaveBGForBtns(True);
        PaintBorderIcons;
      end;
    end;
    MenuChanged := False;
    FCommonData.BGChanged := False;
    if Assigned(Form.OnPaint) and IsCached(SkinData) then begin
      SavedCanvas := Form.Canvas.Handle;
      Form.Canvas.Handle := SkinData.FCacheBmp.Canvas.Handle;
      SavedDC := SaveDC(Form.Canvas.Handle);
      MoveWindowOrg(Form.Canvas.Handle, OffsetX, OffsetY);
      Form.Canvas.Lock;
      Form.OnPaint(Form);
      Form.Canvas.Unlock;
      RestoreDC(Form.Canvas.Handle, SavedDC);
      Form.Canvas.Handle := SavedCanvas;
    end;
    FirstInitialized := True;
    FCommonData.BGChanged := False;
  end;
  FCommonData.Updating := False;
end;

function TsSkinProvider.FormLeftTop: TPoint;
var
  p : TPoint;
  R : TRect;
begin
  if TForm(Form).FormStyle = fsMDIChild then begin
    p := Point(0, 0);
    p := Form.ClientToScreen(p);
    Result.x := p.x - SysBorderWidth(Form.Handle, BorderForm);
    Result.y := p.y - SysBorderHeight(Form.Handle, BorderForm) - integer(not IsIconic(Form.Handle)) * CaptionHeight;
  end
  else begin
    GetWindowRect(Form.Handle, R);
    Result.x := R.Left;
    Result.y := R.Top;
  end;
end;

function TsSkinProvider.IconRect: TRect;
var
  fCaptHeight : integer;
begin
  Result.Left := SysBorderWidth(Form.Handle, BorderForm) + SkinData.SkinManager.SkinData.BILeftMargin + ShadowSize.Left;
  Result.Right := Result.Left + TitleIconWidth(Self);
  Result.Top := ShadowSize.Top + SysBorderWidth(Form.Handle, BorderForm, False) div 2 - 1;
  fCaptHeight := CaptionHeight + SysBorderHeight(Form.Handle, BorderForm, False) + ShadowSize.Top;

  Result.Top := Result.Top + (fCaptHeight - Result.Top - TitleIconHeight(Self)) div 2;


  Result.Bottom := Result.Top + TitleIconHeight(Self);
  if (BorderForm <> nil) then begin
    OffsetRect(Result, 0, FCommonData.SkinManager.SkinData.ExCenterOffs);
    if (Form.WindowState = wsMaximized) and (FCommonData.SkinManager.SkinData.ExTitleHeight <> FCommonData.SkinManager.SkinData.ExMaxHeight)
      then OffsetRect(Result, 0, (FCommonData.SkinManager.SkinData.ExTitleHeight - FCommonData.SkinManager.SkinData.ExMaxHeight) div 2 - 2)
  end;
end;

procedure TsSkinProvider.DropSysMenu(x, y : integer);
var
  mi : TMenuitem;
  SysMenu: HMENU;
  SelItem: DWORD;
  procedure EnableCommandItem(uIDEnableItem : UINT; Enable : Boolean);
  begin
    if Enable
      then EnableMenuItem(SysMenu, uIDEnableItem, MF_BYCOMMAND or MF_ENABLED)
      else EnableMenuItem(SysMenu, uIDEnableItem, MF_BYCOMMAND or MF_GRAYED or MF_DISABLED);
  end;
begin
  if SkinData.SkinManager.SkinnedPopups then begin
    SystemMenu.UpdateItems(SystemMenu.ExtItemsCount > 0);
    if FMakeSkinMenu and (SystemMenu.Items.Count > 0) then begin
      if SystemMenu.Items[0].Name = s_SkinSelectItemName then begin
        while SystemMenu.Items[0].Count > 0 do begin
          mi := SystemMenu.Items[0].Items[0];
          SystemMenu.Items[0].Delete(0);
          FreeAndNil(mi);
        end;
        mi := SystemMenu.Items[0];
        SystemMenu.Items.Delete(0);
        FreeAndNil(mi);
      end;
      SystemMenu.MakeSkinItems;
    end;
    SkinData.SkinManager.SkinableMenus.HookPopupMenu(SystemMenu, True);

    SkinData.SkinManager.SkinableMenus.HookPopupMenu(SystemMenu, True);
    SystemMenu.WindowHandle := Form.Handle;
    SystemMenu.Popup(x, y);
    SystemMenu.WindowHandle := 0;
  end
  else begin
    // Prevent of painting by system (white line)
    SetWindowLong(Form.Handle, GWL_STYLE, GetWindowLong(Form.Handle, GWL_STYLE) and not WS_VISIBLE);
    //get a modifiable copy of the original sysmenu
    SysMenu := GetSystemMenu(Form.Handle, False);
    //read and emulate states from skin SystemMenu
    with SystemMenu do begin
      EnableCommandItem(SC_RESTORE , VisibleRestore And EnabledRestore);
      EnableCommandItem(SC_MOVE    , EnabledMove and not IsIconic(Form.Handle));
      EnableCommandItem(SC_SIZE    , VisibleSize And EnabledSize And (Form.WindowState = wsNormal));
      EnableCommandItem(SC_MINIMIZE, VisibleMin And EnabledMin);
      EnableCommandItem(SC_MAXIMIZE, VisibleMax And EnabledMax);
      EnableCommandItem(SC_CLOSE   , VisibleClose);
    end;
    SetWindowLong(Form.Handle, GWL_STYLE, GetWindowLong(Form.Handle, GWL_STYLE) or WS_VISIBLE);
    //Get menuselection from menu, do not send it on automatically
    SelItem := LongWord(TrackPopupMenu(SysMenu, TPM_LEFTBUTTON or TPM_RIGHTBUTTON or TPM_RETURNCMD, x, y, 0, Form.Handle, nil));
    //If the sysmenu tracking resulted in a selection, post it as a WM_SYSCOMMAND
    if SelItem > 0 then PostMessage(Form.Handle, WM_SYSCOMMAND, SelItem, 0);
  end;
end;

function TsSkinProvider.CursorToPoint(x, y: integer): TPoint;
begin
  Result := FormLeftTop;
  Result.x := x - Result.x;
  Result.y := y - Result.y;
end;

function TsSkinProvider.MenuPresent: boolean;
var
 i, VisibleItems : integer;
begin
  Result := False;
  if (Form.BorderStyle <> bsDialog) and (Form.FormStyle <> fsMDIChild) then begin
    if (Form.Menu <> nil) and not Form.Menu.AutoMerge then begin
      VisibleItems := 0;
      for i := 0 to Form.Menu.Items.Count - 1 do if Form.Menu.Items[i].Visible then begin
        inc(VisibleItems);
        Break;
      end;
      if (Form.FormStyle = fsMDIForm) and Assigned(Form.ActiveMDIChild) and Assigned(Form.ActiveMDIChild.Menu) then begin
        for i := 0 to Form.ActiveMDIChild.Menu.Items.Count - 1 do if Form.ActiveMDIChild.Menu.Items[i].Visible then begin
          inc(VisibleItems);
          Break;
        end;
      end;
      Result := VisibleItems > 0;
    end;
  end;
end;

function TsSkinProvider.OffsetX: integer;
var
  i : integer;
begin
  if (BorderForm <> nil) then Result := BorderWidth + ShadowSize.Left else begin
    if Assigned(ListSW) and Assigned(ListSW.sBarVert) and ListSW.sBarVert.fScrollVisible then i := GetScrollMetric(ListSW.sBarVert, SM_CXVERTSB) else i := 0;
    Result := (GetWindowWidth(Form.Handle) - GetClientWidth(Form.Handle) - i) div 2
  end;
end;

function TsSkinProvider.OffsetY: integer;
var
  i : integer;
begin
  if (BorderForm <> nil) then begin
    Result := CaptionHeight + LinesCount * MenuHeight + Form.BorderWidth + ShadowSize.Top + integer(MenuHeight <> 0)
  end
  else begin
    if Assigned(ListSW) and Assigned(ListSW.sBarHorz) and ListSW.sBarHorz.fScrollVisible then i := GetScrollMetric(ListSW.sBarHorz, SM_CYHORZSB) else i := 0;
    Result := GetWindowHeight(Form.Handle) - GetClientHeight(Form.Handle) - BorderWidth * integer(GetWindowLong(Form.Handle, GWL_STYLE) and WS_BORDER = WS_BORDER) - i;
  end;
end;

function TsSkinProvider.GetLinesCount: integer;
var
  i, y1, y2 : integer;
  R : TRect;
begin
  if FLinesCount <> -1 then Result := FLinesCount else begin
    if (Form.Menu = nil) or (Form.WindowState = wsMinimized) then begin
      Result := 0;
      Exit;
    end;
    Result := 1;
    if GetMenuItemRect(Form.Handle, Form.Menu.Handle, 0, R) then y1 := R.Bottom else Exit;
    GetClientRect(Form.Handle, R);
    if (ListSW <> nil) then begin
      if ListSW.sBarHorz.fScrollVisible
        then i := GetSystemMetrics(SM_CYHSCROLL)
        else i := 0;
    end
    else i := 0;
    y2 := Form.Top + Form.Height - HeightOf(R) - BorderHeight(False) - i - Form.BorderWidth * 2;
//    y2 := Form.Top + ACClientRect(Form.Handle).Top; //
    if y2 > y1 then inc(Result, (y2 - y1) div (GetSystemMetrics(SM_CYMENU) - 1));
    FLinesCount := Result;
  end;
end;

procedure TsSkinProvider.Loaded;
begin
  inherited;
  if not RTEmpty and not RTInit and Assigned(FCommonData.SkinManager) and not (csDesigning in ComponentState) and FCommonData.Skinned(True) then begin
    LoadInit;
  end;
end;

procedure TsSkinProvider.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (AComponent is TsSkinManager) then case Operation of
    opInsert : if not Assigned(SkinData.SkinManager) then SkinData.SkinManager := TsSkinManager(AComponent);
    opRemove : if AComponent = SkinData.SkinManager then SkinData.SkinManager := nil;
  end
  else if (AComponent is TWinControl) then case Operation of
    opInsert : if Assigned(Adapter) then begin
      if TacCtrlAdapter(Adapter).IsControlSupported(TWincontrol(AComponent)) then TacCtrlAdapter(Adapter).AddNewItem(TWincontrol(AComponent));
    end;
  end;
end;

function TsSkinProvider.FormChanged: boolean;
begin
  Result := (FCommonData.FCacheBmp = nil) or (CaptionWidth <> FCommonData.FCacheBmp.Width) or (Form.Height <> FCommonData.FCacheBmp.Height)
end;

procedure TsSkinProvider.RepaintMenuItem(mi: TMenuItem; R: TRect; State : TOwnerDrawState);
var
  DC, SavedDC : hdc;
begin
  SavedDC := 0;
  if MenuPresent and (Form.Menu.FindItem(mi.Handle, fkHandle) <> nil) then begin
    mi.OnAdvancedDrawItem(mi, FCommonData.FCacheBmp.Canvas, R, State);
    DC := GetWindowDC(Form.Handle);
    try
      SavedDC := SaveDC(DC);
      BitBlt(DC, R.Left, R.Top, WidthOf(R), HeightOf(R), FCommonData.FCacheBmp.Canvas.Handle, R.Left, R.Top, SRCCOPY);
    finally
      RestoreDC(DC, SavedDC);
      ReleaseDC(Form.Handle, DC);
    end;
  end;
end;

function TsSkinProvider.SmallButtonWidth: integer;
begin
  if FCommonData.SkinManager.IsValidImgIndex(MDIClose.ImageIndex) then begin
    if Assigned(FCommonData.SkinManager.ma[MDIClose.ImageIndex].Bmp)
      then Result := FCommonData.SkinManager.ma[MDIClose.ImageIndex].Bmp.Width div 3
      else Result := WidthOf(FCommonData.SkinManager.ma[MDIClose.ImageIndex].R) div FCommonData.SkinManager.ma[MDIClose.ImageIndex].ImageCount;
  end
  else Result := 16;
end;

function TsSkinProvider.SmallButtonHeight: integer;
begin
  if FCommonData.SkinManager.IsValidImgIndex(MDIClose.ImageIndex) then begin
    if Assigned(FCommonData.SkinManager.ma[MDIClose.ImageIndex].Bmp)
      then Result := FCommonData.SkinManager.ma[MDIClose.ImageIndex].Bmp.Height div 2
      else Result := HeightOf(FCommonData.SkinManager.ma[MDIClose.ImageIndex].R) div (FCommonData.SkinManager.ma[MDIClose.ImageIndex].MaskType + 1);
  end
  else Result := 16;
end;

function TsSkinProvider.HeaderHeight: integer;
begin
  if (BorderForm <> nil) then begin
    Result := CaptionHeight + SysBorderHeight(Form.Handle, BorderForm, False);
  end
  else
    if CaptionHeight(BorderForm = nil) = 0
      then Result := GetWindowHeight(Form.Handle) - GetClientHeight(Form.Handle) - integer(GetWindowLong(Form.Handle, GWL_STYLE) and WS_BORDER = WS_BORDER) * BorderHeight {v6.45}
      else Result := GetWindowHeight(Form.Handle) - GetClientHeight(Form.Handle) - BorderHeight;

  if Result < 0 then Result := 0;
  if IsIconic(Form.Handle) then inc(Result, SysBorderHeight(Form.Handle, BorderForm, False));
  if SkinData.Skinned and Assigned(ListSW) and Assigned(ListSW.sBarHorz) and ListSW.sBarHorz.fScrollVisible then begin
    dec(Result, GetScrollMetric(ListSW.sBarHorz, SM_CYHORZSB));
  end;
end;

function TsSkinProvider.MDIButtonsNeeded: boolean;
begin
  Result := (ChildProvider <> nil) and (Form.FormStyle = fsMDIForm) and Assigned(Form.ActiveMDIChild) and
              (Form.ActiveMDIChild.WindowState = wsMaximized) and (Form.Menu <> nil) and (biSystemMenu in Form.ActiveMDIChild.BorderIcons);
end;

function TsSkinProvider.MenuHeight: integer;
begin
  if IsMenuVisible(Self) then Result := GetSystemMetrics(SM_CYMENU) - 1 else Result := 0;
end;

type
  TAccessMenuItem = class(TMenuItem);

function TsSkinProvider.UpdateMenu : boolean;
begin
  Result := False;
  if not fGlobalFlag then begin
    fGlobalFlag := True;
    if (Form.Menu <> nil) and (Form.Menu.Items.Count > 0) and (Form.Menu.Items[0] <> nil) then begin
      TAccessMenuItem(Form.Menu.Items[0]).MenuChanged(True);
      Result := True;
    end;
    fGlobalFlag := False;
  end;
end;

function TsSkinProvider.IconVisible: boolean;
begin
  Result := ((Form.BorderStyle = bsSizeable) or (Form.BorderStyle = bsSingle)) and FShowAppIcon and (GetSystemMenu(Form.Handle, False) <> 0);
end;

procedure TsSkinProvider.MakeTitleBG;
begin
{  if TitleBG <> nil then FreeAndNil(TitleBG);
  TitleBG := CreateBmp32(FCommonData.FCacheBmp.Width, CaptionHeight + SysBorderHeight(Form.Handle, BorderForm) + ShadowSize.Top);
  BitBlt(TitleBG.Canvas.Handle, 0, 0, TitleBG.Width, TitleBG.Height, FCommonData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
}  
end;

procedure TsSkinProvider.SetCaptionAlignment(const Value: TAlignment);
begin
  if FCaptionAlignment <> Value then begin
    FCaptionAlignment := Value;
    FCommonData.BGChanged := True;
    if Form.Visible and not (csDesigning in ComponentState) and SkinData.Skinned then UpdateSkinCaption(Self);
  end;
end;

procedure TsSkinProvider.SetShowAppIcon(const Value: boolean);
begin
  if FShowAppIcon <> Value then begin
    FShowAppIcon := Value;
    FCommonData.BGChanged := True;
    if Form.Visible then SendMessage(Form.Handle, WM_NCPAINT, 0, 0);
  end;
end;

procedure TsSkinProvider.SetTitleButtons(const Value: TsTitleButtons);
begin
  FTitleButtons.Assign(Value);
end;

function TsSkinProvider.RBGripPoint(ImgIndex : integer): TPoint;
begin
  Result := Point(FCommonData.FCacheBmp.Width - WidthOfImage(FCommonData.SkinManager.ma[ImgIndex]) - SysBorderWidth(Form.Handle, BorderForm) - ShadowSize.Right - 1,
                  FCommonData.FCacheBmp.Height - HeightOfImage(FCommonData.SkinManager.ma[ImgIndex]) - SysBorderWidth(Form.Handle, BorderForm) - ShadowSize.Bottom - 1);
end;

procedure TsSkinProvider.InitMenuItems(A: boolean);
var
  i : integer;
  procedure ProcessComponent(c: TComponent);
  var
    i: integer;
  begin
    if (c <> nil) then begin
      if (c is TFrame)
        then for i := 0 to c.ComponentCount - 1 do ProcessComponent(c.Components[i])
        else if (c is TMainMenu) then begin
          FCommonData.SkinManager.SkinableMenus.InitMenuLine(TMainMenu(c), A and FDrawNonCLientArea);
          for i := 0 to TMainMenu(c).Items.Count - 1 do
            FCommonData.SkinManager.SkinableMenus.HookItem(TMainMenu(c).Items[i], A and FCommonData.SkinManager.SkinnedPopups);
        end
        else if (c is TPopupMenu) then FCommonData.SkinManager.SkinableMenus.HookPopupMenu(TPopupMenu(c), A and FCommonData.SkinManager.SkinnedPopups)
          else if (c is TMenuItem) then if not (TMenuItem(c).GetParentMenu is TMainMenu)
            then FCommonData.SkinManager.SkinableMenus.HookItem(TMenuItem(c), A and FCommonData.SkinManager.SkinnedPopups)
            else for i := 0 to c.ComponentCount - 1 do ProcessComponent(c.Components[i]);
    end;
  end;
begin
  if (csDesigning in Form.ComponentState) or (FCommonData.SkinManager.SkinableMenus = nil) or not FCommonData.SkinManager.IsDefault then Exit;
  for i := 0 to Form.ComponentCount - 1 do ProcessComponent(Form.Components[i]);
end;

procedure TsSkinProvider.StartMove(X, Y: Integer);
begin
  if (ResizeMode = rmBorder) and Form.Enabled then begin
    //Common section
    bInProcess := TRUE;
    deskwnd    := GetDesktopWindow();
    formDC     := GetWindowDC(deskwnd);
    nDC        := SaveDC(formDC);
    ntop       := Form.Top;
    nleft      := Form.Left;
    SetROP2(formDC, R2_NOT);

    if bMode then begin //Move section
      nX := X;
      nY := Y;
      DrawFormBorder(nleft, ntop);
    end
    else begin //Size section
      nMinHeight := Form.Constraints.MinHeight;
      nMinWidth  := Form.Constraints.MinWidth;
      nbottom    := Form.top + Form.height;
      nright     := Form.left + Form.width;
      DrawFormBorder(0, 0);
    end;
  end;
end;

procedure TsSkinProvider.StopMove(X, Y: Integer);
begin
  if ResizeMode = rmBorder then begin
    //Common section
    ReleaseCapture;
    bInProcess := FALSE;

    if bMode then begin //Move section
      DrawFormBorder(nleft, ntop);
      RestoreDC(formDC, nDC);
      ReleaseDC(deskwnd, formDC);
      MoveWindow(Form.handle, nleft, ntop, Form.width, Form.height, TRUE)
    end
    else begin //Size section
      DrawFormBorder(0,0);
      RestoreDC(formDC, nDC);
      ReleaseDC(deskwnd, formDC);
      if not bCapture then MoveWindow(Form.handle, nleft, ntop, nright - nleft, nbottom - ntop, TRUE);
      bCapture := FALSE;
    end;
  end;
end;

procedure TsSkinProvider.DrawFormBorder(X, Y: Integer);
var
  pts : array [1..5] of TPoint;
  incX, incY : integer;
begin
  if ResizeMode = rmBorder then begin
    if Form.FormStyle = fsMDIChild then with TsSkinProvider(MDISkinProvider) do begin
      incX := Form.Left + SysBorderWidth(Form.Handle, BorderForm) + Form.BorderWidth + 1;
      incY := Form.Top + SysBorderHeight(Form.Handle, BorderForm) * 2 + CaptionHeight + LinesCount * MenuHeight * integer(MenuPresent) + Form.BorderWidth - 2;
      X := X + incX;
      Y := Y + incY;
    end
    else begin
      incX := 0;
      incY := 0;
    end;
    if bMode then begin //Move section
      pts[1] := point(X, Y);
      pts[2] := point(X, Y + Form.Height);
      pts[3] := point(X + Form.Width, Y + Form.Height);
      pts[4] := point(X + Form.Width, Y);
      pts[5] := point(X, Y);
      PolyLine(formDC, pts, 5);
    end
    else begin //Size section
      pts[1].X := nleft + incX;
      pts[1].Y := ntop + incY;
      pts[2].X := nleft + incX;
      pts[2].Y := nbottom + incY;
      pts[3].X := nright + incX;
      pts[3].Y := nbottom + incY;
      pts[4].X := nright + incX;
      pts[4].Y := ntop + incY;
      pts[5].X := nleft + incX;
      pts[5].Y := ntop + incY;
      PolyLine(formDC, pts, 5);
    end;
  end;
end;

procedure TsSkinProvider.SetUseGlobalColor(const Value: boolean);
begin
  if FUseGlobalColor <> Value then begin
    FUseGlobalColor := Value;
    if FCommonData.Skinned and Assigned(Form) and Value and not SkinData.CustomColor
      then Form.Color := FCommonData.SkinManager.GetGlobalColor
      else Form.Color := clBtnFace;
  end;
end;

procedure TsSkinProvider.RepaintMenu;
begin
  SkinData.BGChanged := True;
  MenuChanged := True;
  FLinesCount := -1;
  SendMessage(Form.Handle, WM_NCPAINT, 0, 0);
end;

function TsSkinProvider.CaptionWidth: integer;
var
  R : TRect;
begin
  if IsIconic(Form.Handle) and (Application.MainForm <> Form) then begin
    GetWindowRect(Form.Handle, R);
    Result := WidthOf(R)
  end
  else Result := Form.Width + integer(BorderForm <> nil) * 2 * DiffBorder(Self.BorderForm);
  inc(Result, ShadowSize.Left + ShadowSize.Right);
end;

procedure TsSkinProvider.UpdateIconsIndexes;
begin
  if FCommonData.SkinManager.IsValidSkinIndex(FCommonData.SkinManager.ConstData.IndexGlobalInfo) then begin
    ButtonMin.HitCode := HTMINBUTTON;
    ButtonMax.HitCode := HTMAXBUTTON;
    ButtonClose.HitCode := HTCLOSE;
    with FCommonData.SkinManager do begin // For compatibility with skins with version < 4.33
      if BigButtons(Self) then begin
        ButtonMin.ImageIndex    := GetMaskIndex(ConstData.IndexGlobalInfo, s_GlobalInfo, s_BorderIconMinimize);
        ButtonMax.ImageIndex    := GetMaskIndex(ConstData.IndexGlobalInfo, s_GlobalInfo, s_BorderIconMaximize);

        if (SystemMenu <> nil) and (SystemMenu.VisibleMax or SystemMenu.VisibleMin)
          then ButtonClose.ImageIndex  := GetMaskIndex(ConstData.IndexGlobalInfo, s_GlobalInfo, s_BorderIconClose)
          else begin
            ButtonClose.ImageIndex := GetMaskIndex(ConstData.IndexGlobalInfo, s_GlobalInfo, s_BorderIconCloseAlone);
            if ButtonClose.ImageIndex < 0 then ButtonClose.ImageIndex  := GetMaskIndex(ConstData.IndexGlobalInfo, s_GlobalInfo, s_BorderIconClose)
          end;
        ButtonHelp.ImageIndex   := GetMaskIndex(ConstData.IndexGlobalInfo, s_GlobalInfo, s_BorderIconHelp);
        ButtonMin.HaveAlignment := True;
      end
      else begin
        ButtonClose.ImageIndex  := GetMaskIndex(ConstData.IndexGlobalInfo, s_GlobalInfo, s_SmallIconClose);
        ButtonMin.ImageIndex    := GetMaskIndex(ConstData.IndexGlobalInfo, s_GlobalInfo, s_SmallIconMinimize);
        ButtonMax.ImageIndex    := GetMaskIndex(ConstData.IndexGlobalInfo, s_GlobalInfo, s_SmallIconMaximize);
        ButtonHelp.ImageIndex   := GetMaskIndex(ConstData.IndexGlobalInfo, s_GlobalInfo, s_SmallIconHelp);
        if ButtonHelp.ImageIndex < 0 then ButtonHelp.ImageIndex := GetMaskIndex(ConstData.IndexGlobalInfo, s_GlobalInfo, s_BorderIconHelp);
        ButtonMin.HaveAlignment := False;
      end;
      ButtonMax.HaveAlignment   := ButtonMin.HaveAlignment;
      ButtonClose.HaveAlignment := ButtonMin.HaveAlignment;
      ButtonHelp.HaveAlignment  := False;//ButtonMin.HaveAlignment;

      if ButtonClose.ImageIndex < 0 then begin
        ButtonClose.ImageIndex  := GetMaskIndex(ConstData.IndexGlobalInfo, s_GlobalInfo, s_BorderIconClose);
        ButtonMin.ImageIndex    := GetMaskIndex(ConstData.IndexGlobalInfo, s_GlobalInfo, s_BorderIconMinimize);
        ButtonMax.ImageIndex    := GetMaskIndex(ConstData.IndexGlobalInfo, s_GlobalInfo, s_BorderIconMaximize);
        ButtonHelp.ImageIndex   := GetMaskIndex(ConstData.IndexGlobalInfo, s_GlobalInfo, s_BorderIconHelp);
        ButtonMin.HaveAlignment   := True;
        ButtonMax.HaveAlignment   := True;
        ButtonClose.HaveAlignment := True;
        ButtonHelp.HaveAlignment  := True;

        if (Form.FormStyle = fsMDIForm) and not (csDesigning in ComponentState) then begin
          MDIMin.ImageIndex       := GetMaskIndex(ConstData.IndexGlobalInfo, s_GlobalInfo, s_BorderIconMinimize);
          MDIMax.ImageIndex       := GetMaskIndex(ConstData.IndexGlobalInfo, s_GlobalInfo, s_BorderIconMaximize);
          MDIClose.ImageIndex     := GetMaskIndex(ConstData.IndexGlobalInfo, s_GlobalInfo, s_BorderIconClose);
        end;
        MDIMin.HaveAlignment   := True;
        MDIMax.HaveAlignment   := True;
        MDIClose.HaveAlignment := True;
      end
      else begin
        if (Form.FormStyle = fsMDIForm) and not (csDesigning in ComponentState) then begin
          MDIMin.ImageIndex       := GetMaskIndex(ConstData.IndexGlobalInfo, s_GlobalInfo, s_SmallIconMinimize);
          MDIMax.ImageIndex       := GetMaskIndex(ConstData.IndexGlobalInfo, s_GlobalInfo, s_SmallIconMaximize);
          MDIClose.ImageIndex     := GetMaskIndex(ConstData.IndexGlobalInfo, s_GlobalInfo, s_SmallIconClose);
          MDIMin.HaveAlignment   := False;
          MDIMax.HaveAlignment   := False;
          MDIClose.HaveAlignment := False;
        end;
        if MDIMin.ImageIndex < 0 then begin // Leaved for compatibility, should be removed later
          MDIMin.ImageIndex       := ButtonMin.ImageIndex;
          MDIMax.ImageIndex       := ButtonMax.ImageIndex;
          MDIClose.ImageIndex     := ButtonClose.ImageIndex;
          MDIMin.HaveAlignment   := True;
          MDIMax.HaveAlignment   := True;
          MDIClose.HaveAlignment := True;
        end;
      end;
    end;        
    UserBtnIndex := FCommonData.SkinManager.GetMaskIndex(FCommonData.SkinManager.ConstData.IndexGlobalInfo, s_GlobalInfo, s_TitleButtonMask);
  end;
end;

procedure TsSkinProvider.SetTitleSkin(const Value: TsSkinSection);
begin
  if FTitleSkin <> Value then begin
    FTitleSkin := Value;
    FCommonData.BGChanged := True;
    if Form.Visible then begin
      if BorderForm <> nil then BorderForm.UpdateExBordersPos else SendMessage(Form.Handle, WM_NCPAINT, 0, 0);
    end;
  end;
end;

function TsSkinProvider.TitleSkinSection: string;
begin
  if FTitleSkin = '' then Result := s_FormTitle else Result := FTitleSkin
end;

procedure TsSkinProvider.SetMenuLineSkin(const Value: TsSkinSection);
begin
  if (FMenuLineSkin <> Value) then begin
    FMenuLineSkin := Value;
    if (csDesigning in ComponentState) then SkinData.Invalidate;
  end;
end;

procedure TsSkinProvider.PrepareForm;
begin
  if RTInit or RTEmpty or (FCommonData.SkinManager = nil) or (Form = nil) or not Form.HandleAllocated then Exit;
  FCommonData.Loaded;
  if SystemMenu = nil then begin
    SystemMenu := TsSystemMenu.Create(Self);
    SystemMenu.FForm := Form;
    SystemMenu.WindowHandle := 0;
    SystemMenu.UpdateItems;
  end;
  CheckSysMenu(True);//FCommonData.SkinManager.SkinData.Active);

  if ClearButtons and FCommonData.SkinManager.SkinData.Active then begin
    ClearButtons := False;
    if (Form.FormStyle = fsMDIForm) and not (csDesigning in ComponentState) then HookMDI;
  end;
  FCommonData.UpdateIndexes;
//  FTitleSkinIndex := TitleSkinIndex;
  FCaptionSkinIndex := FCommonData.SkinManager.GetSkinIndex(s_Caption);
  UpdateIconsIndexes;

  RegionChanged := True;
  CaptChanged := True;
  CaptRgnChanged :=True;

  if (Form.FormStyle = fsMDIChild) then begin // If form is MDIChild and menus are merged then
    if Assigned(MDISkinProvider) and not (csDestroying in TsSkinProvider(MDISkinProvider).ComponentState) and
           not (csDestroying in TsSkinProvider(MDISkinProvider).Form.ComponentState) and SkinData.Skinned then begin
      TsSkinProvider(MDISkinProvider).FCommonData.BGChanged := True;
      TsSkinProvider(MDISkinProvider).FLinesCount := -1;
    end;
  end;
  if not (csCreating in Form.ControlState) and not (csReadingState in Form.ControlState) and
       not (csLoading in ComponentState) and (SkinData.SkinManager <> nil) and UseGlobalColor and not SkinData.CustomColor
    then Form.Color := SkinData.SkinManager.GetGlobalColor;
  InitMenuItems(SkinData.Skinned);
  if not MenusInitialized and UpdateMenu then MenusInitialized := True;
  if SystemMenu <> nil then SystemMenu.UpdateGlyphs;
  if not (csLoading in Form.ComponentState) and Form.Showing then InitExBorders(SkinData.SkinManager.ExtendedBorders);
end;

procedure TsSkinProvider.HookMDI(Active: boolean);
begin
  if Active then begin
    if not GetBoolMsg(Form.ClientHandle, AC_CTRLHANDLED) and Assigned(MDIForm) then FreeAndNil(MDIForm);
    if not Assigned(MDIForm) then begin
      MDISkinProvider := Self;
      TsMDIForm(MDIForm) := TsMDIForm.Create(Self);
      if MDIForm <> nil then TsMDIForm(MDIForm).ConnectToClient;
    end;
  end
  else if Assigned(MDIForm) then FreeAndNil(MDIForm);
end;

procedure TsSkinProvider.DsgnWndProc(var Message: TMessage);
begin
  if ChangeFormsInDesign and (csDesigning in ComponentState) and Assigned(SkinData) and Assigned(SkinData.SkinManager) and
       Assigned(Form) and UseGlobalColor and not SkinData.CustomColor and (Message.WParamHi in [AC_SETNEWSKIN, AC_REFRESH, AC_REMOVESKIN]) and
         (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_SETNEWSKIN, AC_REFRESH : if UseGlobalColor and not SkinData.CustomColor then Form.Color := SkinData.SkinManager.GetGlobalColor;
    AC_REMOVESKIN : Form.Color := clBtnFace;
  end;
end;

function TsSkinProvider.TitleBtnsWidth: integer;
var
  i : integer;
begin
  Result := FCommonData.SkinManager.SkinData.BIRightMargin;
  if Assigned(SystemMenu) and SystemMenu.VisibleClose then begin
    inc(Result, SysButtonWidth(ButtonClose));
    if SystemMenu.VisibleMax then inc(Result, SysButtonWidth(ButtonMax) + integer(BigButtons(Self)) * FCommonData.SkinManager.SkinData.BISpacing);
    if SystemMenu.VisibleMin then inc(Result, SysButtonWidth(ButtonMin) + integer(BigButtons(Self)) * FCommonData.SkinManager.SkinData.BISpacing);
    if (biHelp in Form.BorderIcons) then inc(Result, SysButtonWidth(ButtonHelp) + integer(BigButtons(Self)) * FCommonData.SkinManager.SkinData.BISpacing);
  end;

  if TitleButtons.Count > 0 then inc(Result, UserButtonsOffset);
  for i := 0 to TitleButtons.Count - 1 do begin
    inc(Result, UserButtonWidth(TitleButtons[i]) + integer(BigButtons(Self)) * FCommonData.SkinManager.SkinData.BISpacing);
  end;
end;

function TsSkinProvider.UserButtonWidth(Btn: TsTitleButton): integer;
begin
  if Assigned(Btn.Glyph) then Result := Btn.Glyph.Width + 2 else Result := 0;
  if FCommonData.SkinManager.IsValidImgIndex(UserBtnIndex)
    then Result := max(Result, WidthOf(FCommonData.SkinManager.ma[UserBtnIndex].R) div FCommonData.SkinManager.ma[UserBtnIndex].ImageCount)
    else Result := max(Result, 21);
end;

procedure TsSkinProvider.AdapterCreate;
begin
  if not (csDesigning in ComponentState) and FCommonData.Skinned then begin
    Adapter := TacCtrlAdapter.Create(Self);
    TacCtrlAdapter(Adapter).AddAllItems;
  end;
end;

procedure TsSkinProvider.AdapterRemove;
begin
  if not (csDesigning in ComponentState) then begin
    SendToAdapter(MakeMessage(SM_ALPHACMD, MakeWParam(0, AC_REMOVESKIN), LongWord(SkinData.SkinManager), 0));
    FreeAndNil(Adapter);
  end;
end;

procedure TsSkinProvider.SendToAdapter(Message: TMessage);
begin
  if not (csDesigning in ComponentState) and Assigned(Adapter) then TacCtrlAdapter(Adapter).WndProc(Message)
end;

procedure TsSkinProvider.MdiIcoFormPaint(Sender: TObject);
begin
  with TForm(Sender) do BitBlt(Canvas.Handle, 0, 0, 60, GetSystemMetrics(SM_CYMENU) + 3, SkinData.FCacheBmp.Canvas.Handle,
      Form.Width - 60 + SysBorderWidth(Form.Handle, BorderForm, True) - ShadowSize.Right, CaptionHeight + ShadowSize.Top, SRCCOPY); // Cit
end;

procedure TsSkinProvider.CaptFormPaint(Sender: TObject);
begin
{
 Is not required while form is not drawn
  if (CaptForm <> nil) and not (csDestroying in CaptForm.ComponentState)
    then BitBlt(CaptForm.Canvas.Handle, 0, 0, CaptForm.Width, CaptForm.Height, SkinData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
}
end;

procedure TsSkinProvider.NewCaptFormProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_ERASEBKGND : Exit;
  end;
  OldCaptFormProc(Message);
end;

procedure TsSkinProvider.SaveBGForBtns(Full : boolean = False);
begin
  TempBmp.PixelFormat := FCommonData.FCacheBmp.PixelFormat;
  TempBmp.Width := TitleBtnsWidth + SysBorderWidth(Form.Handle, BorderForm) + 10 + ShadowSize.Right;
  TempBmp.Height := CaptionHeight + SysBorderHeight(Form.Handle, BorderForm) + SysBorderWidth(Form.Handle, BorderForm, False) + MenuHeight + ShadowSize.Top;
  BitBlt(TempBmp.Canvas.Handle, 0, 0, TempBmp.Width, iffi(Full, TempBmp.Height, CaptionHeight + SysBorderHeight(Form.Handle, BorderForm)),
         FCommonData.FCacheBmp.Canvas.Handle, CaptionWidth - TempBmp.Width - 1, 0, SRCCOPY);
end;

procedure TsSkinProvider.RestoreBtnsBG;
begin
  if Assigned(TempBmp) then BitBlt(FCommonData.FCacheBmp.Canvas.Handle, CaptionWidth - TempBmp.Width - 1, 0, TempBmp.Width, TempBmp.Height, TempBmp.Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure TsSkinProvider.AC_WMEraseBkGnd(aDC: hdc);
var
  DC, SavedDC : hdc;
  cR : TRect;
begin
  if InAero then begin
    if (GetClipBox(aDC, cR) = NULLREGION) or (WidthOf(cR) = 0) or (HeightOf(cR) = 0) then aDC := 0; // New DC is needed
  end;
  if (aDC = 0) or (aDC <> SkinData.PrintDC) then DC := GetDC(Form.Handle) else DC := aDC;
  try
    FCommonData.FUpdating := False;
    if not fAnimating and not (csDestroying in Form.ComponentState) and not ((Form.FormStyle = fsMDIChild) and (MDISkinProvider <> nil) and not MDICreating and
         Assigned(TsSkinProvider(MDISkinProvider).Form.ActiveMDIChild) and (TsSkinProvider(MDISkinProvider).Form.ActiveMDIChild.WindowState = wsMaximized)
           and (Form <> TsSkinProvider(MDISkinProvider).Form.ActiveMDIChild)) then begin
      SavedDC := SaveDC(DC);
      ExcludeControls(DC, Form, actGraphic, 0, 0);
      PaintForm(DC);
      if IsGripVisible(Self) then begin
        MoveWindowOrg(DC, -OffsetX, -OffsetY);
        PaintGrip(DC, Self);
      end;
      RestoreDC(DC, SavedDC);
      PaintControls(DC, Form, True, Point(0, 0));
    end;
  finally
    if (DC <> aDC) then ReleaseDC(Form.Handle, DC);
  end;
end;

procedure TsSkinProvider.AC_WMNCPaint;
var
  DC, SavedDC : hdc;
  i, y, th, sbw, dy : integer;
begin
  if MDICreating or not FDrawNonClientArea then Exit; // If maximized mdi child was created
  if (ResizeMode = rmBorder) and AeroIsEnabled then ResizeMode := rmStandard;
  if (Form.FormStyle = fsMDIChild) then begin
    if (MDISkinProvider <> nil) and Assigned(TsSkinProvider(MDISkinProvider).Form.ActiveMDIChild) and
         (TsSkinProvider(MDISkinProvider).Form.ActiveMDIChild.WindowState = wsMaximized) and (Form <> TsSkinProvider(MDISkinProvider).Form.ActiveMDIChild) then Exit;
  end;
  if not MenusInitialized and UpdateMenu then MenusInitialized := True;
  if not RgnChanging and RgnChanged then begin
    if (HaveBorder(Self) or IsSizeBox(Form.Handle) or IsIconic(Form.Handle)) then begin
      FillArOR(Self);
      RgnChanged := False;
      if (fsShowing in Form.FormState) and (Form.Position <> poDefault) and (Form.WindowState <> wsMaximized) then UpdateRgn(Self, False) else begin
        UpdateRgn(Self, not InAnimationProcess);
        Exit
      end;
    end
    else SetWindowRgn(Form.Handle, 0, False);
  end;
  FCommonData.Updating := False;
  if (SkinData.FCacheBmp <> nil) and (SkinData.FCacheBmp.Width = 0) then SkinData.BGChanged := True; // If Cache is not ready
  DC := GetWindowDC(Form.Handle);
  SavedDC := SaveDC(DC);
  try
    if (BorderForm <> nil) then begin
      i := Form.BorderWidth;
      y := CaptionHeight(False);
      sbw := SysBorderWidth(Form.Handle, BorderForm, False);
      inc(y, sbw);
      if FSysExHeight then dec(y, 4);
      if FCommonData.BGChanged then PaintAll;

      th := y + MenuHeight * LinesCount + integer(IsMenuVisible(Self)) + Form.BorderWidth;
      dy := OffsetY - MenuHeight * LinesCount - Form.BorderWidth - 1;
      BitBlt(DC, sbw, y, FCommonData.FCacheBmp.Width - ShadowSize.Left - ShadowSize.Right, MenuHeight * LinesCount + integer(IsMenuVisible(Self)) + Form.BorderWidth,
        FCommonData.FCacheBmp.Canvas.Handle, SysBorderWidth(Form.Handle, BorderForm) + ShadowSize.Left, dy, SRCCOPY); // Title and menu line update
      if i <> 0 then begin
        // Left
        BitBlt(DC, sbw, th, i, Form.Height - sbw, FCommonData.FCacheBmp.Canvas.Handle, OffsetX - Form.BorderWidth, OffsetY, SRCCOPY);
        // Bottom
        BitBlt(DC, sbw + Form.BorderWidth, Form.Height - i - sbw, Form.Width - i - sbw - Form.BorderWidth, i, FCommonData.FCacheBmp.Canvas.Handle, BorderWidth + ShadowSize.Left, FCommonData.FCacheBmp.Height - BorderWidth - ShadowSize.Bottom, SRCCOPY); // Bottom border update
        // Right
        BitBlt(DC, Form.Width - i - sbw, th, i, FCommonData.FCacheBmp.Height - sbw, FCommonData.FCacheBmp.Canvas.Handle, FCommonData.FCacheBmp.Width - BorderWidth - ShadowSize.Right, OffsetY, SRCCOPY); // Right border update
      end;

      if (BorderForm.AForm <> nil) and not IsWindowVisible(BorderForm.AForm.Handle)
        then BorderForm.UpdateExBordersPos; // Additional checking of Extended Border
    end
    else if not HaveBorder(Self) and IsSizeBox(Form.Handle) and not IsIconic(Form.Handle) then begin
      if FCommonData.BGChanged then PaintAll;
      i := BorderWidth + 3;
      BitBlt(DC, 0, 0, Form.Width, i, FCommonData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY); // Title and menu line update
      BitBlt(DC, 0, i, i, FCommonData.FCacheBmp.Height, FCommonData.FCacheBmp.Canvas.Handle, 0, i, SRCCOPY); // Left border update
      BitBlt(DC, i, Form.Height - i, Form.Width - i, i, FCommonData.FCacheBmp.Canvas.Handle, i, Form.Height - i, SRCCOPY); // Bottom border update
      BitBlt(DC, FCommonData.FCacheBmp.Width - i, i, i, FCommonData.FCacheBmp.Height, FCommonData.FCacheBmp.Canvas.Handle, FCommonData.FCacheBmp.Width - i, i, SRCCOPY); // Right border update
    end
    else PaintCaption(DC);
  finally
    RestoreDC(DC, SavedDC);
    ReleaseDC(Form.Handle, DC);
  end;
  RgnChanging := False;
end;

function TsSkinProvider.FormColor: TColor;
begin
  if FCommonData.Skinned and not SkinData.CustomColor
    then Result := iffi(FormActive and (FCommonData.SkinManager.gd[FCommonData.Skinindex].States > 1), FCommonData.SkinManager.gd[FCommonData.Skinindex].HotColor, FCommonData.SkinManager.gd[FCommonData.Skinindex].Color)
    else Result := ColorToRGB(Form.Color);
end;

procedure TsSkinProvider.OurPaintHandler(const Msg: TWMPaint);
var
  SavedDC : hdc;
  PS : TPaintStruct;
begin
  if fAnimating or InAnimationProcess and (Msg.DC = 0) or (csDestroying in Form.ComponentState) then begin
    BeginPaint(Form.Handle, PS);
    EndPaint(Form.Handle, PS);
    Exit;
  end;
  if not InAnimationProcess then BeginPaint(Form.Handle, PS);
  SavedDC := SaveDC(Form.Canvas.Handle);
  try
    Form.Canvas.Lock;
    if Form.Parent <> nil then FCommonData.FUpdating := FCommonData.Updating else FCommonData.FUpdating := False;
    if not ((Form.FormStyle = fsMDIChild) and (MDISkinProvider <> nil) and not MDICreating and
         Assigned(TsSkinProvider(MDISkinProvider).Form.ActiveMDIChild) and (TsSkinProvider(MDISkinProvider).Form.ActiveMDIChild.WindowState = wsMaximized)
           and (Form <> TsSkinProvider(MDISkinProvider).Form.ActiveMDIChild)) then begin
      PaintForm(Form.Canvas.Handle);
    end;
  finally
    Form.Canvas.UnLock;
    RestoreDC(Form.Canvas.Handle, SavedDC);
    Form.Canvas.Handle := 0;
    if not InAnimationProcess then EndPaint(Form.Handle, PS);
  end;
end;

procedure TsSkinProvider.CheckSysMenu(const Skinned: boolean);
begin
  if Skinned then begin
    if (GetWindowLong(Form.Handle, GWL_STYLE) and WS_SYSMENU = WS_SYSMENU) or HaveSysMenu then begin
      if FDrawNonClientArea
        then SetWindowLong(Form.Handle, GWL_STYLE, GetWindowLong(Form.Handle, GWL_STYLE) and not WS_SYSMENU)
        else SetWindowLong(Form.Handle, GWL_STYLE, GetWindowLong(Form.Handle, GWL_STYLE) or WS_SYSMENU);
      HaveSysMenu := True;
    end
    else HaveSysMenu := False;
  end
  else begin
    if HaveSysMenu then SetWindowLong(Form.Handle, GWL_STYLE, GetWindowLong(Form.Handle, GWL_STYLE) or WS_SYSMENU);
    HaveSysMenu := False;
  end;
end;

procedure TsSkinProvider.SetDrawNonClientArea(const Value: boolean);
begin
  if (FDrawNonClientArea <> Value) then begin
    FDrawNonClientArea := Value;
    if (csDesigning in ComponentState) then Exit;
    if Value then begin
      CheckSysMenu(True);

      if not (csDesigning in ComponentState) and (Form <> nil) and Form.Showing and SkinData.Skinned then begin
        SkinData.BGChanged := True;
//        FreeAndNil(TitleBG);
        SkinData.SkinManager.SkinableMenus.InitMenuLine(Form.Menu, True);
        InitExBorders(SkinData.SkinManager.ExtendedBorders);
        RedrawWindow(Form.Handle, nil, 0, RDW_FRAME or RDW_INVALIDATE or RDW_UPDATENOW);
        RefreshFormScrolls(Self, ListSW, False);
      end;
    end
    else begin
      if BorderForm <> nil then FreeAndNil(BorderForm);
      if SkinData.SkinManager <> nil then SkinData.SkinManager.SkinableMenus.InitMenuLine(Form.Menu, False);
      if (uxthemeLib <> 0) then Ac_SetWindowTheme(Form.Handle, nil, nil);
      if ListSW <> nil then FreeAndNil(ListSW);
      if HaveSysMenu then SetWindowLong(Form.Handle, GWL_STYLE, GetWindowLong(Form.Handle, GWL_STYLE) or WS_SYSMENU);
      if Form.Showing then SetWindowRgn(Form.Handle, 0, True);
      if BorderForm <> nil then BorderForm.UpdateExBordersPos;
    end;
  end;
end;

procedure TsSkinProvider.AC_WMNCCalcSize(var Message: TWMNCCalcSize);
begin
{  if Message.CalcValidRects and FDrawNonClientArea and (Form.WindowState = wsMaximized) and (BorderForm <> nil) then begin
    inc(Message.CalcSize_Params.rgrc[0].Top, CaptionHeight(BorderForm = nil) + MenuHeight * LinesCount + BorderHeight(BorderForm = nil));
    inc(Message.CalcSize_Params.rgrc[0].Left, BorderWidth(BorderForm = nil));
    dec(Message.CalcSize_Params.rgrc[0].Right, BorderWidth(BorderForm = nil));
    dec(Message.CalcSize_Params.rgrc[0].Bottom, BorderWidth(BorderForm = nil));
    Message.Result := 0;
  end
  else}
  OldWndProc(TMessage(Message));
end;
(*
procedure TsSkinProvider.AC_NCMouseMove(var Message: TWMMouse);
//var
//  p : TPoint;
//  cy1, cy2 : integer;
begin
  p := CursorToPoint(Message.XPos, Message.YPos);
  cy1 := CaptionHeight(False) + SysBorderHeight(False);
  cy2 := cy1 + MenuHeight;
  if Between(p.Y, cy1, cy2)
    then inc(Message.YPos, SkinMenuOffset(Self).Y) {???}
    else begin
{    cy1 := CaptionHeight(False) + SysBorderHeight(False);
    cy2 := cy1 + MenuHeight;
    if Between(p.Y, cy1, cy2)
      then dec(Message.YPos, 12);}
  end;
  OldWndProc(TMessage(Message));
end;

procedure TsSkinProvider.AC_WMDrawItem(var Message: TWMDrawItem);
begin
  case Message.DrawItemStruct^.CtlType of
    ODT_MENU : begin
      if (Form.Menu <> nil) and (Message.DrawItemStruct^.itemState and ODS_SELECTED = ODS_SELECTED) then begin
    //    OffsetRect(Message.DrawItemStruct^.rcItem, SkinMenuOffset(Self).X, SkinMenuOffset(Self).Y);
        OldWndProc(TMessage(Message))
      end
      else OldWndProc(TMessage(Message))
    end
    else OldWndProc(TMessage(Message))
  end;
end;
*)

procedure TsSkinProvider.AC_WMInitMenuPopup(var Message: TWMInitMenuPopup);
var
  c, i : integer;
  TmpItem : TMenuItem;
  s : AcString;
  sCut : String;
  mi : TMenuItemInfo;
  function GetItemText(ID : Cardinal; var Caption : acString; var ShortCut : String; uFlag : Cardinal) : boolean;
  var
    Text: array[0..MaxByte] of acChar;
  begin
{$IFDEF TNTUNICODE}
    Result := GetMenuStringW(Message.MenuPopup, ID, Text, MaxByte, uFlag) <> 0;
{$ELSE}
    Result := GetMenuString(Message.MenuPopup, ID, Text, MaxByte, uFlag) <> 0;
{$ENDIF}
  end;
begin
  if Message.SystemMenu then begin
    EnableMenuItem(Message.MenuPopup, SC_SIZE, MF_BYCOMMAND or MF_GRAYED);
  end
  else acCanHookMenu := False; // Menu skinning is supported

  /////////////////////
  if (Form.FormStyle = fsMDIForm) and (Form.MDIChildCount > 0) and (Form.WindowMenu <> nil) then begin
    if Form.WindowMenu.Handle = Message.MenuPopup then begin
      // Clear old items
      i := Form.WindowMenu.Count - 1;
      while i >= 0 do begin
        if Form.WindowMenu.Items[i].Tag and $200 = $200 then Form.WindowMenu.Delete(i);
        dec(i);
      end;
      c := GetMenuItemCount(Message.MenuPopup);
      i := c;
      while i >= 0 do begin
        if GetItemText(i, s, sCut, MF_BYPOSITION) then begin
          RemoveMenu(Message.MenuPopup, i, MF_BYPOSITION);
          dec(i);
          Continue;
        end;
        mi.cbSize := SizeOf(mi);
        mi.fMask := MIIM_STATE or MIIM_DATA or MIIM_FTYPE;
        if GetMenuItemInfo(Message.MenuPopup, i, True, mi) then begin
          if (mi.dwItemData = 0) and (mi.fType and MF_SEPARATOR = MF_SEPARATOR) then RemoveMenu(Message.MenuPopup, i, MF_BYPOSITION);
        end;
        dec(i);
      end;
      if Form.WindowMenu.Items[Form.WindowMenu.Count - 1].Caption <> '-' then begin
        TmpItem := TMenuItem.Create(Self);
        TmpItem.Caption := '-';
        Form.WindowMenu.Add(TmpItem);
      end;
      for i := 0 to Form.MDIChildCount - 1 do begin
        TmpItem := TMenuItem.Create(Self);
        TmpItem.Caption := Form.MDIChildren[i].Caption;
        TmpItem.OnClick := OnChildMnuClick;
        TmpItem.Tag := i;
        if Form.MDIChildren[i] = Form.ActiveMDIChild then TmpItem.Checked := True;
        TmpItem.Tag := TmpItem.Tag or $200;
        Form.WindowMenu.Add(TmpItem);
      end;
    end;
    Message.Result := 0;
  end
  else OldWndProc(TMessage(Message));
  /////////////////////
end;

procedure TsSkinProvider.InitExBorders(const Active : boolean);
begin
  if Active and HaveBorder(Self) and DrawNonClientArea and (Form.Parent = nil) and (Form.FormStyle <> fsMDIChild) and FAllowExtBorders then begin
    if BorderForm = nil then begin
      BorderForm := TacBorderForm.Create(Self);
      BorderForm.SkinData := FCommonData;
      FCommonData.BGChanged := True;
      BorderForm.UpdateExBordersPos;
    end;
  end
  else begin
    if BorderForm <> nil then FreeAndNil(BorderForm);
  end;
end;

procedure TsSkinProvider.AC_WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo);
var
  R : TRect;
  sbwf, addY, cw : integer;
begin
  if FDrawNonClientArea and (Form.BorderStyle <> bsNone) and (Form.FormStyle <> fsMDIChild) and (Form.Parent = nil) then begin
    R := acWorkRect(Form);
    sbwf := SysBorderWidth(Form.Handle, nil, False); // Standard border width
    if BorderForm <> nil then begin
      if ((GetWindowLong(Form.Handle, GWL_STYLE) and WS_CAPTION = WS_CAPTION)) then begin // If for caption is visible
        if IsZoomed(Form.Handle) then begin
          if SkinData.SkinManager.SkinData.ExMaxHeight <> 0 then cw := SkinData.SkinManager.SkinData.ExMaxHeight else cw := SkinData.SkinManager.SkinData.ExTitleHeight;
          if cw < SysCaptHeight(Form) + 4 then FSysExHeight := True else FSysExHeight := False;
        end
        else FSysExHeight := False;
        addY := MaxBtnOffset(Self);
      end else addY := 0;
    end
    else addY := 0;
    Message.MinMaxInfo^.ptMaxPosition.Y := - sbwf - addY;
    Message.MinMaxInfo^.ptMaxPosition.X := -sbwf;

    sbwf := sbwf * 2;
    Message.MinMaxInfo^.ptMaxSize.X := WidthOf(R) + sbwf;
    Message.MinMaxInfo^.ptMaxSize.Y := HeightOf(R) + sbwf + addY;

    Message.Result := 0;
  end;
  OldWndProc(TMessage(Message));
end;

function TsSkinProvider.ShadowSize: TRect;
begin
  if BorderForm <> nil then Result := SkinData.SkinManager.FormShadowSize else Result := Rect(0, 0, 0, 0);
end;

procedure TsSkinProvider.KillAnimations;
var
  i : integer;
begin
  if ButtonMin.Timer <> nil then FreeAndNil(ButtonMin.Timer);
  if ButtonMax.Timer <> nil then FreeAndNil(ButtonMax.Timer);
  if ButtonClose.Timer <> nil then FreeAndNil(ButtonClose.Timer);
  if ButtonHelp.Timer <> nil then FreeAndNil(ButtonHelp.Timer);

  for i := 0 to TitleButtons.Count - 1 do begin
    if TitleButtons[i].BtnData.Timer <> nil then FreeAndNil(TitleButtons[i].BtnData.Timer);
  end;
end;

procedure TsSkinProvider.SetAllowExtBorders(const Value: boolean);
begin
  if FAllowExtBorders <> Value then begin
    FAllowExtBorders := Value;
    if not (csLoading in ComponentState) then begin
      InitExBorders(True);
      FCommonData.BGChanged := True;
      RedrawWindow(Form.Handle, nil, 0, RDW_FRAME or RDW_INVALIDATE);
    end;
  end;
end;

procedure TsSkinProvider.AssignTo(Dest: TPersistent);
begin
  inherited;
end;

function TsSkinProvider.TitleSkinIndex: integer;
begin
  if FTitleSkinIndex <> -1 then begin
    Result := FTitleSkinIndex
  end
  else begin
    Result := FCommonData.SkinManager.GetSkinIndex(TitleSkinSection);
    FTitleSkinIndex := Result;
  end;
end;

{$IFNDEF ALITE}

var
  bacWheelFlag : boolean = False;

function FindScrollBox(Ctrl : TWinControl; ScrPoint : TPoint) : TsScrollBox;
var
  p : TPoint;
  c : TControl;
begin
  p := Ctrl.ScreenToClient(ScrPoint);
  c := Ctrl.ControlAtPos(p, false, true);
  if (c <> nil) and (c is TWinControl) then begin
    if (c is TsScrollBox) then Result := TsScrollBox(c) else Result := FindScrollBox(TWinControl(c), ScrPoint);
  end
  else Result := nil;
end;

procedure TsSkinProvider.AC_CMMouseWheel(var Message: TCMMouseWheel);
var
  sb : TsScrollBox;
begin
  if not bacWheelFlag then begin
    bacWheelFlag := True;
    if Message.Result = 0 then begin
      sb := FindScrollBox(Form, acMousePos);
      if (sb <> nil) and sb.AutoMouseWheel then Message.Result := integer(sb.DoMouseWheel(Message.ShiftState, Message.WheelDelta, SmallPointToPoint(TCMMouseWheel(Message).Pos)));
    end;
    bacWheelFlag := False;
  end;
end;
{$ENDIF}

constructor TsSkinProvider.CreateRT(AOwner: TComponent; InitRT : boolean = True);
begin
  Create(AOwner);
  RTInit := True;
end;

procedure TsSkinProvider.LoadInit;
var
  mi, i : integer;
begin
  if Form.HandleAllocated then InitDwm(Form.Handle, True);
  PrepareForm;
  if Adapter = nil then AdapterCreate;
  if Assigned(SystemMenu) then SystemMenu.UpdateItems;

  mi := FCommonData.SkinManager.GetMaskIndex(FCommonData.SkinManager.ConstData.IndexGLobalInfo, s_GlobalInfo, s_TitleButtonMask);
  for i := 0 to TitleButtons.Count - 1 do
    if TitleButtons.Items[i].UseSkinData
      then TitleButtons.Items[i].BtnData.ImageIndex := mi
      else TitleButtons.Items[i].BtnData.ImageIndex := -1;

  if Assigned(MDIForm) then begin
    TsMDIForm(MDIForm).ConnectToClient;
  end;
  if (Form.BorderStyle = bsSizeToolWin) then begin
    AllowBlendOnMoving := False; // Not use for dock windows
    UseGlobalColor := True;
  end;
end;

procedure TsSkinProvider.OnChildMnuClick(Sender: TObject);
var
  i : integer;
begin
  i := TMenuItem(Sender).Tag and not $200;
  if i < Form.MDIChildCount then Form.MDIChildren[i].BringToFront;
end;

{ TsSystemMenu }

procedure TsSystemMenu.CloseClick(Sender: TObject);
begin
  Sendmessage(FForm.Handle, WM_SYSCOMMAND, SC_CLOSE, 0);
end;

constructor TsSystemMenu.Create(AOwner: TComponent);
begin
  FOwner := TsSkinProvider(AOwner);

  FForm := FOwner.Form;
  inherited Create(AOwner);
  Name := s_SysMenu;
  Generate
end;

function TsSystemMenu.EnabledMax: boolean;
begin
  Result := ((TForm(FForm).FormStyle = fsMDIChild) or ((FForm.WindowState <> wsMaximized) and (FForm.BorderStyle in [bsSingle, bsSizeable]))) and
      (biMaximize in FOwner.Form.BorderIcons);
end;

function TsSystemMenu.EnabledMin: boolean;
begin
  Result := (biMinimize in FOwner.Form.BorderIcons) and not IsIconic(FForm.Handle);// (FForm.WindowState <> wsMinimized);
end;

function TsSystemMenu.EnabledMove: boolean;
begin
  Result := (FForm.WindowState <> wsMaximized);
end;

function TsSystemMenu.EnabledRestore: boolean;
begin
  Result := ((biMaximize in FOwner.Form.BorderIcons) and (FForm.WindowState <> wsNormal)) or
    (FForm.WindowState = wsMinimized);
end;

function TsSystemMenu.EnabledSize: boolean;
begin
  Result := (FForm.BorderStyle <> bsSingle) and not IsIconic(FForm.Handle);
end;

procedure TsSystemMenu.ExtClick(Sender: TObject);
begin
  PostMessage(FForm.Handle, WM_SYSCOMMAND, TComponent(Sender).Tag, 0);
end;

procedure TsSystemMenu.Generate;
var
  Menu : HMENU;
  i : integer;
  j : UINT;
  s : acString;
  sCut : string;
  TmpItem : TMenuItem;
  function CreateSystemItem(const Caption : acString; const Name : string; EventProc : TNotifyEvent) : TMenuItem; begin
{$IFDEF TNTUNICODE}
    Result := TTntMenuItem.Create(Self);
{$ELSE}
    Result := TMenuItem.Create(Self);
{$ENDIF}
    Result.Caption := Caption;
    Result.OnClick := EventProc;
    Result.Name := Name;
  end;
  function GetItemText(ID : Cardinal; var Caption : acString; var ShortCut : String; uFlag : Cardinal) : boolean;
  var
    Text: array[0..MaxByte] of acChar;
{$IFDEF TNTUNICODE}
    ws : WideString;
{$ENDIF}
    P : integer;
  begin
{$IFDEF TNTUNICODE}
    Result := GetMenuStringW(Menu, ID, Text, MaxByte, uFlag) <> 0;
{$ELSE}
    Result := GetMenuString(Menu, ID, Text, MaxByte, uFlag) <> 0;
{$ENDIF}
    if Result then begin
      P := Pos(#9, Text);
      if P = 0 then ShortCut := '' else begin
        ShortCut := Copy(Text, P + 1, Length(Text) - P);
{$IFDEF TNTUNICODE}
        ws := Text;
        ws := Copy(ws, 1, P - 1);
        Caption := ws;
        Exit;
{$ELSE}
        StrLCopy(Text, Text, P - 1);
{$ENDIF}
      end;
      Caption := Text;
    end;
  end;
begin
  Items.Clear;
  ExtItemsCount := 0;
  Menu := GetSystemMenu(FForm.Handle, False);

  if Menu = 0 then Exit;

  if not GetItemText(SC_RESTORE, s, sCut, MF_BYCOMMAND) then s := acs_RestoreStr;
  ItemRestore := CreateSystemItem(s, 'acIR', RestoreClick);
  ItemRestore.Tag := SC_RESTORE;
  Self.Items.Add(ItemRestore);

  if not GetItemText(SC_MOVE, s, sCut, MF_BYCOMMAND) then s := acs_MoveStr;
  ItemMove := CreateSystemItem(s, 'acIM', MoveClick);
  Self.Items.Add(ItemMove);
  ItemMove.Tag := SC_MOVE;

  if not GetItemText(SC_SIZE, s, sCut, MF_BYCOMMAND) then s := acs_SizeStr;
  ItemSize := CreateSystemItem(s, 'acIS', SizeClick);
  Self.Items.Add(ItemSize);
  ItemSize.Tag := SC_SIZE;

  if not GetItemText(SC_MINIMIZE, s, sCut, MF_BYCOMMAND) then s := acs_MinimizeStr;
  ItemMinimize := CreateSystemItem(s, 'acIN', MinClick);
  Self.Items.Add(ItemMinimize);
  ItemMinimize.Tag := SC_MINIMIZE;

  if not GetItemText(SC_MAXIMIZE, s, sCut, MF_BYCOMMAND) then s := acs_MaximizeStr;
  ItemMaximize := CreateSystemItem(s, 'acIX', MaxClick);
  Self.Items.Add(ItemMaximize);
  ItemMaximize.Tag := SC_MAXIMIZE;

  Self.Items.InsertNewLineAfter(ItemMaximize);

  TmpItem := nil;
  for i := 0 to GetMenuItemCount(Menu) - 1 do begin
    j := GetMenuItemID(Menu, i);
    if (j < $F000) and GetItemText(i, s, sCut, MF_BYPOSITION) then begin // If some external menuitems are exists
{$IFDEF TNTUNICODE}
      TmpItem := TTntMenuItem.Create(Self);
{$ELSE}
      TmpItem := TMenuItem.Create(Self);
{$ENDIF}
      TmpItem.Caption := s;
      TmpItem.Tag := LongInt(j);
      if sCut <> '' then TmpItem.ShortCut := TextToShortCut(sCut);
      TmpItem.OnClick := ExtClick;
      Self.Items.Add(TmpItem);
      inc(ExtItemsCount);
    end;
  end;
  if ExtItemsCount > 0 then Self.Items.InsertNewLineAfter(TmpItem);

  if not GetItemText(SC_CLOSE, s, sCut, MF_BYCOMMAND) then s := acs_CloseStr;
  ItemClose := CreateSystemItem(s, 'acIC', CloseClick);
  if sCut <> '' then ItemClose.ShortCut := TextToShortCut(sCut);
  Self.Items.Add(ItemClose);
  ItemClose.Tag := SC_CLOSE;
end;

procedure TsSystemMenu.MakeSkinItems;
var
  sl : TacStringList;
  i : integer;
  SkinItem, TempItem : TMenuItem;
begin
  if Assigned(FOwner.SkinData.SkinManager) then begin
    sl := TacStringList.Create;
    FOwner.SkinData.SkinManager.GetSkinNames(sl);

    if sl.Count > 0 then begin
{$IFDEF TNTUNICODE}
      SkinItem := TTntMenuItem.Create(Self);
{$ELSE}
      SkinItem := TMenuItem.Create(Self);
{$ENDIF}
      SkinItem.Caption := acs_AvailSkins;
      SkinItem.Name := s_SkinSelectItemName;
      Self.Items.Insert(0, SkinItem);
      Self.Items.InsertNewLineAfter(SkinItem);
      for i := 0 to sl.Count - 1 do begin
{$IFDEF TNTUNICODE}
        TempItem := TTntMenuItem.Create(Self);
{$ELSE}
        TempItem := TMenuItem.Create(Self);
{$ENDIF}
        TempItem.Caption := sl[i];
        TempItem.OnClick := SkinSelect;
        TempItem.Name := s_SkinSelectItemName + IntToStr(i);
        TempItem.RadioItem := True;
        if TempItem.Caption = FOwner.SkinData.SkinManager.SkinName then TempItem.Checked := True;
        if (i <> 0) and (i mod 20 = 0) then TempItem.Break := mbBreak;
        SkinItem.Add(TempItem);
      end;
    end;
    FreeAndNil(sl);
  end;
end;

procedure TsSystemMenu.MaxClick(Sender: TObject);
begin
  Sendmessage(FForm.Handle, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
  UpdateItems;
end;

procedure TsSystemMenu.MinClick(Sender: TObject);
begin
  FOwner.SkipAnimation := True;
  SendMessage(FOwner.Form.Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
  FOwner.SkipAnimation := False;
  FOwner.SystemMenu.UpdateItems;
end;

procedure TsSystemMenu.MoveClick(Sender: TObject);
begin
  Sendmessage(FForm.Handle, WM_SYSCOMMAND, SC_MOVE, 0);
end;

procedure TsSystemMenu.RestoreClick(Sender: TObject);
begin
  Sendmessage(FForm.Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
  UpdateItems;
end;

procedure TsSystemMenu.SizeClick(Sender: TObject);
begin
  Sendmessage(FForm.Handle, WM_SYSCOMMAND, SC_SIZE, 0);
end;

procedure TsSystemMenu.SkinSelect(Sender: TObject);
var
  sSkinName, sInternalSkin : String;
  iIndex : Integer;
begin
  if Assigned(FOwner.SkinData.SkinManager) then begin
    sSkinName := DelChars(TMenuItem(Sender).Caption, '&');
    sInternalSkin := acs_InternalSkin;
    iIndex := Pos(sInternalSkin, sSkinName);
    if iIndex > 0 then begin
      sSkinName := Copy(sSkinName, 1, iIndex - 1 + Length(sInternalSkin));
    end;
    FOwner.SkinData.SkinManager.SkinName := sSkinName;
  end;
end;

procedure TsSystemMenu.UpdateGlyphs;
begin
// 
end;

procedure TsSystemMenu.UpdateItems(Full : boolean = False);
begin
  if Full or (ItemClose = nil) then begin
    Generate;
  end;
  if Assigned(Self) and Assigned(FForm) then begin
    if ItemRestore <> nil then begin
      ItemRestore.Visible := VisibleRestore;
      ItemRestore.Enabled := EnabledRestore;
    end;
    if ItemMove <> nil then begin
      ItemMove.Visible := True;
      ItemMove.Enabled := EnabledMove;
    end;
    if ItemSize <> nil then begin
      ItemSize.Visible := VisibleSize;
      ItemSize.Enabled := EnabledSize;
    end;
    if ItemMinimize <> nil then begin
      ItemMinimize.Visible := VisibleMin;
      ItemMinimize.Enabled := EnabledMin;
    end;
    if ItemMaximize <> nil then begin
      ItemMaximize.Visible := VisibleMax;
      ItemMaximize.Enabled := EnabledMax;
    end;
    if ItemClose <> nil then begin
      ItemClose.Visible := VisibleClose;
      ItemClose.Enabled := True;
    end;
  end;
end;

function TsSystemMenu.VisibleClose: boolean;
begin
  Result := FOwner.HaveSysMenu;
end;

function TsSystemMenu.VisibleMax: boolean;
begin
  Result := False;
  if (Self = nil) or not VisibleClose then Exit;

  Result := IsIconic(Self.FForm.Handle) or (TForm(FForm).FormStyle = fsMDIChild) or
    ((FForm.BorderStyle <> bsDialog) and
    ((FForm.BorderStyle <> bsSingle) or (biMaximize in FOwner.Form.BorderIcons)) and
    (FForm.BorderStyle <> bsNone) and
    (FForm.BorderStyle <> bsSizeToolWin) and
    (FForm.BorderStyle <> bsToolWindow) and VisibleClose) and (biMaximize in FOwner.Form.BorderIcons);
end;

function TsSystemMenu.VisibleMin: boolean;
begin
  Result := False;
  if (Self = nil) or not VisibleClose then Exit;
  if IsIconic(FForm.Handle) or (TForm(FForm).FormStyle = fsMDIChild) then begin
    Result := True
  end
  else begin
    Result :=
      (FForm.BorderStyle <> bsDialog) and
      (FForm.BorderStyle <> bsNone) and
      ((FForm.BorderStyle <> bsSingle) or (biMinimize in FOwner.Form.BorderIcons)) and
      (FForm.BorderStyle <> bsSizeToolWin) and
      (FForm.BorderStyle <> bsToolWindow) and (biMinimize in FOwner.Form.BorderIcons) and VisibleClose;
  end;
end;

function TsSystemMenu.VisibleRestore: boolean;
begin
  Result := False;
  if (Self = nil) or not VisibleClose then Exit;
  Result := (TForm(FForm).FormStyle = fsMDIChild) or
    ((FForm.BorderStyle <> bsDialog) and
    (FForm.BorderStyle <> bsNone) and
    (FForm.BorderStyle <> bsSizeToolWin) and
    (FForm.BorderStyle <> bsToolWindow)) and VisibleClose;
end;

function TsSystemMenu.VisibleSize: boolean;
begin
  Result := False;
  if Self = nil then Exit;
  Result := (TForm(FForm).FormStyle = fsMDIChild) or
    ((FForm.BorderStyle <> bsDialog) and
    (FForm.BorderStyle <> bsNone) and
    (FForm.BorderStyle <> bsToolWindow));
end;

{ TsTitleIcon }

constructor TsTitleIcon.Create;
begin
  FGlyph := TBitmap.Create;
  FHeight := 0;
  FWidth := 0;
end;

destructor TsTitleIcon.Destroy;
begin
  FreeAndNil(FGlyph);
  inherited Destroy; 
end;

procedure TsTitleIcon.SetGlyph(const Value: TBitmap);
begin
  FGlyph.Assign(Value);
end;

procedure TsTitleIcon.SetHeight(const Value: integer);
begin
  FHeight := Value;
end;

procedure TsTitleIcon.SetWidth(const Value: integer);
begin
  FWidth := Value;
end;

{ TsTitleButtons }

constructor TsTitleButtons.Create(AOwner: TsSkinProvider);
begin
  inherited Create(TsTitleButton);
  FOwner := AOwner;
end;

destructor TsTitleButtons.Destroy;
begin
  FOwner := nil;
  inherited Destroy;
end;

function TsTitleButtons.GetItem(Index: Integer): TsTitleButton;
begin
  Result := TsTitleButton(inherited GetItem(Index))
end;

function TsTitleButtons.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TsTitleButtons.SetItem(Index: Integer; Value: TsTitleButton);
begin
  inherited SetItem(Index, Value);
end;

procedure TsTitleButtons.Update(Item: TCollectionItem);
begin
  inherited;
end;

{ TsTitleButton }

procedure TsTitleButton.AssignTo(Dest: TPersistent);
begin
  if Dest = nil then inherited else begin
    TsTitleButton(Dest).Enabled := Enabled;
    TsTitleButton(Dest).Glyph := Glyph;
    TsTitleButton(Dest).Hint := Hint;
    TsTitleButton(Dest).Name := Name;
    TsTitleButton(Dest).UseSkinData := UseSkinData;
    TsTitleButton(Dest).OnMouseDown := OnMouseDown;
    TsTitleButton(Dest).OnMouseUp := OnMouseUp;
  end;
end;

constructor TsTitleButton.Create(Collection: TCollection);
begin
  FGlyph := TBitmap.Create;
  FGlyph.OnChange := OnGlyphChange;
  FUseSkinData := True;
  FEnabled := True;
  FVisible := True;
  HintWnd := nil;
  inherited Create(Collection);
  if FName = '' then FName := ClassName;
end;

destructor TsTitleButton.Destroy;
begin
  if BtnData.Timer <> nil then FreeAndNil(BtnData.Timer);
  FreeAndNil(FGlyph);
  if HintWnd <> nil then FreeAndNil(HintWnd);
  inherited Destroy;
end;

function TsTitleButton.GetDisplayName: string;
begin
  Result := Name;
end;

procedure TsTitleButton.MouseDown(BtnIndex : integer; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseDown) then FOnMouseDown(Self, Button, Shift, X, Y);
end;

procedure TsTitleButton.MouseUp(BtnIndex : integer; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseUp) then FOnMouseUp(Self, Button, Shift, X, Y);
end;

procedure TsTitleButton.OnGlyphChange(Sender: TObject);
begin
  if BtnData.Timer <> nil then FreeAndNil(BtnData.Timer);
end;

procedure TsTitleButton.SetGlyph(const Value: TBitmap);
begin
  FGlyph.Assign(Value);
end;

procedure TsTitleButton.SetName(const Value: string);
begin
  if FName <> Value then FName := Value;
end;

procedure TsTitleButton.SetVisible(const Value: boolean);
begin
  if FVisible <> Value then begin
    FVisible := Value;
    UpdateSkinCaption(TsTitleButtons(Collection).FOwner);
  end
end;

{ TacCtrlAdapter }

procedure TacCtrlAdapter.AddNewItem(const Ctrl: TWinControl);
begin
  AddNewItem(Ctrl, DefaultSection);
end;

procedure TacCtrlAdapter.AddNewItem(const Ctrl: TWinControl; const SkinSection: string);
var
  i, Index, l : integer;
  Found : boolean;
  CanAdd : boolean;
  s : string;
begin
  if (Ctrl = nil) or (Ctrl.Tag = ExceptTag) or (Ctrl.Parent = nil) or GetBoolMsg(Ctrl, AC_CTRLHANDLED) then Exit;
  CanAdd := True;
  s := SkinSection;
  if Assigned(Provider.OnSkinItem) then Provider.FOnSkinItem(Ctrl, CanAdd, s);
  if not CanAdd then Exit;

  if Ctrl is TFrame then begin
{$IFNDEF ALITE}
    with TsFrameAdapter.Create(Ctrl) do SkinData.SkinSection := s_GroupBox;
{$ENDIF}
    Exit;
  end;

  Index := -1;
  l := Length(Items);
  Found := False;
  for i := 0 to l - 1 do if (Items[i].WinCtrl = Ctrl) then begin // If added in list already, then go to Exit
    Index := i;
    Found := True;
    Break;
  end;
  if Index = -1 then begin
    SetLength(Items, l + 1);
    l := Length(Items);
    Index := l - 1;
    Items[Index] := TacAdapterItem.Create;
    Items[Index].Adapter := Self;
    Items[Index].WinCtrl := Ctrl;
  end;
  Items[Index].SkinData.SkinSection := s;
  if Found and Assigned(Items[Index].ScrollWnd) and Items[Index].ScrollWnd.Destroyed then begin
    FreeAndNil(Items[Index].ScrollWnd);
    if (Items[Index].WinCtrl.Parent <> nil) then Items[Index].DoHook(Ctrl);
  end
  else if not Found then begin
    if (Items[Index].WinCtrl.Parent <> nil) then Items[Index].DoHook(Ctrl);
    if Items[Index].ScrollWnd = nil then begin
      FreeAndNil(Items[Index]);
      SetLength(Items, Index);
    end;
  end;
end;

procedure TacCtrlAdapter.AddNewItem(const Ctrl: TSpeedButton);
var
  i, Index, l : integer;
  Found : boolean;
  CanAdd : boolean;
  s : string;
begin
  if (Ctrl = nil) or (Ctrl.Tag = ExceptTag) or (Ctrl.Parent = nil) or (SendAMessage(Ctrl, AC_CTRLHANDLED) = 1) then Exit;
  CanAdd := True;
  s := s_SpeedButton;
  if Assigned(Provider.OnSkinItem) then Provider.FOnSkinItem(Ctrl, CanAdd, s);
  if CanAdd then begin
    Index := -1;
    l := Length(GraphItems);
    Found := False;

    for i := 0 to l - 1 do if (GraphItems[i].Ctrl = Ctrl) then begin // If added in list already, then go to Exit
      Index := i;
      Found := True;
      Break;
    end;
    if Index = -1 then begin
      SetLength(GraphItems, l + 1);
      l := Length(GraphItems);
      Index := l - 1;
      GraphItems[Index] := TacGraphItem.Create;
      GraphItems[Index].Adapter := Self;
      GraphItems[Index].Ctrl := Ctrl;
    end;
    if Ctrl.Flat then GraphItems[Index].SkinData.SkinSection := s_SpeedButton_Small else GraphItems[Index].SkinData.SkinSection := s_SpeedButton;
    if Found and Assigned(GraphItems[Index].Handler) and GraphItems[Index].Handler.Destroyed then begin
      FreeAndNil(GraphItems[Index].Handler);
      GraphItems[Index].DoHook(Ctrl);
    end
    else if not Found then begin
      if (GraphItems[Index].Ctrl.Parent <> nil) then GraphItems[Index].DoHook(Ctrl);
      if GraphItems[Index].Handler = nil then begin
        FreeAndNil(GraphItems[Index]);
        SetLength(GraphItems, Index);
      end;
    end;
  end;
end;

procedure TacCtrlAdapter.AddAllItems(OwnerCtrl : TWinControl = nil);// CheckHandle : boolean = True);
var
  i : integer;
  sSection : string;
  Owner : TWinControl;
begin
{.$IFDEF CHECKXP
  Provider.StdBgIsUsed := False;
  for i := 0 to Provider.Form.ControlCount - 1 do if (Provider.Form.Controls[i] is TWinControl) and TacAccessWinCtrl(Provider.Form.Controls[i]).ParentBackground then begin
    Provider.StdBgIsUsed := True;
    Break
  end;
$ENDIF}
  if not bFlag and (srThirdParty in Provider.SkinData.SkinManager.SkinningRules) then begin
    bFlag := True;
    if OwnerCtrl = nil then Owner := Provider.Form else Owner := OwnerCtrl;
    if Owner <> nil then begin
      CleanItems;
      for i := 0 to Owner.ComponentCount - 1 do begin
        if IsControlSupported(Owner.Components[i]) then begin
          if (Owner.Components[i] is TWinControl) then begin
            sSection := '';//s_Edit;
            AddNewItem(TWinControl(Owner.Components[i]), sSection);
          end
          else if (Owner.Components[i] is TCustomLabel) and not (Owner.Components[i] is TsCustomLabel) and (Owner.Components[i].Tag <> -ExceptTag) then begin
//            TLabel(Owner.Components[i]).Transparent := True;
            TLabel(Owner.Components[i]).ControlStyle := TLabel(Owner.Components[i]).ControlStyle - [csOpaque];
            TLabel(Owner.Components[i]).Font.Color := DefaultManager.GetGlobalFontColor;
          end;
        end;
        if (Owner.Components[i] is TWinControl) then begin
          if TWinControl(Owner.Components[i]).HandleAllocated then begin
            if (TWinControl(Owner.Components[i]).Parent <> nil) then begin
              bFlag := False;
              AddAllItems(TWinControl(Owner.Components[i])); // Recursion
            end;
          end;
        end;
      end;
      for i := 0 to Owner.ControlCount - 1 do begin
        if IsControlSupported(Owner.Controls[i]) then begin
          if (Owner.Controls[i] is TWinControl) then begin
            sSection := '';
            AddNewItem(TWinControl(Owner.Controls[i]), sSection);
          end
          else if (Owner.Controls[i] is TLabel) then begin
            TLabel(Owner.Controls[i]).ControlStyle := TLabel(Owner.Controls[i]).ControlStyle - [csOpaque];
            TLabel(Owner.Controls[i]).Font.Color := DefaultManager.GetGlobalFontColor;
          end
          else if (Owner.Controls[i] is TSpeedButton) then begin
            AddNewItem(TSpeedButton(Owner.Controls[i]));
          end
        end;
        if (Owner.Controls[i] is TWinControl) then begin
          if TWinControl(Owner.Controls[i]).HandleAllocated then begin
            if (TWinControl(Owner.Controls[i]).Parent <> nil) then begin
              bFlag := False;
              AddAllItems(TWinControl(Owner.Controls[i])); // Recursion
            end
          end;
        end;
      end;
    end;
    bFlag := False;
  end;
end;

function TacCtrlAdapter.Count: integer;
begin
  Result := Length(Items);
end;

destructor TacCtrlAdapter.Destroy;
begin
  CleanItems;
  RemoveAllItems;
  inherited Destroy;
end;

function TacCtrlAdapter.GetCommonData(Index: integer): TsCommonData;
begin
  Result := nil;
end;

function TacCtrlAdapter.GetItem(Index: integer) : TacAdapterItem;
begin
  if (Index > -1) and (Index < Count) then Result := Items[Index] else Result := nil;
end;

function TacCtrlAdapter.IndexOf(Ctrl : TWinControl): integer;
var
  i : integer;
begin
  Result := -1;
  for i := 0 to Length(Items) - 1 do if Items[i].WinCtrl = Ctrl then begin
    Result := i;
    Exit;
  end;
end;

procedure TacCtrlAdapter.RemoveItem(Index: integer);
var
  l : integer;
begin
  l := Count;
  if (Index < l) and (l > 0) then begin
    if Items[Index] <> nil then FreeAndNil(Items[Index]);
    Items[Index] := Items[l - 1];
    SetLength(Items, l - 1);
  end;
end;

function TacCtrlAdapter.IsControlSupported(Control: TComponent): boolean;
var
  i, j : integer;
  CanAdd : boolean;
  s : string;
begin
  Result := False;
  if (Control.Tag = ExceptTag) or ((Control is TWinControl) and not CtrlIsReadyForHook(TWinControl(Control))) then Exit;

  if (Control is TWinControl) and GetBoolMsg(TWinControl(Control), AC_CTRLHANDLED) then Exit else begin
    if not (Control is TGraphicControl) then begin
      if Control is TFrame then begin
        CanAdd := True;
        s := '';
        if Assigned(Provider.OnSkinItem) then Provider.FOnSkinItem(Control, CanAdd, s);
        Result := CanAdd;
        Exit;
      end
      else for j := 0 to Length(Provider.SkinData.SkinManager.ThirdLists) - 1 do begin
        for i := 0 to Provider.SkinData.SkinManager.ThirdLists[j].Count - 1 do if Provider.SkinData.SkinManager.ThirdLists[j][i] = Control.ClassName then begin
          Result := True;
          Exit;
        end;
      end;
    end
    else if (Control is TCustomLabel) then begin
      CanAdd := True;
      s := '';
      if Assigned(Provider.OnSkinItem) then Provider.FOnSkinItem(Control, CanAdd, s);
      Result := CanAdd;
      Exit;
    end
    else if (Control is TSpeedButton) then begin
      // Search if control exists in the List of supported
      for j := 0 to Length(Provider.SkinData.SkinManager.ThirdLists) - 1 do begin
        for i := 0 to Provider.SkinData.SkinManager.ThirdLists[j].Count - 1 do begin
          s := Provider.SkinData.SkinManager.ThirdLists[j][i];
          if s = Control.ClassName then begin
            CanAdd := True;
            s := '';
            if Assigned(Provider.OnSkinItem) then Provider.FOnSkinItem(Control, CanAdd, s);
            Result := CanAdd;
            Exit;
          end;
        end;
      end;
    end
  end;
end;

procedure TacCtrlAdapter.RemoveAllItems;
var
  l : integer;
begin
  if bRemoving then Exit;
  bRemoving := True;
  while Length(Items) > 0 do begin
    l := Length(Items);
    FreeAndNil(Items[l - 1]);
    SetLength(Items, l - 1);
  end;
  while Length(GraphItems) > 0 do begin
    l := Length(GraphItems);
    FreeAndNil(GraphItems[l - 1]);
    SetLength(GraphItems, l - 1);
  end;
  bRemoving := False;
end;

procedure TacCtrlAdapter.WndProc(var Message: TMessage);
var
  i, l : integer;
begin
  l := Length(Items) - 1;
  for i := 0 to l do if (Items[i].ScrollWnd <> nil) and not Items[i].ScrollWnd.Destroyed then begin
    if (Items[i].WinCtrl.Parent <> nil) then SendMessage(Items[i].WinCtrl.Handle, Message.Msg, Message.WParam, Message.LParam)
  end;
{ // Not used for TSpeedButton because we not know control exists still or not (we haven't a message about control destroying) // }
end;

procedure TacCtrlAdapter.AfterConstruction;
begin
  inherited;
end;

constructor TacCtrlAdapter.Create(AProvider: TsSkinProvider);
begin
  Provider := AProvider;
  Items := nil;
end;

procedure TacCtrlAdapter.CleanItems;
var
  i, j : integer;
begin
  i := 0;
  while i < Length(Items) do begin
    if (Items[i] = nil) or (Items[i].ScrollWnd = nil) or Items[i].ScrollWnd.Destroyed then begin
      if Items[i] <> nil then FreeAndNil(Items[i]);
      for j := i to Length(Items) - 2 do begin
        Items[j] := Items[j + 1];
        Items[j + 1] := nil;
      end;
      SetLength(Items, Length(Items) - 1);
    end;
    inc(i)
  end;

  i := 0;
  while i < Length(GraphItems) do begin
    if (GraphItems[i] = nil) or (GraphItems[i].Handler = nil) or GraphItems[i].Handler.Destroyed then begin
      if GraphItems[i] <> nil then FreeAndNil(GraphItems[i]);
      for j := i to Length(GraphItems) - 2 do begin
        GraphItems[j] := GraphItems[j + 1];
        GraphItems[j + 1] := nil;
      end;
      SetLength(GraphItems, Length(GraphItems) - 1);
    end;
    inc(i)
  end;
end;

{ TacAdapterItem }
constructor TacAdapterItem.Create;
begin
  OldFontColor := -1;
  SkinData := TsCommonData.Create(Self, True);
  SkinData.COC := COC_TsAdapter;
  ScrollWnd := nil;
end;

destructor TacAdapterItem.Destroy;
begin
  if (ScrollWnd <> nil) then FreeAndNil(ScrollWnd);
  FreeAndNil(SkinData);
  inherited Destroy;
end;

procedure TacAdapterItem.DoHook(Control: TWinControl);
var
  i, j : integer;
  SM : TsSkinManager;
  ClName : string;
begin
  if (Control.Tag = ExceptTag) or not CtrlIsReadyForHook(Control) or (Control.Parent = nil) or GetBoolMsg(Control, AC_CTRLHANDLED) then Exit;

  Self.WinCtrl := Control;
  SkinData.FOwnerControl := Control;
  SkinData.FOwnerObject := TObject(Control);

  SM := SkinData.SkinManager;
  ClName := Control.ClassName;
  if SM <> nil then for j := 0 to Length(SM.ThirdLists) - 1 do begin
    for i := 0 to SM.ThirdLists[j].Count - 1 do begin
      if SM.ThirdLists[j][i] = ClName then begin
        case j of
          ord(tpEdit) : ScrollWnd := TacEditWnd.Create(Control.Handle, SkinData, SM, SkinData.SkinSection);
          ord(tpButton) : ScrollWnd := {$IFDEF D2010}TacButtonWnd{$ELSE}TacBtnWnd{$ENDIF}.Create(Control.Handle, SkinData, SM, SkinData.SkinSection);
          ord(tpBitBtn) : ScrollWnd := TacBitBtnWnd.Create(Control.Handle, SkinData, SM, SkinData.SkinSection);
          ord(tpCheckBox) : ScrollWnd := TacCheckBoxWnd.Create(Control.Handle, SkinData, SM, SkinData.SkinSection);
          ord(tpComboBox) : ScrollWnd := TacComboBoxWnd.Create(Control.Handle, SkinData, SM, SkinData.SkinSection);
          ord(tpGrid) : ScrollWnd := TacGridWnd.Create(Control.Handle, SkinData, SM, SkinData.SkinSection);
          ord(tpGroupBox) : ScrollWnd := TacGroupBoxWnd.Create(Control.Handle, SkinData, SM, SkinData.SkinSection);
          ord(tpListView) : ScrollWnd := TacListViewWnd.Create(Control.Handle, SkinData, SM, SkinData.SkinSection);
          ord(tpPanel) : ScrollWnd := TacPanelWnd.Create(Control.Handle, SkinData, SM, SkinData.SkinSection);
          ord(tpTreeView) : ScrollWnd := TacTreeViewWnd.Create(Control.Handle, SkinData, SM, SkinData.SkinSection);
          ord(tpwwEdit) : ScrollWnd := TacWWComboBoxWnd.Create(Control, SkinData, SM, SkinData.SkinSection);
          ord(tpGridEh) : ScrollWnd := TacGridEhWnd.Create(Control.Handle, SkinData, SM, SkinData.SkinSection);
          ord(tpVirtualTree) : ScrollWnd := TacVirtualTreeViewWnd.Create(Control.Handle, SkinData, SM, SkinData.SkinSection);
          ord(tpPageControl) : ScrollWnd := TacPageControlWnd.Create(Control.Handle, SkinData, SM, SkinData.SkinSection);
          ord(tpTabControl) : ScrollWnd := TacTabControlWnd.Create(Control.Handle, SkinData, SM, SkinData.SkinSection);
          ord(tpToolBar) : ScrollWnd := TacToolBarVCLWnd.Create(Control.Handle, SkinData, SM, SkinData.SkinSection);
          ord(tpStatusBar) : ScrollWnd := TacStatusBarWnd.Create(Control.Handle, SkinData, SM, SkinData.SkinSection);
        end;
        Exit;
      end;
    end;
  end;
end;

{ TacBorderForm }

procedure TacBorderForm.BorderProc(var Message: TMessage);
var
  Rgn, NewRgn : hrgn;
  p : TPoint;
  Wnd : hwnd;
  cR : TRect;
  Form : TForm;
  i : integer;
{$IFNDEF NOWNDANIMATION}
  b : byte;
{$ENDIF}
begin
{$IFDEF LOGGED}
//  if (TsSkinProvider(FOwner).Form <> nil) and (TsSkinProvider(FOwner).Form.Tag = 1) then
//    AddToLog(Message);
{$ENDIF}
  case Message.Msg of

    WM_MOUSEMOVE..WM_MBUTTONDBLCLK : if MouseAboveTheShadow(TWMMouse(Message)) then begin
      acInMouseMsg := True;
      NewRgn := CreateRectRgn(TWMMouse(Message).XPos, TWMMouse(Message).YPos, TWMMouse(Message).XPos + 1, TWMMouse(Message).YPos + 1);
      Rgn := MakeRgn;
      if Rgn = 0 then Rgn := CreateRectRgn(0, 0, AForm.Width, AForm.Height);
      CombineRgn(Rgn, Rgn, NewRgn, RGN_XOR);
      DeleteObject(NewRgn);

      if (FOwner is TsSkinProvider) then begin
        if not (fsModal in TAccessForm(TsSkinProvider(FOwner).Form).FormState {Report builder repaint bug} ) then SetWindowRgn(AForm.Handle, Rgn, False) else DeleteObject(Rgn);
      end
      else SetWindowRgn(AForm.Handle, Rgn, False);

      Wnd := WindowFromPoint(Point(TWMMouse(Message).XPos + AForm.Left, TWMMouse(Message).YPos + AForm.Top));
      if (Wnd <> AForm.Handle) and (Wnd <> OwnerHandle) then begin
        if Message.Msg = WM_MOUSEMOVE then begin // Correcting of coords
          p.X := Integer(LoWord(Message.LParam));
          p.Y := Integer(HiWord(Message.LParam));
          GetWindowRect(Wnd, cR);
          p.X := p.X + AForm.Left - cR.Left;
          p.Y := p.Y + AForm.Top - cR.Top;
          Message.LParam := MakeLParam(Word(p.X), Word(p.Y));
        end;
        SendMessage(Wnd, Message.Msg, Message.wParam, Message.lParam);
      end;
      acInMouseMsg := False;
      Exit;
    end;

    WM_NCHITTEST : if MouseAboveTheShadow(TWMMouse(Message)) then begin
      Message.Result := HTTRANSPARENT;
      OldBorderProc(Message);
    end
    else Message.Result := integer(Windows.HTOBJECT);
    WM_NCLBUTTONDBLCLK : begin
      if (FOwner is TsSkinProvider) then begin
        if (TsSkinProvider(FOwner).ResizeMode = rmBorder) and bInProcess then begin
          p := TsSkinProvider(FOwner).Form.ClientToScreen(Point(TWMMouse(Message).XPos, TWMMouse(Message).YPos));
          TsSkinProvider(FOwner).StopMove(p.x, p.y);
          ReleaseCapture;
          bInProcess := False;
        end;
      end;
      DoStartMove := False;
      TWMNCHitMessage(Message).HitTest := Ex_WMNCHitTest(TWMNCHitTest(Message));
      if (FOwner is TsSkinProvider) then case TWMNCHitMessage(Message).HitTest of
        HTSYSMENU : begin SendMessage(OwnerHandle, WM_SYSCOMMAND, SC_CLOSE, 0); end;
        HTCAPTION : with TsSkinProvider(FOwner) do begin
          if SystemMenu.VisibleClose and (SystemMenu.EnabledMax or SystemMenu.EnabledRestore) or not HaveBorder(TsSkinProvider(FOwner)) and IsIconic(Form.Handle) then begin
            if (Form.WindowState = wsMaximized) or IsIconic(Form.Handle)
              then SendMessage(Form.Handle, WM_SYSCOMMAND, SC_RESTORE, 0)
              else SendMessage(Form.Handle, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
            SystemMenu.UpdateItems;
          end
          else if IsIconic(Form.Handle) then begin
            SendMessage(Form.Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
            SystemMenu.UpdateItems;
          end;
          TWMNCHitMessage(Message).HitTest := 0;
        end;
        HTRIGHT, HTLEFT : begin
          Form := sp.Form;
          if (Form.BorderStyle = bsSizeable) then begin
            if FormState and FS_MAXWIDTH = FS_MAXWIDTH then begin
              Form.SetBounds(sp.NormalBounds.Left, sp.Form.Top, sp.NormalBounds.Right, Form.Height);
              sp.FormState := sp.FormState and not FS_MAXWIDTH;
            end
            else begin
              cR := acWorkRect(Form);
              i := DiffBorder(Self);
//              sp.FormState := sp.FormState or FS_MAXWIDTH;
              sp.NormalBounds.Left := Form.Left;
              sp.NormalBounds.Right := Form.Width;
              Form.SetBounds(cR.Left + i, Form.Top, WidthOf(cR) - 2 * i, Form.Height);
              sp.FormState := sp.FormState or FS_MAXWIDTH;
            end;
          end
        end;
        HTTOP, HTBOTTOM : begin
          Form := sp.Form;
          if (Form.BorderStyle = bsSizeable) then begin
            if FormState and FS_MAXHEIGHT = FS_MAXHEIGHT then begin
              Form.SetBounds(Form.Left, sp.NormalBounds.Top, Form.Width, sp.NormalBounds.Bottom);
              sp.FormState := sp.FormState and not FS_MAXHEIGHT;
            end
            else begin
              cR := acWorkRect(Form);                           
              i := DiffTitle(Self);
//              sp.FormState := sp.FormState or FS_MAXHEIGHT;
              sp.NormalBounds.Top := Form.Top;
              sp.NormalBounds.Bottom := Form.Height;
              Form.SetBounds(Form.Left, cR.Top + i, Form.Width, HeightOf(cR) - i - DiffBorder(Self));
              sp.FormState := sp.FormState or FS_MAXHEIGHT;
            end;
          end
        end;
      end;
    end;
    WM_SETCURSOR : if not Ex_WMSetCursor(TWMSetCursor(Message)) then OldBorderProc(Message);
    WM_MOUSEACTIVATE: begin
      Message.Result := MA_NOACTIVATE;
      if (FOwner is TsSkinProvider) then begin
        if TsSkinProvider(FOwner).Form.Enabled then SetForegroundWindow(OwnerHandle);
      end
      else begin
        if IsWindowEnabled(OwnerHandle) then SetForegroundWindow(OwnerHandle);
      end;
    end;
    WM_NCRBUTTONUP : if not MouseAboveTheShadow(TWMMouse(Message)) then begin
      TWMNCLButtonDown(Message).HitTest := HTTRANSPARENT;
      SendMessage(OwnerHandle, Message.Msg, Message.wParam, Message.lParam);
    end;
    WM_NCLBUTTONUP : if not MouseAboveTheShadow(TWMMouse(Message)) then begin
      TWMNCLButtonDown(Message).HitTest := HTTRANSPARENT;
      SendMessage(OwnerHandle, Message.Msg, Message.wParam, Message.lParam);
    end;
    WM_NCRBUTTONDOWN : if not MouseAboveTheShadow(TWMMouse(Message)) then begin
      TWMNCLButtonDown(Message).HitTest := Ex_WMNCHitTest(TWMNCHitTest(Message));
      SendMessage(OwnerHandle, Message.Msg, Message.wParam, Message.lParam);
    end;
    WM_NCLBUTTONDOWN : if not MouseAboveTheShadow(TWMMouse(Message)) then begin
      ExBorderShowing := False;
      TWMNCLButtonDown(Message).HitTest := HTTRANSPARENT;
{$IFNDEF NOWNDANIMATION}
      i := Ex_WMNCHitTest(TWMNCHitTest(Message));
      case i of
        HTSYSMENU : begin
          SendMessage(OwnerHandle, Message.Msg, i, Message.lParam);
          Exit;
        end;
        HTCAPTION : begin
          if FOwner is TsSkinProvider then begin
            if SkinData.SkinManager.AnimEffects.BlendOnMoving.Active and not IsZoomed(OwnerHandle) and
                not IsIconic(OwnerHandle) and not (AeroIsEnabled and ((SkinData.SkinManager.AnimEffects.BlendOnMoving.BlendValue = MaxByte) or not TsSkinProvider(FOwner).AllowBlendOnMoving){ AlphaMoving is not required then begin} ) then begin
              StartBlendOnMoving(TsSkinProvider(FOwner));
              Exit;
            end;
          end
          else begin
            if SkinData.SkinManager.AnimEffects.BlendOnMoving.Active then begin
              StartBlendOnMovingDlg(TacDialogWnd(FOwner));
              Exit;
            end;
          end;
        end;
      end;
      TWMNCLButtonDown(Message).HitTest := HTTRANSPARENT;
{$ENDIF}
      SendMessage(OwnerHandle, Message.Msg, Message.wParam, Message.lParam);
    end;           
    WM_WINDOWPOSCHANGING : if (FOwner is TsSkinProvider) and (FormState and FS_BLENDMOVING = FS_BLENDMOVING){ and (FormState and FS_ANIMMINIMIZING = FS_ANIMMINIMIZING)} then begin
      if TsSkinProvider(FOwner).FScreenSnap and not IsZoomed(TsSkinProvider(FOwner).Form.Handle) and ((TWMWindowPosChanging(Message).WindowPos^.X <> 0) or (TWMWindowPosChanging(Message).WindowPos^.Y <> 0)) then begin
        with TWMWindowPosChanging(Message).WindowPos^ do begin
          cR := acWorkRect(AForm);
          HandleEdge(x, cR.Right, TsSkinProvider(FOwner).SnapBuffer, AForm.Width - ShadowSize.Right + SkinData.SkinManager.SkinData.ExShadowOffs);
          HandleEdge(y, cR.Bottom, TsSkinProvider(FOwner).SnapBuffer, AForm.Height - ShadowSize.Bottom + SkinData.SkinManager.SkinData.ExShadowOffs);
          HandleEdge(x, cR.Left, TsSkinProvider(FOwner).SnapBuffer, ShadowSize.Left - SkinData.SkinManager.SkinData.ExShadowOffs);
          HandleEdge(y, cR.Top, TsSkinProvider(FOwner).SnapBuffer, ShadowSize.Top - SkinData.SkinManager.SkinData.ExShadowOffs);
        end;
      end;
      OldBorderProc(Message);
    end
    else OldBorderProc(Message);
{$IFNDEF NOWNDANIMATION}
    WM_SHOWWINDOW : if acLayered and (FOwner is TsSkinProvider) and not InAnimationProcess{$IFDEF D2007} and Application.MainFormOnTaskBar {$ENDIF} and TsSkinProvider(FOwner).DrawNonClientArea then begin
      if (Message.WParam = 0) and (Message.LParam in [0, SW_PARENTCLOSING])then begin
        if (FormState and FS_ANIMMINIMIZING = FS_ANIMMINIMIZING) then begin
//          OldBorderProc(Message);
          Message.Result := 0;
          Exit;
        end
        else if (FormState and FS_ANIMCLOSING <> FS_ANIMCLOSING) then begin // Prepare cache if closed with Application.MainFormOnTaskBar (Animation in Application terminating)
          if (SkinData.SkinManager.AnimEffects.FormHide.Active) and (SkinData.SkinManager.AnimEffects.FormHide.Time > 0) and
                    (TsSkinProvider(FOwner).SkinData.SkinManager.ShowState <> saMinimize) then begin // Patch for BDS when MainFormOnTaskBAr
            TsSkinProvider(FOwner).FormState := TsSkinProvider(FOwner).FormState or FS_ANIMCLOSING;
            PaintFormTo(TsSkinProvider(FOwner).SkinData.FCacheBmp, TsSkinProvider(FOwner));
            ExBorderShowing := True;
{$IFDEF DELPHI7UP}
            if TsSkinProvider(FOwner).Form.AlphaBlend then b := TsSkinProvider(FOwner).Form.AlphaBlendValue else
{$ENDIF}
            b := MaxByte;

            SetFormBlendValue(AForm.Handle, SkinData.FCacheBmp, b);
            SetWindowRgn(AForm.Handle, MakeRgn, False);
            SetWindowPos(AForm.Handle, 0, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE or SWP_NOREDRAW or SWP_SHOWWINDOW or SWP_NOSENDCHANGING or SWP_NOOWNERZORDER);
            Exit;
          end;
        end else Exit;
      end;
      OldBorderProc(Message);
    end
    else OldBorderProc(Message);
{$ENDIF}

    WM_WINDOWPOSCHANGED : begin
      KillAnimations;
      OldBorderProc(Message);
      if (sp <> nil) and not (csDestroying in sp.ComponentState) and not (csDestroying in sp.Form.ComponentState) and (sp.Form.FormStyle = fsStayOnTop) and (AForm <> nil) and not (csDestroying in AForm.ComponentState) then begin
        if AeroIsEnabled and (Application.MainForm = sp.Form) and (GetActiveWindow = sp.Form.Handle)
          then SetWindowPos(AForm.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE or SWP_NOREDRAW or SWP_SHOWWINDOW or SWP_NOSENDCHANGING or SWP_NOOWNERZORDER)
          else SetWindowPos(AForm.Handle, sp.Form.Handle, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE or SWP_NOREDRAW or SWP_SHOWWINDOW or SWP_NOSENDCHANGING or SWP_NOOWNERZORDER);
      end;
    end;
    WM_ERASEBKGND, WM_NCPAINT :;
    else OldBorderProc(Message);
  end;
end;

constructor TacBorderForm.Create(AOwner: TObject);
begin
  FOwner := AOwner;
  if FOwner is TsSkinProvider then sp := TsSkinProvider(FOwner) else sp := nil;
  ParentHandle := 0;
  ExBorderShowing := False;
  acInMouseMsg := False;
  CreateNewForm;
end;

destructor TacBorderForm.Destroy;
begin
  KillAnimations;
  if AForm <> nil then FreeAndNil(AForm);
  inherited;
end;

function TacBorderForm.Ex_WMNCHitTest(var Message: TWMNCHitTest): integer;
const
  BtnSpacing = 1;
  DefRESULT = HTTRANSPARENT;
var
  Handle : hwnd;
  SysMenu : TsCustomSysMenu;
  p : TPoint;
  i, SysBtnCount, BtnIndex : integer;
  GripVisible, HelpIconVisible : boolean;
  R, hrect, vrect : TRect;
  function GetBtnIndex : integer;
  var
    i, c : integer;
  begin
    Result := 0;
    c := 0; 
    if FOwner is TsSkinProvider then with FOwner as TsSkinProvider do begin
      if SystemMenu.VisibleClose and Assigned(SystemMenu) then begin
        inc(c);
        if PtInRect(ButtonClose.Rect, p) then Result := c else begin
          if SystemMenu.VisibleMax then begin
            inc(c);
            if PtInRect(ButtonMax.Rect, p) then begin
              Result := c;
              Exit;
            end;
          end;
          if SystemMenu.VisibleMin then begin
            inc(c);
            if PtInRect(ButtonMin.Rect, p) then Result := c
          end;
          if Result <> 0 then Exit;
          if (biHelp in Form.BorderIcons) then begin
            inc(c);
            if PtInRect(ButtonHelp.Rect, p) then begin
              Result := c;
              Exit;
            end;
          end;
        end;
      end;
      for i := 0 to TitleButtons.Count - 1 do begin
        inc(c);
        if not TitleButtons[i].Visible then Continue;
        if PtInRect(TitleButtons[i].BtnData.Rect, p) then begin
          Result := c;
          Exit;
        end;
      end;
    end
    else with FOwner as TacDialogWnd do begin
      inc(c);
      if SystemMenu.VisibleClose then begin
        if PtInRect(ButtonClose.Rect, p)
          then Result := c
          else if TacDialogWnd(FOwner).VisibleHelp then begin
            inc(c);
            if PtInRect(ButtonHelp.Rect, p) then begin
              Result := c;
              Exit;
            end;
          end
      end;
    end
  end;
begin
  if (FOwner is TsSkinProvider) then begin
    Message.Result := Windows.HTNOWHERE;
    if Assigned(TsSkinProvider(FOwner).FOnExtHitTest) then TsSkinProvider(FOwner).FOnExtHitTest(TWMNcHitTest(Message));
    if Message.Result <> Windows.HTNOWHERE then begin
      Result := Message.Result;
      Exit;
    end;
  end;
  Result := DefRESULT;
  if not IsWindowEnabled(OwnerHandle) then Exit;
  p := Point(Message.XPos - AForm.Left, Message.YPos - AForm.Top);

  if FOwner is TsSkinProvider then begin
    SysMenu := TsSkinProvider(FOwner).SystemMenu;
    Handle := TsSkinProvider(FOwner).Form.Handle;
  end
  else begin
    SysMenu := TacDialogWnd(FOwner).SystemMenu;
    Handle := TacDialogWnd(FOwner).CtrlHandle;
  end;
  HelpIconVisible := GetWindowLong(Handle, GWL_EXSTYLE) and WS_EX_CONTEXTHELP = WS_EX_CONTEXTHELP;

  with FOwner do begin
    BtnIndex := GetBtnIndex;
    if (BtnIndex > 0) then begin
      SysBtnCount := 0;
      if SysMenu.VisibleClose then begin
        inc(SysBtnCount);
        if SysMenu.VisibleMax then inc(SysBtnCount);
        if SysMenu.VisibleMin or IsIconic(OwnerHandle) then inc(SysBtnCount);
        if HelpIconVisible then inc(SysBtnCount);
      end;
      if (BtnIndex <= SysBtnCount) then begin
        case BtnIndex of
          1 : if SysMenu.VisibleClose then Result := HTCLOSE;
          2 : begin
            if SysMenu.VisibleMax then begin
              if (SysMenu.EnabledMax or (SysMenu.EnabledRestore and not IsIconic(Handle))) then Result := HTMAXBUTTON else Result := HTCAPTION;
            end
            else if (SysMenu.VisibleMin) or IsIconic(Handle) then begin
              if SysMenu.EnabledMin then Result := HTMINBUTTON else Result := HTCAPTION;
            end
            else if HelpIconVisible then Result := HTHELP;
          end;
          3 : begin
            if (SysMenu.VisibleMin) or IsIconic(Handle) then begin
              if not IsIconic(Handle) then begin
                if SysMenu.EnabledMin then Result := HTMINBUTTON else Result := HTCAPTION;
              end
              else Result := HTMINBUTTON;
            end
            else if HelpIconVisible then Result := HTHELP;
          end;
          4 : if HelpIconVisible and SysMenu.VisibleMax then Result := HTHELP;
        end;
      end
      else if (FOwner is TsSkinProvider) and (BtnIndex <= TsSkinProvider(FOwner).TitleButtons.Count + SysBtnCount) then begin // UDF button
        BtnIndex := BtnIndex - SysBtnCount - 1;
        if TsSkinProvider(FOwner).TitleButtons.Items[BtnIndex].Enabled then Result := HTUDBTN + BtnIndex;
      end;
      if Result <> DefRESULT then begin
        SetHotHT(Result);
        Exit;
      end;
    end;

    if not IsZoomed(Handle) and (GetWindowLong(Handle, GWL_STYLE) and WS_SIZEBOX = WS_SIZEBOX) then begin
      if Between(p.Y, ShadowSize.Top, 4{SysBorderWidth(Handle, Self, False)} + ShadowSize.Top) then Result := HTTOP;
      if Between(p.Y, AForm.Height - SysBorderWidth(Handle, Self, False) - ShadowSize.Bottom, AForm.Height - ShadowSize.Bottom) then Result := HTBOTTOM;
      if Between(p.X, ShadowSize.Left, SysBorderWidth(Handle, Self, False) + ShadowSize.Left) then if Result = HTTOP then Result := HTTOPLEFT else if Result = HTBOTTOM then Result := HTBOTTOMLEFT else Result := HTLEFT;
      if Between(p.X, AForm.Width - SysBorderWidth(Handle, Self, False) - ShadowSize.Right, AForm.Width - ShadowSize.Right) then if Result = HTTOP then Result := HTTOPRIGHT else if Result = HTBOTTOM then Result := HTBOTTOMRIGHT else Result := HTRIGHT;
      if Result <> DefRESULT then begin
        SetHotHT(-1);
        Exit;
      end;
    end;
    SetHotHT(HTTRANSPARENT);

    if Between(p.Y, 0, CaptionHeight + SysBorderHeight(OwnerHandle, Self) + ShadowSize.Top) then begin
        if PtInRect(IconRect, p) then Result := HTSYSMENU else Result := HTCAPTION;
//      if Between(p.Y, CaptionHeight(False) + SysBorderHeight(OwnerHandle, Self, False), CaptionHeight(False) + SysBorderHeight(OwnerHandle, Self, False) + MenuHeight) then begin
//        if PtInRect(IconRect, p) then Result := HTSYSMENU else Result := HTCAPTION;
//        Result := HTCAPTION;
        Exit;
//      end;
    end
    else begin
      if p.Y <= CaptionHeight + SysBorderHeight(OwnerHandle, Self) + MenuHeight then begin
        Result := HTMENU;
      end
      else begin
        GripVisible := False;
        if (FOwner is TsSkinProvider) then with TsSkinProvider(FOwner) do begin
          if IsGripVisible(TsSkinProvider(FOwner)) then GripVisible := True else if Assigned(ListSW) and Assigned(ListSW.sbarVert) and ListSW.sbarVert.fScrollVisible and ListSW.sbarHorz.fScrollVisible then begin
            Ac_GetHScrollRect(ListSW, Form.Handle, hrect);
            Ac_GetVScrollRect(ListSW, Form.Handle, vrect);
            GetWindowRect(Form.Handle, R);
            GripVisible := PtInRect(Rect(hrect.Right - R.Left, hrect.Top - R.Top, vrect.Right - R.Left, hrect.Bottom - R.Top), p)
          end;
        end;
        if GripVisible then begin
          i := SkinData.SkinManager.GetMaskIndex(SkinData.SkinManager.ConstData.IndexGLobalInfo, s_GlobalInfo, s_GripImage);
          if SkinData.SkinManager.IsValidImgIndex(i) then begin
            if (p.y > TsSkinProvider(FOwner).RBGripPoint(i).y) and (p.x > TsSkinProvider(FOwner).RBGripPoint(i).x) then Result := HTBOTTOMRIGHT;
          end;
        end;
        if Result <> DefRESULT then SetHotHT(Result) else SetHotHT(0);
      end;
    end;
  end;
end;

function TacBorderForm.Ex_WMSetCursor(var Message: TWMSetCursor) : boolean;
var
  M : TWMNCHitTest;
  nCursor : HCURSOR;
begin
  M.Msg := WM_NCHitTest;
  M.XPos := SmallInt(acMousePos.X);
  M.YPos := SmallInt(acMousePos.Y);
  M.Unused := 0;
  M.Result := 0;
{$IFDEF D2009}
  Message.HitTest := SmallInt(Ex_WMNCHitTest(M));
{$ELSE}  
  Message.HitTest := Word(Ex_WMNCHitTest(M));
{$ENDIF}  
  Result := False;
  if not MouseAboveTheShadow(TWMMouse(M)) then begin
    nCursor := 0;
    case Message.HitTest of
      HTCAPTION, HTMENU : nCursor := LoadCursor(0, IDC_ARROW);
      HTLEFT, HTRIGHT : nCursor := LoadCursor(0, IDC_SIZEWE);
      HTTOP, HTBOTTOM : nCursor := LoadCursor(0, IDC_SIZENS);
      HTTOPRIGHT, HTBOTTOMLEFT : nCursor := LoadCursor(0, IDC_SIZENESW);
      HTTOPLeft, HTBOTTOMRIGHT : nCursor := LoadCursor(0, IDC_SIZENWSE)
    end;
    if nCursor <> 0 then begin
      SetCursor(nCursor);
      Result := True;
    end;
  end
end;

function TacBorderForm.MouseAboveTheShadow(Message: TWMMouse): boolean;
var
  p : TPoint;
begin
  Result := False;
  if (csDestroying in Application.ComponentState) or (SkinData = nil) or (AForm = nil) or (Self.SkinData.SkinManager = nil) or not Self.SkinData.SkinManager.Active then Exit;
  if Message.Msg = WM_MOUSEMOVE then p := Point(Message.XPos, Message.YPos) else p := Point(Message.XPos - AForm.Left, Message.YPos - AForm.Top);
  if not IsZoomed(OwnerHandle) then if (p.Y < ShadowSize.Top) or (p.Y > AForm.Height - ShadowSize.Bottom) or (p.X < ShadowSize.Left) or (p.X > AForm.Width - ShadowSize.Right) then begin
    Result := True;
    SetHotHT(HTTRANSPARENT);
  end;
end;

type
{$IFDEF D2010}
  TOffsetArray = array[0..90] of byte;
{$ELSE}
  {$IFDEF D2009}
    TOffsetArray = array[0..86] of byte;
  {$ELSE}
    TOffsetArray = array[0..90] of byte;
  {$ENDIF}
{$ENDIF}

  TAccessScreen = class(TComponent)
  public
    Offset : TOffsetArray;
    FAlignLevel: Word;
  end;

procedure TacBorderForm.UpdateExBordersPos(Redraw : boolean = True; Blend : byte = MaxByte);
var
  R, fR : TRect;
  p : TPoint;
  w, h, cy, cx, yAeroTab : integer;
  Flags : Cardinal;
  SavedDC, DC : hdc;
  FBmpSize: TSize;
  FBmpTopLeft: TPoint;
  bSizeChanged : boolean;
  iInsAfter : Cardinal;
  FBlend: TBlendFunction;
  oWnd : THandle;
begin
  with FOwner do begin
    oWnd := OwnerHandle;
    if Application.Terminated or ExBorderShowing or (oWnd = 0) or not GetWindowRect(oWnd, fR) or (SkinData.PrintDC <> 0) or InAnimationProcess then Exit;
    if (AForm = nil) then CreateNewForm;

    if sp <> nil then begin
      if sp.SkinData.CtrlSkinState and ACS_LOCKED = ACS_LOCKED then Exit;
      if InAnimation(sp) or SkinData.FUpdating or not sp.DrawNonClientArea
        or (TAccessScreen(Screen).FAlignLevel = 1) then Exit;

      if (csDestroying in sp.ComponentState) or (csDestroying in sp.Form.ComponentState) then begin
        sp.InitExBorders(False);
        Exit;
      end
      else if not (IsWindowVisible(sp.Form.Handle) or ((sp.FormState <> 0) and (sp.FormState <> FS_ACTIVATE))) then begin
        FreeAndNil(AForm);
//        ShowWindow(AForm.Handle, SW_HIDE);
//        AForm.Visible := True;
        SkinData.BGChanged := True; // Will be redrawn fully
        Exit;
      end;
      ExBorderShowing := True;
      if sp.Form.FormStyle = fsStayOnTop then begin // Patch for Delphi problem concerning StayOnTop forms
        if (GetActiveWindow = ownd) then SetWindowPos(oWnd, HWND_TOP, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOMOVE or SWP_NOOWNERZORDER or SWP_NOSENDCHANGING);
        iInsAfter := HWND_TOP;
      end
      else
      if GetWindowLong(oWnd, GWL_EXSTYLE) and WS_EX_TOPMOST = WS_EX_TOPMOST then begin
        SetWindowPos(oWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOMOVE or SWP_NOOWNERZORDER or SWP_NOSENDCHANGING);
        iInsAfter := HWND_TOPMOST;
      end
      else iInsAfter := oWnd;
//      if IsZoomed(oWnd) and AeroIsEnabled then yAeroTab := 5 else 
      yAeroTab := 0;
    end
    else begin
      if not IsWindowVisible(oWnd) then Exit; // If dialog is not visible still
      ExBorderShowing := True;
      Flags := GetWindowLong(oWnd, GWL_EXSTYLE);
      if (Flags and WS_EX_TOPMOST = WS_EX_TOPMOST) then begin
        if GetActiveWindow = ownd then SetWindowPos(oWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOMOVE or SWP_NOOWNERZORDER or SWP_NOSENDCHANGING);
        iInsAfter := HWND_TOPMOST;
      end
      else iInsAfter := 0;
      yAeroTab := 0;
    end;

    if (FormState and FS_FULLPAINTING <> 0) or aSkinChanging then begin
      if SkinData.BGChanged then PaintAll;
      Redraw := True;
      if sp <> nil then PaintFormTo(sp.SkinData.FCacheBmp, sp) else begin
        DC := GetWindowDC(oWnd);
        SavedDC := SaveDC(DC);
        try
          R := ACClientRect(oWnd);
          BitBlt(SkinData.FCacheBmp.Canvas.Handle, OffsetX + R.Left, OffsetY + R.Top, WidthOf(R), HeightOf(R), DC, R.Left, R.Top, SRCCOPY);
          FillAlphaRect(SkinData.FCacheBmp, Rect(OffsetX + R.Left, OffsetY + R.Top, OffsetX + R.Left + WidthOf(R), OffsetY + R.Top + HeightOf(R)), MaxByte);
        finally
          RestoreDC(DC, SavedDC);
          ReleaseDC(oWnd, DC);
        end;
      end;
    end
    else if SkinData.BGChanged then begin
      PaintAll;
      Redraw := True;
    end;

    if sp <> nil then begin
      if sp.FSysExHeight
        then cy := ShadowSize.Top + DiffTitle(Self) + 4 // SysBorderWidth(oWnd, Self, False) { For MinMax patching }
        else cy := OffsetY;
    end
    else begin
      cy := OffsetY;
    end;

    cx := SkinBorderWidth(Self) - SysBorderWidth(oWnd, Self, False) + ShadowSize.Left;
    w := SkinData.FCacheBmp.Width;
    h := SkinData.FCacheBmp.Height;

    if iInsAfter = 0 then begin
      if isIconic(oWnd) or (FormState and FS_SIZING = FS_SIZING)
        then iInsAfter := GetNextWindow(oWnd, GW_HWNDPREV)
        else iInsAfter := oWnd;
    end;

    Flags := SWP_NOACTIVATE or SWP_NOSENDCHANGING or SWP_NOOWNERZORDER;

    if Redraw or (AForm.Width <> w) or (AForm.Height <> h) then bSizeChanged := True else begin
      Flags := Flags or SWP_NOSIZE;
      bSizeChanged := False;
    end;
    if not Redraw then begin
      Flags := Flags or SWP_NOREDRAW;
    end;
    p := Point(fR.Left - cx, fr.Top - cy);

    if acLayered and bSizeChanged and not acInMouseMsg then begin
      FBmpSize.cx := SkinData.FCacheBmp.Width;
      FBmpSize.cy := SkinData.FCacheBmp.Height;
      FBmpTopLeft := Point(0, 0);
{$IFDEF DELPHI6UP}
      if FOwner is TsSkinProvider and TsSkinProvider(FOwner).Form.AlphaBlend
        then FBlend.SourceConstantAlpha := TsSkinProvider(FOwner).Form.AlphaBlendValue
        else
{$ENDIF}
      FBlend.SourceConstantAlpha := Blend;
      FBlend.BlendOp := AC_SRC_OVER;
      FBlend.BlendFlags := 0;
      FBlend.AlphaFormat := AC_SRC_ALPHA;

      if (AForm.Width <> w) or (AForm.Height <> h) then AForm.SetBounds(fR.Left - cx, fr.Top - cy, w, h - yAeroTab);
      SetWindowRgn(AForm.Handle, MakeRgn, False);

      if (FOwner is TsSkinProvider) and (TsSkinProvider(FOwner).Form.WindowState = wsMaximized) then begin // Solving a problem with hidden taskbar
        if yAeroTab <> 0 then SkinData.FCacheBmp.Height := SkinData.FCacheBmp.Height - ShadowSize.Bottom - SysBorderWidth(TsSkinProvider(FOwner).Form.Handle, Self) - yAeroTab;
        FBmpSize.cy := SkinData.FCacheBmp.Height;
        AForm.Height := FBmpSize.cy;
      end;
      DC := GetDC(0);
      UpdateLayeredWindow(AForm.Handle, DC, @p, @FBmpSize, SkinData.FCacheBmp.Canvas.Handle, @FBmpTopLeft, clNone, @FBlend, ULW_ALPHA);
      ReleaseDC(0, DC);

      if GetWindowLong(AForm.Handle, GWL_STYLE) and WS_VISIBLE <> WS_VISIBLE then begin
        if Blend = 0 then SetWindowLong(oWnd, GWL_STYLE, GetWindowLong(oWnd, GWL_STYLE) and not WS_VISIBLE); // Preventing of the main form painting
        SetWindowPos(AForm.Handle, iInsAfter, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_SHOWWINDOW or SWP_NOSIZE or SWP_NOMOVE or SWP_NOOWNERZORDER);
        if Blend = 0 then SetWindowLong(oWnd, GWL_STYLE, GetWindowLong(oWnd, GWL_STYLE) or WS_VISIBLE);
      end
      else SetWindowPos(AForm.Handle, iInsAfter, 0, 0, 0, 0, Flags or SWP_NOSIZE or SWP_NOMOVE);
    end
    else SetWindowPos(AForm.Handle, iInsAfter{0}, p.X, p.Y, 0, 0, Flags or SWP_NOSIZE);// or SWP_NOZORDER);
  end;
  ExBorderShowing := False;
end;

procedure TacBorderForm.KillAnimations;
begin
  if FOwner is TsSkinProvider then TsSkinProvider(FOwner).KillAnimations else if FOwner is TacDialogWnd then TacDialogWnd(FOwner).KillAnimations;
end;

function TacBorderForm.OffsetX: integer;
begin
  Result := SkinBorderWidth(Self) - SysBorderWidth(OwnerHandle, Self, False) + ShadowSize.Left
end;

function TacBorderForm.OffsetY: integer;
var
  i1, i2 : integer;
begin
  i2 := CaptionHeight(False);
  if i2 <> 0 then i1 := SkinTitleHeight(Self) else i1 := 0;
  Result := ShadowSize.Top - SysBorderWidth(OwnerHandle, Self, False) + i1 - i2
end;

function TacBorderForm.OwnerHandle: hwnd;
begin
  if FOwner is TsSkinProvider then begin
    if TsSkinProvider(FOwner).Form.HandleAllocated then Result := TsSkinProvider(FOwner).Form.Handle else Result := 0
  end
  else if (FOwner is TacDialogWnd) then begin
    Result := TacDialogWnd(FOwner).CtrlHandle
  end
  else Result := 0;
end;

function TacBorderForm.ShadowSize: TRect;
begin
  Result := SkinData.SkinManager.FormShadowSize;
end;

procedure TacBorderForm.SetHotHT(const i: integer; Repaint: boolean);
begin
  if FOwner is TsSkinProvider then TsSkinProvider(FOwner).SetHotHT(i) else TacDialogWnd(FOwner).SetHotHT(i);
end;

function TacBorderForm.CaptionHeight(CheckSkin : boolean = True) : integer;
begin
  if FOwner is TsSkinProvider then Result := TsSkinProvider(FOwner).CaptionHeight(CheckSkin) else Result := TacDialogWnd(FOwner).CaptionHeight(CheckSkin)
end;

function TacBorderForm.MenuHeight: integer;
begin
  if FOwner is TsSkinProvider then Result := TsSkinProvider(FOwner).MenuHeight else Result := 0;
end;

function TacBorderForm.IconRect: TRect;
begin
  if FOwner is TsSkinProvider then Result := TsSkinProvider(FOwner).IconRect else Result := TacDialogWnd(FOwner).IconRect
end;

procedure TacBorderForm.PaintAll;
begin
  if FOwner is TsSkinProvider then TsSkinProvider(FOwner).PaintAll else TacDialogWnd(FOwner).PaintAll
end;

function TacBorderForm.ButtonClose: TsCaptionButton;
begin
  if FOwner is TsSkinProvider then Result := TsSkinProvider(FOwner).ButtonClose else Result := TacDialogWnd(FOwner).ButtonClose
end;

function TacBorderForm.ButtonHelp: TsCaptionButton;
begin
  if FOwner is TsSkinProvider then Result := TsSkinProvider(FOwner).ButtonHelp else Result := TacDialogWnd(FOwner).ButtonHelp
end;

function TacBorderForm.ButtonMax: TsCaptionButton;
begin
  if FOwner is TsSkinProvider then Result := TsSkinProvider(FOwner).ButtonMax else Result := TacDialogWnd(FOwner).ButtonMax
end;

function TacBorderForm.ButtonMin: TsCaptionButton;
begin
  if FOwner is TsSkinProvider then Result := TsSkinProvider(FOwner).ButtonMin else Result := TacDialogWnd(FOwner).ButtonMin
end;

function TacBorderForm.MakeRgn(NewWidth : integer = 0; NewHeight : integer = 0) : HRGN;
var
  R : TRect;
  i, cx, dx : integer;
  SubRgn : hrgn;
  function ClientRgn : hrgn;
  var
    cR, rClient, rInt : TRect;
  begin
    if sp <> nil then begin
      cR.Left := sp.OffsetX;
      cR.Top := sp.OffsetY;

      if (FormState and FS_SIZING = FS_SIZING) and not (fsShowing in sp.Form.FormState) {and AForm.Showing }then begin
        if sp.LastClientRect.Right < sp.Form.ClientWidth
          then cR.Right := cR.Left + sp.LastClientRect.Right
            else if (NewWidth <> 0) and (NewWidth > sp.Form.Constraints.MinWidth)
              then cR.Right := cR.Left + sp.Form.ClientWidth - (TsSkinProvider(FOwner).Form.Width - NewWidth)
              else cR.Right := cR.Left + sp.Form.ClientWidth;

        if sp.LastClientRect.Bottom < sp.Form.ClientHeight
          then cR.Bottom := cR.Top + sp.LastClientRect.Bottom
            else if (NewHeight <> 0) and (NewHeight > sp.Form.Constraints.MinHeight)
              then cR.Bottom := cR.Top + sp.Form.ClientHeight - (sp.Form.Height - NewHeight)
              else cR.Bottom := cR.Top + sp.Form.ClientHeight;
      end
      else begin
        cR.Right := cR.Left + sp.Form.ClientWidth;
        cR.Bottom := cR.Top + sp.Form.ClientHeight;
        if sp.ListSW <> nil then begin
          if (sp.ListSW.sBarVert <> nil) and sp.ListSW.sBarVert.fScrollVisible then cR.Right := cR.Right + GetScrollMetric(sp.ListSW.sBarVert, SM_CXVERTSB);
          if (sp.ListSW.sBarVert <> nil) and sp.ListSW.sBarHorz.fScrollVisible then cR.Bottom := cR.Bottom + GetScrollMetric(sp.ListSW.sBarHorz, SM_CYHORZSB);
        end;
      end;
      cR.Top := cR.Top - sp.LinesCount * sp.MenuHeight;
    end
    else begin
      cR.Left := TacDialogWnd(FOwner).OffsetX;
      cR.Top := TacDialogWnd(FOwner).OffsetY;

      if (FormState and FS_SIZING = FS_SIZING) then begin
        GetClientRect(TacDialogWnd(FOwner).CtrlHandle, rClient);
        if TacDialogWnd(FOwner).LastClientRect.Right < WidthOf(rClient)
          then cR.Right := cR.Left + TacDialogWnd(FOwner).LastClientRect.Right
            else if (NewWidth <> 0)
              then cR.Right := cR.Left + WidthOf(rClient) - (TacDialogWnd(FOwner).WndSize.cx - NewWidth)
              else cR.Right := cR.Left + WidthOf(rClient);

        if TacDialogWnd(FOwner).LastClientRect.Bottom < HeightOf(rClient)
          then cR.Bottom := cR.Top + TacDialogWnd(FOwner).LastClientRect.Bottom
            else if (NewHeight <> 0)
              then cR.Bottom := cR.Top + HeightOf(rClient) - (TacDialogWnd(FOwner).WndSize.cy - NewHeight)
              else cR.Bottom := cR.Top + HeightOf(rClient);
      end
      else begin
        cR.Left := SkinBorderWidth(Self) + ShadowSize.Left;
        GetClientRect(OwnerHandle, rInt);
        cR.Right := cR.Left + WidthOf(rInt);
        cR.Bottom := SkinData.FCacheBmp.Height - SkinBorderWidth(Self) - ShadowSize.Bottom;
//!!!        cR.Top := cR.Bottom - HeightOf(rInt);
      end;
    end;
    Result := CreateRectRgn(cR.Left, cR.Top, cR.Right, cR.Bottom);
  end;
begin
  if AForm <> nil then begin
    if IsZoomed(OwnerHandle) then begin
      i := SysBorderWidth(OwnerHandle, Self, False);
      cx := i;
      dx := DiffBorder(Self);
      R := Rect(cx + dx + ShadowSize.Left, 4 + ShadowSize.Top, AForm.Width - cx - dx - ShadowSize.Right, AForm.Height - cx - dx - ShadowSize.Bottom);
      Result := CreateRectRgn(R.Left, R.Top, R.Right, R.Bottom);
    end
    else Result := 0;
    if (FormState and FS_FULLPAINTING = 0) and (FormState and FS_ANIMCLOSING <> FS_ANIMCLOSING) {or (FOwner is TsSkinProvider) and sp.Form.Showing)} then begin
      if Result = 0 then Result := CreateRectRgn(0, 0, AForm.Width, AForm.Height);
      SubRgn := ClientRgn;
      CombineRgn(Result, Result, SubRgn, RGN_XOR);
      DeleteObject(SubRgn);
    end;
  end
  else Result := 0;
end;

function TacBorderForm.FormState: cardinal;
begin
  if FOwner is TsSkinProvider
    then Result := TsSkinProvider(FOwner).FormState
    else Result := TacDialogWnd(FOwner).FormState
end;

procedure TacBorderForm.CreateNewForm;
var
  Flags : Longint;
begin
  AForm := TForm.Create(nil);
  AForm.Tag := ExceptTag;
  AForm.Visible := False;
  AForm.BorderStyle := bsNone;

  Flags := WS_EX_TOOLWINDOW or WS_EX_NOACTIVATE or WS_EX_LAYERED;

  SetWindowLong(AForm.Handle, GWL_EXSTYLE, Flags);
  ParentHandle := LongWord(SetWindowLong(AForm.Handle, GWL_HWNDPARENT, LongInt(OwnerHandle))); 

  OldBorderProc := AForm.WindowProc;
  AForm.WindowProc := BorderProc;
end;

{ TacSBAnimation }

procedure TacSBAnimation.ChangeState(NewState: integer; ToUp : boolean);
begin
  Up := ToUp;
  Enabled := True;
end;

procedure TacSBAnimation.CheckMouseLeave;
var
  P : TPoint;
  R : TRect;
begin
  if BorderForm <> nil then p := Point(acMousePos.X - BorderForm.AForm.Left, acMousePos.Y - BorderForm.AForm.Top) else begin
    GetWindowRect(FormHandle, R);
    p := Point(acMousePos.X - R.Left, acMousePos.Y - R.Top);
  end;
  if not PtInRect(PBtnData^.Rect, P) then begin
    Enabled := False;
    SendMessage(FormHandle, WM_MOUSELEAVE, 0, 0);
  end;
end;

constructor TacSBAnimation.Create(AOwner: TComponent);
begin
  inherited;
  CurrentLevel := 0;
  CurrentState := 0;
  aBmp := nil;
  AForm := nil;
  Up := False;
  OnTimer := OnAnimTimer;
end;

destructor TacSBAnimation.Destroy;
begin
  Enabled := False;
  if AForm <> nil then FreeAndNil(AForm);
  if ABmp <> nil then FreeAndNil(ABmp);
  PBtnData^.Timer := nil;
  inherited;
end;

function TacSBAnimation.GetFormBounds: TRect;
var
  mi, mOffset : integer;
begin
  if BorderForm <> nil then GetWindowRect(BorderForm.AForm.Handle, Result) else GetWindowRect(FormHandle, Result);
  OffsetRect(Result, PBtnData^.Rect.Left, PBtnData^.Rect.Top);

  mOffset := Offset;

  if mOffset <> 0 then begin
    mi := SkinData.SkinManager.GetMaskIndex(s_GlobalInfo, SkinData.SkinManager.ma[PBtnData^.ImageIndex].PropertyName + s_Glow + '0');
    if (mi > -1) then begin
      Result.Left := Result.Left - mOffset;
      Result.Top := Result.Top - mOffset;
      Result.Right := Result.Left + WidthOf(SkinData.SkinManager.ma[mi].R);
      Result.Bottom := Result.Top + HeightOf(SkinData.SkinManager.ma[mi].R);
    end
    else mOffset := 0;
  end;
  if mOffset = 0 then begin
    Result.Right := Result.Left + WidthOf(PBtnData^.Rect, True);
    Result.Bottom := Result.Top + HeightOf(PBtnData^.Rect, True);            
  end;
end;

procedure TacSBAnimation.MakeForm;
begin
  if AForm = nil then begin
    AForm := TForm.Create(nil);
    AForm.Tag := ExceptTag;
    AForm.Visible := False;
    AForm.BorderStyle := bsNone;
    SetWindowLong(AForm.Handle, GWL_EXSTYLE, GetWindowLong(AForm.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW or WS_EX_NOACTIVATE or WS_EX_TRANSPARENT);

    if (BorderForm <> nil) and (BorderForm.AForm.FormStyle = fsStayOnTop) then begin
      SetWindowLong(AForm.Handle, GWL_EXSTYLE, GetWindowLong(AForm.Handle, GWL_EXSTYLE) or WS_EX_TOPMOST);
    end;
  end;
end;

procedure TacSBAnimation.MakeImg;
var
  R : TRect;
  mi : integer;
  b : boolean;
  CI : TCacheInfo;
  x, y, j : integer;
  p : PRGBAArray;
  ImgIndex : integer;
  TitleButton : TsTitleButton;
begin
  mi := -1;
  if (CurrentState = 0) and (ABmp <> nil) then Exit; // Updating is not required
  R := GetFormBounds;

  b := SkinData.SkinManager.Effects.AllowGlowing and (CurrentState = 1) and (PBtnData^.HitCode in [HTCLOSE, HTMAXBUTTON, HTMINBUTTON]);

  if (SkinData.FOwnerObject is TsSkinProvider) and (PBtnData^.HitCode = HTMINBUTTON) and IsIconic(TsSkinProvider(SkinData.FOwnerObject).Form.Handle)
    then ImgIndex := SkinData.SkinManager.GetMaskIndex(SkinData.SkinManager.ConstData.IndexGlobalInfo, s_GlobalInfo, s_BorderIconNormalize)
    else ImgIndex := PBtnData^.ImageIndex;
  if b then begin
    mi := SkinData.SkinManager.GetMaskIndex(s_GlobalInfo, SkinData.SkinManager.ma[ImgIndex].PropertyName + s_Glow + '0');
    b := mi <> -1;
  end;
  if ABmp = nil then ABmp := CreateBmp32(WidthOf(R, True), HeightOf(R, True));

  if b then with SkinData.SkinManager do begin
    if IsValidImgIndex(mi) then BitBlt(ABmp.Canvas.Handle, 0, 0, ABmp.Width, ABmp.Height, ma[mi].Bmp.Canvas.Handle, 0, 0, SRCCOPY);
  end
  else begin
    CI.X := PBtnData^.Rect.Left;
    CI.Y := PBtnData^.Rect.Top;
    if (SkinData.FOwnerObject is TsSkinProvider) and (TsSkinProvider(SkinData.FOwnerObject).TempBmp <> nil) then begin
      CI.X := CI.X - (TsSkinProvider(SkinData.FOwnerObject).CaptionWidth - TsSkinProvider(SkinData.FOwnerObject).TempBmp.Width - 1);
      CI.Bmp := TsSkinProvider(SkinData.FOwnerObject).TempBmp;
    end
    else CI.Bmp := SkinData.FCacheBmp;
    CI.Ready := True;
    FillRect32(ABmp, Rect(0, 0, ABmp.Width, ABmp.Height), 0);
    FillAlphaRect(ABmp, Rect(0, 0, ABmp.Width, ABmp.Height), 0);
    if (ImgIndex > -1) then begin
      DrawSkinGlyph(ABmp, Point(0, 0), PBtnData^.State, 1, SkinData.SkinManager.ma[ImgIndex], MakeCacheInfo(ABmp));
    end;
    if (BorderForm = nil) then begin
      if (ImgIndex < 0) or (SkinData.SkinManager.ma[ImgIndex].MaskType = 0) then for y := 0 to ABmp.Height - 1 do begin // If AlphaChannel must be updated
        p := ABmp.ScanLine[y];
        for x := 0 to ABmp.Width - 1 do if p[x].C = clFuchsia then p[x].A := MaxByte;
      end;
    end;
  end;
  if (SkinData.FOwnerObject is TsSkinProvider) then with TsSkinProvider(SkinData.FOwnerObject) do if Between(PBtnData^.HitCode, HTUDBTN, HTUDBTN + TitleButtons.Count - 1) then begin // User defined button glyph
    j := PBtnData^.HitCode - HTUDBTN;
    TitleButton := TitleButtons.Items[j];
    if not TitleButton.Glyph.Empty then begin
      if TitleButton.Glyph.PixelFormat = pf32bit then begin
        x := (ABmp.Width - TitleButton.Glyph.Width) div 2;
        y := (ABmp.Height - TitleButton.Glyph.Height) div 2;
        if (PBtnData^.State = 2) then begin inc(x); inc(y) end;
        CopyByMask(Rect(x, y, x + TitleButton.Glyph.Width, y + TitleButton.Glyph.Height),
                   Rect(0, 0, TitleButton.Glyph.Width, TitleButton.Glyph.Height), ABmp, TitleButton.Glyph, EmptyCI, True);
      end
      else begin
        CopyTransBitmaps(ABmp, TitleButton.Glyph,
             integer(PBtnData^.State = 2) + (WidthOf(PBtnData^.Rect) - TitleButton.Glyph.Width) div 2,
             integer(PBtnData^.State = 2) + (HeightOf(PBtnData^.Rect) - TitleButton.Glyph.Height) div 2,
             TsColor(TitleButton.Glyph.Canvas.Pixels[0, TitleButton.Glyph.Height - 1]));
      end;
    end
  end;
end;

function TacSBAnimation.Offset: integer;
begin
  Result := 0;
  if SkinData.SkinManager.Effects.AllowGlowing and (CurrentState = 1) and (PBtnData^.HitCode in [HTCLOSE, HTMAXBUTTON, HTMINBUTTON]) then begin
    case PBtnData^.HitCode of
      HTCLOSE      : Result := SkinData.SkinManager.SkinData.BICloseGlowMargin;
      HTMAXBUTTON  : Result := SkinData.SkinManager.SkinData.BIMaxGlowMargin;
      HTMINBUTTON  : Result := SkinData.SkinManager.SkinData.BIMinGlowMargin;
    end;
  end
end;

procedure TacSBAnimation.OnAnimTimer(Sender: TObject);
begin
  if not Enabled then Exit;
  if Up then begin
    if CurrentLevel >= MaxIterations then begin
      CheckMouseLeave;
      if MaxIterations <> -1 then begin
        MaxIterations := -1;
        UpdateForm(MaxByte);
      end;
    end
    else begin
      UpdateForm(max(min(CurrentLevel * Step, MaxByte), 0));
      inc(CurrentLevel);
    end;
  end
  else begin
    if CurrentLevel <= 0 then begin
      CurrentState := -1;
      Enabled := False;
      if (ABmp <> nil) then FreeAndNil(ABmp);
      if (AForm <> nil) then FreeAndNil(AForm);
    end
    else begin
      UpdateForm(max(0, min(CurrentLevel * Step, MaxByte)));
      dec(CurrentLevel);
    end;
  end;
end;

procedure TacSBAnimation.StartAnimation(NewState: integer; ToUp : boolean);
begin
  if CurrentState <> NewState then begin
    CurrentState := NewState;
    if NewState <> 0 then begin
      if NewState = 2 then begin
        FreeAndNil(AForm);
        FreeAndNil(ABmp);
      end;
      CurrentLevel := 1;
      Up := ToUp;
      UpdateForm(min(Step, MaxByte));
      inc(CurrentLevel);
      if Maxiterations > 1 then Enabled := True;
    end
    else begin
      Up := False;
      dec(CurrentLevel);
      UpdateForm(min(Step, MaxByte));
      if Maxiterations > 1 then Enabled := True;
    end;
  end;
end;

function TacSBAnimation.Step: integer;
begin
  Result := max(MaxByte div MaxIterations, 0); 
end;

procedure TacSBAnimation.UpdateForm(const Blend: integer);
var
  R : TRect;
  iInsAfter, Flags : Cardinal;
  FBmpSize : TSize;
  OwnerHandle : THandle;
  DC : hdc;
  FBmpTopLeft : TPoint;
  FBlend: TBlendFunction;
begin
  if ABmp = nil then MakeImg;
  if AForm = nil then MakeForm;
  if (ABmp = nil) or (AForm = nil) then Exit;
  FBmpSize.cx := ABmp.Width;
  FBmpSize.cy := ABmp.Height;

  R := GetFormBounds;
  if FBmpSize.cx <> WidthOf(R) then begin // If image is hiding
    InflateRect(R, (FBmpSize.cx - WidthOf(R)) div 2, (FBmpSize.cy - HeightOf(R)) div 2);
  end;
  if BorderForm <> nil then OwnerHandle := BorderForm.AForm.Handle else OwnerHandle := FormHandle;
  if GetWindowLong(OwnerHandle, GWL_EXSTYLE) and WS_EX_TOPMOST = WS_EX_TOPMOST then iInsAfter := HWND_TOPMOST else iInsAfter := GetNextWindow(OwnerHandle, GW_HWNDPREV);
  Flags := SWP_NOACTIVATE or SWP_NOOWNERZORDER or SWP_NOSENDCHANGING;

  // Replacement of SetWindowPos (for Aero)
  AForm.Left := R.Left;
  AForm.Top := R.Top;
  AForm.Width := FBmpSize.cx;
  AForm.Height := FBmpSize.cy;

  FBmpTopLeft := Point(0, 0);
  FBlend.SourceConstantAlpha := Blend;
  FBlend.BlendOp := AC_SRC_OVER;
  FBlend.BlendFlags := 0;
  FBlend.AlphaFormat := AC_SRC_ALPHA;

  SetWindowPos(AForm.Handle, iInsAfter, 0, 0, 0, 0, Flags or SWP_NOMOVE or SWP_NOSIZE);
  DC := GetDC(0);
  SetWindowLong(AForm.Handle, GWL_EXSTYLE, GetWindowLong(AForm.Handle, GWL_EXSTYLE) or WS_EX_LAYERED or WS_EX_NOACTIVATE or WS_EX_TRANSPARENT);
  UpdateLayeredWindow(AForm.Handle, DC, nil, @FBmpSize, ABmp.Canvas.Handle, @FBmpTopLeft, clNone, @FBlend, ULW_ALPHA);
  ShowWindow(AForm.Handle, SW_SHOWNOACTIVATE);
  ReleaseDC(0, DC);
end;

{ TacGraphItem }

constructor TacGraphItem.Create;
begin
  SkinData := TsCommonData.Create(Self, True);
  SkinData.COC := COC_TsAdapter;
  Handler := nil;
end;

destructor TacGraphItem.Destroy;
begin
  if (Handler <> nil) then FreeAndNil(Handler);
  FreeAndNil(SkinData);
  inherited Destroy;
end;

procedure TacGraphItem.DoHook(Control: TControl);
begin
  if (Control.Tag = ExceptTag) then Exit;

  Self.Ctrl := Control;
  SkinData.FOwnerControl := Control;
  SkinData.FOwnerObject := TObject(Control);

  Handler := TacSpeedButtonHandler.Create(Ctrl, SkinData, SkinData.SkinManager, SkinData.SkinSection);
end;

{ TacAddedTitle }

constructor TacAddedTitle.Create;
begin
  FFont := TFont.Create;
  FFont.Color := clNone;
  FShowMainCaption := True;
end;

destructor TacAddedTitle.Destroy;
begin
  FreeAndNil(FFont);
  inherited;
end;

procedure TacAddedTitle.Repaint;
begin
  if not (csLoading in FOwner.ComponentState) then UpdateSkinCaption(FOwner);
end;

procedure TacAddedTitle.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
  Repaint;
end;

procedure TacAddedTitle.SetShowMainCaption(const Value: boolean);
begin
  if FShowMainCaption <> Value then begin
    FShowMainCaption := Value;
    Repaint;
  end;
end;

procedure TacAddedTitle.SetText(const Value: acString);
begin
  if FText <> Value then begin
    FText := Value;
    Repaint;
  end;
end;

{ TacMoveTimer }

procedure TacMoveTimer.TimeHandler;
begin
  if not Enabled then Exit;
  if BorderForm <> nil then begin
    SetFormBlendValue(BorderForm.AForm.Handle, BorderForm.SkinData.FCacheBmp, CurrentBlendValue)
  end
  else begin
    if GetWindowLong(FormHandle, GWL_EXSTYLE) and WS_EX_LAYERED <> WS_EX_LAYERED
      then SetWindowLong(FormHandle, GWL_EXSTYLE, GetWindowLong(FormHandle, GWL_EXSTYLE) or WS_EX_LAYERED);
    SetLayeredWindowAttributes(FormHandle, clNone, CurrentBlendValue, ULW_ALPHA);
  end;
  if CurrentBlendValue > BlendValue then CurrentBlendValue := CurrentBlendValue - BlendStep;
end;

{ TacMinTimer }

type
  TTBButtonX = packed record
    iBitmap: Integer;
    idCommand: Integer;
    fsState: Byte;
    fsStyle: Byte;
    bReserved: array[1..6] of Byte;
    dwData: Longint;
    iString: Integer;
  end;

  TacAppInfo = record
    Wnd : THandle;
  end;

{$IFNDEF DELPHI6UP}
function GetWindowThreadProcessId(hWnd: THandle; var dwProcessId: DWORD): DWORD; external user32 name 'GetWindowThreadProcessId';
{$ENDIF}

function GetAppRect : TRect;
const
  Buffer_Size = $1000;
var
  hDesktop : hwnd;
  hTray : hwnd;
  hRebar : hwnd;
  hTask : hwnd;
  hToolBar : hwnd;
  i, bCount : integer;

  processID : Cardinal;
  hProcess : THandle;
  ipRemoteBuffer : Pointer;
  ipBytesRead : Cardinal;
  ai : TacAppInfo;
  ButtonX: TTBButton;
  wndR : TRect;
  si : TSystemInfo;
  appHandle : THandle;
begin
  FillChar(Result, SizeOf(TRect), 0);

  GetSystemInfo(si);

  hDesktop := GetDesktopWindow; if hDesktop = 0 then Exit;
  hTray := FindWindowEx(hDesktop, 0, 'Shell_TrayWnd', nil); if hTray = 0 then Exit;
  hRebar := FindWindowEx(hTray, 0, 'ReBarWindow32', nil); if hRebar = 0 then Exit;
  hTask := FindWindowEx(hReBar, 0, 'MSTaskSwWClass', nil); if hTask = 0 then Exit;
  hToolBar := FindWindowEx(hTask, 0, 'ToolbarWindow32', nil); if hToolBar = 0 then Exit;

  bCount := SendMessage(hToolBar, TB_BUTTONCOUNT, 0, 0);
  if bCount < 1 then Exit;

  processId := 0;
  GetWindowThreadProcessId(hToolBar, processID);
  if processID = 0 then Exit;

  hProcess := OpenProcess(PROCESS_ALL_ACCESS, False, processId); if hProcess = 0 then Exit;
  ipRemoteBuffer := VirtualAllocEx(hProcess, nil, Buffer_Size, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
  if (ipRemoteBuffer = nil) then Exit;
  i := -1;
  while i < bCount do begin
    inc(i);
    if SendMessage(hToolbar, TB_GETBUTTON, i, integer(ipRemoteBuffer)) = 0 then Continue;

    if not ReadProcessMemory(hProcess, ipRemoteBuffer, @ButtonX, SizeOf(TTBButtonX), ipBytesRead) then Continue;
    if (ButtonX.fsStyle and $D {not TBSTYLE_BUTTON ...} <> 0) or (ButtonX.fsState and TBSTATE_HIDDEN = TBSTATE_HIDDEN) then Continue;
    if not ReadProcessMemory(hProcess, Pointer(ButtonX.dwData), @ai, SizeOf(TacAppInfo), ipBytesRead) then Continue;

    if ipBytesRead = 0 then Continue;
{$IFDEF D2009}
    if Application.MainFormOnTaskBar and (Application.MainForm <> nil) then appHandle := Application.MainForm.Handle else
{$ENDIF}
    appHandle := Application.Handle;
    if (ai.Wnd = appHandle) then begin
      if SendMessage(hToolBar, TB_GETITEMRECT, i, integer(ipRemoteBuffer)) <> 0 then ReadProcessMemory(hProcess, ipRemoteBuffer, @Result, SizeOf(TRect), ipBytesRead);
      if ipBytesRead <> 0 then begin
        GetWindowRect(hToolBar, wndR);
        OffsetRect(Result, wndR.Left, wndR.Top);
      end;
      Break;
    end;
  end;
  VirtualFreeEx(hProcess, ipRemoteBuffer, 0, MEM_RELEASE);
  CloseHandle(hProcess);
end;

constructor TacMinTimer.Create(AOwner: TComponent);
begin
  inherited;
  AnimForm := nil;
  AlphaBmp := nil;
  Minimized := False;
  AlphaFormWasCreated := False;
end;

constructor TacMinTimer.CreateOwned(AOwner: TComponent; ChangeEvent : boolean);
begin
  inherited CreateOwned(AOwner, True);
  InitData;
  SavedImage := TBitmap.Create;
end;

destructor TacMinTimer.Destroy;
begin
  if AlphaFormWasCreated and Assigned(AnimForm)
    then FreeAndNil(AnimForm);
  if Assigned(SavedImage) then FreeAndNil(SavedImage);
  if AlphaBmp <> nil then FreeAndNil(AlphaBmp);
  inherited;
end;

function TacMinTimer.GetRectTo: TRect;
var
  R : TRect;
begin
  if ShellTrayWnd <> 0 then begin
    if not AeroIsEnabled then Result := GetAppRect else Result.Left := Result.Right;
    if Result.Left = Result.Right then begin
      GetWindowRect(ShellTrayWnd, R);
      Result := R;
      if R.Top = 0 then begin
        if R.Left = 0 then begin
          if WidthOf(R) > HeightOf(R) then TBPosition := BF_TOP else TBPosition := BF_LEFT
        end
        else TBPosition := BF_RIGHT;
      end
      else begin
        if Between(R.Left, -4, 0) {For windows without themes} then TBPosition := BF_BOTTOM else TBPosition := BF_RIGHT;
      end;
      case TBPosition of
        BF_LEFT : Result := Rect(R.Right, YFrom, R.Right, YFrom);
        BF_TOP : Result := Rect(XFrom, R.Bottom, XFrom, R.Bottom);
        BF_RIGHT : Result := Rect(R.Left, YFrom, R.Left, YFrom)
        else { BF_BOTTOM } Result := Rect(XFrom, R.Top, XFrom, R.Top);
      end;
    end;
  end
  else Result := Rect(0, 0, 0, 0);
end;

procedure TacMinTimer.InitData;
begin
  Interval := 15;//acTimerInterval;
  if FOwner is TsSkinProvider then begin
    sp := TsSkinProvider(FOwner);
    BorderForm := sp.BorderForm;
{$IFDEF DELPHI7UP}
    if sp.Form.AlphaBlend then AlphaFrom := sp.Form.AlphaBlendValue else
{$ENDIF}
    AlphaFrom := MaxByte;
  end
  else begin
    sp := nil;
    AlphaFrom := MaxByte;
  end;
  StepCount := max(1, sp.SkinData.SkinManager.AnimEffects.Minimizing.Time div Interval);
  AlphaOrigin := AlphaFrom;

  if FormHandle = 0 then begin
    FormHandle := sp.Form.Handle;
    CurrentAlpha := AlphaFrom;
  end;

  if (CurrentAlpha <= 0) and Minimized then begin // Minimized
    CurLeft := RectTo.Left;
    CurTop := RectTo.Top;
    CurRight := RectTo.Right;
    CurBottom := RectTo.Bottom;
  end
  else if (CurrentAlpha >= AlphaFrom) then begin // Normal
    if BorderForm <> nil then RectFrom := BorderForm.AForm.BoundsRect else GetWindowRect(FormHandle, RectFrom);
    XFrom := RectFrom.Left + WidthOf(RectFrom) div 2;
    YFrom := RectFrom.Top + HeightOf(RectFrom) div 2;

    UpdateDstRect;

    CurLeft := RectFrom.Left;
    CurTop := RectFrom.Top;
    CurRight := RectFrom.Right;
    CurBottom := RectFrom.Bottom;
  end;

  BlendStep := (AlphaFrom - AlphaTo) / Max(1, StepCount - 1);
  if AlphaBmp = nil then AlphaBmp := CreateBmp32(WidthOf(RectFrom), HeightOf(RectFrom)) else begin
    AlphaBmp.Width := WidthOf(RectFrom);
    AlphaBmp.Height := HeightOf(RectFrom);
  end;
  SetStretchBltMode(AlphaBmp.Canvas.Handle, 0);
  
  if BorderForm <> nil then begin
    AnimForm := BorderForm.AForm;
  end
  else begin
    if AnimForm <> nil then AnimForm.Free;
    AnimForm := MakeCoverForm(FormHandle);
    SetWindowRgn(AnimForm.Handle, 0, False);
  end;
end;

procedure TacMinTimer.TimeHandler;
var
  X, Y : integer;
  W, H : real;
  p : TPoint;
  bAnim : boolean;
begin
  if InHandler then Exit;
  InHandler := True;
  // Check if direction must be changed
  if not Minimized then begin
    if (sp.FormState and FS_ANIMRESTORING = FS_ANIMRESTORING) then begin
      Minimized := True;
    end
  end
  else begin
    if (sp.FormState and FS_ANIMMINIMIZING = FS_ANIMMINIMIZING) then begin
      Minimized := False;
    end
  end;
  if (AnimForm = nil) or not AnimForm.HandleAllocated then begin
    Enabled := False;
    InHandler := False;
    Exit;
  end;

  if sp.BorderForm <> nil then sp.BorderForm.ExBorderShowing := True;

  if not Minimized then begin // If in minimizing process
    FillDC(AlphaBmp.Canvas.Handle, Rect(0, 0, AlphaBmp.Width, alphaBmp.Height), 0);
    CurLeft := CurLeft + DeltaX + DeltaW;
    CurRight := CurRight + DeltaX - DeltaW;
    CurTop := CurTop + DeltaY + DeltaH;
    CurBottom := CurBottom + DeltaY - DeltaH;
    CurrentAlpha := max(0, Round(CurrentAlpha - BlendStep));
    if CurrentAlpha <= 0 then begin // Finish of animation
      Enabled := False;
      if sp <> nil then begin
        sp.SetHotHT(0);
        sp.FormState := sp.FormState and not FS_ANIMMINIMIZING;
        SetWindowLong(sp.Form.Handle, GWL_EXSTYLE, GetWindowLong(sp.Form.Handle, GWL_EXSTYLE) and not WS_EX_LAYERED);
        if sp.BorderForm <> nil then begin
//          ShowWindow(sp.BorderForm.AForm.Handle, SW_HIDE);
          FreeAndNil(sp.BorderForm.AForm);
{$IFDEF D2005}
          if {$IFDEF D2007}Application.MainformOnTaskBar and{$ENDIF} (Application.MainForm <> nil) then SetActiveWindow(Application.MainForm.Handle);
{$ENDIF}
          sp.BorderForm.ExBorderShowing := False;
        end
        else begin
          ShowWindow(AnimForm.Handle, SW_HIDE);
        end;
      end;
      Minimized := True;
    end
    else begin
      W := max(0, CurRight - CurLeft);
      H := max(0, CurBottom - CurTop);
      X := Round(CurLeft + W / 2);
      Y := Round(CurTop + H / 2);
      StretchBlt(AlphaBmp.Canvas.Handle, Round(AlphaBmp.Width - W) div 2, Round(AlphaBmp.Height - H) div 2, Round(W), Round(H), SavedImage.Canvas.Handle, 0, 0, SavedImage.Width, SavedImage.Height, SRCCOPY);

      p := Point(X - AlphaBmp.Width div 2, Y - AlphaBmp.Height div 2);
      SetFormBlendValue(AnimForm.Handle, AlphaBmp, CurrentAlpha, @p);
      SetWindowPos(AnimForm.Handle, ShellTrayWnd, 0, 0, 0, 0, SWP_NOMOVE or SWP_SHOWWINDOW or SWP_NOSIZE or SWP_NOREDRAW or SWP_NOACTIVATE or SWP_NOSENDCHANGING or SWP_NOOWNERZORDER);
    end;
  end
  else begin // If in restoring process
    CurLeft := CurLeft - DeltaX - DeltaW;
    CurRight := CurRight - DeltaX + DeltaW;
    CurTop := CurTop - DeltaY - DeltaH;
    CurBottom := CurBottom - DeltaY + DeltaH;
    CurrentAlpha := min(MaxByte, Round(CurrentAlpha + BlendStep));
    if (CurrentAlpha >= AlphaFrom) then begin // Finish of animation
      Enabled := False;
      p := RectFrom.TopLeft;
      SetFormBlendValue(AnimForm.Handle, SavedImage, AlphaOrigin, @p);
      bAnim := acGetAnimation;
      acSetAnimation(False);
      if IsZoomed(FormHandle)
        then ShowWindow(FormHandle, SW_SHOWMAXIMIZED)
        else ShowWindow(FormHandle, SW_SHOWNOACTIVATE); // v7
      acSetAnimation(bAnim);
      SetWindowPos(AnimForm.Handle, 0, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOREDRAW or SWP_NOACTIVATE or SWP_NOSENDCHANGING or SWP_NOOWNERZORDER);
      // Hide form
//      SetWindowPos(sp.Form.Handle, AnimForm.Handle, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOREDRAW or SWP_NOACTIVATE or SWP_NOSENDCHANGING or SWP_NOOWNERZORDER);
{$IFDEF DELPHI7UP}
      if (sp <> nil) and sp.Form.AlphaBlend then SetLayeredWindowAttributes(sp.Form.Handle, clNone, sp.Form.AlphaBlendValue, ULW_ALPHA) else
{$ENDIF}
      SetWindowLong(FormHandle, GWL_EXSTYLE, GetWindowLong(FormHandle, GWL_EXSTYLE) and not WS_EX_LAYERED);
      if sp <> nil then begin
        sp.fAnimating := False;
        sp.FormState := sp.FormState and not FS_ANIMRESTORING;
        if sp.BorderForm <> nil then sp.BorderForm.ExBorderShowing := False;
      end;

      SetWindowRgn(FormHandle, 0, False); // Remove in Beta
//      UpdateWindow(FormHandle);
//      InvalidateRect(FormHandle, nil, False);
      RedrawWindow(FormHandle, nil, 0, {RDW_ERASE or }RDW_INVALIDATE or RDW_ALLCHILDREN or RDW_UPDATENOW or RDW_FRAME);

      Minimized := False;
      if (sp <> nil) and (sp.BorderForm <> nil) and (sp.BorderForm.AForm = AnimForm) then begin
        sp.BorderForm.UpdateExBordersPos(True);
        AnimForm := nil;
      end
      else begin
        SetWindowPos(AnimForm.Handle, FormHandle, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOREDRAW or SWP_NOACTIVATE or SWP_NOSENDCHANGING or SWP_NOOWNERZORDER);
        FreeAndnil(AnimForm);
      end;
      SetFocus(FormHandle);
      if Assigned(Application.OnRestore) then Application.OnRestore(Application);
    end
    else begin
      W := max(0, CurRight - CurLeft);
      H := max(0, CurBottom - CurTop);
      X := Round(CurLeft + W / 2);
      Y := Round(CurTop + H / 2);
      StretchBlt(AlphaBmp.Canvas.Handle, Round(AlphaBmp.Width - W) div 2, Round(AlphaBmp.Height - H) div 2, Round(W), Round(H), SavedImage.Canvas.Handle, 0, 0, SavedImage.Width, SavedImage.Height, SRCCOPY);
      p := Point(X - AlphaBmp.Width div 2, Y - AlphaBmp.Height div 2);
      SetFormBlendValue(AnimForm.Handle, AlphaBmp, CurrentAlpha, @p);
      SetWindowPos(AnimForm.Handle, ShellTrayWnd, 0, 0, 0, 0, SWP_NOMOVE or SWP_SHOWWINDOW or SWP_NOSIZE or SWP_NOREDRAW or SWP_NOACTIVATE or SWP_NOSENDCHANGING or SWP_NOOWNERZORDER);
    end;
  end;
  InHandler := False;
end;

procedure TacMinTimer.UpdateDstRect;
begin
  RectTo := GetRectTo;
  XTo := RectTo.Left + WidthOf(RectTo) div 2;
  YTo := RectTo.Top + HeightOf(RectTo) div 2;

  DeltaX := (XTo - XFrom) / StepCount;
  DeltaY := (YTo - YFrom) / StepCount;
  DeltaW := (WidthOf(RectFrom) - WidthOf(RectTo)) / (2 * StepCount);
  DeltaH := (HeightOf(RectFrom) - HeightOf(RectTo)) / (2 * StepCount);
  AlphaTo := 0;
end;

initialization

finalization
  if hDWMAPI > 0 then FreeLibrary(hDWMAPI);

end.



