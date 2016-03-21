unit sSkinMenus;
{$I sDefs.inc}
{.$DEFINE LOGGED}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, sConst,
  Menus, ExtCtrls{$IFDEF LOGGED}, sDebugMsgs{$ENDIF} {$IFDEF TNTUNICODE}, TntMenus {$ENDIF};

type
  TsMenuItemType = (smCaption, smDivider, smNormal, smTopLine);
  TsMenuManagerDrawItemEvent = procedure (Sender: TObject; ACanvas: TCanvas; ARect: TRect; State: TOwnerDrawState; ItemType: TsMenuItemType) of object;

  TacMenuSupport = class(TPersistent)
  private
    FIcoLineSkin: TsSkinSection;
    FUseExtraLine: boolean;
    FExtraLineWidth: integer;
    FExtraLineFont: TFont;
    procedure SetExtraLineFont(const Value: TFont);
  public
    constructor Create;
    destructor Destroy; override;
  published
    property IcoLineSkin : TsSkinSection read FIcoLineSkin write FIcoLineSkin;
    property UseExtraLine : boolean read FUseExtraLine write FUseExtraLine default False;
    property ExtraLineWidth : integer read FExtraLineWidth write FExtraLineWidth default 32;
    property ExtraLineFont : TFont read FExtraLineFont write SetExtraLineFont;
  end;

  TMenuItemData = record
    Item : TMenuItem;
    R : TRect;
  end;

  TacMenuInfo = record
    FirstItem : TMenuItem;
    Bmp : TBitmap;
    Wnd : hwnd;
    HaveExtraLine : boolean;
  end;

  TsSkinableMenus = class(TPersistent)
  private
    FMargin : integer;
    FAlignment: TAlignment;
    FBevelWidth: integer;
    FBorderWidth: integer;
    FCaptionFont: TFont;
    FSkinBorderWidth: integer;
    FSpacing: integer;
    procedure SetCaptionFont(const Value: TFont);
    procedure SetAlignment(const Value: TAlignment);
    procedure SetBevelWidth(const Value: integer);
    procedure SetBorderWidth(const Value: integer);
    function GetSkinBorderWidth: integer;
  protected
    FOnDrawItem: TsMenuManagerDrawItemEvent;

    function ParentHeight(aCanvas: TCanvas; Item: TMenuItem): integer;
    function GetItemHeight(aCanvas: TCanvas; Item: TMenuItem): integer;
    function ParentWidth(aCanvas: TCanvas; Item: TMenuItem): integer;
    function GetItemWidth(aCanvas: TCanvas; Item: TMenuItem; mi : TacMenuInfo): integer;
    function IsDivText(Item: TMenuItem): boolean;

    procedure PaintDivider(aCanvas : TCanvas; aRect : TRect; Item: TMenuItem; MenuBmp : TBitmap; mi : TacMenuInfo);
    procedure PaintCaption(aCanvas : TCanvas; aRect : TRect; Item : TMenuItem; BG : TBitmap; mi : TacMenuInfo);

    function CursorMarginH : integer;
    function CursorMarginV : integer;
    function ItemRect(Item : TMenuItem; aRect : TRect) : TRect;
  public
    ArOR : TAOR;
    FActive : boolean;
    FOwner : TComponent;
    Pressed : boolean;
    BorderDrawing : boolean;

    function IsTopLine(Item: TMenuItem): boolean;
    procedure sMeasureItem(Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);
    procedure sAdvancedDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; State: TOwnerDrawState); dynamic;
    procedure DrawWndBorder(Wnd : hWnd; MenuBmp : TBitmap);
    function PrepareMenuBG(Item: TMenuItem; Width, Height : integer; Wnd : hwnd = 0) : TBitmap;

    procedure sMeasureLineItem(Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);
    procedure sAdvancedDrawLineItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; State: TOwnerDrawState); dynamic;
    function IsOpened(Item : TMenuItem) : boolean;

    procedure SetActive(const Value: boolean);
    constructor Create (AOwner: TComponent);
    destructor Destroy; override;
    procedure InitItem(Item : TMenuItem; A : boolean);
    procedure InitItems(A: boolean);
    procedure InitMenuLine(Menu : TMainMenu; A : boolean);
    procedure HookItem(MenuItem: TMenuItem; FActive: boolean);//!!!!
    procedure HookPopupMenu(Menu: TPopupMenu; Active: boolean);
    procedure UpdateMenus;
    function LastItem(Item : TMenuItem) : boolean;
    function IsPopupItem(Item : TMenuItem) : boolean;
    function GetMenuInfo(Item : TMenuItem; const aWidth, aHeight : integer; aWnd : hwnd = 0) : TacMenuInfo;

    function ExtraWidth(mi : TacMenuInfo) : integer;
  published
    property Alignment: TAlignment read FAlignment write SetAlignment;
    property BevelWidth : integer read FBevelWidth write SetBevelWidth default 0;
    property BorderWidth : integer read FBorderWidth write SetBorderWidth default 3;
    property CaptionFont : TFont read FCaptionFont write SetCaptionFont;
    property SkinBorderWidth : integer read GetSkinBorderWidth write FSkinBorderWidth;
    property Margin: integer read FMargin write FMargin default 2;
    property Spacing : integer read FSpacing write FSpacing default 8;
    property OnDrawItem: TsMenuManagerDrawItemEvent read FOnDrawItem write FOnDrawItem;
  end;

function Breaked(MenuItem : TMenuItem) : boolean;
function GlyphSize(Item: TMenuItem; Top: boolean): TSize;
function GetFirstItem(Item : TMenuItem) : TMenuItem;
procedure DeleteUnusedBmps(DeleteAll : boolean);
function ChildIconPresent : boolean;
procedure ClearCache;

var
  MenuInfoArray : array of TacMenuInfo;
  MDISkinProvider : TObject;
  acCanHookMenu : boolean = False;
  CustomMenuFont : TFont = nil;

const
  s_SysMenu = 'SysMenu';

implementation

uses {sContextMenu, }sDefaults, math, sStyleSimply, sSkinProvider, sMaskData, sSkinProps, {$IFDEF TNTUNICODE}TntWindows, {$ENDIF}
  sGraphUtils, sGradient, acntUtils, sAlphaGraph, sSkinManager, sMDIForm, sVclUtils, sMessages;

const
  DontForget = 'Use OnGetExtraLineData event';

var
  Measuring : boolean = False;
  it : TsMenuItemType;
  AlignToInt: array[TAlignment] of Cardinal = (DT_LEFT, DT_RIGHT, DT_CENTER);

  // Temp data
  IcoLineWidth : integer = 0;
  GlyphSizeCX : integer = 0;

  ExtraCaption : string;
  ExtraSection : string;
  ExtraGlyph : TBitmap;

function ChildIconPresent : boolean;
begin
  Result := (MDISkinProvider <> nil) and
     (TsSkinProvider(MDISkinProvider).Form <> nil) and
       (TsSkinProvider(MDISkinProvider).Form.FormStyle = fsMDIForm) and
         (TsSkinProvider(MDISkinProvider).Form.ActiveMDIChild <> nil) and
           (TsSkinProvider(MDISkinProvider).Form.ActiveMDIChild.WindowState = wsMaximized) and (biSystemMenu in TsSkinProvider(MDISkinProvider).Form.ActiveMDIChild.BorderIcons) and
             Assigned(TsSkinProvider(MDISkinProvider).Form.ActiveMDIChild.Icon);
end;

function GetFirstItem(Item : TMenuItem) : TMenuItem;
begin
  Result := Item.Parent.Items[0];
end;

procedure DeleteUnusedBmps(DeleteAll : boolean);
var
  i, l : integer;
begin
  l := Length(MenuInfoArray);
//  if DeleteAll then begin
    for i := 0 to l - 1 do MenuInfoArray[i].Bmp.Free;
    SetLength(MenuInfoArray, 0);
{  end
  else for i := 0 to l - 1 do begin
    for j := 0 to Length(MnuArray) - 1 do begin
      if (MnuArray[j] <> nil) and not MnuArray[j].Destroyed and (MnuArray[j].CtrlHandle = MenuInfoArray[i].Wnd) then begin
        if i <> l - 1 then begin
          MenuInfoArray[i] := MenuInfoArray[l - 1];
        end;
        SetLength(MenuInfoArray, l - 1);
      end;
    end;
  end;}
end;

{ TsSkinableMenus }

function Breaked(MenuItem : TMenuItem) : boolean;
var
  i : integer;
begin
  Result := False;
  for i := 0 to MenuItem.MenuIndex do if MenuItem.Parent.Items[i].Break <> mbNone then begin
    Result := True;
    Break;
  end;
end;

function GlyphSize(Item: TMenuItem; Top: boolean): TSize;
var
  mi : TMenu;
