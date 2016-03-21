unit sSkinManager;
{$I sDefs.inc}
{.$DEFINE LOGGED}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, sDefaults,
  sConst, IniFiles, sMaskData, sSkinMenus, jpeg, sStyleSimply, acSkinPack, menus, acntUtils
  {$IFDEF LOGGED}, sDebugMsgs{$ENDIF};

{$IFNDEF NOTFORHELP}
const
  CurrentVersion = '7.33';

{$ENDIF} // NOTFORHELP

{$R sxb.res}

type
  TacSkinTypes = (stUnpacked, stPacked, stAllSkins);
  TacSkinPlaces = (spInternal, spExternal, spAllPlaces);

  TacGetExtraLineData = procedure (FirstItem: TMenuItem; var SkinSection : string; var Caption : string; var Glyph : TBitmap; var LineVisible : boolean) of object;

{$IFNDEF NOTFORHELP}
  TBitmap = Graphics.TBitmap;
  TsSkinManager = class;
  TsStoredSkin = class;
  TacSkinInfo = type string;

  TacSkinEffects = class(TPersistent)
  private
    FAllowGlowing: boolean;
    function GetAllowGlowing: boolean;
  public
    Manager : TsSkinManager;
    constructor Create;
  published
    property AllowGlowing : boolean read GetAllowGlowing write FAllowGlowing default True;
  end;

  TacBtnEffects = class(TPersistent)
  private
    FEvents: TacBtnEvents;
  public
    Manager : TsSkinManager;
    constructor Create;
  published
    property Events : TacBtnEvents read FEvents write FEvents default [beMouseEnter, beMouseLeave, beMouseDown, beMouseUp];
  end;

  TacFormAnimation = class(TPersistent)
  private
    FTime: word;
    FActive: boolean;
    FMode: TacAnimType;
  public
    constructor Create; virtual;
    property Mode : TacAnimType read FMode write FMode default atAero;
  published
    property Active : boolean read FActive write FActive default True;
    property Time : word read FTime write FTime default 0;
  end;

  TacBlendOnMoving = class(TacFormAnimation)
  private
    FBlendValue: byte;
  public
    constructor Create; override;
  published
    property Active default False;
    property BlendValue : byte read FBlendValue write FBlendValue default 170;
    property Time default 1000;
  end;

  TacMinimizing = class(TacFormAnimation)
  public
    constructor Create; override;
  published
    property Time default 200;
  end;

  TacFormShow = class(TacFormAnimation)
  published
    property Mode;
  end;

  TacFormHide = class(TacFormAnimation)
  published
    property Mode;
  end;

  TacPageChange = class(TacFormAnimation);

  TacDialogShow = class(TacFormAnimation)
  public
    constructor Create; override;
  published
    property Time default 0;
    property Mode;
  end;

  TacSkinChanging = class(TacFormAnimation)
  public
    constructor Create; override;
  published
    property Time default 100;
    property Mode default atFading;
  end;

  TacAnimEffects = class(TPersistent)
  private
    FButtons: TacBtnEffects;
    FDialogShow: TacDialogShow;
    FFormShow: TacFormShow;
    FFormHide: TacFormHide;
    FSkinChanging: TacSkinChanging;
    FPageChange: TacPageChange;
    FDialogHide: TacFormHide;
    FMinimizing: TacMinimizing;
    FBlendOnMoving: TacBlendOnMoving;
  public
    Manager : TsSkinManager;
    constructor Create;
    destructor Destroy; override;
  published
    property BlendOnMoving : TacBlendOnMoving read FBlendOnMoving write FBlendOnMoving;
    property Buttons : TacBtnEffects read FButtons write FButtons;
    property DialogShow : TacDialogShow read FDialogShow write FDialogShow;
    property FormShow : TacFormShow read FFormShow write FFormShow;
    property FormHide : TacFormHide read FFormHide write FFormHide;
    property DialogHide : TacFormHide read FDialogHide write FDialogHide;
    property Minimizing : TacMinimizing read FMinimizing write FMinimizing;
    property PageChange : TacPageChange read FPageChange write FPageChange;
    property SkinChanging : TacSkinChanging read FSkinChanging write FSkinChanging;
  end;

  TsStoredSkin = class(TCollectionItem)
  private
    FName: string;
    FMasterBitmap: TBitmap;
    FVersion: real;
    FDescription: string;
    FAuthor: string;
    FShadow1Offset: integer;
    FShadow1Color: TColor;
    FShadow1Blur: integer;
    FShadow1Transparency: integer;
    FBorderColor: TColor;
  protected
    procedure DefineProperties(Filer: TFiler); override;
    procedure ReadData(Reader: TStream);
    procedure WriteData(Writer: TStream);
  public
    PackedData: TMemoryStream;
    procedure Assign(Source: TPersistent); override;
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
  published
    property Name : string read FName write FName;
    property MasterBitmap : TBitmap read FMasterBitmap write FMasterBitmap;

    property Shadow1Color : TColor read FShadow1Color write FShadow1Color;
    property Shadow1Offset : integer read FShadow1Offset write FShadow1Offset;
    property Shadow1Blur : integer read FShadow1Blur write FShadow1Blur default -1;
    property Shadow1Transparency : integer read FShadow1Transparency write FShadow1Transparency;

    property BorderColor : TColor read FBorderColor write FBorderColor default clFuchsia;

    property Version : real read FVersion write FVersion;
    property Author : string read FAuthor write FAuthor;
    property Description : string read FDescription write FDescription;
  end;

  TsStoredSkins = class(TCollection)
  private
    FOwner: TsSkinManager;
    function GetItem(Index: Integer): TsStoredSkin;
    procedure SetItem(Index: Integer; Value: TsStoredSkin);
  protected
    function GetOwner: TPersistent; override;
  public
    procedure Assign(Source: TPersistent); override;
    constructor Create(AOwner: TsSkinManager);
    destructor Destroy; override;
    property Items[Index: Integer]: TsStoredSkin read GetItem write SetItem; default;
    function IndexOf(const SkinName : string) : integer;
  end;

  ThirdPartyList = class(TPersistent)
  private
    FThirdEdits        : string;
    FThirdButtons      : string;
    FThirdBitBtns      : string;
    FThirdCheckBoxes   : string;
    FThirdGroupBoxes   : string;
    FThirdListViews    : string;
    FThirdPanels       : string;
    FThirdGrids        : string;
    FThirdTreeViews    : string;
    FThirdComboBoxes   : string;
    FThirdWWEdits      : string;
    FThirdVirtualTrees : string;
    FThirdGridEh       : string;
    FThirdPageControl  : string;
    FThirdTabControl   : string;
    FThirdToolBar      : string;
    FThirdStatusBar    : string;
    FThirdSpeedButton  : string;
    function GetString(const Index: Integer): string;
    procedure SetString(const Index: Integer; const Value: string);
  published
    property ThirdEdits        : string index ord(tpEdit       ) read GetString write SetString stored True;
    property ThirdButtons      : string index ord(tpButton     ) read GetString write SetString stored True;
    property ThirdBitBtns      : string index ord(tpBitBtn     ) read GetString write SetString stored True;
    property ThirdCheckBoxes   : string index ord(tpCheckBox   ) read GetString write SetString stored True;
    property ThirdGroupBoxes   : string index ord(tpGroupBox   ) read GetString write SetString stored True;
    property ThirdListViews    : string index ord(tpListView   ) read GetString write SetString stored True;
    property ThirdPanels       : string index ord(tpPanel      ) read GetString write SetString stored True;
    property ThirdGrids        : string index ord(tpGrid       ) read GetString write SetString stored True;
    property ThirdTreeViews    : string index ord(tpTreeView   ) read GetString write SetString stored True;
    property ThirdComboBoxes   : string index ord(tpComboBox   ) read GetString write SetString stored True;
    property ThirdWWEdits      : string index ord(tpWWEdit     ) read GetString write SetString stored True;
    property ThirdVirtualTrees : string index ord(tpVirtualTree) read GetString write SetString stored True;
    property ThirdGridEh       : string index ord(tpGridEh     ) read GetString write SetString stored True;
    property ThirdPageControl  : string index ord(tpPageControl) read GetString write SetString stored True;
    property ThirdTabControl   : string index ord(tpTabControl ) read GetString write SetString stored True;
    property ThirdToolBar      : string index ord(tpToolBar    ) read GetString write SetString stored True;
    property ThirdStatusBar    : string index ord(tpStatusBar  ) read GetString write SetString stored True;
    property ThirdSpeedButton  : string index ord(tpSpeedButton) read GetString write SetString stored True;
  end;
{$ENDIF} // NOTFORHELP

  TacSkinningRule = (srStdForms, srStdDialogs, srThirdParty);
  TacSkinningRules = set of TacSkinningRule;

  TsSkinManager = class(TComponent)
  private
{$IFNDEF NOTFORHELP}
    FGroupIndex: integer;
    FSkinName: TsSkinName;
    FSkinDirectory: TsDirectory;
    FActive: boolean;
    FBuiltInSkins: TsStoredSkins;
    FSkinableMenus: TsSkinableMenus;
    FOnAfterChange: TNotifyEvent;
    FOnBeforeChange: TNotifyEvent;
    FSkinnedPopups: boolean;
    FCommonSections: TStringList;
    FIsDefault: boolean;
    FOnGetPopupLineData: TacGetExtraLineData;
    FMenuSupport: TacMenuSupport;
    FAnimEffects: TacAnimEffects;
    FActiveControl: hwnd;
    GlobalHookInstalled : boolean;
    FSkinningRules: TacSkinningRules;
    FThirdParty: ThirdPartyList;
    FExtendedBorders: boolean;
    FEffects: TacSkinEffects;
    procedure SetSkinName(const Value: TsSkinName);
    procedure SetSkinDirectory(const Value: string);
    procedure SetActive(const Value: boolean);
    procedure SetBuiltInSkins(const Value: TsStoredSkins);
    procedure SetSkinnedPopups(const Value: boolean);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    function GetSkinInfo: TacSkinInfo;
    procedure SetSkinInfo(const Value: TacSkinInfo);
    procedure SetHueOffset(const Value: integer);
    procedure SetSaturation(const Value: integer);
    procedure SetIsDefault(const Value: boolean);
    function GetIsDefault: boolean;
    function MainWindowHook(var Message: TMessage): boolean;
    procedure SetActiveControl(const Value: hwnd);
    procedure SetFSkinningRules(const Value: TacSkinningRules);
    procedure SetExtendedBorders(const Value: boolean);
    function GetAllowGlowing: boolean;
    function GetExtendedBorders: boolean;
    procedure SetAllowGlowing(const Value: boolean); {$IFDEF WARN_DEPRECATED} deprecated; {$ENDIF}
  protected
    NonAutoUpdate : boolean;
    procedure SendNewSkin(Repaint : boolean = True);
    procedure SendRemoveSkin;
    procedure LoadAllMasks;
    procedure LoadAllPatterns;
    procedure FreeBitmaps;
    procedure FreeJpegs;
{$ENDIF} // NOTFORHELP
  public
    ShowState : TShowAction;
    SkinData : TsSkinData;
{$IFNDEF NOTFORHELP}
    ma : TsMaskArray;
    pa : TsPatternArray;
    gd : TsGeneralDataArray;
    ConstData : TConstantSkinData;
    MasterBitmap : TBitmap;
    SkinIsPacked : boolean;
    ShdaTemplate : TBitmap;
    ShdiTemplate : TBitmap;

    FormShadowSize : TRect;

    FHueOffset: integer;
    FSaturation: integer;
    ThirdLists : array of TStringList;

    SkinRemoving : boolean;

    procedure InitConstantIndexes;
    procedure CheckShadows;

    procedure LoadAllGeneralData;
    procedure InitMaskIndexes;
    procedure SetCommonSections(const Value: TStringList);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AfterConstruction; override;
    procedure Loaded; override;
    procedure ReloadSkin;
    procedure ReloadPackedSkin;
    procedure InstallHook;
    procedure UnInstallHook;
    procedure CheckVersion;

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure UpdateSkinSection(const SectionName : string);
    property GroupIndex : integer read FGroupIndex write FGroupIndex;
    property SkinableMenus : TsSkinableMenus read FSkinableMenus write FSkinableMenus;
    property ActiveControl : hwnd read FActiveControl write SetActiveControl;
    procedure RepaintForms(DoLockForms : boolean = True);
    function GetSkinIndex(const SkinSection : string) : integer;
    function GetMaskIndex(SkinIndex : integer; const SkinSection, mask : string) : integer; overload;
    function GetMaskIndex(const SkinSection, mask : string) : integer; overload;
    function GetTextureIndex(SkinIndex : integer; const SkinSection, PropName : string) : integer;
    function GetPatternIndex(SkinIndex : integer; const SkinSection, pattern : string) : integer;
{$ENDIF} // NOTFORHELP

    function GetFullSkinDirectory : string;
    function GetSkinNames(sl: TacStrings; SkinType : TacSkinTypes = stAllSkins) : acString;
    function GetExternalSkinNames(sl: TacStrings; SkinType : TacSkinTypes = stAllSkins) : acString;
    procedure GetSkinSections(sl: TStrings);
    procedure ExtractInternalSkin(const NameOfSkin, DestDir : string);
    procedure ExtractByIndex(Index : integer; const DestDir : string);
    procedure UpdateSkin(Repaint : boolean = True);

    function GetRandomSkin : acString;

    function GetGlobalColor : TColor;
    function GetGlobalFontColor : TColor;
    function GetActiveEditColor : TColor;
    function GetActiveEditFontColor : TColor;
    function GetHighLightColor(Focused : boolean = True) : TColor;
    function GetHighLightFontColor(Focused : boolean = True) : TColor;

{$IFNDEF NOTFORHELP}
    procedure BeginUpdate;
    procedure EndUpdate(Repaint : boolean = False; AllowAnimation : boolean = True);
    function MaskWidthTop(MaskIndex : integer) : integer;
    function MaskWidthLeft(MaskIndex : integer) : integer;
    function MaskWidthBottom(MaskIndex : integer) : integer;
    function MaskWidthRight(MaskIndex : integer) : integer;

    function IsValidImgIndex(ImageIndex : integer) : boolean;
    function IsValidSkinIndex(SkinIndex : integer) : boolean;
{$ENDIF} // NOTFORHELP
    property AllowGlowing : boolean read GetAllowGlowing write SetAllowGlowing; // Existing for compatibility with v6. Use Effects.AllowGlowing
  published
    property Effects : TacSkinEffects read FEffects write FEffects;
    property ExtendedBorders : boolean read GetExtendedBorders write SetExtendedBorders default False;
    property SkinnedPopups : boolean read FSkinnedPopups write SetSkinnedPopups default True;
    property AnimEffects : TacAnimEffects read FAnimEffects write FAnimEffects;
    property IsDefault : boolean read GetIsDefault write SetIsDefault default True;
    property Active : boolean read FActive write SetActive default True;
    property CommonSections : TStringList read FCommonSections write SetCommonSections;
    property Saturation : integer read FSaturation write SetSaturation default 0;
    property HueOffset : integer read FHueOffset write SetHueOffset default 0;
    property InternalSkins : TsStoredSkins read FBuiltInSkins write SetBuiltInSkins;
    property MenuSupport : TacMenuSupport read FMenuSupport write FMenuSupport;
    property SkinDirectory : TsDirectory read FSkinDirectory write SetSkinDirectory;
    property SkinName : TsSkinName read FSkinName write SetSkinName;
    property SkinInfo : TacSkinInfo read GetSkinInfo write SetSkinInfo;
    property SkinningRules : TacSkinningRules read FSkinningRules write SetFSkinningRules default [srStdForms, srStdDialogs, srThirdParty];
    property ThirdParty : ThirdPartyList read FThirdParty write FThirdParty;
    property Version : string read GetVersion write SetVersion stored False;
    property OnAfterChange : TNotifyEvent read FOnAfterChange write FOnAfterChange;
    property OnBeforeChange : TNotifyEvent read FOnBeforeChange write FOnBeforeChange;
    property OnGetMenuExtraLineData : TacGetExtraLineData read FOnGetPopupLineData write FOnGetPopupLineData;
  end;

{$IFNDEF NOTFORHELP}
var
  DefaultManager : TsSkinManager;
  SkinFile : TMemIniFile;
  OSVersionInfo: TOSVersionInfo;
  IsNT : boolean;
  sc : TacSkinConvertor;
  UnPackedFirst : boolean = False;
  acMemSkinFile : TStringList;

procedure UpdateCommonDlgs(sManager : TsSkinManager);
procedure UpdatePreview(Handle : HWND; Enabled : boolean);
function ChangeImageInSkin(const SkinSection, PropName, FileName : string; sm : TsSkinManager) : boolean;

procedure ChangeSkinSaturation(sManager : TsSkinManager; Value : integer);
procedure ChangeSkinHue(sManager : TsSkinManager; Value : integer);
procedure ChangeSkinBrightness(sManager : TsSkinManager; Value : integer);

procedure LoadThirdNames(sm : TsSkinManager; Overwrite : boolean = False);
procedure UpdateThirdNames(sm : TsSkinManager);

{$IFNDEF DISABLEPREVIEWMODE}
const
  iMaxFileSize = 30000;
type
  TacSkinData = packed record
    Magic : integer;
    SkinName : array[0..127] of AnsiChar;
    SkinDir : array[0..512] of AnsiChar;
    Data : array[0..iMaxFileSize] of AnsiChar;
  end;
  PacSkinData = ^TacSkinData;

procedure ReceiveData(var Message : TMessage; SkinReceiver : TsSkinManager);
{$ENDIF}

{$ENDIF} // NOTFORHELP

implementation

uses sMessages, sStoreUtils, sVclUtils, sCommonData, acPNG, acGlow, sThirdParty,
  sSkinProps, acDials, FileCtrl, sGraphUtils, sGradient, sSkinProvider, math, sAlphaGraph;

var
  rsta : TBitmap = nil;
  rsti : TBitmap = nil;

{$IFNDEF DISABLEPREVIEWMODE}

procedure ReceiveData(var Message : TMessage; SkinReceiver : TsSkinManager);
var
  cd : TCopyDataStruct;
  sd : TacSkinData;
begin
  if Message.WParam = 7 then begin
    cd := PCopyDataStruct(Message.LParam)^;
    sd := PacSkinData(cd.lpData)^;
    if sd.Magic = ASE_MSG then begin
      UnPackedFirst := True; // Unpacked skins have the first priority

      SkinReceiver.BeginUpdate;
      acMemSkinFile := TStringList.Create;
      acMemSkinFile.Text := sd.Data;

      SkinReceiver.SkinDirectory := sd.SkinDir;
      SkinReceiver.SkinName := sd.SkinName;
      SkinReceiver.EndUpdate(True, False);

      FreeAndNil(acMemSkinFile);

      Message.Result := 1;
    end;
  end;
end;
{$ENDIF}

procedure UpdatePreview(Handle : HWND; Enabled : boolean);
var
  Policy : Longint;
begin
  if ac_ChangeThumbPreviews then begin
    Policy := integer(Enabled);
    if DwmSetWindowAttribute(Handle, 10{DWMWA_HAS_ICONIC_BITMAP}, @Policy, 4) = S_OK
      then DwmSetWindowAttribute(Handle, 7{DWMWA_FORCE_ICONIC_REPRESENTATION}, @Policy, 4);
    DwmInvalidateIconicBitmaps(Handle);
  end;
end;

procedure UpdateCommonDlgs(sManager : TsSkinManager);
begin
{$IFDEF D2007}
  if (DefaultManager = sManager) then UseLatestCommonDialogs := not (srStdDialogs in sManager.SkinningRules) or not sManager.Active;
{$ENDIF}
end;

