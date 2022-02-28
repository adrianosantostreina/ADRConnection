program srvHorse;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  Horse.Compression,
  Horse.Jhonson,
  Horse.BasicAuthentication,
  Horse.OctetStream,
  Horse.Logger,
  Horse.Logger.Provider.Console,
  Horse.Logger.Provider.LogFile,
  Horse.Paginate,
  Horse.HandleException,
  Horse.GBSwagger,
  System.Json,
  System.SysUtils,
  Dataset.Serialize,
  Dataset.Serialize.Config,
  controllers.mesas in 'controllers\controllers.mesas.pas',
  dao.mesas in 'dao\dao.mesas.pas';

var
  LLogConsoleConfig : THorseLoggerConsoleConfig;
  LLogFileConfig    : THorseLoggerLogFileConfig;
  LLog              : string;
begin
  THorse
    .Use(Compression())
    .Use(OctetStream)
    .Use(Jhonson)
    .Use(HandleException)
    .Use(Paginate)
    .Use(HorseSwagger);

  THorse.Use(HorseBasicAuthentication(
    function(const AUsername, APassword: string): Boolean
    begin
      Result := AUsername.Equals('admin') and APassword.Equals('123456');
    end)
  );

  if ParamStr(1).Equals(EmptyStr)
  then LLog := '--c'
  else LLog := ParamStr(1);

  if LLog.Equals('--c') or LLog.Equals('--console') then
  begin
    LLogConsoleConfig := THorseLoggerConsoleConfig.New
      .SetLogFormat('${request_clientip} [${time}] ${response_status}');
    THorseLoggerManager.RegisterProvider(THorseLoggerProviderConsole.New());
    THorse.Use(THorseLoggerManager.HorseCallback);
  end
  else if ParamStr(1).Equals('--f') or ParamStr(1).Equals('--file') then
  begin
    LLogFileConfig := THorseLoggerLogFileConfig.New
      .SetLogFormat('${request_clientip} [${time}] ${response_status}')
      .SetDir('D:\Servidores\Log');
    THorseLoggerManager.RegisterProvider(THorseLoggerProviderLogFile.New());
    THorse.Use(THorseLoggerManager.HorseCallback);
  end;

  //Test Ping
  THorse
    .Get('/ping',
    procedure (Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end
  );

  controllers.mesas.Registry;

  //Configura o DataSet Serialize para pegar o padrão do banco
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndNone;

  THorse
    .Listen(9000,
    procedure (Horse: THorse)
    begin
      WriteLn(Format('Servidor Comanda Eletronica 2.0 executando na porta %d ', [Horse.Port]));
      WriteLn('Pronto para para funcionameto!');
      if LLog.Equals('--f') or LLog.Equals('--file') then
        WriteLn('Atencao! Log salvando em arquivo!');
    end
  )
end.
