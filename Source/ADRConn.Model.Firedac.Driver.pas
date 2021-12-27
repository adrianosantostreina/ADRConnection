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

type TADRConnModelFiredacDriver = class

  private
    class function GetPostgresDriver: TFDPhysDriverLink;
    class function GetMySQLDriver: TFDPhysDriverLink;
    class function GetSQLiteDriver: TFDPhysDriverLink;
    class function GetFirebirdDriver: TFDPhysDriverLink;

  public
    class function GetDriver(Params: IADRConnectionParams): TFDPhysDriverLink;

end;

implementation

{ TADRConnModelFiredacDriver }

class function TADRConnModelFiredacDriver.GetDriver(Params: IADRConnectionParams): TFDPhysDriverLink;
begin
  case Params.Driver of
    adrMySql : result := GetMySQLDriver;
    adrFirebird : result := GetFirebirdDriver;
    adrPostgres : result := GetPostgresDriver;
    adrSQLite : result := GetSQLiteDriver;
  else
    raise Exception.CreateFmt('Driver %s not found.', [Params.Driver.toString]);
  end;
end;

class function TADRConnModelFiredacDriver.GetFirebirdDriver: TFDPhysDriverLink;
begin
  result := TFDPhysFBDriverLink.Create(nil);
  Result.VendorLib := 'fbclient.dll';
end;

class function TADRConnModelFiredacDriver.GetMySQLDriver: TFDPhysDriverLink;
begin
  Result := TFDPhysMySQLDriverLink.Create(nil);
  Result.VendorLib := 'libmysql.dll';
end;

class function TADRConnModelFiredacDriver.GetPostgresDriver: TFDPhysDriverLink;
begin
  result := TFDPhysPgDriverLink.Create(nil);
  Result.VendorLib := '';
end;

class function TADRConnModelFiredacDriver.GetSQLiteDriver: TFDPhysDriverLink;
begin
  result := TFDPhysSQLiteDriverLink.Create(nil);
  result.VendorLib := 'sqlite3.dll';
end;

end.
