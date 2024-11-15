unit ADRConn.Model.QueryParam;

interface

uses
  Data.DB,
  System.SysUtils,
  System.Generics.Collections,
  System.Variants,
  System.Classes,
  ADRConn.Model.Interfaces;

type
  TADRConnModelQueryParam = class(TInterfacedObject, IADRQueryParam)
  private
    [Weak]
    FQueryParams: IADRQueryParams;
    FParams: TParams;
    FParam: TParam;
    FName: string;
    FDataType: TFieldType;
    FNotEmpty: Boolean;
    FNullIfEmpty: Boolean;
    FStream: TStream;
    FValue: Variant;

    function IsEmptyValue: Boolean;
  protected
    function Name(AValue: string): IADRQueryParam; overload;
    function Name: string; overload;

    function DataType(AValue: TFieldType): IADRQueryParam; overload;
    function DataType: TFieldType; overload;

    function NotEmpty(AValue: Boolean): IADRQueryParam; overload;
    function NotEmpty: Boolean; overload;

    function NullIfEmpty(AValue: Boolean): IADRQueryParam; overload;
    function NullIfEmpty: Boolean; overload;

    function AsInteger(AValue: Integer): IADRQueryParam; overload;
    function AsInteger: Integer; overload;
    function AsCurrency(AValue: Currency): IADRQueryParam; overload;
    function AsCurrency: Currency; overload;
    function AsFloat(AValue: Double): IADRQueryParam; overload;
    function AsFloat: Double; overload;
    function AsString(AValue: string): IADRQueryParam; overload;
    function AsString: string; overload;
    function AsDateTime(AValue: TDateTime): IADRQueryParam; overload;
    function AsDateTime: TDateTime; overload;
    function AsDate(AValue: TDate): IADRQueryParam; overload;
    function AsDate: TDate; overload;
    function AsTime(AValue: TTime): IADRQueryParam; overload;
    function AsTime: TTime; overload;
    function AsBoolean(AValue: Boolean): IADRQueryParam; overload;
    function AsBoolean: Boolean; overload;
    function AsStream(AValue: TStream): IADRQueryParam; overload;
    function AsStream: TStream; overload;

    function Build: TParam;

    function &End: IADRQueryParams;
  public
    constructor Create(AParams: TParams; AQueryParams: IADRQueryParams);
    class function New(AParams: TParams; AQueryParams: IADRQueryParams): IADRQueryParam;
  end;

  TADRConnModelQueryParams = class(TInterfacedObject, IADRQueryParams)
  private
    [Weak]
    FQuery: IADRQuery;
    FParams: TParams;
    FQueryParams: TDictionary<string, IADRQueryParam>;
  protected
    function Get(AName: string): IADRQueryParam;
    function Clear: IADRQueryParams;
    function &End: IADRQuery;

    function AsInteger(AName: string; AValue: Integer; ANullIfEmpty: Boolean = False): IADRQueryParam; overload;
    function AsCurrency(AName: string; AValue: Currency; ANullIfEmpty: Boolean = False): IADRQueryParam; overload;
    function AsFloat(AName: string; AValue: Double; ANullIfEmpty: Boolean = False): IADRQueryParam; overload;
    function AsString(AName: string; AValue: string; ANullIfEmpty: Boolean = False): IADRQueryParam; overload;
    function AsDateTime(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQueryParam; overload;
    function AsDate(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQueryParam; overload;
    function AsTime(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQueryParam; overload;
    function AsBoolean(AName: string; AValue: Boolean; ANullIfEmpty: Boolean = False): IADRQueryParam; overload;
    function AsStream(AName: string; AValue: TStream; ADataType: TFieldType = ftBlob; ANullIfEmpty: Boolean = False): IADRQueryParam; overload;
  public
    constructor Create(AQuery: IADRQuery; AParams: TParams);
    class function New(AQuery: IADRQuery; AParams: TParams): IADRQueryParams;
    destructor Destroy; override;
  end;

implementation

{ TADRConnModelQueryParam }

function TADRConnModelQueryParam.AsBoolean(AValue: Boolean): IADRQueryParam;
begin
  Result := Self;
  FValue := AValue;
  FDataType := ftBoolean;
  Build;
end;

function TADRConnModelQueryParam.&End: IADRQueryParams;
begin
  Result := FQueryParams;
end;

function TADRConnModelQueryParam.AsBoolean: Boolean;
begin
  Result := FValue;
end;

function TADRConnModelQueryParam.AsCurrency: Currency;
begin
  Result := FValue;
end;

function TADRConnModelQueryParam.AsCurrency(AValue: Currency): IADRQueryParam;
begin
  Result := Self;
  FValue := AValue;
  FDataType := ftCurrency;
  Build;
end;

function TADRConnModelQueryParam.AsDate(AValue: TDate): IADRQueryParam;
begin
  Result := Self;
  FValue := AValue;
  FDataType := ftDate;
  Build;
end;

function TADRConnModelQueryParam.AsDate: TDate;
begin
  Result := FValue;
end;

function TADRConnModelQueryParam.AsDateTime(AValue: TDateTime): IADRQueryParam;
begin
  Result := Self;
  FValue := AValue;
  FDataType := ftDateTime;
  Build;
end;

function TADRConnModelQueryParam.AsDateTime: TDateTime;
begin
  Result := FValue;
end;

function TADRConnModelQueryParam.AsFloat(AValue: Double): IADRQueryParam;
begin
  Result := Self;
  FValue := AValue;
  FDataType := ftFloat;
  Build;
end;

function TADRConnModelQueryParam.AsFloat: Double;
begin
  Result := FValue;
end;

function TADRConnModelQueryParam.AsInteger: Integer;
begin
  Result := FValue;
end;

function TADRConnModelQueryParam.AsInteger(AValue: Integer): IADRQueryParam;
begin
  Result := Self;
  FValue := AValue;
  FDataType := ftInteger;
  Build;
end;

function TADRConnModelQueryParam.AsStream: TStream;
begin
  Result := FStream;
end;

function TADRConnModelQueryParam.AsStream(AValue: TStream): IADRQueryParam;
begin
  Result := Self;
  FStream := AValue;
  FDataType := ftBlob;
  Build;
end;

function TADRConnModelQueryParam.AsString(AValue: string): IADRQueryParam;
begin
  Result := Self;
  FValue := AValue;
  FDataType := ftString;
  Build;
end;

function TADRConnModelQueryParam.AsString: string;
begin
  Result := FValue;
end;

function TADRConnModelQueryParam.AsTime: TTime;
begin
  Result := FValue;
end;

function TADRConnModelQueryParam.Build: TParam;
begin
  if not Assigned(FParam) then
  begin
    FParam := FParams.AddParameter;
    FParam.Name := FName;
    FParam.ParamType := ptInput;
    FParam.DataType := FDataType;
    FParam.Value := FValue;
    if IsEmptyValue and FNullIfEmpty then
    begin
      FParam.DataType := FDataType;
      FParam.Clear;
    end;
  end;
  Result := FParam;
end;

constructor TADRConnModelQueryParam.Create(AParams: TParams; AQueryParams: IADRQueryParams);
begin
  FParams := AParams;
  FQueryParams := AQueryParams;
end;

function TADRConnModelQueryParam.DataType: TFieldType;
begin
  Result := FDataType;
end;

function TADRConnModelQueryParam.IsEmptyValue: Boolean;
begin
  Result := VarIsEmpty(FValue);
end;

function TADRConnModelQueryParam.DataType(AValue: TFieldType): IADRQueryParam;
begin
  Result := Self;
  FDataType := AValue;
end;

function TADRConnModelQueryParam.AsTime(AValue: TTime): IADRQueryParam;
begin
  Result := Self;
  FValue := AValue;
  FDataType := ftTime;
  Build;
end;

function TADRConnModelQueryParam.Name(AValue: string): IADRQueryParam;
begin
  Result := Self;
  FName := AValue;
end;

function TADRConnModelQueryParam.Name: string;
begin
  Result := FName;
end;

class function TADRConnModelQueryParam.New(AParams: TParams; AQueryParams: IADRQueryParams): IADRQueryParam;
begin
  Result := Self.Create(AParams, AQueryParams);
end;

function TADRConnModelQueryParam.NotEmpty: Boolean;
begin
  Result := FNotEmpty;
end;

function TADRConnModelQueryParam.NotEmpty(AValue: Boolean): IADRQueryParam;
begin
  Result := Self;
  FNotEmpty := AValue;
end;

function TADRConnModelQueryParam.NullIfEmpty(AValue: Boolean): IADRQueryParam;
begin
  Result := Self;
  FNullIfEmpty := AValue;
end;

function TADRConnModelQueryParam.NullIfEmpty: Boolean;
begin
  Result := FNullIfEmpty;
end;

{ TADRConnModelQueryParams }

function TADRConnModelQueryParams.&End: IADRQuery;
begin
  Result := FQuery;
end;

function TADRConnModelQueryParams.AsBoolean(AName: string; AValue, ANullIfEmpty: Boolean): IADRQueryParam;
begin
  Result := Get(AName);
  Result.AsBoolean(AValue).NullIfEmpty(ANullIfEmpty);
end;

function TADRConnModelQueryParams.AsCurrency(AName: string; AValue: Currency;
  ANullIfEmpty: Boolean): IADRQueryParam;
begin
  Result := Get(AName);
  Result.AsCurrency(AValue).NullIfEmpty(ANullIfEmpty);
end;

function TADRConnModelQueryParams.AsDate(AName: string; AValue: TDateTime;
  ANullIfEmpty: Boolean): IADRQueryParam;
begin
  Result := Get(AName);
  Result.AsDate(AValue).NullIfEmpty(ANullIfEmpty);
end;

function TADRConnModelQueryParams.AsDateTime(AName: string; AValue: TDateTime;
  ANullIfEmpty: Boolean): IADRQueryParam;
begin
  Result := Get(AName);
  Result.AsDateTime(AValue).NullIfEmpty(ANullIfEmpty);
end;

function TADRConnModelQueryParams.AsFloat(AName: string; AValue: Double;
  ANullIfEmpty: Boolean): IADRQueryParam;
begin
  Result := Get(AName);
  Result.AsFloat(AValue).NullIfEmpty(ANullIfEmpty);
end;

function TADRConnModelQueryParams.AsInteger(AName: string; AValue: Integer;
  ANullIfEmpty: Boolean): IADRQueryParam;
begin
  Result := Get(AName);
  Result.AsInteger(AValue).NullIfEmpty(ANullIfEmpty);
end;

function TADRConnModelQueryParams.AsStream(AName: string; AValue: TStream; ADataType: TFieldType;
  ANullIfEmpty: Boolean): IADRQueryParam;
begin
  Result := Get(AName);
  Result.AsStream(AValue).NullIfEmpty(ANullIfEmpty);
end;

function TADRConnModelQueryParams.AsString(AName, AValue: string; ANullIfEmpty: Boolean): IADRQueryParam;
begin
  Result := Get(AName);
  Result.AsString(AValue).NullIfEmpty(ANullIfEmpty);
end;

function TADRConnModelQueryParams.AsTime(AName: string; AValue: TDateTime;
  ANullIfEmpty: Boolean): IADRQueryParam;
begin
  Result := Get(AName);
  Result.AsTime(AValue).NullIfEmpty(ANullIfEmpty);
end;

function TADRConnModelQueryParams.Clear: IADRQueryParams;
begin
  Result := Self;
  FParams.Clear;
  FQueryParams.Clear;
end;

constructor TADRConnModelQueryParams.Create(AQuery: IADRQuery; AParams: TParams);
begin
  FQuery := AQuery;
  FParams := AParams;
  FQueryParams := TDictionary<string, IADRQueryParam>.Create;
end;

destructor TADRConnModelQueryParams.Destroy;
begin
  FQueryParams.Free;
  inherited;
end;

function TADRConnModelQueryParams.Get(AName: string): IADRQueryParam;
var
  LParamName: string;
begin
  LParamName := AName.ToLower.Trim;
  if not FQueryParams.TryGetValue(LParamName, Result) then
  begin
    Result := TADRConnModelQueryParam.New(FParams, Self).Name(AName);
    FQueryParams.AddOrSetValue(LParamName, Result);
  end;
end;

class function TADRConnModelQueryParams.New(AQuery: IADRQuery; AParams: TParams): IADRQueryParams;
begin
  Result := Self.Create(AQuery, AParams);
end;

end.
