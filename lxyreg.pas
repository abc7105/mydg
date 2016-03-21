unit lxyreg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,  registry, ShellApi, OleCtrls, SHDocVw, ExtCtrls, lxyjm,
  bsSkinData, BusinessSkinForm, bsSkinCtrls, StdCtrls;

type
  Tformreg = class(TForm)
    Panel3: TPanel;
    Label1: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label2: TLabel;
    Edit5: TEdit;
    Timer1: TTimer;
    bsBusinessSkinForm1: TbsBusinessSkinForm;
    bsSkinData1: TbsSkinData;
    bsCompressedStoredSkin1: TbsCompressedStoredSkin;
    Button2: TbsSkinSpeedButton;
    Button1: TbsSkinSpeedButton;
    Button5: TbsSkinSpeedButton;
    Button3: TButton;
    edt1: TEdit;
    Button4: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);

    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  formreg: Tformreg;
  sj: integer;
  AJM: tlxyjm;


implementation

uses UnitHardInfo, md5, Crc32, shareunit;

{$R *.dfm}

procedure Tformreg.FormCreate(Sender: TObject);
begin
  AJM := tlxyjm.create(Application.GetNamePath);
  edt1.Clear;
  Edit5.Clear;
end;

procedure Tformreg.Button1Click(Sender: TObject);
begin
 // Edit5.Text := AJM.geneserial;
end;

procedure Tformreg.Button2Click(Sender: TObject);
begin
  Edit5.text := AJM.GeneralREGSN(Edt1.Text);
end;

procedure Tformreg.Button3Click(Sender: TObject);
begin
  if AJM.check1 then mymessage('OK1');
  if AJM.check2 then mymessage('OK2');
  if AJM.check3 then mymessage('OK3');

end;

procedure Tformreg.Button4Click(Sender: TObject);
var S1: string;
begin
  S1 := AJM.GeneralREGSN(Edt1.Text);
  mymessage(S1);
end;

procedure Tformreg.Button5Click(Sender: TObject);
begin
  close;
end;

end.
