unit UnitCadastreUser;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Controls.Presentation, FMX.Edit;

type
  ICadastreListener = interface
    procedure OnSucess;
  end;

type
  TFrameCadastreUser = class(TFrame)
    Layout1: TLayout;
    Layout2: TLayout;
    EditNickname: TEdit;
    Layout3: TLayout;
    Layout4: TLayout;
    EditEmail: TEdit;
    Layout5: TLayout;
    EditCPF: TEdit;
    ButtonConfirm: TSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    VertScrollBox1: TVertScrollBox;
    Layout7: TLayout;
    LayoutPassword: TLayout;
    EditPassword: TEdit;
    EditConfirmPassword: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    ButtonAlterPassword: TSpeedButton;
    procedure ButtonConfirmClick(Sender: TObject);
    procedure EditPasswordKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure ButtonAlterPasswordClick(Sender: TObject);
  private
    { Private declarations }
    CadastreListener: ICadastreListener;
    procedure ValidateValuesComponents;
    var
    IsPasswordChanged : Boolean;
  public
    { Public declarations }
    constructor Create(AWOner: TComponent; CadastreListener: ICadastreListener); overload;
    procedure UpdateValuesComponents;
  end;

implementation

{$R *.fmx}

uses UnitDataModuleGeral, UnitDataModuleLocal, UnitRoutines;

procedure TFrameCadastreUser.ButtonAlterPasswordClick(Sender: TObject);
var
ActualPassword: String;
begin
  //Confirma a senha atual do usu�rio logado.
  ActualPassword := GenerateMD5(InputBox('Confirma��o de Senha', #31'Senha Atual', ''));
  if (ActualPassword.Equals(DataModuleLocal.GetPassword)) then
  begin
    //Exibe os campos de senha e oculta o bot�o de alterar senha.
    LayoutPassword.Visible      := True;
    ButtonAlterPassword.Visible := False;
  end
  else
  begin
    //Levanta uma exce��o informando que a senha � inv�lida.
    raise Exception.Create('Senha Atual Inv�lida!');
  end;
end;

procedure TFrameCadastreUser.ButtonConfirmClick(Sender: TObject);
var
PasswordMD5: String;
begin
  try
    //Valida os valores dos campos.
    ValidateValuesComponents;

    //Verifica se a senha foi alterada.
    if not(DataModuleGeral.IsUserLogged)
    or (IsPasswordChanged) then
    begin
      //Gera o MD5 da senha.
      PasswordMD5 := GenerateMD5(EditPassword.Text);
    end
    else
    begin
      //Neste caso, a senha j� est� criptografada no campo de senha.
      PasswordMD5 := EditPassword.Text;
    end;

    //Envia os dados do usu�rio para o servidor.
    DataModuleGeral.SendUser(EditNickname.Text
                            ,EditEmail.Text
                            ,EditCPF.Text
                            ,PasswordMD5);


    //Chama o procedimento de sucesso do objeto ouvinte de eventos de cadastro.
    CadastreListener.OnSucess;
  except
    on Error: Exception do
    begin
      //Exibe a mensagem do erro.
      ShowMessage(Error.Message);
    end;
  end;
end;

constructor TFrameCadastreUser.Create(AWOner: TComponent;
  CadastreListener: ICadastreListener);
begin
  //Chama o construtor herdado da superclasse.
  inherited Create(AWOner);

  //Inicializa o atributo.
  Self.CadastreListener := CadastreListener;

  //Oculta o bot�o de alterar senha por default.
  ButtonAlterPassword.Visible := False;
end;

procedure TFrameCadastreUser.EditPasswordKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  //Verifica se a senha est� criptografada.
  if not(IsPasswordChanged)
  and (DataModuleGeral.IsUserLogged) then
  begin
    //Limpa a senha criptografada dos campos de senha e confirma��o.
    EditPassword.Text := '';
    EditConfirmPassword.Text := '';

    //Atualiza o atributo isPasswordChanged.
    IsPasswordChanged := True;
  end;
end;

procedure TFrameCadastreUser.UpdateValuesComponents;
begin
  //Atualiza os valores dos campos(componentes) com os dados salvos na base local.
  EditNickname.Text := DataModuleLocal.GetNicknameUser();
  EditEmail.Text    := DataModuleLocal.GetEmailUser();
  EditCPF.Text      := DataModuleLocal.GetCPF();
  EditPassword.Text := DataModuleLocal.GetPassword();
  EditConfirmPassword.Text := DataModuleLocal.GetPassword();

  //Verifica se ainda n�o existe um usu�rio logado.
  if not(DataModuleGeral.IsUserLogged) then
  begin
    //Oculta o bot�o de alterar senha e exibe o layout de senha.
    ButtonAlterPassword.Visible := False;
    LayoutPassword.Visible      := True;
  end
  else
  begin
    //Exibe o bot�o de alterar senha
    //e oculta o layout contendo os campos relacionados a senha.
    ButtonAlterPassword.Visible := True;
    LayoutPassword.Visible      := False;
  end;
end;

procedure TFrameCadastreUser.ValidateValuesComponents;
begin
  //Valida os valores de todos os componentes.
  ValidateValueComponent(EditNickname, EditNickname.Text, 'Informe o seu Nome ou Apelido!');
  ValidateValueComponent(EditEmail, EditEmail.Text, 'Informe o seu Email!');
  ValidateValueComponent(EditPassword, EditPassword.Text, 'Informe a sua Senha!');
  ValidateValueComponent(EditCPF, GetJustNumbersOfString(EditCPF.Text), 'Informe um CPF v�lido!', 11);
  ValidateValueComponent(EditConfirmPassword, EditConfirmPassword.Text, 'Informe a Confirma��o de Senha!');

  //Verifica se o email digitado � v�lido.
  if not(ValidateEmail(EditEmail.Text)) then
  begin
    //Levanta uma exce��o informando sobre o email inv�lido.
    EditEmail.SetFocus;
    raise Exception.Create('Email inv�lido!');
  end;

  //Verifica se o n�mero do CPF � v�lido.
  if not(ValidateCPF(GetJustNumbersOfString(EditCPF.Text))) then
  begin
    //Levanta uma exce��o informando do CPF inv�lido.
    EditCPF.SetFocus;
    raise Exception.Create('CPF inv�lido!');
  end;

  //Verifica se a senha e a confirma��o s�o diferentes.
  if not(EditPassword.Text.Equals(EditConfirmPassword.Text)) then
  begin
    //Levanta uma exce��o informando da senha e confirma��o da senha.
    EditConfirmPassword.SetFocus;
    raise Exception.Create('A Confirma��o da Senha est� inv�lida!');
  end;
  
end;

end.
