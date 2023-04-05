unit ADRConn.Model.Generator.SQLite;

interface

uses
  ADRConn.Model.Interfaces,
  ADRConn.Model.Generator,
  System.SysUtils;

type
  TADRConnModelGeneratorSQLite = class(TADRConnModelGenerator, IADRGenerator)
  protected
    function GetCurrentSequence(AName: string): Double; override;
    function GetNextSequence(AName: string): Double; override;
  public
    class function New(AQuery: IADRQuery): IADRGenerator;
  end;

implementation

{ TADRConnModelGeneratorSQLite }

function TADRConnModelGeneratorSQLite.GetCurrentSequence(AName: string): Double;
begin
  raise Exception.CreateFmt('Not implemented yet.', []);
end;

function TADRConnModelGeneratorSQLite.GetNextSequence(AName: string): Double;
begin
  raise Exception.CreateFmt('Not implemented yet.', []);
end;

class function TADRConnModelGeneratorSQLite.New(AQuery: IADRQuery): IADRGenerator;
begin
  Result := Self.Create(AQuery);
end;

end.
