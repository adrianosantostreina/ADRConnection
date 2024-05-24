unit ADRConn.Model.PGDac.Connection.Test;

interface

{$IFDEF ADRCONN_PGDAC}
uses
  DUnitX.TestFramework,
  ADRConn.Model.Interfaces,
  ADRConn.Model.PGDac.Connection,
  System.SysUtils,
  PgError;

type
  [TestFixture]
  TADRConnModelPGDacConnectionTest = class
  private
    FConnection: IADRConnection;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure PostgresConnection;

    [Test]
    procedure PostgresConnectionError;
  end;
{$ENDIF}

implementation

{$IFDEF ADRCONN_PGDAC}

{ TADRConnModelPGDacConnectionTest }

procedure TADRConnModelPGDacConnectionTest.PostgresConnection;
begin
  FConnection.Params
    .Database('RP')
    .UserName('postgres')
    .Password('123');

  Assert.IsFalse(FConnection.Connected);
  FConnection.Connect;
  Assert.IsTrue(FConnection.Connected);
end;

procedure TADRConnModelPGDacConnectionTest.PostgresConnectionError;
begin
  FConnection.Params
    .Database('RP123')
    .UserName('postgres')
    .Password('123456');

  Assert.IsFalse(FConnection.Connected);
  Assert.WillRaise(
    procedure
    begin
      FConnection.Connect;
    end,
    EPgError);
end;

procedure TADRConnModelPGDacConnectionTest.Setup;
begin
  FConnection := TADRConnModelPGDacConnection.New;
end;

procedure TADRConnModelPGDacConnectionTest.TearDown;
begin
end;

{$ENDIF}

end.