begin
  Result.cx := 0;
  Result.cy := 0;
  if Top then begin
    if not Item.Bitmap.Empty then begin
      Result.cx := Item.Bitmap.Width;
      Result.cy := Item.Bitmap.Height;
    end;
  end
  else begin
    if not Item.Bitmap.Empty then begin
      Result.cx := Item.Bitmap.Width;
      Result.cy := Item.Bitmap.Height;
    end
    else begin
      if Assigned(Item.Parent) and (Item.Parent.SubMenuImages <> nil) then begin
        Result.cx := Item.Parent.SubMenuImages.Width;
        Result.cy := Item.Parent.SubMenuImages.Height;
      end
      else begin
        mi := Item.GetParentMenu;
        if Assigned(mi) and Assigned(mi.Images) then begin
          Result.cx := Item.GetParentMenu.Images.Width;
          Result.cy := Item.GetParentMenu.Images.Height;
        end
        else begin
          Result.cx := 16;
          Result.cy := 16;
        end;
      end;
    end;
  end;
end;

constructor TsSkinableMenus.Create(AOwner: TComponent);
{var
  pl : TList;
  i : integer;}
begin
  FOwner := AOwner;
  FActive := False;
  FCaptionFont := TFont.Create;
  FMargin := 2;
  FBevelWidth := 0;
  FBorderWidth := 3;
  BorderDrawing := False;
  FSpacing := 8;

  if csDesigning in FOwner.ComponentState then Exit;
{
  if (PopupList <> nil) then if PopupList is TsPopupList then Exit else begin
    pl := TList.Create;
    for i := 0 to PopupList.Count - 1 do pl.Add(PopupList[i]);
    FreeAndNil(PopupList);
    PopupList := TsPopupList.Create;
    for i := 0 to pl.Count - 1 do PopupList.Add(pl[i]);
    FreeAndNil(pl);
  end
  else PopupList := TsPopupList.Create;
}
end;

procedure TsSkinableMenus.sAdvancedDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; State: TOwnerDrawState);
const
  s_Webdings = 'Webdings';
var
  R, gRect, cRect : TRect;
  i, j: integer;
  ci : TCacheInfo;
  Item : TMenuItem;
  gChar : string;

  Text: acString;
  ItemBmp : TBitmap;
  DrawStyle : longint;
  Wnd : hwnd;
  NewDC : hdc;
  aMsg: TMSG;
  Br : integer;
  f : TCustomForm;
  BGImage : TBitmap;
  mi : TacMenuInfo;
  RTL, RTLReading : boolean;
  function TextRect: TRect; begin
    Result := aRect;
    OffsetRect(Result, - aRect.Left, - aRect.Top);
    if RTL then begin
      dec(Result.Right, Margin * 2 + GlyphSize(Item, False).cx + Spacing);
    end
    else begin
      inc(Result.Left, Margin * 2 + GlyphSize(Item, False).cx + Spacing);
    end;
  end;
  function ShortCutRect(const s : acString): TRect;
  var
    tr : TRect;
  begin
    Result := aRect;
    tR := Rect(0, 0, 1, 0);
    acDrawText(ItemBmp.Canvas.Handle, PacChar(Text), tR, DT_EXPANDTABS or DT_SINGLELINE or DT_CALCRECT);
    OffsetRect(Result, - aRect.Left, - aRect.Top);
    if RTL then begin
      Result.Left := 6;
    end
    else Result.Left := aRect.Right - WidthOf(tr) - 8;
  end;
  function IsTopVisible(Item : TMenuItem) : boolean; var i : integer; begin
    Result := False;
    for i := 0 to Item.Parent.Count - 1 do if Item.Parent.Items[i].Visible then begin
      if Item.Parent.Items[i] = Item then Result := True;
      Break
    end;
  end;
  function IsBtmVisible(Item : TMenuItem) : boolean; var i : integer; begin
    Result := False;
    for i := 0 to Item.Parent.Count - 1 do if Item.Parent.Items[Item.Parent.Count - 1 - i].Visible then begin
      if Item.Parent.Items[Item.Parent.Count - 1 - i] = Item then Result := True;
      Break
    end;
  end;
begin
  if (FOwner = nil) or not (TsSkinManager(FOwner).Active) then Exit;

  Item := TMenuItem(Sender);
  Wnd := Item.GetParentMenu.WindowHandle;
  if Wnd <> 0 then begin
    RTLReading := GetWindowLong(Wnd, GWL_EXSTYLE) and WS_EX_RTLREADING = WS_EX_RTLREADING;
    RTL := GetWindowLong(Wnd, GWL_EXSTYLE) and WS_EX_RIGHT = WS_EX_RIGHT;
  end
  else begin
    RTLReading := False;
    RTL := False;
  end;

  Br := integer(not Breaked(Item));
  if TempControl <> nil then begin
    if ShowHintStored then Application.ShowHint := AppShowHint;
    SendAMessage(TControl(TempControl), WM_MOUSELEAVE);
    TempControl := nil;
  end;
  try
    if IsNT then Wnd := WindowFromDC(ACanvas.Handle) else Wnd := 0;
    if Wnd <> 0 then GetWindowRect(Wnd, R) else begin
      R.TopLeft := Point(0, 0);
      R.Right := ParentWidth(ACanvas, Item) + BorderWidth * 2;
      R.Bottom := ParentHeight(ACanvas, Item) + BorderWidth * 2;
    end;
    mi := GetMenuInfo(Item, WidthOf(R), HeightOf(R), Wnd);
    BGImage := mi.Bmp; // !
    if IsNT and (Wnd <> 0) then begin
      NewDC := GetWindowDC(Wnd);
      if (BGImage <> nil) and (BGImage.Canvas.Handle <> 0) then try
        if IsTopVisible(Item) then // First item
          BitBlt(NewDC, 0, 0, BGImage.Width, BorderWidth, BGImage.Canvas.Handle, 0, 0, SRCCOPY);
        if IsBtmVisible(Item) then // Last item
          BitBlt(NewDC, 0, BGImage.Height - BorderWidth, BGImage.Width, BorderWidth, BGImage.Canvas.Handle, 0, BGImage.Height - BorderWidth, SRCCOPY);
        // Left border
        BitBlt(NewDC, 0, aRect.Top + BorderWidth, ExtraWidth(mi) * Br + max(SkinBorderWidth, BorderWidth), HeightOf(aRect),
               BGImage.Canvas.Handle, 0, aRect.Top + BorderWidth, SRCCOPY);
        // Right border
        BitBlt(NewDC, BGImage.Width - BorderWidth, aRect.Top + BorderWidth, BorderWidth, HeightOf(aRect),
               BGImage.Canvas.Handle, BGImage.Width - BorderWidth, aRect.Top + BorderWidth, SRCCOPY);
      finally
        ReleaseDC(Wnd, NewDC);
      end;
    end;
    if (Wnd = 0) then begin
      if (Application.Handle <> 0) then begin
        if not PeekMessage(aMsg, Application.Handle, WM_DRAWMENUBORDER, WM_DRAWMENUBORDER2, PM_NOREMOVE)
          then PostMessage(Application.Handle, WM_DRAWMENUBORDER, 0, Integer(Item));
      end
      else begin
{        if GetMenuItemRect(PopupList.Window, Item.Parent.Handle, Item.MenuIndex, R) then begin
          Wnd := WindowFromPoint(Point(r.Left + WidthOf(r) div 2, r.Top + HeightOf(r) div 2));
          if (Wnd <> 0)
            then DefaultManager.SkinableMenus.DrawWndBorder(Wnd, BGImage);
        end; problem of LC, must be checked}
      end;
    end;

    if Item.IsLine then begin
      PaintDivider(aCanvas, aRect, Item, BGImage, mi);
      Exit;
    end
    else if IsDivText(Item) then begin
      mi := GetMenuInfo(Item, WidthOf(R), HeightOf(R), Wnd);
      PaintCaption(aCanvas, aRect, Item, BGImage, mi);
      Exit;
    end;
    it := smNormal;
    if BGImage = nil then Exit;

    // Check for multi-columned menus...
    if (Item.MenuIndex < Item.Parent.Count - 1) then begin
      if (Item.Parent.Items[Item.MenuIndex + 1].Break <> mbNone)
        then BitBlt(ACanvas.Handle, aRect.Left, aRect.Bottom, WidthOf(aRect), BGImage.Height - 6 - aRect.Bottom, BGImage.Canvas.Handle, aRect.Left + 3, aRect.Bottom + 3, SrcCopy);
    end
    else if aRect.Bottom < BGImage.Height - 6
      then BitBlt(ACanvas.Handle, aRect.Left, aRect.Bottom, WidthOf(aRect), BGImage.Height - 6 - aRect.Bottom, BGImage.Canvas.Handle, aRect.Left + 3, aRect.Bottom + 3, SrcCopy);
    if (Item.Break <> mbNone) then begin
      BitBlt(ACanvas.Handle, aRect.Left - 4, aRect.Top, 4, BGImage.Height - 6, BGImage.Canvas.Handle, aRect.Left - 1, aRect.Top + 3, SrcCopy);
    end; //

    ItemBmp := CreateBmp32(max(WidthOf(aRect, True) - ExtraWidth(mi) * Br, 0), HeightOf(aRect, True));
    // Draw MenuItem
    i := TsSkinManager(FOwner).GetSkinIndex(s_MenuItem);
