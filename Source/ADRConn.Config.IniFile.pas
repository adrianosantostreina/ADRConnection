unit ADRConn.Config.IniFile;

interface

uses
  ADRConn.Model.Interfaces,
  System.IniFiles,
  System.Generics.Collections,
  System.SysUtils;

type TADRConnConfigIni = class

  private
    FFileName: string;
    FDatabase: string;
    FServer: string;
    FUserName: string;
    FPassword: string;
    FPort: Integer;
    FVendorLib: string;
    FProtocol: string;
    FDriver: TADRDriverConn;

    class var FInstances: TObjectDictionary<String, TADRConnConfigIni>;

    constructor CreatePrivate(ASection: String);

    function InternalReadString(const Ident: string; const Default: String = ''; const Section: String = ''): string;
    function InternalReadInteger(const Ident: string; const Default: Integer = 0; const Section: String = ''): Integer;
    function InternalReadBool(const Ident: string; const Default: Boolean = False; const Section: String = ''): Boolean;

    function InternalWriteString(const Ident: string; const Value: string; const Section: String = ''): TADRConnConfigIni;
    function InternalWriteInteger(const Ident: string; const Value: Integer; const Section: String = ''): TADRConnConfigIni;
    function InternalWriteBool(const Ident: string; const Value: Boolean; const Section: String = ''): TADRConnConfigIni;

  protected
    class function GetDefaultInstance(ASection: String): TADRConnConfigIni;
    function GetIniFileName: string;
    function GetIniFile: TIniFile; virtual;

    procedure Initialize(ASection: String);

  public
    constructor create;

    property Driver: TADRDriverConn read FDriver write FDriver;
    property FileName: string read FFileName write FFileName;
    property Database: string read FDatabase write FDatabase;
    property UserName: string read FUserName write FUserName;
    property Password: string read FPassword write FPassword;
    property Server: string read FServer write FServer;
    property Port: Integer  read FPort write FPort;
    property VendorLib: string read FVendorLib write FVendorLib;
    property Protocol: string read FProtocol write FProtocol;

    class function ReadString(const Ident: string; const Default: String = ''; const Section: String = ''): string;
    class function ReadBool(const Ident: string; const Default: Boolean = False; const Section: String = ''): Boolean;
    class function ReadInteger(const Ident: string; const Default: Integer; const Section: String = ''): Integer;

    class function WriteString(const Ident: string; const Value: string; const Section: String = ''): TADRConnConfigIni;
    class function WriteInteger(const Ident: string; const Value: Integer; const Section: String = ''): TADRConnConfigIni;
    class function WriteBool(const Ident: string; const Value: Boolean; const Section: String = ''): TADRConnConfigIni;

    class function GetInstance(ASection: string = ''): TADRConnConfigIni;
    class destructor UnInitialize;
end;

implementation

const
  SECTION_DATABASE = 'CONFIG';

{ TADRConnConfigIni }

constructor TADRConnConfigIni.Create;
begin
  raise Exception.Create('Use GetInstance...');
end;

constructor TADRConnConfigIni.CreatePrivate(ASection: String);
var
  LIniFile: TIniFile;
begin
  Initialize(ASection);
  LIniFile := GetIniFile;
  try
    FDriver.fromString(LIniFile.ReadString(ASection, 'Driver', 'Firebird'));

    FDatabase := LIniFile.ReadString(ASection, 'Database', FDatabase);
    FUserName := LIniFile.ReadString(ASection, 'User_Name', FUserName);
    FPassword := LIniFile.ReadString(ASection, 'Password', FPassword);
    FServer := LIniFile.ReadString(ASection, 'Server', FServer);
    FVendorLib := LIniFile.ReadString(ASection, 'VendorLib', FVendorLib);
    FProtocol := LIniFile.ReadString(ASection, 'Protocol', FProtocol);
    FPort := LIniFile.ReadInteger(ASection, 'Port', FPort);
  finally
    LIniFile.Free;
  end;
end;

class function TADRConnConfigIni.GetDefaultInstance(ASection: String): TADRConnConfigIni;
begin
  if not Assigned(FInstances) then
    FInstances := TObjectDictionary<string, TADRConnConfigIni>.create;

  if not FInstances.TryGetValue(ASection, result) then
  begin
    result := TADRConnConfigIni.CreatePrivate(ASection);
    FInstances.Add(ASection, result);
  end;
end;

function TADRConnConfigIni.GetIniFile: TIniFile;
begin
  result := TIniFile.Create(GetIniFileName);
end;

function TADRConnConfigIni.GetIniFileName: string;
begin
  result := ChangeFileExt(GetModuleName(HInstance), '.ini');
end;

class function TADRConnConfigIni.GetInstance(ASection: string): TADRConnConfigIni;
var
  LSection: String;
begin
  LSection := ASection;
  if LSection = EmptyStr then
    LSection := SECTION_DATABASE;

  result := TADRConnConfigIni.GetDefaultInstance(LSection);
