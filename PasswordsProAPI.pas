unit PasswordsProAPI;

(***************************************************************************}
     improt from Modules.h v1.6.1 
     Modul name PasswordsProAPI.pas
     Https://GitHub.com/Superbot-coder  
 ***************************************************************************)

interface

USES
  Windows, SysUtils, Dialogs, Error;

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
    dwFlags: DWORD;      // Флаги
    szAbout: PAnsiChar;  // Адрес строки с версией модуля, авторских правах и т.д.
    szType : PAnsiChar;  // Адрес строки с типом хэша
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
Type TGetInfo = procedure(ModInfo: PModuleInfo) cdecl; //StdCall;

// GetHash() должна генерировать хэш, используя следующие параметры структуры HASHINFO
Type TGetHash = procedure(HashInfo: PHashInfo) cdecl; //StdCall;

// GetData() извлекает из исходного хэша все необходимые данные – соль,
// непосредственно хэш и т.д. В дальнейшем для хэширования и сравнения хэшей
// будет использоваться именно эта информация. Функция использует
// следующие параметры структуры PREPAREDINFO}
Type TGetData = procedure(PreparedInfo: PPreparedInfo) cdecl; //StdCall;

type
  THashMod = class(TObject)
  private
    FhModule  : Thandle;
    FMI       : TModuleInfo;
    FHI       : THashInfo;
    FPI       : TPreparedInfo;
    FHashBuff : TBytes;
    FHashSize : SmallInt;
    GetInfo   : TGetInfo;
    GetHash   : TGetHash;
    // GetData   : TGetData;
    procedure SetHashSize(const Value: SmallInt);
    function GetAbout: string;
    function GetModType: string;
    function GetHashSize: SmallInt;
  public
    property HashSize: SmallInt read GetHashSize write SetHashSize;
    property About: string read GetAbout;
    property ModuleType: string read GetModType;
    function GetHashToHex(APassword: AnsiString): String;
    procedure GetHashToBin(APassword: PAnsiChar; PBuffer: PAnsiChar);
    constructor Create(FileNameDll: String);
    destructor Destroy;
  end;
  { THashMod }

implementation

var
  // MI: TModuleInfo;
  // HI: THashInfo;
  //GetInfo : TGetInfo;
  //GetHash : TGetHash;
  GetData : TGetData;

constructor THashMod.Create(FileNameDll: String);
begin
  inherited Create;

  FhModule := LoadLibrary(PChar(FileNameDll));
  if FhModule = 0 then
    raise Exception.Create('Не удалось загрузить модуль: ' + FileNameDll);

  @GetInfo := GetProcAddress(FhModule, PChar('GetInfo'));
  if @GetInfo = NIL Then
    raise Exception.Create('Не удалось инициировать фунцию: GetInfo()');

  @GetHash := GetProcAddress(FhModule, PChar('GetHash'));
  if @GetHash = NIL Then
    raise Exception.Create('Не удалось инициировать фунцию: GetHash()');

  @GetData := GetProcAddress(FhModule, PChar('GetData'));
  if @GetData = Nil Then
  begin
    // raise Exception.Create('Не удалось инициировать фунцию: GetData()');
    // данная функия отсутствует в некоторых модулях
  end;

  GetInfo(@FMI);
  FHashSize := 0;
  Setlength(FHashBuff, 0);

end;

destructor THashMod.Destroy;
begin
  FHashBuff := nil;
  FreeLibrary(FhModule);
  inherited Destroy;
end;

function THashMod.GetAbout: string;
begin
  Result := PAnsiChar(FMI.szAbout);
end;

function THashMod.GetHashSize: SmallInt;
begin
  Result := FHashSize;
end;

procedure THashMod.GetHashToBin(APassword: PAnsiChar; PBuffer: PAnsiChar);
begin
  if (FhModule = 0) then Exit;
  FHI.pHash        := PBuffer;
  FHI.szPassword   := APassword;
  FHI.nPasswordLen := Length(PAnsiChar(APassword));
  FHI.szSalt       := Nil;
  FHI.nSaltLen     := 0;
  FHI.szName       := Nil;
  FHI.nNameLen     := 0;
  FHI.dwFlags      := PPF_BINARY_HASH;
  GetHash(@FHI);
end;

function THashMod.GetHashToHex(APassword: AnsiString): String;
var
  i: ShortInt;
begin
  if (FhModule = 0) or (FHashSize = 0) then Exit;
  FHI.pHash        := PAnsiChar(FHashBuff);
  FHI.szPassword   := PAnsiChar(APassword);
  FHI.nPasswordLen := Length(APassword);
  FHI.szSalt       := Nil;
  FHI.nSaltLen     := 0;
  FHI.szName       := Nil;
  FHI.nNameLen     := 0;
  GetHash(@FHI);
  Result := '';
  for i := 0 to FHashSize -1 do Result := Result + FHashBuff[i].ToHexString;
end;

function THashMod.GetModType: string;
begin
  Result := PAnsiChar(FMI.szType);
end;

procedure THashMod.SetHashSize(const Value: SmallInt);
begin
  if Value = 0 then
    raise Exception.Create('Ошибка: HashSize = 0');
  FHashSize := Value;
  Setlength(FHashBuff, Value);
end;

end.