function ExtInt(const aPos : integer; const s : string; const aDelim : TSysCharSet) : integer;
begin
{$IFDEF DELPHI6UP}
  if not TryStrToInt(ExtractWord(aPos, s, aDelim), Result) then Result := 0;
{$ELSE}
  Result := StrToInt(ExtractWord(aPos, s, aDelim));
{$ENDIF}
end;

function ChangeImageInSkin(const SkinSection, PropName, FileName : string; sm : TsSkinManager) : boolean;
var
  i, l : integer;
  s : string;
begin
  with sm do begin

    Result := False;
    if not SkinData.Active then Exit;
    if (SkinSection = '') or (PropName='') or not FileExists(FileName) then Exit;

    s := UpperCase(PropName);
    // If property is Background texture
    if (s = s_Pattern) or ( s = s_HotPattern) then begin
      // If loaded file is Bitmap
      if pos('.BMP', UpperCase(FileName)) > 0 then begin
        l := Length(ma);
        // ma - is array of records with image description
        if l > 0 then begin
          // search of the required image in the massive
          for i := 0 to l - 1 do begin
            if (UpperCase(ma[i].PropertyName) = s) and (UpperCase(ma[i].ClassName) = UpperCase(skinSection))  then begin
              // If found then we must define new Bmp
              if ma[i].Bmp = nil then ma[i].Bmp := TBitmap.Create;
              ma[i].Bmp.LoadFromFile(FileName);
              // To exit
              Result := True;
              Break;
            end;
          end;
        end;

        // If not found we must to add new image
        if not Result then begin
          l := Length(ma) + 1;
          SetLength(ma, l);
          ma[l - 1].PropertyName := '';
          ma[l - 1].ClassName := '';
          try
            ma[l - 1].Bmp := TBitmap.Create;
            ma[l - 1].Bmp.LoadFromFile(FileName);
          finally
            ma[l - 1].PropertyName := s;
            ma[l - 1].ClassName := UpperCase(skinSection);
            ma[l - 1].Manager := sm;
            ma[l - 1].R := Rect(0, 0, ma[l - 1].Bmp.Width, ma[l - 1].Bmp.Height);
            ma[l - 1].ImageCount := 1;
            ma[l - 1].ImgType := itisaTexture;
          end;
          if ma[l - 1].Bmp.Width < 1 then begin
            FreeAndNil(ma[l - 1].Bmp);
            SetLength(ma, l - 1);
          end;

          l := Length(pa);
          if l > 0 then for i := 0 to l - 1 do if (pa[i].PropertyName = s) and (pa[i].ClassName = UpperCase(skinSection)) then begin
            FreeAndNil(pa[i].Img);

            l := Length(pa) - 1;
            if l <> i then begin
              pa[i].Img          := pa[l].Img         ;
              pa[i].ClassName    := pa[l].ClassName   ;
              pa[i].PropertyName := pa[l].PropertyName;
            end;
            SetLength(pa, l);
            Break;
          end;
          Result := True;
        end;
      end
      // If loaded image is Jpeg, then working with massive of JPegs
      else begin
        l := Length(pa);
        if l > 0 then for i := 0 to l - 1 do if (pa[i].PropertyName = s) and (pa[i].ClassName = UpperCase(skinSection)) then begin
          if not Assigned(pa[i].Img) then pa[i].Img := TJpegImage.Create;
          pa[i].Img.LoadFromFile(FileName);
          Result := True;
          Break;
        end;
        if not Result then begin
          l := Length(pa) + 1;
          SetLength(pa, l);
          try
            pa[l - 1].Img := TJpegImage.Create;
            pa[l - 1].Img.LoadFromFile(FileName);
          finally
            pa[l - 1].PropertyName := s;
            pa[l - 1].ClassName := UpperCase(SkinSection);
          end;
          if pa[l - 1].Img.Width < 1 then begin
            FreeAndNil(pa[l - 1].Img);
            SetLength(pa, l - 1);
          end;
          l := Length(ma);
          if l > 0 then begin
            for i := 0 to l - 1 do begin
              if (ma[i].PropertyName = s) and (ma[i].ClassName = UpperCase(skinSection))  then begin
                FreeAndNil(ma[i].Bmp);

                l := Length(ma) - 1;
                if l <> i then begin
                  ma[i].Bmp          := ma[l].Bmp         ;
                  ma[i].BorderWidth  := ma[l].BorderWidth ;
                  ma[i].ClassName    := ma[l].ClassName   ;
                  ma[i].DrawMode     := ma[l].DrawMode    ;
                  ma[i].ImageCount   := ma[l].ImageCount  ;
                  ma[i].Manager      := ma[l].Manager     ;
                  ma[i].MaskType     := ma[l].MaskType    ;
                  ma[i].PropertyName := ma[l].PropertyName;
                  ma[i].R            := ma[l].R           ;
                  ma[i].WT           := ma[l].WT          ;
                  ma[i].WL           := ma[l].WL          ;
                  ma[i].WR           := ma[l].WR          ;
                  ma[i].WB           := ma[l].WB          ;
                end;
                SetLength(ma, l);
                Break;
              end;
            end;
          end;
        end;
      end;
    end
    // If property is not background texture
    else begin
      if pos('.BMP', FileName) > 0 then begin
        l := Length(ma);
        if l > 0 then for i := 0 to l - 1 do if (ma[i].PropertyName = s) and (ma[i].ClassName = UpperCase(skinSection)) then begin
          ma[i].Bmp.LoadFromFile(FileName);
          Result := True;
          Exit
        end;
      end;
    end;
  end;
end;

procedure ChangeSkinSaturation(sManager : TsSkinManager; Value : integer);
var
  i, l, j, w : integer;
begin
  if Value = 0 then Exit;
  Value := {- }Value mod 101;
  with sManager do begin
    ChangeBmpSaturation(MasterBitmap, Value);

    l := Length(ma);
    for i := 0 to l - 1 do if Assigned(ma[i].Bmp) then ChangeBmpSaturation(ma[i].Bmp, Value);
    l := Length(gd);
    for i := 0 to l - 1 do begin

      gd[i].Color := ChangeSaturation(gd[i].Color, Value);
      gd[i].HotColor := ChangeSaturation(gd[i].HotColor, Value);
      gd[i].GlowColor := ChangeSaturation(gd[i].GlowColor, Value);
      gd[i].HotGlowColor := ChangeSaturation(gd[i].HotGlowColor, Value);

      if gd[i].FontColor[1] <> -1 then gd[i].FontColor[1] := ChangeSaturation(gd[i].FontColor[1], Value);
      if gd[i].FontColor[2] <> -1 then gd[i].FontColor[2] := ChangeSaturation(gd[i].FontColor[2], Value);
      if gd[i].FontColor[3] <> -1 then gd[i].FontColor[3] := ChangeSaturation(gd[i].FontColor[3], Value);
      if gd[i].FontColor[4] <> -1 then gd[i].FontColor[4] := ChangeSaturation(gd[i].FontColor[4], Value);
      if gd[i].FontColor[5] <> -1 then gd[i].FontColor[5] := ChangeSaturation(gd[i].FontColor[5], Value);

      if gd[i].HotFontColor[1] <> -1 then gd[i].HotFontColor[1] := ChangeSaturation(gd[i].HotFontColor[1], Value);
      if gd[i].HotFontColor[2] <> -1 then gd[i].HotFontColor[2] := ChangeSaturation(gd[i].HotFontColor[2], Value);
      if gd[i].HotFontColor[3] <> -1 then gd[i].HotFontColor[3] := ChangeSaturation(gd[i].HotFontColor[3], Value);
      if gd[i].HotFontColor[4] <> -1 then gd[i].HotFontColor[4] := ChangeSaturation(gd[i].HotFontColor[4], Value);
      if gd[i].HotFontColor[5] <> -1 then gd[i].HotFontColor[5] := ChangeSaturation(gd[i].HotFontColor[5], Value);

      for j := 0 to 1 do begin
        if gd[i].Props[j].Color <> -1 then gd[i].Props[j].Color := ChangeSaturation(gd[i].Props[j].Color, Value);
        if gd[i].Props[j].GlowColor <> -1 then gd[i].Props[j].GlowColor := ChangeSaturation(gd[i].Props[j].GlowColor, Value);
        if gd[i].Props[j].FontColor.Color <> -1 then gd[i].Props[j].FontColor.Color := ChangeSaturation(gd[i].Props[j].FontColor.Color , Value);
        if gd[i].Props[j].FontColor.Left  <> -1 then gd[i].Props[j].FontColor.Left  := ChangeSaturation(gd[i].Props[j].FontColor.Left  , Value);
        if gd[i].Props[j].FontColor.Top   <> -1 then gd[i].Props[j].FontColor.Top   := ChangeSaturation(gd[i].Props[j].FontColor.Top   , Value);
        if gd[i].Props[j].FontColor.Right <> -1 then gd[i].Props[j].FontColor.Right := ChangeSaturation(gd[i].Props[j].FontColor.Right , Value);
        if gd[i].Props[j].FontColor.Bottom<> -1 then gd[i].Props[j].FontColor.Bottom:= ChangeSaturation(gd[i].Props[j].FontColor.Bottom, Value);
      end;

      w := WordCount(gd[i].GradientData, [';']) div 5;
      for j := 0 to w - 1 do begin
        gd[i].GradientArray[j].Color1 := ChangeSaturation(gd[i].GradientArray[j].Color1, Value);
        gd[i].GradientArray[j].Color2 := ChangeSaturation(gd[i].GradientArray[j].Color2, Value);
      end;

      w := Length(gd[i].HotGradientArray);
      for j := 0 to w - 1 do begin
        gd[i].HotGradientArray[j].Color1 := ChangeSaturation(gd[i].HotGradientArray[j].Color1, Value);
        gd[i].HotGradientArray[j].Color2 := ChangeSaturation(gd[i].HotGradientArray[j].Color2, Value);
      end;
    end;

    sManager.SkinData.Shadow1Color := ChangeSaturation(sManager.SkinData.Shadow1Color, Value);
    sManager.SkinData.BorderColor := ChangeSaturation(sManager.SkinData.BorderColor, Value);
  end;
end;

procedure ChangeSkinBrightness(sManager : TsSkinManager; Value : integer);
var
  S1 : PRGBAArray;
  i, l, j, w, h, x, y : integer;
begin
  if Value = 0 then Exit;
  with sManager do begin

    if Assigned(MasterBitmap) then begin
      h := MasterBitmap.Height - 1;
      w := MasterBitmap.Width - 1;
      for y := 0 to h do begin
        S1 := MasterBitmap.ScanLine[y];
        for x := 0 to w do begin
          if (S1[X].C <> clFuchsia) then S1[X].C := ChangeBrightness(S1[X].C, Value);
        end
      end;
    end;

    l := Length(ma);
    for i := 0 to l - 1 do if Assigned(ma[i].Bmp) then begin
      h := ma[i].Bmp.Height - 1;
      w := ma[i].Bmp.Width - 1;
      for y := 0 to h do begin
        S1 := ma[i].Bmp.ScanLine[y];
        for x := 0 to w do begin
          if (S1[X].C = clFuchsia) then Continue;
          S1[X].C := ChangeBrightness(S1[X].C, Value);
        end
      end;
    end;

    l := Length(gd);
    for i := 0 to l - 1 do begin
      gd[i].Color := ChangeBrightness(gd[i].Color, Value);
      gd[i].HotColor := ChangeBrightness(gd[i].HotColor, Value);
      gd[i].GlowColor := ChangeBrightness(gd[i].GlowColor, Value);
      gd[i].HotGlowColor := ChangeBrightness(gd[i].HotGlowColor, Value);

      for j := 1 to 5 do begin
        if gd[i].FontColor[j] <> -1 then gd[i].FontColor[j] := ChangeBrightness(gd[i].FontColor[j], Value);
        if gd[i].HotFontColor[j] <> -1 then gd[i].HotFontColor[j] := ChangeBrightness(gd[i].HotFontColor[j], Value);
      end;

      w := WordCount(gd[i].GradientData, [';']) div 5;
      for j := 0 to w - 1 do begin
        gd[i].GradientArray[j].Color1 := ChangeBrightness(gd[i].GradientArray[j].Color1, Value);
        gd[i].GradientArray[j].Color2 := ChangeBrightness(gd[i].GradientArray[j].Color2, Value);
      end;

      w := Length(gd[i].HotGradientArray);
      for j := 0 to w - 1 do begin
        gd[i].HotGradientArray[j].Color1 := ChangeBrightness(gd[i].HotGradientArray[j].Color1, Value);
        gd[i].HotGradientArray[j].Color2 := ChangeBrightness(gd[i].HotGradientArray[j].Color2, Value);
      end;
    end;
  end;
end;

procedure ChangeSkinHue(sManager : TsSkinManager; Value : integer);
var
  i, l, j, w, x, y : integer;
  bmpClose, bmpMin, bmpMax, bmpNorm, bmpHelp, bmpCloseSmall, bmpMaxSmall, bmpMinSmall, bmpNormSmall : TBitmap;
  ExceptNdx : array of integer;
  procedure SaveImage(var Bmp : TBitmap; Name : string);
  var
    Index : integer;
    procedure AddToArray(Ndx : integer);
    begin
      SetLength(ExceptNdx, Length(ExceptNdx) + 1);
      ExceptNdx[Length(ExceptNdx) - 1] := Ndx;
    end;
  begin
    Index := sManager.GetMaskIndex(s_GlobalInfo, Name);
    if (Index > -1) and (sManager.ma[Index].Bmp = nil) { if Image in MasterBitmap } then begin
      Bmp := CreateBmp32(WidthOf(sManager.ma[Index].R), HeightOf(sManager.ma[Index].R));
      Bmp.Transparent := True;
      Bmp.TransparentColor := Index;
      BitBlt(Bmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, sManager.MasterBitmap.Canvas.Handle, sManager.ma[Index].R.Left, sManager.ma[Index].R.Top, SRCCOPY);

      // Close buttons
      if (Name = s_BorderIconClose) or (Name = s_SmallIconClose) then begin
        i := sManager.GetMaskIndex(s_GlobalInfo, Name + s_Glow + ZeroChar);
        if (i > -1) and (sManager.ma[i].Bmp <> nil) then AddToArray(i);
      end
      else if (sManager.SkinData.BIKeepHUE = 1) then begin
        i := sManager.GetMaskIndex(s_GlobalInfo, Name + s_Glow + ZeroChar);
        if (i > -1) and (sManager.ma[i].Bmp <> nil) then AddToArray(i);
      end;
    end
    else begin
      Bmp := nil;

      // Close buttons
      if (Name = s_BorderIconClose) or (Name = s_SmallIconClose) then begin
        AddToArray(Index);
        i := sManager.GetMaskIndex(s_GlobalInfo, Name + s_Glow + ZeroChar);
        if (i > -1) and (sManager.ma[i].Bmp <> nil) then AddToArray(i);
      end
      else if (sManager.SkinData.BIKeepHUE = 1) then begin
        AddToArray(Index);
        i := sManager.GetMaskIndex(s_GlobalInfo, Name + s_Glow + ZeroChar);
        if (i > -1) and (sManager.ma[i].Bmp <> nil) then AddToArray(i);
      end;
    end;
  end;
  procedure RestoreImage(var Bmp : TBitmap);
  var
    i : integer;
  begin
    if (Bmp <> nil) then begin
      i := Bmp.TransparentColor and $FFFF;
      if sManager.IsValidImgIndex(i) then BitBlt(sManager.MasterBitmap.Canvas.Handle, sManager.ma[i].R.Left, sManager.ma[i].R.Top, Bmp.Width, Bmp.Height, Bmp.Canvas.Handle, 0, 0, SRCCOPY);
      FreeAndNil(Bmp);
    end;
  end;
begin
  if Value = 0 then Exit;
  SetLength(ExceptNdx, 0);
  with sManager do begin
    // Save images of border icons if needed
    if SkinData.BIKeepHUE <> 0 then begin
      SaveImage(bmpClose, s_BorderIconClose);
      SaveImage(bmpCloseSmall, s_SmallIconClose);
      if SkinData.BIKeepHUE = 1 then begin
        SaveImage(bmpMax, s_BorderIconMaximize);
        SaveImage(bmpMin, s_BorderIconMinimize);
        SaveImage(bmpNorm, s_BorderIconNormalize);
        SaveImage(bmpHelp, s_BorderIconHelp);
        SaveImage(bmpMaxSmall, s_SmallIconMaximize);
        SaveImage(bmpMinSmall, s_SmallIconMinimize);
        SaveImage(bmpNormSmall, s_SmallIconNormalize);
      end
    end;

    ChangeBmpHUE(MasterBitmap, Value);

    if SkinData.BIKeepHUE <> 0 then begin
      RestoreImage(bmpClose);
      RestoreImage(bmpCloseSmall);
      if SkinData.BIKeepHUE = 1 then begin
        RestoreImage(bmpMax);
        RestoreImage(bmpMin);
        RestoreImage(bmpNorm);
        RestoreImage(bmpHelp);
        RestoreImage(bmpMaxSmall);
        RestoreImage(bmpMinSmall);
        RestoreImage(bmpNormSmall);
      end;
    end;
    l := Length(ma);
    for i := 0 to l - 1 do if Assigned(ma[i].Bmp) then begin
      if (SkinData.BIKeepHUE <> 0) then begin
        x := Length(ExceptNdx) - 1;
        y := 0;
        for j := 0 to x do if (ExceptNdx[j] = i) then begin
          y := 1;
          Break
        end;
        if y = 1 then { if excepted } Continue;
      end;

      ChangeBmpHUE(ma[i].Bmp, Value);
    end;

    l := Length(gd);
    for i := 0 to l - 1 do begin
      gd[i].Color := ChangeHue(Value, gd[i].Color);
      gd[i].HotColor := ChangeHue(Value, gd[i].HotColor);
      gd[i].GlowColor := ChangeHue(Value, gd[i].GlowColor);
      gd[i].HotGlowColor := ChangeHue(Value, gd[i].HotGlowColor);
      for j := 1 to 5 do begin
        if gd[i].FontColor[j] <> -1 then gd[i].FontColor[j] := ChangeHue(Value, gd[i].FontColor[j]);
        if gd[i].HotFontColor[j] <> -1 then gd[i].HotFontColor[j] := ChangeHue(Value, gd[i].HotFontColor[j]);
      end;
      w := WordCount(gd[i].GradientData, [';']) div 5;
      for j := 0 to w - 1 do begin
        gd[i].GradientArray[j].Color1 := ChangeHue(Value, gd[i].GradientArray[j].Color1);
        gd[i].GradientArray[j].Color2 := ChangeHue(Value, gd[i].GradientArray[j].Color2);
      end;
      w := Length(gd[i].HotGradientArray);
      for j := 0 to w - 1 do begin
        gd[i].HotGradientArray[j].Color1 := ChangeHue(Value, gd[i].HotGradientArray[j].Color1);
        gd[i].HotGradientArray[j].Color2 := ChangeHue(Value, gd[i].HotGradientArray[j].Color2);
      end;

      for j := 0 to 1 do begin
        if gd[i].Props[j].Color <> -1 then gd[i].Props[j].Color := ChangeHue(Value, gd[i].Props[j].Color);
        if gd[i].Props[j].GlowColor <> -1 then gd[i].Props[j].GlowColor := ChangeHue(Value, gd[i].Props[j].GlowColor);
        if gd[i].Props[j].FontColor.Color <> -1 then gd[i].Props[j].FontColor.Color := ChangeHue(Value, gd[i].Props[j].FontColor.Color);
        if gd[i].Props[j].FontColor.Left  <> -1 then gd[i].Props[j].FontColor.Left  := ChangeHue(Value, gd[i].Props[j].FontColor.Left);
        if gd[i].Props[j].FontColor.Top   <> -1 then gd[i].Props[j].FontColor.Top   := ChangeHue(Value, gd[i].Props[j].FontColor.Top);
        if gd[i].Props[j].FontColor.Right <> -1 then gd[i].Props[j].FontColor.Right := ChangeHue(Value, gd[i].Props[j].FontColor.Right);
        if gd[i].Props[j].FontColor.Bottom<> -1 then gd[i].Props[j].FontColor.Bottom:= ChangeHue(Value, gd[i].Props[j].FontColor.Bottom);
      end;
    end;
    sManager.SkinData.Shadow1Color := ChangeHue(Value, sManager.SkinData.Shadow1Color);
    sManager.SkinData.BorderColor := ChangeHue(Value, sManager.SkinData.BorderColor);
  end;
  SetLength(ExceptNdx, 0);
