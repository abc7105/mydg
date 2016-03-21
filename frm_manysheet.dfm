inherited fmmanysheet: Tfmmanysheet
  Left = 375
  Top = 245
  Width = 905
  Height = 505
  Caption = ''
  OldCreateOrder = True
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnl1: TPanel
    Width = 889
    Height = 113
    object Button3: TButton
      Left = 424
      Top = 8
      Width = 137
      Height = 25
      Caption = #25171#21360#21487#35265#34920
      TabOrder = 10
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 424
      Top = 40
      Width = 137
      Height = 25
      Caption = #25171#21360#22810#25991#20214#21487#35265#34920
      TabOrder = 11
      OnClick = Button4Click
    end
    object BitBtn1: TBitBtn
      Left = 304
      Top = 8
      Width = 113
      Height = 25
      Caption = #30452#25509#25171#21360
      TabOrder = 0
      Visible = False
      OnClick = BitBtn1Click
    end
    object BitBtn2: TBitBtn
      Left = 304
      Top = 40
      Width = 113
      Height = 25
      Caption = #33258#21160#36866#37197#39029#38754#21518#25171#21360
      TabOrder = 1
      Visible = False
      OnClick = BitBtn2Click
    end
    object BitBtn3: TBitBtn
      Left = 672
      Top = 8
      Width = 75
      Height = 25
      Caption = #38544#34255
      TabOrder = 2
      OnClick = BitBtn3Click
    end
    object BitBtn4: TBitBtn
      Left = 672
      Top = 40
      Width = 75
      Height = 25
      Caption = #21462#28040#38544#34255
      TabOrder = 3
      OnClick = BitBtn4Click
    end
    object BitBtn5: TBitBtn
      Left = 256
      Top = 8
      Width = 75
      Height = 25
      Caption = #21024#38500#34920
      TabOrder = 4
      OnClick = BitBtn5Click
    end
    object BitBtn6: TBitBtn
      Left = 256
      Top = 40
      Width = 75
      Height = 25
      Caption = #21478#23384#20026#25991#20214
      TabOrder = 5
      OnClick = BitBtn6Click
    end
    object BitBtn7: TBitBtn
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = #20840#36873
      TabOrder = 6
      OnClick = BitBtn7Click
    end
    object BitBtn8: TBitBtn
      Left = 8
      Top = 40
      Width = 75
      Height = 25
      Caption = #20840#19981#36873
      TabOrder = 7
      OnClick = BitBtn8Click
    end
    object Button1: TButton
      Left = 520
      Top = 8
      Width = 137
      Height = 25
      Caption = #20844#24335#36716#21270#20540
      TabOrder = 8
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 520
      Top = 40
      Width = 137
      Height = 25
      Caption = #34920#22806#38142#25509#36716#21270#20026#20540
      TabOrder = 9
      OnClick = Button2Click
    end
    object Button5: TButton
      Left = 336
      Top = 72
      Width = 137
      Height = 25
      Caption = #22810#34920#21512#24182#20026#19968#34920
      TabOrder = 12
      OnClick = Button5Click
    end
    object Button6: TButton
      Left = 176
      Top = 72
      Width = 137
      Height = 25
      Caption = #22810#20010#25991#20214#21512#24182#20026#19968#20010
      TabOrder = 13
      OnClick = Button6Click
    end
    object btn1: TButton
      Left = 96
      Top = 40
      Width = 153
      Height = 25
      Caption = #22810#25991#20214#25171#21360'-'#26631#31614#24425#33394#34920
      TabOrder = 14
      OnClick = btn1Click
    end
    object btn2: TButton
      Left = 96
      Top = 8
      Width = 153
      Height = 25
      Caption = #36873#24425#33394#26631#31614#30340#34920
      TabOrder = 15
      OnClick = btn2Click
    end
    object edt1: TEdit
      Left = 752
      Top = 44
      Width = 121
      Height = 21
      TabOrder = 16
      Text = 'edt1'
      OnKeyPress = edt1KeyPress
    end
  end
  inherited pnl2: TPanel
    Top = 113
    Width = 889
    Height = 353
    object CheckListBox1: TCheckListBox
      Left = 1
      Top = 1
      Width = 887
      Height = 334
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      IntegralHeight = True
      ItemHeight = 22
      ParentFont = False
      Style = lbOwnerDrawFixed
      TabOrder = 0
      OnDblClick = CheckListBox1DblClick
    end
  end
  object SaveDialog1: TSaveDialog
    Left = 184
    Top = 97
  end
  object OpenDialog1: TOpenDialog
    Options = [ofAllowMultiSelect]
    Left = 336
    Top = 105
  end
end
