object dg: Tdg
  Left = 676
  Top = 91
  Width = 386
  Height = 589
  AxBorderStyle = afbNone
  Caption = 'dg'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = ActiveFormActivate
  OnCreate = ActiveFormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 20
    Top = 5
    Width = 141
    Height = 34
    Caption = 'Task Pane'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnShadow
    Font.Height = -29
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object pnl1: TPanel
    Left = 355
    Top = 0
    Width = 15
    Height = 550
    Align = alRight
    Caption = '<<'
    Color = clMenuHighlight
    TabOrder = 0
    OnClick = pnl1Click
  end
  object pgc1: TPageControl
    Left = 0
    Top = 0
    Width = 355
    Height = 550
    ActivePage = ts1
    Align = alClient
    TabOrder = 1
    object ts1: TTabSheet
      Caption = 'ts1'
      object EjunDBGrid1: TEjunDBGrid
        Left = 0
        Top = 0
        Width = 347
        Height = 522
        Options = [goRangeSelect, goRowSelect, goRowSizing, goColSizing, goUnequalRowHeight, goFixedRowShowNo, goFixedColShowNo, goAlwaysShowSelection]
        OptionsEx = [goxStringGrid, goxSupportFormula, goxAutoCalculate]
        ColCount = 2
        RowCount = 6
        DefaultColWidth = 73
        Selection.AlphaBlend = False
        Selection.TransparentColor = False
        Selection.DisableDrag = False
        Selection.HideBorder = False
        AllowEdit = False
        Align = alClient
        FooterRowCount = 0
        DataSet = qry1
        DataColumns = <
          item
            Width = 228
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
            Title = #25991#20214#21517
            UseColumnFont = False
            Name = 'displayname'
            FieldName = 'displayname'
          end>
        TabOrder = 0
        TabStop = True
        PopupMenu = EjunDBGrid1.DefaultPopupMenu
        OnDblClick = EjunDBGrid1DblClick
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
          00000008007D000C0000000000C2010000000000007D000C00010001005C0D01
          000000000008021400000000000200FF000000000080010000FFFF0000040212
          000000000001000000000003008765F64E0D5404022400010000000100000000
          000C0020002000200020001A4EA1527B7C2B52C48BF74E688820000402280002
          0000000100000000000E004100420020001A4EA152DD4F0163C48BF74E68882E
          0078006C00730004021C00030000000100000000000800200020002000200095
          5E3F7AEE76555F04022400040000000100000000000C0020002000200020001A
          4EA152DD4F0163C48BF74EA5624A5404022400050000000100000000000C0020
          002000200020001A4EA152DD4F01636297088CB08B555FE500020000000A0000
          0000000000}
      end
    end
  end
  object EjunLicense1: TEjunLicense
    KeyID = 'y7ERk-Tyquk-RTV1G9Gh-fGdp'
    ProductID = 'B201008101065'
    UserID = #21525#21521#38451
    Left = 408
    Top = 56
  end
  object con1: TADOConnection
    Connected = True
    ConnectionString = 
      'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=D:\DGNEW\DG.mdb;Per' +
      'sist Security Info=False'
    LoginPrompt = False
    Mode = cmShareDenyNone
    Provider = 'Microsoft.Jet.OLEDB.4.0'
    Left = 304
    Top = 374
  end
  object EjunLicense2: TEjunLicense
    KeyID = 'y7ERk-Tyquk-RTV1G9Gh-fGdp'
    ProductID = 'B201008101065'
    UserID = #21525#21521#38451
    Left = 136
    Top = 288
  end
  object qry1: TADOQuery
    Connection = con1
    Parameters = <>
    Left = 100
    Top = 200
  end
end
