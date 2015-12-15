unit UnitTickets;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.Layouts, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  System.Rtti, System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, Data.Bind.Components, Data.Bind.DBScope, Data.Bind.GenData,
  Fmx.Bind.GenData, Data.Bind.ObjectScope, Data.DB, Datasnap.DBClient,
  Datasnap.Provider, UnitParking;

type
  TFrameTickets = class(TFrame)
    LayoutPrincipal: TLayout;
    ListViewTickets: TListView;
    ButtonNew: TSpeedButton;
    LabelMessage: TLabel;
    TimerUpdateListTickets: TTimer;
    DataSetListView: TClientDataSet;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    DataSetListViewPlate: TStringField;
    DataSetListViewIconIndex: TIntegerField;
    DataSetListViewDeadlineTimeFormated: TStringField;
    DataSetListViewDeadlineTime: TDateTimeField;
    procedure ListViewTicketsFilter(Sender: TObject; const AFilter,
      AValue: string; var Accept: Boolean);
    procedure ButtonNewClick(Sender: TObject);
    procedure TimerUpdateListTicketsTimer(Sender: TObject);
    procedure ListViewTicketsItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure ListViewTicketsItemsChange(Sender: TObject);
    procedure ListViewTicketsPullRefresh(Sender: TObject);
  private
    { Private declarations }
    procedure ShowParkingForRenewTicket(Plate: String; DeadlineTime: TDateTime);
    procedure UpdateDataSetOfListView(DataSet: TDataSet);
    procedure ShowParkingForm(FormParking: TFormParking);
  public
    { Public declarations }
    procedure UpdateQueryTickets;
    procedure UpdateList;
  end;

var
  FrameTickets: TFrameTickets;

implementation

{$R *.fmx}

uses UnitDataModuleGeral, UnitRoutines, UnitDataModuleLocal,
  UnitDialogOptions;

procedure TFrameTickets.ButtonNewClick(Sender: TObject);
var
FormParking: TFormParking;
begin
  //Abre o formul�rio de estacionamento para o novo t�quete.
  //Aguarda o resultado.
  FormParking := TFormParking.Create(Self);
  ShowParkingForm(FormParking);
end;

procedure TFrameTickets.ListViewTicketsFilter(Sender: TObject; const AFilter,
  AValue: string; var Accept: Boolean);
begin
  //Exibe registro se o fitlro est� vazio.
  //Ou se o valor filtrado est� contido no valor de seu campo sendo avaliado.
  Accept := (AFilter = EmptyStr) or (Pos(AFilter, AValue) > 0);
end;

procedure TFrameTickets.ListViewTicketsItemClick(const Sender: TObject;
  const AItem: TListViewItem);
var
DialogOptions: TFrameDialogOptions;
begin
  //Verifica se o t�quete pressionado est� ATIVO (Em Aberto).
  if (AItem.ImageIndex = 1) then
  begin
    //Abre um di�logo de op��es para renova��o da vaga.
    DialogOptions := TFrameDialogOptions.Create(Self, LayoutPrincipal, ['Renovar T�quete']
                  , procedure (ModalResult: TModalResult; IndexSelected: Integer)
                    begin
                      try
                        //Verifica se o resultado foi mrOk.
                        if (ModalResult = mrOk) then
                        begin
                          //Verifica qual a op��o selecionada.
                          case IndexSelected of

                            0:  //Se for a op��o de renova��o.
                            begin
                              DataSetListView.Locate('Plate;IconIndex', VarArrayOf([AItem.Text, '1']),[]);
                              ShowParkingForRenewTicket(AItem.Text.Replace(' - ','')
                                                        ,DataSetListViewDeadlineTime.AsDateTime);
                            end;
                          end;
                        end;
                      finally
                        //Desaloca da mem�ria o di�logo de op��es.
                        DialogOptions.Release;
                      end;
                    end
                  );
  end;
end;

procedure TFrameTickets.ListViewTicketsItemsChange(Sender: TObject);
begin
  //Exibe o label de mensagem se n�o existir nenhum t�quete adquirido.
  LabelMessage.Visible := ((DataModuleLocal.DataSetTickets.IsEmpty) or (DataModuleGeral.IsUserLogged))
                    and ((DataModuleGeral.DataSetTickets.IsEmpty) or not(DataModuleGeral.IsUserLogged));
end;

procedure TFrameTickets.ListViewTicketsPullRefresh(Sender: TObject);
begin
  //Atualiza a lista de t�quetes.
  UpdateList;
end;

procedure TFrameTickets.ShowParkingForm(FormParking: TFormParking);
begin
  //Exibe o formul�rio de estacionamento e aguarda o resultado.
  FormParking.ShowModal(
    procedure (ModalResult: TModalResult)
    begin
      try
        //Verifica se o resultado modal � mrOk.
        if (ModalResult = mrOk) then
        begin
          //Atualiza a consulta de t�quetes do ListView.
          UpdateList;
        end;
      finally
        //Desaloca da mem�ria o formul�rio de estacionamento.
        //FormParking.Release;
      end;
    end
  );
