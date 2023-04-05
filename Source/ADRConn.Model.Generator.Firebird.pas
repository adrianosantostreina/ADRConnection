unit ADRConn.Model.Generator.Firebird;

interface

uses
  ADRConn.Model.Interfaces,
  ADRConn.Model.Generator,
  System.SysUtils;

type
  TADRConnModelGeneratorFirebird = class(TADRConnModelGenerator, IADRGenerator)
  protected
    function GetCurrentSequence(AName: string): Double; override;
    function GetNextSequence(AName: string): Double; override;
  public
    class function New(AQuery: IADRQuery): IADRGenerator;
  end;

implementation

{ TADRConnModelGeneratorFirebird }

function TADRConnModelGeneratorFirebird.GetCurrentSequence(AName: string): Double;
begin
  FQuery
    .SQL('SELECT GEN_ID(%s, 0) FROM RDB$DATABASE;', [AName]);

  Result := GetSequence;
end;

function TADRConnModelGeneratorFirebird.GetNextSequence(AName: string): Double;
begin
  FQuery
    .SQL('SELECT GEN_ID(%s, %s) FROM RDB$DATABASE;', [AName, '1']);

  Result := GetSequence;
end;

class function TADRConnModelGeneratorFirebird.New(AQuery: IADRQuery): IADRGenerator;
begin
  Result := Self.Create(AQuery);
end;

end.
