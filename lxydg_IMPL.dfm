object AddInModule: TAddInModule
  OldCreateOrder = True
  AddInName = 'lxydgs'
  LoadBehavior = 3
  SupportedApps = [ohaExcel]
  OnAddInInitialize = adxCOMAddInModuleAddInInitialize
  OnAddInFinalize = adxCOMAddInModuleAddInFinalize
  TaskPanes = <
    item
      ControlProgID = 'lxydg.dg'
      Title = 'lxy's dg'
    end>
  Left = 225
  Top = 140
  Height = 400
  Width = 380
end
