unit ADRConn.Model.Generator.MySQL;

interface

uses
  ADRConn.Model.Interfaces,
  ADRConn.Model.Generator,
  System.SysUtils;

type
  TADRConnModelGeneratorMySQL = class(TADRConnModelGenerator, IADRGenerator)
  protected
    [Weak]
    FConnection: IADRConnection;

    function GetCurrentSequence(AName: string): Double; override;
    function GetNextSequence(AName: string): Double; override;
  public
    class function New(AQuery: IADRQuery): IADRGenerator;
  end;

implementation

{ TADRConnModelGeneratorMySQL }

function TADRConnModelGeneratorMySQL.GetCurrentSequence(AName: string): Double;
begin
  FQuery
    .SQL('SELECT LAST_INSERT_ID() as ID');

  Result := GetSequence;
end;

function TADRConnModelGeneratorMySQL.GetNextSequence(AName: string): Double;
begin
  FQuery
    .SQL('SELECT AUTO_INCREMENT FROM INFORMATION_SCHEMA.TABLES')
    .SQL('WHERE TABLE_SCHEMA = DATABASE()')
    .SQL('AND   UPPER(TABLE_NAME) IN (''%s'')', [AName]);

  Result := GetSequence;
end;

class function TADRConnModelGeneratorMySQL.New(AQuery: IADRQuery): IADRGenerator;
begin
  Result := Self.Create(AQuery);
end;

end.
