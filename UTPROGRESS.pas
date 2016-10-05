unit UTPROGRESS;
interface
{自定义进度条,By 闫磊 编写 2004.10.11 Email:landgis@126.com yanleigis@21cn.com,调用方法如下
const
    Maxx = 10000;
var
    i: Integer;
begin
    initProgressBar(Maxx,'工作');
    try
        for i := 1 to Maxx do
            if ProgressStep() then
                Break;
    finally
        FreeProgressStep();
    end;
end;
}
{类的作用的是创建一个带有进度条以及取消按钮的窗体，在调用时可根据公有函数里的
initProgressBar，ProgressStep和FreeProgressStep来得到一个可以显示进度的进度条。
具体方法如下所示：
1.在长时间循环时：(从1加到10000的例子)
procedure DoAdding;
var
    i,Maxx: Integer;
    SumCount: Integer;
begin
    MaXX := 10000;
    SumCount := 0;
    initProgressBar(Maxx,'工作');
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
{---------------------TMyProgress类----------------------------------------}

type
  TMyProgress = class(TObject)
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { 类的构造函数，创建进度条对话框FrmProgress，并在FrmProgress里创建进度条ProgressBar
    以及取消按钮，这个取消按钮执行的事件是btnCancelClick}
    //constructor Create(); overload;
    constructor Create(MaxNum: Integer = 1; IsCancel: Boolean = True);
      overload;
    {类的析构函数，释放FrmProgress}
    destructor Destroy; override;
  end;
  {-----------------------------公有函数------------------------------------}
//为True表示终止
{进度条显示状态函数，与变量Stop同步，如果Stop为真，则函数返回真，如果Stop为假,函数返回假，进度条
终止}

function ProgressStep(Step: Integer = 1): Boolean; overload;
//释放MyProgress
procedure FreeProgressStep(ex: Boolean = False);
//给进度条赋最大值Max（与进度条显示进度有关），以及进度条窗口的标题Caption。
//对于有两个进度条，这里是初始化的第一个进度条
//maxNum是表示有多少个进度条
//IsCancel是否有取消按钮
procedure InitProgressBar(Max: Integer; Caption: string;
  MaxNum: Integer; IsCancel: Boolean = True); overload;
//给进度条赋最大值Max（与进度条显示进度有关），以及进度条窗口的标题Caption。
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
  {FMax: Integer;                      //最大值
  FMax1: Integer;                     //第一个最大值
  FStep: Integer;                     //当前值
  FStep1: Integer;                    //第一当前值
  }
  FStep: array of Integer; //每个进度条的step
  FMax: array of Integer; //每个进度条的最大值
  ProgressBar: array of TRzProgressBar;
  btnCancel: TRzBitBtn;
  Stop: Boolean;
  MyProgress: TMyProgress;
  FCaption: string;
  ForNum: Integer; //循环的次数 //by yl 2006.3.7
  RemainNum: Integer;
  ////IsCancel是否有取消按钮

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
    Caption := '进度';
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
      Caption := '取消';
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
  if Ansker_showmessage('你确定终止吗', '终止') then
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
//给进度条赋最大值Max（与进度条显示进度有关），以及进度条窗口的标题Caption。
//IsCancel是否有取消按钮

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
//给进度条赋最大值Max（与进度条显示进度有关），以及进度条窗口的标题Caption。

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
  if FrmProgress = nil then //按退出键
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
    FrmProgress.Caption := Format('%s-完成:总%d中%d', [FCaption, FMax[i],
      FStep[i]]);
end;

procedure IsExit();
var
  i: Integer;
  b: Boolean;
begin
  b := False;
  for i := 0 to ForNum - 1 do //所有格都满才可以释放
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
  if FrmProgress = nil then //按退出键
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
    FrmProgress.Caption := Format('%s-完成:总%d中%d', [FCaption, FMax[i],
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

