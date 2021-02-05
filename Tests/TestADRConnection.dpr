program TestADRConnection;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  {$ENDIF }
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
  ADRConn.Test.Firebird.Connection in 'Source\ADRConn.Test.Firebird.Connection.pas',
  ADRConn.Test.Firebird.Query in 'Source\ADRConn.Test.Firebird.Query.pas',
  ADRConn.Test.MySQL.Connection in 'Source\ADRConn.Test.MySQL.Connection.pas',
  ADRConn.Test.MySQL.Query in 'Source\ADRConn.Test.MySQL.Query.pas',
  ADRConn.Test.Query.Base in 'Source\ADRConn.Test.Query.Base.pas',
  ADRConn.Test.SQLite.Connection in 'Source\ADRConn.Test.SQLite.Connection.pas';

{$IFNDEF TESTINSIGHT}
var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
  nunitLogger : ITestLogger;
{$ENDIF}
begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
{$ELSE}
  IsConsole := False;
  ReportMemoryLeaksOnShutdown := True;
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //When true, Assertions must be made during tests;
    runner.FailsOnNoAsserts := False;

    //tell the runner how we will log things
    //Log to the console window if desired
    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
    begin
      logger := TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);
      runner.AddLogger(logger);
    end;
    //Generate an NUnit compatible XML File
//    logger := TDUnitXConsoleLogger.Create(true);
//    runner.AddLogger(logger);
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
{$ENDIF}
end.