end;

procedure LoadThirdNames(sm : TsSkinManager; Overwrite : boolean = False);
var
  i : integer;
begin
  for i := 0 to High(acThirdNames) do begin
    if Overwrite or (sm.ThirdParty.GetString(i) = '') then sm.ThirdParty.SetString(i, acThirdNames[i]);
    sm.ThirdLists[i].Text := sm.ThirdParty.GetString(i);
  end;
end;

procedure UpdateThirdNames(sm : TsSkinManager);
var
  i : integer;
begin
  for i := 0 to High(acThirdNames) do sm.ThirdParty.SetString(i, sm.ThirdLists[i].Text);
end;

{ TsSkinManager }

procedure TsSkinManager.AfterConstruction;
begin
  inherited;
  LoadThirdNames(Self);
  if FSkinDirectory = '' then FSkinDirectory := DefSkinsDir;
  if not (csLoading in ComponentState) and not (csReading in ComponentState) and Assigned(InitDevEx) then InitDevEx(Active and (SkinName <> ''));
end;

constructor TsSkinManager.Create(AOwner: TComponent);
var
  i, l : integer;
begin
  inherited Create(AOwner);
  FEffects := TacSkinEffects.Create;
  FEffects.Manager := Self;
  FThirdParty := ThirdPartyList.Create;
  FExtendedBorders := False;
  NonAutoUpdate := False;
  ShowState := saIgnore;
  FormShadowSize := Rect(0, 0, 0, 0);

  if (DefaultManager = nil) then FIsDefault := True;

  l := High(acThirdNames);
  SetLength(ThirdLists, l + 1);
  for i := 0 to l do begin
    ThirdLists[i] := TStringList.Create;
{$IFDEF DELPHI6UP}
    ThirdLists[i].CaseSensitive := True;
{$ENDIF}
  end;

  SkinData := TsSkinData.Create;
  SkinData.Active := False;
  FBuiltInSkins := TsStoredSkins.Create(Self);
  FCommonSections := TStringList.Create;
{$IFDEF DELPHI6UP}
  FCommonSections.CaseSensitive := True;
{$ENDIF}
  FSkinnedPopups := True;
  FHueOffset := 0;
  FMenuSupport := TacMenuSupport.Create;
  FAnimEffects := TacAnimEffects.Create;
  FAnimEffects.Manager := Self;
  FAnimEffects.Buttons.Manager := Self;
  GlobalHookInstalled := False;
  FSkinningRules := [srStdForms, srStdDialogs, srThirdParty];
  if (DefaultManager = nil) then begin
    DefaultManager := Self;
    if IsNT and not (csDesigning in ComponentState) then Application.HookMainWindow(MainWindowHook);
  end;
  FActive := True;
  SkinRemoving := False;
  FSkinableMenus := TsSkinableMenus.Create(Self);
  SetLength(gd, 0);
  SetLength(ma, 0);
  SetLength(pa, 0);
end;

destructor TsSkinManager.Destroy;
var
  i : integer;
begin
  Active := False;
  FExtendedBorders := False;
  FreeAndNil(FAnimEffects);
  if Assigned(FBuiltInSkins) then FreeAndNil(FBuiltInSkins);
  if Assigned(FSkinableMenus) then FreeAndNil(FSkinableMenus);
  FreeAndNil(FEffects);

  if ShdaTemplate <> nil then FreeAndNil(ShdaTemplate);
  if ShdiTemplate <> nil then FreeAndNil(ShdiTemplate);

  FreeAndNil(FCommonSections);
  if Assigned(SkinData) then FreeAndNil(SkinData);
  FreeAndNil(FMenuSupport);
  FreeJpegs;
  FreeBitmaps;
  if (DefaultManager = Self) then begin
    if IsNT and not (csDesigning in ComponentState) then Application.UnHookMainWindow(MainWindowHook);
    DefaultManager := nil;
  end;

  UpdateThirdNames(Self);

  for i := 0 to Length(ThirdLists) - 1 do if ThirdLists[i] <> nil then FreeAndNil(ThirdLists[i]);
  SetLength(ThirdLists, 0);

  FreeAndNil(FThirdParty);

  inherited Destroy;
end;

procedure TsSkinManager.ExtractByIndex(Index: integer; const DestDir: string);
var
  DirName : string;
begin
  DirName := NormalDir(DestDir);
  if not DirectoryExists(DirName) then begin
    if not CreateDir(DirName) then begin
{$IFNDEF ALITE}
      ShowError('Directory ' + DirName + ' creation error.');
{$ENDIF}
      Exit;
    end;
  end;
  if InternalSkins[Index].PackedData <> nil then InternalSkins[Index].PackedData.SaveToFile(DirName + InternalSkins[Index].Name + ' extracted.asz');
end;

procedure TsSkinManager.ExtractInternalSkin(const NameOfSkin, DestDir: string);
var
  i : integer;
  Executed : boolean;
begin
  Executed := False;
  for i := 0 to InternalSkins.Count - 1 do begin
    if InternalSkins[i].Name = NameOfskin then begin
      if DirectoryExists(Destdir) then begin
        ExtractByIndex(i, Destdir);
{$IFNDEF ALITE}
      end
      else begin
        ShowError('Directory does not exists.');
{$ENDIF}
      end;
      Executed := True;
    end;
  end;
  if not Executed then begin
{$IFNDEF ALITE}
    ShowError('Skin does not exists.');
{$ENDIF}
  end;
end;

function TsSkinManager.GetExternalSkinNames(sl: TacStrings; SkinType : TacSkinTypes = stAllSkins): acString;
var
  FileInfo: TacSearchRec;
  DosCode: Integer;
  s : acString;
  SkinPath : acString;
  stl : TacStringList;
begin
  Result := '';
  SkinPath := GetFullskinDirectory;
  sl.Clear;
  stl := TacStringList.Create;

  // External skins names loading
  if DirectoryExists(SkinPath) then begin
    s := SkinPath + '\*.*';
    DosCode := acFindFirst(s, faDirectory, FileInfo);
    try
      while DosCode = 0 do begin
        if (FileInfo.Name[1] <> '.') then begin
          if (SkinType in [stUnpacked, stAllSkins]) and (FileInfo.Attr and faDirectory = faDirectory) and FileExists(SkinPath + s_Slash + FileInfo.Name + s_Slash + OptionsDatName) then begin
            stl.Add(FileInfo.Name);
            if Result = '' then Result := FileInfo.Name;
          end
          else if (SkinType in [stPacked, stAllSkins]) and (FileInfo.Attr and faDirectory <> faDirectory) and (ExtractFileExt(FileInfo.Name) = '.' + acSkinExt) then begin
            s := ExtractWord(1, FileInfo.Name, ['.']);
            stl.Add(s);
            if Result = '' then Result := s;
          end;
        end;
        DosCode := acFindNext(FileInfo);
      end;
    finally
      acFindClose(FileInfo);
    end;
  end;
  stl.Sort;
  sl.Assign(stl);
  FreeAndNil(stl);
end;

function TsSkinManager.GetFullSkinDirectory: string;
var
  s : string;
