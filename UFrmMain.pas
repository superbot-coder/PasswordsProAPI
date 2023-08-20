unit UFrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, error, PasswordsProAPI, Vcl.ExtCtrls, System.IOUtils,
  System.Generics.Collections, Vcl.Samples.Spin, System.IniFiles, Vcl.ComCtrls,
  Vcl.Menus, Winapi.ShellAPI;

type

  TFlagInfo = Record
    FlagName : string;
    FlagLabel: string;
    HelpText : string;
  End;

type
  TFrmMain = class(TForm)
    CmBoxSelectAlgo: TComboBox;
    mm: TMemo;
    BtnGetHash: TButton;
    lblEditPassword: TLabeledEdit;
    lblEditUserName: TLabeledEdit;
    lblEditSalt: TLabeledEdit;
    LblSelectAlgo: TLabel;
    SpEditHashSize: TSpinEdit;
    LblHashSize: TLabel;
    StatusBar: TStatusBar;
    MainMenu: TMainMenu;
    B1: TMenuItem;
    MMOpenProjectGitHub: TMenuItem;
    MMOpenGitHubOverView: TMenuItem;
    N1: TMenuItem;
    MM_AboutView: TMenuItem;
    MM_ViewFlagsInfo: TMenuItem;
    ChBoxLoverHash: TCheckBox;
    MM_Test: TMenuItem;
    procedure BtnGetHashClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CmBoxSelectAlgoSelect(Sender: TObject);
    procedure MMOpenProjectGitHubClick(Sender: TObject);
    procedure MMOpenGitHubOverViewClick(Sender: TObject);
    procedure MM_AboutViewClick(Sender: TObject);
    procedure MM_ViewFlagsInfoClick(Sender: TObject);
    procedure MM_TestClick(Sender: TObject);
  private
    { Private declarations }
    ModulesPreset: TDictionary<String, Integer>;
    Procedure CreateModulesList(ModulesDir: string);
    procedure LoadHashesPreset;
    procedure SaveHashPresetItem;
    procedure CreateListFlagsInfo;
    procedure ViewFlags;
    function CheckFlag(PPF_FLAG: DWORD): Boolean;
    function GetMD5Hash(ASalt: AnsiString): AnsiString;
    procedure UpdateStatusBar;

  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;
  CurPath      : String;
  ModulPath    : String;
  ModulesList  : TDictionary<String, string>;
  ModulesPreset: TDictionary<String, Integer>;
  FlagsInfoList: TDictionary<Cardinal, TFlagInfo>;
  HM           : THashMod;
  HashesConfig : String;

const
  MAX_SIZE_BIN_HASH  = 128;
  MAX_SIZE_ANSI_HASH = 200;

  GitHubProject   = 'https://github.com/superbot-coder/PasswordsProAPI';
  GitHubOverView  = 'https://github.com/superbot-coder';

implementation

{$R *.dfm}

procedure TFrmMain.BtnGetHashClick(Sender: TObject);
var
  APassword : AnsiString;
  AName     : AnsiString;
  ASalt     : AnsiString;
  Password  : String;
  Name      : String;
  hash      : string;
  ResultStr : string;
