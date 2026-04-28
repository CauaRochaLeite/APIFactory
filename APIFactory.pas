unit Utils.API;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Net.HttpClient,
  System.Net.URLClient,
  System.Generics.Collections,
  REST.Json,
  System.JSON;

type
  IAuthProvider = interface
    ['{0400B6D5-BB00-41C1-90CF-9212C4DED675}']
    function GetToken: string;
    function RefreshToken: string;
  end;

  TAuthProvider = class(TInterfacedObject, IAuthProvider)
  private
    FToken: string;
  public
    constructor Create(const AToken: string);
    function GetToken: string;
    function RefreshToken: string;
  end;

  TApiResult = record
  private
    FJson: string;
  public
    class function FromJson(const AJson: string): TApiResult; static;

    function AsType<T: class, constructor>: T;
    function AsArray<T: class, constructor>: TArray<T>;
    function Raw: string;
  end;

  IApiClient = interface
    ['{7D236C6B-C5DE-457F-874D-BB22688C290B}']

    function BaseURL(const AValue: string): IApiClient;
    function Resource(const AValue: string): IApiClient;
    function Version(const AValue: string): IApiClient;

    function AddHeader(const AKey, AValue: string): IApiClient;
    function AddParam(const AKey, AValue: string): IApiClient;
    function AddBody(const AValue: string): IApiClient; overload;
    function AddBody(const AValue: TObject): IApiClient; overload;


    function AuthProvider(AProvider: IAuthProvider): IApiClient;
    function Timeout(const AMilliseconds: Integer): IApiClient;

    function Get: TApiResult;
    function Post: TApiResult;
    function Put: TApiResult;
    function Delete: TApiResult;
  end;

  TApiClient = class(TInterfacedObject, IApiClient)
  private
    FClient: THTTPClient;
    FBaseURL: string;
    FVersion: string;
    FResource: string;
    FHeaders: TDictionary<string, string>;
    FParams: TDictionary<string, string>;
    FBody: string;
    FAuthProvider: IAuthProvider;

    function BuildURL: string;
    function BuildHeaders: TNetHeaders;
    procedure ApplyAuth;
    procedure CheckResponse(const AResponse: IHTTPResponse);
  public
    constructor Create;
    destructor Destroy; override;

    function BaseURL(const AValue: string): IApiClient;
    function Resource(const AValue: string): IApiClient;
    function Version(const AValue: string): IApiClient;

    function AddHeader(const AKey, AValue: string): IApiClient;
    function AddParam(const AKey, AValue: string): IApiClient;
    function AddBody(const AValue: string): IApiClient; overload;
    function AddBody(const AValue: TObject): IApiClient; overload;

    function AuthProvider(AProvider: IAuthProvider): IApiClient;
    function Timeout(const AMilliseconds: Integer): IApiClient;

    function Get: TApiResult;
    function Post: TApiResult;
    function Put: TApiResult;
    function Delete: TApiResult;
  end;

  TApiFactory = class
  public
    class function New: IApiClient;
  end;

implementation



{ TApiResult }

class function TApiResult.FromJson(const AJson: string): TApiResult;
begin
  Result.FJson := AJson;
end;

function TApiResult.AsType<T>: T;
begin
  Result := TJson.JsonToObject<T>(FJson);
end;

function TApiResult.AsArray<T>: TArray<T>;
var
  lArray: TJSONArray;
  lI: Integer;
begin
  Result := nil;
  lArray := TJSONObject.ParseJSONValue(FJson) as TJSONArray;
  try
    if Assigned(lArray) then
    begin
      SetLength(Result, lArray.Count);
      for lI := 0 to lArray.Count - 1 do
      begin
        Result[lI] := TJson.JsonToObject<T>(lArray.Items[lI].ToJSON);
      end;
    end;
  finally
    lArray.Free;
  end;
end;

function TApiResult.Raw: string;
begin
  Result := FJson;
end;

{ TApiClient }

constructor TApiClient.Create;
begin
  FClient := THTTPClient.Create;
  FHeaders := TDictionary<string, string>.Create;
  FHeaders.Add('Content-Type', 'application/json');
  FHeaders.Add('Accept', 'application/json');
  FParams := TDictionary<string, string>.Create;
end;

destructor TApiClient.Destroy;
begin
  FClient.Free;
  FHeaders.Free;
  FParams.Free;
  inherited;
end;

function TApiClient.BaseURL(const AValue: string): IApiClient;
begin
  FBaseURL := AValue;
  Result := Self;
end;

function TApiClient.Version(const AValue: string): IApiClient;
begin
  FVersion := AValue;
  Result := Self;