begin
  Result := SkinDirectory;
  if (pos('..', Result) = 1) then begin
    s := GetAppPath;
    Delete(s, Length(s), 1);
    while (s[Length(s)] <> '/') and (s[Length(s)] <> s_Slash) do Delete(s, Length(s), 1);
    Delete(Result, 1, 3);
    Result := s + Result;
  end
  else if (pos('.\', Result) = 1) or (pos('./', Result) = 1) then begin
    Delete(Result, 1, 2);
    Result := GetAppPath + Result;
  end
  else if (pos(':', Result) < 1) and (pos('\\', Result) < 1) then Result := GetAppPath + Result;
  NormalDir(Result);
end;

function TsSkinManager.GetGlobalColor: TColor;
begin
  if (ConstData.IndexGlobalInfo > -1) and (ConstData.IndexGlobalInfo <= Length(gd) - 1)
    then Result := ColorToRGB(gd[ConstData.IndexGlobalInfo].Color)
    else Result := ColorToRGB(clBtnFace);
end;

function TsSkinManager.GetGlobalFontColor: TColor;
begin
  if (ConstData.IndexGlobalInfo > -1) and (ConstData.IndexGlobalInfo <= Length(gd) - 1) then Result := ColorToRGB(gd[ConstData.IndexGlobalInfo].FontColor[1]) else Result := clFuchsia;
end;

function TsSkinManager.GetSkinNames(sl: TacStrings; SkinType : TacSkinTypes = stAllSkins) : acString;
var
  FileInfo: TacSearchRec;
  DosCode: Integer;
  s : acString;
  SkinPath : acString;
  stl : TacStringList;
begin
  Result := '';
  SkinPath := GetFullskinDirectory;
  sl.Clear;
  stl := TacStringList.Create;

  // Internal skins names loading
  if InternalSkins.Count > 0 then for DosCode := 0 to InternalSkins.Count - 1 do begin
    stl.Add(InternalSkins[DosCode].Name);
    if Result = '' then Result := InternalSkins[DosCode].Name;
  end;

  // External skins names loading
  if DirectoryExists(SkinPath) then begin
    s := SkinPath + '\*.*';
    DosCode := acFindFirst(s, faDirectory, FileInfo);
    try
      while DosCode = 0 do begin
        if (FileInfo.Name[1] <> '.') then begin
          if (SkinType in [stUnpacked, stAllSkins]) and (FileInfo.Attr and faDirectory = faDirectory) and FileExists(SkinPath + s_Slash + FileInfo.Name + s_Slash + OptionsDatName) then begin
            stl.Add(FileInfo.Name);
            if Result = '' then Result := FileInfo.Name;
          end
          else if (SkinType in [stPacked, stAllSkins]) and (FileInfo.Attr and faDirectory <> faDirectory) and (ExtractFileExt(FileInfo.Name) = '.' + acSkinExt) then begin
            s := ExtractWord(1, FileInfo.Name, ['.']);
            stl.Add(s);
            if Result = '' then Result := s;
          end;
        end;
        DosCode := acFindNext(FileInfo);
      end;
    finally
      acFindClose(FileInfo);
    end;
  end;
  stl.Sort;
  sl.Assign(stl);
  FreeAndNil(stl);
end;

procedure TsSkinManager.GetSkinSections(sl: TStrings);
var
  i : integer;
begin
  sl.Clear;
  if SkinData.Active then for i := Low(gd) to High(gd) do sl.Add(gd[i].ClassName);
end;

function TsSkinManager.GetSkinInfo: TacSkinInfo;
var
  s : char;
begin
  if SkinData.Active then begin
    s := DecimalSeparator;
    DecimalSeparator := '.';
    Result := FloatToStr(SkinData.Version);
    DecimalSeparator := s;
  end
  else Result := 'N/A';
end;

function TsSkinManager.GetVersion: string;
begin
  Result := CurrentVersion {$IFDEF RUNIDEONLY} + ' Trial'{$ENDIF};
end;

procedure TsSkinManager.InitConstantIndexes;
begin
  with ConstData do begin
    IndexGlobalInfo := GetSkinIndex(s_GlobalInfo);
    if IndexGlobalInfo > -1 then begin
      // Global data
      CheckBoxChecked := GetMaskIndex(IndexGlobalInfo, s_GlobalInfo, s_CheckBoxChecked);
      CheckBoxUnChecked := GetMaskIndex(IndexGlobalInfo, s_GlobalInfo, s_CheckBoxUnChecked);
      CheckBoxGrayed := GetMaskIndex(IndexGlobalInfo, s_GlobalInfo, s_CheckBoxGrayed);
      RadioButtonChecked := GetMaskIndex(IndexGlobalInfo, s_GlobalInfo, s_RadioButtonChecked);
      RadioButtonUnChecked := GetMaskIndex(IndexGlobalInfo, s_GlobalInfo, s_RadioButtonUnChecked);
      RadioButtonGrayed := GetMaskIndex(IndexGlobalInfo, s_GlobalInfo, s_RadioButtonGrayed);

      SmallCheckBoxChecked := GetMaskIndex(IndexGlobalInfo, s_GlobalInfo, s_SmallBoxChecked);
      SmallCheckBoxUnChecked := GetMaskIndex(IndexGlobalInfo, s_GlobalInfo, s_SmallBoxUnChecked);
      SmallCheckBoxGrayed := GetMaskIndex(IndexGlobalInfo, s_GlobalInfo, s_SmallBoxGrayed);

      ExBorder := GetMaskIndex(IndexGlobalInfo, s_GlobalInfo, s_ExBorder);
    end
    else begin
      CheckBoxChecked        := -1;
      CheckBoxUnChecked      := -1;
      CheckBoxGrayed         := -1;
      RadioButtonChecked     := -1;
      RadioButtonUnChecked   := -1;
      RadioButtonGrayed      := -1;

      SmallCheckBoxChecked   := -1;
      SmallCheckBoxUnChecked := -1;
      SmallCheckBoxGrayed    := -1;
      ExBorder := -1;
    end;

    // ComboBox
    ComboBtnIndex := GetSkinIndex(s_ComboBtn);
    ComboBtnBorder := GetMaskIndex(s_ComboBtn, s_BordersMask);
    ComboBtnBG := GetTextureIndex(ComboBtnIndex, s_ComboBtn, s_Pattern);
    ComboBtnBGHot := GetTextureIndex(ComboBtnIndex, s_ComboBtn, s_HotPattern);
    ComboGlyph := GetMaskIndex(s_ComboBox, s_ItemGlyph);

    // Tabs
    IndexTabTop := GetSkinIndex(s_TABTOP);
    IndexTabBottom := GetSkinIndex(s_TABBOTTOM);
    IndexTabLeft := GetSkinIndex(s_TABLEFT);
    IndexTabRight := GetSkinIndex(s_TABRIGHT);
    MaskTabTop := GetMaskIndex(IndexTabTop, s_TABTOP, s_BordersMask);
    MaskTabBottom := GetMaskIndex(IndexTabTop, s_TABBOTTOM, s_BordersMask);
    MaskTabLeft := GetMaskIndex(IndexTabTop, s_TABLEFT, s_BordersMask);
    MaskTabRight := GetMaskIndex(IndexTabTop, s_TABRIGHT, s_BordersMask);

    IndexScrollTop := GetSkinIndex(s_SCROLLBTNTOP);
    IndexScrollBottom := GetSkinIndex(s_SCROLLBTNBOTTOM);
    IndexScrollLeft := GetSkinIndex(s_SCROLLBTNLEFT);
    IndexScrollRight := GetSkinIndex(s_SCROLLBTNRIGHT);
    IndexSliderVert := GetSkinIndex(s_SCROLLSLIDERV);
    IndexSliderHorz := GetSkinIndex(s_SCROLLSLIDERH) ;

    MaskScrollTop := GetMaskIndex(IndexScrollTop, s_SCROLLBTNTOP, s_BordersMask);
    if IndexScrollTop > -1 then MaskArrowTop := GetMaskIndex(IndexScrollTop, s_ScrollBtntop, s_ItemGlyph);

    MaskScrollBottom := GetMaskIndex(IndexScrollBottom, s_SCROLLBTNBOTTOM, s_BordersMask);
    if IndexScrollBottom > -1 then MaskArrowBottom := GetMaskIndex(IndexScrollBottom, s_ScrollBtnBottom, s_ItemGlyph);

    MaskScrollLeft := GetMaskIndex(IndexScrollLeft, s_SCROLLBTNLEFT, s_BordersMask);
    if IndexScrollLeft > -1 then MaskArrowLeft := GetMaskIndex(IndexScrollLeft, s_ScrollBtnLeft, s_ItemGlyph);

    MaskScrollRight := GetMaskIndex(IndexScrollRight, s_SCROLLBTNRIGHT, s_BordersMask);
    if IndexScrollRight > -1 then MaskArrowRight := GetMaskIndex(IndexScrollRight, s_ScrollBtnRight, s_ItemGlyph);

    MaskSliderVert := GetMaskIndex(IndexSliderVert, s_SCROLLSLIDERV, s_BordersMask);
    if IndexSLiderVert > -1 then MaskSliderGlyphVert := GetMaskIndex(IndexSLiderVert, s_ScrollSLiderV, s_ItemGlyph);

    MaskSliderHorz := GetMaskIndex(IndexSliderHorz, s_SCROLLSLIDERH, s_BordersMask);
    if IndexSLiderHorz > -1 then MaskSliderGlyphHorz := GetMaskIndex(IndexSLiderHorz, s_ScrollSLiderH, s_ItemGlyph);
    
    IndexBGScrollTop := GetMaskIndex(IndexScrollTop, s_ScrollBtnTop, s_Pattern);
    IndexBGHotScrollTop := GetMaskIndex(IndexScrollTop, s_ScrollBtnTop, s_HotPattern);
    IndexBGScrollBottom := GetMaskIndex(IndexScrollBottom, s_ScrollBtnBottom, s_Pattern);
    IndexBGHotScrollBottom := GetMaskIndex(IndexScrollBottom, s_ScrollBtnBottom, s_HotPattern);
    IndexBGScrollLeft := GetMaskIndex(IndexScrollLeft, s_ScrollBtnLeft, s_Pattern);
    IndexBGHotScrollLeft := GetMaskIndex(IndexScrollLeft, s_ScrollBtnLeft, s_HotPattern);
    IndexBGScrollRight := GetMaskIndex(IndexScrollRight, s_ScrollBtnRight, s_Pattern);
    IndexBGHotScrollRight := GetMaskIndex(IndexScrollRight, s_ScrollBtnRight, s_HotPattern);

    ScrollSliderBGHorz := GetMaskIndex(IndexSLiderHorz, s_ScrollSLiderH, s_Pattern);
    ScrollSliderBGHotHorz := GetMaskIndex(IndexSLiderHorz, s_ScrollSLiderH, s_HotPattern);
    ScrollSliderBGVert := GetMaskIndex(IndexSLiderVert, s_ScrollSLiderV, s_Pattern);
    ScrollSliderBGHotVert := GetMaskIndex(IndexSLiderVert, s_ScrollSLiderV, s_HotPattern);

    //ScrollBars
    IndexScrollBar1H := GetSkinIndex(s_ScrollBar1H);
    IndexScrollBar1V := GetSkinIndex(s_ScrollBar1V);
    IndexScrollBar2H := GetSkinIndex(s_ScrollBar2H);
    IndexScrollBar2V := GetSkinIndex(s_ScrollBar2V);
    MaskScrollBar1H := GetMaskIndex(IndexScrollBar1H, s_ScrollBar1H, s_BordersMask);
    MaskScrollBar1V := GetMaskIndex(IndexScrollBar1V, s_ScrollBar1V, s_BordersMask);
    MaskScrollBar2H := GetMaskIndex(IndexScrollBar2H, s_ScrollBar2H, s_BordersMask);
    MaskScrollBar2V := GetMaskIndex(IndexScrollBar2V, s_ScrollBar2V, s_BordersMask);
    BGScrollBar1H := GetMaskIndex(IndexScrollBar1H, s_ScrollBar1H, s_Pattern);
    BGScrollBar1V := GetMaskIndex(IndexScrollBar1V, s_ScrollBar1V, s_Pattern);
    BGScrollBar2H := GetMaskIndex(IndexScrollBar2H, s_ScrollBar2H, s_Pattern);
    BGScrollBar2V := GetMaskIndex(IndexScrollBar2V, s_ScrollBar2V, s_Pattern);

    BGHotScrollBar1H := GetMaskIndex(IndexScrollBar1H, s_ScrollBar1H, s_HotPattern);
    BGHotScrollBar1V := GetMaskIndex(IndexScrollBar1V, s_ScrollBar1V, s_HotPattern);
    BGHotScrollBar2H := GetMaskIndex(IndexScrollBar2H, s_ScrollBar2H, s_HotPattern);
    BGHotScrollBar2V := GetMaskIndex(IndexScrollBar2V, s_ScrollBar2V, s_HotPattern);
  end;
  InitMaskIndexes;
  CheckShadows;
end;

procedure TsSkinManager.InitMaskIndexes;
var
  i : integer;
begin
  for i := 0 to Length(gd) - 1 do if i <> ConstData.IndexGlobalInfo then begin
    gd[i].BorderIndex := GetMaskIndex(i, gd[i].ClassName, s_BordersMask);
    gd[i].ImgTL := GetMaskIndex(i, gd[i].ClassName, s_ImgTopLeft);
    gd[i].ImgTR := GetMaskIndex(i, gd[i].ClassName, s_ImgTopRight);
    gd[i].ImgBL := GetMaskIndex(i, gd[i].ClassName, s_ImgBottomLeft);
    gd[i].ImgBR := GetMaskIndex(i, gd[i].ClassName, s_ImgBottomRight);
  end;
end;

procedure TsSkinManager.Loaded;
begin
  inherited;
  if FSkinDirectory = '' then FSkinDirectory := DefSkinsDir;
  if FMenuSupport.IcoLineSkin = '' then FMenuSupport.IcoLineSkin := s_MenuIcoLine;
  LoadThirdNames(Self);
  if Active and (SkinName <> '') then SendNewSkin(False);
  UpdateCommonDlgs(Self);
  if not (csLoading in ComponentState) and not (csReading in ComponentState) and Assigned(InitDevEx) then InitDevEx(Active and (SkinName <> ''));
end;

procedure TsSkinManager.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation); 
end;

procedure TsSkinManager.SendNewSkin(Repaint : boolean = True);
var
  M : TMessage;
  i : integer;
begin
  if (csLoading in ComponentState) or (csReading in ComponentState) then Exit;
  ClearGlows;
  if not (csDesigning in ComponentState) and Repaint then LockForms(Self);

  if SkinableMenus <> nil then SkinableMenus.SkinBorderWidth := -1;
  SkinData.Active := False;
  RestrictDrawing := True;

  InitConstantIndexes;

  M.Msg := SM_ALPHACMD;
  M.WParam := MakeWParam(0, AC_SETNEWSKIN);
  M.LParam := longint(Self);
  M.Result := 0;
  if csDesigning in ComponentState then for i := 0 to Screen.FormCount - 1 do begin
    if (Screen.Forms[i].Name = '') or (Screen.Forms[i].Name = 'AppBuilder') or (Screen.Forms[i].Name = 'PropertyInspector') then Continue;
    SendToProvider(Screen.Forms[i], M);
    AlphaBroadCast(Screen.Forms[i], M);
    SendToHooked(M);
  end
  else AppBroadCastS(M);
  RestrictDrawing := False;
  SkinData.Active := True;

  if (DefaultManager = Self) and not GlobalHookInstalled then InstallHook;

  if Assigned(InitDevEx) then InitDevEx(True);
  if Assigned(RefreshDevEx) then RefreshDevEx;
  if {not (csDesigning in ComponentState) and }Repaint then RepaintForms(False);
//  UpdatePreview(Application.Handle, SkinData.Active);
end;

procedure TsSkinManager.SendRemoveSkin;
var
  M : TMessage;
  i : integer;
begin
  if Assigned(InitDevEx) then InitDevEx(False);
  SkinRemoving := True;
  ClearGlows;
  UninstallHook;
  SkinData.Active := False;
  M.Msg := SM_ALPHACMD;
  M.WParam := MakeWParam(0, AC_REMOVESKIN);
  M.LParam := longint(Self);
  M.Result := 0;
  if csDesigning in ComponentState then begin
    for i := 0 to Screen.FormCount - 1 do begin
      if (Screen.Forms[i].Name = '') or
         (Screen.Forms[i].Name = 'AppBuilder') or
         (pos('EditWindow_', Screen.Forms[i].Name)> 0) or
         (pos('DockSite', Screen.Forms[i].Name)> 0) or
         (Screen.Forms[i].Name = 'PropertyInspector') then Continue;
      SendToProvider(Screen.Forms[i], M);
      AlphaBroadCast(Screen.Forms[i], M);
      SendToHooked(M);
    end;
  end
  else begin
    AppBroadCastS(M);
  end;
  FreeBitmaps;
  FreeJpegs;
  SetLength(gd, 0);
//  if not Application.Terminated
//    then UpdatePreview(Application.Handle, False);
  SkinRemoving := False;
end;

procedure TsSkinManager.SetActive(const Value: boolean);
begin
  if FActive <> Value then begin
    FActive := Value;
    if not Value then begin
      if not (csLoading in ComponentState) then SendRemoveSkin;
      InitConstantIndexes;
      UpdateCommonDlgs(Self);
    end
    else begin
      SkinName := FSkinName;
    end;
  end;
end;

procedure TsSkinManager.SetBuiltInSkins(const Value: TsStoredSkins);
begin
  FBuiltInSkins.Assign(Value);
end;

procedure TsSkinManager.SetCommonSections(const Value: TStringList);
var
  i : integer;
  s : string;
begin
  FCommonSections.Assign(Value);
  for i := 0 to FCommonSections.Count - 1 do begin
    s := FCommonSections[i];
    if (s <> '') and (s[1] <> ';') then FCommonSections[i] := acntUtils.DelChars(s, s_Space);
  end;
  SkinName := SkinName;
end;

procedure TsSkinManager.SetSkinDirectory(const Value: string);
begin
  if FSkinDirectory <> Value then begin
    FSkinDirectory := Value;
    SkinData.SkinPath := GetFullSkinDirectory;
  end;
end;

procedure TsSkinManager.SetSkinName(const Value: TsSkinName);
var
  s, OldName : string;
begin
  OldName := FSkinName;
  FSkinName := Value;
  if FActive then begin

    if Assigned(FOnBeforeChange) then FOnBeforeChange(Self);

    // Save form image to layered window if ExtendedBorders
    if ExtendedBorders and not NonAutoUpdate and AnimEffects.SkinChanging.Active then CopyExForms(Self);

    aSkinChanging := True;
    SkinData.Active := False;
    s := NormalDir(SkinDirectory) + Value + '.' + acSkinExt;
    SkinIsPacked := False;
    if UnPackedFirst and DirectoryExists(NormalDir(SkinDirectory) + Value) then SkinIsPacked := False else SkinIsPacked := FileExists(s);

    try
      if SkinIsPacked
        then ReloadPackedSkin
        else ReloadSkin;
    except
      on E: Exception do begin
        FSkinName := OldName;
        ShowError(E.Message);
      end;
    end;

    if FActive then begin
      if not NonAutoUpdate then SendNewSkin;
    end
    else SendRemoveSkin;
    aSkinChanging := False;
    if Assigned(FOnAfterChange) then FOnAfterChange(Self);
  end;
  UpdateCommonDlgs(Self);
end;

procedure TsSkinManager.SetSkinnedPopups(const Value: boolean);
begin
  if FSkinnedPopups <> Value then begin
    FSkinnedPopups := Value;
    if not (csDesigning in ComponentState) and FSkinnedPopups and (SkinableMenus <> nil) and IsDefault then SkinableMenus.UpdateMenus;
  end;
end;

procedure TsSkinManager.SetSkinInfo(const Value: TacSkinInfo); begin end;

procedure TsSkinManager.SetVersion(const Value: string); begin end;

procedure TsSkinManager.UpdateSkin(Repaint : boolean = True);
begin
  if Active then SendNewSkin(Repaint);
end;

procedure TsSkinManager.UpdateSkinSection(const SectionName: string);
var
  M : TMessage;
  i : integer;
begin
  GlobalSectionName := UpperCase(SectionName);

  M.Msg := SM_ALPHACMD;
  M.WParamHi := AC_UPDATESECTION;
  M.Result := 0;
  if csDesigning in ComponentState then begin
    for i := 0 to Screen.FormCount - 1 do begin
      AlphaBroadCast(Screen.Forms[i], M);
    end;
  end
  else begin
    AppBroadCastS(M);
  end;
end;

procedure TsSkinManager.RepaintForms(DoLockForms : boolean = True);
var
  M : TMessage;
  i : integer;
  ap : TacProvider;
begin
  M.Msg := SM_ALPHACMD;
  M.LParam := longint(Self);

  if not (csDesigning in ComponentState) then begin
    M.WParam := MakeWParam(0, AC_STOPFADING);
    M.Result := 0;
    AppBroadCastS(M);
  end;

  M.WParam := MakeWParam(0, AC_REFRESH);
  M.Result := 0;
  if csDesigning in ComponentState then for i := 0 to Screen.FormCount - 1 do begin
    if (Screen.Forms[i].Name = '') or (Screen.Forms[i].Name = 'AppBuilder') or (Screen.Forms[i].Name = 'PropertyInspector') then Continue;
    AlphaBroadCast(Screen.Forms[i], M);
    SendToProvider(Screen.Forms[i], M);
    SendToHooked(M);
  end
  else begin
    if not (csLoading in ComponentState) {and (Application.MainForm <> nil) Changing in DLL}then begin
      if DoLockForms then LockForms(Self);
      AppBroadCastS(M);
      UnLockForms(Self);
    end
    else AppBroadCastS(M);
  end;
  if Assigned(acMagnForm) then SendMessage(acMagnForm.Handle, M.Msg, M.WParam, M.LParam);
  // Repaint dialogs
  if acSupportedList <> nil then begin
    for i := 0 to acSupportedList.Count - 1 do begin
      ap := TacProvider(acSupportedList[i]);
      if (ap <> nil) and (ap.ListSW <> nil) and IsWindowVisible(ap.ListSW.CtrlHandle)
        then RedrawWindow(ap.ListSW.CtrlHandle, nil, 0, RDW_ERASE or RDW_FRAME or {RDW_INTERNALPAINT or }RDW_INVALIDATE or RDW_UPDATENOW or RDW_ALLCHILDREN);// or RDW_ERASENOW);
    end;
  end;
end;

procedure TsSkinManager.SetHueOffset(const Value: integer);
var
  s : string;
begin
  if FHueOffset <> Value then begin
    FHueOffset := Value;

    if FActive and not (csLoading in ComponentState) and not (csReading in ComponentState) then begin
      aSkinChanging := True;
      s := NormalDir(SkinDirectory) + SkinName + '.' + acSkinExt;
      SkinIsPacked := FileExists(s);

      if SkinIsPacked then ReloadPackedSkin else ReloadSkin;
      aSkinChanging := False;
      if not NonAutoUpdate then RepaintForms;
    end
  end;
end;

procedure TsSkinManager.SetSaturation(const Value: integer);
var
  s : string;
begin
  if FSaturation <> Value then begin
    FSaturation := Value;
    if FActive and not (csLoading in ComponentState) and not (csReading in ComponentState) then begin
      aSkinChanging := True;
      s := NormalDir(SkinDirectory) + SkinName + '.' + acSkinExt;
      SkinIsPacked := FileExists(s);

      if SkinIsPacked then ReloadPackedSkin else ReloadSkin;
      aSkinChanging := False;
      if not NonAutoUpdate then RepaintForms;
    end
  end;
end;

function TsSkinManager.GetActiveEditColor: TColor;
begin
  if (ConstData.IndexGlobalInfo > -1) and (ConstData.IndexGlobalInfo <= Length(gd) - 1)
    then Result := ColorToRGB(gd[ConstData.IndexGlobalInfo].HotColor)
    else Result := ColorToRGB(clWindow);
end;

function TsSkinManager.GetActiveEditFontColor: TColor;
var
  i : integer;
begin
  i := GetSkinIndex(s_Edit);
  if (i > -1) then Result := ColorToRGB(gd[i].Props[0].FontColor.Color) else Result := clWindowText;
end;

function TsSkinManager.GetHighLightColor(Focused : boolean = True): TColor;
var
  i : integer;
begin
  i := GetSkinIndex(s_Selection);
  if IsValidSkinIndex(i) then Result := gd[i].Props[integer(Focused and (gd[i].States > 1))].Color else Result := -1;
  if (Result = -1) or (Result = clFuchsia) then begin
    i := GetSkinIndex(s_MenuItem);
    if IsValidSkinIndex(i) then begin
      Result := gd[i].HotColor;
      if (Result <> -1) and (Result <> clFuchsia) and (Result <> clWhite) then Result := ColorToRGB(Result) else Result := clHighLight
    end
    else Result := clHighLight;
  end
  else Result := ColorToRGB(Result);
end;

function TsSkinManager.GetHighLightFontColor(Focused : boolean = True): TColor;
var
  i : integer;
begin
  i := GetSkinIndex(s_Selection);
  if IsValidSkinIndex(i) then Result := gd[i].Props[integer(Focused and (gd[i].States > 1))].FontColor.Color else Result := -1;
  if (Result = -1) or (Result = clFuchsia) then begin
    i := GetSkinIndex(s_MenuItem);
    if IsValidSkinIndex(i) then begin
      Result := gd[i].HotFontColor[1];
      if (Result <> -1) and (Result <> clFuchsia) then Result := ColorToRGB(Result) else Result := clHighLightText
    end
    else Result := clHighLightText;
  end;
end;

function TsSkinManager.IsValidImgIndex(ImageIndex: integer): boolean;
begin
  Result := (ImageIndex > -1) and (ImageIndex < Length(ma));
end;

function TsSkinManager.IsValidSkinIndex(SkinIndex: integer): boolean;
begin
  Result := (SkinData <> nil) and (SkinIndex > -1) and (SkinIndex < Length(gd));
end;

procedure TsSkinManager.LoadAllMasks;
var
  sf : TMemIniFile;
  Sections, Values : TStringList;
  i, j, l : integer;
  s, subs, s1 : string;
  TempBmp : TBitmap;
  b : boolean;
  Png : TPNGGraphic;
begin
  FreeBitmaps;
  if SkinFile <> nil then begin
    sf := SkinFile;
    // Reading of the MasterBitmap if exists
    s := sf.ReadString(s_GLOBALINFO, s_MASTERBITMAP, '');
    MasterBitmap := TBitmap.Create;
    if SkinIsPacked then begin
      for i := 0 to sc.ImageCount - 1 do if UpperCase(sc.Files[i].FileName) = s then begin
        sc.Files[i].FileStream.Seek(0, 0);
        MasterBitmap.LoadFromStream(sc.Files[i].FileStream);
        MasterBitmap.Canvas.Handle;
        MasterBitmap.Canvas.Lock;
        Break
      end;
    end
    else begin
      if (pos(':', s) < 1) then s := SkinData.SkinPath + s;
      if (s <> '') and FileExists(s) then MasterBitmap.LoadFromFile(s);
    end;

    if MasterBitmap.PixelFormat <> pf32bit then begin
      MasterBitmap.PixelFormat := pf32bit;
      FillAlphaRect(MasterBitmap, Rect(0, 0, MasterBitmap.Width, MasterBitmap.Height), MaxByte, True);
    end;
    MasterBitmap.Transparent := True;
    MasterBitmap.TransparentColor := clFuchsia;
    MasterBitmap.HandleType := bmDIB;

    Sections := TStringList.Create;
{$IFDEF DELPHI6UP}
    Sections.CaseSensitive := True;
{$ENDIF}
    Values := TStringList.Create;
{$IFDEF DELPHI6UP}
    Values.CaseSensitive := True;
{$ENDIF}
    try sf.ReadSections(Sections);
    for i := 0 to Sections.Count - 1 do begin
      sf.ReadSection(Sections[i], Values);
      for j := 0 to Values.Count - 1 do begin
        if (Sections[i] = s_GLOBALINFO) and (Values[j] = s_MasterBitmap) then Continue; // Check for MASTERBITMAP property
        s := sf.ReadString(Sections[i], Values[j], '');
        if (s <> '') then begin
          case s[1] of
            TexChar : begin
              l := Length(ma);
              SetLength(ma, l + 1);
              ma[l].PropertyName := Values[j];
              ma[l].ClassName := Sections[i];
              ma[l].Manager := Self;
              ma[l].ImgType := itisaTexture;
              ma[l].R := Rect(StrToInt(Copy(s, 2, 4)), StrToInt(Copy(s, 7, 4)), StrToInt(Copy(s, 12, 4)), StrToInt(Copy(s, 17, 4)));
              ma[l].ImageCount := 1;
              ma[l].DrawMode := StrToInt(Copy(s, 22, 2));
              if Length(s) > 24
                then ma[l].MaskType := StrToInt(Copy(s, 25, 1))
                else ma[l].MaskType := 0;
            end;
            CharGlyph : begin
              l := Length(ma);
              SetLength(ma, l + 1);
              ma[l].PropertyName := Values[j];
              ma[l].ClassName := Sections[i];
              ma[l].Manager := Self;
              ma[l].ImgType := itisaGlyph;
              ma[l].R := Rect(StrToInt(Copy(s, 2, 4)), StrToInt(Copy(s, 7, 4)), StrToInt(Copy(s, 12, 4)), StrToInt(Copy(s, 17, 4)));
              ma[l].ImageCount := StrToInt(Copy(s, 22, 1));
              ma[l].MaskType := StrToInt(Copy(s, 24, 1));
            end;
            CharMask : begin
              l := Length(ma);
              SetLength(ma, l + 1);
              ma[l].PropertyName := Values[j];
              ma[l].ClassName := Sections[i];
              ma[l].Manager := Self;
              ma[l].ImgType := itisaBorder;
              ma[l].R := Rect(StrToInt(Copy(s, 2, 4)), StrToInt(Copy(s, 7, 4)), StrToInt(Copy(s, 12, 4)), StrToInt(Copy(s, 17, 4)));
              ma[l].WL := StrToInt(Copy(s, 22, 4));
              ma[l].WT := StrToInt(Copy(s, 27, 4));
              ma[l].WR := StrToInt(Copy(s, 32, 4));
              ma[l].WB := StrToInt(Copy(s, 37, 4));
              ma[l].ImageCount := StrToInt(Copy(s, 42, 1));
              ma[l].MaskType := StrToInt(Copy(s, 44, 1));
              ma[l].DrawMode := StrToInt(Copy(s, 46, 1));
              ma[l].BorderWidth := StrToInt(Copy(s, 48, 1));
              if ma[l].WL + ma[l].WT + ma[l].WR + ma[l].WB = 0 then begin // If BorderWidths are not defined
                if ma[l].BorderWidth <> 0 then begin
                  ma[l].WL := ma[l].BorderWidth;
                  ma[l].WT := ma[l].BorderWidth;
                  ma[l].WR := ma[l].BorderWidth;
                  ma[l].WB := ma[l].BorderWidth;
                end
                else begin
                  ma[l].WL := WidthOf(ma[l].R) div (ma[l].ImageCount * 3);
                  ma[l].WT := HeightOf(ma[l].R) div ((1 + ma[l].MaskType) * 3);
                  ma[l].WR := ma[l].WL;
                  ma[l].WB := ma[l].WT;
                end;
              end;
            end;
            CharExt : begin
              s1 := ExtractWord(1, s, [CharExt]);
              b := pos('.BMP', s1) > 0;
              if b or (pos('.PNG', s1) > 0) then begin                              // Else if bitmap assigned
                TempBmp := nil;
                if SkinIsPacked then begin
                  for l := 0 to sc.ImageCount - 1 do if UpperCase(sc.Files[l].FileName) = s1 then begin
                    TempBmp := TBitmap.Create;
                    sc.Files[l].FileStream.Seek(0, 0);
                    if b then { if is bitmap } TempBmp.LoadFromStream(sc.Files[l].FileStream) else begin // If is PNG
                      Png := TPNGGraphic.Create;
                      Png.LoadFromStream(sc.Files[l].FileStream);
                      TempBmp.Assign(Png);
                      UpdateTransPixels(TempBmp);
                      FreeAndNil(Png);
                    end;
                    break;
                  end;
                end
                else begin
                  if (pos(':', s1) < 1) then s1 := SkinData.SkinPath + s1;
                  if FileExists(s1) then begin
                    TempBmp := TBitmap.Create;
                    if b then { if is bitmap } TempBmp.LoadFromFile(s1) else begin // If is PNG
                      Png := TPNGGraphic.Create;
                      Png.LoadFromFile(s1);
                      TempBmp.Assign(Png);
                      UpdateTransPixels(TempBmp);
                      FreeAndNil(Png);
                    end;
                  end;
                end;
                if (TempBmp <> nil) and (TempBmp.Width > 0) then begin
                  l := Length(ma);
                  SetLength(ma, l + 1);
                  try
                    ma[l].Bmp := TempBmp;
                    ma[l].Bmp.Canvas.Handle;
                    ma[l].Bmp.Canvas.Lock;
                    ma[l].ImgType := acImgTypes[Min(ExtInt(4, s, [CharExt]), Length(acImgTypes) - 1)];
                    if ma[l].Bmp.PixelFormat <> pf32bit then begin
                      ma[l].Bmp.PixelFormat := pf32bit;
                      FillAlphaRect(ma[l].Bmp, Rect(0, 0, ma[l].Bmp.Width, ma[l].Bmp.Height), MaxByte, True);
                    end;
                  finally
                    ma[l].PropertyName := Values[j];
                    ma[l].ClassName := Sections[i];
                    ma[l].Manager := Self;
                    ma[l].ImageCount := ExtInt(2, s, [CharExt]);
                    ma[l].MaskType := ExtInt(3, s, [CharExt]);
                    ma[l].R := Rect(0, 0, ma[l].Bmp.Width, ma[l].Bmp.Height);
                    if WordCount(s, [CharExt]) > 4 then begin // if border widths are defined
                      ma[l].WL := ExtInt(5, s, [CharExt]);
                      ma[l].WT := ExtInt(6, s, [CharExt]);
                      ma[l].WR := ExtInt(7, s, [CharExt]);
                      ma[l].WB := ExtInt(8, s, [CharExt]);
                    end
                    else with ma[l] do begin
                      ma[l].WL := WidthOf(ma[l].R) div (ImageCount * 3);
                      ma[l].WT := HeightOf(ma[l].R) div ((1 + MaskType) * 3);
                      ma[l].WR := ma[l].WL;
                      ma[l].WB := ma[l].WT;
                    end;
                    if WordCount(s, [CharExt]) > 8
                      then ma[l].DrawMode := ExtInt(9, s, [CharExt])
                      else ma[l].DrawMode := {BDM_FILL or }BDM_STRETCH;
                  end;
                end;
              end;
            end
            else begin
              if (pos(CharDiez, s) > 0) then begin       // Reading of the MasterBitmap item
                if s = CharDiez then Continue;
                l := Length(ma) + 1;
                SetLength(ma, l);

                ma[l - 1].PropertyName := UpperCase(Values[j]);
                ma[l - 1].ClassName := UpperCase(Sections[i]);
                ma[l - 1].Manager := Self;
                subs := ExtractWord(2, s, [')', '(', s_Space]);
                ma[l - 1].R := Rect(ExtInt(1, subs, [s_Space, s_Space]),
                                    ExtInt(2, subs, [s_Comma, s_Space]),
                                    ExtInt(3, subs, [s_Comma, s_Space]),
                                    ExtInt(4, subs, [s_Comma, s_Space]));

                subs := ExtractWord(3, s, [')', '(', s_Space]);
                ma[l - 1].ImageCount := ExtInt(1, subs, [s_Comma, s_Space]);
                if ma[l - 1].ImageCount < 1 then ma[l - 1].ImageCount := 1;
                ma[l - 1].MaskType := ExtInt(2, subs, [s_Comma, s_Space]);
                if ma[l - 1].MaskType < 0 then ma[l - 1].MaskType := 0;
                // BorderWidth
                s1 := ExtractWord(3, subs, [s_Comma, s_Space]);
                if s1 <> '' then begin
                  ma[l - 1].BorderWidth := StrToInt(s1);
                  if ma[l - 1].BorderWidth < 0 then ma[l - 1].BorderWidth := 0;
                end
                else ma[l - 1].BorderWidth := 0;
                // StretchMode
                s1 := ExtractWord(4, subs, [s_Comma, s_Space]);
                if s1 <> ''
                  then ma[l - 1].DrawMode := StrToInt(s1)
                  else ma[l - 1].DrawMode := 1; // Stretching of borders is allowed if possible
                with ma[l - 1] do begin
                  if WL + WT + WR + WB = 0 then begin // If BorderWidths are not defined
                    if BorderWidth <> 0 then begin
                      WL := BorderWidth;
                      WT := BorderWidth;
                      WR := BorderWidth;
                      WB := BorderWidth;
                    end
                    else begin
                      WL := WidthOf(ma[l - 1].R) div (ImageCount * 3);
                      WT := HeightOf(ma[l - 1].R) div ((1 + MaskType) * 3);
                      WR := WL;
                      WB := WT;
                    end;
                  end;
                end;
                Continue;
              end;
              s := AnsiUpperCase(s);
              if (pos('.BMP', s) > 0) then begin                              // Else if bitmap assigned
                TempBmp := nil;
                if SkinIsPacked then begin
                  for l := 0 to sc.ImageCount - 1 do if UpperCase(sc.Files[l].FileName) = s then begin
                    TempBmp := TBitmap.Create;
                    sc.Files[l].FileStream.Seek(0, 0);
                    TempBmp.LoadFromStream(sc.Files[l].FileStream);
                    break;
                  end;
                end
                else begin
                  if (pos(':', s) < 1) then s := SkinData.SkinPath + s;
                  if FileExists(s) then begin
                    TempBmp := TBitmap.Create;
                    TempBmp.LoadFromFile(s);
                  end;
                end;

                if (TempBmp <> nil) and (TempBmp.Width > 0) then begin
                  l := Length(ma) + 1;
                  SetLength(ma, l);
                  ma[l - 1].Bmp := TempBmp;
                  ma[l - 1].Bmp.Canvas.Handle;
                  ma[l - 1].Bmp.Canvas.Lock;
                  ma[l - 1].PropertyName := '';
                  ma[l - 1].ClassName := '';
                  ma[l - 1].Manager := Self;
                  try
                    if ma[l - 1].Bmp.PixelFormat <> pf32bit then begin
                      ma[l - 1].Bmp.PixelFormat := pf32bit;
                      FillAlphaRect(ma[l - 1].Bmp, Rect(0, 0, ma[l - 1].Bmp.Width, ma[l - 1].Bmp.Height), MaxByte, True);
                    end;
                  finally
                    ma[l - 1].PropertyName := UpperCase(Values[j]);
                    ma[l - 1].ClassName := UpperCase(Sections[i]);
                    ma[l - 1].MaskType := 1;
                    ma[l - 1].ImageCount := 3;
                    ma[l - 1].R := Rect(0, 0, ma[l - 1].Bmp.Width, ma[l - 1].Bmp.Height);
                    ma[l - 1].WL := WidthOf(ma[l - 1].R) div (ma[l - 1].ImageCount * 3);
                    ma[l - 1].WT := HeightOf(ma[l - 1].R) div ((1 + ma[l - 1].MaskType) * 3);
                    ma[l - 1].WR := ma[l - 1].WL;
                    ma[l - 1].WB := ma[l - 1].WT;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;

    finally
      if Assigned(Values) then FreeAndNil(Values);
      if Assigned(Sections) then FreeAndNil(Sections);
      sf := nil;
    end;
  end;

  // CommonSection property in TsSkinManager
  if CommonSections.Count > 0 then begin
    sf := TMemInifile.Create('1.tmp');
{$IFDEF DELPHI6UP}
    sf.CaseSensitive := True;
{$ENDIF}
    sf.SetStrings(CommonSections);

    Sections := TStringList.Create;
{$IFDEF DELPHI6UP}
    Sections.CaseSensitive := True;
{$ENDIF}
    Values := TStringList.Create;
{$IFDEF DELPHI6UP}
    Values.CaseSensitive := True;
{$ENDIF}
    try

    sf.ReadSections(Sections);
    sf.SetStrings(CommonSections);
    for i := 0 to Sections.Count - 1 do begin
      if UpperCase(Sections[i]) = s_GLOBALINFO then Continue;
      sf.ReadSection(Sections[i], Values);
      for j := 0 to Values.Count - 1 do begin
        s := sf.ReadString(Sections[i], Values[j], '-');


        if (MasterBitmap <> nil) and (pos(CharDiez, s) > 0) then begin       // Reading of the MasterBitmap item
          if s = CharDiez then Continue;
          l := Length(ma) + 1;
          SetLength(ma, l);

          ma[l - 1].PropertyName := UpperCase(Values[j]);
          ma[l - 1].ClassName := UpperCase(Sections[i]);
          ma[l - 1].Manager := Self;

          subs := ExtractWord(2, s, [')', '(', s_Space]);
          ma[l - 1].R := Rect(ExtInt(1, subs, [s_Comma, s_Space]),
                              ExtInt(2, subs, [s_Comma, s_Space]),
                              ExtInt(3, subs, [s_Comma, s_Space]),
                              ExtInt(4, subs, [s_Comma, s_Space]));

          subs := ExtractWord(3, s, [')', '(', s_Space]);
          ma[l - 1].ImageCount := ExtInt(1, subs, [s_Comma, s_Space]);
          if ma[l - 1].ImageCount < 1 then ma[l - 1].ImageCount := 1;
          ma[l - 1].MaskType := ExtInt(2, subs, [s_Comma, s_Space]);
          if ma[l - 1].MaskType < 0 then ma[l - 1].MaskType := 0;

          // BorderWidth
          s1 := ExtractWord(3, subs, [s_Comma, s_Space]);
          if s1 <> '' then begin
            ma[l - 1].BorderWidth := StrToInt(s1);
            if ma[l - 1].BorderWidth < 0 then ma[l - 1].BorderWidth := 0;
          end
          else ma[l - 1].BorderWidth := 0;

          // StretchMode
          s1 := ExtractWord(4, subs, [s_Comma, s_Space]);
          if s1 <> ''
            then ma[l - 1].DrawMode := StrToInt(s1)
            else ma[l - 1].DrawMode := 1;
          with ma[l - 1] do begin
            if WL + WT + WR + WB = 0 then begin // If BorderWidths are not defined
              if BorderWidth <> 0 then begin
                WL := BorderWidth;
                WT := BorderWidth;
                WR := BorderWidth;
                WB := BorderWidth;
              end
              else begin
                WL := WidthOf(ma[l - 1].R) div (ImageCount * 3);
                WT := HeightOf(ma[l - 1].R) div ((1 + MaskType) * 3);
                WR := WL;
                WB := WT;
              end;
            end;
          end;
          Continue;
        end;
        s := AnsiUpperCase(s);
        if (pos('.BMP', s) > 0) then begin                              // Else if bitmap assigned
          if (pos(':', s) < 1) then begin
            s := SkinData.SkinPath + s;
          end;
          if FileExists(s) then begin
            l := Length(ma) + 1;
            SetLength(ma, l);
            ma[l - 1].PropertyName := '';
            ma[l - 1].ClassName := '';
            ma[l - 1].Manager := Self;
            try
              ma[l - 1].Bmp := TBitmap.Create;
              ma[l - 1].Bmp.LoadFromFile(s);
              if ma[l - 1].Bmp.PixelFormat <> pf32bit then begin
                ma[l - 1].Bmp.PixelFormat := pf32bit;
                FillAlphaRect(ma[l - 1].Bmp, Rect(0, 0, ma[l - 1].Bmp.Width, ma[l - 1].Bmp.Height), MaxByte, True);
              end;
            finally
              ma[l - 1].PropertyName := UpperCase(Values[j]);
              ma[l - 1].ClassName := UpperCase(Sections[i]);
            end;
            if (ma[l - 1].Bmp.Width < 1) then begin
              if Assigned(ma[l - 1].bmp) then FreeAndNil(ma[l - 1].Bmp);
              SetLength(ma, l - 1);
            end
          end
        end
      end
    end;
    finally
      if Assigned(Values) then FreeAndNil(Values);
      FreeAndNil(sf);
      FreeAndNil(Sections);
    end;
  end;
end;

procedure TsSkinManager.LoadAllPatterns;
var
  sf : TMemIniFile;
  Sections, Values : TStringList;
  i, j, l, n : integer;
  s : string;
  TempJpg : TJpegImage;
begin
  FreeJpegs;

  if SkinFile <> nil then begin // Loading from external skin

    sf := SkinFile;
    Sections := TStringList.Create;
{$IFDEF DELPHI6UP}
    Sections.CaseSensitive := True;
{$ENDIF}
    Values := TStringList.Create;
{$IFDEF DELPHI6UP}
    Values.CaseSensitive := True;
{$ENDIF}
    try

    sf.ReadSections(Sections);
    for i := 0 to Sections.Count - 1 do begin
      sf.ReadSection(Sections[i], Values);
      for j := 0 to Values.Count - 1 do begin
        s := sf.ReadString(Sections[i], Values[j], '-');
        s := AnsiUpperCase(s);

        if (pos('.JPG', s) > 0) or (pos('.JPEG', s) > 0) then begin
          TempJpg := nil;
          if SkinIsPacked then begin
            for l := 0 to sc.ImageCount - 1 do if UpperCase(sc.Files[l].FileName) = s then begin
              TempJpg := TJpegImage.Create;
              sc.Files[l].FileStream.Seek(0, 0);
              TempJpg.LoadFromStream(sc.Files[l].FileStream);
              break;
            end;
          end
          else begin
            if (pos(':', s) < 1) then s := SkinData.SkinPath + s;
            if FileExists(s) then begin
              TempJpg := TJpegImage.Create;
              TempJpg.LoadFromFile(s);
            end;
          end;

          if (TempJpg <> nil) and (TempJpg.Width > 0) then begin

            l := Length(pa) + 1;
            SetLength(pa, l);
            pa[l - 1].PropertyName := '';
            pa[l - 1].ClassName := '';

            pa[l - 1].Img := TempJpg;

            if pa[l - 1].Img.Width * pa[l - 1].Img.Height < 900000 then begin // convert to bitmap
              n := Length(ma) + 1;
              SetLength(ma, n);
              ma[n - 1].Bmp := TBitmap.Create;
              ma[n - 1].Bmp.Width := pa[l - 1].Img.Width;
              ma[n - 1].Bmp.Height := pa[l - 1].Img.Height;
              ma[n - 1].Bmp.Canvas.Draw(0, 0, pa[l - 1].Img);
              if ma[n - 1].Bmp.PixelFormat <> pf32bit then begin
                ma[n - 1].Bmp.PixelFormat := pf32bit;
                FillAlphaRect(ma[n - 1].Bmp, Rect(0, 0, ma[n - 1].Bmp.Width, ma[n - 1].Bmp.Height), MaxByte, True);
              end;
              ma[n - 1].PropertyName := UpperCase(Values[j]);
              ma[n - 1].ClassName := UpperCase(Sections[i]);
              ma[n - 1].ImgType := itisaTexture;
              ma[n - 1].ImageCount := 1;
              ma[l - 1].Manager := Self;
              if Assigned(pa[l - 1].Img) then FreeAndNil(pa[l - 1].Img);
              SetLength(pa, l - 1);
            end
            else begin // big image stored as Jpeg
              pa[l - 1].PropertyName := UpperCase(Values[j]);
              pa[l - 1].ClassName := UpperCase(Sections[i]);
            end;
          end;
        end;
      end;
    end;
    finally
      if Assigned(Values) then FreeAndNil(Values);
      if Assigned(Sections) then FreeAndNil(Sections);
    end;
  end;

  // CommonSection property in TsSkinManager
  if CommonSections.Count > 0 then begin
    sf := TMemInifile.Create('2.tmp');
{$IFDEF DELPHI6UP}
    sf.CaseSensitive := True;
{$ENDIF}
    sf.SetStrings(CommonSections);
    Sections := TStringList.Create;
{$IFDEF DELPHI6UP}
    Sections.CaseSensitive := True;
{$ENDIF}
    Values := TStringList.Create;
{$IFDEF DELPHI6UP}
    Values.CaseSensitive := True;
{$ENDIF}
    try
    sf.ReadSections(Sections);
    for i := 0 to Sections.Count - 1 do begin
      sf.ReadSection(Sections[i], Values);
      for j := 0 to Values.Count - 1 do begin
        s := sf.ReadString(Sections[i], Values[j], '-');
        s := AnsiUpperCase(s);

        if (pos('.JPG', s) > 0) or (pos('.JPEG', s) > 0) then begin

          if (pos(':', s) < 1) then begin
            s := SkinData.SkinPath + s;
          end;
          if FileExists(s) then begin //Break;
            l := Length(pa) + 1;
            SetLength(pa, l);
            pa[l - 1].PropertyName := '';
            pa[l - 1].ClassName := '';
            try
              pa[l - 1].Img := TJpegImage.Create;
              pa[l - 1].Img.LoadFromFile(s);
            finally
              pa[l - 1].PropertyName := UpperCase(Values[j]);
              pa[l - 1].ClassName := UpperCase(Sections[i]);
            end;
            if pa[l - 1].Img.Width < 1 then begin
              if Assigned(pa[l - 1].Img) then FreeAndNil(pa[l - 1].Img);
              SetLength(pa, l - 1);
            end;
          end;
        end;
      end;
    end;
    finally
      if Assigned(Values) then FreeAndNil(Values);
      if Assigned(Sections) then FreeAndNil(Sections);
      FreeAndNil(sf);
    end;
  end;
end;

procedure TsSkinManager.FreeBitmaps;
begin
  while Length(ma) > 0 do begin
    if Assigned(ma[Length(ma) - 1].Bmp) then FreeAndNil(ma[Length(ma) - 1].Bmp);
    SetLength(ma, Length(ma) - 1);
  end;
  if Assigned(MasterBitmap) then FreeAndNil(MasterBitmap);
end;

procedure TsSkinManager.FreeJpegs;
begin
  while Length(pa) > 0 do begin
    if Assigned(pa[Length(pa) - 1].Img) then FreeAndNil(pa[Length(pa) - 1].Img);
    SetLength(pa, Length(pa) - 1);
  end;
end;

procedure TsSkinManager.LoadAllGeneralData;
var
  sf : TMemIniFile;
  gData : TsGeneralData;
  Sections, Ini : TStringList;
  i, j, l, SkinIndex, ParentIndex, int : integer;
  s : string;
  OldSeparator : char;
  function FindString(const ClassName, PropertyName, DefaultValue : string) : string; var s : string; begin
    Result := sf.ReadString(ClassName, PropertyName, CharQuest);
    if Result = CharQuest then begin
      s := sf.ReadString(ClassName, s_ParentClass, CharQuest);
      if (s <> '') and (s <> CharQuest) and (s <> ClassName) then begin
        Result := FindString(s, PropertyName, CharQuest);
      end;
      if Result = CharQuest then Result := DefaultValue;
    end;
  end;
  function FindInteger(const ClassName, PropertyName : string; DefaultValue : integer) : integer; var s : string; begin
    Result := sf.ReadInteger(ClassName, PropertyName, -1);
    if Result = -1 then begin
      s := sf.ReadString(ClassName, s_ParentClass, CharQuest);
      if (s <> '') and (s <> CharQuest) and (s <> ClassName) then begin
        Result := FindInteger(s, PropertyName, -1);
      end;
      if Result = -1 then Result := DefaultValue else Result := ColorToRGB(Result);
    end;
  end;
begin
  if SkinFile <> nil then begin
    sf := SkinFile;
    // Global info
    OldSeparator := DecimalSeparator;
    DecimalSeparator := '.';
    SkinData.Version := sf.ReadFloat(s_GlobalInfo, s_Version, 0);
    DecimalSeparator := OldSeparator;
    SkinData.Author := sf.ReadString(s_GlobalInfo, s_Author, '');
    SkinData.Description := sf.ReadString(s_GlobalInfo, s_Description, '');

    SkinData.ExBorderWidth := sf.ReadInteger(s_GlobalInfo, s_BorderWidth, 4);
    SkinData.ExTitleHeight := sf.ReadInteger(s_GlobalInfo, s_TitleHeight, 30);
    SkinData.ExMaxHeight := sf.ReadInteger(s_GlobalInfo, s_MaxTitleHeight, 0);
    if SkinData.ExMaxHeight = 0 then SkinData.ExMaxHeight := SkinData.ExTitleHeight;

    SkinData.ExContentOffs := sf.ReadInteger(s_GlobalInfo, s_FormOffset, GetSystemMetrics(SM_CXSIZEFRAME));
    SkinData.ExShadowOffs := sf.ReadInteger(s_GlobalInfo, s_ShadowOffset, 0);
    SkinData.ExCenterOffs := sf.ReadInteger(s_GlobalInfo, s_CenterOffset, 0);
    SkinData.ExDrawMode := sf.ReadInteger(s_GlobalInfo, s_BorderMode, 0);

    SkinData.Shadow1Color := sf.ReadInteger(s_GlobalInfo, s_Shadow1Color, 0);
    SkinData.Shadow1Offset := StrToInt(sf.ReadString(s_GlobalInfo, s_Shadow1Offset, ZeroChar));
    SkinData.Shadow1Blur := StrToInt(sf.ReadString(s_GlobalInfo, s_Shadow1Blur, s_MinusOne));
    SkinData.Shadow1Transparency := StrToInt(sf.ReadString(s_GlobalInfo, s_Shadow1Transparency, ZeroChar));

    SkinData.BISpacing := sf.ReadInteger(s_GlobalInfo, s_BISpacing, 0);
    SkinData.BIVAlign := sf.ReadInteger(s_GlobalInfo, s_BIVAlign, 0);
    SkinData.BIRightMargin := sf.ReadInteger(s_GlobalInfo, s_BIRightMargin, 0);
    SkinData.BILeftMargin := sf.ReadInteger(s_GlobalInfo, s_BILeftMargin, 0);
    SkinData.BITopMargin := sf.ReadInteger(s_GlobalInfo, s_BITopMargin, 0);
    SkinData.BorderColor := sf.ReadInteger(s_GlobalInfo, s_BorderColor, clBlack);
    SkinData.BIKeepHUE := sf.ReadInteger(s_GlobalInfo, s_BIKeepHUE, 0);

    SkinData.BICloseGlow := StrToInt(sf.ReadString(s_GlobalInfo, s_BorderIconClose + s_Glow, ZeroChar));
    SkinData.BICloseGlowMargin := StrToInt(sf.ReadString(s_GlobalInfo, s_BorderIconClose + s_GlowMargin, ZeroChar));
    SkinData.BIMaxGlow := StrToInt(sf.ReadString(s_GlobalInfo, s_BorderIconMaximize + s_Glow, ZeroChar));
    SkinData.BIMaxGlowMargin := StrToInt(sf.ReadString(s_GlobalInfo, s_BorderIconMaximize + s_GlowMargin, ZeroChar));
    SkinData.BIMinGlow := StrToInt(sf.ReadString(s_GlobalInfo, s_BorderIconMinimize + s_Glow, ZeroChar));
    SkinData.BIMinGlowMargin := StrToInt(sf.ReadString(s_GlobalInfo, s_BorderIconMinimize + s_GlowMargin, ZeroChar));

    CheckVersion;

    Sections := TStringList.Create;
{$IFDEF DELPHI6UP}
    Sections.CaseSensitive := True;
{$ENDIF}
    try

    SetLength(gd, 0);
    sf.ReadSections(Sections);

    for i := 0 to Sections.Count - 1 do begin
      l := Length(gd) + 1;
      SetLength(gd, l);
      // General data
      gd[i].ClassName := Sections[i];
      gd[i].ParentClass := sf.ReadString(Sections[i], s_ParentClass, '');

      gd[i].Color := ColorToRGB(FindInteger(Sections[i], s_Color, clWhite));
      s := UpperCase(FindString(Sections[i], s_ReservedBoolean, ZeroChar));
      gd[i].ReservedBoolean := (s = '1') or (s = s_TrueStr);
      s := UpperCase(FindString(Sections[i], s_GiveOwnFont, ZeroChar));
      gd[i].GiveOwnFont := (s = '1') or (s = s_TrueStr);

      gd[i].GlowCount := FindInteger(Sections[i], s_Glow, 0);
      gd[i].GlowMargin := FindInteger(Sections[i], s_GlowMargin, 0);

      gd[i].ImgTL := -1;
      gd[i].ImgTR := -1;
      gd[i].ImgBL := -1;
      gd[i].ImgBR := -1;

      gd[i].FontColor[1] := FindInteger(Sections[i], s_FontColor, clBlack);
      gd[i].FontColor[2] := FindInteger(Sections[i], s_TCLeft  , -1);
      gd[i].FontColor[3] := FindInteger(Sections[i], s_TCTop   , -1);
      gd[i].FontColor[4] := FindInteger(Sections[i], s_TCRight , -1);
      gd[i].FontColor[5] := FindInteger(Sections[i], s_TCBottom, -1);

      gd[i].Transparency := FindInteger(Sections[i], s_Transparency, 0);
      gd[i].GradientPercent := FindInteger(Sections[i], s_GradientPercent, 0);
      gd[i].ImagePercent := FindInteger(Sections[i], s_ImagePercent, 0);

      gd[i].GradientData := FindString(Sections[i], s_GradientData, s_Space);
      if Length(gd[i].GradientData) > 1 then PrepareGradArray(gd[i].GradientData, gd[i].GradientArray) else gd[i].GradientPercent := 0;

      s := UpperCase(FindString(Sections[i], s_ShowFocus, ZeroChar));
      gd[i].ShowFocus := (s = '1') or (s = s_TrueStr);
      s := UpperCase(FindString(Sections[i], s_FadingEnabled, ZeroChar));
      gd[i].FadingEnabled := (s = '1') or (s = s_TrueStr);
      gd[i].FadingIterations := FindInteger(Sections[i], s_FadingIterations, 5);
      // Text Glow
      gd[i].GlowColor := ColorToRGB(FindInteger(Sections[i], s_GlowColor, clWhite));
      gd[i].GlowSize := FindInteger(Sections[i], s_GlowSize, 0);

      // Prop state array
      gd[i].Props[0].Color            := gd[i].Color;
      gd[i].Props[0].FontColor.Color  := gd[i].FontColor[1];
      gd[i].Props[0].FontColor.Left   := gd[i].FontColor[2];
      gd[i].Props[0].FontColor.Top    := gd[i].FontColor[3];
      gd[i].Props[0].FontColor.Right  := gd[i].FontColor[4];
      gd[i].Props[0].FontColor.Bottom := gd[i].FontColor[5];
      gd[i].Props[0].GlowColor        := gd[i].GlowColor;
      gd[i].Props[0].GlowSize         := gd[i].GlowSize;
      gd[i].Props[0].GradientPercent  := gd[i].GradientPercent;
      gd[i].Props[0].GradientData     := gd[i].GradientData;
      gd[i].Props[0].GradientArray    := gd[i].GradientArray;
      gd[i].Props[0].ImagePercent     := gd[i].ImagePercent;
      gd[i].Props[0].Transparency     := gd[i].Transparency;

      // State count
      gd[i].States := FindInteger(Sections[i], s_States, 4);

      if gd[i].States > 1 then begin

        gd[i].HotFontColor[1] := FindInteger(Sections[i], s_HotFontColor, clBlack);
        gd[i].HotFontColor[2] := FindInteger(Sections[i], s_HotTCLeft  , -1);
        gd[i].HotFontColor[3] := FindInteger(Sections[i], s_HotTCTop   , -1);
        gd[i].HotFontColor[4] := FindInteger(Sections[i], s_HotTCRight , -1);
        gd[i].HotFontColor[5] := FindInteger(Sections[i], s_HotTCBottom, -1);
        gd[i].HotGlowColor := ColorToRGB(FindInteger(Sections[i], s_HotGlowColor, clWhite));
        gd[i].HotGlowSize := FindInteger(Sections[i], s_HotGlowSize, 0);
        gd[i].HotColor := TColor(FindInteger(Sections[i], s_HotColor, clWhite));
        gd[i].HotTransparency := FindInteger(Sections[i], s_HotTransparency, 0);
        gd[i].HotGradientPercent := FindInteger(Sections[i], s_HotGradientPercent, 0);
        gd[i].HotGradientData := FindString(Sections[i], s_HotGradientData, '');
        if Length(gd[i].HotGradientData) > 1 then PrepareGradArray(gd[i].HotGradientData, gd[i].HotGradientArray) else gd[i].HotGradientPercent := 0;
        gd[i].HotImagePercent := FindInteger(Sections[i], s_HotImagePercent, 0);

        gd[i].Props[1].Color            := gd[i].HotColor;
        gd[i].Props[1].FontColor.Color  := gd[i].HotFontColor[1];
        gd[i].Props[1].FontColor.Left   := gd[i].HotFontColor[2];
        gd[i].Props[1].FontColor.Top    := gd[i].HotFontColor[3];
        gd[i].Props[1].FontColor.Right  := gd[i].HotFontColor[4];
        gd[i].Props[1].FontColor.Bottom := gd[i].HotFontColor[5];
        gd[i].Props[1].GlowColor        := gd[i].HotGlowColor;
        gd[i].Props[1].GlowSize         := gd[i].HotGlowSize;
        gd[i].Props[1].GradientPercent  := gd[i].HotGradientPercent;
        gd[i].Props[1].GradientData     := gd[i].HotGradientData;
        gd[i].Props[1].GradientArray    := gd[i].HotGradientArray;
        gd[i].Props[1].ImagePercent     := gd[i].HotImagePercent;
        gd[i].Props[1].Transparency     := gd[i].HotTransparency;
      end
      else begin // For compatibility with old skins
        gd[i].Props[1] := gd[i].Props[0];
      end;
    end;

    finally
      if Assigned(Sections) then FreeAndNil(Sections);
    end;
  end;

  // CommonSection property in TsSkinManager
  if CommonSections.Count > 0 then begin
    Sections := TStringList.Create;
{$IFDEF DELPHI6UP}
    Sections.CaseSensitive := True;
{$ENDIF}
    GetIniSections(CommonSections, Sections);
    try for i := 0 to Sections.Count - 1 do begin
      l := Length(gd);
      gData.ClassName := '';
      SkinIndex := -1;
      for ParentIndex := 0 to l - 1 do if gd[ParentIndex].ClassName = Sections[i] then begin
        gData := gd[ParentIndex];
        SkinIndex := ParentIndex;
        break;
      end;
      Ini := nil;
      if gData.ClassName = '' then begin
        l := Length(gd) + 1;
        SetLength(gd, l);
        gData.ClassName := Sections[i];
        Ini := CommonSections;
        gData.ParentClass := UpperCase(acntUtils.ReadIniString(Ini, Sections, gData.ClassName, s_ParentClass, s_MinusOne));
        ParentIndex := -1;
        for j := 0 to Length(gd) - 1 do begin
          if UpperCase(gd[j].ClassName) = gData.ParentClass then begin
            ParentIndex := j;
            break;
          end;
        end;
      end;
      // General data
      if Ini <> nil then begin
        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_Color, -1);
        if int = -1 then if ParentIndex > -1 then gData.Color := gd[ParentIndex].Color else gData.Color := clWhite else gData.Color := int;
        s := UpperCase(acntUtils.ReadIniString(Ini, Sections, Sections[i], s_ReservedBoolean, CharQuest));
        if s = CharQuest then if ParentIndex > -1 then gData.ReservedBoolean := gd[ParentIndex].ReservedBoolean else gData.ReservedBoolean := False else gData.ReservedBoolean := (s = '1') or (s = s_TrueStr);
        s := UpperCase(acntUtils.ReadIniString(Ini, Sections, Sections[i], s_GiveOwnFont, CharQuest));
        if s = CharQuest then if ParentIndex > -1 then gData.GiveOwnFont := gd[ParentIndex].GiveOwnFont else gData.GiveOwnFont := False else gData.GiveOwnFont := (s = '1') or (s = s_TrueStr);

        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_Glow, 0);
        if int = -1 then if ParentIndex > -1 then gData.GlowCount := gd[ParentIndex].GlowCount else gData.GlowCount := 0 else gData.GlowCount := int;
        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_GlowMargin, 0);
        if int = -1 then if ParentIndex > -1 then gData.GlowMargin := gd[ParentIndex].GlowMargin else gData.GlowMargin := 0 else gData.GlowMargin := int;

        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_FontColor, -1);
        if int = -1 then if ParentIndex > -1 then gData.FontColor[1] := gd[ParentIndex].FontColor[1] else gData.FontColor[1] := 0 else gData.FontColor[1] := int;
        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_TCLeft, -1);
        if int = -1 then if ParentIndex > -1 then gData.FontColor[2] := gd[ParentIndex].FontColor[2] else gData.FontColor[2] := -1 else gData.FontColor[2] := int;
        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_TCTop, -1);
        if int = -1 then if ParentIndex > -1 then gData.FontColor[3] := gd[ParentIndex].FontColor[3] else gData.FontColor[3] := -1 else gData.FontColor[3] := int;
        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_TCRight, -1);
        if int = -1 then if ParentIndex > -1 then gData.FontColor[4] := gd[ParentIndex].FontColor[4] else gData.FontColor[4] := -1 else gData.FontColor[4] := int;
        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_TCBottom, -1);
        if int = -1 then if ParentIndex > -1 then gData.FontColor[5] := gd[ParentIndex].FontColor[5] else gData.FontColor[5] := -1 else gData.FontColor[5] := int;

        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_HotFontColor, -1);
        if int = -1 then if ParentIndex > -1 then gData.HotFontColor[1] := gd[ParentIndex].HotFontColor[1] else gData.HotFontColor[1] := 0 else gData.HotFontColor[1] := int;
        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_HotTCLeft, -1);
        if int = -1 then if ParentIndex > -1 then gData.HotFontColor[2] := gd[ParentIndex].HotFontColor[2] else gData.HotFontColor[2] := -1 else gData.HotFontColor[2] := int;
        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_HotTCTop, -1);
        if int = -1 then if ParentIndex > -1 then gData.HotFontColor[3] := gd[ParentIndex].HotFontColor[3] else gData.HotFontColor[3] := -1 else gData.HotFontColor[3] := int;
        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_HotTCRight, -1);
        if int = -1 then if ParentIndex > -1 then gData.HotFontColor[4] := gd[ParentIndex].HotFontColor[4] else gData.HotFontColor[4] := -1 else gData.HotFontColor[4] := int;
        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_HotTCBottom, -1);
        if int = -1 then if ParentIndex > -1 then gData.HotFontColor[5] := gd[ParentIndex].HotFontColor[5] else gData.HotFontColor[5] := -1 else gData.HotFontColor[5] := int;

  //Panels data
        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_Transparency, -1);
        if int = -1 then if ParentIndex > -1 then gData.Transparency := gd[ParentIndex].Transparency else gData.Transparency := 0 else gData.Transparency := int;
        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_GradientPercent, -1);
        if int = -1 then if ParentIndex > -1 then gData.GradientPercent := gd[ParentIndex].GradientPercent else gData.GradientPercent := 0 else gData.GradientPercent := int;
        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_ImagePercent, -1);
        if int = -1 then if ParentIndex > -1 then gData.ImagePercent := gd[ParentIndex].ImagePercent else gData.ImagePercent := 0 else gData.ImagePercent := int;

        s := acntUtils.ReadIniString(Ini, Sections, Sections[i], s_GradientData, CharQuest);
        if s = CharQuest then if ParentIndex > -1 then gData.GradientData := gd[ParentIndex].GradientData else gData.GradientData := s_Space else gData.GradientData := s;
        if Length(gData.GradientData) > 1 then PrepareGradArray(gData.GradientData, gData.GradientArray);

  // Buttons data
        s := UpperCase(acntUtils.ReadIniString(Ini, Sections, Sections[i], s_ShowFocus, CharQuest));
        if s = CharQuest then begin
          if ParentIndex > -1 then gData.ShowFocus := gd[ParentIndex].ShowFocus else gData.ShowFocus := False
        end
        else gData.ShowFocus := (s = '1') or (s = s_TrueStr);
  // ---- BtnEffects ----
        s := UpperCase(acntUtils.ReadIniString(Ini, Sections, Sections[i], s_FadingEnabled, CharQuest));
        if s = CharQuest then begin
          if ParentIndex > -1 then gData.FadingEnabled := gd[ParentIndex].FadingEnabled else gData.FadingEnabled := False
        end else gData.FadingEnabled := (s = '1') or (s = s_TrueStr);
        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_FadingIterations, -1);
        if int = -1 then if ParentIndex > -1 then gData.FadingIterations := gd[ParentIndex].FadingIterations else gData.FadingIterations := 5 else gData.FadingIterations := int;

  // ---- PaintingOptions -----
        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_HotColor, -1);
        if int = -1 then if ParentIndex > -1 then gData.HotColor := gd[ParentIndex].HotColor else gData.HotColor := clWhite else gData.HotColor := int;
        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_HotTransparency, -1);
        if int = -1 then if ParentIndex > -1 then gData.HotTransparency := gd[ParentIndex].HotTransparency else gData.HotTransparency := 0 else gData.HotTransparency := int;
        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_HotGradientPercent, -1);
        if int = -1 then if ParentIndex > -1 then gData.HotGradientPercent := gd[ParentIndex].HotGradientPercent else gData.HotGradientPercent := 0 else gData.HotGradientPercent := int;
        s := acntUtils.ReadIniString(Ini, Sections, Sections[i], s_HotGradientData, CharQuest);
        if s = CharQuest then if ParentIndex > -1 then gData.HotGradientData := gd[ParentIndex].HotGradientData else gData.HotGradientData := '' else gData.HotGradientData := s;
        if Length(gData.HotGradientData) > 1 then PrepareGradArray(gData.HotGradientData, gData.HotGradientArray);
        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_HotImagePercent, -1);
        if int = -1 then if ParentIndex > -1 then gData.HotImagePercent := gd[ParentIndex].HotImagePercent else gData.HotImagePercent := 0 else gData.HotImagePercent := int;

        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_HotGlowColor, -1);
        if int = -1 then if ParentIndex > -1 then gData.HotGlowColor := gd[ParentIndex].HotGlowColor else gData.HotGlowColor := clWhite else gData.HotGlowColor := int;
        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_HotGlowSize, 0);
        if int = -1 then if ParentIndex > -1 then gData.HotGlowSize := gd[ParentIndex].HotGlowSize else gData.HotGlowSize := 0 else gData.HotGlowSize := int;
        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_GlowColor, -1);
        if int = -1 then if ParentIndex > -1 then gData.GlowColor := gd[ParentIndex].GlowColor else gData.GlowColor := clWhite else gData.GlowColor := int;
        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_GlowSize, 0);
        if int = -1 then if ParentIndex > -1 then gData.GlowSize := gd[ParentIndex].GlowSize else gData.GlowSize := 0 else gData.GlowSize := int;
        int := acntUtils.ReadIniInteger(Ini, Sections, Sections[i], s_States, 0);
        if int = -1 then if ParentIndex > -1 then gData.States := gd[ParentIndex].States else gData.States := 3 else gData.States := int;

        // Prop state array
        gData.Props[0].Color            := gData.Color;
        gData.Props[0].FontColor.Color  := gData.FontColor[1];
        gData.Props[0].FontColor.Left   := gData.FontColor[2];
        gData.Props[0].FontColor.Top    := gData.FontColor[3];
        gData.Props[0].FontColor.Right  := gData.FontColor[4];
        gData.Props[0].FontColor.Bottom := gData.FontColor[5];
        gData.Props[0].GlowColor        := gData.GlowColor;

        gData.Props[0].GlowSize         := gData.GlowSize;
        gData.Props[0].GradientPercent  := gData.GradientPercent;
        gData.Props[0].GradientData     := gData.GradientData;
        gData.Props[0].GradientArray    := gData.GradientArray;
        gData.Props[0].ImagePercent     := gData.ImagePercent;
        gData.Props[0].Transparency     := gData.Transparency;

        gData.States := FindInteger(Sections[i], s_States, 4);

        if gData.States > 1 then begin
          gData.Props[1].Color            := gData.HotColor;
          gData.Props[1].FontColor.Color  := gData.HotFontColor[1];
          gData.Props[1].FontColor.Left   := gData.HotFontColor[2];
          gData.Props[1].FontColor.Top    := gData.HotFontColor[3];
          gData.Props[1].FontColor.Right  := gData.HotFontColor[4];
          gData.Props[1].FontColor.Bottom := gData.HotFontColor[5];
          gData.Props[1].GlowColor        := gData.HotGlowColor;
          gData.Props[1].GlowSize         := gData.HotGlowSize;
          gData.Props[1].GradientPercent  := gData.HotGradientPercent;
          gData.Props[1].GradientData     := gData.HotGradientData;
          gData.Props[1].GradientArray    := gData.HotGradientArray;
          gData.Props[1].ImagePercent     := gData.HotImagePercent;
          gData.Props[1].Transparency     := gData.HotTransparency;
        end
        else begin // For compatibility with old skins
          gData.Props[1] := gData.Props[0];
        end;

        if gData.ClassName <> '' then begin
          if SkinIndex > -1 then gd[SkinIndex] := gData else gd[l - 1] := gData;
          gData.ClassName := '';
        end;
      end;
    end;

    finally
      if Assigned(Sections) then begin
        while Sections.Count > 0 do begin
          if Sections.Objects[0] <> nil then TStringList(Sections.Objects[0]).Free;
          Sections.Delete(0);
        end;
        FreeAndNil(Sections);
      end;
    end;
  end;
  InitMaskIndexes;
  ChangeSkinHue(Self, HueOffset);
  ChangeSkinSaturation(Self, Saturation);
