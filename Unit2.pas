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
    procedure sheet9column_sheet7column(); //��9�еı�ת��Ϊ7�еı�
    procedure genetwosheettitle(); //ͬʱ�������ֱ�ı�ͷ
    procedure genesheet9title(); //����9�еı�ı�ͷ
    procedure genesheet7title(); //����7�еı�ı�ͷ
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

