unit UnitCreditCards;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.Controls.Presentation, FMX.ListView,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, System.Rtti, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.Components, Data.Bind.DBScope, FMX.Layouts;

type
  TFrameCreditCards = class(TFrame)
    ListViewCreditCards: TListView;
    buttonNew: TSpeedButton;
    lblMessage: TLabel;
    LayoutPrincipal: TLayout;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkFillControlToField1: TLinkFillControlToField;
    procedure ListViewCreditCardsItemsChange(Sender: TObject);
    procedure ListViewCreditCardsItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure buttonNewClick(Sender: TObject);
  private
    { Private declarations }
    procedure InactivateCreditCard(Number: String);
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

uses UnitDataModuleGeral, UnitCadastreCreditCard, UnitRoutines,
  UnitDialogOptions;

procedure TFrameCreditCards.buttonNewClick(Sender: TObject);
begin
  //Abre o cadastro de cart�o de cr�dito para um novo registro.
  UnitRoutines.Show(TFormCadastreCreditCard.Create(Self));
end;

procedure TFrameCreditCards.InactivateCreditCard(Number: String);
begin
  //Abre um di�logo de Sim/N�o para confirmar se o usu�rio deseja realmente excluir o cart�o.
  MessageDlg('Deseja excluir o cart�o de n�mero'+#13+Number+' ?'
            ,System.UITypes.TMsgDlgType.mtConfirmation
            ,[System.UITypes.TMsgDlgBtn.mbYes, System.UITypes.TMsgDlgBtn.mbNo]
            ,0
            ,procedure (const ModalResult: TModalResult)
             begin
              //Verifica se o usu�rio confirmou (mrYes).
              if (ModalResult = mrYes) then
              begin
                //Localiza no conjunto de cart�es o registro do cart�o de cr�dito cujo
                //n�mero foi passado como argumento.
                DataModuleGeral.DataSetCreditCards.Locate('Number', Number, []);

                //Envia a atualiza��o do cart�o de cr�dito para o webservice.
                DataModuleGeral.SendCreditCard(
                                     DataModuleGeral.GetIdCreditCardSelected
                                    ,DataModuleGeral.GetFlagCreditCardSelected
                                    ,''
                                    ,Copy(UnitRoutines.GenerateMD5(DataModuleGeral.GetNumberCreditCardSelected+FormatDateTime('ddHHmmss', Now())), 1,16)
                                    ,0
                                    ,0
                                    ,False);

                //Atualiza a consulta de cart�es.
                DataModuleGeral.OpenQueryCreditCards;

              end;
             end
            );
end;

procedure TFrameCreditCards.ListViewCreditCardsItemClick(const Sender: TObject;
  const AItem: TListViewItem);
var
DialogOptions: TFrameDialogOptions;
begin
  //Abre o di�logo de op��es para editar ou excluir o cart�o de cr�dito.
  DialogOptions:= TFrameDialogOptions.Create(nil
                    , LayoutPrincipal
                    , ['Editar', 'Excluir']
                    , procedure (ModalResult: TModalResult; IndexSelected: Integer)
                      begin
                        try
                          //Verifica se o resultado foi mrOk.
                          if (ModalResult = mrOk) then
                          begin
                            //Verifica qual a op��o foi selecionada.
                            case IndexSelected of
                              0:
                              begin
                                //Abre o cadastro de cart�o de cr�dito para alterar o cart�o selecionado(clicado).
                                UnitRoutines.Show(TFormCadastreCreditCard.Create(Self, AItem.Detail));
                              end;

                              1:
                              begin
                                //Inativa o cart�o selecionado.
                                InactivateCreditCard(AItem.Detail);
                              end;
                            end;
                          end;
                        finally
                          //Desaloca o frame da mem�ria.
                          DialogOptions.Parent := nil;
                          //DialogOptions.DisposeOf;
                        end;
                      end
                    );


end;

procedure TFrameCreditCards.ListViewCreditCardsItemsChange(Sender: TObject);
begin
  lblMessage.Visible := (DataModuleGeral.DataSetCreditCards.IsEmpty);
  lblMessage.Text    := 'Nenhum cart�o cadastrado.'+#13+#13+'Clique no bot�o Novo para cadastrar um cart�o.'
end;

end.
