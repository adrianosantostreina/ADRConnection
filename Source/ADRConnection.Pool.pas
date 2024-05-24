unit ADRConnection.Pool;

interface

uses
  PoolManager,
  ADRConn.Model.Interfaces,
  System.SysUtils,
  System.Classes;

type
  TOnGetConnection = TFunc<IADRConnection>;

  TADRConnectionPoolItem = class
  private
    FConnection: IADRConnection;
  public
    property Connection: IADRConnection read FConnection;
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
begin
  inherited;
  AInstanceOwner := True;
  AInstance := TADRConnectionPoolItem.Create;
  AInstance.FConnection := OnGetConnection;
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

end.
