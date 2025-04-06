program ADRConnection_DemoHorse;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  Horse.Jhonson,
  System.SysUtils,
  ADRConnection.Pool,
  DAO.Person in 'DAO.Person.pas',
  Controller.Person in 'Controller.Person.pas';

begin
  IsConsole := False;
  ReportMemoryLeaksOnShutdown := True;

  THorse.Use(Jhonson);

  THorse.Listen(9000,
    procedure
    begin
      System.Writeln('Rodando na porta 9000');
      System.ReadLn;
    end);
end.
