program TestADRConnection;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  TestInsight.DUnitX,
  DUnitX.TestFramework,
  ADRConn.Model.Interfaces in '..\Source\ADRConn.Model.Interfaces.pas',
  ADRConn.Model.Firedac.Connection in '..\Source\ADRConn.Model.Firedac.Connection.pas',
  ADRConn.Model.Params in '..\Source\ADRConn.Model.Params.pas',
  ADRConn.Model.Firedac.Driver in '..\Source\ADRConn.Model.Firedac.Driver.pas',
  ADRConn.Model.Firedac.Query in '..\Source\ADRConn.Model.Firedac.Query.pas',
  ADRConn.Test.Base in 'Source\ADRConn.Test.Base.pas',
  ADRConn.Model.Generator in '..\Source\ADRConn.Model.Generator.pas',
  ADRConn.Model.Generator.Firebird in '..\Source\ADRConn.Model.Generator.Firebird.pas',
  ADRConn.Model.Generator.Postgres in '..\Source\ADRConn.Model.Generator.Postgres.pas',
  ADRConn.Model.Generator.SQLite in '..\Source\ADRConn.Model.Generator.SQLite.pas',
  ADRConn.Model.Generator.MySQL in '..\Source\ADRConn.Model.Generator.MySQL.pas',
  ADRConn.DAO.Base in '..\Source\ADRConn.DAO.Base.pas',
  ADRConn.Config.IniFile in '..\Source\ADRConn.Config.IniFile.pas',
  ADRConn.Model.Factory in '..\Source\ADRConn.Model.Factory.pas',
  ADRConn.Test.Query.Base in 'Source\ADRConn.Test.Query.Base.pas',
  ADRConn.Test.SQLite.Connection in 'Source\ADRConn.Test.SQLite.Connection.pas',
  ADRConn.Test.Query.Firedac in 'Source\ADRConn.Test.Query.Firedac.pas',
  ADRConn.Test.MySQL.Connection in 'Source\ADRConn.Test.MySQL.Connection.pas',
  ADRConn.Model.PgDAC.Connection in '..\Source\ADRConn.Model.PgDAC.Connection.pas',
  ADRConn.Model.PgDAC.Connection.Test in 'Source\ADRConn.Model.PgDAC.Connection.Test.pas',
  ADRConn.Model.PGDac.Query in '..\Source\ADRConn.Model.PGDac.Query.pas',
  ADRConn.Model.PgDAC.Query.Test in 'Source\ADRConn.Model.PgDAC.Query.Test.pas',
  ADRConn.Model.Zeos.Connection in '..\Source\ADRConn.Model.Zeos.Connection.pas',
  ADRConn.Model.Zeos.Connection.Test in 'Source\ADRConn.Model.Zeos.Connection.Test.pas',
  ADRConn.Model.Zeos.Query in '..\Source\ADRConn.Model.Zeos.Query.pas',
  ADRConn.Model.Zeos.Query.Test in 'Source\ADRConn.Model.Zeos.Query.Test.pas',
  PoolManager in '..\Source\PoolManager.pas',
  ADRConnection.Pool in '..\Source\ADRConnection.Pool.pas',
  ADRConn.Model.Events in '..\Source\ADRConn.Model.Events.pas',
  ADRConnection.Pool.Firedac in '..\Source\ADRConnection.Pool.Firedac.pas',
  ADRConn.Model.QueryParam in '..\Source\ADRConn.Model.QueryParam.pas',
  ADRConn.Model.QueryParam.Validator in '..\Source\ADRConn.Model.QueryParam.Validator.pas';

begin
  IsConsole := False;
  ReportMemoryLeaksOnShutdown := True;
  TestInsight.DUnitX.RunRegisteredTests;
end.
