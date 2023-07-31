unit PasswordsProAPI;

(***************************************************************************}
     improt from Modules.h v1.6.1 
     Modul name PasswordsProAPI.pas
     Https://GitHub.com/Superbot-coder  
 ***************************************************************************)

interface

USES
  Windows;

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

var
  ModName    : string;
  hModul     : THandle;
  PrepInfo   : TPreparedInfo;
  HashInfo   : THashInfo;
  ModuleInfo : THashInfo;
  GetInfo    : TGetInfo;
  GetHash    : TGetHash;
  GetData    : TGetData;

//function Loadmodul(ModName: String): TНandle;

implementation



end.