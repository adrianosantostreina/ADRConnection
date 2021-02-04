unit ADRConn.Test.Connection.Postgres;

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
    .Database('pdvmobile')
    .UserName('postgres')
    .Password('postgres')
    .Port(5432)
    .Schema('public')
  .&End;

  Assert.WillNotRaise(FConnection.Connect);
end;

end.
