object fmcash: Tfmcash
  Left = -8
  Top = -8
  Width = 1296
  Height = 776
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
    Width = 1280
    Height = 49
    Align = alTop
    TabOrder = 0
    object btn1: TButton
      Left = 6
      Top = 2
      Width = 123
      Height = 41
      Caption = #21021#27493#35782#21035#29616#37329#27969#37327
      TabOrder = 0
      OnClick = btn1Click
    end
    object btn3: TButton
      Left = 320
      Top = 2
      Width = 97
      Height = 41
      Caption = #30830#35748#25163#21160#32467#26524
      TabOrder = 1
      OnClick = btn3Click
    end
    object cbb1: TComboBox
      Left = 448
      Top = 8
      Width = 137
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 2
      OnChange = cbb1Change
      Items.Strings = (
        #31354#30333
        'OK'
        'X'
        #25910#21040#38144#21806
        #25910#21040#36820#31246
        #25910#21040#20854#20182
        #25903#20184#37319#36141
        #25903#20184#32844#24037
        #25903#20184#31246#36153
        #25903#20184#20854#20182)
    end
    object cbb2: TComboBox
      Left = 600
      Top = 8
      Width = 137
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 3
      OnChange = cbb2Change
      Items.Strings = (
        #31354#30333
        #25910#21040#25237#36164
        #21462#24471#25910#30410
        #22788#32622#36164#20135
        #22788#32622#20844#21496
        #25910#21040#20854#20182#25237#36164
        #25903#20184#25237#36164
        #25237#36164#25903#20184#29616#37329
        #36141#20080#23376#20844#21496
        #25903#20184#20854#20182#25237#36164)
    end
    object cbb3: TComboBox
      Left = 752
      Top = 8
      Width = 137
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 4
      OnChange = cbb3Change
      Items.Strings = (
        #31354#30333
        #21560#25910#25237#36164
        #25910#21040#20511#27454
        #25910#21040#31609#36164
        #24402#36824#20511#27454
        #25903#20184#21033#24687
        #25903#20184#31609#36164)
    end
    object btn4: TButton
      Left = 142
      Top = 2
      Width = 105
      Height = 41
      Caption = #23548#20986#29616#37329#27969#37327
      TabOrder = 5
      OnClick = btn4Click
    end
    object btn5: TButton
      Left = 944
      Top = 16
      Width = 75
      Height = 25
      Caption = 'btn5'
      TabOrder = 6
      OnClick = btn5Click
    end
  end
  object pnl2: TPanel
    Left = 0
    Top = 49
    Width = 1280
    Height = 688
    Align = alClient
    Caption = 'pnl2'
    TabOrder = 1
  end
  object pgc1: TPageControl
    Left = 0
    Top = 49
    Width = 1280
    Height = 688
    ActivePage = ts1
    Align = alClient
    TabOrder = 2
    OnChange = pgc1Change
    object ts1: TTabSheet
      Caption = #36135#24065#36164#37329#22788#29702
      object spl1: TSplitter
        Left = 249
        Top = 0
        Width = 16
        Height = 660
      end
      object pnl3: TPanel
        Left = 0
        Top = 0
        Width = 249
        Height = 660
        Align = alLeft
        TabOrder = 0
        object pgc2: TPageControl
          Left = 1
          Top = 25
          Width = 247
          Height = 634
          ActivePage = ts6
          Align = alClient
          TabOrder = 0
          OnChange = pgc2Change
          object ts5: TTabSheet
            Caption = #27969#37327#20998#26512
            ImageIndex = 1
            object spl3: TSplitter
              Left = 0
              Top = 337
              Width = 239
              Height = 24
              Cursor = crVSplit
              Align = alTop
            end
            object ejuncashtotal: TEjunDBGrid
              Left = 0
              Top = 0
              Width = 239
              Height = 337
              Options = [goRangeSelect, goRowSelect, goRowSizing, goColSizing, goUnequalRowHeight, goFixedRowShowNo, goFixedColShowNo, goAlwaysShowSelection]
              OptionsEx = [goxStringGrid, goxSupportFormula, goxAutoCalculate]
              ColCount = 2
              DefaultColWidth = 73
              Selection.AlphaBlend = False
              Selection.TransparentColor = False
              Selection.DisableDrag = False
              Selection.HideBorder = False
              AllowEdit = False
              Align = alTop
              FooterRowCount = 0
              DataSet = qrycash
              DataColumns = <
                item
                  Width = 174
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
                  Title = #29616#37329#27969#37327#31616#31216
                  UseColumnFont = False
                  Name = #29616#37329#27969#37327#31616#31216
                  FieldName = #29616#37329#27969#37327#31616#31216
                end>
              TabOrder = 0
              TabStop = True
              PopupMenu = ejuncashtotal.DefaultPopupMenu
              OnDblClick = ejuncashtotalDblClick
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
                0000000400000001000100000005203100666666666666294066666666666629
                4066666666666629406666666666662940666666666666294066666666666629
                40000A2031000101000000FFFFFFFF01000000FFFFFFFF000000000000000000
                000000000000000000000000000000000000000000000009202A000900640001
                000000000000000200080000000000000035403333333333B33D400000000000
                00000008007D000C0000000000EF010000000000007D000C0001000100320A01
                000000000008021400000000000200FF000000000080010000FFFF0000040218
                00000000000100000000000600B073D191416DCF91807BF079E500020000000A
                00000000000000}
            end
            object pgc3: TPageControl
              Left = 0
              Top = 361
              Width = 239
              Height = 245
              ActivePage = ts7
              Align = alClient
              TabOrder = 1
              OnChange = pgc3Change
              object ts4: TTabSheet
                Caption = #20851#38190#23383
                object ejun1: TEjunDBGrid
                  Left = 0
                  Top = 0
                  Width = 231
                  Height = 102
                  OptionsEx = [goxStringGrid, goxSupportFormula, goxAutoCalculate]
                  ColCount = 3
                  DefaultColWidth = 73
                  Selection.AlphaBlend = False
                  Selection.TransparentColor = False
                  Selection.DisableDrag = False
                  Selection.HideBorder = False
                  Align = alClient
                  FooterRowCount = 0
                  DataSet = tbkey
                  DataColumns = <
                    item
                      Width = 160
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
                      Title = #20851#38190#23383
                      UseColumnFont = False
                      Name = #20851#38190#23383
                      FieldName = #20851#38190#23383
                    end
                    item
                      Width = 0
                      Style.BgColor = clWindow
                      Style.HorzAlign = haGeneral
                      Style.VertAlign = vaCenter
                      Style.Options = []
                      Visible = False
                      Font.Charset = DEFAULT_CHARSET
                      Font.Color = clWindowText
                      Font.Height = -11
                      Font.Name = 'MS Sans Serif'
                      Font.Style = []
                      Title = 'id'
                      UseColumnFont = False
                      Name = 'id'
                      FieldName = 'id'
                    end>
                  TabOrder = 0
                  TabStop = True
                  PopupMenu = ejun1.DefaultPopupMenu
                  OnDblClick = ejun3DblClick
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
                    0000000400000001000200000005203100666666666666294066666666666629
                    4066666666666629406666666666662940666666666666294066666666666629
                    40000A2031000101000000FFFFFFFF01000000FFFFFFFF000000000000000000
                    000000000000000000000000000000000000000000000009202A000900640001
                    000000000000000200080000000000000035403333333333B33D400000000000
                    00000008007D000C000000000058020000000000007D000C0001000100600901
                    00000000007D000C0002000200000001000000000008021400000000000300FF
                    000000000080010000FFFF00000402120000000000010000000000030073512E
                    95575B0402100000000000020000000000020069006400E500020000000A0000
                    0000000000}
                end
              end
              object ts7: TTabSheet
                Caption = #31185#30446#20313#39069#34920
                ImageIndex = 1
                object ejunkmyeb: TEjunDBGrid
                  Left = 0
                  Top = 0
                  Width = 231
                  Height = 102
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
          end
          object ts6: TTabSheet
            Caption = #20869#37096#27969#36716#24179#34913
            ImageIndex = 2
            object ejunbank: TEjunDBGrid
              Left = 0
              Top = 0
              Width = 239
              Height = 606
              Options = [goRangeSelect, goRowSelect, goRowSizing, goColSizing, goUnequalRowHeight, goFixedRowShowNo, goFixedColShowNo, goAlwaysShowSelection]
              OptionsEx = [goxStringGrid, goxSupportFormula, goxAutoCalculate]
              ColCount = 2
              DefaultColWidth = 73
              Selection.AlphaBlend = False
              Selection.TransparentColor = False
              Selection.DisableDrag = False
              Selection.HideBorder = False
              AllowEdit = False
              Align = alClient
              FooterRowCount = 0
              DataSet = qrybank
              DataColumns = <
                item
                  Width = 174
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
                  Title = #29616#37329#27969#37327#31616#31216
                  UseColumnFont = False
                  Name = #29616#37329#27969#37327#31616#31216
                  FieldName = #29616#37329#27969#37327#31616#31216
                end>
              TabOrder = 0
              TabStop = True
              PopupMenu = ejunbank.DefaultPopupMenu
              OnDblClick = ejunbankDblClick
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
                0000000400000001000100000005203100666666666666294066666666666629
                4066666666666629406666666666662940666666666666294066666666666629
                40000A2031000101000000FFFFFFFF01000000FFFFFFFF000000000000000000
                000000000000000000000000000000000000000000000009202A000900640001
                000000000000000200080000000000000035403333333333B33D400000000000
                00000008007D000C0000000000EF010000000000007D000C0001000100320A01
                000000000008021400000000000200FF000000000080010000FFFF0000040218
                00000000000100000000000600B073D191416DCF91807BF079E500020000000A
                00000000000000}
            end
          end
        end
        object pnl5: TPanel
          Left = 1
          Top = 1
          Width = 247
          Height = 24
          Align = alTop
          TabOrder = 1
        end
      end
      object pnl4: TPanel
        Left = 265
        Top = 0
        Width = 1007
        Height = 660
        Align = alClient
        TabOrder = 1
        object spl2: TSplitter
          Left = 1
          Top = 457
          Width = 1005
          Height = 16
          Cursor = crVSplit
          Align = alBottom
        end
        object pnl6: TPanel
          Left = 1
          Top = 1
          Width = 1005
          Height = 456
          Align = alClient
          Caption = 'pnl6'
          TabOrder = 0
          object ejunpzall: TEjunDBGrid
            Left = 1
            Top = 1
            Width = 1003
            Height = 454
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
            OnSelectionChange = ejunpzallSelectionChange
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
          Top = 473
          Width = 1005
          Height = 186
          Align = alBottom
          Caption = 'pnl7'
          TabOrder = 1
          object ejunpzone: TEjunDBGrid
            Left = 1
            Top = 1
            Width = 1003
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
            OnDblClick = ejunpzoneDblClick
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
    object ts2: TTabSheet
      Caption = #29616#37329#27969#37327#35782#21035#35774#32622
      ImageIndex = 1
      object ejun2: TEjunDBGrid
        Left = 0
        Top = 0
        Width = 1108
        Height = 545
        OptionsEx = [goxStringGrid, goxSupportFormula, goxAutoCalculate]
        ColCount = 7
        DefaultColWidth = 73
        Selection.AlphaBlend = False
        Selection.TransparentColor = False
        Selection.DisableDrag = False
        Selection.HideBorder = False
        Align = alClient
        FooterRowCount = 0
        DataSet = tb1
        DataColumns = <
          item
            Width = 145
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
            Title = #23545#26041#31185#30446
            UseColumnFont = False
            Name = #23545#26041#31185#30446
            FieldName = #23545#26041#31185#30446
          end
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
            Title = #20840#23616#26367#25442
            UseColumnFont = False
            Name = #20840#23616#26367#25442
            FieldName = #20840#23616#26367#25442
          end
          item
            Width = 95
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
            Title = #20511#36151
            UseColumnFont = False
            Name = #20511#36151
            FieldName = #20511#36151
          end
          item
            Width = 107
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
            Title = #25688#35201#20851#38190#23383
            UseColumnFont = False
            Name = #25688#35201#20851#38190#23383
            FieldName = #25688#35201#20851#38190#23383
          end
          item
            Width = 168
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
            Title = #29616#37329#27969#37327#31616#31216
            UseColumnFont = False
            Name = #29616#37329#27969#37327#31616#31216
            FieldName = #29616#37329#27969#37327#31616#31216
          end
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
            Title = #20854#20182
            UseColumnFont = False
            Name = #20854#20182
            FieldName = #20854#20182
          end>
        TabOrder = 0
        TabStop = True
        PopupMenu = ejun2.DefaultPopupMenu
        OnDblClick = ejunpzallDblClick
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
          0000000400000001000600000005203100666666666666294066666666666629
          4066666666666629406666666666662940666666666666294066666666666629
          40000A2031000101000000FFFFFFFF01000000FFFFFFFF000000000000000000
          000000000000000000000000000000000000000000000009202A000900640001
          000000000000000200080000000000000035403333333333B33D400000000000
          00000008007D000C000000000058020000000000007D000C00010001007F0801
          00000000007D000C000200020047040100000000007D000C0003000300910501
          00000000007D000C000400040045060100000000007D000C0005000500D80901
          00000000007D000C0006000600470401000000000008021400000000000700FF
          000000000080010000FFFF000004021400000000000100000000000400F95BB9
          65D179EE76040214000000000002000000000004006851405CFF666263040210
          000000000003000000000002001F50378D040216000000000004000000000005
          005864818973512E95575B04021800000000000500000000000600B073D19141
          6DCF91807BF079040210000000000006000000000002007651D64EE500020000
          000A00000000000000}
      end
    end
    object ts3: TTabSheet
      Caption = #29616#37329#27969#37327#34920
      ImageIndex = 2
      object ejuncashsheet: TEjunDBGrid
        Left = 0
        Top = 41
        Width = 1108
        Height = 504
        OptionsEx = [goxStringGrid, goxSupportFormula, goxAutoCalculate]
        DefaultColWidth = 73
        Selection.AlphaBlend = False
        Selection.TransparentColor = False
        Selection.DisableDrag = False
        Selection.HideBorder = False
        AllowEdit = False
        Align = alClient
        FooterRowCount = 0
        DataSet = tbCASHSHEET
        DataColumns = <>
        TabOrder = 0
        TabStop = True
        PopupMenu = ejuncashsheet.DefaultPopupMenu
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
          00000000007D000C000100010068100000000000007D000C0002000200D70A00
          00000000007D000C0003000300AD0700000000000008021400000000000500FF
          000000000080010000FFFF0000E500020000000A00000000000000}
      end
      object pnl8: TPanel
        Left = 0
        Top = 0
        Width = 1108
        Height = 41
        Align = alTop
        Caption = 'pnl8'
        TabOrder = 1
        object btnupdatesheet: TButton
          Left = 24
          Top = 8
          Width = 137
          Height = 25
          Caption = #26356#26032#29616#37329#27969#37327#34920
          TabOrder = 0
          OnClick = btnupdatesheetClick
        end
      end
    end
    object ts8: TTabSheet
      Caption = #32463#33829#24615#20854#20182#25910#20184#26126#32454
      ImageIndex = 3
      object ejunOTHER: TEjunDBGrid
        Left = 0
        Top = 0
        Width = 1108
        Height = 545
        Options = [goRangeSelect, goRowSelect, goRowSizing, goColSizing, goUnequalRowHeight, goFixedRowShowNo, goFixedColShowNo, goAlwaysShowSelection]
        OptionsEx = [goxStringGrid, goxSupportFormula, goxAutoCalculate]
        DefaultColWidth = 73
        Selection.AlphaBlend = False
        Selection.TransparentColor = False
        Selection.DisableDrag = False
        Selection.HideBorder = False
        AllowEdit = False
        Align = alClient
        FooterRowCount = 0
        DataSet = qryother
        DataColumns = <>
        TabOrder = 0
        TabStop = True
        PopupMenu = ejunOTHER.DefaultPopupMenu
        OnDblClick = ejunOTHERDblClick
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
    object ts9: TTabSheet
      Caption = #23457#35745#22791#24536#24405
      ImageIndex = 4
      object pnl9: TPanel
        Left = 0
        Top = 0
        Width = 1272
        Height = 49
        Align = alTop
        TabOrder = 0
        object btn2: TButton
          Left = 293
          Top = 8
          Width = 81
          Height = 33
          Caption = #20445#23384
          TabOrder = 0
          OnClick = btn2Click
        end
      end
      object mmo1: TMemo
        Left = 0
        Top = 49
        Width = 1272
        Height = 611
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        Lines.Strings = (
          'mmo1')
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 1
      end
    end
  end
  object con1: TADOConnection
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
    Left = 832
    Top = 430
  end
  object qrypzb: TADOQuery
    Connection = con1
    Parameters = <>
    Left = 960
    Top = 430
  end
  object ejnlcns1: TEjunLicense
    KeyID = 'y7ERk-Tyquk-RTV1G9Gh-fGdp'
    ProductID = 'B201008101065'
    UserID = #21525#21521#38451
    Left = 960
    Top = 462
  end
  object tb1: TADOTable
    Connection = con1
    CursorType = ctStatic
    TableName = #29616#37329#27969#37327#34920#23545#24212
    Left = 896
    Top = 462
  end
  object tb2: TADOTable
    Connection = con1
    CursorType = ctStatic
    TableName = #29616#37329#27969#37327#34920#39033#30446
    Left = 928
    Top = 462
  end
  object qrytmp: TADOQuery
    Connection = con1
    Parameters = <>
    Left = 896
    Top = 430
  end
  object qryQRYonepz: TADOQuery
    Connection = con1
    Parameters = <>
    Left = 928
    Top = 430
  end
  object qrycash: TADOQuery
    Connection = con1
    Parameters = <>
    Left = 864
    Top = 430
  end
  object qrybank: TADOQuery
    Connection = con1
    Parameters = <>
    Left = 832
    Top = 462
  end
  object tbkey: TADOTable
    Connection = con1
    CursorType = ctStatic
    TableName = #29616#37329#27969#20851#38190#23383
    Left = 864
    Top = 462
  end
  object tbCASHSHEET: TADOTable
    Connection = con1
    TableName = #29616#37329#27969#37327#34920#39033#30446
    Left = 468
    Top = 185
  end
  object qrykmyeb: TADOQuery
    Connection = con1
    Parameters = <>
    Left = 599
    Top = 171
  end
  object tbdw: TADOTable
    Connection = con1
    CursorType = ctStatic
    TableName = #24213#31295#21333#20301
    Left = 798
    Top = 48
  end
  object qryother: TADOQuery
    Connection = con1
    Parameters = <>
    Left = 748
    Top = 153
  end
end
