program MultiDatabase;

uses
  Vcl.Forms,
  FMultiDatabase in 'FMultiDatabase.pas' {Form1},
  ADRConn.Config.IniFile in '..\..\..\Source\ADRConn.Config.IniFile.pas',
  ADRConn.DAO.Base in '..\..\..\Source\ADRConn.DAO.Base.pas',
  ADRConn.Model.Factory in '..\..\..\Source\ADRConn.Model.Factory.pas',
  ADRConn.Model.Firedac.Connection in '..\..\..\Source\ADRConn.Model.Firedac.Connection.pas',
  ADRConn.Model.Firedac.Driver in '..\..\..\Source\ADRConn.Model.Firedac.Driver.pas',
  ADRConn.Model.Firedac.Query in '..\..\..\Source\ADRConn.Model.Firedac.Query.pas',
  ADRConn.Model.Generator.Firebird in '..\..\..\Source\ADRConn.Model.Generator.Firebird.pas',
  ADRConn.Model.Generator.MySQL in '..\..\..\Source\ADRConn.Model.Generator.MySQL.pas',
  ADRConn.Model.Generator in '..\..\..\Source\ADRConn.Model.Generator.pas',
  ADRConn.Model.Generator.Postgres in '..\..\..\Source\ADRConn.Model.Generator.Postgres.pas',
  ADRConn.Model.Generator.SQLite in '..\..\..\Source\ADRConn.Model.Generator.SQLite.pas',
  ADRConn.Model.Interfaces in '..\..\..\Source\ADRConn.Model.Interfaces.pas',
  ADRConn.Model.Params in '..\..\..\Source\ADRConn.Model.Params.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
