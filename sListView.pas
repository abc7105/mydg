unit sListView;
{$I sDefs.inc}
{.$DEFINE LOGGED}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ComCtrls, ImgList, StdCtrls, sConst, {$IFNDEF DELPHI5}types,{$ENDIF}
  Commctrl, sCommonData, sMessages, acSBUtils{$IFDEF LOGGED}, sDebugMsgs{$ENDIF}
  {$IFDEF TNTUNICODE}, TntComCtrls{$ENDIF};

{$I sDefs.inc}

type
{$IFDEF TNTUNICODE}
  TsCustomListView = class(TTntCustomListView)
{$ELSE}
  TsCustomListView = class(TCustomListView)
{$ENDIF}
{$IFNDEF NOTFORHELP}
  private
    Loading          : boolean;
    FhWndHeader      : HWnd;
    FhHeaderProc     : Pointer;
    FhDefHeaderProc  : Pointer;
    FPressedColumn   : Integer;
    FCommonData: TsCommonData;
    HoverColIndex : integer;
    FBoundLabel: TsBoundLabel;
    FHighlightHeaders: boolean;
    FOldAdvancedCustomDraw: TLVAdvancedCustomDrawEvent;
    FOldAdvancedCustomDrawItem: TLVAdvancedCustomDrawItemEvent;
    FFlag: Boolean;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMHitTest(var Message: TMessage); message WM_NCHITTEST;
    procedure WMParentNotify(var Message: TWMParentNotify); message WM_PARENTNOTIFY;
    procedure NewAdvancedCustomDraw(Sender: TCustomListView; const ARect: TRect; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
    procedure NewAdvancedCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
    procedure NewAdvancedCustomDrawSubItem(Sender: TCustomListView; Item: TListItem; SubItem: Integer; State: TCustomDrawState; Stage: TCustomDrawStage; var DefaultDraw: Boolean; CI : TCacheInfo);

    procedure PrepareCache;
    function GetHeaderColumnRect(Index: Integer): TRect;
    procedure ColumnSkinPaint(ControlRect : TRect; cIndex : Integer);
    procedure PaintHeader;
    function ColumnLeft(Index : integer) : integer;
  protected
    ListSW : TacScrollWnd;
{$IFNDEF D2006}
    FOnMouseLeave: TNotifyEvent;
    FOnMouseEnter: TNotifyEvent;
{$ENDIF}
    procedure WndProc (var Message: TMessage); override;
    procedure HeaderWndProc(var Message: TMessage);
    function AllColWidth : integer;
    function FullRepaint : boolean;
    property BorderStyle;
    procedure InvalidateSmooth(Always : boolean);
    function GetImageList : TCustomImageList; virtual;
  public
    ListLineHeight : Integer;
    constructor Create(AOwner: TComponent); override;
    procedure InitControl(const Skinned : boolean); virtual;
    destructor Destroy; override;

    procedure AfterConstruction; override;
    procedure Loaded; override;
    procedure CreateWnd; override;
    procedure SelectItem(Index: Integer);
  published
{$ENDIF} // NOTFORHELP
{$IFDEF D2009}
    property Action;
    property BevelInner;
    property BevelKind;
    property BevelOuter;
    property BevelEdges;
    property DoubleBuffered;
    property Groups;
    property GroupView default False;
    property GroupHeaderImages;
{$ENDIF}
    property BoundLabel : TsBoundLabel read FBoundLabel write FBoundLabel;
    property SkinData : TsCommonData read FCommonData write FCommonData;
    property HighlightHeaders : boolean read FHighlightHeaders write FHighlightHeaders default True;
{$IFDEF D2006}
    property OnMouseEnter;
    property OnMouseLeave;
{$ELSE}
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
{$ENDIF}
{$IFDEF D2009}
    property OnItemChecked;
{$ENDIF}
  end;

  TsListView = class(TsCustomListView)
{$IFNDEF NOTFORHELP}
  published
    property Align;
    property AllocBy;
    property Anchors;
    property BiDiMode;
    property BorderStyle;
    property BorderWidth;
    property Checkboxes;
    property Color;
    property Columns;
    property ColumnClick;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property FlatScrollBars;
    property FullDrag;
    property GridLines;
    property HideSelection;
    property HotTrack;
    property HotTrackStyles;
    property HoverTime;
    property IconOptions;
    property Items;
    property LargeImages;
    property MultiSelect;
    property OwnerData;
    property OwnerDraw;
    property ReadOnly default False;
    property RowSelect;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowColumnHeaders;
    property ShowWorkAreas;
    property ShowHint;
    property SmallImages;
    property SortType;
    property StateImages;
    property TabOrder;
    property TabStop default True;
    property ViewStyle;
    property Visible;
    property OnAdvancedCustomDraw;
    property OnAdvancedCustomDrawItem;
    property OnAdvancedCustomDrawSubItem;
    property OnChange;
    property OnChanging;
    property OnClick;
    property OnColumnClick;
    property OnColumnDragged;
    property OnColumnRightClick;
    property OnCompare;
    property OnContextPopup;
    property OnCustomDraw;
    property OnCustomDrawItem;
    property OnCustomDrawSubItem;
    property OnData;
    property OnDataFind;
    property OnDataHint;
    property OnDataStateChange;
    property OnDblClick;
    property OnDeletion;
    property OnDrawItem;
    property OnEdited;
    property OnEditing;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetImageIndex;
    property OnGetSubItemImage;
    property OnDragDrop;
    property OnDragOver;
    property OnInfoTip;
    property OnInsert;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnSelectItem;
    property OnStartDock;
    property OnStartDrag;
    property BoundLabel;
    property SkinData;
{$ENDIF} // NOTFORHELP
  end;

{$IFNDEF NOTFORHELP}
{$IFDEF TNTUNICODE}
  TsHackedListItems = class(TTntListItems)
{$ELSE}
  TsHackedListItems = class(TListItems)
{$ENDIF}
  public
    FNoRedraw: Boolean;
  end;
{$ENDIF} // NOTFORHELP

implementation

uses sStyleSimply, acntUtils, sVclUtils, sMaskData, sGraphUtils, sSkinProps, sAlphaGraph, sSkinManager, math;

var
  LocalMsg : TMessage;
  LocalFlag : boolean;

constructor TsCustomListView.Create(AOwner: TComponent);
begin
  FhWndHeader     := 0;
  FhDefHeaderProc := nil;
  FPressedColumn  := -1;
  Loading := True;

  inherited Create(AOwner);
  FCommonData := TsCommonData.Create(Self, True);
  FCommonData.COC := COC_TsListView;
  SkinData.BGChanged := True;
  FBoundLabel := TsBoundLabel.Create(Self, FCommonData);
  ListLineHeight := Font.Size;
  FHighlightHeaders := True;
  HoverColIndex := -2;
  FOldAdvancedCustomDraw := nil;
  FOldAdvancedCustomDrawItem := nil;
  try
    FhHeaderProc := MakeObjectInstance(HeaderWndProc);
  except
    Application.HandleException(Self);
  end;
end;

destructor TsCustomListView.Destroy;
begin
  if ListSW <> nil then FreeAndNil(ListSW);
  SmallImages := nil;
  LargeImages := nil;
  if FhWndHeader <> 0 then begin
    SetWindowLong(FhWndHeader, GWL_WNDPROC, LongInt(FhDefHeaderProc));
  end;
  if FhHeaderProc <> nil then begin
    FreeObjectInstance(FhHeaderProc);
  end;
  FreeAndNil(FBoundLabel);
  InitControl(False);
  if Assigned(FCommonData) then FreeAndNil(FCommonData);
  inherited Destroy;
end;

procedure TsCustomListView.AfterConstruction;
begin
  Loading := True;
  inherited AfterConstruction;
end;

procedure TsCustomListView.WndProc(var Message: TMessage);
var
{$IFDEF D2009}
  si : TScrollInfo;
{$ENDIF}
  R : TRect;
  SavedDC : hdc;
  DstPos, Delta : integer;
//  i, TopIndex, LastIndex : integer;
//  iSize : TSize;
//  himg : HIMAGELIST;
begin
{$IFDEF LOGGED}
  AddToLog(Message);
{$ENDIF}
{$IFNDEF D2006}
  case Message.Msg of
    CM_MOUSEENTER : if (Message.LParam = 0) and Assigned(FOnMouseEnter) then FOnMouseEnter(Self);
    CM_MOUSELEAVE : if (Message.LParam = 0) and Assigned(FOnMouseLeave) then FOnMouseLeave(Self);
  end;
{$ENDIF}
{  case Message.Msg of // Is not ready for Aero
    WM_ERASEBKGND : begin
      if SkinData.Skinned then begin
        if (acPrintDC <> 0) then begin
          TWMPaint(Message).DC := acPrintDC;
        end;
        inherited;
      end
      else if TWMPaint(Message).DC <> 0 then begin
        if ViewStyle = vsIcon then begin // blinking removing
          SavedDC := SaveDC(hdc(TWMPaint(Message).DC));

          iSize.cx := 0;
          iSize.cy := 0;

          if ViewStyle = vsIcon then himg := ListView_GetImageList(Handle, LVSIL_NORMAL) else himg := ListView_GetImageList(Handle, LVSIL_SMALL);
          if (himg <> 0) then ImageList_GetIconSize(himg, iSize.cx, iSize.cy);

          if not (ViewStyle in [vsSmallIcon, vsIcon]) then TopIndex := ListView_GetTopIndex(Handle) else TopIndex := 0;
          if ViewStyle in [vsReport, vsList] then LastIndex := TopIndex + ListView_GetCountPerPage(Handle) -1 else LastIndex := Items.Count - 1;
          for i := TopIndex to LastIndex do begin
            if ListView_GetItemRect(Handle, i, NewR, LVIR_ICON) then begin
              R.Left := NewR.Left + (WidthOf(NewR) - iSize.cx) div 2;
              R.Top := NewR.Top + (HeightOf(NewR) - iSize.cy) div 2;
              R.Right := R.Left + iSize.cx;
              R.Bottom := R.Top + iSize.cy;
              ExcludeClipRect(hdc(TWMPaint(Message).DC), R.Left, R.Top, R.Right, R.Bottom);
            end;
            if ListView_GetItemRect(Handle, i, R, LVIR_LABEL) then ExcludeClipRect(hdc(TWMPaint(Message).DC), R.Left, R.Top, R.Right, R.Bottom);
          end;

          inherited;
          RestoreDC(hdc(TWMPaint(Message).DC), SavedDC);
        end
        else inherited;
      end else inherited;
      Exit;
    end;
    WM_VSCROLL : if not SkinData.Skinned then begin
      SendMessage(Handle, WM_SETREDRAW, 0, 0);
      inherited;
      SendMessage(Handle, WM_SETREDRAW, 1, 0);
      Exit;
    end;
  end;  }
  if Message.Msg = SM_ALPHACMD then case Message.WParamHi of
    AC_CTRLHANDLED : begin Message.Result := 1; Exit end; // AlphaSkins supported
    AC_GETAPPLICATION : begin Message.Result := longint(Application); Exit end;
    AC_REMOVESKIN : if LongWord(Message.LParam) = LongWord(SkinData.SkinManager) then begin
      Items.BeginUpdate;
      CommonWndProc(Message, FCommonData);
      if ListSW <> nil then FreeAndNil(ListSW);
      if not FCommonData.CustomColor then begin
        Color := clWindow;
        ListView_SetBkColor(Handle, ColorToRgb(clWindow));
        ListView_SetTextBkColor(Handle, ColorToRgb(clWindow));
      end;
      if not FCommonData.CustomFont then begin
        Font.Color := clWindowText;
        ListView_SetTextColor(Handle, ColorToRgb(clWindowText));
      end;
      Items.EndUpdate;
      InitControl(False);
      RedrawWindow(Handle, nil, 0, RDW_FRAME or RDW_INVALIDATE or RDW_ERASE);// or RDW_UPDATENOW);
      Exit
    end;
    AC_SETNEWSKIN : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
      CommonWndProc(Message, FCommonData);
      InitControl(FCommonData.Skinned);
      exit
    end;
    AC_REFRESH : if (LongWord(Message.LParam) = LongWord(SkinData.SkinManager)) then begin
      Items.BeginUpdate;
      InitControl(True);
      CommonWndProc(Message, FCommonData);
      if FCommonData.Skinned and not Loading then begin
        if not FCommonData.CustomColor then Color := FCommonData.SkinManager.gd[FCommonData.SkinIndex].Color;
        if not FCommonData.CustomFont then Font.Color := FCommonData.SkinManager.gd[FCommonData.SkinIndex].FontColor[1];
        if HandleAllocated and Assigned(Ac_UninitializeFlatSB) then Ac_UninitializeFlatSB(Handle);
        RefreshEditScrolls(SkinData, ListSW);
        RedrawWindow(Handle, nil, 0, RDW_FRAME + RDW_INVALIDATE + RDW_UPDATENOW);
        HeaderWndProc(LocalMsg);
      end;
      Items.EndUpdate;
      Exit;
    end;
    AC_ENDPARENTUPDATE : begin
      SkinData.PrintDC := 0;
      PaintHeader;
      Exit
    end;
    AC_PREPARING : begin
      Message.Result := integer(SkinData.FUpdating);
      Exit;
    end;
    AC_BEFORESCROLL : begin
      Message.Result := 1;
      Exit;
    end;
  end;
  if (csCreating in ControlState) or (FCommonData = nil) or not FCommonData.Skinned then inherited else begin // <- csLoading state is damaged (enabled always)???
    case Message.Msg of
      CM_UIACTIVATE : begin
        Message.Result := 1; // Forbidden a processing by ListWnd (no blinking)
        Exit;
      end;
      LVM_SETCOLUMN, LVM_INSERTCOLUMN : with PLVColumn(Message.LParam)^ do begin
        if iImage = - 1 then Mask := Mask and not LVCF_IMAGE;
      end;
      WM_PRINT : begin
        inherited;
        if (ViewStyle = vsReport) and (ListSW <> nil) then begin
          SavedDC := SaveDC(TWMPaint(Message).DC);
          MoveWindowOrg(TWMPaint(Message).DC, ListSW.cxLeftEdge, ListSW.cxLeftEdge);
          IntersectClipRect(TWMPaint(Message).DC, 0, 0,
                            SkinData.FCacheBmp.Width - 2 * ListSW.cxLeftEdge - integer(ListSW.sBarVert.fScrollVisible) * GetScrollMetric(ListSW.sBarVert, SM_CXVERTSB),
                            SkinData.FCacheBmp.Height - 2 * ListSW.cxLeftEdge - integer(ListSW.sBarHorz.fScrollVisible) * GetScrollMetric(ListSW.sBarHorz, SM_CYHORZSB));
          SkinData.PrintDC := TWMPaint(Message).DC;
          HeaderWndProc(Message);
          RestoreDC(TWMPaint(Message).DC, SavedDC);
        end;
        Exit;
      end;
      WM_SETFOCUS, WM_KILLFOCUS : if not DoubleBuffered then begin
        SendMessage(Handle, WM_SETREDRAW, 0, 0);
        inherited;
        SendMessage(Handle, WM_SETREDRAW, 1, 0);
        if Selected <> nil then ListView_RedrawItems(Handle, Selected.Index, Selected.Index);
        Exit;
      end;
      WM_ERASEBKGND : if (SkinData.PrintDC <> 0) then begin
        TWMPaint(Message).DC := SkinData.PrintDC;
        inherited;
        Exit;
      end
      else begin
        FCommonData.FUpdating := FCommonData.Updating;
        if FCommonData.FUpdating then Exit;
      end;
      WM_VSCROLL : begin
        UpdateScrolls(ListSW, True);
        if Message.WParamLo = SB_THUMBTRACK then begin
          if Message.LParam <> 0 then DstPos := Message.LParam else DstPos := Message.WParamHi;
{$IFDEF D2009}
          if GroupView and (ViewStyle = vsReport) then begin
            si.cbSize := SizeOf(TScrollInfo);
            si.fMask := SIF_ALL;
            GetScrollInfo(Handle, SB_VERT, si);
            nLastSBPos := si.nPos
          end;
{$ENDIF}
          if nLastSBPos <> DstPos then begin // If CurPos is changed
            Delta := DstPos - nLastSBPos;
            if (ViewStyle = vsReport) {$IFDEF D2009} and not GroupView {$ENDIF} then begin
              ListView_GetItemRect(Handle, 0, R, LVIR_BOUNDS);
              Delta := Delta * HeightOf(R);
            end;
            SendMessage(Handle, WM_SETREDRAW, 0, 0);
//            if ViewStyle = vsReport then InvalidateRect(Handle, nil, True); //  !!!
            ListView_Scroll(Handle, 0, Delta);
            if ViewStyle in [vsIcon, vsSmallIcon] then RedrawWindow(Handle, nil, 0, RDW_INVALIDATE);
            SendMessage(Handle, WM_SETREDRAW, 1, 0);
          end;
        end
        else begin
          Message.LParam := 0;
          inherited;
        end;
        Exit;
      end;
      WM_HSCROLL : case Message.WParamLo of
        SB_THUMBTRACK : begin
          if Message.LParam <> 0 then DstPos := Message.LParam else DstPos := Message.WParamHi;
          Delta := DstPos - nLastSBPos;
          if ViewStyle = vsList then begin
            ListView_GetItemRect(Handle, 0, R, LVIR_BOUNDS);
            Delta := Delta * WidthOf(R);
          end;
          ListView_Scroll(Handle, Delta, 0);
          InvalidateSmooth(False);
          PaintHeader;
          Exit;
        end;
        SB_LINELEFT, SB_LINERIGHT : begin
          inherited;
          InvalidateSmooth(False);
          Exit;
        end;
      end;
    end;
    CommonWndProc(Message, FCommonData);
    inherited;
    if FCommonData.Skinned then case Message.Msg of
      CM_MOUSEWHEEL, WM_MOUSEWHEEL : if (TWMMouseWheel(Message).Keys = 0) then begin
        InvalidateSmooth(False);
      end;
      CN_KEYDOWN, CN_KEYUP : case TWMKey(Message).CharCode of VK_PRIOR..VK_DOWN : InvalidateSmooth(False) end;
      CM_SHOWINGCHANGED : begin
        if HandleAllocated and Assigned(Ac_UninitializeFlatSB) then Ac_UninitializeFlatSB(Handle);
        RefreshEditScrolls(SkinData, ListSW);
      end;
      WM_STYLECHANGED : if not (csReadingState in ControlState) then begin
        ListView_Scroll(Handle, 0, 0);
        UpdateScrolls(ListSW, True);
      end;
      LVM_DELETEITEM, LVM_REDRAWITEMS, LVM_INSERTITEMA : if not FCommonData.Updating then UpdateScrolls(ListSW, True);
      WM_NCPAINT: begin
        PaintHeader;
      end;
      CM_VISIBLECHANGED, CM_ENABLEDCHANGED, WM_MOVE, WM_SIZE, WM_WINDOWPOSCHANGED : if FCommonData.Skinned and not (csDestroying in ComponentState) then begin
        Perform(WM_NCPAINT, 0, 0);
        LocalFlag := True;
        InvalidateSmooth(True);
        LocalFlag := False;
        case Message.Msg of
          WM_MOVE, WM_SIZE : begin
            if FullRepaint then SendMessage(Handle, WM_NCPAINT, 0, 0) // Scrollbars repainting if transparent
          end;
        end;
      end;
    end;
  end;
  // Aligning of the bound label
  if Assigned(BoundLabel) and Assigned(BoundLabel.FtheLabel) then case Message.Msg of
    WM_SIZE, WM_WINDOWPOSCHANGED : begin BoundLabel.AlignLabel end;
    CM_VISIBLECHANGED : begin BoundLabel.FtheLabel.Visible := Visible; BoundLabel.AlignLabel end;
    CM_BIDIMODECHANGED : begin BoundLabel.FtheLabel.BiDiMode := BiDiMode; BoundLabel.AlignLabel end;
  end;
end;

procedure TsCustomListView.Loaded;
begin
  Loading := True;
  inherited Loaded;
  Loading := False;
end;

procedure TsCustomListView.CMMouseLeave(var Msg: TMessage);
var
  p : TPoint;
  r : TRect;
begin
  if FCommonData.Skinned and (ViewStyle = vsReport) then begin
    p := ClientToScreen(Point(Left, Top));
    r := Rect(p.x, p.y, p.x + Width, p.y + Height);

    if not PtInRect(r, acMousePos) then inherited;

    if (HoverColIndex >= 0) then begin
      HoverColIndex := -2;
      PaintHeader;
    end;
  end;
  inherited;
end;

procedure TsCustomListView.HeaderWndProc(var Message: TMessage);
var
  Info : THDHitTestInfo;
  CurIndex, w : integer;
  function MouseToColIndex(p : TSmallPoint) : integer;
  var
    ltPoint : TPoint;
    i, c : integer;
    rc : TRect;
  begin
    w := 0;
    if Assigned(ListSW) and Assigned(ListSW.sBarHorz) then w := ListSW.sBarHorz.ScrollInfo.nPos else w := 0;
    ltPoint := ScreenToClient(Point(p.x + w, p.y));
    Result := -2;
    c := (Header_GetItemCount(FhWndHeader) - 1);
    for i := 0 to c do begin
      rc := GetHeaderColumnRect(i);
      if PtInRect(rc, ltPoint) then begin
        Result := Header_OrderToIndex(FhWndHeader, i);
        exit;
      end;
    end;
  end;
begin
  if (ViewStyle = vsReport) and Assigned(FCommonData) and FCommonData.Skinned then begin
    try
      with Message do begin
        case Msg of
          WM_NCHITTEST : if ColumnClick then begin
            Result := CallWindowProc(FhDefHeaderProc, FhWndHeader, Msg, WParam, LParam);
            if FCommonData.Skinned and FHighLightHeaders then begin
              CurIndex := MouseToColIndex(TWMNCHitTest(Message).Pos);
              if HoverColIndex <> CurIndex then begin
                HoverColIndex := CurIndex;
                PaintHeader;
              end;
            end;
          end;
          WM_LBUTTONUP: if ColumnClick then begin
            FPressedColumn := -1;
            FFlag := False;
          end;
          WM_PRINT : begin
            PaintHeader
          end;
          WM_PAINT: if FCommonData.Skinned then begin
            PaintHeader;
            Exit;
          end;
          WM_ERASEBKGND: Exit;
          WM_NCDESTROY: begin
            Result := CallWindowProc(FhDefHeaderProc, FhWndHeader, Msg, WParam, LParam);
            FhWndHeader := 0;
            FhDefHeaderProc := nil;
            Exit;
          end;
        end;
        Result := CallWindowProc(FhDefHeaderProc, FhWndHeader, Msg, WParam, LParam);
        case Msg of
          WM_LBUTTONDOWN: if ColumnClick then begin
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
          WM_MOUSEMOVE : begin
            if FFlag then UpdateScrolls(ListSW, True)
          end;
        end;
      end;
    except
      Application.HandleException(Self);
    end;
  end
  else with Message do
    Result := CallWindowProc(FhDefHeaderProc, FhWndHeader, Msg, WParam, LParam);
end;

procedure TsCustomListView.WMParentNotify(var Message: TWMParentNotify);
var
  WndName : string;
begin
  try
    with Message do begin
      SetLength(WndName, 96);
      SetLength(WndName, GetClassName(ChildWnd, PChar(WndName), Length(WndName)));
      if (Event = WM_CREATE) and (WndName = WC_HEADER) then begin
        if (FhWndHeader <> 0) then begin
          SetWindowLong(FhWndHeader, GWL_WNDPROC, LongInt(FhDefHeaderProc));
          FhWndHeader := 0;
        end;
        if (FhWndHeader = 0) then begin
          FhWndHeader := ChildWnd;
          FhDefHeaderProc := Pointer(GetWindowLong(FhWndHeader, GWL_WNDPROC));
          SetWindowLong(FhWndHeader, GWL_WNDPROC, LongInt(FhHeaderProc));
        end;
      end else
      if (Event = WM_DESTROY) and (WndName = WC_HEADER) then begin
        if (FhWndHeader <> 0) then begin
          SetWindowLong(FhWndHeader, GWL_WNDPROC, LongInt(FhDefHeaderProc));
          FhWndHeader := 0;
        end;
        if (FhWndHeader = 0) then begin
          FhWndHeader := ChildWnd;
          FhDefHeaderProc := Pointer(GetWindowLong(FhWndHeader, GWL_WNDPROC));
          SetWindowLong(FhWndHeader, GWL_WNDPROC, LongInt(FhHeaderProc));
        end;
      end;
    end;
  except
    Application.HandleException(Self);
  end;
  inherited;
end;

procedure TsCustomListView.PaintHeader;
var
  i, Index, count, RightPos : Integer;
  rc, HeaderR : TRect;
  PS : TPaintStruct;
begin
  BeginPaint(FhWndHeader, PS);
  try
    if not FCommonData.FCacheBmp.Empty then begin
      RightPos := 0;
      count := Header_GetItemCount(FhWndHeader) - 1;
      if count > -1 then begin
        // Draw Columns Headers
        for i := 0 to count do begin
          rc := GetHeaderColumnRect(i);
          if not IsRectEmpty(rc) then begin
            ListLineHeight := HeightOf(rc);
            Index := Header_OrderToIndex(FhWndHeader, i);
            ColumnSkinPaint(rc, Index);
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
        if not IsRectEmpty(rc) then begin ColumnSkinPaint(rc, -1); end;
      end;
    end;
  finally
    EndPaint(FhWndHeader, PS);
  end;
end;

function TsCustomListView.GetHeaderColumnRect(Index: Integer): TRect;
var
  SectionOrder : array of Integer;
  rc : TRect;
begin
  if FhWndHeader <> 0 then begin
    if Self.FullDrag then begin
      SetLength(SectionOrder, Columns.Count);
      Header_GetOrderArray(FhWndHeader, Columns.Count, PInteger(SectionOrder));
      Header_GETITEMRECT(FhWndHeader, SectionOrder[Index] , @rc);
    end
    else begin
      Header_GETITEMRECT(FhWndHeader, Index, @rc);
    end;
    Result := rc;
  end
  else Result := Rect(0, 0, 0, 0);
end;

procedure TsCustomListView.ColumnSkinPaint(ControlRect : TRect; cIndex : Integer);
const
  HDF_SORTDOWN = $0200;
  HDF_SORTUP = $0400;
var
  R, TextRC   : TRect;
  tmpdc : HDC;
  TempBmp : Graphics.TBitmap;
  State, si, rWidth : integer;
  Flags : integer;
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
    TempBmp := CreateBmp32(WidthOf(ControlRect), HeightOf(ControlRect));
    R := Rect(0, 0, TempBmp.Width, TempBmp.Height);
    if FPressedColumn >= 0 then State := iffi(FPressedColumn = cIndex, 2, 0) else if HoverColIndex = cIndex then State := 1 else State := 0;
    CI.Ready := False;
    CI.FillColor := Color;
    si := PaintSection(TempBmp, s_ColHeader, s_Button, State, SkinData.SkinManager, ControlRect.TopLeft, CI.FillColor);
    TempBmp.Canvas.Font.Assign(Font);
    TextRC := R;
    InflateRect(TextRC, -4, -1);
    TempBmp.Canvas.Brush.Style := bsClear;
    FillChar(Item, SizeOf(Item), 0);
    FillChar(Buf, SizeOf(Buf), 0);
    Item.pszText := PacChar(@Buf);
    Item.cchTextMax := SizeOf(Buf);
    Item.Mask := HDI_TEXT or HDI_FORMAT or HDI_IMAGE or HDI_BITMAP;
    if (cIndex >= 0) and bool(SendMessage(FHwndHeader, {$IFDEF TNTUNICODE}HDM_GETITEMW{$ELSE}HDM_GETITEM{$ENDIF}, cIndex, Longint(@Item))) then begin
      ws := acString(Item.pszText);
      Flags := DT_END_ELLIPSIS or DT_EXPANDTABS or DT_SINGLELINE or DT_VCENTER;
      if (SmallImages = nil) or (Item.fmt and (LVCFMT_IMAGE or LVCFMT_COL_HAS_IMAGES) = 0) then begin
        Item.iImage := -1;
        gWidth := 0;
      end
      else gWidth := SmallImages.Width + 4;

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
      inc(ts.cx, 6);
      rWidth := WidthOf(ControlRect, True) - 6;
      case (Item.fmt and $0ff) of
        HDF_CENTER : begin
          if ts.cx + gWidth + ArrowSize.cx + 6 >= rWidth then begin
            TextRc.Left := gWidth + 6;
            TextRc.Right := TextRc.Right - ArrowSize.cx;
          end
          else begin
            TextRc.Left := (WidthOf(TextRc) - ts.cx - ArrowSize.cx - gWidth) div 2 + TextRc.Left + gWidth;
            TextRc.Right := TextRc.Left + ts.cx;
          end;
        end;
        HDF_RIGHT : begin
          TextRc.Right := TextRc.Right - ArrowSize.cx;
          if ts.cx + gWidth + ArrowSize.cx + 6 >= rWidth then TextRc.Left := gWidth + 6 else TextRc.Left := TextRc.Right - ts.cx;
        end
        else begin
          TextRc.Left := TextRc.Left + gWidth;
          TextRc.Right := min(rWidth, TextRc.Left + ts.cx);
{          if ts.cx + TextRc.Left >= rWidth
            then TextRc.Right := rWidth - TextRc.Left
            else TextRc.Right := TextRc.Left + ts.cx;}
        end
      end;
      if ArrowIndex <> -1 then DrawSkinGlyph(TempBmp, Point(TextRc.Right + 6, (HeightOf(TextRc) - ArrowSize.cy) div 2), State, 1, SkinData.SkinManager.ma[ArrowIndex], MakeCacheInfo(TempBmp));

      if (State = 2) then OffsetRect(TextRc, 1, 1);
      if UseRightToLeftReading then Flags := Flags or DT_RTLREADING;
      acWriteTextEx(TempBmp.Canvas, PacChar(ws), True, TextRc, Flags, si, (State <> 0), SkinData.SkinManager);
      if (item.iImage <> -1)
        then SmallImages.Draw(TempBmp.Canvas, TextRc.Left - gWidth, (HeightOf(TextRc) - SmallImages.Height) div 2 + integer(State = 2), Item.iImage, Enabled);
    end;

    if SkinData.PrintDC = 0 then tmpdc := GetDC(FhWndHeader) else tmpdc := SkinData.PrintDC;
    try
      BitBlt(tmpdc, ControlRect.Left, ControlRect.Top, R.Right, R.Bottom, TempBmp.Canvas.Handle, 0, 0, SRCCOPY);
    finally
      if SkinData.PrintDC = 0 then ReleaseDC(FhWndHeader, tmpdc);
    end;
    FreeAndNil(TempBmp);
  except
    Application.HandleException(Self);
  end;
end;

procedure TsCustomListView.PrepareCache;
begin
  InitCacheBmp(SkinData);
  PaintItem(FCommonData, GetParentCache(FCommonData), False, 0, Rect(0, 0, Width, Height), Point(Left, Top), FCommonData.FCacheBmp, True);
  FCommonData.BGChanged := False;
end;

procedure TsCustomListView.WMHitTest(var Message: TMessage);
begin
  inherited;
  if FCommonData.Skinned and (HoverColIndex > -1) and FHighLightHeaders then begin
    HoverColIndex := -2;
    PaintHeader;
  end;
end;

function TsCustomListView.AllColWidth: integer;
var
  i, w, c : integer;
begin
  Result := 0;
  c := Columns.Count - 1;
  for i := 0 to c do begin
    w := integer(ListView_GetColumnWidth(Handle, i));
    if abs(w) > 999999 then Exit;
    Result := integer(Result + w);
  end
end;

procedure TsCustomListView.NewAdvancedCustomDraw(Sender: TCustomListView; const ARect: TRect; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
var
  SavedDC : hdc;
  i, TopIndex, LastIndex : integer;
  R : TRect;
begin
  // inherited
  if not (csDesigning in ComponentState) and Assigned(FOldAdvancedCustomDraw) then FOldAdvancedCustomDraw(Sender, Arect, Stage, DefaultDraw) else begin
    DefaultDraw := False;
    if (Stage in [cdPostErase, cdPostPaint]) then Exit;
    if (Stage in [cdPreErase, cdPrePaint]) then begin
      DefaultDraw := True;
      if SkinData.Skinned then begin
        FCommonData.FUpdating := FCommonData.Updating;
        if FCommonData.FUpdating then Exit;
        if SkinData.BGChanged then PrepareCache;
      end;
      if FullRepaint then begin
        SavedDC := SaveDC(Canvas.Handle);
        if (Stage in [cdPrePaint]) and LocalFlag then begin
          if not (ViewStyle in [vsSmallIcon, vsIcon]) then TopIndex := ListView_GetTopIndex(Handle) else TopIndex := 0;
          if ViewStyle in [vsReport, vsList] then LastIndex := TopIndex + ListView_GetCountPerPage(Handle) -1 else LastIndex := Items.Count - 1;
          for i := TopIndex to LastIndex do begin
            if ListView_GetItemRect(Handle, i, R, LVIR_ICON) then ExcludeClipRect(Canvas.Handle, R.Left, R.Top, R.Right, R.Bottom);
            if ListView_GetItemRect(Handle, i, R, LVIR_LABEL) then ExcludeClipRect(Canvas.Handle, R.Left, R.Top, R.Right, R.Bottom);
          end;
        end;
        BitBlt(Canvas.Handle, 0, 0, ClientWidth, ClientHeight, FCommonData.FCacheBmp.Canvas.Handle,
                        integer(BorderStyle = bsSingle) * 2, integer(BorderStyle = bsSingle) * 2, SRCCOPY);
        RestoreDC(Canvas.Handle, SavedDC);
        if (Stage in [cdPrePaint]) and not SkinData.CustomColor then begin
          // Ensure that the items are drawn transparently
          SetBkMode(Canvas.Handle, TRANSPARENT);
          ListView_SetTextBkColor(Handle, CLR_NONE);
          ListView_SetBKColor(Handle, CLR_NONE);
        end;
      end
      else if not SkinData.CustomColor then begin
//        Color := GetBGColor(SkinData, 0);
      end;
      if Stage = cdPreErase then DefaultDraw := False
    end
    else if Stage = cdPostErase then DefaultDraw := False;
  end
end;

function TsCustomListView.FullRepaint: boolean;
begin
  Result := False;
end;

procedure TsCustomListView.InvalidateSmooth(Always : boolean);
begin
  if FullRepaint then begin
    if Always then InvalidateRect(Handle, nil, False) else case ViewStyle of
      vsList : begin
        if (ListSW.sBarHorz.ScrollInfo.nPos < ListSW.sBarHorz.ScrollInfo.nMax - 1) and
          (ListSW.sBarHorz.ScrollInfo.nPos > ListSW.sBarHorz.ScrollInfo.nMin) then InvalidateRect(Handle, nil, False);
      end;
      vsReport : begin
        GetScrollInfo(Handle, SB_VERT, ListSW.sBarVert.ScrollInfo);
        if (ListSW.sBarVert.ScrollInfo.nPos < ListSW.sBarVert.ScrollInfo.nMax - Font.Size - 3) and
             (ListSW.sBarVert.ScrollInfo.nPos > ListSW.sBarVert.ScrollInfo.nMin) then begin
          InvalidateRect(Handle, nil, False);
        end
      end;
    end;
  end;
end;

procedure TsCustomListView.SelectItem(Index: Integer);
begin
  if (Index > -1) and (Index < Items.Count) then begin
    (Items[Index] as TListItem).Selected := True;
    (Items[Index] as TListItem).Focused := True;
    SendMessage(Handle, LVM_ENSUREVISIBLE, Index, 0);
  end;
end;

procedure TsCustomListView.InitControl(const Skinned: boolean);
var
  FTempValue : TLVAdvancedCustomDrawEvent;
  FTempItemValue : TLVAdvancedCustomDrawItemEvent;
begin
  if (csDesigning in ComponentState) then Exit;
  if Skinned then begin
    if Assigned(OnAdvancedCustomDraw) then begin
      FTempValue := NewAdvancedCustomDraw;
      if not Assigned(FOldAdvancedCustomDraw) and (addr(OnAdvancedCustomDraw) <> addr(FTempValue)) then FOldAdvancedCustomDraw := OnAdvancedCustomDraw;
    end
    else FOldAdvancedCustomDraw := nil;
    OnAdvancedCustomDraw := NewAdvancedCustomDraw;

    if not Assigned(OnDrawItem) then begin
      if Assigned(OnAdvancedCustomDrawItem) then begin
        FTempItemValue := NewAdvancedCustomDrawItem;
        if not Assigned(FOldAdvancedCustomDrawItem) and (addr(OnAdvancedCustomDrawItem) <> addr(FTempITemValue))
          then FOldAdvancedCustomDrawItem := OnAdvancedCustomDrawItem;
      end
      else FOldAdvancedCustomDrawItem := nil;
      OnAdvancedCustomDrawItem := NewAdvancedCustomDrawItem;
    end;
  end
  else begin
    if Assigned(FOldAdvancedCustomDraw) then begin
      OnAdvancedCustomDraw := FOldAdvancedCustomDraw;
      FOldAdvancedCustomDraw := nil;
    end
    else begin
      FTempValue := NewAdvancedCustomDraw;
      if addr(OnAdvancedCustomDraw) = addr(FTempValue)
        then OnAdvancedCustomDraw := nil;
    end;

    if not Assigned(OnDrawItem) then begin
      if Assigned(FOldAdvancedCustomDrawItem) then begin
        OnAdvancedCustomDrawItem := FOldAdvancedCustomDrawItem;
        FOldAdvancedCustomDrawItem := nil;
      end
      else begin
        FTempItemValue := NewAdvancedCustomDrawItem;
        if addr(OnAdvancedCustomDrawItem) = addr(FTempItemValue)
          then OnAdvancedCustomDrawItem := nil;
      end;
    end;
  end
end;

procedure TsCustomListView.CreateWnd;
begin
  inherited;
  try
    FCommonData.Loaded;
  except
    Application.HandleException(Self);
  end;
  if FCommonData.Skinned then begin
    if not FCommonData.CustomColor then Color := FCommonData.SkinManager.gd[FCommonData.SkinIndex].Color;
    if not FCommonData.CustomFont then Font.Color := FCommonData.SkinManager.gd[FCommonData.SkinIndex].FontColor[1];
    InitControl(True);
  end;
end;

procedure TsCustomListView.NewAdvancedCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
var
  Bmp : TBitmap;
  fText, nRect, aRect, imgRect, cRect : TRect;
  cw, XOffset, sNdx : integer;
  CI : TCacheInfo;
  Size : TSize;
  DrawStyle : Cardinal;
  DisabledKind : TsDisabledKind;
  ImgList : TCustomImageList;
  b, bSelected : boolean;
{$IFDEF DELPHI6UP}
  iDrawStyle : TDrawingStyle;
{$ENDIF}
  CheckState : TCheckBoxState;
begin
  if (csDesigning in ComponentState) {$IFDEF DELPHI6UP}or not Canvas.HandleAllocated{$ENDIF} then Exit;
  if Assigned(FOldAdvancedCustomDrawItem) then begin
    FOldAdvancedCustomDrawItem(Sender, Item, State, Stage, DefaultDraw);
    Exit;
  end;
  if (Stage in [cdPrePaint, cdPostPaint]) then begin
    CI.Bmp := nil;
    CI.Ready := False;
    CI.FillColor := Color;

    DrawStyle := DT_NOPREFIX or DT_EXPANDTABS or DT_SINGLELINE or DT_VCENTER or DT_NOCLIP;
    if UseRightToLeftReading then DrawStyle := DrawStyle or DT_RTLREADING;

    bSelected := Item.Selected;
    if bSelected then sNdx := SkinData.SkinManager.GetSkinIndex(s_Selection) else sNdx := -1;
    if (ViewStyle = vsReport) and RowSelect then begin // and Item.Selected;
      nRect := Item.DisplayRect(drBounds);
      if IsRectEmpty(nRect) then Exit;
      Bmp := CreateBmp32(WidthOf(nRect), HeightOf(nRect));
      Bmp.Canvas.Font := Canvas.Font;
      aRect := Classes.Rect(0, 0, Bmp.Width, Bmp.Height);
      DrawStyle := DrawStyle or DT_END_ELLIPSIS;
      if (ListSW <> nil) and (ListSW.sBarHorz <> nil) then XOffset := ListSW.sBarHorz.ScrollInfo.nPos else XOffset := 0;

      if bSelected then begin
        if sNdx < 0
          then FillDC(Bmp.Canvas.Handle, aRect, SkinData.SkinManager.GetHighLightColor(cdsFocused in State))
          else PaintItem(sNdx, s_Selection, CI, True, integer(Focused), aRect, Point(nRect.Left, nRect.Top), Bmp, SkinData.SkinManager);
      end
      else FillDC(Bmp.Canvas.Handle, aRect, Color);

      if CheckBoxes then begin
        if Item.Checked then CheckState := cbChecked else CheckState := cbUnChecked;

        fText := Item.DisplayRect(drBounds);
        fText.Left := fText.Left + 3;
        cw := CheckWidth(SkinData.SkinManager) + 2;
        fText.Right := fText.Left + cw;

        CI.X := fText.Left;
        CI.Y := fText.Top;
        FillDC(Bmp.Canvas.Handle, fText, Color);

        acDrawCheck(fText, CheckState, True, Bmp, CI, SkinData.SkinManager);
      end
      else cw := 0;

      FillMemory(@imgRect, SizeOf(ImgRect), 0);
      // Glyph
      ImgList := GetImageList;
      if (ImgList <> nil) then begin
        imgRect := Item.DisplayRect(drIcon);
        OffsetRect(imgRect, XOffset, 0);
        if (Item.ImageIndex > -1) and (Item.ImageIndex < ImgList.Count) then begin
          imgRect.Top := (HeightOf(imgRect) - ImgList.Height) div 2;
          imgRect.Bottom := imgRect.Top + ImgList.Height;
          imgRect.Left := imgRect.Left + (WidthOf(imgRect) - ImgList.Width) div 2;
  {$IFDEF DELPHI6UP}
          ImgList.Draw(Bmp.Canvas, imgRect.Left, imgRect.Top, Item.ImageIndex, dsNormal, itImage);
  {$ELSE}
          ImgList.Draw(Bmp.Canvas, imgRect.Left, imgRect.Top, Item.ImageIndex, True);
  {$ENDIF}
        end
      end
      else OffsetRect(imgRect, cw, 0);

      // Text
      fText := aRect;
      fText.Right := ListView_GetColumnWidth(Handle, 0);
      fText.Left := imgRect.Right + 1;
      if not IsRectEmpty(fText) then begin
        InflateRect(fText, -1, 0);
        fText.Left := fText.Left + 1;
        if (sNdx = -1) or (SkinData.CustomFont) then begin
          Bmp.Canvas.Brush.Style := bsClear;
          if SkinData.CustomFont then begin
            DrawText(Bmp.Canvas.Handle, PChar(Item.Caption), Length(Item.Caption), fText, DrawStyle);
          end
          else begin
            if bSelected
              then Bmp.Canvas.Font.Color := SkinData.SkinManager.GetHighLightFontColor(cdsFocused in State)
              else Bmp.Canvas.Font.Color := SkinData.SkinManager.gd[SkinData.SkinIndex].Props[0].FontColor.Color;
            AcDrawText(Bmp.Canvas.Handle, Item.Caption, fText, DrawStyle);
          end;
        end
        else begin
    {$IFDEF TNTUNICODE}
          acWriteTextEx(Bmp.Canvas, PacChar(TTntListItem(Item).Caption), True, fText, DrawStyle, sNdx, Focused, SkinData.SkinManager);
    {$ELSE}
          acWriteTextEx(Bmp.Canvas, PacChar(Item.Caption), True, fText, DrawStyle, sNdx, Focused, SkinData.SkinManager);
    {$ENDIF}
        end;
      end;

      if not Enabled then begin
        DisabledKind := [dkBlended];
        BmpDisabledKind(Bmp, DisabledKind, Parent, CI, Point(nRect.Left + 3, nRect.Top + 3));
      end;
      for sNdx := 0 to Item.SubItems.Count - 1 do begin
        b := True;
        NewAdvancedCustomDrawSubItem(Self, Item, sNdx, State, Stage, b, MakeCacheInfo(Bmp, -nRect.Left, -nRect.Top));
      end;
      BitBlt(TAccessCanvas(Canvas).FHandle, nRect.Left, nRect.Top, Bmp.Width, Bmp.Height, Bmp.Canvas.Handle, 0, 0, SRCCOPY);
    end
    else begin
      nRect := Item.DisplayRect(drLabel);
      if IsRectEmpty(nRect) then Exit;
      Bmp := CreateBmp32(WidthOf(nRect, True), HeightOf(nRect, True));
      Bmp.Canvas.Font.Assign(Canvas.Font);

      aRect := Classes.Rect(0, 0, Bmp.Width, Bmp.Height);
      FillDC(Bmp.Canvas.Handle, aRect, Color);

      case ViewStyle of
        vsReport : DrawStyle := DrawStyle or DT_END_ELLIPSIS;
        vsIcon : begin
          DrawStyle := DrawStyle and not DT_SINGLELINE and not DT_VCENTER;
          DrawStyle := DrawStyle or DT_CENTER or DT_WORDBREAK or DT_END_ELLIPSIS or DT_WORD_ELLIPSIS;

          if bSelected {$IFDEF DELPHI6UP} {or ((ItemIndex = -1) and (cdsFocused in State)) problem with items captions (selected is changed)} {$ENDIF} then begin
            fText := aRect;
            AcDrawText(Bmp.Canvas.Handle, Item.Caption, fText, DrawStyle or DT_CALCRECT and not DT_END_ELLIPSIS);
            aRect.Bottom := min(fText.Bottom + 2, Bmp.Height);
            Bmp.Height := HeightOf(aRect);
          end;
        end;
      end;

      if bSelected then begin
        fText := aRect;
        case ViewStyle of
          vsSmallIcon, vsList, vsReport : begin
            acGetTextExtent(Bmp.Canvas.Handle, Item.Caption, Size);
            fText.Right := ftext.Left + Size.cx + 5;
//            if CheckBoxes then
{
            AcDrawText(Bmp.Canvas.Handle, Item.Caption, fText, DrawStyle or DT_CALCRECT);
            fText.Right := ftext.Right + 5;
            fText.Left := aRect.Left;
            fText.Bottom := aRect.Bottom
}
          end;
        end;
        if sNdx < 0
          then FillDC(Bmp.Canvas.Handle, Classes.Rect(0, 0, min(WidthOf(fText), Bmp.Width), Bmp.Height), SkinData.SkinManager.GetHighLightColor(cdsFocused in State))
          else PaintItem(sNdx, s_Selection, CI, True, integer(Focused), Classes.Rect(0, 0, min(WidthOf(fText), Bmp.Width), Bmp.Height), Point(0, 0), Bmp, SkinData.SkinManager);
      end
      else sNdx := -1;

      if ViewStyle <> vsIcon then begin
        inc(aRect.Left);
        InflateRect(aRect, -1, 0);
{      end
      else begin // Patch for problem with std ellipsis
        acGetTextExtent(Bmp.Canvas.Handle, Item.Caption, Size);
        dec(aRect.Bottom, (HeightOf(aRect) mod Size.cy) + 1);}
      end;

      if (sNdx = -1) or (SkinData.CustomFont) then begin
        Bmp.Canvas.Brush.Style := bsClear;
        if SkinData.CustomFont then begin
          AcDrawText(Bmp.Canvas.Handle, Item.Caption, aRect, DrawStyle);
        end
        else begin
          if bSelected then Bmp.Canvas.Font.Color := SkinData.SkinManager.GetHighLightFontColor(cdsFocused in State) else Bmp.Canvas.Font.Color := Font.Color;
          AcDrawText(Bmp.Canvas.Handle, Item.Caption, aRect, DrawStyle);
        end;
      end
      else begin
{$IFDEF TNTUNICODE}
        acWriteTextEx(Bmp.Canvas, PacChar(TTntListItem(Item).Caption), True, aRect, DrawStyle, sNdx, Focused, SkinData.SkinManager);
{$ELSE}
        acWriteTextEx(Bmp.Canvas, PacChar(Item.Caption), True, aRect, DrawStyle, sNdx, Focused, SkinData.SkinManager);
{$ENDIF}
      end;
      if bSelected and (Focused) and (sNdx < 0) then begin
        DrawFocusRect(Bmp.Canvas.Handle, fText);
      end;

      if not Enabled then begin
        DisabledKind := [dkBlended];
        BmpDisabledKind(Bmp, DisabledKind, Parent, CI, Point(nRect.Left + 3, nRect.Top + 3));
      end;

      BitBlt(TAccessCanvas(Canvas).FHandle, nRect.Left, nRect.Top, Bmp.Width, Bmp.Height, Bmp.Canvas.Handle, 0, 0, SRCCOPY);

      cw := 0;
      if CheckBoxes then begin
        if Item.Checked then CheckState := cbChecked else CheckState := cbUnChecked;

        cw := CheckWidth(SkinData.SkinManager) + 2;
        if ViewStyle = vsIcon then begin
          if (Item.ImageIndex > -1) and (LargeImages <> nil) then begin
            cRect := Item.DisplayRect(drIcon);
            if (Win32MajorVersion > 5) then begin // if Vista and newer
              cRect.Left := cRect.Left + (WidthOf(cRect) - LargeImages.Width - cw) div 2;
              cRect.Top := cRect.Top + (HeightOf(cRect) - cw) div 2;
            end
            else begin
              cRect.Left := cRect.Left + (WidthOf(cRect) - LargeImages.Width) div 2 - cw - 2;
              cRect.Top := cRect.Top + (HeightOf(cRect) - cw) div 2 + 6;
            end;
          end
          else begin
            cRect := Item.DisplayRect(drBounds);
            if (Win32MajorVersion > 5) then begin // if Vista and newer
              inc(cRect.Top, 4);
              cRect.Left := cRect.Left + (WidthOf(cRect) - cw - 2) div 2 - cw;
            end
            else begin
              cRect.Top := Item.DisplayRect(drLabel).Top - cw - 6;
              cRect.Left := cRect.Left + (WidthOf(cRect) - cw - 2) div 2 - cw;
            end;
          end;
          cRect.Bottom := cRect.Top + cw;
        end
        else begin
          cRect := Item.DisplayRect(drBounds);
          cRect.Left := cRect.Left + 3;
        end;
        cRect.Right := cRect.Left + cw;

        Bmp.Width := cw;
        Bmp.Height := HeightOf(cRect);
        CI.X := cRect.Left;
        CI.Y := cRect.Top;
        FillDC(Bmp.Canvas.Handle, Rect(0, 0, Bmp.Width, Bmp.Height), Color);

        acDrawCheck(Rect(0, 0, Bmp.Width, Bmp.Height), CheckState, True, Bmp, CI, SkinData.SkinManager);
        BitBlt(TAccessCanvas(Canvas).FHandle, cRect.Left, cRect.Top, Bmp.Width, Bmp.Height, Bmp.Canvas.Handle, 0, 0, SRCCOPY);
      end;

      if (Item.ImageIndex > -1) then begin
        ImgList := GetImageList;
        if (ImgList <> nil) and (Item.ImageIndex < ImgList.Count) then begin
          aRect := Item.DisplayRect(drIcon);
          if (Win32MajorVersion > 5) then begin // if Vista and newer
            aRect.Left := aRect.Left + (WidthOf(aRect) - ImgList.Width - cw) div 2 + cw;
          end
          else begin
            aRect.Left := aRect.Left + (WidthOf(aRect) - ImgList.Width) div 2;
          end;
          aRect.Top := aRect.top + (HeightOf(aRect) - ImgList.Height) div 2;

          FillDC(TAccessCanvas(Canvas).FHandle, aRect, Color);
  {$IFDEF DELPHI6UP}
          if bSelected and Focused then iDrawStyle := dsFocus else iDrawStyle := dsNormal;
          ImgList.Draw(Canvas, aRect.Left, aRect.Top, Item.ImageIndex, iDrawStyle, itImage);
  {$ELSE}
          ImgList.Draw(Canvas, aRect.Left, aRect.Top, Item.ImageIndex, True);
  {$ENDIF}
        end
      end;

      if (ViewStyle = vsReport) then begin
        CI.Bmp := nil;
        CI.Ready := False;
        CI.FillColor := Color;
        for sNdx := 0 to Item.SubItems.Count - 1 do begin
          b := True;
          NewAdvancedCustomDrawSubItem(Self, Item, sNdx, State, Stage, b, CI);
        end;
      end;
    end;
    FreeAndNil(Bmp);
    DefaultDraw := False;
  end;
end;

function TsCustomListView.GetImageList: TCustomImageList;
begin
  if (ViewStyle in [vsIcon]) then result := LargeImages else result := SmallImages;
end;

procedure TsCustomListView.NewAdvancedCustomDrawSubItem(Sender: TCustomListView; Item: TListItem; SubItem: Integer; State: TCustomDrawState; Stage: TCustomDrawStage; var DefaultDraw: Boolean; CI : TCacheInfo);
var
  Bmp : TBitmap;
  fText, nRect, aRect : TRect;
  sNdx : integer;
  DrawStyle : longint;
  DisabledKind : TsDisabledKind;
  iNdx, XOffset : integer;
  bSelected : boolean;
begin
  if (csDesigning in ComponentState) or (ViewStyle <> vsReport) then Exit;
  if Assigned(OnAdvancedCustomDrawSubItem) then begin
    OnAdvancedCustomDrawSubItem(Sender, Item, SubItem + 1, State, Stage, DefaultDraw);
    if not DefaultDraw then Exit;
  end;
  if Assigned(OnCustomDrawSubItem) then begin
    OnCustomDrawSubItem(Sender, Item, SubItem + 1, State, DefaultDraw);
    if not DefaultDraw then Exit;
  end;
  if SkinData.Skinned then if (Stage in [cdPrePaint, cdPostPaint]) then begin
    bSelected := Item.Selected;
    aRect := Item.DisplayRect(drBounds);
    if IsRectEmpty(aRect) then Exit;

    aRect.Left := ColumnLeft(SubItem + 1);
    aRect.Right := aRect.Left + ListView_GetColumnWidth(Handle, SubItem + 1);

    if aRect.Left = aRect.Right then Exit;

    Bmp := CreateBmp32(WidthOf(aRect, True), HeightOf(aRect, True));
    // Text rect receiving
    nRect := Item.DisplayRect(drLabel);
    iNdx := Item.SubItemImages[SubItem];
    if Assigned(SmallImages) and (iNdx >= 0) then fText.Left := SmallImages.Width + 8 else fText.Left := 3;
    fText.Right := Bmp.Width - 4;
    fText.Top := nRect.Top - aRect.Top;
    fText.Bottom := Bmp.Height + (nRect.Bottom - aRect.Bottom);

    if (ListSW <> nil) and (ListSW.sBarHorz <> nil) then XOffset := ListSW.sBarHorz.ScrollInfo.nPos else XOffset := 0;
    if CI.Ready
      then BitBlt(Bmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, CI.Bmp.Canvas.Handle, aRect.Left + CI.X - XOffset, 0, SRCCOPY)
      else FillDC(Bmp.Canvas.Handle, Classes.Rect(0, 0, Bmp.Width, Bmp.Height), Color);

    if Assigned(SmallImages) and (iNdx <> -1) and (iNdx < SmallImages.Count) then begin
      SmallImages.Draw(Bmp.Canvas, 1, (Bmp.Height - SmallImages.Height) div 2, iNdx);
    end;

    DrawStyle := DT_NOPREFIX or DT_EXPANDTABS or DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS or GetStringFlags(Self, Columns[Subitem + 1].Alignment);
    if Item.Selected and RowSelect then sNdx := SkinData.SkinManager.GetSkinIndex(s_Selection) else sNdx := -1;
    Bmp.Canvas.Font.Assign(Canvas.Font);
    Bmp.Canvas.Brush.Style := bsClear;
    if sNdx = -1 then begin
      if not SkinData.CustomFont then begin
        if Item.Selected and RowSelect then Bmp.Canvas.Font.Color := SkinData.SkinManager.GetHighLightFontColor(cdsFocused in State) else Bmp.Canvas.Font.Color := Font.Color;
      end;
      AcDrawText(Bmp.Canvas.Handle, Item.SubItems[SubItem], fText, DrawStyle);
    end
    else begin
      if not SkinData.CustomFont then begin
        if bSelected then Bmp.Canvas.Font.Color := SkinData.SkinManager.GetHighLightFontColor(cdsFocused in State) else Bmp.Canvas.Font.Color := Font.Color;
      end;
      AcDrawText(Bmp.Canvas.Handle, Item.SubItems[SubItem], fText, DrawStyle);
    end;
    if not Enabled then begin
      DisabledKind := [dkBlended];
      BmpDisabledKind(Bmp, DisabledKind, Parent, CI, Point(aRect.Left + 3, aRect.Top + 3));
    end;
    if CI.Ready
      then BitBlt(CI.Bmp.Canvas.Handle, aRect.Left + CI.X - XOffset, aRect.Top + CI.Y, Bmp.Width, Bmp.Height, Bmp.Canvas.Handle, 0, 0, SRCCOPY)
      else BitBlt(Canvas.Handle, aRect.Left - XOffset, aRect.Top, Bmp.Width, Bmp.Height, Bmp.Canvas.Handle, 0, 0, SRCCOPY);

    FreeAndNil(Bmp);

    DefaultDraw := False;
  end;
end;

function TsCustomListView.ColumnLeft(Index: integer): integer;
var
  i : integer;
begin
  Result := 0;
  for i := 1 to Index do inc(Result, ListView_GetColumnWidth(Handle, i - 1));
end;

end.
