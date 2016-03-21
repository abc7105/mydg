object fmxmgl: Tfmxmgl
  Left = 220
  Top = 172
  Width = 899
  Height = 627
  Caption = 'fmxmgl'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object spl1: TSplitter
    Left = 209
    Top = 49
    Width = 13
    Height = 540
    Color = clSkyBlue
    ParentColor = False
  end
  object pnl1: TPanel
    Left = 0
    Top = 49
    Width = 209
    Height = 540
    Align = alLeft
    Caption = 'pnl1'
    TabOrder = 0
    object ejunallxm: TEjunDBGrid
      Left = 1
      Top = 1
      Width = 207
      Height = 538
      OptionsEx = [goxStringGrid, goxSupportFormula, goxAutoCalculate]
      DefaultColWidth = 73
      Selection.AlphaBlend = False
      Selection.TransparentColor = False
      Selection.DisableDrag = False
      Selection.HideBorder = False
      Align = alClient
      FooterRowCount = 0
      DataSet = qry1
      DataColumns = <>
      TabOrder = 0
      TabStop = True
      PopupMenu = ejunonexm.DefaultPopupMenu
      GridData = {
        090810000006050000000000000000000000000031004800F5FFFFFF00000100
        4D0053002000530061006E007300200053006500720069006600000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        E0004C0000000000FFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1F
        FFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1F00000000000000000000000100000000
        00000000050000FF080000FF00000000850017000000000000000845006A0075
        006E0047007200690064001E040400000000000A000000090810000007100000
        000000000000000000000000020E000100000004000000010004000000052031
        0066666666666629406666666666662940666666666666294066666666666629
        4066666666666629406666666666662940000A2031000101000000FFFFFFFF01
        000000FFFFFFFF00000000000000000000000000000000000000000000000000
        0000000000000009202A00090064000100000000000000020008000000000000
        0035403333333333B33D40000000000000000008007D000C0000000000580200
        000000000008021400000000000500FF000000000080010000FFFF0000E50002
        0000000A00000000000000}
    end
  end
  object pnl2: TPanel
    Left = 222
    Top = 49
    Width = 661
    Height = 540
    Align = alClient
    Caption = 'pnl2'
    TabOrder = 1
    object ejunonexm: TEjunDBGrid
      Left = 1
      Top = 1
      Width = 659
      Height = 538
      OptionsEx = [goxStringGrid, goxSupportFormula, goxAutoCalculate]
      ColCount = 2
      DefaultColWidth = 73
      Selection.AlphaBlend = False
      Selection.TransparentColor = False
      Selection.DisableDrag = False
      Selection.HideBorder = False
      Align = alClient
      FooterRowCount = 0
      DataSet = qry2
      DataColumns = <
        item
          Width = 73
          Style.BgColor = clWindow
          Style.HorzAlign = haGeneral
          Style.VertAlign = vaCenter
          Style.Options = []
          Visible = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          UseColumnFont = False
        end>
      TabOrder = 0
      TabStop = True
      PopupMenu = ejunonexm.DefaultPopupMenu
      OnDblClick = ejunonexmDblClick
      GridData = {
        090810000006050000000000000000000000000031004800F5FFFFFF00000100
        4D0053002000530061006E007300200053006500720069006600000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        E0004C0000000000FFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1F
        FFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1F00000000000000000000000100000000
        00000000050000FF080000FF00000000E0004C0000000000FFFFFF1FFFFFFF1F
        FFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1F
        0000000000000000000000010000000000000000050000FF080000FF00000014
        850017000000000000000845006A0075006E0047007200690064001E04040000
        0000000A000000090810000007100000000000000000000000000000020E0001
        0000000400000001000100000005203100666666666666294066666666666629
        4066666666666629406666666666662940666666666666294066666666666629
        40000A2031000101000000FFFFFFFF01000000FFFFFFFF000000000000000000
        000000000000000000000000000000000000000000000009202A000900640001
        000000000000000200080000000000000035403333333333B33D400000000000
        00000008007D000C000000000058020000000000007D000C0001000100470401
        000000000008021400000000000200FF000000000080010000FFFF0000E50002
        0000000A00000000000000}
    end
  end
  object pnl3: TPanel
    Left = 0
    Top = 0
    Width = 883
    Height = 49
    Align = alTop
    TabOrder = 2
    object btn1: TButton
      Left = 232
      Top = 8
      Width = 75
      Height = 33
      Caption = #30830#23450
      TabOrder = 0
      OnClick = btn1Click
    end
  end
  object qry1: TADOQuery
    Parameters = <>
    Left = 24
    Top = 16
  end
  object qry2: TADOQuery
    Parameters = <>
    Left = 408
    Top = 16
  end
  object qrytmp: TADOQuery
    Parameters = <>
    Left = 464
    Top = 24
  end
end
