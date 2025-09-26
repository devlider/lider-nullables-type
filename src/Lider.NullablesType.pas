unit Lider.NullablesType;

interface

uses
  System.SysUtils, System.Variants, System.Classes, System.Generics.Defaults, System.Rtti,
  System.TypInfo, System.JSON;

type
  ENullableException = class(Exception);

  TNullable<T> = record
  private
    FValue: T;
    FHasValue: string;
    procedure Clear;
    function GetValueType: PTypeInfo;
    function GetValue: T;
    procedure SetValue(const AValue: T);
    function GetHasValue: Boolean;
  public
    constructor Create(const Value: T); overload;
    constructor Create(const Value: Variant); overload;
    function Equals(const Value: TNullable<T>): Boolean; overload;
    function Equals(const Value: T): Boolean; overload;
    function GetValueOrDefault: T; overload;
    function GetValueOrDefault(const Default: T): T; overload;

    property HasValue: Boolean read GetHasValue;
    function IsNull: Boolean;

    property Value: T read GetValue;

    class operator Implicit(const Value: TNullable<T>): T;
    class operator Implicit(const Value: TNullable<T>): Variant;
    class operator Implicit(const Value: Pointer): TNullable<T>;
    class operator Implicit(const Value: T): TNullable<T>;
    class operator Implicit(const Value: Variant): TNullable<T>;
    class operator Implicit(const Value: TValue): TNullable<T>;
    class operator Equal(const Left, Right: TNullable<T>): Boolean; overload;
    class operator Equal(const Left: TNullable<T>; Right: T): Boolean; overload;
    class operator Equal(const Left: T; Right: TNullable<T>): Boolean; overload;
    class operator NotEqual(const Left, Right: TNullable<T>): Boolean; overload;
    class operator NotEqual(const Left: TNullable<T>; Right: T): Boolean; overload;
    class operator NotEqual(const Left: T; Right: TNullable<T>): Boolean; overload;
    class operator GreaterThan(const Left: TNullable<T>; Right: T): Boolean; overload;
    class operator LessThan(const Left: TNullable<T>; Right: T): Boolean; overload;
  end;

  NullString = TNullable<string>;
  NullBoolean = TNullable<Boolean>;
  NullInteger = TNullable<Integer>;
  NullInt64 = TNullable<Int64>;
  NullDouble = TNullable<Double>;
  NullDateTime = TNullable<TDateTime>;
  NullCurrency = TNullable<Currency>;

implementation

{ TNullable<T> }

constructor TNullable<T>.Create(const Value: T);
begin
  FValue := Value;
  FHasValue := DefaultTrueBoolStr;
end;

constructor TNullable<T>.Create(const Value: Variant);
begin
  if not VarIsNull(Value) and not VarIsEmpty(Value) then
    Create(TValue.FromVariant(Value).AsType<T>)
  else
    Clear;
end;

procedure TNullable<T>.Clear;
begin
  FValue := Default(T);
  FHasValue := '';
end;

class operator TNullable<T>.Equal(const Left: TNullable<T>; Right: T): Boolean;
begin
  Result := Left.Equals(Right);
end;

class operator TNullable<T>.Equal(const Left: T; Right: TNullable<T>): Boolean;
begin
  Result := Right.Equals(Left);
end;

function TNullable<T>.Equals(const Value: T): Boolean;
begin
  Result := HasValue and TEqualityComparer<T>.Default.Equals(Self.Value, Value)
end;

function TNullable<T>.Equals(const Value: TNullable<T>): Boolean;
begin
  if HasValue and Value.HasValue then
    Result := TEqualityComparer<T>.Default.Equals(Self.Value, Value.Value)
  else
    Result := HasValue = Value.HasValue;
end;

function TNullable<T>.GetHasValue: Boolean;
begin
  Result := FHasValue <> '';
end;

function TNullable<T>.GetValueType: PTypeInfo;
begin
  Result := TypeInfo(T);
end;

class operator TNullable<T>.GreaterThan(const Left: TNullable<T>; Right: T): Boolean;
begin
  Result := Left.HasValue and (TComparer<T>.Default.Compare(Left.Value, Right) > 0);
end;

function TNullable<T>.GetValue: T;
begin
  if not HasValue then
    raise ENullableException.Create('Nullable type has no value');
  Result := FValue;
end;

function TNullable<T>.GetValueOrDefault(const Default: T): T;
begin
  if HasValue then
    Result := FValue
  else
    Result := Default;
end;

function TNullable<T>.GetValueOrDefault: T;
begin
  Result := GetValueOrDefault(Default(T));
end;

class operator TNullable<T>.Implicit(const Value: TNullable<T>): T;
begin
  Result := Value.Value;
end;

class operator TNullable<T>.Implicit(const Value: TNullable<T>): Variant;
begin
  if Value.HasValue then
    Result := TValue.From<T>(Value.Value).AsVariant
  else
    Result := Null;
end;

class operator TNullable<T>.Implicit(const Value: Pointer): TNullable<T>;
begin
  if Value = nil then
    Result.Clear
  else
    Result := TNullable<T>.Create(T(Value^));
end;

class operator TNullable<T>.Implicit(const Value: T): TNullable<T>;
begin
  Result := TNullable<T>.Create(Value);
end;

class operator TNullable<T>.Implicit(const Value: Variant): TNullable<T>;
begin
  Result := TNullable<T>.Create(Value);
end;

function TNullable<T>.IsNull: Boolean;
begin
  Result := FHasValue = '';
end;

class operator TNullable<T>.LessThan(const Left: TNullable<T>; Right: T): Boolean;
begin
  Result := Left.HasValue and (TComparer<T>.Default.Compare(Left.Value, Right) < 0);
end;

class operator TNullable<T>.NotEqual(const Left: TNullable<T>; Right: T): Boolean;
begin
  Result := not Left.Equals(Right);
end;

class operator TNullable<T>.NotEqual(const Left: T; Right: TNullable<T>): Boolean;
begin
  Result := not Right.Equals(Left);
end;

class operator TNullable<T>.Equal(const Left, Right: TNullable<T>): Boolean;
begin
  Result := Left.Equals(Right);
end;

class operator TNullable<T>.NotEqual(const Left, Right: TNullable<T>): Boolean;
begin
  Result := not Left.Equals(Right);
end;

procedure TNullable<T>.SetValue(const AValue: T);
begin
  FValue := AValue;
  FHasValue := DefaultTrueBoolStr;
end;

class operator TNullable<T>.Implicit(const Value: TValue): TNullable<T>;
begin
  Result := TNullable<T>.Create(Value.AsType<T>);
end;

end.
