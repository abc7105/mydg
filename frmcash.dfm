object fmcash: Tfmcash
  Left = 688
  Top = 307
  Width = 1032
  Height = 566
  Caption = 'fmcash'
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
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 1016
    Height = 49
    Align = alTop
    TabOrder = 0
    object btn4: TButton
      Left = 182
      Top = 6
      Width = 115
      Height = 33
      Caption = #23548#20986#29616#37329#27969#37327
      TabOrder = 0
      OnClick = btn4Click
    end
    object btn5: TButton
      Left = 944
      Top = 16
      Width = 75
      Height = 25
      Caption = 'btn5'
      TabOrder = 1
      OnClick = btn5Click
    end
    object Button1: TButton
      Left = 34
      Top = 6
      Width = 137
      Height = 33
      Caption = #29983#25104#29616#37329#27969#37327#34920
      TabOrder = 2
      OnClick = Button1Click
    end
  end
  object pnl2: TPanel
    Left = 0
    Top = 49
    Width = 1016
    Height = 479
    Align = alClient
    Caption = 'pnl2'
    TabOrder = 1
  end
  object pgc1: TPageControl
    Left = 0
    Top = 49
    Width = 1016
    Height = 479
    ActivePage = tsbank
    Align = alClient
    TabOrder = 2
    OnChange = pgc1Change
    object tsbank: TTabSheet
      Caption = #36135#24065#36164#37329#22788#29702
      object pnl4: TPanel
        Left = 0
        Top = 0
        Width = 1008
        Height = 451
        Align = alClient
        TabOrder = 0
        object spl2: TSplitter
          Left = 1
          Top = 248
          Width = 1006
          Height = 16
          Cursor = crVSplit
          Align = alBottom
        end
        object pnl6: TPanel
          Left = 1
          Top = 1
          Width = 1006
          Height = 247
          Align = alClient
          Caption = 'pnl6'
          TabOrder = 0
          object ejunpzall: TEjunDBGrid
            Left = 1
            Top = 1
            Width = 1004
            Height = 245
            OptionsEx = [goxStringGrid, goxSupportFormula, goxAutoCalculate]
            DefaultColWidth = 73
            Selection.AlphaBlend = False
            Selection.TransparentColor = False
            Selection.DisableDrag = False
            Selection.HideBorder = False
            Align = alClient
            FooterRowCount = 0
            DataSet = qrypzb
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
            PopupMenu = ejunpzall.DefaultPopupMenu
            OnDblClick = ejunpzallDblClick
            OnCellGetColor = ejunpzallCellGetColor
            OnMouseDown = ejunpzallMouseDown
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
              0000000400000001000400000005203100666666666666294066666666666629
              4066666666666629406666666666662940666666666666294066666666666629
              40000A2031000101000000FFFFFFFF01000000FFFFFFFF000000000000000000
              000000000000000000000000000000000000000000000009202A000900640001
              000000000000000200080000000000000035403333333333B33D400000000000
              00000008007D000C000000000058020000000000007D000C0001000100470401
              000000000008021400000000000500FF000000000080010000FFFF0000E50002
              0000000A00000000000000}
          end
        end
        object pnl7: TPanel
          Left = 1
          Top = 264
          Width = 1006
          Height = 186
          Align = alBottom
          Caption = 'pnl7'
          TabOrder = 1
          object ejunpzone: TEjunDBGrid
            Left = 1
            Top = 1
            Width = 1004
            Height = 184
            OptionsEx = [goxStringGrid, goxSupportFormula, goxAutoCalculate]
            DefaultColWidth = 73
            Selection.AlphaBlend = False
            Selection.TransparentColor = False
            Selection.DisableDrag = False
            Selection.HideBorder = False
            AllowEdit = False
            Align = alClient
            FooterRowCount = 0
            DataSet = qryQRYonepz
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
            PopupMenu = ejunpzall.DefaultPopupMenu
            OnMouseDown = ejunpzoneMouseDown
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
              0000000400000001000400000005203100666666666666294066666666666629
              4066666666666629406666666666662940666666666666294066666666666629
              40000A2031000101000000FFFFFFFF01000000FFFFFFFF000000000000000000
              000000000000000000000000000000000000000000000009202A000900640001
              000000000000000200080000000000000035403333333333B33D400000000000
              00000008007D000C000000000058020000000000007D000C0001000100470401
              000000000008021400000000000500FF000000000080010000FFFF0000E50002
              0000000A00000000000000}
          end
        end
      end
    end
    object tscashtable: TTabSheet
      Caption = #29616#37329#27969#37327#34920
      ImageIndex = 2
      object ejuncashsheet: TEjunDBGrid
        Left = 0
        Top = 0
        Width = 1008
        Height = 451
        OptionsEx = [goxStringGrid, goxSupportFormula, goxAutoCalculate]
        DefaultColWidth = 73
        Selection.AlphaBlend = False
        Selection.TransparentColor = False
        Selection.DisableDrag = False
        Selection.HideBorder = False
        Align = alClient
        FooterRowCount = 0
        DataSet = tbCASHSHEET
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
        PopupMenu = ejunpzall.DefaultPopupMenu
        OnDblClick = ejunpzallDblClick
        OnCellGetColor = ejunpzallCellGetColor
        OnMouseDown = ejunpzallMouseDown
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
          0000000400000001000400000005203100666666666666294066666666666629
          4066666666666629406666666666662940666666666666294066666666666629
          40000A2031000101000000FFFFFFFF01000000FFFFFFFF000000000000000000
          000000000000000000000000000000000000000000000009202A000900640001
          000000000000000200080000000000000035403333333333B33D400000000000
          00000008007D000C000000000058020000000000007D000C0001000100470401
          000000000008021400000000000500FF000000000080010000FFFF0000E50002
          0000000A00000000000000}
      end
    end
    object tskmyeb: TTabSheet
      Caption = #31185#30446#20313#38989#34920
      ImageIndex = 6
      object ejunkmyeb: TEjunDBGrid
        Left = 0
        Top = 0
        Width = 1008
        Height = 451
        Options = [goRangeSelect, goRowSelect, goRowSizing, goColSizing, goUnequalRowHeight, goFixedRowShowNo, goFixedColShowNo, goAlwaysShowSelection]
        OptionsEx = [goxStringGrid, goxSupportFormula, goxAutoCalculate]
        DefaultColWidth = 73
        Selection.AlphaBlend = False
        Selection.TransparentColor = False
        Selection.DisableDrag = False
        Selection.HideBorder = False
        Align = alClient
        FooterRowCount = 0
        DataSet = qrykmyeb
        DataColumns = <>
        TabOrder = 0
        TabStop = True
        PopupMenu = ejunkmyeb.DefaultPopupMenu
        OnDblClick = ejunkmyebDblClick
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
  end
  object con1: TADOConnection
    Connected = True
    ConnectionString = 
      'Provider=Microsoft.Jet.OLEDB.4.0;User ID=Admin;Data Source=D:\20' +
      '14prg\mydg\DG.mdb;Mode=Share Deny None;Persist Security Info=Fal' +
      'se;Jet OLEDB:System database="";Jet OLEDB:Registry Path="";Jet O' +
      'LEDB:Database Password="";Jet OLEDB:Engine Type=5;Jet OLEDB:Data' +
      'base Locking Mode=1;Jet OLEDB:Global Partial Bulk Ops=2;Jet OLED' +
      'B:Global Bulk Transactions=1;Jet OLEDB:New Database Password="";' +
      'Jet OLEDB:Create System Database=False;Jet OLEDB:Encrypt Databas' +
      'e=False;Jet OLEDB:Don'#39't Copy Locale on Compact=False;Jet OLEDB:C' +
      'ompact Without Replica Repair=False;Jet OLEDB:SFP=False;'
    LoginPrompt = False
    Mode = cmShareDenyNone
    Provider = 'Microsoft.Jet.OLEDB.4.0'
    Left = 757
    Top = 267
  end
  object qrypzb: TADOQuery
    Connection = con1
    Parameters = <>
    Left = 914
    Top = 304
  end
  object ejnlcns1: TEjunLicense
    KeyID = 'y7ERk-Tyquk-RTV1G9Gh-fGdp'
    ProductID = 'B201008101065'
    UserID = #21525#21521#38451
    Left = 960
    Top = 462
  end
  object qrytmp: TADOQuery
    Connection = con1
    Parameters = <>
    Left = 847
    Top = 330
  end
  object qryQRYonepz: TADOQuery
    Connection = con1
    Parameters = <>
    Left = 938
    Top = 209
  end
  object qrycash: TADOQuery
    Connection = con1
    Parameters = <>
    Left = 771
    Top = 349
  end
  object qrybank: TADOQuery
    Connection = con1
    Parameters = <>
    Left = 572
    Top = 300
  end
  object tbCASHSHEET: TADOTable
    Connection = con1
    TableName = #29616#37329#27969#37327#34920#39033#30446
    Left = 347
    Top = 154
  end
  object qrykmyeb: TADOQuery
    Connection = con1
    Parameters = <>
    Left = 470
    Top = 175
  end
  object tbcalccash: TADOTable
    Left = 195
    Top = 163
  end
  object dlgSave1: TSaveDialog
    Left = 884
    Top = 468
  end
end
