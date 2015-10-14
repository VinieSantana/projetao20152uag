unit UnitDataModuleLocal;

interface

uses
  System.SysUtils, System.Classes, Data.DbxSqlite, Data.FMTBcd, Data.DB,
  Datasnap.DBClient, Datasnap.Provider, Data.SqlExpr, DateUtils,
  System.ImageList, FMX.ImgList;

type
  TDataModuleLocal = class(TDataModule)
    SQLConnectionLocal: TSQLConnection;
    IconsTicketsList: TImageList;
    SQLTableTickets: TSQLTable;
    DataSetTickets: TClientDataSet;
    DataSetTicketsPlate: TWideStringField;
    DataSetTicketsStartTimeStr: TWideStringField;
    DataSetTicketsStartTime: TDateTimeField;
    DataSetTicketsTime: TLargeintField;
    DataSetTicketsDeadlineTime: TDateTimeField;
    DataSetTicketsIconIndex: TIntegerField;
    DataSetProviderTickets: TDataSetProvider;
    procedure DataModuleCreate(Sender: TObject);
    procedure SQLConnectionLocalAfterConnect(Sender: TObject);
    procedure SQLConnectionLocalBeforeConnect(Sender: TObject);
    procedure DataSetTicketsCalcFields(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }

    procedure InsertTicketLocal(Plate: String; StartTime: TDateTime; Time: Integer);
  end;

var
  DataModuleLocal: TDataModuleLocal;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDataModuleLocal.DataModuleCreate(Sender: TObject);
begin
  //Abre a conex�o da base local e suas respectivas tabelas.
  SQLConnectionLocal.Open;

  //Atribui a ordena��o aos t�quetes da base local.
  DataSetTickets.IndexDefs.Add('OrderByTickets', 'DeadlineTime', [ixDescending]);
  DataSetTickets.IndexName := 'OrderByTickets';
  DataSetTickets.Open;

end;

procedure TDataModuleLocal.DataSetTicketsCalcFields(DataSet: TDataSet);
var
ResourceStream : TResourceStream;
DeadlineTime: TDateTime;
IconName: String;
begin
  //Verifica se o estado determina o c�lculo dos atributos internos calculados.
  //E verifica se o registro do t�quete n�o � o padr�o.
  if (DataSetTickets.State = dsInternalCalc)
  and (DataSetTicketsPlate.AsString <> EmptyStr) then
  begin
    //Atualiza os valores dos atributos calculados internamente de DataSetTickets
    //atrav�s do objeto SQLDataSetTickets vinculado.
    DataSetTicketsStartTime.AsDateTime := StrToDateTime(DataSetTicketsStartTimeStr.AsString);;

    //Calcula o tempo limite do t�quete corrente.
    DeadlineTime := IncMinute(DataSetTicketsStartTime.AsDateTime, DataSetTicketsTime.AsInteger);

    //Atualiza os valores dos atributos internos calculados.
    DataSetTicketsDeadlineTime.AsDateTime := DeadlineTime;

    //Verifica se o t�quete passou do limite.
    if (Now > DeadlineTime) then
    begin
      //O �cone a ser atribu�do ao t�quete ser� o de t�quete vencido.
      DataSetTicketsIconIndex.AsInteger := 0;
    end
    else
    begin
      //O �cone a ser atribu�do ao t�quete ser� o de t�quete v�lido(ativo).
      DataSetTicketsIconIndex.AsInteger := 1;
    end;
  end;
end;

procedure TDataModuleLocal.SQLConnectionLocalAfterConnect(Sender: TObject);
begin
  //Cria as tabelas da base de dados local.
  SQLConnectionLocal.ExecuteDirect('CREATE TABLE IF NOT EXISTS Tickets('
                                  +'Plate CHAR(10) NOT NULL'
                                  +',StartTimeStr CHAR(20) NOT NULL'
                                  +',Time INTEGER NOT NULL'
                                  +');');
  //Necess�rio inserir o primeiro registro para identifica��o dos tipos dos atributos(Fields).
  SQLConnectionLocal.ExecuteDirect('INSERT INTO Tickets Select '''', '''', 0 Where Not Exists(Select * From Tickets)');
end;

procedure TDataModuleLocal.SQLConnectionLocalBeforeConnect(Sender: TObject);
begin
  {$IF DEFINED(IOS) or DEFINED(ANDROID)}
  SQLConnectionLocal.Params.Values['Database'] :=   TPath.GetDocumentsPath + PathDelim + 'tasks.s3db';
  {$ENDIF}
end;

procedure TDataModuleLocal.InsertTicketLocal(Plate: String;
  StartTime: TDateTime; Time: Integer);
var
CommandSQL: String;
begin
  //Constroi o comando de INSERT para o novo t�quete.
  CommandSQL := Format('INSERT INTO Tickets(Plate, StartTimeStr, Time) VALUES(%s,%s, %d);'
                      ,[ QuotedStr(Plate)
                        ,QuotedStr(DateTimeToStr(StartTime))
                        ,Time]);

  //Executa o comando SQL de Insert do t�quete na base local.
  SQLConnectionLocal.ExecuteDirect(CommandSQL);

  //Atualiza a consulta de DataSetTickets.
  DataSetTickets.Close;
  DataSetTickets.Open;
end;

end.
