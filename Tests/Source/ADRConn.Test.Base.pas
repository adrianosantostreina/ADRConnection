unit ADRConn.Test.Base;

interface

uses
  DUnitX.TestFramework,
  ADRConn.Model.Interfaces;

type
  TADRConnTestBase = class
  protected
    FConnection: IADRConnection;

    procedure TestConnect;
  end;

implementation

{ TADRConnTestBase }

procedure TADRConnTestBase.TestConnect;
begin
  FConnection.Connect;
end;

end.
