unit sGradient;
{$I sDefs.inc}

interface

uses
  windows, Graphics, Classes, Controls, SysUtils, StdCtrls, sConst, math, Dialogs, Forms, Messages, extctrls, IniFiles, sMaskData;

// Fills bitmap by custom properties of Gradient
procedure PaintGrad(Bmp: TBitMap; const aRect : TRect; const Gradient : string); overload;
procedure PaintGrad(Bmp: TBitMap; aRect : TRect; const Data : TsGradArray; OffsetX : integer = 0; OffsetY : integer = 0); overload;
procedure PaintGradTxt(Bmp: TBitMap; aRect : TRect; const Data : TsGradArray; TextureBmp : TBitmap; TextureRect : TRect; TextureAlpha : byte);
procedure PrepareGradArray(const GradientStr : string; var GradArray : TsGradArray);

implementation

uses acntUtils, sAlphaGraph;

type
  TRIVERTEX = packed record
    X, Y : DWORD;
    Red, Green, Blue, Alpha : Word;
  end;

var
  GradientFillAC : function(DC : hDC; pVertex : Pointer; dwNumVertex : DWORD; pMesh : Pointer; dwNumMesh, dwMode: DWORD): DWORD; stdcall; //external 'msimg32.dll' name 'GradientFill';

procedure PaintGrad(Bmp: TBitMap; const aRect : TRect; const Gradient : string);
var
  ga : TsGradArray;
begin
  PrepareGradArray(Gradient, ga);
  PaintGrad(Bmp, aRect, ga);
end;

procedure PaintGrad(Bmp: TBitMap; aRect : TRect; const Data : TsGradArray; OffsetX : integer = 0; OffsetY : integer = 0);
var
  SSrc1, SSrc : PRGBAArray;
  i, dX, dY, w, h: Integer;
  R, G, B : single;
  RStep, GStep, BStep, p : real;
  Color1, Color2 : TsColor;
  CurrentColor : TsColor_;
  C : TsColor;
  Count, Percent, CurrentX, MaxX, CurrentY, MaxY : integer;
  Y, X : integer;
  vert : array[0..4] of TRIVERTEX;
  gRect: array[0..3] of GRADIENT_TRIANGLE;
