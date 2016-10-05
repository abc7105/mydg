unit frmkmtocash;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, DB,
  ADODB,
  Dialogs, ExtCtrls, ZcUniClass, ZJGrid, ZcDataGrid, ZcDBGrids,
  ZcGridClasses, StdCtrls;

type
  Tfmkmtocash = class(TForm)
    ejunkmlist: TEjunDBGrid;
    ejuncashlist: TEjunDBGrid;
    Splitter1: TSplitter;
    tbkmlist: TADOTable;
    qrycashlist: TADOQuery;
    qrytmp: TADOQuery;
    EjunLicense1: TEjunLicense;
    Panel1: TPanel;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure ejuncashlistDblClick(Sender: TObject);
  private
    conthis: tadoconnection;
    excelapp: variant;
    procedure openkmlist();
    procedure openCASHLIST();
    procedure update_cashlist;
    procedure UPDATE_pzb;

    { Private declarations }
  public
    { Public declarations }
    constructor FormCreate(Sender: TObject; xlsapp: variant; con:
      tadoconnection);
  end;

var
  fmkmtocash: Tfmkmtocash;

implementation

{$R *.dfm}

{ TForm6 }

constructor Tfmkmtocash.FormCreate(Sender: TObject; xlsapp: variant; con:
  tadoconnection);
begin
  inherited Create(Application); //����Ҫ
  excelapp := xlsapp;
  conthis := con;
  qrytmp.Connection := conthis;
  tbkmlist.Connection := conthis;
  qrycashlist.Connection := conthis;
  openkmlist;
  openCASHLIST;
end;

procedure Tfmkmtocash.Button1Click(Sender: TObject);
begin
  //
  UPDATE_pzb;
  update_cashlist;
  close;

end;

procedure Tfmkmtocash.ejuncashlistDblClick(Sender: TObject);
begin
  try
    tbkmlist.Edit;
    tbkmlist.FieldByName('��Ӧ�ֽ���������').asstring :=
      qrycashlist.fieldbyname('�ֽ��������').asstring;
    tbkmlist.Post;
  except
  end;
end;

procedure Tfmkmtocash.openCASHLIST;
var
  STRLIST: tstringlist;
  stext: string;
  i: Integer;
begin
  if qrytmp.Active = true then
    qrytmp.close;

  //  qrytmp.Connection := conthis;

  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('UPDATE �ֽ���������Ŀ set �ֽ��������=trim(�ֽ�������Ŀ) where trim(�ֽ��������)<>""');
  qrytmp.ExecSQL;

  qrycashlist.close;
  qrycashlist.SQL.Clear;
  qrycashlist.SQL.Add('select  �ֽ�������� from  �ֽ���������Ŀ where trim(�ֽ��������)<>"" order by id');
  qrycashlist.open;

  stext := '�ֽ��������';
  STRLIST := tstringlist.create();
  STRLIST.Delimiter := ',';
  STRLIST.DelimitedText := stext;

  ejuncashlist.DataSet := tbkmlist;
  for i := 1 to strlist.Count do
  begin
    if I >= ejuncashlist.DataColumns.Count - 1 then
      ejuncashlist.DataColumns.Add;
    ejuncashlist.DATAColumns.Items[i - 1].FieldName := strlist[i - 1];
    ejuncashlist.DATAColumns.Items[I - 1].Title := STRLIST[I - 1];
  end;

  ejuncashlist.Columns[1].Width := 200;
  ejuncashlist.DataSet := qrycashlist;

  ejuncashlist.Activate(true);

end;

procedure Tfmkmtocash.openkmlist;
var
  STRLIST: tstringlist;
  stext: string;
  i: Integer;
begin
  if qrytmp.Active = true then
    qrytmp.close;

  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('delete from  �ֽ�����ͳ��');
  qrytmp.ExecSQL;

  qrytmp.SQL.Clear;
  qrytmp.SQL.Add(' insert into �ֽ�����ͳ��(��Ŀ����,һ����Ŀ,������Ŀ,��� ,��Ӧ�ֽ���������,��������ϸ)');
  qrytmp.SQL.Add(' select max(��Ŀ����) AS  ��Ŀ���� ,MAX(һ������)  AS һ����Ŀ ,MAX(��Ŀ����) AS ������Ŀ ,0,');
  qrytmp.SQL.Add(' MAX(�ֽ�����) as ��Ӧ�ֽ���������,max(��Ӫ����) AS ��������ϸ ');
  qrytmp.SQL.Add(' FROM ƾ֤�� where xjpz  '); //
  qrytmp.SQL.Add(' GROUP BY ��Ŀ����,��Ŀ����');
  qrytmp.SQL.Add(' order by ��Ŀ���� ');
  qrytmp.ExecSQL;

  tbkmlist.Close;
  tbkmlist.TableName := '�ֽ�����ͳ��';
  tbkmlist.open;

  stext :=
    '��Ŀ����,һ����Ŀ,������Ŀ,��� ,��Ӧ�ֽ���������,��������ϸ,ID';
  STRLIST := tstringlist.create();
  STRLIST.Delimiter := ',';
  STRLIST.DelimitedText := stext;

  ejunkmlist.DataSet := tbkmlist;
  for i := 1 to strlist.Count do
  begin
    if I >= ejunkmlist.DataColumns.Count - 1 then
      ejunkmlist.DataColumns.Add;
    ejunkmlist.DATAColumns.Items[i - 1].FieldName := strlist[i - 1];
    ejunkmlist.DATAColumns.Items[I - 1].Title := STRLIST[I - 1];
  end;

  ejunkmlist.Columns[1].Width := 120;
  ejunkmlist.Columns[2].Width := 120;
  ejunkmlist.Columns[3].Width := 120;
  ejunkmlist.Columns[4].Width := 120;
  ejunkmlist.Columns[5].Width := 200;
  ejunkmlist.Columns[6].Width := 0;

  ejunkmlist.DataColumns.Items[4].Style.FormatString := '#,##0.00';
  //  ejunkmlist.DataColumns.Items[6].Style.FormatString := '#,##0.00';

  ejunkmlist.Activate(true);

end;

procedure Tfmkmtocash.update_cashlist;
begin
  // TODO -cMM: Tfmkmtocash.update_cashlist default body inserted
  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('insert into �ֽ��������Ӧ(�ֽ��������,�Է���Ŀ)  select max(��Ӧ�ֽ���������),max(һ����Ŀ) from �ֽ�����ͳ�� group by һ����Ŀ ');
  qrytmp.ExecSQL;

end;

procedure Tfmkmtocash.UPDATE_pzb;
begin
  // TODO -cMM: Tfmkmtocash.UPDATE_pzb default body inserted

  qrytmp.SQL.Clear;
  qrytmp.SQL.Add('update ƾ֤�� A,�ֽ�����ͳ�� B  set A.�ֽ�����=B.��Ӧ�ֽ��������� where A.xjpz=true and A.��Ŀ����=B.��Ŀ����');
  qrytmp.ExecSQL;
end;

end.

