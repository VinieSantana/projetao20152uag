unit UnitConsultPayments;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.Layouts, FMX.Edit, DateUtils;

type
  TFrameConsultPayments = class(TFrame)
    LayoutPrincipal: TLayout;
    Layout2: TLayout;
    Label1: TLabel;
    Layout8: TLayout;
    EditPlateLetters: TEdit;
    Label2: TLabel;
    EditPlateNumbers: TEdit;
    LayoutResultConsult: TLayout;
    LabelResult: TLabel;
    buttonConsultTicket: TSpeedButton;
    RectangleResult: TRectangle;
    Layout4: TLayout;
    LabelTimeInterval: TLabel;
    procedure buttonConsultTicketClick(Sender: TObject);
    procedure EditPlateNumbersChange(Sender: TObject);
    procedure EditPlateLettersChange(Sender: TObject);
    procedure EditPlateLettersKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
  private
    { Private declarations }
    procedure SetPaymentAuthorized(DayTime, DeadlineTime: TDateTime);
    procedure SetPaymentUnauthorized;
    procedure SetFontColorResultLabels(Color: TAlphaColor);
    procedure ValidateValuesComponents;
    procedure ConsultTicket;
  public
    { Public declarations }
    constructor Create(AWOner: TComponent); override;
    procedure ClearComponents;
  end;

var
  FrameConsultPayments: TFrameConsultPayments;

implementation

{$R *.fmx}

uses UnitDataModuleGeral, UnitRoutines;

{ TFrameConsultPayments }

procedure TFrameConsultPayments.buttonConsultTicketClick(Sender: TObject);
begin
  //Valida os valores dos campos.
  ValidateValuesComponents;

  //Exibe o di�logo de progresso.
  ExecuteAsync(LayoutPrincipal
              , procedure
                begin
                  try
                    //Executa a consulta do t�quete.
                    ConsultTicket;
                  except
                    on E: Exception do
                      ShowMessage(E.Message);
                  end;
                end);
end;

procedure TFrameConsultPayments.ClearComponents;
begin
  //Limpa os campos da consulta.
  RectangleResult.Visible := False;
end;

procedure TFrameConsultPayments.ConsultTicket;
var
DayTime, DeadlineTime: TDateTime;
Plate: String;
IsAuthorized: Boolean;
begin
  try
    //Junta as letras e n�meros da placa.
    Plate := EditPlateLetters.Text+editPlateNumbers.Text;

    //Consulta no servidor se o estacionamento est� pago para a placa informada.
    IsAuthorized := DataModuleGeral.ConsultPayment(Plate, DayTime, DeadlineTime);

    //Executa a atualiza��o dos componentes na Thread principal.
    TThread.Synchronize(nil,
        procedure
        begin
          //Verifica se o estacionamento est� autorizado para a placa consultada.
          if (IsAuthorized) then
          begin
            //Exibe como resultado que o pagamento foi confirmado.
            SetPaymentAuthorized(DayTime, DeadlineTime);
          end
          else
          begin
            //Exibe o resultado de n�o pagamento do estacionamento.
            SetPaymentUnauthorized;
          end;
        end
    );
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

constructor TFrameConsultPayments.Create(AWOner: TComponent);
begin
  inherited Create(AWOner);

  //Limpa os campos referente � consulta.
  ClearComponents;
end;

procedure TFrameConsultPayments.EditPlateLettersChange(Sender: TObject);
begin
  //Deixa as letras da placa em mai�sculo.
  SetTextUpperCaseEditChange(Sender);
end;

procedure TFrameConsultPayments.EditPlateLettersKeyDown(Sender: TObject;
  var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  //Permite apenas a digita��o de letras.
  AllowJustLettersEditKeyDown(Sender, Key, KeyChar, Shift);
end;

procedure TFrameConsultPayments.EditPlateNumbersChange(Sender: TObject);
begin
  try
    //Permite apenas n�meros no campo editPlateNumbers.
    if (EditPlateNumbers.Text <> EmptyStr) then
      EditPlateNumbers.Text := GetJustNumbersOfString(editPlateNumbers.Text);
  except
  end;
end;

procedure TFrameConsultPayments.SetFontColorResultLabels(Color: TAlphaColor);
begin
  //Atribui aos labels a cor de fonte passada como argumento.
  LabelResult.TextSettings.FontColor := Color;
  LabelTimeInterval.TextSettings.FontColor := Color;
end;

procedure TFrameConsultPayments.SetPaymentAuthorized(DayTime, DeadlineTime: TDateTime);
begin
  //Exibe os campos de resultados.
  RectangleResult.Visible := True;

  //Atribui os dados do pagamento aos campos de resultados.
  LabelResult.Text := 'Estacionamento Autorizado';
  LabelTimeInterval.Text := Format('de %s'+#13+' a %s'
                                  ,[FormatDateTime('dd/mm/yyyy hh:MM', DayTime)
                                   ,FormatDateTime('dd/mm/yyyy hh:MM', DeadlineTime)]);

  //Coloca a fonte verde nos labels de resultado.
  SetFontColorResultLabels(TAlphaColors.Green);
end;

procedure TFrameConsultPayments.SetPaymentUnauthorized;
begin
  //Exibe os campos de resultados.
  RectangleResult.Visible := True;

  //Atribui ao label de resultado o texto de n�o autoriza��o.
  LabelResult.Text := 'Estacionamento'+#13+'N�o Autorizado';
  LabelTimeInterval.Text := FormatDateTime('dd/mm/yyyy hh:MM', now);
  Application.ProcessMessages;

  //Coloca a fonte vermelha nos labels de resultado.
  SetFontColorResultLabels(TAlphaColors.Red);
end;

procedure TFrameConsultPayments.ValidateValuesComponents;
begin
  //Verifica os valores dos campos.
  if (EditPlateNumbers.Text <> EmptyStr) then
    EditPlateNumbers.Text := GetJustNumbersOfString(EditPlateNumbers.Text);

  ValidateValueComponent(editPlateLetters, editPlateLetters.Text, 'Informe as letras da placa!', 3);
  ValidateValueComponent(editPlateNumbers, editPlateNumbers.Text, 'Informe os n�meros da placa!', 4);
end;

end.
