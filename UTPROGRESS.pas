unit UTPROGRESS;
interface
{�Զ��������,By ���� ��д 2004.10.11 Email:landgis@126.com yanleigis@21cn.com,���÷�������
const
    Maxx = 10000;
var
    i: Integer;
begin
    initProgressBar(Maxx,'����');
    try
        for i := 1 to Maxx do
            if ProgressStep() then
                Break;
    finally
        FreeProgressStep();
    end;
end;
}
{������õ��Ǵ���һ�����н������Լ�ȡ����ť�Ĵ��壬�ڵ���ʱ�ɸ��ݹ��к������
initProgressBar��ProgressStep��FreeProgressStep���õ�һ��������ʾ���ȵĽ�������
���巽��������ʾ��
1.�ڳ�ʱ��ѭ��ʱ��(��1�ӵ�10000������)
procedure DoAdding;
var
    i,Maxx: Integer;
    SumCount: Integer;
begin
    MaXX := 10000;
    SumCount := 0;
    initProgressBar(Maxx,'����');
    try
        for i := 1 to Maxx do
        begin
            SumCount := SumCount +i;
            if ProgressStep() then
                Break;
        end;
    finally
        FreeProgressStep();
    end;
end;
}
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RzPrgres, StdCtrls, RzButton;
{---------------------TMyProgress��----------------------------------------}

type
  TMyProgress = class(TObject)
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { ��Ĺ��캯���������������Ի���FrmProgress������FrmProgress�ﴴ��������ProgressBar
    �Լ�ȡ����ť�����ȡ����ťִ�е��¼���btnCancelClick}
    //constructor Create(); overload;
    constructor Create(MaxNum: Integer = 1; IsCancel: Boolean = True);
      overload;
    {��������������ͷ�FrmProgress}
    destructor Destroy; override;
  end;
  {-----------------------------���к���------------------------------------}
//ΪTrue��ʾ��ֹ
{��������ʾ״̬�����������Stopͬ�������StopΪ�棬���������棬���StopΪ��,�������ؼ٣�������
��ֹ}

function ProgressStep(Step: Integer = 1): Boolean; overload;
//�ͷ�MyProgress
procedure FreeProgressStep(ex: Boolean = False);
//�������������ֵMax�����������ʾ�����йأ����Լ����������ڵı���Caption��
//�����������������������ǳ�ʼ���ĵ�һ��������
//maxNum�Ǳ�ʾ�ж��ٸ�������
//IsCancel�Ƿ���ȡ����ť
procedure InitProgressBar(Max: Integer; Caption: string;
  MaxNum: Integer; IsCancel: Boolean = True); overload;
//�������������ֵMax�����������ʾ�����йأ����Լ����������ڵı���Caption��
procedure InitProgressBar(Max: Integer; Caption: string; IsCancel: Boolean =
  True); overload;
function ProgressStep(MaxNum: Integer; Step: Integer = 1): Boolean; overload;
function Ansker_showmessage(answerstr: string; anstitle: string): Boolean;
overload;

var
  hintCaption: Boolean = False;
  FrmProgress: TForm;
implementation

//uses utYGpub;

var
  {FMax: Integer;                      //���ֵ
  FMax1: Integer;                     //��һ�����ֵ
  FStep: Integer;                     //��ǰֵ
  FStep1: Integer;                    //��һ��ǰֵ
  }
  FStep: array of Integer; //ÿ����������step
  FMax: array of Integer; //ÿ�������������ֵ
  ProgressBar: array of TRzProgressBar;
  btnCancel: TRzBitBtn;
  Stop: Boolean;
  MyProgress: TMyProgress;
  FCaption: string;
  ForNum: Integer; //ѭ���Ĵ��� //by yl 2006.3.7
  RemainNum: Integer;
  ////IsCancel�Ƿ���ȡ����ť

constructor TMyProgress.Create(MaxNum: Integer = 1; IsCancel: Boolean = True);
var
  i: Integer;
begin
  inherited Create();
  FrmProgress := TForm.Create(nil);
  with FrmProgress do
  begin
    Stop := False;
    BorderStyle := bsDialog;
    Caption := '����';
    ClientHeight := 96 + (MaxNum - 1) * 35;
    ClientWidth := 326;
    Left := (screen.Width - ClientWidth) div 2;
    Top := 100;
    //Position := poDesktopCenter;
    BorderIcons := [biMinimize, biMaximize];
    BringToFront;
    //FormStyle := fsStayOnTop;
  end;
  setlength(ProgressBar, MaxNum);
  setlength(FStep, MaxNum);
  setlength(FMax, MaxNum);
  for i := 0 to MaxNum - 1 do
  begin
    ProgressBar[i] := TRzProgressBar.Create(nil);
    with ProgressBar[i] do
    begin
      Left := 9;
      Top := 25 + (i) * 30;
      Width := 304;
      ProgressBar[i].Parent := FrmProgress;
    end;
  end;
  if IsCancel then
  begin
    btnCancel := TRzBitBtn.Create(nil);
    btnCancel.Parent := FrmProgress;
    with btnCancel do
    begin
      Left := 246;
      Top := 54 + (MaxNum - 1) * 30;
      Width := 62;
      Height := 26;
      Caption := 'ȡ��';
      HotTrack := True;
      OnClick := btnCancelClick;
      Parent := FrmProgress;
      Margin := -1;
    end;
  end;
  //  Set_ControlColor(FrmProgress);
