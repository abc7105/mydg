unit ushare;

interface

uses Windows, Classes, SysUtils, forms,lxyjm;

type

  cellxy = record
    zdname: string;
    liking: Single;
    row: integer;
    column: integer;
    sheetname: string;
  end;

  mxbPOS = record
    qc: integer;
    jffs: integer;
    dffs: integer;
    qm: integer;
    kmmc: Integer;
    top: integer;
    bottom: Integer;
    tzjf: integer; //�����跽
    tzdf: integer;
    tzfzjf: integer; //��ֵ�����跽
    tzfzdf: Integer;
    nosd: Integer; //δ����
    sd: integer; //����
    maxwidth: integer;
    maxheight: integer;
    fx: integer; //����
    dm: integer;
    memo1: integer;
    memo2: integer;
    memo3: integer;
  end;

type
  xminfo = record
    xmid: string;
    xmname: string;
    dwmc: string;
    xmpath: string;
    startrq: tdatetime;
    endrq: tdatetime;
    yeard: string;
    kmlen: Integer;
    //ģ��
    mbid: string;
    MBNAME: string;
    mbpath: string;

    //ԭXMINFO
    editor: string;
    checkor: string;
    editrq: tdatetime;
    checkRQ: TDATETIME;

    //��չ
    xmyear: Integer;

  end;
var
  axm: xminfo;
  ajm:tlxyjm      ;

implementation



end.

