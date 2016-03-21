unit frminfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, umb, ExtCtrls, StdCtrls, DateUtils, Buttons, sDialogs, CLSexcel,
  sGroupBox, DB, ADODB, ZcUniClass, ZJGrid, ZcDataGrid, ZcDBGrids, communit,   ushare,
  ZcGridClasses, Mask, sMaskEdit, sCustomComboEdit, sTooledit;
const
  adxVersion: string = '3.7.395';
  adxLCID: Integer = LOCALE_USER_DEFAULT;

type
  Tfminfo = class(Tfm_mb)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    sPathDialog1: TsPathDialog;
    Label9: TLabel;
    sGroupBox1: TsGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    lblfhrq: TLabel;
    lblfhr: TLabel;
    Label6: TLabel;
    edtkhname: TEdit;
    sGroupBox2: TsGroupBox;
    ADOTable1: TADOTable;
    EjunLicense1: TEjunLicense;
    EjunDBGrid1: TEjunDBGrid;
    EjunDBGrid2: TEjunDBGrid;
    ADOTable2: TADOTable;
    qrydg: TADOQuery;
    Button2: TButton;
    Label11: TLabel;
    lblxmname: TLabel;
    Label14: TLabel;
    shp1: TShape;
    cbbbzr: TComboBox;
    cbbfhr: TComboBox;
    btn1: TButton;
    edtbzrq: TsDateEdit;
    edtfhrq: TsDateEdit;

    procedure FormCreate(Sender: TObject);
    procedure EjunDBGrid2DblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    fxlsapp: Variant;
    //    procedure setbook(const Value: Variant);
    procedure saveinfo();
    procedure clearedit();
    procedure dispXMINFO();
    procedure saveXMINFO();
    { Private declarations }
  public
    { Public declarations }
  published
    //    property xlsapp: Variant write setbook;

  end;
var
  fminfo: Tfminfo;
  adgworkbook: dgworkbook;

implementation

{$R *.dfm}

procedure Tfminfo.FormCreate(Sender: TObject);
var
  ausername, apassword, filename: string;
begin
  inherited;
  //重要的地方
  clearedit;
  adgworkbook := dgworkbook.create;
  axm := adgsystem.OPENLAST;
  adgworkbook.xm := axm;
  lblxmname.Caption := axm.xmname + '(' + AXM.MBNAME + ')';

end;

procedure Tfminfo.EjunDBGrid2DblClick(Sender: TObject);
begin
  inherited;
  //
  ADOTable1.Edit;
  ADOTable1.FieldByName('底稿名称').AsString := ADOTable2.FieldByName('底稿名称').AsString;
  ADOTable1.Post;
end;

