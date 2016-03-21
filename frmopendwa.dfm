object fmopendw: Tfmopendw
  Left = 639
  Top = 162
  Width = 617
  Height = 411
  Caption = #25171#24320#23457#35745#39033#30446
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object dbgrid2: TDBGrid
    Left = 24
    Top = 24
    Width = 553
    Height = 297
    DataSource = ds1
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
    ReadOnly = True
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    OnDblClick = dbgrid2DblClick
    Columns = <
      item
        Expanded = False
        Width = 50
        Visible = True
      end
      item
        Expanded = False
        Width = 163
        Visible = True
      end
      item
        Expanded = False
        Width = 273
        Visible = True
      end>
  end
  object btn1: TButton
    Left = 160
    Top = 336
    Width = 75
    Height = 25
    Caption = #25171#24320#39033#30446
    TabOrder = 1
    OnClick = btn1Click
  end
  object btn2: TButton
    Left = 296
    Top = 336
    Width = 75
    Height = 25
    Caption = #21462#28040#36864#20986
    TabOrder = 2
    OnClick = btn2Click
  end
  object btn3: TButton
    Left = 424
    Top = 336
    Width = 105
    Height = 25
    Caption = #36827#20837#23457#35745#20013#24515
    TabOrder = 3
    OnClick = btn3Click
  end
  object btn4: TButton
    Left = 64
    Top = 336
    Width = 75
    Height = 25
    Caption = #21024#38500#39033#30446
    TabOrder = 4
    OnClick = btn4Click
  end
  object ds1: TDataSource
    DataSet = qry1
    Left = 48
    Top = 320
  end
  object qry1: TADOQuery
    Connection = con1
    Parameters = <>
    Left = 104
    Top = 192
  end
  object con1: TADOConnection
    Connected = True
    ConnectionString = 
      'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=D:\2014prg\mydg\DG.' +
      'mdb;Persist Security Info=False'
    LoginPrompt = False
    Mode = cmShareDenyNone
    Provider = 'Microsoft.Jet.OLEDB.4.0'
    Left = 88
  end
  object qrytmp: TADOQuery
    Connection = con1
    Parameters = <>
    Left = 152
    Top = 16
  end
end
