unit fmnewdw;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Mask, sMaskEdit, DateUtils, StrUtils, communit, ushare,
  sCustomComboEdit, sTooledit, Buttons, sDialogs, DB, ADODB;

type
  Tfmadddw = class(TForm)
    pnl1: TPanel;
    lbl1: TLabel;
    lbl2: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    edtxm: TEdit;
    edtdw: TEdit;
    cbb1: TComboBox;
    sDateEdit1: TsDateEdit;
    btn1: TButton;
    btn2: TButton;
    edtpath: TEdit;
    Label3: TLabel;
    btn3: TBitBtn;
    sPathDialog1: TsPathDialog;
    qry1: TADOQuery;
    sDateEdit2: TsDateEdit;
    Label4: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);
  private
    fcon: TADOConnection;
    procedure setfcon(const Value: TADOConnection);
    { Private declarations }
  public
    { Public declarations }
  published
    property connection: TADOConnection write setfcon;

  end;

var
  fmadddw: Tfmadddw;

implementation

uses
  CLSexcel;

{$R *.dfm}

procedure Tfmadddw.FormCreate(Sender: TObject);
var
  stmp: TDateTime;
  i: integer;
begin
  edtxm.Clear;
  edtdw.Clear;
  edtpath.text := mainpath + '项目文件夹';
  cbb1.Items.Clear;
  cbb1.Text := '';
  sDateEdit1.Clear;
  stmp := EncodeDate(yearof(now) - 1, 12, 31);
  //stmp := encodedate(yearof(now) - 1) + '/' + '12/31';

  sDateEdit1.Date := stmp;
  stmp := EncodeDate(yearof(now) - 1, 1, 1);
  //  stmp := IntToStr(yearof(now) - 1) + '/' + '01/01';
  sDateEdit2.Date := stmp;

end;

procedure Tfmadddw.btn3Click(Sender: TObject);
begin
  try
    try
      MkDir(mainpath + '项目文件夹');
    except
    end;
    sPathDialog1.Path := mainpath + '项目文件夹';
  except
    sPathDialog1.Path := 'c:\';
  end;
  sPathDialog1.Execute;
  if sPathDialog1.Path <> '' then
    edtpath.Text := sPathDialog1.Path
  else
    edtpath.Clear;
end;

procedure Tfmadddw.setfcon(const Value: TADOConnection);
var
  i: integer;
begin
  //
  fcon := Value;
  qry1.Connection := ADGSYSTEM.connection;
  qry1.Close;
  qry1.SQL.Clear;
  qry1.SQL.Add('select * from mb');
  qry1.Open;

  qry1.First;
  for i := 1 to qry1.RecordCount do
  begin
    cbb1.Items.Add(Trim(qry1.fieldbyname('mbid').asstring) + ' ' + Trim(qry1.fieldbyname('mbname').asstring));
    qry1.Next;
  end;
end;

procedure Tfmadddw.btn2Click(Sender: TObject);
begin
  close;

end;

procedure Tfmadddw.btn1Click(Sender: TObject);
var
  tb: TADOTable;
  filename, aUserName, apassword: string;
begin
  if (Trim(edtxm.text) = '') or
    (Trim(edtdw.text) = '') or
    (Trim(sDateEdit1.text) = '') or
    (Trim(sDateEdit2.text) = '') or
    (Trim(cbb1.text) = '') or
    (Trim(edtpath.text) = '') then
  begin
    mymessage('数据没有输入完整，请检查！');
    exit;
  end;

  axm.xmname := edtxm.Text;
  axm.startrq := sDateEdit2.Date;
  axm.endrq := sDateEdit1.Date;
  axm.dwmc := edtdw.Text;
  axm.xmid := ADGSYSTEM.getmaxxmid;
  if RightStr(trim(edtpath.Text), 1) = '\' then
    axm.xmpath := edtpath.Text + trim(edtxm.text)
  else
    axm.xmpath := edtpath.Text + '\' + trim(edtxm.text);

  axm.mbid := copy(cbb1.Text, 1, 3);
  axm.MBNAME := Trim(copy(cbb1.Text, 4, Length(cbb1.Text) - 4));
  ADGSYSTEM.newxm(axm);

  if not CopyFile(PChar(mainpath + 'MB.DAT'), PChar(axm.xmpath + '\dg.mdb'), false) then
  begin
    mymessage('处理过程中数据库文件复制失败，项目建立失败！');
    exit;
  end;

  mymessage('项目建立成功！');
  close;

end;

end.

