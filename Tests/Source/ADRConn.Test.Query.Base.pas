unit ADRConn.Test.Query.Base;

interface

uses
  ADRConn.Model.Interfaces,
  ADRConn.Test.Base,
  System.SysUtils;

type
  TADRConnTestBaseQuery = class(TADRConnTestBase)
  protected
    FQuery: IADRQuery;
    FConnection: IADRConnection;

    function GetConnection: IADRConnection; virtual; abstract;
    procedure InitializeQuery;
  end;

implementation

{ TADRConnTestBaseQuery }

procedure TADRConnTestBaseQuery.InitializeQuery;
begin
  FConnection := GetConnection;
  FQuery := CreateQuery(FConnection);
end;

end.
