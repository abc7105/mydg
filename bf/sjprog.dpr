program sjprog;

uses
  Windows,
  Forms,
  Dialogs,
  SysUtils,
  Messages,
  fmpzb in 'fmpzb.pas' {frmpzh},
  communit in 'communit.pas',
  csdg in 'csdg.pas',
  XMmanager in 'XMmanager.pas' {fmxmgl},
  jm in 'jm.pas',
  lxyjm in 'lxyjm.pas',
  lxyjmA in 'lxyjmA.pas',
  ushare in 'ushare.pas',
  shareunit in 'shareunit.pas',
  reg in 'reg.pas' {fmreg},
  CLSexcel in 'CLSexcel.pas',
  clslxy in 'clslxy.pas',
  frmopendw in 'frmopendw.pas' {fmopendw};

{$R *.res}
var
  // myhandle: THandle;
  Mutex: THandle;
  EnumWndProc, hMutex, FindHid: HWND;
  MoudleName: string;
begin

  Mutex := CreateMutex(nil, true, 'one'); {第3个参数任意设置}
  if WaitForSingleObject(Mutex, 0) <> wait_TimeOut then
  begin
    if GetLastError <> ERROR_ALREADY_EXISTS then
    begin
      //      Application.MessageBox('建立！', '提示', MB_OK);
      Application.Initialize;
      //    Application.CreateForm(TForm1, Form1);
   //   Application.CreateForm(TDataModule4, DataModule4);
      Application.CreateForm(Tfrmpzh, frmpzh);
  //     Application.CreateForm(Tfmreg, fmreg);
 //     Application.CreateForm(Tfmopendw, fmopendw);
      Application.Run;
    end
    else
    begin
      //    Application.MessageBox('恢复 该程序正在运行！', '提示', MB_OK);
      SetLength(MoudleName, 100);
      GetModuleFileName(HInstance, pchar(MoudleName), length(MoudleName));
      //获得自己程序文件名
      MoudleName := pchar(MoudleName);
      EnumWindows(@EnumWndProc, 0); //调用枚举函数
      if FindHid <> 0 then
        SetForegroundWindow(FindHid);

      //    Application.MessageBox('该程序正在运行！', '提示', MB_OK);

          //   ReleaseMutex(Mutex); {释放资源}

    end;
  end
    //  else
    //  begin
    //  //  Application.MessageBox('恢复222程序正在运行！', '提示', MB_OK);
    //    SetLength(MoudleName, 100);
    //    GetModuleFileName(HInstance, pchar(MoudleName), length(MoudleName));
    //    //获得自己程序文件名
    //    MoudleName := pchar(MoudleName);
    //    EnumWindows(@EnumWndProc, 0); //调用枚举函数
    //    if FindHid <> 0 then
    //      SetForegroundWindow(FindHid);
    //    Application.MessageBox('恢复222程序正在运行ok！', '提示', MB_OK);
    //  end;

      //
      //var

      //  begin
      //
      //    hMutex := CreateMutex(nil, false, 'hkOneCopy');
      //
      //    if WaitForSingleObject(hMutex, 0) <> wait_TimeOut then
      //    begin
      //
      //      if GetLastError <> ERROR_ALREADY_EXISTS then
      //      begin
      //        Application.Initialize;
      //        //    Application.CreateForm(TForm1, Form1);
      //        Application.CreateForm(Tfrmpzh, frmpzh);
      //        Application.Run;
      //      end
      //      else
      //        //       Application.MessageBox('该程序正在运行！', '提示', MB_OK);
      //        ReleaseMutex(hMutex); {释放资源}
      //
      //    end
      //
      //
      //  end;

end.

