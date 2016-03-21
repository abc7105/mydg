unit reg;

interface

uses
  Classes, Controls, Forms,
  StdCtrls, lxyjm, Dialogs, bsSkinCtrls;

type
  Tfmreg = class(TForm)
    lbl4: TLabel;
    lbl8: TLabel;
    edt1: TEdit;
    edt2: TEdit;
    Button2: TButton;
    Button5: TButton;
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
  myjm: tlxyjm;


implementation



{$R *.dfm}

procedure Tfmreg.FormCreate(Sender: TObject);
begin
  myjm := tlxyjm.create;
  edt1.text := '';
  edt2.text := '';

end;

procedure Tfmreg.Button2Click(Sender: TObject);
begin
 //


  edt2.Text := myjm.TOKH(edt1.text);
end;

procedure Tfmreg.Button5Click(Sender: TObject);
begin
  Self.close;
end;

procedure Tfmreg.disperr(bok: Boolean);
begin

end;

end.

