unit ADRConn.Model.Generator.SQLite;

interface

uses
  ADRConn.Model.Interfaces,
  ADRConn.Model.Generator,
  System.SysUtils;

type TADRConnModelGeneratorSQLite = class(TADRConnModelGenerator, IADRGenerator)

  protected
    function GetCurrentSequence(Name: String): Double; override;
    function GetNextSequence(Name: String): Double; override;

  public
    class function New(Query: IADRQuery): IADRGenerator;

end;

implementation

{ TADRConnModelGeneratorSQLite }

function TADRConnModelGeneratorSQLite.GetCurrentSequence(Name: String): Double;
begin
  raise Exception.CreateFmt('Not implemented yet.', []);
end;

function TADRConnModelGeneratorSQLite.GetNextSequence(Name: String): Double;
begin
  raise Exception.CreateFmt('Not implemented yet.', []);
end;

class function TADRConnModelGeneratorSQLite.New(Query: IADRQuery): IADRGenerator;
begin
  result := Self.create(Query);
end;

end.
