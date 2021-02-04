unit Server.Horse.Config;

interface

uses
  System.SysUtils,
  System.Classes,
  IniFiles,
  SmartPoint;

type
  TServerHorseConfig = class
    private
      class var FHorsePort : Integer;
      class function GetHorsePort: integer;static;
      class procedure SetHorsePort(const Value: integer);static;
    public
      class procedure ReadConfig;
      class property HorsePort  : integer  read GetHorsePort  write SetHorsePort;
  end;

implementation

{ TServerHorseConfig }

class function TServerHorseConfig.GetHorsePort: integer;
begin
  Result := FHorsePort;
end;

class procedure TServerHorseConfig.SetHorsePort(const Value: integer);
begin
  FHorsePort := Value;
end;

class procedure TServerHorseConfig.ReadConfig;
var
  IniFile   : TIniFile;
  LFileName : string;
begin
  LFileName :=  ExtractFilePath(ParamStr(0)) + 'Config.ini';

  try
    IniFile    := TIniFile.Create(LFileName);

    FHorsePort := IniFile.ReadInteger('HORSE_CONFIG' , 'Port'   , FHorsePort);
  finally
    IniFile.Free;
  end;
end;

end.