end;

function TsSkinManager.GetSkinIndex(const SkinSection: string): integer;
var
  i, l : integer;
  p : PChar;
begin
  Result := -1;
  if Self = nil then Exit;
  l := Length(gd);
  p := PChar(SkinSection);
  if l > 0 then for i := 0 to l - 1 do if lStrCmp(PChar(gd[i].ClassName), p) = 0 then begin
    Result := i;
    Exit;
  end;
end;

function TsSkinManager.GetMaskIndex(SkinIndex: integer; const SkinSection, mask: string): integer;
var
  i, l : integer;
  s : string;
begin
  Result := -1;
  if SkinIndex < 0 then Exit;
  if (SkinSection <> '') then begin
    l := Length(ma);
    for i := 0 to l - 1 do if (ma[i].ClassName = SkinSection) and (ma[i].PropertyName = mask) then begin
      Result := i;
      Exit;
    end;
    if SkinIndex > -1 then begin
      s := gd[SkinIndex].ParentClass;
      if (s <> '') and (SkinSection <> s) then begin
        i := GetSkinIndex(s);
        if i > -1 then Result := GetMaskIndex(i, s, mask);
      end;
    end;
  end;
end;

function TsSkinManager.GetPatternIndex(SkinIndex: integer; const SkinSection, pattern: string): integer;
var
  i, l : integer;
  s : string;
