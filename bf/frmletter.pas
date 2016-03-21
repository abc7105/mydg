unit frmletter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Excel2000, adxAddIn,
  Dialogs, umb, ExtCtrls, StdCtrls, IniFiles, DateUtils;

type
  Tfmletter = class(Tfm_mb)
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Button1: TButton;
    Button3: TButton;
    GroupBox1: TGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    Label10: TLabel;
    Label12: TLabel;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Button2: TButton;
    GroupBox2: TGroupBox;
    Edit9: TEdit;
    Edit10: TEdit;
    Edit13: TEdit;
    Edit14: TEdit;
    Edit15: TEdit;
    Edit16: TEdit;
    Label9: TLabel;
    Label11: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Edit17: TEdit;
    Label17: TLabel;
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Label13Click(Sender: TObject);
  private

    ffilltocell: Boolean;
    fdgtitle: string;
    procedure setbook(const Value: excel2000._Application);
  published
    Fxlsapp: excel2000.TExcelApplication;
    { Private declarations }
  public
    { Public declarations }
    property filltocell: Boolean read ffilltocell write ffilltocell;
    property dgtitle: string read fdgtitle write fdgtitle;
    property xlsapp: excel2000._Application write setbook;
  end;
procedure showletter();

var
  fmletter: Tfmletter;

implementation

uses
  communit;

{$R *.dfm}

procedure showletter();
begin
  fmletter := Tfmletter.Create(nil);
  try
    fmletter.ShowModal;
  finally
    fmletter.Free;
    fmletter := nil;
  end;
end;

procedure Tfmletter.Button3Click(Sender: TObject);
begin
  inherited;

  Edit1.Enabled := true;
  Edit2.Enabled := true;
  Edit3.Enabled := true;
  Edit4.Enabled := true;
  Edit5.Enabled := true;
  Edit6.Enabled := true;

end;

procedure Tfmletter.FormCreate(Sender: TObject);
var
  myinifile: TIniFile;
  inifilename: string;

begin
  inherited;
  ffilltocell := False;

  inifilename := mainpath + 'xx.ini';
  Edit1.Clear;
  Edit2.Clear;
  Edit3.Clear;
  Edit4.Clear;
  Edit5.Clear;
  Edit6.Clear;

  Edit7.Clear;
  Edit8.Clear;
  Edit11.Clear;
  Edit12.Clear;

  Edit9.Clear;
  Edit10.Clear;
  Edit13.Clear;
  Edit14.Clear;
  Edit15.Clear;
  Edit16.Clear;
  Edit17.Clear;
  myinifile := TIniFile.Create(inifilename);

  try
    Edit1.Text := myinifile.ReadString('事务所', '事务所名称', '');
    Edit2.Text := myinifile.ReadString('事务所', '地址', '');
    Edit3.Text := myinifile.ReadString('事务所', '收件人', '');
    Edit5.Text := myinifile.ReadString('事务所', '电话', '');
    Edit4.Text := myinifile.ReadString('事务所', '传真', '');
    Edit6.Text := myinifile.ReadString('事务所', '邮政编码', '');

  except
  end;

  try
    Edit7.Text := myinifile.ReadString('系统设置', '保留副本的地址', '');
    Edit8.Text := myinifile.ReadString('系统设置', '自己的邮箱', '');
    Edit12.Text := myinifile.ReadString('系统设置', '邮箱密码', '');
    Edit11.Text := myinifile.ReadString('系统设置', '是否启动时显示导航', '');

  except
  end;

  try
    Edit9.Text := myinifile.ReadString('客户', '客户名称1', '');
    Edit10.Text := myinifile.ReadString('客户', '截止日', '');
    Edit13.Text := myinifile.ReadString('客户', '编制人', '');
    Edit14.Text := myinifile.ReadString('客户', '编制日期', '');
    Edit15.Text := myinifile.ReadString('客户', '复核人', '');
    Edit16.Text := myinifile.ReadString('客户', '复核日期', '');
    Edit17.Text := myinifile.ReadString('客户', '底稿名称', '');
  except
  end;

  myinifile.Destroy;

end;

procedure Tfmletter.Button2Click(Sender: TObject);
var
  myinifile: TIniFile;
  inifilename: string;
begin
  inherited;
  try
    inifilename := mainpath + 'xx.ini';
    myinifile := TIniFile.Create(inifilename);
    myinifile.WriteString('系统设置', '保留副本的地址', Edit7.text);
    myinifile.WriteString('系统设置', '自己的邮箱', Edit8.Text);
    myinifile.WriteString('系统设置', '邮箱密码', Edit12.Text);
    myinifile.WriteString('系统设置', '是否启动时显示导航', Edit11.Text);
    myinifile.Destroy;
  except

  end;
end;

procedure Tfmletter.Button1Click(Sender: TObject);
var
  myinifile: TIniFile;
begin
  inherited;
  try
    myinifile := TIniFile.Create(mainpath + 'xx.ini');
    myinifile.WriteString('事务所', '事务所名称', Edit1.Text);
    myinifile.WriteString('事务所', '地址', Edit2.Text);
    myinifile.WriteString('事务所', '收件人', Edit3.Text);
    myinifile.WriteString('事务所', '电话', Edit5.Text);
    myinifile.WriteString('事务所', '传真', Edit4.Text);
    myinifile.WriteString('事务所', '邮政编码', Edit6.Text);
    myinifile.Destroy;
  except

  end;
end;

procedure Tfmletter.Button5Click(Sender: TObject);
var
  myinifile: TIniFile;
  inifilename: string;
begin
  inherited;
  try
    inifilename := mainpath + 'xx.ini';
    myinifile := TIniFile.Create(inifilename);
    myinifile.WriteString('客户', '客户名称1', Edit9.text);
    myinifile.WriteString('客户', '截止日', Edit10.Text);
    myinifile.WriteString('客户', '编制人', Edit13.Text);
    myinifile.WriteString('客户', '编制日期', Edit14.Text);
    myinifile.WriteString('客户', '复核人', Edit15.Text);
    myinifile.WriteString('客户', '复核日期', Edit16.Text);
    myinifile.WriteString('客户', '底稿名称', Edit17.Text);
    myinifile.Destroy;
  except

  end;
end;

procedure Tfmletter.Button6Click(Sender: TObject);
var
  yy: integer;
  dstr: string;

begin
  inherited;
  yy := yearof(now);
  dstr := Trim(IntToStr(yy - 1)) + '年12月31日';

  Edit10.Text := dstr;

  Edit14.Text := formatdatetime('yyyy/mm/dd', now);
  Edit16.Text := formatdatetime('yyyy/mm/dd', now + 5);

end;

procedure Tfmletter.Button7Click(Sender: TObject);
begin
  inherited;
  ffilltocell := True;
  fdgtitle := edit17.text;
  Button5.Click;
  close;
end;

procedure Tfmletter.Label13Click(Sender: TObject);
begin
  inherited;
  Edit14.Text := FormatDateTime('yyyy-mm-dd', now);
  Edit16.Text := formatdatetime('yyyy-mm-dd', incday(Now, 5));
  Edit10.Text := IntToStr(YearOf(now) - 1) + '-12-31';

end;

procedure Tfmletter.setbook(const Value: excel2000._Application);
begin
  //
  Fxlsapp := TExcelApplication.Create(nil);
  Fxlsapp.ConnectTo(Value);
  Fxlsapp.DisplayAlerts[adxLCID] := False;
end;

end.
