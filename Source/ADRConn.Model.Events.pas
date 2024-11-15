unit ADRConn.Model.Events;

interface

uses
  ADRConn.Model.Interfaces,
  System.SysUtils;

type
  TADRConnConnectionModelEvents = class(TInterfacedObject, IADRConnectionEvents)
  private
    FOnHandleException: TADRHandleException;
    FOnLog: TADROnLog;
  protected
    function OnHandleException(AValue: TADRHandleException): IADRConnectionEvents; overload;
    function OnHandleException: TADRHandleException; overload;

    function OnLog(AValue: TADROnLog): IADRConnectionEvents; overload;
    function OnLog: TADROnLog; overload;

    function HandleException(AException: Exception): Boolean;
    function Log(ALog: string): IADRConnectionEvents; overload;
    function Log(ALog: string; const AArgs: array of const): IADRConnectionEvents; overload;
  public
    class function New: IADRConnectionEvents;
  end;

implementation

{ TADRConnConnectionModelEvents }

function TADRConnConnectionModelEvents.HandleException(AException: Exception): Boolean;
begin
  Result := False;
  if Assigned(FOnHandleException) then
    Result := FOnHandleException(AException);
end;

function TADRConnConnectionModelEvents.Log(ALog: string): IADRConnectionEvents;
begin
  Result := Self;
  if Assigned(FOnLog) then
    FOnLog(ALog);
end;

function TADRConnConnectionModelEvents.Log(ALog: string; const AArgs: array of const): IADRConnectionEvents;
var
  LLog: string;
begin
  Result := Self;
  try
    LLog := Format(ALog, AArgs);
  except
    LLog := ALog;
  end;

  if Assigned(FOnLog) then
    FOnLog(LLog);
end;

class function TADRConnConnectionModelEvents.New: IADRConnectionEvents;
begin
  Result := Self.Create;
end;

function TADRConnConnectionModelEvents.OnHandleException: TADRHandleException;
begin
  Result := FOnHandleException;
end;

function TADRConnConnectionModelEvents.OnLog: TADROnLog;
begin
  Result := FOnLog;
end;

function TADRConnConnectionModelEvents.OnLog(AValue: TADROnLog): IADRConnectionEvents;
begin
  Result := Self;
  FOnLog := AValue;
end;

function TADRConnConnectionModelEvents.OnHandleException(AValue: TADRHandleException): IADRConnectionEvents;
begin
  Result := Self;
  FOnHandleException := AValue;
end;

end.
