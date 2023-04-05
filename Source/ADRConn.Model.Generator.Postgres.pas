unit ADRConn.Model.Generator.Postgres;

interface

uses
  ADRConn.Model.Interfaces,
  ADRConn.Model.Generator,
  System.SysUtils;

type
  TADRConnModelGeneratorPostgres = class(TADRConnModelGenerator, IADRGenerator)
  protected
    function GetCurrentSequence(AName: string): Double; override;
    function GetNextSequence(AName: string): Double; override;
  public
    class function New(AQuery: IADRQuery): IADRGenerator;
  end;

implementation

{ TADRConnModelGeneratorPostgres }

function TADRConnModelGeneratorPostgres.GetCurrentSequence(AName: string): Double;
begin
  FQuery
    .SQL('SELECT CURRVAL(''%s'')', [AName]);

  Result := GetSequence;
end;

function TADRConnModelGeneratorPostgres.GetNextSequence(AName: string): Double;
begin
  FQuery
    .SQL('SELECT NEXTVAL(''%s'')', [AName, '1']);

  Result := GetSequence;
end;

class function TADRConnModelGeneratorPostgres.New(AQuery: IADRQuery): IADRGenerator;
begin
  Result := Self.Create(AQuery);
end;

end.
