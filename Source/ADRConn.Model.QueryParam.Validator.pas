unit ADRConn.Model.QueryParam.Validator;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Variants,
  Data.DB,
  ADRConn.Model.Interfaces;

type
  TADRConnModelQueryParamValidator = class(TInterfacedObject, IADRQueryParamValidator)
  protected
    FParam: IADRQueryParam;

    procedure Validate; virtual;
  public
    constructor Create(AParam: IADRQueryParam);
    class function New(AParam: IADRQueryParam): IADRQueryParamValidator;
  end;

  TADRConnModelQueryParamValidatorLength = class(TADRConnModelQueryParamValidator,
    IADRQueryParamValidator)
  protected
    procedure Validate; override;
  end;

  TADRConnModelQueryParamValidatorNotEmpty = class(TADRConnModelQueryParamValidator,
    IADRQueryParamValidator)
  private
    function IsEmptyValue: Boolean;
  protected
    procedure Validate; override;
  end;

  TADRConnModelQueryParamValidatorValue = class(TADRConnModelQueryParamValidator,
    IADRQueryParamValidator)
  protected
    procedure Validate; override;
  end;

implementation

{ TADRConnModelQueryParamValidator }

constructor TADRConnModelQueryParamValidator.Create(AParam: IADRQueryParam);
begin
  FParam := AParam;
end;

class function TADRConnModelQueryParamValidator.New(AParam: IADRQueryParam): IADRQueryParamValidator;
begin
  Result := Self.Create(AParam);
end;

procedure TADRConnModelQueryParamValidator.Validate;
var
  LValidators: TList<IADRQueryParamValidator>;
  LValidator: IADRQueryParamValidator;
begin
  LValidators := TList<IADRQueryParamValidator>.Create;
  try
    if FParam.DataType = ftString then
    begin
      LValidators.Add(TADRConnModelQueryParamValidatorNotEmpty.New(FParam));
      LValidators.Add(TADRConnModelQueryParamValidatorLength.New(FParam));
    end;

    if FParam.DataType in [ftInteger, ftFloat, ftCurrency] then
      LValidators.Add(TADRConnModelQueryParamValidatorValue.New(FParam));

    for LValidator in LValidators do
      LValidator.Validate;
  finally
    LValidators.Free;
  end;
end;

{ TADRConnModelQueryParamValidatorNotEmpty }

function TADRConnModelQueryParamValidatorNotEmpty.IsEmptyValue: Boolean;
var
  LParam: TParam;
begin
  LParam := FParam.Param;
  Result := False;
  if LParam.DataType = ftString then
    Result := LParam.AsString.IsEmpty
  else
  if LParam.DataType in [ftInteger, ftFloat, ftCurrency, ftDate, ftDateTime, ftTime] then
    Result := LParam.Value = 0;
end;

procedure TADRConnModelQueryParamValidatorNotEmpty.Validate;
begin
  if (FParam.NotEmpty) and (IsEmptyValue) then
    raise Exception.CreateFmt('Field %s must not be empty.', [FParam.Name]);
end;

{ TADRConnModelQueryParamValidatorLength }

procedure TADRConnModelQueryParamValidatorLength.Validate;
var
  LValue: string;
begin
  if FParam.DataType <> ftString then
    Exit;

  LValue := FParam.Param.AsString;
  if (FParam.MinLength > 0) and (LValue.Length < FParam.MinLength) then
    raise Exception.CreateFmt('Field %s must have a minimum size of %d.',
      [FParam.Name, FParam.MinLength]);

  if (FParam.MaxLength > 0) and (LValue.Length > FParam.MaxLength) then
    raise Exception.CreateFmt('Field %s must have a maximum size of %d.',
      [FParam.Name, FParam.MaxLength]);
end;

{ TADRConnModelQueryParamValidatorValue }

procedure TADRConnModelQueryParamValidatorValue.Validate;
var
  LValue: Double;
begin
  if not (FParam.DataType in [ftInteger, ftFloat, ftCurrency]) then
    Exit;

  LValue := FParam.AsFloat;
  if (FParam.MinValue <> 0) and (LValue < FParam.MinValue) then
    raise Exception.CreateFmt('Field %s must have a minimum value of %s.',
      [FParam.Name, FloatToStr(FParam.MinValue)]);

  if (FParam.MaxValue <> 0) and (LValue > FParam.MaxValue) then
    raise Exception.CreateFmt('Field %s must have a maximum value of %s.',
      [FParam.Name, FloatToStr(FParam.MaxValue)]);
end;

end.
