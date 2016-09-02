unit reg;

interface

uses
  Classes, Controls, Forms, Dialogs,
  StdCtrls, lxyjm, lxyjmA,
  bsSkinCtrls,
  ExtCtrls;

type
  Tfmreg = class(TForm)
    lbl1: TLabel;
    lbl2: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    lbl6: TLabel;
    lbl7: TLabel;
    lbl8: TLabel;
    Button2: TbsSkinSpeedButton;
    Button5: TbsSkinSpeedButton;
    edt1: TEdit;
    edt2: TEdit;
    lblok: TLabel;
    lblerr: TLabel;
    lbl9: TLabel;
    lbl11: TbsSkinLinkLabel;
    Label1: TLabel;
    GroupBox1: TGroupBox;
    bsSkinLinkLabel1: TbsSkinLinkLabel;
    Shape1: TShape;
    lblk: TLabel;
    lbl3: TbsSkinLinkLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  published
    procedure disperr(bok: Boolean);
  end;

var
  fmreg: Tfmreg;
  sj: integer;
  ajm: tlxyjm;

implementation

uses
  jm,  communit, Udebug;

{$R *.dfm}

procedure Tfmreg.FormCreate(Sender: TObject);
begin
  ajm := tlxyjm.CREATE(mainpath);
  edt1.Text := ajm.thispc_MachineNumber; //
  edt2.Text := ajm.thispc_regNumber;
  if ajm.check2 then
    lblerr.Visible := false;

end;

procedure Tfmreg.Button2Click(Sender: TObject);
begin
  //
  SHOWMESSAGE('请关闭程序后重新打开，检查注册是否成功！');

  ajm.usersn := edt2.Text;
  ajm.writeToReg;

  CLOSE;

end;

procedure Tfmreg.Button5Click(Sender: TObject);
begin
  close;
end;

procedure Tfmreg.disperr(bok: Boolean);
begin
  lblerr.Visible := not bok;
end;

end.

