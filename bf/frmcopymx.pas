unit frmcopymx;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, StrUtils,
  Dialogs, umb, StdCtrls, ExtCtrls, adxAddIn, lhh_TLB, Excel2000;

type
  Tfmcopymxdxn = class(Tfm_mb)
    ListBox1: TListBox;
    Panel1: TPanel;
    ListBox2: TListBox;
    Button1: TButton;
    Button2: TButton;
    procedure ListBox1DblClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure setlist(cname: array of string; ncount: integer);
    procedure ListBox2DblClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    abook: Excel2000.TExcelApplication;
    flastrow: Integer;
    ffastrow: Integer;
    procedure setbook(const Value: Excel2000._Application);
    { Private declarations }
  public
    { Public declarations }
  published
    property aworkbook: Excel2000._Application write setbook;
    property fastrow: Integer read ffastrow write ffastrow;
    property lastrow: Integer read flastrow write flastrow;

  end;

var
  fmcopymxdxn: Tfmcopymxdxn;

implementation

{$R *.dfm}

procedure Tfmcopymxdxn.ListBox1DblClick(Sender: TObject);
var astr: string;
begin
  inherited;
  astr := ListBox1.Items[listbox1.itemindex];
  ListBox2.Items.Add(astr);
end;

procedure Tfmcopymxdxn.Button2Click(Sender: TObject);
begin
  inherited;
  close;
end;

procedure Tfmcopymxdxn.setbook(const Value: Excel2000._Application);
begin
  abook := TExcelApplication.Create(nil);
  abook.ConnectTo(Value);

end;

procedure Tfmcopymxdxn.setlist(cname: array of string; ncount: integer);
var i: integer;
  aExcelApp: Excel2000._Application;
  asheet: ExcelWorksheet;
begin
  ListBox1.Clear;
  for i := 0 to ncount do
  begin
    ListBox1.Items.Add(cname[i]);
  end;

end;

procedure Tfmcopymxdxn.ListBox2DblClick(Sender: TObject);
begin
  inherited;
  ListBox2.Items.Delete(ListBox2.itemindex);
end;

procedure Tfmcopymxdxn.Button1Click(Sender: TObject);
var i, colno, pos1: integer;
  anewsheet, aoldsheet: _Worksheet;
  range, rng: excelrange;
  vstr: string;
begin
  inherited;
  aoldsheet := abook.activecell.worksheet;
  anewsheet := _Worksheet(abook.ActiveWorkbook.Sheets.Add(EmptyParam, EmptyParam, 1, xlWorksheet, 0));
  aoldsheet.Activate(adxLCID);

  for i := 1 to ListBox2.Items.Count do
  begin
    colno := strtoint(Leftstr(ListBox2.Items[i - 1], 3));
    range := abook.Range[aoldsheet.Cells.item[fastrow, colno], aoldsheet.Cells.item[lastrow, colno]];
    range.Copy(EmptyParam);
    anewsheet.Activate(adxLCID);
    anewsheet.Cells.Item[1, i].select;
    excel2000.ExcelRange(abook.ActiveWindow.Selection).PasteSpecial(xlPasteValues, xlNone, False, False);
    aoldsheet.Activate(adxLCID);
  end;

  anewsheet.Activate(adxLCID);
  for i := 1 to ListBox2.Items.Count do
  begin
    vstr := anewsheet.Cells.Item[1, i].Text;
    pos1 := pos('$', vstr);
    if pos1 > 0 then
      anewsheet.Cells.Item[1, i].Value := copy(vstr, 1, pos1 - 1)
  end;
  close;

end;

end.