begin

  if Not Assigned(HM) then
  begin
    mm.Lines.Add('Assigned(HM) = false модуль не инициализирован');
    Exit;
  end;

  HM.HashSize := SpEditHashSize.Value;

  Password  := lblEditPassword.Text;
  Name      := lblEditUserName.Text;

  if CheckFlag(PPF_LOWER_NAME) then Name := AnsiLowerCase(Name);
  if CheckFlag(PPF_UPPER_NAME) then Name := AnsiUpperCase(Name);

  APassword := AnsiString(Password);
  AName     := AnsiString(Name);
  ASalt     := AnsiString(lblEditSalt.Text);

  if CheckFlag(PPF_MD5_SALT) then
    Asalt := GetMD5Hash(Asalt);


  if CheckFlag(PPF_BINARY_HASH) then
  begin
    //mm.Lines.Add('USE PPF_BINARY_HASH HM.GetHashToHex');
    if CheckFlag(PPF_UNICODE_PASS) then
      hash := HM.GetHashToHex(PChar(Password), PChar(Name))
    else
      hash := HM.GetHashToHex(PAnsiChar(APassword), PAnsiChar(ASalt), PAnsiChar(AName));
  end
    else
  begin
    // mm.Lines.Add('USE PPF_COMPLEX_HASH HM.GetHashToAnsi');
    if CheckFlag(PPF_UNICODE_PASS) then
      hash := HM.GetHashToAnsi(PChar(Password), PAnsiChar(ASalt))
    else
      hash := HM.GetHashToAnsi(PAnsiChar(APassword), PAnsiChar(ASalt), PAnsiChar(AName));
  end;

  if ChBoxLoverHash.Checked then
    hash := LowerCase(hash);

  ResultStr := 'Пароль: ' + lblEditPassword.Text;
  if CheckFlag(PPF_USE_NAME) then
    ResultStr := ResultStr + ' имя: ' + lblEditUserName.Text;
  if CheckFlag(PPF_USE_SALT) then
    ResultStr := ResultStr + ' соль: ' + lblEditSalt.Text;
  ResultStr := ResultStr + ' хэш: ' + hash;

  mm.Lines.Add(ResultStr);

end;

function TFrmMain.CheckFlag(PPF_FLAG: DWORD): Boolean;
begin
  if (HM.PPF_FLAGS AND PPF_FLAG) = PPF_FLAG then
    Result := True
  else
    Result := false;
end;

procedure TFrmMain.CmBoxSelectAlgoSelect(Sender: TObject);
begin
  if Assigned(HM) then
  begin
    mm.Lines.Add('Assigned(HM) = true');
    HM.Free;
    HM := Nil;
  end;

  if ModulesList.ContainsKey(ModulesList.Items[CmBoxSelectAlgo.Text]) then
    exit;

  HM := THashMod.Create(ModulesList.Items[CmBoxSelectAlgo.Text]);
  if mm.Lines.Count > 1 then mm.Lines.Add('');

  mm.Lines.Add('Тип модуля (алгоритм): ' + HM.ModuleType);
  ViewFlags;

  if ModulesPreset.ContainsKey(CmBoxSelectAlgo.Text) then
    SpEditHashSize.Value  := ModulesPreset.Items[CmBoxSelectAlgo.Text];

  lblEditPassword.Text := '';
  lblEditUserName.Text := '';
  lblEditSalt.Text     := '';

  if CheckFlag(PPF_USE_NAME) then
    lblEditUserName.Enabled := true
  else
    lblEditUserName.Enabled := false;

  if CheckFlag(PPF_USE_SALT) or CheckFlag(PPF_USE_SALT) then
    lblEditSalt.Enabled := true
  else
    lblEditSalt.Enabled := false;

end;

procedure TFrmMain.CreateListFlagsInfo;
var
  FI: TFlagInfo;