//    if odSelected in State
//      then ItemBmp.Width := ItemBmp.Width;

    if TsSkinManager(FOwner).IsValidSkinIndex(i) then begin
      ci := MakeCacheInfo(BGImage, 3, 3);
      PaintItem(i, s_MenuItem, ci, True, integer(Item.Enabled and (odSelected in State)), Rect(0, 0, ItemBmp.Width, HeightOf(aRect)),
              Point(aRect.Left + ExtraWidth(mi) * Br, aRect.Top), ItemBmp.Canvas.Handle, FOwner);
    end;

    if odChecked in State then begin
      if Item.Bitmap.Empty and ((Item.GetImageList = nil) or (Item.ImageIndex < 0)) then begin
        if Item.RadioItem
          then j := TsSkinManager(FOwner).GetMaskIndex(s_GlobalInfo, s_RadioButtonChecked)
          else j := TsSkinManager(FOwner).GetMaskIndex(s_GlobalInfo, s_CheckGlyph);
        if j = -1 then j := TsSkinManager(FOwner).GetMaskIndex(s_GlobalInfo, s_CheckBoxChecked);
        if j > -1 then begin
          cRect.Top    := 0;
          cRect.Bottom := HeightOfImage(TsSkinManager(FOwner).ma[j]);
          if RTL then begin
            cRect.Right  := ItemBmp.Width - 2;
            cRect.Left   := cRect.Right - WidthOfImage(TsSkinManager(FOwner).ma[j]);
          end
          else begin
            cRect.Left   := 0;
            cRect.Right  := WidthOfImage(TsSkinManager(FOwner).ma[j]);
          end;
          OffsetRect(cRect, Margin, (HeightOf(aRect) - cRect.Bottom) div 2);
          DrawSkinGlyph(ItemBmp, cRect.TopLeft, integer(Item.Enabled and (odSelected in State)), 1, TsSkinManager(FOwner).ma[j], MakeCacheInfo(ItemBmp))
        end
      end
    end;

    if not Item.Bitmap.Empty then begin
      gRect.Top := (ItemBmp.Height - GlyphSize(Item, False).cy) div 2;
      if RTL
        then gRect.Left := ARect.Right - gRect.Top - GlyphSize(Item, False).cx - ExtraWidth(mi)
        else gRect.Left := gRect.Top;
      gRect.Bottom := gRect.top + Item.Bitmap.Height;
      gRect.Right := gRect.Left + Item.Bitmap.Width;

      if odChecked in State then begin
        j := TsSkinManager(FOwner).GetSkinIndex(s_SpeedButton_Small);
        if j > -1 then begin
          CI.Bmp := ItemBmp;
          InflateRect(gRect, 1, 1);
          CI.X := 0;
          CI.Y := 0;
          CI.Ready := True;
          PaintItem(j, s_SpeedButton_Small, CI, True, 2, gRect, Point(0, 0), ItemBmp, TsSkinManager(FOwner));
          InflateRect(gRect, -1, -1);
        end;
      end;

      if Item.Bitmap.PixelFormat = pf32bit then begin
        CopyByMask(Rect(gRect.Left, gRect.Top, gRect.Left + Item.Bitmap.Width, gRect.Top + Item.Bitmap.Height),
                   Rect(0, 0, Item.Bitmap.Width, Item.Bitmap.Height), ItemBmp, Item.Bitmap, EmptyCI, False);
      end
      else ItemBmp.Canvas.Draw(gRect.Left, gRect.Top, Item.Bitmap);
    end
    else if (Item.GetImageList <> nil) and (Item.ImageIndex >= 0) then begin
      gRect.Top := (ItemBmp.Height - Item.GetImageList.Height) div 2;

      if RTL
        then gRect.Left := ItemBmp.Width - gRect.Top - GlyphSize(Item, False).cx// - ExtraWidth(mi)
        else gRect.Left := gRect.Top;
      gRect.Bottom := gRect.top + Item.GetImageList.Height;
      gRect.Right := gRect.Left + Item.GetImageList.Width;

      if odChecked in State then begin
        j := TsSkinManager(FOwner).GetSkinIndex(s_SpeedButton_Small);
        if j > -1 then begin
          CI := MakeCacheInfo(ItemBmp);
          InflateRect(gRect, 1, 1);
          PaintItem(j, s_SpeedButton_Small, CI, True, 2, gRect, Point(0, 0), ItemBmp, TsSkinManager(FOwner));
          InflateRect(gRect, -1, -1);
        end;
      end;

      Item.GetImageList.Draw(ItemBmp.Canvas, gRect.Left, gRect.Top, Item.ImageIndex, True);
    end
    else if (Item.GetParentMenu <> nil) and (Item.GetParentMenu.Name = s_SysMenu) then begin
      gChar := #0;
      ItemBmp.Canvas.Font.Name := s_Webdings;
      ItemBmp.Canvas.Font.Style := [];
      ItemBmp.Canvas.Font.Size := 10;
      case Item.Tag of
        SC_MINIMIZE : gChar := '0';
        SC_MAXIMIZE : gChar := '1';
        SC_RESTORE : gChar := '2';
        SC_CLOSE : gChar := 'r'
      end;
      if gChar <> #0 then begin
        j := ItemBmp.Canvas.TextHeight(gChar);
        gRect.Top := (ItemBmp.Height - j) div 2;
        gRect.Bottom := gRect.Top + j;
        if RTL then begin
          gRect.Right := aRect.Right - 4;
          gRect.Left := gRect.Right - j;
          DrawStyle := DT_RIGHT;
        end
        else begin
          gRect.Left := 4;
          gRect.Right := gRect.Left + j + 10;
          DrawStyle := 0;
        end;
        sGraphUtils.acWriteTextEx(ItemBmp.Canvas, PacChar(gChar), True, gRect, DrawStyle, i, (Item.Enabled and ((odSelected in State) or (odHotLight in State))), FOwner);
      end;
    end;

    // Text writing
    if Assigned(CustomMenuFont) then ItemBmp.Canvas.Font.Assign(CustomMenuFont) else if Assigned(Screen.MenuFont) then ItemBmp.Canvas.Font.Assign(Screen.MenuFont);
    f := GetOwnerForm(Item.GetParentMenu);
    if f <> nil then ItemBmp.Canvas.Font.Charset := f.Font.Charset;

    if odDefault in State then ItemBmp.Canvas.Font.Style := [fsBold];
    R := TextRect;