end;

function TApiClient.Resource(const AValue: string): IApiClient;
begin
  FResource := AValue;
  Result := Self;
end;

function TApiClient.AddHeader(const AKey, AValue: string): IApiClient;
begin
  FHeaders.AddOrSetValue(AKey, AValue);
  Result := Self;
end;

function TApiClient.AddParam(const AKey, AValue: string): IApiClient;
begin
  FParams.AddOrSetValue(AKey, AValue);
  Result := Self;
end;

function TApiClient.AddBody(const AValue: string): IApiClient;
begin
  FBody := AValue;
  Result := Self;
end;

function TApiClient.AddBody(const AValue: TObject): IApiClient;
begin
  FBody := TJson.ObjectToJsonString(AValue);
  Result := Self;
end;

function TApiClient.AuthProvider(AProvider: IAuthProvider): IApiClient;
begin
  FAuthProvider := AProvider;
  Result := Self;
end;

function TApiClient.Timeout(const AMilliseconds: Integer): IApiClient;
begin
  FClient.ConnectionTimeout := AMilliseconds;
  FClient.ResponseTimeout := AMilliseconds;
  Result := Self;
end;

procedure TApiClient.ApplyAuth;
var
  lToken: string;
begin
  if Assigned(FAuthProvider) then
  begin
    lToken := FAuthProvider.GetToken;
    AddHeader('Authorization', 'Bearer ' + lToken);
  end;
end;

function TApiClient.BuildURL: string;
var
  Pair: TPair<string, string>;
  First: Boolean;
begin
  Result := FBaseURL;

  if FVersion <> '' then
    Result := Result + '/' + FVersion;

  Result := Result + FResource;

  if FParams.Count > 0 then
  begin
    Result := Result + '?';
    First := True;

    for Pair in FParams do
    begin
      if not First then
        Result := Result + '&';

      Result := Result + Pair.Key + '=' + Pair.Value;
      First := False;
    end;
  end;
end;

function TApiClient.BuildHeaders: TNetHeaders;
var
  Pair: TPair<string, string>;
  Index: Integer;
begin
  SetLength(Result, FHeaders.Count);
  Index := 0;

  for Pair in FHeaders do
  begin
    Result[Index].Name := Pair.Key;
    Result[Index].Value := Pair.Value;
    Inc(Index);
  end;
end;

procedure TApiClient.CheckResponse(const AResponse: IHTTPResponse);
begin
  if (AResponse.StatusCode < 200) or (AResponse.StatusCode >= 300) then
    raise Exception.CreateFmt(
      'Erro HTTP %d: %s',
      [AResponse.StatusCode, AResponse.ContentAsString]
    );
end;

function TApiClient.Get: TApiResult;
var
  Response: IHTTPResponse;
begin
  ApplyAuth;
  Response := FClient.Get(BuildURL, nil, BuildHeaders);
  CheckResponse(Response);
  Result := TApiResult.FromJson(Response.ContentAsString);
end;

function TApiClient.Post: TApiResult;
var
  Response: IHTTPResponse;
  Stream: TStringStream;
begin
  ApplyAuth;
  Stream := TStringStream.Create(FBody, TEncoding.UTF8);
  try
    Response := FClient.Post(BuildURL, Stream, nil, BuildHeaders);
    CheckResponse(Response);
    Result := TApiResult.FromJson(Response.ContentAsString);
  finally
    Stream.Free;
  end;
end;

function TApiClient.Put: TApiResult;
var
  Response: IHTTPResponse;
  Stream: TStringStream;
begin
  ApplyAuth;
  Stream := TStringStream.Create(FBody, TEncoding.UTF8);
  try
    Response := FClient.Put(BuildURL, Stream, nil, BuildHeaders);
    CheckResponse(Response);
    Result := TApiResult.FromJson(Response.ContentAsString);
  finally
    Stream.Free;
  end;
end;

function TApiClient.Delete: TApiResult;
var
  Response: IHTTPResponse;
begin
  ApplyAuth;
  Response := FClient.Delete(BuildURL, nil, BuildHeaders);
  CheckResponse(Response);
  Result := TApiResult.FromJson(Response.ContentAsString);
end;

{ Factory }

class function TApiFactory.New: IApiClient;
begin
  Result := TApiClient.Create;
end;

{ TAuthProvider }

constructor TAuthProvider.Create(const AToken: string);
begin
  FToken := AToken;
end;

function TAuthProvider.GetToken: string;
begin
  Result := FToken;
end;

function TAuthProvider.RefreshToken: string;
begin
  Result := FToken;
end;

end.
