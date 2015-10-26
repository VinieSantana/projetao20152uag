unit UnitCreditCards;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.Controls.Presentation, FMX.ListView,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, System.Rtti, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.Components, Data.Bind.DBScope;

type
  TFrameCreditCards = class(TFrame)
    ListViewCreditCards: TListView;
    buttonNew: TSpeedButton;
    lblMessage: TLabel;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkFillControlToField1: TLinkFillControlToField;
    procedure ListViewCreditCardsItemsChange(Sender: TObject);
    procedure ListViewCreditCardsItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure buttonNewClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure UpdateCreditCardsList;
  end;

implementation

{$R *.fmx}

uses UnitDataModuleGeral, UnitCadastreCreditCard, UnitRoutines;

procedure TFrameCreditCards.buttonNewClick(Sender: TObject);
begin
  //Abre o cadastro de cart�o de cr�dito para um novo registro.
  UnitRoutines.Show(TFormCadastreCreditCard.Create(Self));
end;

procedure TFrameCreditCards.ListViewCreditCardsItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  //Abre o cadastro de cart�o de cr�dito para alterar o cart�o selecionado(clicado).
  UnitRoutines.Show(TFormCadastreCreditCard.Create(Self, AItem.Detail));
end;

procedure TFrameCreditCards.ListViewCreditCardsItemsChange(Sender: TObject);
begin
  lblMessage.Visible := (DataModuleGeral.DataSetCreditCards.IsEmpty);
  lblMessage.Text    := 'Nenhum cart�o cadastrado.'+#13+#13+'Clique no bot�o Novo para cadastrar um cart�o.'
end;

procedure TFrameCreditCards.UpdateCreditCardsList;
begin
  //Verifica se a consulta de cart�es de cr�dito est� fechada.
  if not(DataModuleGeral.DataSetCreditCards.Active) then
  begin
    //Abre a consulta de cart�es de cr�dito.
    DataModuleGeral.OpenQueryCreditCards;
  end;
end;

end.