begin
  FI.FlagName  := 'PPF_BINARY_HASH';
  FI.FlagLabel := 'Бинарный хэш';
  FI.HelpText  := 'Наличие этого флага означает, что модуль предназначен ' +
                  'для работы с хэшами в бинарном виде.';
  FlagsInfoList.Add(PPF_BINARY_HASH, FI);

  FI.FlagName  := 'PPF_COMPLEX_HASH';
  FI.FlagLabel := 'Комплексный хэш';
  FI.HelpText  := 'Наличие этого флага означает, что хэш содержит в себе соль ' +
                  'и другую информацию для хэширования. Модуль с таким флагом ' +
                  'обязательно должен иметь функцию GetData()';
  FlagsInfoList.Add(PPF_COMPLEX_HASH, FI);

  FI.FlagName  := 'PPF_USE_SALT';
  FI.FlagLabel := 'Используется соль';
  FI.HelpText  := 'Наличие этого флага означает, что для генерации хэша ' +
                  'кроме пароля еще используется соль.';
  FlagsInfoList.Add(PPF_USE_SALT, FI);

  FI.FlagName  := 'PPF_MD5_SALT';
  FI.FlagLabel := 'Используется MD5 соль';
  FI.HelpText  := 'Наличие этого флага означает, что перед хэшированием ' +
                  'необходимо подсчитать MD5-хэш от соли ' +
                  'и преобразовать его в 32-символьную строку.';
  FlagsInfoList.Add(PPF_MD5_SALT, FI);

  FI.FlagName  := 'PPF_USE_NAME';
  FI.FlagLabel := 'Используется имя пользователя';
  FI.HelpText  := 'Наличие этого флага означает, что для генерации хэша ' +
                  'кроме пароля еще используется имя пользователя.';
  FlagsInfoList.Add(PPF_USE_NAME, FI);

  FI.FlagName  := 'PPF_UNICODE_NAME';
  FI.FlagLabel := 'Используется Unicode имя пользователя';
  FI.HelpText  := 'Наличие этого флага означает, что имя пользователя ' +
                  'перед хэшированием необходимо конвертировать в Unicode.';
  FlagsInfoList.Add(PPF_UNICODE_NAME, FI);

  FI.FlagName  := 'PPF_LOWER_NAME';
  FI.FlagLabel := 'Используется имя пользователя в нижнем регистре';
  FI.HelpText  := 'Наличие этого флага означает, что имя пользователя перед ' +
                  'хэшированием необходимо конвертировать в нижний регистр.';
  FlagsInfoList.Add(PPF_LOWER_NAME, FI);

  FI.FlagName  := 'PPF_UPPER_NAME';
  FI.FlagLabel := 'Используется имя пользователя в верхнем регистре';
  FI.HelpText  := 'Наличие этого флага означает, что имя пользователя перед ' +
                  'хэшированием необходимо конвертировать в верхний регистр.';
  FlagsInfoList.Add(PPF_UPPER_NAME, FI);

  FI.FlagName  := 'PPF_HUGE_PASS';
  FI.FlagLabel := 'Входные данные объемом до 2Гб';
  FI.HelpText  := 'Наличие этого флага означает, что модуль может генерировать ' +
                  'хэш от входных данных объемом до 2Гб. При отсутствии этого ' +
                  'флага длина входных данных ограничена 127 символами.';
  FlagsInfoList.Add(PPF_HUGE_PASS, FI);

  FI.FlagName  := 'PPF_UNICODE_PASS';
  FI.FlagLabel := 'Используется Unicode пароль';
  FI.HelpText  := 'Наличие этого флага означает, что пароль перед ' +
                  'хэшированием необходимо конвертировать в Unicode.';
  FlagsInfoList.Add(PPF_UNICODE_PASS, FI);

{
  FI.FlagName  := 'PPF_PREPARED_HASH';
  FI.FlagLabel := '';
  FI.HelpText  := 'С этим флагом функция вызывается во время атаки, ' +
                  'что позволяет модулям возвращать хэши в том формате, ' +
                  'в котором их предварительно подготавливает функция GetData().';

  FlagsInfoList.Add(PPF_PREPARED_HASH, FI);
 }

end;

procedure TFrmMain.CreateModulesList(ModulesDir: string);
var
  FileName, NameKey, ext: String;
begin
  ModulesList.Clear;
  CmBoxSelectAlgo.Clear;
  for FileName in TDirectory.GetFiles(ModulesDir, '*.dll', TSearchOption.soTopDirectoryOnly) do
  begin
    NameKey := ExtractFileName(FileName);
    ext := ExtractFileExt(NameKey);
    Delete(NameKey, Length(NameKey) - Length(ext) + 1 , Length(ext));
    ModulesList.Add(NameKey, FileName);
    CmBoxSelectAlgo.Items.Add(NameKey);
  end;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  CurPath := ExtractFilePath(Application.ExeName);
  HashesConfig  := CurPath + 'HashesConfig.ini';
  ModulesList   := TDictionary<String, string>.Create;
  ModulesPreset := TDictionary<String, Integer>.Create;
  FlagsInfoList := TDictionary<Cardinal, TFlagInfo>.Create;
  CreateModulesList(CurPath + 'Modules');
  CreateListFlagsInfo;
  LoadHashesPreset;
  UpdateStatusBar;
  Constraints.MinHeight := 600;
  Constraints.MinWidth  := 800;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
   ModulesList.Free;
   ModulesPreset.Free;
   FlagsInfoList.Free;
