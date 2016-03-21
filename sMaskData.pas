unit sMaskData;
{$I sDefs.inc}

interface

uses Windows, Graphics, sConst, jpeg;

type

  TsMaskData = record
    Bmp          : TBitmap;
    ClassName    : string;
    PropertyName : string;
    R            : TRect;             // Rectangle of the image piece in MasterBitmap
    ImageCount   : smallint;          // Count of States, allowed for control (count of images in piece)
    MaskType     : smallint;          // Type of used mask (0 - not used, 1 - AlphaMask, 2... - reserved)
    BorderWidth  : smallint;
    DrawMode     : smallint;          // Fill type if ImgType is texture
    ImgType      : TacImgType;        // itisaBorder, itisaTexture, itisaGlyph //, itisanOldType (default)
    Manager      : TObject;

    WL           : smallint;          // Border width / Left
    WT           : smallint;          // Top
    WR           : smallint;          // Right
    WB           : smallint;          // Bottom
  end;

  PsMaskData = ^TsMaskData;

  TsPatternData = record
    Img          : TJPegImage;
    ClassName    : string;
    PropertyName : string;
  end;

  TsFontColor = record
    Color : TColor;                        // Text color
    Left : TColor;                         // Colors
    Top : TColor;                          //   of 
    Right : TColor;                        //     text
    Bottom : TColor;                       //        contours
  end;

  TsGenState = record
    Color : TColor;                        // Color of background 
    FontColor : TsFontColor;               // Text color structure
    GradientPercent : integer;             // Percent of gradient in BG
    GradientData : string;
    GradientArray : TsGradArray;
    ImagePercent : integer;                // Percent of texture in BG
    GlowColor : TColor;                    // Color of text glowing
    GlowSize : byte;                       // Size of text glowing
    Transparency : integer;                // Transparency of control
  end;
  
  TsProps = array[0..1] of TsGenState;     // Array of properties for different states of control (0 - normal, 1 - active)
  
  TsGeneralData = record
    ParentClass : string;                  // Name of parent skin section (if exists)
    ClassName : string;                    // Name of skin section
    States : integer;                      // Count of defined control states
    Props : TsProps;                       // Array of properties for different control states  

    GiveOwnFont : boolean;                 // Gives own font color for transparent child
    ReservedBoolean : boolean;             // Reserved
    ShowFocus : boolean;
    // Text Glow
    GlowCount : integer;                   // Reserved
    GlowMargin : integer;                  // Margin for glowing effect
    // Initialized values
    BorderIndex : integer;                 // Index of border mask
    ImgTL : integer;                       // Indexes
    ImgTR : integer;                       //    of 
    ImgBL : integer;                       //     corner 
    ImgBR : integer;                       //      images

    // <<< Deprecated properties (use Props array)    
    Color : TColor;
    Transparency : integer;
    GradientPercent : integer;
    GradientData : string;
    GradientArray : TsGradArray;
    ImagePercent : integer;
    FontColor : array [1..5] of integer;
    
    HotColor : TColor;
    HotTransparency : integer;
    HotGradientPercent : integer;
    HotGradientData : string;
    HotGradientArray : TsGradArray;
    HotImagePercent : integer;
    HotFontColor : array [1..5] of integer;
    // Fading properties will be common for all controls later
    FadingEnabled : boolean;
    FadingIterations : integer;

    HotGlowColor : TColor;
    GlowColor : TColor;
    HotGlowSize : byte;                    
    GlowSize : byte;                       
    // >>>
  end;

  TsMaskArray = array of TsMaskData;
  TsPatternArray = array of TsPatternData;
  TsGeneralDataArray = array of TsGeneralData;

function WidthOfImage(const md : TsMaskData) : integer;
function HeightOfImage(const md : TsMaskData) : integer;

implementation

uses acntUtils;

function WidthOfImage(const md : TsMaskData) : integer;
begin
  case md.ImageCount of
    0 : Result := 0;
    1 : Result := WidthOf(md.R);
    else Result := WidthOf(md.R) div md.ImageCount
  end;
end;

function HeightOfImage(const md : TsMaskData) : integer;
begin
  case md.MaskType of
    -1 : Result := 0;
    0 : Result := HeightOf(md.R);
    1 : Result := HeightOf(md.R) div 2;
    else Result := HeightOf(md.R) div (md.MaskType + 1)
  end;
end;

end.
