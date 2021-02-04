unit ADRConn.Model.Generator.Firebird;

interface

uses
  ADRConn.Model.Interfaces,
  ADRConn.Model.Generator,
  System.SysUtils;

type TADRConnModelGeneratorFirebird = class(TADRConnModelGenerator, IADRGenerator)

  protected
    function GetCurrentSequence(Name: String): Double; override;
    function GetNextSequence(Name: String): Double; override;

  public
    class function New(Query: IADRQuery): IADRGenerator;

end;

implementation

{ TADRConnModelGeneratorFirebird }

function TADRConnModelGeneratorFirebird.GetCurrentSequence(Name: String): Double;
begin
  FQuery
    .SQL('SELECT GEN_ID(%s, 0) FROM RDB$DATABASE;', [Name]);

  result := GetSequence;
end;

function TADRConnModelGeneratorFirebird.GetNextSequence(Name: String): Double;
begin
  FQuery
    .SQL('SELECT GEN_ID(%s, %s) FROM RDB$DATABASE;', [Name, '1']);

  result := GetSequence;
end;

class function TADRConnModelGeneratorFirebird.New(Query: IADRQuery): IADRGenerator;
begin
  result := Self.create(Query);
end;

end.