begin
  Result := -1;
  if SkinIndex > -1 then begin
    l := Length(pa);
    if (l > 0) and (SkinSection <> '') then begin
      for i := 0 to l - 1 do if (pa[i].PropertyName = pattern) and (pa[i].ClassName = skinSection) then begin
        Result := i;
        Exit;
      end;
      s := gd[SkinIndex].ParentClass;
      if (s <> '') and (SkinSection <> s) then begin
        i := GetSkinIndex(s);
        if i > -1 then Result := GetPatternIndex(i, s, pattern);
      end;
    end;
  end;
end;

procedure TsSkinManager.SetIsDefault(const Value: boolean);
begin
  if Value or (DefaultManager = nil) then begin
    FIsDefault := True;
    DefaultManager := Self;
    if Active then begin
      SendNewSkin;
    end
    else SendRemoveSkin;
  end
  else FIsDefault := DefaultManager = Self;
end;

function TsSkinManager.GetRandomSkin : acString;
var
  sl : TacStringList;
begin
  sl := TacStringList.Create;
  GetSkinNames(sl);
  if sl.Count > 0 then begin
    Randomize;
    Result := sl[Random(sl.Count)]
  end
  else Result := '';
  FreeAndNil(sl);
end;

function TsSkinManager.GetIsDefault: boolean;
begin
  Result := DefaultManager = Self;