end;

function TFrmMain.GetMD5Hash(ASalt: AnsiString): AnsiString;
var
  MD5: THashMod;
begin
  Result := '00000000000000000000000000000000';
  if Not ModulesList.ContainsKey('MD5') then Exit;
  MD5 := THashMod.Create(ModulesList.Items['MD5']);
  MD5.HashSize := 16;
  Result := AnsiLowerCase(MD5.GetHashToHex(PAnsiChar(ASalt), nil, nil));
  MD5.free;
end;

procedure TFrmMain.LoadHashesPreset;
var
  INI: TIniFile;
   ST: TStrings;
   i : SmallInt;
begin
  INI := TIniFile.Create(HashesConfig);
   ST := TStringList.Create;
  try
    INI.ReadSections(ST);
    for i := 0 to ST.Count -1 do
    begin
      ModulesPreset.Add(ST.Strings[i], INI.ReadInteger(ST.Strings[i], 'HashSize', MAX_SIZE_BIN_HASH));
    end;
  finally
    ST.Free;
    INI.Free;
  end;
end;

procedure TFrmMain.MMOpenGitHubOverViewClick(Sender: TObject);
begin
  ShellExecute(Handle, PChar('open'), PChar(GitHubOverView), Nil, Nil, SW_NORMAL);
end;

procedure TFrmMain.MMOpenProjectGitHubClick(Sender: TObject);
begin
  ShellExecute(Handle, PChar('open'), PChar(GitHubProject), Nil, Nil, SW_NORMAL);
end;

procedure TFrmMain.MM_AboutViewClick(Sender: TObject);
begin
  if Not Assigned(HM) then Exit;
  mm.Lines.Add('');
  mm.Lines.Add('Файл: ' + ModulesList.Items[CmBoxSelectAlgo.Text]);
  mm.Lines.Add('О модуле: ' + HM.About);
end;

procedure TFrmMain.MM_TestClick(Sender: TObject);
begin
 //
end;

procedure TFrmMain.MM_ViewFlagsInfoClick(Sender: TObject);
var i: ShortInt;
begin
  if Not Assigned(HM) then exit;
  i := 0;
  mm.Lines.Add('');
  mm.Lines.Add('Маска: h' + HM.PPF_FLAGS.ToHexString);
  for var FlagItem in FlagsInfoList do
  begin
    if CheckFlag(FlagItem.Key) then
    begin
      // Бход бага когда выводтся два флага одновременно
      if FlagItem.Key = PPF_LOWER_NAME then
        if CheckFlag(PPF_UPPER_NAME) then
          Continue;
      inc(i);
      mm.Lines.Add(i.ToString + '  ' + FlagItem.Value.FlagName + ' = '  + FlagItem.Value.FlagLabel);
      mm.Lines.Add(FlagItem.Value.HelpText);
    end;
  end;
end;

procedure TFrmMain.SaveHashPresetItem;
var
  INI: TIniFile;
   SECT: string;
begin
  if Not ModulesPreset.ContainsKey(CmBoxSelectAlgo.Text) then Exit;
  INI  := TIniFile.Create(HashesConfig);
  try
    SECT := CmBoxSelectAlgo.Text;
    INI.WriteInteger(SECT, 'HashSize', ModulesPreset.Items[CmBoxSelectAlgo.Text]);
  finally
    INI.Free;
  end;
end;

procedure TFrmMain.UpdateStatusBar;
begin
  StatusBar.Panels[0].Text := 'Количество библиотек: ' + ModulesList.Count.ToString;
end;

procedure TFrmMain.ViewFlags;
var i: ShortInt;
begin
  i := 0;
  mm.Lines.Add('ФЛАГИ:');
  for var FlagItem in FlagsInfoList do
  begin
    if CheckFlag(FlagItem.Key) then
    begin
      // Бход бага когда выводтся два флага одновременно
      if FlagItem.Key = PPF_LOWER_NAME then
        if CheckFlag(PPF_UPPER_NAME) then
          Continue;
      inc(i);
      mm.Lines.Add(i.ToString + ' ' + FlagItem.Value.FlagLabel);
    end;
  end;
end;

end.