{$IFDEF TNTUNICODE}
    if Sender is TTntMenuItem then Text := TTntMenuItem(Sender).Caption else Text := TMenuItem(Sender).Caption;
{$ELSE}
    Text := Item.Caption;
{$ENDIF}
    if (Text <> '') and (Text[1] = #8) then begin
      Delete(Text, 1, 1);
      Text := Text + '      ';
      DrawStyle := AlignToInt[taRightJustify];
    end
    else DrawStyle := AlignToInt[Alignment];
    DrawStyle := DrawStyle or DT_EXPANDTABS or DT_SINGLELINE or DT_VCENTER or DT_NOCLIP;
    if RTL then begin
      DrawStyle := DrawStyle or DT_RIGHT;
      dec(R.Right, ExtraWidth(mi));
    end;
    if odNoAccel in State then DrawStyle := DrawStyle or DT_HIDEPREFIX;
    if RTLReading then DrawStyle := DrawStyle or DT_RTLREADING;

    sGraphUtils.acWriteTextEx(ItemBmp.Canvas, PacChar(Text), True, R, DrawStyle, i, (Item.Enabled and ((odSelected in State) or (odHotLight in State))), FOwner);
    Text := ShortCutToText(TMenuItem(Sender).ShortCut);

    DrawStyle := DT_SINGLELINE or DT_VCENTER or DT_LEFT;
    if Text <> '' then begin
      r := ShortCutRect(Text);
      dec(r.Right, 8);
      OffsetRect(R, -ExtraWidth(mi), 0);
      sGraphUtils.acWriteTextEx(ItemBmp.Canvas, PacChar(Text), True, R, DrawStyle, i, (Item.Enabled and ((odSelected in State) or (odHotLight in State))), FOwner);
    end;
{
    if (Item.Count > 0) and not (Item.GetParentMenu is TMainMenu) then begin // Paint arrow
      ItemBmp.Canvas.Font.Name := s_Webdings;
      ItemBmp.Canvas.Font.Style := [];
      ItemBmp.Canvas.Font.Size := 10;

      gChar := #52; // >
      j := ItemBmp.Canvas.TextHeight(gChar);
      gRect.Top := (ItemBmp.Height - j) div 2;
      gRect.Bottom := gRect.Top + j;
      if SysLocale.MiddleEast and (Item.GetParentMenu.BiDiMode = bdRightToLeft) then begin
        gChar := #51; // <
        gRect.Left := 4;
      end
      else begin
        gRect.Left := ItemBmp.Width - gRect.Top - 15;
      end;
      gRect.Right := gRect.Left + j + 10;
      DrawStyle := 0;
      sGraphUtils.acWriteTextEx(ItemBmp.Canvas, PacChar(gChar), True, gRect, DrawStyle, i, (Item.Enabled and ((odSelected in State) or (odHotLight in State))), FOwner);
    end;
}
    if Assigned(FOnDrawItem) then FOnDrawItem(Item, ItemBmp.Canvas, Rect(0, 0, ItemBmp.Width, ItemBmp.Height), State, it);

    if not Item.Enabled then begin
      R := aRect;
      OffsetRect(R, BorderWidth + ExtraWidth(mi) * Br, BorderWidth);
      BlendTransRectangle(ItemBmp, 0, 0, BGImage, R, DefDisabledBlend);
    end;
    BitBlt(ACanvas.Handle, aRect.Left + ExtraWidth(mi) * Br, aRect.Top, ItemBmp.Width, ItemBmp.Height, ItemBmp.Canvas.Handle, 0, 0, SrcCopy);
    if (Item = Item.Parent.Items[0]) and (ExtraWidth(mi) > 0) then begin
      if not IsNT or (Win32MajorVersion >= 6) then begin
        BitBlt(ACanvas.Handle, 0, 0, ExtraWidth(mi) * Br, BGImage.Height, BGImage.Canvas.Handle, 3, 3, SRCCOPY);
      end;
    end;

    FreeAndNil(ItemBmp);
  finally
  end;
  if Assigned(Item.OnDrawItem) then Item.OnDrawItem(Item, ACanvas, ARect, odSelected in State);
end;

procedure TsSkinableMenus.InitItems(A: boolean);
var
  i : integer;
  procedure ProcessComponent(c: TComponent);
  var
    i: integer;
  begin
    if (c <> nil) then begin
      if (c is TMainMenu) then begin
        InitMenuLine(TMainMenu(c), A);
        for i := 0 to TMainMenu(c).Items.Count - 1 do HookItem(TMainMenu(c).Items[i], A and TsSkinManager(FOwner).SkinnedPopups);
      end
      else begin
        if (c is TPopupMenu)
          then HookPopupMenu(TPopupMenu(c), A and TsSkinManager(FOwner).SkinnedPopups)
          else if (c is TMenuItem) then if not (TMenuItem(c).GetParentMenu is TMainMenu) then HookItem(TMenuItem(c), A and TsSkinManager(FOwner).SkinnedPopups);
      end;
      for i := 0 to c.ComponentCount - 1 do ProcessComponent(c.Components[i]);
    end;
  end;
begin
  FActive := A;
  if (csDesigning in Fowner.ComponentState) then Exit;
  for i := 0 to Application.ComponentCount - 1 do ProcessComponent(Application.Components[i]);
end;

procedure TsSkinableMenus.HookItem(MenuItem: TMenuItem; FActive: boolean);
var
  i : integer;
  procedure HookSubItems(Item: TMenuItem);
  var
    i : integer;
  begin
    for i := 0 to Item.Count - 1 do begin
      if FActive then begin
        if not IsTopLine(Item.Items[i]) then begin
          if not Assigned(Item.Items[i].OnAdvancedDrawItem) then Item.Items[i].OnAdvancedDrawItem := sAdvancedDrawItem;
          if not Assigned(Item.Items[i].OnMeasureItem) then Item.Items[i].OnMeasureItem := sMeasureItem;
        end;
      end
      else begin
        if addr(Item.Items[i].OnAdvancedDrawItem) = addr(TsSkinableMenus.sAdvancedDrawItem) then Item.Items[i].OnAdvancedDrawItem := nil;
        if addr(Item.Items[i].OnMeasureItem) = addr(TsSkinableMenus.sMeasureItem) then Item.Items[i].OnMeasureItem := nil;
      end;
      HookSubItems(Item.Items[i]);
    end;
  end;
begin
  for i := 0 to MenuItem.Count - 1 do begin
    if FActive then begin
      if not IsTopLine(MenuItem.Items[i]) then begin
        if not Assigned(MenuItem.Items[i].OnAdvancedDrawItem) then MenuItem.Items[i].OnAdvancedDrawItem := sAdvancedDrawItem;
        if not Assigned(MenuItem.Items[i].OnMeasureItem) then MenuItem.Items[i].OnMeasureItem := sMeasureItem;
      end;
    end
    else begin
      if (addr(MenuItem.Items[i].OnAdvancedDrawItem) = addr(TsSkinableMenus.sAdvancedDrawItem)) then MenuItem.Items[i].OnAdvancedDrawItem := nil;
      if (addr(MenuItem.Items[i].OnMeasureItem) = addr(TsSkinableMenus.sMeasureItem)) then MenuItem.Items[i].OnMeasureItem := nil;
    end;
    HookSubItems(MenuItem.Items[i]);
  end;
end;

procedure TsSkinableMenus.SetActive(const Value: boolean);
begin
  if FActive <> Value then begin
    FActive := Value;
    InitItems(Value);
  end
end;

procedure TsSkinableMenus.sMeasureItem(Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);
var
  Text : acString;
  Item : TMenuItem;
  R : TRect;
  f : TCustomForm;
  mi : TacMenuInfo;
begin
  if csDestroying in TComponent(Sender).ComponentState then Exit;
  acCanHookMenu := True;
  Item := TMenuItem(Sender);
  mi := GetMenuInfo(Item, 0, 0);
  if Item.Caption = cLineCaption then it := smDivider else if IsdivText(Item) then it := smCaption else it := smNormal;
  if mi.FirstItem = nil then begin // if not defined still
    mi.FirstItem := Item.Parent.Items[0];
    if not Measuring and not (csDesigning in TsSkinManager(FOwner).ComponentState) then begin
      if (mi.FirstItem.Name <> s_SkinSelectItemName) then begin
        Measuring := True;
        ExtraSection := s_MenuExtraLine;
        if ExtraGlyph <> nil then FreeAndNil(ExtraGlyph);
        ExtraCaption := DontForget;
        mi.HaveExtraLine := True;
        if Assigned(TsSkinManager(FOwner).OnGetMenuExtraLineData) then TsSkinManager(FOwner).OnGetMenuExtraLineData(mi.FirstItem, ExtraSection, ExtraCaption, ExtraGlyph, mi.HaveExtraLine);
        ExtraCaption := DelChars(ExtraCaption, '&');
        if not mi.HaveExtraLine and Assigned(ExtraGlyph) then FreeAndNil(ExtraGlyph);
        Measuring := False;
      end else mi.HaveExtraLine := False;
    end;
  end;
  if Assigned(CustomMenuFont) then ACanvas.Font.Assign(CustomMenuFont) else if Assigned(Screen.MenuFont) then ACanvas.Font.Assign(Screen.MenuFont);
  f := GetOwnerForm(Item.GetParentMenu);
  if f <> nil then ACanvas.Font.Charset := f.Font.Charset;
  if Item.Default then ACanvas.Font.Style := ACanvas.Font.Style + [fsBold];
  case it of
    smDivider : Text := '';
    smCaption : Text := cLineCaption + Item.Caption + cLineCaption;
    else Text := Item.Caption + iff(ShortCutToText(Item.ShortCut) = '', '', ShortCutToText(Item.ShortCut));
  end;
  R := Rect(0, 0, 1, 0);
{$IFDEF TNTUNICODE}
  if Sender is TTntMenuItem
    then Tnt_DrawTextW(ACanvas.Handle, PacChar(Text), Length(Text), R, DT_EXPANDTABS or DT_SINGLELINE or DT_NOCLIP or DT_CALCRECT)
    else
{$ENDIF}
  acDrawText(ACanvas.Handle, PacChar(Text), R, DT_EXPANDTABS or DT_SINGLELINE or DT_NOCLIP or DT_CALCRECT);
  Width := Margin * 3 + WidthOf(R) + GlyphSize(Item, False).cx * 2 + Spacing;
  if mi.HaveExtraLine and not Breaked(Item) then inc(Width, ExtraWidth(mi));
  Height := GetItemHeight(aCanvas, Item);
end;

destructor TsSkinableMenus.Destroy;
begin
  FOwner := nil;
  if Assigned(FCaptionfont) then FreeAndNil(FCaptionFont);
  inherited Destroy;
end;

// Refresh list of all MenuItems on project
procedure TsSkinableMenus.UpdateMenus;
begin
  SetActive(TsSkinManager(FOwner).SkinData.Active);
end;

// Return height of the menu panel
function TsSkinableMenus.ParentHeight(aCanvas: TCanvas; Item: TMenuItem): integer;
var
  i, ret : integer;
begin
  Result := 0;
  ret := 0;
  for i := 0 to Item.Parent.Count - 1 do if Item.Parent.Items[i].Visible then begin
    if Item.Parent.Items[i].Break <> mbNone then begin
      Result := max(Result, ret);
      ret := GetItemHeight(aCanvas, Item.Parent.Items[i]);
    end
    else inc(ret, GetItemHeight(aCanvas, Item.Parent.Items[i]));
  end;
  Result := max(Result, ret);
end;

// Return height of the current MenuItem
function TsSkinableMenus.GetItemHeight(aCanvas: TCanvas; Item: TMenuItem): integer;
var
  Text: string;
  IsDivider : boolean;
begin
  IsDivider  := Item.Caption = cLineCaption;

  if IsDivider then Text := '' else if IsDivText(Item) then begin
    Text := Item.Caption;
  end
  else begin
    Text := Item.Caption + iff(ShortCutToText(Item.ShortCut) = '', '', ShortCutToText(Item.ShortCut));
  end;
  if Assigned(CustomMenuFont) then ACanvas.Font.Assign(CustomMenuFont) else if Assigned(Screen.MenuFont) then ACanvas.Font.Assign(Screen.MenuFont);

  if IsDivider then begin
    Result := 2;
  end
  else if IsDivText(Item) then begin
    Result := Round(ACanvas.TextHeight('W') * 1.25) + 2 * Margin;
  end
  else begin
    Result := Maxi(Round(ACanvas.TextHeight('W') * 1.25), GlyphSize(Item, False).cy) + 2 * Margin;
  end;
end;

function TsSkinableMenus.IsDivText(Item: TMenuItem): boolean;
begin
  Result := (copy(Item.Caption, 1, 1) = cLineCaption) and (copy(Item.Caption, length(Item.Caption), 1) = cLineCaption);
end;

procedure TsSkinableMenus.SetAlignment(const Value: TAlignment);
begin
  if FAlignment <> Value then begin
    FAlignment := Value;
  end;
end;

function TsSkinableMenus.IsTopLine(Item: TMenuItem): boolean;
var
  i : integer;
  m : TMenu;
begin
  Result := False;
  m := Item.GetParentMenu;
  if m is TMainMenu then for i := 0 to m.Items.Count - 1 do if m.Items[i] = Item then begin
    Result := True;
    Exit;
  end;
end;

procedure TsSkinableMenus.SetBevelWidth(const Value: integer);
begin
  FBevelWidth := Value;
end;

procedure TsSkinableMenus.SetBorderWidth(const Value: integer);
begin
  FBorderWidth := Value;
end;

function TsSkinableMenus.CursorMarginH: integer;
begin
  Result := BorderWidth;
end;

function TsSkinableMenus.CursorMarginV: integer;
begin
  Result := 0;
end;

function TsSkinableMenus.ItemRect(Item : TMenuItem; aRect: TRect): TRect;
begin
  Result := aRect;
  if Item.Parent.Items[0] = Item then Result.Top := Result.Top + CursorMarginV;
  if Item.Parent.Items[Item.Parent.Count - 1] = Item then Result.Bottom := Result.Bottom - CursorMarginV;
  Result.Left := Result.Left + CursorMarginH;
  Result.Right := Result.Right - CursorMarginH;
end;

procedure TsSkinableMenus.PaintDivider(aCanvas : TCanvas; aRect : TRect; Item: TMenuItem; MenuBmp : TBitmap; mi : TacMenuInfo);
var
  SkinIndex, BorderIndex : integer;
  nRect : TRect;
  s : string;
  CI : TCacheInfo;
  TempBmp : TBitmap;
begin
  s := s_DIVIDERV;
  SkinIndex := TsSkinManager(FOwner).GetSkinIndex(s);
  BorderIndex := TsSkinManager(FOwner).GetMaskIndex(SkinIndex, s, s_BordersMask);

  nRect := aRect;
  OffsetRect(nRect, -nRect.Left + Margin + ExtraWidth(mi) + Spacing, -nRect.Top);
  dec(nRect.Right, Margin + Margin + ExtraWidth(mi) + Spacing);
  if nRect.Left < (IcoLineWidth + ExtraWidth(mi)) then nRect.Left := IcoLineWidth + ExtraWidth(mi) + 2;

  if BorderIndex > -1 then begin
    TempBmp := CreateBmp32(WidthOf(aRect), HeightOf(aRect));
    if MenuBmp <> nil
      then BitBlt(TempBmp.Canvas.Handle, 0, 0, WidthOf(aRect), HeightOf(aRect), MenuBmp.Canvas.Handle, aRect.Left + 3, aRect.Top + 3, SRCCOPY);

    CI := MakeCacheInfo(TempBmp);
    DrawSkinRect(TempBmp, nRect, True, CI, TsSkinManager(FOwner).ma[BorderIndex], 0, True, TsSkinManager(FOwner));
    BitBlt(aCanvas.Handle, aRect.Left, aRect.Top, WidthOf(aRect), HeightOf(aRect), TempBmp.Canvas.Handle, 0, 0, SRCCOPY);

    FreeAndnil(TempBmp);
  end
  else begin
    BitBlt(aCanvas.Handle, aRect.Left, aRect.Top, WidthOf(aRect), HeightOf(aRect), MenuBmp.Canvas.Handle, aRect.Left + 3, aRect.Top + 3, SRCCOPY);
    if TsSkinManager(FOwner).SkinData.BorderColor <> clFuchsia then aCanvas.Pen.Color := TsSkinManager(FOwner).SkinData.BorderColor else aCanvas.Pen.Color := clBtnShadow;
    aCanvas.Pen.Style := psSolid;
    aCanvas.MoveTo(nRect.Left, aRect.Top);
    aCanvas.LineTo(nRect.Right, aRect.Top);
  end;

end;

procedure TsSkinableMenus.PaintCaption(aCanvas: TCanvas; aRect: TRect; Item : TMenuItem; BG : TBitmap; mi : TacMenuInfo);
var
  i : integer;
  ItemBmp : TBitmap;
  s : acString;
  SkinSection : string;
  Flags : integer;
  R : TRect;
begin
  ItemBmp := CreateBmp32(WidthOf(aRect), HeightOf(aRect));
  R := Rect(ExtraWidth(mi) + 1, 1, ItemBmp.Width - 1, ItemBmp.Height - 1);
  SkinSection := s_ToolBAr;

  i := TsSkinManager(FOwner).GetSkinIndex(SkinSection);

  if ExtraWidth(mi) > 0 then
    BitBlt(ItemBmp.Canvas.Handle, 0, 0, ExtraWidth(mi) + 1, ItemBmp.Height,
          BG.Canvas.Handle, aRect.Left + 3, aRect.Top + 3, SRCCOPY);

  BitBltBorder(ItemBmp.Canvas.Handle, 0, 0, ItemBmp.Width, ItemBmp.Height,
          BG.Canvas.Handle, aRect.Left + 3, aRect.Top + 3, 1);

  if TsSkinManager(FOwner).IsValidSkinIndex(i) then begin
    PaintItem(i, SkinSection, MakeCacheInfo(BG, 3, 3), True, 0,
            R, Point(aRect.Left + ExtraWidth(mi), aRect.Top), ItemBmp.Canvas.Handle, FOwner);
  end;

  if Assigned(FCaptionFont) then ItemBmp.Canvas.Font.Assign(FCaptionFont);
  s := ExtractWord(1, Item.Caption, [cLineCaption]);
  Flags := DT_SINGLELINE or DT_VCENTER or DT_CENTER or DT_HIDEPREFIX;
  R := Rect(ExtraWidth(mi), 0, ItemBmp.Width, ItemBmp.Height);
  acWriteTextEx(ItemBmp.Canvas, PacChar(s), True, R, Flags, i, False);

  BitBlt(ACanvas.Handle, aRect.Left, aRect.Top, ItemBmp.Width, ItemBmp.Height,
          ItemBmp.Canvas.Handle, 0, 0, SrcCopy);

  FreeAndNil(ItemBmp);
end;

procedure TsSkinableMenus.SetCaptionFont(const Value: TFont);
begin
  FCaptionFont.Assign(Value);
end;

type
  TAccessProvider = class(TsSkinProvider);

procedure TsSkinableMenus.sAdvancedDrawLineItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; State: TOwnerDrawState);
var
{$IFDEF TNTUNICODE}
  ws : WideString;
{$ENDIF}
  R, gRect : TRect;
  i, l, t: integer;
  ci : TCacheInfo;
  Item : TMenuItem;
  sp : TAccessProvider;
  Bmp : TBitmap;
  f : TCustomForm;
  Flags : cardinal;
  ItemSelected : boolean;
  function TextRect: TRect; begin
    Result := aRect;
    inc(Result.Left, Margin);
    dec(Result.Right, Margin);
  end;
  function ShortCutRect: TRect; begin
    Result := aRect;
    Result.Left := WidthOf(TextRect);
  end;
