program SampleHorse;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  Horse.Jhonson,
  ADRConn.Config.IniFile,
  System.SysUtils,
  Controller.Cidade in 'Controllers\Controller.Cidade.pas',
  DAO.Cidade in 'DAO\DAO.Cidade.pas';

begin
  IsConsole := False;
  ReportMemoryLeaksOnShutdown := True;
  THorse.Use(Jhonson);

  Controller.Cidade.RegisterCidade;

  THorse.Listen(TADRConnConfigIni.ReadInteger('API_PORT', 8001), procedure(Horse: THorse)
    begin
      Writeln(Format('Server is runing on %s:%d', [Horse.Host, Horse.Port]));
      Readln;
    end);
end.
