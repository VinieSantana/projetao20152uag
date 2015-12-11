unit UnitTickets;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.Layouts, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  System.Rtti, System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, Data.Bind.Components, Data.Bind.DBScope, Data.Bind.GenData,
  Fmx.Bind.GenData, Data.Bind.ObjectScope, Data.DB, Datasnap.DBClient;

type
  TFrameTickets = class(TFrame)
    LayoutPrincipal: TLayout;
    ListViewTickets: TListView;
    ButtonNew: TSpeedButton;
    lblMessage: TLabel;
    BindingsList1: TBindingsList;
    LinkFillControlToField1: TLinkFillControlToField;
    BindSourceDB1: TBindSourceDB;
    TimerUpdateListTickets: TTimer;
    procedure ListViewTicketsFilter(Sender: TObject; const AFilter,
      AValue: string; var Accept: Boolean);
    procedure ButtonNewClick(Sender: TObject);
    procedure ListViewTicketsItemsChange(Sender: TObject);
    procedure TimerUpdateListTicketsTimer(Sender: TObject);
    procedure ListViewTicketsItemClick(const Sender: TObject;
      const AItem: TListViewItem);
  private
    { Private declarations }
    procedure ShowParkingForRenewTicket(Plate: String; DeadlineTime: TDateTime);
  public
    { Public declarations }
    procedure UpdateQueryTickets;
  end;

var
  FrameTickets: TFrameTickets;

implementation

{$R *.fmx}

uses UnitDataModuleGeral, UnitParking, UnitRoutines, UnitDataModuleLocal,
  UnitDialogOptions;

procedure TFrameTickets.ButtonNewClick(Sender: TObject);
begin
  //Abre o formul�rio de estacionamento para o novo t�quete.
  UnitRoutines.Show(TFormParking.Create(Self));
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
                            //Se for a op��o de renova��o.
                            0: ShowParkingForRenewTicket(AItem.Text, StrToDateTime(AItem.Detail));
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
  lblMessage.Visible := (DataModuleLocal.DataSetTickets.IsEmpty)
                      and ((DataModuleGeral.DataSetTickets.IsEmpty) or not(DataModuleGeral.IsUserLogged));
  lblMessage.Text    := 'Nenhum t�quete comprado'+#13+#13+'Clique no bot�o Novo para comprar um novo t�quete';
end;

procedure TFrameTickets.ShowParkingForRenewTicket(Plate: String;
  DeadlineTime: TDateTime);
var
FormParking: TFormParking;
begin
  //Abre o formul�rio de estacionamento para a renova��o do t�quete passado como argumento.
  FormParking := TFormParking.Create(Self);
  FormParking.RenewTicket(Plate, DeadlineTime);
  UnitRoutines.Show(FormParking);
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

procedure TFrameTickets.UpdateQueryTickets;
begin
  try
    //Verifica se existe um usu�rio logado no aplicativo.
    if (DataModuleGeral.IsUserLogged) then
    begin
      //Abre a consulta de t�quetes do usu�rio logado.
      DataModuleGeral.OpenQueryTicketsUser;

      //Atribui ao ListView o DataSetTickets do usu�rio logado como conjunto de dados.
      BindSourceDB1.DataSet := DataModuleGeral.DataSetTickets;
    end
    else
    begin
      //Atribui ao ListView o DataSetTickets da base local como conjunto de dados.
      BindSourceDB1.DataSet := DataModuleLocal.DataSetTickets;
    end;

    //Exibe o label de mensagem se n�o existir nenhum t�quete adquirido.
    lblMessage.Visible := (DataModuleLocal.DataSetTickets.IsEmpty)
                      and ((DataModuleGeral.DataSetTickets.IsEmpty) or not(DataModuleGeral.IsUserLogged));
    lblMessage.Text    := 'Nenhum t�quete comprado'+#13+#13+'Clique no bot�o Novo para comprar um novo t�quete';
  except
    on Error: Exception do
    begin
      //Exibe a mensagem do erro para o usu�rio.
      ShowMessage(Error.Message);
    end;
  end;
end;

end.
