inherited fminfo: Tfminfo
  Left = 86
  Top = 311
  Width = 939
  Height = 645
  Caption = #24213#31295#22522#30784#20449#24687#36755#20837#21450#31185#30446#19982#24213#31295#21517#31216#23545#24212#35774#32622
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 24
    Top = 96
    Width = 60
    Height = 13
    Caption = #23457#35745#25130#27490#26085
  end
  object Label2: TLabel [1]
    Left = 32
    Top = 144
    Width = 48
    Height = 13
    Caption = #21457#20989#26085#26399
  end
  object Label3: TLabel [2]
    Left = 16
    Top = 96
    Width = 60
    Height = 13
    Caption = #23457#35745#25130#27490#26085
  end
  object Label4: TLabel [3]
    Left = 16
    Top = 136
    Width = 48
    Height = 13
    Caption = #21457#20989#26085#26399
  end
  object Label9: TLabel [4]
    Left = 463
    Top = 20
    Width = 48
    Height = 13
    Caption = #25130#27490#26085#26399
  end
  object Label11: TLabel [5]
    Left = 31
    Top = 19
    Width = 73
    Height = 13
    AutoSize = False
    Caption = #23458#25143#21333#20301
  end
  inherited pnl1: TPanel
    Width = 923
    Height = 607
    Align = alClient
    object shp1: TShape
      Left = 144
      Top = 6
      Width = 753
      Height = 32
      Brush.Color = clMoneyGreen
      Pen.Color = clGreen
      Pen.Width = 2
    end
    object lblxmname: TLabel
      Left = 160
      Top = 10
      Width = 641
      Height = 24
      AutoSize = False
      Color = clMoneyGreen
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object Label14: TLabel
      Left = 16
      Top = 8
      Width = 121
      Height = 24
      AutoSize = False
      Caption = #39033#30446#21517#31216' '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object sGroupBox1: TsGroupBox
      Left = 12
      Top = 40
      Width = 885
      Height = 137
      Caption = #24213#31295#34920#22836#20449#24687
      TabOrder = 0
      SkinData.SkinSection = 'GROUPBOX'
      object Label7: TLabel
        Left = 31
        Top = 27
        Width = 73
        Height = 13
        AutoSize = False
        Caption = #23458#25143#21333#20301
      end
      object Label8: TLabel
        Left = 32
        Top = 65
        Width = 57
        Height = 13
        AutoSize = False
        Caption = #32534#21046#20154
      end
      object lblfhrq: TLabel
        Left = 309
        Top = 101
        Width = 78
        Height = 13
        AutoSize = False
        Caption = #22797#26680#26085#26399
      end
      object lblfhr: TLabel
        Left = 35
        Top = 101
        Width = 63
        Height = 13
        AutoSize = False
        Caption = #22797#26680#20154
      end
      object Label6: TLabel
        Left = 308
        Top = 65
        Width = 66
        Height = 13
        AutoSize = False
        Caption = #32534#21046#26085#26399
      end
      object edtkhname: TEdit
        Left = 103
        Top = 27
        Width = 466
        Height = 21
        TabOrder = 0
        Text = 'Edit1'
      end
      object Button2: TButton
        Left = 756
        Top = 72
        Width = 109
        Height = 49
        Caption = #30830#35748
        TabOrder = 1
        OnClick = Button2Click
      end
      object cbbbzr: TComboBox
        Left = 104
        Top = 65
        Width = 113
        Height = 21
        ItemHeight = 13
        TabOrder = 2
        Text = 'cbbbzr'
      end
      object cbbfhr: TComboBox
        Left = 104
        Top = 101
        Width = 113
        Height = 21
        ItemHeight = 13
        TabOrder = 3
        Text = 'cbb1'
      end
      object edtbzrq: TsDateEdit
        Left = 448
        Top = 65
        Width = 121
        Height = 21
        AutoSize = False
        EditMask = '!9999/99/99;1; '
        MaxLength = 10
        TabOrder = 4
        Text = '    /  /  '
        BoundLabel.Indent = 0
        BoundLabel.Font.Charset = DEFAULT_CHARSET
        BoundLabel.Font.Color = clWindowText
        BoundLabel.Font.Height = -11
        BoundLabel.Font.Name = 'MS Sans Serif'
        BoundLabel.Font.Style = []
        BoundLabel.Layout = sclLeft
        BoundLabel.MaxWidth = 0
        BoundLabel.UseSkinColor = True
        SkinData.SkinSection = 'EDIT'
        GlyphMode.Blend = 0
        GlyphMode.Grayed = False
      end
      object edtfhrq: TsDateEdit
        Left = 448
        Top = 101
        Width = 121
        Height = 21
        AutoSize = False
        EditMask = '!9999/99/99;1; '
        MaxLength = 10
        TabOrder = 5
        Text = '    /  /  '
        BoundLabel.Indent = 0
        BoundLabel.Font.Charset = DEFAULT_CHARSET
        BoundLabel.Font.Color = clWindowText
        BoundLabel.Font.Height = -11
        BoundLabel.Font.Name = 'MS Sans Serif'
        BoundLabel.Font.Style = []
        BoundLabel.Layout = sclLeft
        BoundLabel.MaxWidth = 0
        BoundLabel.UseSkinColor = True
        SkinData.SkinSection = 'EDIT'
        GlyphMode.Blend = 0
        GlyphMode.Grayed = False
      end
    end
    object sGroupBox2: TsGroupBox
      Left = 11
      Top = 184
      Width = 886
      Height = 401
      Caption = #31185#30446#19982#24213#31295#25991#20214#24314#31435#20851#32852
      TabOrder = 1
      SkinData.SkinSection = 'GROUPBOX'
      object EjunDBGrid1: TEjunDBGrid
        Left = 8
        Top = 29
        Width = 511
        Height = 356
        OptionsEx = [goxStringGrid, goxSupportFormula, goxAutoCalculate]
        ColCount = 4
        RowCount = 6
        DefaultColWidth = 73
        Selection.AlphaBlend = False
        Selection.TransparentColor = False
        Selection.DisableDrag = False
        Selection.HideBorder = False
        FooterRowCount = 0
        DataSet = ADOTable1
        Active = False
        DataColumns = <
          item
            Width = 108
            Style.BgColor = clWindow
            Style.HorzAlign = haGeneral
            Style.VertAlign = vaCenter
            Style.Options = [gcoLocked]
            Visible = True
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            Title = #20195#30721
            UseColumnFont = False
            Name = #20195#30721
            FieldName = #20195#30721
          end
          item
            Width = 173
            Style.BgColor = clWindow
            Style.HorzAlign = haGeneral
            Style.VertAlign = vaCenter
            Style.Options = [gcoLocked]
            Visible = True
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            Title = #31185#30446#21517#31216
            UseColumnFont = False
            Name = #31185#30446#21517#31216
            FieldName = #31185#30446#21517#31216
          end
          item
            Width = 164
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
            Title = #24213#31295#21517#31216
            UseColumnFont = False
            Name = #24213#31295#21517#31216
            FieldName = #24213#31295#21517#31216
          end>
        TabOrder = 0
        TabStop = True
        PopupMenu = EjunDBGrid1.DefaultPopupMenu
        GridData = {
          090810000006050000000000000000000000000031004800F5FFFFFF00000100
          4D0053002000530061006E007300200053006500720069006600000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          E0004C0000000000FFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1F
          FFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1F00000000000000000000000100000000
          00000000050000FF080000FF00000000E0004C0000000000FFFFFF1FFFFFFF1F
          FFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1F
          0000000000000000000000010100000000000000050000FF080000FF00000060
          E0004C0000000000FFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1F
          FFFFFF1FFFFFFF1FFFFFFF1FFFFFFF1F00000000000000000000000100000000
          00000000050000FF080000FF00000074850017000000000000000845006A0075
          006E0047007200690064001E040400000000000A000000090810000007100000
          000000000000000000000000020E000100000005000000010003000000052031
          0066666666666629406666666666662940666666666666294066666666666629
          4066666666666629406666666666662940000A2031000101000000FFFFFFFF01
          000000FFFFFFFF00000000000000000000000000000000000000000000000000
          0000000000000009202A00090064000100000000000000020008000000000000
          0035403333333333B33D40000000000000000008007D000C0000000000580200
          00000000007D000C000100010054060100000000007D000C0002000200230A01
          00000000007D000C00030003009C0902000000000008021400000000000400FF
          000000000080010000FFFF000004021000000000000100000000000200E34E01
          7804021400000000000200000000000400D179EE760D54F07904021400000000
          000300000000000400955E3F7A0D54F079040214000100000001000000000004
          003100320034003100040214000100000002000000000004004F57268DC65107
          5904021400020000000100000000000400310034003000360004021400020000
          000200000000000400005FD153A74EC154040214000300000001000000000004
          00310034003100320004021E000300000002000000000009000553C5886972CA
          534E4F3C5013661780C154040214000400000001000000000004003100350032
          003400040218000400000002000000000006007F951F67A18043679562448D04
          0214000500000001000000000004003100360030003100040214000500000002
          00000000000400FA569A5B448DA74EE500020000000A00000000000000}
      end
      object EjunDBGrid2: TEjunDBGrid
        Left = 610
        Top = 30
        Width = 255
        Height = 355
        OptionsEx = [goxStringGrid, goxSupportFormula, goxAutoCalculate]
        ColCount = 2
        RowCount = 6
        DefaultColWidth = 73
        Selection.AlphaBlend = False
        Selection.TransparentColor = False
        Selection.DisableDrag = False
        Selection.HideBorder = False
        FooterRowCount = 0
        DataSet = ADOTable2
        Active = False
        DataColumns = <
          item
            Width = 172
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
            Name = #24213#31295#21517#31216
            FieldName = #24213#31295#21517#31216
          end>
        TabOrder = 1
        TabStop = True
        PopupMenu = EjunDBGrid2.DefaultPopupMenu
        OnDblClick = EjunDBGrid2DblClick
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
          0000000500000001000100000005203100666666666666294066666666666629
          4066666666666629406666666666662940666666666666294066666666666629
          40000A2031000101000000FFFFFFFF01000000FFFFFFFF000000000000000000
          000000000000000000000000000000000000000000000009202A000900640001
          000000000000000200080000000000000035403333333333B33D400000000000
          00000008007D000C000000000058020000000000007D000C0001000100140A01
          000000000008021400000000000200FF000000000080010000FFFF0000E50002
          0000000A00000000000000}
      end
      object btn1: TButton
        Left = 528
        Top = 320
        Width = 75
        Height = 25
        Caption = #37325#32622#23545#24212#20851#31995
        TabOrder = 2
      end
    end
  end
  inherited pnl2: TPanel
    Top = 0
    Width = 0
    Height = 347
    Align = alCustom
  end
  object sPathDialog1: TsPathDialog
    Root = 'rfDesktop'
    Left = 871
    Top = 515
  end
  object ADOTable1: TADOTable
    Connection = DataModule3.conxm
    CursorType = ctStatic
    TableName = #39033#30446#23545#24212#20851#31995
    Left = 783
    Top = 475
  end
  object EjunLicense1: TEjunLicense
    KeyID = 'y7ERk-Tyquk-RTV1G9Gh-fGdp'
    ProductID = 'B201008101065'
    UserID = #21525#21521#38451
    Left = 839
    Top = 563
  end
  object ADOTable2: TADOTable
    Connection = DataModule3.conxm
    CursorType = ctStatic
    TableName = #31185#30446#24213#31295#23545#24212#34920
    Left = 719
    Top = 475
  end
  object qrydg: TADOQuery
    Connection = DataModule3.conmain
    Parameters = <>
    Left = 655
    Top = 483
  end
end
