unit ADRConn.Test.MySQL.Connection;

interface

uses
  DUnitX.TestFramework,
  ADRConn.Model.Interfaces,
  ADRConn.Test.Base,
  System.SysUtils;

type
  [TestFixture]
  TADRConnTestMySQL = class(TADRConnTestBase)
  public
    [Test]
    procedure TestConnection;

    [Test]
    procedure TestMariaDB;
  end;

implementation

{ TADRConnTestMySQL }

procedure TADRConnTestMySQL.TestConnection;
begin
  FConnection := CreateConnection;
  FConnection.Params
    .Lib('libmysql.dll')
    .Driver(adrMySql)
    .Database('adrconn')
    .UserName('root')
    .Password('root')
    .Port(3306)
  .&End;

  Assert.WillNotRaise(TestConnect);
end;

procedure TADRConnTestMySQL.TestMariaDB;
begin
  FConnection := CreateConnection;
  FConnection.Params
    .Lib('libmariadb.dll')
    .Driver(adrMySql)
//    .Server('127.0.0.1')
//    .Database('')
//    .UserName('root')
//    .Password('')
    .Port(3306)
  .&End;

  Assert.WillNotRaise(TestConnect);
end;

end.

