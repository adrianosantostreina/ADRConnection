unit ADRConn.Test.Postgres.Connection;

interface

uses
  DUnitX.TestFramework,
  ADRConn.Model.Interfaces,
  ADRConn.Test.Base,
  System.SysUtils;

type
  [TestFixture]
  TADRConnTestPostgres = class(TADRConnTestBase)

  public
    [Test]
    procedure TestConnection;
  end;


implementation

{ TADRConnTestPostgres }

procedure TADRConnTestPostgres.TestConnection;
begin
  FConnection := CreateConnection;
  FConnection.Params
    .Driver(adrPostgres)
    .Server('127.0.0.1')
    .Database('adrconntest')
    .UserName('postgres')
    .Password('postgres')
    .Port(5432)
    .Schema('public')
  .&End;

  Assert.WillNotRaise(TestConnect);
end;

end.
