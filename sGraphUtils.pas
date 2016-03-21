unit sGraphUtils;
{$I sDefs.inc}
{.$DEFINE LOGGED}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, {$IFDEF TNTUNICODE}TntGraphics, {$ENDIF}
  StdCtrls, ComCtrls, sConst{$IFNDEF DELPHI5}, Types{$ENDIF}, ExtCtrls, Jpeg, acntUtils, math, Buttons{$IFDEF LOGGED}, sDebugMsgs{$ENDIF}
  {$IFNDEF ACHINTS}, imglist, sMaskData, sCommonData{$ENDIF};

{$IFNDEF NOTFORHELP}
type
  TsHSV = record h : integer; s : real; v : real end;
  TFilterType = (ftBox {fastest}, ftTriangle, ftHermite, ftBell, ftSpline, ftLanczos3, ftMitchell);

const
  MaxKernelSize = 100;

type
  PByteArrays = ^TByteArrays;
  TByteArrays = array[0..1000000] of PByteArray;

  TKernelSize = 1..MaxKernelSize;

  TKernel = record
    Size: TKernelSize;
    Weights: array[-MaxKernelSize..MaxKernelSize] of single;
  end;
{$ENDIF} // NOTFORHELP

procedure DrawColorArrow(Bmp : TBitmap; Color : TColor; R : TRect; Direction : integer);
function SwapInteger(const i : integer) : integer;
// Paint tiled TGraphic on bitmap
procedure TileBitmap(Canvas: TCanvas; aRect: TRect; Graphic: TGraphic); overload;
procedure Stretch(const Src, Dst : TBitmap; const Width, Height : Integer; Filter : TFilterType; Param : Integer = 0);

{$IFNDEF ACHINTS}
procedure RGBToHSV (const R, G, B: Real; var H, S, V: Real);
procedure HSVtoRGB (const H,S,V: Real; var R,G,B: real);
procedure CopyImage(Glyph : TBitmap; ImageList: TCustomImageList; Index: Integer);
procedure PaintItemBG(SkinData : TsCommonData; ci : TCacheInfo; State : integer; R : TRect; pP : TPoint; ItemBmp : TBitmap; OffsetX : integer = 0; OffsetY : integer = 0); overload;
procedure PaintItem(SkinData : TsCommonData; ci : TCacheInfo; Filling : boolean; State : integer; R : TRect; pP : TPoint; ItemBmp : TBitmap; UpdateCorners : boolean; OffsetX : integer = 0; OffsetY : integer = 0); overload;
function PaintSection(const Bmp : TBitmap; Section : string; const SecondSection : string; const State : integer; const Manager : TObject; const ParentOffset : TPoint; const BGColor : TColor; ParentDC : hdc = 0) : integer;

procedure PaintControlByTemplate(const DstBmp, SrcBmp : TBitmap; const DstRect, SrcRect, BorderWidths, BorderMaxWidths : TRect; const DrawModes : TRect; const StretchCenter : boolean; FillCenter : boolean = True);//TacBorderDrawModes);
procedure PaintSkinControl(const SkinData : TsCommonData; const Parent : TControl; const Filling : boolean; State : integer; const R : TRect; const pP : TPoint; const ItemBmp : TBitmap; const UpdateCorners : boolean; const OffsetX : integer = 0; const OffsetY : integer = 0);
procedure CopyChannel32(const DstBmp, SrcBmp : TBitmap; const Channel : integer);
procedure CopyChannel(const Bmp32, Bmp8 : TBitmap; const Channel : integer; const From32To8 : boolean);

procedure DrawGlyphEx(Glyph, DstBmp : TBitmap; R : TRect; NumGlyphs : integer; Enabled : boolean; DisabledGlyphKind : TsDisabledGlyphKind; State, Blend : integer; Down : boolean = False; Reflected : boolean = False);
{$ENDIF}
// Fills rectangle on device context by Color
procedure FillDC(DC: HDC; const aRect: TRect; const Color: TColor);
procedure FillDCBorder(const DC: HDC; const aRect: TRect; const wl, wt, wr, wb : integer; const Color: TColor);
procedure BitBltBorder(const DestDC: HDC; const X, Y, Width, Height: Integer; const SrcDC: HDC; const XSrc, YSrc: Integer; const BorderWidth : integer);
// Grayscale bitmap
procedure GrayScale(Bmp: TBitmap);
procedure GrayScaleTrans(Bmp: TBitmap; const TransColor : TsColor);
procedure ChangeBmpHUE(const Bmp: TBitmap; const Value : integer);
procedure ChangeBmpSaturation(const Bmp: TBitmap; const Value : integer);
// Function CutText get text with ellipsis if no enough place
function CutText(Canvas: TCanvas; const Text: acString; MaxLength : integer): acString;
// Writes text on Canvas on custom rectangle by Flags
procedure WriteText(Canvas: TCanvas; Text: PChar; Enabled: boolean; var aRect : TRect; Flags: Cardinal);
procedure SumBitmaps(SrcBmp, MskBmp: Graphics.TBitMap; Color : TsColor);
procedure SumBmpRect(const DstBmp, SrcBmp: Graphics.TBitMap; const AlphaValue : byte; SrcRect : TRect; DstPoint : TPoint);
// Alpha-blending of rectangle on bitmap by Blend, excluding pixels with color clFuchsia
procedure BlendTransRectangle(Dst: TBitmap; X, Y: integer; Src: TBitmap; aRect: TRect; Blend: real; TransColor : TColor = clFuchsia);
procedure BlendTransBitmap(Bmp: TBitmap; Blend: real; Color: TsColor);
// Alpha-blending of rectangle on bitmap custom transparency, color, blur and radius
procedure FadeBmp(FadedBmp: TBitMap; aRect: TRect;Transparency: integer; Color: TsColor; Blur, Radius : integer);
// Copying alpha-blended rectangle from CanvasSrc to CanvasDst
procedure FadeRect(CanvasSrc: TCanvas; RSrc: TRect; CanvasDst: HDC; PDst: TPoint; Transparency: integer; Color: TColor; Blur : integer; Shape: TsShadowingShape); overload;
procedure FadeRect(CanvasSrc: TCanvas; RSrc: TRect; CanvasDst: HDC; PDst: TPoint; Transparency: integer; Color: TColor; Blur : integer; Shape: TsShadowingShape; Radius : integer); overload;
// Sum two bitmaps where Color used as mask
procedure BlendBmpByMask(SrcBmp, MskBmp: Graphics.TBitMap; BlendColor : TsColor);
// Copying bitmap SrcBmp to DstBmp, excluding pixels with color TransColor
procedure CopyTransBitmaps(DstBmp, SrcBmp: Graphics.TBitMap; X, Y : integer; TransColor : TsColor);
// Sum two bitmaps by mask MskBmp
procedure SumByMaskWith32(const Src1, Src2, MskBmp: Graphics.TBitMap; const aRect: TRect);
procedure SumByMask(var Src1, Src2, MskBmp: Graphics.TBitMap; aRect: TRect);
function MakeRotated90(var Bmp : TBitmap; CW : boolean; KillSource : boolean = True) : TBitmap;
// Returns color as ColorBegin -  (ColorBegin - ColorEnd) * i
function ChangeColor(ColorBegin, ColorEnd : TColor; i : real) : TColor;
// Returns color as (ColorBegin + ColorEnd) / 2
function AverageColor(ColorBegin, ColorEnd : TsColor) : TsColor; overload;
function AverageColor(ColorBegin, ColorEnd : TColor) : TColor; overload;
function MixColors(Color1, Color2 : TColor; PercentOfColor1 : real) : TColor;
// Draws rectangle on device context
procedure DrawRectangleOnDC(DC: HDC; var R: TRect; ColorTop, ColorBottom: TColor; var Width: integer);
// Returns height of font
function GetFontHeight(hFont : HWnd): integer;
// Returns width of text
function GetStringSize(hFont : hgdiobj; const Text : acString): TSize;
// Loads to Image TJpegImage or TBitmap from FileName
function LoadJpegOrBmp(Image: TPicture; const FileName: string; Gray: boolean):boolean;
//procedure FocusRect(Canvas : TCanvas; R : TRect); overload;
procedure FocusRect(Canvas : TCanvas; R : TRect; LightColor : TColor = clBtnFace; DarkColor : TColor = clBlack);

{$IFNDEF NOTFORHELP}
{$IFNDEF ACHINTS}
procedure ExcludeControls(const DC : hdc; const Ctrl : TWinControl; const CtrlType : TacCtrlType; const OffsetX : integer; const OffsetY : integer);
procedure CalcButtonLayout(const Client: TRect; const GlyphSize: TPoint; const TextRectSize: TSize; Layout: TButtonLayout;
            Alignment: TAlignment; Margin, Spacing: Integer; var GlyphPos: TPoint; var TextBounds: TRect; BiDiFlags: LongInt);      {RL}
procedure TileBitmap(Canvas: TCanvas; var aRect: TRect; Graphic: TGraphic; MaskData : TsMaskData; FillMode : TacFillMode = fmTiled); overload;
procedure TileMasked(Bmp: TBitmap; var aRect: TRect; CI : TCacheInfo; MaskData : TsMaskData; FillMode : TacFillMode = fmDisTiled);
procedure AddRgn(var AOR : TAOR; Width : integer; MaskData : TsMaskData; VertOffset : integer; Bottom : boolean);
function GetRgnForMask(MaskIndex, Width, Height : integer; SkinManager : TObject) : hrgn;
procedure GetRgnFromBmp(var rgn : hrgn; MaskBmp : TBitmap; TransColor : TColor);
procedure AddRgnBmp(var AOR : TAOR; MaskBmp : TBitmap; TransColor : TsColor);
function GetBGInfo(const BGInfo : PacBGInfo; const Handle : THandle; PleaseDraw : boolean = False) : boolean; overload;
function GetBGInfo(const BGInfo : PacBGInfo; const Control : TControl; PleaseDraw : boolean = False) : boolean; overload;
function BGInfoToCI(const BGInfo : PacBGInfo) : TCacheInfo;
{$ENDIF}
procedure SumBitmapsByMask(var ResultBmp, Src1, Src2: Graphics.TBitMap; MskBmp: Graphics.TBitMap; Percent : word = 0);
// Copy Bmp with AlphaMask if Bmp2 is not MasterBitmap
procedure CopyByMask(R1, R2 : TRect; const Bmp1, Bmp2 : TBitmap; const CI : TCacheInfo; const UpdateTrans : boolean); overload;
procedure CopyByMask(R1, R2 : TRect; const Bmp1, Bmp2 : TBitmap; const CI : TCacheInfo; const UpdateTrans : boolean; const MaskData : TsMaskData); overload;
procedure CopyBmp32(R1, R2 : TRect; const Bmp1, Bmp2 : TBitmap; const CI : TCacheInfo; const UpdateTrans : boolean; const GrayedColor : TColor; const Blend : integer; const Reflected : boolean);
// Copying rectangle from SrcBmp to DstBmp, excluding pixels with color TransColor (get trans pixels from parent)
procedure CopyTransRect(DstBmp, SrcBmp: Graphics.TBitMap; X, Y : integer; SrcRect: TRect; TransColor : TColor; CI : TCacheInfo; UpdateTrans : boolean);
// Skip transarent part
procedure CopyTransRectA(DstBmp, SrcBmp: Graphics.TBitMap; X, Y : integer; SrcRect: TRect; TransColor : TColor; CI : TCacheInfo);
// Creates bitmap like Bmp
function CreateBmpLike(const Bmp: TBitmap): TBitmap;
function CreateBmp24(const Width, Height : integer) : TBitmap; {$IFDEF WARN_DEPRECATED} deprecated; {$ENDIF} // Only pf32bit images are used in the v7
function CreateBmp32(const Width, Height : integer) : TBitmap;
procedure WriteTextOnDC(DC: hdc; Text: PChar; Enabled: boolean; var aRect : TRect; Flags: Cardinal);
function acDrawText(hDC: HDC; const Text: ACString; var lpRect: TRect; uFormat: Cardinal): Integer;
function acTextWidth(const Canvas: TCanvas; const Text: ACString): Integer;
function acTextHeight(const Canvas: TCanvas; const Text: ACString): Integer;
function acTextExtent(const Canvas: TCanvas; const Text: ACString): TSize;
procedure acTextRect(const Canvas : TCanvas; const Rect: TRect; X, Y: Integer; const Text: ACString);

function acGetTextExtent(const DC: HDC; const Str: acString; var Size: TSize): BOOL;

procedure acDrawGlowForText(const DstBmp: TBitmap; Text: PacChar; aRect : TRect; Flags: Cardinal; Side : Cardinal; BlurSize : integer; Color : TColor; var MaskBmp : TBitmap);
procedure Blur8(theBitmap: TBitmap; radius: double);

procedure acWriteTextEx(const Canvas: TCanvas; Text: PacChar; Enabled: boolean; var aRect : TRect; Flags: Cardinal; SkinData : TsCommonData; Hot : boolean; SkinManager : TObject = nil); overload;
procedure acWriteTextEx(const Canvas: TCanvas; Text: PacChar; Enabled: boolean; var aRect : TRect; Flags: Cardinal; SkinIndex : integer; Hot : boolean; SkinManager : TObject = nil); overload;
procedure acWriteText(const Canvas: TCanvas; Text: PacChar; Enabled: boolean; var aRect : TRect; Flags: Cardinal);

{$IFNDEF ACHINTS}
procedure WriteTextEx(const Canvas: TCanvas; Text: PChar; Enabled: boolean; var aRect : TRect; Flags: Cardinal; SkinIndex : integer; Hot : boolean; SkinManager : TObject = nil); overload;
procedure WriteTextEx(const Canvas: TCanvas; Text: PChar; Enabled: boolean; var aRect : TRect; Flags: Cardinal; SkinData : TsCommonData; Hot : boolean); overload;
{$IFDEF TNTUNICODE}
procedure WriteUnicode(const Canvas: TCanvas; const Text: WideString; Enabled: boolean; var aRect : TRect; Flags: Cardinal; SkinData : TsCommonData; Hot : boolean); overload;
procedure WriteTextExW(const Canvas: TCanvas; Text: PWideChar; Enabled: boolean; var aRect : TRect; Flags: Cardinal; SkinData : TsCommonData; Hot : boolean); overload;
// replace function of Canvas.TextRect
procedure TextRectW(const Canvas : TCanvas; var Rect: TRect; X, Y: Integer; const Text: WideString);
procedure WriteTextExW(const Canvas: TCanvas; Text: PWideChar; Enabled: boolean; var aRect : TRect; Flags: Cardinal; SkinIndex : integer; Hot : boolean; SkinManager : TObject = nil); overload;
{$ENDIF}

procedure PaintItemBG(SkinIndex : integer; const SkinSection : string; ci : TCacheInfo; State : integer; R : TRect; pP : TPoint; ItemBmp : TBitmap; SkinManager : TObject = nil; TextureIndex : integer = -1; HotTextureIndex : integer = -1; CustomColor : TColor = clFuchsia); overload;
procedure PaintItemBGFast(SkinIndex, BGIndex, BGHotIndex : integer; const SkinSection : string; ci : TCacheInfo; State : integer; R : TRect; pP : TPoint; ItemBmp : TBitmap; SkinManager : TObject = nil);
procedure PaintItemFast(SkinIndex, MaskIndex, BGIndex, BGHotIndex : integer; const SkinSection : string; var ci : TCacheInfo; Filling : boolean; State : integer; R : TRect; pP : TPoint; ItemBmp : TBitmap; SkinManager : TObject = nil); overload;
procedure PaintSmallItem(SkinIndex : integer; const SkinSection : string; ci : TCacheInfo; Filling : boolean; State : integer; R : TRect; pP : TPoint; ItemBmp : TBitmap; SkinManager : TObject = nil); overload;
procedure PaintItem(SkinIndex : integer; const SkinSection : string; ci : TCacheInfo; Filling : boolean; State : integer; R : TRect; pP : TPoint; ItemBmp : TBitmap; SkinManager : TObject = nil; BGIndex : integer = -1; BGHotIndex : integer = -1); overload;
procedure PaintItem(SkinIndex : integer; const SkinSection : string; ci : TCacheInfo; Filling : boolean; State : integer; R : TRect; pP : TPoint; DC : HDC; SkinManager : TObject = nil); overload;

function ChangeBrightness(Color : TColor; Delta : integer) : TColor;
function ChangeSaturation(Color : TColor; Delta : integer) : TColor; overload;
function ChangeSaturation(Delta : integer; Color : TsColor_) : TsColor_; overload;
function ChangeHue(Delta : integer; Color : TColor) : TColor; overload;
function ChangeHue(Delta : integer; C : TsColor_) : TsColor_; overload;
function Hsv2Rgb(h, s, v : real) : TsColor;
function Rgb2Hsv(C : TsColor) : TsHSV;
function acLayered: Boolean;

function CheckWidth(SkinManager : TObject) : integer;
function CheckHeight(SkinManager : TObject) : integer;
procedure acDrawCheck(R: TRect; AState: TCheckBoxState; AEnabled: Boolean; Bmp : TBitmap; CI : TCacheInfo; SkinManager : TObject);
{$ENDIF}

var
  User32Lib: Cardinal = 0;
  UpdateLayeredWindow: function (Handle: THandle; hdcDest: HDC; pptDst: PPoint; _psize: PSize;
    hdcSrc: HDC; pptSrc: PPoint; crKey: COLORREF; pblend: PBLENDFUNCTION; dwFlags: DWORD): Boolean; stdcall;
  SetLayeredWindowAttributes: function (Hwnd: THandle; crKey: COLORREF; bAlpha: Byte; dwFlags: DWORD): Boolean; stdcall;

{$ENDIF} // NOTFORHELP
implementation

uses {$IFNDEF ACHINTS}sStyleSimply, sSkinProps, sSkinManager, sBorders, sSkinProvider, sVCLUtils, sMessages,
  {$ENDIF}sGradient, sAlphaGraph{$IFDEF TNTUNICODE}, TntWideStrUtils, TntWindows{$ENDIF}, sDefaults
  {$IFNDEF ALITE}, sSplitter{$ENDIF};

var
  FCheckWidth, FCheckHeight: Integer;

procedure DrawColorArrow(Bmp : TBitmap; Color : TColor; R : TRect; Direction : integer);
const
  aWidth = 6;
  aHeight = 3;
var
  x, y, Left, Top, i : integer;
begin
  i := 0;
  case Direction of
    BF_BOTTOM : begin
      Left := R.Left + (WidthOf(R) - aWidth) div 2;
      Top := R.Top + (HeightOf(R) - aHeight) div 2;
      for y := Top to Top + aHeight do begin
        for x := Left + i to Left + aHeight do begin
          Bmp.Canvas.Pixels[x, y] := Color;
          Bmp.Canvas.Pixels[R.Left + 1 + Left + aWidth - x, y] := Color;
        end;
        inc(i);
      end;
    end;
    BF_RIGHT : begin
      Left := R.Left + (WidthOf(R) - aHeight) div 2;
      Top := R.Top + (HeightOf(R) - aWidth) div 2;
      for x := Left to Left + aHeight do begin
        for y := Top + i to Top + aHeight do begin
          Bmp.Canvas.Pixels[x, y] := Color;
          Bmp.Canvas.Pixels[x, R.Top + 2 + Top + aWidth - y] := Color;
        end;
        inc(i);
      end;
    end;
  end;
end;

function CheckWidth(SkinManager : TObject) : integer;
begin
  with TsSkinManager(SkinManager) do if Assigned(SkinManager) and Active and IsValidImgIndex(ConstData.SmallCheckBoxChecked) then begin
    Result := WidthOfImage(ma[ConstData.SmallCheckBoxChecked]) + 2;
  end
  else Result := FCheckWidth;
end;

function CheckHeight(SkinManager : TObject) : integer;
begin
  with TsSkinManager(SkinManager) do if Assigned(SkinManager) and Active and IsValidImgIndex(ConstData.SmallCheckBoxChecked) then begin
    Result := HeightOfImage(ma[ConstData.SmallCheckBoxChecked]);
  end
  else Result := FCheckHeight;
end;

procedure GetCheckSize;
begin
  with TBitmap.Create do try
    Handle := LoadBitmap(0, PChar(OBM_CHECKBOXES));
    FCheckWidth := Width div 4;
    FCheckHeight := Height div 3;
  finally
    ReleaseHandle;
    Free;
  end;
end;

procedure acDrawCheck(R: TRect; AState: TCheckBoxState; AEnabled: Boolean; Bmp : TBitmap; CI : TCacheInfo; SkinManager : TObject);
var
  DrawState: Integer;
  DrawRect: TRect;
  SkinnedGlyph : boolean;
begin
  with TsSkinManager(SkinManager) do begin
    SkinnedGlyph := False;
    case AState of
      cbChecked : if IsValidImgIndex(ConstData.SmallCheckBoxChecked) then SkinnedGlyph := True;
      cbUnChecked : if IsValidImgIndex(ConstData.SmallCheckBoxUnChecked) then SkinnedGlyph := True;
      cbGrayed : if IsValidImgIndex(ConstData.SmallCheckBoxGrayed) then SkinnedGlyph := True;
    end;

    DrawRect := R;
    DrawState := 0;

    if not SkinnedGlyph then begin
      OffsetRect(DrawRect, - DrawRect.Left, - DrawRect.Top);
      if CI.Ready
        then BitBlt(Bmp.Canvas.Handle, DrawRect.Left, DrawRect.Top, CheckWidth(SkinManager) + 2, HeightOf(R), CI.Bmp.Canvas.Handle, CI.X + R.Left + 1, CI.Y + R.Top + 1, SRCCOPY)
        else FillDC(Bmp.Canvas.Handle, Rect(DrawRect.Left, DrawRect.Top, DrawRect.Left + CheckWidth(SkinManager) + 2, DrawRect.Top + HeightOf(R)), CI.FillColor);
      case AState of
        cbChecked: DrawState := DFCS_BUTTONCHECK or DFCS_CHECKED;
        cbUnchecked: DrawState := DFCS_BUTTONCHECK;
        else DrawState := DFCS_BUTTON3STATE or DFCS_CHECKED;
      end;
      if not AEnabled then DrawState := DrawState or DFCS_INACTIVE;
    end;

    DrawRect.Left := DrawRect.Left + (DrawRect.Right - DrawRect.Left - CheckWidth(SkinManager)) div 2;
    DrawRect.Top := DrawRect.Top + (DrawRect.Bottom - DrawRect.Top - CheckHeight(SkinManager)) div 2;
    DrawRect.Right := DrawRect.Left + CheckWidth(SkinManager);
    DrawRect.Bottom := DrawRect.Top + CheckHeight(SkinManager);

    if SkinnedGlyph then begin
      OffsetRect(DrawRect, 0, - DrawRect.Top + (HeightOf(R) - CheckHeight(SkinManager)) div 2);
      case AState of
        cbChecked : if IsValidImgIndex(ConstData.SmallCheckBoxChecked)
          then sAlphaGraph.DrawSkinGlyph(Bmp, DrawRect.TopLeft, 0, 1 + integer(not AEnabled), ma[ConstData.SmallCheckBoxChecked], CI);
        cbUnChecked : if IsValidImgIndex(ConstData.SmallCheckBoxUnChecked)
          then sAlphaGraph.DrawSkinGlyph(Bmp, DrawRect.TopLeft, 0, 1 + integer(not AEnabled), ma[ConstData.SmallCheckBoxUnChecked], CI);
        cbGrayed : if IsValidImgIndex(ConstData.SmallCheckBoxGrayed)
          then sAlphaGraph.DrawSkinGlyph(Bmp, DrawRect.TopLeft, 0, 1 + integer(not AEnabled), ma[ConstData.SmallCheckBoxGrayed], CI);
      end;
  {
      if not AEnabled then begin
        OffsetRect(R, CI.X, CI.Y);
        BlendTransRectangle(Bmp, 0, 0, CI.Bmp, R, 0.4);
      end;
  }
    end
    else DrawFrameControl(Bmp.Canvas.Handle, DrawRect, DFC_BUTTON, DrawState);
  end;
end;


function acLayered: Boolean;
begin
  Result := @UpdateLayeredWindow <> nil;
end;

function SwapInteger(const i : integer) : integer;
var
  r, g, b, j : integer;
begin
  r := i mod 256;
  j := i shr 8;
  g := j mod 256;
  b := j shr 8;
  Result := r shl 16 + g shl 8 + b;
end;

{$IFNDEF ACHINTS}
function IsNAN(const d: double): boolean;
var
  Overlay: Int64 absolute d;
begin
  Result := ((Overlay and $7FF0000000000000) = $7FF0000000000000) and ((Overlay and $000FFFFFFFFFFFFF) <> $0000000000000000)
end;

function ChangeBrightness(Color : TColor; Delta : integer) : TColor;
var
  C : TsColor;
  dR, dG, dB : real;
begin
  Result := Color;
  if Delta = 0 then Exit;
  C.C := Color;

  if Delta > 0 then begin
    dR := (MaxByte - C.R) / 100;
    dG := (MaxByte - C.G) / 100;
    dB := (MaxByte - C.B) / 100;
  end
  else begin
    dR := C.R / 100;
    dG := C.G / 100;
    dB := C.B / 100;
  end;

  C.R := max(min(Round(C.R + Delta * dR), MaxByte), 0);
  C.G := max(min(Round(C.G + Delta * dG), MaxByte), 0);
  C.B := max(min(Round(C.B + Delta * dB), MaxByte), 0);
  Result := C.C;
end;

function ChangeSaturation(Color : TColor; Delta : integer) : TColor;
var
  C : TsColor_;
begin
  if Delta <> 0 then begin
    C.C := Color;
    C := ChangeSaturation(Delta, C);
    Result := C.C;
  end
  else Result := Color;
end;

function ChangeSaturation(Delta : integer; Color : TsColor_) : TsColor_; overload;
var
  Gray : real;
begin
  if Delta <> 0 then begin
    Gray := (Color.R + Color.G + Color.B) / 3;
    TsColor(Result).A := Color.A;
    TsColor(Result).B := max(min(Round(Color.R - Delta * (Gray - Color.R) / 100), MaxByte), 0);
    TsColor(Result).G := max(min(Round(Color.G - Delta * (Gray - Color.G) / 100), MaxByte), 0);
    TsColor(Result).R := max(min(Round(Color.B - Delta * (Gray - Color.B) / 100), MaxByte), 0);
  end
  else Result := Color;
end;

function Hsv2Rgb(h, s, v : real) : TsColor;
var
  I : integer;
  F, M, N, K : real;
begin
  Result.A := 0;
  if S = 0 then begin Result.R := IntToByte(Round(V * MaxByte)); Result.G := Result.R; Result.B := Result.R end else begin
    if H = 360 then H := 0 else H := H / 60;
    I := Round(Int(H));
    F := (H - I);

    V := V * MaxByte;
    M := V * (1 - S);
    N := V * (1 - S * F);
    K := V * (1 - S * (1 - F));

    M := max(min(M, MaxByte), 0);
    N := max(min(N, MaxByte), 0);
    K := max(min(K, MaxByte), 0);

    Result.A := 0;
    case I of
      0: begin Result.R := Round(V); Result.G := Round(K); Result.B := Round(M) end;
      1: begin Result.R := Round(N); Result.G := Round(V); Result.B := Round(M) end;
      2: begin Result.R := Round(M); Result.G := Round(V); Result.B := Round(K) end;
      3: begin Result.R := Round(M); Result.G := Round(N); Result.B := Round(V) end;
      4: begin Result.R := Round(K); Result.G := Round(M); Result.B := Round(V) end
      else begin Result.R := Round(V); Result.G := Round(M); Result.B := Round(N) end
    end;
  end
end;

function Rgb2Hsv(C : TsColor) : TsHSV;
var
  Rt, Gt, Bt : real;
  H, S, V : real;
  d, max, min : integer;
begin
  C.A := 0;
  max := math.Max(math.Max(c.R, c.G), c.B);
  min := math.Min(math.Min(c.R, c.G), c.B);
  d := max - min;
  V := max;
  if (max <> 0) then S := d / max else S := 0;
  if S = 0 then begin
    Result.H := 0;
  end
  else begin
    rt := max - c.R * 60 / d;
    gt := max - c.G * 60 / d;
    bt := max - c.B * 60 / d;
    if c.R = max then H := bt - gt else if c.G = max then H := 120 + rt - bt else H := 240 + gt - rt;
    if H < 0 then H := H + 360;
    Result.H := Round(H);
  end;
  Result.S := S;
  Result.V := V / MaxByte;