begin
  if (Self = nil) or (FOwner = nil) {or not (Sender is TMenuItem) v7.22 }then begin
    inherited;
    Exit;
  end;          
  Item := TMenuItem(Sender);
  try
    sp := TAccessProvider(SendAMessage(Item.GetParentMenu.WindowHandle, AC_GETPROVIDER));
  except
    sp := nil;
  end;
  if (sp = nil) and (MDISkinProvider <> nil) then sp := TAccessProvider(MDISkinProvider);
//  if (sp <> nil) and (sp.Form.FormStyle = fsMDIChild) then sp := TAccessProvider(MDISkinProvider);

  if sp = nil then inherited else begin
    if sp.SkinData.FCacheBmp = nil then Exit;
    // Calc rectangle for painting and defining a Canvas
    Bmp := CreateBmp32(WidthOf(aRect, True), HeightOf(aRect, True));
    gRect := Rect(0, 0, Bmp.Width, Bmp.Height);

    // BG for menu item
    CI := MakeCacheInfo(sp.MenuLineBmp);
    // Calc real offset to menu item in cache
    if ACanvas = sp.SkinData.FCacheBmp.Canvas then begin // If paint in form cache
      if sp.BorderForm <> nil then begin
        t := aRect.Top - sp.CaptionHeight(True) - sp.ShadowSize.Top;
