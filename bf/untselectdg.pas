unit untselectdg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, ADODB,
  Dialogs, sAlphaListBox, StdCtrls, CheckLst;

type
  Tfmselectdg = class(TForm)
    schecklistbox1: TCheckListBox;
    btn1: TButton;
    btn2: TButton;
    btn3: TButton;
    procedure FormShow(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
  private
    fcon: tadoconnection;
    function getlist: TStringList;
    procedure SETLIST(const Value: TStringList);
    { Private declarations }
  public
    { Public declarations }

  published
    property kmlist: TStringList read getlist write SETLIST;
  end;

var
  fmselectdg: Tfmselectdg;

implementation

uses
  communit, CLSexcel;

{$R *.dfm}

procedure Tfmselectdg.FormShow(Sender: TObject);
var
  dgnames: TStringList;
begin

end;

function Tfmselectdg.getlist: TStringList;
var
  lista: TStringList;
  i: Integer;
begin
  result := nil;
  try
    lista := TStringList.Create;
    for i := 0 to sCheckListBox1.items.count - 1 do
    begin
      if sCheckListBox1.Checked[i] then
        lista.Add(sCheckListBox1.Items[i]);
    end;
    result := lista;
  except
  end;

end;

procedure Tfmselectdg.btn1Click(Sender: TObject);
begin
  Self.Close;
end;

procedure Tfmselectdg.btn2Click(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to sCheckListBox1.count - 1 do
    schecklistbox1.Checked[i] := True;
end;

procedure Tfmselectdg.btn3Click(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to sCheckListBox1.count - 1 do
    schecklistbox1.Checked[i] := false;
end;

procedure Tfmselectdg.SETLIST(const Value: TStringList);
var
  lista: TStringList;
  i: Integer;
begin
  lista := Value;
  for i := 0 to lista.count - 1 do
  begin
    sCheckListBox1.Items.Add(lista[i]);
  end;

end;

end.