procedure Tfminfo.FormShow(Sender: TObject);
begin
  inherited;
  ADOTable1.Connection := adgworkbook.connection;
  ADOTable2.Connection := adgworkbook.connection;
  qrydg.Connection := ADGSYSTEM.connection;

  if ADOTable1.Active then
    ADOTable1.Close;
  if ADOTable2.Active then
    ADOTable2.Close;

  ADOTable1.Open;
  ADOTable1.Filter := 'xmid=''' + axm.xmid + '''';
  ADOTable1.Filtered := true;
  ADOTable2.Open;
  ADOTable2.Filter := 'mbid=''' + axm.mbid + '''';
  ADOTable2.Filtered := true;

  EjunDBGrid1.DataSet := ADOTable1;
  EjunDBGrid2.DataSet := ADOTable2;

  EjunDBGrid1.Activate(True);
  EjunDBGrid2.Activate(True);

  dispXMINFO;
end;

procedure Tfminfo.saveinfo();
var
  sname: string;
begin
  //
  qrydg.Connection := ADGSYSTEM.connection;

  //如果编制人员的姓名不在编制者表中，将其加入
  qrydg.Close;
  qrydg.sql.Clear;
  qrydg.SQL.add('select * from 编制者 where trim(审计员姓名)=''' + trim(cbbbzr.text) + ''' and 类别="1" ');
  qrydg.open;

  if qrydg.RecordCount < 1 then
  begin
    qrydg.Close;
    qrydg.sql.Clear;
    qrydg.SQL.add('insert  into 编制者(审计员姓名,类别) values(''' + trim(cbbbzr.text) + ''',"1")');
    qrydg.ExecSQL;
  end;

  //如果复核人员的姓名不在编制者表中，将其加入
  qrydg.Close;
  qrydg.sql.Clear;
  qrydg.SQL.add('select * from 编制者 where trim(审计员姓名)=''' + trim(cbbfhr.text) + '''  and 类别="2"');
  qrydg.open;

  if qrydg.RecordCount < 1 then
  begin
    qrydg.Close;
    qrydg.sql.Clear;
    qrydg.SQL.add('insert  into 编制者(审计员姓名,类别) values(''' + trim(cbbfhr.text) + ''',"2")');
    qrydg.ExecSQL;
  end;

end;

procedure Tfminfo.clearedit;
begin
  //
  edtkhname.Clear;
  cbbbzr.Clear;
  edtbzrq.Clear;
  cbbfhr.Clear;
  edtfhrq.Clear;
end;

procedure Tfminfo.dispXMINFO;
begin
  //
  qrydg.Connection := ADGSYSTEM.connection;
  qrydg.close;
  //将编制人名单提交到CBBbzr
  qrydg.sql.Clear;
  qrydg.SQL.add('select  * from 编制者 where 类别="1"');
  qrydg.open;
  cbbbzr.Items.Clear;
  while not QRYDG.Eof do
  begin
    cbbbzr.Items.Add(qrydg.FIELDBYNAME('审计员姓名').ASSTRING);
    qrydg.Next;
  end;

  //将审核人名单提交到CBBFHR
  qrydg.close;
  qrydg.sql.Clear;
  qrydg.SQL.add('select  * from 编制者 where 类别="2"');
  qrydg.open;
  cbbfhr.Items.Clear;
  while not QRYDG.Eof do
  begin
    cbbfhr.Items.Add(qrydg.FIELDBYNAME('审计员姓名').ASSTRING);
    qrydg.Next;
  end;

  try
    axm := ADGSYSTEM.OPENLAST;
    edtkhname.Text := axm.dwmc;

    cbbbzr.Text := axm.editor;
    if yearof(axm.editrq) < 1950 then
      edtbzrq.Date := Today
    else
      edtbzrq.Date := axm.editrq;

    cbbfhr.Text := axm.checkor;
    if yearof(axm.checkRQ) < 1950 then
      edtfhrq.Date := Today
    else
      edtfhrq.Date := axm.checkRQ;

  except
  end;

end;

procedure Tfminfo.saveXMINFO();
var
  adw: XMINFO;
begin
  //
  if Trim(edtkhname.text) = '' then
  begin
    mymessage('单位名称不能为空，保存失败！');
    Exit;
  end
  else
    axm.dwmc := edtkhname.Text;

  if Trim(cbbbzr.text) = '' then
  begin
    mymessage('保存失败：  编制人不能为空，保存失败！');
    Exit;
  end
  else
    axm.editor := cbbbzr.Text;

  try
    axm.editrq := (edtbzrq.Date);
  except
    mymessage('保存失败：  编制日期输入不正确，正确格式 为1999-12-30');
    Exit;
  end;

  if Trim(cbbfhr.text) = '' then
  begin
    mymessage('保存失败：  复核人不能为空，保存失败！');
    Exit;
  end
  else
    axm.checkor := cbbfhr.Text;

  try
    axm.checkRQ := (edtfhrq.Date);
  except
    mymessage('保存失败：  编制日期输入不正确，正确格式 为1999-12-30');
    Exit;
  end;

  ADGSYSTEM.writetomdb_EXTinfo(axm);
  saveinfo;

end;

procedure Tfminfo.Button2Click(Sender: TObject);
begin
  inherited;
  saveXMINFO;
  mymessage('基本信息保存成功！');
end;

end.
