unit ADRConn.Model.Firedac.Driver;

interface

uses
  ADRConn.Model.Interfaces,
  FireDAC.Phys,
  FireDAC.Phys.FB,
  FireDAC.Phys.MySQL,
  FireDAC.Phys.PG,
  FireDAC.Phys.SQLite,
  System.SysUtils;

type
  TADRConnModelFiredacDriver = class
  private
    class function GetPostgresDriver: TFDPhysDriverLink;
    class function GetMySQLDriver: TFDPhysDriverLink;
    class function GetSQLiteDriver: TFDPhysDriverLink;
    class function GetFirebirdDriver: TFDPhysDriverLink;
  public
    class function GetDriver(AParams: IADRConnectionParams): TFDPhysDriverLink;
  end;

implementation

{ TADRConnModelFiredacDriver }

class function TADRConnModelFiredacDriver.GetDriver(AParams: IADRConnectionParams): TFDPhysDriverLink;
begin
  case AParams.Driver of
    adrMySql:
      Result := GetMySQLDriver;
    adrFirebird:
      Result := GetFirebirdDriver;
    adrPostgres:
      Result := GetPostgresDriver;
    adrSQLite:
      Result := GetSQLiteDriver;
  else
    raise Exception.CreateFmt('Driver %s not found.', [AParams.Driver.ToString]);
  end;
end;

class function TADRConnModelFiredacDriver.GetFirebirdDriver: TFDPhysDriverLink;
begin
  Result := TFDPhysFBDriverLink.Create(nil);
  Result.VendorLib := 'fbclient.dll';
end;

class function TADRConnModelFiredacDriver.GetMySQLDriver: TFDPhysDriverLink;
begin
  Result := TFDPhysMySQLDriverLink.Create(nil);
  Result.VendorLib := 'libmysql.dll';
end;

class function TADRConnModelFiredacDriver.GetPostgresDriver: TFDPhysDriverLink;
begin
  Result := TFDPhysPgDriverLink.Create(nil);
  Result.VendorLib := '';
end;

class function TADRConnModelFiredacDriver.GetSQLiteDriver: TFDPhysDriverLink;
begin
  Result := TFDPhysSQLiteDriverLink.Create(nil);
  Result.VendorLib := 'sqlite3.dll';
end;

end.