begin
  if IsRectEmpty(aRect) then Exit;

  if aRect.Right > Bmp.Width then aRect.Right := Bmp.Width;
  if aRect.Bottom > Bmp.Height then aRect.Bottom := Bmp.Height;
  if aRect.Left < 0 then aRect.Left := 0;
  if aRect.Top < 0 then aRect.Top := 0;
  CurrentColor.A := MaxByte;

  Count := Length(Data) - 1; if Count < 0 then Exit;

  case Data[0].Mode1 of
    0 : begin
      C.A := MaxByte;
      MaxY := aRect.Top + OffsetY;
      w := min(WidthOf(aRect) + aRect.Left, bmp.Width) - 1;
      dX := (w - aRect.Left + 1);
      for i := 0 to Count do begin
        Color1.C := Data[i].Color1;
        Color2.C := Data[i].Color2;
        Percent := Data[i].Percent;
        CurrentY := MaxY;
        MaxY := CurrentY + ((HeightOf(aRect) + OffsetY) * Percent) div 100;
        if i = Count
          then MaxY := min(aRect.Bottom, Bmp.Height) - 1
          else MaxY := min(MaxY, min(aRect.Bottom, Bmp.Height) - 1);
        if MaxY - CurrentY > 0 then begin
          R := Color1.R;
          G := Color1.G;
          B := Color1.B;
          if (i = Count) or (MaxY > bmp.Height - 1) then MaxY := min(aRect.Bottom - 1, bmp.Height - 1);
          dY := MaxY - CurrentY;
          if dY = 0 then Exit;
          if Color1.C = Color2.C then begin
            CurrentColor.R := Color1.R;
            CurrentColor.G := Color1.G;
            CurrentColor.B := Color1.B;
            for Y := CurrentY to MaxY do begin
              SSrc := Bmp.ScanLine[Y];
              FillLongword(SSrc[aRect.Left], dX, Cardinal(CurrentColor.C));
            end
          end
          else begin
            RStep := (Color2.R - Color1.R) / dY;
            GStep := (Color2.G - Color1.G) / dY;
            BStep := (Color2.B - Color1.B) / dY;
            for Y := CurrentY to MaxY do begin
              CurrentColor.R := Round(R);
              CurrentColor.G := Round(G);
              CurrentColor.B := Round(B);
              SSrc := Bmp.ScanLine[Y];
              FillLongword(SSrc[aRect.Left], dX, Cardinal(CurrentColor.C));
              R := R + RStep;
              G := G + GStep;
              B := B + BStep;
            end
          end;
        end;
      end;
    end;
    1 : begin
      p := WidthOf(aRect) / 100;
      if Bmp.PixelFormat = pf32bit then begin
        SSrc1 := Bmp.ScanLine[aRect.Top];
        // Paint first line
        MaxX := aRect.Left;
        for i := 0 to Count do begin
          Color1.C := Data[i].Color1;
          Color2.C := Data[i].Color2;
          Percent := Data[i].Percent;
          CurrentX := MaxX;
          MaxX := Round(CurrentX + (p * Percent));
          if i = Count then MaxX := min(aRect.Right, Bmp.Width) - 1 else MaxX := min(MaxX, min(aRect.Right, Bmp.Width) - 1);
          if MaxX - CurrentX > 0 then begin
            dX := MaxX - CurrentX;
            R := Color1.R;
            G := Color1.G;
            B := Color1.B;
            RStep := (Color2.R - Color1.R) / dX;
            GStep := (Color2.G - Color1.G) / dX;
            BStep := (Color2.B - Color1.B) / dX;
            for X := CurrentX to MaxX do begin
              CurrentColor.R := Round(R);
              CurrentColor.G := Round(G);
              CurrentColor.B := Round(B);
              SSrc1[X] := CurrentColor;
              R := R + RStep;
              G := G + GStep;
              B := B + BStep;
            end;
          end;
        end;
        // Clone lines
        w := WidthOf(aRect);
        h := 1;
        if w > 0 then for CurrentY := aRect.Top + 1 to aRect.Bottom - 1 do begin
          BitBlt(Bmp.Canvas.Handle, aRect.Left, CurrentY, w, h, Bmp.Canvas.Handle, aRect.Left, aRect.Top, SRCCOPY);
        end;
      end
      else begin
        for CurrentY := aRect.Top to aRect.Bottom - 1 do begin
          SSrc := Bmp.ScanLine[CurrentY];
          MaxX := aRect.Left;
          for i := 0 to Count do begin
            Color1.C := Data[i].Color1;
            Color2.C := Data[i].Color2;
            Percent := Data[i].Percent;
            CurrentX := MaxX;
            MaxX := Round(CurrentX + (p * Percent));
            if i = Count then MaxX := min(aRect.Right, Bmp.Width) - 1 else MaxX := min(MaxX, min(aRect.Right, Bmp.Width) - 1);
            if MaxX - CurrentX > 0 then begin
              dX := MaxX - CurrentX;
              R := Color1.R;
              G := Color1.G;
              B := Color1.B;
              RStep := (Color2.R - Color1.R) / dX;
              GStep := (Color2.G - Color1.G) / dX;
              BStep := (Color2.B - Color1.B) / dX;
              for X := CurrentX to MaxX do begin
                CurrentColor.R := Round(R);
                CurrentColor.G := Round(G);
                CurrentColor.B := Round(B);
                SSrc[X] := CurrentColor;
                R := R + RStep;
                G := G + GStep;
                B := B + BStep;
              end;
            end;
          end;
        end;
      end;
    end;
    2 : begin // Triangles
      if Count > -1 then c.C := Data[0].Color1 else c.C := 0;
      // Left-top
      vert[0].Alpha := $FF00;
      vert[0].x := aRect.Left;
      vert[0].y:= aRect.Top;
      vert[0].Red := c.R shl 8;
      vert[0].Green := c.G shl 8;
      vert[0].Blue := c.B shl 8;

      if Count > 0 then c.C := Data[1].Color1;
      // Center
      vert[1].Alpha := $FF00;
      vert[1].x := aRect.Left + WidthOf(aRect) div 2;
      vert[1].y:= aRect.Top + HeightOf(aRect) div 2;
      vert[1].Red := c.R shl 8;
      vert[1].Green := c.G shl 8;
      vert[1].Blue := c.B shl 8;

      if Count > 1 then c.C := Data[2].Color1;
      // Right-top
      vert[2].Alpha := $FF00;
      vert[2].x := aRect.Right;
      vert[2].y:= aRect.Top;
      vert[2].Red := c.R shl 8;
      vert[2].Green := c.G shl 8;
      vert[2].Blue := c.B shl 8;

      if Count > 2 then c.C := Data[3].Color1;
      // Right-bottom
      vert[3].Alpha := $FF00;
      vert[3].x := aRect.Right;
      vert[3].y:= aRect.Bottom;
      vert[3].Red := c.R shl 8;
      vert[3].Green := c.G shl 8;
      vert[3].Blue := c.B shl 8;

      if Count > 3 then c.C := Data[4].Color1;
      // Left-bottom
      vert[4].Alpha := $FF00;
      vert[4].x := aRect.Left;
      vert[4].y:= aRect.Bottom;
      vert[4].Red := c.R shl 8;
      vert[4].Green := c.G shl 8;
      vert[4].Blue := c.B shl 8;

      gRect[0].Vertex1 := 0; // Top
      gRect[0].Vertex2 := 1;
      gRect[0].Vertex3 := 2;

      gRect[1].Vertex1 := 1; // Right
      gRect[1].Vertex2 := 2;
      gRect[1].Vertex3 := 3;

      gRect[2].Vertex1 := 0; // Left
      gRect[2].Vertex2 := 1;
      gRect[2].Vertex3 := 4;

      gRect[3].Vertex1 := 4; // Bottom
      gRect[3].Vertex2 := 1;
      gRect[3].Vertex3 := 3;

      if Assigned(GradientFillAC) then GradientFillAC(Bmp.Canvas.Handle, @vert, 5, @gRect, 4, GRADIENT_FILL_TRIANGLE);
    end;
  end;