end;

function TsSkinManager.GetTextureIndex(SkinIndex: integer; const SkinSection, PropName: string): integer;
var
  i, l : integer;
begin
  Result := -1;
  if SkinIndex > -1 then begin
    l := Length(ma);
    if (l > 0) and (SkinSection <> '') then begin
      for i := 0 to l - 1 do if (ma[i].ImgType = itisaTexture) and (ma[i].PropertyName = PropName) and (ma[i].ClassName = SkinSection) then begin
        Result := i;
        Exit;
      end;
      if (gd[SkinIndex].ParentClass <> '') and (SkinSection <> gd[SkinIndex].ParentClass) then begin
        i := GetSkinIndex(gd[SkinIndex].ParentClass);
        if i > -1 then Result := GetTextureIndex(i, gd[SkinIndex].ParentClass, PropName);
      end;
    end;
  end;
end;

function TsSkinManager.GetMaskIndex(const SkinSection, mask: string): integer;
var
  i, l : integer;
begin
  Result := -1;
  if (SkinSection <> '') then begin
    l := Length(ma);
    for i := 0 to l - 1 do if (ma[i].ClassName = SkinSection) then if (ma[i].PropertyName = mask) then begin
      Result := i;
      Exit;
    end;
  end;
end;

function MakePreviewBmp(sp : TObject; Width : integer = 200; Height : integer = 140) : TBitmap;
var
  TmpBmp : TBitmap;
begin
  Result := CreateBmp32(Width, Height);
  with sp as TsSkinProvider do begin
    TmpBmp := CreateBmp32(SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height);
    if BorderForm <> nil then begin
      FormState := FormState or FS_BLENDMOVING;
      BorderForm.UpdateExBordersPos(False); // Repaint cache
      FormState := FormState and not FS_BLENDMOVING;
      TmpBmp.Assign(SkinData.FCacheBmp);
      BorderForm.UpdateExBordersPos(False); // Repaint cache
    end
    else begin
      TmpBmp.Assign(SkinData.FCacheBmp);
      PaintFormTo(TmpBmp, sp as TsSkinProvider);
    end;
  end;
  Stretch(TmpBmp, Result, Width, Height, ftMitchell);
  FreeAndNil(TmpBmp);
end;

function MakeThumbIcon(sp : TObject; Width : integer = 200; Height : integer = 140) : TBitmap;
var
  TmpBmp : TBitmap;
begin
  Result := CreateBmp32(Width, Height);
  with sp as TsSkinProvider do begin
    TmpBmp := CreateBmp32(SkinData.FCacheBmp.Width, SkinData.FCacheBmp.Height);
    if BorderForm <> nil then begin
      FormState := FormState or FS_BLENDMOVING;
      BorderForm.UpdateExBordersPos(False); // Repaint cache
      FormState := FormState and not FS_BLENDMOVING;
      TmpBmp.Assign(SkinData.FCacheBmp);
      BorderForm.UpdateExBordersPos(False); // Repaint cache
    end
    else begin
      TmpBmp.Assign(SkinData.FCacheBmp);
      PaintFormTo(TmpBmp, sp as TsSkinProvider);
    end;
  end;
  Stretch(TmpBmp, Result, Width, Height, ftMitchell);
  FreeAndNil(TmpBmp);
end;

type
  TAccessProvider = class(TsSkinProvider);

function TsSkinManager.MainWindowHook(var Message: TMessage): boolean;
var
  FMenuItem : TMenuItem;
  R : TRect;
  Wnd : hwnd;
  mi : TacMenuInfo;
  i : integer;
  sp : TsSkinProvider;
{$IFNDEF NOWNDANIMATION}
  b : boolean;
{$ENDIF}
begin
{$IFDEF LOGGED}
//  if fGlobalFlag then
  AddToLog(Message);
{$ENDIF}
  Result := False;
  case Message.Msg of
    WM_DRAWMENUBORDER : if SkinnedPopups then begin
      FMenuItem := TMenuItem(Message.LParam);
      if Assigned(FMenuItem) then begin
        if GetMenuItemRect(0, FMenuItem.Parent.Handle, 0, R) or GetMenuItemRect(PopupList.Window, FMenuItem.Parent.Handle, 0, R) then begin
          Wnd := WindowFromPoint(Point(r.Left + WidthOf(r) div 2, r.Top + HeightOf(r) div 2));
          if (Wnd <> 0) then begin
            mi := SkinableMenus.GetMenuInfo(FMenuItem, 0, 0, Wnd);
            if (mi.Bmp <> nil) then SkinableMenus.DrawWndBorder(Wnd, mi.Bmp);
          end;
        end;
      end;
      Result := True;
    end;
    WM_DWMSENDICONICLIVEPREVIEWBITMAP : if ac_ChangeThumbPreviews and (Application.MainForm <> nil) then begin // Task menu support when not MainFormOnTaskBar
      try
        sp := TsSkinProvider(SendAMessage(Application.MainForm.Handle, AC_GETPROVIDER));
        if sp <> nil then Result := SetPreviewBmp(Application.Handle, sp);
      finally
        Message.Result := 0;
      end;
    end;
    WM_DWMSENDICONICTHUMBNAIL : if ac_ChangeThumbPreviews and (Application.MainForm <> nil) and (Message.LParamHi <> 0) and (Message.LParamLo <> 0) then begin // Task menu support when not MainFormOnTaskBar
      try
        sp := TsSkinProvider(SendAMessage(Application.MainForm.Handle, AC_GETPROVIDER));
        if sp <> nil then Result := SetThumbIcon(Application.Handle, sp, Message.LParamHi, Message.LParamLo);
      finally
        Message.Result := 0;
      end;
    end;
    WM_DRAWMENUBORDER2 : if SkinnedPopups then begin
      Wnd := HWND(Message.LParam);
      if (Wnd <> 0) then begin
        mi := SkinableMenus.GetMenuInfo(nil, 0, 0, Wnd);
        if (mi.Bmp <> nil) then SkinableMenus.DrawWndBorder(Wnd, mi.Bmp);
      end;
      Result := True;
    end;
    $031A{ <- WM_THEMECHANGED} : Result := True;
{$IFDEF D2005}
    787 : if {$IFDEF D2007}Application.MainFormOnTaskBar and {$ENDIF}(Application.MainForm <> nil) then begin // Task menu support when not MainFormOnTaskBar
      try
        sp := TsSkinProvider(SendAMessage(Application.MainForm.Handle, AC_GETPROVIDER));
      except
        sp := nil;
      end;
      if sp <> nil then begin
        sp.DropSysMenu(Mouse.CursorPos.X, Mouse.CursorPos.Y);
        Result := True;
      end;
    end;
{$ENDIF}

    CM_ACTIVATE : begin // Solving a problem in Report Builder dialogs and similar windows
      for i := Screen.FormCount - 1 downto 0 do SendAMessage(Screen.Forms[i].Handle, AC_INVALIDATE);
    end;

{$IFNDEF NOWNDANIMATION}
    WM_WINDOWPOSCHANGED : if acLayered {$IFDEF D2011}and not Application.MainFormOnTaskBar{$ENDIF} then begin
      if (TWMWindowPosChanged(Message).WindowPos.Flags and SWP_HIDEWINDOW = SWP_HIDEWINDOW) then begin
        if (AnimEffects.FormHide.Active) and (AnimEffects.FormHide.Time > 0) and not IsIconic(Application.Handle) and Application.Terminated then begin
          if (Application.MainForm = nil) or not IsWindowVisible(Application.MainForm.Handle) then Exit;
          sp := TsSkinProvider(SendAMessage(Application.MainForm.Handle, AC_GETPROVIDER));
          if sp = nil then Exit;
          if not sp.DrawNonClientArea or sp.SkipAnimation then Exit;
          sp.SkipAnimation := True;

//          if AeroIsEnabled {$IFDEF D2007}or not Application.MainFormOnTaskBar{$ENDIF} then

(*          {$IFDEF D2007}if not Application.MainFormOnTaskBar then {$ENDIF}
          begin
            sp.FormState := sp.FormState or FS_ANIMCLOSING;
            if sp.BorderForm <> nil then sp.BorderForm.UpdateExBordersPos;
          end;*)
          DoLayered(Application.MainForm.Handle, True);
          Application.MainForm.Update;
          acHideTimer := nil;
          AnimHideForm(sp);
          while InAnimationProcess do Continue;
//          sp.SkipAnimation := False;
        end;
      end;
    end;
{$ENDIF}
    WM_SYSCOMMAND : if SkinData.Active then begin
      case Message.WParam of
        SC_MINIMIZE : begin
          ShowState := saMinimize;
{$IFNDEF NOWNDANIMATION}
          if not IsIconic(Application.Handle) and ((Application.MainForm <> nil) and Application.MainForm.Visible) then begin
            sp := TsSkinProvider(SendAMessage(Application.MainForm.Handle, AC_GETPROVIDER));
            if sp <> nil then begin
              if AnimEffects.Minimizing.Active then begin
                if not sp.DrawNonClientArea then Exit;
                StartMinimizing(sp);
                if not AeroIsEnabled then begin
                  Result := True;
                  b := acGetAnimation;
                  acSetAnimation(False);
                  Application.Minimize;
                  acSetAnimation(b);
                end;
              end
              else begin
                if (sp.BorderForm <> nil) and (sp.BorderForm.AForm <> nil) then begin
                  sp.BorderForm.ExBorderShowing := True;
                  FreeAndNil(sp.BorderForm.AForm);
                  sp.BorderForm.ExBorderShowing := False;
                end;
              end;
            end
            else Exit;
          end;
{$ENDIF}
        end;
        SC_RESTORE : begin
          ShowState := saRestore;
{$IFNDEF NOWNDANIMATION}
          if (Application.MainForm <> nil) then begin
            sp := TsSkinProvider(SendAMessage(Application.MainForm.Handle, AC_GETPROVIDER));
            if sp = nil then Exit;
            if sp.FormState and FS_ANIMCLOSING = FS_ANIMCLOSING then begin // If all windows were hidden
              sp.FormState := sp.FormState and not FS_ANIMCLOSING;
              // Update ExtBorders in the WM_NCPAINT message
              if sp.SkinData.SkinManager.ExtendedBorders and sp.AllowExtBorders and (sp.BorderForm = nil) then FreeAndNil(sp.SkinData.FCacheBmp);
              if sp.BorderForm <> nil then begin
                sp.BorderForm.ExBorderShowing := False;
              end;
              b := acGetAnimation;
              acSetAnimation(False);

              Application.Restore;
              if AeroIsEnabled then begin
                RedrawWindow(Application.MainForm.Handle, nil, 0, RDW_INVALIDATE or RDW_ALLCHILDREN or RDW_FRAME or RDW_ERASE);// or RDW_UPDATENOW);
                if GetWindowLong(Application.MainForm.Handle, GWL_EXSTYLE) and WS_EX_LAYERED = WS_EX_LAYERED then begin
                  sp.SkinData.BGChanged := True;
                  SetWindowLong(Application.MainForm.Handle, GWL_EXSTYLE, GetWindowLong(Application.MainForm.Handle, GWL_EXSTYLE) and not WS_EX_LAYERED);
                end;
              end;
              acSetAnimation(b);
              Exit;
            end
            else if AnimEffects.Minimizing.Active and Application.MainForm.Visible {and IsIconic(Application.Handle) }then begin
              if sp <> nil then begin
                if not sp.DrawNonClientArea then Exit;
                if not StartRestoring(sp) then begin
                  if (TAccessProvider(sp).CoverForm <> nil) then begin
                    if TAccessProvider(sp).CoverForm.HandleAllocated
                      then SetWindowPos(Application.MainForm.Handle, TAccessProvider(sp).CoverForm.Handle, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE or SWP_NOREDRAW or SWP_SHOWWINDOW or SWP_NOSENDCHANGING or SWP_NOOWNERZORDER);
                    InvalidateRect(Application.MainForm.Handle, nil, True);
                    RedrawWindow(Application.MainForm.Handle, nil, 0, RDW_INVALIDATE or RDW_ALLCHILDREN or RDW_FRAME or RDW_ERASE or RDW_UPDATENOW);
                    if TAccessProvider(sp).CoverForm <> nil then FreeAndNil(TAccessProvider(sp).CoverForm);
                  end
                  else begin
                    ShowWindow(Application.MainForm.Handle, SW_RESTORE);
                    InvalidateRect(Application.MainForm.Handle, nil, True);
                    RedrawWindow(Application.MainForm.Handle, nil, 0, RDW_INVALIDATE or RDW_ALLCHILDREN or RDW_FRAME or RDW_ERASE or RDW_UPDATENOW);
                  end;
                end;
              end;
              if not AeroIsEnabled then begin
                Result := True;
                b := acGetAnimation;
                acSetAnimation(False);
                Application.Restore;
                acSetAnimation(b);
              end;
            end
            else begin
              if AeroIsEnabled then begin
{$IFDEF D2009}
                if not Application.MainFormOnTaskBar then
{$ENDIF}
                begin
                  Result := True;
                  b := acGetAnimation;
                  acSetAnimation(False);
                  Application.Restore;
                  acSetAnimation(b);
                  InvalidateRect(Application.MainForm.Handle, nil, True);
                  RedrawWindow(Application.MainForm.Handle, nil, 0, RDW_INVALIDATE or RDW_ALLCHILDREN or RDW_FRAME or RDW_ERASE);
                end;
              end;
            end;
          end;
{$ENDIF}
        end
        else begin
          ShowState := saIgnore;
        end;
      end;
    end;
  end;
end;

procedure TsSkinManager.ReloadSkin;
var
  s : string;
  sl : TStringList;
  i : integer;