end;

procedure TADRConnConfigIni.Initialize(ASection: String);
var
  fileName: String;
  iniFile : TIniFile;
begin
  fileName := GetIniFileName;
  if not FileExists(fileName) then
  begin
    iniFile := GetIniFile;
    try
      iniFile.WriteString(ASection, 'Driver', FDriver.toString);
      iniFile.WriteString(ASection, 'Database', 'adrconntest');
      iniFile.WriteString(ASection, 'User_Name', 'sysdba');
      iniFile.WriteString(ASection, 'Password', 'masterkey');
      iniFile.WriteString(ASection, 'Server', '127.0.0.1');
      iniFile.WriteString(ASection, 'VendorLib', 'fbclient.dll');
      iniFile.WriteString(ASection, 'Protocol', 'http');
      iniFile.WriteInteger(ASection, 'Port', 3050);
    finally
      iniFile.Free;
    end;
  end;
end;

class function TADRConnConfigIni.ReadBool(const Ident: string; const Default: Boolean = False; const Section: String = ''): Boolean;
begin
  result := Self.GetInstance.InternalReadBool(Ident, Default, Section);
end;

class function TADRConnConfigIni.ReadInteger(const Ident: string; const Default: Integer; const Section: String = ''): Integer;
begin
  result := Self.GetInstance.InternalReadInteger(Ident, Default, Section);
end;

function TADRConnConfigIni.InternalReadBool(const Ident: string; const Default: Boolean = False; const Section: String = ''): Boolean;
var
  iniFile: TIniFile;
begin
  iniFile := GetIniFile;
  try
    result := iniFile.ReadBool(Section, Ident, Default);
    iniFile.WriteBool(Section, Ident, Result);
  finally
    iniFile.Free;
  end;
end;

function TADRConnConfigIni.InternalReadInteger(const Ident: string; const Default: Integer = 0; const Section: String = ''): Integer;
var
  iniFile: TIniFile;
begin
  iniFile := GetIniFile;
  try
    result := iniFile.ReadInteger(Section, Ident, Default);
    iniFile.WriteInteger(Section, Ident, result);
  finally
    iniFile.Free;
  end;
end;

function TADRConnConfigIni.InternalReadString(const Ident: string; const Default: String = ''; const Section: String = ''): string;
var
  iniFile: TIniFile;
begin
  iniFile := GetIniFile;
  try
    result := iniFile.ReadString(Section, Ident, Default);
    iniFile.WriteString(Section, Ident, result);
  finally
    iniFile.Free;
  end;
end;

function TADRConnConfigIni.InternalWriteBool(const Ident: string; const Value: Boolean; const Section: String = ''): TADRConnConfigIni;
var
  iniFile: TIniFile;
begin
  result := Self;
  iniFile := GetIniFile;
  try
    iniFile.WriteBool(Section, Ident, Value);
  finally
    iniFile.Free;
  end;
end;

function TADRConnConfigIni.InternalWriteInteger(const Ident: string; const Value: Integer; const Section: String = ''): TADRConnConfigIni;
var
  iniFile: TIniFile;
begin
  result := Self;
  iniFile := GetIniFile;
  try
    iniFile.WriteInteger(Section, Ident, Value);
  finally
    iniFile.Free;
  end;
end;

function TADRConnConfigIni.InternalWriteString(const Ident: string; const Value: string; const Section: String = ''): TADRConnConfigIni;
var
  iniFile: TIniFile;
begin
  result := Self;
  iniFile := GetIniFile;
  try
    iniFile.WriteString(Section, Ident, Value);
  finally
    iniFile.Free;
  end;
end;

class function TADRConnConfigIni.ReadString(const Ident: string; const Default: String = ''; const Section: String = ''): string;
begin
  result := Self.GetInstance.InternalReadString(Ident, Default, Section);
end;

class destructor TADRConnConfigIni.UnInitialize;
var
  LKey: string;
begin
  if Assigned(FInstances) then
  begin
    for LKey in FInstances.Keys do
      FInstances.Items[LKey].Free;
    FreeAndNil(FInstances);
  end;
end;

class function TADRConnConfigIni.WriteBool(const Ident: string; const Value: Boolean; const Section: String = ''): TADRConnConfigIni;
begin
  result := Self.GetInstance.InternalWriteBool(Ident, Value, Section);
end;

class function TADRConnConfigIni.WriteInteger(const Ident: string; const Value: Integer; const Section: String = ''): TADRConnConfigIni;
begin
  result := Self.GetInstance.InternalWriteInteger(Ident, Value, Section);
end;

class function TADRConnConfigIni.WriteString(const Ident: string; const Value: string; const Section: String = ''): TADRConnConfigIni;
begin
  result := Self.GetInstance.InternalWriteString(Ident, Value, Section);
end;

end.
