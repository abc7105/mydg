unit acPathDialog;
{$I sDefs.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, sBitBtn, ComCtrls, {sTreeView, }acShellCtrls,
  sSkinProvider, sEdit, sTreeView, sScrollBox, ImgList, sLabel,
  acAlphaImageList;

type
  TPathDialogForm = class(TForm)
    sShellTreeView1: TsShellTreeView;
    sBitBtn1: TsBitBtn;
    sBitBtn2: TsBitBtn;
    sSkinProvider1: TsSkinProvider;
    sBitBtn3: TsBitBtn;
    sScrollBox1: TsScrollBox;
    sLabel1: TsLabel;
    ImageList1: TsAlphaImageList;
    procedure sShellTreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure sBitBtn3Click(Sender: TObject);
    procedure sBitBtn2Click(Sender: TObject);
    procedure sBitBtn1Click(Sender: TObject);
  public
    procedure InitLngCaptions;
    procedure GenerateButtons;
    procedure UpdateAnchors;
    procedure BtnOnClick(Sender : TObject);
  end;

var
  PathDialogForm: TPathDialogForm;
  FLargeImages : integer = 0;

implementation

uses acntUtils, FileCtrl, sConst, Commctrl, sStrings, acSBUtils, TypInfo, sSpeedButton, ShlObj, ShellAPI, sSkinProps;

{$R *.DFM}

procedure TPathDialogForm.sShellTreeView1Change(Sender: TObject; Node: TTreeNode);
begin
  sBitBtn1.Enabled := DirectoryExists(sShellTreeView1.Path);
  sBitBtn3.Enabled := DirectoryExists(sShellTreeView1.Path)
//  if sBitBtn1.Enabled then sEdit1.Text := sShellTreeView1.Path else sEdit1.Text := ''
end;

procedure TPathDialogForm.sBitBtn3Click(Sender: TObject);
var
  NewName : string;
  TreeNode : TTreeNode;
  i : integer;
  function GetUniName : string;
  var
    i : integer;
  begin
    for i := 1 to maxint - 1 do begin
      Result := NormalDir(sShellTreeView1.SelectedFolder.PathName) + s_NewFolder + IntToStr(i);
      if not acDirExists(Result) then Exit
    end;
    Result := '';
  end;
begin
  NewName := GetUniName;
  CreateDir(NewName);
  if not acDirExists(NewName) then ShowError('Directory ' + NewName + ' can`t be created!') else begin
    sShellTreeView1.Refresh(sShellTreeView1.Selected);
    RefreshScrolls(sShellTreeView1.SkinData, sShellTreeView1.ListSW);

    for i := 0 to sShellTreeView1.Selected.Count - 1 do begin
      TreeNode := sShellTreeView1.Selected.Item[i];
      if sShellTreeView1.Folders[TreeNode.AbsoluteIndex].PathName = NewName then begin
        TreeNode.Selected := True;
        sShellTreeView1.SetFocus;
        TreeNode.Expanded := True;
        TreeNode.EditText;
        sShellTreeView1.Path := NewName;
        Break;
      end;
    end;
  end;
end;

procedure TPathDialogForm.sBitBtn2Click(Sender: TObject);
begin
  if sShellTreeView1.IsEditing then ModalResult := mrNone else ModalResult := mrCancel;
  inherited;
end;

procedure TPathDialogForm.sBitBtn1Click(Sender: TObject);
begin
  if sShellTreeView1.IsEditing then begin
    ModalResult := mrNone;
    sShellTreeView1.Selected.EndEdit(False);
    sShellTreeView1.SetFocus;
  end
  else ModalResult := mrOk;
end;

procedure TPathDialogForm.InitLngCaptions;
begin
  Caption          := acs_SelectDir;
  sLabel1.Caption  := acs_Root;
  sBitBtn1.Caption := acs_MsgDlgOK;
  sBitBtn2.Caption := acs_MsgDlgCancel;
  sBitBtn3.Caption := acs_Create;
end;

procedure TPathDialogForm.GenerateButtons;
var
  FileInfo: TSHFileInfo;
  procedure MakeBtn(Folder : TacRootFolder);
  var
    Btn : TsSpeedButton;
    NewPIDL: PItemIDList;
    Fldr : TacShellFolder;
  begin
    Btn := TsSpeedButton.Create(sScrollBox1);
    Btn.Height := 70;
    Btn.Layout := blGlyphTop;
    Btn.Flat := True;
    Btn.SkinData.SkinSection := s_ToolButton;
    SHGetSpecialFolderLocation(0, nFolder[Folder], NewPIDL);
    Btn.Caption := GetDisplayName(DesktopShellFolder, NewPIDL, SHGDN_NORMAL, seHide);

    Fldr := CreateRootFromPIDL(NewPIDL);
    Btn.ImageIndex := GetShellImage(Fldr.AbsoluteID, False, False);
    FreeAndNil(Fldr);
    Btn.Images := ImageList1;

    Btn.Tag := ord(Folder);
    Btn.Align := alTop;
    Btn.OnClick := BtnOnClick;
    Btn.Parent := sScrollBox1;
  end;
begin
  sScrollBox1.Color := clAppworkSpace;
  if FLargeImages = 0 then FLargeImages := SHGetFileInfo('C:\', 0, FileInfo, SizeOf(FileInfo), SHGFI_SYSICONINDEX or SHGFI_LARGEICON);
  if FLargeImages <> 0 then ImageList1.Handle := FLargeImages;
  MakeBtn(rfDesktop);
  MakeBtn(rfMyComputer);
  MakeBtn(rfPersonal);
  MakeBtn(rfNetwork);
end;

procedure TPathDialogForm.BtnOnClick(Sender: TObject);
begin
  sShellTreeView1.Root := GetEnumName(TypeInfo(TacRootFolder), TsSpeedButton(Sender).Tag);
end;

procedure TPathDialogForm.UpdateAnchors;
begin
  DisableAlign;
  sShellTreeView1.Anchors := sShellTreeView1.Anchors + [akRight, akBottom];
  sScrollBox1.Anchors := sScrollBox1.Anchors + [akBottom];
  sBitBtn1.Anchors := [akRight, akBottom];
  sBitBtn2.Anchors := [akRight, akBottom];
  sBitBtn3.Anchors := [akLeft, akBottom];
  RefreshScrolls(sShellTreeView1.SkinData, sShellTreeView1.ListSW);
  EnableAlign;
end;

end.
