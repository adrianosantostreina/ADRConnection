unit ADRConn.Test.Connection.Firebird;

interface

uses
  DUnitX.TestFramework,
  ADRConn.Model.Interfaces,
  ADRConn.Test.Base,
  System.SysUtils;

type
  [TestFixture]
  TADRConnTestFirebird = class(TADRConnTestBase)

  public
    [Test]
    procedure TestConnection;
  end;


implementation

{ TADRConnTestFirebird }

procedure TADRConnTestFirebird.TestConnection;
begin
  FConnection := CreateConnection;
  FConnection.Params
    .Driver(adrFirebird)
    .Database('pdvmobile')
    .UserName('sysdba')
    .Password('masterkey')
  .&End;

  Assert.WillNotRaise(FConnection.Connect);
end;

end.