end;

function ChangeHue(Delta : integer; C : TsColor_) : TsColor_; overload;
var
  Rt, Gt, Bt : real;
  H, S, V, r : real;
  d, max, min : integer;
  I : integer;
  F, M, N, K : real;
begin
  max := math.Max(math.Max(c.R, c.G), c.B);
  min := math.Min(math.Min(c.R, c.G), c.B);
  d := max - min;
  V := max;
  if (max <> 0) then S := d / max else S := 0;
  if S = 0 then H := 0 else begin
    r := 60 / d;
    rt := max - c.R * r;
    gt := max - c.G * r;
    bt := max - c.B * r;
    if c.R = max then H := bt - gt else if c.G = max then H := 120 + rt - bt else H := 240 + gt - rt;
    if H < 0 then H := H + 360;
  end;

  H := round(H + Delta) mod 360;

  if S = 0 then begin C.R := Round(V) end else begin
    H := H / 60;
    I := Round(Int(H));
    F := (H - I);

    M := V * (1 - S);
    N := V * (1 - S * F);
    K := V * (1 - S * (1 - F));

    M := Math.max(Math.min(M, MaxByte), 0);
    N := Math.max(Math.min(N, MaxByte), 0);
    K := Math.max(Math.min(K, MaxByte), 0);

    case I of
      0: begin C.R := Round(V); C.G := Round(K); C.B := Round(M) end;
      1: begin C.R := Round(N); C.G := Round(V); C.B := Round(M) end;
      2: begin C.R := Round(M); C.G := Round(V); C.B := Round(K) end;
      3: begin C.R := Round(M); C.G := Round(N); C.B := Round(V) end;
      4: begin C.R := Round(K); C.G := Round(M); C.B := Round(V) end
      else begin C.R := Round(V); C.G := Round(M); C.B := Round(N) end
    end;
  end;
  Result := C
end;

function ChangeHue(Delta : integer; Color : TColor) : TColor; overload;
var
  C : TsColor_;
begin
  if Delta <> 0 then begin
    C.A := TsColor(Color).A;
    C.R := TsColor(Color).R;
    C.G := TsColor(Color).G;
    C.B := TsColor(Color).B;
    C := ChangeHue(Delta, C);
    TsColor(Result).A := C.A;
    TsColor(Result).R := C.R;
    TsColor(Result).G := C.G;
    TsColor(Result).B := C.B;
  end
  else Result := Color;
end;

procedure HSVtoRGB(const H,S,V: Real; var R,G,B: real);
var
  f : Real;
  i : Integer;
  hTemp : Real;              // since H is const parameter
  p, q, t : Real;
begin
  if (ABS(S - 0.0001) <= 0.0001) or IsNan(H) { color is on black-and-white center line } then begin
    if IsNaN(H) then begin
      R := V;                   // achromatic:  shades of gray
      G := V;
      B := V
    end
  end
  else begin                    // chromatic color
    if H = 360.0 { 360 degrees same as 0 degrees } then hTemp := 0.0 else hTemp := H;
    hTemp := hTemp / 60;        // h is now IN [0,6)
    i := TRUNC(hTemp);          // largest integer <= h
    f := hTemp - i;             // fractional part of h
    p := V * (1.0 - S);
    q := V * (1.0 - (S * f));
    t := V * (1.0 - (S * (1.0 - f)));
    case i OF
      0:  begin R := V; G := t; B := p end;
      1:  begin R := q; G := V; B := p end;
      2:  begin R := p; G := V; B := t end;
      3:  begin R := p; G := q; B := V end;
      4:  begin R := t; G := p; B := V end;
      5:  begin R := V; G := p; B := q end
    end
  end
end {HSVtoRGB};

procedure RGBToHSV (const R, G, B: Real; var H, S, V: Real);
var
  Delta:  Real;
  Min  :  Real;
