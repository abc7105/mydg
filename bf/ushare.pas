unit ushare;

interface

uses Windows, Classes, SysUtils;
procedure mymessage(str: string);

implementation

procedure mymessage(str: string);
begin
  Application.MessageBox(PChar(str), '��ʾ', MB_OK + MB_ICONINFORMATION);
end;

end.

