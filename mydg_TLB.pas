unit mydg_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : 1.2
// File generated on 2016-8-14 8:27:31 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\2014prg\mydg\mydg.tlb (1)
// LIBID: {499840AA-6E61-4941-80C3-16FC8F6D4BB4}
// LCID: 0
// Helpfile: 
// HelpString: mydg Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  mydgMajorVersion = 1;
  mydgMinorVersion = 0;

  LIBID_mydg: TGUID = '{499840AA-6E61-4941-80C3-16FC8F6D4BB4}';

  IID_Imydgs: TGUID = '{8E6E657D-611F-42B7-A20B-E0EB373CF742}';
  CLASS_mydgs: TGUID = '{1A31AC94-0D1C-41D6-B6AD-80F516233A18}';
  IID_Idg: TGUID = '{99C2F624-97EF-4032-8516-79BB8B58192C}';
  DIID_IdgEvents: TGUID = '{6C8ACE64-5499-4484-B25E-D5172137DFD5}';
  CLASS_dg: TGUID = '{D926610A-DD1E-4BBD-B123-C9133F741301}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum TxActiveFormBorderStyle
type
  TxActiveFormBorderStyle = TOleEnum;
const
  afbNone = $00000000;
  afbSingle = $00000001;
  afbSunken = $00000002;
  afbRaised = $00000003;

// Constants for enum TxPrintScale
type
  TxPrintScale = TOleEnum;
const
  poNone = $00000000;
  poProportional = $00000001;
  poPrintToFit = $00000002;

// Constants for enum TxMouseButton
type
  TxMouseButton = TOleEnum;
const
  mbLeft = $00000000;
  mbRight = $00000001;
  mbMiddle = $00000002;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  Imydgs = interface;
  ImydgsDisp = dispinterface;
  Idg = interface;
  IdgDisp = dispinterface;
  IdgEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  mydgs = Imydgs;
  dg = Idg;


// *********************************************************************//
// Interface: Imydgs
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {8E6E657D-611F-42B7-A20B-E0EB373CF742}
// *********************************************************************//
  Imydgs = interface(IDispatch)
    ['{8E6E657D-611F-42B7-A20B-E0EB373CF742}']
  end;

// *********************************************************************//
// DispIntf:  ImydgsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {8E6E657D-611F-42B7-A20B-E0EB373CF742}
// *********************************************************************//
  ImydgsDisp = dispinterface
    ['{8E6E657D-611F-42B7-A20B-E0EB373CF742}']
  end;

// *********************************************************************//
// Interface: Idg
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {99C2F624-97EF-4032-8516-79BB8B58192C}
// *********************************************************************//
  Idg = interface(IDispatch)
    ['{99C2F624-97EF-4032-8516-79BB8B58192C}']
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function Get_AutoScroll: WordBool; safecall;
    procedure Set_AutoScroll(Value: WordBool); safecall;
    function Get_AutoSize: WordBool; safecall;
    procedure Set_AutoSize(Value: WordBool); safecall;
    function Get_AxBorderStyle: TxActiveFormBorderStyle; safecall;
    procedure Set_AxBorderStyle(Value: TxActiveFormBorderStyle); safecall;
    function Get_Caption: WideString; safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    function Get_Color: Integer; safecall;
    procedure Set_Color(Value: Integer); safecall;
    function Get_KeyPreview: WordBool; safecall;
    procedure Set_KeyPreview(Value: WordBool); safecall;
    function Get_PixelsPerInch: Integer; safecall;
    procedure Set_PixelsPerInch(Value: Integer); safecall;
    function Get_PrintScale: TxPrintScale; safecall;
    procedure Set_PrintScale(Value: TxPrintScale); safecall;
    function Get_Scaled: WordBool; safecall;
    procedure Set_Scaled(Value: WordBool); safecall;
    function Get_Active: WordBool; safecall;
    function Get_DropTarget: WordBool; safecall;
    procedure Set_DropTarget(Value: WordBool); safecall;
    function Get_HelpFile: WideString; safecall;
    procedure Set_HelpFile(const Value: WideString); safecall;
    function Get_DoubleBuffered: WordBool; safecall;
    procedure Set_DoubleBuffered(Value: WordBool); safecall;
    function Get_VisibleDockClientCount: Integer; safecall;
    function Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    function Get_Cursor: Smallint; safecall;
    procedure Set_Cursor(Value: Smallint); safecall;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property AutoScroll: WordBool read Get_AutoScroll write Set_AutoScroll;
    property AutoSize: WordBool read Get_AutoSize write Set_AutoSize;
    property AxBorderStyle: TxActiveFormBorderStyle read Get_AxBorderStyle write Set_AxBorderStyle;
    property Caption: WideString read Get_Caption write Set_Caption;
    property Color: Integer read Get_Color write Set_Color;
    property KeyPreview: WordBool read Get_KeyPreview write Set_KeyPreview;
    property PixelsPerInch: Integer read Get_PixelsPerInch write Set_PixelsPerInch;
    property PrintScale: TxPrintScale read Get_PrintScale write Set_PrintScale;
    property Scaled: WordBool read Get_Scaled write Set_Scaled;
    property Active: WordBool read Get_Active;
    property DropTarget: WordBool read Get_DropTarget write Set_DropTarget;
    property HelpFile: WideString read Get_HelpFile write Set_HelpFile;
    property DoubleBuffered: WordBool read Get_DoubleBuffered write Set_DoubleBuffered;
    property VisibleDockClientCount: Integer read Get_VisibleDockClientCount;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property Cursor: Smallint read Get_Cursor write Set_Cursor;
  end;

