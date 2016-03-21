unit acSBUtils;
{$I sDefs.inc}
{.$DEFINE LOGGED}

interface

uses Windows, Messages, sCommonData, Controls, sSkinManager, Graphics, Classes, ExtCtrls, Grids, CommCtrl, acAlphaImageList,
  Forms{$IFNDEF DELPHI5}, types{$ENDIF}, ComCtrls, StdCtrls, sConst, TypInfo;

const
  acPropStr         = 'ACSBSC';
  CSBS_NORMAL       = 0;
  CSBS_HOTTRACKED   = 2;
  CSBS_THUMBALWAYS  = 4;
  CSBS_VISIBLE      = 8;

  THUMBTRACK_SNAPDIST = 24;

  MINTHUMBSIZE_NT4   = 8;
  MINTHUMBSIZE_2000  = 6;

  SM_CXVERTSB = 1;
  SM_CYVERTSB = 0;
  SM_CXHORZSB = 0;
  SM_CYHORZSB = 1;

  SM_SCROLL_LENGTH = 0;

  COOLSB_NONE = -1;
  HTSCROLL_NONE	= -1;
  HTSCROLL_NORMAL = -1;
  SYSTEM_METRIC = -1;

  HTSCROLL_LEFT	= SB_LINELEFT;
  HTSCROLL_UP = SB_LINEUP;
  HTSCROLL_DOWN = SB_LINEDOWN;
  HTSCROLL_RIGHT = SB_LINERIGHT;
  HTSCROLL_THUMB = SB_THUMBTRACK;
  HTSCROLL_PAGELEFT = SB_PAGELEFT;
  HTSCROLL_PAGERIGHT = SB_PAGERIGHT;
  HTSCROLL_PAGEUP   = SB_PAGEUP;
  HTSCROLL_PAGEDOWN = SB_PAGEDOWN;

  COOLSB_TIMERID1 = 65533;	// initial timer
  COOLSB_TIMERID2 = 65534;	// scroll message timer
  COOLSB_TIMERID3 = 65522;   	// mouse hover timer
  COOLSB_TIMERINTERVAL1	= 300;
  COOLSB_TIMERINTERVAL2	= 55;
  COOLSB_TIMERINTERVAL3	= 20;	// mouse hover time

type
  TDropMarkMode = (dmmNone, dmmLeft, dmmRight);
  THeaderPaintInfo = record
    TargetCanvas: TCanvas;
    Column: TCollectionItem;
    PaintRectangle: TRect;
    TextRectangle: TRect;
    IsHoverIndex, IsDownIndex, IsEnabled, ShowHeaderGlyph, ShowSortGlyph, ShowRightBorder: Boolean;
    DropMark: TDropMarkMode;
    GlyphPos, SortGlyphPos: TPoint;
  end;
  THeaderPaintElements = set of (hpeBackground, hpeDropMark, hpeHeaderGlyph, hpeSortGlyph, hpeText);

  TAdvancedHeaderPaintEvent = procedure(Sender: TPersistent; var PaintInfo: THeaderPaintInfo; const Elements: THeaderPaintElements) of object;
  THeaderPaintQueryElementsEvent = procedure(Sender: TPersistent; var PaintInfo: THeaderPaintInfo; var Elements: THeaderPaintElements) of object;

  PAdvancedHeaderPaintEvent = ^TAdvancedHeaderPaintEvent;
  PHeaderPaintQueryElementsEvent = ^THeaderPaintQueryElementsEvent;

  TacScrollWnd = class;
  TacScrollBar = class(TObject)
    fScrollFlags : word;                // flags
    fScrollVisible : boolean;
    ScrollInfo : TScrollInfo;		// positional data (range, position, page size etc)
    nArrowLength : integer;             // perpendicular size (height of a horizontal, width of a vertical)
    nArrowWidth : integer;              // parallel size (width of horz, height of vert)

    nButSizeBefore : integer;           // size to the left / above the bar
    nButSizeAfter : integer;            // size to the right / below the bar
    fButVisibleBefore : boolean;        // if the buttons to the left are visible
    fButVisibleAfter : boolean;         // if the buttons to the right are visible

    nBarType : word;                    // SB_HORZ / SB_VERT
    fFlatScrollbar : word;              // do we display flat scrollbars?
    nMinThumbSize : integer;
    sw : TacScrollWnd;
  end;

  TacSpeedButtonHandler = class(TObject)
  public
    WndRect : TRect;
    WndSize : TSize;
    WndPos : TPoint;
    ParentRect : TRect;
    ParentWnd : hwnd;
    Ctrl : TControl;

    OldWndProc : TWndMethod;
    OldProc : Pointer;
    SkinManager : TsSkinManager;
    SkinData : TsCommonData;
    Destroyed : boolean;

    NewWndProcInstance : Pointer;
    constructor Create(Btn : TControl; ASkinData : TsCommonData; ASkinManager : TsSkinManager; const SkinSection : string; Repaint : boolean = True); virtual;
    destructor Destroy; override;
    function CallPrevWndProc(Ctrl : TControl; Msg : longint; WParam : longint; var LParam : longint) : longint;
    procedure acWndProc(var Message: TMessage); virtual;
    procedure AC_WMPaint(var Message : TWMPaint);
    procedure PrepareCache;
    procedure DrawCaption;
    procedure DrawGlyph;
    function Caption : acString;
    function ImgRect : TRect;
    function GlyphHeight : integer;
    function CaptionRect : TRect;
    function TextRectSize : TSize;
    function GlyphWidth : integer;
    procedure DoDrawText(var Rect: TRect; Flags: Longint);
    function CurrentState : integer;
  end;

  TacMainWnd = class(TObject)
  public
    DlgMode : boolean;
    Caption : AcString;

    WndRect : TRect;
    WndSize : TSize;
    WndPos : TPoint;
    ParentRect : TRect;
    ParentWnd : hwnd;

    OldWndProc : TWndMethod;
    OldProc : Pointer;
    CtrlHandle : hwnd;
    SkinManager : TsSkinManager;
    SkinData : TsCommonData;
    DontRepaint : boolean;
    ParamsChanged : boolean;
    StdColor, StdFontColor : TColor;
    Destroyed : boolean;
    OwnSkinData : boolean;

    NewWndProcInstance : Pointer;
    Tag : integer;
    constructor Create(AHandle : hwnd; ASkinData : TsCommonData; ASkinManager : TsSkinManager; const SkinSection : string; Repaint : boolean = True); virtual;
    procedure SaveStdParams; virtual;
    procedure RestoreStdParams; virtual;
    procedure SetSkinParams; virtual;
    destructor Destroy; override;
    function CallPrevWndProc(Handle : hwnd; Msg : longint; WParam : longint; var LParam : longint) : longint;
    procedure acWndProc(var Message: TMessage); virtual;
  end;

  TacStaticWnd = class(TacMainWnd)
  public
    procedure AC_WMPaint(var Message : TWMPaint); virtual;
    function PaintText : boolean; virtual;
    procedure acWndProc(var Message: TMessage); override;
  end;

  TacEdgeWnd = class(TacStaticWnd)
  public
    procedure AC_WMPaint(var Message : TWMPaint); override;
    procedure acWndProc(var Message: TMessage); override;
  end;

  TacIconWnd = class(TacStaticWnd)
  public
    IsBmp : boolean;
    FBmp : TBitmap;
    constructor Create(AHandle : hwnd; ASkinData : TsCommonData; ASkinManager : TsSkinManager; const SkinSection : string; Repaint : boolean = True); override;
    destructor Destroy; override;
    function PaintText : boolean; override;
  end;

  TacDlgPanelWnd = class(TacMainWnd) // Used in Open/Save picture dialogs (preview panel)
  public
    Panel : TPanel;
    constructor Create(AHandle : hwnd; ASkinData : TsCommonData; ASkinManager : TsSkinManager; const SkinSection : string; Repaint : boolean = True); override;
    procedure PrepareCache; dynamic;
    procedure AC_WMNCPaint(aDC : hdc);
    procedure AC_WMPaint(aDC : hdc);
    procedure acWndProc(var Message: TMessage); override;
    procedure SetSkinParams; override;
  end;

  TacLinkWnd = class(TacStaticWnd)
  public
    procedure acWndProc(var Message: TMessage); override;
    function PaintText : boolean; override;
  end;

  TacBtnWnd = class(TacMainWnd)
  public
    constructor Create(AHandle : hwnd; ASkinData : TsCommonData; ASkinManager : TsSkinManager; const SkinSection : string; Repaint : boolean = True); override;
    function CtrlStyle : dword;
    function Down : boolean;
    function CurrentState : integer;
    procedure DrawCaption; virtual;
    procedure DrawGlyph; virtual;
    function GlyphSize : TSize; virtual;
    procedure DoDrawText(var Rect: TRect; Flags: Longint); virtual;
    function CaptionRect : TRect; virtual;
    function MaxCaptionWidth : integer; virtual;
    function TextRectSize : TSize; virtual;
    procedure PrepareCache; virtual;
    procedure AC_WMPaint(Message : TWMPaint);
    procedure acWndProc(var Message: TMessage); override;
    procedure Repaint;
    procedure RestoreStdParams; override;
    procedure SetSkinParams; override;
  end;

  TacBitBtnWnd = class(TacBtnWnd)
  public
    hBmp : hBitmap;
    hIco : hIcon;
    function CaptionRect : TRect; override;
    function GlyphRect : TRect;
    function GlyphSize : TSize; override;
    procedure DrawGlyph; override;
    function MaxCaptionWidth : integer; override;
  end;

{$IFDEF D2009}
  TacButtonWnd = class(TacBtnWnd)
  public
    Btn : TButton;
    function HaveImage : boolean;
    function CaptionRect : TRect; override;
    function GlyphIndex : integer;
    function GlyphRect : TRect;
    function GlyphSize : TSize; override;
    procedure DrawGlyph; override;
    constructor Create(AHandle : hwnd; ASkinData : TsCommonData; ASkinManager : TsSkinManager; const SkinSection : string; Repaint : boolean = True); override;
  end;
{$ENDIF}      

  TacSizerWnd = class(TacMainWnd)
  public
    procedure AC_WMPaint(const Message : TWMPaint);
    procedure acWndProc(var Message: TMessage); override;
  end;

  TacSpinWnd = class(TacMainWnd)
  public
    lOffset : integer;
    bMousePressed : boolean;
    Btn1State, Btn2State : integer;
    function IsVertical : boolean; virtual;
    constructor Create(AHandle : hwnd; ASkinData : TsCommonData; ASkinManager : TsSkinManager; const SkinSection : string; Repaint : boolean = True); override;
    procedure PrepareCache;
    procedure AC_WMPaint(Message : TWMPaint);
    procedure acWndProc(var Message: TMessage); override;
  end;

  TAPoint = array of TPoint;

  TacTrackWnd = class(TacMainWnd)
  public
    bMousePressed : boolean;
    TrackBarNdx : integer;
    TickHeight : integer;
    iStep : real;
    function IsVertical : boolean; virtual;
    constructor Create(AHandle : hwnd; ASkinData : TsCommonData; ASkinManager : TsSkinManager; const SkinSection : string; Repaint : boolean = True); override;
    procedure PrepareCache;
    procedure PaintBody;
    procedure PaintBar;
    procedure PaintThumb(i: integer);
    procedure PaintTicksHor;
    procedure PaintTicksVer;
    procedure PaintTick(P : TPoint; Horz : boolean);
    function TickMarks : TTickMark;
    function TickStyle : TTickStyle;
    function TickCount : integer;
    function TicksArray : TAPoint;
    function TickPos(i: integer): integer;
    function ThumbRect: TRect;
    function ChannelRect: TRect;
    function Mode : integer;
    procedure AC_WMPaint(Message : TWMPaint);
    procedure acWndProc(var Message: TMessage); override;
  end;

  TacCheckBoxWnd = class(TacMainWnd)
  public
    OwnerDraw : boolean;
    function State : TCheckBoxState;
    function CtlState : integer;
    function CheckRect: TRect;
    function SkinCheckRect(i : integer): TRect;
    function SkinGlyphWidth(i : integer) : integer;
    function SkinGlyphHeight(i : integer) : integer;
    procedure DrawCheckText;
    procedure DrawSkinGlyph(i : integer);

    function GlyphMaskIndex(State : TCheckBoxState) : smallint;
    procedure PrepareCache;
    procedure AC_WMPaint(Message : TWMPaint);
    constructor Create(AHandle : hwnd; ASkinData : TsCommonData; ASkinManager : TsSkinManager; const SkinSection : string; Repaint : boolean = True); override;
    procedure acWndProc(var Message: TMessage); override;
  end;

  TacToolBarWnd = class(TacMainWnd)
  public
    ClientRect : TRect;
    BorderWidth : integer;
    HotBtn : integer;
    procedure PrepareCache;
    procedure DrawButtons(Bmp : TBitmap);
    procedure DrawBtn(Index : integer; R : TRect; DC : hdc);

    function GetButtonRect(Index : integer) : TRect;
    function Count : integer;
    function ButtonRect(Index : integer) : TRect;
    procedure AC_WMPaint(Message : TWMPaint);
    procedure AC_WMPrint(Message : TWMPaint);
    procedure AC_WMNCPaint(Message : TMessage);
    procedure acWndProc(var Message: TMessage); override;
  end;

  TacTransPanelWnd = class(TacMainWnd)
  public
    procedure AC_WMPaint(Message : TWMPaint); virtual;
    procedure acWndProc(var Message: TMessage); override;
  end;

  TacGroupBoxWnd = class(TacMainWnd)
  public
    constructor Create(AHandle : hwnd; ASkinData : TsCommonData; ASkinManager : TsSkinManager; const SkinSection : string; Repaint : boolean = True); override;
    function CaptionRect: TRect;
    procedure PrepareCache;
    procedure WriteText(R : TRect);
    procedure AC_WMPaint(Message : TWMPaint);
    procedure acWndProc(var Message: TMessage); override;
  end;

  TacTabWnd = class(TacMainWnd)
  public
    function DisplayRect: TRect;
    procedure PrepareCache;
    procedure AC_WMPaint(Message : TWMPaint);
    procedure AC_WMNCPaint(Message : TWMPaint);
    procedure acWndProc(var Message: TMessage); override;
  end;

  TacScrollWnd = class(TacMainWnd)
  public
    bars : word;
    sBarHorz : TacScrollBar;
    sBarVert : TacScrollBar;
    fThumbTracking : boolean;
    fLeftScrollbar : boolean;
    cxLeftEdge, cxRightEdge : integer;
    cyTopEdge,  cyBottomEdge : integer;
    bPreventStyleChange : boolean; // To prevent calling original WindowProc in response to our own temporary style change (fixes TreeView problem)

    destructor Destroy; override;
    procedure acWndProc(var Message: TMessage); override;
  end;

  TacPanelWnd = class(TacMainWnd)
  public
    Panel : TPanel;
    constructor Create(AHandle : hwnd; ASkinData : TsCommonData; ASkinManager : TsSkinManager; const SkinSection : string; Repaint : boolean = True); override;
    procedure PrepareCache; virtual;
    procedure AC_WMNCPaint(aDC : hdc);
    procedure AC_WMPaint(var aDC : hdc); virtual;
    procedure acWndProc(var Message: TMessage); override;
    procedure WriteText(R : TRect; aCanvas : TCanvas = nil; aDC : hdc = 0);
  end;

{$IFNDEF NOMNUHOOK}
  TacMnuWnd = class(TacScrollWnd)
  public
    RgnChanged : integer;
    procedure PrepareCache; dynamic;
    procedure acWndProc(var Message: TMessage); override;
    constructor Create(AHandle : hwnd; ASkinData : TsCommonData; ASkinManager : TsSkinManager; const SkinSection : string; Repaint : boolean = True); override;
  end;
{$ENDIF}

  TacBaseWnd = class(TacScrollWnd)
  public
    procedure acWndProc(var Message: TMessage); override;
  end;

  TacMDIWnd = class(TacBaseWnd)
  public
    FForm : TForm;
    MDISkinData : TsCommonData;
    SkinProvider : TObject;
    destructor Destroy; override;
    procedure acWndProc(var Message: TMessage); override;
    procedure UpdateGraphControls;
  end;

  ////////////////////////////////////////////
  // TCustomEdit, TCustomListbox compatible //
  ////////////////////////////////////////////
  TacEditWnd = class(TacBaseWnd)
  public
    Color : TColor;
    FocusColor : TCOlor;
    FrameColor : integer;
    Brush : TBrush;
    constructor Create(AHandle : hwnd; ASkinData : TsCommonData; ASkinManager : TsSkinManager; const SkinSection : string; Repaint : boolean = True); override;
    procedure acWndProc(var Message: TMessage); override;
    procedure SaveStdParams; override;
    procedure SetSkinParams; override;
    procedure RestoreStdParams; override;
  end;

  //////////////////
  // ComboListBox //
  //////////////////
  TacComboListWnd = class(TacEditWnd)
  public
    Showed : boolean;
    SimplyBox : boolean;
    constructor Create(AHandle : hwnd; ASkinData : TsCommonData; ASkinManager : TsSkinManager; const SkinSection : string; Repaint : boolean = True); override;
    constructor CreateEx(AHandle : hwnd; ASkinData : TsCommonData; ASkinManager : TsSkinManager; const SkinSection : string; Repaint : boolean; Simply : boolean);
    destructor Destroy; override;
    procedure acWndProc(var Message: TMessage); override;
  end;

  ////////////////////////////////
  // TCustomListView compatible //
  ////////////////////////////////
  TacListViewWnd = class(TacEditWnd)
  public
    FhWndHeader : HWnd;
    FhHeaderProc : Pointer;
    FhDefHeaderProc : Pointer;
    FPressedColumn : Integer;
    HoverColIndex : integer;
    ListLineHeight : Integer;
    FFlag: Boolean;
    function ViewStyle : TViewStyle;
    constructor Create(AHandle : hwnd; ASkinData : TsCommonData; ASkinManager : TsSkinManager; const SkinSection : string; Repaint : boolean = True); override;
    procedure acWndProc(var Message: TMessage); override;
    procedure RestoreStdParams; override;

    procedure SaveStdParams; override;
    procedure SetSkinParams; override;
    // Header
    procedure ColumnSkinPaint(ControlRect : TRect; cIndex : Integer; DC : hdc);
    function AllColWidth : integer;
    function HotTrack : boolean;
    procedure HeaderWndProc(var Message: TMessage);
    function GetHeaderColumnRect(Index: Integer): TRect;
    procedure PaintHeader(DC : hdc);
  end;

  ////////////////////////////
  // TCustomGrid compatible //
  ////////////////////////////
  TacGridWnd = class(TacEditWnd)
  public
    FixedColor : TColor;
    FooterColor : TColor;
    FooterCellColor : TColor;
    TitleFontColor : TColor;
    TitleColor : TColor;
    IndColor : TColor;
    SelectionColor : TColor;
    SelectionTextColor : TColor;
    GridLineColor : TColor;
    GridFixedLineColor : TColor;
    FixedGradientFrom : TColor;
    FixedGradientTo : TColor;
    FixedGradientMirrorFrom : TColor;
    FixedGradientMirrorTo : TColor;
{$IFDEF D2010}
    DrawingStyle : TGridDrawingStyle;
{$ENDIF}
    procedure acWndProc(var Message: TMessage); override;
    procedure SaveStdParams; override;
    procedure SetSkinParams; override;
    procedure RestoreStdParams; override;
  end;

  ////////////////////////
  // TGridEh compatible //
  ////////////////////////
  TacGridEhWnd = class(TacGridWnd)
  public
    procedure acWndProc(var Message: TMessage); override;
  end;

  ////////////////////////////////
  // TCustomTreeView compatible //
  ////////////////////////////////
  TacTreeViewWnd = class(TacEditWnd)
  public
    procedure acWndProc(var Message: TMessage); override;
    procedure SetSkinParams; override;
    procedure RestoreStdParams; override;
    destructor Destroy; override;
  end;

  ////////////////////////////////
  // TCustomComboBox compatible //
  ////////////////////////////////
  TacComboBoxWnd = class(TacEditWnd)
  public
    FListHandle : hwnd;
    FDefListProc : pointer;
    LBSkinData : TsCommonData;
    ListSW : TacComboListWnd;
    LBoxOpening : boolean;
    function DroppedDown : boolean;
    function ButtonHeight : integer;
    function ButtonRect: TRect; virtual;
    procedure PaintButton(DC : hdc);
    procedure RepaintButton;
    procedure PaintText;
    procedure PrepareSimple;
    constructor Create(AHandle : hwnd; ASkinData : TsCommonData; ASkinManager : TsSkinManager; const SkinSection : string; Repaint : boolean = True); override;
    destructor Destroy; override;
    procedure Invalidate;
    procedure acWndProc(var Message: TMessage); override;
  end;

  ///////////////////////////////////
  // TVirtualStringTree compatible //
  ///////////////////////////////////
  TacVirtualTreeViewWnd = class(TacEditWnd)
  public
    CompressedTextColor : TColor;
    FileTextColor : TColor;
    FolderTextColor : TColor;
    OwnerDraw : boolean;
    PropInfo: PPropInfo;
    procedure AdvancedHeaderDraw(Sender: TPersistent; var PaintInfo: THeaderPaintInfo; const Elements: THeaderPaintElements);
    procedure HeaderDrawQueryElements(Sender: TPersistent; var PaintInfo: THeaderPaintInfo; var Elements: THeaderPaintElements);

    procedure SaveStdParams; override;
    procedure SetSkinParams; override;
    procedure RestoreStdParams; override;
    function GetBorderDimensions: TSize;
    procedure acWndProc(var Message: TMessage); override;
  end;

  // TacWWComboBoxWnd
  TacWWComboBoxWnd = class(TacComboBoxWnd)
  private
    ListBox : TCustomListBox;
    ListBoxSW : TacScrollWnd;
    ListBoxSkinData : TsCommonData;
    FShowButton: Boolean;
    function GetShowButton(aCtrl: TWinControl): Boolean;
  public
    function ButtonRect: TRect;  override;
    constructor Create(aCtrl: TWinControl; ASkinData : TsCommonData; ASkinManager : TsSkinManager; SkinSection : string; Repaint : boolean = True); reintroduce;
    destructor Destroy; override;
    procedure acWndProc(var Message: TMessage); override;
  end;

  // Windows TabControl
  TacTabControlWnd = class(TacMainWnd)
  public
    BtnSW : TacSpinWnd;
    function TabCount : integer;
    function ClientRect : TRect; virtual;
    function PageRect : TRect; virtual;
    function TabRect(const Index : integer) : TRect;
    function TabRow(TabIndex : integer) : integer;
    function TabsRect: TRect;
    function TabPosition : TTabPosition;
    function Style : TTabStyle;

    function ActiveTabIndex : integer;
    function SkinTabRect(Index : integer; Active : boolean) : TRect;

    procedure CheckUpDown;
    procedure DrawSkinTabs(const CI : TCacheInfo);
    procedure DrawSkinTab(Index: Integer; State : integer; Bmp : TBitmap; OffsetPoint : TPoint); overload;
    procedure DrawSkinTab(Index: Integer; State : integer; DC : hdc); overload;

    procedure AC_WMPaint(var Message : TWMPaint);
    constructor Create(AHandle : hwnd; ASkinData : TsCommonData; ASkinManager : TsSkinManager; const SkinSection : string; Repaint : boolean = True); override;
    destructor Destroy; override;
    procedure acWndProc(var Message: TMessage); override;
  end;

  TacPageWnd = class(TacMainWnd)
  public
    Page : TTabSheet;
    function TabPosition : TTabPosition;
    procedure PrepareCache;
    procedure AC_WMEraseBKGnd(var Message : TWMPaint);
    procedure acWndProc(var Message: TMessage); override;
    constructor Create(AHandle : hwnd; ASkinData : TsCommonData; ASkinManager : TsSkinManager; const SkinSection : string; Repaint : boolean = True); override;
  end;

  // TPageControl from Delphi
  TacPageControlWnd = class(TacTabControlWnd)
  public
    function ClientRect : TRect; override;
    function PageRect : TRect; override;
    procedure InitPages(Skinned : boolean);
    procedure acWndProc(var Message: TMessage); override;
    constructor Create(AHandle : hwnd; ASkinData : TsCommonData; ASkinManager : TsSkinManager; const SkinSection : string; Repaint : boolean = True); override;
  end;

  TacToolBarVCLWnd = class(TacMainWnd)
  public
    ToolBar : TToolBar;
    DroppedButton : TToolButton;
    HotButtonIndex : integer;
    function DisplayRect: TRect;
    procedure WMNCPaint(const aDC : hdc = 0);
    function GetButtonRect(Index : integer) : TRect;
    constructor Create(AHandle : hwnd; ASkinData : TsCommonData; ASkinManager : TsSkinManager; const SkinSection : string; Repaint : boolean = True); override;
    procedure PrepareCache;
    function IndexByMouse(MousePos : TPoint) : integer;
    procedure RepaintButton(Index : integer);
    procedure OurAdvancedCustomDraw(Sender: TToolBar; const ARect: TRect; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
    procedure OurAdvancedCustomDrawButton(Sender: TToolBar; Button: TToolButton; State: TCustomDrawState; Stage: TCustomDrawStage; var Flags: TTBCustomDrawFlags; var DefaultDraw: Boolean);
    procedure acWndProc(var Message: TMessage); override;
  end;

  TacStatusBarWnd = class(TacMainWnd)
  public
    StatusBar : TStatusBar;
    function SimplePanel : boolean;
    function PartsCount : integer;
    function PartText(const Index : integer) : acString;
    function PartRect(const Index : integer) : TRect;

    constructor Create(AHandle : hwnd; ASkinData : TsCommonData; ASkinManager : TsSkinManager; const SkinSection : string; Repaint : boolean = True); override;
    procedure PaintPanels;
    procedure DrawPanel(const Index : integer; const Rect: TRect);
    procedure InternalDrawPanel(const Index : integer; const Text: string; const Rect: TRect);
    procedure DoDrawText(const Text : acString; var Rect: TRect; const Flags: Longint);
    procedure PrepareCache;
    procedure WMPaint(const aDC : hdc = 0);
    procedure WMNCPaint(const aDC : hdc = 0);
    procedure acWndProc(var Message: TMessage); override;
  end;

const
  // Properties names
  acColor = 'Color';
  acTitleFont = 'TitleFont'; // DBGrid
  acDataSource = 'DataSource';

  acFont = 'Font'; // AdvGrid
  acFixedFont = 'FixedFont';
  acFixedColor = 'FixedColor';
  acHeaderFont = 'HeaderFont';
  acColumns = 'Columns';
  acSelectionColor = 'SelectionColor';
  acSelectionTextColor = 'SelectionTextColor';
  acControlLook = 'ControlLook';
  acFixedGradientFrom = 'FixedGradientFrom';
  acFixedGradientTo = 'FixedGradientTo';
  acFixedGradientMirrorFrom = 'FixedGradientMirrorFrom';
  acFixedGradientMirrorTo = 'FixedGradientMirrorTo';
  acGridFixedLineColor = 'GridFixedLineColor';
  acGridLineColor = 'GridLineColor';

  acIndColor = 'IndicatorIconColor'; // wwGrid
  acFooterColor = 'FooterColor';
  acFooterCellColor = 'FooterCellColor';
  acTitleColor = 'TitleColor';
  acTwwDBGrid = 'TwwDBGrid';

  acVETColors = 'VETColors';
  acCompressedTextColor = 'CompressedTextColor';
  acFileTextColor = 'FileTextColor';
  acFolderTextColor = 'FolderTextColor';

  acFocusColor = 'FocusColor'; // Raize

  acOnAdvancedHeaderDraw = 'OnAdvancedHeaderDraw'; // MustangPeak
  acOnHeaderDrawQueryElements = 'OnHeaderDrawQueryElements';
  achoOwnerDraw = 'hoOwnerDraw';
  achoVisible = 'hoVisible';
  acPaintInfoColumn = 'PaintInfoColumn';
  acThemed = 'Themed';
  acStyle = 'Style';
  acHeight = 'Height';

  // Supported types
  acTDBAdvGrid = 'TDBAdvGrid';
  acTAdvStringGrid = 'TAdvStringGrid';

  acOptions = 'Options';
  acHeader = 'Header';

  PreviewBorderWidth = 6;

  // TabControl offsets
  TopOffset = 4;
  BottomOffset = 2;
  LeftOffset = 1;
  RightOffset = 1;

var
  nLastSBPos : integer = -1;
  acDlgMode : boolean;

  inPaint : boolean = False; // for debug
  Ac_UninitializeFlatSB : procedure(hWnd: HWND); stdcall;
  Ac_InitializeFlatSB : function(hWnd: HWND): Bool; stdcall;

type
  TacWinControl = class(TWinControl);

// Initializes

function Ac_SetScrollInfo(Handle : hwnd; fnBar : integer; si : TScrollInfo; fRedraw : boolean) : integer;
procedure InitControl(Handle: hwnd; ASkinData: TsCommonData; ASkinManager: TsSkinManager);
procedure InitCtrlData(Wnd : hwnd; var ParentWnd : hwnd; var WndRect : TRect; var ParentRect : TRect; var WndSize : TSize; var WndPos : TPoint; const Caption : acString);
procedure InitializeACScrolls(sw : TacScrollWnd; AHandle : hwnd; Repaint : boolean = True);
procedure InitializeACWnd(sw : TacMainWnd; AHandle : hwnd);
function HookScrollWnd(Handle : hwnd; ASkinManager : TsSkinManager; ASkinData : TsCommonData = nil) : TacScrollWnd;
procedure RefreshScrolls(SkinData : TsCommonData; var ListSW : TacScrollWnd);
procedure RefreshEditScrolls(SkinData : TsCommonData; var ListSW : TacScrollWnd);
procedure RefreshTreeScrolls(SkinData : TsCommonData; var ListSW : TacScrollWnd);
function Scrolls_SetStyle(Handle : hwnd; wBar : integer; nStyle : integer) : boolean;
procedure UninitializeACScroll(Handle : hwnd; FreeSW : boolean; Repaint : boolean; var ListSW : TacScrollWnd);
procedure UninitializeACWnd(Handle : hwnd; FreeSW : boolean; Repaint : boolean; var ListSW : TacMainWnd);

// Paintings

function Ac_NCPaint(sw : TacScrollWnd; Handle : hwnd; wParam : longint; lParam : longint; ThumbPos : integer = -1; aDC : hdc = 0) : longint;
function Ac_NCDrawHScrollbar(sb : TacScrollBar; Handle : hwnd; DC : hdc; R : TRect; uDrawFlags : integer; SliderPos : integer = -1) : longint;
function Ac_NCDrawVScrollbar(sb : TacScrollBar; Handle : hwnd; DC : hdc; R : TRect; uDrawFlags : integer; SliderPos : integer = -1) : longint;
function Ac_NCDrawScrollbar(sb : TacScrollBar; Handle : hwnd; DC : hdc; R : TRect; uDrawFlags : integer; ThumbPos : integer = -1) : longint;
procedure Ac_RedrawNonClient(Handle : hwnd; fFrameChanged : boolean);
procedure PrepareCache(SkinData : TsCommonData; CtrlHandle : hwnd = 0; DlgMode : boolean = False);

// Mouse

function Ac_LButtonUp(sw : TacScrollWnd; Handle : hwnd; wParam : longint; lParam : longint) : longint;
function Ac_MouseMove(sw : TacScrollWnd; Handle : hwnd; wParam : longint; lParam : longint) : longint;
function Ac_NCHitTest(sw : TacScrollWnd; Handle : hwnd; wParam : longint; lParam : longint) : longint;
function Ac_NCLButtonDown(sw : TacScrollWnd; Handle : hwnd; wParam : longint; lParam : longint) : longint;
function Ac_SetCursor(sw : TacScrollWnd; Handle : hwnd; var wParam : longint; var lParam : longint) : longint;
function Ac_ThumbTrackHorz(sbar : TacScrollBar; Handle : hwnd; x, y : integer) : longint;
function Ac_ThumbTrackVert(sbar : TacScrollBar; Handle : hwnd; x, y : integer) : longint;

// Scroll Data

procedure AC_GetHScrollRect(sw : TacScrollWnd; Handle : hwnd; var R : TRect);
procedure AC_GetVScrollRect(sw : TacScrollWnd; Handle : hwnd; var R : TRect);
function Ac_GetHorzPortion(sb : TacScrollBar; Handle : hwnd; R : TRect; x, y : integer) : integer;
function Ac_GetVertPortion(sb : TacScrollBar; Handle : hwnd; R : TRect; x, y : integer) : integer;
function Ac_GetHorzScrollPortion(sb : TacScrollBar; Handle : hwnd; R : TRect; x, y : integer) : integer;
function Ac_GetVertScrollPortion(sb : TacScrollBar; Handle : hwnd; R : TRect; x, y : integer) : integer;
procedure Ac_GetRealScrollRect(sb : TacScrollBar; var R : TRect);
function Ac_IsScrollInfoActive(si : TScrollInfo) : boolean;
function Ac_IsScrollbarActive(sb : TacScrollBar) : boolean;
function GetScrollMetric(sBar : TacScrollBar; metric : integer; Btn : boolean = False) : integer;
procedure SendScrollMessage(Handle : hwnd; scrMsg : integer; scrId : integer; pos : integer);
procedure UpdateScrolls(sw : TacScrollWnd; Repaint : boolean = False);

// Paint Data

function Ac_CalcThumbSize(sb : TacScrollBar; R : TRect; var pthumbsize : integer; var pthumbpos : integer; Ext : boolean = False) : integer;
function Ac_GetDefaultMinThumbSize : integer;
function Ac_SetMinThumbSize(Handle : hwnd; wBar : word; Size : word) : boolean;

function Ac_NCCalcSize(sw : TacScrollWnd; Handle : hwnd; wParam : longint; lParam : longint) : longint;
function Ac_GetScrollWndFromHwnd(Handle : hwnd) : TacScrollWnd;
function Ac_GetScrollBarFromHwnd(Handle : hwnd; nBar : word) : TacScrollBar;
function Ac_Notify(sw : TacScrollWnd; Handle : hwnd; wParam : longint; lParam : longint) : longint;
function Ac_StyleChange(sw : TacScrollWnd; Handle : hwnd; wParam : longint; lParam : longint) : longint;
function Ac_Timer(sw : TacScrollWnd; Handle : hwnd; wTimerId : longint; lParam : longint) : longint;
function RotateRect0(sb : TacScrollBar; var R : TRect) : TRect;
procedure AlphaBroadCastCheck(Control : TControl; Handle : hwnd; var Message);
function MayBeHot(const SkinData : TsCommonData) : boolean;

implementation

uses acntUtils, SysUtils, math, sGraphUtils, sStyleSimply, sSkinProps, sDefaults, sSkinProvider, acDials, Buttons, sSkinMenus, Menus, sBorders, acPNG, ImgList,
  {$IFNDEF ALITE} sTabControl, sSplitter, sFrameAdapter,{$ENDIF} sThirdParty, ToolWin, acGlow, sAlphaGraph, sMessages, sVclUtils {$IFDEF LOGGED}, sDebugMsgs{$ENDIF},
  sMaskData, sMDIForm {$IFDEF TNTUNICODE}, TntControls, TntStdCtrls, TntButtons{$ENDIF} {$IFDEF USEPNG}, PngImageList, PngFunctions, PngImage{$ENDIF};

var
  uCurrentScrollbar : integer = COOLSB_NONE;
  uScrollTimerPortion : integer = HTSCROLL_NONE;
  uLastHitTestPortion : integer = HTSCROLL_NONE;
  hwndCurSB : THandle = 0;
  uScrollTimerMsg : dword = 0;
  uMouseOverId : dword = 0;
  uMouseOverScrollbar : integer = COOLSB_NONE;
  uHitTestPortion : integer = HTSCROLL_NONE;
  uCurrentScrollPortion : integer = HTSCROLL_NONE;

  nThumbSize : integer;
  nThumbPos : integer;
  rcThumbBounds : TRect;
  nThumbMouseOffset : integer;
  nThumbPos0 : integer;
  uScrollTimerId : longint = 0;
  MouseOverRect :TRect;
  bDroppedDown : boolean = False;

  ServWndList : TList;
  Ac_GetScrollBarInfo : Function(hwnd: HWND; idObject: Longint; var psbi: TScrollBarInfo): BOOL; stdcall;

procedure AlphaBroadCastCheck(Control : TControl; Handle : hwnd; var Message);
begin
  if Control <> nil then AlphaBroadcast(TWinControl(Control), Message) else AlphaBroadcast(Handle, Message);
end;

function MayBeHot(const SkinData : TsCommonData) : boolean;
begin
  Result := False;
  if (SkinData.SkinManager = nil) or (SkinData.SkinIndex < 0) or (SkinData.BorderIndex < 0) then Exit;
  Result := (SkinData.SkinManager.ma[SkinData.BorderIndex].ImageCount > 1) or (SkinData.SkinManager.gd[SkinData.SkinIndex].States > 1);
end;

procedure TryChangeIntProp(const Obj : TObject; const Name : string; Value : TColor);
begin
  if (Obj <> nil) and HasProperty(Obj, Name) then begin
    SetIntProp(Obj, Name, Value); // Alert(Name + ' is changed');
  end;
end;

function TryGetColorProp(const Obj : TObject; const Name : string) : TColor;
begin
  if (Obj <> nil) and HasProperty(Obj, Name) then begin
    Result := ColorToRGB(GetIntProp(Obj, Name));
  end
  else Result := 0;
end;

function SearchWndAsCtrl(Wnd : hwnd; Component : TComponent) : TWincontrol;
var
  i : integer;
begin
  Result := nil;
  for i := 0 to Component.ComponentCount - 1 do begin
    if (Component.Components[i] is TWinControl) and TWinControl(Component.Components[i]).HandleAllocated and (TWinControl(Component.Components[i]).Handle = Wnd) then begin
      Result := TWinControl(Component.Components[i]);
      Exit;
    end;
    Result := SearchWndAsCtrl(Wnd, Component.Components[i]);
    if Result <> nil then Exit;
  end;
end;

procedure InitCtrlData(Wnd : hwnd; var ParentWnd : hwnd; var WndRect : TRect; var ParentRect : TRect; var WndSize : TSize; var WndPos : TPoint; const Caption : acString);
begin
  GetWindowRect(Wnd, WndRect);
  ParentWnd := GetParent(Wnd);
  GetWindowRect(ParentWnd, ParentRect);

  WndSize.cx := WidthOf(WndRect, True);
  WndSize.cy := HeightOf(WndRect, True);

  WndPos := Point(WndRect.Left, WndRect.Top);
  ScreenToClient(ParentWnd, WndPos);
end;

procedure UpdateWndCorners(SkinData : TsCommonData; State : integer; Wnd : TacMainWnd);
var
  w, Width, Height : integer;
  dw, dh : integer;
  MaskData : TsMaskData;
  CI : TCacheInfo;
  ParentRGB : TsColor_;
  ParentColor : TsColor;
  SrcBmp : TBitmap;
  wl, wt, wr, wb : integer;
  procedure CopyTransCorner(SrcBmp: Graphics.TBitMap; X, Y : integer; SrcRect: TRect);
  var
    Dst, Src : PRGBAArray;
    sX, sY, SrcX, DstX, DstY : Integer;
    NewColor : TsColor_;
    h, w : integer;
    col : TsColor;
    Fast32Src : TacFast32;
  begin
    if SrcRect.Top < 0 then SrcRect.Top := 0;
    if SrcRect.Bottom > SrcBmp.Height - 1 then SrcRect.Bottom := SrcBmp.Height - 1;
    if SrcRect.Left < 0 then SrcRect.Left := 0;
    if SrcRect.Right > SrcBmp.Width - 1 then SrcRect.Right := SrcBmp.Width - 1;

    h := HeightOf(SrcRect);
    w := WidthOf(SrcRect);
    if ci.Ready then begin
      Fast32Src := TacFast32.Create;
      if (ci.Bmp.PixelFormat = pf32bit) and Fast32Src.Attach(ci.Bmp) then for sY := 0 to h do begin
        DstY := sY + Y;
        if (DstY <= SkinData.FCacheBmp.Height - 1) and (DstY >= 0) then begin
          Dst := SkinData.FCacheBmp.ScanLine[DstY];
          Src := SrcBmp.ScanLine[sY + SrcRect.Top];
          for sX := 0 to w do begin
            DstX := sX + X;
            if (DstX <= SkinData.FCacheBmp.Width - 1) and (DstX >= 0) then begin
              SrcX := sX + SrcRect.Left;
              if (Src[SrcX].B = sFuchsia.B) and (Src[SrcX].G = sFuchsia.G) and (Src[SrcX].R = sFuchsia.R) {if transparent pixel} then begin
                if (ci.Y + DstY >= ci.Bmp.Height) or (ci.X + DstX >= ci.Bmp.Width) or (ci.Y + DstY < 0) or (ci.X + DstX < 0) then continue;
                try
                  col := Fast32Src.Pixels[ci.X + DstX, ci.Y + DstY];
                finally
                  NewColor.R := col.R;
                  NewColor.G := col.G;
                  NewColor.B := col.B;
                  Dst[DstX] := NewColor
                end
              end;
            end;
          end
        end;
      end;
      FreeAndNil(Fast32Src);
    end
    else if ParentColor.C <> clFuchsia then for sY := 0 to h do begin
      DstY := sY + Y;
      if (DstY <= SkinData.FCacheBmp.Height - 1) and (DstY >= 0) then begin
        Dst := SkinData.FCacheBmp.ScanLine[DstY];
        Src := SrcBmp.ScanLine[sY + SrcRect.Top];
        for sX := 0 to w do begin
          DstX := sX + X;
          if (DstX <= SkinData.FCacheBmp.Width - 1) and (DstX >= 0) then begin
            SrcX := sX + SrcRect.Left;
            if (Src[SrcX].B = sFuchsia.B) and (Src[SrcX].G = sFuchsia.G) and (Src[SrcX].R = sFuchsia.R) then Dst[DstX] := ParentRGB
          end;
        end
      end;
    end;
  end;
  procedure CopyMasterCorner(R1, R2 : TRect; Bmp : TBitmap);
  var
    S1, S2 : PRGBAArray;
    X, Y, h, w, dX1, dX2: Integer;
    col : TsColor;
    Fast32Src : TacFast32;
  begin
    if CI.Ready then begin
      if (R1.Left + ci.X < 0) then R1.Left := -ci.X;
      if (R1.Top + ci.Y < 0) then R1.Top := -ci.Y;
    end;
    h := Min(HeightOf(R1), HeightOf(R2));
    h := Min(h, SkinData.FCacheBmp.Height - R1.Top);
    h := Min(h, Bmp.Height - R2.Top) - 1;
    if h < 0 then Exit;

    w := Min(WidthOf(R1), WidthOf(R2));
    w := Min(w, SkinData.FCacheBmp.Width - R1.Left);
    w := Min(w, Bmp.Width - R2.Left) - 1;

    if CI.Ready then begin
      if (R1.Left + w + CI.X > CI.Bmp.Width) then w := CI.Bmp.Width - R1.Left - CI.X;
      if (R1.Top + h + CI.Y > CI.Bmp.Height) then h := CI.Bmp.Height - R1.Top - CI.Y;
    end;
    if (w < 0) or (h < 0) then Exit;

    if R1.Left < R2.Left then begin
      if (R1.Left < 0) then begin
        inc(R2.Left, - R1.Left);
        dec(h, - R1.Left);
        R1.Left := 0;
      end;
    end
    else begin
      if (R2.Left < 0) then begin
        inc(R1.Left, - R2.Left);
        dec(h, - R2.Left);
        R2.Left := 0;
      end;
    end;
    if R1.Top < R2.Top then begin
      if (R1.Top < 0) then begin
        inc(R2.Top, - R1.Top);
        dec(h, - R1.Top);
        R1.Top := 0;
      end;
    end
    else begin
      if (R2.Top < 0) then begin
        inc(R1.Top, - R2.Top);
        dec(h, - R2.Top);
        R2.Top := 0;
      end;
    end;
    col.C := CI.FillColor;
    if not CI.Ready then begin
      if CI.FillColor <> clFuchsia then for Y := 0 to h do begin
        S1 := SkinData.FCacheBmp.ScanLine[R1.Top + Y];
        S2 := Bmp.ScanLine[R2.Top + Y];
        for X := 0 to w do begin
          if S2[R2.Left + X].C = sFuchsia.C then S1[R1.Left + X].C := col.C
        end;
      end;
    end
    else begin
      Fast32Src := TacFast32.Create;
      if Fast32Src.Attach(ci.Bmp) then for Y := 0 to h do begin
        S1 := SkinData.FCacheBmp.ScanLine[R1.Top + Y];
        S2 := Bmp.ScanLine[R2.Top + Y];
        dX1 := R1.Left;
        dX2 := R2.Left;
        for X := 0 to w do begin
          if S2[dX2].C = sFuchsia.C then S1[dX1].C := SwapRedBlue(Fast32Src.Pixels[dX1 + ci.X, R1.Top + ci.Y + Y].C);
          inc(dX1);
          inc(dX2);
        end;
      end;
      FreeAndNil(Fast32Src);
    end;
  end;
begin
  if not Assigned(Skindata.SkinManager) or Wnd.DlgMode then Exit;
  if (SkinData.BorderIndex < 0) or not Skindata.SkinManager.IsValidImgIndex(SkinData.BorderIndex) or not Assigned(SkinData.FCacheBmp) or (Wnd.WndSize.cx < 2) or (Wnd.WndSize.cy < 2) then Exit;

  CI := GetParentCacheHwnd(Wnd.CtrlHandle);

  MaskData := SkinData.SkinManager.ma[SkinData.BorderIndex];

  dw := WidthOfImage(MaskData);                // Width of mask
  dh := HeightOfImage(MaskData);               // Height of mask
  if (dw = 0) or (dh = 0) then Exit;

  Width := Wnd.WndSize.cx;
  Height := Wnd.WndSize.cy;
  wl := MaskData.WL; wt := MaskData.WT; wr := MaskData.WR; wb := MaskData.WB;

  if (MaskData.ImageCount = 0) and (MaskData.Bmp <> nil) then begin // if external
    MaskData.MaskType := 1;
    MaskData.ImageCount := 3;
    MaskData.R := Rect(0, 0, MaskData.Bmp.Width, MaskData.Bmp.Height);
  end;

  if not CI.Ready then begin
    ParentColor.C := ColorToRGB(CI.FillColor);
    ParentRGB.R := ParentColor.R;
    ParentRGB.G := ParentColor.G;
    ParentRGB.B := ParentColor.B;
  end
  else begin
    inc(CI.X, Wnd.WndPos.x);
    inc(CI.Y, Wnd.WndPos.y);
  end;

  if State >= MaskData.ImageCount then State := MaskData.ImageCount - 1;
  dw := State * dw;

  w := WidthOf(MaskData.R) div MaskData.ImageCount - wl - wr;         // Width of piece of mask
  if MaskData.Bmp <> nil then SrcBmp := MaskData.Bmp else SrcBmp := SkinData.SkinManager.MasterBitmap;
  if MaskData.MaskType = 0 then begin // Copy without mask
    CopyTransCorner(SrcBmp, 0, 0, Rect(MaskData.R.Left + dw, MaskData.R.Top, MaskData.R.Left + dw + wl - 1, MaskData.R.Top + wt - 1));
    CopyTransCorner(SrcBmp, 0, Height - wb, Rect(MaskData.R.Left, MaskData.R.Bottom - wb, MaskData.R.Left + wl - 1, MaskData.R.Bottom - 1));
    CopyTransCorner(SrcBmp, Width - wr, Height - wb, Rect(MaskData.R.Left + dw + wl + w, MaskData.R.Bottom - wb, MaskData.R.Left + dw + wl + w + wr - 1, MaskData.R.Bottom - 1));
    CopyTransCorner(SrcBmp, Width - wr, 0, Rect(MaskData.R.Left + dw + wl + w, MaskData.R.Top, MaskData.R.Left + dw + wl + w + wr - 1, MaskData.R.Top + wb - 1));
  end
  else begin
    CopyMasterCorner(Rect(0, 0, wl + 1, wt + 1), Rect(MaskData.R.Left + dw, MaskData.R.Top, MaskData.R.Left + dw + wl, MaskData.R.Top + wt), SrcBmp);
    CopyMasterCorner(Rect(0, Height - wb, wl, Height), Rect(MaskData.R.Left + dw, MaskData.R.Top + dh - wb, MaskData.R.Left + dw + wl, MaskData.R.Top + dh), SrcBmp);
    CopyMasterCorner(Rect(Width - wr, Height - wb, Width, Height), Rect(MaskData.R.Left + dw + wl + w, MaskData.R.Top + dh - wb, MaskData.R.Left + dw + wl + w + wr, MaskData.R.Top + dh), SrcBmp);
    CopyMasterCorner(Rect(Width - wr, 0, Width, wt), Rect(MaskData.R.Left + dw + wl + w, MaskData.R.Top, MaskData.R.Left + dw + wl + w + wr, MaskData.R.Top + wt), SrcBmp);
  end;
end;

procedure RefreshScrolls(SkinData : TsCommonData; var ListSW : TacScrollWnd);
begin
  if not (csLoading in SkinData.FOwnerControl.ComponentState) and not (csDestroying in SkinData.FOwnerControl.ComponentState) and not (csDesigning in SkinData.FOwnerControl.ComponentState) then begin
    if SkinData.Skinned then begin
      if Assigned(Ac_UninitializeFlatSB) then Ac_UninitializeFlatSB(TWinControl(SkinData.FOwnerControl).Handle);
      if (ListSW <> nil) and ListSW.Destroyed then FreeAndNil(ListSW);
      if ListSW = nil then ListSW := TacScrollWnd.Create(TWinControl(SkinData.FOwnerControl).Handle, SkinData, SkinData.SkinManager, SkinData.SkinSection);
    end
    else begin
      if ListSW <> nil then FreeAndNil(ListSW);
      if Assigned(Ac_InitializeFlatSB) then Ac_InitializeFlatSB(TWinControl(SkinData.FOwnerControl).Handle);
    end;
  end;
end;

procedure RefreshEditScrolls(SkinData : TsCommonData; var ListSW : TacScrollWnd);
begin
  if SkinData.Skinned then begin
    if (ListSW <> nil) and ListSW.Destroyed then FreeAndNil(ListSW);
    if ListSW = nil then ListSW := TacEditWnd.Create(TWinControl(SkinData.FOwnerControl).Handle, SkinData, SkinData.SkinManager, SkinData.SkinSection);
  end
  else begin
    if ListSW <> nil then FreeAndNil(ListSW);
  end;
end;

procedure RefreshTreeScrolls(SkinData : TsCommonData; var ListSW : TacScrollWnd);
begin
  if SkinData.Skinned then begin
    if (ListSW <> nil) and ListSW.Destroyed then FreeAndNil(ListSW);
    if ListSW = nil then ListSW := TacTreeViewWnd.Create(TWinControl(SkinData.FOwnerControl).Handle, SkinData, SkinData.SkinManager, SkinData.SkinSection);
  end
  else begin
    if ListSW <> nil then FreeAndNil(ListSW);
  end;
end;

procedure UpdateScrolls(sw : TacScrollWnd; Repaint : boolean = False);
begin
  if sw <> nil then begin
    if not IsWindowVisible(sw.CtrlHandle) then Exit;
    if (sw.SkinData <> nil) and sw.SkinData.FUpdating then Exit;
    if (sw.sbarHorz <> nil) and (sw.sbarVert <> nil) then begin
      sw.sbarHorz.ScrollInfo.cbSize := SizeOf(TScrollInfo);
      sw.sbarHorz.ScrollInfo.fMask := SIF_ALL;
      GetScrollInfo(sw.CtrlHandle, SB_HORZ, sw.sbarHorz.ScrollInfo);

      sw.sbarVert.ScrollInfo.cbSize := SizeOf(TScrollInfo);
      sw.sbarVert.ScrollInfo.fMask := SIF_ALL;
      GetScrollInfo(sw.CtrlHandle, SB_VERT, sw.sbarVert.ScrollInfo);
      if Repaint and not InAnimationProcess then Ac_NCPaint(sw, sw.CtrlHandle, 1, 0);
    end;
  end;
end;

procedure SendControlLoaded(Ctrl : hwnd);
var
  pWnd : hwnd;
begin
  pWnd := GetParent(Ctrl);
  if pWnd <> 0
    then SendControlLoaded(pWnd)
    else SendMessage(Ctrl, SM_ALPHACMD, MakeWParam(0, AC_CONTROLLOADED), 0);
end;

procedure PrepareCache(SkinData : TsCommonData; CtrlHandle : hwnd = 0; DlgMode : boolean = False);
var
  rCtrl : TRect;
  ci : TCacheInfo;
  P : TPoint;
  pHwnd : hwnd;
  dk : TsDisabledKind;
begin
  if (SkinData <> nil) and SkinData.BGChanged then begin
    if (CtrlHandle <> 0) then GetWindowRect(CtrlHandle, rCtrl) else Exit;
    CI := GetParentCacheHwnd(CtrlHandle);
    InitCacheBmp(SkinData);
    SkinData.FCacheBmp.Width := WidthOf(rCtrl);
    SkinData.FCacheBmp.Height := HeightOf(rCtrl);

    if DlgMode and (DefaultManager.SkinData.BorderColor <> clFuchsia) then begin
      FillDC(SkinData.FCacheBmp.Canvas.Handle, Rect(0, 0, SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height), clWindow);
      SkinData.FCacheBmp.Canvas.Brush.Color := DefaultManager.SkinData.BorderColor;
      SkinData.FCacheBmp.Canvas.FrameRect(Rect(0, 0, SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height));
    end
    else begin
      pHwnd := GetParent(CtrlHandle);
      if pHwnd = 0 then Exit;

      P := Point(rCtrl.Left, rCtrl.Top);
      if not ScreenToClient(pHwnd, P) then Exit;

      if Assigned(SkinData.SkinManager) and SkinData.SkinManager.IsValidSkinIndex(SkinData.SkinIndex) then begin
        PaintItem(SkinData, CI, True, integer((SkinData.FFocused or SkinData.FMouseAbove) and MayBeHot(SkinData)), Rect(0, 0, SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height), p, SkinData.FCacheBmp, not DlgMode);
      end;
    end;
    if SkinData.FOwnerControl <> nil then begin
      if not SkinData.FOwnerControl.Enabled then begin
        dk := [dkBlended];
        SendAMessage(CtrlHandle, AC_GETDISKIND, Cardinal(@dk));
        BmpDisabledKind(SkinData.FCacheBmp, dk, SkinData.FOwnerControl.Parent, GetParentCache(SkinData), Point(SkinData.FOwnerControl.Left, SkinData.FOwnerControl.Top));
      end;
    end;
    SkinData.BGChanged := False;
  end;
end;

procedure UninitializeACScroll(Handle : hwnd; FreeSW : boolean; Repaint : boolean; var ListSW : TacScrollWnd);
begin
  if ListSW = nil then exit;
  if (ListSW <> nil) and not ListSW.Destroyed and (ListSW.SkinData <> nil) and (ListSW.SkinData.FOwnerControl <> nil) then begin
    // restore the window procedure with the original one
    if Assigned(ListSW.OldWndProc) then begin
      if (ListSW.SkinData.FOwnerObject is TsSkinProvider) then begin
         TsSkinProvider(ListSW.SkinData.FOwnerObject).Form.WindowProc := ListSW.OldWndProc;
      end
      else TacWinControl(ListSW.SkinData.FOwnerControl).WindowProc := ListSW.OldWndProc;
    end
    else begin
      if DWord(GetWindowLong(Handle, GWL_WNDPROC)) = DWord(ListSW.NewWndProcInstance) then
        SetWindowLong(Handle, GWL_WNDPROC, Longint(ListSW.oldproc));
      if ListSW.NewWndProcInstance <> nil then begin
        FreeObjectInstance(ListSW.NewWndProcInstance);
        ListSW.NewWndProcInstance := nil;
      end;
    end;
    RemoveProp(Handle, acPropStr);
    ListSW.RestoreStdParams;
    if Assigned(ListSW.sBarHorz) then begin
      ListSW.sBarHorz.sw := nil;
      FreeAndNil(ListSW.sBarHorz);
    end;
    if Assigned(ListSW.sBarVert) then begin
      ListSW.sBarVert.sw := nil;
      FreeAndNil(ListSW.sBarVert);
    end;
    // Force WM_NCCALCSIZE and WM_NCPAINT so the original scrollbars can kick in
    if IsWindowVisible(Handle) then Ac_RedrawNonClient(Handle, Repaint);
    ListSW.Destroyed := True;
  end;
  if FreeSW and (ListSW <> nil) then begin
    if ListSW.OldProc <> nil then begin
      SetWindowLong(ListSW.CtrlHandle, GWL_WNDPROC, Longint(ListSW.OldProc));
      ListSW.oldproc := nil;
    end;
    ListSW.OldWndProc := nil;
    FreeAndnil(ListSW);
  end;
end;

procedure InitControl(Handle: hwnd; ASkinData: TsCommonData; ASkinManager: TsSkinManager);
begin
  if ASkinManager.Active then begin
    HookScrollWnd(Handle, ASkinManager, ASkinData);
  end
  else begin
    // !
  end;
end;

function Scrolls_SetStyle(Handle : hwnd; wBar : integer; nStyle : integer) : boolean;
var
  sbar : TacScrollBAr;
begin
  Result := False;
  if Ac_GetScrollWndFromHwnd(Handle) = nil then Exit;

  if (wBar = SB_HORZ) or (wBar = SB_BOTH) then begin
    sbar := Ac_GetScrollBarFromHwnd(Handle, SB_HORZ);
    if sbar <> nil then sbar.fFlatScrollbar := nStyle;
  end;
  if (wBar = SB_VERT) or (wBar = SB_BOTH) then begin
    sbar := Ac_GetScrollBarFromHwnd(Handle, SB_VERT);
    if sbar <> nil then sbar.fFlatScrollbar := nStyle;
  end;

  if IsWindowVisible(Handle) then Ac_RedrawNonClient(Handle, True);
  Result := True;
end;

procedure InitializeACScrolls(sw : TacScrollWnd; AHandle : hwnd; Repaint : boolean = True);
var
  dwCurStyle : LongInt;
begin
  with sw do begin
    DontRepaint := False;
    CtrlHandle := AHandle;
    sbarHorz := TacScrollBar.Create;
    sbarHorz.sw := sw;
    sbarVert := TacScrollBar.Create;
    sbarVert.sw := sw;

    sbarHorz.ScrollInfo.cbSize := SizeOf(TScrollInfo);
    sbarHorz.ScrollInfo.fMask := SIF_ALL;
    GetScrollInfo(CtrlHandle, SB_HORZ, sbarHorz.ScrollInfo);

    sbarVert.ScrollInfo.cbSize := SizeOf(TScrollInfo);
    sbarVert.ScrollInfo.fMask := SIF_ALL;
    GetScrollInfo(CtrlHandle, SB_VERT, sbarVert.ScrollInfo);

    fLeftScrollbar := GetWindowLong(CtrlHandle, GWL_EXSTYLE) and WS_EX_LEFTSCROLLBAR = WS_EX_LEFTSCROLLBAR;
    dwCurStyle := GetWindowLong(CtrlHandle, GWL_STYLE);
    SetProp(CtrlHandle, acPropStr, Cardinal(sw));

    if dwCurStyle and WS_HSCROLL <> 0 then sw.sBarHorz.fScrollFlags := CSBS_VISIBLE;
    if dwCurStyle and WS_VSCROLL <> 0 then sw.sbarVert.fScrollFlags := CSBS_VISIBLE;

    sbarHorz.nBarType := SB_HORZ;
    sbarVert.nBarType := SB_VERT;

    sbarHorz.fFlatScrollbar := CSBS_NORMAL;
    sbarVert.fFlatScrollbar := CSBS_NORMAL;

    sbarHorz.nArrowLength := SYSTEM_METRIC;
    sbarHorz.nArrowWidth  := SYSTEM_METRIC;
    sbarVert.nArrowLength := SYSTEM_METRIC;
    sbarVert.nArrowWidth  := SYSTEM_METRIC;

    bPreventStyleChange   := False;

    InitializeACWnd(sw, AHandle);

    Ac_SetMinThumbSize(CtrlHandle, SB_BOTH, Ac_GetDefaultMinThumbSize);

    if Ac_GetScrollWndFromHwnd(CtrlHandle) = nil then Exit;

    sbarVert := Ac_GetScrollBarFromHwnd(CtrlHandle, SB_VERT);
    if sbarVert <> nil then sbarVert.fFlatScrollbar := CSBS_NORMAL;
    sbarHorz := Ac_GetScrollBarFromHwnd(CtrlHandle, SB_HORZ);
    if sbarHorz <> nil then sbarHorz.fFlatScrollbar := CSBS_NORMAL;

    if Repaint then Ac_RedrawNonClient(CtrlHandle, True);
  end;
end;

procedure InitializeACWnd(sw : TacMainWnd; AHandle : hwnd);
begin
  with sw do begin
    DontRepaint := False;
    CtrlHandle := AHandle;

    SetProp(CtrlHandle, acPropStr, Cardinal(sw));

    if (sw.SkinData.FOwnerControl <> nil) or (sw.SkinData.FOwnerObject is TsSkinProvider) then begin
      if (sw.SkinData.FOwnerObject is TsSkinProvider) then begin
        OldWndProc := TsSkinProvider(sw.SkinData.FOwnerObject).Form.WindowProc;
        TsSkinProvider(sw.SkinData.FOwnerObject).Form.WindowProc := acWndProc;
      end
      else begin
        OldWndProc := TacWinControl(sw.SkinData.FOwnerControl).WindowProc;
        TacWinControl(sw.SkinData.FOwnerControl).WindowProc := acWndProc;
      end;
    end
    else begin         
{$IFDEF LOGGED}
//  LogLines.Add(GetWndText(AHandle) + ' TacMainWnd.Create Before');
{$ENDIF}
      OldProc := Pointer(GetWindowLong(CtrlHandle, GWL_WNDPROC));
      NewWndProcInstance := MakeObjectInstance(acWndProc);
      SetWindowLong(CtrlHandle, GWL_WNDPROC, Longint(NewWndProcInstance));
    end;
  end;
end;

procedure UninitializeACWnd(Handle : hwnd; FreeSW : boolean; Repaint : boolean; var ListSW : TacMainWnd);
var
//  sw : TacMainWnd;
  Destroyed: Boolean;
begin
  Destroyed := True;
  if ListSW = nil then exit;// else sw := ListSW;
  if not ListSW.Destroyed then begin
    // restore the window procedure with the original one
    if Assigned(ListSW.OldWndProc) then begin
      if (ListSW.SkinData.FOwnerObject is TsSkinProvider) then begin
        TsSkinProvider(ListSW.SkinData.FOwnerObject).Form.WindowProc := ListSW.OldWndProc;
      end
      else TacWinControl(ListSW.SkinData.FOwnerControl).WindowProc := ListSW.OldWndProc;
    end
    else if DWord(GetWindowLong(ListSW.CtrlHandle, GWL_WNDPROC)) = DWord(ListSW.NewWndProcInstance) then begin
      SetWindowLong(Handle, GWL_WNDPROC, longint(ListSW.oldproc));
      ListSW.oldproc := nil;
      if ListSW.NewWndProcInstance <> nil then begin
        FreeObjectInstance(ListSW.NewWndProcInstance);
        ListSW.NewWndProcInstance := nil;
      end;
    end
    else Destroyed := False;
    RemoveProp(Handle, acPropStr);
    ListSW.RestoreStdParams;
    // Force WM_NCCALCSIZE and WM_NCPAINT so the original scrollbars can kick in
    if IsWindowVisible(Handle) then Ac_RedrawNonClient(Handle, Repaint);
    ListSW.Destroyed := Destroyed;
  end;
  if FreeSW and (ListSW <> nil) then begin
    ListSW.oldproc := nil;
    ListSW.OldWndProc := nil;
    FreeAndnil(ListSW);
  end;
end;

function HookScrollWnd(Handle : hwnd; ASkinManager : TsSkinManager; ASkinData : TsCommonData = nil) : TacScrollWnd;
begin
  if Ac_GetScrollWndFromHwnd(Handle) = nil
    then Result := TacScrollWnd.Create(Handle, ASkinData, ASkinManager, '')
    else Result := nil;
end;

function Ac_GetScrollInfoFromHwnd(Handle : hwnd; fnBar : integer) : TScrollInfo;
var
  sb : TacScrollBar;
begin
  Result.cbSize := 0;
  sb := Ac_GetScrollBarFromHwnd(Handle, fnBar);
  if (sb = nil) then Exit;
  if fnBar = SB_HORZ then Result := sb.scrollInfo else if fnBar = SB_VERT then Result := sb.scrollInfo else Result.cbSize := 0;
end;

function Ac_ShowScrollBar(Handle : hwnd; wBar : integer; fShow : boolean) : boolean;
var
  sbar : TacScrollBar;
  bFailed : boolean;
  dwStyle : Longint;
begin
  bFailed := FALSE;
  dwStyle := GetWindowLong(Handle, GWL_STYLE);

  if Ac_GetScrollWndFromHwnd(Handle) = nil then begin
    Result := ShowScrollBar(Handle, wBar, fShow);
    Exit;
  end;

  if ((wBar = SB_HORZ) or (wBar = SB_BOTH)) then begin
    sbar := Ac_GetScrollBarFromHwnd(Handle, SB_HORZ);
    if sbar <> nil then begin
      sbar.fScrollFlags := sbar.fScrollFlags and not CSBS_VISIBLE;
      sbar.fScrollFlags := sbar.fScrollFlags or (integer(fShow) * CSBS_VISIBLE);

      if fShow
        then SetWindowLong(Handle, GWL_STYLE, dwStyle or WS_HSCROLL)
        else SetWindowLong(Handle, GWL_STYLE, dwStyle and not WS_HSCROLL);
    end;
  end;

  if ((wBar = SB_VERT) or (wBar = SB_BOTH)) then begin
    sbar := Ac_GetScrollBarFromHwnd(Handle, SB_VERT);
    if sbar <> nil then begin
      sbar.fScrollFlags := sbar.fScrollFlags and not CSBS_VISIBLE;
      sbar.fScrollFlags := sbar.fScrollFlags or (integer(fShow) * CSBS_VISIBLE);

      if fShow
        then SetWindowLong(Handle, GWL_STYLE, dwStyle or WS_VSCROLL)
        else SetWindowLong(Handle, GWL_STYLE, dwStyle and not WS_VSCROLL);
    end;
  end;

  if bFailed then Result := False else begin
    SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE or SWP_FRAMECHANGED);
    Result := True;
  end
end;

function Ac_IsThumbTracking(Handle : hwnd) : boolean;
var
  sw : TacScrollWnd;
begin
  sw := Ac_GetScrollWndFromHwnd(Handle);
  if sw = nil then Result := FALSE else Result := sw.fThumbTracking;
end;

function Ac_SetScrollInfo(Handle : hwnd; fnBar : integer; si : TScrollInfo; fRedraw : boolean) : integer;
var
  sbar : TacScrollBar;
  mysi : TScrollInfo;
  fRecalcFrame : boolean;
  t : integer;
begin
  fRecalcFrame := FALSE;

  mysi := Ac_GetScrollInfoFromHwnd(Handle, fnBar);
  if mysi.cbSize = 0 then begin
    Result := SetScrollInfo(Handle, fnBar, si, fRedraw);
    Exit;
  end;

  if (si.fMask and SIF_RANGE) <> 0 then begin
    mysi.nMin := si.nMin;
    mysi.nMax := si.nMax;
  end;
  //The nPage member must specify a value from 0 to nMax - nMin +1.
  if (si.fMask and SIF_PAGE) <> 0 then begin
    t := mysi.nMax - mysi.nMin + 1;
    mysi.nPage := min(max(0, integer(si.nPage)), t);
  end;
  //The nPos member must specify a value between nMin and nMax - max(nPage - 1, 0).
  if (si.fMask and SIF_POS) <> 0 then begin
    mysi.nPos := max(si.nPos, mysi.nMin);
    t := integer(mysi.nPage) - 1;
    mysi.nPos := min(mysi.nPos, mysi.nMax - maxi(t, 0));
  end;
  sbar := Ac_GetScrollBarFromHwnd(Handle, fnBar);
  if ((si.fMask and SIF_DISABLENOSCROLL) <> 0) or (sbar.fScrollFlags and CSBS_THUMBALWAYS <> 0) then begin
    if sbar.fScrollVisible then begin
      Ac_ShowScrollBar(Handle, fnBar, TRUE);
      fRecalcFrame := TRUE;
    end
  end
  else begin
    if (mysi.nPage > UINT(mysi.nMax)) or (mysi.nPage = UINT(mysi.nMax)) and (mysi.nMax = 0) or (mysi.nMax <= mysi.nMin) then begin
      if sbar.fScrollVisible then begin
        Ac_ShowScrollBar(Handle, fnBar, FALSE);
        fRecalcFrame := TRUE;
      end
    end
    else begin
      if not sbar.fScrollVisible then begin
        Ac_ShowScrollBar(Handle, fnBar, TRUE);
        fRecalcFrame := TRUE;
      end;
    end;
  end;

  if (fRedraw and not Ac_IsThumbTracking(Handle) and IsWindowVisible(Handle)) then Ac_RedrawNonClient(Handle, fRecalcFrame);
  Result := mysi.nPos;
end;

procedure Ac_RedrawNonClient(Handle : hwnd; fFrameChanged : boolean);
begin
  if not fFrameChanged
    then SendMessage(Handle, WM_NCPAINT, 1, 0)
    else SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE or SWP_FRAMECHANGED);
end;

function Ac_GetScrollWndFromHwnd(Handle : hwnd) : TacScrollWnd;
begin
  Result := TacScrollWnd(GetProp(Handle, acPropStr));
end;

function Ac_GetScrollBarFromHwnd(Handle : hwnd; nBar : word) : TacScrollBar;
var
  sw : TacScrollWnd;
begin
  sw := Ac_GetScrollWndFromHwnd(Handle);
  if not Assigned(sw) then result := nil else if nBar = SB_HORZ then Result := sw.sbarHorz else if nBar = SB_VERT then Result := sw.sbarVert else Result := nil
end;

function Ac_GetDefaultMinThumbSize : integer;
var
  dwVersion : dword;
begin
  dwVersion := GetVersion;
  if dwVersion < $80000000 { Windows NT/2000 } then begin
    if (LOBYTE(LOWORD(dwVersion)) >= 5) then Result := MINTHUMBSIZE_2000 else Result := MINTHUMBSIZE_NT4;
  end
  else Result := MINTHUMBSIZE_NT4;
  if Result < 10 then Result := 10;
end;

function Ac_SetMinThumbSize(Handle : hwnd; wBar : word; Size : word) : boolean;
var
  sBar : TacScrollBar;
begin
  Result := False;
  if Ac_GetScrollWndFromHwnd(Handle) = nil then Exit;

  if (wBar = SB_HORZ) or (wBar = SB_BOTH) then begin
    sBar := Ac_GetScrollBarFromHwnd(Handle, SB_HORZ);
    if sbar <> nil then sbar.nMinThumbSize := size;
  end;
  if (wBar = SB_VERT) or (wBar = SB_BOTH) then begin
    sbar := Ac_GetScrollBarFromHwnd(Handle, SB_VERT);
    if sBar <> nil then sbar.nMinThumbSize := size;
  end;

  Result := True;
end;

function GetScrollMetric(sBar : TacScrollBar; metric : integer; Btn : boolean = False) : integer;
begin
  with sbar.sw.SkinManager do begin
    if sBar.nBarType = SB_HORZ then begin
      if metric = SM_CXHORZSB then begin
        if sBar.nArrowLength < 0 then begin
          if Btn and (ConstData.IndexScrollLeft > -1) and gd[ConstData.IndexScrollLeft].ReservedBoolean and (ConstData.MaskScrollLeft > -1)
            then Result := -sBar.nArrowLength * math.max(acScrollBtnLength, WidthOf(ma[ConstData.MaskScrollLeft].R) div ma[ConstData.MaskScrollLeft].ImageCount)
            else Result := -sBar.nArrowLength * acScrollBtnLength;
        end
        else Result := sBar.nArrowLength;
      end
      else begin
        if sBar.nArrowWidth < 0
          then Result := -sBar.nArrowWidth * GetSystemMetrics(SM_CYHSCROLL)
          else Result := sBar.nArrowWidth;
      end;
    end
    else if sBar.nBarType = SB_VERT then begin
      if metric = SM_CYVERTSB then begin
        if sBar.nArrowLength < 0 then begin
          if Btn and (ConstData.IndexScrollLeft > -1) and gd[ConstData.IndexScrollLeft].ReservedBoolean and (ConstData.MaskScrollLeft > -1)
            then Result := -sbar.nArrowLength * math.max(acScrollBtnLength, HeightOf(ma[ConstData.MaskScrollTop].R) div (1 + ma[ConstData.MaskScrollTop].MaskType))
            else Result := -sbar.nArrowLength * acScrollBtnLength;
        end
        else Result := sbar.nArrowLength;
      end
      else begin
        if sbar.nArrowWidth < 0
          then Result := -sbar.nArrowWidth * GetSystemMetrics(SM_CXVSCROLL)
          else Result := sbar.nArrowWidth;
      end;
    end
    else Result := 0;
  end;
end;

procedure AC_GetHScrollRect(sw : TacScrollWnd; Handle : hwnd; var R : TRect);
begin
  GetWindowRect(Handle, R);

  if sw.fLeftScrollbar then begin
    inc(R.Left, sw.cxLeftEdge + integer(sw.sbarVert.fScrollVisible) * GetScrollMetric(sw.sbarVert, SM_CXVERTSB));
    dec(R.Right, sw.cxRightEdge);
  end
  else begin
    inc(R.Left, sw.cxLeftEdge);
    dec(R.Right,sw.cxRightEdge + integer(sw.sbarVert.fScrollVisible) * GetScrollMetric(sw.sbarVert, SM_CXVERTSB));
  end;
  dec(R.Bottom, sw.cyBottomEdge);
  R.Top	:= R.Bottom - integer(sw.sbarHorz.fScrollVisible) * GetScrollMetric(sw.sbarHorz, SM_CYHORZSB);
end;

procedure AC_GetVScrollRect(sw : TacScrollWnd; Handle : hwnd; var R : TRect);
begin
  GetWindowRect(Handle, R);
  inc(R.Top, sw.cyTopEdge);
  dec(R.Bottom, sw.cyBottomEdge + integer(sw.sbarHorz.fScrollVisible) * GetScrollMetric(sw.sbarHorz, SM_CYHORZSB));

  if sw.fLeftScrollbar then begin
    inc(R.Left, sw.cxLeftEdge);
    R.Right := R.Left + integer(sw.sbarVert.fScrollVisible) * GetScrollMetric(sw.sbarVert, SM_CXVERTSB);
  end
  else begin
    dec(R.Right, sw.cxRightEdge);
    R.Left := R.Right - integer(sw.sbarVert.fScrollVisible) * GetScrollMetric(sw.sbarVert, SM_CXVERTSB);
  end;
end;

function Ac_GripVisible(sw : TacScrollWnd; Handle : THandle; R : TRect) : boolean;
var
  parRect : TRect;
  parHandle : hwnd;
begin
  Result := False;
  parHandle := GetParent(Handle);
  if GetParent(parHandle) = 0 then begin
    GetClientRect(parHandle, parRect);
    MapWindowPoints(parHandle, 0, parRect, 2);
    Result := (parHandle = 0) or
      (not sw.fLeftScrollbar and (parRect.right = R.right + sw.cxRightEdge) and (parRect.bottom = R.bottom + sw.cyBottomEdge))
       or (sw.fLeftScrollbar and (parRect.left = R.left - sw.cxLeftEdge) and (parRect.bottom = R.bottom + sw.cyBottomEdge))
  end;
end;

function Ac_NCPaint(sw : TacScrollWnd; Handle : hwnd; wParam : longint; lParam : longint; ThumbPos : integer = -1; aDC : hdc = 0) : longint;
var
  WinRect, R, parRect, R2 : TRect;
  DC : hdc;
  sb : TacScrollBar;
  LeftRight : integer;
  parHandle : hwnd;
  bGrip : TBitmap;
  BGInfo : TacBGInfo;
begin
  Result := 0;
  if sw = nil then Exit;
  if sw.SkinData <> nil then begin
    sw.SkinData.FUpdating := sw.SkinData.Updating;
    if sw.SkinData.FUpdating then Exit;
    if Assigned(sw.SkinData.FOwnerControl) and ((csCreating in sw.SkinData.FOwnerControl.ControlState) or not (IsWindowVisible(sw.CtrlHandle) or TWinControl(sw.SkinData.FOwnerControl).Showing)) then Exit;
    if sw.SkinData.BGChanged
      then SendMessage(sw.CtrlHandle, SM_ALPHACMD, MakeWParam(0, AC_PREPARECACHE), 0);
  end;
  GetWindowRect(Handle, WinRect);
  if aDC = 0 then DC := GetWindowDC(Handle) else DC := aDC;
  sb := sw.sBarHorz;
  if sb = nil then Exit;
  if sb.fScrollVisible then begin
    AC_GetHScrollRect(sw, Handle, R);
    OffsetRect(R, -WinRect.Left, -WinRect.Top);
    if uCurrentScrollbar = SB_HORZ
      then Ac_NCDrawHScrollbar(sb, Handle, dc, R, uScrollTimerPortion, ThumbPos)
      else Ac_NCDrawHScrollbar(sb, Handle, dc, R, HTSCROLL_NONE, ThumbPos);
  end;
  sb := sw.sBarVert;
  if sb = nil then Exit;
  if sb.fScrollVisible then begin
    AC_GetVScrollRect(sw, Handle, R);
    OffsetRect(R, -WinRect.Left, -WinRect.Top);
    if uCurrentScrollbar = SB_VERT
      then Ac_NCDrawVScrollbar(sb, Handle, dc, R, uScrollTimerPortion, ThumbPos)
      else Ac_NCDrawVScrollbar(sb, Handle, dc, R, HTSCROLL_NONE, ThumbPos);
  end;      
  if sw.sbarHorz.fScrollVisible and sw.sbarVert.fScrollVisible then begin
    GetWindowRect(Handle, R);
    OffsetRect(R, -winrect.left, -winrect.top);
    dec(R.bottom, sw.cyBottomEdge);
    R.top := R.bottom - GetScrollMetric(sw.sbarHorz, SM_CYHORZSB);

    if sw.fLeftScrollbar then begin
      inc(R.left, sw.cxLeftEdge);
      R.right := R.left + GetScrollMetric(sw.sbarVert, SM_CXVERTSB);
    end
    else begin
      dec(R.right, sw.cxRightEdge);
      R.left := R.right  - GetScrollMetric(sw.sbarVert, SM_CXVERTSB);
    end;
    // Paint dead zone
    parHandle := GetParent(Handle);
    GetClientRect(parHandle, parRect);
    MapWindowPoints(parHandle, 0, parRect, 2);
    Windows.CopyRect(R2, R);
    OffsetRect(R2, winrect.left, winrect.top);
    // Paint BG
    BGInfo.PleaseDraw := False;
    GetBGInfo(@BGInfo, Handle);
    bGrip := CreateBmp32(WidthOf(R, True), HeightOf(R, True));
    if BGInfo.BgType = btCache then begin // If AlphaSkins are fully supported
      BitBlt(bGrip.Canvas.Handle, 0, 0, bGrip.Width, bGrip.Height, BGInfo.Bmp.Canvas.Handle, R.Left, R.Top, SRCCOPY);
    end
    else begin
      FillDC(bGrip.Canvas.Handle, Rect(0, 0, bGrip.Width, bGrip.Height), BGInfo.Color);
    end;
    // Grip if exists
    if Ac_GripVisible(sw, Handle, R2) then begin
      LeftRight := sw.SkinManager.GetMaskIndex(sw.SkinManager.ConstData.IndexGLobalInfo, s_GlobalInfo, s_GripImage);
      if sw.SkinManager.IsValidImgIndex(LeftRight) then begin
        DrawSkinGlyph(bGrip,
          Point(bGrip.Width - (WidthOf(sw.SkinManager.ma[LeftRight].R) div sw.SkinManager.ma[LeftRight].ImageCount),
                bGrip.Height - (HeightOf(sw.SkinManager.ma[LeftRight].R) div (1 + sw.SkinManager.ma[LeftRight].MaskType))),
                0, 1, sw.SkinManager.ma[LeftRight], BGInfoToCI(@BGInfo));
      end;
    end;

    BitBlt(dc, R.Left, R.Top, bGrip.Width, bGrip.Height, bGrip.Canvas.Handle, 0, 0, SRCCOPY);
    FreeAndNil(bGrip);
  end;
  if aDC = 0 then ReleaseDC(Handle, DC);
end;

procedure DrawCenterGlyph(b : TBitmap; m : integer; State : integer; sm : TsSkinManager; R : TRect);
var
  p : TPoint;
  w, h : integer;
begin
  with sm do if IsValidImgIndex(m) then begin
    w := WidthOf(ma[m].R) div ma[m].ImageCount;
    h := HeightOf(ma[m].R) div (1 + ma[m].MaskType);
    p.x := R.Left + (WidthOf(R) - w) div 2;
    p.y := R.Top + (HeightOf(R) - h) div 2;
    DrawSkinGlyph(b, p, State, 1, ma[m], MakeCacheInfo(b));
  end;
end;

procedure DrawSlider(bRect : TRect; State : integer; Bmp : TBitmap; sm : TsSkinManager);
var
  ci : TCacheInfo;
  b : TBitmap;
begin
  b := CreateBmp32(WidthOf(bRect, True), HeightOf(bRect, True));
  with sm.ConstData do begin
    Ci := MakeCacheInfo(Bmp, bRect.Left, bRect.Top);
    PaintItemFast(IndexSliderHorz, MaskSliderHorz, ScrollSliderBGHorz, ScrollSliderBGHotHorz, s_ScrollSliderH, Ci, True,
      State, Rect(0, 0, b.Width, b.Height), Point(0, 0), b, sm);
    DrawCenterGlyph(b, MaskSliderGlyphHorz, State, sm, Rect(0, 0, b.Width, b.Height));
  end;
  BitBlt(Bmp.Canvas.Handle, bRect.Left, bRect.Top, b.Width, b.Height, b.Canvas.Handle, 0, 0, SRCCOPY);
  FreeAndNil(b);
end;

procedure DrawSliderV(bRect : TRect; State : integer; Bmp : TBitmap; sm : TsSkinManager);
var
  ci : TCacheInfo;
  b : TBitmap;
begin
  b := CreateBmp32(WidthOf(bRect, True), HeightOf(bRect, True));
  with sm.ConstData do begin
    Ci := MakeCacheInfo(Bmp, bRect.Left, bRect.Top);
    PaintItemFast(IndexSliderVert, MaskSliderVert, ScrollSliderBGVert, ScrollSliderBGHotVert, s_ScrollSliderV, Ci, True,
      State, Rect(0, 0, b.Width, b.Height), Point(0, 0), b, sm);
    DrawCenterGlyph(b, MaskSliderGlyphVert, State, sm, Rect(0, 0, b.Width, b.Height));
  end;
  BitBlt(Bmp.Canvas.Handle, bRect.Left, bRect.Top, b.Width, b.Height, b.Canvas.Handle, 0, 0, SRCCOPY);
  FreeAndNil(b);
end;

procedure DrawBtnTop(bRect : TRect; State : integer; Bmp : TBitmap; sm : TsSkinManager);
var
  ci : TCacheInfo;
  b : TBitmap;
begin
  b := CreateBmp32(WidthOf(bRect, True), HeightOf(bRect, True));
  with sm.ConstData do begin
    Ci := MakeCacheInfo(Bmp);
    PaintItemFast(IndexScrollTop, MaskScrollTop, IndexBGScrollTop, IndexBGHotScrollTop, s_ScrollBtnTop, Ci, True,
      State, Rect(0, 0, b.Width, b.Height), Point(0, 0), b, sm);
    DrawCenterGlyph(b, MaskArrowTop, State, sm, Rect(0, 0, b.Width, acScrollBtnLength));
  end;
  BitBlt(Bmp.Canvas.Handle, bRect.Left, bRect.Top, b.Width, b.Height, b.Canvas.Handle, 0, 0, SRCCOPY);
  FreeAndNil(b);
end;

procedure DrawBtnBtm(bRect : TRect; State : integer; Bmp : TBitmap; sm : TsSkinManager);
var
  ci : TCacheInfo;
  b : TBitmap;
begin
  b := CreateBmp32(WidthOf(bRect, True), HeightOf(bRect, True));
  with sm.ConstData do begin
    Ci := MakeCacheInfo(Bmp, bRect.Left, bRect.Top);
    PaintItemFast(IndexScrollBottom, MaskScrollBottom, IndexBGScrollBottom, IndexBGHotScrollBottom, s_ScrollBtnBottom, Ci, True,
      State, Rect(0, 0, b.Width, b.Height), Point(0, 0), b, sm);
    DrawCenterGlyph(b, MaskArrowBottom, State, sm, Rect(0, b.Height - acScrollBtnLength, b.Width, b.Height));
  end;
  BitBlt(Bmp.Canvas.Handle, bRect.Left, bRect.Top, b.Width, b.Height, b.Canvas.Handle, 0, 0, SRCCOPY);
  FreeAndNil(b);
end;

procedure DrawBtnLeft(bRect : TRect; State : integer; Bmp : TBitmap; sm : TsSkinManager);
var
  ci : TCacheInfo;
  b : TBitmap;
begin
  b := CreateBmp32(WidthOf(bRect, True), HeightOf(bRect, True));
  with sm.ConstData do begin
    Ci := MakeCacheInfo(Bmp);
    PaintItemFast(IndexScrollLeft, MaskScrollLeft, IndexBGScrollLeft, IndexBGHotScrollLeft, s_ScrollBtnLeft, Ci, True,
      State, Rect(0, 0, b.Width, b.Height), Point(0, 0), b, sm);
    DrawCenterGlyph(b, MaskArrowLeft, State, sm, Rect(0, 0, acScrollBtnLength, b.Height));
  end;
  BitBlt(Bmp.Canvas.Handle, bRect.Left, bRect.Top, b.Width, b.Height, b.Canvas.Handle, 0, 0, SRCCOPY);
  FreeAndNil(b);
end;

procedure DrawBtnRight(bRect : TRect; State : integer; Bmp : TBitmap; sm : TsSkinManager);
var
  ci : TCacheInfo;
  b : TBitmap;
begin
  b := CreateBmp32(WidthOf(bRect, True), HeightOf(bRect, True));
  with sm.ConstData do begin
    Ci := MakeCacheInfo(Bmp, bRect.Left, bRect.Top);
    PaintItemFast(IndexScrollRight, MaskScrollRight, IndexBGScrollRight, IndexBGHotScrollRight, s_ScrollBtnRight, Ci, True,
      State, Rect(0, 0, b.Width, b.Height), Point(0, 0), b, sm);
    DrawCenterGlyph(b, MaskArrowRight, State, sm, Rect(b.Width - acScrollBtnLength, 0, b.Width, b.Height));
  end;
  BitBlt(Bmp.Canvas.Handle, bRect.Left, bRect.Top, b.Width, b.Height, b.Canvas.Handle, 0, 0, SRCCOPY);
  FreeAndNil(b);
end;

function Ac_NCDrawHScrollbar(sb : TacScrollBar; Handle : hwnd; DC : hdc; R : TRect; uDrawFlags : integer; SliderPos : integer = -1) : integer;
var
  ctrl, thumb : TRect;
  butwidth, scrollwidth, workingwidth, thumbwidth, realthumbsize, thumbpos : integer;
  fMouseOverL, fBarHot, fMouseOverR : boolean;
  Bmp : TBitmap;
  sm : TsSkinManager;
  lbState, rbState, tdiv2 : integer;
  c : TsColor;
  IsEnabled : boolean;
  BG : TacBGInfo;
  CI : TCacheInfo;
begin
  Result := 0;
  if sb.sw.fThumbTracking then Exit;
  sm := sb.sw.SkinManager;
  if not sb.fScrollVisible or (sm = nil) or not sm.IsValidSkinIndex(sm.ConstData.IndexScrollBar1H) or (WidthOf(R) < 2) then Exit;
  GetScrollInfo(sb.sw.CtrlHandle, sb.nBarType, sb.scrollinfo);

  butwidth := GetScrollMetric(sb, SM_SCROLL_LENGTH, True);
  scrollwidth := R.right - R.left;
  if scrollwidth <= 0 then Exit;
  Result := 1;
  workingwidth := scrollwidth - butwidth * 2;
  GetScrollMetric(sb, SM_SCROLL_LENGTH);
  thumbwidth := 0;
  thumbpos := 0;

  if sb.sw.SkinData.FOwnerControl <> nil
    then IsEnabled := Ac_IsScrollbarActive(sb) and sb.sw.SkinData.FOwnerControl.Enabled
    else IsEnabled := Ac_IsScrollbarActive(sb);
  fBarHot := (sb.nBarType = uMouseOverScrollbar);

  fMouseOverL := (uHitTestPortion = HTSCROLL_LEFT) and fBarHot and IsEnabled and (Handle = hwndCurSB);
  fMouseOverR := (uHitTestPortion = HTSCROLL_RIGHT) and fBarHot and IsEnabled and (Handle = hwndCurSB);

  if Handle <> hwndCurSB then uDrawFlags := HTSCROLL_NONE;
  Ac_CalcThumbSize(sb, R, thumbwidth, thumbpos);
  if SliderPos <> -1 then thumbpos := SliderPos;

  if Handle = hwndCurSB then begin
    if (uDrawFlags = HTSCROLL_LEFT) then lbState := 2 else if fMouseOverL then lbState := 1 else lbState := 0;
    if (uDrawFlags = HTSCROLL_RIGHT) then rbState := 2 else if fMouseOverR then rbState := 1 else rbState := 0
  end
  else begin
    lbState := 0;
    rbState := 0
  end;
  ////////////////////////////
  // Draw the scrollbar now //
  ////////////////////////////
  Bmp := CreateBmp32(WidthOf(R, True), HeightOf(R, True));

  BG.PleaseDraw := False;
  GetBGInfo(@BG, Handle);
  if sb.sw is TacMdiWnd then begin
    GetWindowRect(TacMdiWnd(sb.sw).FForm.ClientHandle, thumb);
    GetWindowRect(TacMdiWnd(sb.sw).FForm.Handle, ctrl);
    BG.Offset.X := thumb.Left - ctrl.Left;
    BG.Offset.Y := thumb.Top - ctrl.top;
  end
  else if (sb.sw.SkinData.FOwnerObject <> nil) and (sb.sw.SkinData.FOwnerObject is TsSkinProvider) then begin
    if TsSkinProvider(sb.sw.SkinData.FOwnerObject).BorderForm = nil then BG.Offset := Point(0, 0) else begin
      BG.Offset := Point(DiffBorder(TsSkinProvider(sb.sw.SkinData.FOwnerObject).BorderForm) + sb.sw.SkinData.SkinManager.FormShadowSize.Left, DiffTitle(TsSkinProvider(sb.sw.SkinData.FOwnerObject).BorderForm) + sb.sw.SkinData.SkinManager.FormShadowSize.Top);
    end;
  end;
  CI := BGInfoToCI(@BG);
  if (scrollwidth > butwidth * 2) then begin
    tdiv2 := thumbpos + thumbwidth div 2 - R.Left;
    PaintItemFast(sm.ConstData.IndexScrollBar1H, sm.ConstData.MaskScrollBar1H, sm.ConstData.BGScrollBar1H, sm.ConstData.BGHotScrollBar1H,
      s_ScrollBar1H, CI, True, integer(uDrawFlags = HTSCROLL_PAGELEFT) * 2, Rect(0, 0, tdiv2, Bmp.Height), Point(R.Left, R.Top), Bmp, sm);
    PaintItemFast(sm.ConstData.IndexScrollBar2H, sm.ConstData.MaskScrollBar2H, sm.ConstData.BGScrollBar2H, sm.ConstData.BGHotScrollBar2H,
      s_ScrollBar2H, CI, True, integer(uDrawFlags = HTSCROLL_PAGERIGHT) * 2, Rect(tdiv2, 0, Bmp.Width, Bmp.Height), Point(R.Left + tdiv2, R.Top), Bmp, sm);
    // LEFT ARROW
    SetRect(ctrl, R.left, R.top, R.left + butwidth, R.bottom);
    DrawBtnLeft(Rect(0, 0, WidthOf(Ctrl), HeightOf(Ctrl)), lbState, Bmp, sm);
    // RIGHT ARROW
    SetRect(ctrl, R.right - butwidth, R.top, R.right, R.bottom);
    OffsetRect(ctrl, -R.Left, -R.Top);
    DrawBtnRight(ctrl, rbState, Bmp, sm);
    // MIDDLE PORTION
    // Getting real values
    realthumbsize := MulDiv(integer(sb.scrollInfo.nPage), scrollwidth - 2 * butwidth, sb.scrollInfo.nMax - sb.scrollInfo.nMin);
    if realthumbsize < sb.nMinThumbSize then realthumbsize := sb.nMinThumbSize;

    if IsEnabled and (realthumbsize > 0) and (realthumbsize <= workingWidth) then begin
      // Draw the THUMB finally
      SetRect(thumb, thumbpos, R.top, thumbpos + thumbwidth{realthumbsize}, R.bottom);
      OffsetRect(thumb, -R.Left, -R.Top);
      DrawSlider(thumb, integer((uHitTestPortion = HTSCROLL_THUMB) and fBarHot and IsEnabled and (Handle = hwndCurSB)), Bmp, sm);
    end;
  end
  //not enough room for the scrollbar, so just draw the buttons (scaled in size to fit)
  else begin
    butWidth := Bmp.width div 2;
    PaintItemFast(sm.ConstData.IndexScrollBar1H, sm.ConstData.MaskScrollBar1H, sm.ConstData.BGScrollBar1H, sm.ConstData.BGHotScrollBar1H,
      s_ScrollBar1H, CI, True, 0, Rect(0, 0, butWidth, Bmp.Height), Point(0, 0), Bmp, sm);
    PaintItemFast(sm.ConstData.IndexScrollBar2H, sm.ConstData.MaskScrollBar2H, sm.ConstData.BGScrollBar2H, sm.ConstData.BGHotScrollBar2H,
      s_ScrollBar2H, CI, True, 0, Rect(butWidth, 0, Bmp.Width, Bmp.Height), Point(0, 0), Bmp, sm);
    DrawBtnLeft(Rect(0, 0, butWidth, Bmp.Height), lbState, Bmp, sm);
    DrawBtnRight(Rect(butWidth, 0, Bmp.Width, Bmp.Height), rbState, Bmp, sm);
  end;
  if not IsEnabled then begin
    BG.PleaseDraw := False;
    GetBGInfo(@BG, Handle);
    CI := BGInfoToCI(@BG);
    if (sb.sw.SkinData.FOwnerObject <> nil) and (sb.sw.SkinData.FOwnerObject is TsSkinProvider) then begin
      CI.X := 0; CI.Y := 0;
    end;
    if CI.Ready then begin
      BlendTransRectangle(Bmp, 0, 0, CI.Bmp, R, DefDisabledBlend);
    end
    else begin
      c.C := CI.FillColor;
      FadeBmp(bmp, Rect(0, 0, bmp.Width + 1, bmp.Height + 1), 60, c, 0, 0);
    end;
  end;
  BitBlt(DC, R.Left, R.Top, Bmp.Width, Bmp.Height, Bmp.Canvas.Handle, 0, 0, SRCCOPY);
  FreeAndNil(Bmp);
end;

function Ac_NCDrawVScrollbar(sb : TacScrollBar; Handle : hwnd; DC : hdc; R : TRect; uDrawFlags : integer; SliderPos : integer = -1) : integer;
var
  ctrl, thumb : TRect;
  butheight, scrollHeight, workingHeight, thumbHeight, realthumbsize, thumbpos : integer;
  fMouseOverT, fBarHot, fMouseOverB : boolean;
  Bmp : TBitmap;
  sm : TsSkinManager;
  lbState, rbState, tdiv2 : integer;
  c : TsColor;
  IsEnabled : boolean;
  BG : TacBGInfo;
  CI : TCacheInfo;
begin
  Result := 0;
  if sb.sw.fThumbTracking or sb.sw.DontRepaint then Exit;
  sm := sb.sw.SkinManager;
  if not sb.fScrollVisible or (sm = nil) or not sm.IsValidSkinIndex(sm.ConstData.IndexScrollBar1V) or (HeightOf(R) < 2) then Exit;
  GetScrollInfo(sb.sw.CtrlHandle, sb.nBarType, sb.scrollinfo);

  butheight := GetScrollMetric(sb, SM_SCROLL_LENGTH, True);
  scrollHeight := R.Bottom - R.Top;
  if scrollHeight <= 0 then Exit;
  Result := 1;
  workingHeight := scrollHeight - butheight * 2;
  thumbHeight := 0;
  thumbpos := 0;

  if sb.sw.SkinData.FOwnerControl <> nil
    then IsEnabled := Ac_IsScrollbarActive(sb) and sb.sw.SkinData.FOwnerControl.Enabled
    else IsEnabled := Ac_IsScrollbarActive(sb);
  fBarHot := (sb.nBarType = uMouseOverScrollbar);

  if Handle = hwndCurSB then begin
    fMouseOverT := (uHitTestPortion = HTSCROLL_UP) and fBarHot and IsEnabled and (Handle = hwndCurSB);
    fMouseOverB := (uHitTestPortion = HTSCROLL_DOWN) and fBarHot and IsEnabled and (Handle = hwndCurSB);
  end
  else begin
    fMouseOverT := False;
    fMouseOverB := False;
  end;

  if Handle <> hwndCurSB then uDrawFlags := HTSCROLL_NONE;
  Ac_CalcThumbSize(sb, R, thumbHeight, thumbpos);
  if SliderPos <> -1 then thumbpos := SliderPos;

  if Handle = hwndCurSB then begin
    if (uDrawFlags = HTSCROLL_UP) then lbState := 2 else if fMouseOverT then lbState := 1 else lbState := 0;
    if (uDrawFlags = HTSCROLL_DOWN) then rbState := 2 else if fMouseOverB then rbState := 1 else rbState := 0
  end
  else begin
    lbState := 0;
    rbState := 0
  end;
  ////////////////////////////
  // Draw the scrollbar now //
  ////////////////////////////
  Bmp := CreateBmp32(WidthOf(R, True), HeightOf(R, True));
  BG.PleaseDraw := False;
  GetBGInfo(@BG, Handle);
  if sb.sw is TacMdiWnd then begin
    GetWindowRect(TacMdiWnd(sb.sw).FForm.ClientHandle, thumb);
    GetWindowRect(TacMdiWnd(sb.sw).FForm.Handle, ctrl);
    BG.Offset.X := thumb.Left - ctrl.Left;
    BG.Offset.Y := thumb.Top - ctrl.top;
  end
  else if (sb.sw.SkinData.FOwnerObject <> nil) and (sb.sw.SkinData.FOwnerObject is TsSkinProvider) then begin
    if TsSkinProvider(sb.sw.SkinData.FOwnerObject).BorderForm = nil then BG.Offset := Point(0, 0) else begin
//      BG.Offset := Point(DiffBorder(TsSkinProvider(sb.sw.SkinData.FOwnerObject)), DiffTitle(TsSkinProvider(sb.sw.SkinData.FOwnerObject)));
      BG.Offset := Point(DiffBorder(TsSkinProvider(sb.sw.SkinData.FOwnerObject).BorderForm) + sb.sw.SkinData.SkinManager.FormShadowSize.Left, DiffTitle(TsSkinProvider(sb.sw.SkinData.FOwnerObject).BorderForm) + sb.sw.SkinData.SkinManager.FormShadowSize.Top);
    end;
  end;
  CI := BGInfoToCI(@BG);
  if (scrollHeight > butheight * 2) then begin
    tdiv2 := thumbpos + thumbHeight div 2 - R.Top;
    PaintItemFast(sm.ConstData.IndexScrollBar1V, sm.ConstData.MaskScrollBar1V, sm.ConstData.BGScrollBar1V, sm.ConstData.BGHotScrollBar1V,
      s_ScrollBar1V, CI, True, integer(uDrawFlags = HTSCROLL_PAGEUP) * 2, Rect(0, 0, Bmp.Width, tdiv2), Point(R.Left, R.Top), Bmp, sm);
    PaintItemFast(sm.ConstData.IndexScrollBar2V, sm.ConstData.MaskScrollBar2V, sm.ConstData.BGScrollBar2V, sm.ConstData.BGHotScrollBar2V,
      s_ScrollBar2V, CI, True, integer(uDrawFlags = HTSCROLL_PAGEDOWN) * 2, Rect(0, tdiv2, Bmp.Width, Bmp.Height), Point(R.Left, R.Top + tdiv2), Bmp, sm);
    //LEFT ARROW
    SetRect(ctrl, R.left, R.top, R.Right, R.Top + butheight);
    OffsetRect(ctrl, -R.Left, -R.Top);
    DrawBtnTop(Ctrl, lbState, Bmp, sm);
    //RIGHT ARROW
    SetRect(ctrl, R.Left, R.Bottom - butheight, R.Right, R.bottom);
    OffsetRect(ctrl, -R.Left, -R.Top);
    DrawBtnBtm(ctrl, rbState, Bmp, sm);
    //MIDDLE PORTION
    // Getting real values
    realthumbsize := MulDiv(integer(sb.scrollInfo.nPage), scrollheight - 2 * butheight, sb.scrollInfo.nMax - sb.scrollInfo.nMin);
    if realthumbsize < sb.nMinThumbSize then realthumbsize := sb.nMinThumbSize;

    if IsEnabled and (thumbHeight > 0) and (realthumbsize <= workingHeight) then begin
      //Draw the THUMB finally
      SetRect(thumb, R.Left, thumbpos, R.Right, thumbpos + thumbHeight);
      OffsetRect(thumb, -R.Left, -R.Top);

      DrawSliderV(thumb, integer((uHitTestPortion = HTSCROLL_THUMB) and fBarHot and IsEnabled and (Handle = hwndCurSB)), Bmp, sm);
    end;
  end
  //not enough room for the scrollbar, so just draw the buttons (scaled in size to fit)
  else begin
    butheight := Bmp.Height div 2;
    PaintItemFast(sm.ConstData.IndexScrollBar1V, sm.ConstData.MaskScrollBar1V, sm.ConstData.BGScrollBar1V, sm.ConstData.BGHotScrollBar1V,
      s_ScrollBar1V, CI, True, 0, Rect(0, 0, Bmp.Width, butHeight), Point(R.Left, R.Top), Bmp, sm);
    PaintItemFast(sm.ConstData.IndexScrollBar2V, sm.ConstData.MaskScrollBar2V, sm.ConstData.BGScrollBar2V, sm.ConstData.BGHotScrollBar2V,
      s_ScrollBar2V, CI, True, 0, Rect(0, butHeight, Bmp.Width, Bmp.Height), Point(R.Left, ButHeight), Bmp, sm);
    DrawBtnTop(Rect(0, 0, Bmp.Width, butheight), lbState, Bmp, sm);
    DrawBtnBtm(Rect(0, Bmp.Height - butheight, Bmp.Width, Bmp.Height), rbState, Bmp, sm);
  end;
  if not IsEnabled then begin
    BG.PleaseDraw := False;
    GetBGInfo(@BG, Handle);
    CI := BGInfoToCI(@BG);
    if (sb.sw.SkinData.FOwnerObject <> nil) and (sb.sw.SkinData.FOwnerObject is TsSkinProvider) then begin
      CI.X := 0; CI.Y := 0;
    end;
    if CI.Ready then begin
      BlendTransRectangle(Bmp, 0, 0, CI.Bmp, R, DefDisabledBlend);
    end
    else begin
      c.C := CI.FillColor; // ColorToRGB(sb.sw.SkinManager.gd[sb.sw.SkinManager.ConstData.IndexScrollBar1H].Color); v6.40
      FadeBmp(bmp, Rect(0, 0, bmp.Width + 1, bmp.Height + 1), 60, c, 0, 0);
    end;
  end;
  BitBlt(DC, R.Left, R.Top, Bmp.Width, Bmp.Height, Bmp.Canvas.Handle, 0, 0, SRCCOPY);
  FreeAndNil(Bmp);
end;

function Ac_NCDrawScrollbar(sb : TacScrollBar; Handle : hwnd; DC : hdc; R : TRect; uDrawFlags : integer; ThumbPos : integer = -1) : integer;
begin
  if (sb.nBarType = SB_HORZ)
    then Result := Ac_NCDrawHScrollbar(sb, Handle, dc, R, uDrawFlags, ThumbPos)
    else Result := Ac_NCDrawVScrollbar(sb, Handle, dc, R, uDrawFlags, ThumbPos);
end;

function Ac_NCCalcSize(sw : TacScrollWnd; Handle : hwnd; wParam : longint; lParam : longint) : longint;
var
  R, OldRect : TRect;
  nwStyle, dwStyle : Longint;
  sb : TacScrollBar;
begin
  OldRect := TNCCalcSizeParams(Pointer(lParam)^).rgrc[0];
  dwStyle := GetWindowLong(Handle, GWL_STYLE);
  if ((dwStyle and WS_VSCROLL = WS_VSCROLL) or (dwStyle and WS_HSCROLL = WS_HSCROLL)) then begin
    nwStyle := dwStyle and not WS_VSCROLL and not WS_HSCROLL;
    sw.bPreventStyleChange := True;
    SetWindowLong(Handle, GWL_STYLE, nwStyle);
    Result := sw.CallPrevWndProc(Handle, WM_NCCALCSIZE, wParam, lParam);
    SetWindowLong(Handle, GWL_STYLE, dwStyle);
    sw.bPreventStyleChange := False;
  end
  else Result := sw.CallPrevWndProc(Handle, WM_NCCALCSIZE, wParam, lParam);

  R := TNCCalcSizeParams(Pointer(lParam)^).rgrc[0];

  sw.cxLeftEdge   := R.left - oldrect.left;
  sw.cxRightEdge  := oldrect.right - R.right;
  sw.cyTopEdge    := R.top - oldrect.top;
  sw.cyBottomEdge := oldrect.bottom - R.bottom;

  sb := sw.sbarHorz;
  if sb = nil then Exit;
  if dwStyle and WS_HSCROLL = WS_HSCROLL then sb.fScrollFlags := CSBS_VISIBLE else sb.fScrollFlags := 0;
  if ((sb.fScrollFlags and CSBS_VISIBLE = CSBS_VISIBLE) and (R.bottom - R.top >= GetScrollMetric(sb, SM_CYHORZSB))) then begin
    dec(TNCCalcSizeParams(Pointer(lParam)^).rgrc[0].bottom, GetScrollMetric(sb, SM_CYHORZSB));
    sb.fScrollVisible := True;
  end
  else sb.fScrollVisible := False;
  sb := sw.sbarVert;
  if dwStyle and WS_VSCROLL = WS_VSCROLL then sb.fScrollFlags := CSBS_VISIBLE else sb.fScrollFlags := 0;
  if ((sb.fScrollFlags and CSBS_VISIBLE) <> 0) and (R.right - R.left >= GetScrollMetric(sb, SM_CXVERTSB)) then begin
    if sw.fLeftScrollbar
      then inc(TNCCalcSizeParams(Pointer(lParam)^).rgrc[0].left, GetScrollMetric(sb, SM_CXVERTSB))
      else dec(TNCCalcSizeParams(Pointer(lParam)^).rgrc[0].right, GetScrollMetric(sb, SM_CXVERTSB));
    sb.fScrollVisible := True;
  end
  else sb.fScrollVisible := False;
end;

function Ac_Notify(sw : TacScrollWnd; Handle : hwnd; wParam : longint; lParam : longint) : longint;
begin
  Result := sw.CallPrevWndProc(Handle, WM_NOTIFY, wParam, lParam);
end;

function Ac_ThumbTrackHorz(sbar : TacScrollBar; Handle : hwnd; x, y : integer) : longint;
var
  pt : TPoint;
  R, rc, winrect : TRect;
  DC : hdc;
  thumbpos, pos, siMaxMin, btnWidth, tdiv2 : integer;
  Bmp : TBitmap;
  sm : TsSkinManager;
  BG : TacBGInfo;
  CI : TCacheInfo;
begin
  pt := Point(x, y);
  rc := rcThumbBounds;

  btnWidth := GetScrollMetric(sbar, SM_CXHORZSB);
  inc(rc.left,  btnWidth);
  dec(rc.right, btnWidth);
  btnWidth := GetScrollMetric(sbar, SM_CXHORZSB, True);

  thumbpos := pt.x - nThumbMouseOffset;
  if (thumbpos < rc.left) then thumbpos := rc.left;
  if (thumbpos > rc.right - nThumbSize) then thumbpos := rc.right - nThumbSize;

  GetWindowRect(Handle, WinRect);

  AC_GetHScrollRect(sbar.sw, Handle, R);
  OffsetRect(R, -winrect.left, -winrect.top);
  Bmp := CreateBmp32(WidthOf(R, True), HeightOf(R, True));
  sm := sbar.sw.SkinManager;
  OffsetRect(rc, -winrect.left, -winrect.top);

  BG.PleaseDraw := False;
  GetBGInfo(@BG, Handle);
  if (sbar.sw.SkinData.FOwnerObject <> nil) and (sbar.sw.SkinData.FOwnerObject is TsSkinProvider) then begin
    if TsSkinProvider(sbar.sw.SkinData.FOwnerObject).BorderForm = nil then BG.Offset := Point(0, 0) else begin
      BG.Offset := Point(DiffBorder(TsSkinProvider(sbar.sw.SkinData.FOwnerObject).BorderForm) + sbar.sw.SkinData.SkinManager.FormShadowSize.Left, DiffTitle(TsSkinProvider(sbar.sw.SkinData.FOwnerObject).BorderForm) + sbar.sw.SkinData.SkinManager.FormShadowSize.Top);
    end;
  end;
  CI := BGInfoToCI(@BG);

  dec(thumbpos, winrect.left);
  tdiv2 := thumbpos + nThumbSize div 2 - R.Left;
  PaintItemFast(sm.ConstData.IndexScrollBar1H, sm.ConstData.MaskScrollBar1H, sm.ConstData.BGScrollBar1H, sm.ConstData.BGHotScrollBar1H,
    s_ScrollBar1H, CI, True, 0, Rect(0, 0, tdiv2, Bmp.Height), R.TopLeft, Bmp, sm);
  PaintItemFast(sm.ConstData.IndexScrollBar2H, sm.ConstData.MaskScrollBar2H, sm.ConstData.BGScrollBar2H, sm.ConstData.BGHotScrollBar2H,
    s_ScrollBar2H, CI, True, 0, Rect(tdiv2, 0, Bmp.Width, Bmp.Height), Point(R.Left + tdiv2, R.Top), Bmp, sm);
  DrawBtnLeft(Rect(0, 0, BtnWidth, Bmp.Height), 0, Bmp, sm);
  DrawBtnRight(Rect(Bmp.Width - BtnWidth, 0, Bmp.Width, Bmp.Height), 0, Bmp, sm);
  DrawSlider(Rect(thumbpos - R.Left, 0, thumbpos + nThumbSize - R.Left, Bmp.Height), 2, Bmp, sm);

  dc := GetWindowDC(Handle);
  BitBlt(dc, R.Left, R.Top, Bmp.Width, Bmp.Height, Bmp.Canvas.Handle, 0, 0, SRCCOPY);
  ReleaseDC(Handle, dc);
  FreeAndNil(Bmp);

  siMaxMin := sbar.scrollInfo.nMax - sbar.scrollInfo.nMin;
  if siMaxMin > 0
    then pos := MulDiv(thumbpos - Rc.left, siMaxMin - integer(sbar.scrollInfo.nPage) + 1, Rc.right - Rc.left - nThumbSize)
    else pos := thumbpos - Rc.left;
  if pos <> nLastSBPos then begin
    sbar.scrollInfo.nTrackPos := pos;
    sbar.sw.DontRepaint := True;
    SendScrollMessage(Handle, uScrollTimerMsg, SB_THUMBTRACK, pos);
    sbar.sw.DontRepaint := False;
  end;
  nLastSBPos := pos;
  Result := 0;
end;

function Ac_ThumbTrackVert(sbar : TacScrollBar; Handle : hwnd; x, y : integer) : longint;
var
  pt : TPoint;
  R, rc, winrect : TRect;
  DC : hdc;
  thumbpos, pos, siMaxMin, btnHeight, tdiv2 : integer;
  Bmp : TBitmap;
  sm : TsSkinManager;
  BG : TacBGInfo;
  CI : TCacheInfo;
begin
  pt := Point(x, y);
  rc := rcThumbBounds;

  btnHeight := GetScrollMetric(sbar, SM_CYVERTSB);
  inc(rc.Top,  btnHeight);
  dec(rc.Bottom, btnHeight);
  btnHeight := GetScrollMetric(sbar, SM_CYVERTSB, true);

  thumbpos := pt.y - nThumbMouseOffset;
  if (thumbpos < rc.Top) then thumbpos := rc.Top;
  if (thumbpos > rc.Bottom - nThumbSize) then thumbpos := rc.Bottom - nThumbSize;

  GetWindowRect(Handle, WinRect);

  AC_GetVScrollRect(sbar.sw, Handle, R);
  OffsetRect(R, -winrect.left, -winrect.top);
  Bmp := CreateBmp32(WidthOf(R, True), HeightOf(R, True));
  sm := sbar.sw.SkinManager;
  OffsetRect(rc, -winrect.left, -winrect.top);

  BG.PleaseDraw := False;
  GetBGInfo(@BG, Handle);
  if (sbar.sw.SkinData.FOwnerObject <> nil) and (sbar.sw.SkinData.FOwnerObject is TsSkinProvider) then begin
    if TsSkinProvider(sbar.sw.SkinData.FOwnerObject).BorderForm = nil then BG.Offset := Point(0, 0) else begin
      BG.Offset := Point(DiffBorder(TsSkinProvider(sbar.sw.SkinData.FOwnerObject).BorderForm) + sbar.sw.SkinData.SkinManager.FormShadowSize.Left, DiffTitle(TsSkinProvider(sbar.sw.SkinData.FOwnerObject).BorderForm) + sbar.sw.SkinData.SkinManager.FormShadowSize.Top);
    end;
  end;
  CI := BGInfoToCI(@BG);

  dec(thumbpos, winrect.Top);
  tdiv2 := thumbpos + nThumbSize div 2 - R.Top;

  PaintItemFast(sm.ConstData.IndexScrollBar1V, sm.ConstData.MaskScrollBar1V, sm.ConstData.BGScrollBar1V, sm.ConstData.BGHotScrollBar1V,
    s_ScrollBar1V, CI, True, 0, Rect(0, 0, Bmp.Width, tdiv2), R.TopLeft, Bmp, sm);
  PaintItemFast(sm.ConstData.IndexScrollBar2V, sm.ConstData.MaskScrollBar2V, sm.ConstData.BGScrollBar2V, sm.ConstData.BGHotScrollBar2V,
    s_ScrollBar2V, CI, True, 0, Rect(0, tdiv2, Bmp.Width, Bmp.Height), Point(R.Left, R.Top + tdiv2), Bmp, sm);
  DrawBtnTop(Rect(0, 0, Bmp.Width, BtnHeight), 0, Bmp, sm);
  DrawBtnBtm(Rect(0, Bmp.Height - BtnHeight, Bmp.Width, Bmp.Height), 0, Bmp, sm);
  DrawSliderV(Rect(0, thumbpos - R.Top, Bmp.Width, thumbpos + nThumbSize - R.Top), 2, Bmp, sm);

  dc := GetWindowDC(Handle);
  BitBlt(dc, R.Left, R.Top, Bmp.Width, Bmp.Height, Bmp.Canvas.Handle, 0, 0, SRCCOPY);
  ReleaseDC(Handle, dc);

  FreeAndNil(Bmp);

  siMaxMin := sbar.scrollInfo.nMax - sbar.scrollInfo.nMin;
  if siMaxMin > 0 then begin
    if thumbpos - Rc.Top = HeightOf(Rc) - nThumbSize then begin // If max
      pos := siMaxMin - integer(sbar.scrollInfo.nPage) + 2
    end
    else pos := MulDiv(thumbpos - Rc.Top, siMaxMin - integer(sbar.scrollInfo.nPage) + 2, HeightOf(Rc) - nThumbSize)
  end
  else pos := thumbpos - Rc.Top;
  if pos <> nLastSBPos then begin
    sbar.scrollInfo.nTrackPos := pos;
    sbar.sw.DontRepaint := True;
    SendScrollMessage(Handle, uScrollTimerMsg, SB_THUMBTRACK, pos);
    sbar.sw.DontRepaint := False;
  end;
  nLastSBPos := pos;
  Result := 0;
end;

function GetScrollRect(sw : TacScrollWnd; nBar : integer; Handle : hwnd; var R : TRect) : boolean;
begin
  Result := True;
  if nBar = SB_HORZ
    then Ac_GetHScrollRect(sw, Handle, R)
    else if nBar = SB_VERT
      then Ac_GetVScrollRect(sw, Handle, R)
      else Result := False;
end;

function Ac_GetPortion(sbar : TacScrollBar; Handle : hwnd; R : TRect; x, y : integer) : integer;
begin
  if (sbar.nBarType = SB_HORZ)
    then Result := Ac_GetHorzPortion(sbar, Handle, R, x, y)
    else if (sbar.nBarType = SB_VERT)
      then Result := Ac_GetVertPortion(sbar, Handle, R, x, y)
      else Result := HTSCROLL_NONE;
end;

function Ac_MouseMove(sw : TacScrollWnd; Handle : hwnd; wParam : longint; lParam : longint) : longint;
var
  R, WinRect : TRect;
  thisportion : integer;
  dc : hdc;
  x, y, lastportion : integer;
  pt : TPoint;
  nlParam : longint;
  sb : TacScrollBar;
begin
  lastportion := 0;

  if sw.fThumbTracking then begin
    LongWord(lParam) := GetMessagePos();
    x := SmallInt(LOWORD(LongWord(lParam)));
    y := SmallInt(HIWORD(LongWord(lParam)));

    if (uCurrentScrollbar = SB_HORZ) then begin
      Result := Ac_ThumbTrackHorz(sw.sbarHorz, Handle, x,y);
      Exit;
    end
    else if (uCurrentScrollbar = SB_VERT) then begin
      Result := Ac_ThumbTrackVert(sw.sbarVert, Handle, x,y);
      Exit;
    end
  end;

  if (uCurrentScrollPortion = HTSCROLL_NONE) then begin
    Result := sw.CallPrevWndProc(Handle, WM_MOUSEMOVE, WParam, LParam);
    Exit
  end
  else begin
    sb := sw.sbarHorz;
    LongWord(nlParam) := GetMessagePos();
    GetWindowRect(Handle, winrect);
    pt.x := SmallInt(LOWORD(LongWord(nlParam)));
    pt.y := SmallInt(HIWORD(LongWord(nlParam)));
    //emulate the mouse input on a scrollbar here...
    if(uCurrentScrollbar = SB_HORZ)
      then sb := sw.sbarHorz
      else if uCurrentScrollbar = SB_VERT then sb := sw.sbarVert;
    //get the total area of the normal scrollbar area
    GetScrollRect(sw, sb.nBarType, Handle, R);
    //see if we clicked in the inserted buttons / normal scrollbar
    //thisportion = GetPortion(sb, hwnd, &rect, LOWORD(lParam), HIWORD(lParam));
    thisportion := Ac_GetPortion(sb, Handle, R, pt.x, pt.y);
    //we need to do different things depending on if the
    //user is activating the scrollbar itself, or one of
    //the inserted buttons
    case uCurrentScrollPortion of
      HTSCROLL_LEFT, HTSCROLL_RIGHT, HTSCROLL_THUMB, HTSCROLL_PAGELEFT, HTSCROLL_PAGERIGHT, HTSCROLL_NONE: begin
        //adjust the total scroll area to become where the scrollbar
        //really is (take into account the inserted buttons)
        Ac_GetRealScrollRect(sb, R);
        OffsetRect(R, -winrect.left, -winrect.top);
        dc := GetWindowDC(Handle);
        if thisportion <> uCurrentScrollPortion then begin
          uScrollTimerPortion := HTSCROLL_NONE;
          if lastportion <> thisportion then Ac_NCDrawScrollbar(sb, Handle, dc, R, HTSCROLL_NORMAL);
        end
        //otherwise, draw the button in its depressed / clicked state
        else begin
          uScrollTimerPortion := uCurrentScrollPortion;
          if lastportion <> thisportion then Ac_NCDrawScrollbar(sb, Handle, dc, R, thisportion);
        end;
        ReleaseDC(Handle, dc);
      end
    end;
//    lastportion := thisportion;
//    lastbutton := buttonIdx;
    //must return zero here, because we might get cursor anomilies
    //CallWindowProc(sw->oldproc, hwnd, WM_MOUSEMOVE, wParam, lParam);
    Result := 0;
  end
end;

function Ac_NCMouseMove(sw : TacScrollWnd; Handle : hwnd; wHitTest : longint; lParam : longint) : longint;
begin
  //install a timer for the mouse-over events, if the mouse moves
  //over one of the scrollbars
  hwndCurSB := Handle;
  if (wHitTest = HTHSCROLL) then begin
    if (uMouseOverScrollbar = SB_HORZ) then begin
      Result := sw.CallPrevWndProc(Handle, WM_NCMOUSEMOVE, wHitTest, LParam);
      Exit;
    end;

    uLastHitTestPortion := HTSCROLL_NONE;
    uHitTestPortion     := HTSCROLL_NONE;
    GetScrollRect(sw, SB_HORZ, Handle, MouseOverRect);
    uMouseOverScrollbar := SB_HORZ;
    uMouseOverId := SetTimer(Handle, COOLSB_TIMERID3, COOLSB_TIMERINTERVAL3, nil);

    Ac_NCPaint(sw, Handle, 1, 0);
  end
  else if wHitTest = HTVSCROLL then begin
    if uMouseOverScrollbar = SB_VERT then begin
      Result := sw.CallPrevWndProc(Handle, WM_NCMOUSEMOVE, wHitTest, LParam);
      Exit;
    end;

    uLastHitTestPortion := HTSCROLL_NONE;
    uHitTestPortion     := HTSCROLL_NONE;
    GetScrollRect(sw, SB_VERT, Handle, MouseOverRect);
    uMouseOverScrollbar := SB_VERT;
    uMouseOverId := SetTimer(Handle, COOLSB_TIMERID3, COOLSB_TIMERINTERVAL3, nil);

    Ac_NCPaint(sw, Handle, 1, 0);
  end;
  Result := sw.CallPrevWndProc(Handle, WM_NCMOUSEMOVE, wHitTest, LParam);
end;

function Ac_SetCursor(sw : TacScrollWnd; Handle : hwnd; var wParam : longint; var lParam : longint) : longint;
begin
  Result := sw.CallPrevWndProc(Handle, WM_SETCURSOR, WParam, LParam);
end;

function Ac_StyleChange(sw : TacScrollWnd; Handle : hwnd; wParam : longint; lParam : longint) : longint;
var
  ss : TStyleStruct;
begin
  ss := TStyleStruct(Pointer(lParam)^);
  if wParam = GWL_EXSTYLE then begin
    if ss.styleNew and WS_EX_LEFTSCROLLBAR <> 0
      then sw.fLeftScrollbar := True
      else sw.fLeftScrollbar := False;
  end;
  Result := sw.CallPrevWndProc(Handle, WM_STYLECHANGED, WParam, LParam);
end;

function Ac_NCHitTest(sw : TacScrollWnd; Handle : hwnd; wParam : longint; lParam : longint) : longint;
var
  pt : TPoint;
  hrect, vrect : TRect;
begin
  pt.x := SmallInt(LoWord(longword(lParam)));
  pt.y := SmallInt(HiWord(longWord(lParam)));
  Ac_GetHScrollRect(sw, Handle, hrect);
  Ac_GetVScrollRect(sw, Handle, vrect);

{  if ((sw is TacComboListWnd) and not TacComboListWnd(sw).SimplyBox) then begin
    pt.X := pt.X + sw.WndRect.Left;
    pt.Y := pt.Y + sw.WndRect.Top;
  end;        }

  if sw.sbarHorz.fScrollVisible and PtInRect(hrect, pt) then begin
    if not Ac_IsScrollbarActive(sw.sbarHorz)
      then Result := Windows.HTNOWHERE
      else Result := HTHSCROLL;
  end
  else if sw.sbarVert.fScrollVisible and PtInRect(vrect, pt) then begin
    if not Ac_IsScrollbarActive(sw.sbarVert)
      then Result := Windows.HTNOWHERE
      else Result := HTVSCROLL;
  end
  else if {sw.sbarVert.fScrollVisible and
            sw.sbarHorz.fScrollVisible and}
          Ac_GripVisible(sw, Handle, Rect(hrect.Right, hrect.Top, vrect.Right, hrect.Bottom)) and 
              PtInRect(Rect(hrect.Right, hrect.Top, vrect.Right, hrect.Bottom), pt)
                 then begin
    Result := HTBOTTOMRIGHT;
//???    Result := CallWindowProc(sw.OldProc, Handle, WM_NCHITTEST, wParam, lParam);
  end
  else
    Result := sw.CallPrevWndProc(Handle, WM_NCHITTEST, WParam, LParam);
end;

function Ac_GetHorzPortion(sb : TacScrollBar; Handle : hwnd; R : TRect; x, y : integer) : integer;
var
  rc : TRect;
begin
  rc := R;
  if (y < rc.top) or (y >= rc.bottom) then begin
    Result := HTSCROLL_NONE;
    Exit;
  end;
  Result := Ac_GetHorzScrollPortion(sb, Handle, rc, x, y);
end;

function Ac_GetVertPortion(sb : TacScrollBar; Handle : hwnd; R : TRect; x, y : integer) : integer;
var
  rc : TRect;
begin
  rc := R;
  if (x < rc.Left) or (x >= rc.Right) then begin
    Result := HTSCROLL_NONE;
    Exit;
  end;
  Result := Ac_GetVertScrollPortion(sb, Handle, rc, x, y);
end;

function Ac_CalcThumbSize(sb : TacScrollBar; R : TRect; var pthumbsize : integer; var pthumbpos : integer; Ext : boolean = False) : integer;
var
  scrollsize, workingsize, siMaxMin, butsize, startcoord, thumbpos, thumbsize{, adjust, count} : integer;
begin
  thumbpos := 0;
  thumbsize := 0;
  butsize := GetScrollMetric(sb, SM_SCROLL_LENGTH);//, True);

  if sb.nBarType = SB_HORZ then begin
    scrollsize := R.right - R.left;
    startcoord := R.left;
  end
  else begin
    scrollsize := R.Bottom - R.Top;
    startcoord := R.Top;
  end;

  siMaxMin := sb.scrollInfo.nMax - sb.scrollInfo.nMin + 1;
  workingsize := scrollsize - butsize * 2;

  if sb.scrollInfo.nPage = 0 then thumbsize := butsize else if siMaxMin > 0 then begin
    thumbsize := MulDiv(integer(sb.scrollInfo.nPage), workingsize, siMaxMin);
    if thumbsize < sb.nMinThumbSize then thumbsize := sb.nMinThumbSize;
  end;

  if siMaxMin > 0 then begin
    if sb.scrollInfo.nPos <> 0 then sb.scrollInfo.nPos := sb.scrollInfo.nPos;
    thumbpos := MulDiv(sb.scrollInfo.nPos - sb.scrollInfo.nMin, workingsize - thumbsize, siMaxMin - max(1, integer(sb.scrollInfo.nPage)));
    if thumbpos < 0 then thumbpos := 0;
    if thumbpos >= workingsize - thumbsize then thumbpos := workingsize - thumbsize;
  end;

  inc(thumbpos, startcoord + butsize);
  pthumbpos := thumbpos;
  pthumbsize := thumbsize;

  Result := 1;
end;

function Ac_IsScrollInfoActive(si : TScrollInfo) : boolean;
begin
  if ((si.nPage > UINT(si.nMax)) or (si.nMax <= si.nMin) or (si.nMax = 0)) then Result := False else Result := True;
end;

function Ac_IsScrollbarActive(sb : TacScrollBar) : boolean;
var
  sbi : TScrollBarInfo;
  idObject : Int64;
begin
  sbi.cbSize := SizeOf(sbi);
  if sb.nBarType = SB_HORZ then idObject := OBJID_HSCROLL else if sb.nBarType = SB_VERT then idObject := OBJID_VSCROLL else idObject := OBJID_CLIENT; 
  if Assigned(Ac_GetScrollBarInfo) then begin
    if Ac_GetScrollBarInfo(sb.sw.CtrlHandle, longint(idObject), sbi) then begin
      if (((sb.fScrollFlags and ESB_DISABLE_BOTH) = ESB_DISABLE_BOTH) or
              ((sb.fScrollFlags and CSBS_THUMBALWAYS) <> 0) and not Ac_IsScrollInfoActive(sb.scrollInfo)) or
                  (sbi.rgstate[0] and STATE_SYSTEM_UNAVAILABLE = STATE_SYSTEM_UNAVAILABLE)
        then Result := False
        else Result := True;
    end
    else Result := False
  end
  else begin // Win95
    if sb.nBarType = SB_VERT
      then Result := (GetWindowLong(sb.sw.CtrlHandle, GWL_STYLE) and WS_VSCROLL) = WS_VSCROLL
      else Result := (GetWindowLong(sb.sw.CtrlHandle, GWL_STYLE) and WS_HSCROLL) = WS_HSCROLL;
  end;
end;

function Ac_GetHorzScrollPortion(sb : TacScrollBar; Handle : hwnd; R : TRect; x, y : integer) : integer;
var
  workingwidth, scrollwidth, butwidth, thumbwidth, thumbpos : integer;
begin
  butwidth := GetScrollMetric(sb, SM_SCROLL_LENGTH, False);
  scrollwidth := R.right - R.left;
  workingwidth := scrollwidth - butwidth * 2;
  if (y < R.top) or (y >= R.bottom) then begin
    Result := HTSCROLL_NONE;
    Exit;
  end;
  Ac_CalcThumbSize(sb, R, thumbwidth, thumbpos);
  if scrollwidth <= butwidth * 2 then butwidth := scrollwidth div 2;
  if (x >= R.left) and (x < R.left + butwidth) then begin
    Result := HTSCROLL_LEFT;
    Exit
  end
  else if (x >= R.right - butwidth) and (x < R.Right) then begin
    Result := HTSCROLL_RIGHT;
    Exit
  end;
  if thumbwidth >= workingwidth then begin
    Result := HTSCROLL_NONE;
    Exit;
  end;
  if (x >= thumbpos) and (x < thumbpos + thumbwidth) then begin
    Result := HTSCROLL_THUMB;
    Exit;
  end
  else if (x >= R.left + butwidth) and (x < thumbpos) then begin
    Result := HTSCROLL_PAGELEFT;
    Exit;
  end
  else if (x >= thumbpos + thumbwidth) and (x < R.right - butwidth) then begin
    Result := HTSCROLL_PAGERIGHT;
    Exit;
  end;
  Result := HTSCROLL_NONE;
end;

function Ac_GetVertScrollPortion(sb : TacScrollBar; Handle : hwnd; R : TRect; x, y : integer) : integer;
var
  workingHeight, scrollHeight, butHeight, thumbHeight, thumbpos : integer;
begin
  butHeight := GetScrollMetric(sb, SM_SCROLL_LENGTH, False);//True);
  scrollHeight := HeightOf(R);
  workingHeight := scrollHeight - butHeight * 2;
  if (x < R.Left) or (x >= R.Right) then begin
    Result := HTSCROLL_NONE;
    Exit;
  end;
  Ac_CalcThumbSize(sb, R, thumbHeight, thumbpos);
  if scrollHeight <= butHeight * 2 then butHeight := scrollHeight div 2;
  if (y >= R.Top) and (y < R.Top + butHeight) then begin
    Result := HTSCROLL_LEFT;
    Exit
  end
  else if (y >= R.Bottom - butHeight) and (y < R.Bottom) then begin
    Result := HTSCROLL_RIGHT;
    Exit
  end;
  if thumbHeight >= workingHeight then begin
    Result := HTSCROLL_NONE;
    Exit;
  end;
  if (y >= thumbpos) and (y < thumbpos + thumbHeight) then begin
    Result := HTSCROLL_THUMB;
    Exit;
  end
  else if (y >= R.Top + butHeight) and (y < thumbpos) then begin
    Result := HTSCROLL_PAGELEFT;
    Exit;
  end
  else if (y >= thumbpos + thumbHeight) and (y < R.Bottom - butHeight) then begin
    Result := HTSCROLL_PAGERIGHT;
    Exit;
  end;
  Result := HTSCROLL_NONE;
end;

procedure Ac_GetRealHorzScrollRect(sb : TacScrollBar; var R : TRect);
begin
  if (sb.fButVisibleBefore) then inc(R.Left, sb.nButSizeBefore);
  if (sb.fButVisibleAfter) then dec(R.Right, sb.nButSizeAfter);
end;

procedure Ac_GetRealVertScrollRect(sb : TacScrollBar; var R : TRect);
begin
  if(sb.fButVisibleBefore) then inc(R.top, sb.nButSizeBefore);
  if(sb.fButVisibleAfter) then dec(R.bottom, sb.nButSizeAfter);
end;

procedure Ac_GetRealScrollRect(sb : TacScrollBar; var R : TRect);
begin
  if sb.nBarType = SB_HORZ then Ac_GetRealHorzScrollRect(sb, R) else
    if sb.nBarType = SB_VERT then Ac_GetRealVertScrollRect(sb, R);
end;

function RotateRect0(sb : TacScrollBar; var R : TRect) : TRect;
begin
  if (sb.nBarType = SB_VERT) then Result := RotateRect(R);
end;

procedure SendScrollMessage(Handle : hwnd; scrMsg : integer; scrId : integer; pos : integer);
var
  si : TScrollInfo;
  BarFlag : integer;
begin
{$IFDEF LOGGED}
//  AddToLog(MakeMessage(scrMsg, scrID, pos, 0));
{$ENDIF}
  if SendAMessage(Handle, AC_BEFORESCROLL, MakeLPAram(Word(ScrId), Word(ScrMsg))) <> 1 then begin // If using more then 64K is not forbidden (is not used in ListView)
    si.cbSize := SizeOf(TScrollInfo);
    si.fMask := SIF_ALL;//SIF_RANGE or SIF_PAGE;
    if ScrMsg = WM_HSCROLL then BarFlag := SB_HORZ else BarFlag := SB_VERT;
    GetScrollInfo(Handle, BarFlag, si);
    // Patch for DBGridEh works incorrectly for other controls ?
//    if (Pos <> si.nMin) and (Pos <> si.nMax - si.nPage + 1) then
    case scrId of
      SB_THUMBTRACK : begin
        si.cbSize := SizeOf(TScrollInfo);
        si.fMask := SIF_POS;
        si.nPos := pos;
        SetScrollInfo(Handle, BarFlag, si, False);
      end;
    end;
    SendMessage(Handle, Cardinal(ScrMsg), MakeWParam(Longword(ScrId), min(Longword(Pos), MaxWord)), 0);
  end
  else begin
    SendMessage(Handle, Cardinal(ScrMsg), MakeWParam(Longword(ScrId), min(Longword(Pos), MaxWord)), Pos {Sending this value specially for a ListView});
  end;

  SendAMessage(Handle, AC_AFTERSCROLL, MakeLPAram(Word(ScrId), Word(ScrMsg)));
end;

function Ac_NCLButtonDown(sw : TacScrollWnd; Handle : hwnd; wParam : longint; lParam : longint) : longint;
var
  R, WinRect : TRect;
  DC : hdc;
  sb : TacScrollBar;
  pt : TPoint;
  procedure JustDoIt;
  begin
    if not Ac_IsScrollbarActive(sb) then Exit;
    Ac_GetRealScrollRect(sb, R);
    if (uCurrentScrollbar = SB_HORZ)
      then uScrollTimerPortion := Ac_GetHorzScrollPortion(sb, Handle, R, pt.x, pt.y)
      else uScrollTimerPortion := Ac_GetVertScrollPortion(sb, Handle, R, pt.x, pt.y);

    GetWindowRect(Handle, WinRect);
    OffsetRect(R, -WinRect.left, -WinRect.top);
    dc := GetWindowDC(Handle);

    Ac_NCDrawScrollbar(sb, Handle, dc, R, uScrollTimerPortion);
    ReleaseDC(Handle, dc);

    SendScrollMessage(Handle, uScrollTimerMsg, uCurrentScrollPortion, 0);
    uScrollTimerPortion := uCurrentScrollPortion;
    uScrollTimerId := SetTimer(Handle, COOLSB_TIMERID1, COOLSB_TIMERINTERVAL1, nil);
  end;
begin
  Result := 0;
  pt.x := SmallInt(LoWord(LongWord(lParam)));
  pt.y := SmallInt(HiWord(LongWord(lParam)));
  hwndCurSB := Handle;
  if wParam = HTHSCROLL then begin
    uScrollTimerMsg := WM_HSCROLL;
    uCurrentScrollbar := SB_HORZ;
    sb := sw.sbarHorz;
    //get the total area of the normal Horz scrollbar area
    Ac_GetHScrollRect(sw, Handle, R);
    uCurrentScrollPortion := Ac_GetHorzPortion(sb, Handle, R, SmallInt(LoWord(LongWord(lParam))), SmallInt(HiWord(LongWord(lParam))));
  end
  else if wParam = HTVSCROLL then begin
    uScrollTimerMsg := WM_VSCROLL;
    uCurrentScrollbar := SB_VERT;
    sb := sw.sbarVert;
    Ac_GetVScrollRect(sw, Handle, R);
    uCurrentScrollPortion := Ac_GetVertPortion(sb, Handle, R, SmallInt(LOWORD(LongWord(lParam))), SmallInt(HIWORD(LongWord(lParam))));
  end
  // NORMAL PROCESSING
  else begin
    uCurrentScrollPortion := HTSCROLL_NONE;
    Result := sw.CallPrevWndProc(Handle, WM_NCLBUTTONDOWN, WParam, LParam);
    Exit
  end;
  case uCurrentScrollPortion of
    HTSCROLL_THUMB : begin
      if not Ac_IsScrollbarActive(sb) then Exit;
      Ac_GetRealScrollRect(sb, R);
      Ac_CalcThumbSize(sb, R, nThumbSize, nThumbPos, True);

      //remember the bounding rectangle of the scrollbar work area
      rcThumbBounds := R;

      sw.fThumbTracking := True;
      sb.scrollInfo.nTrackPos := sb.scrollInfo.nPos;

      if (wParam = HTVSCROLL) then nThumbMouseOffset := pt.y - nThumbPos else nThumbMouseOffset := pt.x - nThumbPos;

      nLastSBPos := sb.scrollInfo.nPos;
      nThumbPos0 := nThumbPos;

      GetWindowRect(Handle, WinRect);
      OffsetRect(R, -WinRect.left, -WinRect.top);
      dc := GetWindowDC(Handle);
      Ac_NCDrawScrollbar(sb, Handle, dc, R, HTSCROLL_THUMB);
      ReleaseDC(Handle, dc);
    end;
    HTSCROLL_LEFT : begin
      if sb.fScrollFlags and ESB_DISABLE_LEFT <> 0 then Exit else JustDoIt;
    end;
    HTSCROLL_RIGHT : begin
      if sb.fScrollFlags and ESB_DISABLE_RIGHT <> 0 then Exit else JustDoIt;
    end;
    HTSCROLL_PAGELEFT, HTSCROLL_PAGERIGHT : JustDoIt
    else
      Result := sw.CallPrevWndProc(Handle, WM_NCLBUTTONDOWN, WParam, LParam);
  end;
  if uCurrentScrollPortion <> -1 then SetCapture(Handle);
end;

function Ac_LButtonUp(sw : TacScrollWnd; Handle : hwnd; wParam : longint; lParam : longint) : longint;
var
  R, WinRect : TRect;
  DC : hdc;
  pt : TPoint;
  sb : TacScrollBar;
begin
  Result := 0;
  //current scrollportion is the button that we clicked down on
  if (uCurrentScrollPortion <> HTSCROLL_NONE) then begin
    // For popup listboxes
    if (sw.SkinData.FOwnerControl <> nil) or not ((sw is TacComboListWnd) and not TacComboListWnd(sw).SimplyBox) or (sw.Tag = ACT_RELCAPT) then ReleaseCapture;
    sb := sw.sbarHorz;
    LongWord(lParam) := GetMessagePos();

    GetWindowRect(Handle, winrect);
    pt.x := SmallInt(LOWORD(LongWord(lParam)));
    pt.y := SmallInt(HIWORD(LongWord(lParam)));

    //emulate the mouse input on a scrollbar here...
    if uCurrentScrollbar = SB_HORZ then begin
      //get the total area of the normal Horz scrollbar area
      sb := sw.sbarHorz;
      Ac_GetHScrollRect(sw, Handle, R);
    end
    else if uCurrentScrollbar = SB_VERT then begin
      //get the total area of the normal Horz scrollbar area
      sb := sw.sbarVert;
      Ac_GetVScrollRect(sw, Handle, R);
    end;
    case uCurrentScrollPortion of
      HTSCROLL_LEFT, HTSCROLL_RIGHT, HTSCROLL_PAGELEFT, HTSCROLL_PAGERIGHT, HTSCROLL_NONE: begin
        KillTimer(Handle, uScrollTimerId);
        //In case we were thumb tracking, make sure we stop NOW
        if sw.fThumbTracking then begin
          sw.DontRepaint := True;
          SendScrollMessage(Handle, uScrollTimerMsg, SB_THUMBPOSITION, nLastSBPos);
          sw.fThumbTracking := False;
        end;
        //send the SB_ENDSCROLL message now that scrolling has finished
        sw.DontRepaint := True;
        SendScrollMessage(Handle, uScrollTimerMsg, SB_ENDSCROLL, 0);
        sw.DontRepaint := False;

        //adjust the total scroll area to become where the scrollbar
        //really is (take into account the inserted buttons)
        Ac_GetRealScrollRect(sb, R);
        OffsetRect(R, -winrect.left, -winrect.top);
        dc := GetWindowDC(Handle);
        //draw whichever scrollbar sb is
        Ac_NCDrawScrollbar(sb, Handle, dc, R, HTSCROLL_NORMAL);
        ReleaseDC(Handle, dc);
      end;
      HTSCROLL_THUMB: begin
        //In case we were thumb tracking, make sure we stop NOW

        if sw.fThumbTracking then begin
          sw.DontRepaint := True;
          SendScrollMessage(Handle, uScrollTimerMsg, SB_THUMBPOSITION, nLastSBPos);
          sw.fThumbTracking := False;
        end;
        //send the SB_ENDSCROLL message now that scrolling has finished
        sw.DontRepaint := True;
        SendScrollMessage(Handle, uScrollTimerMsg, SB_ENDSCROLL, nLastSBPos);
        sw.DontRepaint := False;

        //adjust the total scroll area to become where the scrollbar
        //really is (take into account the inserted buttons)
        Ac_GetRealScrollRect(sb, R);
        OffsetRect(R, -winrect.left, -winrect.top);
        dc := GetWindowDC(Handle);
        //draw whichever scrollbar sb is
        Ac_NCDrawScrollbar(sb, Handle, dc, R, HTSCROLL_NORMAL);
        ReleaseDC(Handle, dc);
      end;
    end;

    //reset our state to default
    uCurrentScrollPortion := HTSCROLL_NONE;
    uScrollTimerPortion	  := HTSCROLL_NONE;
    uScrollTimerId	  := 0;

    uScrollTimerMsg       := 0;
    uCurrentScrollbar     := COOLSB_NONE;
    if (sw.SkinData.FOwnerControl <> nil) then begin
      if (sw.SkinData.FOwnerControl.ClassName <> 'TImageEnView') and (sw.SkinData.FOwnerControl.ClassName <> 'TImageEnVect')
        then Result := sw.CallPrevWndProc(Handle, WM_LBUTTONUP, WParam, LParam);
    end
    else if not ((sw is TacComboListWnd) and not TacComboListWnd(sw).SimplyBox) then begin
      Result := sw.CallPrevWndProc(Handle, WM_LBUTTONUP, WParam, LParam);
    end;
  end
  else Result := sw.CallPrevWndProc(Handle, WM_LBUTTONUP, WParam, LParam);
end;

function Ac_Timer(sw : TacScrollWnd; Handle : hwnd; wTimerId : longint; lParam : longint) : longint;
var
  pt : TPoint;
  rect, winrect : TRect;
  DC : hdc;
  sbar : TacScrollBar;
begin
  Result := 0;
  //let all timer messages go past if we don't have a timer installed ourselves
  if (uScrollTimerId = 0) and (uMouseOverId = 0) then begin
    Result := sw.CallPrevWndProc(Handle, WM_TIMER, wTimerID, LParam);
  end;
  //mouse-over timer
  if wTimerId = COOLSB_TIMERID3 then begin
    if sw.fThumbTracking then Exit;
    // if the mouse moves outside the current scrollbar, then kill the timer..
    GetCursorPos(pt);

    if not PtInRect(MouseOverRect, pt) then begin
      KillTimer(Handle, uMouseOverId);
      uMouseOverId := 0;
      uMouseOverScrollbar := COOLSB_NONE;
      uLastHitTestPortion := HTSCROLL_NONE;

      uHitTestPortion := HTSCROLL_NONE;
      Ac_NCPaint(sw, Handle, 1, 0);
    end
    else begin
      if uMouseOverScrollbar = SB_HORZ then begin
        uHitTestPortion := Ac_GetHorzPortion(sw.sbarHorz, Handle, MouseOverRect, pt.x, pt.y);
        sbar := sw.sbarHorz;
      end
      else begin
        uHitTestPortion := Ac_GetVertPortion(sw.sbarVert, Handle, MouseOverRect, pt.x, pt.y);
        sbar := sw.sbarVert;
      end;

      if uLastHitTestPortion <> uHitTestPortion then begin
        rect := MouseOverRect;
        Ac_GetRealScrollRect(sbar, rect);

        GetWindowRect(Handle, winrect);
        OffsetRect(rect, -winrect.left, -winrect.top);
        dc := GetWindowDC(Handle);
        Ac_NCDrawScrollbar(sbar, Handle, dc, rect, HTSCROLL_NONE);
        ReleaseDC(Handle, dc);
      end;
      uLastHitTestPortion := uHitTestPortion;
    end;
    Exit;
  end;

  //if the first timer goes off, then we can start a more
  //regular timer interval to auto-generate scroll messages
  //this gives a slight pause between first pressing the scroll arrow, and the
  //actual scroll starting
  if (wTimerID = COOLSB_TIMERID1) then begin
    KillTimer(Handle, uScrollTimerId);
    uScrollTimerId := SetTimer(Handle, COOLSB_TIMERID2, COOLSB_TIMERINTERVAL2, nil);
    Result := 0;
  end
  //send the scrollbar message repeatedly
  else if (wTimerID = COOLSB_TIMERID2) then begin
    //need to process a spoof WM_MOUSEMOVE, so that
    //we know where the mouse is each time the scroll timer goes off.
    //This is so we can stop sending scroll messages if the thumb moves
    //under the mouse.
    GetCursorPos(pt);
    ScreenToClient(Handle, pt);
    if pt.X < 0 then pt.X := 0;
    if pt.Y < 0 then pt.Y := 0;
    Ac_MouseMove(sw, Handle, MK_LBUTTON, MAKELPARAM(Word(pt.x), Word(pt.y)));

    if (uScrollTimerPortion <> HTSCROLL_NONE) then begin
      sw.DontRepaint := True;
      SendScrollMessage(Handle, uScrollTimerMsg, uScrollTimerPortion, 0);
      sw.DontRepaint := False;
    end;

    Result := 0;
  end
  else
    Result := sw.CallPrevWndProc(Handle, WM_TIMER, WM_TIMER, LParam);
end;

destructor TacScrollWnd.Destroy;
begin
  if Assigned(sBarHorz) then FreeAndnil(sBarHorz);
  if Assigned(sBarVert) then FreeAndnil(sBarVert);
  inherited Destroy;
end;

procedure TacScrollWnd.acWndProc(var Message: TMessage);
var
  ListSW : TacScrollWnd;
begin
  case Message.Msg of
    WM_CONTEXTMENU : if (SkinData <> nil) and (SkinData.FOwnerControl <> nil) and (TsHackedControl(SkinData.FOwnerControl).PopupMenu <> nil) then begin
      if SkinData.SkinManager <> nil
        then SkinData.SkinManager.SkinableMenus.HookPopupMenu(TsHackedControl(SkinData.FOwnerControl).PopupMenu, SkinData.SkinManager.Active);
    end;
    WM_UPDATEUISTATE : begin
      Exit;
    end;
    CM_RECREATEWND : if not IsWindowVisible(CtrlHandle) then begin
      if (SkinData.FOwnerControl <> nil) and (SkinData.FOwnerControl is TCustomComboBox) then Exit; // Problem with TDriveComboBox
    end;
    WM_DESTROY, WM_NCDESTROY: begin
      if (OldProc <> nil) or Assigned(OldWndProc) then begin
        ListSW := Self;
        Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
        if Message.Result = 0 then
        try
          UninitializeACScroll(CtrlHandle, False, False, ListSW);
        except
        end;
      end
      else Message.Result := SendMessage(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
      Exit;
    end;
  end;
  if Destroyed then Exit;
  if not Assigned(SkinData) or not SkinData.Skinned then begin
    if Assigned(SkinData) and (Message.Msg = SM_ALPHACMD) then begin
      case Message.WParamHi of
        AC_SETNEWSKIN : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
          SkinData.UpdateIndexes;
        end;
      end;
    end;
    Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
  end
  else begin
    if Message.Msg = SM_ALPHACMD then begin
      case Message.WParamHi of
        AC_GETBG : if SkinData <> nil then begin
          Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
          if PacBGInfo(Message.LParam).BgType = btUnknown then InitBGInfo(SkinData, PacBGInfo(Message.LParam), 0);
          Exit;
        end;
        AC_CTRLHANDLED : begin Message.Result := 1; Exit end;
        AC_GETAPPLICATION : begin Message.Result := longint(Application); Exit end;
        AC_REMOVESKIN : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
          RestoreStdParams;
        end;
        AC_SETSECTION : if (Message.LParam <> 0) and (SkinData <> nil) then SkinData.SkinSection := PacSectionInfo(Message.LParam).Name;
        AC_SETNEWSKIN : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
          SkinData.UpdateIndexes;
          AlphaBroadCastCheck(SkinData.FOwnerControl, CtrlHandle, Message);
        end;
        AC_REFRESH : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
          SkinData.UpdateIndexes;
          SkinData.BGChanged := True;
        end;
        AC_UPDATING        : Skindata.Updating := Message.WParamLo = 1;
        AC_ENDPARENTUPDATE : if SkinData.FUpdating then begin
//          InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
{$IFNDEF ALITE}
{$IFDEF D2006}
          if (SkinData.FOwnerObject <> nil) and (SkinData.FOwnerObject is TsFrameAdapter) and (csAligning in TsFrameAdapter(SkinData.FOwnerObject).Frame.ControlState) then Exit;
{$ENDIF}
{$ENDIF}
          SkinData.FUpdating := False;
          SkinData.FUpdating := SkinData.Updating;
          if not SkinData.FUpdating
            then RedrawWindow(CtrlHandle, nil, 0, RDW_ALLCHILDREN or RDW_INVALIDATE or RDW_ERASE or RDW_FRAME);
        end;
        AC_GETCONTROLCOLOR : begin
          Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
          if Message.Result = 0 then Message.Result := GetBGColor(SkinData, 0);
          Exit;
        end;
      end
    end
    else case Message.Msg of
{
      CM_UIACTIVATE : if WndSize.cx <> 0 then begin // Hack. Updating of scrollbars after window activation
        Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
        if Message.Result = 0
          then SetWindowPos(CtrlHandle, 0, 0, 0, WndSize.cx, WndSize.cy, SWP_NOMOVE or SWP_NOZORDER or SWP_NOCOPYBITS or SWP_NOSENDCHANGING or SWP_NOREPOSITION or SWP_FRAMECHANGED);
        Exit;
      end;
}
      WM_NCCALCSIZE: begin
        Message.Result := Ac_NCCalcSize(Self, Self.CtrlHandle, Message.wParam, Message.lParam);
        Exit
      end;
      WM_NCPAINT: if IsWindowVisible(CtrlHandle) then begin
        SkinData.FUpdating := SkinData.Updating;
        if not SkinData.FUpdating and not DontRepaint then Message.Result := integer(Ac_NCPaint(Self, CtrlHandle, Message.WParam, Message.LParam));
      end;
      WM_NCRBUTTONDOWN, WM_NCRBUTTONUP, WM_NCMBUTTONDOWN, WM_NCMBUTTONUP:
       if (Message.wParam = HTHSCROLL) or (Message.wParam = HTVSCROLL) then begin
        Message.Result := 0;
        Exit
      end;
      WM_NCLBUTTONDBLCLK: if (Message.wParam = HTHSCROLL) or (Message.wParam = HTVSCROLL) then begin
        Message.Result := Ac_NCLButtonDown(Self, CtrlHandle, Message.wParam, Message.lParam);
        Exit
      end;
      WM_NCHITTEST: begin
        Message.Result := Ac_NCHitTest(Self, CtrlHandle, Message.WParam, Message.LParam);
        Exit
      end;
      WM_NCLBUTTONDOWN: if (Message.wParam = HTHSCROLL) or (Message.wParam = HTVSCROLL) then begin
        Message.Result := Ac_NCLButtonDown(Self, CtrlHandle, Message.wParam, Message.lParam);
        Exit
      end;
      WM_LBUTTONUP: begin
        Message.Result := Ac_LButtonUp(Self, CtrlHandle, Message.WParam, Message.LParam);
        Exit
      end;
      WM_NOTIFY: begin
        Message.Result := Ac_Notify(Self, CtrlHandle, Message.WPAram, Message.LParam);
        Exit
      end;
      WM_MOUSEMOVE: begin
        Message.Result := Ac_MouseMove(Self, CtrlHandle, Message.WPAram, Message.LParam);
        Exit
      end;
      WM_TIMER: begin
        Message.Result := Ac_Timer(Self, CtrlHandle, Message.WPAram, Message.LParam);
        if not DontRepaint and not fThumbTracking then UpdateScrolls(Self, True);
        Exit
      end;
      WM_STYLECHANGED: begin
        if bPreventStyleChange then begin // the NCPAINT handler has told us to eat this message!
          Message.Result := 0;
        end
        else begin
          Message.Result := Ac_StyleChange(Self, CtrlHandle, Message.WPAram, Message.LParam);
        end;
        Exit
      end;
      WM_NCMOUSEMOVE: begin
        Message.Result := Ac_NCMouseMove(Self, CtrlHandle, Message.WPAram, Message.LParam);
        Exit
      end;
      WM_SYSCOMMAND : if Message.WParamlo = 61559 then Exit; // Prevent of standard scrollbar showing after wnd activation
    end;
    Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
    case Message.Msg of
      WM_MOUSEWHEEL, CM_MOUSEWHEEL : if not DontRepaint then UpdateScrolls(Self, True); 
      CM_FOCUSCHANGED : UpdateScrolls(Self, True);
    end;
  end;
end;

procedure TacEditWnd.acWndProc(var Message: TMessage);
var
  DC, SavedDC : hdc;
  PS : TPaintStruct;
  R : TRect;
begin
{$IFDEF LOGGED}
//  AddToLog(Message);
{$ENDIF}
  if not Assigned(SkinData) or not SkinData.Skinned then begin
    inherited acWndProc(Message);
    Exit;
  end;
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_CTRLHANDLED : begin Message.Result := 1; Exit end;
    AC_GETAPPLICATION : begin Message.Result := longint(Application); Exit end;
    AC_ENDPARENTUPDATE : if SkinData.FUpdating then begin
      SkinData.FUpdating := False;
      SkinData.FUpdating := SkinData.Updating;
      if not SkinData.FUpdating then RedrawWindow(CtrlHandle, nil, 0, RDW_ALLCHILDREN or RDW_INVALIDATE or RDW_FRAME or RDW_UPDATENOW or RDW_ERASE);
    end;
    AC_PREPARECACHE : begin
      InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
      PrepareCache(SkinData, CtrlHandle, DlgMode);
      UpdateWndCorners(SkinData, 0, Self);
      Exit;
    end;
    AC_GETSKININDEX : begin
      PacSectionInfo(Message.LParam)^.SkinIndex := SkinData.SkinIndex;
      Exit;
    end;
    AC_REFRESH : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
      inherited;
      SetSkinParams;
      Exit;
    end;
  end
  else case Message.Msg of
//    WM_USER + 68{EM_SETCHARFORMAT} : begin // Prevent of OnChange event calling in RichEdit
//      if SkinData.Updating then Exit;
//    end;
    WM_PRINT : begin
      Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
      if Message.Result = 2 then Exit; // Processed already
//      SkinData.CtrlSkinState := SkinData.CtrlSkinState or ACS_PRINTING;
      InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
      SkinData.FUpdating := False;
      SkinData.BGChanged := True;
      DC := TWMPaint(Message).DC;

      if not ParamsChanged then SetSkinParams;
      if SkinData = nil then Exit;
      PrepareCache(SkinData, CtrlHandle, DlgMode);

      if not DlgMode then UpdateWndCorners(SkinData, 0, Self);
      BitBltBorder(DC, 0, 0, SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height, SkinData.FCacheBmp.Canvas.Handle, 0, 0, cxLeftEdge);
      Message.Result := Ac_NCPaint(Self, Self.CtrlHandle, Message.wParam, Message.lParam, -1, DC);

      SavedDC := SaveDC(DC);
      MoveWindowOrg(DC, cxLeftEdge, cxLeftEdge);
      IntersectClipRect(DC, 0, 0,
                        SkinData.FCacheBmp.Width - 2 * cxLeftEdge - integer(sBarVert.fScrollVisible) * GetScrollMetric(sBarVert, SM_CXVERTSB),
                        SkinData.FCacheBmp.Height - 2 * cxLeftEdge - integer(sBarHorz.fScrollVisible) * GetScrollMetric(sBarHorz, SM_CYHORZSB));
      SendMessage(CtrlHandle, WM_ERASEBKGND, longint(DC), 0);

{$IFNDEF D2005}
      if (SkinData.FOwnerControl <> nil) and (SkinData.FOwnerControl is TCustomListBox) then begin // Fix empty ListBox drawing bug, fixed in latest Delphi versions
        if (TCustomListBox(SkinData.FOwnerControl).Items.Count <> 0) then SendMessage(CtrlHandle, WM_PAINT, longint(DC), 0);
      end
      else
{$ENDIF}
      SendMessage(CtrlHandle, WM_PAINT, longint(DC), 0);
      SendMessage(CtrlHandle, WM_PRINTCLIENT, longint(DC), PRF_CLIENT or PRF_OWNED);
      RestoreDC(DC, SavedDC);
//      SkinData.CtrlSkinState := SkinData.CtrlSkinState and not ACS_PRINTING;
    end;
    CM_FONTCHANGED : if not SkinData.FUpdating then RedrawWindow(CtrlHandle, nil, 0, RDW_ERASE or RDW_INVALIDATE or RDW_FRAME);
    WM_ERASEBKGND : if IsWindowVisible(CtrlHandle) and not bPreventStyleChange then begin
      if (TWMPaint(Message).DC <> SkinData.PrintDC) and (GetClipBox(TWMPaint(Message).DC, R) = NULLREGION) then begin
        Exit;
      end;
      SkinData.FUpdating := SkinData.Updating;
      if SkinData.FUpdating then Exit;
      if not ParamsChanged then SetSkinParams;
      if (Win32MajorVersion >= 6) and InAnimationProcess and (TWMPaint(Message).DC <> SkinData.PrintDC) then begin
        Message.Result := 1;
        Exit;
      end;
    end;
    WM_PAINT : if IsWindowVisible(CtrlHandle) and not bPreventStyleChange then begin
      if (TWMPaint(Message).DC <> SkinData.PrintDC) and (GetClipBox(TWMPaint(Message).DC, R) = NULLREGION) then begin
        Exit;
      end;
      SkinData.FUpdating := SkinData.Updating;
      if SkinData.FUpdating or (InAnimationProcess and (SkinData.PrintDC = 0)) then begin
        BeginPaint(CtrlHandle, PS);
        EndPaint(CtrlHandle, PS);
        Exit;
      end
      else Message.Result := Ac_NCPaint(Self, Self.CtrlHandle, Message.wParam, Message.lParam, -1, hdc(Message.wParam));
      if not ParamsChanged then SetSkinParams;
    end;
{
    CM_MOUSEENTER : begin
      if MayBeHot(SkinData) then begin
        inherited;
        Skindata.FMouseAbove := True;
        if Skindata.COC = COC_TsAdapter then ShowGlowingIfNeeded(SkinData);
        if Skindata.FOwnerControl <> nil then begin
          Skindata.BGChanged := True;
  //        RedrawWindow(TWinControl(Skindata.FOwnerControl).Handle, nil, 0, RDW_INVALIDATE or RDW_FRAME);
          SendMessage(TWinControl(Skindata.FOwnerControl).Handle, WM_NCPAINT, 0, 0);
        end;
      end
      else Exit;
    end;
    CM_MOUSELEAVE : begin
      if MayBeHot(SkinData) then begin
        inherited;
        Skindata.FMouseAbove := False;
        if Skindata.FOwnerControl <> nil then begin
          Skindata.BGChanged := True;
          SendMessage(TWinControl(Skindata.FOwnerControl).Handle, WM_NCPAINT, 0, 0);
  //        RedrawWindow(TWinControl(Skindata.FOwnerControl).Handle, nil, 0, RDW_INVALIDATE or RDW_FRAME);
        end;
        ClearGlows;
      end
      else Exit;
    end;
}
    WM_NCPAINT : if IsWindowVisible(CtrlHandle) and not bPreventStyleChange then begin
      if not InAnimationProcess then begin
        SkinData.FUpdating := SkinData.Updating;
        if SkinData.FUpdating then begin
//          ReleaseDC(CtrlHandle, DC);
          Exit;
        end;
        DC := GetWindowDC(CtrlHandle);
        if (DC <> SkinData.PrintDC) and (GetClipBox(DC, R) = NULLREGION) then begin
          ReleaseDC(CtrlHandle, DC);
          Exit;
        end;
//        InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
        if SkinData.BGChanged then begin
          if not ParamsChanged then SetSkinParams;
          PrepareCache(SkinData, CtrlHandle, DlgMode);
        end;
        SavedDC := SaveDC(DC);
        try
          Message.Result := Ac_NCPaint(Self, Self.CtrlHandle, Message.wParam, Message.lParam, -1, DC);
          if (DC <> 0) and (SkinData <> nil) then BitBltBorder(DC, 0, 0, SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height, SkinData.FCacheBmp.Canvas.Handle, 0, 0, cxLeftEdge);
        finally
          RestoreDC(DC, SavedDC);
          ReleaseDC(CtrlHandle, DC);
        end;
      end;
      Exit;
    end;
    WM_SETFOCUS: begin
      inherited acWndProc(Message);
      if MayBeHot(SkinData) and Assigned(Skindata.FOwnerControl) and (Skindata.FOwnerControl is TWinControl) and TWinControl(Skindata.FOwnerControl).CanFocus and TWinControl(Skindata.FOwnerControl).TabStop then begin
        Skindata.BGChanged := True;
        Skindata.FFocused := True;
        SendMessage(TWinControl(Skindata.FOwnerControl).Handle, WM_NCPAINT, 0, 0);
      end;
      Exit;
    end;
    WM_KILLFOCUS : begin
      inherited acWndProc(Message);
      if MayBeHot(SkinData) and Assigned(Skindata.FOwnerControl) and (Skindata.FOwnerControl is TWinControl) and TWinControl(Skindata.FOwnerControl).CanFocus and TWinControl(Skindata.FOwnerControl).TabStop then begin
        Skindata.BGChanged := True;
        Skindata.FFocused := False;
        SendMessage(TWinControl(Skindata.FOwnerControl).Handle, WM_NCPAINT, 0, 0);
      end;
      Exit;
    end;
  end;
  inherited acWndProc(Message);
  case Message.Msg of
    LB_GETTOPINDEX : begin // Fix of empty ListBox drawing bug
      if (SkinData.FOwnerControl <> nil) and (SkinData.FOwnerControl is TCustomListBox) then begin
        if (Message.Result = 0) and (TCustomListBox(SkinData.FOwnerControl).Items.Count = 0) then Message.Result := -1;
      end;
    end;
    LB_SETCURSEL : UpdateScrolls(Self, True);
    LB_INSERTSTRING, LB_SETTOPINDEX, EM_REPLACESEL, LB_ADDSTRING : UpdateScrolls(Self, True);
    WM_SETFONT, WM_KEYDOWN, WM_KEYUP, CN_KEYDOWN, CN_KEYUP, WM_LBUTTONDOWN : begin
      if not DontRepaint
        then UpdateScrolls(Self, True)
    end;
    WM_SIZE : if IsWindowVisible(CtrlHandle) then begin
//      InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
      SendMessage(CtrlHandle, WM_NCPAINT, 0, 0);
    end;
    WM_MOUSEMOVE : if (DefaultManager <> nil) and not (csDesigning in DefaultManager.ComponentState) and IsWindowEnabled(CtrlHandle) then begin
      if (DefaultManager.ActiveControl <> CtrlHandle) then DefaultManager.ActiveControl := CtrlHandle;
      if not SkinData.Updating and (GetCapture <> 0) then UpdateScrolls(Self, True); // For ImageEn and similar products
    end;
  end;
end;

constructor TacEditWnd.Create(AHandle: hwnd; ASkinData: TsCommonData; ASkinManager: TsSkinManager; const SkinSection: string; Repaint: boolean);
begin
  if aHandle <> 0 then begin
    if (Repaint or not (Self is TacComboListWnd)) and not (Self is TacGridWnd) and (uxthemeLib <> 0) and (SkinSection <> s_Dialog) then begin
      if (ASkinData = nil) then Ac_SetWindowTheme(AHandle, ' ', ' ') else begin
        if not ((ASkinData.COC in [COC_TsListView]) and AeroIsEnabled) then Ac_SetWindowTheme(AHandle, ' ', ' ');
      end;
    end;
    CtrlHandle := AHandle;
    NewWndProcInstance := nil;
    SkinManager := ASkinManager;
    Destroyed := False;
    if ASkinData <> nil then begin
      SkinData := ASkinData;
      if SkinManager = nil then SkinManager := SkinData.SkinManager;
    end
    else begin
      OwnSkinData := True;
      SkinData := TsCommonData.Create(nil, True);
    end;
    SkinData.CustomFont := ac_KeepOwnFont or SkinData.CustomFont;
    if SkinSection = '' then SkinData.SkinSection := s_Edit else SkinData.SkinSection := SkinSection;
    SaveStdParams;
    ParamsChanged := False;
    DlgMode := acDlgMode;
    InitializeACScrolls(Self, AHandle, Repaint);
    if (SkinData.FOwnerControl <> nil) and not (SkinData.FOwnerControl is TCustomListView) then SkinData.FOwnerControl.ControlStyle := SkinData.FOwnerControl.ControlStyle + [csOpaque];
  end;
end;

procedure TacEditWnd.RestoreStdParams;
begin
  inherited;
  // Scrolbars updating if exists
  if IsWindowVisible(CtrlHandle) 
    then SetWindowPos(CtrlHandle, 0, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE or SWP_NOZORDER or SWP_NOREPOSITION or SWP_FRAMECHANGED);
  if Assigned(SkinData) and Assigned(SkinData.FOwnerControl) and not (csDestroying in SkinData.FOwnerControl.ComponentState) then begin
    TsHackedControl(SkinData.FOwnerControl).Color := StdColor;
    TsHackedControl(SkinData.FOwnerControl).Font.Color := StdFontColor;
    if HasProperty(SkinData.FOwnerControl, acFocusColor) then SetIntProp(SkinData.FOwnerControl, acFocusColor, FocusColor);
  end;
end;

procedure TacEditWnd.SaveStdParams;
begin
  inherited;
  if Assigned(SkinData) and Assigned(SkinData.FOwnerControl) then begin
    StdColor := TsHackedControl(SkinData.FOwnerControl).Color;
    StdFontColor := TsHackedControl(SkinData.FOwnerControl).Font.Color;
    if HasProperty(SkinData.FOwnerControl, acFocusColor) then FocusColor := GetIntProp(SkinData.FOwnerControl, acFocusColor);
  end
end;

procedure TacEditWnd.SetSkinParams;
var
  C : TColor;
  b : boolean;
begin
  if not bPreventStyleChange then begin
    SkinData.Updating := True;
    bPreventStyleChange := True;
    inherited;
    if Assigned(SkinData) and Assigned(SkinData.FOwnerControl) then begin
      b := ControlIsActive(SkinData) and (SkinData.SkinManager.gd[SkinData.SkinIndex].States > 1);
      if not SkinData.CustomColor then begin
        C := GetBGColor(SkinData, integer(b));
        if HasProperty(SkinData.FOwnerControl, acFocusColor) then begin
          if TsHackedControl(SkinData.FOwnerControl).Color <> C then SetIntProp(SkinData.FOwnerControl, acColor, C);
          SetIntProp(SkinData.FOwnerControl, acFocusColor, C);
        end
        else if TsHackedControl(SkinData.FOwnerControl).Color <> C then TsHackedControl(SkinData.FOwnerControl).Color := C;
      end;
      if Assigned(SkinData) and not SkinData.CustomFont then begin
        if b and (SkinData.SkinManager.gd[SkinData.SkinIndex].States > 1)
          then C := SkinData.SkinManager.gd[SkinData.SkinIndex].HotFontColor[1]
          else C := SkinData.SkinManager.gd[SkinData.SkinIndex].FontColor[1];
        if TsHackedControl(SkinData.FOwnerControl).Font.Color <> C then begin
          TsHackedControl(SkinData.FOwnerControl).Font.Color := C;
          if Destroyed then Exit;
        end;
      end
    end
    else begin
      if not DlgMode and Assigned(SkinData) and SkinData.SkinManager.IsValidSkinIndex(SkinData.SkinIndex) then Color := SkinData.SkinManager.gd[SkinData.SkinIndex].Color else Color := clWindow;
      FrameColor := clBlack;
    end;
    if Assigned(SkinData) then SkinData.BGChanged := True;
    bPreventStyleChange := False;
    SkinData.Updating := False;
  end;
end;

type
  TacAccessLV = class(TListView);

procedure TacListViewWnd.acWndProc(var Message: TMessage);
var
  M : TMessage;
  WndName : string;
  R : TRect;
  SavedDC : hdc;
  DstPos, Delta : integer;
begin
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_GETSKININDEX : begin
      PacSectionInfo(Message.LParam)^.SkinIndex := SkinData.SkinIndex;
      Exit;
    end;
    AC_REFRESH : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
      inherited;
      M := MakeMessage(WM_PAINT, 0, 0, 0);
      HeaderWndProc(M);
      Exit;
    end;
    AC_BEFORESCROLL : begin
      Message.Result := 1; // it's a listview
      Exit;
    end;
  end;
  case Message.Msg of
    WM_NCPAINT : begin
      Message.Result := 0;
      inherited;
    end;
    WM_NCHITTEST : begin
      if (HoverColIndex > -1) or (FPressedColumn > -1) then begin
        HoverColIndex := -1;
        FPressedColumn := -1;
        PaintHeader(0);
      end;
    end;
    WM_VSCROLL : begin
      if (Message.WParamLo = SB_THUMBTRACK) then begin
        if Message.LParam <> 0 then DstPos := Message.LParam else DstPos := Message.WParamHi;
        if nLastSBPos <> DstPos then begin // If CurPos is changed
          Delta := DstPos - nLastSBPos;
          if ViewStyle = vsReport then begin
            ListView_GetItemRect(CtrlHandle, 0, R, LVIR_BOUNDS);
            Delta := Delta * HeightOf(R);
          end;
          ListView_Scroll(CtrlHandle, 0, Delta);
        end
      end
      else begin
        Message.LParam := 0;
        Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
      end;
      Exit;
    end;
    WM_HSCROLL : begin
      case Message.WParamLo of
        SB_THUMBTRACK : begin
          if Message.LParam <> 0 then DstPos := Message.LParam else DstPos := Message.WParamHi;
          Delta := DstPos - nLastSBPos;
          if ViewStyle = vsList then begin
            ListView_GetItemRect(CtrlHandle, 0, R, LVIR_BOUNDS);
            Delta := Delta * WidthOf(R);
          end;
          ListView_Scroll(CtrlHandle, Delta, 0);
        end;
        else Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
      end;
      Exit;
    end;
    WM_PAINT : SetSkinParams;
  end;
  inherited acWndProc(Message);
  case Message.Msg of
    WM_LBUTTONUP: begin
      ReleaseCapture;
    end;
    LVM_ARRANGE, WM_STYLECHANGED : begin
      if not SkinData.Updating then UpdateScrolls(Self, True);
    end;
    WM_PRINT : begin
//      Message.LParam := PRF_CHILDREN or PRF_OWNED or PRF_CLIENT;
//      Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
      if ViewStyle = vsReport then begin
        SavedDC := SaveDC(TWMPaint(Message).DC);
        MoveWindowOrg(TWMPaint(Message).DC, cxLeftEdge, cxLeftEdge);
        IntersectClipRect(TWMPaint(Message).DC, 0, 0,
                          SkinData.FCacheBmp.Width - 2 * cxLeftEdge - integer(sBarVert.fScrollVisible) * GetScrollMetric(sBarVert, SM_CXVERTSB),
                          SkinData.FCacheBmp.Height - 2 * cxLeftEdge - integer(sBarHorz.fScrollVisible) * GetScrollMetric(sBarHorz, SM_CYHORZSB));
        PaintHeader(TWMPaint(Message).DC);
        RestoreDC(TWMPaint(Message).DC, SavedDC);
      end;
      Exit;
    end;
    WM_PARENTNOTIFY : with TWMParentNotify(Message) do begin
      SetLength(WndName, 96);
      SetLength(WndName, GetClassName(ChildWnd, PChar(WndName), Length(WndName)));
      if (WndName = WC_HEADER{'SysHeader32'}) then begin
        case Event of
          WM_CREATE : begin
            if (FhWndHeader <> 0) then begin
              SetWindowLong(FhWndHeader, GWL_WNDPROC, Longint(FhDefHeaderProc));
              FhWndHeader := 0;
            end
            else begin
              FhWndHeader := ChildWnd;
              FhDefHeaderProc := Pointer(GetWindowLong(FhWndHeader, GWL_WNDPROC));
              SetWindowLong(FhWndHeader, GWL_WNDPROC, Longint(FhHeaderProc));
            end;
          end;
        end;
      end;
    end;
    LVM_INSERTITEMA : if not SkinData.Updating then UpdateScrolls(Self, True);
  end;
end;

function TacListViewWnd.AllColWidth: integer;
var
  i, w, c : integer;
begin
  Result := 0;
  if SkinData.FOwnerControl = nil then Exit;
  c := TacAccessLV(SkinData.FOwnerControl).Columns.Count - 1;
  for i := 0 to c do begin
    w := integer(ListView_GetColumnWidth(CtrlHandle, i));
    if abs(w) > 999999 then Exit;
    Result := integer(Result + w);
  end
end;

procedure TacListViewWnd.ColumnSkinPaint(ControlRect: TRect; cIndex: Integer; DC : hdc);
const
  HDF_SORTDOWN = $0200;
  HDF_SORTUP = $0400;
var
  R, TextRC   : TRect;
  tmpdc : HDC;
  TempBmp : Graphics.TBitmap;
  State, si : integer;
  Flags : integer;
  bf : HFont;
{$IFDEF TNTUNICODE}
  Item: THDItemW;
{$ELSE}
  Item: THDItem;
{$ENDIF}
  Buf: array[0..128] of acChar;
  ws : acString;
  ts, ArrowSize : TSize;
  ArrowIndex : integer;
  CI : TCacheInfo;
  gWidth : integer;
begin
  try
    TempBmp := CreateBmp32(WidthOf(ControlRect, True), HeightOf(ControlRect, True));
    R := Rect(0, 0, TempBmp.Width, TempBmp.Height);
    if FPressedColumn >= 0 then State := iffi(FPressedColumn = cIndex, 2, 0) else if HoverColIndex = cIndex then State := 1 else State := 0;
    CI.Ready := False;
    if SkinData.FOwnerControl <> nil then CI.FillColor := TacAccessLV(SkinData.FOwnerControl).color else CI.FillColor := clWindow;
    si := PaintSection(TempBmp, s_ColHeader, s_Button, State, SkinData.SkinManager, ControlRect.TopLeft, CI.FillColor);
    bf := LongWord(SendMessage(CtrlHandle, WM_GETFONT, 0, 0));
    SelectObject(TempBmp.Canvas.Handle, bf);
    TextRC := R;
    InflateRect(TextRC, -4, -1);
    TempBmp.Canvas.Brush.Style := bsClear;
    FillChar(Item, SizeOf(Item), 0);
    FillChar(Buf, SizeOf(Buf), 0);
    Item.pszText := PacChar(@Buf);
    Item.cchTextMax := SizeOf(Buf);
    Item.Mask := HDI_TEXT or HDI_FORMAT or HDI_IMAGE or HDI_BITMAP;

    if (cIndex >= 0) and bool(SendMessage(FHwndHeader, {$IFDEF TNTUNICODE}HDM_GETITEMW{$ELSE}HDM_GETITEM{$ENDIF}, cIndex, Longint(@Item))) then begin // ?
      ws := acString(Item.pszText);
      Flags := DT_END_ELLIPSIS or DT_EXPANDTABS or DT_SINGLELINE or DT_VCENTER;
      if (SkinData.FOwnerControl = nil) or (TacAccessLV(SkinData.FOwnerControl).SmallImages = nil) or (Item.fmt and (LVCFMT_IMAGE or LVCFMT_COL_HAS_IMAGES) = 0) then begin
        Item.iImage := -1;
        gWidth := 0;
      end
      else gWidth := TacAccessLV(SkinData.FOwnerControl).SmallImages.Width + 4;

      if item.fmt and HDF_SORTDOWN = HDF_SORTDOWN
        then ArrowIndex := SkinData.SkinManager.GetMaskIndex(SkinData.SkinManager.ConstData.IndexScrollBottom, s_ScrollBtnBottom, s_ItemGlyph)
        else if item.fmt and HDF_SORTUP = HDF_SORTUP
          then ArrowIndex := SkinData.SkinManager.GetMaskIndex(SkinData.SkinManager.ConstData.IndexScrollTop, s_ScrollBtnTop, s_ItemGlyph)
          else ArrowIndex := -1;
      if ArrowIndex <> -1 then begin
        ArrowSize.cx := WidthOfImage(SkinData.SkinManager.ma[ArrowIndex]) + 6;
        ArrowSize.cy := HeightOfImage(SkinData.SkinManager.ma[ArrowIndex]);
      end
      else begin
        ArrowSize.cx := 0;
        ArrowSize.cy := 0;
      end;

{$IFDEF TNTUNICODE}
      GetTextExtentPoint32W(TempBmp.Canvas.Handle, PacChar(ws), Length(ws), ts);
{$ELSE}
      GetTextExtentPoint32(TempBmp.Canvas.Handle, PacChar(ws), Length(ws), ts);
{$ENDIF}
      inc(ts.cx, 5);
      case (Item.fmt and $0ff) of
        HDF_CENTER : begin
          TextRc.Left := (WidthOf(TextRc) - ts.cx - ArrowSize.cx - gWidth) div 2 + TextRc.Left + gWidth;
          TextRc.Right := TextRc.Left + ts.cx;
        end;
        HDF_RIGHT : begin
          TextRc.Right := TextRc.Right - ArrowSize.cx;
          TextRc.Left := TextRc.Right - ts.cx;
        end
        else begin
          TextRc.Left := TextRc.Left + gWidth;
          TextRc.Right := TextRc.Left + ts.cx;
        end
      end;
      if ArrowIndex <> -1 then DrawSkinGlyph(TempBmp, Point(TextRc.Right + 6, (HeightOf(TextRc) - ArrowSize.cy) div 2), State, 1, SkinData.SkinManager.ma[ArrowIndex], MakeCacheInfo(TempBmp));

      if (State = 2) then OffsetRect(TextRc, 1, 1);
      acWriteTextEx(TempBmp.Canvas, PacChar(ws), True, TextRc, Flags, si, (State <> 0), SkinData.SkinManager);
      if (item.iImage <> -1) and (SkinData.FOwnerControl <> nil)
        then TacAccessLV(SkinData.FOwnerControl).SmallImages.Draw(TempBmp.Canvas, TextRc.Left - gWidth, (HeightOf(TextRc) - TacAccessLV(SkinData.FOwnerControl).SmallImages.Height) div 2 + integer(State = 2), Item.iImage, TacAccessLV(SkinData.FOwnerControl).Enabled);
    end;

    if DC = 0 then tmpdc := GetDC(FhWndHeader) else tmpdc := DC;
    try
      BitBlt(tmpdc, ControlRect.Left, ControlRect.Top, R.Right, R.Bottom, TempBmp.Canvas.Handle, 0, 0, SRCCOPY);
    finally
      if DC = 0 then ReleaseDC(FhWndHeader, tmpdc);
    end;
    FreeAndNil(TempBmp);
  except
    Application.HandleException(Self);
  end;
end;

constructor TacListViewWnd.Create(AHandle: hwnd; ASkinData: TsCommonData; ASkinManager: TsSkinManager; const SkinSection : string; Repaint : boolean = True);
var
  Wnd : HWND;
begin
  inherited;
  HoverColIndex := -1;
  FhHeaderProc := MakeObjectInstance(HeaderWndProc);
  Wnd := FindWindowEx(CtrlHandle, 0, WC_HEADER{'SysHeader32'}, nil);
  FPressedColumn := -1;
  if Wnd <> 0 then if (FhWndHeader = 0) then begin
    FhWndHeader := Wnd;
    FhDefHeaderProc := Pointer(GetWindowLong(FhWndHeader, GWL_WNDPROC));
    SetWindowLong(FhWndHeader, GWL_WNDPROC, Longint(FhHeaderProc));
  end
end;

function TacListViewWnd.GetHeaderColumnRect(Index: Integer): TRect;
var
  SectionOrder : array of Integer;
  rc : TRect;
begin
  if GetWindowLong(FhWndHeader, GWL_STYLE) and HDS_FULLDRAG = HDS_FULLDRAG then begin
    SetLength(SectionOrder, Header_GetItemCount(FhWndHeader));
    Header_GetOrderArray(FhWndHeader, Header_GetItemCount(FhWndHeader), PInteger(SectionOrder));
    if Length(SectionOrder) > 0
      then Header_GETITEMRECT(FhWndHeader, SectionOrder[Index] , @rc)
      else Header_GETITEMRECT(FhWndHeader, Index, @rc);
  end
  else begin
    Header_GETITEMRECT(FhWndHeader, Index, @rc);
  end;
  Result := rc;
end;

procedure TacListViewWnd.HeaderWndProc(var Message: TMessage);
var
  Info : THDHitTestInfo;
  CurIndex, w : integer;
  function MouseToColIndex(p : TSmallPoint) : integer;
  var
    ltPoint : TPoint;
    i, c : integer;
    rc : TRect;
  begin
    w := AllcolWidth;
    if SkinData.FOwnerControl <> nil then ltPoint := TacAccessLV(SkinData.FOwnerControl).ScreenToClient(Point(p.x, p.y)) else begin
      GetWindowRect(FhWndHeader, rc);
      ltPoint.X := p.x - rc.Left; 
      ltPoint.Y := p.y - rc.Top; 
    end;
    Result := -2;
    c := (Header_GetItemCount(FhWndHeader) - 1);
    for i := 0 to c do begin
      rc := GetHeaderColumnRect(i);
      if PtInRect(rc, ltPoint) then begin
        Result := i;
        exit;
      end;
    end;
  end;
begin
  if ViewStyle = vsReport then begin
    try
      with Message do begin
        case Msg of
          WM_NCHITTEST : if HotTrack then begin
            Result := CallWindowProc(FhDefHeaderProc, FhWndHeader, Msg, WParam, LParam);
            CurIndex := MouseToColIndex(TWMNCHitTest(Message).Pos);
            if HoverColIndex <> CurIndex then begin
              HoverColIndex := Header_OrderToIndex(FhWndHeader, CurIndex);
              PaintHeader(0);
            end;
            Exit;
          end;
          WM_LBUTTONUP: if HotTrack then begin
            FPressedColumn := -1;
          end;
          WM_PAINT: begin
            PaintHeader(0);
            Exit;
          end;
          WM_ERASEBKGND: begin
            Exit;
          end;
          WM_WINDOWPOSCHANGING : if IsWindowVisible(CtrlHandle) then begin
            SendMessage(CtrlHandle, WM_NCPAINT, 0, 0)
          end;
          WM_NCDESTROY: begin
            Result := CallWindowProc(FhDefHeaderProc, FhWndHeader, Msg, WParam, LParam);
            FhWndHeader := 0;
            FhDefHeaderProc := nil;
            Exit;
          end;
        end;
        Result := CallWindowProc(FhDefHeaderProc, FhWndHeader, Msg, WParam, LParam);
        case Msg of
          WM_LBUTTONDOWN: if HotTrack then begin
            FFlag := True;
            Info.Point.X := TWMMouse(Message).XPos;
            Info.Point.Y := TWMMouse(Message).YPos;
            SendMessage(FhWndHeader, HDM_HITTEST, 0, Integer(@Info));

            if (Info.Flags and HHT_ONDIVIDER = 0) and (Info.Flags and HHT_ONDIVOPEN = 0) then begin
              FPressedColumn := Info.Item
            end
            else FPressedColumn := -1;
            RedrawWindow(FhWndHeader, nil, 0, RDW_INVALIDATE);
          end;
        end;
      end;
    except
      Application.HandleException(Self);
    end;
  end
  else if (FhDefHeaderProc <> nil) and (FhWndHeader <> 0) then with Message do Result := CallWindowProc(FhDefHeaderProc, FhWndHeader, Msg, WParam, LParam);
end;

function TacListViewWnd.HotTrack: boolean;
begin
  Result := True;
//  Result := GetWindowLong(FhWndHeader, GWL_STYLE) and HDS_HOTTRACK <> 0
end;

procedure TacListViewWnd.PaintHeader;
var
  i, Index, count, RightPos : Integer;
  rc, HeaderR : TRect;
  PS : TPaintStruct;
begin
  if ViewStyle = vsReport then begin
    BeginPaint(FhWndHeader, PS);
    try
      RightPos := 0;
      count := Header_GetItemCount(FhWndHeader) - 1;
      if count > -1 then begin
        // Draw Columns Headers
        for i := 0 to count do begin
          rc := GetHeaderColumnRect(i);
          if not IsRectEmpty(rc) then begin
            ListLineHeight := HeightOf(rc);
            Index := Header_OrderToIndex(FhWndHeader, i);
            ColumnSkinPaint(rc, Index, DC);
          end;
          if RightPos < rc.Right then RightPos := rc.Right;
        end;
      end
      else begin
        rc := GetHeaderColumnRect(0);
        ListLineHeight := HeightOf(rc);
      end;

      // Draw background section
      if Windows.GetWindowRect(FhWndHeader, HeaderR) then begin
        rc := Rect(RightPos, 0, WidthOf(HeaderR), HeightOf(HeaderR));
        if not IsRectEmpty(rc) then begin ColumnSkinPaint(rc, -2, DC); end;
      end;
    finally
      EndPaint(FhWndHeader, PS);
    end;
  end;
end;

procedure TacListViewWnd.RestoreStdParams;
begin
  ListView_SetTextColor(CtrlHandle, ColorToRgb(clWindowText));
  if FhWndHeader <> 0 then begin
    SetWindowLong(FhWndHeader, GWL_WNDPROC, Longint(FhDefHeaderProc));
    FhWndHeader := 0;
  end;
  if FhHeaderProc <> nil then begin
    FreeObjectInstance(FhHeaderProc);
    FhHeaderProc := nil;
  end;
  inherited RestoreStdParams;
end;

procedure TacListViewWnd.SaveStdParams;
begin
  inherited;
  if CtrlHandle <> 0 then begin
    StdColor := TColor(SendMessage(CtrlHandle, LVM_GETBKCOLOR, 0, 0));
    StdFontColor := TColor(SendMessage(CtrlHandle, LVM_GETTEXTCOLOR, 0, 0));//ListView_GetTextColor(CtrlHandle));
  end
end;

procedure TacListViewWnd.SetSkinParams;
begin
  inherited;
  if CtrlHandle <> 0 then begin
    if DlgMode then begin
      ListView_SetBkColor(CtrlHandle, ColorToRgb(clWindow));
      ListView_SetTextBkColor(CtrlHandle, ColorToRgb(clWindow));
      ListView_SetTextColor(CtrlHandle, ColorToRgb(clWindowText));
    end
    else if DefaultManager.IsValidSkinIndex(SkinData.SkinIndex) then begin
      ListView_SetBkColor(CtrlHandle, DefaultManager.gd[SkinData.SkinIndex].Color);
      ListView_SetTextBkColor(CtrlHandle, ColorToRGB(DefaultManager.gd[SkinData.SkinIndex].Color));
      ListView_SetTextColor(CtrlHandle, DefaultManager.gd[SkinData.SkinIndex].FontColor[1]);
    end;
  end
end;

function TacListViewWnd.ViewStyle: TViewStyle;
var
  St : dword;
begin
  if SkinData.FOwnerControl <> nil then begin
    Result := TacAccessLV(SkinData.FOwnerControl).ViewStyle;
  end
  else begin
    St := dword(SendMessage(CtrlHandle, LVM_FIRST + 143 {LVM_GETVIEW}, 0, 0));
    case St of
      0 : Result := vsIcon;
      1 : Result := vsReport;
      2 : Result := vsSmallIcon;
      3 : Result := vsList
      else Result := vsList;
    end;
  end;
end;

{ TacGridWnd }
type
  TsAccessGrid = class(TCustomGrid);

procedure TacGridWnd.acWndProc(var Message: TMessage);
var
  SavedDC : hdc;
  sb : TScrollStyle;
begin
  case Message.Msg of
    WM_ERASEBKGND : begin
      SkinData.Updating := SkinData.Updating;
      Exit; // Blinking removing in loading
    end;
    WM_VSCROLL : begin
      // TDBGrid params
      if (TWMVScroll(Message).ScrollCode = SB_THUMBPOSITION) and HasProperty(SkinData.FOwnerControl, acDataSource) then begin
        if TWMVScroll(Message).Pos > 4 then TWMVScroll(Message).Pos := TWMVScroll(Message).Pos;

        sBarVert.ScrollInfo.cbSize := SizeOf(TScrollInfo);
        sBarVert.ScrollInfo.fMask := SIF_ALL;
        if HasProperty(SkinData.FOwnerControl, 'DataSource') // SkinData.FOwnerControl.ClassName = acTwwDBGrid
          then sBarVert.ScrollInfo.nPos := sBarVert.ScrollInfo.nTrackPos
          else sBarVert.ScrollInfo.nPos := sBarVert.ScrollInfo.nTrackPos + 1;

        SetScrollInfo(CtrlHandle, SB_VERT, sBarVert.ScrollInfo, False);
      end;
      // For DBGridEH
      if (TWMVScroll(Message).ScrollCode = SB_THUMBTRACK) and HasProperty(SkinData.FOwnerControl, acDataSource) then begin
        sBarVert.ScrollInfo.cbSize := SizeOf(TScrollInfo);
        sBarVert.ScrollInfo.fMask := SIF_ALL;
        sBarVert.ScrollInfo.nPos := sBarVert.ScrollInfo.nTrackPos;

        SetScrollInfo(CtrlHandle, SB_VERT, sBarVert.ScrollInfo, False);
      end;
      if (TWMVScroll(Message).ScrollCode = SB_ENDSCROLL) and HasProperty(SkinData.FOwnerControl, acDataSource) and (SkinData.FOwnerControl.ClassName <> acTwwDBGrid) then begin
        SendScrollMessage(CtrlHandle, WM_VSCROLL, SB_THUMBPOSITION, sBarVert.ScrollInfo.nTrackPos);
      end;
    end;
    WM_PRINT : begin
      inherited acWndProc(Message);
      SavedDC := SaveDC(TWMPaint(Message).DC);
      MoveWindowOrg(TWMPaint(Message).DC, cxLeftEdge, cxLeftEdge);
      IntersectClipRect(TWMPaint(Message).DC, 0, 0,
                        SkinData.FCacheBmp.Width - 2 * cxLeftEdge - integer(sBarVert.fScrollVisible) * GetScrollMetric(sBarVert, SM_CXVERTSB),
                        SkinData.FCacheBmp.Height - 2 * cxLeftEdge - integer(sBarHorz.fScrollVisible) * GetScrollMetric(sBarHorz, SM_CYHORZSB));
      SendMessage(CtrlHandle, WM_PAINT, Message.WParam, Message.LParam);
//      SendMessage(CtrlHandle, WM_PRINTCLIENT, Message.WParam, PRF_CLIENT or PRF_OWNED);
//      SendMessage(CtrlHandle, WM_PRINT, Message.WParam, PRF_CLIENT or PRF_OWNED);
      RestoreDC(TWMPaint(Message).DC, SavedDC);
      Exit;
    end;
  end;
  inherited acWndProc(Message);
  if Message.Msg = SM_ALPHACMD then begin
    case Message.WParamHi of
      AC_REMOVESKIN : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) and (SkinData.FOwnerControl <> nil) and (SkinData.FOwnerControl is TCustomGrid) then begin
        sb := TsAccessGrid(SkinData.FOwnerControl).ScrollBars;
        TsAccessGrid(SkinData.FOwnerControl).ScrollBars := ssNone;
        TsAccessGrid(SkinData.FOwnerControl).ScrollBars := sb;
      end;
    end;
  end
  else
  case Message.Msg of
    WM_WINDOWPOSCHANGED : if IsWindowVisible(CtrlHandle) then SendMessage(CtrlHandle, WM_NCPAINT, 0, 0);
    WM_PAINT : UpdateScrolls(Self, True)
  end;
end;

procedure TacGridWnd.RestoreStdParams;
var
  f, l  : TObject;
begin
  inherited;
  if Assigned(SkinData) and Assigned(SkinData.FOwnerControl) and not (csDestroying in SkinData.FOwnerControl.ComponentState) then begin
    TryChangeIntProp(SkinData.FOwnerControl, acFixedColor, FixedColor);
{$IFDEF D2010}
    if SkinData.FOwnerControl is TCustomGrid then begin
      TsAccessGrid(SkinData.FOwnerControl).DrawingStyle := DrawingStyle;
      TsAccessGrid(SkinData.FOwnerControl).GradientStartColor := FixedGradientFrom;
      TsAccessGrid(SkinData.FOwnerControl).GradientEndColor := FixedGradientTo;
    end;
{$ENDIF}
    // TDBGrid params
    if HasProperty(SkinData.FOwnerControl, acTitleFont) then begin
      f := TFont(GetObjProp(SkinData.FOwnerControl, acTitleFont));
      TFont(f).Color := TitleFontColor;
    end;
    // AdvGrid params
    if HasProperty(SkinData.FOwnerControl, acControlLook) then begin
      if HasProperty(SkinData.FOwnerControl, acFixedFont) then begin
        f := TFont(GetObjProp(SkinData.FOwnerControl, acFixedFont));
        TFont(f).Color := TitleFontColor;
      end;
      TryChangeIntProp(SkinData.FOwnerControl, acGridFixedLineColor, GridFixedLineColor);
      TryChangeIntProp(SkinData.FOwnerControl, acGridLineColor, GridLineColor);

      l := TObject(GetObjProp(SkinData.FOwnerControl, acControlLook));
      if l <> nil then begin
        TryChangeIntProp(l, acFixedGradientFrom, FixedGradientFrom);
        TryChangeIntProp(l, acFixedGradientTo, FixedGradientTo);
        TryChangeIntProp(l, acFixedGradientMirrorFrom, FixedGradientMirrorFrom);
        TryChangeIntProp(l, acFixedGradientMirrorTo, FixedGradientMirrorTo);
      end;

      TryChangeIntProp(SkinData.FOwnerControl, acSelectionColor, SelectionColor);
      TryChangeIntProp(SkinData.FOwnerControl, acSelectionTextColor, SelectionTextColor);
    end;
    // wwGrid
    TryChangeIntProp(SkinData.FOwnerControl, acFooterColor, FooterColor);
    TryChangeIntProp(SkinData.FOwnerControl, acFooterCellColor, FooterCellColor);
    TryChangeIntProp(SkinData.FOwnerControl, acTitleColor, TitleColor);
    TryChangeIntProp(SkinData.FOwnerControl, acIndColor, IndColor);
  end;
end;

procedure TacGridWnd.SaveStdParams;
var
  f, l  : TObject;
begin
  inherited;
  FixedColor := TryGetColorProp(SkinData.FOwnerControl, acFixedColor);
{$IFDEF D2010}
  if SkinData.FOwnerControl is TCustomGrid then begin
    DrawingStyle := TsAccessGrid(SkinData.FOwnerControl).DrawingStyle;
    FixedGradientFrom := TsAccessGrid(SkinData.FOwnerControl).GradientStartColor;
    FixedGradientTo := TsAccessGrid(SkinData.FOwnerControl).GradientEndColor;
  end;
{$ENDIF}
  // TDBGrid params
  if HasProperty(SkinData.FOwnerControl, acTitleFont) then begin
    f := TFont(GetObjProp(SkinData.FOwnerControl, acTitleFont));
    TitleFontColor := TFont(f).Color;
  end;
  // AdvGrid params
  if HasProperty(SkinData.FOwnerControl, acControlLook) then begin
    if HasProperty(SkinData.FOwnerControl, acFixedFont) then begin
      f := TFont(GetObjProp(SkinData.FOwnerControl, acFixedFont));
      TitleFontColor := ColorToRGB(TFont(f).Color);
    end;
    GridFixedLineColor := TryGetColorProp(SkinData.FOwnerControl, acGridFixedLineColor);
    GridLineColor := TryGetColorProp(SkinData.FOwnerControl, acGridLineColor);

    l := TObject(GetObjProp(SkinData.FOwnerControl, acControlLook));
    if l <> nil then begin
      FixedGradientFrom := TryGetColorProp(l, acFixedGradientFrom);
      if FixedGradientFrom = clNone then FixedGradientFrom := clBtnFace;
      FixedGradientTo := TryGetColorProp(l, acFixedGradientTo);
      if FixedGradientTo = clNone then FixedGradientTo := clBtnFace;
      FixedGradientMirrorFrom := TryGetColorProp(l, acFixedGradientMirrorFrom);
      if FixedGradientMirrorFrom = clNone then FixedGradientMirrorFrom := clBtnFace;
      FixedGradientMirrorTo := TryGetColorProp(l, acFixedGradientMirrorTo);
      if FixedGradientMirrorTo = clNone then FixedGradientMirrorTo := clBtnFace;
    end;
    SelectionColor := TryGetColorProp(SkinData.FOwnerControl, acSelectionColor);
    SelectionTextColor := TryGetColorProp(SkinData.FOwnerControl, acSelectionTextColor);
  end;
  // wwGrid
  FooterColor := TryGetColorProp(SkinData.FOwnerControl, acFooterColor);
  FooterCellColor := TryGetColorProp(SkinData.FOwnerControl, acFooterCellColor);
  TitleColor := TryGetColorProp(SkinData.FOwnerControl, acTitleColor);
  IndColor := TryGetColorProp(SkinData.FOwnerControl, acIndColor);
end;

procedure TacGridWnd.SetSkinParams;
var
  f, l  : TObject;
  CGlobal : TColor;
begin
  inherited;
  CGlobal := SkinData.SkinManager.GetGlobalColor;
  TryChangeIntProp(SkinData.FOwnerControl, acFixedColor, CGlobal);
{$IFDEF D2010}
  if SkinData.FOwnerControl is TCustomGrid then begin
    if DrawingStyle <> gdsClassic then TsAccessGrid(SkinData.FOwnerControl).DrawingStyle := gdsGradient;
    TsAccessGrid(SkinData.FOwnerControl).GradientStartColor := MixColors(CGlobal, SkinData.SkinManager.GetActiveEditColor, 0.5);
    TsAccessGrid(SkinData.FOwnerControl).GradientEndColor := CGlobal;
  end;
{$ENDIF}
  // TDBGrid params
  if HasProperty(SkinData.FOwnerControl, acTitleFont) then begin
    f := TFont(GetObjProp(SkinData.FOwnerControl, acTitleFont));
    TFont(f).Color := SkinData.SkinManager.GetGlobalFontColor;
  end;
  // AdvGrid params <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  if HasProperty(SkinData.FOwnerControl, acControlLook) then begin // (SkinData.FOwnerControl.ClassName = acTDBAdvGrid) or (SkinData.FOwnerControl.ClassName = acTAdvStringGrid) then begin
    if HasProperty(SkinData.FOwnerControl, acFixedFont) then begin
      f := TFont(GetObjProp(SkinData.FOwnerControl, acFixedFont));
      TFont(f).Color := SkinData.SkinManager.GetGlobalFontColor;
    end;
    TryChangeIntProp(SkinData.FOwnerControl, acGridFixedLineColor, SkinData.SkinManager.SkinData.BorderColor);
    TryChangeIntProp(SkinData.FOwnerControl, acGridLineColor, MixColors(DefaultManager.GetActiveEditColor, DefaultManager.GetActiveEditFontColor, 0.7));

    l := TObject(GetObjProp(SkinData.FOwnerControl, acControlLook));
    if l <> nil then begin
      TryChangeIntProp(l, acFixedGradientFrom, MixColors(CGlobal, SkinData.SkinManager.GetActiveEditColor, 0.5));
      TryChangeIntProp(l, acFixedGradientTo, CGlobal);
      TryChangeIntProp(l, acFixedGradientMirrorFrom, MixColors(CGlobal, 0, 0.95));
      TryChangeIntProp(l, acFixedGradientMirrorTo, MixColors(CGlobal, clWhite, 0.9));
    end;
    TryChangeIntProp(SkinData.FOwnerControl, acSelectionColor, SkinData.SkinManager.GetHighLightColor);
    TryChangeIntProp(SkinData.FOwnerControl, acSelectionTextColor, SkinData.SkinManager.GetHighLightFontColor);
  end; // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  // wwGrid
  TryChangeIntProp(SkinData.FOwnerControl, acFooterColor, SkinData.SkinManager.gd[SkinData.SkinManager.ConstData.IndexGlobalInfo].Color);
  TryChangeIntProp(SkinData.FOwnerControl, acFooterCellColor, SkinData.SkinManager.gd[SkinData.SkinManager.ConstData.IndexGlobalInfo].Color);
  TryChangeIntProp(SkinData.FOwnerControl, acTitleColor, SkinData.SkinManager.gd[SkinData.SkinManager.ConstData.IndexGlobalInfo].Color);
  TryChangeIntProp(SkinData.FOwnerControl, acIndColor, SkinData.SkinManager.gd[SkinData.SkinIndex].FontColor[1]);
end;

{ TacTreeViewWnd }

procedure TacTreeViewWnd.acWndProc(var Message: TMessage);
var
  DC : hdc;
begin
  if SkinData <> nil then case Message.Msg of
    WM_LBUTTONUP : begin
      inherited;
      ReleaseCapture;
    end;
    WM_ERASEBKGND : begin
      if (SkinData.FOwnerControl <> nil) and Assigned(TTreeView(SkinData.FOwnerControl).OnAdvancedCustomDraw) then begin
        Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
      end
      else begin
        SkinData.FUpdating := SkinData.Updating;
        if SkinData.FUpdating then Exit;
        if SkinData.BGChanged then begin
          PrepareCache(SkinData, CtrlHandle, DlgMode);
        end;
        if Message.WParam <> 0 then DC := hdc(Message.WParam) else DC := GetWindowDC(CtrlHandle);
        try
          FillDC(DC, Rect(0, 0, WndSize.cx, WndSize.cy), iffi(DlgMode, clWindow, SkinData.SkinManager.gd[SkinData.SkinIndex].Color))
        finally
          if Message.WParam = 0 then ReleaseDC(CtrlHandle, DC);
        end;
        Message.Result := 0;
      end
    end
    else inherited;
  end
  else inherited;
end;

destructor TacTreeViewWnd.Destroy;
begin
//  Destroyed := True;
//  OldWndProc := nil;
  inherited;
end;

procedure TacTreeViewWnd.RestoreStdParams;
begin
  inherited;
  if IsWindowVisible(CtrlHandle)
    then TreeView_SetBkColor(CtrlHandle, ColorToRGB(clWindow));
end;

procedure TacTreeViewWnd.SetSkinParams;
var
  C, fC : TColor;
begin
  ParamsChanged := True;
  if DlgMode then TreeView_SetBkColor(CtrlHandle, ColorToRGB(clWindow)) else if (SkinData <> nil) then begin
    if (SkinData.SkinManager.gd[SkinData.SkinIndex].States > 1) and ControlIsActive(SkinData) then begin
      C := SkinData.SkinManager.gd[SkinData.SkinIndex].HotColor;
      fC := SkinData.SkinManager.gd[SkinData.SkinIndex].HotFontColor[1]
    end
    else begin
      C := SkinData.SkinManager.gd[SkinData.SkinIndex].Color;
      fC := SkinData.SkinManager.gd[SkinData.SkinIndex].FontColor[1]
    end;
    if (SkinData.FOwnerControl <> nil) then begin
      if not SkinData.CustomFont and (TsHackedControl(SkinData.FOwnerControl).Font.Color <> fC) then TsHackedControl(SkinData.FOwnerControl).Font.Color := fC;
      if not SkinData.CustomColor and (TsHackedControl(SkinData.FOwnerControl).Color <> C) then TreeView_SetBkColor(CtrlHandle, ColorToRGB(C));
    end
    else TreeView_SetBkColor(CtrlHandle, ColorToRGB(C));
  end;
end;

{ TacComboBoxWnd }

procedure TacComboBoxWnd.acWndProc(var Message: TMessage);
const
  BordWidth = 3;
var
  DC : hdc;
  b, Simple : boolean;
  i : integer;
  si : TacSectionInfo;
begin
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_REMOVESKIN : if LongWord(Message.LParam) = LongWord(SkinData.SkinManager) then begin
      inherited;
      if FListHandle <> 0 then begin
        SetWindowLong(FListHandle, GWL_STYLE, GetWindowLong(FListHandle, GWL_STYLE) and not WS_THICKFRAME or WS_BORDER);
        UninitializeACScroll(FListHandle, True, False, TacScrollWnd(ListSW));
        FListHandle := 0;
      end;
      exit
    end;
    AC_MOUSEENTER, AC_MOUSELEAVE : begin
      inherited;
      RepaintButton;
    end;
  end;
  case Message.Msg of
    WM_DRAWITEM : begin
      Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
      Invalidate;
    end;
    WM_ERASEBKGND : ;
    WM_PRINT : begin
      InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
      SkinData.Updating := True;
      if not ParamsChanged
        then SetSkinParams;
      if Destroyed then Exit;
      SkinData.Updating := False;
      SkinData.BGChanged := True;
      if GetWindowLong(CtrlHandle, GWL_STYLE) and CBS_DROPDOWNLIST = CBS_SIMPLE then begin
        PrepareSimple;
      end
      else SendMessage(CtrlHandle, SM_ALPHACMD, MakeWParam(0, AC_PREPARECACHE), 0);
      if SkinData = nil then Exit;
      PrepareCache(SkinData, CtrlHandle, DlgMode);
      PaintText;
      UpdateWndCorners(SkinData, 0, Self);

      DC := TWMPaint(Message).DC;
      BitBlt(DC, 0, 0, SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height, SkinData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
      PaintButton(DC);
    end;
    WM_NCCALCSIZE : begin
      inherited;
      cxLeftEdge := 3;
    end;
    WM_PAINT : begin
      if not ParamsChanged then SetSkinParams;
      InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
      Simple := (GetWindowLong(CtrlHandle, GWL_STYLE) and CBS_DROPDOWNLIST = CBS_SIMPLE);

{      b := False;
      if not Simple and not DroppedDown then begin
        if TWMPaint(Message).DC = 0 then begin
          TWMPaint(Message).DC := GetWindowDC(CtrlHandle);
          b := True;
        end
        else b := False;
        ExcludeClipRect(TWMPaint(Message).DC, 0, 0, WndSize.cx, 2);
        ExcludeClipRect(TWMPaint(Message).DC, 0, WndSize.cy - 2, WndSize.cx, WndSize.cy);
        ExcludeClipRect(TWMPaint(Message).DC, 0, 0, 2, WndSize.cy);
        ExcludeClipRect(TWMPaint(Message).DC, ButtonRect.Left, 0, WndSize.cx, WndSize.cy);
      end;}
      Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
{      if not Simple and not DroppedDown then begin
        if b then ReleaseDC(CtrlHandle, TWMPaint(Message).DC);
        TWMPaint(Message).DC := 0;
      end;}

      if TWMPaint(Message).DC = 0 then begin
        DC := GetWindowDC(CtrlHandle);
        TWMPaint(Message).DC := DC;
        b := True;
      end
      else begin
        DC := TWMPaint(Message).DC;
        b := False;
      end;
//      SkinData.FUpdating := SkinData.Updating;
//      if not SkinData.FUpdating then begin
        if Simple then begin
          PrepareSimple;
          BitBltBorder(DC, 0, 0, SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height, SkinData.FCacheBmp.Canvas.Handle, 0, 0, 3);
        end
        else begin
          SkinData.BGChanged := True;
          SendMessage(CtrlHandle, SM_ALPHACMD, MakeWParam(0, AC_PREPARECACHE), 0);
//          if (SkinData.FCacheBmp = nil) or (SkinData.FCacheBmp.Width <> WndSize.cx) or (SkinData.FCacheBmp.Height <> WndSize.cy) then Alert; // !!!
          BitBltBorder(DC, 0, 0, SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height, SkinData.FCacheBmp.Canvas.Handle, 0, 0, 3);
          PaintButton(DC);
        end;
//      end;
      if b then ReleaseDC(CtrlHandle, DC);
    end;
    CM_MOUSEENTER : begin
      SkinData.FMouseAbove := True;
      SkinData.BGChanged := True;
      inherited;
      Invalidate;
    end;
    CM_MOUSELEAVE : begin
      SkinData.FMouseAbove := False;
      SkinData.BGChanged := True;
      inherited;
      Invalidate;
    end;
    WM_KILLFOCUS, WM_SETFOCUS, WM_LBUTTONUP : begin
      inherited;
      RepaintButton;
    end;
    CN_COMMAND : begin
      case TWMCommand(Message).NotifyCode of
        CBN_CLOSEUP : begin
          bDroppedDown := False;
          SkinData.BGChanged := True;
          RepaintButton;
        end;
        CBN_DROPDOWN : bDroppedDown := True;
      end;
      inherited;
    end;
    WM_COMMAND : begin
      if GetWindowLong(CtrlHandle, GWL_STYLE) and CBS_SIMPLE <> CBS_SIMPLE then begin
        if TWMCommand(Message).NotifyCode = CBN_CLOSEUP then begin
          SkinData.BGChanged := True;
          bDroppedDown := False;
          RepaintButton;
        end
        else if TWMCommand(Message).NotifyCode = CBN_DROPDOWN then bDroppedDown := True;
      end;
      inherited;
    end;
    WM_CTLCOLORLISTBOX : if not LBoxOpening then begin
      LBoxOpening := True;
      inherited;
{$IFDEF TNTUNICODE}
      if SkinData.FOwnerControl <> nil then if SkinData.FOwnerControl is TTntCustomComboBox then Exit;
{$ENDIF}
      if (FListHandle = 0) then begin
        FListHandle := Message.LParam;
        if ListSW = nil then begin
          Simple := (GetWindowLong(CtrlHandle, GWL_STYLE) and CBS_DROPDOWNLIST = CBS_SIMPLE);
          if SkinData.FOwnerControl = nil then begin
            acDlgMode := DlgMode;
            b := SendMessage(CtrlHandle, CB_GETCOUNT, 0, 0) > 0;
            ListSW := TacComboListWnd.CreateEx(FListHandle, nil, SkinData.SkinManager, s_Edit, b, Simple);
            acDlgMode := False;
          end
          else begin
            b := SendMessage(CtrlHandle, CB_GETCOUNT, 0, 0) > 0;
            ListSW := TacComboListWnd.CreateEx(FListHandle, nil, SkinData.SkinManager, s_Edit, b, Simple);
          end;
//          ListSW.SimplyBox := GetWindowLong(CtrlHandle, GWL_STYLE) and CBS_DROPDOWNLIST = CBS_SIMPLE;
        end;
        si.SkinIndex := -1;
        SendMessage(FListHandle, SM_ALPHACMD, MakeWParam(0, AC_GETSKININDEX), integer(@si));// - 1;
        i := si.SkinIndex;
        if (i > -1) and not DlgMode then begin
          if SkinData.SkinManager.gd[i].FontColor[1] >= 0
            then SetTextColor(hdc(Message.WParam), Cardinal(ColorToRGB(SkinData.SkinManager.gd[i].FontColor[1])));
          SetBkColor(hdc(Message.WParam), ColorToRGB(SkinData.SkinManager.gd[i].Color));
          Message.Result := LongInt(CreateSolidBrush(ColorToRGB(SkinData.SkinManager.gd[i].Color)));
        end;
      end;
      LBoxOpening := False;
    end;
    else inherited;
  end;
end;

function TacComboBoxWnd.ButtonHeight: integer;
begin
  if (SkinData.SkinManager.ConstData.ComboGlyph > -1)
    then Result := HeightOf(SkinData.SkinManager.ma[SkinData.SkinManager.ConstData.ComboGlyph].R) div (1 + SkinData.SkinManager.ma[SkinData.SkinManager.ConstData.ComboGlyph].MaskType)
    else Result := 16;
end;

function TacComboBoxWnd.ButtonRect: TRect;
const
  bWidth = 2;
var
  w : integer;
  r : TRect;
begin
  if GetWindowLong(CtrlHandle, GWL_STYLE) and CBS_DROPDOWN = CBS_DROPDOWN then w := GetSystemMetrics(SM_CXVSCROLL) else w := 0;
  GetWindowRect(CtrlHandle, r);
  if GetWindowLong(CtrlHandle, GWL_EXSTYLE) and WS_EX_RTLREADING = WS_EX_RTLREADING {SysLocale.MiddleEast }then begin
    Result.Left := bWidth
  end
  else Result.Left := WidthOf(r) - w - bWidth;
  Result.Top := bWidth;
  Result.Right := Result.Left + w;
  Result.Bottom := HeightOf(r) - bWidth;
end;

constructor TacComboBoxWnd.Create(AHandle: hwnd; ASkinData: TsCommonData; ASkinManager: TsSkinManager; const SkinSection : string; Repaint : boolean = True);
begin
  inherited;
  LBoxOpening := False;
  LBSkinData := TsCommonData.Create(nil, True);
end;

destructor TacComboBoxWnd.Destroy;
begin
  FreeAndNil(LBSkinData);
  if Assigned(ListSW) then begin
    UninitializeACScroll(ListSW.CtrlHandle, True, False, TacScrollWnd(ListSW));
    FListHandle := 0;
  end;
  inherited;
end;

function TacComboBoxWnd.DroppedDown: boolean;
begin
  Result := bDroppedDown; 
end;

procedure TacComboBoxWnd.Invalidate;
begin
{$IFDEF DELPHI7UP}
  if (SkinData.FOwnerControl <> nil) {and (SkinData.FOwnerControl is TComboBoxEx) }then begin // Invalidate ComboBoxEx
    InvalidateRect(CtrlHandle, nil, True);
    UpdateWindow(CtrlHandle);
  end;
{$ENDIF}  
end;

procedure TacComboBoxWnd.PaintButton;
var
  R, wR : TRect;
  Mode : integer;
  c : TsColor;
  glIndex : integer;
  TmpBtn : TBitmap;
begin
  if (FListHandle <> 0) and IsWindowVisible(FListHandle)
    then Mode := 2
    else if ControlIsActive(SkinData) or (DefaultManager.ActiveControl = CtrlHandle) then Mode := 1 else Mode := 0;
  R := ButtonRect;

  TmpBtn := CreateBmpLike(SkinData.FCacheBmp);

  if SkinData.SkinManager.ConstData.ComboBtnIndex > -1 then begin
    BitBlt(TmpBtn.Canvas.Handle, 0, 0, TmpBtn.Width, TmpBtn.Height, SkinData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
    PaintItem(SkinData.SkinManager.ConstData.ComboBtnIndex, s_ComboBtn, MakeCacheInfo(TmpBtn),
      True, Mode, R, Point(0, 0), TmpBtn, SkinData.SkinManager, SkinData.SkinManager.ConstData.ComboBtnBG, SkinData.SkinManager.ConstData.ComboBtnBGHot);
  end
  else BitBlt(TmpBtn.Canvas.Handle, 0, 0, TmpBtn.Width, TmpBtn.Height, SkinData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
  glIndex := SkinData.SkinManager.ConstData.ComboGlyph;
  if glIndex > -1 then begin
    if SkinData.SkinIndex > -1 then begin
      if ControlIsActive(SkinData)
        then c.C := SkinData.SkinManager.gd[SkinData.SkinIndex].HotColor
        else c.C := SkinData.SkinManager.gd[SkinData.SkinIndex].Color;
    end;

    GetWindowRect(CtrlHandle, wR);
    DrawSkinGlyph(TmpBtn,
      Point(R.Left + (WidthOf(R) - WidthOf(SkinData.SkinManager.ma[glIndex].R) div SkinData.SkinManager.ma[glIndex].ImageCount) div 2,
            (HeightOf(wR) - ButtonHeight) div 2), Mode, 1, SkinData.SkinManager.ma[SkinData.SkinManager.ConstData.ComboGlyph], MakeCacheInfo(TmpBtn));
  end;

  BitBlt(DC, R.Left, R.Top, WidthOf(R), HeightOf(R), TmpBtn.Canvas.Handle, R.Left, R.Top, SRCCOPY);
  FreeAndNil(TmpBtn);
end;

procedure TacComboBoxWnd.PaintText;
var
  Text : array[0 .. 4095] of Char;
  Len : Integer;
  s : string;

  wR, R : TRect;
  li : integer;
  DropDownList : boolean;
begin
  if SkinData.FOwnerControl <> nil then SkinData.FCacheBMP.Canvas.Font.Assign(TsHackedControl(SkinData.FOwnerControl).Font);
  GetWindowRect(CtrlHandle, wR);
  if GetWindowLong(CtrlHandle, GWL_EXSTYLE) and WS_EX_RTLREADING = WS_EX_RTLREADING then begin
    R := Rect(ButtonRect.Right, 3, WndSize.cx - 3, 3);
  end
  else R := Rect(3, 3, ButtonRect.Left, HeightOf(wR) - 3);
  li := SendMessage(CtrlHandle, CB_GETCURSEL, 0, 0);
  s := '';
  if li > -1 then begin
    Len := SendMessage(CtrlHandle, CB_GETLBTEXT, li, Longint(@Text));
    if Len = CB_ERR then Len := 0;
    SetString(s, Text, Len);
  end
  else begin
    Len := SendMessage(CtrlHandle, WM_GETTEXTLENGTH, 0, 0);
    SetString(s, PChar(nil), Len);
    if Len <> 0 then SendMessage(CtrlHandle, WM_GETTEXT, Len + 1, Longint(s));
  end;

  DropDownList := GetWindowLong(CtrlHandle, GWL_STYLE) and CBS_DROPDOWNLIST = CBS_DROPDOWNLIST;

  if (GetFocus = CtrlHandle) and DropDownList then begin
    SkinData.FCacheBMP.Canvas.Brush.Style := bsSolid;
    FillDC(SkinData.FCacheBMP.Canvas.Handle, R, clHighLight);
    SkinData.FCacheBMP.Canvas.Font.Color := clHighLightText;
  end
  else begin
    SkinData.FCacheBMP.Canvas.Brush.Style := bsClear;
  end;

  SkinData.FCacheBMP.Canvas.Brush.Style := bsClear;
  if s <> '' then SkinData.FCacheBMP.Canvas.TextRect(R, R.Left + integer(DropDownList), R.Top + integer(DropDownList), s);

  if (GetFocus = CtrlHandle) and DropDownList
    then DrawFocusRect(SkinData.FCacheBMP.Canvas.Handle, R);

end;

procedure TacComboBoxWnd.PrepareSimple;
begin
  SkinData.FCacheBmp.Width := WndSize.cx;
  SkinData.FCacheBmp.Height := SendMessage(CtrlHandle, CB_GETITEMHEIGHT, 0, 0) + 8;
  if DlgMode and (DefaultManager.SkinData.BorderColor <> clFuchsia) then begin
    FillDC(SkinData.FCacheBmp.Canvas.Handle, Rect(0, 0, SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height), clWindow);
    SkinData.FCacheBmp.Canvas.Brush.Color := DefaultManager.SkinData.BorderColor;
    SkinData.FCacheBmp.Canvas.FrameRect(Rect(0, 0, SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height));
  end
  else begin
    PaintItem(SkinData,
            GetParentCache(SkinData), True,
            integer(ControlIsActive(SkinData)),
            Rect(0, 0, SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height),
            Point(0, 0), SkinData.FCacheBmp, True);
  end;
end;

procedure TacComboBoxWnd.RepaintButton;
var
  DC : hdc;
begin
  DC := GetWindowDC(CtrlHandle);
  PaintButton(DC);
  ReleaseDC(CtrlHandle, DC);
end;

{ TacGridEhWnd }

procedure TacGridEhWnd.acWndProc(var Message: TMessage);
begin
  inherited;
end;

{ TacComboListWnd }

procedure TacComboListWnd.acWndProc(var Message: TMessage);
var
  pDC, DC, SavedDC : hdc;
  wR, pR : TRect;
  pt : TPoint;
  h : integer;
  BG : TacBGInfo;
  procedure PrepareCache(DrawSB : boolean = True);
  begin
    InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
    if SimplyBox then begin
      SendAMessage(CtrlHandle, AC_PREPARECACHE);
    end
    else begin
      GetWindowRect(CtrlHandle, wR);
      SkinData.UpdateIndexes;
      SetSkinParams;
      SkinData.FCacheBmp.Width := WidthOf(wR);
      SkinData.FCacheBmp.Height := HeightOf(wR);
      SkinData.FCacheBmp.Canvas.Brush.Style := bsSolid;
      SkinData.FCacheBmp.Canvas.Brush.Color := Color;
      SkinData.FCacheBmp.Canvas.Pen.Color := FrameColor;
      SkinData.FCacheBmp.Canvas.Rectangle(Rect(0, 0, SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height));
      SkinData.BGChanged := False;
    end;
  end;
begin
  case Message.Msg of
    WM_ERASEBKGND : begin
      Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
      Exit;
    end;
    WM_VSCROLL, WM_HSCROLL : begin // Direct calling of standard scrolling
      Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
      Exit;
    end;
    WM_NCCALCSIZE: begin
      Message.Result := Ac_NCCalcSize(Self, Self.CtrlHandle, Message.wParam, Message.lParam);
      Exit
    end;
    WM_NCLBUTTONDBLCLK, WM_NCLBUTTONDOWN: begin
      Message.wParam := Ac_NCHitTest(Self, CtrlHandle, Message.WParam, Message.LParam);
      if (Message.wParam = HTHSCROLL) or (Message.wParam = HTVSCROLL) then begin
        Message.Result := Ac_NCLButtonDown(Self, CtrlHandle, Message.wParam, Message.lParam);
      end;
      Exit
    end;
    WM_LBUTTONUP: begin
      InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
      h := Message.LParam;
      pt.x := SmallInt(LoWord(longword(Message.LParam)));
      pt.y := SmallInt(HiWord(longWord(Message.LParam)));
      inc(pt.X, Self.WndRect.Left);
      inc(pt.Y, Self.WndRect.Top);
      Message.LParam := MakeLParam(Word(pt.X), Word(pt.Y));

      Message.WParam := Ac_NCHitTest(Self, CtrlHandle, Message.WParam, Message.LParam);
      if (Message.WParam <> Windows.HTNOWHERE) and (Message.WParam <> HTCLIENT) then begin
        Message.Result := Ac_LButtonUp(Self, CtrlHandle, Message.WParam, Message.LParam);
        if SimplyBox then ReleaseCapture;
      end
      else begin
        Message.LParam := h;
        Ac_LButtonUp(Self, CtrlHandle, Message.WParam, Message.LParam);
        Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
//        ReleaseCapture;
      end;
      Exit
    end;
    WM_PRINT, WM_PRINTCLIENT : begin
      if (Message.WParam <> 0) and IsWindowVisible(CtrlHandle) then begin
        PrepareCache;
        Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
        if (Message.Msg = WM_PRINTCLIENT) or (SendMessage(CtrlHandle, LB_GETCOUNT, 0, 0) < 1) then Exit;
        DC := hdc(Message.WParam);
        OffsetRect(wR, -wR.Left, -wR.Top);
        if (uCurrentScrollPortion = HTSCROLL_NONE) and not Showed then BitBltBorder(DC, wR.Left, wR.Top, WidthOf(wR), HeightOf(wR), SkinData.FCacheBmp.Canvas.Handle, 0, 0, 3);
        Message.Result := Ac_NCPaint(Self, Self.CtrlHandle, Message.wParam, Message.lParam, -1, DC);
      end;
      Exit;
    end;
    WM_NCPAINT : if not DontRepaint then begin
      InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
      PrepareCache;
      if not DlgMode then UpdateWndCorners(SkinData, 0, Self);
      DC := GetWindowDC(CtrlHandle);
      SavedDC := SaveDC(DC);
      try
        BitBltBorder(DC, 0, 0, SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height, SkinData.FCacheBmp.Canvas.Handle, 0, 0, 2);
        Message.Result := Ac_NCPaint(Self, Self.CtrlHandle, Message.wParam, Message.lParam, -1, DC);
        if SimplyBox then begin
          BG.PleaseDraw := False;
          GetBGInfo(@BG, GetParent(GetParent(CtrlHandle))); // Get and copy piece of dialog BG
          if BG.BgType = btCache then begin
            GetWindowRect(ParentWnd, pR);
            h := pR.Bottom - WndRect.Bottom;
            OffsetRect(WndRect, -WndRect.Left, -WndRect.Top);
            OffsetRect(pR, -pR.Left, -pR.Top);
            wR := Rect(0, WndRect.Bottom, WndRect.Right, HeightOf(pR));

            pDC := GetWindowDC(GetParent(CtrlHandle));
            GetWindowRect(GetParent(ParentWnd), wR);
            pR := ParentRect;
            BitBlt(pDC, 0, HeightOf(pR) - h, WidthOf(pR), HeightOf(pR), BG.Bmp.Canvas.Handle, pR.Left - wR.Left + BG.Offset.X, pR.Top - wR.Top + WndSize.cy + BG.Offset.Y, SRCCOPY);
            ReleaseDC(GetParent(CtrlHandle), pDC);
          end;
        end;
      finally
        RestoreDC(DC, SavedDC);
        ReleaseDC(CtrlHandle, DC);
      end;
      Exit;
    end;
    $1AF : begin
      Showed := False;
      if SkinData <> nil then SkinData.BGChanged := True;
    end;
    $1AE : begin
      Showed := True;
    end;
  end;
  inherited acWndProc(Message);
  case Message.Msg of
    WM_WINDOWPOSCHANGED : begin
      UpdateScrolls(Self, True);
    end;
  end;
end;

constructor TacComboListWnd.Create(AHandle: hwnd; ASkinData: TsCommonData; ASkinManager: TsSkinManager; const SkinSection : string; Repaint : boolean = True);
begin
  inherited;
  if SkinData = nil then SkinData := TsCommonData.Create(nil, True);
  Showed := False;
  GetWindowRect(CtrlHandle, WndRect);
end;

constructor TacComboListWnd.CreateEx(AHandle: hwnd; ASkinData: TsCommonData; ASkinManager: TsSkinManager; const SkinSection: string; Repaint, Simply: boolean);
begin
  SimplyBox := Simply;
  Create(AHandle, ASkinData, ASkinManager, SkinSection, Repaint);
  if not SimplyBox
    then SetWindowPos(CtrlHandle, 0, 0, 0, WndSize.cx + 1, WndSize.cy, SWP_NOMOVE or SWP_NOOWNERZORDER or SWP_NOZORDER or SWP_NOCOPYBITS or SWP_NOSENDCHANGING or SWP_NOREPOSITION or SWP_FRAMECHANGED);
end;

destructor TacComboListWnd.Destroy;
begin
  if (uxthemeLib <> 0) then Ac_SetWindowTheme(CtrlHandle, nil, nil);
  if SkinData <> nil then FreeAndNil(SkinData);
  inherited;
end;

{ TacBaseWnd }

procedure TacBaseWnd.acWndProc(var Message: TMessage);
begin
  if Destroyed or not Assigned(SkinData) or not SkinData.Skinned then begin
    inherited;
  end
  else begin
    if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
      AC_REFRESH : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
        inherited;
        if IsWindowVisible(CtrlHandle) then SendMessage(CtrlHandle, WM_NCPAINT, 0, 0);
        Exit;
      end;
      AC_PREPARECACHE : if SkinData <> nil then PrepareCache(SkinData, CtrlHandle);
    end
    else case Message.Msg of
      WM_EXITSIZEMOVE, WM_SIZE : begin
        if SkinData <> nil then SkinData.BGChanged := True;
      end;
      WM_SETCURSOR: begin
        Message.Result := Ac_SetCursor(Self, CtrlHandle, Message.WPAram, Message.LParam);
        Exit
      end;
      8448 {!} : Exit;
    end;
    inherited;
    case Message.Msg of
      WM_ENABLE, CM_ENABLEDCHANGED : if IsWindowVisible(CtrlHandle) then SendMessage(CtrlHandle, WM_NCPAINT, 0, 0);
      WM_SIZE, WM_HSCROLL, WM_VSCROLL : begin
        if not DontRepaint then UpdateScrolls(Self, True)
      end;
    end;
  end;
end;

{ TacMDIWnd }

type
  TAccessProvider = class(TsSkinProvider);

procedure TacMDIWnd.acWndProc(var Message: TMessage);
var
  DC, SavedDC : HDC;
  si : TScrollInfo;
  function DstRect(const sp : TsSkinProvider) : TRect;
  begin
    GetWindowRect(sp.Form.ClientHandle, Result);
    OffsetRect(Result, -Result.Left, -Result.Top);
  end;
  function SrcRect(const sp : TsSkinProvider) : TRect;
  var
    fR : TRect;
    dX, dY : integer;
  begin
    GetWindowRect(sp.Form.Handle, fR);
    GetWindowRect(sp.Form.ClientHandle, Result);
    if sp.BorderForm <> nil then begin
      dX := DiffBorder(sp.BorderForm) + sp.ShadowSize.Left;
      dY := DiffTitle(sp.BorderForm) + sp.ShadowSize.Top;
    end
    else begin
      dX := 0;
      dY := 0;
    end;
    OffsetRect(Result, -fR.Left + dX, - fR.Top + dY);
  end;
  procedure PaintClient(const DC : HDC; PaintBorder : boolean);
  var
    SrcR, DstR : TRect;
    bw, W, H : Integer;
  begin
    if TsSkinProvider(SkinProvider).fAnimating then Exit;
    SrcR := SrcRect(TsSkinProvider(SkinProvider));
    DstR := DstRect(TsSkinProvider(SkinProvider));

    w := WidthOf(SrcR);
    h := HeightOf(SrcR);

    bw := TsSkinProvider(SkinProvider).SkinData.SkinManager.GetSkinIndex(s_MdiArea);
    if IsCached(TsSkinProvider(SkinProvider).SkinData) or (bw > -1) then begin
      if (TsSkinProvider(SkinProvider).SkinData.FCacheBmp = nil) or TsSkinProvider(SkinProvider).SkinData.BGChanged then TAccessProvider(SkinProvider).PaintAll;
      if TsSkinProvider(SkinProvider).SkinData.FCacheBmp <> nil then begin
        if PaintBorder then bw := 0 else bw := integer((GetWindowLong(CtrlHandle, GWL_EXSTYLE) and WS_EX_CLIENTEDGE) = WS_EX_CLIENTEDGE) * 2;
        BitBlt(DC, DstR.Left, DstR.Top, w, h, TsSkinProvider(SkinProvider).SkinData.FCacheBmp.Canvas.Handle, SrcR.Left + bw, SrcR.Top + bw, SRCCOPY);
      end;
    end
    else begin
      FillDC(DC, DstR, TsSkinProvider(SkinProvider).FormColor);
    end;
  end;
  procedure PaintBorders(const DC : HDC);
  var
    bw : integer;
    R : TRect;
    W, H : Integer;
  begin
    if MDISkinData.FCacheBmp = nil then Exit;
    R := SrcRect(TsSkinProvider(SkinProvider));
    w := WidthOf(R);
    h := HeightOf(R);
    bw := TsSkinProvider(SkinProvider).SkinData.SkinManager.GetSkinIndex(s_MdiArea);
    if IsCached(TsSkinProvider(SkinProvider).SkinData) or (bw > -1) then begin
      BitBltBorder(DC, 0, 0, w, h, MDISkinData.FCacheBmp.Canvas.Handle, R.Left, R.Top, 2);
    end
    else begin
      bw := integer((GetWindowLong(CtrlHandle, GWL_EXSTYLE) and WS_EX_CLIENTEDGE) = WS_EX_CLIENTEDGE) * 2;
      FillDCBorder(DC, Rect(0, 0, w, h), bw, bw, bw, bw, TsSkinProvider(SkinProvider).FormColor);
    end;
  end;
begin
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_GETCACHE : begin
      SendAMessage(FForm, AC_GETCACHE);
      Exit;
    end;
    AC_BEFORESCROLL : begin
      if Message.LParamLo in [SB_THUMBTRACK, SB_THUMBPOSITION] then
        Message.Result := 1; // it's MDI THUMB
      Exit;
    end;
    AC_AFTERSCROLL : begin
      UpdateScrolls(Self, True);
      Exit;
    end;
  end
  else if MDISkinData <> nil then case Message.Msg of
    WM_PRINT : if MDISkinData.Skinned and DrawSkinnedMDIWall and DrawSkinnedMDIScrolls and (TWMPaint(Message).DC <> 0) then begin
      Message.Result := 0;
      if TsSkinProvider(SkinProvider).BorderForm <> nil then Exit;
      if Assigned(FForm.ActiveMDIChild) and (FForm.ActiveMDIChild.WindowState = wsMaximized) then Exit;
      SavedDC := SaveDC(TWMPaint(Message).DC);
      try
        PaintClient(TWMPaint(Message).DC, True);
        Ac_NCPaint(Self, Self.CtrlHandle, Message.wParam, Message.lParam, -1, TWMPaint(Message).DC);
      finally
        RestoreDC(TWMPaint(Message).DC, SavedDC);
      end;
      Exit;
    end;
    WM_NCPAINT: if MDISkinData.Skinned and DrawSkinnedMDIWall and DrawSkinnedMDIScrolls then begin
      if not (Assigned(FForm.ActiveMDIChild) and (FForm.ActiveMDIChild.WindowState = wsMaximized)) and not InAnimationProcess then begin
        DC := GetWindowDC(FForm.ClientHandle);
        try
          PaintBorders(DC);
          Message.Result := Ac_NCPaint(Self, Self.CtrlHandle, Message.wParam, Message.lParam, -1, DC);
        finally
          ReleaseDC(FForm.ClientHandle, DC);
        end;
      end;
      Message.Result := 1;
      Exit;
    end;
    WM_PAINT: if InAnimationProcess then Exit;
    WM_ERASEBKGND: if MDISkinData.Skinned and DrawSkinnedMDIWall and DrawSkinnedMDIScrolls and (TWMEraseBkGnd(Message).DC <> 0) then begin
      if InAnimationProcess then Exit;
      if Assigned(FForm.ActiveMDIChild) and (FForm.ActiveMDIChild.WindowState = wsMaximized) then UpdateGraphControls else begin
        DC := TWMEraseBkGnd(Message).DC;
        SavedDC := SaveDC(DC);
        try
          PaintClient(DC, False);
        finally
          RestoreDC(DC, SavedDC);
        end;
      end;
      Message.Result := 1;
      Exit;
    end;
    WM_STYLECHANGED : begin
      Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
      Exit;
    end;
    WM_WINDOWPOSCHANGING : begin
      TsSkinProvider(MDISkinProvider).SkinData.BGChanged := True;
    end;
    WM_MDISETMENU : begin
      Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
      TsSkinProvider(MDISkinProvider).SkinData.BGChanged := True;
      TsSkinProvider(MDISkinProvider).MenuChanged := True;
      TsSkinProvider(MDISkinProvider).FLinesCount := -1;
      Exit;
    end;
    WM_MDITILE, WM_MDICASCADE : begin
      Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
      TsSkinProvider(SkinProvider).SkinData.BGChanged := True;
      TsSkinProvider(SkinProvider).FLinesCount := -1;
      if (TsSkinProvider(SkinProvider).Form.FormStyle = fsMDIForm) and Assigned(TsSkinProvider(SkinProvider).Form.ActiveMDIChild)
        then SetWindowLong(TsSkinProvider(SkinProvider).Form.ActiveMDIChild.Handle, GWL_STYLE, GetWindowLong(TsSkinProvider(SkinProvider).Form.ActiveMDIChild.Handle, GWL_STYLE) and not WS_SYSMENU);
      if Assigned(TsSkinProvider(SkinProvider).MDIForm) then TsMDIForm(TsSkinProvider(SkinProvider).MDIForm).UpdateMDIIconItem;

      InvalidateRect(CtrlHandle, nil, True);
      RedrawWindow(TsSkinProvider(SkinProvider).Form.ClientHandle, nil, 0, RDW_FRAME or RDW_INVALIDATE or RDW_ALLCHILDREN);
      TsSkinProvider(SkinProvider).SystemMenu.UpdateItems;
      Exit;
    end;
    WM_VSCROLL, WM_HSCROLL : begin
      if Message.WParamLo = SB_THUMBTRACK then Exit;
      if Message.WParamLo = SB_THUMBPOSITION then begin
        si.cbSize := SizeOf(TScrollInfo);
        si.fMask := SIF_ALL;
        if Message.Msg = WM_VSCROLL then begin
          GetScrollInfo(CtrlHandle, SB_VERT, SI);
          ScrollWindow(CtrlHandle, 0, (si.nPos - si.nMin - (nLastSBPos - 1)) * 8, nil, nil);
        end
        else begin
          GetScrollInfo(CtrlHandle, SB_HORZ, SI);
          ScrollWindow(CtrlHandle, (si.nPos - si.nMin - (nLastSBPos - 1)) * 8, 0, nil, nil);
        end;
        Exit;
      end;
    end;
  end;
  inherited;
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_BEFORESCROLL : begin
      SendMessage(CtrlHandle, WM_SETREDRAW, 0, 0);
    end;
    AC_AFTERSCROLL : begin
      SendMessage(CtrlHandle, WM_SETREDRAW, 1, 0);
      if Message.LParamLo <> SB_THUMBTRACK then begin
        RedrawWindow(CtrlHandle, nil, 0, RDW_ERASE or RDW_UPDATENOW or RDW_INVALIDATE or RDW_ALLCHILDREN or RDW_FRAME);
        UpdateScrolls(Self, False);
        ReleaseCapture
      end
    end;
  end
  else case Message.Msg of
    WM_MDIREFRESHMENU : UpdateSkinCaption(TsSkinProvider(SkinProvider));
    WM_PARENTNOTIFY, 63 : begin
      sbarVert.fScrollVisible := GetWindowLong(CtrlHandle, GWL_STYLE) and WS_VSCROLL = WS_VSCROLL;
      sbarHorz.fScrollVisible := GetWindowLong(CtrlHandle, GWL_STYLE) and WS_HSCROLL = WS_HSCROLL;
      UpdateScrolls(Self, True);
    end;
  end;
end;

destructor TacMDIWnd.Destroy;
begin
  MDISkinData := nil;
  SkinProvider := nil;
  inherited;
end;

procedure TacMDIWnd.UpdateGraphControls;
{$IFNDEF ALITE}
var
  i : integer;
  BG : TacBGInfo;
{$ENDIF}
begin
{$IFNDEF ALITE}
  if (FForm.MDIChildCount > 0) and (FForm.ActiveMDIChild <> nil) and (FForm.ActiveMDIChild.WindowState = wsMaximized) then
    for i := 0 to FForm.ControlCount - 1 do if FForm.Controls[i] is TsSplitter then begin
      BG.BgType := btUnknown;
      BG.PleaseDraw := True;
      BG.R := FForm.Controls[i].BoundsRect;
      BG.DrawDC := FForm.Canvas.Handle;
      SendMessage(FForm.Handle, SM_ALPHACMD, MakeWParam(0, AC_GETBG), longint(@BG));
    end;
{$ENDIF}
end;

{ TacVirtualTreeViewWnd }

function TacVirtualTreeViewWnd.GetBorderDimensions: TSize;
var
  Styles: LongInt;
begin
  Result.cx := 0;
  Result.cy := 0;

  Styles := GetWindowLong(CtrlHandle, GWL_STYLE);
  if (Styles and WS_BORDER) <> 0 then begin
    Dec(Result.cx);
    Dec(Result.cy);
  end;
  if (Styles and WS_THICKFRAME) <> 0 then begin
    Dec(Result.cx, GetSystemMetrics(SM_CXFIXEDFRAME));
    Dec(Result.cy, GetSystemMetrics(SM_CYFIXEDFRAME));
  end;
  Styles := GetWindowLong(CtrlHandle, GWL_EXSTYLE);
  if (Styles and WS_EX_CLIENTEDGE) <> 0 then begin
    Dec(Result.cx, GetSystemMetrics(SM_CXEDGE));
    Dec(Result.cy, GetSystemMetrics(SM_CYEDGE));
  end;
end;

procedure TacVirtualTreeViewWnd.acWndProc(var Message: TMessage);
var
  SavedDC, DC : hdc;
  pOffset : TPoint;
  HeaderProp : TObject;
  i : integer;
begin
  if Assigned(SkinData) and SkinData.Skinned then begin
    case Message.Msg of
      WM_HSCROLL : begin
        if (TWMVScroll(Message).ScrollCode = SB_THUMBTRACK) then begin
          sBarHorz.ScrollInfo.cbSize := SizeOf(TScrollInfo);
          sBarHorz.ScrollInfo.fMask := SIF_ALL;
          sBarHorz.ScrollInfo.nPos := sBarHorz.ScrollInfo.nTrackPos;
          SetScrollInfo(CtrlHandle, SB_HORZ, sBarHorz.ScrollInfo, False);
        end;
      end;
      WM_VSCROLL : begin
        if (TWMVScroll(Message).ScrollCode = SB_THUMBTRACK) then begin
          sBarVert.ScrollInfo.cbSize := SizeOf(TScrollInfo);
          sBarVert.ScrollInfo.fMask := SIF_ALL;
          sBarVert.ScrollInfo.nPos := sBarVert.ScrollInfo.nTrackPos;
          SetScrollInfo(CtrlHandle, SB_VERT, sBarVert.ScrollInfo, False);
        end;
      end;
      WM_ERASEBKGND : Exit;
      WM_PRINT : begin
        SkinData.Updating := False;
        DC := TWMPaint(Message).DC;
        if SkinData.BGChanged then begin
          if not ParamsChanged then SetSkinParams;
          PrepareCache(SkinData, CtrlHandle);
        end;
        SavedDC := SaveDC(DC);

        pOffset.X := cxLeftEdge;
        pOffset.Y := cxLeftEdge;
        HeaderProp := GetObjProp(SkinData.FOwnerControl, acHeader);
        if HeaderProp <> nil then begin
          if CheckSetProp(HeaderProp, acOptions, achoVisible)
            then inc(pOffset.Y, GetIntProp(HeaderProp, acHeight))
        end
        else pOffset.Y := cxLeftEdge;
        MoveWindowOrg(DC, pOffset.X, pOffset.Y);
        i := 0;
        CallPrevWndProc(CtrlHandle, WM_PRINTCLIENT, longint(DC), i);
        RestoreDC(DC, SavedDC);
        CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
        UpdateWndCorners(SkinData, 0, Self);
        BitBltBorder(DC, 0, 0, SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height, SkinData.FCacheBmp.Canvas.Handle, 0, 0, cxLeftEdge);
        Message.Result := Ac_NCPaint(Self, CtrlHandle, Message.wParam, Message.lParam, -1, DC);
        Exit;
      end;
      WM_NCPAINT : if IsWindowVisible(CtrlHandle) then begin
        InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
        SkinData.Updating := SkinData.Updating;
        if SkinData.Updating then Exit;
        if SkinData.BGChanged then begin
          if not ParamsChanged then SetSkinParams;
          PrepareCache(SkinData, CtrlHandle, DlgMode);
        end;
        UpdateWndCorners(SkinData, 0, Self);
        DC := GetWindowDC(CtrlHandle);
        SavedDC := SaveDC(DC);
        try
          BitBltBorder(DC, 0, 0, SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height, SkinData.FCacheBmp.Canvas.Handle, 0, 0, cxLeftEdge);
          i := 0;
          CallPrevWndProc(CtrlHandle, WM_PRINT, longint(DC), i);
          Message.Result := Ac_NCPaint(Self, Self.CtrlHandle, Message.wParam, Message.lParam, -1, DC);
        finally
          RestoreDC(DC, SavedDC);
          ReleaseDC(CtrlHandle, DC);
        end;
        Exit;
      end;
    end;
  end;
  inherited;
end;

(*procedure TacVirtualTreeViewWnd.PaintHeader(DC: HDC);
var
  hR : TRect;
  iH{, i} : integer;
  oHeader : TObject;
  Size : TSize;
  Font : TFont;
  Images: TCustomImageList;
  Columns : TCollection;
begin
  if HasProperty(SkinData.FOwnerControl, 'Header') then begin
    oHeader := TObject(GetObjProp(SkinData.FOwnerControl, 'Header'));
    if (oHeader <> nil) and CheckSetProp(oHeader, 'Options', 'hoVisible') and HasProperty(oHeader, 'Height') then begin
      Columns := TCollection(GetObjProp(oHeader, 'Columns')); if (Columns = nil) or (Columns.Count = 0) then Exit;
      Font := TFont(GetObjProp(oHeader, 'Font')); if Font = nil then Exit;
      Images := TCustomImageList(GetObjProp(oHeader, 'Images'));
      iH := GetIntProp(oHeader, 'Height'); if iH = 0 then Exit;
      hR := Rect(0, 0, SkinData.FOwnerControl.Width, SkinData.FOwnerControl.Height);
      Size := GetBorderDimensions;
      InflateRect(hR, Size.cx, Size.cy);
      hR.Bottom := hR.Top + iH;
    end;
  end;
end;*)

procedure TacVirtualTreeViewWnd.RestoreStdParams;
var
  obj, Obj2 : TObject;
  HeaderProp : TObject;
  PropInfo: PPropInfo;
  Method: TMethod;
  PEvent1: PAdvancedHeaderPaintEvent;
  PEvent2: PHeaderPaintQueryElementsEvent;
begin
  inherited;
  if HasProperty(SkinData.FOwnerControl, acVETColors) then begin
    obj := GetObjProp(SkinData.FOwnerControl, acVETColors);
    if obj <> nil then begin
      SetIntProp(obj, acCompressedTextColor, CompressedTextColor);
      SetIntProp(obj, acFileTextColor, FileTextColor);
      SetIntProp(obj, acFolderTextColor, FolderTextColor);
    end;
  end;

  PropInfo := GetPropInfo(SkinData.FOwnerControl.ClassInfo, acOnAdvancedHeaderDraw);
  if (PropInfo <> nil) and (PropInfo^.PropType^^.Kind = tkMethod) then begin
    Method := GetMethodProp(SkinData.FOwnerControl, PropInfo);
    if Assigned(Method.Code) then begin
      PEvent1 := PAdvancedHeaderPaintEvent(@Method.Code);
      PEvent1^ := nil;
      Method.Data := Self;
      SetMethodProp(SkinData.FOwnerControl, PropInfo, Method);
    end;
  end;
  PropInfo := GetPropInfo(SkinData.FOwnerControl.ClassInfo, acOnHeaderDrawQueryElements);
  if (PropInfo <> nil) and (PropInfo^.PropType^^.Kind = tkMethod) then begin
    Method := GetMethodProp(SkinData.FOwnerControl, PropInfo);
    if Assigned(Method.Code) then begin
      PEvent2 := PHeaderPaintQueryElementsEvent(@Method.Code);
      PEvent2^ := nil;
      Method.Data := Self;
      SetMethodProp(SkinData.FOwnerControl, PropInfo, Method);
    end;
  end;

  HeaderProp := GetObjProp(SkinData.FOwnerControl, acHeader);
  if HeaderProp <> nil then begin
    SetSetPropValue(HeaderProp, acOptions, achoOwnerDraw, OwnerDraw);
  end;

  Obj2 := GetObjProp(SkinData.FOwnerControl, acPaintInfoColumn);
  if Obj2 <> nil then begin
    TryChangeIntProp(SkinData.FOwnerControl, acThemed, 1);
    TryChangeIntProp(Obj2, acColor, clBtnFace);

    HeaderProp := GetObjProp(SkinData.FOwnerControl, acHeader);
    if HeaderProp <> nil then begin
      TryChangeIntProp(HeaderProp, acColor, clBtnFace);
      obj := GetObjProp(HeaderProp, acFont);
      TryChangeIntProp(obj, acColor, clBtnText);
    end;
  end;
end;

procedure TacVirtualTreeViewWnd.SetSkinParams;
var
  obj, Obj2 : TObject;
  HeaderProp : TObject;
  Method: TMethod;
  PEvent1: PAdvancedHeaderPaintEvent;
  PEvent2: PHeaderPaintQueryElementsEvent;
begin
  inherited;
  if HasProperty(SkinData.FOwnerControl, acVETColors) then begin
    obj := GetObjProp(SkinData.FOwnerControl, acVETColors);
    if obj <> nil then begin
      SetIntProp(obj, acCompressedTextColor, SkinData.SkinManager.gd[SkinData.SkinIndex].FontColor[1]);
      SetIntProp(obj, acFileTextColor, SkinData.SkinManager.gd[SkinData.SkinIndex].FontColor[1]);
      SetIntProp(obj, acFolderTextColor, SkinData.SkinManager.gd[SkinData.SkinIndex].FontColor[1]);
    end;
  end;
  PropInfo := GetPropInfo(SkinData.FOwnerControl.ClassInfo, acOnAdvancedHeaderDraw);
  if (PropInfo <> nil) and (PropInfo^.PropType^^.Kind = tkMethod) then begin
    Method := GetMethodProp(SkinData.FOwnerControl, PropInfo);
    if not Assigned(Method.Code) then begin
      PEvent1 := PAdvancedHeaderPaintEvent(@Method.Code);
      PEvent1^ := AdvancedHeaderDraw;
      Method.Data := Self;
      SetMethodProp(SkinData.FOwnerControl, PropInfo, Method);

      PropInfo := GetPropInfo(SkinData.FOwnerControl.ClassInfo, acOnHeaderDrawQueryElements);
      if (PropInfo <> nil) and (PropInfo^.PropType^^.Kind = tkMethod) then begin
        Method := GetMethodProp(SkinData.FOwnerControl, PropInfo);
        if not Assigned(Method.Code) then begin
          PEvent2 := PHeaderPaintQueryElementsEvent(@Method.Code);
          PEvent2^ := HeaderDrawQueryElements;
          Method.Data := Self;
          SetMethodProp(SkinData.FOwnerControl, PropInfo, Method);
        end;
      end;
      if PropInfo <> nil then begin
        HeaderProp := GetObjProp(SkinData.FOwnerControl, acHeader);
        if HeaderProp <> nil then SetSetPropValue(HeaderProp, acOptions, achoOwnerDraw, True);
      end;
    end;
  end;
  Obj2 := GetObjProp(SkinData.FOwnerControl, acPaintInfoColumn);
  if Obj2 <> nil then begin
    TryChangeIntProp(Obj2, acColor, SkinData.SkinManager.GetGlobalColor);
    TryChangeIntProp(Obj2, acStyle, 1);

    HeaderProp := GetObjProp(SkinData.FOwnerControl, acHeader);
    if HeaderProp <> nil then begin
      TryChangeIntProp(HeaderProp, acColor, SkinData.SkinManager.GetActiveEditColor);
      obj := GetObjProp(HeaderProp, acFont);
      TryChangeIntProp(obj, acColor, SkinData.SkinManager.GetGlobalFontColor);
      RedrawWindow(TWinControl(SkinData.FOwnerControl).Handle, nil, 0, RDW_FRAME or RDW_INVALIDATE or RDW_UPDATENOW or RDW_ERASE);
    end;
    TryChangeIntProp(SkinData.FOwnerControl, acThemed, 0);
  end;
end;

procedure TacVirtualTreeViewWnd.SaveStdParams;
var
  obj : TObject;
  HeaderProp : TObject;
begin
  inherited;
  if HasProperty(SkinData.FOwnerControl, acVETColors) then begin
    obj := GetObjProp(SkinData.FOwnerControl, acVETColors);
    if obj <> nil then begin
      CompressedTextColor := GetIntProp(obj, acCompressedTextColor);
      FileTextColor := GetIntProp(obj, acFileTextColor);
      FolderTextColor := GetIntProp(obj, acFolderTextColor);
    end;
  end;
  HeaderProp := GetObjProp(SkinData.FOwnerControl, acHeader);
  if HeaderProp <> nil then begin
    OwnerDraw := CheckSetProp(HeaderProp, acOptions, achoOwnerDraw);
  end;
end;

procedure TacVirtualTreeViewWnd.AdvancedHeaderDraw(Sender: TPersistent; var PaintInfo: THeaderPaintInfo; const Elements: THeaderPaintElements);
var
  Bmp : TBitmap;
  si, State, Index : integer;
  ss : string;
  Text : acString;
  TextRC : TRect;
  HeaderProp, FontProp : TObject;
  Flags : Cardinal;
begin
  if Assigned(Self) and not DontRepaint and Assigned(SkinData) and SkinData.Skinned then begin
    if PaintInfo.Column = nil then begin
      if SkinData.SkinIndex <> -1
        then FillDC(PaintInfo.TargetCanvas.Handle, PaintInfo.PaintRectangle, DefaultManager.gd[SkinData.SkinIndex].Color);
      Exit;
    end;
    ss := s_ColHeader;
    si := DefaultManager.GetSkinIndex(ss);
    if not DefaultManager.IsValidSkinIndex(si) then begin
      ss := s_Button;
      si := DefaultManager.GetSkinIndex(ss);
    end;
    if PaintInfo.IsDownIndex then State := 2 else if PaintInfo.IsHoverIndex then State := 1 else State := 0;

    Bmp := CreateBmp32(WidthOf(PaintInfo.PaintRectangle, True), HeightOf(PaintInfo.PaintRectangle, True));
    if hpeBackground in Elements then begin
      PaintItem(si, ss, MakeCacheInfo(SkinData.FCacheBmp), True, State, Rect(0, 0, Bmp.Width, Bmp.Height), PaintInfo.PaintRectangle.TopLeft, Bmp);
      BitBlt(PaintInfo.TargetCanvas.Handle, PaintInfo.PaintRectangle.Left, PaintInfo.PaintRectangle.Top, Bmp.Width, Bmp.Height, Bmp.Canvas.Handle, 0, 0, SRCCOPY);
    end
    else {if PaintInfo.Column <> nil then }begin
      BitBlt(Bmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, PaintInfo.TargetCanvas.Handle, PaintInfo.PaintRectangle.Left, PaintInfo.PaintRectangle.Top, SRCCOPY);

      if (hpeText in Elements) and not (hpeDropMark in Elements) then begin
{$IFDEF TNTUNICODE}
        Text := GetWideStrProp(PaintInfo.Column, 'Text');
{$ELSE}
        Text := GetStrProp(PaintInfo.Column, 'Text');
{$ENDIF}
        if Text <> '' then begin
          TextRC := PaintInfo.TextRectangle;
          OffsetRect(TextRC, -PaintInfo.PaintRectangle.Left, -PaintInfo.PaintRectangle.Top);
          HeaderProp := GetObjProp(SkinData.FOwnerControl, 'Header');
          if HeaderProp <> nil then begin
            FontProp := GetObjProp(HeaderProp, 'Font');
            if FontProp <> nil then begin
              Bmp.Canvas.Font.Assign(TFont(FontProp));
            end;
          end;
          acWriteTextEx(Bmp.Canvas, PacChar(Text), True, TextRC, 0, Si, (State <> 0), DefaultManager);
        end;
      end;
      if (hpeSortGlyph in Elements) and PaintInfo.ShowSortGlyph then begin
        HeaderProp := GetObjProp(SkinData.FOwnerControl, 'Header');
        if HeaderProp <> nil then begin
          if GetOrdProp(HeaderProp, 'SortDirection') = 0 then begin
            Index := DefaultManager.GetMaskIndex(DefaultManager.ConstData.IndexScrollBottom, s_ScrollBtnBottom, s_ItemGlyph)
          end
          else begin
            Index := DefaultManager.GetMaskIndex(DefaultManager.ConstData.IndexScrollTop, s_ScrollBtnTop, s_ItemGlyph)
          end;
          if Index > -1 then begin
            DrawSkinGlyph(Bmp, Point(PaintInfo.SortGlyphPos.x - PaintInfo.PaintRectangle.Left,
                          (HeightOf(PaintInfo.PaintRectangle) - (HeightOf(DefaultManager.ma[Index].R) div (DefaultManager.ma[Index].MaskType + 1))) div 2),
                          State, 1, DefaultManager.ma[Index], MakeCacheInfo(Bmp));
          end;
        end;
      end;
      if hpeDropMark in Elements then begin
{$IFDEF TNTUNICODE}
        Text := GetWideStrProp(PaintInfo.Column, 'Text');
{$ELSE}
        Text := GetStrProp(PaintInfo.Column, 'Text');
{$ENDIF}
        if Text <> '' then begin
          TextRC := PaintInfo.TextRectangle;
          OffsetRect(TextRC, -PaintInfo.PaintRectangle.Left, -PaintInfo.PaintRectangle.Top);

          HeaderProp := GetObjProp(SkinData.FOwnerControl, 'Header');
          if HeaderProp <> nil then begin
            FontProp := GetObjProp(HeaderProp, 'Font');
            if FontProp <> nil then begin
              Bmp.Canvas.Font.Assign(TFont(FontProp));
            end;
          end;

          // HTG
          Flags := DT_VCENTER or DT_END_ELLIPSIS;
          if (Pos('coWrapCaption', GetSetProp(PaintInfo.Column, 'Options')) > 0) then Flags := Flags + DT_WORDBREAK else Flags := Flags + DT_SINGLELINE;

          acWriteTextEx(Bmp.Canvas, PacChar(Text), True, TextRC, Flags, Si, (State <> 0), DefaultManager);
        end;
      end;
      BitBlt(PaintInfo.TargetCanvas.Handle, PaintInfo.PaintRectangle.Left, PaintInfo.PaintRectangle.Top, Bmp.Width, Bmp.Height, Bmp.Canvas.Handle, 0, 0, SRCCOPY);
    end;
    FreeAndNil(Bmp);
  end;
end;

procedure TacVirtualTreeViewWnd.HeaderDrawQueryElements(Sender: TPersistent; var PaintInfo: THeaderPaintInfo; var Elements: THeaderPaintElements);
begin
  Elements := [hpeBackground, hpeDropMark, hpeSortGlyph, hpeText]
end;

{ TacMainWnd }

procedure TacMainWnd.acWndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_SIZE : SkinData.BGChanged := True;
    WM_UPDATEUISTATE : Exit;
    WM_CONTEXTMENU : if (SkinData <> nil) and (SkinData.FOwnerControl <> nil) and (TsHackedControl(SkinData.FOwnerControl).PopupMenu <> nil) then begin
      if SkinData.SkinManager <> nil
        then SkinData.SkinManager.SkinableMenus.HookPopupMenu(TsHackedControl(SkinData.FOwnerControl).PopupMenu, SkinData.SkinManager.Active);
    end;
    WM_DESTROY, WM_NCDESTROY: begin
      if (SkinData <> nil) and (SkinData.GlowID > -1) then HideGlow(SkinData.GlowID);
      if (OldProc <> nil) or Assigned(OldWndProc) then begin
        Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
        if Message.Result = 0 then
        try
          UninitializeACWnd(CtrlHandle, False, False, Self);
        except
        end;
      end
      else Message.Result := SendMessage(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
      Exit;
    end;
    WM_MOUSEMOVE : begin
      if (DefaultManager <> nil) and not (csDesigning in DefaultManager.ComponentState) and IsWindowEnabled(CtrlHandle) and (DefaultManager.ActiveControl <> CtrlHandle) then DefaultManager.ActiveControl := CtrlHandle;
    end;
    WM_SETTEXT : begin
      Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
      Caption := GetWndText(CtrlHandle);
    end;
    WM_PRINT : begin
      Message.Result := SendMessage(CtrlHandle, WM_PAINT, Message.WParam, Message.LParam);
      Exit;
    end;
  end;
  if not Assigned(SkinData) or not Assigned(SkinData.SkinManager) or not SkinData.SkinManager.Active then begin
    Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
  end
  else begin
    if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
      AC_GETBG : if (SkinData <> nil) then begin
        InitBGInfo(SkinData, PacBGInfo(Message.LParam), 0, CtrlHandle);
        Exit;
      end;
      AC_PRINTING : begin
        if Message.LParam = 0 then SkinData.CtrlSkinState := SkinData.CtrlSkinState and not ACS_PRINTING else SkinData.CtrlSkinState := SkinData.CtrlSkinState or ACS_PRINTING;
        SkinData.PrintDC := hdc(Message.LParam);
      end;
      AC_SETNEWSKIN : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
        SkinData.UpdateIndexes;
        SkinData.BGChanged := True;
        AlphaBroadCastCheck(SkinData.FOwnerControl, CtrlHandle, Message);
      end;
      AC_ENDPARENTUPDATE : if SkinData.FUpdating then begin
        SkinData.FUpdating := False;
        SkinData.FUpdating := SkinData.Updating;
        if not SkinData.FUpdating then RedrawWindow(CtrlHandle, nil, 0, RDW_ALLCHILDREN or RDW_INVALIDATE or RDW_FRAME or RDW_UPDATENOW);
        Exit;
      end;
      AC_CTRLHANDLED : begin Message.Result := 1; Exit end;
      AC_GETAPPLICATION : begin Message.Result := longint(Application); Exit end;
      AC_REFRESH : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
        SkinData.UpdateIndexes;
        SkinData.BGChanged := True;
        SkinData.Updating := False;
        if IsWindowVisible(CtrlHandle) then begin
          SendMessage(CtrlHandle, WM_PAINT, 0, 0);
        end;
        Exit;
      end;
      AC_PREPARING : if (SkinData <> nil) then begin
        Message.Result := integer(SkinData.FUpdating);
        Exit;
      end;
      AC_SETSECTION : if (Message.LParam <> 0) and (SkinData <> nil) then SkinData.SkinSection := PacSectionInfo(Message.LParam).Name;
      AC_REMOVESKIN : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
        RestoreStdParams;
      end;
      AC_PREPARECACHE : if SkinData <> nil then PrepareCache(SkinData, CtrlHandle);
      AC_CHILDCHANGED : if SkinData.FOwnerControl <> nil then begin
        CommonMessage(Message, SkinData);
        Exit;
      end;
      AC_GETCONTROLCOLOR : begin
        Message.Result := 0;
        Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
        if Message.Result = 0 then Message.Result := GetBGColor(SkinData, 0, CtrlHandle);
        Exit;
      end;
      
    end;
    Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
  end;
end;

function TacMainWnd.CallPrevWndProc(Handle : hwnd; Msg : longint; WParam : longint; var LParam : longint) : longint;
var
  M : TMessage;
begin
  if Assigned(OldWndProc) then begin
    M.Msg := Msg;
    M.WParam := WParam;
    M.LParam := LParam;
    M.Result := 0;
    OldWndProc(M);
    Result := M.Result;
    LParam := M.LParam;
  end
  else if Assigned(OldProc) then begin
    Result := CallWindowProc(OldProc, Handle, Msg, WParam, LParam);
  end
  else Result := 0;
end;

constructor TacMainWnd.Create(AHandle: hwnd; ASkinData: TsCommonData; ASkinManager: TsSkinManager; const SkinSection : string; Repaint: boolean);
begin
  CtrlHandle := AHandle;
  OldWndProc := nil;
  OldProc := nil;
//  if not InAnimationProcess or (ASkinData = nil) or not (ASkinData.FOwnerObject is TsSkinProvider) then begin
  if (uxthemeLib <> 0) and (SkinSection <> s_Dialog) then Ac_SetWindowTheme(AHandle, ' ', ' ');
//  end;
  NewWndProcInstance := nil;
  SkinManager := ASkinManager;
  Destroyed := False;
  if ASkinData <> nil then begin
    SkinData := ASkinData;
    if SkinManager = nil then SkinManager := SkinData.SkinManager;
  end
  else begin
    OwnSkinData := True;
    SkinData := TsCommonData.Create(nil, True);
  end;
  SkinData.CustomFont := ac_KeepOwnFont or SkinData.CustomFont;
  if SkinData.SkinSection = '' then SkinData.SkinSection := SkinSection;
  DlgMode := acDlgMode;
  SaveStdParams;
  ParamsChanged := False;
  Caption := GetWndText(AHandle);
  if not (Self is TacScrollWnd)
    then InitializeACWnd(Self, AHandle)
    else InitializeACScrolls(TacScrollWnd(Self), AHandle, Repaint);
  if SkinData.FOwnerControl <> nil then SkinData.FOwnerControl.ControlStyle := SkinData.FOwnerControl.ControlStyle + [csOpaque];
end;

destructor TacMainWnd.Destroy;
begin
  if (SkinData <> nil) then begin
    if not Destroyed and (SkinManager <> nil) then begin
      if not bRemoving or SkinManager.SkinRemoving then begin
        if Assigned(OldWndProc) then begin
          if (SkinData.FOwnerObject is TsSkinProvider)
            then TsSkinProvider(SkinData.FOwnerObject).Form.WindowProc := OldWndProc
            else TacWinControl(SkinData.FOwnerControl).WindowProc := OldWndProc;
        end
        else if (OldProc <> nil) then begin
          if DWord(GetWindowLong(CtrlHandle, GWL_WNDPROC)) = DWord(NewWndProcInstance) then SetWindowLong(CtrlHandle, GWL_WNDPROC, Longint(oldproc));
          oldproc := nil;
          if NewWndProcInstance <> nil then begin
            FreeObjectInstance(NewWndProcInstance);
            NewWndProcInstance := nil;
          end;
        end;
        RemoveProp(CtrlHandle, acPropStr);
        RestoreStdParams;
        if {SkinManager.SkinRemoving and }(uxthemeLib <> 0) then Ac_SetWindowTheme(CtrlHandle, nil, nil);
      end;
      Destroyed := True;
    end;
    if OwnSkinData then FreeAndNil(SkinData) else SkinData := nil;
  end;
  SkinManager := nil;
  inherited Destroy;
end;

procedure TacMainWnd.RestoreStdParams;
begin
end;

procedure TacMainWnd.SaveStdParams;
begin
end;

procedure TacMainWnd.SetSkinParams;
begin
  ParamsChanged := True;
end;

{ TacStaticWnd }

procedure TacStaticWnd.acWndProc(var Message: TMessage);
var
  PS : TPaintStruct;
begin
{$IFDEF LOGGED}
//  AddToLog(Message);
{$ENDIF}
  if (GetWindowLong(CtrlHandle, GWL_STYLE) and WS_TABSTOP <> WS_TABSTOP) and (GetWindowLong(CtrlHandle, GWL_EXSTYLE) and WS_EX_STATICEDGE <> WS_EX_STATICEDGE) then case Message.Msg of
    WM_UPDATEUISTATE : if IsWindowVisible(CtrlHandle) then begin
      Inherited;
      exit
    end;
    WM_NCPAINT : Exit;
    WM_ERASEBKGND : if IsWindowVisible(CtrlHandle) then begin
//      AC_WMPaint(TWMPaint(Message));
      Message.Result := 1;
      Exit;
    end;
    WM_PRINT : begin
      AC_WMPaint(TWMPaint(Message));
      Exit;
    end;
    WM_PAINT : begin
      BeginPaint(CtrlHandle, ps);
      if IsWindowVisible(CtrlHandle) then AC_WMPaint(TWMPaint(Message));
      EndPaint(CtrlHandle, ps);
      Exit;
    end;
    WM_CANCELMODE : begin
      Inherited;
      exit
    end;
    WM_ENABLE, WM_MOVE : if IsWindowVisible(CtrlHandle) then begin
      SkinData.BGChanged := True;
      Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
      RedrawWindow(CtrlHandle, nil, 0, RDW_ERASE or RDW_UPDATENOW or RDW_INVALIDATE);
      Exit;
    end;
    WM_SETTEXT : if IsWindowVisible(CtrlHandle) then begin
      SendMessage(CtrlHandle, WM_SETREDRAW, 0, 0);
      Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
      Caption := GetWndText(CtrlHandle);
      SkinData.BGChanged := True;
      SendMessage(CtrlHandle, WM_SETREDRAW, 1, 0);
      RedrawWindow(CtrlHandle, nil, 0, RDW_INVALIDATE or RDW_ERASE or RDW_UPDATENOW);
      Exit;
    end;
  end;
  inherited;
end;

procedure TacStaticWnd.AC_WMPaint(var Message: TWMPaint);
var
  DC, SavedDC : hdc;
begin
  InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
  if Message.DC = 0 then DC := GetWindowDC(CtrlHandle) else DC := Message.DC;
  SavedDC := SaveDC(DC);
  SkinData.BGChanged := True;
  SkinData.FCacheBmp.Width := WndSize.cx;
  SkinData.FCacheBmp.Height := WndSize.cy;
  PrepareCache(SkinData, CtrlHandle);

  if PaintText
    then BitBlt(DC, 0, 0, WndSize.cx, WndSize.cy, SkinData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
  RestoreDC(DC, SavedDC);

  if Message.DC <> DC then ReleaseDC(CtrlHandle, DC);
end;

{$IFNDEF TNTUNICODE}
function _WStr(lpString: PWideChar; cchCount: Integer): WideString;
begin
  if cchCount = -1 then
    Result := lpString
  else
    Result := Copy(WideString(lpString), 1, cchCount);
end;

function ac_DrawTextW(hDC: HDC; lpString: PWideChar; nCount: Integer; var lpRect: TRect; uFormat: UINT): Integer;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT
    then Result := DrawTextW(hDC, lpString, nCount, lpRect, uFormat)
    else Result := DrawTextA(hDC, PAnsiChar(AnsiString(_WStr(lpString, nCount))), -1, lpRect, uFormat);
end;

function WStrEnd(Str: PWideChar): PWideChar;
begin
  // returns a pointer to the end of a null terminated string
  Result := Str;
  While Result^ <> #0 do
    Inc(Result);
end;

function WStrLen(Str: PWideChar): Cardinal;
begin
  Result := WStrEnd(Str) - Str;
end;

procedure WriteTextExW(Canvas: TCanvas; Text: PWideChar; Enabled: boolean; var aRect : TRect; Flags: Cardinal; SkinData : TsCommonData; Hot : boolean); //overload;
var
  R, Rd: TRect;
  x, y : integer;
  ts: TSize;
  SavedDC : hdc;
  nLength: Integer;
begin
{$IFDEF D2005}
  nLength := Length(Text);
{$ELSE}
  nLength := WStrLen(Text);
{$ENDIF}

  R := aRect;
  if Assigned(SkinData.FOwnerControl) then Canvas.Font.Assign(TsHackedControl(SkinData.FOwnerControl).Font);
  if Hot and (SkinData.SkinSection = s_WebBtn) then Canvas.Font.Style := Canvas.Font.Style + [fsUnderline];

  SavedDC := SaveDC(Canvas.Handle);
  try
  IntersectClipRect(Canvas.Handle, aRect.Left, aRect.Top, aRect.Right, aRect.Bottom); 

  if (Flags or DT_WORDBREAK <> Flags) and (Flags or DT_END_ELLIPSIS <> Flags) then begin // If not multiline

    GetTextExtentPoint32W(Canvas.Handle, Text, nLength, ts);
    R.Right := R.Left + ts.cx;
    R.Bottom := R.Top + ts.cy;

    if Flags or DT_CENTER = Flags then begin
      y := (HeightOf(R) - HeightOf(aRect)) div 2;
      x := (WidthOf(R) - WidthOf(aRect)) div 2;
      InflateRect(aRect, x, y);
    end
    else if Flags or DT_RIGHT = Flags then begin
      y := (HeightOf(R) - HeightOf(aRect)) div 2;
      dec(aRect.Top, y);
      inc(aRect.Bottom, y);
      inc(aRect.Left, WidthOf(aRect) - WidthOf(R));
    end
    else if Flags or DT_LEFT = Flags then begin
      y := (HeightOf(R) - HeightOf(aRect)) div 2;
      dec(aRect.Top, y);
      inc(aRect.Bottom, y);
      inc(aRect.Right, WidthOf(R) - WidthOf(aRect));
    end;

    R := aRect;// := R;
    InflateRect(aRect, 1, 1);
  end;

  Canvas.Brush.Style := bsClear;
  if Text <> '' then
    if Enabled then begin
      if Assigned(SkinData.SkinManager) and SkinData.SkinManager.IsValidSkinIndex(SkinData.SkinIndex) then begin
        // Left contur
        if not SkinData.CustomFont then begin
          if SkinData.SkinManager.gd[SkinData.SkinIndex].States < 2 then Hot := False;
          if Hot then Canvas.Font.Color := SkinData.SkinManager.gd[SkinData.SkinIndex].HotFontColor[2] else Canvas.Font.Color := SkinData.SkinManager.gd[SkinData.SkinIndex].FontColor[2];
          if Canvas.Font.Color <> -1 then begin
            Rd := Rect(R.Left - 1, R.Top, R.Right - 1, R.Bottom);
            ac_DrawTextW(Canvas.Handle, Text, nLength, Rd, Flags);
          end;
          // Top
          if Hot then Canvas.Font.Color := SkinData.SkinManager.gd[SkinData.SkinIndex].HotFontColor[3] else Canvas.Font.Color := SkinData.SkinManager.gd[SkinData.SkinIndex].FontColor[3];
          if Canvas.Font.Color <> -1 then begin
            Rd := Rect(R.Left, R.Top - 1, R.Right, R.Bottom - 1);
            ac_DrawTextW(Canvas.Handle, Text, nLength, Rd, Flags);
          end;
          // Right
          if Hot then Canvas.Font.Color := SkinData.SkinManager.gd[SkinData.SkinIndex].HotFontColor[4] else Canvas.Font.Color := SkinData.SkinManager.gd[SkinData.SkinIndex].FontColor[4];
          if Canvas.Font.Color <> -1 then begin
            Rd := Rect(R.Left + 1, R.Top, R.Right + 1, R.Bottom);
            ac_DrawTextW(Canvas.Handle, Text, nLength, Rd, Flags);
          end;
          // Bottom
          if Hot then Canvas.Font.Color := SkinData.SkinManager.gd[SkinData.SkinIndex].HotFontColor[5] else Canvas.Font.Color := SkinData.SkinManager.gd[SkinData.SkinIndex].FontColor[5];
          if Canvas.Font.Color <> -1 then begin
            Rd := Rect(R.Left, R.Top + 1, R.Right, R.Bottom + 1);
            ac_DrawTextW(Canvas.Handle, Text, nLength, Rd, Flags);
          end;
        end;
        // Center
        if not SkinData.CustomFont then begin
          if Hot then Canvas.Font.Color := SkinData.SkinManager.gd[SkinData.SkinIndex].HotFontColor[1] else Canvas.Font.Color := SkinData.SkinManager.gd[SkinData.SkinIndex].FontColor[1];
        end;
        ac_DrawTextW(Canvas.Handle, Text, nLength, R, Flags or DT_NOCLIP);
      end
      else
        ac_DrawTextW(Canvas.Handle, Text, nLength, R, Flags);
    end
    else begin
      Rd := Rect(R.Left + 1, R.Top + 1, R.Right + 1, R.Bottom + 1);
      Canvas.Font.Color := ColorToRGB(clBtnHighlight);
      ac_DrawTextW(Canvas.Handle, Text, nLength, Rd, Flags);
      Canvas.Font.Color := ColorToRGB(clBtnShadow);
      ac_DrawTextW(Canvas.Handle, Text, nLength, R, Flags);
    end;
  finally
    RestoreDC(Canvas.Handle, SavedDC);
  end;
end;
{$ENDIF}

function TacStaticWnd.PaintText : boolean;
var
  rText : TRect;
  Flags : Cardinal;
  f : hFont;
begin
  if Caption <> '' then begin
    SkinData.FCacheBmp.Canvas.Brush.Style := bsClear;
    rText := Rect(0, 0, WndSize.cx, WndSize.cy);
    f := LongWord(SendMessage(CtrlHandle, WM_GETFONT, 0, 0));
    SkinData.FCacheBmp.Canvas.Font.Handle := f;

    Flags := {DT_LEFT or }DT_TOP or DT_EXPANDTABS or DT_WORDBREAK or DT_NOCLIP;
    if GetWindowLong(CtrlHandle, GWL_STYLE) and SS_NOPREFIX = SS_NOPREFIX then Flags := Flags + DT_NOPREFIX;
    if GetWindowLong(CtrlHandle, GWL_EXSTYLE) and WS_EX_RIGHT = WS_EX_RIGHT then Flags := Flags or DT_RIGHT else Flags := Flags or DT_LEFT;

    acWriteTextEx(SkinData.FCacheBmp.Canvas, PacChar(Caption), True, rText, Flags, SkinData, False);
    Result := True;
  end
  else Result := True;
end;

{ TacBtnWnd }

procedure TacBtnWnd.AC_WMPaint(Message: TWMPaint);
var
  PS : TPaintStruct;
  DC : hdc;
begin
  InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
  BeginPaint(CtrlHandle, ps);
  if not (InAnimationProcess and (0 = SkinData.PrintDC)) {if showed before animation} then begin
    SkinData.FUpdating := SkinData.Updating and not InAnimationProcess;
    if not SkinData.FUpdating then begin
      if Message.DC = 0 then DC := GetDC(CtrlHandle) else DC := Message.DC;
      SkinData.BGChanged := True;
      PrepareCache;
      BitBlt(DC, 0, 0, SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height, SkinData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
      if Message.DC = 0 then ReleaseDC(CtrlHandle, DC);
    end;
  end;
  EndPaint(CtrlHandle, ps);
end;

procedure TacBtnWnd.acWndProc(var Message: TMessage);
var
  R : TRect;
begin
{$IFDEF LOGGED}
//  AddToLog(Message);
{$ENDIF}
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_MOUSEENTER : if not SkinData.FMouseAbove and (DefaultManager.ActiveControl = CtrlHandle) then begin
      GetWindowRect(CtrlHandle, R);
      if not PtInRect(R, acMousePos) then Exit;
      SkinData.FMouseAbove := True;
      SkinData.BGChanged := True;
      SkinData.Updating := False;
      Repaint;
      ShowGlowingIfNeeded(SkinData, False, CtrlHandle);
    end;
    AC_MOUSELEAVE : if SkinData.FMouseAbove then begin
      ClearGlows;
      SkinData.FMouseAbove := False;
      SkinData.Updating := False;
      SkinData.BGChanged := True;
      Repaint;
    end;
    AC_ENDPARENTUPDATE : if SkinData.FUpdating then begin
      SkinData.FUpdating := False;
      SkinData.FUpdating := SkinData.Updating;
      if not SkinData.FUpdating then RedrawWindow(CtrlHandle, nil, 0, RDW_ALLCHILDREN or RDW_INVALIDATE or RDW_FRAME or RDW_UPDATENOW);
      Exit;
    end;
  end
  else case Message.Msg of
    WM_PAINT : if IsWindowVisible(CtrlHandle) or (SkinData.CtrlSkinState and ACS_PRINTING = ACS_PRINTING) then begin
      if not ParamsChanged then SetSkinParams;
      AC_WMPaint(TWMPaint(Message));
      Exit;
    end;
    WM_ENABLE : if IsWindowVisible(CtrlHandle) then begin
      SendMessage(CtrlHandle, WM_SETREDRAW, 0, 0);
      Inherited;
      SendMessage(CtrlHandle, WM_SETREDRAW, 1, 0);
      SkinData.BGChanged := True;
      Repaint;
      exit
    end;
    WM_MOUSELEAVE : if DefaultManager.ActiveControl = CtrlHandle then DefaultManager.ActiveControl := 0;
    WM_MOUSEHOVER : SendAMessage(CtrlHandle, AC_MOUSEENTER);
    BM_SETSTATE : if IsWindowVisible(CtrlHandle) then begin
      SendMessage(CtrlHandle, WM_SETREDRAW, 0, 0);
      Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
      SendMessage(CtrlHandle, WM_SETREDRAW, 1, 0);
      SkinData.BGChanged := True;
      Repaint;
      exit
    end;
    WM_NCPAINT, WM_UPDATEUISTATE, WM_ERASEBKGND : begin
      Message.Result := 1;
      Exit;
    end;
    WM_PRINT : begin
      AC_WMPaint(TWMPaint(Message));
      Exit;
    end;
    WM_MOVE : if (SkinData.SkinManager.gd[SkinData.SkinIndex].Transparency > 0) or ((SKinData.SkinManager.gd[SkinData.SkinIndex].HotTransparency > 0) and ControlIsActive(SkinData)) then begin
      SkinData.BGChanged := True;
      Repaint;
    end;
    WM_SETFOCUS : begin
      if IsWindowEnabled(CtrlHandle) then begin
        SendMessage(CtrlHandle, WM_SETREDRAW, 0, 0);
        inherited;
        SendMessage(CtrlHandle, WM_SETREDRAW, 1, 0);
        SkinData.FFocused := True;
        SkinData.BGChanged := True;
        RedrawWindow(CtrlHandle, nil, 0, RDW_INVALIDATE or RDW_FRAME);
        Exit;
      end;
    end;
    WM_KILLFOCUS: begin
      if IsWindowEnabled(CtrlHandle) then begin
        SendMessage(CtrlHandle, WM_SETREDRAW, 0, 0);
        inherited;
        SendMessage(CtrlHandle, WM_SETREDRAW, 1, 0);

        SkinData.FFocused := False;
        SkinData.BGChanged := True;
        RedrawWindow(CtrlHandle, nil, 0, RDW_INVALIDATE or RDW_FRAME);
        Exit
      end;
    end;
    WM_SETTEXT : if IsWindowVisible(CtrlHandle) then begin
      SendMessage(CtrlHandle, WM_SETREDRAW, 0, 0);
      inherited;
      SendMessage(CtrlHandle, WM_SETREDRAW, 1, 0);
      SkinData.BGChanged := True;
      Repaint;
      Exit;
    end;
  end;
  inherited;
  case Message.Msg of
    WM_MOUSEMOVE : begin
      if (DefaultManager <> nil) and not (csDesigning in DefaultManager.ComponentState) and IsWindowEnabled(CtrlHandle) then begin
        GetWindowRect(CtrlHandle, R);
        if PtInRect(R, acMousePos) then begin
          if DefaultManager.ActiveControl <> CtrlHandle then begin
            DefaultManager.ActiveControl := CtrlHandle;
          end;
        end
        else begin
          if DefaultManager.ActiveControl = CtrlHandle then begin
            DefaultManager.ActiveControl := 0;
          end;
        end;
      end;
    end;
  end;
end;

procedure TacBtnWnd.PrepareCache;
var
  CI : TCacheInfo;
  C : TsColor;
  R : TRect;
  s : integer;
begin
  InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
  CI := GetParentCacheHwnd(CtrlHandle);
  InitCacheBmp(SkinData);

  SkinData.FCacheBMP.Width := WndSize.cx;
  SkinData.FCacheBMP.Height := WndSize.cy;
  s := CurrentState;

  PaintItem(SkinData, CI, True, s, Rect(0, 0, WndSize.cx, WndSize.cy), WndPos, SkinData.FCacheBMP, True, integer(Down), integer(Down));
  DrawCaption;
  DrawGlyph;

  if not IsWindowEnabled(CtrlHandle) then begin
    if CI.Ready then begin
      C.A := MaxByte;
      R := Rect(0, 0, WndSize.cx, WndSize.cy);
      OffsetRect(R, WndPos.x + CI.x, WndPos.y + CI.y);
      BlendTransRectangle(SkinData.FCacheBmp, 0, 0, CI.Bmp, R, DefDisabledBlend);
    end
    else begin
      C.C := CI.FillColor;
      BlendTransBitmap(SkinData.FCacheBmp, DefDisabledBlend, C);
    end;
  end;

  SkinData.BGChanged := False;
end;

function TacBtnWnd.CurrentState: integer;
begin
  if Down then begin
    Result := 2;
    ClearGlows;
  end
  else begin
    if not IsWindowEnabled(CtrlHAndle) then begin
      Result := 0;
      Exit
    end;
    if ((GetFocus = CtrlHandle) or (DefaultManager.ActiveControl = CtrlHandle)) then begin
      Result := 1;
    end
    else begin
      if (SkinData.FOwnerControl <> nil)
        then Result := integer(GetWindowLong(CtrlHandle, GWL_STYLE) and $000F = BS_DEFPUSHBUTTON)
        else if (CtrlStyle and BS_DEFPUSHBUTTON <> 0) then Result := 1 else Result := 0;
    end;
  end;
end;

function TacBtnWnd.CtrlStyle: dword;
begin
  Result := GetWindowLong(CtrlHandle, GWL_STYLE);
end;

function TacBtnWnd.Down: boolean;
begin
  Result := SendMessage(CtrlHandle, BM_GETSTATE, 0, 0) and BST_PUSHED = BST_PUSHED;
end;

procedure TacBtnWnd.DrawCaption;
var
  R : TRect;
  DrawStyle: Cardinal;
  bf, cf : HFont;
begin
  cf := 0;
  if SkinData.FOwnerControl = nil then begin
    bf := LongWord(SendMessage(CtrlHandle, WM_GETFONT, 0, 0));
    cf := SelectObject(SkinData.FCacheBMP.Canvas.Handle, bf);
    SkinData.FCacheBMP.Canvas.Font.Handle := bf;
  end
  else SkinData.FCacheBMP.Canvas.Font.Assign(TBitBtn(SkinData.FOwnerControl).Font);
  R := CaptionRect;
  { Calculate vertical layout }

  DrawStyle := DT_EXPANDTABS or DT_CENTER;
  if CtrlStyle and BS_MULTILINE <> BS_MULTILINE then DrawStyle := DrawStyle or DT_WORDBREAK;
  if GetWindowLong(CtrlHandle, GWL_EXSTYLE) and WS_EX_RTLREADING = WS_EX_RTLREADING then DrawStyle := DrawStyle or DT_RTLREADING;

  DoDrawText(R, DrawStyle);

  if IsWindowEnabled(CtrlHandle) and (SendMessage(CtrlHandle, BM_GETSTATE, 0, 0) and BST_FOCUS = BST_FOCUS) and (Caption <> '') and SkinData.SkinManager.gd[SkinData.SkinIndex].ShowFocus then begin
    InflateRect(R, 1, 1);
    FocusRect(SkinData.FCacheBMP.Canvas, R);
  end;

  SelectObject(SkinData.FCacheBMP.Canvas.Handle, cf);
end;

function TacBtnWnd.CaptionRect: TRect;
var
  l, t, r, b : integer;
  Size : TSize;
begin
  Size := TextRectSize;
  l := (WndSize.cx - Size.cx) div 2;
  t := (WndSize.cy - Size.cy) div 2;
  b := WndSize.cy - t;
  r := WndSize.cx - l;
  Result := Rect(l - 1, t, r + 2, b);
  if Down then OffsetRect(Result, 1, 1);
end;

procedure TacBtnWnd.DoDrawText(var Rect: TRect; Flags: Integer);
begin
  SkinData.FCacheBMP.Canvas.Brush.Style := bsClear;
  acWriteTextEx(SkinData.FCacheBMP.Canvas, PacChar(Caption), True, Rect, Flags, SkinData, CurrentState <> 0);
end;

function TacBtnWnd.TextRectSize: TSize;
var
  R : TRect;
  DrawStyle: Cardinal;
begin
  R := Rect(0, 0, MaxCaptionWidth, 0);
  DrawStyle := DT_EXPANDTABS or DT_CENTER or DT_CALCRECT or DT_NOPREFIX;
  if CtrlStyle and BS_MULTILINE <> BS_MULTILINE then DrawStyle := DrawStyle or DT_WORDBREAK;
  acDrawText(SkinData.FCacheBMP.Canvas.Handle, Caption, R, DrawStyle);
  Result.cy := HeightOf(R, True);
  Result.cx := WidthOf(R, True);
end;

procedure TacBtnWnd.DrawGlyph;
begin

end;

function TacBtnWnd.GlyphSize: TSize;
begin
  Result.cx := 0;
  Result.cy := 0;
end;

function TacBtnWnd.MaxCaptionWidth: integer;
begin
  if (Caption <> '') then begin
    if Glyphsize.cx <> 0
      then Result := max(0, WndSize.cx - Glyphsize.cx)
      else Result := WndSize.cx - 2
  end
  else Result := 0;
end;

procedure TacBtnWnd.Repaint;
begin
  RedrawWindow(CtrlHandle, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW);
end;

procedure TacBtnWnd.RestoreStdParams;
begin
  inherited;
end;

procedure TacBtnWnd.SetSkinParams;
begin
  inherited;
end;

constructor TacBtnWnd.Create(AHandle: hwnd; ASkinData: TsCommonData; ASkinManager: TsSkinManager; const SkinSection: string; Repaint: boolean);
begin
  inherited;
  if SkinSection = '' then ASkinData.SkinSection := s_Button;
end;

{ TacSizerWnd }

procedure TacSizerWnd.AC_WMPaint(const Message: TWMPaint);
var
  PS : TPaintStruct;
  DC : hdc;
  Bmp : TBitmap;
  i : integer;
  BG : TacBGInfo;
begin
  InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
  BeginPaint(CtrlHandle, PS);
  DC := GetDC(CtrlHandle);
  Bmp := CreateBmp32(WndSize.cx, WndSize.cy);
  try
    i := SkinData.SkinManager.GetMaskIndex(SkinData.SkinManager.ConstData.IndexGLobalInfo, s_GlobalInfo, s_GripImage);
    if SkinData.SkinManager.IsValidImgIndex(i) then begin
      BG.DrawDC := Bmp.Canvas.Handle;
      BG.R := Rect(0, 0, WndSize.cx, WndSize.cy);
      BG.Offset.X := WndPos.X;
      BG.Offset.Y := WndPos.Y;
      BG.PleaseDraw := True;
      SendMessage(ParentWnd, SM_ALPHACMD, MakeWParam(0, AC_GETBG), longint(@BG));

      DrawSkinGlyph(Bmp, Point(max(WndSize.cx - WidthOf(SkinData.SkinManager.ma[i].R) div SkinData.SkinManager.ma[i].ImageCount, 0),
                               max(WndSize.cy - HeightOf(SkinData.SkinManager.ma[i].R) div (1 + SkinData.SkinManager.ma[i].MaskType), 0)),
                    0, 1, SkinData.SkinManager.ma[i], MakeCacheInfo(Bmp));

      BitBlt(DC, 0, 0, WndSize.cx, WndSize.cy, Bmp.Canvas.Handle, 0, 0, SRCCOPY);
    end;

  finally
    FreeAndNil(Bmp);
    ReleaseDC(CtrlHandle, DC);
    EndPaint(CtrlHandle, PS);
  end;
end;

procedure TacSizerWnd.acWndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_NCPAINT, WM_ERASEBKGND : begin
      Exit;
    end;
    WM_PAINT : begin
      AC_WMPaint(TWMPaint(Message));
      Exit;
    end;
  end;
  inherited;
  case Message.Msg of
    WM_NCHITTEST : begin
      if IsWindowEnabled(CtrlHandle) then DefaultManager.ActiveControl := 0;
      Message.Result := HTBOTTOMRIGHT;
    end;
  end;
end;

{ TacToolBarWnd }

procedure TacToolBarWnd.acWndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_PRINT : begin
      AC_WMPrint(TWMPaint(Message));
      Exit;
    end;
    WM_NCPAINT : begin
      AC_WMNCPaint(Message);
      Exit;
    end;
    WM_ERASEBKGND : begin
      Exit;
    end;
    WM_PAINT : if IsWindowVisible(CtrlHandle) then begin
      AC_WMPaint(TWMPaint(Message));
      Exit;
    end;
    WM_WINDOWPOSCHANGED, WM_SIZE : begin
      SkinData.BGChanged := True;
    end;
  end;
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_ENDPARENTUPDATE : if SkinData.Updating then begin
      SkinData.Updating := False;
      RedrawWindow(CtrlHandle, nil, 0, RDW_ALLCHILDREN or RDW_INVALIDATE or RDW_FRAME or RDW_UPDATENOW);
      Exit;
    end;
  end;
  inherited;
  case Message.Msg of
    WM_WINDOWPOSCHANGED, WM_SIZE : begin
      SendMessage(CtrlHandle, WM_NCPAINT, 0, 0);
    end;
    WM_MOUSEMOVE : begin
      if (DefaultManager <> nil) and not (csDesigning in DefaultManager.ComponentState) and IsWindowEnabled(CtrlHandle) then DefaultManager.ActiveControl := CtrlHandle;
    end;
  end;
end;

function TacToolBarWnd.Count: integer;
begin
  Result := SendMessage(CtrlHandle, TB_BUTTONCOUNT, 0, 0);
end;

function TacToolBarWnd.ButtonRect(Index : integer): TRect;
begin
  if SendMessage(CtrlHandle, TB_GETITEMRECT, Index, Longint(@Result)) = 0 then Result := Rect(0, 0, 0, 0);
end;

procedure TacToolBarWnd.AC_WMNCPaint(Message: TMessage);
var
  DC, SavedDC : hdc;
begin
  if GetWindowLong(CtrlHandle, GWL_EXSTYLE) and WS_EX_CLIENTEDGE = WS_EX_CLIENTEDGE then begin
    SkinData.Updating := GetBoolMsg(GetParent(CtrlHandle), AC_PREPARING) or SkinData.Updating;
    if SkinData.Updating then Exit;
    PrepareCache;
    DC := GetWindowDC(CtrlHandle);
    SavedDC := SaveDC(DC);
    try
      BitBltBorder(DC, 0, 0, SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height, SkinData.FCacheBmp.Canvas.Handle, 0, 0, (WndSize.cx - WidthOf(ClientRect)) div 2);
    finally
      RestoreDC(DC, SavedDC);
      ReleaseDC(CtrlHandle, DC);
    end;
  end;
end;

procedure TacToolBarWnd.PrepareCache;
begin
  InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
  if SkinData.BGChanged then begin
    GetClientRect(CtrlHandle, ClientRect);
    acSBUtils.PrepareCache(SkinData, CtrlHandle, False);
    UpdateWndCorners(SkinData, 0, Self);
    BorderWidth := (WndSize.cy - HeightOf(ClientRect)) div 2;
    SkinData.BGChanged := False;
  end;
end;

procedure TacToolBarWnd.AC_WMPaint(Message: TWMPaint);
var
  PS : TPaintStruct;
begin
  BeginPaint(CtrlHandle, PS);
  SkinData.Updating := GetBoolMsg(GetParent(CtrlHandle), AC_PREPARING) or SkinData.Updating;
  if not SkinData.Updating then begin
    AC_WMPrint(Message);
  end;
  EndPaint(CtrlHandle, PS);
end;

procedure TacToolBarWnd.AC_WMPrint(Message: TWMPaint);
var
  DC : hdc;
  TempBmp : TBitmap;
begin
  PrepareCache;
  TempBmp := CreateBmp32(SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height);
  DrawButtons(TempBmp);
  if Message.DC = 0 then DC := GetDC(CtrlHandle) else DC := Message.DC;
  BitBlt(DC, 0, 0, SkinData.FCacheBmp.Width - 2 * BorderWidth, SkinData.FCacheBmp.Height - 2 * BorderWidth, TempBmp.Canvas.Handle, BorderWidth, BorderWidth, SRCCOPY);
  FreeAndNil(TempBmp);
  if Message.DC = 0 then ReleaseDC(CtrlHandle, DC);
end;

procedure TacToolBarWnd.DrawButtons(Bmp: TBitmap);
var
  i, c : integer;
  r : TRect;
begin
  BitBlt(Bmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, SkinData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
  c := Count;
  for i := 0 to c - 1 do begin
    r := GetButtonRect(i);
    OffsetRect(r, BorderWidth, BorderWidth);
    DrawBtn(i, r, Bmp.Canvas.Handle);
  end;
end;

function TacToolBarWnd.GetButtonRect(Index: integer): TRect;
begin
  SendMessage(CtrlHandle, TB_GETITEMRECT, Index, longint(@Result));
end;

{$IFDEF TNTUNICODE}
function StrPasW(const Str: PWideChar): WideString;
begin
  Result := Str;
end;
{$ENDIF}

procedure TacToolBarWnd.DrawBtn(Index : integer; R : TRect; DC : hdc);
const
  Margin = 2;
var
  BtnIndex : integer;
  BtnBmp : TBitmap;
  i, cx, cy, count, Ndx : integer;
  Btn : TTBBUTTON;
  s, s1, s2 : acString;
  buf: array[0..1000] of acChar;
  bf : hFont;
  rText, rT : TRect;
  State, ArrowIndex, pOffset : integer;
  pt : TPoint;
  ArrowSize : TSize;
  tm : TTextMetric;
  si, mi : integer;
  nRect : TRect;
begin
  if (SendMessage(CtrlHandle, TB_GETBUTTON, Index, longint(@Btn)) <> 0) then begin
    BtnBmp := CreateBmp32(WidthOf(r, True), HeightOf(r, True));
    if (Btn.fsStyle = TBSTYLE_SEP) then begin // Separator
      si := DefaultManager.GetSkinIndex(s_Divider);
      mi := DefaultManager.GetMaskIndex(si, s_Divider, s_BordersMask);
      if DefaultManager.IsValidImgIndex(mi) then begin

        nRect.Top := 2;
        nRect.Left := BtnBmp.Width div 2 - 1;
        nRect.Bottom := BtnBmp.Height - 2;
        nRect.Right := nRect.Left + 4;

        BitBlt(BtnBmp.Canvas.Handle, 0, 0, BtnBmp.Width, BtnBmp.Height, SkinData.FCacheBmp.Canvas.Handle, R.Left, R.Top, SRCCOPY);
        PaintItem(si, s_Divider, MakeCacheInfo(SkinData.FCacheBmp), True, 0, nRect, Point(R.Left + nRect.Left, R.Top + nRect.Top), BtnBmp);
        BitBlt(DC, r.Left, r.Top, BtnBmp.Width, BtnBmp.Height, BtnBmp.Canvas.Handle, 0, 0, SRCCOPY);
        FreeAndNil(BtnBmp);
      end;
      Exit
    end;

    BtnIndex := DefaultManager.GetSkinIndex(s_ToolButton);

    pOffset := 0;
    if Btn.fsState and TBSTATE_ENABLED <> TBSTATE_ENABLED then begin
      State := 0;
    end
    else if Btn.fsState and TBSTATE_PRESSED = TBSTATE_PRESSED then begin
      State := 2;
      pOffset := 1;
    end
    else begin
      GetCursorPos(pt);
      if PtInRect(Rect(R.Left + WndRect.Left, R.Top + WndRect.Top, R.Right + WndRect.Left, R.Bottom + WndRect.Top), pt) then State := 1 else State := 0;
    end;

    PaintItem(BtnIndex, s_ToolButton, MakeCacheInfo(SkinData.FCacheBmp), True, State, Rect(0, 0, BtnBmp.Width, BtnBmp.Height), Point(r.Left, r.Top), BtnBmp);
    if Btn.iBitmap <> 0 then begin
      i := SendMessage(CtrlHandle, TB_GETIMAGELIST, 0, 0);
      if i <> 0 then begin
        ImageList_GetIconSize(i, cx, cy);
        ImageList_SetBkColor(i, CLR_NONE);
        if Btn.fsStyle and $0080 = $0080 then begin // BTNS_WHOLEDROPDOWN
          ArrowIndex := DefaultManager.GetMaskIndex(DefaultManager.ConstData.IndexScrollBottom, s_ScrollBtnBottom, s_ItemGlyph);
          if ArrowIndex <> -1 then begin
            ArrowSize.cx := WidthOf(DefaultManager.ma[ArrowIndex].R) div DefaultManager.ma[ArrowIndex].ImageCount;
            ArrowSize.cy := HeightOf(DefaultManager.ma[ArrowIndex].R) div (DefaultManager.ma[ArrowIndex].MaskType + 1);
            DrawSkinGlyph(BtnBmp, Point(BtnBmp.Width - 2 - ArrowSize.cx + pOffset, (BtnBmp.Height - ArrowSize.cy) div 2 + pOffset), State, 1, DefaultManager.ma[ArrowIndex], MakeCacheInfo(BtnBmp));
            ImageList_Draw(i, Btn.iBitmap, BtnBmp.Canvas.Handle, (WidthOf(r) - cx - ArrowSize.cx) div 2 + pOffset, 4+ pOffset, 0);
          end
          else begin
            ImageList_Draw(i, Btn.iBitmap, BtnBmp.Canvas.Handle, (WidthOf(r) - cx) div 2 + pOffset, 4 + pOffset, 0);
          end;
        end
        else begin
          ImageList_Draw(i, Btn.iBitmap, BtnBmp.Canvas.Handle, (WidthOf(r) - cx) div 2 + pOffset, 4 + pOffset, 0);
        end;
      end
      else begin
        cy := 0;
        cx := 0;
      end;
    end;
{$IFDEF TNTUNICODE}
    if SendMessage(CtrlHandle, TB_GETBUTTONTEXTW, Btn.idCommand, integer(@buf)) <> -1 then begin
      s := StrPasW(buf);
{$ELSE}
    if SendMessage(CtrlHandle, TB_GETBUTTONTEXT, Btn.idCommand, integer(@buf)) <> -1 then begin
      s := StrPas(buf);
{$ENDIF}
      if s <> '' then begin
        bf := LongWord(SendMessage(CtrlHandle, WM_GETFONT, 0, 0));
        SelectObject(BtnBmp.Canvas.Handle, bf);
        GetTextMetrics(BtnBmp.Canvas.Handle, tm);

        rText.Left := Margin + pOffset;
        rText.Right := WidthOf(r) - Margin + pOffset;
        rText.Top := Margin + integer(cy <> 0) * (cy + 2) + pOffset;
        rText.Bottom := HeightOf(r) - Margin + pOffset;
        BtnBmp.Canvas.Brush.Style := bsClear;

        count := acWordCount(s, [' ']);
        s2 := '';
        for i := 1 to count do begin
          s2 := Copy(s, 1, acWordPosition(i, s, [' ']) - 2);
          if (BtnBmp.Canvas.TextWidth(s2) > WidthOf(R)) or (i = count) then begin
            s1 := Copy(s, 1, acWordPosition(i - 1, s, [' ']) - 2);
            s2 := Copy(s, acWordPosition(i - 1, s, [' ']), Length(s));
          end
        end;

        if (State = 0) and SkinData.SkinManager.gd[SkinData.SkinIndex].GiveOwnFont then Ndx := SkinData.SkinIndex else Ndx := BtnIndex;

        if (s1 = '') or (s2 = '') then begin
          acWriteTextEx(BtnBmp.Canvas, PacChar(s), True, rText, DT_WORDBREAK or DT_CENTER or DT_END_ELLIPSIS or DT_VCENTER, Ndx, State <> 0);
        end
        else begin
          rT := rText;
          rT.Bottom := rT.Top + tm.tmHeight;
          acWriteTextEx(BtnBmp.Canvas, PacChar(s1), True, rT, DT_CENTER, Ndx, State <> 0);
          rT.Top := rT.Bottom;
          rT.Bottom := rText.Bottom;
          rT.Left := rText.Left;
          rT.Right := rText.Right;
          acWriteTextEx(BtnBmp.Canvas, PacChar(s2), True, rT, DT_LEFT or DT_END_ELLIPSIS, Ndx, State <> 0)
        end;
      end;
    end;
    if Btn.fsState and TBSTATE_ENABLED <> TBSTATE_ENABLED then begin
      rText := Rect(0, 0, BtnBmp.Width, BtnBmp.Height);
      OffsetRect(rText, R.Left, R.Top);
      BlendTransRectangle(BtnBmp, 0, 0, SkinData.FCacheBmp, rText, DefDisabledBlend);
    end;
    BitBlt(DC, r.Left, r.Top, BtnBmp.Width, BtnBmp.Height, BtnBmp.Canvas.Handle, 0, 0, SRCCOPY);
    FreeAndNil(BtnBmp);
  end;
end;

{ TacTransPanelWnd }

procedure TacTransPanelWnd.acWndProc(var Message: TMessage);
begin
{$IFDEF LOGGED}
//  AddToLog(Message);
{$ENDIF}
  case Message.Msg of
    WM_NCPAINT : begin
      Message.Result := 0;
      Exit;
    end;
    WM_ERASEBKGND : begin
      AC_WMPaint(TWMPaint(Message));
      Message.Result := 1;
      Exit;
    end;
(*
    WM_NOTIFY : begin
      case TWMNotify(Message).NMHdr^.code of
        CDN_FIRST - 1 {CDN_SELCHANGE} : SkinData.BGChanged := True;
      end;
    end;
*)    
  end;
  inherited;
end;

procedure TacTransPanelWnd.AC_WMPaint(Message: TWMPaint);
var
  PS : TPaintStruct;
  DC : hdc;
begin
  GetWindowRect(CtrlHandle, WndRect);
  WndSize.cx := WidthOf(WndRect);
  WndSize.cy := HeightOf(WndRect);
  BeginPaint(CtrlHandle, ps);
  if Message.DC <> 0 then DC := Message.DC else DC := GetWindowDC(CtrlHandle);

  SkinData.BGChanged := True;
  SendMessage(CtrlHandle, SM_ALPHACMD, MakeWParam(0, AC_PREPARECACHE), 0);

  CopyHwndCache(CtrlHandle, SkinData, Rect(0, 0, 0, 0), Rect(0, 0, WndSize.cx, WndSize.cy), DC, False, 0, 0);

  if Message.DC <> DC then ReleaseDC(CtrlHandle, DC);
  EndPaint(CtrlHandle, ps);
end;

{ TacGroupBoxWnd }

procedure TacGroupBoxWnd.AC_WMPaint(Message: TWMPaint);
var
  DC : hdc;
  cRect : TRect;
  PS : TPaintStruct;
begin
  InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
  BeginPaint(CtrlHandle, PS);

  SkinData.FUpdating := SkinData.Updating;
  if not SkinData.FUpdating then begin
    if (Message.DC = 0) or (Message.Unused <> 1) then DC := GetWindowDC(CtrlHandle) else DC := Message.DC;

    PrepareCache;

    if DlgMode then begin
      cRect.Top := HeightOf(CaptionRect);
      cRect.Left := DefaultManager.MaskWidthLeft(SkinData.BorderIndex);
      cRect.Right := WndSize.cx - DefaultManager.MaskWidthRight(SkinData.BorderIndex);
      cRect.Bottom := WndSize.cy - DefaultManager.MaskWidthBottom(SkinData.BorderIndex);
      ExcludeClipRect(DC, cRect.Left, cRect.Top, cRect.Right, cRect.Bottom);
    end;

    CopyHwndCache(CtrlHandle, SkinData, Rect(0, 0, 0, 0), Rect(0, 0, WndSize.cx, WndSize.cy), DC, False);
    if SkinData.FOwnerControl <> nil then begin
      PaintControls(DC, TWinControl(SkinData.FOwnerControl), False, Point(0, 0));
    end;

    if DC <> Message.DC then ReleaseDC(CtrlHandle, DC);
    SetParentUpdated(CtrlHandle);
  end;

  EndPaint(CtrlHandle, PS);
end;

procedure TacGroupBoxWnd.acWndProc(var Message: TMessage);
begin
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_GETSERVICEINT : begin Message.Result := HeightOf(CaptionRect); Exit end;
    AC_REMOVESKIN : begin
      SkinData.FOwnerControl.ControlStyle := SkinData.FOwnerControl.ControlStyle - [csOpaque];
    end;
  end;
  case Message.Msg of
    WM_ERASEBKGND : if not DlgMode then begin
      if Message.WParam = Message.LParam then begin
        if SkinData.BGChanged then PrepareCache;
        if not SkinData.BGChanged then begin
          if IsCached(SkinData)
            then BitBlt(TWMPaint(Message).DC, 0, 0, WndSize.cx, WndSize.cy, SkinData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY)
            else FillDC(TWMPaint(Message).DC, Rect(0, 0, WndSize.cx, WndSize.cy), GetControlColor(CtrlHandle));
        end;
      end;
      Message.Result := 1;
      Exit;
    end;
    WM_NCPAINT : if DlgMode then begin
      AC_WMPaint(TWMPaint(MakeMessage(WM_NCPAINT, 0, 0, 0)));
      Message.Result := 1;
      Exit;
    end;
    WM_PRINT : {if not DlgMode then }begin
      SkinData.BGChanged := True;
      Message.LParam := 1;
      AC_WMPaint(TWMPaint(Message));
      Exit;
    end;
    WM_PAINT : if not DlgMode then begin
      AC_WMPaint(TWMPaint(Message));
      Message.Result := 0;
      Exit;
    end;
    WM_PARENTNOTIFY : if (Message.WParam and $FFFF = WM_CREATE) or (Message.WParam and $FFFF = WM_DESTROY) then begin
      inherited;
      if Message.WParamLo = WM_CREATE then AddToAdapter(TWinControl(SkinData.FOwnerControl));
      exit;
    end;
    WM_SETFOCUS, WM_KILLFOCUS : begin
      SendMessage(CtrlHandle, WM_SETREDRAW, 0, 0);
      inherited;
      SendMessage(CtrlHandle, WM_SETREDRAW, 1, 0);
      SkinData.BGChanged := True;
      RedrawWindow(CtrlHandle, nil, 0, RDW_INVALIDATE or RDW_ERASE or RDW_FRAME);
      Exit;
    end;
    WM_SETTEXT : begin
      inherited;
      SkinData.BGChanged := True;
      RedrawWindow(CtrlHandle, nil, 0, RDW_INVALIDATE or RDW_ERASE or RDW_FRAME);
      Exit;
    end;
  end;
  inherited;
end;

procedure TacGroupBoxWnd.PrepareCache;
var
  cRect: TRect;
  bf : hFont;
  BGInfo : TacBGInfo;
  P : TPoint;
begin
  InitCacheBmp(SkinData);
  SkinData.FCacheBmp.Width := WndSize.cx;
  SkinData.FCacheBmp.Height := WndSize.cy;

  if SkinData.FOwnerControl <> nil then SkinData.FCacheBMP.Canvas.Font.Assign(TsHackedControl(SkinData.FOwnerControl).Font) else begin
    bf := LongWord(SendMessage(CtrlHandle, WM_GETFONT, 0, 0));
    if bf <> 0 then SelectObject(SkinData.FCacheBMP.Canvas.Handle, bf);
  end;
  cRect := CaptionRect;

  BGInfo.PleaseDraw := False;
  GetBGInfo(@BGInfo, ParentWnd);
  if BGInfo.BgType = btCache then begin
    P := Point(WndRect.Left, WndRect.Top);
    if not ScreenToClient(ParentWnd, P) then Exit;
    BitBlt(SkinData.FCacheBmp.Canvas.Handle, 0, 0, WndSize.cx, HeightOf(cRect), BGInfo.Bmp.Canvas.Handle, P.X + BGInfo.Offset.X, P.Y + BGInfo.Offset.Y, SRCCOPY)
  end
  else FillDC(SkinData.FCacheBmp.Canvas.Handle, Rect(0, 0, WndSize.cx, cRect.Bottom), BGInfo.Color);

  PaintItem(SkinData, BGInfoToCI(@BGInfo), False, 0, Rect(0, HeightOf(cRect) div 2, WndSize.cx, WndSize.cy), Point(P.x, P.y + HeightOf(cRect) div 2), SkinData.FCacheBMP, True);

  if Caption <> '' then WriteText(cRect);
  SkinData.BGChanged := False;
end;

function TacGroupBoxWnd.CaptionRect: TRect;
const
  Margin = 4;
var
  Size : TSize;
begin
  SelectObject(SkinData.FCacheBMP.Canvas.Handle, LongWord(SendMessage(CtrlHandle, WM_GETFONT, 0, 0)));
  if Caption = '' then Result := Rect(0, 0, 0, 0) else acDrawText(SkinData.FCacheBMP.Canvas.Handle, Caption, Result, DT_CENTER or DT_CALCRECT);
  Size.cx := WidthOf(Result);
  Size.cy := HeightOf(Result);
  if GetWindowLong(CtrlHandle, GWL_EXSTYLE) and WS_EX_RTLREADING = WS_EX_RTLREADING then Result.Left := WndSize.cx - Size.cx - 2 * Margin - 6 else Result.Left := 6;
  Result.Top := 0;
  Result.Bottom := Result.Top + Maxi(4, Size.cy) + 2;
  Result.Right := Result.Left + Size.cx + 2 * Margin;
  if Result.Right > WndSize.cx then Result.Right := WndSize.cx - 1;
end;

procedure TacGroupBoxWnd.WriteText(R: TRect);
var
  BGInfo : TacBGInfo;
  Flags : Cardinal;
begin
  BGInfo.PleaseDraw := False;
  GetBGInfo(@BGInfo, ParentWnd);
  if BGInfo.BgType = btCache
    then BitBlt(SkinData.FCacheBmp.Canvas.Handle, R.Left, R.Top, WidthOf(R), HeightOf(R), BGInfo.Bmp.Canvas.Handle, WndPos.x + R.Left + BGInfo.Offset.X, WndPos.y + R.Top + BGInfo.Offset.y, SRCCOPY)
    else FillDC(SkinData.FCacheBmp.Canvas.Handle, R, BGInfo.Color);

  SkinData.FCacheBMP.Canvas.Brush.Style := bsClear;
  SelectObject(SkinData.FCacheBMP.Canvas.Handle, LongWord(SendMessage(CtrlHandle, WM_GETFONT, 0, 0)));
  Flags := DT_CENTER or DT_SINGLELINE or DT_VCENTER;
  if GetWindowLong(CtrlHandle, GWL_EXSTYLE) and WS_EX_RTLREADING = WS_EX_RTLREADING then Flags := Flags or DT_RTLREADING;
  acWriteTextEx(SkinData.FCacheBMP.Canvas, PacChar(Caption), True, R, Flags, SkinData, False);
end;

constructor TacGroupBoxWnd.Create(AHandle: hwnd; ASkinData: TsCommonData; ASkinManager: TsSkinManager; const SkinSection: string; Repaint: boolean);
begin
  inherited;
  if SkinSection = '' then ASkinData.SkinSection := s_GroupBox;
end;

{ TacCheckBoxWnd }

procedure TacCheckBoxWnd.AC_WMPaint(Message: TWMPaint);
var
  PS : TPaintStruct;
  DC : hdc;
begin
  InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
  BeginPaint(CtrlHandle, ps);

  SkinData.FUpdating := SkinData.Updating;
  if not SkinData.FUpdating then begin
    if not OwnerDraw then begin 
      Style := GetWindowLong(CtrlHandle, GWL_STYLE);
      if IsWindowVisible(CtrlHandle) or (Message.DC <> 0) then begin
        InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
//        SendMessage(ParentWnd, SM_ALPHACMD, MakeWParam(0, AC_GETCACHE), 0);
        if Message.DC = 0 then DC := GetDC(CtrlHandle) else DC := Message.DC;
        PrepareCache;
        BitBlt(DC, 0, 0, SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height, SkinData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
        if Message.DC = 0 then ReleaseDC(CtrlHandle, DC);
      end;
    end;
  end;
  EndPaint(CtrlHandle, ps);
end;

procedure TacCheckBoxWnd.acWndProc(var Message: TMessage);
var
  CI : TCacheInfo;
  DC : hdc;
begin
{$IFDEF LOGGED}
//  AddToLog(Message);
{$ENDIF}
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_MOUSEENTER, AC_MOUSELEAVE : begin
      SkinData.Updating := False;
      SendMessage(CtrlHandle, WM_PAINT, 0, 0);
    end;
  end
  else case Message.Msg of
    WM_NCPAINT : begin
      Exit;
    end;
    WM_ERASEBKGND : begin
      if OwnerDraw then begin
        InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
        CI := GetParentCacheHwnd(CtrlHandle);
        if Message.WParam <> 0 then DC := hdc(Message.WParam) else DC := GetDC(CtrlHandle);
        if CI.Ready then begin
          BitBlt(DC, 0, 0, WndSize.cx, WndSize.cy, CI.Bmp.Canvas.Handle, WndPos.X, WndPos.Y, SRCCOPY);
        end
        else FillDC(DC, Rect(0, 0, WndSize.cx, WndSize.cy), CI.FillColor);
        if hdc(Message.WParam) <> DC then ReleaseDC(CtrlHandle, DC);
      end;
      Exit;
    end;
    WM_PAINT : begin
      AC_WMPaint(TWMPaint(Message));
      Exit;
    end;
    CM_TEXTCHANGED, WM_ENABLE, BM_SETSTATE, BM_SETCHECK : if IsWindowVisible(CtrlHandle) then begin
      SendMessage(CtrlHandle, WM_SETREDRAW, 0, 0);
      inherited;
      SendMessage(CtrlHandle, WM_SETREDRAW, 1, 0);
      SendMessage(CtrlHandle, WM_PAINT, 0, 0);
      Exit;
    end;
  end;
  inherited;
  case Message.Msg of
    WM_KEYUP, WM_KEYDOWN : if (TWMKey(Message).CharCode = VK_SPACE) then begin
      SendMessage(CtrlHandle, WM_PAINT, 0, 0);
    end;
    WM_LBUTTONUP, WM_SETFOCUS, WM_KILLFOCUS : begin
      SendMessage(CtrlHandle, WM_PAINT, 0, 0);
    end;
    WM_NCHITTEST : begin
      if IsWindowEnabled(CtrlHandle) and (DefaultManager.ActiveControl <> CtrlHandle) then DefaultManager.ActiveControl := CtrlHandle;
    end;
  end;
end;

procedure TacCheckBoxWnd.PrepareCache;
var
  bf : hfont;
  R : TRect;
  C : TsColor;
  CI : TCacheInfo;
begin
  InitCacheBmp(SkinData);
  if OwnerDraw then Exit;
  SkinData.FCacheBmp.Width := WndSize.cx;
  SkinData.FCacheBmp.Height := WndSize.cy;
  bf := LongWord(SendMessage(CtrlHandle, WM_GETFONT, 0, 0));
  SelectObject(SkinData.FCacheBmp.Canvas.Handle, bf);

  CI := GetParentCacheHwnd(CtrlHandle);

  PaintItem(SkinData, CI, True, integer(ControlIsActive(SkinData)), Rect(0, 0, WndSize.cx, WndSize.cy), WndPos, SkinData.FCacheBmp, False);
  DrawCheckText;
  DrawSkinGlyph(GlyphMaskIndex(State));
  if not IsWindowEnabled(CtrlHandle) then begin
    if CI.Ready then begin
      R := Rect(0, 0, WndSize.cx, WndSize.cy);
      OffsetRect(R, CI.X + WndPos.x, CI.Y + WndPos.y);
      BlendTransRectangle(SkinData.FCacheBmp, 0, 0, CI.Bmp, R, DefDisabledBlend);
    end
    else begin
      C.C := CI.FillColor;
      BlendTransBitmap(SkinData.FCacheBmp, DefDisabledBlend, C);
    end;
  end;
end;

procedure TacCheckBoxWnd.DrawCheckText;
const
  Margin = 0;
var
  rText: TRect;
  Fmt: integer;
  WordWrap, Focused : boolean;
  t, b, w, h, dx : integer;
begin
  if Caption <> '' then begin
    w := WndSize.cx - (WidthOf(CheckRect) + 2);
    WordWrap := GetWindowLong(CtrlHandle, GWL_STYLE) and BS_MULTILINE = BS_MULTILINE;
    Focused := SendMessage(CtrlHandle, BM_GETSTATE, 0, 0) and BST_FOCUS = BST_FOCUS;

    rText := Rect(0, 0, w, 0);
    Fmt := DT_CALCRECT;
    if WordWrap
      then Fmt := Fmt or DT_WORDBREAK
      else Fmt := Fmt or DT_SINGLELINE;
    if SkinData.FOwnerControl <> nil then SkinData.FCacheBMP.Canvas.Font.Assign(TsHackedControl(SkinData.FOwnerControl).Font);
    AcDrawText(SkinData.FCacheBMP.Canvas.Handle, Caption, rText, Fmt);
    h := HeightOf(rText);
    dx := WidthOf(rText);
    t := Max((WndSize.cy - h) div 2, 0);
    b := WndSize.cy - t;

    Fmt := 0;
    if GetWindowLong(CtrlHandle, GWL_STYLE) and BS_LEFTTEXT <> BS_LEFTTEXT then begin
      rText := Rect(WndSize.cx - w - Margin + 2, t, WndSize.cx - w - Margin + 2 + dx, b);
      if not WordWrap then Fmt := DT_LEFT;
      OffsetRect(rText, -integer(WordWrap), -1);
    end
    else begin
      if GetWindowLong(CtrlHandle, GWL_EXSTYLE) and WS_EX_RTLREADING = WS_EX_RTLREADING then begin
        rText.Right := WndSize.cx - Margin - WidthOf(CheckRect) - 6;
        rText.Left := rText.Right - dx;
        rText.Top := t;
        rText.Bottom := b;
        if not WordWrap then Fmt := DT_RIGHT;
        Fmt := Fmt or DT_RTLREADING;
      end
      else rText := Rect(Margin + 2, t, dx + Margin + 2, b);
    end;
    if WordWrap
      then Fmt := Fmt or DT_WORDBREAK or DT_TOP
      else Fmt := Fmt or DT_SINGLELINE or DT_TOP;

    acWriteTextEx(SkinData.FCacheBmp.Canvas, PacChar(Caption), True, rText, Fmt, SkinData, ControlIsActive(SkinData));

    SkinData.FCacheBmp.Canvas.Pen.Style := psClear;
    SkinData.FCacheBmp.Canvas.Brush.Style := bsSolid;
    if Focused then begin
      InflateRect(rText, 1, 0);
      FocusRect(SkinData.FCacheBmp.Canvas, rText);
    end;
  end;
end;

function TacCheckBoxWnd.CheckRect: TRect;
var
  i : integer;
begin
  i := GlyphMaskIndex(cbChecked);
  if SkinData.SkinManager.IsValidImgIndex(i) then Result := SkinCheckRect(i) else Result := Rect(0, 0, 16, 16);
end;

function TacCheckBoxWnd.CtlState: integer;
begin
  if SendMessage(CtrlHandle, BM_GETSTATE, 0, 0) and BST_PUSHED = BST_PUSHED
    then Result := 2
    else if (SendMessage(CtrlHandle, BM_GETSTATE, 0, 0) and BST_FOCUS = BST_FOCUS) or (DefaultManager.ActiveControl = CtrlHandle)
      then Result := 1
      else Result := 0
end;

function TacCheckBoxWnd.GlyphMaskIndex(State: TCheckBoxState): smallint;
begin
  if (Style and BS_RADIOBUTTON <> BS_RADIOBUTTON) and (Style and BS_AUTORADIOBUTTON <> BS_AUTORADIOBUTTON) or (Style and BS_AUTOCHECKBOX = BS_AUTOCHECKBOX) or (Style and BS_CHECKBOX = BS_CHECKBOX) or (Style and BS_3STATE = BS_3STATE) then begin
    case State of
      cbChecked : Result := SkinData.SkinManager.GetMaskIndex(SkinData.SkinManager.ConstData.IndexGLobalInfo, s_GLobalInfo, s_CheckBoxChecked);
      cbUnchecked : Result := SkinData.SkinManager.GetMaskIndex(SkinData.SkinManager.ConstData.IndexGLobalInfo, s_GLobalInfo, s_CheckBoxUnChecked)
      else Result := SkinData.SkinManager.GetMaskIndex(SkinData.SkinManager.ConstData.IndexGLobalInfo, s_GLobalInfo, s_CheckBoxGrayed);
    end;
  end
  else begin
    case State of
      cbChecked : Result := SkinData.SkinManager.GetMaskIndex(SkinData.SkinManager.ConstData.IndexGLobalInfo, s_GLobalInfo, s_RadioButtonChecked);
      cbUnchecked : Result := SkinData.SkinManager.GetMaskIndex(SkinData.SkinManager.ConstData.IndexGLobalInfo, s_GLobalInfo, s_RadioButtonUnChecked)
      else Result := SkinData.SkinManager.GetMaskIndex(SkinData.SkinManager.ConstData.IndexGLobalInfo, s_GLobalInfo, s_CheckBoxGrayed);
    end;
  end;
end;

function TacCheckBoxWnd.SkinCheckRect(i: integer): TRect;
var
  h, w, hdiv : integer;
begin
  Result := Rect(0, 0, 0, 0);
  if i > -1 then begin
    h := SkinGlyphHeight(i);
    w := SkinGlyphWidth(i);
    hdiv := (WndSize.cy - h) div 2;
    if GetWindowLong(CtrlHandle, GWL_STYLE) and BS_LEFTTEXT <> BS_LEFTTEXT
      then Result := Rect(0, hdiv, w, h + hdiv)
      else Result := Rect(WndSize.cx - w, hdiv, WndSize.cx, h + hdiv)
  end;
end;

function TacCheckBoxWnd.SkinGlyphHeight(i: integer): integer;
begin
  with SkinData.SkinManager do if Assigned(ma[i].Bmp) then Result := ma[i].Bmp.Height div 2 else Result := HeightOf(ma[i].R) div (ma[i].MaskType + 1);
end;

function TacCheckBoxWnd.SkinGlyphWidth(i: integer): integer;
begin
  with SkinData.SkinManager do begin
    if ma[i].ImageCount = 0 then ma[i].ImageCount := 1;
    if Assigned(ma[i].Bmp) then Result := ma[i].Bmp.Width div 3 else Result := WidthOf(ma[i].R) div ma[i].ImageCount;
  end;
end;

procedure TacCheckBoxWnd.DrawSkinGlyph(i: integer);
var
  R : TRect;
begin
  if (SkinData.FCacheBmp.Width < 1) or (i < 0) then exit;
  R := SkinCheckRect(i);
  sAlphaGraph.DrawSkinGlyph(SkinData.FCacheBmp, R.TopLeft, CtlState, 1, SkinData.SkinManager.ma[i], MakeCacheInfo(SkinData.FCacheBmp))
end;

function TacCheckBoxWnd.State: TCheckBoxState;
begin
  if SendMessage(CtrlHandle, BM_GETSTATE, 0, 0) and BST_INDETERMINATE = BST_INDETERMINATE
    then Result := cbGrayed
    else if SendMessage(CtrlHandle, BM_GETSTATE, 0, 0) and BST_CHECKED = BST_CHECKED
      then Result := cbChecked
      else Result := cbUnChecked
end;

constructor TacCheckBoxWnd.Create(AHandle: hwnd; ASkinData: TsCommonData; ASkinManager: TsSkinManager; const SkinSection: string; Repaint: boolean);
var
  Style : Cardinal;
begin
  inherited;
  Style := GetWindowLong(CtrlHandle, GWL_STYLE) and SS_TYPEMASK;
  OwnerDraw := Style and SS_SIMPLE = SS_SIMPLE;
  if SkinSection = '' then ASkinData.SkinSection := s_CheckBox;
end;

{ TacLinkWnd }

procedure TacLinkWnd.acWndProc(var Message: TMessage);
var
  ps : TPaintStruct;
begin
  if (GetWindowLong(CtrlHandle, GWL_EXSTYLE) and WS_EX_STATICEDGE <> WS_EX_STATICEDGE) then case Message.Msg of
    WM_UPDATEUISTATE : if IsWindowVisible(CtrlHandle) then begin
      Inherited;
      exit
    end;
    WM_NCPAINT : Exit;//Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
    WM_ERASEBKGND : if IsWindowVisible(CtrlHandle) then begin
      AC_WMPaint(TWMPaint(Message));
      Message.Result := 1;
      Exit;
    end;
    WM_PAINT : begin
      BeginPaint(CtrlHandle, ps);
      EndPaint(CtrlHandle, ps);
      Exit;
    end;
    WM_ENABLE,
    WM_CANCELMODE : begin
      Inherited;
      exit
    end;
    WM_MOVE : begin
      SkinData.BGChanged := True;
      Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
      RedrawWindow(CtrlHandle, nil, 0, RDW_ERASE or RDW_UPDATENOW or RDW_INVALIDATE);
      Exit;
    end;
    WM_SETTEXT : begin
      Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
      Caption := GetWndText(CtrlHandle);
      SkinData.BGChanged := True;
      RedrawWindow(CtrlHandle, nil, 0, RDW_INVALIDATE or RDW_ERASE or RDW_UPDATENOW);
      Exit;
    end;
{  end
  else begin
    Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
    Exit;}
  end;
  inherited;
end;

function TacLinkWnd.PaintText : boolean;
var
  rText : TRect;
  Flags : Cardinal;
  f : hFont;
  s : acString;
  function GetMsgFont : hFont;
  var
    NonClientMetrics: TNonClientMetricsW;
  begin
    NonClientMetrics.cbSize := SizeOf(NonClientMetrics);
    if SystemParametersInfoW(SPI_GETNONCLIENTMETRICS, 0, @NonClientMetrics, 0)
      then Result := CreateFontIndirectW(NonClientMetrics.lfMessageFont)
      else Result := 0;
  end;
begin
  Result := True;
  SkinData.FCacheBmp.Canvas.Brush.Style := bsClear;
  rText := Rect(0, 0, WndSize.cx + 4, WndSize.cy);
  f := GetMsgFont;
  SkinData.FCacheBmp.Canvas.Font.Handle := f;
  SkinData.FCacheBmp.Canvas.Font.Style := SkinData.FCacheBmp.Canvas.Font.Style + [fsUnderline];

  Flags := DT_LEFT or DT_TOP or DT_EXPANDTABS or DT_WORDBREAK or DT_NOCLIP;
  s := Caption;
{.$IFNDEF TNTUNICODE}
  s := ReplaceStr(s, '<A>', '');
  s := ReplaceStr(s, '</A>', '');
{.$ENDIF}
  SkinData.FCacheBmp.Canvas.Brush.Style := bsClear;
  acWriteTextEx(SkinData.FCacheBmp.Canvas, PacChar(s), True, rText, Flags, SkinData, False);

{  if GetFocus = CtrlHandle then begin
//    InflateRect(rText, -1, -1);
    SkinData.FCacheBmp.Canvas.Pen.Color := clWindowFrame;
    SkinData.FCacheBmp.Canvas.Brush.Color := clBtnFace;
    DrawFocusRect(SkinData.FCacheBmp.Canvas.Handle, rText);
  end;}
end;

{ TacImageWnd }

constructor TacIconWnd.Create(AHandle: hwnd; ASkinData: TsCommonData; ASkinManager: TsSkinManager; const SkinSection: string; Repaint: boolean);
begin
  IsBmp := (GetWindowLong(AHandle, GWL_STYLE) and SS_TYPEMASK) and SS_ICON <> SS_ICON;
  FBmp := nil;
  inherited;
end;

destructor TacIconWnd.Destroy;
begin
  if FBmp <> nil then FreeAndNil(FBmp);
  inherited;
end;

function TacIconWnd.PaintText : boolean;
var
  hi : hIcon;
begin
  if not IsBmp then begin // Icon
    hi := hIcon(SendMessage(CtrlHandle, STM_GETICON, 0, 0));
    if hi <> 0 then begin
      DrawIconEx(SkinData.FCacheBmp.Canvas.Handle, 0, 0, hi, 0, 0, 0, 0, DI_NORMAL);
      Result := True;
    end
    else Result := False;
  end
  else begin
    if FBmp = nil then begin
      FBmp := TBitmap.Create;
      FBmp.Handle := hBitmap(SendMessage(CtrlHandle, STM_GETIMAGE, IMAGE_BITMAP, 0));
    end;
    if not FBmp.Empty then begin
      BitBlt(SkinData.FCacheBmp.Canvas.Handle, 0, 0, min(WndSize.cx, FBmp.Width), min(WndSize.cy, FBmp.Height), FBmp.Canvas.Handle, 0, 0, SRCCOPY);
      Result := True;
    end
    else Result := False;
  end
end;

{ TacTabWnd }

procedure TacTabWnd.AC_WMPaint(Message: TWMPaint);
var
  PS : TPaintStruct;
  DC : hdc;
begin
//  InvalidateRect(CtrlHandle, nil, True); // Background update (for repaint of graphic controls and for tansheets refreshing)
  BeginPaint(CtrlHandle, ps);
  if IsWindowVisible(CtrlHandle) then begin
    DC := GetDC(CtrlHandle);
    PrepareCache;
    ReleaseDC(CtrlHandle, DC);
  end;
  EndPaint(CtrlHandle, ps);
end;

procedure TacTabWnd.acWndProc(var Message: TMessage);
var
  cRect : TRect;
begin
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_GETCACHE : begin
      inherited;
      GetClientRect(CtrlHandle, cRect);
      Exit;
    end;
  end;
  case Message.Msg of
    WM_ERASEBKGND : Exit;
    WM_NCPAINT : if DlgMode then begin
      InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
      AC_WMNCPaint(TWMPaint(Message));
      Exit;
    end;
    WM_PRINT, WM_PAINT : begin
      AC_WMPaint(TWMPaint(Message));
      Message.Result := 0;
      Exit;
    end;
  end;
  inherited;
end;

procedure TacTabWnd.PrepareCache;
begin
  SkinData.FCacheBmp.Width := WndSize.cx;
  SkinData.FCacheBmp.Height := WndSize.cy;
end;

procedure TacTabWnd.AC_WMNCPaint(Message: TWMPaint);
var
  DC : hdc;
  cRect : TRect;
begin
  SkinData.Updating := SkinData.Updating;
  if not SkinData.Updating then begin
    DC := GetWindowDC(CtrlHandle);
    PrepareCache;
    cRect := DisplayRect;
    BitBlt(DC, 0, 0, WndSize.cx, cRect.Top, SkinData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY); 
    BitBlt(DC, 0, cRect.Top, cRect.Left, WndSize.cy, SkinData.FCacheBmp.Canvas.Handle, 0, cRect.Top, SRCCOPY); 
    ReleaseDC(CtrlHandle, DC);
  end;
end;

function TacTabWnd.DisplayRect: TRect;
begin
  GetClientRect(CtrlHandle, Result);
  SendMessage(CtrlHandle, TCM_ADJUSTRECT, 0, Integer(@Result));
  Inc(Result.Top, 2);
end;

{ TacSpinWnd }

procedure TacSpinWnd.AC_WMPaint(Message: TWMPaint);
var
  PS : TPaintStruct;
  DC : hdc;
begin
  InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);

  if IsVertical then begin
    if not PtInRect(WndRect, acMousePos) then begin
      Btn1State := 0;
      Btn2State := 0;
    end
    else begin
      if PtInRect(Rect(WndRect.Left, WndRect.Top, WndRect.Right, WndRect.Bottom - WndSize.cy div 2), acMousePos) then begin
        Btn1State := 1 + integer(bMousePressed);
        Btn2State := 0;
      end
      else begin
        Btn1State := 0;
        Btn2State := 1 + integer(bMousePressed);
      end;
    end;

    BeginPaint(CtrlHandle, ps);

    SkinData.Updating := SkinData.Updating;
    if not SkinData.Updating then begin
      if Message.DC = 0 then DC := GetDC(CtrlHandle) else DC := Message.DC;
      SkinData.BGChanged := True;
      PrepareCache;
      BitBlt(DC, lOffset, 0, SkinData.FCacheBmp.Width - lOffset, SkinData.FCacheBmp.Height, SkinData.FCacheBmp.Canvas.Handle, lOffset, 0, SRCCOPY);
      if Message.DC <> 0 then ReleaseDC(CtrlHandle, DC);
    end;
    EndPaint(CtrlHandle, ps);
  end
  else begin
    if not PtInRect(WndRect, acMousePos) then begin
      Btn1State := 0;
      Btn2State := 0;
    end
    else begin
      if PtInRect(Rect(WndRect.Left, WndRect.Top, WndRect.Right - WndSize.cx div 2, WndRect.Bottom), acMousePos) then begin
        Btn1State := 1 + integer(bMousePressed);
        Btn2State := 0;
      end
      else begin
        Btn1State := 0;
        Btn2State := 1 + integer(bMousePressed);
      end;
    end;

    BeginPaint(CtrlHandle, ps);

    SkinData.FUpdating := SkinData.Updating;
    if not SkinData.FUpdating then begin
      if Message.DC = 0 then DC := GetDC(CtrlHandle) else DC := Message.DC;
      SkinData.BGChanged := True;
      PrepareCache;
      BitBlt(DC, 0, 0, SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height, SkinData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
      if Message.DC <> 0 then ReleaseDC(CtrlHandle, DC);
    end;
    EndPaint(CtrlHandle, ps);
  end;
end;

procedure TacSpinWnd.acWndProc(var Message: TMessage);
begin
{$IFDEF LOGGED}
  AddToLog(Message);
{$ENDIF}
  case Message.Msg of
    WM_NCPAINT, WM_ERASEBKGND : begin
      Message.Result := 0;
      Exit;
    end;
    WM_PAINT : begin
      AC_WMPaint(TWMPaint(Message));
      Message.Result := 0;
      Exit;
    end;
    WM_LBUTTONDOWN : bMousePressed := True;
    WM_LBUTTONUP : bMousePressed := False;
    WM_MOUSELEAVE : InvalidateRect(CtrlHandle, nil, False);
  end;
  inherited;
  case Message.Msg of
    WM_LBUTTONDOWN, WM_LBUTTONUP : RedrawWindow(CtrlHandle, nil, 0, RDW_INVALIDATE or RDW_FRAME or RDW_UPDATENOW);
    WM_MOUSEMOVE : begin
      if (DefaultManager <> nil) and not (csDesigning in DefaultManager.ComponentState) and IsWindowEnabled(CtrlHandle) then begin
        if PtInRect(WndRect, acMousePos) then begin
          if DefaultManager.ActiveControl <> CtrlHandle
            then DefaultManager.ActiveControl := CtrlHandle
            else RedrawWindow(CtrlHandle, nil, 0, RDW_INVALIDATE or RDW_FRAME or RDW_UPDATENOW);
        end
        else begin
          if DefaultManager.ActiveControl = CtrlHandle then DefaultManager.ActiveControl := 0;
        end;
      end;
    end;
  end;
end;

procedure TacSpinWnd.PrepareCache;
var
  Btn1Rect, Btn2Rect : TRect;
  p : TPoint;
  ParentBG : TacBGInfo;
  CI : TCacheInfo;
begin
  if SkinData.SkinManager.GetSkinIndex(SkinData.SkinSection) < 0 then SkinData.SkinSection := s_Button;
  ParentBG.Offset := Point(0, 0);
  if IsVertical then begin
    Btn1Rect := Rect(lOffset, 0, WndSize.cx, WndSize.cy div 2 + WndSize.cy mod 2);
    Btn2Rect := Rect(lOffset, WndSize.cy div 2, WndSize.cx, WndSize.cy);

    ParentBG.PleaseDraw := False;
    GetBGInfo(@ParentBG, ParentWnd);
    CI := BGInfoToCI(@ParentBG);
    InitCacheBmp(SkinData);
    SkinData.FCacheBMP.Width := WndSize.cx;
    SkinData.FCacheBMP.Height := WndSize.cy;

    PaintItem(SkinData, CI, True, Btn1State, Btn1Rect, Point(WndPos.X + Btn1Rect.Left, WndPos.Y + Btn1Rect.Top), SkinData.FCacheBMP, False);
    if DefaultManager.ConstData.MaskArrowTop > -1 then begin
      p.x := Btn1Rect.Left + (WidthOf(Btn1Rect) - WidthOf(DefaultManager.ma[DefaultManager.ConstData.MaskArrowTop].R) div DefaultManager.ma[DefaultManager.ConstData.MaskArrowTop].ImageCount) div 2;
      p.y := Btn1Rect.Top + (HeightOf(Btn1Rect) - HeightOf(DefaultManager.ma[DefaultManager.ConstData.MaskArrowTop].R) div (1 + DefaultManager.ma[DefaultManager.ConstData.MaskArrowTop].MaskType)) div 2;
      DrawSkinGlyph(SkinData.FCacheBMP, p, Btn1State, 1, DefaultManager.ma[DefaultManager.ConstData.MaskArrowTop], MakeCacheInfo(SkinData.FCacheBmp));
    end;

    PaintItem(SkinData, CI, True, Btn2State, Btn2Rect, Point(WndPos.Y + Btn2Rect.Left, WndPos.Y + Btn2Rect.Top), SkinData.FCacheBMP, False);
    if DefaultManager.ConstData.MaskArrowBottom > -1 then begin
      p.x := Btn2Rect.Left + (WidthOf(Btn2Rect) - WidthOf(DefaultManager.ma[DefaultManager.ConstData.MaskArrowBottom].R) div DefaultManager.ma[DefaultManager.ConstData.MaskArrowBottom].ImageCount) div 2;
      p.y := Btn2Rect.Top + (HeightOf(Btn2Rect) - HeightOf(DefaultManager.ma[DefaultManager.ConstData.MaskArrowBottom].R) div (1 + DefaultManager.ma[DefaultManager.ConstData.MaskArrowBottom].MaskType)) div 2;
      DrawSkinGlyph(SkinData.FCacheBMP, p, Btn2State, 1, DefaultManager.ma[DefaultManager.ConstData.MaskArrowBottom], MakeCacheInfo(SkinData.FCacheBmp));
    end;
  end
  else begin
    Btn1Rect := Rect(0, 0, WndSize.cx div 2 + WndSize.cx mod 2, WndSize.cy);
    Btn2Rect := Rect(WndSize.cx div 2, 0, WndSize.cx, WndSize.cy);

    ParentBG.PleaseDraw := False;
    GetBGInfo(@ParentBG, ParentWnd);
    CI := BGInfoToCI(@ParentBG);
    InitCacheBmp(SkinData);
    SkinData.FCacheBMP.Width := WndSize.cx;
    SkinData.FCacheBMP.Height := WndSize.cy;

    PaintItem(SkinData, CI, True, Btn1State, Btn1Rect, Point(WndPos.X + Btn1Rect.Left, WndPos.Y + Btn1Rect.Top), SkinData.FCacheBMP, False);
    if DefaultManager.ConstData.MaskArrowLeft > -1 then begin
      p.x := Btn1Rect.Left + (WidthOf(Btn1Rect) - WidthOf(DefaultManager.ma[DefaultManager.ConstData.MaskArrowLeft].R) div DefaultManager.ma[DefaultManager.ConstData.MaskArrowLeft].ImageCount) div 2;
      p.y := Btn1Rect.Top + (HeightOf(Btn1Rect) - HeightOf(DefaultManager.ma[DefaultManager.ConstData.MaskArrowLeft].R) div (1 + DefaultManager.ma[DefaultManager.ConstData.MaskArrowLeft].MaskType)) div 2;
      DrawSkinGlyph(SkinData.FCacheBMP, p, Btn1State, 1, DefaultManager.ma[DefaultManager.ConstData.MaskArrowLeft], MakeCacheInfo(SkinData.FCacheBmp));
    end;

    PaintItem(SkinData, CI, True, Btn2State, Btn2Rect, Point(WndPos.X + Btn2Rect.Left, WndPos.Y + Btn2Rect.Top), SkinData.FCacheBMP, False);
    if DefaultManager.ConstData.MaskArrowRight > -1 then begin
      p.x := Btn2Rect.Left + (WidthOf(Btn2Rect) - WidthOf(DefaultManager.ma[DefaultManager.ConstData.MaskArrowRight].R) div DefaultManager.ma[DefaultManager.ConstData.MaskArrowRight].ImageCount) div 2;
      p.y := Btn2Rect.Top + (HeightOf(Btn2Rect) - HeightOf(DefaultManager.ma[DefaultManager.ConstData.MaskArrowRight].R) div (1 + DefaultManager.ma[DefaultManager.ConstData.MaskArrowRight].MaskType)) div 2;
      DrawSkinGlyph(SkinData.FCacheBMP, p, Btn2State, 1, DefaultManager.ma[DefaultManager.ConstData.MaskArrowRight], MakeCacheInfo(SkinData.FCacheBmp));
    end;
  end;
end;

constructor TacSpinWnd.Create(AHandle: hwnd; ASkinData: TsCommonData; ASkinManager: TsSkinManager; const SkinSection: string; Repaint: boolean);
begin
  inherited;
  lOffset := 0;
  bMousePressed := False;
  Btn1State := 0;
  Btn2State := 0;
end;

function TacSpinWnd.IsVertical: boolean;
begin
  Result := GetWindowLong(CtrlHandle, GWL_STYLE) and UDS_HORZ <> UDS_HORZ;
end;

{ TacBitBtnWnd }

function TacBitBtnWnd.CaptionRect: TRect;
var
  GlyphPos: TPoint;
  gSize, cSize : TSize;
begin
  gSize := GlyphSize;
  cSize := TextRectSize;
  if SkinData.FOwnerControl <> nil then begin
    CalcButtonLayout(Rect(0, 0, WndSize.cx, WndSize.cy), Point(gSize.cx, gSize.cy), cSize,
        TBitBtn(SkinData.FOwnerControl).Layout, taCenter, 0, 0, GlyphPos, Result, DT_CENTER);
    OffsetRect(Result, integer(CurrentState = 2), integer(CurrentState = 2));
  end
  else begin
    Result := inherited CaptionRect;
    if gSize.cx <> 0 then OffsetRect(Result, gSize.cx div 2 + 1, 0);
  end;
end;

procedure TacBitBtnWnd.DrawGlyph;
var
  TmpPng : TPNGGraphic;
  gR : TRect;
begin
  if SkinData.FOwnerControl <> nil then with TBitBtn(SkinData.FOwnerControl) do begin
    gR := GlyphRect;
    if Glyph.PixelFormat = pfDevice then Glyph.HandleType := bmDIB;
    if (NumGlyphs = 1) and (Glyph.PixelFormat = pf32bit) then begin // Patch if Png, don't work in std. mode
      TmpPng := TPNGGraphic.Create;
      TmpPng.PixelFormat := pf32bit;
      TmpPng.Width := Glyph.Width;
      TmpPng.Height := Glyph.Height;
      BitBlt(TmpPng.Canvas.Handle, 0, 0, Glyph.Width, Glyph.Height, Glyph.Canvas.Handle, 0, 0, SRCCOPY);
      SkinData.FCacheBmp.Canvas.Draw(gR.Left, gR.Top, TmpPng);
      FreeAndNil(TmpPng);
    end
    else DrawGlyphEx(Glyph, SkinData.FCacheBmp, gR, NumGlyphs, Enabled, DefDisabledGlyphKind, CurrentState, 0, Down, False);
  end
end;

function TacBitBtnWnd.GlyphRect: TRect;
var
  Size, sText : TSize;
  rText : TRect;
  x, y, sp : integer;
  dh, dw : integer;
begin
  Size := GlyphSize;
  if SkinData.FOwnerControl <> nil then begin
    x := 0;
    y := 0;
    Result := Rect(0, 0, 0, 0);
    sText := TextRectSize;
    sp := TBitBtn(SkinData.FOwnerControl).Spacing * integer((Size.cx > 0) and (Caption <> ''));
    dw := (WndSize.cx - Size.cx - sText.cx - Sp) div 2;
    dh := (WndSize.cy - Size.cy - sText.cy - Sp) div 2;
    case TBitBtn(SkinData.FOwnerControl).Layout of
      blGlyphLeft : begin
        x := dw;
        y := (WndSize.cy - Size.cy) div 2;
      end;
      blGlyphRight : begin
        x := (WndSize.cx - Size.cx + Sp + sText.cx) div 2;
        y := (WndSize.cy - Size.cy) div 2;
      end;
      blGlyphTop : begin
        x := (WndSize.cx - Size.cx) div 2 + 1;
        y := dh;
      end;
      blGlyphBottom : begin
        x := (WndSize.cx - Size.cx) div 2 + 1;
        y := WndSize.cy - dh - Size.cy;
      end;
    end;
    inc(x, integer(CurrentState = 2));
    inc(y, integer(CurrentState = 2));
    Result := Rect(x, y, x + Size.cx, y + Size.cy);
  end
  else begin
    if Size.cx = 0 then Result := Rect(0, 0, 0, 0) else begin
      rText := CaptionRect;
      Result.Right := rText.Left - 2;
      Result.Left := Result.Right - Size.cx;
      Result.Top := (WndSize.cy - Size.cy) div 2 + integer(Down);
      Result.Bottom := Result.Top + Size.cy;
    end;
  end;
end;

function TacBitBtnWnd.GlyphSize: TSize;
var
  hBmp : hBitmap;
begin
  if SkinData.FOwnerControl <> nil then begin
    if TBitBtn(SkinData.FOwnerControl).Glyph <> nil then begin
      Result.cx := TBitBtn(SkinData.FOwnerControl).Glyph.Width div TBitBtn(SkinData.FOwnerControl).NumGlyphs;
      Result.cy := TBitBtn(SkinData.FOwnerControl).Glyph.Height;
    end
    else Result.cx := 0;
  end
  else begin
    hBmp := SendMessage(CtrlHandle, BM_GETIMAGE, IMAGE_BITMAP, 0);
    if hBmp = 0 then Result.cx := 0 else begin
      GetBitmapDimensionEx(hBmp, Result);
    end;
  end;
end;

function TacBitBtnWnd.MaxCaptionWidth: integer;
begin
  if SkinData.FOwnerControl <> nil then begin
    with SkinData.FOwnerControl as TBitBtn do begin
      if (Caption <> '') then begin
        Result := Width - 2 * Margin;
        case Layout of
          blGlyphLeft, blGlyphRight : Result := Result - (Spacing + GlyphSize.cx) * integer(GlyphSize.cy <> 0);
        end;
      end
      else Result := 0
    end
  end
  else Result := inherited MaxCaptionWidth;
end;

{$IFDEF D2009}
{ TacButtonWnd }

constructor TacButtonWnd.Create(AHandle : hwnd; ASkinData : TsCommonData; ASkinManager : TsSkinManager; const SkinSection : string; Repaint : boolean = True);
begin
  if (ASkinData <> nil) and (ASkinData.FOwnerControl <> nil) then Btn := TButton(ASkinData.FOwnerControl);
  inherited;
end;

function TacButtonWnd.HaveImage : boolean;
begin
  if Btn <> nil then with Btn do begin
    Result := (Images <> nil) and (ImageIndex >= 0) and (ImageIndex < Images.Count);
  end
  else Result := False;
end;

function TacButtonWnd.CaptionRect: TRect;
const
  wBorder = 3;
var
  l, t, r, b : integer;
  Size : TSize;
begin
  l := 0;
  t := 0;
  r := 0;
  b := 0;
  if Btn <> nil then SkinData.FCacheBMP.Canvas.Font := Btn.Font;
  Size := TextRectSize;
  with Btn do begin
    if HaveImage and (Btn.ImageAlignment <> iaCenter) then begin
      case ImageAlignment of
        iaLeft: begin
          l := ImageMargins.Left + wBorder + Images.Width;
          l := l + (Width - l - Size.cx) div 2;
          r := l + Size.cx;
          t := (Height - Size.cy) div 2;
          b := Height - t;
        end;
        iaRight: begin
          r := ImageMargins.Right + wBorder + Images.Width;
          l := (Width - r - Size.cx) div 2;
          r := l + Size.cx;
          t := (Height - Size.cy) div 2;
          b := Height - t;
        end;
        iaTop: begin
          t := ImageMargins.Top + wBorder + Images.Height;
          t := t + (Height - t - Size.cy) div 2;
          b := t + Size.cy;
          l := (Width - Size.cx) div 2;
          r := Width - l;
        end;
        iaBottom: begin
          b := ImageMargins.Bottom + wBorder + Images.Height;
          t := (Height - b - Size.cy) div 2;
          b := t + Size.cy;
          l := (Width - Size.cx) div 2;
          r := Width - l;
        end;
      end;
    end
    else begin
      l := (Width - Size.cx) div 2;
      r := Width - l;
      t := (Height - Size.cy) div 2;
      b := Height - t;
    end;
  end;
  Result := Rect(l - 1, t, r + 2, b);
  if CurrentState = 2 then OffsetRect(Result, 1, 1);
end;

procedure TacButtonWnd.DrawGlyph;
var
  R : TRect;
begin
  if not HaveImage then inherited else begin
    R := GlyphRect;
    if Btn.Images is TsAlphaImageList then begin
      DrawAlphaImgList(Btn.Images, SkinData.FCacheBmp, R.Left, R.Top, GlyphIndex, 0, clNone, 0, 1, False)
    end
    else Btn.Images.Draw(SkinData.FCacheBmp.Canvas, R.Left, R.Top, GlyphIndex);
  end;
end;

function TacButtonWnd.GlyphIndex: integer;
var
  State : integer;
begin
  if not Btn.Enabled then State := 4 else if CurrentState = 2 then State := 2 else if Btn.Focused then State := 3 else State := CurrentState;
  with Btn do case State of
    0 : Result := ImageIndex;
    1 : if (HotImageIndex > -1) and (HotImageIndex < Images.Count) then Result := HotImageIndex else Result := ImageIndex;
    2 : if (PressedImageIndex > -1) and (PressedImageIndex < Images.Count) then Result := PressedImageIndex else Result := ImageIndex;
    3 : if (SelectedImageIndex > -1) and (SelectedImageIndex < Images.Count) then Result := SelectedImageIndex else Result := ImageIndex;
    4 : if (DisabledImageIndex > -1) and (DisabledImageIndex < Images.Count) then Result := DisabledImageIndex else Result := ImageIndex
    else Result := -1;
  end;
end;

function TacButtonWnd.GlyphRect: TRect;
const
  wBorder = 3;
var
  l, t, r, b : integer;
begin
  l := 0;
  t := 0;
  r := 0;
  b := 0;
  if HaveImage then with Btn do begin
    case ImageAlignment of
      iaLeft: begin
        l := ImageMargins.Left + wBorder;
        r := l + Images.Width;
        t := (Height - Images.Height) div 2;
        b := t + Images.Height;
      end;
      iaRight: begin
        r := Width - ImageMargins.Right - wBorder;
        l := r - Images.Width;
        t := (Height - Images.Height) div 2;
        b := t + Images.Height;
      end;
      iaTop: begin
        t := ImageMargins.Bottom + wBorder;
        b := t + Images.Height;
        l := (Width - Images.Width) div 2;
        r := l + Images.Width;
      end;
      iaBottom: begin
        b := Height - ImageMargins.Bottom - wBorder;
        t := b - Images.Height;
        l := (Width - Images.Width) div 2;
        r := l + Images.Width;
      end;
      iaCenter: begin
        t := (Height - Images.Height) div 2;
        b := t + Images.Height;
        l := (Width - Images.Width) div 2;
        r := l + Images.Width;
      end;
    end;
    Result := Rect(l, t, r, b);
    if CurrentState = 2 then OffsetRect(Result, 1, 1);
  end
  else Result := Rect(0, 0, 0, 0);
end;

function TacButtonWnd.GlyphSize: TSize;
begin
  if HaveImage then begin
    Result.cx := Btn.Images.Width;
    Result.cy := Btn.Images.Height;
  end
  else begin
    Result.cx := 0;
    Result.cy := 0;
  end;
end;
{$ENDIF}

{$IFNDEF NOMNUHOOK}

{ TacMnuWnd }

procedure TacMnuWnd.acWndProc(var Message: TMessage);
var
  DC : hdc;
  mi : TacMenuInfo;
  i : integer;
begin
{$IFDEF LOGGED}
//  AddToLog(Message);
{$ENDIF}
  case Message.Msg of
    WM_TIMER : begin
      Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
    end;
    WM_DESTROY{7.07}, WM_NCDESTROY: begin
      if (OldProc <> nil) or Assigned(OldWndProc) then begin
        Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
        UninitializeACWnd(CtrlHandle, False, False, TacMainWnd(Self));

        Destroyed := True; // Mark as destroyed
        RgnChanged := 0;
        ClearCache;

        DC := 0;
        for i := 0 to Length(MnuArray) - 1 do if (MnuArray[i] <> nil) and not MnuArray[i].Destroyed then begin
          DC := 1;
          RedrawWindow(MnuArray[i].CtrlHandle, nil, 0, RDW_FRAME or RDW_INVALIDATE or RDW_UPDATENOW); // Update frames of visible menus
        end;
        if DC = 0 then ClearMnuArray; // Clear all if no visible menus
        acCanHookMenu := False;
      end
      else Message.Result := SendMessage(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
      Exit;
    end;
  end;
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_UPDATING : Message.LParam := RgnChanged;
    AC_GETAPPLICATION : begin Message.Result := longint(Application); Exit end;
    AC_CTRLHANDLED : begin Message.Result := 1; Exit; end;
    AC_DROPPEDDOWN : if IsWindowVisible(CtrlHandle) then RgnChanged := 1;
  end
  else if acCanHookMenu then case Message.Msg of
    WM_ERASEBKGND : begin
      PrepareCache;
      if Message.WParam <> 0 then DC := hdc(Message.WParam) else DC := GetDC(CtrlHandle);
      BitBlt(DC, 0, 0, SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height, SkinData.FCacheBmp.Canvas.Handle, 3, 3, SRCCOPY);
      if DC <> hdc(Message.WParam) then ReleaseDC(CtrlHandle, DC);
      RgnChanged := 0;
    end;
    WM_NCPAINT : begin
{$IFDEF LOGGED}
//  LogLines.Add('TacMnuWnd.acWndProc');
{$ENDIF}
      if not IsNT then inherited else begin
        mi.Bmp := nil;
        mi := SkinData.SkinManager.SkinableMenus.GetMenuInfo(nil, 0, 0, CtrlHandle);
        DC := GetWindowDC(CtrlHandle);
//(Win32MajorVersion >= 6)
        if (mi.Bmp <> nil) and (mi.Bmp.Width + 6 = WndSize.cx) and (mi.Bmp.Height = WndSize.cy) // If cache image is exists already
          then BitBltBorder(DC, 0, 0, mi.Bmp.Width, mi.Bmp.Height, mi.Bmp.Canvas.Handle, 0, 0, 3)
          else begin
            PrepareCache;
            BitBltBorder(DC, 0, 0, SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height, SkinData.FCacheBmp.Canvas.Handle, 0, 0, 3);
          end;
        ReleaseDC(CtrlHandle, DC);
      end
    end
    else inherited;
  end else inherited;
end;

constructor TacMnuWnd.Create(AHandle: hwnd; ASkinData: TsCommonData; ASkinManager: TsSkinManager; const SkinSection: string; Repaint: boolean);
begin
  inherited;
  RgnChanged := 0;
end;

procedure TacMnuWnd.PrepareCache;
begin
  InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
  if not SkinData.BGChanged then Exit;
  InitCacheBmp(SkinData);

  SkinData.FCacheBMP.Width := WndSize.cx;
  SkinData.FCacheBMP.Height := WndSize.cy;

  PaintItem(SkinData, EmptyCI, True, 0, Rect(0, 0, WndSize.cx, WndSize.cy), Point(WndRect.Left - ParentRect.Left, WndRect.Top - ParentRect.Top),
    SkinData.FCacheBMP, False, 0, 0);

  UpdateWndCorners(SkinData, 0, Self);
  SkinData.BGChanged := False;
end;
{$ENDIF}

{ TacWWComboBoxWnd }

procedure TacWWComboBoxWnd.acWndProc(var Message: TMessage);
var
  i : integer;
begin
{$IFDEF LOGGED}
//  AddToLog(Message);
{$ENDIF}
  case Message.Msg of
    WM_CTLCOLORLISTBOX : begin
      Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
      Exit;
    end;
  end;
  inherited;
  case Message.Msg of
    WM_PARENTNOTIFY : if (Message.WParam and $FFFF = WM_CREATE) and (SkinData.FOwnerControl <> nil) then begin
      for i := 0 to TWinControl(SkinData.FOwnerControl).ControlCount - 1 do begin
        if TWinControl(SkinData.FOwnerControl).Controls[i] is TCustomListBox then begin
          ListBox := TCustomListBox(TWinControl(SkinData.FOwnerControl).Controls[i]);
          ListBoxSkinData := TsCommonData.Create(ListBox, True);
          ListBoxSkinData.SkinSection := s_EDIT;
          ListBoxSkinData.FOwnerControl := ListBox;
          RefreshEditScrolls(ListBoxSkinData, ListBoxSW);
          if (ListBoxSW <> nil) and ListBoxSW.Destroyed then FreeAndNil(ListBoxSW);
          RefreshEditScrolls(ListBoxSkinData, ListBoxSW);
        end;
      end;
    end;
  end;
end;

function TacWWComboBoxWnd.ButtonRect: TRect;
const
  bWidth = 2;
var
  w : integer;
  r : TRect;
begin
  if FShowButton then w := GetSystemMetrics(SM_CXVSCROLL) else w := 0;
  GetWindowRect(CtrlHandle, r);
  if GetWindowLong(CtrlHandle, GWL_EXSTYLE) and WS_EX_RTLREADING = WS_EX_RTLREADING then begin
    Result.Left := bWidth
  end
  else Result.Left := WidthOf(r) - w - bWidth;
  Result.Top := bWidth;
  Result.Right := Result.Left + w;
  Result.Bottom := HeightOf(r) - bWidth;
end;

constructor TacWWComboBoxWnd.Create(aCtrl: TWinControl; ASkinData: TsCommonData; ASkinManager: TsSkinManager; SkinSection: string; Repaint: boolean);
begin
  inherited Create(aCtrl.Handle, ASkinData, ASkinManager, SkinSection, Repaint);
  ListBox := nil;
  ListBoxSkinData := nil;
  FShowButton := GetShowButton(aCtrl);
end;

destructor TacWWComboBoxWnd.Destroy;
begin
  if ListBoxSkinData <> nil then FreeAndNil(ListBoxSkinData);
  inherited;
end;

function TacWWComboBoxWnd.GetShowButton(aCtrl: TWinControl): Boolean;
begin
  if (aCtrl is TComboBox) then begin
    Result := ((aCtrl as TComboBox).Style in [StdCtrls.csDropDown, StdCtrls.csDropDownList]);
  end
  else Result := True;
end;

{ TacPanelWnd }

type
  TacAccessPanel = class(TPanel);

procedure TacPanelWnd.AC_WMPaint(var aDC : hdc);
var
  b : boolean;
  DC, SaveIndex : HDC;
  R : TRect;
  Panel : TacAccessPanel;
  w : integer;
  ClRect : TRect;
begin
  Panel := TacAccessPanel(SkinData.FOwnerControl);
  if (csDestroying in SkinData.FOwnerControl.ComponentState) then Exit;
  if (SkinData.FOwnerControl.Parent <> nil) and (csCreating in SkinData.FOwnerControl.Parent.ControlState) then Exit;

  SkinData.FUpdating := SkinData.Updating;
  if not SkinData.FUpdating then begin
    InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption); 
    if aDC = 0 then DC := GetWindowDC(Panel.Handle) else DC := aDC;
    SaveIndex := SaveDC(DC);
    try
      // If transparent and form resizing processed
      b := SkinData.HalfVisible or SkinData.BGChanged;
      if SkinData.RepaintIfMoved then begin
        GetClipBox(DC, R);
        SkinData.HalfVisible := (WidthOf(R) <> Panel.Width) or (HeightOf(R) <> Panel.Height)
      end
      else SkinData.HalfVisible := False;

      if b then PrepareCache;
      GetClientRect(CtrlHandle, ClRect);
      w := (WidthOf(WndRect) - WidthOf(ClRect)) div 2;
      CopyWinControlCache(Panel, SkinData, Rect(w, w, 0, 0), Rect(0, 0, Panel.Width - 2 * w, Panel.Height - 2 * w), DC, True);
      sVCLUtils.PaintControls(DC, Panel, b and SkinData.RepaintIfMoved, Point(0, 0));
      SetParentUpdated(Panel);
    finally
      RestoreDC(DC, SaveIndex);
      if aDC = 0 then ReleaseDC(Panel.Handle, DC);
    end;
  end;
end;

procedure TacPanelWnd.acWndProc(var Message: TMessage);
var
  PS : TPaintStruct;
  M : TMessage;
begin
{$IFDEF LOGGED}
//  AddToLog(Message);
{$ENDIF}
  if (SkinData.FOwnerControl <> nil) and (csAcceptsControls in TWinControl(SkinData.FOwnerControl).ControlStyle) then begin
    if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
      AC_CTRLHANDLED : begin Message.Result := 1; Exit end; // AlphaSkins supported
      AC_GETAPPLICATION : begin Message.Result := longint(Application); Exit end;
      AC_SETNEWSKIN, AC_REFRESH : begin
        inherited;
        AlphaBroadCastCheck(SkinData.FOwnerControl, CtrlHandle, Message);
        Exit;
      end;
      AC_REMOVESKIN : begin
        SkinData.SkinIndex := -1;
        SkinData.FOwnerControl.ControlStyle := SkinData.FOwnerControl.ControlStyle - [csOpaque];
        inherited;
        Exit;
      end;
      AC_ENDPARENTUPDATE : begin
        SkinData.Updating := False;
        RedrawWindow(CtrlHandle, nil, 0, RDW_INVALIDATE or RDW_ERASE or RDW_FRAME);
        Exit;
      end;
      AC_PREPARECACHE : Exit;
    end
    else if Assigned(SkinData) and SkinData.Skinned then case Message.Msg of
      WM_PAINT : begin
        InvalidateRect(CtrlHandle, nil, True);
        BeginPaint(CtrlHandle, PS);
        EndPaint(CtrlHandle, PS);
        Exit;
      end;
      WM_NCPAINT : begin
        AC_WMNCPaint(0);
        Message.Result := 0;
        Exit;
      end;
      WM_ERASEBKGND : begin
        AC_WMPaint(TWMPaint(Message).DC);
        Message.Result := 1;
        Exit;
      end;
      WM_UPDATEUISTATE: begin
        Message.Result := 1;
        Exit;
      end;
      WM_PRINT : begin
        AC_WMPaint(TWMPaint(Message).DC);
        AC_WMNCPaint(TWMPaint(Message).DC);
        Exit;
      end;
      CM_SHOWINGCHANGED : if SkinData.FOwnerControl.Visible then begin
        AddToAdapter(TWinControl(SkinData.FOwnerControl));
        M := MakeMessage(SM_ALPHACMD, MakeWParam(0, AC_SETNEWSKIN), Longint(SkinData.SkinManager), 0);
        AlphaBroadCastCheck(SkinData.FOwnerControl, CtrlHandle, M);
        M := MakeMessage(SM_ALPHACMD, MakeWParam(0, AC_REFRESH), Longint(SkinData.SkinManager), 0);
        AlphaBroadCastCheck(SkinData.FOwnerControl, CtrlHandle, M);
      end;
      WM_PARENTNOTIFY : if (Message.WParam and $FFFF = WM_CREATE) or (Message.WParam and $FFFF = WM_DESTROY) then begin
        inherited;
        if Message.WParamLo = WM_CREATE then AddToAdapter(TWinControl(SkinData.FOwnerControl));
        exit;
      end;
      WM_SETTEXT : if IsWindowVisible(CtrlHandle) then begin
        SendMessage(CtrlHandle, WM_SETREDRAW, 0, 0);
        inherited;
        SendMessage(CtrlHandle, WM_SETREDRAW, 1, 0);
        SkinData.BGChanged := True;
        SendMessage(CtrlHandle, WM_PAINT, 0, 0);
        Exit;
      end;
    end;
  end;
  inherited;
  case Message.Msg of
    WM_WINDOWPOSCHANGING : begin
      SendMessage(CtrlHandle, WM_NCPAINT, 0, 0);
    end;
  end;
end;

procedure TacPanelWnd.PrepareCache;
var
  CI : TCacheInfo;
  w : integer;
  R : TRect;
  Panel : TacAccessPanel;
begin
  Panel := TacAccessPanel(SkinData.FOwnerControl);
  InitCacheBmp(SkinData);
  CI := GetParentCache(SkinData);
  PaintItem(SkinData, CI, False, 0, Rect(0, 0, Panel.Width, Panel.Height), Point(Panel.Left, Panel.Top), SkinData.FCacheBMP, False);
  R := Panel.ClientRect;
  w := Panel.BorderWidth + integer(Panel.BevelInner <> bvNone) * Panel.BevelWidth + integer(Panel.BevelOuter <> bvNone) * Panel.BevelWidth;
  InflateRect(R, -w, -w);
  WriteText(R, SkinData.FCacheBmp.Canvas);
  SkinData.BGChanged := False;
end;

procedure TacPanelWnd.AC_WMNCPaint(aDC : hdc);
var
  DC : hdc;
  w : integer;
  ClRect : TRect;
begin
  GetWindowRect(CtrlHandle, WndRect);
  GetClientRect(CtrlHandle, ClRect);
  WndSize.cx := WidthOf(WndRect);
  WndSize.cy := HeightOf(WndRect);
  if aDC = 0 then DC := GetWindowDC(CtrlHandle) else DC := aDC;

  try
    SendMessage(CtrlHandle, SM_ALPHACMD, MakeWParam(0, AC_PREPARECACHE), 0);
    w := (WidthOf(WndRect) - WidthOf(ClRect)) div 2;
    if w > 0 then BitBltBorder(DC, 0, 0, WndSize.cx, WndSize.cy, SkinData.FCacheBmp.Canvas.Handle, 0, 0, w);
  finally
    if aDC = 0 then ReleaseDC(CtrlHandle, DC);
  end
end;

constructor TacPanelWnd.Create(AHandle: hwnd; ASkinData: TsCommonData; ASkinManager: TsSkinManager; const SkinSection: string; Repaint: boolean);
begin
  inherited;
  if SkinData.FOwnerControl <> nil then begin
    Panel := TPanel(SkinData.FOwnerControl);
    if SkinSection = '' then case Panel.BevelOuter of // If not custom SkinSection
      bvRaised : if Panel.BevelInner = bvLowered then SkinData.SkinSection := s_GroupBox else SkinData.SkinSection := s_Panel;
      bvLowered : begin
        if Panel.BevelInner = bvRaised then SkinData.SkinSection := s_GroupBox else SkinData.SkinSection := s_PanelLow
      end
      else if Panel.BorderStyle = bsNone then SkinData.SkinSection := s_CheckBox else  SkinData.SkinSection := s_PanelLow;
    end;
  end
  else Panel := nil;
end;

procedure TacPanelWnd.WriteText(R: TRect; aCanvas: TCanvas; aDC: hdc);
var
  Flags : Cardinal;
begin
  if SkinData.FOwnerControl <> nil then aCanvas.Font.Assign(TsHAckedControl(SkinData.FOwnerControl).Font);
  aCanvas.Brush.Style := bsClear;
  R.Top := ((R.Bottom + R.Top) - aCanvas.TextHeight('W')) div 2;
  R.Bottom := R.Top + aCanvas.TextHeight('W');
  Flags := DT_VCENTER;
  if Panel <> nil then begin
    Flags := Flags or GetStringFlags(Panel, Panel.Alignment) or DT_WORDBREAK;
  end
  else Flags := Flags or DT_CENTER;
  if SkinData.FOwnerControl <> nil
    then acWriteTextEx(aCanvas, PacChar(Caption), SkinData.FOwnerControl.Enabled, R, Flags, SkinData, False)
    else acWriteTextEx(aCanvas, PacChar(Caption), True, R, DT_CENTER or DT_VCENTER, SkinData, False);
end;

{ TacDlgPanelWnd }

procedure TacDlgPanelWnd.AC_WMNCPaint(aDC: hdc);
var
  DC : hdc;
  w : integer;
  ClRect : TRect;
begin
  GetClientRect(CtrlHandle, ClRect);

  w := (WidthOf(WndRect) - WidthOf(ClRect)) div 2 + 6;
  if w > 0 then begin
    SkinData.BGChanged := True;
    PrepareCache;
    if aDC = 0 then DC := GetWindowDC(CtrlHandle) else DC := aDC;
    try
      BitBltBorder(DC, 0, 0, WndSize.cx, WndSize.cy, SkinData.FCacheBmp.Canvas.Handle, 0, 0, w);
    finally
      if aDC = 0 then ReleaseDC(CtrlHandle, DC);
    end
  end;
end;

procedure TacDlgPanelWnd.AC_WMPaint(aDC: hdc);
var
  DC, SaveIndex : HDC;
  w : integer;
  ClRect : TRect;
begin
  if not Assigned(SkinData) or not SkinData.Skinned then Exit;
  if aDC = 0 then DC := GetWindowDC(CtrlHandle) else DC := aDC;
  SaveIndex := SaveDC(DC);
  try
    SkinData.Updating := SkinData.FUpdating;
    if not SkinData.FUpdating then begin
      // If transparent and form resizing processed
      PrepareCache;
      GetClientRect(CtrlHandle, ClRect);
      w := (WidthOf(WndRect) - WidthOf(ClRect)) div 2;
      BitBlt(DC, w, w, WndSize.cx - 2 * w, WndSize.cy - 2 * w, SkinData.FCacheBmp.Canvas.Handle, w, w, SRCCOPY);
    end
  finally
    RestoreDC(DC, SaveIndex);
    if aDC = 0 then ReleaseDC(CtrlHandle, DC);
  end;
end;

procedure TacDlgPanelWnd.acWndProc(var Message: TMessage);
var
  PS : TPaintStruct;
  SavedDC : hdc;
begin
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_SETNEWSKIN : begin
      AlphaBroadCastCheck(SkinData.FOwnerControl, CtrlHandle, Message);
    end;
  end
  else
  case Message.Msg of
    794 : begin // Closing dialog
      if (Panel <> nil) and (Panel.Color <> clBtnFace) then Panel.Color := clBtnFace;
    end;
    WM_PAINT : begin
      if (Panel <> nil) and (Panel.Color <> SkinData.SkinManager.GetGlobalColor) then Panel.Color := SkinData.SkinManager.GetGlobalColor;
      BeginPaint(CtrlHandle, PS);
      EndPaint(CtrlHandle, PS);
      Exit;
    end;      
    WM_NCPAINT : begin
      AC_WMNCPaint(0);
      Message.Result := 1;
      Exit;
    end;
    WM_ERASEBKGND : begin
      SavedDC := SaveDC(TWMPaint(Message).DC);
      try
        AC_WMPaint(TWMPaint(Message).DC);
        IntersectClipRect(TWMPaint(Message).DC, PreviewBorderWidth, PreviewBorderWidth, WndSize.cx - PreviewBorderWidth, WndSize.cy - PreviewBorderWidth);
        CallPrevWndProc(CtrlHandle, WM_PAINT, Message.WParam, Message.LParam);
      finally
        RestoreDC(TWMPaint(Message).DC, SavedDC);
      end;
      Message.Result := 1;
      Exit;
    end;
    WM_UPDATEUISTATE : begin
      Message.Result := 1;
      Exit;
    end;
    WM_PRINT : begin
      AC_WMPaint(TWMPaint(Message).DC);
      AC_WMNCPaint(TWMPaint(Message).DC);
      Exit;
    end;
    WM_PARENTNOTIFY : if (Message.WParam and $FFFF = WM_CREATE) or (Message.WParam and $FFFF = WM_DESTROY) then begin
      inherited;
      if Panel <> nil then Panel.Color := SkinData.SkinManager.GetGlobalColor;
      if Message.WParamLo = WM_CREATE then AddToAdapter(TWinControl(SkinData.FOwnerControl));
      exit;
    end;
    WM_SETTEXT : if IsWindowVisible(CtrlHandle) then begin
      SkinData.BGChanged := True;
      inherited;
      Exit;
    end;
  end;
  inherited;
end;

constructor TacDlgPanelWnd.Create(AHandle: hwnd; ASkinData: TsCommonData; ASkinManager: TsSkinManager; const SkinSection: string; Repaint: boolean);
begin
  inherited;
  Panel := TPanel(SearchWndAsCtrl(AHandle, Application));
  if Assigned(Panel) and (Panel.ClassName = 'TPanel') then begin
    Panel.Color := ASkinManager.GetGlobalColor;
    SkinData.SkinSection := s_CheckBox
  end
  else SkinData.SkinSection := s_GroupBox
end;

procedure TacDlgPanelWnd.PrepareCache;
var
  CI : TCacheInfo;
begin
  InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
  InitCacheBmp(SkinData);
  if SkinData.FCacheBmp.Width <> WndSize.cx then SkinData.FCacheBmp.Width := WndSize.cx;
  if SkinData.FCacheBmp.Height <> WndSize.cy then SkinData.FCacheBmp.Height := WndSize.cy;
  CI := GetParentCacheHwnd(CtrlHandle);
  PaintItem(SkinData, CI, False, 0, Rect(0, 0, WndSize.cx, WndSize.cy), Point(WndPos.X, WndPos.Y), SkinData.FCacheBMP, False);
  SkinData.BGChanged := False;
end;

procedure TacDlgPanelWnd.SetSkinParams;
begin
  inherited;
  if Panel <> nil then Panel.Color := SkinData.SkinManager.GetGlobalColor
end;

{ TacTabControlWnd }

procedure TacTabControlWnd.AC_WMPaint(var Message: TWMPaint);
var
  DC, SavedDC, TabDC : hdc;
  ci : TCacheInfo;
  R : TRect;
  ChangedSkinSection : string;
begin
  InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
  SavedDC := 0;
  TabDC := 0;

  SkinData.FUpdating := SkinData.Updating;
  if not SkinData.FUpdating then begin
    if (Message.Unused = 1) or InAnimationProcess or (SkinData.CtrlSkinState and ACS_PRINTING = ACS_PRINTING) then DC := Message.DC else begin
      DC := GetDC(CtrlHandle);
      SavedDC := SaveDC(DC);
    end;
    try
      // If transparent and form resizing processed
      SkinData.BGChanged := True;
      if TabCount < 1 then ChangedSkinSection := s_CheckBox else begin
        if SkinData.SkinSection = s_PageControl then case TabPosition of
          tpTop :    ChangedSkinSection := s_PageControl;
          tpLeft :   ChangedSkinSection := s_PageControl + 'LEFT';
          tpRight :  ChangedSkinSection := s_PageControl + 'RIGHT';
          tpBottom : ChangedSkinSection := s_PageControl + 'BOTTOM';
        end
        else ChangedSkinSection := SkinData.SkinSection;
      end;
      SkinData.SkinIndex := SkinData.SkinManager.GetSkinIndex(ChangedSkinSection);

      CI := GetParentCacheHwnd(CtrlHandle);// BGInfoToCI(@ParentBG);

      InitCacheBmp(SkinData);
      if SkinData.BGChanged then begin
        SkinData.FCacheBmp.Width := WndSize.cx;
        SkinData.FCacheBmp.Height := WndSize.cy;
        if TabCount > 0 then DrawSkinTabs(CI);
        R := PageRect;

        PaintItem(SkinData.SkinIndex, ChangedSkinSection, CI, False, 0, R, Point(WndPos.X{ + R.Left}, WndPos.Y{ + r.Top}), SkinData.FCacheBmp, SkinData.SkinManager);
        SkinData.BGChanged := False;
      end;
//      if not InAnimationProcess then begin
//        clRect := ClientRect;
//        ExcludeClipRect(DC, clRect.Left, clRect.Top, clRect.Right, clRect.Bottom); // It's needed?
//      end;

      if (TabCount > 0) and (ActiveTabIndex >= 0) then begin
        R := SkinTabRect(ActiveTabIndex, True);
        TabDC := SaveDC(DC);
        ExcludeClipRect(DC, R.Left, R.Top, R.Right, R.Bottom);
      end;
      BitBlt(DC, 0, 0, WndSize.cx, WndSize.cy, SkinData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);

      if (TabCount > 0) and (ActiveTabIndex >= 0) then begin
        RestoreDC(DC, TabDC);
        if Message.Unused <> 1 then begin
          RestoreDC(DC, SavedDC);
          SavedDC := SaveDC(DC);
        end;
        DrawSkinTab(ActiveTabIndex, 2, DC);
      end;
      if SkinData.FOwnerControl <> nil
        then sVCLUtils.PaintControls(DC, TWinControl(SkinData.FOwnerControl), True, Point(0, 0));
    finally
      if DC <> Message.DC then begin
        RestoreDC(DC, SavedDC);
        ReleaseDC(CtrlHandle, DC);
      end;
    end;
  end
end;

procedure TacTabControlWnd.acWndProc(var Message: TMessage);
var
  R : TRect;
  PS : TPaintStruct;
begin
  if (SkinData <> nil) then if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_GETSERVICEINT : begin
      Message.Result := LongInt(SkinData.SkinManager);
      Exit
    end;
    AC_CTRLHANDLED : begin Message.Result := 1; Exit; end;
    AC_REMOVESKIN : begin
      if Message.LParam = LongInt(SkinData.SkinManager) then begin
        CommonWndProc(Message, SkinData);
        CheckUpDown;
        AlphaBroadCastCheck(SkinData.FOwnerControl, CtrlHandle, Message);
        InvalidateRect(CtrlHandle, nil, True);
        RedrawWindow(CtrlHandle, nil, 0, RDW_FRAME or RDW_ERASE or RDW_INVALIDATE or RDW_INTERNALPAINT or RDW_ERASENOW or RDW_UPDATENOW or RDW_ALLCHILDREN);
      end
      else AlphaBroadCastCheck(SkinData.FOwnerControl, CtrlHandle, Message);
      Exit;
    end;
    AC_REFRESH : begin
      if (Message.LParam = LongInt(SkinData.SkinManager)) then begin
        CommonWndProc(Message, SkinData);
        InvalidateRect(CtrlHandle, nil, True);
        CheckUpDown;
      end;
      AlphaBroadCastCheck(SkinData.FOwnerControl, CtrlHandle, Message);
      Exit;
    end;
    AC_SETNEWSKIN : begin
      if (Message.LParam = LongInt(SkinData.SkinManager)) then CommonWndProc(Message, SkinData);
      AlphaBroadCastCheck(SkinData.FOwnerControl, CtrlHandle, Message);
      Exit;
    end;
    AC_PREPARING : if SkinData.Skinned then begin
      Message.Result := integer(SkinData.FUpdating);
      Exit;
    end;
    AC_ENDPARENTUPDATE : if SkinData.Skinned then begin
      SkinData.Updating := False;
      InvalidateRect(CtrlHandle, nil, True);
      Exit;
    end;
    AC_GETBG : if SkinData.Skinned then begin
      CommonWndProc(Message, SkinData);
      Exit;
    end;
  end
  else if SkinData.Skinned then case Message.Msg of
    TCM_SETCURSEL : begin
      SendMessage(CtrlHandle, WM_SETREDRAW, 0, 0);
      inherited;
      SendMessage(CtrlHandle, WM_SETREDRAW, 1, 0);
      Exit;
    end;
    WM_PRINT : begin
      CheckUpDown;
      AC_WMPaint(TWMPaint(Message));
      Exit;
    end;
    WM_NCPAINT : begin
      Exit;
    end;
    WM_ERASEBKGND : if IsWindowVisible(CtrlHandle) then begin
      if not InAnimationProcess then AC_WMPaint(TWMPaint(Message));
      CheckUpDown;
      Message.Result := 0;
      Exit;
    end;
    WM_PAINT : begin
      InvalidateRect(CtrlHandle, nil, True); // Background update (for repaint of graphic controls and for tansheets refreshing)
      BeginPaint(CtrlHandle, PS);
      EndPaint(CtrlHandle, PS);
      Exit;
    end;
  end;
  inherited;
  if (SkinData <> nil) and SkinData.Skinned then case Message.Msg of
    CM_CONTROLLISTCHANGE : begin
      CheckUpDown;
    end;
    TCM_SETCURSEL : begin
      RedrawWindow(CtrlHandle, nil, 0, RDW_FRAME or RDW_INVALIDATE or RDW_ALLCHILDREN);
    end;
    WM_SIZE : begin
      CheckUpDown;
      GetWindowRect(CtrlHandle, R);
      if (WidthOf(R) < WndSize.cx) or (HeightOf(R) < WndSize.cy)
        then RedrawWindow(CtrlHandle, nil, 0, RDW_FRAME or RDW_INVALIDATE or RDW_NOERASE or RDW_NOINTERNALPAINT or RDW_NOCHILDREN);
    end;
  end;
end;

function TacTabControlWnd.TabCount: integer;
begin
  Result := SendMessage(CtrlHandle, TCM_GETITEMCOUNT, 0, 0);
end;

procedure TacTabControlWnd.DrawSkinTabs(const CI: TCacheInfo);
var
  i, Row, rc : integer;
  aRect: TRect;
begin
  aRect := TabsRect;
  if not ci.Ready then begin
    SkinData.FCacheBmp.Canvas.Brush.Style := bsSolid;
    SkinData.FCacheBmp.Canvas.Brush.Color := CI.FillColor;
    SkinData.FCacheBmp.Canvas.FillRect(aRect);
  end
  else begin
    BitBlt(SkinData.FCacheBmp.Canvas.Handle,
           aRect.Left, aRect.Top,
           min(WidthOf(aRect), ci.Bmp.Width),
           min(HeightOf(aRect), ci.Bmp.Height),
           ci.Bmp.Canvas.Handle, ci.X + WndPos.x + aRect.Left, ci.Y + WndPos.Y + aRect.Top, SRCCOPY);
  end;
  // Draw tabs in special order
  rc := TabCtrl_GetRowCount(CtrlHandle);
  for Row := 1 to rc do
    for i := 0 to TabCount - 1 do if (i <> ActiveTabIndex) and (TabRow(i) = Row)
      then DrawSkinTab(i, 0, SkinData.FCacheBmp, Point(0, 0));
end;

function TacTabControlWnd.PageRect: TRect;
begin
  Result := Rect(0, 0, WndSize.cx, WndSize.cy);
  if TabCount > 0 then begin
    case TabPosition of
      tpTop : Result.Top := ClientRect.Top - TopOffset;
      tpBottom : Result.Bottom := ClientRect.Bottom + BottomOffset;
      tpLeft : Result.Left := ClientRect.Left - LeftOffset;
      tpRight : Result.Right := ClientRect.Right + RightOffset;
    end;
  end;
end;

function TacTabControlWnd.ActiveTabIndex: integer;
begin
  Result := SendMessage(CtrlHandle, TCM_GETCURSEL, 0, 0);
end;

function TacTabControlWnd.SkinTabRect(Index: integer; Active: boolean): TRect;
begin
  Result := Rect(0, 0, 0, 0);
  if (Index > TabCount - 1) or (Index < 0) or (TabCount < 1){ or (ActiveTabIndex < 0)} then Exit;
  Result := TabRect(Index);
  if (Style <> tsTabs) or (Result.Left = Result.Right) then Exit;
  if Active then begin
    dec(Result.Bottom, 1);
  end
  else begin
    inc(Result.Bottom, 3);
    dec(Result.Right, 1);
  end;
  case TabPosition of
    tpTop : begin
      InflateRect(Result, 2 * Integer(Active), 2 * Integer(Active));
      inc(Result.Bottom, 1);
    end;
    tpBottom : begin
      InflateRect(Result, 2 * Integer(Active), Integer(Active));
      dec(Result.Top, 2);
      if Active then inc(Result.Bottom) else dec(Result.Bottom, 3);
    end;
    tpLeft : begin
      InflateRect(Result, 0, 1);
      inc(Result.Right, 2);
      if Active then InflateRect(Result, 1, 1) else begin
        dec(Result.Bottom, 4);
        inc(Result.Right, 2);
      end;
    end;
    tpRight : begin
      InflateRect(Result, 1, 0);
      OffsetRect(Result, -1, -1);
      if Active then begin
        InflateRect(Result, 1, 1);
        inc(Result.Bottom, 3);
      end
      else dec(Result.Bottom, 2);
    end;
  end;
end;

type
  TAccessControl = class(TControl);

procedure TacTabControlWnd.DrawSkinTab(Index, State: integer; Bmp: TBitmap; OffsetPoint: TPoint);
var
  rText, aRect, R : TRect;
  VertFont : TLogFont;
  Buffer: array[0..4095] of AcChar;
  bFont, cFont : hfont;
{$IFDEF TNTUNICODE}
  ItemData : TTCItemW;
{$ELSE}
  ItemData : TTCItem;
{$ENDIF}
  ImgList : HImageList;
  Font : TFont;
  ImageList : TCustomImageList;
  pFont : PLogFontA;
  i, h, w, iHeight, iWidth : integer;
  CI : TCacheInfo;
  TabIndex, TabMask, TabState : integer;
  TabSection : string;
  TempBmp : Graphics.TBitmap;
  SavedDC : hdc;
  lCaption: ACString;
  procedure MakeVertFont(Orient : integer);
  begin
    Font := TFont.Create;
    Font.Assign(Bmp.Canvas.Font);
    pFont := PLogFontA(@VertFont);
    GetObject(Bmp.Canvas.Handle, SizeOf(TLogFont), pFont);
    VertFont.lfEscapement := Orient;
    VertFont.lfHeight := Bmp.Canvas.Font.Height;
    VertFont.lfStrikeOut := integer(fsStrikeOut in Bmp.Canvas.Font.Style);
    VertFont.lfItalic := integer(fsItalic in Bmp.Canvas.Font.Style);
    VertFont.lfUnderline := integer(fsUnderline	in Bmp.Canvas.Font.Style);
    VertFont.lfWeight := FW_NORMAL;
    VertFont.lfCharSet := Bmp.Canvas.Font.Charset;

    VertFont.lfWidth := 0;
    Vertfont.lfOutPrecision := OUT_DEFAULT_PRECIS;
    VertFont.lfClipPrecision := CLIP_DEFAULT_PRECIS;
    VertFont.lfOrientation := VertFont.lfEscapement;
    VertFont.lfPitchAndFamily := Default_Pitch;
    VertFont.lfQuality := Default_Quality;
    StrPCopy(VertFont.lfFaceName, Bmp.Canvas.Font.Name);
    if Font.Name <> 'MS Sans Serif' then StrPCopy(VertFont.lfFaceName, Font.Name) else VertFont.lfFaceName := 'Arial';
    Bmp.Canvas.Font.Handle := CreateFontIndirect(VertFont);
    if (State <> 0) and (SkinData.SkinManager.gd[TabIndex].States > 1)
      then Bmp.Canvas.Font.Color := SkinData.SkinManager.gd[TabIndex].HotFontColor[1]
      else Bmp.Canvas.Font.Color := SkinData.SkinManager.gd[TabIndex].FontColor[1];
  end;
  procedure KillVertFont;
  begin
    if Font <> nil then begin
      Bmp.Canvas.Font.Assign(Font);
      FreeAndNil(Font);
    end;
  end;
begin
  if (Index = -1) then Exit;

  bFont := LongWord(SendMessage(CtrlHandle, WM_GETFONT, 0, 0));
  cFont := SelectObject(Bmp.Canvas.Handle, bFont);

  R := SkinTabRect(Index, Index = ActiveTabIndex);
  if (State = 1) and (R.Left < 0) then Exit;

  rText := SkinTabRect(Index, (State = 2) and (Index = ActiveTabIndex));
  aRect := rText;

  ItemData.mask := TCIF_IMAGE or TCIF_STATE or TCIF_TEXT;
  ItemData.dwStateMask := TCIF_STATE;
  ItemData.pszText := Buffer;
  ItemData.cchTextMax := SizeOf(Buffer);

{$IFDEF TNTUNICODE}
  SendMessage(CtrlHandle, TCM_GETITEMW, Index, Integer(@ItemData));
{$ELSE}
  SendMessage(CtrlHandle, TCM_GETITEM, Index, Integer(@ItemData));
{$ENDIF}
  lCaption := Buffer;

  // Tabs drawing
  if SkinData.SkinManager.ConstData.IndexTabTop > 0 then begin // new style
    TabState := State;
    case Style of
      tsTabs : begin
        case TabPosition of // Init of skin data
          tpTop : begin TabIndex := SkinData.SkinManager.ConstData.IndexTabTop; TabMask := SkinData.SkinManager.ConstData.MaskTabTop; TabSection := s_TabTop end;
          tpLeft : begin TabIndex := SkinData.SkinManager.ConstData.IndexTabLeft; TabMask := SkinData.SkinManager.ConstData.MaskTabLeft; TabSection := s_TabLeft end;
          tpBottom : begin TabIndex := SkinData.SkinManager.ConstData.IndexTabBottom; TabMask := SkinData.SkinManager.ConstData.MaskTabBottom; TabSection := s_TabBottom end
          else begin TabIndex := SkinData.SkinManager.ConstData.IndexTabRight; TabMask := SkinData.SkinManager.ConstData.MaskTabRight; TabSection := s_TabRight end;
        end;
      end;
      tsButtons : begin
        TabSection := s_Button;
        TabIndex := SkinData.SkinManager.GetSkinIndex(TabSection);
        TabMask := SkinData.SkinManager.GetMaskIndex(TabSection, s_BordersMask);
      end
      else begin
        TabSection := s_ToolButton;
        TabIndex := SkinData.SkinManager.GetSkinIndex(TabSection);
        TabMask := SkinData.SkinManager.GetMaskIndex(TabSection, s_BordersMask);
      end;
    end;

    if SkinData.SkinManager.IsValidImgIndex(TabMask) then begin // Drawing of tab
      TempBmp := CreateBmp32(WidthOf(aRect, True), HeightOf(aRect, True));
      try
        if (State = 2) and (Index = ActiveTabIndex) then begin
          // Restore BG for Active tab
          BitBlt(TempBmp.Canvas.Handle, aRect.Left + OffsetPoint.x, aRect.Top + OffsetPoint.y, TempBmp.Width, TempBmp.Height,
                   SkinData.FCacheBmp.Canvas.Handle, aRect.Left, aRect.Top, SRCCOPY);
          OffsetRect(R, OffsetPoint.X, OffsetPoint.Y);
          BitBlt(TempBmp.Canvas.Handle, 0, 0, TempBmp.Width, TempBmp.Height,
                 SkinData.FCacheBmp.Canvas.Handle, SkinTabRect(Index, Index = ActiveTabIndex).Left,
                 SkinTabRect(Index, Index = ActiveTabIndex).Top, SRCCOPY);
          // Paint active tab
          BitBlt(Bmp.Canvas.Handle, aRect.Left + OffsetPoint.x, aRect.Top + OffsetPoint.y, TempBmp.Width, TempBmp.Height, TempBmp.Canvas.Handle, 0, 0, SRCCOPY);
          CI := MakeCacheInfo(TempBmp);
          PaintItem(TabIndex, TabSection, CI, True, TabState, Rect(0, 0, TempBmp.Width, TempBmp.Height),
                           Point(0, 0), Bmp, SkinData.SkinManager);
        end
        else begin
          CI := MakeCacheInfo(SkinData.FCacheBmp);
          if State = 1 then CI.X := 0;
          PaintItem(TabIndex, TabSection, CI, True, TabState, Rect(0, 0, TempBmp.Width, TempBmp.Height),
                           Point(aRect.Left, aRect.Top), TempBmp, SkinData.SkinManager);

          SavedDC := SaveDC(Bmp.Canvas.Handle);
          R := PageRect;
          if TabPosition in [tpLeft, tpTop] then ExcludeClipRect(Bmp.Canvas.Handle, R.Left, R.Top, R.Right, R.Bottom);
          BitBlt(Bmp.Canvas.Handle, aRect.Left + OffsetPoint.x, aRect.Top + OffsetPoint.y, TempBmp.Width, TempBmp.Height, TempBmp.Canvas.Handle, 0, 0, SRCCOPY);
          RestoreDC(Bmp.Canvas.Handle, SavedDC);
        end;
      finally
        FreeAndNil(TempBmp);
      end;
    end;
  end;

  // End of tabs drawing
  // Drawing of the tab content
  OffsetRect(rText, OffsetPoint.x, OffsetPoint.y);

  R := rText;
  InflateRect(R, -3, -3);
  ImgList := SendMessage(CtrlHandle, TCM_GETIMAGELIST, 0, 0);
  if SkinData.FOwnerControl = nil then begin
    ImageList := nil;
  end
  else begin
    ImageList := TTabControl(SkinData.FOwnerControl).Images;
  end;
  if SkinData.FOwnerControl <> nil
    then Bmp.Canvas.Font.Assign(TAccessControl(SkinData.FOwnerControl).Font);
  case TabPosition of
    tpTop, tpBottom : begin
      if (ImgList <> 0) and (ItemData.iImage > -1) then begin
        ImageList_GetIconSize(ImgList, w, h);

        if ImageList <> nil
          then ImageList.Draw(Bmp.Canvas, rText.Left + (WidthOf(rText) - (acTextWidth(Bmp.Canvas, lCaption) + w + 8)) div 2,
                        rText.Top + (HeightOf(rText) - w) div 2, ItemData.iImage, True)
          else ImageList_Draw(ImgList, ItemData.iImage, Bmp.Canvas.handle,
                      rText.Left + (WidthOf(rText) - (acTextWidth(Bmp.Canvas, lCaption) + w + 8)) div 2,
                      rText.Top + (HeightOf(rText) - w) div 2, ILD_NORMAL);

        inc(rText.Left, w);
        R := rText;
        acWriteTextEx(Bmp.Canvas, PACChar(lCaption), True, rText, DT_CENTER or DT_SINGLELINE or DT_VCENTER, TabIndex, State <> 0, SkinData.SkinManager);
      end
      else begin
        R := rText;
        acWriteTextEx(Bmp.Canvas, PACChar(lCaption), True, rText, DT_CENTER or DT_SINGLELINE or DT_VCENTER, TabIndex, State <> 0, SkinData.SkinManager);
      end;
    end;

    tpLeft : begin
      Bmp.Canvas.Brush.Style := bsClear;
      MakeVertFont(-2700);

      with acTextExtent(bmp.Canvas, lCaption) do begin
        h := cx;
        w := cy;
      end;

      if (ImgList <> 0) and (ItemData.iImage > -1) then begin
        ImageList_GetIconSize(ImgList, iWidth, iHeight);
        if Index = ActiveTabIndex then OffsetRect(rText, 2, 0);
        i := rText.Bottom - (HeightOf(rText) - (iHeight + 4 + h)) div 2 - iHeight;

        if ImageList <> nil
          then ImageList.Draw(Bmp.Canvas, rText.Left + (WidthOf(rText) - iWidth) div 2, i, ItemData.iImage, True)
          else ImageList_Draw(ImgList, ItemData.iImage, Bmp.Canvas.handle,
                      rText.Left + (WidthOf(rText) - iWidth) div 2, i, ILD_TRANSPARENT);

        Bmp.Canvas.Brush.Style := bsClear;
        acTextRect(bmp.Canvas, rText, rText.Left + (WidthOf(rText) - w) div 2, i - 4, lCaption);
        InflateRect(rText, (w - WidthOf(rText)) div 2, (h - HeightOf(rText)) div 2 + 2);
        OffsetRect(rText, 0, - (4 + h) div 2);
      end
      else begin
        Bmp.Canvas.Brush.Style := bsClear;
        acTextRect(Bmp.Canvas, rText, rText.Left + (WidthOf(rText) - w) div 2, rText.Bottom - (HeightOf(rText) - h) div 2, lCaption);
        InflateRect(rText, (w - WidthOf(rText)) div 2, (h - HeightOf(rText)) div 2);
      end;
      KillVertFont;
    end;

    tpRight : begin
      Bmp.Canvas.Brush.Style := bsClear;
      MakeVertFont(-900);
      OffsetRect(rText, -2, -1);
      with acTextExtent(bmp.Canvas, lCaption) do begin
        h := cx;
        w := cy;
      end;
      if (ImgList <> 0) and (ItemData.iImage > -1) then begin
        ImageList_GetIconSize(ImgList, iWidth, iHeight);
        if Index = ActiveTabIndex then OffsetRect(rText, 2, 0);

        i := rText.Top + (HeightOf(rText) - (iHeight + 4 + h)) div 2;
        if ImageList <> nil
          then ImageList.Draw(Bmp.Canvas, rText.Left + (WidthOf(rText) - iWidth) div 2, i, ItemData.iImage, True)
          else ImageList_Draw(ImgList, ItemData.iImage, Bmp.Canvas.handle, rText.Left + (WidthOf(rText) - iWidth) div 2, i, ILD_TRANSPARENT);

        Bmp.Canvas.Brush.Style := bsClear;
        acTextRect(Bmp.Canvas, rText, rText.Left + (WidthOf(rText) - w) div 2 + w, i + 4 + iHeight, lCaption);

        InflateRect(rText, (w - WidthOf(rText)) div 2, (h - HeightOf(rText)) div 2 + 2);
        OffsetRect(rText, 0, + (4 + iHeight) div 2);
      end
      else begin
        Bmp.Canvas.Brush.Style := bsClear;
        acTextRect(Bmp.Canvas, rText, rText.Left + (WidthOf(rText) - w) div 2 + w, rText.Top + (HeightOf(rText) - h) div 2, lCaption);
        InflateRect(rText, (w - WidthOf(rText)) div 2, (h - HeightOf(rText)) div 2 + 2);
      end;
      KillVertFont;
    end;
  end;

  SelectObject(Bmp.Canvas.Handle, cFont);
end;

procedure TacTabControlWnd.DrawSkinTab(Index, State: integer; DC: hdc);
var
  aRect : TRect;
  TempBmp : TBitmap;
begin
  if (Index < 0) then Exit;
  aRect := SkinTabRect(Index, State = 2);
  TempBmp := CreateBmp32(WidthOf(aRect, True), HeightOf(aRect, True));

  DrawSkinTab(Index, State, TempBmp, Point(-aRect.Left, -aRect.Top));
  BitBlt(DC, aRect.Left, aRect.Top, WidthOf(aRect), HeightOf(aRect), TempBmp.Canvas.Handle, 0, 0, SRCCOPY);

  FreeAndNil(TempBmp);
end;

function TacTabControlWnd.TabRect(const Index: integer): TRect;
begin
  TabCtrl_GetItemRect(CtrlHandle, Index, Result);
end;

function EnumChildWndProc(Child: HWND; Data: LParam): BOOL; stdcall;
type
  PHWND = ^HWND;
var
  ParentWnd : hwnd;
begin
  ParentWnd := PHWND(Data)^;
  if GetParent(Child) = ParentWnd then begin
    PHWND(Data)^ := Child;
    Result := False;
  end
  else Result := True;
end;

function EnumPages(Child: HWND; Data: LParam): BOOL; stdcall;
type
  PHWND = ^HWND;
var
  ParentWnd : hwnd;
  SkinManager : Longint;
begin
  ParentWnd := PHWND(Data)^;
  if GetParent(Child) = ParentWnd then begin
    SkinManager := SendMessage(ParentWnd, SM_ALPHACMD, MakeWParam(0, AC_GETSERVICEINT), 0);
    if (SkinManager <> 0) and not GetBoolMsg(Child, AC_CTRLHANDLED) then begin
      if ServWndList = nil then ServWndList := TList.Create;
      ServWndList.Add(TacPageWnd.Create(Child, nil, TsSkinManager(SkinManager), s_CheckBox {Fully transparent}));
    end;
  end;
  Result := True;
end;

function TacTabControlWnd.ClientRect: TRect;
begin
  Result := Rect(0, 0, WndSize.cx, WndSize.cy);
  SendMessage(CtrlHandle, TCM_ADJUSTRECT, 0, Integer(@Result));
  Inc(Result.Top, 2);
end;

function TacTabControlWnd.TabsRect: TRect;
var
  r : TRect;
begin
  Result := Rect(0, 0, WndSize.cx, WndSize.cy);
  if TabCount > 0 then begin
    r := ClientRect;
    case TabPosition of
      tpTop : Result.Bottom := R.Top - TopOffset;
      tpBottom : Result.Top := R.Bottom + BottomOffset;
      tpLeft : Result.Right := R.Left - LeftOffset;
      tpRight : Result.Left := R.Right + RightOffset;
    end;
  end;
end;

function TacTabControlWnd.TabRow(TabIndex: integer): integer;
var
  h, w, rCount : integer;
  R, tR : TRect;
begin
  rCount := TabCtrl_GetRowCount(CtrlHandle);
  if rCount > 1 then begin
    R := TabRect(TabIndex);
    tR := TabsRect;
    w := WidthOf(R);
    h := HeightOf(R);
    case TabPosition of
      tpTop   : Result := (R.Bottom + h div 2) div h;
      tpLeft  : Result := (R.Right + w div 2) div w;
      tpRight : Result := rCount - (R.Right - tR.Left + w div 2) div w + 1
      else      Result := rCount - (R.Bottom - tR.Top + h div 2) div h + 1;
    end;
  end
  else Result := 1;
end;

function TacTabControlWnd.TabPosition: TTabPosition;
var
  Style : Longint;
begin
  Style := GetWindowLong(CtrlHandle, GWL_STYLE);
  if Style and TCS_VERTICAL = TCS_VERTICAL then begin
    if Style and TCS_RIGHT = TCS_RIGHT then Result := tpRight else Result := tpLeft;
  end
  else begin
    if Style and TCS_BOTTOM = TCS_BOTTOM then Result := tpBottom else Result := tpTop;
  end;
end;

function TacTabControlWnd.Style: TTabStyle;
var
  Style : Longint;
begin
  Style := GetWindowLong(CtrlHandle, GWL_STYLE);
  if Style and TCS_FLATBUTTONS = TCS_FLATBUTTONS then begin
    Result := tsFlatButtons
  end
  else if Style and TCS_BUTTONS = TCS_BUTTONS then begin
    Result := tsButtons
  end
  else Result := tsTabs
end;

procedure TacTabControlWnd.CheckUpDown;
var
  Wnd : HWND;
begin
  if SkinData.Skinned then begin
    Wnd := FindWindowEx(CtrlHandle, 0, 'msctls_updown32', nil);
    if Wnd <> 0 then begin
      if BtnSW <> nil then FreeAndNil(BtnSW);
      BtnSW := TacSpinWnd.Create(Wnd, nil, SkinData.SkinManager, s_UpDown);
    end
    else if BtnSW <> nil then FreeAndNil(BtnSW);
  end;
end;

destructor TacTabControlWnd.Destroy;
begin
  inherited;
  if BtnSW <> nil then FreeAndNil(BtnSW);
end;

constructor TacTabControlWnd.Create(AHandle: hwnd; ASkinData: TsCommonData; ASkinManager: TsSkinManager; const SkinSection: string; Repaint: boolean);
begin
  inherited;
  if SkinSection = '' then ASkinData.SkinSection := s_PageControl;
end;

{ TacPageWnd }

procedure TacPageWnd.acWndProc(var Message: TMessage);
var
  PS : TPaintStruct;
begin
{$IFDEF LOGGED}
//  AddToLog(Message);
{$ENDIF}
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_CTRLHANDLED : begin Message.Result := 1; Exit; end;
    AC_REMOVESKIN : begin
      if Message.LParam = LongInt(SkinData.SkinManager) then begin
        CommonWndProc(Message, SkinData);
        InvalidateRect(CtrlHandle, nil, True);
      end;
      AlphaBroadCastCheck(SkinData.FOwnerControl, CtrlHandle, Message);
    end;
    AC_REFRESH : begin
      if (Message.LParam = LongInt(SkinData.SkinManager)) then begin
        CommonWndProc(Message, SkinData);
        InvalidateRect(CtrlHandle, nil, True);
      end;
      AlphaBroadCastCheck(SkinData.FOwnerControl, CtrlHandle, Message);
      Exit;
    end;
    AC_SETNEWSKIN : begin
      AlphaBroadCastCheck(SkinData.FOwnerControl, CtrlHandle, Message);
      if (Message.LParam = LongInt(SkinData.SkinManager)) then CommonWndProc(Message, SkinData);
      Exit;
    end;
    AC_PREPARING : begin
      Message.Result := integer(SkinData.FUpdating);
      Exit;
    end;
    AC_ENDPARENTUPDATE : if SkinData.Updating then begin
      SkinData.Updating := False;
      InvalidateRect(CtrlHandle, nil, True);
      Exit;
    end;
    AC_GETBG : begin
      GetBGInfo(PacBGInfo(Message.LParam), GetParent(CtrlHandle), PacBGInfo(Message.LParam)^.PleaseDraw);
      PacBGInfo(Message.LParam)^.Offset.X := PacBGInfo(Message.LParam)^.Offset.X + WndPos.X;
      PacBGInfo(Message.LParam)^.Offset.Y := PacBGInfo(Message.LParam)^.Offset.Y + WndPos.Y;
      Exit;
    end;
  end
  else if (SkinData <> nil) and SkinData.Skinned then case Message.Msg of
    WM_PRINT : begin
      AC_WMEraseBKGnd(TWMPaint(Message));
      SendMessage(CtrlHandle, WM_PAINT, Message.WParam, Message.LParam);
      Exit;
    end;
    WM_NCPAINT : Exit;
    WM_ERASEBKGND : if IsWindowVisible(CtrlHandle) then begin
      AC_WMEraseBKGnd(TWMPaint(Message));
      Exit;
    end;
    WM_PAINT : if IsWindowVisible(CtrlHandle) then begin
      BeginPaint(CtrlHandle, PS);
      AC_WMEraseBKGnd(TWMPaint(Message));
      EndPaint(CtrlHandle, PS);
      Exit;
    end;
  end;
  inherited;
  case Message.Msg of
    WM_PARENTNOTIFY : if (Message.WParam and $FFFF = WM_CREATE) then begin
      if (Message.WParamLo = WM_CREATE) then SendControlLoaded(CtrlHandle);
    end;
  end
end;

procedure TacPageWnd.PrepareCache;
begin

end;

procedure TacPageWnd.AC_WMEraseBKGnd(var Message: TWMPaint);
const
  cWidth = 3;
var
  ParentBG : TacBGInfo;
begin
  InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
  ParentBG.Bmp := nil;
  ParentBG.Offset := Point(0, 0);
  GetBGInfo(@ParentBG, ParentWnd, False);
  if ParentBG.BgType = btCache then begin
    BitBlt(Message.DC, 0, 0, WndSize.cx, WndSize.cy, ParentBG.Bmp.Canvas.Handle, WndPos.X + ParentBG.Offset.X, WndPos.Y + ParentBG.Offset.Y, SRCCOPY);
  end
  else if (Page <> nil) and (Page.PageControl <> nil) then begin
    FillDC(Message.DC, Rect(0, 0, WndSize.cx, WndSize.cy), ParentBG.Color);
    if (SendMessage(Page.PageControl.Handle, TCM_GETITEMCOUNT, 0, 0) > 0) and (ParentBG.Bmp <> nil) then case TabPosition of
      tpTop    : BitBlt(Message.DC, 0, 0, WndSize.cx, cWidth, ParentBG.Bmp.Canvas.Handle, WndPos.X + ParentBG.Offset.X, WndPos.Y + ParentBG.Offset.Y, SRCCOPY);
      tpLeft   : BitBlt(Message.DC, 0, 0, 3, WndSize.cy, ParentBG.Bmp.Canvas.Handle, WndPos.X, WndPos.Y, SRCCOPY);
      tpBottom : BitBlt(Message.DC, 0, WndSize.cy - cWidth, WndSize.cx, cWidth, ParentBG.Bmp.Canvas.Handle, WndPos.X, WndPos.Y + WndSize.cy - cWidth, SRCCOPY);
      tpRight  : BitBlt(Message.DC, WndSize.cx - cWidth, 0, cWidth, WndSize.cy, ParentBG.Bmp.Canvas.Handle, WndPos.X + WndSize.cx - cWidth, WndPos.Y, SRCCOPY);
    end;
  end;

  if Page <> nil then begin
    sVCLUtils.PaintControls(Message.DC, Page, True, Point(0, 0), CtrlHandle);
    SetParentUpdated(Page);
  end;

  Message.Result := 1;
end;

function TacPageWnd.TabPosition: TTabPosition;
var
  Style : Longint;
begin
  Style := GetWindowLong(GetParent(CtrlHandle), GWL_STYLE);
  if Style and TCS_VERTICAL = TCS_VERTICAL then begin
    if Style and TCS_RIGHT = TCS_RIGHT then Result := tpRight else Result := tpLeft;
  end
  else begin
    if Style and TCS_BOTTOM = TCS_BOTTOM then Result := tpBottom else Result := tpTop;
  end;
end;

constructor TacPageWnd.Create(AHandle: hwnd; ASkinData: TsCommonData; ASkinManager: TsSkinManager; const SkinSection: string; Repaint: boolean);
begin
  inherited;
  Page := nil;
  InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
end;

{ TacPageControlWnd }

procedure TacPageControlWnd.acWndProc(var Message: TMessage);
begin
{$IFDEF LOGGED}
//  AddToLog(Message);
{$ENDIF}
  if (SkinData <> nil) and SkinData.Skinned then case Message.Msg of
    WM_NCPAINT : begin
      InitPages(SkinData.Skinned);
      Exit;
    end;
    WM_ERASEBKGND : if IsWindowVisible(CtrlHandle) then begin
      if not InAnimationProcess then AC_WMPaint(TWMPaint(Message));
      Message.Result := 1;
      Exit;
    end;
    TCM_SETCURSEL : if (SkinData.FOwnerControl <> nil) then AddToAdapter(TWinControl(SkinData.FOwnerControl));
    WM_PRINT : begin
      CheckUpDown;
      InitPages(True);
      AC_WMPaint(TWMPaint(Message));
      Exit;
    end;
    WM_PARENTNOTIFY : begin
      case Message.WParam and $FFFF of
        WM_CREATE : InitPages(SkinData.Skinned);
        WM_DESTROY : InitPages(False);
      end;
    end;
  end;
  inherited;
end;

function TacPageControlWnd.ClientRect: TRect;
begin
  Result := Rect(0, 0, WndSize.cx, WndSize.cy);
  SendMessage(CtrlHandle, TCM_ADJUSTRECT, 0, Integer(@Result));
  Inc(Result.Top, 2);
end;

constructor TacPageControlWnd.Create(AHandle: hwnd; ASkinData: TsCommonData; ASkinManager: TsSkinManager; const SkinSection: string; Repaint: boolean);
begin
  inherited;
  InitPages(SkinData.Skinned);
end;

procedure TacPageControlWnd.InitPages(Skinned: boolean);
var
  ChildWnd: HWND;
  i : integer;
  pw : TacPageWnd;
begin
  if (SkinData.FOwnerControl <> nil) and (SkinData.FOwnerControl is TPageControl) then begin
    for i := 0 to TPageControl(SkinData.FOwnerControl).PageCount - 1 do begin
      if not GetBoolMsg(TPageControl(SkinData.FOwnerControl).Pages[i].Handle, AC_CTRLHANDLED) then begin
        if ServWndList = nil then ServWndList := TList.Create;
        pw := TacPageWnd.Create(TPageControl(SkinData.FOwnerControl).Pages[i].Handle, nil, TsSkinManager(SkinManager), s_CheckBox);
        pw.Page := TPageControl(SkinData.FOwnerControl).Pages[i];
        ServWndList.Add(pw);
      end;
    end;
  end
  else begin
    ChildWnd := CtrlHandle;
    EnumChildWindows(CtrlHandle, @EnumPages, LPARAM(@ChildWnd));
  end;
end;

function TacPageControlWnd.PageRect: TRect;
begin
  Result := Rect(0, 0, WndSize.cx, WndSize.cy);
  if TabCount > 0 then begin
    case TabPosition of
      tpTop : Result.Top := ClientRect.Top - TopOffset;
      tpBottom : Result.Bottom := ClientRect.Bottom + BottomOffset;
      tpLeft : Result.Left := ClientRect.Left - LeftOffset;
      tpRight : Result.Right := ClientRect.Right + RightOffset;
    end;
  end;
end;

{ TacToolBarVCLWnd }

procedure TacToolBarVCLWnd.acWndProc(var Message: TMessage);
var
  OldIndex, i, h, w : integer;
  RC : TRect;
begin
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_REFRESH : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
      DroppedButton := nil;
    end;
    AC_SETNEWSKIN : begin
      ToolBar.OnAdvancedCustomDraw := OurAdvancedCustomDraw;
      ToolBar.OnAdvancedCustomDrawButton := OurAdvancedCustomDrawButton;
    end;
    AC_REMOVESKIN : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
      ToolBar.OnAdvancedCustomDraw := nil;
      ToolBar.OnAdvancedCustomDrawButton := nil;
      DroppedButton := nil;
    end;
    AC_GETBG : if (SkinData <> nil) then begin
      InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
      InitBGInfo(SkinData, PacBGInfo(Message.LParam), 0, CtrlHandle);
      PacBGInfo(Message.LParam).Offset.X := PacBGInfo(Message.LParam).Offset.X + DisplayRect.Left;
      PacBGInfo(Message.LParam).Offset.Y := PacBGInfo(Message.LParam).Offset.Y + DisplayRect.Top;
      Exit;
    end;
  end;
  if (SkinData <> nil) and SkinData.Skinned then case Message.Msg of
    WM_ERASEBKGND : Exit;
    WM_NCPAINT : begin
      if not InAnimationProcess then WMNCPaint;
      Exit;
    end;
    WM_PRINT : begin
      RC := ACClientRect(ToolBar.Handle);
      w := WidthOf(Rc);
      h := HeightOf(Rc);
      if SkinData.BGChanged then PrepareCache;
      BitBlt(TWMPaint(Message).DC, 0, 0, ToolBar.Width, Rc.Top, SkinData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
      BitBlt(TWMPaint(Message).DC, 0, Rc.Top, Rc.Left, h, SkinData.FCacheBmp.Canvas.Handle, 0, Rc.Top, SRCCOPY);
      BitBlt(TWMPaint(Message).DC, 0, Rc.Bottom, ToolBar.Width, ToolBar.Height - h - Rc.Top, SkinData.FCacheBmp.Canvas.Handle, 0, Rc.Bottom, SRCCOPY);
      BitBlt(TWMPaint(Message).DC, Rc.Right, Rc.Top, ToolBar.Width - Rc.Left - w, h, SkinData.FCacheBmp.Canvas.Handle, Rc.Right, Rc.Top, SRCCOPY);

      MoveWindowOrg(TWMPaint(Message).DC, Rc.Left, Rc.Top);
      IntersectClipRect(TWMPaint(Message).DC, 0, 0, w, h);
      SendMessage(CtrlHandle, WM_PAINT, Message.WParam, 0);
      Exit;
    end;
    CN_NOTIFY : with TWMNotify(Message) do case NMHdr^.code of
      TBN_DROPDOWN: with PNMToolBar(NMHdr)^ do if ToolBar.Perform(TB_GETBUTTON, iItem, Longint(@tbButton)) <> 0 then begin
        DroppedButton := TToolButton(tbButton.dwData);
        DroppedButton.Repaint
      end;
      TBN_DELETINGBUTTON : if HotButtonIndex >= ToolBar.ButtonCount then HotButtonIndex := -1;
    end;
  end;
  if CommonWndProc(Message, SkinData) then Exit;
  inherited;
  if (SkinData <> nil) and SkinData.Skinned then case Message.Msg of
    CN_DROPDOWNCLOSED : begin
      if DroppedButton <> nil then begin
        HotButtonIndex := -1;
        i := DroppedButton.Index;
        DroppedButton := nil;
        RepaintButton(i);
      end;
    end;
    WM_SIZE : begin
      RedrawWindow(CtrlHandle, nil, 0, RDW_INVALIDATE);
      Exit;
    end;
    CM_MOUSELEAVE : if not ToolBar.Flat and not (csDesigning in ToolBar.ComponentState) then begin
      OldIndex := HotButtonIndex;
      HotButtonIndex := -1;
      if (OldIndex > -1) and not ToolBar.Buttons[OldIndex].Down then RepaintButton(OldIndex);
      HotButtonIndex := -1;
    end;
    WM_MOUSEMOVE : if not ToolBar.Flat and not (csDesigning in ToolBar.ComponentState) then with TWMMouse(Message) do begin
      i := IndexByMouse(Point(TWMMouse(Message).XPos, TWMMouse(Message).YPos));
      if (i <> HotButtonIndex) then begin
        if (i > -1) and not ToolBar.Buttons[i].Enabled then Exit; // v4.50
        OldIndex := HotButtonIndex;
        HotButtonIndex := i;
        if (OldIndex > -1) and not ToolBar.Buttons[OldIndex].Down then RepaintButton(OldIndex);
        if (HotButtonIndex > -1) and not ToolBar.Buttons[HotButtonIndex].Down then RepaintButton(HotButtonIndex);
      end;
    end;
  end;
end;

constructor TacToolBarVCLWnd.Create(AHandle: hwnd; ASkinData: TsCommonData; ASkinManager: TsSkinManager; const SkinSection: string; Repaint: boolean);
begin
  inherited;
  HotButtonIndex := -1;
  if Assigned(ASkinData) and Assigned(ASkinData.FOwnerControl) and (ASkinData.FOwnerControl is TToolBar) then begin
    ToolBar := TToolBar(ASkinData.FOwnerControl);
    ToolBar.OnAdvancedCustomDraw := OurAdvancedCustomDraw;
    ToolBar.OnAdvancedCustomDrawButton := OurAdvancedCustomDrawButton;
    if SkinSection = '' then ASkinData.SkinSection := s_ToolBar;
  end
  else ToolBar := nil;
end;

procedure CopyCache(Control : TWinControl; SkinData : TsCommonData; SrcRect, DstRect : TRect; DstDC : HDC);
var
  SaveIndex : HDC;
  i : integer;
  Designing : boolean;
begin
  sAlphaGraph.UpdateCorners(SkinData, 0);
  SaveIndex := SaveDC(DstDC);
  IntersectClipRect(DstDC, DstRect.Left, DstRect.Top, DstRect.Right, DstRect.Bottom);
  Designing := csDesigning in Control.ComponentState;
  try
    for i := 0 to Control.ControlCount - 1 do begin
      if (Control.Controls[i] is TToolButton) and (csDesigning in Control.ComponentState) then Continue;
      if (Control.Controls[i] is TGraphicControl) and StdTransparency then Continue;
      if not Control.Controls[i].Visible or not RectIsVisible(DstRect, Control.Controls[i].BoundsRect) then Continue;
      if ((csOpaque in Control.Controls[i].ControlStyle) or (Control.Controls[i] is TGraphicControl) or Designing) then begin
        ExcludeClipRect(DstDC, Control.Controls[i].Left, Control.Controls[i].Top, 
                          Control.Controls[i].Left + Control.Controls[i].Width,
                          Control.Controls[i].Top + Control.Controls[i].Height);
      end;
    end;
    BitBlt(DstDC, DstRect.Left, DstRect.Top, WidthOf(DstRect), HeightOf(DstRect), SkinData.FCacheBmp.Canvas.Handle, SrcRect.Left, SrcRect.Top, SRCCOPY); 
  finally
    RestoreDC(DstDC, SaveIndex);
  end;
end;

function TacToolBarVCLWnd.DisplayRect: TRect;
var
  RW : TRect;
begin
  GetClientRect(CtrlHandle, Result);
  if (WidthOf(Result) <> WndSize.cx) or (HeightOf(Result) <> WndSize.cy) then begin
    GetWindowRect(CtrlHandle, RW);
    MapWindowPoints(0, CtrlHandle, RW, 2);
    OffsetRect(Result, -RW.Left, -RW.Top);
  end;

end;

function TacToolBarVCLWnd.GetButtonRect(Index: integer): TRect;
begin
  ToolBar.Perform(TB_GETITEMRECT, Index, Longint(@Result))
end;

function TacToolBarVCLWnd.IndexByMouse(MousePos: TPoint): integer;
var
  i : integer;
begin
  Result := -1;
  for i := 0 to ToolBar.ButtonCount - 1 do begin
    if PtInRect(GetButtonRect(i), MousePos) then begin
      if (TControl(ToolBar.Buttons[I]) is TToolButton) and (ToolBar.Buttons[i].Style in [tbsButton, tbsCheck, tbsDropDown]) then Result := i;
      Exit;
    end;
  end;
end;

procedure TacToolBarVCLWnd.OurAdvancedCustomDraw(Sender: TToolBar; const ARect: TRect; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
var
  RC, RW: TRect;
begin
  if SkinData.Skinned(True) then begin
    SkinData.Updating := SkinData.Updating;
    if not (Stage in [cdPrePaint]) then begin DefaultDraw := False; Exit end;
    if not SkinData.Updating then begin
      SkinData.FCacheBMP.Canvas.Font.Assign(Sender.Font);
      if SkinData.BGChanged then PrepareCache;

      Windows.GetClientRect(Sender.Handle, RC);
      GetWindowRect(Sender.Handle, RW);
      MapWindowPoints(0, Sender.Handle, RW, 2);
      OffsetRect(RC, -RW.Left, -RW.Top);

      CopyCache(Sender, SkinData, RC, ARect, Sender.Canvas.Handle);
      sVCLUtils.PaintControls(Sender.Canvas.Handle, Sender, True, Point(0, 0));
      SetParentUpdated(Sender);
      if (RC.Left > 0) or (RC.Top > 0) or (RC.Right <> Sender.Width) or (RC.Bottom <> Sender.Height) then SendMessage(Sender.Handle, WM_NCPAINT, 0, 0);
    end;
  end
  else begin
    DefaultDraw := True;
  end
end;

procedure TacToolBarVCLWnd.OurAdvancedCustomDrawButton(Sender: TToolBar; Button: TToolButton; State: TCustomDrawState; Stage: TCustomDrawStage; var Flags: TTBCustomDrawFlags; var DefaultDraw: Boolean);
var
  Mode, SkinIndex, BorderIndex : integer;
  ci : TCacheInfo;
  R, iR : TRect;
  BtnBmp : TBitmap;
  bWidth, bHeight : integer;
  function AddedWidth : integer;
  begin
    if (Button.Style = tbsDropDown) then Result := GetSystemMetrics(SM_CXVSCROLL) - 2 else Result := 0
  end;
  function IntButtonWidth : integer;
  begin
    Result := Button.Width - AddedWidth;
  end;
  function ButtonWidth : integer;
  begin
    Result := Button.Width;
  end;
  function ImgRect : TRect; begin
    if not ToolBar.List then begin
      Result.Left := (IntButtonWidth - ToolBar.Images.Width) div 2 + 1;
      Result.Top := (Button.Height - ToolBar.Images.Height - integer(ToolBar.ShowCaptions) * (SkinData.FCacheBMP.Canvas.TextHeight('A') + 3)) div 2;
      Result.Right := Result.Left + ToolBar.Images.Width;
      Result.Bottom := Result.Bottom + ToolBar.Images.Height;
    end
    else begin
      Result.Left := 5;
      Result.Top := (Button.Height - ToolBar.Images.Height) div 2;
      Result.Right := Result.Left + ToolBar.Images.Width;
      Result.Bottom := Result.Bottom + ToolBar.Images.Height;
    end;
    if Mode = 2 then OffsetRect(Result, 1, 1);
  end;
  procedure DrawBtnCaption;
  var
    cRect : TRect;
    function CaptionRect : TRect; var l, t, r, b, dh : integer; begin
      if not ToolBar.List then begin
        l := (IntButtonWidth - SkinData.FCacheBMP.Canvas.TextWidth(Button.Caption)) div 2;
        if Assigned(ToolBar.Images) then begin
          dh := (Button.Height - ToolBar.Images.Height - SkinData.FCacheBMP.Canvas.TextHeight('A') - 3) div 2;
          t := dh + ToolBar.Images.Height + 3;
        end
        else begin
          dh := (Button.Height - SkinData.FCacheBMP.Canvas.TextHeight('A')) div 2;
          t := dh;
        end;
        r := IntButtonWidth - l;
        b := Button.Height - dh;
        Result := Rect(l - 1, t, r + 2, b);
      end
      else begin
        if Assigned(ToolBar.Images) and (Button.ImageIndex > -1) then Result.Left := 6 + ToolBar.Images.Width else Result.Left := 1;
        Result.Right := IntButtonWidth - 2;
        Result.Top := 2;
        Result.Bottom := Button.Height - 2;
      end;
      OffsetRect(Result, integer(Mode = 2), integer(Mode = 2));
    end;
  begin
    if ToolBar.ShowCaptions then begin
      cRect := CaptionRect;
      acWriteTextEx(BtnBMP.Canvas, PacChar(Button.Caption), True, cRect, DT_CENTER or DT_VCENTER or DT_SINGLELINE, GetFontIndex(Button, SkinIndex, SkinData.SkinManager), Mode > 0);
    end;
  end;
  procedure DrawBtnGlyph;
  begin
    if Assigned(ToolBar.Images) and (Button.ImageIndex > -1) and (Button.ImageIndex < ToolBar.Images.Count) then begin
      CopyToolBtnGlyph(ToolBar, Button, State, Stage, Flags, BtnBmp);
    end;
  end;
  procedure DrawArrow;
  var
    Mode : integer;
    x, y : integer;
  begin
    if SkinData.SkinManager.ConstData.MaskArrowBottom > -1 then begin
      if ((DroppedButton = Button) and Assigned(Button.DropDownMenu) or Button.Down) then Mode := 2 else if cdsHot in State then Mode := 1 else Mode := 0;

      R.Left := IntButtonWidth;
      R.Right := Button.Width;
      BorderIndex := SkinData.SkinManager.GetMaskIndex(SkinIndex, s_ToolButton, s_BordersMask);
      if SkinData.SkinManager.IsValidImgIndex(BorderIndex) then DrawSkinRect(BtnBmp, R, True, ci, SkinData.SkinManager.ma[BorderIndex], Mode, True);

      if (SkinData.SkinManager.ConstData.MaskArrowBottom > -1) and (SkinData.SkinManager.ConstData.MaskArrowBottom < High(SkinData.SkinManager.ma)) then begin
        x := IntButtonWidth + (AddedWidth - 3 - WidthOf(SkinData.SkinManager.ma[SkinData.SkinManager.ConstData.MaskArrowBottom].R) div SkinData.SkinManager.ma[SkinData.SkinManager.ConstData.MaskArrowBottom].ImageCount) div 2 + 2;
        y := (ToolBar.ButtonHeight - HeightOf(SkinData.SkinManager.ma[SkinData.SkinManager.ConstData.MaskArrowBottom].R) div (1 + SkinData.SkinManager.ma[SkinData.SkinManager.ConstData.MaskArrowBottom].MaskType)) div 2;

        DrawSkinGlyph(BtnBmp, Point(x, y), Mode, 1, SkinData.SkinManager.ma[SkinData.SkinManager.ConstData.MaskArrowBottom], MakeCacheInfo(BtnBmp));
      end;
    end;
  end;
begin
  if SkinData.Skinned then begin
    DefaultDraw := False;
    if not (Stage in [cdPrePaint]) then begin DefaultDraw := False; Exit end;
    if Stage in [cdPrePaint] then begin
      if not ToolBar.Flat and not (csDesigning in ToolBar.ComponentState) and (HotButtonIndex = Button.Index) then State := State + [cdsHot];
      Flags := Flags + [tbNoEtchedEffect, tbNoEdges];

      iR := GetButtonRect(Button.Index);
      bWidth := WidthOf(iR);
      bHeight := HeightOf(iR);

      BtnBmp := CreateBmp32(bWidth, bHeight);
      BtnBmp.Canvas.Font.Assign(ToolBar.Font);

      if not Button.Marked and not Button.Indeterminate and ((State = []) or (State = [cdsDisabled])) 
        then Mode := 0
        else if (cdsSelected in State) or (cdsChecked in State) or Button.Marked or Button.Indeterminate
          then Mode := 2
          else Mode := 1;
      SkinIndex := SkinData.SkinManager.GetSkinIndex(s_TOOLBUTTON);
      ci := MakeCacheInfo(SkinData.FCacheBmp,
                          ToolBar.BorderWidth * 2 + integer(ebLeft in ToolBar.EdgeBorders) * (integer(ToolBar.EdgeInner <> esNone) + integer(ToolBar.EdgeOuter <> esNone)),
                          ToolBar.BorderWidth * 2 + integer(ebTop in ToolBar.EdgeBorders) * (integer(ToolBar.EdgeInner <> esNone) + integer(ToolBar.EdgeOuter <> esNone)));
      R := Rect(0, 0, bWidth, Button.Height);
      OffsetRect(R, ToolBar.ClientRect.Left, ToolBar.ClientRect.Top);

      PaintItemBg(SkinIndex, s_ToolButton, ci, Mode, R, Point(Button.Left, Button.Top), BtnBmp, SkinData.SkinManager);
      R.Right := bWidth - AddedWidth;

      ci.X := ci.X + Button.Left;
      ci.Y := ci.Y + Button.Top;
      BorderIndex := SkinData.SkinManager.GetMaskIndex(SkinIndex, s_ToolButton, s_BordersMask);
      if BorderIndex > -1 then DrawSkinRect(BtnBmp, R, True, ci, SkinData.SkinManager.ma[BorderIndex], Mode, True);

      DrawBtnCaption;
      DrawBtnGlyph;
      if Button.Style = tbsDropDown then DrawArrow;
      if not Button.Enabled or Button.Indeterminate then BmpDisabledKind(BtnBmp, [dkBlended], ToolBar.Parent, CI, Point(0, 0));

      BitBlt(ToolBar.Canvas.Handle, Button.Left, Button.Top, bWidth, bHeight, BtnBmp.Canvas.Handle, 0, 0, SRCCOPY);
      FreeAndNil(BtnBmp);
    end
  end
  else begin
    DefaultDraw := True;
    inherited;
  end;
end;

procedure TacToolBarVCLWnd.PrepareCache;
begin
  InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
  InitCacheBmp(SkinData);
  PaintItem(SkinData, GetParentCache(SkinData), False, 0,
              Rect(0, 0, SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height), Point(WndPos.X, WndPos.Y), SkinData.FCacheBmp, False);
  SkinData.BGChanged := False;
end;

procedure TacToolBarVCLWnd.RepaintButton(Index: integer);
var
  Flags : TTBCustomDrawFlags;
  Def : boolean;
  DC, SavedDC: HDC;
  RC, RW: TRect;
begin
  if (Index > -1) and ToolBar.Buttons[Index].Visible then begin
    Flags := [tbNoEtchedEffect, tbNoEdges];
    Def := False;
    DC := GetWindowDC(ToolBar.Handle);
    SavedDC := SaveDC(DC);
    try
      Windows.GetClientRect(ToolBar.Handle, RC);
      GetWindowRect(ToolBar.Handle, RW);
      MapWindowPoints(0, ToolBar.Handle, RW, 2);
      OffsetRect(RC, -RW.Left, -RW.Top);
      MoveWindowOrg(DC, -RW.Left, -RW.Top);

      ToolBar.Canvas.Handle := DC;
      OurAdvancedCustomDrawButton(ToolBar, ToolBar.Buttons[Index], [], cdPrePaint, Flags, Def)
    finally
      ToolBar.Canvas.Handle := 0;
      RestoreDC(DC, SavedDC);
      ReleaseDC(ToolBar.Handle, DC);
    end;
  end;
end;

procedure TacToolBarVCLWnd.WMNCPaint(const aDC: hdc);
var
  DC : hdc;
  w, h : integer;
  RC, RW: TRect;
begin
  Windows.GetClientRect(ToolBar.Handle, RC);

  if (WidthOf(RC) <> ToolBar.Width) or (HeightOf(RC) <> ToolBar.Height) then begin

    GetWindowRect(ToolBar.Handle, RW);
    MapWindowPoints(0, ToolBar.Handle, RW, 2);
    OffsetRect(RC, -RW.Left, -RW.Top);

    if aDC = 0 then DC := GetWindowDC(CtrlHandle) else DC := aDC;
    ExcludeClipRect(DC, RC.Left, RC.Top, RC.Right, RC.Bottom);
    { Draw borders in non-client area }                          
    w := WidthOf(Rc);
    h := HeightOf(Rc);
    BitBlt(DC, 0, 0, ToolBar.Width, Rc.Top, SkinData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
    BitBlt(DC, 0, Rc.Top, Rc.Left, h, SkinData.FCacheBmp.Canvas.Handle, 0, Rc.Top, SRCCOPY);
    BitBlt(DC, 0, Rc.Bottom, ToolBar.Width, ToolBar.Height - h - Rc.Top, SkinData.FCacheBmp.Canvas.Handle, 0, Rc.Bottom, SRCCOPY);
    BitBlt(DC, Rc.Right, Rc.Top, ToolBar.Width - Rc.Left - w, h, SkinData.FCacheBmp.Canvas.Handle, Rc.Right, Rc.Top, SRCCOPY);

    IntersectClipRect(DC, RW.Left, RW.Top, RW.Right, RW.Bottom);

    if aDC = 0 then ReleaseDC(CtrlHandle, DC);
  end;
end;

{ TacStatusBarWnd }

procedure TacStatusBarWnd.acWndProc(var Message: TMessage);
var
  PS : TPaintStruct;
begin
{$IFDEF LOGGED}
//  AddToLog(Message);
{$ENDIF}
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_REFRESH : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
    end;
    AC_REMOVESKIN : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
    end;
  end;
  if (SkinData <> nil) and SkinData.Skinned then case Message.Msg of
    WM_ERASEBKGND : begin
      WMPaint(hdc(Message.WParam));
      Exit;
    end;
    WM_NCPAINT : begin
      if not InAnimationProcess then WMNCPaint;
      Exit;
    end;
    WM_PAINT : begin
      InvalidateRect(CtrlHandle, nil, True);
      BeginPaint(CtrlHandle, PS);
      EndPaint(CtrlHandle, PS);
      Exit;
    end;
    WM_PRINT : begin
      WMPaint(hdc(Message.WParam));
      Exit;
    end;
  end;
  inherited;
  if (SkinData <> nil) and SkinData.Skinned then case Message.Msg of
    WM_SIZE : begin
      RedrawWindow(CtrlHandle, nil, 0, RDW_INVALIDATE or RDW_ERASE);
      Exit;
    end;
  end;
end;

constructor TacStatusBarWnd.Create(AHandle: hwnd; ASkinData: TsCommonData; ASkinManager: TsSkinManager; const SkinSection: string; Repaint: boolean);
begin
  inherited;
  if SkinSection = '' then ASkinData.SkinSection := s_StatusBar;
  if (ASkinData.FOwnerControl <> nil) and (ASkinData.FOwnerControl is TStatusBar) then StatusBar := TStatusBar(ASkinData.FOwnerControl) else StatusBar := nil;
end;

procedure TacStatusBarWnd.DoDrawText(const Text: acString; var Rect: TRect; const Flags: Integer);
begin
  if Assigned(StatusBar) then SkinData.FCacheBmp.Canvas.Font.Assign(StatusBar.Font);

  acWriteTextEx(SkinData.FCacheBMP.Canvas, PacChar(Text), True, Rect, Flags or DT_SINGLELINE or DT_VCENTER, SkinData, False);
end;

procedure TacStatusBarWnd.DrawPanel(const Index: integer; const Rect: TRect);
var
  aRect: TRect;
begin
  aRect := Rect;
  InflateRect(aRect, -1, -1);
  InternalDrawPanel(Index, '', aRect);
end;

procedure TacStatusBarWnd.InternalDrawPanel(const Index: integer; const Text: string; const Rect: TRect);
var
  aRect: TRect;
  si, mi, SkinIndex: integer;
  s : acString;
  TempBmp : TBitmap;
  CI : TCacheInfo;
  SavedDC : hdc;
begin
  aRect := Rect;
  InflateRect(aRect, -1, -1);

  SkinIndex := SkinData.SkinManager.GetMaskIndex(SkinData.SkinIndex, SkinData.SkinSection, s_StatusPanelBordersMask);
  if Assigned(SkinData.SkinManager) and SkinData.SkinManager.IsValidSkinIndex(SkinData.SkinIndex) then begin
    if SkinData.SkinManager.IsValidImgIndex(SkinIndex) then begin
      if SimplePanel then begin
        DrawSkinRect(SkinData.FCacheBmp, Classes.Rect(0, 0, WndSize.cx, WndSize.cy), True, EmptyCI, SkinData.SkinManager.ma[SkinIndex], 0, True);
      end
      else begin
        DrawSkinRect(SkinData.FCacheBmp, Rect, True, EmptyCI, SkinData.SkinManager.ma[SkinIndex], 0, True);
      end;
    end
    else begin
      if not (SimplePanel or (Index = PartsCount - 1)) then begin;
        si := SkinData.SkinManager.GetSkinIndex(s_Divider);
        if Assigned(SkinData.SkinManager) and SkinData.SkinManager.IsValidskinIndex(si) then begin
          mi := SkinData.SkinManager.GetMaskIndex(si, s_Divider, s_BordersMask);
          if SkinData.SkinManager.IsValidImgIndex(mi) then begin
            TempBmp := CreateBmp32(WidthOfImage(SkinData.SkinManager.ma[mi]) - 1, WndSize.cy - 2);
            BitBlt(TempBmp.Canvas.Handle, 0, 0, TempBmp.Width, TempBmp.Height, SkinData.FCacheBmp.Canvas.Handle, Rect.Right - TempBmp.Width, Rect.Top, SRCCOPY);

            CI := MakeCacheInfo(SkinData.FCacheBmp);
            PaintItem(si, s_Divider, CI, True, 0, Classes.Rect(0, 0, TempBmp.Width, TempBmp.Height), Point(Rect.Right - TempBmp.Width, 1), TempBmp, SkinData.SkinManager);
            BitBlt(SkinData.FCacheBmp.Canvas.Handle, Rect.Right - TempBmp.Width, 1, TempBmp.Width, TempBmp.Height, TempBmp.Canvas.Handle, 0, 0, SRCCOPY);
            FreeAndNil(TempBmp);
          end;
        end;
      end;
    end
  end;
  if (StatusBar <> nil) and (Index > -1) and (Index < StatusBar.Panels.Count) and (StatusBar.Panels[Index].Style = psOwnerDraw) and Assigned(StatusBar.OnDrawPanel) then begin
    SavedDC := StatusBar.Canvas.Handle;
    StatusBar.Canvas.Handle := SkinData.FCacheBmp.Canvas.Handle;
    StatusBar.OnDrawPanel(StatusBar, StatusBar.Panels[Index], Rect);
    StatusBar.Canvas.Handle := SavedDC;
  end
  else begin
    dec(aRect.Bottom, 1);
    inc(aRect.Left, 2);
    dec(aRect.Right, 4);

    s := PartText(Index);
    s := CutText(SkinData.FCacheBmp.Canvas, s, WidthOf(aRect));
    if StatusBar <> nil then with StatusBar do begin
      if not SimplePanel and (Index > -1) and (Index < Panels.Count)
        then DoDrawText(s, aRect, GetStringFlags(StatusBar, Panels[Index].Alignment))
        else DoDrawText(s, aRect, GetStringFlags(StatusBar, taLeftJustify))
    end;
  end;
end;

procedure TacStatusBarWnd.PaintPanels;
var
  i, l: integer;
begin
  if SimplePanel then InternalDrawPanel(-1, PartText(0), Rect(0, 1, WndSize.cx - 1, WndSize.cy - 1)) else begin
    l := PartsCount - 1;
    for i := 0 to l do DrawPanel(i, PartRect(i));
  end
end;

function TacStatusBarWnd.PartRect(const Index: integer): TRect;
begin
  SendMessage(CtrlHandle, SB_GETRECT, Index, LongInt(@Result));
end;

function TacStatusBarWnd.PartsCount: integer;
begin
  Result := SendMessage(CtrlHandle, SB_GETPARTS, 0, 0);
end;

function TacStatusBarWnd.PartText(const Index: integer): acString;
var
  Len : integer;
begin
  if PartsCount = 0 then begin
    Result := '';
    Exit
  end
  else begin
    if SimplePanel then begin
      Len := SendMessage(CtrlHandle, WM_GETTEXTLENGTH, 0, 0);
      SetString(Result, PacChar(nil), Len);
      if Len <> 0 then SendMessage(CtrlHandle, WM_GETTEXT, Len + 1, Longint(Result)) else Result := '';
    end
    else begin
      if StatusBar <> nil then begin
        if StatusBar.Panels.Count > 0 then Result := StatusBar.Panels[Index].Text else Result := StatusBar.SimpleText
      end
      else Result := '';
    end;
  end
end;

procedure TacStatusBarWnd.PrepareCache;
begin
  InitCacheBmp(SkinData);
  PaintItem(SkinData, GetParentCache(SkinData), False, 0, Rect(0, 0, SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height), Point(WndPos.X, WndPos.Y), SkinData.FCacheBmp, False);
  PaintPanels;

  SkinData.BGChanged := False;
end;

function TacStatusBarWnd.SimplePanel: boolean;
begin
  Result := SendMessage(CtrlHandle, SB_ISSIMPLE, 0, 0) = 1;
end;

procedure TacStatusBarWnd.WMNCPaint(const aDC: hdc);
var
  DC : hdc;
begin
  InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
  if (SkinData.FOwnerControl <> nil) and (SkinData.FOwnerControl is TStatusBar) then begin
    if aDC = 0 then DC := GetWindowDC(CtrlHandle) else DC := aDC;
    if SkinData.BGChanged then PrepareCache;
    { Draw borders in non-client area }
    BitBltBorder(DC, 0, 0, WndSize.cx, WndSize.cy, SkinData.FCacheBmp.Canvas.Handle, 0, 0, TStatusBar(SkinData.FOwnerControl).BorderWidth);
    if aDC = 0 then ReleaseDC(CtrlHandle, DC);
  end;
end;

procedure TacStatusBarWnd.WMPaint(const aDC: hdc);
var
  DC : hdc;
begin
  InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
  if aDC = 0 then DC := GetWindowDC(CtrlHandle) else DC := aDC;
//  if SkinData.BGChanged then
  PrepareCache;
  { Draw borders in non-client area }
  BitBlt(DC, 0, 0, WndSize.cx, WndSize.cy, SkinData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
  if aDC = 0 then ReleaseDC(CtrlHandle, DC);
end;

{ TacSpeedButtonWnd }

type
  TAccessButton = class(TSpeedButton);

procedure TacSpeedButtonHandler.acWndProc(var Message: TMessage);
begin
{$IFDEF LOGGED}
//  AddToLog(Message);
{$ENDIF}
  if Message.Msg = SM_ALPHACMD then with Ctrl do case Message.WParamHi of
    AC_CTRLHANDLED : begin Message.Result := 1; Exit end;
    AC_GETAPPLICATION : begin Message.Result := longint(Application); Exit end;
    AC_SETNEWSKIN : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
      CommonWndProc(Message, SkinData);
//      if SkinData.Skinned then ControlStyle := ControlStyle + [csOpaque];
      Exit;
    end;
    AC_REMOVESKIN : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) and not (csDestroying in ComponentState) then begin
      CommonWndProc(Message, SkinData);
//      ControlStyle := ControlStyle - [csOpaque];
      if Visible then Repaint;
      Ctrl.WindowProc := OldWndProc;
      Destroyed := True;
      Exit;
    end;
    AC_ENDPARENTUPDATE : if SkinData.Updating then begin
      SkinData.Updating := False;
      Repaint;
      Exit;
    end;
    AC_REFRESH : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
      CommonWndProc(Message, SkinData);
      if Visible then Repaint;
      exit
    end;
    AC_INVALIDATE : begin
      SkinData.FUpdating := False;
      SkinData.BGChanged := True;
      Repaint;
    end;
  end
  else case Message.Msg of
    CM_MOUSEENTER, CM_MOUSELEAVE : begin
      SkinData.FMouseAbove := CM_MOUSEENTER = Message.Msg;
      SkinData.BGChanged := True;
      Message.Result := CallPrevWndProc(Ctrl, Message.Msg, Message.WParam, Message.LParam);
//      Ctrl.Repaint;
      Exit;
    end;
    WM_PAINT : begin
      AC_WMPaint(TWMPaint(Message));
      Exit;
    end
  end;
  Message.Result := CallPrevWndProc(Ctrl, Message.Msg, Message.WParam, Message.LParam);
end;

procedure TacSpeedButtonHandler.AC_WMPaint(var Message: TWMPaint);
var
  DC, SavedDC : hdc;
begin
  if Message.DC = 0 then Exit;
//  if Message.DC = 0 then DC := GetDC(CtrlHandle) else
  DC := Message.DC;
  SavedDC := SaveDC(DC);

  PrepareCache;
  UpdateCorners(SkinData, 0);

  BitBlt(DC, 0, 0, Ctrl.Width, Ctrl.Height, SkinData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);
  RestoreDC(DC, SavedDC);

//  if Message.DC = 0 then ReleaseDC(CtrlHandle, DC);
end;

function TacSpeedButtonHandler.CallPrevWndProc(Ctrl : TControl; Msg, WParam: Integer; var LParam: Integer): longint;
var
  M : TMessage;
begin
  Result := 0;
  if Assigned(OldWndProc) then begin
    M.Msg := Msg;
    M.WParam := WParam;
    M.LParam := LParam;
    M.Result := 0;
    OldWndProc(M);
    Result := M.Result;
    LParam := M.LParam;
  end
end;

function TacSpeedButtonHandler.Caption: acString;
begin
{$IFDEF TNTUNICODE}
  if Ctrl is TTntSpeedButton then Result := TTntSpeedButton(Ctrl).Caption else
{$ENDIF}
    Result := TSpeedButton(Ctrl).Caption
end;

function TacSpeedButtonHandler.CaptionRect: TRect;
var
  Size : TSize;
  IsDown : integer;
begin
  with TSpeedButton(Ctrl) do begin
    Size := TextRectSize;
    IsDown := integer(CurrentState = 2);
    if not Glyph.Empty then begin
      Result := ImgRect;
      case Layout of
        blGlyphLeft : begin
          Result.Left := Result.Right + Spacing;
          Result.Top := (Height - Size.cy) div 2 + IsDown;
        end;
        blGlyphRight : begin
          Result.Left := Result.Left - Spacing - Size.cx;
          Result.Top := (Height - Size.cy) div 2 + IsDown;
        end;
        blGlyphTop : begin
          Result.Left := (Width - Size.cx) div 2 + IsDown;
          Result.Top := Result.Bottom + Spacing;
        end;
        blGlyphBottom : begin
          Result.Left := (Width - Size.cx) div 2 + IsDown;
          Result.Top := Result.Top - Spacing - Size.cy;
        end;
      end;
    end
    else begin
      if Margin <> -1 then case Layout of
        blGlyphLeft : begin
          Result.Left := Margin;
          Result.Top := (Height - Size.cy) div 2 + IsDown;
        end;
        blGlyphRight : begin
          Result.Left := Width - Margin - Size.cx;
          Result.Top := (Height - Size.cy) div 2 + IsDown;
        end;
        blGlyphTop : begin
          Result.Left := (Width - Size.cx) div 2 + IsDown;
          Result.Top := Margin;
        end;
        blGlyphBottom : begin
          Result.Left := (Width - Size.cx) div 2 + IsDown;
          Result.Top := Height - Margin - Size.cy;
        end;
      end
      else begin
        Result.Left := (Width - Size.cx) div 2 + IsDown;
        Result.Top := (Height - Size.cy) div 2 + IsDown;
      end
    end;
    Result.Right := Result.Left + Size.cx;
    Result.Bottom := Result.Top + Size.cy;
  end;
end;

constructor TacSpeedButtonHandler.Create(Btn: TControl; ASkinData: TsCommonData; ASkinManager: TsSkinManager; const SkinSection: string; Repaint: boolean);
begin
  Ctrl := Btn;
  OldWndProc := nil;
  OldProc := nil;

  NewWndProcInstance := nil;
  SkinManager := ASkinManager;
  Destroyed := False;
  SkinData := ASkinData;
  if SkinManager = nil then SkinManager := SkinData.SkinManager;

  if SkinData.SkinSection = '' then SkinData.SkinSection := SkinSection;

  OldWndProc := Ctrl.WindowProc;
  Ctrl.WindowProc := acWndProc;
//  if SkinData.FOwnerControl <> nil then SkinData.FOwnerControl.ControlStyle := SkinData.FOwnerControl.ControlStyle + [csOpaque];
end;

function TacSpeedButtonHandler.CurrentState: integer;
begin
  if TAccessButton(Ctrl).FState in [bsDown, bsExclusive]
    then Result := 2
    else if ControlIsActive(SkinData) then Result := 1 else Result := 0
end;

destructor TacSpeedButtonHandler.Destroy;
begin
{
  if not Destroyed then begin
//    if SkinManager.SkinRemoving and Assigned(Ctrl) then Ctrl.WindowProc := OldWndProc;
    Destroyed := True;
  end;
}
  SkinManager := nil;
  inherited Destroy;
end;

procedure TacSpeedButtonHandler.DoDrawText(var Rect: TRect; Flags: Integer);
begin
  Flags := Ctrl.DrawTextBiDiModeFlags(Flags) and not DT_SINGLELINE;
  SkinData.FCacheBMP.Canvas.Font.Assign(TAccessButton(Ctrl).Font);
  acWriteTextEx(SkinData.FCacheBMP.Canvas, PacChar(Caption), True, Rect, Flags, SkinData, CurrentState <> 0);
end;

procedure TacSpeedButtonHandler.DrawCaption;
var
  R, CalcRect : TRect;
begin
  if Caption <> '' then begin
    SkinData.FCacheBmp.Canvas.Font.Assign(TAccessButton(Ctrl).Font);
    SkinData.FCacheBMP.Canvas.Brush.Style := bsClear;
    R := CaptionRect;
    { Calculate vertical layout }
    CalcRect := R;
    DoDrawText(R, DT_EXPANDTABS or DT_WORDBREAK or GetStringFlags(Ctrl, taLeftJustify));
  end;
end;

procedure TacSpeedButtonHandler.DrawGlyph;
var
  TmpPng : TPNGGraphic;
  R : TRect;
begin
  if Ctrl is TSpeedButton then with TSpeedButton(Ctrl) do begin
    if Glyph.PixelFormat = pfDevice then Glyph.HandleType := bmDIB;
    if (NumGlyphs = 1) and (Glyph.PixelFormat = pf32bit) then begin // Patch if Png, don't work in std. mode
      TmpPng := TPNGGraphic.Create;
      TmpPng.PixelFormat := pf32bit;
      TmpPng.Width := Glyph.Width;
      TmpPng.Height := Glyph.Height;
      BitBlt(TmpPng.Canvas.Handle, 0, 0, Glyph.Width, Glyph.Height, Glyph.Canvas.Handle, 0, 0, SRCCOPY);
      R := ImgRect;
      SkinData.FCacheBmp.Canvas.Draw(R.Left, R.Top, TmpPng);
      FreeAndNil(TmpPng);
    end
    else DrawGlyphEx(TSpeedButton(Ctrl).Glyph, SkinData.FCacheBmp, ImgRect, NumGlyphs, Enabled, DefDisabledGlyphKind, CurrentState, 0, Down, False);
  end
end;

function TacSpeedButtonHandler.GlyphHeight: integer;
begin
  if not TSpeedButton(Ctrl).Glyph.Empty then begin
    Result := TSpeedButton(Ctrl).Glyph.Height;
  end
  else Result := 0;
end;

function TacSpeedButtonHandler.GlyphWidth: integer;
begin
  if not TSpeedButton(Ctrl).Glyph.Empty then begin
    Result := TSpeedButton(Ctrl).Glyph.Width div TSpeedButton(Ctrl).NumGlyphs;
  end
  else Result := 0;
end;

function TacSpeedButtonHandler.ImgRect: TRect;
var
  x, y : integer;
  dw, dh, gw, gh : integer;
begin
  x := 0;
  y := 0;
  with TSpeedButton(Ctrl) do begin
    Result := Rect(0, 0, 0, 0);
    gw := GlyphWidth;
    gh := GlyphHeight;
    dw := (TSpeedButton(Ctrl).Width - gw - TSpeedButton(Ctrl).Spacing * integer((gw > 0) and (TSpeedButton(Ctrl).Caption <> '')) - TextRectSize.cx) div 2;
    dh := (Height - gh - Spacing * integer((gh > 0) and (Caption <> '')) - TextRectSize.cy) div 2;

    case Layout of
      blGlyphLeft : begin
        if Margin <> -1 then x := Margin else x := dw;
        y := (Height - gh) div 2;
      end;
      blGlyphRight : begin
        if Margin <> -1 then x := Width - gw - Margin else x := Width - dw - gw;
        y := (Height - GlyphHeight) div 2;
      end;
      blGlyphTop : begin
        x := (Width - gw) div 2;
        if Margin <> -1 then y := Margin else y := dh;
      end;
      blGlyphBottom : begin
        x := (Width - gw) div 2;
        if Margin <> -1 then y := Height - gh - Margin else y := Height - dh - gh;
      end;
    end;

    if CurrentState = 2 then begin
      inc(x);
      inc(y);
    end;
    Result := Rect(x, y, x + gw, y + gh);
  end;
end;

procedure TacSpeedButtonHandler.PrepareCache;
var
  CI : TCacheInfo;
  ParentBG : TacBGInfo;
begin
  InitCacheBmp(SkinData);

  SkinData.FCacheBmp.Canvas.Font.Assign(TsHackedControl(Ctrl).Font);

  ParentBG.BgType := btUnknown;
  ParentBG.DrawDC := 0;
  ParentBG.PleaseDraw := False;
  GetBGInfo(@ParentBG, Ctrl.Parent);
  CI := BGInfoToCI(@ParentBG);
  if CI.Ready and (CI.Bmp.Width = 0) then Exit;
  PaintItem(SkinData, CI, True, CurrentState, Rect(0, 0, Ctrl.Width, Ctrl.Height), Point(Ctrl.Left, Ctrl.Top), SkinData.FCacheBmp, True, integer(CurrentState = 2), integer(CurrentState = 2));
  UpdateCorners(SkinData, CurrentState);
  DrawCaption;
  DrawGlyph;
  if not Ctrl.Enabled then begin
    CI := GetParentCache(SkinData);
    BmpDisabledKind(SkinData.FCacheBmp, DefDisabledKind, Ctrl.Parent, CI, Point(Ctrl.Left, Ctrl.Top));
  end;
  SkinData.BGChanged := False;  
end;

function TacSpeedButtonHandler.TextRectSize: TSize;
var
  R : TRect;
begin
  if Caption <> '' then begin
    R := Rect(0, 0, MaxByte, 0);
    acDrawText(SkinData.FCacheBMP.Canvas.Handle, Caption, R, DT_EXPANDTABS or DT_WORDBREAK or DT_CALCRECT);
    Result.cy := HeightOf(R);
    Result.cx := WidthOf(R);
  end
  else begin
    Result.cy := 0;
    Result.cx := 0;
  end
end;

var
  huser32 : HMODULE = 0;
  hcomctl32 : HMODULE = 0;

{ TacEdgeWnd }

procedure TacEdgeWnd.acWndProc(var Message: TMessage);
begin
{$IFDEF LOGGED}
//  AddToLog(Message);
{$ENDIF}
  case Message.Msg of
    WM_PAINT : begin
      Message.Result := CallPrevWndProc(CtrlHandle, Message.Msg, Message.WParam, Message.LParam);
      AC_WMPaint(TWMPaint(Message));
      Exit;
    end;
    WM_NCPAINT, WM_ERASEBKGND : Exit;
  end;
  inherited;
end;

procedure TacEdgeWnd.AC_WMPaint(var Message : TWMPaint);
var
  DC, SavedDC : hdc;
begin
  InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
  if Message.DC = 0 then DC := GetWindowDC(CtrlHandle) else DC := Message.DC;
  SavedDC := SaveDC(DC);
  SkinData.BGChanged := True;
  SkinData.FCacheBmp.Width := WndSize.cx;
  SkinData.FCacheBmp.Height := WndSize.cy;
  PrepareCache(SkinData, CtrlHandle);

  PaintText;
  BitBltBorder(DC, 0, 0, WndSize.cx, WndSize.cy, SkinData.FCacheBmp.Canvas.Handle, 0, 0, 2);
  RestoreDC(DC, SavedDC);

  if Message.DC = 0 then ReleaseDC(CtrlHandle, DC);
end;

{ TacTrackWnd }

procedure TacTrackWnd.AC_WMPaint(Message: TWMPaint);
var
  PS : TPaintStruct;
  DC : hdc;
begin
  InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
  BeginPaint(CtrlHandle, ps);

  SkinData.FUpdating := SkinData.Updating;
  if not SkinData.FUpdating then begin
    Style := GetWindowLong(CtrlHandle, GWL_STYLE);
    InitCtrlData(CtrlHandle, ParentWnd, WndRect, ParentRect, WndSize, WndPos, Caption);
    SendMessage(ParentWnd, SM_ALPHACMD, MakeWParam(0, AC_GETCACHE), 0);

    if IsWindowVisible(CtrlHandle) or (Message.DC <> 0) then begin
      if Message.DC = 0 then DC := GetDC(CtrlHandle) else DC := Message.DC;

      PrepareCache;

      BitBlt(DC, 0, 0, SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height, SkinData.FCacheBmp.Canvas.Handle, 0, 0, SRCCOPY);

      if Message.DC = 0 then ReleaseDC(CtrlHandle, DC);
    end;
  end;
  EndPaint(CtrlHandle, ps);
end;

procedure TacTrackWnd.acWndProc(var Message: TMessage);
begin
{$IFDEF LOGGED}
//  AddToLog(Message);
{$ENDIF}
  case Message.Msg of
    WM_NCPAINT, WM_ERASEBKGND : Exit;
    WM_PAINT : begin
      AC_WMPaint(TWMPaint(Message));
      Exit;
    end;
    WM_LBUTTONDOWN : begin
      bMousePressed := True;
    end;
    WM_LBUTTONUP : begin
      bMousePressed := False;
    end;
  end;
  inherited;
end;

constructor TacTrackWnd.Create(AHandle: hwnd; ASkinData: TsCommonData; ASkinManager: TsSkinManager; const SkinSection: string; Repaint: boolean);
begin
  inherited;
  TickHeight := 4;
end;

function TacTrackWnd.IsVertical: boolean;
begin
  Result := GetWindowLong(CtrlHandle, GWL_STYLE) and TBS_VERT = TBS_VERT;
end;

procedure TacTrackWnd.PrepareCache;
begin
  InitCacheBmp(SkinData);
  SkinData.FCacheBmp.Width := WndSize.cx;
  SkinData.FCacheBmp.Height := WndSize.cy;
  PaintBody;
end;

procedure TacTrackWnd.PaintBody;
var
  R : TRect;
  CI : TCacheInfo;
begin
  CI := GetParentCacheHwnd(CtrlHandle);
  PaintItem(SkinData, CI, True, Mode, Rect(0, 0, WndSize.cx, WndSize.cy), WndPos, SkinData.FCacheBmp, False);

  TrackBarNdx := SkinData.SkinManager.GetSkinIndex(s_TrackBar);
  if TrackBarNdx < 0 then Exit;

  PaintBar;
  PaintThumb(SendMessage(CtrlHandle, TBM_GETPOS, 0, 0));

  if not IsWindowEnabled(CtrlHandle) then begin
    if CI.Ready then begin
      R := Rect(0, 0, WndSize.cx, WndSize.cy);
      OffsetRect(R, CI.X + WndPos.x, CI.Y + WndPos.y);
      BlendTransRectangle(SkinData.FCacheBmp, 0, 0, CI.Bmp, R, DefDisabledBlend);
    end
    else begin
      BlendTransBitmap(SkinData.FCacheBmp, DefDisabledBlend, TsColor(CI.FillColor));
    end;
  end;
end;

procedure TacTrackWnd.PaintBar;
var
  w, h, i : integer;
  aRect : TRect;
  CI : TCacheInfo;
begin
  aRect := ChannelRect;
  i := SkinData.SkinManager.GetMaskIndex(TrackBarNdx, s_TrackBar, s_SliderChannelMask);
  if SkinData.SkinManager.IsValidImgIndex(i) then begin
    if IsVertical then begin
      h := WidthOfImage(SkinData.SkinManager.ma[i]) - 1;
      w := WidthOf(aRect);
      aRect.Left := aRect.Left + (w - h) div 2;
      aRect.Right := aRect.Left + h;
    end
    else begin
      h := HeightOfImage(SkinData.SkinManager.ma[i]) - 1;
      w := HeightOf(aRect);
      aRect.Top := aRect.Top + (w - h) div 2;
      aRect.Bottom := aRect.Top + h;
    end;
    CI := MakeCacheInfo(SkinData.FCacheBmp);
    DrawSkinRect(SkinData.FCacheBmp, aRect, True, CI, SkinData.SkinManager.ma[i], integer(ControlIsActive(SkinData)), True);
  end;
  if IsVertical then PaintTicksVer else PaintTicksHor;
end;

procedure TacTrackWnd.PaintThumb(i: integer);
var
  aRect, DrawRect : TRect;
  Bmp : TBitmap;
  GlyphSize : TSize;
  Stretched : boolean;
  procedure RotateBmp180(Bmp : TBitmap; Horz : boolean);
  var
    x, y : integer;
    c : TColor;
  begin
    if not Horz then for x := 0 to Bmp.Width - 1 do for y := 0 to (Bmp.Height - 1) div 2 do begin
      c := Bmp.Canvas.Pixels[x, y];
      Bmp.Canvas.Pixels[x, y] := Bmp.Canvas.Pixels[x, Bmp.Height - y - 1];
      Bmp.Canvas.Pixels[x, Bmp.Height - y - 1] := c
    end
    else for y := 0 to Bmp.Height - 1 do for x := 0 to (Bmp.Width - 1) div 2 do begin
      c := Bmp.Canvas.Pixels[x, y];
      Bmp.Canvas.Pixels[x, y] := Bmp.Canvas.Pixels[Bmp.Width - x - 1, y];
      Bmp.Canvas.Pixels[Bmp.Width - x - 1, y] := c
    end;
  end;
  function PrepareBG : TRect;
  var
    TmpBmp : TBitmap;
  begin
    if Stretched or (TickMarks = tmTopLeft) then begin
      Bmp := CreateBmp32(GlyphSize.cx, GlyphSize.cy);
      Result := Rect(0, 0, GlyphSize.cx, GlyphSize.cy);
      TmpBmp := CreateBmp32(WidthOf(aRect, True), HeightOf(aRect, True));
      BitBlt(TmpBmp.Canvas.Handle, 0, 0, TmpBmp.Width, TmpBmp.Height, SkinData.FCacheBmp.Canvas.Handle, aRect.Left, aRect.Top, SRCCOPY);
      Stretch(TmpBmp, Bmp, Bmp.Width, Bmp.Height, ftMitchell);
      if TickMarks = tmTopLeft then RotateBmp180(Bmp, IsVertical);
      FreeAndNil(TmpBmp);
    end
    else begin
      Bmp := SkinData.FCacheBmp;
      Result := aRect;
    end;
  end;
  procedure ReturnToCache;
  var
    TmpBmp : TBitmap;
  begin
    if SkinData.FCacheBmp <> Bmp then begin
      if TickMarks = tmTopLeft then RotateBmp180(Bmp, IsVertical);
      TmpBmp := CreateBmp32(WidthOf(aRect, True), HeightOf(aRect, True));
      Stretch(Bmp, TmpBmp, TmpBmp.Width, TmpBmp.Height, ftMitchell);
      BitBlt(SkinData.FCacheBmp.Canvas.Handle, aRect.Left, aRect.Top, WidthOf(aRect), HeightOf(aRect), TmpBmp.Canvas.Handle, 0, 0, SRCCOPY);
      FreeAndNil(TmpBmp);
    end
  end;
begin
  aRect := ThumbRect;
  if IsVertical then i := SkinData.SkinManager.GetMaskIndex(TrackBarNdx, s_TrackBar, s_SliderVertMask) else i := -1;
  if i = -1 then i := SkinData.SkinManager.GetMaskIndex(TrackBarNdx, s_TrackBar, s_SliderHorzMask);
  if SkinData.SkinManager.IsValidImgIndex(i) then with SkinData.SkinManager do begin
    GlyphSize.cx := WidthOfImage(ma[i]);
    GlyphSize.cy := HeightOfImage(ma[i]);
    if not IsVertical and (HeightOf(aRect) = 23) or IsVertical and (WidthOf(aRect) = 23)
      then Stretched := False
      else Stretched := (HeightOf(aRect) <> GlyphSize.cy) or (WidthOf(aRect) <> GlyphSize.cx);
    DrawRect := PrepareBG;
    DrawSkinGlyph(Bmp, point(DrawRect.Left + (WidthOf(DrawRect) - GlyphSize.cx) div 2, DrawRect.Top + (HeightOf(DrawRect) - GlyphSize.cy) div 2), Mode, 1, ma[i], MakeCacheInfo(Bmp));
    ReturnToCache;
    if Bmp <> Self.SkinData.FCacheBmp then FreeAndNil(Bmp);
  end;
end;

function TacTrackWnd.ChannelRect: TRect;
begin
  Result := Rect(0, 0, 1, 1);
  SendMessage(CtrlHandle, TBM_GETCHANNELRECT, 0, longint(@Result));
  if IsVertical then begin
    Changei(Result.Left, Result.Top);
    Changei(Result.Right, Result.Bottom);
  end;
end;

procedure TacTrackWnd.PaintTicksHor;
const
  SelSize = 3;
var
  i, mh : integer;
  pa : TAPoint;
  cr : TRect;
begin
  pa := nil;
  cr := ChannelRect;
  mh := (HeightOf(ThumbRect) - HeightOf(cr)) div 2 + 2;
  if TickStyle <> tsNone then begin
    pa := TicksArray;
    if TickMarks in [tmTopLeft, tmBoth] then for i := 0 to High(pa) do PaintTick(Point(pa[i].x, cr.Top - mh - TickHeight), True);
    if TickMarks in [tmBottomRight, tmBoth] then for i := 0 to High(pa) do PaintTick(Point(pa[i].x, cr.Bottom + mh), True);
  end;
end;

procedure TacTrackWnd.PaintTicksVer;
var
  i, mh : integer;
  pa : TAPoint;
  cr : TRect;
begin
  if TickStyle <> tsNone then begin
    pa := TicksArray;
    cr := ChannelRect;
    mh := (WidthOf(ThumbRect) - WidthOf(cr)) div 2 + 2;
    if TickMarks in [tmTopLeft, tmBoth] then for i := 0 to High(pa) do PaintTick(Point(cr.Left - mh - TickHeight, pa[i].y), False);
    if TickMarks in [tmBottomRight, tmBoth] then for i := 0 to High(pa) do PaintTick(Point(cr.Right + mh, pa[i].y), False);
  end
  else pa := nil;
end;

function TacTrackWnd.TickMarks: TTickMark;
var
  Style : longint;
begin
  Style := GetWindowLong(CtrlHandle, GWL_STYLE);
  if Style and TBS_BOTH = TBS_BOTH
    then Result := tmBoth
    else if Style and TBS_TOP = TBS_TOP
      then Result := tmTopLeft
      else Result := tmBottomRight;
end;

function TacTrackWnd.ThumbRect: TRect;
begin
  Result := Rect(0, 0, 1, 1);
  SendMessage(CtrlHandle, TBM_GETTHUMBRECT, 0, longint(@Result));
end;

function TacTrackWnd.Mode: integer;
begin
  Result := integer(bMousePressed)
end;

function TacTrackWnd.TicksArray: TAPoint;
var
  i, w, c : integer;
  ChRect, ThRect : TRect;
begin
  Result := nil;
  ChRect := ChannelRect;
  ThRect := ThumbRect;
  c := TickCount;
  SetLength(Result, c);
  if TickStyle = tsAuto then begin
    if IsVertical then begin
      iStep := (HeightOf(ChRect) - HeightOf(ThRect)) / (TickCount - 1);
      w := HeightOf(ThRect) div 2;
      for i := 0 to c - 1 do Result[i] := Point(0, Round(ChRect.Top + i * iStep + w));
    end
    else begin
      iStep := (WidthOf(ChRect) - WidthOf(ThRect)) / (TickCount - 1);
      w := WidthOf(ThRect) div 2;
      for i := 0 to c - 1 do Result[i] := Point(Round(ChRect.Left + i * iStep + w), 0);
    end;
  end
  else begin
    if IsVertical then begin
      Result[0] := Point(0, ChRect.Top + HeightOf(ThRect) div 2);
      for i := 0 to c - 3 do Result[i + 1] := Point(0, TickPos(i));
      Result[c - 1] := Point(0, ChRect.Bottom - HeightOf(ThRect) div 2);
    end
    else begin
      Result[0] := Point(ChRect.Left + WidthOf(ThRect) div 2, 0);
      for i := 0 to c - 3 do Result[i + 1] := Point(TickPos(i), 0);
      Result[c - 1] := Point(ChRect.Right - WidthOf(ThRect) div 2, 0);
    end;
  end;
end;

function TacTrackWnd.TickStyle: TTickStyle;
begin
  if GetWindowLong(CtrlHandle, GWL_STYLE) and TBS_NOTICKS = TBS_NOTICKS
    then Result := tsNone
    else Result := tsAuto;
end;

procedure TacTrackWnd.PaintTick(P: TPoint; Horz: boolean);
var
  GlyphIndex : integer;
  w : integer;
  R : TRect;
begin
  if Horz
    then GlyphIndex := SkinData.SkinManager.GetMaskIndex(TrackBarNdx, s_TrackBar, s_TICKHORZ)
    else GlyphIndex := SkinData.SkinManager.GetMaskIndex(TrackBarNdx, s_TrackBar, s_TICKVERT);
  if GlyphIndex <> -1 then begin
    if Horz
      then dec(P.x, WidthOfImage(SkinData.SkinManager.ma[GlyphIndex]))
      else dec(P.y, HeightOfImage(SkinData.SkinManager.ma[GlyphIndex]));
    DrawSkinGlyph(SkinData.FCacheBmp, P, Mode, 1, SkinData.SkinManager.ma[GlyphIndex], MakeCacheInfo(SkinData.FCacheBmp))
  end
  else begin
    if Horz
      then R := Rect(P.x, P.y, P.x + 2, P.Y + TickHeight)
      else R := Rect(P.x, P.y, P.x + TickHeight, P.Y + 2);
    w := 1;
    DrawRectangleOnDC(SkinData.FCacheBmp.Canvas.Handle, R, ColorToRGB(clBtnShadow), ColorToRGB(clWhite), w);
  end;
end;

function TacTrackWnd.TickCount: integer;
begin
  Result := SendMessage(CtrlHandle, TBM_GETNUMTICS, 0, 0);
end;

function TacTrackWnd.TickPos(i: integer): integer;
var
  Value : longint;
begin
  Value := longint(i);
  Result := SendMessage(CtrlHandle, TBM_GETTICPOS, Value, 0);
end;

initialization
  huser32 := LoadLibrary(user32);
  if huser32 <> 0 then Ac_GetScrollBarInfo := GetProcAddress(huser32, 'GetScrollBarInfo');

  hcomctl32 := LoadLibrary(comctl32);
  if hcomctl32 <> 0 then begin
    Ac_UninitializeFlatSB := GetProcAddress(hcomctl32, 'UninitializeFlatSB');
    Ac_InitializeFlatSB := GetProcAddress(hcomctl32, 'InitializeFlatSB');
  end;

finalization
  ClearMnuArray;

  if huser32 <> 0 then FreeLibrary(huser32);
  if hcomctl32 <> 0 then FreeLibrary(hcomctl32);
  if ServWndList <> nil then begin
    while ServWndList.Count > 0 do begin
      TObject(ServWndList[0]).Free;
      ServWndList.Delete(0);
    end;
    FreeAndNil(ServWndList);
    FreeAndNil(acSupportedList);
  end;

end.