end;

procedure TMyProgress.btnCancelClick(Sender: TObject);
begin
  FrmProgress.FormStyle := fsNormal;
  if Ansker_showmessage('��ȷ����ֹ��', '��ֹ') then
    Stop := True
  else
    FrmProgress.FormStyle := fsStayOnTop;
end;

function Ansker_showmessage(answerstr: string; anstitle: string):
  Boolean;
begin
  result := false;
  if Application.MessageBox(PChar(answerstr), PChar(anstitle), MB_OKCANCEL) =
    IDOK then
  begin
    result := true;

  end;

end;

destructor TMyProgress.Destroy;
var
  i: Integer;
begin
  for i := 0 to ForNum - 1 do
  begin
    ProgressBar[i].Free;
  end;
  setlength(ProgressBar, 0);
  setlength(FStep, 0);
  setlength(FMax, 0);
  FreeAndNil(FrmProgress);
  inherited Destroy;
end;
//�������������ֵMax�����������ʾ�����йأ����Լ����������ڵı���Caption��
//IsCancel�Ƿ���ȡ����ť

procedure InitProgressBar(Max: Integer; Caption: string; MaxNum: Integer;
  IsCancel: Boolean = True);
var
  i: Integer;
begin
  RemainNum := MaxNum;
  if MaxNum < ForNum then
  begin
    i := ForNum - MaxNum;
    FMax[i] := Max;
    FStep[i] := 0;
  end
  else
  begin
    ForNum := MaxNum;
    MyProgress := TMyProgress.Create(MaxNum, IsCancel);
    FrmProgress.Caption := Caption;
    FCaption := Caption;
    FMax[0] := Max;
    FStep[0] := 0;
  end;
end;
//�������������ֵMax�����������ʾ�����йأ����Լ����������ڵı���Caption��

procedure InitProgressBar(Max: Integer; Caption: string; IsCancel: Boolean =
  True);
begin
  if ForNum < 2 then
  begin
    ForNum := 1;
    MyProgress := TMyProgress.Create(1, IsCancel);
    FrmProgress.Caption := Caption;
    FCaption := Caption;
  end;
  FMax[ForNum - 1] := Max;
  FStep[ForNum - 1] := 0;
end;

function ProgressStep(MaxNum: Integer; Step: Integer = 1): Boolean; overload;
var
  i: Integer;
begin
  result := Stop;
  if FrmProgress = nil then //���˳���
    Exit;
  //if not FrmProgress.Showing then FrmProgress.Show;
  if Stop then
  begin
    FreeProgressStep();
    Exit;
  end;
  i := ForNum - MaxNum;
  if Step = 1 then
    inc(FStep[i])
  else
    inc(FStep[i], Step);
  if Application.Active then
    FrmProgress.BringToFront;
  Application.ProcessMessages;
  ProgressBar[i].Percent := FStep[i] * 100 div FMax[i];
  if hintCaption then
    FrmProgress.Caption := Format('%s-���:��%d��%d', [FCaption, FMax[i],
      FStep[i]]);
end;

procedure IsExit();
var
  i: Integer;
  b: Boolean;
begin
  b := False;
  for i := 0 to ForNum - 1 do //���и����ſ����ͷ�
  begin
    b := FStep[i] = FMax[i];
    if not b then
      Break;
  end;
  if b then
    FreeProgressStep(True);
end;

function ProgressStep(Step: Integer = 1): Boolean;
var
  i: Integer;
begin
  result := Stop;
  if FrmProgress = nil then //���˳���
    Exit;
  if not FrmProgress.Showing then
    FrmProgress.Show;
  if Stop then
  begin
    FreeProgressStep();
    Exit;
  end;
  if ForNum > 0 then
    i := ForNum - 1
  else
    i := 0;
  if Step = 1 then
    inc(FStep[i])
  else
    inc(FStep[i], Step);
  if Application.Active then
    FrmProgress.BringToFront;
  Application.ProcessMessages;
  ProgressBar[i].Percent := FStep[i] * 100 div FMax[i];
  if hintCaption then
    FrmProgress.Caption := Format('%s-���:��%d��%d', [FCaption, FMax[i],
      FStep[i]]);
  IsExit();
end;

procedure FreeProgressStep(ex: Boolean = False);
begin
  if (ForNum < 2) or Stop or ex then
  begin
    if FrmProgress <> nil then
    begin
      FreeAndNil(MyProgress);
    end;
    ForNum := 1;
  end
  else
  begin
    IsExit();
  end;
end;
end.