// *********************************************************************//
// DispIntf:  IdgDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {99C2F624-97EF-4032-8516-79BB8B58192C}
// *********************************************************************//
  IdgDisp = dispinterface
    ['{99C2F624-97EF-4032-8516-79BB8B58192C}']
    property Visible: WordBool dispid 1;
    property AutoScroll: WordBool dispid 2;
    property AutoSize: WordBool dispid 3;
    property AxBorderStyle: TxActiveFormBorderStyle dispid 4;
    property Caption: WideString dispid -518;
    property Color: Integer dispid 5;
    property KeyPreview: WordBool dispid 6;
    property PixelsPerInch: Integer dispid 7;
    property PrintScale: TxPrintScale dispid 8;
    property Scaled: WordBool dispid 9;
    property Active: WordBool readonly dispid 10;
    property DropTarget: WordBool dispid 11;
    property HelpFile: WideString dispid 12;
    property DoubleBuffered: WordBool dispid 13;
    property VisibleDockClientCount: Integer readonly dispid 14;
    property Enabled: WordBool dispid -514;
    property Cursor: Smallint dispid 15;
  end;

// *********************************************************************//
// DispIntf:  IdgEvents
// Flags:     (4096) Dispatchable
// GUID:      {6C8ACE64-5499-4484-B25E-D5172137DFD5}
// *********************************************************************//
  IdgEvents = dispinterface
    ['{6C8ACE64-5499-4484-B25E-D5172137DFD5}']
    procedure OnActivate; dispid 1;
    procedure OnClick; dispid 2;
    procedure OnCreate; dispid 3;
    procedure OnDblClick; dispid 5;
    procedure OnDestroy; dispid 6;
    procedure OnDeactivate; dispid 7;
    procedure OnKeyPress(var Key: Smallint); dispid 11;
    procedure OnPaint; dispid 16;
  end;

// *********************************************************************//
// The Class Comydgs provides a Create and CreateRemote method to          
// create instances of the default interface Imydgs exposed by              
// the CoClass mydgs. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  Comydgs = class
    class function Create: Imydgs;
    class function CreateRemote(const MachineName: string): Imydgs;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : Tdg
