unit UnitCadastreCreditCard;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.Layouts, FMX.Edit, FMX.ListBox, DateUtils;

type
  TFormCadastreCreditCard = class(TForm)
    Layout1: TLayout;
    MasterToolBar: TToolBar;
    Rectangle1: TRectangle;
    Label3: TLabel;
    Layout3: TLayout;
    Label2: TLabel;
    Layout2: TLayout;
    Label1: TLabel;
    EditName: TEdit;
    ComboboxFlag: TComboBox;
    Layout4: TLayout;
    Layout5: TLayout;
    Label4: TLabel;
    ComboboxMonth: TComboBox;
    ComboboxYear: TComboBox;
    buttonSave: TSpeedButton;
    Layout7: TLayout;
    Label6: TLabel;
    EditNumber: TEdit;
    procedure EditNameChange(Sender: TObject);
    procedure buttonSaveClick(Sender: TObject);
    procedure EditNameKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure EditNumberChange(Sender: TObject);
  private
    { Private declarations }
    var
    Id: Integer;
  protected
    { Protected declarations }
    procedure ValidateValuesComponents; virtual;
  public
    { Public declarations }
    constructor Create(AWoner: TComponent); overload;
    constructor Create(AWoner: TComponent; NumberForEdit: String); overload;
  end;

var
  FormCadastreCreditCard: TFormCadastreCreditCard;

implementation

{$R *.fmx}

uses UnitDataModuleGeral, UnitRoutines;

procedure TFormCadastreCreditCard.buttonSaveClick(Sender: TObject);
begin
  try
    //Valida os valores dos campos.
    ValidateValuesComponents;

    //Envia o cart�o de cr�dito para o servidor.
    DataModuleGeral.SendCreditCard(Id
                                  ,ComboboxFlag.Selected.Text
                                  ,EditName.Text
                                  ,EditNumber.Text
                                  ,StrToInt(ComboboxMonth.Selected.Text)
                                  ,StrToInt(ComboboxYear.Selected.Text)
                                  ,True);

    //Fecha o cadastro do cart�o de cr�dito.
    Close;
  except
    on Error: Exception do
    begin
      //Exibe o erro para o usu�rio.
      ShowMessage(Error.Message);
    end;
  end;
end;

constructor TFormCadastreCreditCard.Create(AWoner: TComponent);
begin
  //Chama o construtor herdado.
  inherited Create(AWoner);
  Id := 0;
end;

constructor TFormCadastreCreditCard.Create(AWoner: TComponent;
  NumberForEdit: String);
begin
  //Chama o construtor herdado.
  inherited Create(AWoner);

  //Busca o registro a ser editado no conjunto de cart�es.
  if (DataModuleGeral.DataSetCreditCards.Locate('Number', NumberForEdit, [])) then
  begin
    //Carrega nos campos os valores do cart�o de cr�dito a ser editado.
    Id              := DataModuleGeral.GetIdCreditCardSelected();
    EditName.Text   := DataModuleGeral.GetNameCreditCardSelected();
    EditNumber.Text := DataModuleGeral.GetNumberCreditCardSelected();
    ComboboxFlag.ItemIndex := ComboboxFlag.Items.IndexOf(DataModuleGeral.GetFlagCreditCardSelected);
    ComboboxMonth.ItemIndex:= DataModuleGeral.GetMonthCreditCardSelected - 1;
    ComboboxYear.ItemIndex := ComboboxYear.Items.IndexOf(IntToStr(DataModuleGeral.GetYearCreditCardSelected));
  end;
end;

procedure TFormCadastreCreditCard.EditNameChange(Sender: TObject);
begin
  //Permite apenas letras A-Z, e deixa as letras em mai�sculo.
  EditName.Text := GetJustLettersOfString(editName.Text);
  SetTextUpperCaseEditChange(Sender);
end;

procedure TFormCadastreCreditCard.EditNameKeyDown(Sender: TObject;
  var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  AllowJustLettersEditKeyDown(Sender, Key, KeyChar, Shift);
end;

procedure TFormCadastreCreditCard.EditNumberChange(Sender: TObject);
begin
  //Permite apenas n�meros no campo editNumber.
  EditNumber.Text := GetJustNumbersOfString(editNumber.Text);
end;

procedure TFormCadastreCreditCard.ValidateValuesComponents;
var
Month, Year, MonthCurrent, YearCurrent: Integer;
begin
  //Valida os valores de todos os campos.
  Focused := nil;
  EditName.Text := GetJustLettersOfString(editName.Text);
  EditNumber.Text := GetJustNumbersOfString(editNumber.Text);
  ValidateValueComponent(EditName, editName.Text, 'Informe o nome impresso no cart�o!');
  ValidateValueComponent(EditNumber, editNumber.Text, 'Informe o n�mero do cart�o!', 16);

  //Verifica se o cart�o de cr�dito est� vencido.
  Month := StrToInt(ComboboxMonth.Selected.Text);
  Year  := StrToInt(ComboboxYear.Selected.Text);
  MonthCurrent := MonthOf(Date);
  YearCurrent  := YearOf(Date);
  if (Year < YearCurrent)
  or ((Month < MonthCurrent) and (Year = YearCurrent)) then
  begin
    //Levanta uma exce��o informando sobre a validade do cart�o de cr�dito.
    raise Exception.Create('Cart�o de cr�dito vencido!');
  end;

end;

end.