//        if sp.FSysExHeight then dec(t, 4);
      end
      else t := aRect.Top - SysCaptHeight(sp.Form) - SysBorderWidth(sp.Form.Handle, sp.BorderForm, False);

      l := aRect.Left - sp.ShadowSize.Left - SysBorderWidth(sp.Form.Handle, sp.BorderForm);
    end
    else begin // If procedure was called by system (DRAWITEM)
      if sp.BorderForm <> nil
        then t := aRect.Top - sp.CaptionHeight(True) + DiffTitle(sp.BorderForm) + integer(sp.FSysExHeight) * 4
        else t := aRect.Top - SysCaptHeight(sp.Form) + DiffTitle(sp.BorderForm) - SysBorderWidth(sp.Form.Handle, sp.BorderForm, False);
//      if sp.FSysExHeight then dec(t, 4);
      l := aRect.Left - SysBorderWidth(sp.Form.Handle, sp.BorderForm) + DiffBorder(sp.BorderForm);
    end;

    // Skin index for menu item
    i := TsSkinManager(FOwner).GetSkinIndex(s_MenuItem);

    ItemSelected := Item.Enabled and ((odSelected in State) or (odHotLight in State) or IsOpened(Item));// (Item.MenuIndex = acSelectedItem));
    if TsSkinManager(FOwner).IsValidSkinIndex(i)
      then PaintItem(i, s_MenuItem, ci, True, integer(ItemSelected), gRect, Point(l, t), Bmp, FOwner);

    gRect.Left := 0;
    gRect.Right := 0;
    if not Item.Bitmap.Empty then begin
      gRect.Top := (HeightOf(ARect) - GlyphSize(Item, False).cy) div 2;// + aRect.Top;
      if SysLocale.MiddleEast and (Item.GetParentMenu.BiDiMode = bdRightToLeft)
        then gRect.Left := Bmp.Width - 3 - Item.Bitmap.Width
        else gRect.Left := 3;
      gRect.Right := gRect.Left + Item.Bitmap.Width + 3;
      if not Item.Enabled then OffsetRect(gRect, -gRect.Left + 3, -gRect.Top + 1);
      Bmp.Canvas.Draw(gRect.Left, gRect.Top, Item.Bitmap);
    end
    else if (Item.GetImageList <> nil) and (Item.ImageIndex >= 0) then begin
      gRect.Top := (HeightOf(ARect) - Item.GetImageList.Height) div 2;// + aRect.Top;
      if SysLocale.MiddleEast and (Item.GetParentMenu.BiDiMode = bdRightToLeft)
        then gRect.Left := Bmp.Width - 3 - Item.GetImageList.Width
        else gRect.Left := 3;
      gRect.Right := gRect.Left + Item.GetImageList.Width + 3; //!!!
      Item.GetImageList.Draw(Bmp.Canvas, gRect.Left, gRect.Top, Item.ImageIndex, True);
    end;

    // Text writing
    if Assigned(CustomMenuFont) then Bmp.Canvas.Font.Assign(CustomMenuFont) else if Assigned(Screen.MenuFont) then Bmp.Canvas.Font.Assign(Screen.MenuFont);
    f := GetOwnerForm(Item.GetParentMenu);
    if f <> nil then ACanvas.Font.Charset := f.Font.Charset;

    if odDefault in State then Bmp.Canvas.Font.Style := [fsBold] else Bmp.Canvas.Font.Style := [];

    R := TextRect;
    if SysLocale.MiddleEast and (Item.GetParentMenu.BiDiMode = bdRightToLeft) then R.Left := R.Left - WidthOf(gRect) else R.Left := R.Left + WidthOf(gRect);
    if Bmp <> nil then OffsetRect(R, -TextRect.Left + 2, -R.Top);

    i := TsSkinManager(FOwner).GetSkinIndex(s_MenuLine);
    Flags := DT_CENTER or DT_EXPANDTABS or DT_SINGLELINE or DT_VCENTER or DT_NOCLIP;
    if sp.Form.UseRightToLeftReading then Flags := Flags or DT_RTLREADING;
    if odNoAccel in State then Flags := Flags + DT_HIDEPREFIX;
{$IFDEF TNTUNICODE}
    if Sender is TTntMenuItem then begin
      ws := WideString(TTntMenuItem(Sender).Caption);
      sGraphUtils.WriteTextExW(Bmp.Canvas, PWideChar(ws), True, R, Flags or AlignToInt[Alignment], i, ItemSelected, FOwner);
    end
    else
{$ENDIF}
    if (sp.BorderForm <> nil) then begin
      WriteText32(Bmp, PacChar(Item.Caption), True, R, Flags or AlignToInt[Alignment], i, ItemSelected, FOwner{$IFDEF TNTUNICODE}, True{$ENDIF});
    end
    else begin
      sGraphUtils.WriteTextEx(Bmp.Canvas, PChar(Item.Caption), True, R, Flags or AlignToInt[Alignment], i, ItemSelected, FOwner);
    end;

    if Assigned(FOnDrawItem) then FOnDrawItem(Item, Bmp.Canvas, gRect, State, smTopLine);
    if Assigned(Bmp) then begin
      if not Item.Enabled then begin
        R := Rect(l, t, l + Bmp.Width, t + Bmp.Width);
        SumBmpRect(Bmp, sp.MenuLineBmp, IntToByte(Round(DefDisabledBlend * MaxByte)), R, Point(0, 0));
      end;
      BitBlt(ACanvas.Handle, aRect.Left, aRect.Top, Bmp.Width, Bmp.Height, Bmp.Canvas.Handle, 0, 0, SRCCOPY);
      FreeAndNil(Bmp);
    end;
  end;
end;

procedure TsSkinableMenus.sMeasureLineItem(Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);
var
  Text: acString;
  Item: TMenuItem;
  W : integer;
  Menu : TMenu;
begin
  Item := TMenuItem(Sender);

  Height := GetSystemMetrics(SM_CYMENU) - 1;

  if Assigned(CustomMenuFont) then ACanvas.Font.Assign(CustomMenuFont) else if Assigned(Screen.MenuFont) then ACanvas.Font.Assign(Screen.MenuFont);

  Text := ReplaceStr(Item.Caption, '&', '');
  W := ACanvas.TextWidth(Text);
  Menu := Item.GetParentMenu;
  if Assigned(Menu.Images) and (Item.ImageIndex > -1)
    then inc(W, Menu.Images.Width + 6)
    else if not Item.Bitmap.Empty then inc(W, Item.Bitmap.Width + 6);

  // If last item (for a MDIChild buttons drawing)
  if LastItem(Item) then inc(W, 40);
  Width := W;
end;

procedure TsSkinableMenus.InitItem(Item: TMenuItem; A : boolean);
begin
  if Item.GetParentMenu <> nil then Item.GetParentMenu.OwnerDraw := A;
  if A then begin
    if not IsTopLine(Item) then begin
      if not TsSkinManager(FOwner).SkinnedPopups then Exit;
      if not Assigned(Item.OnAdvancedDrawItem) then Item.OnAdvancedDrawItem := sAdvancedDrawItem;
      if not Assigned(Item.OnMeasureItem) then Item.OnMeasureItem := sMeasureItem;
    end
    else begin
      Item.OnAdvancedDrawItem := sAdvancedDrawLineItem;
      Item.OnMeasureItem := sMeasureLineItem;
    end;
  end
  else begin
    if (addr(Item.OnAdvancedDrawItem) = addr(TsSkinableMenus.sAdvancedDrawItem)) then Item.OnAdvancedDrawItem := nil;
    if (addr(Item.OnMeasureItem) = addr(TsSkinableMenus.sMeasureItem)) then Item.OnMeasureItem := nil;
  end;
end;

procedure TsSkinableMenus.InitMenuLine(Menu: TMainMenu; A: boolean);
var
  i : integer;
begin
  if not Assigned(Menu) then Exit;
  for i := 0 to Menu.Items.Count - 1 do begin
    if A then begin
      if TsSkinManager(FOwner).SkinData.Active then begin
        if not TsSkinManager(FOwner).SkinnedPopups then Exit; 
        Menu.Items[i].OnAdvancedDrawItem := sAdvancedDrawLineItem;
        Menu.Items[i].OnMeasureItem := sMeasureLineItem;
      end;
    end
    else begin
      if addr(Menu.Items[i].OnAdvancedDrawItem) = addr(TsSkinableMenus.sAdvancedDrawLineItem) then Menu.Items[i].OnAdvancedDrawItem := nil;
      if addr(Menu.Items[i].OnMeasureItem) = addr(TsSkinableMenus.sMeasureLineItem) then Menu.Items[i].OnMeasureItem := nil;
    end;
  end;
  if csDestroying in Menu.ComponentState then Exit;
  Menu.OwnerDraw := A;
