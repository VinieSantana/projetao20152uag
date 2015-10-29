unit UnitDataModuleGeral;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, Data.DB,
  Datasnap.DBClient, DateUtils, System.UITypes, FMX.Forms, System.ImageList,
  FMX.ImgList, Data.FMTBcd, Data.SqlExpr, System.iOUtils, Data.DbxSqlite,
  Datasnap.Provider, IPPeerClient, REST.Client, Data.Bind.Components,
  Data.Bind.ObjectScope, DBXJSON, System.JSON, REST.Response.Adapter
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
    DataSetCreditCards: TClientDataSet;
    DataSetCreditCardsNumber: TStringField;
    DataSetCreditCardsMonthValidate: TIntegerField;
    DataSetCreditCardsYearValidate: TIntegerField;
    DataSetCreditCardsName: TStringField;
    DataSetCreditCardsFlag: TStringField;
    DataSetCreditCardsId: TIntegerField;
    DataSetCreditCardsStatus: TBooleanField;
  private
    { Private declarations }
    function PostPayment(Plate: String;
                          Time: Integer;
                          FlagCreditCard: String;
                          NameCreditCard: String;
                          NumberCreditCard: String;
                          MonthCreditCard: Integer;
                          YearCreditCard: Integer;
                          CSCCredCard: Integer): TDateTime;

    function PostUser(Id: Integer; Nickname, Email, CPF, Password: String): Integer;

    function PostCreditCard(IdUser,Id: Integer; Flag, Name, Number: String; MonthValidate, YearValidate: Integer; Status: Boolean): Integer;
  public
    { Public declarations }

    function ConsultPayment(Plate: String; var DayTime, DeadlineTime: TDateTime): Boolean;

    procedure SendPayment(Plate: String; Time: Integer; PaymentListener: IPaymentListener);

    procedure SendPaymentSeparate(Plate: String; Time: Integer; PaymentListener: IPaymentListener);

    procedure SendPaymentByCredit(Plate: String; Time: Integer; PaymentListener: IPaymentListener);

    procedure SendUser(Nickname, Email, CPF, Password: String);

    procedure SendCreditCard(Id: Integer; Flag, Name, Number: String; MonthValidate, YearValidate: Integer; Status: Boolean);

    procedure OpenQueryCreditCards;

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
  Result := 0;
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
  //Carrega da base local a �ltima placa usada.
  Result := DataModuleLocal.DataSetTickets.FieldByName('Plate').AsString;
end;

function TDataModuleGeral.ConsultPayment(Plate: String; var DayTime, DeadlineTime: TDateTime): Boolean;
var
Json: TJSONObject;
Error: String;
begin
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
end;

function TDataModuleGeral.GetCreditsUser: Double;
begin
  //Retorna valor default para os testes. N�o est� implementado o cadastro do usu�rio.
  Result := 0;
end;

function TDataModuleGeral.IsUserLogged: Boolean;
begin
  //Se a consulta do usu�rio na base local n�o for vazia, significa que existe um usu�rio logado.
  Result := not (DataModuleLocal.DataSetUser.IsEmpty);
end;

procedure TDataModuleGeral.OpenQueryCreditCards;
begin
  //Envia a requisi��o GET de consulta de cart�es de cr�ditos.
  RequestGetCreditCards.ClearBody;
  RequestGetCreditCards.Params.ParameterByName('json').Value := '{"IdUser":'+IntToStr(DataModuleLocal.GetIdUser)+'}';
  RequestGetCreditCards.Execute;
end;

function TDataModuleGeral.GetMaxTime: Integer;
begin
  Result := 120;
end;

function TDataModuleGeral.GetMinTime: Integer;
begin
  Result := 10;
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
  Result := 1;
end;

function TDataModuleGeral.PostCreditCard(IdUser, Id: Integer; Flag, Name, Number: String;
  MonthValidate, YearValidate: Integer; Status: Boolean): Integer;
var
Json, JsonResponse: TJSONObject;
begin
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
end;

function TDataModuleGeral.PostPayment(Plate: String;
  Time: Integer; FlagCreditCard, NameCreditCard,
  NumberCreditCard: String; MonthCreditCard, YearCreditCard,
  CSCCredCard: Integer): TDateTime;
var
Json: TJSONObject;
JsonResponse: TJSONObject;
begin
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
end;

function TDataModuleGeral.PostUser(Id: Integer; Nickname, Email, CPF,
  Password: String): Integer;
var
Json, JsonResponse: TJSONObject;
begin
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
    SendPaymentByCredit(Plate, Time, PaymentListener);
  end;
end;

procedure TDataModuleGeral.SendPaymentByCredit(Plate: String; Time: Integer;
  PaymentListener: IPaymentListener);
begin
  //Falta implementar.
end;

procedure TDataModuleGeral.SendPaymentSeparate(Plate: String; Time: Integer;
  PaymentListener: IPaymentListener);
var
StartTime: TDateTime;
begin
  //Exibe o formul�rio de cart�o de cr�dito avulso.
  FormCreditCardSeparate := TFormCreditCardSeparate.Create(Self);
  FormCreditCardSeparate
        .ShowModal(procedure(ModalResult: TModalResult)
                   begin
                      //Oculta o formul�rio.
                      FormCreditCardSeparate.Hide;

                      //Verifica se o usu�rio confirmou a opera��o.
                      if (ModalResult = mrOk) then
                      begin
                        try
                          //Envia ao servidor a requisi��o HTTP Post do pagamento.
                          StartTime:= postPayment(
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

                          //Chama o procedimento do ouvinte de pagamento.
                          PaymentListener.OnSucess;
                        except
                          on Error: Exception do
                          begin
                            //Chama o procedimento OnError do objeto ouvinte de pagamentos.
                            PaymentListener.OnError(Error.Message);
                          end;
                        end;
                      end;

                      //Dispensa(elimina) o formul�rio.
                      //FormCreditCardSeparate.DisposeOf();
                   end);
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
  Result := 10;
end;

function TDataModuleGeral.GetYearCreditCardSelected: Integer;
begin
  Result := DataSetCreditCards.FieldByName('YearValidate').AsInteger;
end;

end.

