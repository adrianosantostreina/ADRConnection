unit ADRConnection.Pool.Firedac;

interface

uses
  System.SysUtils,
  System.DateUtils,
  System.TypInfo,
  FireDAC.Phys.PGWrapper,
  FireDAC.Stan.Error,
  ADRConnection.Pool;

type
  TADRConnectionPoolItemFiredac = class(TADRConnectionPoolItem)
  private
    FOnError: TFDErrorEvent;
    procedure OnComponentError(ASender, AInitiator: TObject; var AException: Exception);
  public
    constructor Create; override;
    property OnError: TFDErrorEvent read FOnError;
  end;

implementation

{ TADRConnectionPoolItemFiredac }

constructor TADRConnectionPoolItemFiredac.Create;
begin
  inherited;
  FOnError := OnComponentError;
end;

procedure TADRConnectionPoolItemFiredac.OnComponentError(ASender, AInitiator: TObject;
  var AException: Exception);
var
  LErrorCode: string;
  LKind: TFDCommandExceptionKind;
begin
  Inc(FRetryCount);
  FSleep := FSleep + 2000;

  Log(Format('Exception: %s %s', [AException.ClassName, AException.Message]));
  FIsHandledError := AException is EPgNativeException;

  if not FIsHandledError then
    Exit;

  LKind := EPgNativeException(AException).Kind;
  FIsHandledError := LKind in [ekOther, ekServerGone];
  Log(Format('Kind: %s', [GetEnumName(TypeInfo(TFDCommandExceptionKind), Ord(LKind))]));

  if EPgNativeException(AException).ErrorCount > 0 then
  begin
    LErrorCode := EPgNativeException(AException).Errors[0].ErrorCode;
    Log(Format('ErrorCode: %s', [LErrorCode]));
  end;

  FIsHandledError := FIsHandledError and (not LErrorCode.Contains('22001'));
end;

end.
