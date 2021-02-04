unit Server.DataSets;

interface

uses
  System.Classes,
  System.SysUtils,

  FireDAC.Comp.Client,
  FireDAC.DApt,
  FireDAC.Stan.Def,        //StanStorage

  SmartPoint,
  Server.Connection;

type
  TMyQuery = class
    private
      FQuery : TFDQuery;
    public
      constructor Create;
      destructor Destroy;
      property Query : TFDQuery read FQuery write FQuery;
  end;

implementation

{ TMyQuery }

constructor TMyQuery.Create;
var
  LConnection : TSmartPointer<TConnectionData>;
begin
  if not Assigned(FQuery) then
    FQuery := TFDQuery.Create(nil);

  if FQuery.Connection = nil then
    FQuery.Connection := LConnection.Value.Connection;
end;

destructor TMyQuery.Destroy;
begin
  if Assigned(FQuery) then
  begin
    FQuery.Active := False;
    FQuery.Free;
    FQuery := nil;
  end;
end;

end.
