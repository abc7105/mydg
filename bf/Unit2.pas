unit Unit2;

interface
uses
  SysUtils, Variants, mydg_TLB, 
  Dialogs, 
  Classes;

type
  makedg = class
  private
    fxlsapp: OleVariant;
    function getxlsapp: OleVariant;
    procedure setxlsapp(const Value: OleVariant);
  public
    constructor create(xlsapp: OleVariant);
    procedure sheet9column_sheet7column(); //有9列的表转换为7列的表
    procedure genetwosheettitle(); //同时生成两种表的表头
    procedure genesheet9title(); //生成9列的表的表头
    procedure genesheet7title(); //生成7列的表的表头
    property xlsapp: OleVariant read getxlsapp write setxlsapp;
  end;


implementation



{ makedg }

constructor makedg.create(xlsapp: OleVariant);
begin
//
end;

procedure makedg.genesheet7title;
begin
  //
end;

procedure makedg.genesheet9title;
begin
    //
end;

procedure makedg.genetwosheettitle;
begin
      //
end;

function makedg.getxlsapp: OleVariant;
begin
   //
end;

procedure makedg.setxlsapp(const Value: OleVariant);
begin
//
end;

procedure makedg.sheet9column_sheet7column;
begin
 //
end;

end.