end;

procedure TsSkinableMenus.HookPopupMenu(Menu: TPopupMenu; Active: boolean);
var
  i : integer;
  procedure HookSubItems(Item: TMenuItem);
  var
    i : integer;
  begin
    for i := 0 to Item.Count - 1 do begin
      if Active then begin
        if not Assigned(Item.Items[i].OnAdvancedDrawItem) then
          Item.Items[i].OnAdvancedDrawItem := sAdvancedDrawItem;
        if not Assigned(Item.Items[i].OnMeasureItem) then
          Item.Items[i].OnMeasureItem := sMeasureItem;
      end
      else begin
        if addr(Item.Items[i].OnAdvancedDrawItem) = addr(TsSkinableMenus.sAdvancedDrawItem) then
          Item.Items[i].OnAdvancedDrawItem := nil;
        if addr(Item.Items[i].OnMeasureItem) = addr(TsSkinableMenus.sMeasureItem) then
          Item.Items[i].OnMeasureItem := nil;
      end;
      HookSubItems(Item.Items[i]);
    end;
  end;
begin
  Menu.OwnerDraw := Active and TsSkinManager(Self.FOwner).SkinnedPopups;
  if Active then Menu.MenuAnimation := Menu.MenuAnimation + [maNone] else Menu.MenuAnimation := Menu.MenuAnimation - [maNone];
  for i := 0 to Menu.Items.Count - 1 do begin
    if Active then begin
      if not Assigned(Menu.Items[i].OnAdvancedDrawItem) then
        Menu.Items[i].OnAdvancedDrawItem := sAdvancedDrawItem;
      if not Assigned(Menu.Items[i].OnMeasureItem) then
        Menu.Items[i].OnMeasureItem := sMeasureItem;
    end
    else begin
      if (addr(Menu.Items[i].OnAdvancedDrawItem) = addr(TsSkinableMenus.sAdvancedDrawItem))
        then Menu.Items[i].OnAdvancedDrawItem := nil;
      if (addr(Menu.Items[i].OnMeasureItem) = addr(TsSkinableMenus.sMeasureItem))
        then Menu.Items[i].OnMeasureItem := nil;
    end;
    HookSubItems(Menu.Items[i]);
  end;
end;

function TsSkinableMenus.LastItem(Item: TMenuItem): boolean;
begin
  Result := False;
end;

function TsSkinableMenus.IsPopupItem(Item: TMenuItem): boolean;
var
  mi : TMenu;
begin
  mi := Item.GetParentMenu;
  Result := mi is TPopupMenu;
end;

procedure ClearCache;
begin
  DeleteUnusedBmps(True);
