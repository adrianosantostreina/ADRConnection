unit ADRConn.Model.PgDAC.Connection.Test;

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
  TADRConnModelPgDACConnectionTest = class
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

{ TADRConnModelPgDACConnectionTest }

procedure TADRConnModelPgDACConnectionTest.PostgresConnection;
begin
  FConnection.Params
    .Database('RP')
    .UserName('postgres')
    .Password('123');

  Assert.IsFalse(FConnection.Connected);
  FConnection.Connect;
  Assert.IsTrue(FConnection.Connected);
end;

procedure TADRConnModelPgDACConnectionTest.PostgresConnectionError;
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

procedure TADRConnModelPgDACConnectionTest.Setup;
begin
  FConnection := TADRConnModelPGDacConnection.New;
end;

procedure TADRConnModelPgDACConnectionTest.TearDown;
begin
end;

{$ENDIF}

end.
