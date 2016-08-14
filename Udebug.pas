unit Udebug;

interface

uses
  Windows, Classes, SysUtils, Variants, adxAddIn, forms, FileCtrl,
  excel2000, StrUtils, ZcGridClasses, ZJGrid, ZcDataGrid, ZcDBGrids, ZcUniClass,
  Dialogs, Controls, IniFiles, ShellAPI, communit,
  ExtCtrls, DB, ADODB;

procedure NewTxt(FileName: string);
procedure OpenTxt(FileName: string);
procedure ReadTxt(FileName: string);
procedure AppendTxt(Str: string; FileName: string);
procedure debugto(str: string);
procedure DebugReset();

implementation

procedure NewTxt(FileName: string);
var
  F: Textfile;
begin
  if fileExists(FileName) then
    DeleteFile(FileName); {���ļ��Ƿ����,�ھ̈́h��}
  AssignFile(F, FileName); {���ļ�������� F ����}
  ReWrite(F); {����һ���µ��ļ�������Ϊ ek.txt}
  Writeln(F, 'test:');
  Closefile(F); {�ر��ļ� F}
end;

procedure OpenTxt(FileName: string);
var
  F: Textfile;
begin
  AssignFile(F, FileName); {���ļ�������� F ����}
  Append(F); {�Ա༭��ʽ���ļ� F }
  Writeln(F, '����Ҫд����ı�д�뵽һ�� .txt �ļ�');
  Closefile(F); {�ر��ļ� F}
end;

procedure ReadTxt(FileName: string);
var
  F: Textfile;
  str: string;
begin
  AssignFile(F, FileName); {���ļ�������� F ����}
  Reset(F); {�򿪲���ȡ�ļ� F }
  Readln(F, str);
  ShowMessage('�ļ���:' + str + '�С�');
  Closefile(F); {�ر��ļ� F}
end;

procedure AppendTxt(Str: string; FileName: string);
var
  F: Textfile;
begin
  AssignFile(F, FileName);
  Append(F);
  Writeln(F, Str);
  Closefile(F);
end;

procedure DebugReset();
begin
  NewTxt(mainpath + 'test.txt');
end;

procedure debugto(str: string);
var
  afile: string;
begin
  afile := mainpath + 'test.txt';

  if not FileExists(afile) then
    NewTxt(afile);

  AppendTxt(Str, afile);

end;

end.

