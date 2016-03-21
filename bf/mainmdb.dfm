object DataModule3: TDataModule3
  OldCreateOrder = False
  Left = 396
  Top = 284
  Height = 292
  Width = 468
  object conxm: TADOConnection
    ConnectionString = 
      'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=D:\2014prg\mydg\DG.' +
      'mdb;Persist Security Info=False;'
    LoginPrompt = False
    Mode = cmShareDenyNone
    Provider = 'Microsoft.Jet.OLEDB.4.0'
    Left = 88
    Top = 16
  end
  object conmain: TADOConnection
    LoginPrompt = False
    Left = 24
    Top = 16
  end
end
