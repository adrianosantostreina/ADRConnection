unit ADRConn.Model.Generator;

interface

uses
  ADRConn.Model.Interfaces,
  Data.DB;

type
  TADRConnModelGenerator = class abstract(TInterfacedObject, IADRGenerator)
  protected
    [Weak]
    FQuery: IADRQuery;

    function GetCurrentSequence(AName: string): Double; virtual; abstract;
    function GetNextSequence(AName: string): Double; virtual; abstract;
    function GetSequence: Double;
  public
    constructor Create(AQuery: IADRQuery);
    class function NewGenerator(AConnection: IADRConnection; AQuery: IADRQuery): IADRGenerator;
  end;

implementation

{ TADRConnModelGenerator }

uses
  ADRConn.Model.Generator.Firebird,
  ADRConn.Model.Generator.MySQL,
  ADRConn.Model.Generator.Postgres,
  ADRConn.Model.Generator.SQLite;

constructor TADRConnModelGenerator.Create(AQuery: IADRQuery);
begin
  FQuery := AQuery;
end;

function TADRConnModelGenerator.GetSequence: Double;
var
  LDataSet: TDataSet;
begin
  LDataSet := FQuery.OpenDataSet;
  try
    Result := LDataSet.Fields[0].AsFloat;
  finally
    LDataSet.Free;
  end;
end;

class function TADRConnModelGenerator.NewGenerator(AConnection: IADRConnection; AQuery: IADRQuery): IADRGenerator;
begin
  case AConnection.Params.Driver of
    adrFirebird:
      Result := TADRConnModelGeneratorFirebird.New(AQuery);
    adrMySql:
      Result := TADRConnModelGeneratorMySQL.New(AQuery);
    adrPostgres:
      Result := TADRConnModelGeneratorPostgres.New(AQuery);
    adrSQLite:
      Result := TADRConnModelGeneratorSQLite.New(AQuery);
  end;
end;

end.