begin
  if FActive then begin
    aSkinChanging := True;

    SkinData.SkinPath := GetFullSkinDirectory + s_Slash + SkinName + s_Slash;
    s := SkinData.SkinPath + OptionsDatName;
    if acMemSkinFile <> nil then begin
      if not Assigned(SkinFile) then begin
        SkinFile := TMemIniFile.Create(s + '_');
{$IFDEF DELPHI6UP}
        Skinfile.CaseSensitive := True;
{$ENDIF}
      end;
      SkinFile.SetStrings(acMemSkinFile);
    end
    else begin
      if Assigned(SkinFile) then FreeAndNil(SkinFile);
      if FileExists(s) then begin // If used external skins
        SkinIsPacked := False;
        SkinFile := TMemIniFile.Create(s);
{$IFDEF DELPHI6UP}
        Skinfile.CaseSensitive := True;
{$ENDIF}
      end
      else begin // If used internal skins
        SkinData.SkinPath := '';
        i := InternalSkins.IndexOf(FSkinName);
        if (i = -1) and (InternalSkins.Count > 0) then begin
          FSkinName := InternalSkins.Items[0].Name;
          i := 0;
        end
        else if (InternalSkins.Count < 1) then begin
          FActive := False;
          Exit;
        end;
        if InternalSkins.Items[i].PackedData.Size > 0 then begin // if packed
          if Assigned(sc) then FreeAndNil(sc);
          SkinIsPacked := True;
          sc := TacSkinConvertor.Create;
          sc.PackedData := InternalSkins.Items[i].PackedData;
          ExtractPackedData(sc);
          sc.PackedData := nil;

          sc.Options.Seek(0, 0);
          sl := TStringList.Create;
{$IFDEF DELPHI6UP}
          sl.CaseSensitive := True;
{$ENDIF}
          sl.LoadFromStream(sc.Options);
          SkinFile := TMemIniFile.Create('');
{$IFDEF DELPHI6UP}
          SkinFile.CaseSensitive := True;
{$ENDIF}
          SkinFile.SetStrings(sl);
          FreeAndNil(sl);
        end
        else SkinIsPacked := False;
      end;
    end;
    LoadAllMasks;
    LoadAllPatterns;
    LoadAllGeneralData;
    InitConstantIndexes;
    aSkinChanging := False;
    if Assigned(SkinFile) then FreeAndNil(SkinFile);
    if Assigned(sc) then FreeAndNil(sc);
  end;
end;

function TsSkinManager.MaskWidthBottom(MaskIndex: integer): integer;
begin
  if ma[MaskIndex].WB > 0
    then Result := ma[MaskIndex].WB
    else if ma[MaskIndex].BorderWidth > 0
      then Result := ma[MaskIndex].BorderWidth
      else Result := HeightOfImage(ma[MaskIndex]);
end;

function TsSkinManager.MaskWidthLeft(MaskIndex: integer): integer;
begin
  if ma[MaskIndex].WL > 0 then Result := ma[MaskIndex].WL else if ma[MaskIndex].BorderWidth > 0 then Result := ma[MaskIndex].BorderWidth else begin
    if ma[MaskIndex].ImageCount = 0 then ma[MaskIndex].ImageCount := 1;
    Result := WidthOfImage(ma[MaskIndex]);
  end
end;

function TsSkinManager.MaskWidthRight(MaskIndex: integer): integer;
begin
  if ma[MaskIndex].WR > 0
    then Result := ma[MaskIndex].WR
    else if ma[MaskIndex].BorderWidth > 0
      then Result := ma[MaskIndex].BorderWidth
      else Result := WidthOfImage(ma[MaskIndex]);
end;

function TsSkinManager.MaskWidthTop(MaskIndex: integer): integer;
begin
  if ma[MaskIndex].WT > 0
    then Result := ma[MaskIndex].WT
    else if ma[MaskIndex].BorderWidth > 0
      then Result := ma[MaskIndex].BorderWidth
      else Result := HeightOfImage(ma[MaskIndex]);
end;

procedure TsSkinManager.SetActiveControl(const Value: hwnd);
var
  OldHwnd : hwnd;
begin
  if FActiveControl <> Value then begin
    OldHwnd := FActiveControl;
    FActiveControl := Value;
    if OldHwnd <> 0 then SendAMessage(OldHwnd, AC_MOUSELEAVE, LongWord(Self));
    if FActiveControl <> 0 then SendAMessage(FActiveControl, AC_MOUSEENTER, LongWord(Self));
  end;
end;

procedure TsSkinManager.InstallHook;
var
  dwThreadID: DWORD;
begin
  if (csDesigning in ComponentState) or (DefaultManager <> Self) then Exit;
  if not GlobalHookInstalled then begin
    GlobalHookInstalled := True;
    if acSupportedList = nil then acSupportedList := TList.Create;
    dwThreadID := GetCurrentThreadId;
    HookCallback := SetWindowsHookEx(WH_CBT, SkinHookCBT, 0, dwThreadID);
  end;
end;

procedure TsSkinManager.UnInstallHook;
var
  i : integer;
begin
  if (csDesigning in ComponentState) or (DefaultManager <> Self) then Exit;
  if GlobalHookInstalled then begin
    ClearMnuArray;
    if HookCallBack <> 0 then UnhookWindowsHookEx(HookCallback);
    if acSupportedList <> nil then begin
      for i := 0 to acSupportedList.Count - 1 do if acSupportedList[i] <> nil then TObject(acSupportedList[i]).Free;
      FreeAndNil(acSupportedList);
    end;
    GlobalHookInstalled := False;
    HookCallback := 0;
  end;
end;

procedure TsSkinManager.ReloadPackedSkin;
var
  sl : TStringList;
begin
  if FActive then begin
    aSkinChanging := True;
    if Assigned(SkinFile) then FreeAndNil(SkinFile);
    sc := nil;
    LoadSkinFromFile(NormalDir(SkinDirectory) + SkinName + '.' + acSkinExt, sc);
    sc.Options.Seek(0, 0);
    sl := TStringList.Create;
{$IFDEF DELPHI6UP}
    sl.CaseSensitive := True;
{$ENDIF}
    sl.LoadFromStream(sc.Options);
    SkinFile := TMemIniFile.Create('');
{$IFDEF DELPHI6UP}
    SkinFile.CaseSensitive := True;
{$ENDIF}
    SkinFile.SetStrings(sl);
    FreeAndNil(sl);

    SkinData.SkinPath := GetFullSkinDirectory + s_Slash;

    LoadAllMasks;
    LoadAllPatterns;
    LoadAllGeneralData;
    InitConstantIndexes;
    aSkinChanging := False;
    if Assigned(SkinFile) then FreeAndNil(SkinFile);
    if Assigned(sc) then FreeAndNil(sc);
  end;
end;

procedure TsSkinManager.SetFSkinningRules(const Value: TacSkinningRules);
begin
  FSkinningRules := Value;
  UpdateCommonDlgs(Self);
end;

procedure TsSkinManager.SetExtendedBorders(const Value: boolean);
var
  s : string;
begin
  if FExtendedBorders <> Value then begin
    FExtendedBorders := Value;
    if not SkinData.Active then Exit;
    aSkinChanging := True;
    s := NormalDir(SkinDirectory) + SkinName + '.' + acSkinExt;
    SkinIsPacked := FileExists(s);
    CheckShadows;
    if SkinIsPacked then ReloadPackedSkin else ReloadSkin;
    aSkinChanging := False;
    if not (csLoading in ComponentState) and not (csReading in ComponentState) and not (csDesigning in ComponentState) then RepaintForms;
  end;
end;

procedure TsSkinManager.CheckShadows;
var
  w, h : integer;
begin
  if FActive and ExtendedBorders then begin
    if ShdaTemplate <> nil then FreeAndNil(ShdaTemplate);
    if ShdiTemplate <> nil then FreeAndNil(ShdiTemplate);
    ShdaTemplate := TPngGraphic.Create;
    ShdiTemplate := TPngGraphic.Create;
    if ConstData.ExBorder > -1 then begin
      if SkinData.ExDrawMode = 0 then begin // Shadow only
        FormShadowSize.Top := ma[ConstData.ExBorder].WT - SkinData.ExContentOffs;
        FormShadowSize.Left := ma[ConstData.ExBorder].WL - SkinData.ExContentOffs;
        FormShadowSize.Right := ma[ConstData.ExBorder].WR - SkinData.ExContentOffs;
        FormShadowSize.Bottom := ma[ConstData.ExBorder].WB - SkinData.ExContentOffs;
      end
      else begin
        FormShadowSize := Rect(SkinData.ExContentOffs, SkinData.ExContentOffs, SkinData.ExContentOffs, SkinData.ExContentOffs);
      end;

      w := WidthOfImage(ma[ConstData.ExBorder]);
      h := HeightOfImage(ma[ConstData.ExBorder]);
      ShdiTemplate.PixelFormat := pf32bit;
      ShdiTemplate.Width := w;
      ShdiTemplate.Height := h;
      BitBlt(ShdiTemplate.Canvas.Handle, 0, 0, w, h, ma[ConstData.ExBorder].Bmp.Canvas.Handle, 0, 0, SRCCOPY);
      if ma[ConstData.ExBorder].ImageCount = 1 then begin
        ShdaTemplate.Assign(ShdiTemplate);
      end
      else begin
        ShdaTemplate.PixelFormat := pf32bit;
        ShdaTemplate.Width := w;
        ShdaTemplate.Height := h;
        BitBlt(ShdaTemplate.Canvas.Handle, 0, 0, w, h, ma[ConstData.ExBorder].Bmp.Canvas.Handle, w, 0, SRCCOPY);
      end;
    end
    else if (rsta <> nil) and (rsti <> nil) then begin
//      FormShadowSize := Rect(13, 11, 13, 13);
      FormShadowSize := Rect(11, 10, 11, 12);
      ShdaTemplate.Assign(rsta);
      ShdiTemplate.Assign(rsti);
      if AeroIsEnabled then begin
        inc(FormShadowSize.Left);
        inc(FormShadowSize.Top);
        inc(FormShadowSize.Right);
        inc(FormShadowSize.Bottom);
      end;
    end;
    UpdateTransPixels(ShdaTemplate);
    UpdateTransPixels(ShdiTemplate);
  end
  else FormShadowSize := Rect(0, 0, 0, 0);
end;

procedure TsSkinManager.CheckVersion;
var
  i : integer;
  b : boolean;
begin
  if (SkinData.Version < CompatibleSkinVersion) then begin
    if not (csDesigning in ComponentState) then begin
      b := False;
      if ParamCount > 0 then for i := 1 to ParamCount do if LowerCase(ParamStr(i)) = '/actest' then begin
        b := True;
        break;
      end;
      if not b then Exit;
    end;
    ShowMessage('You are using an old version of the "' + SkinName + '" skin. Please, update a skins to latest or link with the AlphaControls support for upgrading of existing skin.'#13#10#13#10'This notification occurs in design-time only for your information and will not occur in real-time.')
  end
  else if SkinData.Version > MaxCompSkinVersion
    then ShowMessage('This version of the skin have not complete support by used AlphaControls package release.'#13#10'Components must be updated up to latest version for using this skin.');
end;

function TsSkinManager.GetAllowGlowing: boolean;
begin
  Result := Effects.AllowGlowing;
end;

function TsSkinManager.GetExtendedBorders: boolean;
begin
  Result := FExtendedBorders and Assigned(UpdateLayeredWindow);
end;

procedure TsSkinManager.BeginUpdate;
begin
  NonAutoUpdate := True;
end;

procedure TsSkinManager.EndUpdate(Repaint : boolean = False; AllowAnimation : boolean = True);
var
  b : boolean;
begin
  NonAutoUpdate := False;
  if AllowAnimation then UpdateSkin(Repaint) else begin
    b := AnimEffects.SkinChanging.Active;
    AnimEffects.SkinChanging.Active := False;
    UpdateSkin(Repaint);
    AnimEffects.SkinChanging.Active := b;
  end;
end;

procedure TsSkinManager.SetAllowGlowing(const Value: boolean);
begin
  Effects.AllowGlowing := Value;
end;

{ TsStoredSkins }

procedure TsStoredSkins.Assign(Source: TPersistent);
begin
end;

constructor TsStoredSkins.Create(AOwner: TsSkinManager);
begin
  inherited Create(TsStoredSkin);
  FOwner := AOwner;
end;

destructor TsStoredSkins.Destroy;
begin
  FOwner := nil;
  inherited Destroy;
end;

function TsStoredSkins.GetItem(Index: Integer): TsStoredSkin;
begin
  Result := TsStoredSkin(inherited GetItem(Index))
end;

function TsStoredSkins.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TsStoredSkins.IndexOf(const SkinName: string): integer;
var
  i : integer;
begin
  Result := -1;
  for i := 0 to Count - 1 do if Items[i].Name = SkinName then begin
    Result := i;
    Exit;
  end;
end;

procedure TsStoredSkins.SetItem(Index: Integer; Value: TsStoredSkin);
begin
  inherited SetItem(Index, Value);
end;

{ TsStoredSkin }

procedure TsStoredSkin.Assign(Source: TPersistent);
begin
  if Source = nil then inherited else begin
    PackedData.LoadFromStream(TsStoredSkin(Source).PackedData);
    FName := TsStoredSkin(Source).Name;

    FMasterBitmap.Assign(TsStoredSkin(Source).MasterBitmap);

    FShadow1Color := TsStoredSkin(Source).Shadow1Color;
    FShadow1Offset := TsStoredSkin(Source).Shadow1Offset;
    FShadow1Blur := TsStoredSkin(Source).Shadow1Blur;
    FShadow1Transparency := TsStoredSkin(Source).Shadow1Transparency;

    FBorderColor := TsStoredSkin(Source).BorderColor;

    FVersion := TsStoredSkin(Source).Version;
    FAuthor := TsStoredSkin(Source).Author;
    FDescription := TsStoredSkin(Source).Description;
  end;
end;

constructor TsStoredSkin.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FMasterBitmap := TBitmap.Create;
  PackedData := TMemoryStream.Create;
  FShadow1Blur := -1;
  FBorderColor := clFuchsia;
end;

procedure TsStoredSkin.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineBinaryProperty('Data', ReadData, WriteData, True);
end;

destructor TsStoredSkin.Destroy;
begin
  if Assigned(FMasterBitmap) then FreeAndNil(FMasterBitmap);
  FreeAndNil(PackedData);
  inherited Destroy;
end;

procedure TsStoredSkin.ReadData(Reader: TStream);
begin
  PackedData.LoadFromStream(Reader);
end;

procedure TsStoredSkin.WriteData(Writer: TStream);
begin
  PackedData.SaveToStream(Writer);
end;

{ TacAnimEffects }

constructor TacAnimEffects.Create;
begin
  FBlendOnMoving := TacBlendOnMoving.Create;
  FButtons := TacBtnEffects.Create;
  FButtons.Manager := Manager;
  FDialogShow := TacDialogShow.Create;
  FFormShow := TacFormShow.Create;
  FFormHide := TacFormHide.Create;
  FDialogHide := TacFormHide.Create;
  FMinimizing := TacMinimizing.Create;
  FPageChange := TacPageChange.Create;
  FSkinChanging := TacSkinChanging.Create;
end;

destructor TacAnimEffects.Destroy;
begin
  FreeAndNil(FBlendOnMoving);
  FreeAndNil(FButtons);
  FreeAndNil(FDialogShow);
  FreeAndNil(FFormShow);
  FreeAndNil(FFormHide);
  FreeAndNil(FDialogHide);
  FreeAndNil(FMinimizing);
  FreeAndNil(FPageChange);
  FreeAndNil(FSkinChanging);
  inherited;
end;

{ TacBtnEffects }

constructor TacBtnEffects.Create;
begin
  FEvents := [beMouseEnter, beMouseLeave, beMouseDown, beMouseUp]
end;

{ TacFormAnimation }

constructor TacFormAnimation.Create;
begin
  FActive := True;
  FTime := 0;
  FMode := atAero;
end;

{ TacDialogShow }

constructor TacDialogShow.Create;
begin
  inherited;
  FTime := 0;
end;

{ TacSkinChanging }

constructor TacSkinChanging.Create;
begin
  inherited;
  FTime := 100;
  FMode := atFading
end;

{ ThirdPartyList }

function ThirdPartyList.GetString(const Index: Integer): string;
begin
  case Index of
    ord(tpEdit)        : Result := FThirdEdits       ;
    ord(tpButton)      : Result := FThirdButtons     ;
    ord(tpBitBtn)      : Result := FThirdBitBtns     ;
    ord(tpCheckBox)    : Result := FThirdCheckBoxes  ;
    ord(tpGroupBox)    : Result := FThirdGroupBoxes  ;
    ord(tpListView)    : Result := FThirdListViews   ;
    ord(tpPanel)       : Result := FThirdPanels      ;
    ord(tpGrid)        : Result := FThirdGrids       ;
    ord(tpTreeView)    : Result := FThirdTreeViews   ;
    ord(tpComboBox)    : Result := FThirdComboBoxes  ;
    ord(tpwwEdit)      : Result := FThirdWWEdits     ;
    ord(tpVirtualTree) : Result := FThirdVirtualTrees;
    ord(tpGridEh)      : Result := FThirdGridEh      ;
    ord(tpPageControl) : Result := FThirdPageControl ;
    ord(tpTabControl)  : Result := FThirdTabControl  ;
    ord(tpToolBar)     : Result := FThirdToolBar     ;
    ord(tpStatusBar)   : Result := FThirdStatusBar   ;
    ord(tpSpeedButton) : Result := FThirdSpeedButton ;
  end
end;

procedure ThirdPartyList.SetString(const Index: Integer; const Value: string);
begin
  case Index of
    ord(tpEdit)        :   FThirdEdits         := Value;
    ord(tpButton)      :   FThirdButtons       := Value;
    ord(tpBitBtn)      :   FThirdBitBtns       := Value;
    ord(tpCheckBox)    :   FThirdCheckBoxes    := Value;
    ord(tpGroupBox)    :   FThirdGroupBoxes    := Value;
    ord(tpListView)    :   FThirdListViews     := Value;
    ord(tpPanel)       :   FThirdPanels        := Value;
    ord(tpGrid)        :   FThirdGrids         := Value;
    ord(tpTreeView)    :   FThirdTreeViews     := Value;
    ord(tpComboBox)    :   FThirdComboBoxes    := Value;
    ord(tpwwEdit)      :   FThirdWWEdits       := Value;
    ord(tpVirtualTree) :   FThirdVirtualTrees  := Value;
    ord(tpGridEh)      :   FThirdGridEh        := Value;
    ord(tpPageControl) :   FThirdPageControl   := Value;
    ord(tpTabControl)  :   FThirdTabControl    := Value;
    ord(tpToolBar)     :   FThirdToolBar       := Value;
    ord(tpStatusBar)   :   FThirdStatusBar     := Value;
    ord(tpSpeedButton) :   FThirdSpeedButton   := Value;
  end
end;

var
  rst : TResourceStream = nil;
  ic : integer;

{ TacSkinEffects }

constructor TacSkinEffects.Create;
begin
  FAllowGlowing := True;
end;

function TacSkinEffects.GetAllowGlowing: boolean;
begin
  Result := FAllowGlowing and (acLayered or (csDesigning in Manager.ComponentState)) and not x64woAero;
end;

{ TacMinimizing }

constructor TacMinimizing.Create;
begin
  inherited;
  FTime := 200;
end;

{ TacBlendOnMoving }

constructor TacBlendOnMoving.Create;
begin
  inherited;
  FActive := False;
  FBlendValue := 170;
  Time := 1000;  
end;

initialization

  OSVersionInfo.dwOSVersionInfoSize := sizeof(OSVersionInfo);
  GetVersionEx(OSVersionInfo);
  IsNT := OSVersionInfo.dwPlatformId = VER_PLATFORM_WIN32_NT;

  rst := TResourceStream.Create(hInstance, 'acSHDA', RT_RCDATA);
  rsta := TPNGGraphic.Create;
  rsta.LoadFromStream(rst);
  FreeAndNil(rst);

  rst := TResourceStream.Create(hInstance, 'acSHDI', RT_RCDATA);
  rsti := TPNGGraphic.Create;
  rsti.LoadFromStream(rst);
  FreeAndNil(rst);
  if ParamCount > 0 then for ic := 1 to ParamCount do if LowerCase(ParamStr(ic)) = '/acver' then begin
    ShowMessage('AlphaControls v' + CurrentVersion);
    Break;
  end;

finalization
  FreeAndNil(rsta);
  FreeAndNil(rsti);

end.
