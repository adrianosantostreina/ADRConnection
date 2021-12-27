unit ADRConn.Model.Generator;

interface

uses
  ADRConn.Model.Interfaces,
  Data.DB;

type TADRConnModelGenerator = class abstract(TInterfacedObject, IADRGenerator)

  protected
    [Weak]
    FQuery: IADRQuery;

    function GetCurrentSequence(Name: String): Double; virtual; abstract;
    function GetNextSequence(Name: String): Double; virtual; abstract;
    function GetSequence: Double;

  public
    constructor create(Query: IADRQuery);
    class function NewGenerator(Connection: IADRConnection; Query: IADRQuery): IADRGenerator;
end;

implementation

{ TADRConnModelGenerator }

uses
  ADRConn.Model.Generator.Firebird,
  ADRConn.Model.Generator.MySQL,
  ADRConn.Model.Generator.Postgres,
  ADRConn.Model.Generator.SQLite;

constructor TADRConnModelGenerator.create(Query: IADRQuery);
begin
  FQuery := Query;
end;

function TADRConnModelGenerator.GetSequence: Double;
var
  dataSet: TDataSet;
begin
  dataSet := FQuery.OpenDataSet;
  try
    result := dataSet.Fields[0].AsFloat;
  finally
    dataSet.Free;
  end;
end;

class function TADRConnModelGenerator.NewGenerator(Connection: IADRConnection; Query: IADRQuery): IADRGenerator;
begin
  case Connection.Params.Driver of
    adrFirebird : result := TADRConnModelGeneratorFirebird.New(Query);
    adrMySql : result := TADRConnModelGeneratorMySQL.New(Query);
    adrPostgres : result := TADRConnModelGeneratorPostgres.New(Query);
    adrSQLite : Result := TADRConnModelGeneratorSQLite.New(Query);
  end;
end;

end.