end;
{
function MenuWindowProc(Wnd: HWND; uMsg: integer; WParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  case uMsg of
    WM_NCPAINT : begin
      Result := 1;
    end;
    WM_ERASEBKGND : begin
      Result := 1;
    end;
    WM_DESTROY : begin
      ClearCache;
      Result := CallWindowProc(Pointer(GetWindowLong(Wnd, GWL_USERDATA)), wnd, uMsg, wParam, lParam);
    end
    else Result := CallWindowProc(Pointer(GetWindowLong(Wnd, GWL_USERDATA)), wnd, uMsg, wParam, lParam);
  end;
end;
}
procedure TsSkinableMenus.DrawWndBorder(Wnd : hWnd; MenuBmp : TBitmap);
var
  l, i : integer;
  rgn, subRgn : hrgn;
begin
  if BorderDrawing then Exit;
{  if GetWindowLong(Wnd, GWL_WNDPROC) <> Longint(@MenuWindowProc) then begin
    SetWindowLong(Wnd, GWL_USERDATA, GetWindowLong(Wnd, GWL_WNDPROC));
    SetWindowLong(Wnd, GWL_WNDPROC, Longint(@MenuWindowProc));
  end;}
  if IsNT and (MenuBmp <> nil) and (SendMessage(Wnd, SM_ALPHACMD, MakeWParam(0, AC_UPDATING), 0) = 0) then begin
    SendMessage(Wnd, SM_ALPHACMD, MakeWParam(0, AC_DROPPEDDOWN), 0);
    BorderDrawing := True;
    l := Length(ArOR);
    rgn := CreateRectRgn(0, 0, MenuBmp.Width, MenuBmp.Height);
    if (l > 0) then begin
      for i := 0 to l - 1 do begin
        subrgn := CreateRectRgn(ArOR[i].Left, ArOR[i].Top, ArOR[i].Right, ArOR[i].Bottom);
        CombineRgn(rgn, rgn, subrgn, RGN_DIFF);
        DeleteObject(subrgn);
      end;
    end
    else begin
      subrgn := CreateRectRgn(0, 0, 1, 1);
      CombineRgn(rgn, rgn, subrgn, RGN_DIFF);
      DeleteObject(subrgn);
    end;
    SetWindowRgn(Wnd, rgn, True);
  end;
  BorderDrawing := False;
end;

function TsSkinableMenus.GetSkinBorderWidth: integer;
var
  i : integer;
begin
  if FSkinBorderWidth < 0 then begin
    i := TsSkinManager(FOwner).GetMaskIndex(s_MainMenu, s_BordersMask);
    if i > -1 then begin
      FSkinBorderWidth := TsSkinManager(FOwner).ma[i].BorderWidth;
      if FSkinBorderWidth < 1 then FSkinBorderWidth := 3;
    end
    else FSkinBorderWidth := 0;
  end;
  Result := FSkinBorderWidth;
end;

function TsSkinableMenus.ExtraWidth(mi : TacMenuInfo): integer;
begin
  if TsSkinManager(FOwner).MenuSupport.UseExtraLine and mi.HaveExtraLine then begin
    Result := TsSkinManager(FOwner).MenuSupport.ExtraLineWidth;
  end
  else Result := 0;
end;

function TsSkinableMenus.GetItemWidth(aCanvas: TCanvas; Item: TMenuItem; mi : TacMenuInfo): integer;
var
  Text : string;
  R : TRect;
begin
  if Assigned(CustomMenuFont) then ACanvas.Font.Assign(CustomMenuFont) else if Assigned(Screen.MenuFont) then ACanvas.Font.Assign(Screen.MenuFont);

  case it of
    smDivider : begin
      Text := '';
      Result := Margin * 3 + ACanvas.TextWidth(Text) + GlyphSize(Item, False).cx * 2 + Spacing;
    end;
    smCaption : begin
      Text := cLineCaption + Item.Caption + cLineCaption;
      Result := Margin * 3 + ACanvas.TextWidth(Text) + GlyphSize(Item, False).cx * 2 + Spacing;
    end
    else begin
      Text := Item.Caption + iff(ShortCutToText(Item.ShortCut) = '', '', ShortCutToText(Item.ShortCut));

      R := Rect(0, 0, 1, 0);
      DrawText(ACanvas.Handle, PChar(Text), Length(Text), R, DT_EXPANDTABS or DT_SINGLELINE or DT_NOCLIP or DT_CALCRECT);
      Result := WidthOf(R) + Margin * 3 + GlyphSize(Item, False).cx * 2 + Spacing;
    end;
  end;
  if mi.HaveExtraLine then inc(Result, ExtraWidth(mi));
end;

function TsSkinableMenus.ParentWidth(aCanvas: TCanvas; Item: TMenuItem): integer;
var
  i, OldRes, w, h : integer;
  it : TMenuItem;
begin
  Result := 0;
  OldRes := 0;
  for i := 0 to Item.Parent.Count - 1 do if Item.Parent.Items[i].Visible then begin
    it := Item.Parent.Items[i];
    if it.Break <> mbNone then begin
      inc(OldRes, Result + 4{?});
      Result := 0;
    end;
    w := 0;
    h := 0;
    sMeasureItem(it, aCanvas, w, h);
    Result := max(Result, w + 12);
  end;
  inc(Result, OldRes);
end;

function TsSkinableMenus.PrepareMenuBG(Item: TMenuItem; Width, Height : integer; Wnd : hwnd = 0) : TBitmap;
var
  R, gRect : TRect;
  i, j, w, Marg : integer;
  CI : TCacheInfo;
  ItemBmp : TBitmap;
  VertFont : TLogFont;
  pFont : PLogFontA;
  f : TCustomForm;
  mi : TacMenuInfo;
  procedure MakeVertFont(Orient : integer);
  begin
    ItemBmp.Canvas.Font.Assign(TsSkinManager(FOwner).MenuSupport.ExtraLineFont);
    f := GetOwnerForm(Item.GetParentMenu);
    if f <> nil then ItemBmp.Canvas.Font.Charset := f.Font.Charset;
    pFont := PLogFontA(@VertFont);
    StrPCopy(VertFont.lfFaceName, TsSkinManager(FOwner).MenuSupport.ExtraLineFont.Name);
    GetObject(ItemBmp.Canvas.Handle, SizeOf(TLogFont), pFont);
    VertFont.lfEscapement := Orient;
    VertFont.lfHeight := TsSkinManager(FOwner).MenuSupport.ExtraLineFont.Size;
    VertFont.lfStrikeOut := integer(fsStrikeOut in TsSkinManager(FOwner).MenuSupport.ExtraLineFont.Style);
    VertFont.lfItalic := integer(fsItalic in TsSkinManager(FOwner).MenuSupport.ExtraLineFont.Style);
    VertFont.lfUnderline := integer(fsUnderline	in TsSkinManager(FOwner).MenuSupport.ExtraLineFont.Style);
    VertFont.lfWeight := FW_NORMAL;
    VertFont.lfCharSet := TsSkinManager(FOwner).MenuSupport.ExtraLineFont.Charset;

    VertFont.lfWidth := 0;
    Vertfont.lfOutPrecision := OUT_DEFAULT_PRECIS;
    VertFont.lfClipPrecision := CLIP_DEFAULT_PRECIS;
    VertFont.lfOrientation := VertFont.lfEscapement;
    VertFont.lfPitchAndFamily := Default_Pitch;
    VertFont.lfQuality := Default_Quality;
    ItemBmp.Canvas.Font.Handle := CreateFontIndirect(VertFont);
    ItemBmp.Canvas.Font.Color := TsSkinManager(FOwner).gd[j].FontColor[1];
  end;
begin
  Result := nil;
  if not (csDesigning in TsSkinManager(FOwner).ComponentState) then begin
    if (Item.Parent.Items[0].Name <> s_SkinSelectItemName) then begin
      ExtraSection := s_MenuExtraLine;
      if ExtraGlyph <> nil then FreeAndNil(ExtraGlyph);
      ExtraCaption := DontForget;
      mi.HaveExtraLine := True;
      if Assigned(TsSkinManager(FOwner).OnGetMenuExtraLineData) then TsSkinManager(FOwner).OnGetMenuExtraLineData(Item.Parent.Items[0], ExtraSection, ExtraCaption, ExtraGlyph, mi.HaveExtraLine);
      ExtraCaption := DelChars(ExtraCaption, '&');
      if not mi.HaveExtraLine and Assigned(ExtraGlyph) then FreeAndNil(ExtraGlyph);
    end
    else mi.HaveExtraLine := False;
  end;
  mi.FirstItem := Item.Parent.Items[0];
  mi.Wnd := Wnd;
  mi.Bmp := CreateBmp32(Width, Height);
  mi.Bmp.Canvas.Lock;

  gRect := Rect(0, 0, Width, Height);

  i := TsSkinManager(FOwner).GetSkinIndex(s_MainMenu);
  // Draw Menu
  GlyphSizeCX := GlyphSize(Item, false).cx;
  IcoLineWidth := GlyphSizeCX + Margin + Spacing;
  if TsSkinManager(FOwner).IsValidSkinIndex(i) then begin
    // Background
    PaintItemBG(i, s_MainMenu, EmptyCI, 0, gRect, Point(0, 0), mi.Bmp, FOwner);
    ci := MakeCacheInfo(mi.Bmp);
    // Ico line painting
    if GetWindowLong(Item.GetParentMenu.WindowHandle, GWL_EXSTYLE) and WS_EX_RIGHT <> WS_EX_RIGHT then begin
      j := TsSkinManager(FOwner).GetSkinIndex(TsSkinManager(FOwner).MenuSupport.IcoLineSkin);
      if j > -1 then begin // Ico line
        ItemBmp := CreateBmp32(IcoLineWidth, Mi.Bmp.Height - SkinBorderWidth * 2);
        PaintItem(j, TsSkinManager(FOwner).MenuSupport.IcoLineSkin, ci, True, 0, Rect(0, 0, ItemBmp.Width, ItemBmp.Height), Point(SkinBorderWidth + ExtraWidth(mi), SkinBorderWidth), ITemBmp, FOwner);
        BitBlt(mi.Bmp.Canvas.Handle, SkinBorderWidth + ExtraWidth(mi), SkinBorderWidth, ItemBmp.Width, ItemBmp.Height, ItemBmp.Canvas.Handle, 0, 0, SrcCopy);
        FreeAndNil(ItemBmp);
      end;
    end;
    // Border
    j := TsSkinManager(FOwner).GetMaskIndex(i, s_MainMenu, s_BordersMask);
    if TsSkinManager(FOwner).IsValidImgIndex(j) then DrawSkinRect(mi.Bmp, gRect, False, MakeCacheInfo(mi.Bmp), TsSkinManager(FOwner).ma[j], 0, False);
    // Extra line painting
    if TsSkinManager(FOwner).MenuSupport.UseExtraLine and mi.HaveExtraLine then begin
      j := TsSkinManager(FOwner).GetSkinIndex(ExtraSection);
      if j > -1 then begin // Extra line
        ItemBmp := CreateBmp32(TsSkinManager(FOwner).MenuSupport.ExtraLineWidth, mi.Bmp.Height - SkinBorderWidth * 2);
        R := Rect(0, 0, ItemBmp.Width, ItemBmp.Height);
        PaintItem(j, ExtraSection, ci, True, 0, R, Point(SkinBorderWidth, SkinBorderWidth), ItemBmp, FOwner);
        Marg := 12;
        if ExtraGlyph <> nil then begin
          inc(Marg, ExtraGlyph.Height + 8);
          ItemBmp.Canvas.Draw((ItemBmp.Width - ExtraGlyph.Width) div 2, ItemBmp.Height - 12 - ExtraGlyph.Height, ExtraGlyph);
        end;
        if ExtraCaption <> '' then begin
          MakeVertFont(-2700);

          w := ItemBmp.Canvas.TextHeight(ExtraCaption);

          ItemBmp.Canvas.Brush.Style := bsClear;
          ItemBmp.Canvas.TextRect(R, R.Left + (WidthOf(R) - w) div 2, ItemBmp.Height - Marg, ExtraCaption);
        end;
        BitBlt(mi.Bmp.Canvas.Handle, SkinBorderWidth, SkinBorderWidth, ItemBmp.Width, ItemBmp.Height, ItemBmp.Canvas.Handle, 0, 0, SrcCopy);
        FreeAndNil(ItemBmp);
      end;
      if Assigned(ExtraGlyph) then FreeAndNil(ExtraGlyph);
    end;

    // Prepare array of trans. px
    SetLength(ArOR, 0);
    i := TsSkinManager(FOwner).GetMaskIndex(i, s_MAINMENU, s_BORDERSMASK);
    if TsSkinManager(FOwner).IsValidImgIndex(i) then begin
      AddRgn(ArOR, mi.Bmp.Width, TsSkinManager(FOwner).ma[i], 0, False);
      AddRgn(ArOR, mi.Bmp.Width, TsSkinManager(FOwner).ma[i],
             mi.Bmp.Height - TsSkinManager(FOwner).ma[i].WB, True);
    end;
    if Wnd <> 0
      then DrawWndBorder(Wnd, mi.Bmp);
  end;
  mi.Bmp.Canvas.UnLock;
  SetLength(MenuInfoArray, Length(MenuInfoArray) + 1);
  MenuInfoArray[Length(MenuInfoArray) - 1] := mi;
end;

function TsSkinableMenus.GetMenuInfo(Item : TMenuItem; const aWidth, aHeight : integer; aWnd : hwnd = 0): TacMenuInfo;
var
  i, l : integer;
  fi : TMenuItem;
begin
  Result.FirstItem := nil;
  Result.Bmp := nil;
  l := Length(MenuInfoArray);
  if Item <> nil then begin
    fi := Item.Parent.Items[0];
    for i := 0 to l - 1 do begin
      if MenuInfoArray[i].FirstItem = fi then begin
        Result := MenuInfoArray[i];
        Exit;
      end;
    end;
    // If not found but BG is required already
    if aWidth <> 0 then begin
      PrepareMenuBG(fi, aWidth, aHeight, aWnd);
      Result := GetMenuInfo(fi, aWidth, aHeight);
    end;
  end
  else if aWnd <> 0 then begin
    for i := 0 to l - 1 do begin
      if MenuInfoArray[i].Wnd = aWnd then begin
        Result := MenuInfoArray[i];
        Exit;
      end;
    end;
  end;
end;

function TsSkinableMenus.IsOpened(Item: TMenuItem): boolean;
//var
//  i, l : integer;
begin
  Result := False;
{  if MenuInfoArray = nil then Exit;
  l := Length(MenuInfoArray);
  for i := 0 to l - 1 do begin
    if MenuInfoArray[i].FirstItem.Parent = Item then begin
      Result := True;
      Exit;
    end;
  end;}
end;

{ TacMenuSupport }

constructor TacMenuSupport.Create;
begin
  FUseExtraLine := False;
  FExtraLineWidth := 32;
  FExtraLineFont := TFont.Create;
end;

destructor TacMenuSupport.Destroy;
begin
  FreeAndNil(FExtraLineFont);
  inherited;
end;

procedure TacMenuSupport.SetExtraLineFont(const Value: TFont);
begin
  FExtraLineFont.Assign(Value);
end;

initialization

finalization
  ClearCache;

end.
