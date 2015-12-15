unit UnitDataModuleGeral;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, Data.DB,
  Datasnap.DBClient, DateUtils, System.UITypes, FMX.Forms, System.ImageList,
  FMX.ImgList, Data.FMTBcd, Data.SqlExpr, System.iOUtils, Data.DbxSqlite,
  Datasnap.Provider, IPPeerClient, REST.Client, Data.Bind.Components,
  Data.Bind.ObjectScope, DBXJSON, System.JSON, REST.Response.Adapter
  , FMX.Platform, System.Notification, System.Net.HTTPClient, REST.Exception
{$IFDEF Win32 or Win64}
, MidasLib;
{$ELSE}
;
{$ENDIF}

type
  IPaymentListener = interface
     procedure OnSucess;
     procedure OnError(Msg: String);
  end;

  TDataModuleGeral = class(TDataModule)
    CustomStyleBook: TStyleBook;
    ClientWebService: TRESTClient;
    RequestGetPayment: TRESTRequest;
    ResponseGetPayment: TRESTResponse;
    RequestPostPayment: TRESTRequest;
    ResponsePostPayment: TRESTResponse;
    RequestPostUser: TRESTRequest;
    ResponsePostUser: TRESTResponse;
    RequestPostCreditCard: TRESTRequest;
    ResponsePostCreditCard: TRESTResponse;
    RequestGetCreditCards: TRESTRequest;
    ResponseGetCreditCards: TRESTResponse;
    AdapterCreditCards: TRESTResponseDataSetAdapter;
    DataSetGetCreditCards: TClientDataSet;
    DataSetGetCreditCardsNumber: TStringField;
    DataSetGetCreditCardsMonthValidate: TIntegerField;
    DataSetGetCreditCardsYearValidate: TIntegerField;
    DataSetGetCreditCardsName: TStringField;
    DataSetGetCreditCardsFlag: TStringField;
    DataSetGetCreditCardsId: TIntegerField;
    DataSetGetCreditCardsStatus: TBooleanField;
    RequestGetUser: TRESTRequest;
    ResponseGetUser: TRESTResponse;
    RequestPostBuyCredits: TRESTRequest;
    ResponsePostBuyCredits: TRESTResponse;
    IconsGenericList: TImageList;
    RequestGetCreditsUser: TRESTRequest;
    ResponseGetCreditsUser: TRESTResponse;
    RequestGetTickets: TRESTRequest;
    ResponseGetTickets: TRESTResponse;
    AdapterTickets: TRESTResponseDataSetAdapter;
    DataSetGetTickets: TClientDataSet;
    DataSetProviderTickets: TDataSetProvider;
    DataSetTickets: TClientDataSet;
    DataSetGetTicketsPlate: TStringField;
    DataSetGetTicketsTime: TIntegerField;
    DataSetTicketsPlate: TStringField;
    DataSetTicketsTime: TIntegerField;
    DataSetTicketsDeadlineTime: TDateTimeField;
    DataSetTicketsIconIndex: TIntegerField;
    RequestPostPaymentByCredits: TRESTRequest;
    ResponsePostPaymentByCredits: TRESTResponse;
    DataSetProviderCreditCards: TDataSetProvider;
    DataSetCreditCards: TClientDataSet;
    DataSetCreditCardsFlag: TStringField;
    DataSetCreditCardsName: TStringField;
    DataSetCreditCardsNumber: TStringField;
    DataSetCreditCardsMonthValidate: TIntegerField;
    DataSetCreditCardsYearValidate: TIntegerField;
    DataSetCreditCardsStatus: TBooleanField;
    DataSetCreditCardsId: TIntegerField;
    DataSetCreditCardsIconIndex: TIntegerField;
    DataSetGetTicketsStartTime: TStringField;
    DataSetTicketsStartTime: TStringField;
    RequestGetPrice: TRESTRequest;
    ResponseGetPrice: TRESTResponse;
    AdapterPrice: TRESTResponseDataSetAdapter;
    DataSetPrice: TClientDataSet;
    DataSetPriceMinTime: TIntegerField;
    DataSetPriceMaxTime: TIntegerField;
    DataSetPriceUnitTime: TIntegerField;
    DataSetPricePriceTime: TStringField;
    DataSetPriceDiscountPrice: TStringField;
    RequestRedefinePassword: TRESTRequest;
    ResponseRedefinePassword: TRESTResponse;
    procedure DataSetTicketsCalcFields(DataSet: TDataSet);
    procedure DataSetCreditCardsCalcFields(DataSet: TDataSet);
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    var
    CreditsAvailableUser: Double;
    NotificationCenter: TNotificationCenter;
    
    function PostPayment(Plate: String;
                          Time: Integer;
                          FlagCreditCard: String;
                          NameCreditCard: String;
                          NumberCreditCard: String;
                          MonthCreditCard: Integer;
                          YearCreditCard: Integer;
                          CSCCredCard: Integer): TDateTime;

    function PostPaymentByCredits(IdUser: Integer;
                                  Plate: String;
                                  Time: Integer): TDateTime;

    function PostUser(Id: Integer; Nickname, Email, CPF, Password: String): Integer;

    function PostCreditCard(IdUser,Id: Integer; Flag, Name, Number: String; MonthValidate, YearValidate: Integer; Status: Boolean): Integer;

    function GetUser(CPF, Password: String): TJSONObject;

    procedure PostBuyCredits(IdUser, IdCreditCard, CSCCreditCard: Integer; Value: Double);

    procedure CreateNotification(Name, AlertBody: String; DateTime: TDateTime);

    procedure CreateTicketNotification(Plate: String; StartTime: TDateTime; Time: Integer);

    procedure CatchRestException(E : Exception);
  public
    { Public declarations }

    function ConsultPayment(Plate: String; var DayTime, DeadlineTime: TDateTime): Boolean;

    procedure SendPayment(Plate: String; Time: Integer; PaymentListener: IPaymentListener);

    procedure SendPaymentSeparate(Plate: String; Time: Integer; PaymentListener: IPaymentListener);

    procedure SendPaymentByCredits(Plate: String; Time: Integer; PaymentListener: IPaymentListener);

    procedure SendUser(Nickname, Email, CPF, Password: String);

    procedure SendCreditCard(Id: Integer; Flag, Name, Number: String; MonthValidate, YearValidate: Integer; Status: Boolean);

    procedure Login(CPF, Password: String);

    procedure SendBuyCredits(IdCreditCard, CSCCreditCard: Integer; Value: Double);

    procedure SendRedefinePassword(CPF: String);

    procedure OpenQueryCreditCards;

    procedure OpenQueryCreditsUser;

    procedure OpenQueryTicketsUser;

    procedure OpenQueryPrice;

    function IsUserLogged: Boolean;

    function GetCreditsUser: Double;

    function GetMaxTime: Integer;

    function GetMinTime: Integer;

    function GetUnitTime: Integer;

    function GetPriceTime: Double;

    function GetDiscountPrice: Double;

    function GetLastPlate: String;

    function GetNameCreditCardSelected: String;
    function GetNumberCreditCardSelected: String;
    function GetFlagCreditCardSelected: String;
    function GetMonthCreditCardSelected: Integer;
    function GetYearCreditCardSelected: Integer;
    function GetIdCreditCardSelected: Integer;
  end;

