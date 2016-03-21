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
  case MessageDlg('��ȷ�����Ƿ�ӵ�ǰ�������ġ��󶨱�������ȡ�׸������Ϣ��',
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
    ASHEET := _Worksheet(Fxlsapp.activeworkbook.sheets.item['�󶨱�']);
    for i := 1 to 8 do
      for J := 2 to 4 do
      begin
        ASHEET.activate(adxLCID);
        ASHEET.cells.Item[i, J].select;
        cellrows := excelrange(Fxlsapp.Selection[adxLCID]).COLUMNS.Count;
        if (cellrows > 10) and (Pos('����Ƶ�λ', ASHEET.cells.Item[i, J].text)
          >
          0) then
        begin
          str := ASHEET.cells.Item[i, J].text;
          Edit9.Text := betweenstr(str, '��λ', '����');
          edit13.Text := betweenstr(str, '����', '����');
          edit14.Text := betweenstr(str, '����', '������');

          str := Trim(Copy(str, Pos('����', str), Length(str)));
          Edit10.Text := trim(betweenstr(str, '����', '��')) + '��12��31��';
          edit15.Text := betweenstr(str, '����', '����');
          edit16.Text := betweenstr(str, '����', '��Ŀ');

          break;

        end;
      end;

    oldSHEET.activate(adxLCID);
  except
    showmessage('��ǰ�����������󶨱��򶼴��󶨱���ȡ�׸���Ϣʱʧ�ܣ����飡');
    oldSHEET.activate(adxLCID);
    exit;
  end;

end;

end.

