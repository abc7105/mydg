object fmadddw: Tfmadddw
  Left = 692
  Top = 331
  Width = 635
  Height = 412
  ActiveControl = sDateEdit1
  Caption = #24314#31435#26032#23457#35745#39033#30446
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnl1: TPanel
    Left = 16
    Top = 16
    Width = 569
    Height = 281
    TabOrder = 0
    object lbl1: TLabel
      Left = 56
      Top = 56
      Width = 120
      Height = 13
      AutoSize = False
      Caption = #39033#30446#21517#31216
    end
    object lbl2: TLabel
      Left = 56
      Top = 96
      Width = 120
      Height = 13
      AutoSize = False
      Caption = #34987#23457#35745#21333#20301#20840#21517
    end
    object Label1: TLabel
      Left = 56
      Top = 128
      Width = 120
      Height = 13
      AutoSize = False
      Caption = #23457#35745#26399#38388
    end
    object Label2: TLabel
      Left = 56
      Top = 168
      Width = 120
      Height = 13
      AutoSize = False
      Caption = #36873#29992#20250#35745#25919#31574
    end
    object Label3: TLabel
      Left = 56
      Top = 200
      Width = 120
      Height = 13
      AutoSize = False
      Caption = #25991#20214#36335#24452
    end
    object Label4: TLabel
      Left = 304
      Top = 128
      Width = 25
      Height = 17
      AutoSize = False
      Caption = #33267
    end
    object edtxm: TEdit
      Left = 184
      Top = 56
      Width = 273
      Height = 21
      TabOrder = 0
      Text = 'edtxm'
    end
    object edtdw: TEdit
      Left = 184
      Top = 96
      Width = 273
      Height = 21
      TabOrder = 1
      Text = 'edtdw'
    end
    object cbb1: TComboBox
      Left = 184
      Top = 168
      Width = 273
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 2
    end
    object sDateEdit1: TsDateEdit
      Left = 336
      Top = 128
      Width = 121
      Height = 21
      AutoSize = False
      EditMask = '!9999/99/99;1; '
      MaxLength = 10
      TabOrder = 3
      Text = '    -  -  '
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
    object edtpath: TEdit
      Left = 184
      Top = 200
      Width = 273
      Height = 21
      ReadOnly = True
      TabOrder = 4
      Text = 'edtpath'
    end
    object btn3: TBitBtn
      Left = 472
      Top = 196
      Width = 49
      Height = 25
      Caption = '>>>'
      TabOrder = 5
      OnClick = btn3Click
    end
    object sDateEdit2: TsDateEdit
      Left = 184
      Top = 128
      Width = 121
      Height = 21
      AutoSize = False
      EditMask = '!9999/99/99;1; '
      MaxLength = 10
      TabOrder = 6
      Text = '    -  -  '
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
  object btn1: TButton
    Left = 208
    Top = 320
    Width = 89
    Height = 25
    Caption = #30830#23450' '
    TabOrder = 1
    OnClick = btn1Click
  end
  object btn2: TButton
    Left = 352
    Top = 320
    Width = 75
    Height = 25
    Caption = #21462#28040#36864#20986' '
    TabOrder = 2
    OnClick = btn2Click
  end
  object sPathDialog1: TsPathDialog
    Root = 'rfDesktop'
    Left = 64
    Top = 248
  end
  object qry1: TADOQuery
    Parameters = <>
    Left = 104
    Top = 328
  end
end