end;

procedure TFrameTickets.ShowParkingForRenewTicket(Plate: String;
  DeadlineTime: TDateTime);
var
FormParking: TFormParking;
begin
  //Abre o formul�rio de estacionamento para a renova��o do t�quete passado como argumento.
  FormParking := TFormParking.Create(Self);
  FormParking.RenewTicket(Plate, DeadlineTime);
  ShowParkingForm(FormParking);
end;

procedure TFrameTickets.TimerUpdateListTicketsTimer(Sender: TObject);
begin
  //Verifica se existe um usu�rio logado.
  if (DataModuleGeral.IsUserLogged) then
  begin
    //Atualiza a consulta de t�quetes do usu�rio logado.
    DataModuleGeral.DataSetTickets.Close;
    DataModuleGeral.DataSetTickets.Open;
  end
  else
  begin
    //Atualiza a consulta de t�quetes(avulsos) na base local.
    DataModuleLocal.DataSetTickets.Close;
    DataModuleLocal.DataSetTickets.Open();
  end;
end;

procedure TFrameTickets.UpdateDataSetOfListView(DataSet: TDataSet);
var
Plate: String;
DeadlineTime: TDateTime;
IconIndex: Integer;
begin
  //Limpa os t�quetes do ListView.
  DataSetListView.EmptyDataSet;

  //Percorre todos os t�quetes do conjunto passado como argumento.
  DataSet.First;
  while not(DataSet.Eof) do
  begin
    //Insere o t�quete selecionado no ListView.
    Plate := DataSet.FieldByName('Plate').AsString;
    DeadlineTime := DataSet.FieldByName('DeadlineTime').AsDateTime;
    IconIndex := DataSet.FieldByName('IconIndex').AsInteger;

    DataSetListView.Append;
    DataSetListViewIconIndex.AsInteger  := IconIndex;
    DataSetListViewPlate.AsString := Format('%s - %s'
                                           ,[Copy(Plate,1,3), Copy(Plate,4,4)]);
    DataSetListViewDeadlineTimeFormated.AsString := 'V�lido at�: '
                                                +FormatDateTime('hh:nn:ss dd/MM'
                                                               ,DeadlineTime);
    DataSetListViewDeadlineTime.AsDateTime := DeadlineTime;
    DataSetListView.Post;

    //Seleciona o pr�ximo t�quete do conjunto passado como argumento.
    DataSet.Next;
  end;
end;

procedure TFrameTickets.UpdateList;
begin
  //Oculta o label de mensagem.
  LabelMessage.Text    := 'Nenhum t�quete comprado'+#13+#13+'Clique no bot�o Novo para comprar um novo t�quete';
  LabelMessage.Visible := False;

  //Verifica se o conjunto do ListView ainda n�o est� ativo.
  if not(DataSetListView.Active) then
  begin
    //Cria e abre o conjunto do ListView.
    DataSetListView.CreateDataSet;
    DataSetListView.Open;
  end;

  //Atualiza a lista de t�quete em outra Thread.
  ExecuteAsync(LayoutPrincipal,
               procedure
               begin
                  //Atualiza a consulta de t�quetes.
                  UpdateQueryTickets;
               end);
end;

procedure TFrameTickets.UpdateQueryTickets;
begin
  try
    //Verifica se existe um usu�rio logado no aplicativo.
    if (DataModuleGeral.IsUserLogged) then
    begin
      //Abre a consulta de t�quetes do usu�rio logado.
      DataModuleGeral.OpenQueryTicketsUser;

    end;

    //Atualiza os componentes gr�ficos na Thread principal.
    TThread.Synchronize(nil
              , procedure
                begin
                  //Verifica se existe um usu�rio logado no aplicativo.
                  if (DataModuleGeral.IsUserLogged) then
                  begin
                    //Atualiza os t�quetes do ListView atrav�s os t�quetes do usu�rio logado.
                    UpdateDataSetOfListView(DataModuleGeral.DataSetTickets);
                  end
                  else
                  begin
                    //Atualiza o ListView atrav�s dos t�quetes na base local (usu�rio avulso).
                    UpdateDataSetOfListView(DataModuleLocal.DataSetTickets);
                  end;

                  //Exibe o label de mensagem se n�o existir nenhum t�quete adquirido.
                  LabelMessage.Visible := ((DataModuleLocal.DataSetTickets.IsEmpty) or (DataModuleGeral.IsUserLogged))
                                    and ((DataModuleGeral.DataSetTickets.IsEmpty) or not(DataModuleGeral.IsUserLogged));
                end);
  except
    on Error: Exception do
    begin
      //Exibe a mensagem de erro na Thread principal.
      TThread.Synchronize(nil
       ,procedure
        begin
          //Exibe a mensagem do erro para o usu�rio.
          ShowMessage(Error.Message);
        end);
    end;
  end;
end;

end.
