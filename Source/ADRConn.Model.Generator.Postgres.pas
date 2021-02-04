unit ADRConn.Model.Generator.Postgres;

interface

uses
  ADRConn.Model.Interfaces,
  ADRConn.Model.Generator,
  System.SysUtils;

type TADRConnModelGeneratorPostgres = class(TADRConnModelGenerator, IADRGenerator)

  protected
    function GetCurrentSequence(Name: String): Double; override;
    function GetNextSequence(Name: String): Double; override;

  public
    class function New(Query: IADRQuery): IADRGenerator;

end;

implementation

{ TADRConnModelGeneratorPostgres }

function TADRConnModelGeneratorPostgres.GetCurrentSequence(Name: String): Double;
begin
  FQuery
    .SQL('SELECT CURRVAL(''%s'')', [Name]);

  result := GetSequence;
end;

function TADRConnModelGeneratorPostgres.GetNextSequence(Name: String): Double;
begin
  FQuery
    .SQL('SELECT NEXTVAL(''%s'')', [Name, '1']);

  result := GetSequence;
end;

class function TADRConnModelGeneratorPostgres.New(Query: IADRQuery): IADRGenerator;
begin
  result := Self.create(Query);
end;

end.
