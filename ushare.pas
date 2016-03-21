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
    tzjf: integer; //调整借方
    tzdf: integer;
    tzfzjf: integer; //负值调整借方
    tzfzdf: Integer;
    nosd: Integer; //未审数
    sd: integer; //审定数
    maxwidth: integer;
    maxheight: integer;
    fx: integer; //方向
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
    //模板
    mbid: string;
    MBNAME: string;
    mbpath: string;

    //原XMINFO
    editor: string;
    checkor: string;
    editrq: tdatetime;
    checkRQ: TDATETIME;

    //扩展
    xmyear: Integer;

  end;
var
  axm: xminfo;
  ajm:tlxyjm      ;

implementation



end.

