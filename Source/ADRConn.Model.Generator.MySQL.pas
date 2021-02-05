unit ADRConn.Model.Generator.MySQL;

interface

uses
  ADRConn.Model.Interfaces,
  ADRConn.Model.Generator,
  System.SysUtils;

type TADRConnModelGeneratorMySQL = class(TADRConnModelGenerator, IADRGenerator)

  protected
    [Weak]
    FConnection: IADRConnection;

    function GetCurrentSequence(Name: String): Double; override;
    function GetNextSequence(Name: String): Double; override;

  public
    class function New(Query: IADRQuery): IADRGenerator;

end;

implementation

{ TADRConnModelGeneratorMySQL }

function TADRConnModelGeneratorMySQL.GetCurrentSequence(Name: String): Double;
begin
  FQuery
    .SQL('SELECT LAST_INSERT_ID() as ID');

  result := GetSequence;
end;

function TADRConnModelGeneratorMySQL.GetNextSequence(Name: String): Double;
begin
  FQuery
    .SQL('SELECT AUTO_INCREMENT FROM INFORMATION_SCHEMA.TABLES')
    .SQL('WHERE TABLE_SCHEMA = DATABASE()')
    .SQL('AND   UPPER(TABLE_NAME) IN (''%s'')', [Name]);

  result := GetSequence;
end;

class function TADRConnModelGeneratorMySQL.New(Query: IADRQuery): IADRGenerator;
begin
  result := Self.create(Query);
end;

end.
