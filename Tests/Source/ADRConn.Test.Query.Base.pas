unit ADRConn.Test.Query.Base;

interface

uses
  ADRConn.Model.Interfaces,
  ADRConn.Test.Base,
  System.SysUtils;

type TADRConnTestBaseQuery = class(TADRConnTestBase)

  protected
    FQuery: IADRQuery;
    FConnection: IADRConnection;

    function getConnection: IADRConnection; virtual; abstract;
    procedure initializeQuery;
end;

implementation

{ TADRConnTestBaseQuery }

procedure TADRConnTestBaseQuery.initializeQuery;
begin
  FConnection := getConnection;
  FQuery := CreateQuery(FConnection);
end;

end.
