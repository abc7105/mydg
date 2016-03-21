object frmpzh: Tfrmpzh
  Left = 217
  Top = 450
  Width = 1057
  Height = 660
  Caption = #24635#36134'-'#26126#32454#36134'-'#20973#35777#31995#32479
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = mm1
  OldCreateOrder = False
  Position = poDesktopCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label22: TLabel
    Left = 48
    Top = 8
    Width = 113
    Height = 13
    AutoSize = False
    Caption = #21306#38388
  end
  object Label23: TLabel
    Left = 136
    Top = 8
    Width = 113
    Height = 13
    AutoSize = False
    Caption = #24635#25968#37327
  end
  object Label24: TLabel
    Left = 232
    Top = 8
    Width = 73
    Height = 13
    AutoSize = False
    Caption = #26679#26412#25968
  end
  object pgc1: TPageControl
    Left = 0
    Top = 73
    Width = 1041
    Height = 529
    ActivePage = ts1
    Align = alClient
    TabOrder = 0
    OnChange = pgc1Change
    object ts1: TTabSheet
      Caption = #24635'    '#36134'  '
      object pnl8: TPanel
        Left = 921
        Top = 0
        Width = 112
        Height = 501
        Align = alClient
        TabOrder = 0
        object fllst1: TFileListBox
          Left = 1
          Top = 1
          Width = 110
          Height = 499
          Align = alClient
          ItemHeight = 19
          Mask = '*.xls*'
          TabOrder = 0
          OnDblClick = fllst1DblClick
        end
      end
      object pnl9: TPanel
        Left = 0
        Top = 0
        Width = 921
        Height = 501
        Align = alLeft
        Caption = 'pnl9'
        TabOrder = 1
        object ejunkmyeb: TEjunDBGrid
          Left = 1
          Top = 1
          Width = 919
          Height = 499
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
          DataSet = qrykmb
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
    object ts2: TTabSheet
      Caption = #24403#21069#31185#30446#26126#32454#36134
      ImageIndex = 1
      object ejundbgrid2: TEjunDBGrid
        Left = 0
        Top = 0
        Width = 961
        Height = 501
        Options = [goRangeSelect, goRowSelect, goRowSizing, goColSizing, goUnequalRowHeight, goFixedRowShowNo, goFixedColShowNo, goAlwaysShowSelection]
        OptionsEx = [goxStringGrid, goxSupportFormula, goxAutoCalculate]
        ColCount = 11
        DefaultColWidth = 73
        Selection.AlphaBlend = False
        Selection.TransparentColor = False
        Selection.DisableDrag = False
        Selection.HideBorder = False
        Align = alClient
        FooterRowCount = 0
        DataSet = qryONEpz
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
            UseColumnFont = False
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
            UseColumnFont = False
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
            UseColumnFont = False
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
            UseColumnFont = False
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
            UseColumnFont = False
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
            UseColumnFont = False
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
            UseColumnFont = False
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
            UseColumnFont = False
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
            UseColumnFont = False
          end>
        TabOrder = 0
        TabStop = True
        PopupMenu = ejundbgrid2.DefaultPopupMenu
        OnDblClick = ejundbgrid2DblClick
        OnMouseDown = ejundbgrid2MouseDown
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
          0000000400000001000A00000005203100666666666666294066666666666629
          4066666666666629406666666666662940666666666666294066666666666629
          40000A2031000101000000FFFFFFFF01000000FFFFFFFF000000000000000000
          000000000000000000000000000000000000000000000009202A000900640001
          000000000000000200080000000000000035403333333333B33D400000000000
          00000008007D000C000000000058020000000000007D000C0001000A00470401
          000000000008021400000000000B00FF000000000080010000FFFF0000E50002
          0000000A00000000000000}
      end
    end
    object ts3: TTabSheet
      Caption = #20973#35777#28165#21333#21450#25277#20973#36807#31243
      ImageIndex = 2
      object spl2: TSplitter
        Left = 0
        Top = 179
        Width = 1033
        Height = 15
        Cursor = crVSplit
        Align = alBottom
      end
      object pnl2: TPanel
        Left = 0
        Top = 0
        Width = 1033
        Height = 179
        Align = alClient
        Caption = 'pnl2'
        TabOrder = 0
        object ejunpzall: TEjunDBGrid
          Left = 1
          Top = 1
          Width = 959
          Height = 177
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
          OnDblClick = ejunpzallDblClick
          OnMouseUp = ejunpzallMouseUp
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
      object pgc2: TPageControl
        Left = 0
        Top = 194
        Width = 1033
        Height = 307
        ActivePage = ts5
        Align = alBottom
        TabOrder = 1
        OnChange = pgc2Change
        object ts5: TTabSheet
          Caption = #24403#21069#20973#35777#30340#20840#37096#20998#24405
          object pnl3: TPanel
            Left = 0
            Top = 0
            Width = 953
            Height = 279
            Align = alClient
            Caption = 'pnl3'
            TabOrder = 0
            object pnl4: TPanel
              Left = 1
              Top = 1
              Width = 951
              Height = 41
              Align = alTop
              TabOrder = 0
              object Label1: TLabel
                Left = 16
                Top = 16
                Width = 113
                Height = 13
                AutoSize = False
                Caption = #26597#35810#23545#24212#20973#35777
              end
              object btn6: TButton
                Left = 304
                Top = 8
                Width = 153
                Height = 25
                Caption = #20840#37096#20973#35777
                TabOrder = 0
                OnClick = btn6Click
              end
              object btn7: TButton
                Left = 472
                Top = 8
                Width = 129
                Height = 25
                Caption = #26412#31185#30446#20511#26041#20973#35777
                TabOrder = 1
                OnClick = btn7Click
              end
              object btn9: TButton
                Left = 616
                Top = 8
                Width = 129
                Height = 25
                Caption = #26412#31185#30446#36151#26041#20973#35777
                TabOrder = 2
                OnClick = btn9Click
              end
            end
            object ejunonepz: TEjunDBGrid
              Left = 1
              Top = 42
              Width = 951
              Height = 236
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
              DataSet = qryONEpz
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
              TabOrder = 1
              TabStop = True
              OnMouseUp = ejunpzallMouseUp
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
        object ts6: TTabSheet
          Caption = #20973#35777#25277#26597#36807#31243
          ImageIndex = 1
          object pgc3: TPageControl
            Left = 0
            Top = 73
            Width = 1025
            Height = 206
            ActivePage = ts7
            Align = alClient
            TabOrder = 0
            OnChange = pgc3Change
            object ts7: TTabSheet
              Caption = #38543#26426#25277#26679
              object mmo2: TMemo
                Left = 521
                Top = 0
                Width = 496
                Height = 178
                Align = alClient
                Lines.Strings = (
                  #20351#29992#24110#21161
                  ''
                  '1'#12289#22312#19978#37096#34920#26684#20013#21452#20987#26576#34892#21487#36827#34892#20154#24037#36873#26679
                  ''
                  '2'#12289#22312#19979#38754#30340#39029#26694#20013#21487#20197#25353#33258#24049#30340#24819#27861#20998#21035#36827#34892#38543#26426#25277#26679#12289#31995#32479#25277#26679#12289#20998#23618#25277#26679
                  #21450#20154#24037#36873#26679
                  ''
                  #38543#26426#25277#26679#65292#31995#32479#25277#26679#65292#20998#23618#25277#26679#20013#21482#38656#36755#20837#24744#24819#25277#21462#30340#20973#35777#30340#31508#25968#65292#20877#28857#25277#26679
                  #21363#21487#12290
                  ''
                  '3'#12289#22312#34920#26684#30340#26631#39064#19978#21452#20987#21487#25353#35813#21015#30340#20869#23481#36827#34892#25490#24207#65292#25353#19968#27425#21319#24207#65292#20877#25353#19968#27425#38477#24207
                  #12290)
                TabOrder = 0
              end
              object pnl7: TPanel
                Left = 0
                Top = 0
                Width = 521
                Height = 178
                Align = alLeft
                TabOrder = 1
                object rb1: TRadioButton
                  Left = 40
                  Top = 40
                  Width = 113
                  Height = 17
                  Caption = #25277#21462#26679#26412#25968
                  TabOrder = 0
                end
                object rb2: TRadioButton
                  Left = 40
                  Top = 72
                  Width = 273
                  Height = 17
                  Caption = ' '#25277#21462#26679#26412#25968#21344#24635#25968'                                    %'
                  TabOrder = 1
                end
                object btn2: TButton
                  Left = 368
                  Top = 40
                  Width = 75
                  Height = 49
                  Caption = #38543#26426#25277#26679
                  TabOrder = 2
                  OnClick = btn2Click
                end
                object edtRNDsl: TNxNumberEdit
                  Left = 192
                  Top = 40
                  Width = 81
                  Height = 21
                  TabOrder = 3
                  Text = '0'
                  Options = [eoAllowSigns]
                end
                object edtRNDpercent: TNxNumberEdit
                  Left = 192
                  Top = 69
                  Width = 81
                  Height = 21
                  TabOrder = 4
                  Text = '0.00'
                end
              end
            end
            object ts8: TTabSheet
              Caption = #31995#32479#25277#26679
              ImageIndex = 1
              object Label11: TLabel
                Left = 48
                Top = 40
                Width = 113
                Height = 13
                AutoSize = False
                Caption = #25277#21462#26679#26412#25968
              end
              object Label12: TLabel
                Left = 48
                Top = 72
                Width = 105
                Height = 13
                AutoSize = False
                Caption = #38543#26426#36215#28857#20540
              end
              object btn3: TButton
                Left = 392
                Top = 40
                Width = 75
                Height = 49
                Caption = #31995#32479#25277#26679
                TabOrder = 2
                OnClick = btn3Click
              end
              object edtsystem: TNxNumberEdit
                Left = 168
                Top = 40
                Width = 81
                Height = 21
                TabOrder = 0
                Text = '30'
                Options = [eoAllowSigns]
                Value = 30.000000000000000000
              end
              object edtsystembegin: TNxNumberEdit
                Left = 168
                Top = 69
                Width = 81
                Height = 21
                TabOrder = 1
                Text = '1'
                Options = [eoAllowSigns]
                Value = 1.000000000000000000
              end
            end
            object ts9: TTabSheet
              Caption = #20998#23618#25277#26679
              ImageIndex = 2
              object Label13: TLabel
                Left = 32
                Top = 56
                Width = 113
                Height = 13
                AutoSize = False
                Caption = '<0'
              end
              object Label14: TLabel
                Left = 32
                Top = 88
                Width = 105
                Height = 13
                AutoSize = False
                Caption = '0-10,000'
              end
              object Label15: TLabel
                Left = 32
                Top = 120
                Width = 113
                Height = 13
                AutoSize = False
                Caption = '10,000-99,999'
              end
              object Label16: TLabel
                Left = 320
                Top = 56
                Width = 105
                Height = 13
                AutoSize = False
                Caption = '100,000-999,999'
              end
              object Label17: TLabel
                Left = 320
                Top = 88
                Width = 113
                Height = 13
                AutoSize = False
                Caption = '1,000,000-9,999,999'
              end
              object Label18: TLabel
                Left = 320
                Top = 120
                Width = 105
                Height = 13
                AutoSize = False
                Caption = '>10,000,000'
              end
              object Label19: TLabel
                Left = 32
                Top = 24
                Width = 113
                Height = 13
                AutoSize = False
                Caption = #21306#38388
              end
              object Label20: TLabel
                Left = 120
                Top = 24
                Width = 113
                Height = 13
                AutoSize = False
                Caption = #24635#25968#37327
              end
              object Label21: TLabel
                Left = 216
                Top = 24
                Width = 73
                Height = 13
                AutoSize = False
                Caption = #26679#26412#25968
              end
              object Label25: TLabel
                Left = 552
                Top = 24
                Width = 57
                Height = 13
                AutoSize = False
                Caption = #26679#26412#25968
              end
              object Label26: TLabel
                Left = 448
                Top = 24
                Width = 73
                Height = 13
                AutoSize = False
                Caption = #24635#25968#37327
              end
              object Label27: TLabel
                Left = 320
                Top = 24
                Width = 81
                Height = 13
                AutoSize = False
                Caption = #21306#38388
              end
              object lblLBLCOUNT4: TLabel
                Left = 449
                Top = 56
                Width = 70
                Height = 13
                AutoSize = False
                Caption = 'AA'
              end
              object lblLBLCOUNT5: TLabel
                Left = 449
                Top = 88
                Width = 70
                Height = 13
                AutoSize = False
                Caption = 'AA'
              end
              object lblLBLCOUNT6: TLabel
                Left = 449
                Top = 120
                Width = 70
                Height = 13
                AutoSize = False
                Caption = 'AA'
              end
              object LBLCOUNT1: TLabel
                Left = 128
                Top = 56
                Width = 70
                Height = 13
                AutoSize = False
                Caption = 'AA'
              end
              object lblLBLCOUNT2: TLabel
                Left = 128
                Top = 88
                Width = 70
                Height = 13
                AutoSize = False
                Caption = 'AA'
              end
              object lblLBLCOUNT3: TLabel
                Left = 128
                Top = 120
                Width = 70
                Height = 13
                AutoSize = False
                Caption = 'AA'
              end
              object btn4: TButton
                Left = 696
                Top = 48
                Width = 105
                Height = 57
                Caption = #20998#23618#25277#26679
                TabOrder = 6
                OnClick = btn4Click
              end
              object edtlev1: TNxNumberEdit
                Left = 208
                Top = 56
                Width = 81
                Height = 21
                TabOrder = 0
                Text = '5'
                Options = [eoAllowSigns]
                Value = 5.000000000000000000
              end
              object edtlev2: TNxNumberEdit
                Left = 208
                Top = 85
                Width = 81
                Height = 21
                TabOrder = 1
                Text = '5'
                Options = [eoAllowSigns]
                Value = 5.000000000000000000
              end
              object edtlev3: TNxNumberEdit
                Left = 208
                Top = 120
                Width = 81
                Height = 21
                TabOrder = 2
                Text = '5'
                Options = [eoAllowSigns]
                Value = 5.000000000000000000
              end
              object edtlev4: TNxNumberEdit
                Left = 536
                Top = 53
                Width = 81
                Height = 21
                TabOrder = 3
                Text = '5'
                Options = [eoAllowSigns]
                Value = 5.000000000000000000
              end
              object edtlev5: TNxNumberEdit
                Left = 536
                Top = 88
                Width = 81
                Height = 21
                TabOrder = 4
                Text = '5'
                Options = [eoAllowSigns]
                Value = 5.000000000000000000
              end
              object edtlev6: TNxNumberEdit
                Left = 536
                Top = 117
                Width = 81
                Height = 21
                TabOrder = 5
                Text = '5'
                Options = [eoAllowSigns]
                Value = 5.000000000000000000
              end
            end
            object ts10: TTabSheet
              Caption = #36873#26679#25277#20973
              ImageIndex = 3
            end
          end
          object pnl5: TPanel
            Left = 0
            Top = 0
            Width = 1025
            Height = 73
            Align = alTop
            Caption = 'pnl5'
            TabOrder = 1
            object Label2: TLabel
              Left = 24
              Top = 8
              Width = 49
              Height = 13
              AutoSize = False
              Caption = #24635#31508#25968
            end
            object Label3: TLabel
              Left = 24
              Top = 28
              Width = 65
              Height = 17
              AutoSize = False
              Caption = #24050#25277#31508#25968
            end
            object Label4: TLabel
              Left = 24
              Top = 48
              Width = 65
              Height = 13
              AutoSize = False
              Caption = #25152#21344#27604#20363
            end
            object Label5: TLabel
              Left = 304
              Top = 8
              Width = 97
              Height = 13
              AutoSize = False
              Caption = #20511#26041#24635#37329#39069
            end
            object Label6: TLabel
              Left = 304
              Top = 28
              Width = 97
              Height = 17
              AutoSize = False
              Caption = #24050#25277#20511#26041#37329#39069
            end
            object Label7: TLabel
              Left = 304
              Top = 48
              Width = 97
              Height = 13
              AutoSize = False
              Caption = #25152#21344#27604#20363
            end
            object Label8: TLabel
              Left = 616
              Top = 8
              Width = 97
              Height = 13
              AutoSize = False
              Caption = #36151#26041#24635#37329#39069
            end
            object Label9: TLabel
              Left = 616
              Top = 28
              Width = 97
              Height = 17
              AutoSize = False
              Caption = #24050#25277#36151#26041#37329#39069
            end
            object Label10: TLabel
              Left = 616
              Top = 48
              Width = 97
              Height = 13
              AutoSize = False
              Caption = #25152#21344#27604#20363
            end
            object lblALLcount: TLabel
              Left = 136
              Top = 8
              Width = 97
              Height = 13
              AutoSize = False
              Caption = 'lblALLcount'
            end
            object lblselectCOUNT: TLabel
              Left = 136
              Top = 28
              Width = 97
              Height = 17
              AutoSize = False
              Caption = 'lblselectCOUNT'
            end
            object lblpercentcount: TLabel
              Left = 136
              Top = 48
              Width = 97
              Height = 13
              AutoSize = False
              Caption = 'lblpercentcount'
            end
            object lblJFall: TLabel
              Left = 416
              Top = 8
              Width = 97
              Height = 13
              AutoSize = False
              Caption = 'Label2'
            end
            object lblJFselect: TLabel
              Left = 416
              Top = 28
              Width = 97
              Height = 17
              AutoSize = False
              Caption = 'Label2'
            end
            object LBLJFpercent: TLabel
              Left = 416
              Top = 48
              Width = 97
              Height = 13
              AutoSize = False
              Caption = 'Label2'
            end
            object lblDFall: TLabel
              Left = 712
              Top = 8
              Width = 97
              Height = 13
              AutoSize = False
              Caption = 'Label2'
            end
            object lbldfSELECT: TLabel
              Left = 712
              Top = 28
              Width = 97
              Height = 17
              AutoSize = False
              Caption = 'Label2'
            end
            object LBLDFpercent: TLabel
              Left = 712
              Top = 48
              Width = 97
              Height = 13
              AutoSize = False
              Caption = 'Label2'
            end
          end
        end
      end
    end
    object ts4: TTabSheet
      Caption = #39033#30446#22791#24536#24405
      ImageIndex = 3
      object mmo1: TMemo
        Left = 0
        Top = 49
        Width = 1033
        Height = 452
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
        TabOrder = 0
      end
      object pnl6: TPanel
        Left = 0
        Top = 0
        Width = 1033
        Height = 49
        Align = alTop
        TabOrder = 1
        object btn1: TButton
          Left = 293
          Top = 8
          Width = 81
          Height = 33
          Caption = #20445#23384
          TabOrder = 0
          OnClick = btn1Click
        end
      end
    end
  end
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 1041
    Height = 73
    Align = alTop
    TabOrder = 1
    object lbl3: TLabel
      Left = 12
      Top = 2
      Width = 41
      Height = 25
      AutoSize = False
      Caption = #36134#22871
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lbl1: TLabel
      Left = 8
      Top = 36
      Width = 89
      Height = 24
      AutoSize = False
      Caption = #24635'    '#36134
      Color = clYellow
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      OnClick = lbl1Click
      OnMouseMove = lbl1MouseMove
      OnMouseUp = lbl1MouseUp
      OnMouseLeave = lbl1MouseLeave
    end
    object lbl2: TLabel
      Left = 104
      Top = 36
      Width = 33
      Height = 24
      AutoSize = False
      Caption = '>>'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lblTITLE1: TLabel
      Left = 128
      Top = 36
      Width = 217
      Height = 24
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lblTITLE2BZ: TLabel
      Left = 352
      Top = 36
      Width = 201
      Height = 24
      AutoSize = False
      Caption = '>>'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lblid: TLabel
      Left = 56
      Top = 3
      Width = 73
      Height = 25
      AutoSize = False
      Caption = 'lblid'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblname: TLabel
      Left = 128
      Top = 3
      Width = 425
      Height = 25
      AutoSize = False
      Caption = 'lblname'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object shp1: TShape
      Left = 11
      Top = 25
      Width = 538
      Height = 1
    end
    object btn5: TButton
      Left = 855
      Top = 23
      Width = 105
      Height = 25
      Caption = #25171#24320#24213#31295
      TabOrder = 0
      OnClick = btn5Click
    end
    object btnok: TButton
      Left = 784
      Top = 24
      Width = 75
      Height = 25
      Caption = #29983#25104#24213#31295
      TabOrder = 1
      OnClick = btnokClick
    end
    object btn8: TButton
      Left = 560
      Top = 2
      Width = 75
      Height = 25
      Caption = #20999#25442#36134#22871
      TabOrder = 2
      OnClick = btn8Click
    end
    object btndgfalse: TButton
      Left = 712
      Top = 24
      Width = 75
      Height = 25
      Caption = #29983#25104#24213#31295
      TabOrder = 3
      OnClick = btndgfalseClick
    end
  end
  object ds1: TDataSource
    DataSet = qrypzb
    Left = 925
    Top = 554
  end
  object qrykmb: TADOQuery
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select * from dg7')
    Left = 925
    Top = 522
  end
  object qryONEpz: TADOQuery
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select * from  '#20973#35777#34920)
    Left = 893
    Top = 522
  end
  object dskmb: TDataSource
    DataSet = qrykmb
    Left = 893
    Top = 554
  end
  object dsonepz: TDataSource
    DataSet = qryONEpz
    Left = 797
    Top = 586
  end
  object ejnlcns1: TEjunLicense
    KeyID = 'y7ERk-Tyquk-RTV1G9Gh-fGdp'
    ProductID = 'B201008101065'
    UserID = #21525#21521#38451
    Left = 829
    Top = 586
  end
  object qrymxlist: TADOQuery
    Parameters = <>
    Left = 861
    Top = 522
  end
  object qrypzb: TADOQuery
    Parameters = <>
    Left = 829
    Top = 522
  end
  object tbdw: TADOTable
    CursorType = ctStatic
    TableName = #24213#31295#21333#20301
    Left = 829
    Top = 554
  end
  object dsdw: TDataSource
    DataSet = tbdw
    Left = 861
    Top = 554
  end
  object qryTMP: TADOQuery
    Parameters = <>
    Left = 797
    Top = 554
  end
  object mm1: TMainMenu
    Left = 808
    Top = 152
    object N1: TMenuItem
      Caption = #39033#30446#31649#29702
      object N5: TMenuItem
        Caption = #26032#24314#36134#22871
      end
      object N4: TMenuItem
        Caption = #20999#25442#36134#22871
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object N2: TMenuItem
        Caption = #23548#20837#31185#30446#20313#39069#34920
      end
      object N3: TMenuItem
        Caption = #26680#31639#39033#30446#23545#24212
        OnClick = N3Click
      end
      object N7: TMenuItem
        Caption = '-'
      end
    end
  end
end
