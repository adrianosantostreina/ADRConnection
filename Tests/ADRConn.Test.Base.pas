unit ADRConn.Test.Base;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TADRConnTestBase = class
  public
  end;

implementation

initialization
  TDUnitX.RegisterTestFixture(TADRConnTestBase);

end.