var
  DataModuleGeral: TDataModuleGeral;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses UnitCreditCardSeparate, UnitBuyCredits, UnitTickets, UnitDataModuleLocal,
  UnitRoutines;

{$R *.dfm}

function TDataModuleGeral.GetDiscountPrice: Double;
begin
  Result := StrToFloatDef(DataSetPriceDiscountPrice.AsString.Replace('.',','), 0);
end;

function TDataModuleGeral.GetFlagCreditCardSelected: String;
begin
  Result := DataSetCreditCards.FieldByName('Flag').AsString;
end;

function TDataModuleGeral.GetIdCreditCardSelected: Integer;
begin
  Result := DataSetCreditCards.FieldByName('Id').AsInteger;
end;

function TDataModuleGeral.GetLastPlate: String;
begin
  //Verifica se existe um usu�rio logado.
  if (IsUserLogged) then
  begin
    //Carrega da lista de t�quetes do usu�rio logado a �ltima placa usada.
    DataSetTickets.First;
    Result := DataSetTicketsPlate.AsString;
  end
  else
  begin
    //Carrega da base local a �ltima placa usada.
    Result := DataModuleLocal.DataSetTickets.FieldByName('Plate').AsString;
  end;
end;

procedure TDataModuleGeral.CatchRestException(E: Exception);
begin
  TThread.Synchronize(nil
   ,procedure
    begin
      if (E is ENetHTTPClientException) then
        raise ENetHTTPClientException.Create('N�o foi poss�vel conectar com o servidor'
                                             +#13+'Verifique a sua Internet.')
      else if (E is ERESTException) then
        raise ENetHTTPClientException.Create('N�o foi poss�vel conectar com o servidor'
                                             +#13+'Verifique a sua Internet.')
      else
        raise Exception.Create(E.Message);
    end);
end;

function TDataModuleGeral.ConsultPayment(Plate: String; var DayTime, DeadlineTime: TDateTime): Boolean;
var
Json: TJSONObject;
Error: String;
begin
  try
    //Consulta no servidor o pagamento do estacionamento referente � placa passada como argumento.
    RequestGetPayment.Params.ParameterByName('json').Value := '{"Plate":"'+Plate+'"}';
    RequestGetPayment.Execute;

    //Pega o registro JSON retornado pela consulta.
    Json := (TJSONObject.ParseJSONValue(RequestGetPayment.Response.Content) as TJSONObject);

    //Se o json n�o tiver um par de chave "error", significa que a consulta foi realizada com sucesso.
    if (Json.Values['Error'] = nil) then
    begin
      //Pega a data de in�cio e a data de limite do pagamento retornado pelo webservice.
      DayTime      := StrToDateTimeFromWebService(Json.GetValue('DateBegin').Value);
      DeadlineTime := StrToDateTimeFromWebService(Json.GetValue('DeadlineTime').Value);

      //Retorna como resultado o valor true.
      Result := True;
    end
    else
    begin
      //Verifica se a mensagem retornada � "sem pagamento".
      Error := Json.GetValue('Error').Value;
      if (Error.Contains('Veiculo nao estacionado')) then
      begin
        //Retorna como resultado falso.
        Result := False;
      end
      else
      begin
        //Neste caso, levanta uma exce��o com a mensagem do erro.
        raise Exception.Create(Error);
      end;
    end;
  except
    //Trata a exce��o levantada.
    on E: Exception do
      CatchRestException(E);
  end;
end;

procedure TDataModuleGeral.CreateNotification(Name, AlertBody: String; DateTime: TDateTime);
var
Notification: TNotification;
begin
  try
    //Cria uma notifica��o para indicar ao usu�rio o t�rmino do t�quete adquirido.
    Notification := NotificationCenter.CreateNotification;
    Notification.Name := Name;
    Notification.AlertBody := AlertBody;
    Notification.FireDate  := DateTime;
    NotificationCenter.ScheduleNotification(Notification);
  finally
    Notification.DisposeOf;
  end;
end;

procedure TDataModuleGeral.CreateTicketNotification(Plate: String;
  StartTime: TDateTime; Time: Integer);
begin
  //Cria duas notifica��es que ser�o exibidas antes de 10 e 5 minutos
  //do tempo limite do t�quete.
  CreateNotification(Plate+'10'
                    ,'Faltam menos de 10 minutos para seu t�quete acabar'
                    ,IncMinute(StartTime, Time - 10));

  CreateNotification(Plate+'5'
                    ,'Faltam menos de 5 minutos para seu t�quete acabar'
                    ,IncMinute(StartTime, Time - 5));
end;

procedure TDataModuleGeral.DataModuleCreate(Sender: TObject);
begin
  //Instancia um objeto de gerenciamento de notifica��es.
  NotificationCenter := TNotificationCenter.Create(Self);
end;

procedure TDataModuleGeral.DataSetCreditCardsCalcFields(DataSet: TDataSet);
begin
  //Verifica se o estado do DataSet de cart�es � para calculo de atributos internos(locais).
  if (DataSetCreditCards.State = dsInternalCalc) then
  begin
    //Verifica qual a bandeira do cart�o de cr�dito.
    if (DataSetCreditCardsFlag.AsString.Equals('VISA')) then
    begin
      //Se for Visa, ent�o o indice do �cone � zero (0).
      DataSetCreditCardsIconIndex.AsInteger := 0;
    end
    else
    begin
      //Nesse caso o cart�o � da bandeira Mastercard, indice um (1).
      DataSetCreditCardsIconIndex.AsInteger := 1;
    end;
  end;
end;

procedure TDataModuleGeral.DataSetTicketsCalcFields(DataSet: TDataSet);
begin
  //Verifica se o estado do DataSet de tickets � para c�lculos de atributos(Fields) internos.
  if (DataSetTickets.State = dsInternalCalc) then
  begin
    //Calcula o tempo de limite.
    DataSetTicketsDeadlineTime.AsDateTime := IncMinute(StrToDateTimeFromWebService(DataSetTicketsStartTime.AsString), DataSetTicketsTime.AsInteger);

    //Verifica se o t�quete ainda est� ativo de acordo com o seu tempo de limite.
    if (DataSetTicketsDeadlineTime.AsDateTime < now()) then
    begin
      //Atribui como estado do objeto o �cone Inativo.
      DataSetTicketsIconIndex.AsInteger := 0;
    end
    else
    begin
      //Atribui como estado do objeto o �cone Ativo.
      DataSetTicketsIconIndex.AsInteger := 1;
    end;
  end;
end;

function TDataModuleGeral.GetCreditsUser: Double;
begin
  //Retorna o valor de cr�ditos do usu�rio logado.
  Result := CreditsAvailableUser;
end;

function TDataModuleGeral.IsUserLogged: Boolean;
begin
  //Se a consulta do usu�rio na base local n�o for vazia, significa que existe um usu�rio logado.
  Result := not (DataModuleLocal.DataSetUser.IsEmpty);
end;

procedure TDataModuleGeral.Login(CPF, Password: String);
var
JsonUser: TJSONObject;
begin
  //Envia a requisi��o GET do usu�rio para o webservice.
  JsonUser := GetUser(CPF, Password);

  //Salva as informa��es do usu�rio logando.
  DataModuleLocal.InsertUser(StrToInt(JsonUser.GetValue('Id').Value)
                            , JsonUser.GetValue('Nickname').Value
                            , JsonUser.GetValue('Email').Value
                            , CPF
                            , Password);
end;

procedure TDataModuleGeral.OpenQueryCreditCards;
begin
  try
    //Envia a requisi��o GET de consulta de cart�es de cr�ditos.
    RequestGetCreditCards.ClearBody;
    RequestGetCreditCards.Params.ParameterByName('json').Value := '{"IdUser":'+IntToStr(DataModuleLocal.GetIdUser)+'}';
    RequestGetCreditCards.Execute;

    //Abre a consulta do objeto DataSetCreditCards associado ao cojunto de cart�es consultados.
    DataSetCreditCards.Close;
    DataSetCreditCards.Open;
  except
    //Trata a exce��o levantada.
    on E: Exception do
      CatchRestException(E);
  end;
end;

procedure TDataModuleGeral.OpenQueryCreditsUser;
var
JsonResponse: TJSONObject;
begin
  try
    //Envia a requisi��o GET de consulta dos cr�ditos do usu�rio logado.
    RequestGetCreditsUser.ClearBody;
    RequestGetCreditsUser.Params.ParameterByName('json').Value := '{"IdUser": '+IntToStr(DataModuleLocal.GetIdUser)+'}';
    RequestGetCreditsUser.Execute;

    //Pega o JSON retornado pela resposta.
    JsonResponse := (TJSONObject.ParseJSONValue(ResponseGetCreditsUser.Content) as TJSONObject);

    //Verifica se houve sucesso, ou seja, n�o houve erro.
    if (JsonResponse.Values['Error'] = nil) then
    begin
      //Atualiza o atributo que guarda o valor de cr�ditos do usu�rio logado.
      CreditsAvailableUser := StrToFloat(JsonResponse.GetValue('Value').Value.Replace('.',','));
    end
    else
    begin
      //Zera o valor do atributo referente aos cr�ditos.
      CreditsAvailableUser := 0;

      //Levanta uma exce��o com a mensagem do erro.
      raise Exception.Create(JsonResponse.GetValue('Error').Value);
    end;
  except
    //Trata a exce��o levantada.
    on E: Exception do
      CatchRestException(E);
  end;
end;

procedure TDataModuleGeral.OpenQueryPrice;
var
Json: TJSONObject;
begin
  try
    //Remove a liga��o do adapter e a o objeto ResponseGetPrice.
    //S� ser�o ligados novamente se n�o ocorrer erros.
    AdapterPrice.Response := nil;

    //Envia a requisi��o Get para o webservice.
    RequestGetPrice.Params.ParameterByName('json').Value := '{"IdUser": "'+IntToStr(DataModuleLocal.GetIdUser)+'"}';
    RequestGetPrice.Execute;

    //Pega o JSON retornado na resposta da requisi��o.
    Json := (TJSONObject.ParseJSONValue(ResponseGetPrice.Content) as TJSONObject);

    //Verifica se n�o ocorreu erro.
    if (Json.Values['Error'] = nil) then
    begin
      //Faz a liga��o do adapter com os dados retornado na resposta.
      AdapterPrice.Response := ResponseGetPrice;
    end
    else
    begin
      //Levanta uma exce��o com a mensagem do erro retornado pelo webservice.
      raise Exception.Create(Json.GetValue('Error').Value);
    end;
  except
    //Trata a exce��o levantada.
    on E: Exception do
      CatchRestException(E);
  end;
end;

procedure TDataModuleGeral.OpenQueryTicketsUser;
var
JsonResponse: TJSONObject;
begin
  try
    //Remove a liga��o do Adapter e do Response, pois somente ser�o ligados
    //se ocorrer sucesso na consulta.
    AdapterTickets.Response := Nil;

    //Envia a requisi��o GET da consulta dos t�quetes do usu�rio logado.
    RequestGetTickets.ClearBody;
    RequestGetTickets.Params.ParameterByName('json').Value := '{"IdUser": '+IntToStr(DataModuleLocal.GetIdUser())+'}';
    RequestGetTickets.Execute;

    //Verifica se na resposta N�O existe a palavra "Error", significando sucesso na consulta.
    if not(ResponseGetTickets.Content.Contains('"Error"')) then
    begin
      //Realiza a liga��o do AdapterTickets com o objeto ResponseGetTickets.
      //Com isso, os t�quetes retornados no JSONArray pelo WebService estar�o
      //dispon�veis no objeto DataSetTickets.
      AdapterTickets.Response := ResponseGetTickets;
    end
    else
    begin
      //Pega o JSON com a resposta.
      JsonResponse := (TJSONObject.ParseJSONValue(ResponseGetTickets.Content) as TJSONObject);

      //Levanta uma exce��o com o erro retornado na resposta.
      raise Exception.Create(JsonResponse.GetValue('Error').Value);
    end;

    //Abre a consulta do objeto DataSetTickets relacionado ao conjunto de t�quetes consultados no WebService.
    DataSetTickets.Close;
    DataSetTickets.Open;
  except
    //Trata a exce��o.
    on E: Exception do
      CatchRestException(E);
  end;
end;

function TDataModuleGeral.GetMaxTime: Integer;
begin
  Result := DataSetPriceMaxTime.AsInteger;
end;

function TDataModuleGeral.GetMinTime: Integer;
begin
  Result := DataSetPriceMinTime.AsInteger;
end;

function TDataModuleGeral.GetMonthCreditCardSelected: Integer;
begin
  Result := DataSetCreditCards.FieldByName('MonthValidate').AsInteger;
end;

function TDataModuleGeral.GetNameCreditCardSelected: String;
begin
  Result := DataSetCreditCards.FieldByName('Name').AsString;
end;

function TDataModuleGeral.GetNumberCreditCardSelected: String;
begin
  Result := DataSetCreditCards.FieldByName('Number').AsString;
end;

function TDataModuleGeral.GetPriceTime: Double;
begin
  Result := StrToFloatDef(DataSetPricePriceTime.AsString.Replace('.',','), 0);
end;

procedure TDataModuleGeral.PostBuyCredits(IdUser, IdCreditCard,
  CSCCreditCard: Integer; Value: Double);
var
Json, JsonResponse: TJSONObject;
begin
  try
    //Envia a requisi��o do POST com a compra de cr�ditos.
    Json := TJSONObject.Create;
    Json.AddPair('IdUser', TJSONNumber.Create(IdUser));
    Json.AddPair('IdCreditCard', TJSONNumber.Create(IdCreditCard));
    Json.AddPair('CSC', TJSONNumber.Create(CSCCreditCard));
    Json.AddPair('Value', TJSONString.Create(FloatToStr(Value).Replace(',','.')));
    RequestPostBuyCredits.Params.ParameterByName('json').Value := Json.ToString;
    RequestPostBuyCredits.Execute;

    //Pega o JSON retornado pela resposta.
    JsonResponse := (TJSONObject.ParseJSONValue(ResponsePostBuyCredits.Content) as TJSONObject);

    //Verifica se ocorreu algum erro na compra de cr�dito.
    if (JsonResponse.Values['Error'] <> nil) then
    begin
      //Levanta uma exce��o contendo a mensagem do erro.
      raise Exception.Create(JsonResponse.GetValue('Error').Value);
    end;
  except
    //Trata a exce��o levantada.
    on E: Exception do
      CatchRestException(E);
  end;
end;

function TDataModuleGeral.PostCreditCard(IdUser, Id: Integer; Flag, Name, Number: String;
  MonthValidate, YearValidate: Integer; Status: Boolean): Integer;
var
Json, JsonResponse: TJSONObject;
begin
  try
    //Constroi o JSON a ser enviado na requisi��o POST.
    Json := TJSONObject.Create;
    Json.AddPair('IdUser', TJSONNumber.Create(IdUser));
    Json.AddPair('Id', TJSONNumber.Create(Id));
    Json.AddPair('Flag', TJSONString.Create(Flag));
    Json.AddPair('Name', TJSONString.Create(Name));
    Json.AddPair('Number', TJSONString.Create(Number));
    Json.AddPair('MonthValidate', TJSONNumber.Create(MonthValidate));
    Json.AddPair('YearValidate', TJSONNumber.Create(YearValidate));
    Json.AddPair('Status', TJSONBool.Create(Status));

    //Envia a requisi��o POST com o cadastro do cart�o.
    RequestPostCreditCard.Params.ParameterByName('json').Value := Json.ToString;
    RequestPostCreditCard.Execute;

    //Pega o json contendo a resposta do servidor.
    JsonResponse := (TJSONObject.ParseJSONValue(ResponsePostCreditCard.Content) as TJSONObject);

    //Verifica se o json com a resposta cont�m o par de chave Id, significando sucesso.
    if (JsonResponse.Values['Id'] <> nil) then
    begin
      //Atribui a resposta o Id retornado pelo webservice.
      Result := StrToInt(JsonResponse.GetValue('Id').Value);
    end
    else
    begin
      //Levanta uma exce��o com o erro retornado pelo webservice.
      raise Exception.Create(JsonResponse.GetValue('Error').Value);
    end;
  except
    //Trata a exce��o levantada.
    on E: Exception do
      CatchRestException(E);
  end;
end;

function TDataModuleGeral.PostPayment(Plate: String;
  Time: Integer; FlagCreditCard, NameCreditCard,
  NumberCreditCard: String; MonthCreditCard, YearCreditCard,
  CSCCredCard: Integer): TDateTime;
var
Json: TJSONObject;
JsonResponse: TJSONObject;
begin
  try
    //Constroi o JSON contendo os par�metros para serem enviados ao webservice.
    Json := TJSONObject.Create;
    Json.AddPair('Plate', TJSONString.Create(Plate));
    Json.AddPair('Time', TJSONNumber.Create(Time));
    Json.AddPair('FlagCreditCard', TJSONString.Create(FlagCreditCard));
    Json.AddPair('NameCreditCard', TJSONString.Create(NameCreditCard));
    Json.AddPair('NumberCreditCard', TJSONString.Create(NumberCreditCard));
    Json.AddPair('MonthCreditCard', TJSONNumber.Create(MonthCreditCard));
    Json.AddPair('YearCreditCard', TJSONNumber.Create(YearCreditCard));
    Json.AddPair('CSCCredCard', TJSONNumber.Create(CSCCredCard));

    //Envia a requisi��o POST para o pagamento.
    RequestPostPayment.Params.ParameterByName('json').Value := Json.ToString;
    RequestPostPayment.Execute;

    //Pega a resposta do webservice.
    JsonResponse := (TJSONObject.ParseJSONValue(RequestPostPayment.Response.Content) as TJSONObject);

    //Se o json com a resposta cont�m o par de chave "Sucess", significa que o pagamento foi realizado com sucesso.
    if (JsonResponse.Values['Sucess'] <> nil) then
    begin
      //Retorna a data do t�quete atribu�da pelo servidor.
      Result := StrToDateTimeFromWebService(JsonResponse.GetValue('Sucess').Value);
    end
    else
    begin
      //Levanta uma exce��o com o erro retornado na resposta do webservice.
      raise Exception.Create(JsonResponse.GetValue('Error').Value);
    end;
  except
    //Trata a exce��o levantada.
    on E: Exception do
      CatchRestException(E);
  end;
end;

function TDataModuleGeral.PostPaymentByCredits(IdUser: Integer; Plate: String;
  Time: Integer): TDateTime;
var
Json, JsonResponse: TJSONObject;
begin
  try
    //Envia a requisi��o POST do pagamento para o WebService.
    Json := TJSONObject.Create;
    Json.AddPair('IdUser', TJSONNumber.Create(IdUser));
    Json.AddPair('Plate', TJSONString.Create(Plate));
    Json.AddPair('Time', TJSONNumber.Create(Time));
    RequestPostPaymentByCredits.Params.ParameterByName('json').Value := Json.ToString;
    RequestPostPaymentByCredits.Execute;

    //Pega o JSON retornado pela resposta.
    JsonResponse := (TJSONObject.ParseJSONValue(ResponsePostPaymentByCredits.Content) as TJSONObject);

    //Verifica se o pagamento foi realizado com sucesso.
    if (JsonResponse.Values['Sucess'] <> nil) then
    begin
      //Retorna a data e hora de limite do estacionamento pago.
      Result := StrToDateTimeFromWebService(JsonResponse.GetValue('Sucess').Value);
    end
    else
    begin
      //Levanta uma exce��o com o erro retornado na resposta.
      raise Exception.Create(JsonResponse.GetValue('Error').Value);
    end;
  except
    //Trata a exce��o levantada.
    on E: Exception do
      CatchRestException(E);
  end;
end;

function TDataModuleGeral.PostUser(Id: Integer; Nickname, Email, CPF,
  Password: String): Integer;
var
Json, JsonResponse: TJSONObject;
begin
  try
    //Constroi o JSON do usu�rio que vai ser enviado ao webservice.
    Json := TJSONObject.Create;
    Json.AddPair('Id', TJSONNumber.Create(Id));
    Json.AddPair('Nickname', TJSONString.Create(Nickname));
    Json.AddPair('Email', TJSONString.Create(Email));
    Json.AddPair('CPF', TJSONString.Create(CPF));
    Json.AddPair('Password', TJSONString.Create(Password));

    //Envia a requisi��o POST contendo o JSON do usu�rio.
    RequestPostUser.Params.ParameterByName('json').Value := Json.ToString;
    RequestPostUser.Execute;

    //Pega o JSON contendo a resposta da requisi��o POST.
    JsonResponse := (TJSONObject.ParseJSONValue(ResponsePostUser.Content) as TJSONObject);

    //Verifica se o JSON objeto cont�m o par de chave Id, significando que houve sucesso.
    if (JsonResponse.Values['Id'] <> nil) then
    begin
      //Atribui ao resultado o Id recebido como resposta.
      Result := StrToInt(JsonResponse.GetValue('Id').Value);
    end
    else
    begin
      //Levanta uma exce��o com o erro retornado pelo webservice.
      raise Exception.Create(JsonResponse.GetValue('Error').Value);
    end;
  except
    //Trata a exce��o levantada.
    on E: Exception do
      CatchRestException(E);
  end;
end;

procedure TDataModuleGeral.SendBuyCredits(IdCreditCard, CSCCreditCard: Integer;
  Value: Double);
begin
  //Envia a requisi��o POST da compra de cr�ditos para o usu�rio logado.
  PostBuyCredits(DataModuleLocal.GetIdUser, IdCreditCard, CSCCreditCard, Value);
end;

procedure TDataModuleGeral.SendCreditCard(Id: Integer; Flag, Name, Number: String;
  MonthValidate, YearValidate: Integer; Status: Boolean);
begin
  //Envia a requisi��o POST com os dados do cart�o de cr�dito para o WebService.
  Id:= PostCreditCard(DataModuleLocal.GetIdUser
                    ,Id
                    ,Flag
                    ,Name
                    ,Number
                    ,MonthValidate
                    ,YearValidate
                    ,Status);

  //Atualiza a consulta de cart�es de cr�dito.
  OpenQueryCreditCards;
end;

procedure TDataModuleGeral.SendPayment(Plate: String; Time: Integer; PaymentListener: IPaymentListener);
begin
  //Verifica se n�o existe usu�rio logado. Ou seja, pagamento avulso.
  if not(IsUserLogged) then
  begin
    //Chama o procedimento de pagamento de t�quete avulso.
    SendPaymentSeparate(Plate, Time, PaymentListener);
  end
  else
  begin
    //Chama o procedimento de pagamento que utiliza os cr�ditos j� adquiridos pelo usu�rio.
    SendPaymentByCredits(Plate, Time, PaymentListener);
  end;
end;

procedure TDataModuleGeral.SendPaymentByCredits(Plate: String; Time: Integer;
  PaymentListener: IPaymentListener);
var
DeadlineTime: TDateTime;
begin
  try
    //Envia a requisi��o POST de pagamento ao WebService.
    DeadlineTime := PostPaymentByCredits(DataModuleLocal.GetIdUser
                                        ,Plate
                                        ,Time);

    //Cria a notifica��o para indicar o t�rmino do t�quete adquirido pelo usu�rio logado.
    CreateTicketNotification(Plate, IncMinute(DeadlineTime, -Time), Time);


    //Executa o procedimento de sucesso do objeto ouvinte de eventos de pagamento.
    PaymentListener.OnSucess;
  except
    on Error: Exception do
    begin
      //Executa o procedimento de erro do objeto ouvinte de eventos de pagamento.
      PaymentListener.OnError(Error.Message);
    end;
  end;
end;

procedure TDataModuleGeral.SendPaymentSeparate(Plate: String; Time: Integer;
  PaymentListener: IPaymentListener);
var
StartTime: TDateTime;
begin
  //Exibe o formul�rio de cart�o de cr�dito avulso.
  FormCreditCardSeparate := TFormCreditCardSeparate.Create(Self
        ,procedure
         begin
          //Executa o envio da requisi��o de pagamento de t�quete em uma Thread paralela.
          UnitRoutines.ExecuteAsync(FormCreditCardSeparate.GetLayoutPrincipal
             ,procedure
              begin
                try
                  try
                    //Envia ao servidor a requisi��o HTTP Post do pagamento.
                    StartTime:= PostPayment(
                                    Plate
                                   ,Time
                                   ,FormCreditCardSeparate.GetFlag()
                                   ,FormCreditCardSeparate.GetName()
                                   ,FormCreditCardSeparate.GetNumber()
                                   ,FormCreditCardSeparate.GetMonth()
                                   ,FormCreditCardSeparate.GetYear()
                                   ,FormCreditCardSeparate.GetCSC()
                                );

                    //Insere o novo t�quete na base local.
                    DataModuleLocal.InsertTicket(Plate, StartTime, Time);

                    //Cria a notifica��o para indicar o t�rmino do t�quete adquirido.
                    CreateTicketNotification(Plate, StartTime, Time);

                    //Chama o procedimento do ouvinte de pagamento.
                    PaymentListener.OnSucess;
                  except
                    on Error: Exception do
                    begin
                      //Executa o procedimento de erro do objeto ouvinte de pagamento.
                      PaymentListener.OnError(Error.Message);
                    end;
                  end;
                finally
                  //Fecha e desaloca da mem�rio o formul�rio de cart�o avulso.
                  FormCreditCardSeparate.Close;
                  FormCreditCardSeparate.Release;
                end;
              end);
         end);

  //Exibe o formul�rio de cart�o avulso.
  Show(FormCreditCardSeparate);
end;

procedure TDataModuleGeral.SendRedefinePassword(CPF: String);
var
JsonResponse: TJSONObject;
Content: String;
Index : Integer;
begin
  try
    //Envia a requisi��o para redefini��o de senha para o webservice.
    RequestRedefinePassword.Params.ParameterByName('json').Value := '{"CPF": "'+CPF+'"}';
    RequestRedefinePassword.Execute;

    //Pega o json retornado na resposta do WebService.
    Content      := ResponseRedefinePassword.Content;
    Index        := Pos('{"', Content);
    Content      := Copy(Content, Index, Content.Length - Index + 1);
    JsonResponse := (TJSONObject.ParseJSONValue(Content) as TJSONObject);

    //Verifica se a redefini��o de senha teve algum erro.
    if (JsonResponse.Values['Error'] <> nil) then
    begin
      //Levanta uma exce��o com a mensagem de erro retornada na resposta.
      raise Exception.Create(JsonResponse.GetValue('Error').Value);
    end;
  except
    //Trata a exce��o levantada.
    on E: Exception do
      CatchRestException(E);
  end;
end;

procedure TDataModuleGeral.SendUser(Nickname, Email, CPF, Password: String);
var
Id: Integer;
begin
  //Envia o cadastro do usu�rio para o webservidor.
  Id := PostUser(DataModuleLocal.DataSetUser.FieldByName('Id').AsInteger
                ,Nickname
                ,Email
                ,CPF
                ,Password);

  //Armazena na base local as altera��es do usu�rio.
  DataModuleLocal.InsertUser(Id, Nickname, Email, CPF, Password);
end;

function TDataModuleGeral.GetUnitTime: Integer;
begin
  Result := DataSetPriceUnitTime.AsInteger;
end;

function TDataModuleGeral.GetUser(CPF, Password: String): TJSONObject;
var
Json, JsonResponse: TJSONObject;
begin
  try
    //Envia a requisi��o GET para consultar o usu�rio atrav�s do seu CPF e senha.
    Json := TJSONObject.Create;
    Json.AddPair('CPF', TJSONString.Create(CPF));
    Json.AddPair('Password', TJSONString.Create(Password));
    RequestGetUser.Params.ParameterByName('json').Value := Json.ToString;
    RequestGetUser.Execute;

    //Pega o JSON retornado pela resposta.
    JsonResponse := (TJSONObject.ParseJSONValue(ResponseGetUser.Content) as TJSONObject);

    //Verifica se ocorreu sucesso, ou seja, n�o ocorreu erro.
    if (JsonResponse.Values['Error'] = nil) then
    begin
      //Retorna o JSON contendo o usu�rio consultado.
      Result := JsonResponse;
    end
    else
    begin
      //Levanta uma exce��o com a mensagem do erro.
      raise Exception.Create(JsonResponse.GetValue('Error').Value);
    end;
  except
    //Trata a exce��o levantada.
    on E: Exception do
      CatchRestException(E);
  end;
end;

function TDataModuleGeral.GetYearCreditCardSelected: Integer;
begin
  Result := DataSetCreditCards.FieldByName('YearValidate').AsInteger;
end;

end.