end;

procedure PaintGradTxt(Bmp: TBitMap; aRect : TRect; const Data : TsGradArray; TextureBmp : TBitmap; TextureRect : TRect; TextureAlpha : byte);
var
  SSrc1, SSrc, STxt : PRGBAArray;
  i, w, h, dX, dY, TxtX, TxtY, TxtW, TxtH: Integer;
  R, G, B : single;
  RStep, GStep, BStep, p : real;
  Color1, Color2 : TsColor;
  CurrentColor, TxtColor, C_ : TsColor_;
  C : TsColor;
  Count, Percent, CurrentX, MaxX, CurrentY, MaxY : integer;
  Y, X : integer;
begin
  if IsRectEmpty(aRect) then Exit;

  if aRect.Right > Bmp.Width then aRect.Right := Bmp.Width;
  if aRect.Bottom > Bmp.Height then aRect.Bottom := Bmp.Height;
  if aRect.Left < 0 then aRect.Left := 0;
  if aRect.Top < 0 then aRect.Top := 0;
  CurrentColor.A := MaxByte;
  C_.A := MaxByte;
  if IsRectEmpty(TextureRect) then TextureRect := Rect(0, 0, TextureBmp.Width, TextureBmp.Height); // Compatibility with old skins
  TxtW := WidthOf(TextureRect, True);
  TxtH := HeightOf(TextureRect, True);
  if TextureRect.Top + TxtH > TextureBmp.Height - 1 then TxtH := TextureBmp.Height - 1 - TextureRect.Top;
  if TextureRect.Left + TxtW > TextureBmp.Width - 1 then TxtW := TextureBmp.Width - 1 - TextureRect.Left;
  if (TxtH < 0) or (TxtW < 0) then Exit;

  Count := Length(Data) - 1; if Count < 0 then Exit;

  case Data[0].Mode1 of
    0 : begin
      C.A := MaxByte;
      MaxY := aRect.Top;
      for i := 0 to Count do begin
        Color1.C := Data[i].Color1;
        Color2.C := Data[i].Color2;
        Percent := Data[i].Percent;
        CurrentY := MaxY;
        MaxY := CurrentY + ((HeightOf(aRect)) * Percent) div 100;
        if i = Count
          then MaxY := min(aRect.Bottom, Bmp.Height) - 1
          else MaxY := min(MaxY, min(aRect.Bottom, Bmp.Height) - 1);
        if MaxY - CurrentY > 0 then begin
          R := Color1.R;
          G := Color1.G;
          B := Color1.B;
          if (i = Count) or (MaxY > bmp.Height - 1) then MaxY := min(aRect.Bottom - 1, bmp.Height - 1);
          dY := MaxY - CurrentY;
          if dY = 0 then Exit;
          w := min(WidthOf(aRect) + aRect.Left, bmp.Width) - 1;
          RStep := (Color2.R - Color1.R) / dY;
          GStep := (Color2.G - Color1.G) / dY;
          BStep := (Color2.B - Color1.B) / dY;
          for Y := CurrentY to MaxY do begin
            CurrentColor.R := Round(R);
            CurrentColor.G := Round(G);
            CurrentColor.B := Round(B);
            SSrc := Bmp.ScanLine[Y];
            STxt := TextureBmp.ScanLine[TextureRect.Top + Y mod TxtH];
            for X := aRect.Left to aRect.Right - 1 do begin
              TxtColor := STxt[TextureRect.Left + X mod TxtW];
              C_.R := (((TxtColor.R - CurrentColor.R) * TextureAlpha + CurrentColor.R shl 8) shr 8) and MaxByte;
              C_.G := (((TxtColor.G - CurrentColor.G) * TextureAlpha + CurrentColor.G shl 8) shr 8) and MaxByte;
              C_.B := (((TxtColor.B - CurrentColor.B) * TextureAlpha + CurrentColor.B shl 8) shr 8) and MaxByte;
              SSrc[X] := C_
            end;

            R := R + RStep;
            G := G + GStep;
            B := B + BStep;
          end
        end;
      end;
    end;
    1 : begin
      p := WidthOf(aRect) / 100;

      SSrc1 := Bmp.ScanLine[aRect.Top];
      // Paint first line
      MaxX := aRect.Left;
      for i := 0 to Count do begin
        Color1.C := Data[i].Color1;
        Color2.C := Data[i].Color2;
        Percent := Data[i].Percent;
        CurrentX := MaxX;
        MaxX := Round(CurrentX + (p * Percent));
        if i = Count then MaxX := min(aRect.Right, Bmp.Width) - 1 else MaxX := min(MaxX, min(aRect.Right, Bmp.Width) - 1);
        if MaxX - CurrentX > 0 then begin
          dX := MaxX - CurrentX;
          R := Color1.R;
          G := Color1.G;
          B := Color1.B;
          RStep := (Color2.R - Color1.R) / dX;
          GStep := (Color2.G - Color1.G) / dX;
          BStep := (Color2.B - Color1.B) / dX;
          for X := CurrentX to MaxX do begin
            CurrentColor.R := Round(R);
            CurrentColor.G := Round(G);
            CurrentColor.B := Round(B);
            SSrc1[X] := CurrentColor;
            R := R + RStep;
            G := G + GStep;
            B := B + BStep;
          end;
        end;
      end;
      h := min(TxtH, HeightOf(aRect, True)) - 1;
      // Clone lines with using a texture
      for CurrentY := aRect.Top + 1 to h + aRect.Top do begin
        SSrc := Bmp.ScanLine[CurrentY];
        STxt := TextureBmp.ScanLine[TextureRect.Top + CurrentY mod TxtH];
        for X := aRect.Left to aRect.Right - 1 do begin
          TxtColor := STxt[TextureRect.Left + X mod TxtW];
          CurrentColor := SSrc1[X];
          CurrentColor.R := (((TxtColor.R - CurrentColor.R) * TextureAlpha + CurrentColor.R shl 8) shr 8) and MaxByte;
          CurrentColor.G := (((TxtColor.G - CurrentColor.G) * TextureAlpha + CurrentColor.G shl 8) shr 8) and MaxByte;
          CurrentColor.B := (((TxtColor.B - CurrentColor.B) * TextureAlpha + CurrentColor.B shl 8) shr 8) and MaxByte;
          SSrc[X] := CurrentColor
        end;
      end;
      // Texture for the first line
      CurrentY := aRect.Top;
      STxt := TextureBmp.ScanLine[TextureRect.Top + CurrentY mod TxtH];
      for X := aRect.Left to aRect.Right - 1 do begin
        TxtColor := STxt[TextureRect.Left + X mod TxtW];
        CurrentColor := SSrc1[X];
        CurrentColor.R := (((TxtColor.R - CurrentColor.R) * TextureAlpha + CurrentColor.R shl 8) shr 8) and MaxByte;
        CurrentColor.G := (((TxtColor.G - CurrentColor.G) * TextureAlpha + CurrentColor.G shl 8) shr 8) and MaxByte;
        CurrentColor.B := (((TxtColor.B - CurrentColor.B) * TextureAlpha + CurrentColor.B shl 8) shr 8) and MaxByte;
        SSrc1[X] := CurrentColor
      end;

      CurrentY := aRect.Top + h;
      w := WidthOf(aRect);
      if w > 0 then while CurrentY < aRect.Bottom - 1 - h do begin
        BitBlt(Bmp.Canvas.Handle, aRect.Left, CurrentY, w, h, Bmp.Canvas.Handle, aRect.Left, aRect.Top, SRCCOPY);
        inc(CurrentY, h);
      end;
      if CurrentY < aRect.Bottom - 1 then BitBlt(Bmp.Canvas.Handle, aRect.Left, CurrentY, w, aRect.Bottom - 1 - CurrentY, Bmp.Canvas.Handle, aRect.Left, aRect.Top, SRCCOPY);
    end;
  end;
end;

procedure PrepareGradArray(const GradientStr : string; var GradArray : TsGradArray);
var
  Count, i : integer;
begin
  SetLength(GradArray, 0);
  if GradientStr = '' then Exit;

  Count := WordCount(GradientStr, [';']) div 5;
  SetLength(GradArray, Count);
  for i := 0 to Count - 1 do begin
    GradArray[i].Color1 := max(0, StrToInt(ExtractWord(i * 5 + 1, GradientStr, [';'])));
    GradArray[i].Color2 := max(0, StrToInt(ExtractWord(i * 5 + 2, GradientStr, [';'])));
    GradArray[i].Percent := max(0, min(100, StrToInt(ExtractWord(i * 5 + 3, GradientStr, [';']))));
    GradArray[i].Mode1 := StrToInt(ExtractWord(i * 5 + 4, GradientStr, [';']));
  end;
end;

var
  hmsimg32: HMODULE = 0;

initialization
  hmsimg32 := LoadLibrary('msimg32.dll');
  if hmsimg32 <> 0 then GradientFillAC := GetProcAddress(hmsimg32, 'GradientFill');

finalization
  if hmsimg32 <> 0 then FreeLibrary(hmsimg32);
end.


