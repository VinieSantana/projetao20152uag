unit UnitAccountRecovery;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts;

type
  TFormAccountRecovery = class(TForm)
    LayoutPrincipal: TLayout;
    Layout3: TLayout;
    ButtonRecovery: TSpeedButton;
    Layout5: TLayout;
    EditCPF: TEdit;
    Label1: TLabel;
    procedure ButtonRecoveryClick(Sender: TObject);
    procedure EditCPFChange(Sender: TObject);
  private
    { Private declarations }
    procedure ValidateValuesComponents;
  public
    { Public declarations }
  end;

var
  FormAccountRecovery: TFormAccountRecovery;

implementation

{$R *.fmx}

uses UnitDataModuleGeral, UnitRoutines;

procedure TFormAccountRecovery.ButtonRecoveryClick(Sender: TObject);
begin
  //Valida os valores dos campos do formul�rio.
  ValidateValuesComponents;

  //Envia a recupera��o de conta em uma Thread paralela.
  ExecuteAsync(LayoutPrincipal
    ,procedure
     begin
        try
          //Envia a recupera��o de senha para o servidor.
          DataModuleGeral.SendRedefinePassword(EditCPF.Text);

          //Atualiza a interface gr�fica na Thread principal.
          TThread.Synchronize(nil
              ,procedure
               begin
                  //Exibe uma mensagem de sucesso para o usu�rio.
                  ShowMessage('Voc� receber� um e-mail com informa��es da sua conta!');

                  //Fecha o formul�rio de recupera��o de senha.
                  Close;
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
     end);
end;

procedure TFormAccountRecovery.EditCPFChange(Sender: TObject);
begin
  if (EditCPF.Text <> 'CPF') then
  begin
    //Permite apenas n�meros no campo de CPF.
    EditCPF.Text := UnitRoutines.GetJustNumbersOfString(EditCPF.Text);
  end;
end;

procedure TFormAccountRecovery.ValidateValuesComponents;
begin
  //Valida os valores de todos os componentes.
  EditCPF.Text := GetJustNumbersOfString(EditCPF.Text);

  //Verifica se o n�mero do CPF � v�lido.
  if not(ValidateCPF(GetJustNumbersOfString(EditCPF.Text))) then
  begin
    //Levanta uma exce��o informando do CPF inv�lido.
    EditCPF.SetFocus;
    raise Exception.Create('CPF inv�lido!');
  end;
end;

end.