// Help String      : dg Control
// Default Interface: Idg
// Def. Intf. DISP? : No
// Event   Interface: IdgEvents
// TypeFlags        : (34) CanCreate Control
// *********************************************************************//
  TdgOnKeyPress = procedure(ASender: TObject; var Key: Smallint) of object;

  Tdg = class(TOleControl)
  private
    FOnActivate: TNotifyEvent;
    FOnClick: TNotifyEvent;
    FOnCreate: TNotifyEvent;
    FOnDblClick: TNotifyEvent;
    FOnDestroy: TNotifyEvent;
    FOnDeactivate: TNotifyEvent;
    FOnKeyPress: TdgOnKeyPress;
    FOnPaint: TNotifyEvent;
    FIntf: Idg;
    function  GetControlInterface: Idg;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    property  ControlInterface: Idg read GetControlInterface;
    property  DefaultInterface: Idg read GetControlInterface;
    property Visible: WordBool index 1 read GetWordBoolProp write SetWordBoolProp;
    property Active: WordBool index 10 read GetWordBoolProp;
    property DropTarget: WordBool index 11 read GetWordBoolProp write SetWordBoolProp;
    property HelpFile: WideString index 12 read GetWideStringProp write SetWideStringProp;
    property DoubleBuffered: WordBool index 13 read GetWordBoolProp write SetWordBoolProp;
    property VisibleDockClientCount: Integer index 14 read GetIntegerProp;
    property Enabled: WordBool index -514 read GetWordBoolProp write SetWordBoolProp;
  published
    property Anchors;
    property  Align;
    property  DragCursor;
    property  DragMode;
    property  ParentShowHint;
    property  PopupMenu;
    property  ShowHint;
    property  TabOrder;
    property  OnDragDrop;
    property  OnDragOver;
    property  OnEndDrag;
    property  OnEnter;
    property  OnExit;
    property  OnStartDrag;
    property AutoScroll: WordBool index 2 read GetWordBoolProp write SetWordBoolProp stored False;
    property AutoSize: WordBool index 3 read GetWordBoolProp write SetWordBoolProp stored False;
    property AxBorderStyle: TOleEnum index 4 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property Caption: WideString index -518 read GetWideStringProp write SetWideStringProp stored False;
    property Color: Integer index 5 read GetIntegerProp write SetIntegerProp stored False;
    property KeyPreview: WordBool index 6 read GetWordBoolProp write SetWordBoolProp stored False;
    property PixelsPerInch: Integer index 7 read GetIntegerProp write SetIntegerProp stored False;
    property PrintScale: TOleEnum index 8 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property Scaled: WordBool index 9 read GetWordBoolProp write SetWordBoolProp stored False;
    property Cursor: Smallint index 15 read GetSmallintProp write SetSmallintProp stored False;
    property OnActivate: TNotifyEvent read FOnActivate write FOnActivate;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnCreate: TNotifyEvent read FOnCreate write FOnCreate;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnDestroy: TNotifyEvent read FOnDestroy write FOnDestroy;
    property OnDeactivate: TNotifyEvent read FOnDeactivate write FOnDeactivate;
    property OnKeyPress: TdgOnKeyPress read FOnKeyPress write FOnKeyPress;
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
  end;

procedure Register;

resourcestring
  dtlServerPage = 'Servers';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

class function Comydgs.Create: Imydgs;
begin
  Result := CreateComObject(CLASS_mydgs) as Imydgs;
end;

class function Comydgs.CreateRemote(const MachineName: string): Imydgs;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_mydgs) as Imydgs;
end;

procedure Tdg.InitControlData;
const
  CEventDispIDs: array [0..7] of DWORD = (
    $00000001, $00000002, $00000003, $00000005, $00000006, $00000007,
    $0000000B, $00000010);
  CControlData: TControlData2 = (
    ClassID: '{D926610A-DD1E-4BBD-B123-C9133F741301}';
    EventIID: '{6C8ACE64-5499-4484-B25E-D5172137DFD5}';
    EventCount: 8;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil (*HR:$00000000*);
    Flags: $00000018;
    Version: 401);
begin
  ControlData := @CControlData;
  TControlData2(CControlData).FirstEventOfs := Cardinal(@@FOnActivate) - Cardinal(Self);
end;

procedure Tdg.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as Idg;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function Tdg.GetControlInterface: Idg;
begin
  CreateControl;
  Result := FIntf;
end;

procedure Register;
begin
  RegisterComponents(dtlOcxPage, [Tdg]);
end;

end.
