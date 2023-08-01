unit PasswordsProAPI;

(***************************************************************************}
     improt from Modules.h v1.6.1 
     Modul name PasswordsProAPI.pas
     Https://GitHub.com/Superbot-coder  
 ***************************************************************************)

interface

USES
  Windows, SysUtils, Dialogs;

const
  // наличие этого флага означает, что модуль предназначен для работы с хэшами в бинарном виде.
  PPF_BINARY_HASH = $00000001;

  //наличие этого флага означает, что хэш содержит в себе соль и другую информацию для хэширования.
  //Модуль с таким флагом обязательно должен иметь функцию GetData().
  PPF_COMPLEX_HASH = $00000002;

  //наличие этого флага означает, что для генерации хэша кроме пароля еще используется соль.
  PPF_USE_SALT = $00000100;

  //наличие этого флага означает, что перед хэшированием необходимо подсчитать MD5-хэш от соли
  // и преобразовать его в 32-символьную строку.
  PPF_MD5_SALT = $00000200;

  //наличие этого флага означает, что для генерации хэша кроме пароля еще используется имя пользователя.
  PPF_USE_NAME = $00010000;

  //наличие этого флага означает, что имя пользователя перед хэшированием необходимо конвертировать в Unicode.
  PPF_UNICODE_NAME = $00020000;

  //наличие этого флага означает, что имя пользователя перед хэшированием необходимо конвертировать в нижний регистр.
  PPF_LOWER_NAME = $00800000;

  //наличие этого флага означает, что имя пользователя перед хэшированием необходимо конвертировать в верхний регистр.
  PPF_UPPER_NAME = $00C00000;

  // наличие этого флага означает, что модуль может генерировать хэш от входных данных объемом до 2Гб.
  // При отсутствии этого флага длина входных данных ограничена 127 символами.
  PPF_HUGE_PASS = $01000000;

  //наличие этого флага означает, что пароль перед хэшированием необходимо конвертировать в Unicode.
  PPF_UNICODE_PASS = $02000000;

  //с этим флагом функция вызывается во время атаки, что позволяет модулям возвращать хэши в том формате,
  // в котором их предварительно подготавливает функция GetData().
  PPF_PREPARED_HASH = $00000001;

Type
  PModuleInfo = ^TModuleInfo;
  TModuleInfo = Record
    dwFlags: DWORD;   // Флаги
    szAbout: PAnsiChar;   // Адрес строки с версией модуля, авторских правах и т.д.
    szType : PAnsiChar;   // Адрес строки с типом хэша
  End;

Type
  PHashInfo = ^THashInfo;
  THashInfo = Record
    pHash        : PAnsiChar; // Адрес буфера для сохранения сгенерированного хэша
    szPassword   : PAnsiChar; // Пароль
    nPasswordLen : Integer;   // Длина пароля
    szSalt       : PAnsiChar; // Соль
    nSaltLen     : Integer;   // Длина соли
    szName       : PAnsiChar; // Имя пользователя
    nNameLen     : Integer;   // Длина имени пользователя
    dwFlags      : DWORD;     // Флаги
  End;

  PPreparedInfo = ^TPreparedInfo;
  TPreparedInfo = Record
    szHash   : PAnsiChar; // Адрес строки с исходным хэшем
    nHashLen : Integer;   // Длина исходного хэша
    pHash    : PAnsiChar; // Адрес буфера для сохранения извлеченного хэша
    pHashLen : Integer;   // Длина извлеченного хэша
    pSalt    : PAnsiChar; // Адрес буфера для сохранения извлеченной соли
    pSaltLen : Integer;   // Длина извлеченной соли
  End;

// GetInfo() должна заполнять структуру TModuleInfo информацией об этом модуле:
Type TGetInfo = procedure(ModInfo: PModuleInfo); StdCall;

// GetHash() должна генерировать хэш, используя следующие параметры структуры HASHINFO
Type TGetHash = procedure(HashInfo: PHashInfo); StdCall;

// GetData() извлекает из исходного хэша все необходимые данные – соль,
// непосредственно хэш и т.д. В дальнейшем для хэширования и сравнения хэшей
// будет использоваться именно эта информация. Функция использует
// следующие параметры структуры PREPAREDINFO}
Type TGetData = procedure(PreparedInfo: PPreparedInfo); StdCall;

type
  THashMod = class(TObject)
  private
    FhModule  : Thandle;
    FAbout    : string;
    FModType  : string;
    FFlags    : DWORD;
    FHI       : THashInfo;
    FAStrBuff : AnsiString;
    FHashBuff : TBytes;
    FHashSize : SmallInt;
    GetInfo   : TGetInfo;
    GetHash   : TGetHash;
    procedure SetHashSize(const Value: SmallInt);
  public
    property HashSize: SmallInt read FHashSize write SetHashSize;
    property About: string read FAbout;
    property ModuleType: string read FModType;
    function GetHashToHex(APassword: AnsiString): String;
    function GetHashToBin(APassword: AnsiString): TBytes;
    constructor Create(FileNameDll: String);
    destructor Destroy;
  end;
  { THashMod }

implementation

constructor THashMod.Create(FileNameDll: String);
var
  MI:  TModuleInfo;
begin
  inherited Create;
  FhModule := LoadLibrary(PChar(FileNameDll));
  if FhModule = 0 then
  begin
    ShowMessage('Не удалось загрузить модуль: ' + FileNameDll);
    free;
    Exit;
  end;

  @GetInfo := GetProcAddress(FhModule, PChar('GetInfo'));
  if @GetInfo = NIL Then
  begin
    ShowMessage('GetInfo = NIL');
    exit;
  end;

  @GetHash := GetProcAddress(FhModule, PChar('GetHash'));
  if @GetHash = NIL Then
  begin
    ShowMessage('GetHash = NIL');
    Exit;
  end;

  GetInfo(@MI);
  FAbout   := PAnsiChar(MI.szAbout);
  FModType := PAnsiChar(MI.szType);
  FFlags   := MI.dwFlags;

  FHI.szSalt       := Nil;
  FHI.nSaltLen     := 0;
  FHI.szName       := Nil;
  FHI.nNameLen     := 0;
  FHI.dwFlags      := PPF_BINARY_HASH;
end;

destructor THashMod.Destroy;
begin
  FreeLibrary(FhModule);
  inherited Destroy;
end;

function THashMod.GetHashToBin(APassword: AnsiString): TBytes;
begin
  if (FhModule = 0) or (FHashSize = 0) then Exit;
  FHI.pHash        := PAnsiChar(FHashBuff);  // PAnsiChar(@FHashBuff[0]);
  FHI.szPassword   := PAnsiChar(APassword);
  FHI.nPasswordLen := Length(APassword);
  GetHash(@FHI);
  Result := FHashBuff;
end;

function THashMod.GetHashToHex(APassword: AnsiString): String;
var
  i: ShortInt;
begin
  if (FhModule = 0) or (FHashSize = 0) then Exit;
  // FHI.pHash        := PAnsiChar(FHashBuff);
  // FHI.szPassword   := PAnsiChar(APassword);
  // FHI.nPasswordLen := Length(APassword);
  // GetHash(@FHI);
  GetHashToBin(APassword);
  Result := '';
  for i := 0 to FHashSize -1 do Result := Result + FHashBuff[i].ToHexString;
end;

procedure THashMod.SetHashSize(const Value: SmallInt);
begin
  FHashSize := Value;
  Setlength(FHashBuff, Value);
end;

end.