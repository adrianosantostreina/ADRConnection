unit ADRConnection.Pool;

interface

uses
  PoolManager,
  ADRConn.Model.Interfaces,
  System.SysUtils,
  System.Classes;

type
  TOnGetConnection = TFunc<IADRConnection>;

  TOnComponentError = procedure(ASender, AInitiator: TObject; var AException: Exception);

  TADRConnectionPoolItem = class
  protected
    FConnection: IADRConnection;
    FRetry: Integer;
    FRetryCount: Integer;
    FIsHandledError: Boolean;
    FSleep: Integer;
    FOnLog: TProc<string>;
    function DoHandleException(AException: Exception): Boolean;
    procedure Log(ALog: string);
    procedure SetOnLog(const AValue: TProc<string>);
  public
    constructor Create; virtual;
    procedure Initialize;
    property Connection: IADRConnection read FConnection;
    property OnLog: TProc<string> write SetOnLog;
  end;

  TADRConnectionPool = class(TPoolManager<TADRConnectionPoolItem>)
  private
    class var FPoolManager: TADRConnectionPool;
  protected
    class procedure CreateDefaultInstance;
    class function GetPoolManager: TADRConnectionPool; static;
  public
    class destructor UnInitialize;

    procedure DoGetInstance(var AInstance: TADRConnectionPoolItem; var AInstanceOwner: Boolean); override;

    class property PoolManager: TADRConnectionPool read GetPoolManager;
  end;

  IADRConnectionPoolBuilder = interface
    ['{BA34C2B7-A0B2-46F7-8ECB-606C10BB9271}']
    function MaxRefCountPerItem(AValue: Integer): IADRConnectionPoolBuilder;
    function MaxIdleSeconds(AValue: Integer): IADRConnectionPoolBuilder;
    function MinPoolCount(AValue: Integer): IADRConnectionPoolBuilder;
    function OnGetConnection(AValue: TFunc<IADRConnection>): IADRConnectionPoolBuilder;
    procedure Build;
  end;

  TADRConnectionPoolBuilder = class(TInterfacedObject, IADRConnectionPoolBuilder)
  private
    FMaxRefCountPerItem: Integer;
    FMaxIdleSeconds: Integer;
    FMinPoolCount: Integer;
    FOnGetConnection: TFunc<IADRConnection>;
  protected
    function MaxRefCountPerItem(AValue: Integer): IADRConnectionPoolBuilder;
    function MaxIdleSeconds(AValue: Integer): IADRConnectionPoolBuilder;
    function MinPoolCount(AValue: Integer): IADRConnectionPoolBuilder;
    function OnGetConnection(AValue: TFunc<IADRConnection>): IADRConnectionPoolBuilder;
    procedure Build;
  public
    constructor Create;
    class function New: IADRConnectionPoolBuilder;
  end;

var
  OnGetConnection: TOnGetConnection;

function GetPoolItem: TPoolItem<TADRConnectionPoolItem>;

implementation

{$IFDEF ADRCONN_FIREDAC}
uses
  FireDAC.Comp.Client,
  ADRConnection.Pool.Firedac;
{$ENDIF}

function GetPoolItem: TPoolItem<TADRConnectionPoolItem>;
begin
  Result := TADRConnectionPool.PoolManager.TryGetItem;
end;

{ TADRConnectionPool }

class procedure TADRConnectionPool.CreateDefaultInstance;
begin
  FPoolManager := TADRConnectionPool.Create(True);
  FPoolManager.SetMaxIdleSeconds(30);
end;

procedure TADRConnectionPool.DoGetInstance(var AInstance: TADRConnectionPoolItem; var AInstanceOwner: Boolean);
var
  LInstance: TADRConnectionPoolItem;
begin
  inherited;
  AInstanceOwner := True;
{$IFDEF ADRCONN_FIREDAC}
  AInstance := TADRConnectionPoolItemFiredac.Create;
  TFDConnection(AInstance.FConnection.Component).OnError :=
    TADRConnectionPoolItemFiredac(AInstance).OnError;
{$ELSE}
  AInstance := TADRConnectionPoolItem.Create;
{$ENDIF}
  LInstance := AInstance;
  LInstance.FConnection := OnGetConnection;
  AInstance.FConnection.Events.OnHandleException(LInstance.DoHandleException);
end;

class function TADRConnectionPool.GetPoolManager: TADRConnectionPool;
begin
  if not Assigned(FPoolManager) then
    CreateDefaultInstance;
  Result := FPoolManager;
end;

class destructor TADRConnectionPool.UnInitialize;
begin
  if Assigned(FPoolManager) then
    FreeAndNil(FPoolManager);
end;

{ TADRConnectionPoolBuilder }

procedure TADRConnectionPoolBuilder.Build;
begin
  ADRConnection.Pool.OnGetConnection := FOnGetConnection;
  TADRConnectionPool.PoolManager.SetMaxRefCountPerItem(FMaxRefCountPerItem);
  TADRConnectionPool.PoolManager.SetMinPoolCount(FMinPoolCount);
  TADRConnectionPool.PoolManager.SetMaxIdleSeconds(FMaxIdleSeconds);
  TADRConnectionPool.PoolManager.Start;
end;

constructor TADRConnectionPoolBuilder.Create;
begin
  FMaxRefCountPerItem := 1;
  FMaxIdleSeconds := 30;
  FMinPoolCount := 10;
  FOnGetConnection := nil;
end;

function TADRConnectionPoolBuilder.MaxIdleSeconds(AValue: Integer): IADRConnectionPoolBuilder;
begin
  Result := Self;
  FMaxIdleSeconds := AValue;
end;

function TADRConnectionPoolBuilder.MaxRefCountPerItem(AValue: Integer): IADRConnectionPoolBuilder;
begin
  Result := Self;
  FMaxRefCountPerItem := AValue;
end;

function TADRConnectionPoolBuilder.MinPoolCount(AValue: Integer): IADRConnectionPoolBuilder;
begin
  Result := Self;
  FMinPoolCount := AValue;
end;

class function TADRConnectionPoolBuilder.New: IADRConnectionPoolBuilder;
begin
  Result := Self.Create;
end;

function TADRConnectionPoolBuilder.OnGetConnection(AValue: TFunc<IADRConnection>): IADRConnectionPoolBuilder;
begin
  Result := Self;
  FOnGetConnection := AValue;
end;

{ TADRConnectionPoolItem }

constructor TADRConnectionPoolItem.Create;
begin
  Initialize;
end;

function TADRConnectionPoolItem.DoHandleException(AException: Exception): Boolean;
begin
  Result := False;
  if not FIsHandledError then
    Exit(False);

  repeat
    if FRetryCount = FRetry then
    begin
      Log('Reconnection: Failed');
      Exit(False);
    end;

    if FIsHandledError then
    begin
      Sleep(FSleep);
      try
        if not FConnection.Connected then
          FConnection.Connect;
      except
      end;

      Result := FConnection.Connected;
      if Result then
        Log('Reconnection: Success');
    end;
  until (not FIsHandledError) or (Result);
end;

procedure TADRConnectionPoolItem.Initialize;
begin
  FRetry := 5;
  FSleep := 1000;
  FRetryCount := 0;
end;

procedure TADRConnectionPoolItem.Log(ALog: string);
begin
  if Assigned(FOnLog) then
    FOnLog(ALog);
end;

procedure TADRConnectionPoolItem.SetOnLog(const AValue: TProc<string>);
begin
  FOnLog := AValue;
  FConnection.Events.OnLog(FOnLog);
end;

end.
