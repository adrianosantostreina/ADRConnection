unit DAO.Base;

interface

uses
  Data.DB,

  System.SysUtils,
  Server.Connection,
  Server.DataSets;

type
  TDAOBase = class
    protected
      FFormatSettings : TFormatSettings;
      FConnection    : TConnectionData;
      procedure SetFormatSettings;
      function NewQuery           : TMyQuery;
      function SetSQL(SQL: string): TMyQuery;

      property FormatSettings: TFormatSettings read FFormatSettings write FFormatSettings;
    public
      constructor Create(Connection: TConnectionData);

  end;

implementation

{ TDAOBase }

procedure TDAOBase.SetFormatSettings;
begin
  FFormatSettings                 := TFormatSettings.Create;
  FFormatSettings.DateSeparator   := '-';
  FFormatSettings.ShortDateFormat := 'yyyy-MM-dd';
  FFormatSettings.TimeSeparator   := ':';
  FFormatSettings.ShortTimeFormat := 'hh:mm';
  FFormatSettings.LongTimeFormat  := 'hh:mm:ss';
end;

constructor TDAOBase.Create(Connection: TConnectionData);
begin
  FConnection := Connection;
  SetFormatSettings;
end;

function TDAOBase.NewQuery: TMyQuery;
begin
  Result                  := TMyQuery.Create;
  Result.Query.Connection := FConnection.Connection;
  Result.Query.Active     := False;
  Result.Query.SQL.Clear;
end;

function TDAOBase.SetSQL(SQL: string): TMyQuery;
begin
  Result := NewQuery;
  try
    Result.Query.SQL.Text := SQL;
  except
    Result.Free;
    raise;
  end;
end;



end.