begin
  Min := MinValue( [R, G, B] );
  V   := MaxValue( [R, G, B] );
  Delta := V - Min;
  // Calculate saturation:  saturation is 0 if r, g and b are all 0
  if V = 0.0 then S := 0 else S := Delta / V;
  if S = 0.0 then {H := NAN // Achromatic:  When s = 0, h is undefined } else begin    // Chromatic
    if R = V then { between yellow and magenta [degrees] } H := 60.0 * (G - B) / Delta else
      if G = V then { between cyan and yellow } H := 120.0 + 60.0 * (B - R) / Delta else if B = V then { between magenta and cyan } H := 240.0 + 60.0 * (R - G) / Delta;
    if H < 0.0 then H := H + 360.0
  end
end {RGBtoHSV};

procedure GetRgnFromBmp(var rgn : hrgn; MaskBmp : TBitmap; TransColor : TColor);
var
  ArOR : TAOR;
  subrgn : hrgn;
  i, l : integer;
begin
  SetLength(ArOR, 0);
  AddRgnBmp(ArOR, MaskBmp, TsColor(TransColor));
  l := Length(ArOR);
  rgn := CreateRectRgn(0, 0, MaskBmp.Width, MaskBmp.Height);
  if l > 0 then for i := 0 to l - 1 do begin
    subrgn := CreateRectRgn(ArOR[i].Left, ArOR[i].Top, ArOR[i].Right, ArOR[i].Bottom);
    CombineRgn(rgn, rgn, subrgn, RGN_DIFF);
    DeleteObject(subrgn);
  end
end;

function GetBGInfo(const BGInfo : PacBGInfo; const Handle : THandle; PleaseDraw : boolean = False) : boolean;
var
  b : boolean;
  FSaveIndex : hdc;
  P: TPoint;
begin
  Result := False;
  b := BGInfo^.PleaseDraw;
  BGInfo^.BgType := btUnknown;
  BGInfo^.PleaseDraw := PleaseDraw;
  SendMessage(Handle, SM_ALPHACMD, MakeWParam(0, AC_GETBG), longint(BGInfo));
  if BGInfo^.BgType <> btUnknown then Result := True else begin
    if b then begin // If real parent bg is required
      FSaveIndex := SaveDC(BGInfo^.DrawDC);
      GetViewportOrgEx(BGInfo^.DrawDC, P);
      SetViewportOrgEx(BGInfo^.DrawDC, P.X - BGInfo^.Offset.X, P.Y - BGInfo^.Offset.Y, nil);
      OffsetRect(BGInfo^.R, BGInfo^.Offset.X, BGInfo^.Offset.Y);
      IntersectClipRect(BGInfo^.DrawDC, BGInfo^.R.Left, BGInfo^.R.Top, BGInfo^.R.Right, BGInfo^.R.Bottom);

      SendMessage(Handle, WM_ERASEBKGND, Longint(BGInfo^.DrawDC), 0);
      SendMessage(Handle, WM_PAINT, Longint(BGInfo^.DrawDC), 0);
      RestoreDC(BGInfo^.DrawDC, FSaveIndex);
    end
    else begin
      if DefaultManager <> nil then BGInfo^.Color := DefaultManager.GetGlobalColor else BGInfo^.Color := clBtnFace;
      BGInfo^.BgType := btFill;
      Result := False;
    end;
  end;
end;

function BGInfoToCI(const BGInfo : PacBGInfo) : TCacheInfo;
begin
  if BGInfo^.BgType = btCache then begin
    Result := MakeCacheInfo(BGInfo^.Bmp, BGInfo^.Offset.X, BGInfo^.Offset.Y);
  end
  else begin
    Result.X := BGInfo^.Offset.X;
    Result.Y := BGInfo^.Offset.Y;
    Result.Ready := False;
    Result.FillColor := ColorToRGB(BGInfo^.Color);
    Result.Bmp := nil;
  end;
end;

function GetBGInfo(const BGInfo : PacBGInfo; const Control : TControl; PleaseDraw : boolean = False) : boolean; overload;
var
  b : boolean;
  FSaveIndex : hdc;
  P: TPoint;
begin
  Result := False;
  b := BGInfo^.PleaseDraw;
  BGInfo^.BgType := btUnknown;
  BGInfo^.PleaseDraw := PleaseDraw;
  if (Control is TWinControl) and (TWinControl(Control)).HandleAllocated
    then SendMessage(TWinControl(Control).Handle, SM_ALPHACMD, MakeWParam(0, AC_GETBG), longint(BGInfo))
    else Control.Perform(SM_ALPHACMD, MakeWParam(0, AC_GETBG), longint(BGInfo));
  if BGInfo^.BgType <> btUnknown then Result := True else begin
    if b then begin // If real parent bg is required
      FSaveIndex := SaveDC(BGInfo^.DrawDC);
      GetViewportOrgEx(BGInfo^.DrawDC, P);
      SetViewportOrgEx(BGInfo^.DrawDC, P.X - BGInfo^.Offset.X, P.Y - BGInfo^.Offset.Y, nil);
      OffsetRect(BGInfo^.R, BGInfo^.Offset.X, BGInfo^.Offset.Y);
      IntersectClipRect(BGInfo^.DrawDC, BGInfo^.R.Left, BGInfo^.R.Top, BGInfo^.R.Right, BGInfo^.R.Bottom);

      Control.Perform(WM_ERASEBKGND, Longint(BGInfo^.DrawDC), 0);
      Control.Perform(WM_PAINT, Longint(BGInfo^.DrawDC), 0);
      RestoreDC(BGInfo^.DrawDC, FSaveIndex);
    end
    else begin
      Result := False;
      BGInfo^.BgType := btFill;
      BGInfo^.Color := Control.Perform(SM_ALPHACMD, MakeWParam(0, AC_GETCONTROLCOLOR), 0);
      if BGInfo^.Color = 0 then BGInfo^.Color := ColorToRGB(TsHackedControl(Control).Color);
      if BGInfo^.PleaseDraw and (BGInfo^.Bmp <> nil) then FillDC(BGInfo^.DrawDC, BGInfo^.R, BGInfo^.Color);
    end
  end;
end;

procedure AddRgnBmp(var AOR : TAOR; MaskBmp : TBitmap; TransColor : TsColor);
var
  X, Y, h, w, l: Integer;
  c : TsColor;
  RegRect : TRect;
  Fast32Src : TacFast32;
begin
  h := MaskBmp.Height - 1;
  w := MaskBmp.Width - 1;
  RegRect := Rect(-1, 0, 0, 0);
  TransColor.A := 0;
  c.A := 0;
  l := Length(AOR);

  Fast32Src := TacFast32.Create;
  try
    if Fast32Src.Attach(MaskBmp) then for Y := 0 to h do begin
      for X := 0 to w do begin
        c := Fast32Src.Pixels[x, y];
        if c.C = TransColor.C then begin
          if RegRect.Left <> -1 then inc(RegRect.Right) else begin
            RegRect.Left := X;
            RegRect.Right := RegRect.Left + 1;
            RegRect.Top := Y;
            RegRect.Bottom := RegRect.Top + 1;
          end;
        end
        else if RegRect.Left <> -1 then begin
          SetLength(aOR, l + 1);
          AOR[l] := RegRect;
          inc(l);
          RegRect.Left := -1;
        end;
      end;
      if RegRect.Left <> -1 then begin
        SetLength(AOR, l + 1);
        AOR[l] := RegRect;
        inc(l);
        RegRect.Left := -1;
      end;
    end;
  finally
    FreeAndNil(Fast32Src);
  end;
end;

procedure AddRgn(var AOR : TAOR; Width : integer; MaskData : TsMaskData; VertOffset : integer; Bottom : boolean);
var
  S : PRGBAArray;
  X, Y, h, w, l, w2, cx: Integer;
  c : TsColor;
  cur : TsColor_;
  RegRect : TRect;
  Bmp : TBitmap;
  XOffs, YOffs, MaskOffs : integer;
begin
  if MaskData.Manager = nil then Exit;
  if MaskData.Bmp = nil then Bmp := TsSkinManager(MaskData.Manager).MasterBitmap else Bmp := MaskData.Bmp;

  if Bottom then h := MaskData.WB else h := MaskData.WT;
  w := MaskData.WL;
  if Bottom then MaskOffs := (HeightOf(MaskData.R) div (1 + MaskData.MaskType) - MaskData.WB) else MaskOffs := 0;
  XOffs := MaskData.R.Left; YOffs := MaskData.R.Top;

  if Bmp = nil then Exit;
  inc(YOffs, MaskOffs);
  RegRect := Rect(-1, 0, 0, 0);
  l := Length(AOR);
  dec(h); dec(w);
  if h + YOffs > Bmp.Height then Exit;
  c.A := 0;

  for Y := 0 to h do begin
    S := Bmp.ScanLine[Y + YOffs];
    for X := 0 to w do begin
      cur := S[X + XOffs];
      if (cur.C = clFuchsia) then begin
        if RegRect.Left <> -1 then inc(RegRect.Right) else begin
          RegRect.Left := X;
          RegRect.Right := RegRect.Left + 1;
          RegRect.Top := Y + VertOffset;
          RegRect.Bottom := RegRect.Top + 1;
        end;
      end
      else if RegRect.Left <> -1 then begin
        SetLength(aOR, l + 1);
        AOR[l] := RegRect;
        inc(l);
        RegRect.Left := -1;
      end;
    end;
    if RegRect.Left <> -1 then begin
      SetLength(AOR, l + 1);
      AOR[l] := RegRect;
      inc(l);
      RegRect.Left := -1;
    end;
  end;

  w2 := WidthOf(MaskData.R) div MaskData.ImageCount - 1;      //x2
  w := WidthOf(MaskData.R) div MaskData.ImageCount - MaskData.WR;
  cx := Width - WidthOf(MaskData.R) div MaskData.ImageCount;  //First pixel on control
  for Y := 0 to h do begin
    S := Bmp.ScanLine[Y + YOffs];
    for X := w to w2 do begin
      cur := S[X + XOffs];
      if (cur.C = clFuchsia) then begin
        if RegRect.Left <> -1 then inc(RegRect.Right) else begin
          RegRect.Left := cx + X;
          RegRect.Right := RegRect.Left + 1;
          RegRect.Top := Y + VertOffset;
          RegRect.Bottom := RegRect.Top + 1;
        end;
      end
      else if RegRect.Left <> -1 then begin
        SetLength(aOR, l + 1);
        AOR[l] := RegRect;
        inc(l);
        RegRect.Left := -1;
      end;
    end;
    if RegRect.Left <> -1 then begin
      SetLength(AOR, l + 1);
      AOR[l] := RegRect;
      inc(l);
      RegRect.Left := -1;
    end;
  end;
end;

function GetRgnForMask(MaskIndex, Width, Height : integer; SkinManager : TObject) : hrgn;
var
  ArOR : TAOR;
  SubRgn : hrgn;
  i, l : integer;
begin
  Result := 0;
  SetLength(ArOR, 0);
  if TsSkinManager(SkinManager).IsValidImgIndex(MaskIndex) then begin
    AddRgn(ArOR, Width, TsSkinManager(SkinManager).ma[MaskIndex], 0, False);
    if TsSkinManager(SkinManager).ma[MaskIndex].Bmp = nil
      then AddRgn(ArOR, Width, TsSkinManager(SkinManager).ma[MaskIndex], Height - (HeightOf(TsSkinManager(SkinManager).ma[MaskIndex].R) div (3 * (1 + TsSkinManager(SkinManager).ma[MaskIndex].MaskType))), True)
      else AddRgn(ArOR, Width, TsSkinManager(SkinManager).ma[MaskIndex], Height - TsSkinManager(SkinManager).ma[MaskIndex].Bmp.Height div 6, True);

    l := Length(ArOR);
    if (l > 0) then begin
      Result := CreateRectRgn(0, 0, Width, Height);
      for i := 0 to l - 1 do begin
        SubRgn := CreateRectRgn(ArOR[i].Left, ArOR[i].Top, ArOR[i].Right, ArOR[i].Bottom);
        CombineRgn(Result, Result, SubRgn, RGN_DIFF);
        DeleteObject(SubRgn);
      end;
    end
  end;
end;

procedure CopyImage(Glyph : TBitmap; ImageList: TCustomImageList; Index: Integer);
begin
  with Glyph do begin
    Width := ImageList.Width;
    Height := ImageList.Height;
    if ImageList.BkColor = clNone then Canvas.Brush.Color := clFuchsia else Canvas.Brush.Color := ImageList.BkColor;//! for lack of a better color
    Canvas.FillRect(Rect(0,0, Width, Height));
{$IFDEF DELPHI7UP}
    ImageList.Draw(Canvas, 0, 0, Index, dsTransparent, itImage);
{$ELSE}
    ImageList.Draw(Canvas, 0, 0, Index, True);
{$ENDIF}
  end;
end;

procedure PaintItemBG(SkinIndex : integer; const SkinSection : string; ci : TCacheInfo; State : integer; R : TRect; pP : TPoint; ItemBmp : TBitmap; SkinManager : TObject = nil; TextureIndex : integer = -1; HotTextureIndex : integer = -1; CustomColor : TColor = clFuchsia);
var
  aRect: TRect;
  iDrawed : boolean;
  TempBmp : TBitmap;

  ImagePercent, GradientPercent : integer;
  PatternIndex, Transparency : integer;
  GradientData : string;
  GradientArray : TsGradArray;
  Color : TColor;
  Isjpg : boolean;
  md : TsMaskData;
  C : TColor;

  procedure PaintAddons(var aBmp : TBitmap);
  var
    bmp : TBitmap;
    R : TRect;
  begin
    iDrawed := False;
    if (ImagePercent + GradientPercent = 100) and (GradientPercent in [1..99]) and
         (TsSkinManager(SkinManager).ma[PatternIndex].DrawMode = 0) and (GradientArray[0].Mode1 < 2) and TsSkinManager(SkinManager).IsValidImgIndex(PatternIndex) then begin // Optimized drawing
      if TsSkinManager(SkinManager).ma[PatternIndex].Bmp <> nil
        then PaintGradTxt(aBmp, aRect, GradientArray, TsSkinManager(SkinManager).ma[PatternIndex].Bmp, TsSkinManager(SkinManager).ma[PatternIndex].R, MaxByte * ImagePercent div 100)
        else PaintGradTxt(aBmp, aRect, GradientArray, TsSkinManager(SkinManager).MasterBitmap, TsSkinManager(SkinManager).ma[PatternIndex].R, MaxByte * ImagePercent div 100)
    end
    else begin
      R := aRect;
      // BGImage painting
      if (ImagePercent > 0) then with TsSkinManager(SkinManager) do begin
        if IsJpg then begin
          if (PatternIndex > -1) and (PatternIndex < Length(pa)) then begin
            TileBitmap(aBmp.Canvas, R, pa[PatternIndex].Img, md);
            iDrawed := True;
          end;
        end
        else if (PatternIndex > -1) and (PatternIndex < Length(ma)) then begin
          if boolean(ma[PatternIndex].MaskType)
            then TileMasked(aBmp, R, CI, ma[PatternIndex], acFillModes[ma[PatternIndex].DrawMode])
            else TileBitmap(aBmp.Canvas, R, ma[PatternIndex].Bmp, ma[PatternIndex], acFillModes[ma[PatternIndex].DrawMode]);
          iDrawed := True;
        end;
        if R.Right <> -1 then begin
          if aBmp.PixelFormat = pf32bit
            then FillRect32(aBmp, R, Color)
            else FillDC(aBmp.Canvas.Handle, R, Color);
        end;
      end;
      // BGGradient painting
      if (GradientPercent > 0) then begin
        if iDrawed then begin
          bmp := CreateBmp32(WidthOf(aRect, True), HeightOf(aRect, True));
          try
            if Length(GradientData) > 0
              then PaintGrad(Bmp, Rect(0, 0, Bmp.Width, Bmp.Height), GradientArray)
              else if Bmp.PixelFormat = pf32bit
                then FillRect32(Bmp, aRect, Color)
                else FillDC(Bmp.Canvas.Handle, aRect, Color);

            SumBmpRect(aBmp, Bmp, max(min((ImagePercent * integer(MaxByte)) div 100, MaxByte), 0), Rect(0, 0, Bmp.Width, Bmp.Height), Point(aRect.Left, aRect.Top));
          finally
            FreeAndNil(Bmp);
          end;
        end
        else if Length(GradientData) > 0 then PaintGrad(aBmp, aRect, GradientArray) else begin
          if aBmp.PixelFormat = pf32bit then FillRect32(aBmp, aRect, Color) else FillDC(aBmp.Canvas.Handle, aRect, Color);
        end;
      end;
      case GradientPercent + ImagePercent of
        1..99 : BlendColorRect(aBmp, aRect, GradientPercent + ImagePercent, Color);
        0 : if not ci.Ready and (Transparency <> 0) then begin
          case Transparency of
            0 : C := ci.FillColor;
            100 : C := Color
            else C := MixColors(Color, ci.FillColor, Transparency / 100)
          end;
          if aBmp.PixelFormat = pf32bit then FillRect32(aBmp, aRect, C) else FillDC(aBmp.Canvas.Handle, aRect, C)
        end
        else begin
          if aBmp.PixelFormat = pf32bit then FillRect32(aBmp, aRect, Color) else FillDC(aBmp.Canvas.Handle, aRect, Color);
        end;
      end;
    end;
  end;
begin
  if SkinManager = nil then SkinManager := DefaultManager;
  if not Assigned(SkinManager) or not TsSkinManager(SkinManager).IsValidSkinIndex(SkinIndex) then Exit;
  ImagePercent := 0;
  GradientPercent := 0;
  with TsSkinManager(SkinManager) do begin {SeeLater}
    if gd[SkinIndex].States <= State then State := gd[SkinIndex].States - 1;
    aRect := R;
    IsJpg := False;
    if CustomColor = clFuchsia then begin
      case State of
        0 : begin
          Color := gd[SkinIndex].Color;
          Transparency := gd[SkinIndex].Transparency;
          if Transparency <> 100 then begin
            ImagePercent := gd[SkinIndex].ImagePercent;
            GradientPercent := gd[SkinIndex].GradientPercent;
            if (ImagePercent > 0) then begin
              if TextureIndex <> -1 then begin
                if ma[TextureIndex].MaskType = 0 then PatternIndex := TextureIndex
              end
              else PatternIndex := GetMaskIndex(SkinIndex, SkinSection, s_Pattern);
              if not TsSkinManager(SkinManager).IsValidImgIndex(PatternIndex) then begin PatternIndex := GetPatternIndex(SkinIndex, SkinSection, s_Pattern); IsJpg := PatternIndex > -1 end;
            end;
            if GradientPercent <> 0 then begin GradientData := gd[SkinIndex].GradientData; GradientArray := gd[SkinIndex].GradientArray end;
          end;
        end
        else begin
          Color := gd[SkinIndex].HotColor;
          Transparency := gd[SkinIndex].HotTransparency;
          if Transparency <> 100 then begin
            ImagePercent := TsSkinManager(SkinManager).gd[SkinIndex].HotImagePercent;
            GradientPercent := gd[SkinIndex].HotGradientPercent;
            if (ImagePercent > 0) then begin
              if HotTextureIndex <> -1 then begin
                if TsSkinManager(SkinManager).ma[HotTextureIndex].MaskType = 0 then PatternIndex := HotTextureIndex
              end
              else PatternIndex := GetMaskIndex(SkinIndex, SkinSection, s_HotPattern);
              if not TsSkinManager(SkinManager).IsValidImgIndex(PatternIndex) then begin PatternIndex := GetPatternIndex(SkinIndex, SkinSection, s_HotPattern); IsJpg := PatternIndex > -1 end;
            end;
            if GradientPercent <> 0 then begin GradientData := gd[SkinIndex].HotGradientData; GradientArray := gd[SkinIndex].HotGradientArray end;
          end
        end;
      end;
    end
    else begin
      Color := CustomColor;
      Transparency := 0;
    end;
    if ci.Ready or (ci.FillColor <> clFuchsia) then case Transparency of
      100 : begin
        if ci.Ready then begin
          if ItemBmp <> ci.Bmp then begin
            BitBlt(ItemBmp.Canvas.Handle, aRect.Left, aRect.Top, WidthOf(aRect, True), HeightOf(aRect, True), ci.Bmp.Canvas.Handle, ci.X + pP.X, ci.Y + pP.Y, SRCCOPY)
          end;
        end
        else FillRect32(ItemBmp, aRect, ci.FillColor);
      end;
      0 : PaintAddons(ItemBmp);
      else begin
        if ci.Ready or (GradientPercent + ImagePercent <> 0) then begin
          if ItemBmp.PixelFormat = pf32bit then TempBmp := CreateBmp32(WidthOf(aRect, True), HeightOf(aRect, True)) else TempBmp := CreateBmp32(WidthOf(aRect, True), HeightOf(aRect, True));
          try
            OffsetRect(aRect, - aRect.Left, - aRect.Top);
            PaintAddons(TempBmp);

            aRect := R;

            if ci.Ready then begin
              if ItemBmp <> ci.Bmp then BitBlt(ItemBmp.Canvas.Handle, R.Left, R.Top, WidthOf(R, True), HeightOf(R, True), ci.Bmp.Canvas.Handle, ci.X + pP.X, ci.Y + pP.y, SRCCOPY)
            end
            else if ItemBmp.PixelFormat = pf32bit then FillRect32(ItemBmp, aRect, ci.FillColor) else FillDC(ItemBmp.Canvas.Handle, R, ci.FillColor);

            SumBmpRect(ItemBmp, TempBmp, IntToByte(Transparency * integer(MaxByte) div 100), Rect(0, 0, WidthOf(aRect, True), HeightOf(aRect, True)), Point(aRect.Left, aRect.Top));
          finally
            FreeAndNil(TempBmp);
          end
        end
        else begin
          case Transparency of
            0 : C := ci.FillColor;
            100 : C := Color
            else C := MixColors(ci.FillColor, Color, Transparency / 100)
          end;
          if ItemBmp.PixelFormat = pf32bit then FillRect32(ItemBmp, aRect, C) else FillDC(ItemBmp.Canvas.Handle, aRect, C)
        end;
      end;
    end
    else PaintAddons(ItemBmp);

    case State of
      0 : if (TextureIndex <> -1) then begin
        if (ma[TextureIndex].MaskType > 0) then begin
          if (ma[TextureIndex].DrawMode in [ord(fmDisTiled)]) then begin
            inc(ci.X, pP.X);
            inc(ci.Y, pP.Y);
            TileMasked(ItemBmp, R, ci, ma[TextureIndex], acFillModes[ma[TextureIndex].DrawMode]);
            dec(ci.X, pP.X);
            dec(ci.Y, pP.Y);
          end;
        end;
      end
      else if (HotTextureIndex <> -1) then begin
        if (ma[HotTextureIndex].MaskType > 0) then begin
          if (ma[HotTextureIndex].DrawMode in [ord(fmDisTiled)]) then begin
            inc(ci.X, pP.X);
            inc(ci.Y, pP.Y);
            TileMasked(ItemBmp, R, ci, ma[HotTextureIndex], acFillModes[ma[HotTextureIndex].DrawMode]);
            dec(ci.X, pP.X);
            dec(ci.Y, pP.Y);
          end;
        end;
      end;
    end;    
  end;
end;

procedure PaintItemBG(SkinData : TsCommonData; ci : TCacheInfo; State : integer; R : TRect; pP : TPoint; ItemBmp : TBitmap; OffsetX : integer = 0; OffsetY : integer = 0); overload;
var
  CustomColor : TColor;
begin
  if SkinData.CustomColor then begin // If custom color used
    if SkinData.FOwnerObject is TsSkinProvider
      then CustomColor := ColorToRGB(TsHackedControl(TsSkinProvider(SkinData.FOwnerObject).Form).Color)
      else if (SkinData.FOwnerControl <> nil)
        then CustomColor := ColorToRGB(TsHackedControl(SkinData.FOwnerControl).Color)
        else CustomColor := clFuchsia;
  end
  else CustomColor := clFuchsia;
  State := min(State, SkinData.SkinManager.gd[SkinData.SkinIndex].States - 1);
  PaintItemBG(SkinData.SkinIndex, SkinData.SkinSection, ci, State, R, pP, ItemBmp, SkinData.SkinManager, SkinData.Texture, SkinData.HotTexture, CustomColor);
end;

procedure PaintItemBGFast(SkinIndex, BGIndex, BGHotIndex : integer; const SkinSection : string; ci : TCacheInfo; State : integer; R : TRect; pP : TPoint; ItemBmp : TBitmap; SkinManager : TObject = nil);
var
  aRect: TRect;
  iDrawed : boolean;
  TempBmp : TBitmap;

  ImagePercent, GradientPercent : integer;
  PatternIndex, Transparency : integer;
  GradientData : string;
  GradientArray : TsGradArray;
  Color : TColor;
  Isjpg : boolean;
  md : TsMaskData;

  procedure PaintAddons(var aBmp : TBitmap);
  var
    bmp : TBitmap;
    R : TRect;
  begin
    iDrawed := False;
    R := aRect;
    // BGImage painting
    if (ImagePercent > 0) then with TsSkinManager(SkinManager) do begin
      if IsJpg then begin
        if (PatternIndex > -1) and (PatternIndex < Length(pa)) then begin
          TileBitmap(aBmp.Canvas, R, pa[PatternIndex].Img, md);
          iDrawed := True;
        end;
      end
      else if (PatternIndex > -1) and (PatternIndex < Length(ma)) then begin
        if boolean(ma[PatternIndex].MaskType)
          then TileMasked(aBmp, R, CI, ma[PatternIndex], acFillModes[ma[PatternIndex].DrawMode])
          else TileBitmap(aBmp.Canvas, R, ma[PatternIndex].Bmp, ma[PatternIndex], acFillModes[ma[PatternIndex].DrawMode]);
        iDrawed := True;
      end;
      if R.Right <> -1 then if aBmp.PixelFormat = pf32bit then FillRect32(aBmp, R, Color) else FillDC(aBmp.Canvas.Handle, R, Color);
    end;
    // BGGradient painting
    if (GradientPercent > 0) then begin
      if iDrawed then begin
        bmp := CreateBmp32(WidthOf(aRect, True), HeightOf(aRect, True));
        try                                                
          if Length(GradientData) > 0
            then PaintGrad(Bmp, Rect(0, 0, Bmp.Width, Bmp.Height), GradientArray)
            else if Bmp.PixelFormat = pf32bit then FillRect32(Bmp, aRect, Color) else FillDC(Bmp.Canvas.Handle, aRect, Color);

          SumBmpRect(aBmp, Bmp, ImagePercent * integer(MaxByte) div 100, Rect(0, 0, Bmp.Width{ - 1}, Bmp.Height{ - 1}), Point(aRect.Left, aRect.Top));
        finally
          FreeAndNil(Bmp);
        end;
      end
      else begin
        if Length(GradientData) > 0 then begin
          PaintGrad(aBmp, aRect, GradientArray);
        end
        else if aBmp.PixelFormat = pf32bit then FillRect32(aBmp, aRect, Color) else FillDC(aBmp.Canvas.Handle, aRect, Color);
      end;
    end;
    case GradientPercent + ImagePercent of
      1..99 : BlendColorRect(aBmp, aRect, GradientPercent + ImagePercent, Color);
      100 :
      else begin
        if not CI.Ready and (Transparency = 100)
          then if aBmp.PixelFormat = pf32bit then FillRect32(aBmp, aRect, ci.FillColor) else FillDC(aBmp.Canvas.Handle, aRect, CI.FillColor)
          else if aBmp.PixelFormat = pf32bit then FillRect32(aBmp, aRect, Color) else FillDC(aBmp.Canvas.Handle, aRect, Color);
      end;
    end;
  end;
begin
  if SkinManager = nil then SkinManager := DefaultManager;
  if not Assigned(DefaultManager) or not TsSkinManager(SkinManager).IsValidSkinIndex(SkinIndex) then Exit;
  with TsSkinManager(SkinManager) do begin

    aRect := R;
    IsJpg := False;
    // Properties definition from skin file
    case State of
      0 : begin
        Color := gd[SkinIndex].Color;
        ImagePercent := gd[SkinIndex].ImagePercent;
        GradientPercent := gd[SkinIndex].GradientPercent;
        PatternIndex := BGIndex;
        if GradientPercent <> 0 then begin
          GradientData := gd[SkinIndex].GradientData;
          GradientArray := gd[SkinIndex].GradientArray;
        end;
        Transparency := gd[SkinIndex].Transparency;
      end
      else begin
        Color := gd[SkinIndex].HotColor;
        ImagePercent := gd[SkinIndex].HotImagePercent;
        GradientPercent := gd[SkinIndex].HotGradientPercent;
        PatternIndex := BGHotIndex;
        if GradientPercent <> 0 then begin
          GradientData := gd[SkinIndex].HotGradientData;
          GradientArray := gd[SkinIndex].HotGradientArray;
        end;
        Transparency := gd[SkinIndex].HotTransparency;
      end;
    end;

    if ci.Ready and (Transparency = 100) then begin
      if ItemBmp <> ci.Bmp then begin
        BitBlt(ItemBmp.Canvas.Handle, aRect.Left, aRect.Top, WidthOf(aRect, True), HeightOf(aRect, True), ci.Bmp.Canvas.Handle, ci.X + pP.X, ci.Y + pP.Y, SRCCOPY);
      end;
    end
    else if not ci.Ready or (Transparency = 0) then begin
      PaintAddons(ItemBmp);
    end
    else if ci.Ready and (Transparency > 0) then begin
      TempBmp := CreateBmp32(WidthOf(aRect, True), HeightOf(aRect, True));
      try
        OffsetRect(aRect, - aRect.Left, - aRect.Top);
        PaintAddons(TempBmp);
        aRect := R;
        if ci.Ready and (ci.Bmp <> nil) and (ci.Bmp <> ItemBmp) then begin
          BitBlt(ItemBmp.Canvas.Handle, aRect.Left, aRect.Top, WidthOf(aRect, True), HeightOf(aRect, True), ci.Bmp.Canvas.Handle, ci.X + pP.X, ci.Y + pP.y, SRCCOPY);
        end;
        SumBmpRect(ItemBmp, TempBmp, IntToByte(Transparency * integer(MaxByte) div 100), Rect(0, 0, WidthOf(aRect, True), HeightOf(aRect, True)), Point(aRect.Left, aRect.Top));
      finally
        FreeAndNil(TempBmp);
      end;
    end;
  end;
end;

procedure PaintItem(SkinIndex : integer; const SkinSection : string; ci : TCacheInfo; Filling : boolean; State : integer; R : TRect; pP : TPoint; DC : HDC; SkinManager : TObject = nil); overload;
var
  TempBmp : TBitmap;
  SavedDC : HDC;
begin
  if (SkinManager = nil) then SkinManager := DefaultManager;
  if not Assigned(SkinManager) or not TsSkinManager(SkinManager).IsValidSkinIndex(SkinIndex) or (R.Left < 0) or (R.Top < 0) or (WidthOf(r, True) < 1) or (HeightOf(r, True) < 1) then Exit;
  SavedDC := SaveDC(DC);
  TempBmp := CreateBmp32(WidthOf(r, True), HeightOf(r, True));
  try
    PaintItem(SkinIndex, SkinSection, ci, Filling, State , Rect(0, 0, TempBmp.Width, TempBmp.Height), pP, TempBmp, SkinManager);
    BitBlt(DC, r.Left, r.top, WidthOf(r, True), HeightOf(r, True), TempBmp.Canvas.Handle, 0, 0, SRCCOPY);
  finally
    FreeAndNil(TempBmp);
    RestoreDC(DC, SavedDC);
  end;
end;

procedure PaintItem(SkinIndex : integer; const SkinSection : string; ci : TCacheInfo; Filling : boolean; State : integer; R : TRect; pP : TPoint; ItemBmp : TBitmap; SkinManager : TObject = nil; BGIndex : integer = -1; BGHotIndex : integer = -1); overload;
begin
  if (ItemBmp = nil) or (R.Left >= R.Right) or (R.Top >= R.Bottom) then Exit;
  if (SkinManager = nil) then SkinManager := DefaultManager;
  if not Assigned(SkinManager) or not TsSkinManager(SkinManager).IsValidSkinIndex(SkinIndex) or (R.Bottom > ItemBmp.Height) or (R.Right > ItemBmp.Width) or (R.Left < 0) or (R.Top < 0) then Exit;
  if TsSkinManager(SkinManager).gd[SkinIndex].States <= State then State := TsSkinManager(SkinManager).gd[SkinIndex].States - 1;
  PaintItemBG(SkinIndex, SkinSection, ci, State, R, pP, ItemBmp, SkinManager, BGIndex, BGHotIndex);

  with TsSkinManager(SkinManager).gd[SkinIndex] do begin
    if ImgTL > -1 then DrawSkinGlyph(ItemBmp, Point(R.Left, R.Top), State, 1, TsSkinManager(SkinManager).ma[ImgTL], MakeCacheInfo(ItemBmp));
    if ImgTR > -1 then DrawSkinGlyph(ItemBmp, Point(R.Right - WidthOfImage(TsSkinManager(SkinManager).ma[ImgTR]), R.Top), State, 1, TsSkinManager(SkinManager).ma[ImgTR], MakeCacheInfo(ItemBmp));
    if ImgBL > -1 then DrawSkinGlyph(ItemBmp, Point(R.Left, R.Bottom - HeightOfImage(TsSkinManager(SkinManager).ma[ImgBL])), State, 1, TsSkinManager(SkinManager).ma[ImgBL], MakeCacheInfo(ItemBmp));
    if ImgBR > -1 then DrawSkinGlyph(ItemBmp, Point(R.Right - WidthOfImage(TsSkinManager(SkinManager).ma[ImgBR]), R.Bottom - HeightOfImage(TsSkinManager(SkinManager).ma[ImgBR])), State, 1, TsSkinManager(SkinManager).ma[ImgBR], MakeCacheInfo(ItemBmp));

    inc(ci.X, pP.X);
    inc(ci.Y, pP.Y);
    if TsSkinManager(SkinManager).IsValidImgIndex(TsSkinManager(SkinManager).gd[SkinIndex].BorderIndex) then DrawSkinRect(ItemBmp, R, Filling, ci, TsSkinManager(SkinManager).ma[BorderIndex], State, True);
  end;
end;

procedure PaintItemFast(SkinIndex, MaskIndex, BGIndex, BGHotIndex : integer; const SkinSection : string; var ci : TCacheInfo; Filling : boolean; State : integer; R : TRect; pP : TPoint; ItemBmp : TBitmap; SkinManager : TObject = nil); overload;
begin
  if SkinManager = nil then SkinManager := DefaultManager;
  if not Assigned(SkinManager) or not TsSkinManager(SkinManager).IsValidSkinIndex(SkinIndex) then Exit;
  if (R.Bottom > ItemBmp.Height) or (R.Right > ItemBmp.Width) or (R.Left < 0) or (R.Top < 0) then Exit;
  if TsSkinManager(SkinManager).gd[SkinIndex].States <= State then State := TsSkinManager(SkinManager).gd[SkinIndex].States - 1;
  PaintItemBGFast(SkinIndex, BGIndex, BGHotIndex, SkinSection, ci, State, R, pP, ItemBmp, SkinManager);
  inc(ci.X, pP.X);
  inc(ci.Y, pP.Y);
  if TsSkinManager(SkinManager).IsValidImgIndex(MaskIndex) then DrawSkinRect(ItemBmp, R, Filling, ci, TsSkinManager(SkinManager).ma[MaskIndex], State, True, TsSkinManager(SkinManager));
  dec(ci.X, pP.X);
  dec(ci.Y, pP.Y);
end;

procedure PaintSmallItem(SkinIndex : integer; const SkinSection : string; ci : TCacheInfo; Filling : boolean; State : integer; R : TRect; pP : TPoint; ItemBmp : TBitmap; SkinManager : TObject = nil); overload;
var
  i : integer;
begin
  if SkinManager = nil then SkinManager := DefaultManager;
  if not Assigned(SkinManager) or not TsSkinManager(SkinManager).IsValidSkinIndex(SkinIndex) or (R.Bottom > ItemBmp.Height) or (R.Right > ItemBmp.Width) or (R.Left < 0) or (R.Top < 0) then Exit;
  PaintItemBG(SkinIndex, SkinSection, ci, State, R, pP, ItemBmp, SkinManager);
  i := TsSkinManager(SkinManager).GetMaskIndex(SkinIndex, SkinSection, s_BordersMask);
  inc(ci.X, pP.X);
  inc(ci.Y, pP.Y);
  if TsSkinManager(SkinManager).IsValidImgIndex(i) then DrawSmallSkinRect(ItemBmp, R, Filling, ci, TsSkinManager(SkinManager).ma[i], State);
end;

function PaintSection(const Bmp : TBitmap; Section : string; const SecondSection : string; const State : integer; const Manager : TObject; const ParentOffset : TPoint; const BGColor : TColor; ParentDC : hdc = 0) : integer;
var
  CI : TCacheInfo;
begin
  with TsSkinManager(Manager) do begin
    Result := GetSkinIndex(Section);
    if not IsValidSkinIndex(Result) then begin
      Section := SecondSection;
      Result := GetSkinIndex(Section);
    end;
    if IsValidSkinIndex(Result) then begin
      CI.FillColor := BGColor;//GetGlobalColor;
      if ParentDC = 0 then CI.Ready := False else begin
        BitBlt(Bmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, ParentDC, ParentOffset.x, ParentOffset.y, SRCCOPY);
        CI.Bmp := Bmp;
        CI.Ready := True;
      end;
      PaintItem(Result, Section, CI, True, State, Rect(0, 0, Bmp.Width, Bmp.Height), Point(0, 0), Bmp, DefaultManager);
    end;
  end;
end;

procedure PaintItem(SkinData : TsCommonData; ci : TCacheInfo; Filling : boolean; State : integer; R : TRect; pP : TPoint; ItemBmp : TBitmap; UpdateCorners : boolean; OffsetX : integer = 0; OffsetY : integer = 0); overload;
var
  DefManager : TsSkinManager;
begin
  DefManager := SkinData.SkinManager;
  if (ItemBmp = nil) or not Assigned(DefManager) or not DefManager.IsValidSkinIndex(SkinData.SkinIndex) or (R.Bottom > ItemBmp.Height) or (R.Right > ItemBmp.Width) or (R.Left < 0) or (R.Top < 0) then Exit;

  if State >= DefManager.gd[SkinData.SkinIndex].States then State := DefManager.gd[SkinData.SkinIndex].States - 1;
  PaintItemBG(SkinData, ci, State, R, pP, ItemBmp, OffsetX, OffsetY);
  inc(ci.X, pP.X);
  inc(ci.Y, pP.Y);

  with DefManager.gd[SkinData.SkinIndex] do begin
    if DefManager.IsValidImgIndex(ImgTL) then DrawSkinGlyph(ItemBmp, Point(R.Left, R.Top), State, 1, DefManager.ma[ImgTL], MakeCacheInfo(ItemBmp));
    if DefManager.IsValidImgIndex(ImgTR) then DrawSkinGlyph(ItemBmp, Point(R.Right - WidthOfImage(DefManager.ma[ImgTR]), R.Top), State, 1, DefManager.ma[ImgTR], MakeCacheInfo(ItemBmp));
    if DefManager.IsValidImgIndex(ImgBL) then DrawSkinGlyph(ItemBmp, Point(0, R.Bottom - HeightOfImage(DefManager.ma[ImgBL])), State, 1, DefManager.ma[ImgBL], MakeCacheInfo(ItemBmp));
    if DefManager.IsValidImgIndex(ImgBR) then DrawSkinGlyph(ItemBmp, Point(R.Right - WidthOfImage(DefManager.ma[ImgBR]), R.Bottom - HeightOfImage(DefManager.ma[ImgBR])), State, 1, DefManager.ma[ImgBR], MakeCacheInfo(ItemBmp));
  end;

  if Assigned(DefManager) and DefManager.IsValidImgIndex(SkinData.BorderIndex) and not ((State = 0) and (DefManager.ma[SkinData.BorderIndex].DrawMode and BDM_ACTIVEONLY = BDM_ACTIVEONLY)) then begin
    DrawSkinRect(ItemBmp, R, True{Filling}, ci, DefManager.ma[SkinData.BorderIndex], State, UpdateCorners);
    if SkinData.HUEOffset <> 0 then ChangeBmpHUE(ItemBmp, SkinData.HUEOffset);
    if SkinData.Saturation <> 0 then ChangeBmpSaturation(ItemBmp, SkinData.Saturation);
  end
  else if DefManager.IsValidSkinIndex(SkinData.SkinIndex) and (DefManager.gd[SkinData.SkinIndex].Props[min(State, 1)].Transparency = 0) then begin
    if (SkinData.HUEOffset <> 0) then ChangeBmpHUE(ItemBmp, SkinData.HUEOffset);
    if (SkinData.Saturation <> 0) then ChangeBmpSaturation(ItemBmp, SkinData.Saturation);
  end;
end;

procedure PaintSkinControl(const SkinData : TsCommonData; const Parent : TControl; const Filling : boolean; State : integer; const R : TRect; const pP : TPoint; const ItemBmp : TBitmap; const UpdateCorners : boolean; const OffsetX : integer = 0; const OffsetY : integer = 0);
var
  BG : TacBGInfo;
  CI : TCacheInfo;
begin
  if (ItemBmp = nil) or not Assigned(SkinData.SkinManager) or not SkinData.SkinManager.IsValidSkinIndex(SkinData.SkinIndex) or
    (R.Bottom > ItemBmp.Height) or (R.Right > ItemBmp.Width) or (R.Left < 0) or (R.Top < 0) then Exit;

  if State >= SkinData.SkinManager.gd[SkinData.SkinIndex].States then State := SkinData.SkinManager.gd[SkinData.SkinIndex].States - 1;
  BG.PleaseDraw := False;
  GetBGInfo(@BG, Parent);
  CI := BGInfoToCI(@BG);

  PaintItemBG(SkinData, ci, State, R, pP, ItemBmp, OffsetX, OffsetY);
  inc(ci.X, pP.X);
  inc(ci.Y, pP.Y);
  if Assigned(SkinData.SkinManager) and SkinData.SkinManager.IsValidImgIndex(SkinData.BorderIndex) and not ((State = 0) and (SkinData.SkinManager.ma[SkinData.BorderIndex].DrawMode and BDM_ACTIVEONLY = BDM_ACTIVEONLY))
    then DrawSkinRect(ItemBmp, R, True{Filling}, ci, SkinData.SkinManager.ma[SkinData.BorderIndex], State, UpdateCorners);

  with TsSkinManager(SkinData.SkinManager).gd[SkinData.SkinIndex] do begin
    if ImgTL > -1 then DrawSkinGlyph(ItemBmp, Point(R.Left, R.Top), State, 1, TsSkinManager(SkinData.SkinManager).ma[ImgTL], MakeCacheInfo(ItemBmp));
    if ImgTR > -1 then DrawSkinGlyph(ItemBmp, Point(R.Right - WidthOfImage(TsSkinManager(SkinData.SkinManager).ma[ImgTR]), R.Top), State, 1, TsSkinManager(SkinData.SkinManager).ma[ImgTR], MakeCacheInfo(ItemBmp));
    if ImgBL > -1 then DrawSkinGlyph(ItemBmp, Point(0, R.Bottom - HeightOfImage(TsSkinManager(SkinData.SkinManager).ma[ImgBL])), State, 1, TsSkinManager(SkinData.SkinManager).ma[ImgBL], MakeCacheInfo(ItemBmp));
    if ImgBR > -1 then DrawSkinGlyph(ItemBmp, Point(R.Right - WidthOfImage(TsSkinManager(SkinData.SkinManager).ma[ImgBR]), R.Bottom - HeightOfImage(TsSkinManager(SkinData.SkinManager).ma[ImgBR])), State, 1, TsSkinManager(SkinData.SkinManager).ma[ImgBR], MakeCacheInfo(ItemBmp));
  end;
end;

procedure CopyChannel32(const DstBmp, SrcBmp : TBitmap; const Channel : integer);
var
  Dst, Src : PByteArray;
  X, Y : integer;
begin
  for Y := 0 to DstBmp.Height - 1 do begin
    Dst := DstBmp.ScanLine[Y];
    Src := SrcBmp.ScanLine[Y];
    for X := 0 to DstBmp.Width - 1 do Dst[X * 4 + Channel] := Src[X * 4 + Channel];
  end;
end;

procedure CopyChannel(const Bmp32, Bmp8 : TBitmap; const Channel : integer; const From32To8 : boolean);
var
  Dst, Src : PByteArray;
  X, Y : integer;
begin
  if From32To8 then for Y := 0 to Bmp32.Height - 1 do begin
    Dst := Bmp8.ScanLine[Y];
    Src := Bmp32.ScanLine[Y];
    for X := 0 to Bmp32.Width - 1 do begin
      Dst[X] := Src[X * 4 + Channel];
    end;
  end
  else for Y := 0 to Bmp32.Height - 1 do begin
    Dst := Bmp32.ScanLine[Y];
    Src := Bmp8.ScanLine[Y];
    for X := 0 to Bmp32.Width - 1 do Dst[X * 4 + Channel] := Src[X];
  end;
end;

procedure PaintControlByTemplate(const DstBmp, SrcBmp : TBitmap; const DstRect, SrcRect, BorderWidths, BorderMaxWidths : TRect; const DrawModes : TRect; const StretchCenter : boolean; FillCenter : boolean = True);//TacBorderDrawModes);
var
  X, Y, w, h, i : integer;
  dl, dr, dt, db : integer;
begin
  dl := min(BorderWidths.Left, BorderMaxWidths.Left);
  dr := min(BorderWidths.Right, BorderMaxWidths.Right);
  dt := min(BorderWidths.Top, BorderMaxWidths.Top);
  db := min(BorderWidths.Bottom, BorderMaxWidths.Bottom);
  SetStretchBltMode(DstBmp.Canvas.Handle, COLORONCOLOR);//BLACKONWHITE);
  // Copy corners
  BitBlt(DstBmp.Canvas.Handle, DstRect.Left, DstRect.Top, BorderWidths.Left, dt,    // LeftTop
    SrcBmp.Canvas.Handle, SrcRect.Left, SrcRect.Top, SRCCOPY);
  if dt <> BorderWidths.Top then BitBlt(DstBmp.Canvas.Handle, DstRect.Left, DstRect.Top + dt, dl, BorderWidths.Top - dt,
    SrcBmp.Canvas.Handle, SrcRect.Left, SrcRect.Top + dt, SRCCOPY);

  BitBlt(DstBmp.Canvas.Handle, DstRect.Left, DstRect.Bottom - db, BorderWidths.Left, db, // LeftBottom
    SrcBmp.Canvas.Handle, SrcRect.Left, SrcRect.Bottom - db, SRCCOPY);
  if db <> BorderWidths.Bottom then BitBlt(DstBmp.Canvas.Handle, DstRect.Left, DstRect.Bottom - BorderWidths.Bottom, dl, BorderWidths.Bottom - db,
    SrcBmp.Canvas.Handle, SrcRect.Left, SrcRect.Bottom - BorderWidths.Bottom, SRCCOPY);

  BitBlt(DstBmp.Canvas.Handle, DstRect.Right - BorderWidths.Right, DstRect.Top, BorderWidths.Right, dt,      // RightTop
         SrcBmp.Canvas.Handle, SrcRect.Right - BorderWidths.Right, SrcRect.Top, SRCCOPY);
  if dt <> BorderWidths.Top then BitBlt(DstBmp.Canvas.Handle, DstRect.Right - dr, DstRect.Top + dt, dr, BorderWidths.Top - dt,
         SrcBmp.Canvas.Handle, SrcRect.Right - dr, SrcRect.Top + dt, SRCCOPY);

  BitBlt(DstBmp.Canvas.Handle, DstRect.Right - BorderWidths.Right, DstRect.Bottom - db, BorderWidths.Right, db, // RightBottom
         SrcBmp.Canvas.Handle, SrcRect.Right - BorderWidths.Right, SrcRect.Bottom - db, SRCCOPY);
  if BorderWidths.Right <> db then BitBlt(DstBmp.Canvas.Handle, DstRect.Right - dr, DstRect.Bottom - BorderWidths.Bottom, dr, BorderWidths.Bottom - db,
         SrcBmp.Canvas.Handle, SrcRect.Right - dr, SrcRect.Bottom - BorderWidths.Bottom, SRCCOPY);

  w := max(0, WidthOf(SrcRect, True) - BorderWidths.Right - BorderWidths.Left);
  h := max(0, HeightOf(SrcRect, True) - BorderWidths.Bottom - BorderWidths.Top);
  // Left border
  case DrawModes.Left of
    0 : if (h <> 0) then begin
      X := DstRect.Left;
      Y := DstRect.Top + BorderWidths.Top;
      while Y < DstRect.Bottom - BorderWidths.Bottom - h do begin
        BitBlt(DstBmp.Canvas.Handle, X, Y, dl, h, SrcBmp.Canvas.Handle, SrcRect.Left, SrcRect.Top + BorderWidths.Top, SRCCOPY);
        inc(Y, h);
      end;
      if Y < DstRect.Bottom - BorderWidths.Bottom then begin
        BitBlt(DstBmp.Canvas.Handle, X, Y, dl, DstRect.Bottom - BorderWidths.Bottom - Y, SrcBmp.Canvas.Handle, SrcRect.Left, SrcRect.Top + BorderWidths.Top, SRCCOPY);
      end;
    end;
    1 : begin
      i := SrcRect.Bottom - SrcRect.Top - BorderWidths.Top - BorderWidths.Bottom;
      StretchBlt(DstBmp.Canvas.Handle, DstRect.Left, DstRect.Top + BorderWidths.Top, dl, DstRect.Bottom - DstRect.Top - BorderWidths.Top - BorderWidths.Bottom,
                 SrcBmp.Canvas.Handle, SrcRect.Left, SrcRect.Top + BorderWidths.Top, dl, i, SRCCOPY);
    end;
  end;
  // Top border
  case DrawModes.Top of
    0 : if (w <> 0) then begin
      X := DstRect.Left + BorderWidths.Left;
      Y := DstRect.Top;
      while X < DstRect.Right - BorderWidths.Right - w do begin
        BitBlt(DstBmp.Canvas.Handle, X, Y, w, dt, SrcBmp.Canvas.Handle, SrcRect.Left + BorderWidths.Left, SrcRect.Top, SRCCOPY);
        inc(X, w);
      end;
      if X < DstRect.Right - BorderWidths.Right then begin
        BitBlt(DstBmp.Canvas.Handle, X, Y, DstRect.Right - BorderWidths.Right - X, dt, SrcBmp.Canvas.Handle, SrcRect.Left + BorderWidths.Left, SrcRect.Top, SRCCOPY);
      end;
    end;
    1 : begin
      StretchBlt(DstBmp.Canvas.Handle, DstRect.Left + BorderWidths.Left, DstRect.Top, DstRect.Right - DstRect.Top - BorderWidths.Left - BorderWidths.Right, dt,
                 SrcBmp.Canvas.Handle, SrcRect.Left + BorderWidths.Left, SrcRect.Top, SrcRect.Right - SrcRect.Top - BorderWidths.Left - BorderWidths.Right, dt, SRCCOPY);
    end;
  end;
  // Right border
  case DrawModes.Right of
    0 : if (h <> 0) then begin
      X := DstRect.Right - dr;
      Y := DstRect.Top + BorderWidths.Top;
      while Y < DstRect.Bottom - BorderWidths.Bottom - h do begin
        BitBlt(DstBmp.Canvas.Handle, X, Y, dr, h, SrcBmp.Canvas.Handle, SrcRect.Right - dr, SrcRect.Top + BorderWidths.Top, SRCCOPY);
        inc(Y, h);
      end;
      if Y < DstRect.Bottom - BorderWidths.Bottom then begin
        BitBlt(DstBmp.Canvas.Handle, X, Y, dr, DstRect.Bottom - BorderWidths.Bottom - Y, SrcBmp.Canvas.Handle, SrcRect.Right - dr, SrcRect.Top + BorderWidths.Top, SRCCOPY);
      end;
    end;
    1 : begin
      StretchBlt(DstBmp.Canvas.Handle, DstRect.Right - dr, DstRect.Top + BorderWidths.Top, dr, DstRect.Bottom - DstRect.Top - BorderWidths.Bottom - BorderWidths.Top,
                 SrcBmp.Canvas.Handle, SrcRect.Right - dr, SrcRect.Top + BorderWidths.Top, dr, SrcRect.Bottom - SrcRect.Top - BorderWidths.Bottom - BorderWidths.Top, SRCCOPY);
    end;
  end;
  // Bottom border
  case DrawModes.Bottom of
    0 : if (w <> 0) then begin
      X := DstRect.Left + BorderWidths.Left;
      Y := DstRect.Bottom - db;
      while X < DstRect.Right - BorderWidths.Right - w do begin
        BitBlt(DstBmp.Canvas.Handle, X, Y, w, db, SrcBmp.Canvas.Handle, SrcRect.Left + BorderWidths.Left, SrcRect.Bottom - db, SRCCOPY);
        inc(X, w);
      end;
      if X < DstRect.Right - BorderWidths.Right then begin
        BitBlt(DstBmp.Canvas.Handle, X, Y, DstRect.Right - BorderWidths.Right - X, db, SrcBmp.Canvas.Handle, SrcRect.Left + BorderWidths.Left, SrcRect.Bottom - db, SRCCOPY);
      end;
    end;
    1 : begin
      StretchBlt(DstBmp.Canvas.Handle, DstRect.Left + BorderWidths.Left, DstRect.Bottom - db, DstRect.Right - DstRect.Left - BorderWidths.Right - BorderWidths.Left, db,
                 SrcBmp.Canvas.Handle, SrcRect.Left + BorderWidths.Left, SrcRect.Bottom - db, SrcRect.Right - SrcRect.Left - BorderWidths.Right - BorderWidths.Left, db, SRCCOPY);
    end;
  end;
  // Center
  if FillCenter then begin
    case StretchCenter of
      False : if (h <> 0) and (w <> 0) then begin
        X := DstRect.Left + BorderWidths.Left;
        while X < DstRect.Right - BorderWidths.Right - w do begin
          Y := DstRect.Top + BorderWidths.Top;
          while Y < DstRect.Bottom - BorderWidths.Bottom - h do begin
            BitBlt(DstBmp.Canvas.Handle, X, Y, w, h, SrcBmp.Canvas.Handle, SrcRect.Left + BorderWidths.Left, SrcRect.Top + BorderWidths.Top, SRCCOPY);
            inc(Y, h);
          end;
          if Y < DstRect.Bottom - BorderWidths.Bottom then begin
            BitBlt(DstBmp.Canvas.Handle, X, Y, w, DstRect.Bottom - BorderWidths.Bottom - Y, SrcBmp.Canvas.Handle, SrcRect.Left + BorderWidths.Left, SrcRect.Top + BorderWidths.Top, SRCCOPY);
          end;
          inc(X, w);
        end;
        if X < DstRect.Right - BorderWidths.Right then begin
          Y := DstRect.Top + BorderWidths.Top;
          while Y < DstRect.Bottom - BorderWidths.Bottom - h do begin
            BitBlt(DstBmp.Canvas.Handle, X, Y, DstRect.Right - BorderWidths.Right - X, h, SrcBmp.Canvas.Handle, SrcRect.Left + BorderWidths.Left, SrcRect.Top + BorderWidths.Top, SRCCOPY);
            inc(Y, h);
          end;
          if Y < DstRect.Bottom - BorderWidths.Bottom then begin
            BitBlt(DstBmp.Canvas.Handle, X, Y, DstRect.Right - BorderWidths.Right - X, DstRect.Bottom - BorderWidths.Bottom - Y, SrcBmp.Canvas.Handle, SrcRect.Left + BorderWidths.Left, SrcRect.Top + BorderWidths.Top, SRCCOPY);
          end;
        end;
      end;
      True : begin
        StretchBlt(DstBmp.Canvas.Handle, DstRect.Left + BorderWidths.Left, DstRect.Top + BorderWidths.Top, DstRect.Right - DstRect.Left - BorderWidths.Right - BorderWidths.Left, DstRect.Bottom - DstRect.Top - BorderWidths.Bottom - BorderWidths.Top,
                   SrcBmp.Canvas.Handle, SrcRect.Left + BorderWidths.Left, SrcRect.Top + BorderWidths.Top, SrcRect.Right - SrcRect.Left - BorderWidths.Right - BorderWidths.Left, SrcRect.Bottom - SrcRect.Top - BorderWidths.Bottom - BorderWidths.Top, SRCCOPY);
      end;
    end;
  end;
end;

procedure DrawGlyphEx(Glyph, DstBmp : TBitmap; R : TRect; NumGlyphs : integer; Enabled : boolean; DisabledGlyphKind : TsDisabledGlyphKind; State, Blend : integer; Down : boolean = False; Reflected : boolean = False);
var
  Bmp, TmpGlyph : TBitmap;
  MaskColor: TsColor;
  w, GlyphIndex : integer;
  CI : TCacheInfo;
begin
  GlyphIndex := -1;
  TmpGlyph := TBitmap.Create;
  TmpGlyph.Assign(Glyph);
  TmpGlyph.PixelFormat := pf32bit;
  case NumGlyphs of
    1 : begin
      Bmp := TBitmap.Create;
      Bmp.Assign(TmpGlyph);
      Bmp.PixelFormat := pf32bit;
      MaskColor.C := Bmp.Canvas.Pixels[0, Bmp.Height - 1];
      try if not Enabled then begin
        if dgGrayed in DisabledGlyphKind then GrayScale(Bmp);
        MaskColor.C := Bmp.Canvas.Pixels[0, Bmp.Height - 1];
        if dgBlended in DisabledGlyphKind
          then BlendTransRectangle(DstBmp, R.Left, R.Top, Bmp, Rect(0, 0, WidthOf(R, True), HeightOf(R, True)), 0.5, MaskColor.C)
          else CopyTransBitmaps(DstBmp, Bmp, R.Left, R.Top, MaskColor);
      end
      else begin
        if (State = 0) and (Blend > 0)
          then BlendTransRectangle(DstBmp, R.Left, R.Top, Bmp, Rect(0, 0, WidthOf(R, True), HeightOf(R, True)), Blend / 100)
          else CopyTransBitmaps(DstBmp, Bmp, R.Left, R.Top, MaskColor);
      end;
      finally
        FreeAndNil(Bmp);
      end;
    end
    else begin
      if not Enabled then GlyphIndex := 0 else begin
        case State of
          0 : GlyphIndex := 0;
          1 : if (Glyph.PixelFormat = pf4bit) or acOldGlyphsOrder then GlyphIndex := 0 else GlyphIndex := 1;
          2 : if NumGlyphs > 2 + integer(Down) then GlyphIndex := 2 + integer(Down) else begin
            if (Glyph.PixelFormat = pf4bit) or acOldGlyphsOrder then GlyphIndex := 0 else GlyphIndex := min(1, NumGlyphs - 1);
          end;
        end;
      end;
      w := TmpGlyph.Width div NumGlyphs;
      CI := MakeCacheInfo(DstBmp);
      if Enabled {or (Glyph.PixelFormat = pf4bit) }then begin
        CopyTransRectA(DstBmp, TmpGlyph, R.Left, R.Top, Rect(w * GlyphIndex, 0, (GlyphIndex + 1) * w - 1, TmpGlyph.Height - 1), TmpGlyph.Canvas.Pixels[GlyphIndex * w, TmpGlyph.Height - 1], CI);
      end
      else begin
        if (State = 0) and (Blend > 0) then begin
          MaskColor := TsColor(TmpGlyph.Canvas.Pixels[0, TmpGlyph.Height - 1]);
          BlendTransRectangle(DstBmp, R.Left, R.Top, TmpGlyph, Rect(w * GlyphIndex, 0, (GlyphIndex + 1) * w - 1, TmpGlyph.Height - 1), Blend / 100);
        end
        else begin
          CopyTransRectA(DstBmp, TmpGlyph, R.Left, R.Top, Rect(w * GlyphIndex, 0, (GlyphIndex + 1) * w - 1, TmpGlyph.Height - 1), TmpGlyph.Canvas.Pixels[0, TmpGlyph.Height - 1], CI);
        end;
      end;
    end;
  end;
  FreeAndNil(TmpGlyph);
end;
{$ENDIF}

procedure FillDC(DC: HDC; const aRect: TRect; const Color: TColor);
var
  OldBrush, NewBrush : hBrush;
  SavedDC : hdc;
begin
  SavedDC := SaveDC(DC);
  NewBrush := CreateSolidBrush(Cardinal(ColorToRGB(Color)));
  OldBrush := SelectObject(dc, NewBrush);
  try
    FillRect(DC, aRect, NewBrush);
  finally
    SelectObject(dc, OldBrush);
    DeleteObject(NewBrush);
    RestoreDC(DC, SavedDC);
  end;
end;

procedure FillDCBorder(const DC: HDC; const aRect: TRect; const wl, wt, wr, wb : integer; const Color: TColor);
var
  OldBrush, NewBrush : hBrush;
  SavedDC : hWnd;
begin
  SavedDC := SaveDC(DC);
  NewBrush := CreateSolidBrush(Cardinal(ColorToRGB(Color)));
  OldBrush := SelectObject(dc, NewBrush);
  try
    FillRect(DC, Rect(aRect.Left, aRect.Top, aRect.Right, aRect.Top + wt), NewBrush);
    FillRect(DC, Rect(aRect.Left, aRect.Top + wt, aRect.Left + wl, aRect.Bottom), NewBrush);
    FillRect(DC, Rect(aRect.Left + wl, aRect.Bottom - wb, aRect.Right, aRect.Bottom), NewBrush);
    FillRect(DC, Rect(aRect.Right - wr, aRect.Top + wt, aRect.Right, aRect.Bottom - wb), NewBrush);
  finally
    SelectObject(dc, OldBrush);
    DeleteObject(NewBrush);
    RestoreDC(DC, SavedDC);
  end;
end;

procedure BitBltBorder(const DestDC: HDC; const X, Y, Width, Height: Integer; const SrcDC: HDC; const XSrc, YSrc: Integer; const BorderWidth : integer);
begin
  BitBlt(DestDC, X, Y, BorderWidth, Height, SrcDC, XSrc, YSrc, SRCCOPY);
  BitBlt(DestDC, X + BorderWidth, Y, Width, BorderWidth, SrcDC, XSrc + BorderWidth, YSrc, SRCCOPY);
  BitBlt(DestDC, Width - BorderWidth, Y + BorderWidth, Width, Height, SrcDC, XSrc + Width - BorderWidth, YSrc + BorderWidth, SRCCOPY);
  BitBlt(DestDC, X + BorderWidth, Height - BorderWidth, Width - BorderWidth, Height, SrcDC, XSrc + BorderWidth, YSrc + Height - BorderWidth, SRCCOPY);
end;

procedure ExcludeControls(const DC : hdc; const Ctrl : TWinControl; const CtrlType : TacCtrlType; const OffsetX : integer; const OffsetY : integer);
var
  i : integer;
  Child : TControl;
begin
  for i := 0 to Ctrl.ControlCount - 1 do begin
    Child := Ctrl.Controls[i];
    if (Child is TGraphicControl) and StdTransparency {$IFNDEF ALITE} or (Child is TsSplitter) {$ENDIF} then Continue;
    if Child.Visible then if (Child is TGraphicControl)
      then ExcludeClipRect(DC, Child.Left + OffsetX, Child.Top + OffsetY, Child.Left + Child.Width + OffsetX, Child.Top + Child.Height + OffsetY);
  end;
end;

procedure GrayScale(Bmp: TBitmap);
var
  SA : PRGBAArray;
  x, y, w, h : integer;
begin
  h := Bmp.Height - 1;
  w := Bmp.Width - 1;
  for y := 0 to h do begin
    SA := Bmp.scanline[y];
    for x := 0 to w do begin
      SA[x].R := (SA[x].R + SA[x].G + SA[x].B) div 3;
      SA[x].G := SA[x].R;
      SA[x].B := SA[x].R;
    end
  end;
end;

procedure GrayScaleTrans(Bmp: TBitmap; const TransColor : TsColor);
var
  S1 : PRGBAArray;
  x, y, w, h : integer;
  InvColor : TsColor_;
begin
  h := Bmp.Height - 1;
  w := Bmp.Width - 1;
  InvColor.C := TransColor.C;
  InvColor.R := TransColor.B;
  InvColor.B := TransColor.R;
  for Y := 0 to h do begin
    S1 := Bmp.ScanLine[Y];
    for X := 0 to w do if (S1[X].C <> InvColor.C) then begin
      S1[X].R := (S1[X].R + S1[X].G + S1[X].B) div 3;
      S1[X].G := S1[X].R;
      S1[X].B := S1[X].R
    end
  end;
end;

procedure ChangeBmpHUE(const Bmp: TBitmap; const Value : integer);
var
  S1 : PRGBAArray;
  w, h, x, y : integer;
begin
  if Assigned(Bmp) then begin
    h := Bmp.Height - 1;
    w := Bmp.Width - 1;
    for y := 0 to h do begin
      S1 := Bmp.ScanLine[y];
      for x := 0 to w do begin
        if (S1[X].C = clFuchsia) or ((S1[X].R = S1[X].G) and (S1[X].R = S1[X].B)) then Continue;
        S1[X] := ChangeHue(Value, S1[X]);
      end
    end;
  end;
end;

procedure ChangeBmpSaturation(const Bmp: TBitmap; const Value : integer);
var
  S1 : PRGBAArray;
  w, h, x, y : integer;
begin
  if Assigned(Bmp) then begin
    h := Bmp.Height - 1;
    w := Bmp.Width - 1;
    for y := 0 to h do begin
      S1 := Bmp.ScanLine[y];
      for x := 0 to w do begin
        if (S1[X].C = clFuchsia) or ((S1[X].R = S1[X].G) and (S1[X].R = S1[X].B)) then Continue;
        S1[X] := ChangeSaturation(Value, S1[X]);
      end
    end;
  end;
end;

function CutText(Canvas: TCanvas; const Text: acString; MaxLength : integer): acString;
begin
  if MaxLength < 1 then Result := '' else Result := Text;
  if (Canvas.TextWidth(Result) > MaxLength) and (Result <> '') then begin
    while (Result <> '') and (Canvas.TextWidth(Result + '...') > MaxLength) do Delete(Result, Length(Result), 1);
    if Result <> '' then Result := Result + '...';
  end;
end;

procedure WriteText(Canvas: TCanvas; Text: PChar; Enabled: boolean; var aRect : TRect; Flags: Cardinal);
var
  R, Rd: TRect;
  x, y : integer;
  ts: TSize;
begin
  R := aRect;
  if Flags or DT_WORDBREAK <> Flags then begin // If not multiline
    GetTextExtentPoint32(Canvas.Handle, Text, Length(Text), ts);
    R.Right := R.Left + ts.cx;
    R.Bottom := R.Top + ts.cy;
    if Flags or DT_CENTER = Flags then begin
      y := (HeightOf(R) - HeightOf(aRect)) div 2;
      x := (WidthOf(R, True) - WidthOf(aRect, True)) div 2;
      InflateRect(aRect, x, y);
    end
    else if Flags or DT_RIGHT = Flags then begin
      y := (HeightOf(R) - HeightOf(aRect)) div 2;
      dec(aRect.Top, y);
      inc(aRect.Bottom, y);
      inc(aRect.Left, WidthOf(aRect, True) - WidthOf(R, True));
    end
    else if Flags or DT_LEFT = Flags then begin
      y := (HeightOf(R) - HeightOf(aRect)) div 2;
      dec(aRect.Top, y);
      inc(aRect.Bottom, y);
      inc(aRect.Right, WidthOf(R) - WidthOf(aRect));
    end;                                                
    R := aRect;
    InflateRect(aRect, 1, 1);
  end;                                                  
  Canvas.Brush.Style := bsClear;
  if Text <> ''then
  if Enabled then begin
    DrawText(Canvas.Handle, Text, Length(Text), R, Flags);
  end
  else begin
    Rd := Rect(R.Left + 1, R.Top + 1, R.Right + 1, R.Bottom + 1);
    Canvas.Font.Color := ColorToRGB(clBtnHighlight);
    DrawText(Canvas.Handle, Text, Length(Text), Rd, Flags);

    Canvas.Font.Color := ColorToRGB(clBtnShadow);
    DrawText(Canvas.Handle, Text, Length(Text), R, Flags);
  end;
end;

procedure WriteTextOnDC(DC: hdc; Text: PChar; Enabled: boolean; var aRect : TRect; Flags: Cardinal);
var
  R, Rd: TRect;
  x, y : integer;
  ts: TSize;
begin
  R := aRect;
  SetBkMode(DC, TRANSPARENT);

  if Flags or DT_WORDBREAK <> Flags then begin // If no multiline

    GetTextExtentPoint32(DC, Text, Length(Text), ts);
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


    R := aRect;
    InflateRect(aRect, 1, 1);
  end;

  if Text <> ''then
  if Enabled then begin
    DrawText(DC, Text, Length(Text), R, Flags);
  end
  else begin
    Rd := Rect(R.Left + 1, R.Top + 1, R.Right + 1, R.Bottom + 1);
    DrawText(DC, Text, Length(Text), Rd, Flags);
    DrawText(DC, Text, Length(Text), R, Flags);
  end;
end;

function acDrawText(hDC: HDC; const Text: ACString; var lpRect: TRect; uFormat: Cardinal): Integer;
begin
{$IFDEF TNTUNICODE}
  Result := Tnt_DrawTextW(hDC, PACChar(Text), Length(Text), lpRect, uFormat);
{$else}
  Result := DrawText(hDC, PACChar(Text), Length(Text), lpRect, uFormat);
{$ENDIF}
end;

function acTextWidth(const Canvas: TCanvas; const Text: ACString): Integer;
begin
{$IFDEF TNTUNICODE}
  Result := WideCanvasTextExtent(Canvas, Text).cx;
{$ELSE}
  Result := Canvas.TextExtent(Text).cx;
{$ENDIF}
end;

function acTextHeight(const Canvas: TCanvas; const Text: ACString): Integer;
begin
{$IFDEF TNTUNICODE}
  Result := WideCanvasTextExtent(Canvas, Text).cy;
{$ELSE}
  Result := Canvas.TextExtent(Text).cy;
{$ENDIF}
end;

function acTextExtent(const Canvas: TCanvas; const Text: ACString): TSize;
begin
{$IFDEF TNTUNICODE}
  Result := WideCanvasTextExtent(Canvas, Text);
{$ELSE}
  Result := Canvas.TextExtent(Text);
{$ENDIF}
end;

procedure acTextRect(const Canvas : TCanvas; const Rect: TRect; X, Y: Integer; const Text: ACString);
begin
{$IFDEF TNTUNICODE}
  WideCanvasTextRect(Canvas, Rect, X, Y, Text);
{$ELSE}
  Canvas.TextRect(Rect, X, Y, Text);
{$ENDIF}
end;

function acGetTextExtent(const DC: HDC; const Str: acString; var Size: TSize): BOOL;
begin
{$IFDEF TNTUNICODE}
  Result := GetTextExtentPoint32W(DC, PWideChar(Str), Length(Str), Size);
{$ELSE}
  Result := GetTextExtentPoint32(DC, PChar(Str), Length(Str), Size);
{$ENDIF}
end;

procedure acDrawGlowForText(const DstBmp: TBitmap; Text: PacChar; aRect : TRect; Flags: Cardinal; Side : Cardinal; BlurSize : integer; Color : TColor; var MaskBmp : TBitmap);
const
  Offs = 4;
  lOffs = 1;
var
  R, lRect, tmpRect : TRect;
  DstLineA : PRGBAArray;
  MaskLine : PByteArray;
  bMask : byte;
  X, Y : integer;
  gColor : TsColor;
  CA : TsColor_;
begin
  R := aRect;
  gColor.C := Color;
  InflateRect(R, BlurSize + Offs, BlurSize + Offs);

  if (MaskBmp = nil) or (MaskBmp.Width <> WidthOf(R)) or (MaskBmp.Height <> HeightOf(R)) then begin

    if MaskBmp = nil then MaskBmp := TBitmap.Create;
    MaskBmp.PixelFormat := pf8bit;
    MaskBmp.Width := WidthOf(R, True);
    MaskBmp.Height := HeightOf(R, True);
    MaskBmp.Canvas.Brush.Color := clWhite;
    MaskBmp.Canvas.FillRect(Rect(0, 0, MaskBmp.Width, MaskBmp.Height));

    MaskBmp.Canvas.Font.Assign(DstBmp.Canvas.Font);
    MaskBmp.Canvas.Font.Color := 0;
    MaskBmp.Canvas.Brush.Style := bsClear;

    lRect := Rect(BlurSize + Offs, BlurSize + Offs, BlurSize + Offs + WidthOf(aRect), BlurSize + Offs + HeightOf(aRect));

    if Side and BF_LEFT = BF_LEFT then begin
      tmpRect := Rect(lRect.Left - lOffs, lRect.Top, lRect.Right - lOffs, lRect.Bottom);
{$IFDEF TNTUNICODE}
      DrawTextW(MaskBmp.Canvas.Handle, Text, Length(Text), tmpRect, Flags);
{$ELSE}
      DrawText(MaskBmp.Canvas.Handle, Text, Length(Text), tmpRect, Flags);
{$ENDIF}
    end;

    if Side and BF_TOP = BF_TOP then begin
      tmpRect := Rect(lRect.Left, lRect.Top - lOffs, lRect.Right, lRect.Bottom - lOffs);
{$IFDEF TNTUNICODE}
      DrawTextW(MaskBmp.Canvas.Handle, Text, Length(Text), tmpRect, Flags);
{$ELSE}
      DrawText(MaskBmp.Canvas.Handle, Text, Length(Text), tmpRect, Flags);
{$ENDIF}
    end;

    if Side and BF_RIGHT = BF_RIGHT then begin
      tmpRect := Rect(lRect.Left + lOffs, lRect.Top, lRect.Right + lOffs, lRect.Bottom);
{$IFDEF TNTUNICODE}
      DrawTextW(MaskBmp.Canvas.Handle, Text, Length(Text), tmpRect, Flags);
{$ELSE}
      DrawText(MaskBmp.Canvas.Handle, Text, Length(Text), tmpRect, Flags);
{$ENDIF}
    end;

    if Side and BF_BOTTOM = BF_BOTTOM then begin
      tmpRect := Rect(lRect.Left, lRect.Top + lOffs, lRect.Right, lRect.Bottom + lOffs);
{$IFDEF TNTUNICODE}
      DrawTextW(MaskBmp.Canvas.Handle, Text, Length(Text), tmpRect, Flags);
{$ELSE}
      DrawText(MaskBmp.Canvas.Handle, Text, Length(Text), tmpRect, Flags);
{$ENDIF}
    end;

    tmpRect := lRect;
{$IFDEF TNTUNICODE}
    DrawTextW(MaskBmp.Canvas.Handle, Text, Length(Text), tmpRect, Flags);
{$ELSE}
    DrawText(MaskBmp.Canvas.Handle, Text, Length(Text), tmpRect, Flags);
{$ENDIF}

    Blur8(MaskBmp, BlurSize);
  end;
  if MaskBmp <> nil then begin
    for Y := 0 to MaskBmp.Height - 1 do begin
      if (aRect.Top + Y - BlurSize - Offs < 0) or (aRect.Top + Y - BlurSize - Offs >= DstBmp.Height) then Continue;
      DstLineA := DstBmp.ScanLine[aRect.Top + Y - BlurSize - Offs];
      MaskLine := MaskBmp.ScanLine[Y];
      for X := 0 to MaskBmp.Width - 1 do if (MaskLine[X] <> MaxByte) then begin
        if (aRect.Left + X - BlurSize - Offs < 0) or (aRect.Left + X - BlurSize - Offs >= DstBmp.Width) then Continue;
        bMask := MaskLine[X];
        CA := DstLineA[aRect.Left + X - BlurSize - Offs];

        CA.R := gColor.R + ((CA.R - gColor.R) * bMask) div MaxByte;
        CA.G := gColor.G + ((CA.G - gColor.G) * bMask) div MaxByte;
        CA.B := gColor.B + ((CA.B - gColor.B) * bMask) div MaxByte;

//        CA.A := CA.A + ((MaxByte - CA.A) * ({MaxByte - }bMask)) div MaxByte;
        CA.A := CA.A + ((MaxByte - CA.A) * (MaxByte - bMask)) div MaxByte;
        DstLineA[aRect.Left + X - BlurSize - Offs] := CA;
      end;
    end;
  end;
end;

procedure MakeGaussianKernel(var K: TKernel; radius: double; MaxData, DataGranularity: double);
var
  j: integer;
  temp, delta: double;
  KernelSize: TKernelSize;
begin
  for j := Low(K.Weights) to High(K.Weights) do begin
    temp := j / radius;
    K.Weights[j] := exp(-temp * temp / 2);
  end;
  temp := 0;
  for j := Low(K.Weights) to High(K.Weights) do temp := temp + K.Weights[j];
  for j := Low(K.Weights) to High(K.Weights) do K.Weights[j] := K.Weights[j] / temp;
  KernelSize := MaxKernelSize;
  delta := DataGranularity / (2 * MaxData);
  temp := 0;
  while (temp < delta) and (KernelSize > 1) do begin
    temp := temp + 2 * K.Weights[KernelSize];
    dec(KernelSize);
  end;
  K.Size := KernelSize;
  temp := 0;
  for j := -K.Size to K.Size do temp := temp + K.Weights[j];
  for j := -K.Size to K.Size do K.Weights[j] := K.Weights[j] / temp;
end;

function TrimInt(Lower, Upper, theInteger: integer): integer;
begin
  if (theInteger <= Upper) and (theInteger >= Lower)
    then result := theInteger
    else if theInteger > Upper then result := Upper else result := Lower;
end;

function TrimReal(Lower, Upper: integer; x: double): integer;
begin
  if (x < upper) and (x >= lower)
    then result := trunc(x)
    else if x > Upper then result := Upper else result := Lower;
end;

procedure BlurRow8(var theRow: array of byte; K: TKernel; P: PByteArray);
var
  j, n: integer;
  d: double;
  w: double;
begin
  for j := 0 to High(theRow) do begin
    d := 0;
    for n := -K.Size to K.Size do begin
      w := K.Weights[n];
      d := d + w * theRow[TrimInt(0, High(theRow), j - n)];
    end;
    P[j] := TrimReal(0, MaxByte, d);
  end;
  Move(P[0], theRow[0], (High(theRow) + 1));
end;

procedure Blur8(theBitmap: TBitmap; radius: double);
var
  Row, Col: integer;
  theRows: PByteArrays;
  K: TKernel;
  ACol: PByteArray;
  P: PByteArray;
begin
  if (theBitmap.HandleType <> bmDIB) or (theBitmap.PixelFormat <> pf8Bit) then Exit;
  MakeGaussianKernel(K, radius, MaxByte, 1);
  GetMem(theRows, theBitmap.Height * SizeOf(PByteArrays));
  GetMem(ACol, theBitmap.Height);
  for Row := 0 to theBitmap.Height - 1 do theRows[Row] := theBitmap.Scanline[Row];
  P := AllocMem(theBitmap.Width);
  for Row := 0 to theBitmap.Height - 1 do BlurRow8(Slice(theRows[Row]^, theBitmap.Width), K, P);
  ReAllocMem(P, theBitmap.Height);
  for Col := 0 to theBitmap.Width - 1 do begin
    for Row := 0 to theBitmap.Height - 1 do ACol[Row] := theRows[Row][Col];
    BlurRow8(Slice(ACol^, theBitmap.Height), K, P);
    for Row := 0 to theBitmap.Height - 1 do theRows[Row][Col] := ACol[Row];
  end;
  FreeMem(theRows);
  FreeMem(ACol);
  ReAllocMem(P, 0);
end;

procedure acWriteTextEx(const Canvas: TCanvas; Text: PacChar; Enabled: boolean; var aRect : TRect; Flags: Cardinal; SkinData : TsCommonData; Hot : boolean; SkinManager : TObject = nil);
begin
{$IFDEF TNTUNICODE}
  WriteTextExW(Canvas, Text, Enabled, aRect, Flags, SkinData, Hot);
{$ELSE}
  WriteTextEx(Canvas, Text, Enabled, aRect, Flags, SkinData, Hot);
{$ENDIF}
end;

procedure acWriteTextEx(const Canvas: TCanvas; Text: PacChar; Enabled: boolean; var aRect : TRect; Flags: Cardinal; SkinIndex : integer; Hot : boolean; SkinManager : TObject = nil);
begin
{$IFDEF TNTUNICODE}
  WriteTextExW(Canvas, Text, Enabled, aRect, Flags, SkinIndex, Hot, SkinManager);
{$ELSE}
  WriteTextEx(Canvas, Text, Enabled, aRect, Flags, SkinIndex, Hot, SkinManager);
{$ENDIF}
end;

procedure acWriteText(const Canvas: TCanvas; Text: PacChar; Enabled: boolean; var aRect : TRect; Flags: Cardinal);
begin
{$IFDEF TNTUNICODE}
  DrawTextW(Canvas.Handle, Text, Length(Text), aRect, Flags);
{$ELSE}
  DrawText(Canvas.Handle, Text, Length(Text), aRect, Flags);
{$ENDIF}
end;

{$IFNDEF ACHINTS}
procedure WriteTextEx(const Canvas: TCanvas; Text: PChar; Enabled: boolean; var aRect : TRect; Flags: Cardinal; SkinIndex : integer; Hot : boolean; SkinManager : TObject = nil); overload;
var
  R, Rd: TRect;
  nLength: Integer;
  C : TColor;
  State : integer;
begin
  if (Text <> '') then begin
    nLength := StrLen(Text);
    if SkinManager = nil then SkinManager := DefaultManager;
    if not Assigned(SkinManager) or not TsSkinManager(SkinManager).IsValidSkinIndex(SkinIndex) then Exit;
    with TsSkinManager(SkinManager) do begin
      SetBkMode(Canvas.Handle, TRANSPARENT);
      R := aRect;
      if Enabled then begin
        State := integer(Hot);
        if IsValidSkinIndex(SkinIndex) then begin
          // Left
          C := TsSkinManager(SkinManager).gd[SkinIndex].Props[State].FontColor.Left;
          if C <> -1 then begin
            Rd := Rect(R.Left - 1, R.Top, R.Right - 1, R.Bottom);
            SetTextColor(Canvas.Handle, Cardinal(C));
            DrawText(Canvas.Handle, Text, nLength, Rd, Flags);
          end;
          // Top
          C := gd[SkinIndex].Props[State].FontColor.Top;
          if C <> -1 then begin
            Rd := Rect(R.Left, R.Top - 1, R.Right, R.Bottom - 1);
            SetTextColor(Canvas.Handle, Cardinal(C));
            DrawText(Canvas.Handle, Text, nLength, Rd, Flags);
          end;
          // Right
          C := gd[SkinIndex].Props[State].FontColor.Right;
          if C <> -1 then begin
            Rd := Rect(R.Left + 1, R.Top, R.Right + 1, R.Bottom);
            SetTextColor(Canvas.Handle, Cardinal(C));
            DrawText(Canvas.Handle, Text, nLength, Rd, Flags);
          end;
          // Bottom
          C := gd[SkinIndex].Props[State].FontColor.Bottom;
          if C <> -1 then begin
            Rd := Rect(R.Left, R.Top + 1, R.Right, R.Bottom + 1);
            SetTextColor(Canvas.Handle, Cardinal(C));
            DrawText(Canvas.Handle, Text, nLength, Rd, Flags);
          end;
          // Center
          C := gd[SkinIndex].Props[State].FontColor.Color;
          SetTextColor(Canvas.Handle, Cardinal(C));
          DrawText(Canvas.Handle, Text, nLength, R, Flags);
        end
        else DrawText(Canvas.Handle, Text, nLength, R, Flags);
      end
      else begin
        Rd := R;
        Canvas.Font.Color := MixColors(gd[SkinIndex].Props[0].FontColor.Color, gd[SkinIndex].Color, DefDisabledBlend);
        DrawText(Canvas.Handle, Text, nLength, Rd, Flags);
      end;
    end;
  end;
end;
{$ENDIF}

procedure WriteTextEx(const Canvas: TCanvas; Text: PChar; Enabled: boolean; var aRect : TRect; Flags: Cardinal; SkinData : TsCommonData; Hot : boolean); overload;
var
  R, Rd: TRect;
  SavedDC : hdc;
  nLength : Integer;
  SkinIndex : integer;
  i : integer;
  FGlowMask : TBitmap;
  C : TColor;
  State : integer;
begin
  if Text <> '' then begin
    nLength := StrLen(Text);
    R := aRect;
    if Hot and (SkinData.SkinSection = s_WebBtn) then Canvas.Font.Style := Canvas.Font.Style + [fsUnderline];
    SavedDC := SaveDC(Canvas.Handle);
    try
      IntersectClipRect(Canvas.Handle, aRect.Left, aRect.Top, aRect.Right, aRect.Bottom);
      Canvas.Brush.Style := bsClear;
      if SkinData.Skinned and not SkinData.CustomFont then begin
        if Hot then State := 1 else State := 0;
        if (SkinData.FOwnerControl <> nil) and ((SkinData.COC in [COC_TsGroupBox, COC_TsCheckBox, COC_TsRadioButton]) or (SkinData.FOwnerControl is TGraphicControl)) and
              TsHackedControl(SkinData.FOwnerControl).ParentFont and (SkinData.FOwnerControl.Parent <> nil) then begin
          if SkinData.SkinManager.gd[SkinData.SkinIndex].Props[State].Transparency > 0
            then SkinIndex := GetFontIndex(SkinData.FOwnerControl, SkinData.SkinIndex, SkinData.SkinManager)
            else SkinIndex := SkinData.SkinIndex;
        end
        else SkinIndex := SkinData.SkinIndex;
        Canvas.Brush.Style := bsClear;
        if SkinData.SkinManager.IsValidSkinIndex(SkinIndex) then begin
          if SkinData.FCacheBmp <> nil then begin
            i := SkinData.SkinManager.gd[SkinIndex].Props[State].GlowSize;
            if i <> 0 then begin
              FGlowMask := nil;
              C := SkinData.SkinManager.gd[SkinIndex].Props[State].GlowColor;
              if SkinData.HUEOffset <> 0 then C := ChangeHUE(SkinData.HUEOffset, C);
              if SkinData.Saturation <> 0 then C := ChangeSaturation(C, SkinData.Saturation);
              acDrawGlowForText(SkinData.FCacheBmp, PacChar(Text), R, Flags, BF_LEFT or BF_TOP or BF_BOTTOM or BF_RIGHT, i, C, FGlowMask);
              FreeAndNil(FGlowMask);
            end;
          end;

          if Enabled then begin
            // Left contour
            if not SkinData.CustomFont then begin
              if SkinData.SkinManager.gd[SkinIndex].Props[State].FontColor.Left <> -1 then begin
                C := ChangeSaturation(ChangeHUE(SkinData.HUEOffset, SkinData.SkinManager.gd[SkinIndex].Props[State].FontColor.Left), SkinData.Saturation);
                Rd := Rect(R.Left - 1, R.Top, R.Right - 1, R.Bottom);
                SetTextColor(Canvas.Handle, C);
                DrawText(Canvas.Handle, Text, nLength, Rd, Flags);
              end;
              // Top
              if SkinData.SkinManager.gd[SkinIndex].Props[State].FontColor.Top <> -1 then begin
                C := ChangeSaturation(ChangeHUE(SkinData.HUEOffset, SkinData.SkinManager.gd[SkinIndex].Props[State].FontColor.Top), SkinData.Saturation);
                Rd := Rect(R.Left, R.Top - 1, R.Right, R.Bottom - 1);
                SetTextColor(Canvas.Handle, C);
                DrawText(Canvas.Handle, Text, nLength, Rd, Flags);
              end;
              // Right
              if SkinData.SkinManager.gd[SkinIndex].Props[State].FontColor.Right <> -1 then begin
                C := ColortoRGB(ChangeSaturation(ChangeHUE(SkinData.HUEOffset, SkinData.SkinManager.gd[SkinIndex].Props[State].FontColor.Right), SkinData.Saturation));
                Rd := Rect(R.Left + 1, R.Top, R.Right + 1, R.Bottom);
                SetTextColor(Canvas.Handle, C);
                DrawText(Canvas.Handle, Text, nLength, Rd, Flags);
              end;
              // Bottom
              if SkinData.SkinManager.gd[SkinIndex].Props[State].FontColor.Bottom <> -1 then begin
                C := ChangeSaturation(ChangeHUE(SkinData.HUEOffset, SkinData.SkinManager.gd[SkinIndex].Props[State].FontColor.Bottom), SkinData.Saturation);
                Rd := Rect(R.Left, R.Top + 1, R.Right, R.Bottom + 1);
                SetTextColor(Canvas.Handle, C);
                DrawText(Canvas.Handle, Text, nLength, Rd, Flags);
              end;
              // Center
              if not SkinData.CustomFont then begin
                C := SkinData.SkinManager.gd[SkinIndex].Props[State].FontColor.Color;
                if SkinData.HUEOffset <> 0 then C := ChangeHUE(SkinData.HUEOffset, C);
                if SkinData.Saturation <> 0 then C := ChangeSaturation(C, SkinData.Saturation);
                SetTextColor(Canvas.Handle, C);
              end;
              DrawText(Canvas.Handle, Text, nLength, R, Flags or DT_NOCLIP);
            end
            else DrawText(Canvas.Handle, Text, nLength, R, Flags or DT_NOCLIP);
          end
          else begin
            Canvas.Font.Color := ChangeSaturation(ChangeHUE(SkinData.HUEOffset, MixColors(SkinData.SkinManager.gd[SkinIndex].FontColor[1], SkinData.SkinManager.GetGlobalColor, DefDisabledBlend)), SkinData.Saturation);
            DrawText(Canvas.Handle, Text, nLength, R, Flags);
          end
        end
        else DrawText(Canvas.Handle, Text, nLength, R, Flags);
      end
      else begin
        if Enabled then DrawText(Canvas.Handle, Text, nLength, R, Flags) else begin
          OffsetRect(R, 1, 1);
          Canvas.Font.Color := clBtnHighlight;
          DrawText(Canvas.Handle, Text, nLength, R, Flags);
          OffsetRect(R, -1, -1);
          Canvas.Font.Color := clBtnShadow;
          DrawText(Canvas.Handle, Text, nLength, R, Flags);
        end;
      end;
    finally
      RestoreDC(Canvas.Handle, SavedDC);
    end;
  end;
end;

{$IFDEF TNTUNICODE}
procedure WriteTextExW(const Canvas: TCanvas; Text: PWideChar; Enabled: boolean; var aRect : TRect; Flags: Cardinal; SkinData : TsCommonData; Hot : boolean); overload;
var
  R, Rd: TRect;
  SavedDC : hdc;
  nLength : Integer;
  SkinIndex : integer;
  i : integer;
  FGlowMask : TBitmap;
  C : TColor;
  State : integer;
begin
  if Text <> '' then begin
    nLength := Length(Text);
    R := aRect;
    if Hot and (SkinData.SkinSection = s_WebBtn) then Canvas.Font.Style := Canvas.Font.Style + [fsUnderline];
    SavedDC := SaveDC(Canvas.Handle);
    try
      IntersectClipRect(Canvas.Handle, aRect.Left, aRect.Top, aRect.Right, aRect.Bottom);
      if SkinData.Skinned then begin
        if Hot then State := 1 else State := 0;
        if (SkinData.FOwnerControl <> nil) and ((SkinData.COC in [COC_TsGroupBox, COC_TsCheckBox, COC_TsRadioButton]) or (SkinData.FOwnerControl is TGraphicControl)) and
              TsHackedControl(SkinData.FOwnerControl).ParentFont and (SkinData.FOwnerControl.Parent <> nil) then begin
          if SkinData.SkinManager.gd[SkinData.SkinIndex].Props[State].Transparency > 0
            then SkinIndex := GetFontIndex(SkinData.FOwnerControl, SkinData.SkinIndex, SkinData.SkinManager)
            else SkinIndex := SkinData.SkinIndex;
        end
        else SkinIndex := SkinData.SkinIndex;
        Canvas.Brush.Style := bsClear;
        if SkinData.SkinManager.IsValidSkinIndex(SkinIndex) then begin
          if SkinData.FCacheBmp <> nil then begin
            i := SkinData.SkinManager.gd[SkinIndex].Props[State].GlowSize;
            if i <> 0 then begin
              FGlowMask := nil;
              C := SkinData.SkinManager.gd[SkinIndex].Props[State].GlowColor;
              if SkinData.HUEOffset <> 0 then C := ChangeHUE(SkinData.HUEOffset, C);
              if SkinData.Saturation <> 0 then C := ChangeSaturation(C, SkinData.Saturation);
              acDrawGlowForText(SkinData.FCacheBmp, PacChar(Text), R, Flags, BF_LEFT or BF_TOP or BF_BOTTOM or BF_RIGHT, i, C, FGlowMask);
              FreeAndNil(FGlowMask);
            end;
          end;

          if Enabled then begin
            // Left contour
            if not SkinData.CustomFont then begin
              if SkinData.SkinManager.gd[SkinIndex].Props[State].FontColor.Left <> -1 then begin
                C := ChangeSaturation(ChangeHUE(SkinData.HUEOffset, SkinData.SkinManager.gd[SkinIndex].Props[State].FontColor.Left), SkinData.Saturation);
                Rd := Rect(R.Left - 1, R.Top, R.Right - 1, R.Bottom);
                SetTextColor(Canvas.Handle, C);
                Tnt_DrawTextW(Canvas.Handle, Text, nLength, Rd, Flags);
              end;
              // Top
              if SkinData.SkinManager.gd[SkinIndex].Props[State].FontColor.Top <> -1 then begin
                C := ChangeSaturation(ChangeHUE(SkinData.HUEOffset, SkinData.SkinManager.gd[SkinIndex].Props[State].FontColor.Top), SkinData.Saturation);
                Rd := Rect(R.Left, R.Top - 1, R.Right, R.Bottom - 1);
                SetTextColor(Canvas.Handle, C);
                Tnt_DrawTextW(Canvas.Handle, Text, nLength, Rd, Flags);
              end;
              // Right
              if SkinData.SkinManager.gd[SkinIndex].Props[State].FontColor.Right <> -1 then begin
                C := ChangeSaturation(ChangeHUE(SkinData.HUEOffset, SkinData.SkinManager.gd[SkinIndex].Props[State].FontColor.Right), SkinData.Saturation);
                Rd := Rect(R.Left + 1, R.Top, R.Right + 1, R.Bottom);
                SetTextColor(Canvas.Handle, C);
                Tnt_DrawTextW(Canvas.Handle, Text, nLength, Rd, Flags);
              end;
              // Bottom
              if SkinData.SkinManager.gd[SkinIndex].Props[State].FontColor.Bottom <> -1 then begin
                C := ChangeSaturation(ChangeHUE(SkinData.HUEOffset, SkinData.SkinManager.gd[SkinIndex].Props[State].FontColor.Bottom), SkinData.Saturation);
                Rd := Rect(R.Left, R.Top + 1, R.Right, R.Bottom + 1);
                SetTextColor(Canvas.Handle, C);
                Tnt_DrawTextW(Canvas.Handle, Text, nLength, Rd, Flags);
              end;
              // Center
              if not SkinData.CustomFont then begin
                C := SkinData.SkinManager.gd[SkinIndex].Props[State].FontColor.Color;
                if SkinData.HUEOffset <> 0 then C := ChangeHUE(SkinData.HUEOffset, C);
                if SkinData.Saturation <> 0 then C := ChangeSaturation(C, SkinData.Saturation);
                SetTextColor(Canvas.Handle, C);
              end;
              Tnt_DrawTextW(Canvas.Handle, Text, nLength, R, Flags or DT_NOCLIP);
            end
            else Tnt_DrawTextW(Canvas.Handle, Text, nLength, R, Flags or DT_NOCLIP);
          end
          else begin
            Canvas.Font.Color := ChangeSaturation(ChangeHUE(SkinData.HUEOffset, MixColors(SkinData.SkinManager.gd[SkinIndex].FontColor[1], SkinData.SkinManager.GetGlobalColor, DefDisabledBlend)), SkinData.Saturation);
            Tnt_DrawTextW(Canvas.Handle, Text, nLength, R, Flags);
          end
        end
        else Tnt_DrawTextW(Canvas.Handle, Text, nLength, R, Flags);
      end
      else Tnt_DrawTextW(Canvas.Handle, Text, nLength, R, Flags);
    finally
      RestoreDC(Canvas.Handle, SavedDC);
    end;
  end;
end;

procedure WriteUnicode(const Canvas: TCanvas; const Text: WideString; Enabled: boolean; var aRect : TRect; Flags: Cardinal; SkinData : TsCommonData; Hot : boolean); overload;
var
  R, Rd: TRect;
  x, y : integer;
  ts: TSize;
  SavedDC : hdc;
  nLength: Integer;
  State : integer;
begin
  nLength := Length(Text);

  R := aRect;
  if Hot and (SkinData.SkinSection = s_WebBtn) then Canvas.Font.Style := Canvas.Font.Style + [fsUnderline];
  if Hot then State := 1 else State := 0;

  SavedDC := SaveDC(Canvas.Handle);
  try
    IntersectClipRect(Canvas.Handle, aRect.Left, aRect.Top, aRect.Right, aRect.Bottom);

    if Flags or DT_WORDBREAK <> Flags then begin // If no multiline

      ts := WideCanvasTextExtent(Canvas, Text);

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

      R := aRect;
      InflateRect(aRect, 1, 1);
    end;

    Canvas.Brush.Style := bsClear;
    Flags := ETO_CLIPPED or Flags;
    if Text <> '' then begin
      if Enabled then begin
        if Assigned(SkinData.SkinManager) and SkinData.SkinManager.IsValidSkinIndex(SkinData.SkinIndex) then begin
          // Left contur
          if not SkinData.CustomFont then begin
            if SkinData.SkinManager.gd[SkinData.SkinIndex].Props[State].FontColor.Left <> -1 then begin
              Canvas.Font.Color := SkinData.SkinManager.gd[SkinData.SkinIndex].Props[State].FontColor.Left;
              Rd := Rect(R.Left - 1, R.Top, R.Right - 1, R.Bottom);
              Windows.ExtTextOutW(Canvas.Handle, Rd.Left, Rd.Top, Flags, @Rd, PWideChar(Text), nLength, nil)
            end;
            // Top
            Canvas.Font.Color := SkinData.SkinManager.gd[SkinData.SkinIndex].Props[State].FontColor.Top;
            if Canvas.Font.Color <> -1 then begin
              Rd := Rect(R.Left, R.Top - 1, R.Right, R.Bottom - 1);
              Windows.ExtTextOutW(Canvas.Handle, Rd.Left, Rd.Top, Flags, @Rd, PWideChar(Text), nLength, nil)
            end;
            // Right
            Canvas.Font.Color := SkinData.SkinManager.gd[SkinData.SkinIndex].Props[State].FontColor.Right;
            if Canvas.Font.Color <> -1 then begin
              Rd := Rect(R.Left + 1, R.Top, R.Right + 1, R.Bottom);
              Windows.ExtTextOutW(Canvas.Handle, Rd.Left, Rd.Top, Flags, @Rd, PWideChar(Text), nLength, nil)
            end;
            // Bottom
            Canvas.Font.Color := SkinData.SkinManager.gd[SkinData.SkinIndex].Props[State].FontColor.Bottom;
            if Canvas.Font.Color <> -1 then begin
              Rd := Rect(R.Left, R.Top + 1, R.Right, R.Bottom + 1);
              Windows.ExtTextOutW(Canvas.Handle, Rd.Left, Rd.Top, Flags, @Rd, PWideChar(Text), nLength, nil)
            end;
          end;
          // Center
          if not SkinData.CustomFont then begin
            Canvas.Font.Color := SkinData.SkinManager.gd[SkinData.SkinIndex].Props[State].FontColor.Color;
          end;
          Windows.ExtTextOutW(Canvas.Handle, R.Left, R.Top, Flags, @R, PWideChar(Text), nLength, nil)
        end
        else
          Windows.ExtTextOutW(Canvas.Handle, R.Left, R.Top, Flags, @R, PWideChar(Text), nLength, nil)
      end
      else begin
        Canvas.Font.Color := MixColors(SkinData.SkinManager.gd[SkinData.SkinIndex].FontColor[1], SkinData.SkinManager.gd[SkinData.SkinIndex].Color, DefDisabledBlend);
        Windows.ExtTextOutW(Canvas.Handle, R.Left, R.Top, Flags, @R, PWideChar(Text), nLength, nil)
      end;
    end;
  finally
    RestoreDC(Canvas.Handle, SavedDC);
  end;
end;

procedure TextRectW(const Canvas : TCanvas; var Rect: TRect; X, Y: Integer; const Text: WideString);
begin
  WideCanvasTextRect(Canvas, Rect, X, Y, Text);
end;

procedure WriteTextExW(const Canvas: TCanvas; Text: PWideChar; Enabled: boolean; var aRect : TRect; Flags: Cardinal; SkinIndex : integer; Hot : boolean; SkinManager : TObject = nil);
var
  R, Rd: TRect;
  x, y : integer;
  ts: TSize;
  nLength: Integer;
begin
  nLength := {$IFNDEF D2006}WStrLen(Text){$ELSE}Length(Text){$ENDIF};

  if SkinManager = nil then SkinManager := DefaultManager;
  if not Assigned(DefaultManager) or not TsSkinManager(SkinManager).IsValidSkinIndex(SkinIndex) then Exit;
  with TsSkinManager(SkinManager) do begin {SeeLater}

    R := aRect;

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

      R := aRect;
      InflateRect(aRect, 1, 1);
    end;

    Canvas.Brush.Style := bsClear;
    if Text <> '' then begin
      if Enabled then begin
        if IsValidSkinIndex(SkinIndex) then begin
          // Left contur
          if Hot then Canvas.Font.Color := gd[SkinIndex].HotFontColor[2] else Canvas.Font.Color := gd[SkinIndex].FontColor[2];
          if Canvas.Font.Color <> -1 then begin
            Rd := Rect(R.Left - 1, R.Top, R.Right - 1, R.Bottom);
            Tnt_DrawTextW(Canvas.Handle, Text, nLength, Rd, Flags);
          end;
          // Top
          if Hot then Canvas.Font.Color := gd[SkinIndex].HotFontColor[3] else Canvas.Font.Color := gd[SkinIndex].FontColor[3];
          if Canvas.Font.Color <> -1 then begin
            Rd := Rect(R.Left, R.Top - 1, R.Right, R.Bottom - 1);
            Tnt_DrawTextW(Canvas.Handle, Text, nLength, Rd, Flags);
          end;
          // Right
          if Hot then Canvas.Font.Color := gd[SkinIndex].HotFontColor[4] else Canvas.Font.Color := gd[SkinIndex].FontColor[4];
          if Canvas.Font.Color <> -1 then begin
            Rd := Rect(R.Left + 1, R.Top, R.Right + 1, R.Bottom);
            Tnt_DrawTextW(Canvas.Handle, Text, nLength, Rd, Flags);
          end;
          // Bottom
          if Hot then Canvas.Font.Color := gd[SkinIndex].HotFontColor[5] else Canvas.Font.Color := gd[SkinIndex].FontColor[5];
          if Canvas.Font.Color <> -1 then begin
            Rd := Rect(R.Left, R.Top + 1, R.Right, R.Bottom + 1);
            Tnt_DrawTextW(Canvas.Handle, Text, nLength, Rd, Flags);
          end;
          // Center
          if Hot then Canvas.Font.Color := gd[SkinIndex].HotFontColor[1] else Canvas.Font.Color := gd[SkinIndex].FontColor[1];
          Tnt_DrawTextW(Canvas.Handle, Text, nLength, R, Flags);
        end
        else Tnt_DrawTextW(Canvas.Handle, Text, nLength, R, Flags);
      end
      else begin
        Canvas.Font.Color := MixColors(gd[SkinIndex].FontColor[1], gd[SkinIndex].Color, DefDisabledBlend);
        Tnt_DrawTextW(Canvas.Handle, Text, nLength, R, Flags);
      end;
    end;
  end
end;

{$ENDIF}

procedure FadeRect(CanvasSrc: TCanvas; RSrc: TRect; CanvasDst: HDC; PDst: TPoint; Transparency: integer; Color: TColor; Blur : integer; Shape: TsShadowingShape); overload;
begin
  FadeRect(CanvasSrc, RSrc, CanvasDst, PDst, Transparency, Color, Blur, Shape, 0);
end;

procedure FadeRect(CanvasSrc: TCanvas; RSrc: TRect; CanvasDst: HDC; PDst: TPoint; Transparency: integer; Color: TColor; Blur : integer; Shape: TsShadowingShape; Radius : integer); overload;
var
  Bmp, TempBmp : TBitmap;
  delta: real;
  RValue,
  i : integer;
  c : TsColor;
  SavedBmp, SavedSrc, SavedDst: longint;
begin
  SavedSrc := SaveDC(CanvasSrc.Handle);
  SavedDst := SaveDC(CanvasDst);
  Color := ColorToRGB(Color);
  try
    case Transparency of
      100: BitBlt(CanvasDst, PDst.x, PDst.y, WidthOf(RSrc), HeightOf(RSrc), CanvasSrc.Handle, RSrc.Left, RSrc.Top, SRCCOPY);
      0: FillDC(CanvasDst, Rect(PDst.x, PDst.y, PDst.x + WidthOf(RSrc), PDst.y + HeightOf(RSrc)), Color)
      else begin
        Bmp := CreateBmp32(WidthOf(rSrc), HeightOf(rSrc));
        TempBmp := CreateBmp32(Bmp.Width, Bmp.Height);
        Blur := Mini(Mini(TempBmp.Width div 2, TempBmp.Height div 2), Blur);

        RValue := MaxByte * Transparency div 100;
        SavedBmp := SaveDC(Bmp.Canvas.Handle);
        try

          bitBlt(Bmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, CanvasSrc.Handle, RSrc.Left, RSrc.Top, SrcCopy);

          delta := (MaxByte - RValue) / (Blur + 1);
          // Prepare a mask
          TColor(c) := clWhite;
          TempBmp.Canvas.Pen.Style := psClear;
          TempBmp.Canvas.Brush.Style := bsSolid;
          TempBmp.Canvas.Brush.Color := clWhite;
          case Shape of
            ssRectangle: begin
              for i := 0 to Blur do begin
                c.R := RValue + Round(delta * (Blur - i));
                c.G := c.R;
                c.B := c.R;
                TempBmp.Canvas.Brush.Color := TColor(c);
                TempBmp.Canvas.RoundRect(i, i, TempBmp.Width - i + 1, TempBmp.Height - i + 1, Blur + Radius, Blur + Radius);
              end;
            end;
            ssEllipse: begin
              for i := 0 to Blur do begin
                c.R := RValue + Round(delta * (Blur - i));
                c.G := c.R;
                c.B := c.R;
                TempBmp.Canvas.Brush.Color := TColor(c);
                TempBmp.Canvas.Ellipse(Rect(i, i, TempBmp.Width - i, TempBmp.Height - i));
              end;
            end;
          end;

          BlendBmpByMask(Bmp, TempBmp, TsColor(Color));

          // Copy back
          BitBlt(CanvasDst, PDst.x, PDst.y, Bmp.Width, Bmp.Height, Bmp.Canvas.Handle, 0, 0, SRCCOPY);

        finally
          RestoreDC(Bmp.Canvas.Handle, SavedBmp);

          FreeAndNil(Bmp);
          FreeAndNil(TempBmp);
        end
      end;
    end;
  finally
    RestoreDC(CanvasSrc.Handle, SavedSrc);
    RestoreDC(CanvasDst, SavedDst);
  end;
end;

procedure FadeBmp(FadedBmp: TBitMap; aRect: TRect; Transparency: integer; Color: TsColor; Blur, Radius : integer);
var
  Bmp, TempBmp : Graphics.TBitmap;
  r: TRect;
  delta: real;
  RValue, i : integer;
  c : TsColor;
begin
  Bmp := CreateBmp32(aRect.Right - aRect.Left, aRect.Bottom - aRect.Top);
  TempBmp := CreateBmp32(Bmp.Width, Bmp.Height);
  Blur := Mini(Mini(TempBmp.Width div 2, TempBmp.Height div 2), Blur);
  Radius := Mini(Mini(TempBmp.Width div 2, TempBmp.Height div 2), Radius);
  RValue := MaxByte * Transparency div 100;
  // Copy faded area in Ftb
  bitBlt(Bmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height, FadedBmp.Canvas.Handle, aRect.Left, aRect.Top, SrcCopy);

  TempBmp.Canvas.Pen.Style := psClear;
  TempBmp.Canvas.Brush.Style := bsSolid;
  TempBmp.Canvas.Brush.Color := clWhite;

  delta := (MaxByte - RValue) / (Blur + 1);
  // Prepare template
  TColor(c) := clWhite;
  for i := 0 to Blur do begin

    r := Rect(i, i, TempBmp.Width - i, TempBmp.Height - i);
    TempBmp.Canvas.Brush.Color := TColor(c);
    TempBmp.Canvas.RoundRect(i, i, TempBmp.Width - i, TempBmp.Height - i, Radius, Radius);

    c.R := RValue + Round(delta * (Blur - i));
    c.G := c.R;
    c.B := c.R;
  end;
  r := Rect(Blur, Blur, TempBmp.Width - Blur, TempBmp.Height - Blur);

  TempBmp.Canvas.Pen.Style := psClear;
  TempBmp.Canvas.Brush.Style := bsSolid;
  TempBmp.Canvas.Brush.Color := TColor(c);
  TempBmp.Canvas.RoundRect(r.Left, R.Top, R.Right, R.Bottom, Blur, Blur);

  BlendBmpByMask(Bmp, TempBmp, Color);

  // Copy back
  BitBlt(FadedBmp.Canvas.Handle, aRect.Left, aRect.Top, Bmp.Width, Bmp.Height, Bmp.Canvas.Handle, 0, 0, SRCCOPY);
  FreeAndNil(Bmp);
  FreeAndNil(TempBmp);
end;

procedure BlendTransRectangle(Dst: TBitmap; X, Y: integer; Src: TBitmap; aRect: TRect; Blend: real; TransColor : TColor = clFuchsia);
var
  oldleft, oldtop, dx, dy, h, w, width, height, curX, nextX : integer;
  S, D : PRGBAArray;
begin
  if aRect.Top < 0 then begin
    oldtop := aRect.Top;
    aRect.Top := 0
  end
  else oldtop := 0;
  if aRect.Left < 0 then begin
    oldleft := aRect.Left;
    aRect.Left := 0
  end
  else oldleft := 0;
  if aRect.Bottom > Src.Height - 1 then aRect.Bottom := Src.Height - 1;
  if aRect.Right > Src.Width - 1 then aRect.Right := Src.Width - 1;

  h := HeightOf(aRect);
  w := WidthOf(aRect);
  width := Dst.Width - 1;
  height := Dst.Height - 1;

  S := nil;
  D := nil;
  for dy := 0 to h do begin
    if (dy + Y > height) then break else if dy + Y < 0 then Continue;
    if dy + aRect.Top >= 0 then S := Src.ScanLine[dy + aRect.Top] else Continue;
    if dy + Y - oldtop < 0 then Continue else if dy + Y - oldtop > Dst.Height - 1 then Break else D := Dst.ScanLine[dy + Y - oldtop];
    nextX := X - oldleft;
    CurX := aRect.Left;
    for dx := 0 to w do begin
      if (nextX > Width) then Break;
      if (nextX < 0) then Continue;
      if CurX > Src.Width - 1 then Continue;
      if S[CurX].C <> TransColor then begin
        D[nextX].R := round(S[CurX].R - Blend * (S[CurX].R - D[nextX].R));
        D[nextX].G := round(S[CurX].G - Blend * (S[CurX].G - D[nextX].G));
        D[nextX].B := round(S[CurX].B - Blend * (S[CurX].B - D[nextX].B));
      end;
      inc(nextX);
      inc(CurX);
    end;
  end;
end;

procedure BlendTransBitmap(Bmp: TBitmap; Blend: real; Color: TsColor);
var
  dx, dy : integer;
  S : PRGBAArray;
  w, h : integer;
begin
  w := Bmp.Width - 1;
  h := Bmp.Height - 1;
  for dy := 0 to h do begin
    S := Bmp.ScanLine[dy];
    for dx := 0 to w do if (S[dX].C <> clFuchsia) then begin
      S[dX].R := round((S[dX].R - Color.R) * Blend + Color.R);
      S[dX].G := round((S[dX].G - Color.G) * Blend + Color.G);
      S[dX].B := round((S[dX].B - Color.B) * Blend + Color.B);
    end;
  end;
end;

procedure BlendBmpByMask(SrcBmp, MskBmp: Graphics.TBitMap; BlendColor : TsColor);
var
  S1, S2 : PRGBAArray;
  X, Y: Integer;
  minW, minH : integer;
  r, g, b : integer;
begin
  if (SrcBmp.Width <> MskBmp.Width) or (SrcBmp.Height <> MskBmp.Height) then Exit;
  minH := SrcBmp.Height - 1;
  minW := SrcBmp.Width - 1;
  r := BlendColor.R shl 8;
  g := BlendColor.G shl 8;
  b := BlendColor.B shl 8;
  for Y := 0 to minH do begin
    S1 := SrcBmp.ScanLine[Y];
    S2 := MskBmp.ScanLine[Y];
    for X := 0 to minW do begin
      S1[X].R := (((S1[X].R - BlendColor.R) * S2[X].R + r) shr 8) and MaxByte;
      S1[X].G := (((S1[X].G - BlendColor.G) * S2[X].G + g) shr 8) and MaxByte;
      S1[X].B := (((S1[X].B - BlendColor.B) * S2[X].B + b) shr 8) and MaxByte;
    end
  end;
end;

procedure SumBitmaps(SrcBmp, MskBmp: Graphics.TBitMap; Color : TsColor);
var
  FastSum32 : TacFastSum32;
begin
  FastSum32 := TacFastSum32.Create;
  try
    if (SrcBmp.Width = MskBmp.Width) and (SrcBmp.Height = MskBmp.Height) then with FastSum32 do if Attach(MskBmp, SrcBmp) then begin
      FastSum32.Alpha := Color.R;
      DstX1 := 0;
      DstY1 := 0;
      DstX2 := DstX1 + Mskbmp.Width;
      DstY2 := DstY1 + Mskbmp.Height;
      SrcX1 := 0;
      SrcY2 := 0;
      SrcX2 := SrcX1 + SrcBmp.Width;
      SrcY2 := SrcY1 + SrcBmp.Height;
      BlendBitmapsRect;
    end;
  finally
    FreeAndNil(FastSum32);
  end;
end;

procedure SumBmpRect(const DstBmp, SrcBmp: Graphics.TBitMap; const AlphaValue : byte; SrcRect : TRect; DstPoint : TPoint);
var
  FastSum32 : TacFastSum32;
begin
  // Coordinates correcting
  if DstPoint.x < 0 then begin
    inc(SrcRect.Left, -DstPoint.x);
    DstPoint.x := 0;
  end;
  if DstPoint.y < 0 then begin
    inc(SrcRect.Top, -DstPoint.y);
    DstPoint.y := 0;
  end;
  if SrcRect.Left < 0 then begin
    inc(DstPoint.x, -SrcRect.Left);
    SrcRect.Left := 0;
    if DstPoint.x < 0 then begin
      inc(SrcRect.Left, -DstPoint.x);
      DstPoint.x := 0;
    end;
  end;
  if SrcRect.Top < 0 then begin
    inc(DstPoint.y, - SrcRect.Top);
    SrcRect.Top := 0;
    if DstPoint.y < 0 then begin
      inc(SrcRect.Top, - DstPoint.y);
      DstPoint.y := 0;
    end;
  end;

  if (SrcRect.Right <= SrcRect.Left) or (SrcRect.Bottom <= SrcRect.Top) then Exit;
  if (DstPoint.x >= DstBmp.Width) or (DstPoint.y >= DstBmp.Height) then Exit;
  if (SrcRect.Left >= SrcBmp.Width) or (SrcRect.Top >= SrcBmp.Height) then Exit;

  if SrcRect.Right > SrcBmp.Width then SrcRect.Right := SrcBmp.Width;
  if SrcRect.Bottom > SrcBmp.Height then SrcRect.Bottom := SrcBmp.Height;
  if DstPoint.x + WidthOf(SrcRect) > DstBmp.Width then SrcRect.Right := SrcRect.Left + (DstBmp.Width - DstPoint.x);
  if DstPoint.y + HeightOf(SrcRect) > DstBmp.Height then SrcRect.Bottom := SrcRect.Top + (DstBmp.Height - DstPoint.y);

  FastSum32 := TacFastSum32.Create;
  try
    with FastSum32 do if Attach(SrcBmp, DstBmp) then begin
      Alpha := AlphaValue;
      DstX1 := DstPoint.x;
      DstY1 := DstPoint.y;
      DstX2 := DstX1 + WidthOf(SrcRect);
      DstY2 := DstY1 + HeightOf(SrcRect);
      SrcX1 := SrcRect.Left;
      SrcY2 := SrcRect.Top;
      SrcX2 := SrcX1 + WidthOf(SrcRect);
      SrcY2 := SrcY1 + HeightOf(SrcRect);
      BlendBitmapsRect;
    end;
  finally
    FastSum32.Free;
  end;
end;

procedure CopyByMask(R1, R2 : TRect; const Bmp1, Bmp2 : TBitmap; const CI : TCacheInfo; const UpdateTrans : boolean); overload;
var
  S1, S2 : PRGBAArray;
  X, Y, h, w, dX1, dX2: Integer;
  col : TsColor;
  C_ : TsColor_;
begin
  if Bmp2 = nil then Exit;
  h := Min(HeightOf(R1), HeightOf(R2));
  h := Min(h, Bmp1.Height - R1.Top);
  h := Min(h, Bmp2.Height - R2.Top) - 1;
  if h < 0 then Exit;
  w := Min(WidthOf(R1), WidthOf(R2));
  w := Min(w, Bmp1.Width - R1.Left);
  w := Min(w, Bmp2.Width - R2.Left) - 1;
  if w < 0 then Exit;
  if R1.Left < R2.Left then begin
    if (R1.Left < 0) then begin
      inc(R2.Left, - R1.Left);
      dec(w, - R1.Left);
      R1.Left := 0;
    end;
  end
  else begin
    if (R2.Left < 0) then begin
      inc(R1.Left, - R2.Left);
      dec(w, - R2.Left);
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

  if not CI.Ready then begin
    for Y := 0 to h do begin
      S1 := Bmp1.ScanLine[R1.Top + Y];
      S2 := Bmp2.ScanLine[R2.Top + Y];
      dX1 := R1.Left;
      dX2 := R2.Left;
      for X := 0 to w do begin
        S1[dX1].R := (((S2[dX2].R - S1[dX1].R) * S2[dX2].A + S1[dX1].R shl 8) shr 8) and MaxByte;
        S1[dX1].G := (((S2[dX2].G - S1[dX1].G) * S2[dX2].A + S1[dX1].G shl 8) shr 8) and MaxByte;
        S1[dX1].B := (((S2[dX2].B - S1[dX1].B) * S2[dX2].A + S1[dX1].B shl 8) shr 8) and MaxByte;
        if S2[dX2].A <> 0 then S1[dX1].A := S1[dX1].A + ((MaxByte - S1[dX1].A) * S2[dX2].A) div MaxByte;// else S1[dX1].A := MaxByte;
        inc(dX1);
        inc(dX2);
      end;
    end;
  end
  else begin
    for Y := 0 to h do begin
      S1 := Bmp1.ScanLine[R1.Top + Y];
      S2 := Bmp2.ScanLine[R2.Top + Y];
      dX1 := R1.Left;
      dX2 := R2.Left;
      for X := 0 to w do begin
        C_ := S2[dX2];
        if C_.C <> clFuchsia then begin
          S1[dX1].R := (((C_.R - S1[dX1].R) * C_.A + S1[dX1].R shl 8) shr 8) and MaxByte;
          S1[dX1].G := (((C_.G - S1[dX1].G) * C_.A + S1[dX1].G shl 8) shr 8) and MaxByte;
          S1[dX1].B := (((C_.B - S1[dX1].B) * C_.A + S1[dX1].B shl 8) shr 8) and MaxByte;
          if C_.A <> 0 then S1[dX1].A := S1[dX1].A + ((MaxByte - S1[dX1].A) * C_.A) div MaxByte;
        end
        else if UpdateTrans then begin // Optimize
          if (CI.Bmp.Height <= ci.Y + R1.Top + Y) then Continue;
          if (CI.Bmp.Width <= ci.X + R1.Left + X) then Break;
          if ci.Y + R1.Top + Y < 0 then Break;
          if ci.X + dX1 < 0 then Continue;
          col.C := ci.Bmp.Canvas.Pixels[ci.X + R1.Left + X, ci.Y + R1.Top + Y];
          S1[dX1].R := col.R;
          S1[dX1].G := col.G;
          S1[dX1].B := col.B;
          S1[dX1].A := MaxByte;
        end;
        inc(dX1);
        inc(dX2);
      end;
    end;
  end;
end;

procedure CopyBmp32(R1, R2 : TRect; const Bmp1, Bmp2 : TBitmap; const CI : TCacheInfo; const UpdateTrans : boolean; const GrayedColor : TColor; const Blend : integer; const Reflected : boolean);
var
  S1 : PRGBAArray;
  S3 : PRGBAArray;
  X, Y, h, w, dX1, dX2: Integer;
  col : TsColor;
  Col_ : TsColor_;
  gMaskValue, MaskValue : byte;
  dR, dG, dB : real;
begin
  if Bmp2 = nil then Exit else Bmp2.PixelFormat := pf32Bit;
  h := Min(HeightOf(R1, True), HeightOf(R2, True));
  h := Min(h, Bmp1.Height - R1.Top);
  h := Min(h, Bmp2.Height - R2.Top) - 1;
  if h < 0 then Exit;
  w := Min(WidthOf(R1, True), WidthOf(R2, True));
  w := Min(w, Bmp1.Width - R1.Left);
  w := Min(w, Bmp2.Width - R2.Left);
  if w < 0 then Exit;
  if R1.Left < R2.Left then begin
    if (R1.Left < 0) then begin
      inc(R2.Left, - R1.Left);
      dec(w, - R1.Left);
      R1.Left := 0;
      w := Min(w, Bmp2.Width - R2.Left) - 1;
    end;
  end
  else begin
    if (R2.Left < 0) then begin
      inc(R1.Left, - R2.Left);
      dec(w, - R2.Left);
      R2.Left := 0;
      w := Min(w, Bmp1.Width - R1.Left) - 1;
    end;
  end;
  if R1.Top < R2.Top then begin
    if (R1.Top < 0) then begin
      inc(R2.Top, - R1.Top);
      dec(h, - R1.Top);
      R1.Top := 0;
      h := Min(h, Bmp2.Height - R2.Top) - 1;
    end;
  end
  else begin
    if (R2.Top < 0) then begin
      inc(R1.Top, - R2.Top);
      dec(h, - R2.Top);
      R2.Top := 0;
      h := Min(h, Bmp1.Height - R1.Top) - 1;
    end;
  end;

  w := Min(w, Bmp1.Width - R1.Left);
  w := Min(w, Bmp2.Width - R2.Left) - 1;

  if GrayedColor <> clNone then begin
    Col.C := GrayedColor;
    dR := Col.R / MaxByte;
    dG := Col.G / MaxByte;
    dB := Col.B / MaxByte;

    if Blend <> 0 then begin
      if not CI.Ready then begin
        for Y := 0 to h do begin
          S1 := Bmp1.ScanLine[R1.Top + Y];
          S3 := Bmp2.ScanLine[R2.Top + Y];
          for X := 0 to w do begin
            dX1 := R1.Left + X;
            dX2 := R2.Left + X;
            col_ := S3[dX2];
            MaskValue := col_.A * (100 - Blend) div 100;
            gMaskValue := (col_.R + col_.G + col_.B) div 3;
            S1[dX1].R := (((min(round(gMaskValue * dR), MaxByte) - S1[dX1].R) * MaskValue + S1[dX1].R shl 8) shr 8) and MaxByte;
            S1[dX1].G := (((min(round(gMaskValue * dG), MaxByte) - S1[dX1].G) * MaskValue + S1[dX1].G shl 8) shr 8) and MaxByte;
            S1[dX1].B := (((min(round(gMaskValue * dB), MaxByte) - S1[dX1].B) * MaskValue + S1[dX1].B shl 8) shr 8) and MaxByte;
          end;
        end;
      end
      else begin
        for Y := 0 to h do begin
          S1 := Bmp1.ScanLine[R1.Top + Y];
          S3 := Bmp2.ScanLine[R2.Top + Y];
          dX1 := R1.Left;
          dX2 := R2.Left;
          for X := 0 to w do begin
            Col_ := S3[dX2];
            if Col_.C <> clFuchsia then begin
              MaskValue := Col_.A * (100 - Blend) div 100;
              gMaskValue := (col_.R + col_.G + col_.B) div 3;
              S1[dX1].R := (((min(round(gMaskValue * dR), MaxByte) - S1[dX1].R) * MaskValue + S1[dX1].R shl 8) shr 8) and MaxByte;
              S1[dX1].G := (((min(round(gMaskValue * dR), MaxByte) - S1[dX1].G) * MaskValue + S1[dX1].G shl 8) shr 8) and MaxByte;
              S1[dX1].B := (((min(round(gMaskValue * dR), MaxByte) - S1[dX1].B) * MaskValue + S1[dX1].B shl 8) shr 8) and MaxByte;
            end
            else if UpdateTrans then begin
              if (CI.Bmp.Height <= ci.Y + R1.Top + Y) then Continue;
              if (CI.Bmp.Width <= ci.X + dX1) then Break;
              if ci.Y + R1.Top + Y < 0 then Break;
              if ci.X + dX1 < 0 then Continue;
              col.C := ci.Bmp.Canvas.Pixels[ci.X + dX1, ci.Y + R1.Top + Y];
              S1[dX1].R := col.R;
              S1[dX1].G := col.G;
              S1[dX1].B := col.B;
            end;
            inc(dX1);
            inc(dX2);
          end;
        end;
      end;
    end
    else begin
      if not CI.Ready then begin
        for Y := 0 to h do begin
          S1 := Bmp1.ScanLine[R1.Top + Y];
          Bmp2.Handle;
          S3 := Bmp2.ScanLine[R2.Top + Y];
          dX1 := R1.Left;
          dX2 := R2.Left;
          for X := 0 to w do begin
            Col_ := S3[dX2];
            gMaskValue := (col_.R + col_.G + col_.B) div 3;
            S1[dX1].R := (((min(round(gMaskValue * dR), MaxByte) - S1[dX1].R) * S3[dX2].A + S1[dX1].R shl 8) shr 8) and MaxByte;
            S1[dX1].G := (((min(round(gMaskValue * dG), MaxByte) - S1[dX1].G) * S3[dX2].A + S1[dX1].G shl 8) shr 8) and MaxByte;
            S1[dX1].B := (((min(round(gMaskValue * dB), MaxByte) - S1[dX1].B) * S3[dX2].A + S1[dX1].B shl 8) shr 8) and MaxByte;
            inc(dX1);
            inc(dX2);
          end;
        end;
      end
      else begin
        for Y := 0 to h do begin
          S1 := Bmp1.ScanLine[R1.Top + Y];
          S3 := Bmp2.ScanLine[R2.Top + Y];
          dX1 := R1.Left;
          dX2 := R2.Left;
          for X := 0 to w do begin
            Col_ := S3[dX2];
            gMaskValue := (col_.R + col_.G + col_.B) div 3;
            if Col_.C <> clFuchsia then begin
              S1[dX1].R := (((min(round(gMaskValue * dR), MaxByte) - S1[dX1].R) * S3[dX2].A + S1[dX1].R shl 8) shr 8) and MaxByte;
              S1[dX1].G := (((min(round(gMaskValue * dG), MaxByte) - S1[dX1].G) * S3[dX2].A + S1[dX1].G shl 8) shr 8) and MaxByte;
              S1[dX1].B := (((min(round(gMaskValue * dB), MaxByte) - S1[dX1].B) * S3[dX2].A + S1[dX1].B shl 8) shr 8) and MaxByte;
            end
            else if UpdateTrans then begin
              if (CI.Bmp.Height <= ci.Y + R1.Top + Y) then Continue;
              if (CI.Bmp.Width <= ci.X + dX1) then Break;
              if ci.Y + R1.Top + Y < 0 then Break;
              if ci.X + dX1 < 0 then Continue;
              col.C := ci.Bmp.Canvas.Pixels[ci.X + R1.Left + X, ci.Y + R1.Top + Y];
              S1[dX1].R := col.R;
              S1[dX1].G := col.G;
              S1[dX1].B := col.B;
            end;
            inc(dX1);
            inc(dX2);
          end;
        end;
      end;
    end;

    if Reflected then begin
      h := min(Bmp2.Height div 2 - 1, Bmp1.Height - R1.Bottom - 1);
      Col.A := MaxByte div (Bmp2.Height div 2); // Step
      Col.R := MaxByte;
      for Y := 1 to h do begin
        S1 := Bmp1.ScanLine[R1.Bottom + Y];
        S3 := Bmp2.ScanLine[R2.Bottom - Y - 1];
        dX1 := R1.Left;
        dX2 := R2.Left;
        for X := 0 to w do begin
          Col_ := S3[dX2];
          if Col_.C <> clFuchsia then begin
            if Blend = 0
              then MaskValue := max(((Col_.A div 3) * Col.R) div MaxByte, 0)
              else MaskValue := max(((Col_.A * (100 - Blend) div 300) * Col.R) div MaxByte, 0);
            gMaskValue := (col_.R + col_.G + col_.B) div 3;
            S1[dX1].R := (((min(round(gMaskValue * dR), MaxByte) - S1[dX1].R) * MaskValue + S1[dX1].R shl 8) shr 8) and MaxByte;
            S1[dX1].G := (((min(round(gMaskValue * dG), MaxByte) - S1[dX1].G) * MaskValue + S1[dX1].G shl 8) shr 8) and MaxByte;
            S1[dX1].B := (((min(round(gMaskValue * dB), MaxByte) - S1[dX1].B) * MaskValue + S1[dX1].B shl 8) shr 8) and MaxByte;
          end;

          inc(dX1);
          inc(dX2);
        end;
        dec(Col.R, Col.A);
      end;
    end;
  end
  else begin
    if Blend <> 0 then begin
      if not CI.Ready then begin
        for Y := 0 to h do begin
          S1 := Bmp1.ScanLine[R1.Top + Y];
          S3 := Bmp2.ScanLine[R2.Top + Y];
          for X := 0 to w do begin
            dX1 := R1.Left + X;
            dX2 := R2.Left + X;
            col_ := S3[dX2];
            MaskValue := col_.A * (100 - Blend) div 100;
            S1[dX1].R := (((col_.R - S1[dX1].R) * MaskValue + S1[dX1].R shl 8) shr 8) and MaxByte;
            S1[dX1].G := (((col_.G - S1[dX1].G) * MaskValue + S1[dX1].G shl 8) shr 8) and MaxByte;
            S1[dX1].B := (((col_.B - S1[dX1].B) * MaskValue + S1[dX1].B shl 8) shr 8) and MaxByte;
          end;
        end;
      end
      else begin
        for Y := 0 to h do begin
          S1 := Bmp1.ScanLine[R1.Top + Y];
          S3 := Bmp2.ScanLine[R2.Top + Y];
          dX1 := R1.Left;
          dX2 := R2.Left;
          for X := 0 to w do begin
            Col_ := S3[dX2];
            if Col_.C <> clFuchsia then begin
              MaskValue := Col_.A * (100 - Blend) div 100;
              S1[dX1].R := (((Col_.R - S1[dX1].R) * MaskValue + S1[dX1].R shl 8) shr 8) and MaxByte;
              S1[dX1].G := (((Col_.G - S1[dX1].G) * MaskValue + S1[dX1].G shl 8) shr 8) and MaxByte;
              S1[dX1].B := (((Col_.B - S1[dX1].B) * MaskValue + S1[dX1].B shl 8) shr 8) and MaxByte;
            end
            else if UpdateTrans then begin
              if (CI.Bmp.Height <= ci.Y + R1.Top + Y) then Continue;
              if (CI.Bmp.Width <= ci.X + dX1) then Break;
              if ci.Y + R1.Top + Y < 0 then Break;
              if ci.X + dX1 < 0 then Continue;
              col.C := ci.Bmp.Canvas.Pixels[ci.X + dX1, ci.Y + R1.Top + Y];
              S1[dX1].R := col.R;
              S1[dX1].G := col.G;
              S1[dX1].B := col.B;
            end;
            inc(dX1);
            inc(dX2);
          end;
        end;
      end;
    end
    else begin
      if not CI.Ready then begin
        for Y := 0 to h do begin
          S1 := Bmp1.ScanLine[R1.Top + Y];
          Bmp2.Handle;
          S3 := Bmp2.ScanLine[R2.Top + Y];
          dX1 := R1.Left;
          dX2 := R2.Left;
          for X := 0 to w do begin
            S1[dX1].R := (((S3[dX2].R - S1[dX1].R) * S3[dX2].A + S1[dX1].R shl 8) shr 8) and MaxByte;
            S1[dX1].G := (((S3[dX2].G - S1[dX1].G) * S3[dX2].A + S1[dX1].G shl 8) shr 8) and MaxByte;
            S1[dX1].B := (((S3[dX2].B - S1[dX1].B) * S3[dX2].A + S1[dX1].B shl 8) shr 8) and MaxByte;
            inc(dX1);
            inc(dX2);
          end;
        end;
      end
      else begin
        for Y := 0 to h do begin
          S1 := Bmp1.ScanLine[R1.Top + Y];
          S3 := Bmp2.ScanLine[R2.Top + Y];
          dX1 := R1.Left;
          dX2 := R2.Left;
          for X := 0 to w do begin
            Col_ := S3[dX2];
            if Col_.C <> clFuchsia then begin
              S1[dX1].R := (((S3[dX2].R - S1[dX1].R) * S3[dX2].A + S1[dX1].R shl 8) shr 8) and MaxByte;
              S1[dX1].G := (((S3[dX2].G - S1[dX1].G) * S3[dX2].A + S1[dX1].G shl 8) shr 8) and MaxByte;
              S1[dX1].B := (((S3[dX2].B - S1[dX1].B) * S3[dX2].A + S1[dX1].B shl 8) shr 8) and MaxByte;
              S1[dX1].A := max(S1[dX1].A, S3[dX1].A); // Solving a problem of glyph making by Imglist
            end
            else if UpdateTrans then begin
              if (CI.Bmp.Height <= ci.Y + R1.Top + Y) then Continue;
              if (CI.Bmp.Width <= ci.X + dX1) then Break;
              if ci.Y + R1.Top + Y < 0 then Break;
              if ci.X + dX1 < 0 then Continue;
              col.C := ci.Bmp.Canvas.Pixels[ci.X + R1.Left + X, ci.Y + R1.Top + Y];
              S1[dX1].R := col.R;
              S1[dX1].G := col.G;
              S1[dX1].B := col.B;
            end;
            inc(dX1);
            inc(dX2);
          end;
        end;
      end;
    end;

    if Reflected then begin
      h := min(Bmp2.Height div 2 - 1, Bmp1.Height - R1.Bottom - 1);
      Col.A := MaxByte div (Bmp2.Height div 2); // Step
      Col.R := MaxByte;
      for Y := 1 to h do begin
        S1 := Bmp1.ScanLine[R1.Bottom + Y];
        S3 := Bmp2.ScanLine[R2.Bottom - Y - 1];
        dX1 := R1.Left;
        dX2 := R2.Left;
        for X := 0 to w do begin
          Col_ := S3[dX2];
          if Col_.C <> clFuchsia then begin
            if Blend = 0
              then MaskValue := max(((Col_.A div 3) * Col.R) div MaxByte, 0)
              else MaskValue := max(((Col_.A * (100 - Blend) div 300) * Col.R) div MaxByte, 0);
            S1[dX1].R := (((Col_.R - S1[dX1].R) * MaskValue + S1[dX1].R shl 8) shr 8) and MaxByte;
            S1[dX1].G := (((Col_.G - S1[dX1].G) * MaskValue + S1[dX1].G shl 8) shr 8) and MaxByte;
            S1[dX1].B := (((Col_.B - S1[dX1].B) * MaskValue + S1[dX1].B shl 8) shr 8) and MaxByte;
          end;

          inc(dX1);
          inc(dX2);
        end;
        dec(Col.R, Col.A);
      end;
    end;
  end;
end;

procedure CopyByMask(R1, R2 : TRect; const Bmp1, Bmp2 : TBitmap; const CI : TCacheInfo; const UpdateTrans : boolean; const MaskData : TsMaskData); overload;
var
  S1, S2, M : PRGBAArray;
  X, Y, h, w, ch, cw, dX1, dX2, hdiv2, k1, k2: Integer;
  C : TsColor;
  Cur : TsColor_;
  C1 : TsColor;
  Color : TsColor_;
  Fast32 : TacFast32;
begin
{$IFDEF NOSLOWDETAILS} Exit;{$ENDIF}
  h := R1.Bottom - R1.Top;
  if h > R2.Bottom - R2.Top then h := R2.Bottom - R2.Top;
  if h > Bmp1.Height - R1.Top then h := Bmp1.Height - R1.Top;
  if h > Bmp2.Height - R2.Top then h := Bmp2.Height - R2.Top - 1 else h := h - 1;
  if h < 0 then Exit;

  w := R1.Right - R1.Left;
  if w > R2.Right - R2.Left then w := R2.Right - R2.Left;
  if w > Bmp1.Width - R1.Left then w := Bmp1.Width - R1.Left;
  if w > Bmp2.Width - R2.Left then w := Bmp2.Width - R2.Left - 1 else w := w - 1;
  if w < 0 then Exit;

  if R1.Left < R2.Left then begin
    if (R1.Left < 0) then begin
      inc(R2.Left, - R1.Left);
      dec(w, - R1.Left);
      R1.Left := 0;
    end;
  end
  else begin
    if (R2.Left < 0) then begin
      inc(R1.Left, - R2.Left);
      dec(w, - R2.Left);
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
  Cur.A := 0;
  C1.A := 0;
  Color.A := TsColor(CI.FillColor).A; // Invert channels for a fast filling
  Color.R := TsColor(CI.FillColor).R;
  Color.G := TsColor(CI.FillColor).G;
  Color.B := TsColor(CI.FillColor).B;

  hdiv2 := (MaskData.R.Bottom - MaskData.R.Top) div 2;
  k1 := min(R2.Top + hdiv2, Bmp2.Height - h - 1);
  k2 := ci.X + R1.Left;
  if not CI.Ready then begin
    if UpdateTrans then for Y := 0 to h do begin
      S1 := Bmp1.ScanLine[R1.Top + Y];
      S2 := Bmp2.ScanLine[R2.Top + Y];
      M  := Bmp2.ScanLine[k1 + Y];
      dX1 := R1.Left;
      dX2 := R2.Left;
      for X := 0 to w do begin
//        cur := S2[dX2];
        with S2[dX2] do if C <> clFuchsia then begin
          S1[dX1].R := (((S1[dX1].R - R) * M[dX2].R + R shl 8) shr 8) and MaxByte;
          S1[dX1].G := (((S1[dX1].G - G) * M[dX2].G + G shl 8) shr 8) and MaxByte;
          S1[dX1].B := (((S1[dX1].B - B) * M[dX2].B + B shl 8) shr 8) and MaxByte;
        end
        else S1[dX1] := TsColor_(Color); // UpdateTrans
        inc(dX1);
        inc(dX2);
      end;
    end
    else for Y := 0 to h do begin
      S1 := Bmp1.ScanLine[R1.Top + Y];
      S2 := Bmp2.ScanLine[R2.Top + Y];
      M  := Bmp2.ScanLine[k1 + Y];
      dX1 := R1.Left;
      dX2 := R2.Left;
      for X := 0 to w do begin
        cur := S2[dX2];
        if cur.C <> clFuchsia then begin
          S1[dX1].R := (((S1[dX1].R - cur.R) * M[dX2].R + cur.R shl 8) shr 8) and MaxByte;
          S1[dX1].G := (((S1[dX1].G - cur.G) * M[dX2].G + cur.G shl 8) shr 8) and MaxByte;
          S1[dX1].B := (((S1[dX1].B - cur.B) * M[dX2].B + cur.B shl 8) shr 8) and MaxByte;
        end;
        inc(dX1);
        inc(dX2);
      end;
    end;
  end
  else begin
    ch := CI.Bmp.Height;
    cw := CI.Bmp.Width;
    if UpdateTrans then begin
      Fast32 := TacFast32.Create;
      try
        if Fast32.Attach(CI.Bmp) then begin
          for Y := 0 to h do begin
            S1 := Bmp1.ScanLine[R1.Top + Y];
            S2 := Bmp2.ScanLine[R2.Top + Y];
            M  := Bmp2.ScanLine[k1 + Y];
            dX1 := R1.Left;
            dX2 := R2.Left;
            for X := 0 to w do begin
              cur := S2[dX2];
              S1[dX1].A := MaxByte;
              if cur.C <> clFuchsia then begin
                S1[dX1].R := (((S1[dX1].R - cur.R) * M[dX2].R + cur.R shl 8) shr 8) and MaxByte;
                S1[dX1].G := (((S1[dX1].G - cur.G) * M[dX2].G + cur.G shl 8) shr 8) and MaxByte;
                S1[dX1].B := (((S1[dX1].B - cur.B) * M[dX2].B + cur.B shl 8) shr 8) and MaxByte;
              end
              else begin
                if (ch <= ci.Y + R1.Top + Y) then Continue;
                if (cw <= k2 + X) then Break;
                if ci.Y + R1.Top + Y < 0 then Break;
                if k2 + X < 0 then Continue;
                C := Fast32.Pixels[k2 + X, ci.Y + R1.Top + Y];
                S1[dX1].R := C.R;
                S1[dX1].G := C.G;
                S1[dX1].B := C.B;
              end;
              inc(dX1);
              inc(dX2);
            end;
          end;
        end;
      finally
        FreeAndNil(Fast32);
      end
    end
    else for Y := 0 to h do begin
      S1 := Bmp1.ScanLine[R1.Top + Y];
      S2 := Bmp2.ScanLine[R2.Top + Y];
      M  := Bmp2.ScanLine[k1 + Y];
      dX1 := R1.Left;
      dX2 := R2.Left;
      for X := 0 to w do begin
        S1[dX1].R := (((S1[dX1].R - S2[dX2].R) * M[dX2].R + S2[dX2].R shl 8) shr 8) and MaxByte;
        S1[dX1].G := (((S1[dX1].G - S2[dX2].G) * M[dX2].G + S2[dX2].G shl 8) shr 8) and MaxByte;
        S1[dX1].B := (((S1[dX1].B - S2[dX2].B) * M[dX2].B + S2[dX2].B shl 8) shr 8) and MaxByte;
        inc(dX1);
        inc(dX2);
      end;
    end;
  end;
end;

procedure CopyTransBitmaps(DstBmp, SrcBmp: Graphics.TBitMap; X, Y : integer; TransColor : TsColor);
var
  Dst, Src : PRGBAArray;
  Src24 : PRGBArray;
  minDY, maxDY, minDX, maxDX, dX, dY, sX, sY, sw, sh, dh, dw: Integer;
  C : TsColor_;
begin
  sw := SrcBmp.Width - 1;
  sh := SrcBmp.Height - 1;
  dw := DstBmp.Width - 1;
  dh := DstBmp.Height - 1;
  C.A := 0;

  sY := 0;
  maxDY := min(dh, Y + sh);
  minDY := max(Y, 0);
  maxDX := min(dw, X + sw);
  minDX := max(X, 0);

  if SrcBmp.PixelFormat = pf32bit then begin
    TransColor.C := SwapColor(TransColor.C);
    for dY := minDY to maxDY do begin
      Dst := DstBmp.ScanLine[dY];
      Src := SrcBmp.ScanLine[sY];
      sX := 0;
      for dX := minDX to maxDX do begin
        if Src[sX].C <> TransColor.C then begin
          Dst[dX] := Src[sX];
          Dst[dX].A := MaxByte
        end;
        inc(sX);
      end;
      inc(sY);
    end
  end
  else begin
    SrcBmp.PixelFormat := pf24bit;
    for dY := minDY to maxDY do begin
      Dst := DstBmp.ScanLine[dY];
      Src24 := SrcBmp.ScanLine[sY];
      sX := 0;
      for dX := minDX to maxDX do begin
        C.R := Src24[sX].R;
        C.G := Src24[sX].G;
        C.B := Src24[sX].B;
        if C.C <> TransColor.C then begin
          Dst[dX] := C;
          Dst[dX].A := MaxByte
        end;
        inc(sX);
      end;
      inc(sY);
    end;
  end;
end;

procedure CopyTransRect(DstBmp, SrcBmp: Graphics.TBitMap; X, Y : integer; SrcRect: TRect; TransColor : TColor; CI : TCacheInfo; UpdateTrans : boolean);
var
  Dst, Src : PRGBAArray;
  sX, sY, DstX, DstY, SrcX, SrcY : Integer;
  Cur : TsColor_;
  h, w, ch, cw, dh, dw : integer;
  col : TsColor;
  ParentRGBA : TsColor_;
  Fast32 : TacFast32;
begin
//  MaskColor := TsColor_(TransColor);

  if SrcRect.Top < 0 then SrcRect.Top := 0;
  if SrcRect.Bottom > SrcBmp.Height - 1 then SrcRect.Bottom := SrcBmp.Height - 1;
  if SrcRect.Left < 0 then SrcRect.Left := 0;
  if SrcRect.Right > SrcBmp.Width - 1 then SrcRect.Right := SrcBmp.Width - 1;

  h := HeightOf(SrcRect);
  w := WidthOf(SrcRect);
  dh := DstBmp.Height - 1;
  dw := DstBmp.Width - 1;
  Cur.A := 0;

  if UpdateTrans and CI.Ready and (CI.Bmp <> nil) then begin
    ch := CI.Bmp.Height;
    cw := CI.Bmp.Width;
    Fast32 := TacFast32.Create;
    try
      if Fast32.Attach(CI.Bmp) then begin
        DstY := Y;
        SrcY := SrcRect.Top;
        if DstBmp <> CI.Bmp then begin
          for sY := 0 to h do begin
            if (DstY <= dh) and (DstY >= 0) then begin
              Dst := DstBmp.ScanLine[DstY];
              Src := SrcBmp.ScanLine[SrcY];
              DstX := X;
              SrcX := SrcRect.Left;
              for sX := 0 to w do begin
                if (DstX <= dw) and (DstX >= 0) then begin
                  Cur := Src[SrcX];
                  if Cur.C <> TransColor then Dst[DstX] := Cur else begin
                    if (ch <= ci.Y + DstY) then Continue;
                    if (cw <= ci.X + DstX) then Break;
                    if ci.Y + DstY < 0 then Break;
                    if ci.X + DstX < 0 then Continue;
                    col := Fast32.Pixels[ci.X + DstX, ci.Y + DstY];
                    Dst[DstX].R := col.R;
                    Dst[DstX].G := col.G;
                    Dst[DstX].B := col.B;
                  end;
                  Dst[DstX].A := MaxByte;
                end;
                inc(DstX);
                inc(SrcX);
              end
            end;
            inc(DstY);
            inc(SrcY);
          end
        end
        else begin
          for sY := 0 to h do begin
            if (DstY <= dh) and (DstY >= 0) then begin
              Dst := DstBmp.ScanLine[DstY];
              Src := SrcBmp.ScanLine[SrcY];
              DstX := X;
              SrcX := SrcRect.Left;
              for sX := 0 to w do begin
                if (DstX <= dw) and (DstX >= 0) then begin
                  Cur := Src[SrcX];
                  if Cur.C <> TransColor then begin
                    Dst[DstX] := Cur;
                    Dst[DstX].A := MaxByte;
                  end;
                end;
                inc(DstX);
                inc(SrcX);
              end
            end;
            inc(DstY);
            inc(SrcY);
          end
        end;
      end
    finally
      FreeAndNil(Fast32);
    end;
  end
  else begin
    DstY := Y;
    SrcY := SrcRect.Top;
    if not CI.Ready then begin // If color for transparent pixels is defined
      ParentRGBA.R := TsColor(CI.FillColor).R;
      ParentRGBA.G := TsColor(CI.FillColor).G;
      ParentRGBA.B := TsColor(CI.FillColor).B;
      ParentRGBA.A := MaxByte;
      for sY := 0 to h do begin
        if (DstY <= dh) and (DstY >= 0) then begin
          Dst := DstBmp.ScanLine[DstY];
          Src := SrcBmp.ScanLine[SrcY];
          DstX := X;
          SrcX := SrcRect.Left;
          for sX := 0 to w do begin
            if (DstX <= dw) and (DstX >= 0) then begin
              if (Src[SrcX].C <> TransColor) then Dst[DstX] := Src[SrcX] else Dst[DstX] := ParentRGBA
            end;
            inc(DstX);
            inc(SrcX);
          end
        end;
        inc(DstY);
        inc(SrcY);
      end
    end
    else begin
      for sY := 0 to h do begin
        if (DstY <= dh) and (DstY >= 0) then begin
          Dst := DstBmp.ScanLine[DstY];
          Src := SrcBmp.ScanLine[SrcY];
          DstX := X;
          SrcX := SrcRect.Left;
          for sX := 0 to w do begin
            if (DstX <= dw) and (DstX >= 0) then begin
              if (Src[SrcX].C <> TransColor) then Dst[DstX] := Src[SrcX];
            end;
            inc(DstX);
            inc(SrcX);
          end
        end;
        inc(DstY);
        inc(SrcY);
      end;
    end
  end;
end;

procedure CopyTransRectA(DstBmp, SrcBmp: Graphics.TBitMap; X, Y : integer; SrcRect: TRect; TransColor : TColor; CI : TCacheInfo);
var
  Dst, Src : PRGBAArray;
  sX, sY, SrcX, DstX, DstY : Integer;
  h, w, dh, dw : integer;
  C, M : TsColor_;
begin
  M.B := TsColor_(TransColor).R;
  M.G := TsColor_(TransColor).G;
  M.R := TsColor_(TransColor).B;
  M.A := 0;

  if SrcRect.Top < 0 then SrcRect.Top := 0;
  if SrcRect.Bottom > SrcBmp.Height - 1 then SrcRect.Bottom := SrcBmp.Height - 1;
  if SrcRect.Left < 0 then SrcRect.Left := 0;
  if SrcRect.Right > SrcBmp.Width - 1 then SrcRect.Right := SrcBmp.Width - 1;

  h := HeightOf(SrcRect);
  w := WidthOf(SrcRect);
  C.A := 0;

  DstY := Y;
  dh := DstBmp.Height - 1;
  dw := DstBmp.Width - 1;
  for sY := 0 to h do begin
    if (DstY <= dh) and (DstY >= 0) then begin
      Dst := DstBmp.ScanLine[DstY];
      Src := SrcBmp.ScanLine[sY + SrcRect.Top];
      DstX := X;
      SrcX := SrcRect.Left;
      for sX := 0 to w do if (DstX <= dw) and (DstX >= 0) then begin
        C := Src[SrcX];
        if C.C <> M.C then Dst[DstX] := C;
        inc(SrcX);
        inc(dstX);
      end;
    end;
    inc(DstY);
  end;
end;

procedure SumBitmapsByMask(var ResultBmp, Src1, Src2: Graphics.TBitMap; MskBmp: Graphics.TBitMap; Percent : word = 0);
var
  S1, S2, M : PRGBAArray;
  R : PRGBAArray;
  X, Y, w, h: Integer;
begin
  if (Src1.Width <> Src2.Width) or (Src1.Height <> Src2.Height) then Exit;
  w := Src1.Width - 1;
  h := Src1.Height - 1;
  if MskBmp = nil then for Y := 0 to h do begin
    S1 := Src1.ScanLine[Y];
    S2 := Src2.ScanLine[Y];
    R  := ResultBmp.ScanLine[Y];
    for X := 0 to w do begin
      R[X].R := (((S1[X].R - S2[X].R) * Percent + S2[X].R shl 8) shr 8) and MaxByte;
      R[X].G := (((S1[X].G - S2[X].G) * Percent + S2[X].G shl 8) shr 8) and MaxByte;
      R[X].B := (((S1[X].B - S2[X].B) * Percent + S2[X].B shl 8) shr 8) and MaxByte;
    end
  end
  else for Y := 0 to h do begin
    S1 := Src1.ScanLine[Y];
    S2 := Src2.ScanLine[Y];
    R  := ResultBmp.ScanLine[Y];
    M  := MskBmp.ScanLine[Y];
    for X := 0 to w do begin
      R[X].R := (((S1[X].R - S2[X].R) * M[X].R + S2[X].R shl 8) shr 8) and MaxByte;
      R[X].G := (((S1[X].G - S2[X].G) * M[X].G + S2[X].G shl 8) shr 8) and MaxByte;
      R[X].B := (((S1[X].B - S2[X].B) * M[X].B + S2[X].B shl 8) shr 8) and MaxByte;
    end
  end
end;

procedure SumByMask(var Src1, Src2, MskBmp: Graphics.TBitMap; aRect: TRect);
var
  S1, S2, M : PRGBAArray;
  X, Y, B, R: Integer;
begin
  if Src1.Width < WidthOf(aRect) then Exit;
  if Src1.Height < HeightOf(aRect) then Exit;
  B := aRect.Bottom - 1;
  R := aRect.Right - 1;
  for Y := aRect.Top to B do begin
    S1 := Src1.ScanLine[Y];
    S2 := Src2.ScanLine[Y];
    M  := MskBmp.ScanLine[Y];
    for X := aRect.Left to R do begin
      S1[X].R := (((S1[X].R - S2[X].R) * M[X].R + S2[X].R shl 8) shr 8) and MaxByte;
      S1[X].G := (((S1[X].G - S2[X].G) * M[X].G + S2[X].G shl 8) shr 8) and MaxByte;
      S1[X].B := (((S1[X].B - S2[X].B) * M[X].B + S2[X].B shl 8) shr 8) and MaxByte;
    end
  end;
end;

procedure SumByMaskWith32(const Src1, Src2, MskBmp: Graphics.TBitMap; const aRect: TRect);
var
  S1, S2, M : PRGBAArray;
  X, Y, B, R: Integer;
  tmp : integer;
begin
  if Src1.Width < WidthOf(aRect) then Exit;
  if Src1.Height < HeightOf(aRect) then Exit;
  B := aRect.Bottom - 1;
  R := aRect.Right - 1;
  for Y := aRect.Top to B do begin
    S1 := Src1.ScanLine[Y];
    S2 := Src2.ScanLine[Y];
    M  := MskBmp.ScanLine[Y];
    for X := aRect.Left to R do begin
      case M[X].R of
        0 : begin
          S1[X].R := (((S2[X].R - S1[X].R) * S2[X].A + S1[X].R shl 8) shr 8) and MaxByte;
          S1[X].G := (((S2[X].G - S1[X].G) * S2[X].A + S1[X].G shl 8) shr 8) and MaxByte;
          S1[X].B := (((S2[X].B - S1[X].B) * S2[X].A + S1[X].B shl 8) shr 8) and MaxByte;
        end;
        MaxByte : begin
          // skip
        end
        else begin
          tmp := ((MaxByte - M[X].R) * S2[X].A) shr 8;
          S1[X].R := (((S2[X].R - S1[X].R) * tmp + S1[X].R shl 8) shr 8) and MaxByte;
          S1[X].G := (((S2[X].G - S1[X].G) * tmp + S1[X].G shl 8) shr 8) and MaxByte;
          S1[X].B := (((S2[X].B - S1[X].B) * tmp + S1[X].B shl 8) shr 8) and MaxByte;
        end;
      end;
    end
  end;
end;

function MakeRotated90(var Bmp : TBitmap; CW : boolean; KillSource : boolean = True) : TBitmap;
var
  X, Y, w, h : integer;
  Dst, Src : TacFast32;
begin
  w := Bmp.Width - 1;
  h := Bmp.Height - 1;
  if Bmp.PixelFormat = pf32bit then begin
    Result := CreateBmp32(h + 1, w + 1);
    Src := TacFast32.Create;
    Dst := TacFast32.Create;
    if Src.Attach(Bmp) and Dst.Attach(Result) then begin
      if CW
        then for Y := 0 to h do for X := 0 to w do Dst[h - Y, X] := Src[X, Y]
        else for Y := 0 to h do for X := 0 to w do Dst[Y, X] := Src[w - X, Y];
    end;
    FreeAndNil(Src);
    FreeAndNil(Dst);
  end
  else Result := nil;
  if KillSource then FreeAndNil(Bmp);
end;

function CreateBmpLike(const Bmp: TBitmap): TBitmap;
begin
  Result := TBitmap.Create;
  Result.Width := Bmp.Width;
  Result.Height := Bmp.Height;
  Result.PixelFormat := Bmp.PixelFormat
end;

function CreateBmp24(const Width, Height : integer) : TBitmap;
begin
  Result := TBitmap.Create;
  Result.PixelFormat := pf32bit;
  Result.HandleType := bmDIB;
  Result.Width  := Width;
  Result.Height := Height;
end;

function CreateBmp32(const Width, Height : integer) : TBitmap;
begin
  Result := TBitmap.Create;
  Result.PixelFormat := pf32bit;
  Result.HandleType := bmDIB;
  Result.Width  := Width;
  Result.Height := Height;
end;

function ChangeColor(ColorBegin, ColorEnd : TColor; i : real) : TColor;
var
  r, g, b : integer;
begin
  r := Round(GetRValue(ColorBegin) - (GetRValue(ColorBegin) - GetRValue(ColorEnd)) * i);
  g := Round(GetGValue(ColorBegin) - (GetGValue(ColorBegin) - GetGValue(ColorEnd)) * i);
  b := Round(GetBValue(ColorBegin) - (GetBValue(ColorBegin) - GetBValue(ColorEnd)) * i);
  Result := RGB(iffi(r > MaxByte, MaxByte, r), iffi(g > MaxByte, MaxByte, g), iffi(b > MaxByte, MaxByte, b));
end;

function AverageColor(ColorBegin, ColorEnd : TsColor) : TsColor;
begin
  Result.R := ((ColorBegin.R - ColorEnd.R) * 127 + ColorEnd.R shl 8) shr 8;
  Result.G := ((ColorBegin.G - ColorEnd.G) * 127 + ColorEnd.G shl 8) shr 8;
  Result.B := ((ColorBegin.B - ColorEnd.B) * 127 + ColorEnd.B shl 8) shr 8;
  Result.A := 0;
end;

function AverageColor(ColorBegin, ColorEnd : TColor) : TColor; overload;
var
  c1, c2 : TsColor;
begin
  c1.C := ColorBegin;
  c2.C := ColorEnd;
  Result := AverageColor(c1, c2).C;
end;

function MixColors(Color1, Color2 : TColor; PercentOfColor1 : real) : TColor;
var
  c1, c2 : TsColor;
begin
  c1.C := Color1;
  c2.C := Color2;
  c1.R := Round((c1.R * PercentOfColor1 + c2.R * (1 - PercentOfColor1)));
  c1.G := Round((c1.G * PercentOfColor1 + c2.G * (1 - PercentOfColor1)));
  c1.B := Round((c1.B * PercentOfColor1 + c2.B * (1 - PercentOfColor1)));
  Result := c1.C;
end;

procedure DrawRectangleOnDC(DC: HDC; var R: TRect; ColorTop, ColorBottom: TColor; var Width: integer);
var
  PenTop, PenBottom, OldPen : hPen;
  OldBrush : hBrush;
  Points : Array [0..2] of TPoint;
  procedure DoRect;
  var
    TopRight, BottomLeft: TPoint;
  begin
    with R do begin
      TopRight.X := Right;
      TopRight.Y := Top;
      BottomLeft.X := Left;
      BottomLeft.Y := Bottom;

      Points[0] := BottomLeft;
      Points[1] := TopLeft;
      Points[2] := TopRight;
      SelectObject(dc, PenTop);
      PolyLine(DC, PPoints(@Points)^, 3);

      Dec(BottomLeft.X);

      Points[0] := TopRight;
      Points[1] := BottomRight;
      Points[2] := BottomLeft;
      SelectObject(dc, PenBottom);
      PolyLine(DC, PPoints(@Points)^, 3);
    end;
  end;
begin
  PenTop := CreatePen(PS_SOLID, 1, ColorToRGB(ColorTop));
  PenBottom := CreatePen(PS_SOLID, 1, ColorBottom);
  OldPen := SelectObject(dc, PenTop);
  OldBrush := SelectObject(dc, GetStockObject(NULL_BRUSH));

  Dec(R.Bottom);
  Dec(R.Right);

  while Width > 0 do begin
    Dec(Width);
    DoRect;
    InflateRect(R, -1, -1);
  end;
  Inc(R.Bottom); Inc(R.Right);

  SelectObject(dc, OldPen);
  SelectObject(dc, OldBrush);
  DeleteObject(PenTop);
  DeleteObject(PenBottom);
end;

procedure TileBitmap(Canvas: TCanvas; aRect: TRect; Graphic: TGraphic);
var
  X, Y, cx, cy, w, h: Integer;
  SavedDC : hdc;
begin
{$IFDEF NOSLOWDETAILS} Exit;{$ENDIF}
  if Graphic = nil then Exit;

  w := Graphic.Width;
  h := Graphic.Height;
  if (w = 0) or (h = 0) then Exit;

  if Graphic is TBitmap then begin
    x := aRect.Left;
    while x < aRect.Right - w do begin
      y := aRect.Top;
      while y < aRect.Bottom - h do begin
        BitBlt(Canvas.Handle, x, y, w, h, TBitmap(Graphic).Canvas.Handle, 0, 0, SRCCOPY);
        inc(y, h);
      end;
      BitBlt(Canvas.Handle, x, y, w, aRect.Bottom - y, TBitmap(Graphic).Canvas.Handle, 0, 0, SRCCOPY);
      inc(x, w);
    end;
    y := aRect.Top;
    while y < aRect.Bottom - h do begin
      BitBlt(Canvas.Handle, x, y, aRect.Right - x, h, TBitmap(Graphic).Canvas.Handle, 0, 0, SRCCOPY);
      inc(y, h);
    end;
    BitBlt(Canvas.Handle, x, y, aRect.Right - x, aRect.Bottom - y, TBitmap(Graphic).Canvas.Handle, 0, 0, SRCCOPY);
  end
  else if Graphic is TJpegImage then begin
    SavedDC := SaveDC(Canvas.Handle);
    IntersectClipRect(Canvas.Handle, aRect.Left, aRect.Top, aRect.Right, aRect.Bottom);
    cx := WidthOf(aRect) div w;
    cy := HeightOf(aRect) div h;
    for X := 0 to cx do for Y := 0 to cy do Canvas.Draw(aRect.Left + X * w, aRect.Top + Y * h, Graphic);
    RestoreDC(Canvas.Handle, SavedDC);
  end;
end;

{$IFNDEF ACHINTS}
procedure TileBitmap(Canvas: TCanvas; var aRect: TRect; Graphic: TGraphic; MaskData : TsMaskData; FillMode : TacFillMode = fmTiled);
var
  X, Y, w, h, NewX, NewY, Tmp: Integer;
  SrcBmp : TBitmap;
begin
{$IFDEF NOSLOWDETAILS} Exit;{$ENDIF}
  if (Graphic = nil) or Graphic.Empty then begin // If bitmap in the MaskData
    if MaskData.Bmp <> nil then SrcBmp := MaskData.Bmp else begin
      if (MaskData.Manager = nil) then Exit else SrcBmp := TsSkinManager(MaskData.Manager).MasterBitmap;
    end;
    w := WidthOf(MaskData.R);
    h := HeightOf(MaskData.R);
    Tmp := 0;
    case FillMode of
      fmStretched : begin
        SetStretchBltMode(Canvas.Handle, COLORONCOLOR);//STRETCH_HALFTONE);
        StretchBlt(Canvas.Handle, aRect.Left, aRect.Top, WidthOf(aRect), HeightOf(aRect),
                   SrcBmp.Canvas.Handle,
                   MaskData.R.Left, MaskData.R.Top, w, h, SRCCOPY);
        aRect := Rect(-1, -1, -1, -1);
      end;
      fmStretchHorz : begin
        SetStretchBltMode(Canvas.Handle, COLORONCOLOR);//STRETCH_HALFTONE);
        StretchBlt(Canvas.Handle, aRect.Left, aRect.Top, WidthOf(aRect), h,
                   SrcBmp.Canvas.Handle,
                   MaskData.R.Left, MaskData.R.Top, w, h, SRCCOPY);
        aRect := Rect(aRect.Left, aRect.Top + h, aRect.Right, aRect.Bottom);
      end;
      fmStretchVert : begin
        SetStretchBltMode(Canvas.Handle, COLORONCOLOR);//STRETCH_HALFTONE);
        StretchBlt(Canvas.Handle, aRect.Left, aRect.Top, w, HeightOf(aRect),
                   SrcBmp.Canvas.Handle,
                   MaskData.R.Left, MaskData.R.Top, w, h, SRCCOPY);
        aRect := Rect(aRect.Left + w, aRect.Top, aRect.Right, aRect.Bottom);
      end;
      fmDisTiled : begin
        x := aRect.Left;
        NewX := aRect.Right - w;
        NewY := aRect.Bottom - h;
        while x < NewX do begin
          y := aRect.Top;
          while y < NewY do begin
            BitBlt(Canvas.Handle, x, y, w, h, SrcBmp.Canvas.Handle, MaskData.R.Left, MaskData.R.Top, SRCCOPY);
            inc(y, h);
          end;
          inc(x, w);
        end;
        y := aRect.Top;
        while y < NewY do begin
          BitBlt(Canvas.Handle, x, y, aRect.Right - x, h, SrcBmp.Canvas.Handle, MaskData.R.Left, MaskData.R.Top, SRCCOPY);
          inc(y, h);
        end;
        aRect := Rect(-1, -1, -1, -1);
      end
      else begin
        x := aRect.Left;
        case FillMode of
          fmTiled : begin
            NewX := aRect.Right - w;
            NewY := aRect.Bottom - h;
          end;
          fmTiledHorz : begin
            NewX := aRect.Right - w;
            NewY := aRect.Top;
          end;
          fmTiledVert : begin
            NewX := aRect.Left;
            NewY := aRect.Bottom - h;
          end;
          fmTileHorBtm : begin
            Tmp := aRect.Top;
            aRect.Top := aRect.Bottom - h;
            NewX := aRect.Right - w;
            NewY := aRect.Top;
          end
          else begin
            Tmp := aRect.Left;
            aRect.Left := aRect.Right - w;
            NewX := aRect.Left;
            NewY := aRect.Bottom - h;
          end;
        end;
        while x < NewX do begin
          y := aRect.Top;
          while y < NewY do begin
            BitBlt(Canvas.Handle, x, y, w, h, SrcBmp.Canvas.Handle, MaskData.R.Left, MaskData.R.Top, SRCCOPY);
            inc(y, h);
          end;
          BitBlt(Canvas.Handle, x, y, w, aRect.Bottom - y, SrcBmp.Canvas.Handle, MaskData.R.Left, MaskData.R.Top, SRCCOPY);
          inc(x, w);
        end;
        y := aRect.Top;
        while y < NewY do begin
          BitBlt(Canvas.Handle, x, y, aRect.Right - x, h, SrcBmp.Canvas.Handle, MaskData.R.Left, MaskData.R.Top, SRCCOPY);
          inc(y, h);
        end;
        BitBlt(Canvas.Handle, x, y, aRect.Right - x, aRect.Bottom - y, SrcBmp.Canvas.Handle, MaskData.R.Left, MaskData.R.Top, SRCCOPY);

        case FillMode of
          fmTiled : aRect := Rect(-1, -1, -1, -1);
          fmTiledHorz : aRect := Rect(aRect.Left, aRect.Top + h, aRect.Right, aRect.Bottom);
          fmTiledVert : aRect := Rect(aRect.Left + w, aRect.Top, aRect.Right, aRect.Bottom);
          fmTileHorBtm : aRect := Rect(aRect.Left, Tmp, aRect.Right, aRect.Bottom - h);
          fmTileVertRight : aRect := Rect(Tmp, arect.Top, aRect.Right - w, aRect.Bottom);
        end;
      end
    end
  end
  else begin
    TileBitmap(Canvas, aRect, Graphic);
    aRect := Rect(-1, -1, -1, -1);
  end;
end;

procedure TileMasked(Bmp: TBitmap; var aRect: TRect; CI : TCacheInfo; MaskData : TsMaskData; FillMode : TacFillMode = fmDisTiled);
var
  X, Y, w, h, NewX, NewY: Integer;
  mr : TRect;
begin
  if MaskData.Manager = nil then Exit;
  w := WidthOf(MaskData.R) div MaskData.ImageCount;
  h := HeightOf(MaskData.R) div 2;
  case FillMode of
    fmTiled : begin
      x := aRect.Left;
      NewX := aRect.Right - w;
      NewY := aRect.Bottom - h;
      mr := MaskData.R;
      while x < NewX do begin
        y := aRect.Top;
        while y < NewY do begin
          CopyMasterRect(Rect(x, y, x + w, y + h), mr, Bmp, CI, MaskData);
          inc(y, h);
        end;
//        BitBlt(Canvas.Handle, x, y, w, aRect.Bottom - y, TsSkinManager(MaskData.Manager).MasterBitmap.Canvas.Handle, MaskData.R.Left, MaskData.R.Top, SRCCOPY);
        inc(x, w);
      end;
      y := aRect.Top;
      while y < NewY do begin
        CopyMasterRect(Rect(x, y, aRect.Right, y + h), mr, Bmp, CI, MaskData);
        inc(y, h);
      end;
//      BitBlt(Canvas.Handle, x, y, aRect.Right - x, aRect.Bottom - y, TsSkinManager(MaskData.Manager).MasterBitmap.Canvas.Handle, MaskData.R.Left, MaskData.R.Top, SRCCOPY);
      aRect := Rect(-1, -1, -1, -1);
    end;
    fmStretched : begin
{        StretchBlt(Canvas.Handle, aRect.Left, aRect.Top, WidthOf(aRect), HeightOf(aRect),
                 TsSkinManager(MaskData.Manager).MasterBitmap.Canvas.Handle,
                 MaskData.R.Left, MaskData.R.Top, w, h, SRCCOPY);
      aRect := Rect(-1, -1, -1, -1);}
    end;
    fmStretchHorz : begin
{        StretchBlt(Canvas.Handle, aRect.Left, aRect.Top, WidthOf(aRect), h,
                 TsSkinManager(MaskData.Manager).MasterBitmap.Canvas.Handle,
                 MaskData.R.Left, MaskData.R.Top, w, h, SRCCOPY);
      aRect := Rect(aRect.Left, aRect.Top + h, aRect.Right, aRect.Bottom);}
    end;
    fmStretchVert : begin
{        StretchBlt(Canvas.Handle, aRect.Left, aRect.Top, w, HeightOf(aRect),
                 TsSkinManager(MaskData.Manager).MasterBitmap.Canvas.Handle,
                 MaskData.R.Left, MaskData.R.Top, w, h, SRCCOPY);
      aRect := Rect(aRect.Left + w, aRect.Top, aRect.Right, aRect.Bottom);}
    end;
    fmDisTiled : begin
      x := aRect.Left;
      NewX := aRect.Right - w;
      NewY := aRect.Bottom - h;
      mr := MaskData.R;
      y := 0;
      while x < NewX do begin
        y := aRect.Top;
        while y < NewY do begin
          CopyMasterRect(Rect(x, y, x + w, y + h), mr, Bmp, CI, MaskData);
          inc(y, h);
        end;
        inc(x, w);
      end;
      if CI.Ready then begin
        BitBlt(Bmp.Canvas.Handle, aRect.Left, y, WidthOf(aRect), aRect.Bottom - y, CI.Bmp.Canvas.Handle, aRect.Left + CI.X, Y + CI.Y, SRCCOPY);
        BitBlt(Bmp.Canvas.Handle, x, aRect.Top, aRect.Right - x, HeightOf(aRect), CI.Bmp.Canvas.Handle, x + CI.X, aRect.Top + CI.Y, SRCCOPY);
      end
      else begin
        if Bmp.PixelFormat = pf32bit then FillRect32(Bmp, Rect(aRect.Left, y, aRect.Right, aRect.Bottom), ci.FillColor) else FillDC(Bmp.Canvas.Handle, Rect(aRect.Left, y, aRect.Right, aRect.Bottom), CI.FillColor);
        if Bmp.PixelFormat = pf32bit then FillRect32(Bmp, Rect(x, aRect.Top, aRect.Right, aRect.Bottom), ci.FillColor) else FillDC(Bmp.Canvas.Handle, Rect(x, aRect.Top, aRect.Right, aRect.Bottom), CI.FillColor);
      end;
      aRect := Rect(-1, -1, -1, -1);
    end
  end
end;

{$ENDIF}

procedure CalcButtonLayout(const Client: TRect; const GlyphSize: TPoint; const TextRectSize: TSize; Layout: TButtonLayout;
            Alignment: TAlignment; Margin, Spacing: Integer; var GlyphPos: TPoint; var TextBounds: TRect; BiDiFlags: LongInt);      {RL}
var
  TextPos, ClientSize, TextSize, TotalSize: TPoint;
  dh : integer;
begin
  if (BiDiFlags and DT_RIGHT) = DT_RIGHT then
    if Layout = blGlyphLeft then Layout := blGlyphRight else if Layout = blGlyphRight then Layout := blGlyphLeft;
  { calculate the item sizes }
  ClientSize := Point(Client.Right - Client.Left, Client.Bottom - Client.Top);

  TextBounds := Rect(0, 0, TextRectSize.cx, TextRectSize.cy);
  TextSize := Point(TextRectSize.cx,TextRectSize.cy);

  { If the layout has the glyph on the right or the left, then both the
    text and the glyph are centered vertically.  If the glyph is on the top
    or the bottom, then both the text and the glyph are centered horizontally.}
  if Layout in [blGlyphLeft, blGlyphRight] then begin
    GlyphPos.Y := (ClientSize.Y - GlyphSize.Y + 1) div 2;
    TextPos.Y := (ClientSize.Y - TextSize.Y + 1) div 2;
  end
  else begin
    GlyphPos.X := (ClientSize.X - GlyphSize.X + 1) div 2;
    TextPos.X := (ClientSize.X - TextSize.X + 1) div 2;
  end;

  { if there is no text or no bitmap, then Spacing is irrelevant }
  if (TextSize.X = 0) or (GlyphSize.X = 0) then Spacing := 0;

  if Margin = -1 then begin // adjust Margin and Spacing
    if Spacing < 0 then begin
      TotalSize := Point(GlyphSize.X + TextSize.X, GlyphSize.Y + TextSize.Y);
      if Layout in [blGlyphLeft, blGlyphRight] then Margin := (ClientSize.X - TotalSize.X) div 3 else Margin := (ClientSize.Y - TotalSize.Y) div 3;
      Spacing := Margin;
    end
    else begin
      TotalSize := Point(GlyphSize.X + Spacing + TextSize.X, GlyphSize.Y + Spacing + TextSize.Y);
      if Alignment = taCenter then begin
        if Layout in [blGlyphLeft, blGlyphRight]
          then Margin := (ClientSize.X - TotalSize.X + 1) div 2
          else Margin := (ClientSize.Y - TotalSize.Y + 1) div 2;
      end
      else Margin := 2;
    end;
  end
  else begin
    if Spacing < 0 then begin
      TotalSize := Point(ClientSize.X - (Margin + GlyphSize.X), ClientSize.Y - (Margin + GlyphSize.Y));
      if Layout in [blGlyphLeft, blGlyphRight] then Spacing := (TotalSize.X - TextSize.X) div 2 else Spacing := (TotalSize.Y - TextSize.Y) div 2;
    end;
  end;

  case Layout of
    blGlyphLeft: begin
      case Alignment of
        taLeftJustify: begin
          GlyphPos.X := Margin;
          TextPos.X := GlyphPos.X + GlyphSize.X + Spacing;
          TextBounds.Right := min(TextRectSize.cx, Client.Right - Margin - TextPos.X);
        end;
        taCenter: begin
          Margin := max((ClientSize.X - TextSize.X - Spacing - GlyphSize.X) div 2, Margin);
          GlyphPos.X := Margin;
          TextPos.X := GlyphPos.X + Spacing + GlyphSize.X;
        end;
        taRightJustify: begin
          TextPos.X := ClientSize.X - Margin - TextSize.X;
          GlyphPos.X := TextPos.X - Spacing - GlyphSize.X;
        end;
      end;
    end;
    blGlyphRight: begin
      case Alignment of
        taLeftJustify: begin
          GlyphPos.X := Margin + TextSize.X + Spacing;
          TextPos.X := GlyphPos.X - Spacing - TextRectSize.cx;
        end;
        taCenter: begin
          Margin := (ClientSize.X - TextSize.X - Spacing - GlyphSize.X) div 2;
          TextPos.X := Margin;
          GlyphPos.X := TextPos.X + Spacing + TextSize.X;
        end;
        taRightJustify: begin
          GlyphPos.X := ClientSize.X - Margin - GlyphSize.X;
          TextPos.X := GlyphPos.X - Spacing - TextRectSize.cx;
        end;
      end;
    end;
    blGlyphTop: begin
      dh := (ClientSize.y - GlyphSize.Y - Spacing - TextRectSize.cy) div 2 - Margin;
      GlyphPos.Y := Margin + dh;
      TextPos.Y := GlyphPos.Y + GlyphSize.Y + Spacing;
    end;
    blGlyphBottom: begin
      dh := (ClientSize.y - GlyphSize.Y - Spacing - TextRectSize.cy) div 2 - Margin;
      GlyphPos.Y := ClientSize.Y - Margin - GlyphSize.Y - dh;
      TextPos.Y := GlyphPos.Y - Spacing - TextSize.Y;
    end;
  end;

  { fixup the result variables }
  with GlyphPos do begin
    Inc(X, Client.Left);
    Inc(Y, Client.Top);
  end;

  OffsetRect(TextBounds, TextPos.X + Client.Left, TextPos.Y + Client.Top);
end;

function GetFontHeight(hFont : HWnd): integer;
var
  DC: HDC;
  SaveFont: LongInt;
  Metrics: TTextMetric;
begin
  DC := GetDC(0);
  try
    SaveFont := SelectObject(DC, hFont);
    GetTextMetrics(DC, Metrics);
    SelectObject(DC, SaveFont);
    Result := Metrics.tmHeight + 6;
  finally
    ReleaseDC(0, DC);
  end;
end;

function GetStringSize(hFont : hgdiobj; const Text : acString): TSize;
var
  DC: HDC;
  SaveFont: LongInt;
begin
  DC := GetDC(0);
  try
    SaveFont := SelectObject(DC, hFont);
{$IFDEF TNTUNICODE}
    if not GetTextExtentPoint32W(DC, PWideChar(Text), Length(Text), Result) then begin
{$ELSE}
    if not GetTextExtentPoint32(DC, PChar(Text), Length(Text), Result) then begin
{$ENDIF}
      Result.cx := 0;
      Result.cy := 0;
    end;
    SelectObject(DC, SaveFont);
  finally
    ReleaseDC(0, DC);
  end;
end;                             

function LoadJpegOrBmp(Image: TPicture; const FileName: string; Gray: boolean):boolean;
var
  s: string;
  j: TJpegImage;
begin
  Result := False;
  if FileExists(FileName) then begin
    s := ExtractFileExt(FileName);
    if (UpperCase(s)='.JPG') or (UpperCase(s)='.JPEG') then begin
      j := TJPEGImage.Create;
      try
      j.LoadFromFile(FileName);
      j.Grayscale := Gray;
      Image.Assign(TGraphic(j));
      finally
        FreeAndNil(j);
      end;
    end
    else if (UpperCase(s)='.BMP') then begin
      Image.LoadFromFile(FileName);
      Image.Bitmap.PixelFormat := pf32Bit;
      if Gray then GrayScale(Image.Bitmap);
    end;
  end
  else begin
    Image.Assign(nil);
  end;
end;

procedure FocusRect(Canvas : TCanvas; R : TRect; LightColor : TColor = clBtnFace; DarkColor : TColor = clBlack);
var
  x, y, dx, dy : integer;
begin
  dx := WidthOf(R) div 3;
  dy := HeightOf(R) div 3;

  dec(R.Right);
  dec(R.Bottom);
  for x := 0 to dx do begin
    Canvas.Pixels[R.Left + 3 * x, R.Top] := DarkColor;
    Canvas.Pixels[R.Left + 3 * x, R.Bottom] := DarkColor;

    Canvas.Pixels[R.Left + 3 * x - 1, R.Top] := LightColor;
    Canvas.Pixels[R.Left + 3 * x - 1, R.Bottom] := LightColor;
  end;
  for y := 0 to dy do begin
    Canvas.Pixels[R.Left, R.Top + 3 * y] := DarkColor;
    Canvas.Pixels[R.Right, R.Top + 3 * y] := DarkColor;

    Canvas.Pixels[R.Left, R.Top + 3 * y - 1] := LightColor;
    Canvas.Pixels[R.Right, R.Top + 3 * y - 1] := LightColor;
  end;
end;

{ Scale }

type
  TContributor = packed record
    Pixel : Integer;
    Weight : Integer;
  end;
  TContributorList = array[0..0] of TContributor;
  PContributorList = ^TContributorList;
  TCList = packed record
    Count : Integer;
    Data : PContributorList;
  end;
  TCListList = array[0..0] of TCList;
  PCListList = ^TCListList;
  TRGBTripleArray = array[0..0] of TRGBTriple;
  PRGBTripleArray = ^TRGBTripleArray;
  TDrawProc = procedure(Count : Integer; Contributes : PCListList; srcLine, dstLine : Pointer; dstDelta, srcDelta : Integer); pascal;

procedure CreateContributors(var Contrib : PCListList; Size : Integer; MaxSize : Integer; Filter : TFilterType; Delta : Integer);
var
  A, B, Count : Integer;
  Scale2 : Single;
  AWidth : Single;
  Param, W : Single;
  Center : Single;
  CSize : Integer;
  Data : PContributorList;
const
  CFilters : array [TFilterType] of Single = (0.51, 1, 1, 1.5, 2, 3, 2);
begin
{$T-}
{$R-}
  Contrib := nil;
  if MaxSize > Size then Scale2 := Size / MaxSize else Scale2 := 1;
  AWidth := CFilters[Filter] / Scale2;
  CSize := Trunc(AWidth * 2 + 1) * SizeOf(TContributor);
  GetMem(Contrib, Size * (SizeOf(TCList) + CSize));
  Data := @PAnsiChar(Contrib)[Size * SizeOf(TCList)];
  for A := 0 to Size - 1 do begin
    Count := 0;
    Center := A * MaxSize / Size;
    for B := Floor(Center - AWidth) to Ceil(Center + AWidth) do begin
      Param := Abs(Center - B) * Scale2;
      if Param >= CFilters[Filter] then Continue;
      case Filter of
        ftBox: if (Param <= 0.5) and ((Center - B) * Scale2 <> -0.5) then W := 1.0 else W := 0.0;
        ftTriangle : W := 1.0 - Param;
        ftHermite : W := (2.0 * Param - 3.0) * Sqr(Param) + 1.0;
        ftBell: if Param < 0.5 then W := 0.75 - Sqr(Param) else W := Sqr(Param - 1.5) * 0.5;
        ftSpline: if Param < 1.0 then W := 2 / 3 + Sqr(Param) * (Param * 0.5 - 1.0) else W := Sqr(2 - Param) * (2 - Param) * (1 / 6);
        ftLanczos3: if Param <> 0.0 then W := Sin(Param * Pi) * Sin(Param) / (Sqr(Param) * Pi) else W := 1.0;
        ftMitchell: if Param < 1.0 then W := Sqr(Param) * (7 / 6 * Param - 2) + 8 / 9 else W := Sqr(Param) * ((-7 / 18) * Param + 2.0) - 10 / 3 * Param + 16 / 9;
        else W := 0.0;
      end;
      if W = 0.0 then Continue;
      with Data[Count] do begin
        if B < 0 then Pixel := -B else if B >= MaxSize then Pixel := 2 * MaxSize - B - 1 else Pixel := B;
        Pixel := Pixel * Delta;
        Weight := Round(W * Scale2 * 65536);
      end;
      Inc(Count);
    end;
    Contrib[A].Count := Count;
    Contrib[A].Data := Data;
    Inc(DWORD(Data), CSize);
  end;
{$R+}
{$T+}
end;

procedure FreeContributors(var Contrib : PCListList);
begin
  if Assigned(Contrib) then begin
    FreeMem(Contrib);
    Contrib := nil;
  end;
end;

procedure DrawLine24Pas(Count : Integer; Contributes : PCListList; srcLine, dstLine : Pointer; dstDelta, srcDelta : Integer); pascal;
var
  r, g, B : Integer;
  A, X : Integer;
  Src, Dest : PRGBTriple;
begin
{$R-}
  Dest := dstLine;
  for X := 0 to Count - 1 do begin
    r := 0;
    g := 0;
    B := 0;
    for A := 0 to Contributes[X].Count - 1 do
      with Contributes[X].Data[A] do begin
        Src := PRGBTriple(Integer(srcLine) + Pixel);
        if Weight <> 0 then begin
          Inc(r, Src.rgbtRed * Weight);
          Inc(g, Src.rgbtGreen * Weight);
          Inc(B, Src.rgbtBlue * Weight);
        end;
      end;
    if r < 0 then Dest.rgbtRed := 0 else if r > $FF0000 then Dest.rgbtRed := $FF else Dest.rgbtRed := r shr 16;
    if g < 0 then Dest.rgbtGreen := 0 else if g > $FF0000 then Dest.rgbtGreen := $FF else Dest.rgbtGreen := g shr 16;
    if B < 0 then Dest.rgbtBlue := 0 else if B > $FF0000 then Dest.rgbtBlue := $FF else Dest.rgbtBlue := B shr 16;
    if DWORD(Dest) + dstDelta < MAXDWORD then DWORD(Dest) := DWORD(DWORD(Dest) + dstDelta)
  end;
{$R+}
end;

procedure DrawLine32Pas(Count : Integer; Contributes : PCListList; srcLine, dstLine : Pointer; dstDelta, srcDelta : Integer); pascal;
var
  r, g, B, AA : Integer;
  A, X : Integer;
  Src, Dest : PRGBQUAD;
begin
{$R-}
  Dest := dstLine;
  for X := 0 to Count - 1 do begin
    r := 0;
    g := 0;
    B := 0;
    AA := 0;
    for A := 0 to Contributes[X].Count - 1 do with Contributes[X].Data[A] do begin
      Src := PRGBQuad(Integer(srcLine) + Pixel);
      if Weight <> 0 then begin
        Inc(r, Src.rgbRed * Weight);
        Inc(g, Src.rgbGreen * Weight);
        Inc(B, Src.rgbBlue * Weight);
        Inc(AA, Src.rgbReserved * Weight);
      end;
    end;
    if r < 0 then Dest.rgbRed := 0 else if r > $FF0000 then Dest.rgbRed := $FF else Dest.rgbRed := r shr 16;
    if g < 0 then Dest.rgbGreen := 0 else if g > $FF0000 then Dest.rgbGreen := $FF else Dest.rgbGreen := g shr 16;
    if B < 0 then Dest.rgbBlue := 0 else if B > $FF0000 then Dest.rgbBlue := $FF else Dest.rgbBlue := B shr 16;
    if AA < 0 then Dest.rgbReserved := 0 else if AA > $FF0000 then Dest.rgbReserved := $FF else Dest.rgbReserved := AA shr 16;
    if DWORD(Dest) + dstDelta < MAXDWORD then DWORD(Dest) := DWORD(DWORD(Dest) + dstDelta)
  end;
{$R+}
end;

procedure Stretch(const Src, Dst : TBitmap; const Width, Height : Integer; Filter : TFilterType; Param : Integer = 0);
var
  A : Integer;
  Contrib : PCListList;
  Work : TBitmap;
  SourceLine : Pointer;
  Delta : Integer;
  DestLine : Pointer;
  DestDelta : Integer;
  SrcWidth : Integer;
  SrcHeight : Integer;
  SrcPixelFormat : TPixelFormat;
  BytePerPixel : Integer;
  DrawLine : TDrawProc;
begin
  if Height = 0 then Exit;
  SrcWidth := Src.Width;
  SrcHeight := Src.Height;
  if Src.PixelFormat = pf32bit then begin
    BytePerPixel := 4;
    DrawLine := DrawLine32Pas;
    SrcPixelFormat := pf32bit;
  end
  else begin
    BytePerPixel := 3;
    DrawLine := DrawLine24Pas;
    SrcPixelFormat := pf24bit;
  end;
  if (SrcWidth < 2) or (SrcHeight < 2) then
    raise Exception.Create('Source bitmap is too small');
  if (SrcWidth <> Width) or (SrcHeight <> Height) then begin
    Work := TBitmap.Create;
    try
      Work.Height := SrcHeight;
      Work.Width := Width;
      Src.PixelFormat := SrcPixelFormat;
      Work.PixelFormat := SrcPixelFormat;
      SourceLine := Src.ScanLine[0];
      Delta := PAnsiChar(Src.ScanLine[1]) - PAnsiChar(SourceLine);
      DestLine := Work.ScanLine[0];
      DestDelta := PAnsiChar(Work.ScanLine[1]) - PAnsiChar(DestLine);
      CreateContributors(Contrib, Width, SrcWidth, Filter, BytePerPixel);
      try
        for A := 0 to SrcHeight - 1 do begin
          DrawLine(Width, Contrib, SourceLine, DestLine, BytePerPixel, BytePerPixel);
          Inc(PAnsiChar(SourceLine), Delta);
          Inc(PAnsiChar(DestLine), DestDelta);
        end;
      finally
        FreeContributors(Contrib);
      end;

      Dst.Width := Width;
      Dst.Height := Height;
      Dst.PixelFormat := SrcPixelFormat;
      SourceLine := Work.ScanLine[0];
      Delta := PAnsiChar(Work.ScanLine[1]) - PAnsiChar(SourceLine);
      DestLine := Dst.ScanLine[0];
      DestDelta := PAnsiChar(Dst.ScanLine[1]) - PAnsiChar(DestLine);

      CreateContributors(Contrib, Height, SrcHeight, Filter, Delta);
      try
        for A := 0 to Width - 1 do begin
          DrawLine(Height, Contrib, SourceLine, DestLine, DestDelta, Delta);
          Inc(DWORD(SourceLine), BytePerPixel);
          Inc(DWORD(DestLine), BytePerPixel);
        end;
      finally
        FreeContributors(Contrib);
      end;
    finally
      FreeAndNil(Work);
    end;
  end
  else if Dst <> Src then Dst.Assign(Src);
end;

initialization
  if @UpdateLayeredWindow = nil then begin
    User32Lib := LoadLibrary(user32);
    if User32Lib <> 0 then begin
      UpdateLayeredWindow := GetProcAddress(User32Lib, 'UpdateLayeredWindow');
      SetLayeredWindowAttributes := GetProcAddress(User32Lib, 'SetLayeredWindowAttributes');
    end
    else begin
      @UpdateLayeredWindow := nil;
      @SetLayeredWindowAttributes := nil;
    end;
  end;
  GetCheckSize;

finalization
  if User32Lib <> 0 then FreeLibrary(User32Lib);

end.



