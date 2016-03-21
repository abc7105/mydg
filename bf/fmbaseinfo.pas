unit fmbaseinfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Excel2000, adxAddIn, communit,
  Dialogs, frmletter, StdCtrls, ExtCtrls;

type
  Tfrmbaseinfo = class(Tfmletter)
    btn1: TButton;
    procedure btn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmbaseinfo: Tfrmbaseinfo;

implementation

{$R *.dfm}

procedure Tfrmbaseinfo.btn1Click(Sender: TObject);
var
  ASHEET, oldsheet: _Worksheet;
  i, j: integer;
  str: string;
  cellrows: integer;

begin
  inherited;
  //
  case MessageDlg('请确认您是否从当前工作簿的【审定表】表中提取底稿基本信息？',
    mtCustom, mbOKCancel, 0) of
    mrOk:
      begin

      end;
    mrCancel:
      begin
        exit;
      end;
  end;

  try
    oldsheet := Fxlsapp.ActiveCell.Worksheet;
    ASHEET := _Worksheet(Fxlsapp.activeworkbook.sheets.item['审定表']);
    for i := 1 to 8 do
      for J := 2 to 4 do
      begin
        ASHEET.activate(adxLCID);
        ASHEET.cells.Item[i, J].select;
        cellrows := excelrange(Fxlsapp.Selection[adxLCID]).COLUMNS.Count;
        if (cellrows > 10) and (Pos('被审计单位', ASHEET.cells.Item[i, J].text)
          >
          0) then
        begin
          str := ASHEET.cells.Item[i, J].text;
          Edit9.Text := betweenstr(str, '单位', '编制');
          edit13.Text := betweenstr(str, '编制', '日期');
          edit14.Text := betweenstr(str, '日期', '索引号');

          str := Trim(Copy(str, Pos('索引', str), Length(str)));
          Edit10.Text := trim(betweenstr(str, '报表', '年')) + '年12月31日';
          edit15.Text := betweenstr(str, '复核', '日期');
          edit16.Text := betweenstr(str, '日期', '项目');

          break;

        end;
      end;

    oldSHEET.activate(adxLCID);
  except
    showmessage('当前工作簿中无审定表，或都从审定表中取底稿信息时失败，请检查！');
    oldSHEET.activate(adxLCID);
    exit;
  end;

end;

end.

