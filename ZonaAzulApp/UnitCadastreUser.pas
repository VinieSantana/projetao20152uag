unit UnitCadastreUser;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Controls.Presentation, FMX.Edit;

type
  ICadastreListener = interface
    procedure OnSucess;
    procedure OnCancel;
  end;

type
  TFrameCadastreUser = class(TFrame)
    LayoutPrincipal: TLayout;
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
    ButtonBack: TSpeedButton;
    procedure ButtonConfirmClick(Sender: TObject);
    procedure ButtonAlterPasswordClick(Sender: TObject);
    procedure EditNicknameChange(Sender: TObject);
    procedure EditNicknameKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure EditCPFChange(Sender: TObject);
    procedure ButtonBackClick(Sender: TObject);
  private
    { Private declarations }
    CadastreListener: ICadastreListener;
    procedure ValidateValuesComponents;
    procedure ShowCadastreCreditCard;
    var
    IsPasswordChanged : Boolean;
  public
    { Public declarations }
    constructor Create(AWOner: TComponent; CadastreListener: ICadastreListener; IsShowButtonBack: Boolean = False); overload;
    procedure UpdateValuesComponents;
    procedure SendDataUser;
    procedure SaveDataUser;
  end;

implementation

{$R *.fmx}

uses UnitDataModuleGeral, UnitDataModuleLocal, UnitRoutines,
  UnitCadastreCreditCard;

procedure TFrameCadastreUser.ButtonAlterPasswordClick(Sender: TObject);
begin
  //Confirma a senha atual do usu�rio logado.

  InputBox('Confirma��o de Senha', #31'Senha Atual', ''
    ,procedure(const ModalResult: TModalResult; const Value: string)
     begin
        //Caso o resultado seja mrOK.
        if (ModalResult = mrOk) then
        begin
          //Atualiza a interface na Thread principal.
          TThread.Synchronize(nil
            ,procedure
             var
             ActualPassword: String;
             begin
                //Pega a senha digitada pelo usu�rio.
                ActualPassword := GenerateMD5(Value);

                if (ActualPassword.Equals(DataModuleLocal.GetPassword)) then
                begin
                  //Exibe os campos de senha e oculta o bot�o de alterar senha.
                  LayoutPassword.Visible      := True;
                  ButtonAlterPassword.Visible := False;

                  //Limpa a senha criptografada dos campos de senha e confirma��o.
                  EditPassword.Text := '';
                  EditConfirmPassword.Text := '';

                  //Atualiza o atributo isPasswordChanged.
                  IsPasswordChanged := True;
                end
                else
                begin
                  //Levanta uma exce��o informando que a senha � inv�lida.
                  raise Exception.Create('Senha Atual Inv�lida!');
                end;
             end);
        end;
     end);
end;

procedure TFrameCadastreUser.ButtonBackClick(Sender: TObject);
begin
  //Executa o procedimento de cancelamento no objeto ouvinte de cadastro.
  CadastreListener.OnCancel;
end;

procedure TFrameCadastreUser.ButtonConfirmClick(Sender: TObject);
begin
  //Verifica se � um novo usu�rio.
  if not(DataModuleGeral.IsUserLogged) then
  begin
    //Salva os dados do novo usu�rio.
    SaveDataUser;
  end
  else
  begin
    //Exibe um di�logo de confirma��o para averiguar se o usu�rio deseja
    //alterar suas informa��es.
    //Abre o di�logo para averiguar se o usu�rio deseja sair da aplica��o.
    MessageDlg( 'Confirmar altera��es?'
         , System.UITypes.TMsgDlgType.mtConfirmation
         , [System.UITypes.TMsgDlgBtn.mbYes, System.UITypes.TMsgDlgBtn.mbNo]
         , 0
         , procedure (const Result: TModalResult)
           begin
              case Result of
                mrYes:
                  begin
                    //Salva os dados modificados do usu�rio logado.
                    SaveDataUser;
                  end;
              end;
           end
    );
  end;
end;

constructor TFrameCadastreUser.Create(AWOner: TComponent;
  CadastreListener: ICadastreListener; IsShowButtonBack: Boolean);
begin
  //Chama o construtor herdado da superclasse.
  inherited Create(AWOner);

  //Inicializa o atributo.
  Self.CadastreListener := CadastreListener;

  //Oculta o bot�o de alterar senha por default.
  ButtonAlterPassword.Visible := False;

  //Exibe o bot�o de voltar de acordo com o par�metro IsShowButtonBack.
  ButtonBack.Visible := IsShowButtonBack;
end;

procedure TFrameCadastreUser.EditCPFChange(Sender: TObject);
begin
  //Permite apenas a digita��o de n�meros no campo de CPF.
  EditCPF.Text := GetJustNumbersOfString(EditCPF.Text);
end;

procedure TFrameCadastreUser.EditNicknameChange(Sender: TObject);
begin
  //Permite apenas letras no campo.
  EditNickname.Text := GetJustLettersOfString(EditNickname.Text);
end;

procedure TFrameCadastreUser.EditNicknameKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  //Permite apenas a digita��o de letras no campo de apelido.
  AllowJustLettersEditKeyDown(Sender, Key, KeyChar, Shift);
end;

procedure TFrameCadastreUser.SaveDataUser;
begin
  //Envia os dados do usu�rio para o servidor em uma Thread concorrente.
  ExecuteAsync(LayoutPrincipal
    ,procedure
     begin
        //Envia os dados do usu�rio para o servidor.
        SendDataUser;
     end);
end;

procedure TFrameCadastreUser.SendDataUser;
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

    //Executa a atualiza��o da UI na Thread principal.
    TThread.Synchronize(nil
      ,procedure
       begin
          //Verifica se � um novo cadastro.
          if not(DataModuleGeral.IsUserLogged) then
          begin
            //Exibe o cadastro de cart�o.
            ShowCadastreCreditCard;
          end
          else
          begin
            //Neste caso, executa o procedimento de sucesso do objeto ouvinte de eventos.
            CadastreListener.OnSucess;
          end;
       end);
  except
    on Error: Exception do
    begin
      //Exibe a mensagem do erro na Thread principal.
      TThread.Synchronize(nil
      ,procedure
       begin
         ShowMessage(Error.Message);
       end);
    end;
  end;
end;

procedure TFrameCadastreUser.ShowCadastreCreditCard;
var
FormCadastreCreditCard: TFormCadastreCreditCard;
begin
  //Exibe o cadastro de cart�o de cr�dito.
  FormCadastreCreditCard := TFormCadastreCreditCard.Create(Self);
  FormCadastreCreditCard.ShowModal( procedure (ModalResult: TModalResult)
                                    begin
                                      //Chama o procedimento de sucesso do objeto
                                      //ouvinte de eventos de cadastro.
                                      CadastreListener.OnSucess;
                                    end
                                  );
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
  EditNickname.Text := GetJustLettersOfString(EditNickname.Text);
  EditCPF.Text := GetJustNumbersOfString(EditCPF.Text);
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
