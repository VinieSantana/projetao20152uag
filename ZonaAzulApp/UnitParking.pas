unit UnitParking;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.DateTimeCtrls,
  FMX.EditBox, FMX.NumberBox, FMX.Objects, UnitDataModuleGeral, DateUtils,
  FMX.TMSBaseControl, FMX.TMSSpinner;

type
  TFormParking = class(TForm, IPaymentListener)
    Label1: TLabel;
    LayoutPrincipal: TLayout;
    Layout2: TLayout;
    Layout3: TLayout;
    Label4: TLabel;
    Layout4: TLayout;
    Label9: TLabel;
    lblDeadline: TLabel;
    LayoutCreditsAvailable: TLayout;
    Label8: TLabel;
    lblCreditsAvailable: TLabel;
    Layout6: TLayout;
    Label5: TLabel;
    lblCreditsPay: TLabel;
    Layout7: TLayout;
    Layout8: TLayout;
    EditPlateLetters: TEdit;
    Label2: TLabel;
    EditPlateNumbers: TEdit;
    ButtonActiveTickets: TSpeedButton;
    TimerUpdateValues: TTimer;
    SpinnerTimerOut: TTMSFMXSpinner;
    VertScrollBox1: TVertScrollBox;
    procedure EditPlateLettersKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure EditPlateLettersChange(Sender: TObject);
    procedure ButtonActiveTicketsClick(Sender: TObject);
    procedure EditPlateNumbersChange(Sender: TObject);
    procedure TimerUpdateValuesTimer(Sender: TObject);
    procedure SpinnerTimerOutSelectedValueChanged(Sender: TObject;
      Column: Integer; SelectedValue: Double;
      RangeType: TTMSFMXSpinnerRangeType);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure UpdateValuesLabels;
    procedure ValidateValuesComponents;
    procedure OnSucess;
    procedure OnError(Msg: String);
    procedure UpdateValuesComponents;
    procedure ActiveTicket;
    var
    Time, TimeAlreadyPaid: Integer;
    BeginTime, DeadlineTime: TDateTime;
    ValueTotal: Double;
    IsRenew: Boolean;
  public
    { Public declarations }
    procedure RenewTicket(Plate: String; DeadlineTime: TDateTime);
    procedure BeginComponents;
  end;

var
  FormParking: TFormParking;

implementation

{$R *.fmx}

uses UnitRoutines, UnitDataModuleLocal, UnitBuyCredits, UnitDialogBuyCredits;

procedure TFormParking.ActiveTicket;
begin
  //Se existir um usu�rio logado, executa a ativa��o do t�quete em outra Thread.
  if (DataModuleGeral.IsUserLogged) then
  begin
    //Executa a ativa��o do t�quete em uma Thread paralela.
    ExecuteAsync(LayoutPrincipal
       ,procedure
        begin
          //Envia o pagamento para o Webservice.
          DataModuleGeral.SendPayment(Format('%s%s',[EditPlateLetters.Text, EditPlateNumbers.Text])
                                     ,Time
                                     ,Self);
        end
    );
  end
  else
  begin
    //Nesse caso, executa a ativa��o do t�quete na Thread principal(corrente).
    //Envia o pagamento para o Webservice.
    DataModuleGeral.SendPayment(Format('%s%s',[EditPlateLetters.Text, EditPlateNumbers.Text])
                               ,Time
                               ,Self);
  end;
end;

procedure TFormParking.BeginComponents;
begin
  try
    //Verifica se existe um usu�rio logado.
    if (DataModuleGeral.IsUserLogged) then
    begin
      //Atualiza a consulta de cr�ditos do usu�rio logado.
      DataModuleGeral.OpenQueryCreditsUser;
    end;

    //Atualiza a consulta de pre�o.
    DataModuleGeral.OpenQueryPrice;

    //Atualiza a interface na Thread principal.
    TThread.Synchronize(nil
     ,procedure
      begin
        //Atribui valores iniciais a alguns campos.
        Time := DataModuleGeral.GetMinTime;

        //Verifica se � um novo t�quete.
        if not(IsRenew) then
        begin
          //Atribui aos campos de placa usando o �ltimo t�quete pago.
          EditPlateLetters.Text    := Copy(DataModuleGeral.GetLastPlate(), 1, 3);
          EditPlateNumbers.Text    := Copy(DataModuleGeral.GetLastPlate(), 4, 4);
        end;

        //Atualiza os valores dos campos.
        UpdateValuesComponents();
      end);
  except
    on Error: Exception do
    begin
      TThread.Synchronize(nil
       ,procedure
        begin
          //Exibe a mensagem do erro para o usu�rio.
          ShowMessage(Error.Message);
        end);
    end;
  end;
end;

procedure TFormParking.ButtonActiveTicketsClick(Sender: TObject);
var
DialogBuyCredits: TFormDialogBuyCredits;
begin
  try
    //Valida os valores dos componentes.
    ValidateValuesComponents;

    //Verifica se � um usu�rio avulso ou se o usu�rio logado tem valor suficiente para
    //adquirir o t�quete.
    if (not(DataModuleGeral.IsUserLogged)
    or (ValueTotal <= DataModuleGeral.GetCreditsUser)) then
    begin
      //Ativa o novo t�quete.
      ActiveTicket;
    end
    else
    begin
      //Exibe o formul�rio de compra de cr�dito para o usu�rio adquirir os cr�ditos restante.
      DialogBuyCredits := TFormDialogBuyCredits.Create(Self);
      DialogBuyCredits.SetCreditsForBuy(ValueTotal - DataModuleGeral.GetCreditsUser);
      DialogBuyCredits
              .ShowModal(
                 procedure (ModalResult: TModalResult)
                 begin
                    try
                      //Verifica se o resultado � mrOk.
                      if (ModalResult = mrOk) then
                      begin
                        //Fecha o di�logo.
                        DialogBuyCredits.Close;

                        //Ativa o novo t�quete.
                        ActiveTicket;
                      end;
                    finally
                      //Desaloca o di�logo de compra da mem�ria.
                      DialogBuyCredits.Release;
                    end;
                 end
              );
    end;
  except
    on Error: Exception do
    begin
      //Exibe a mensagem do erro para o usu�rio.
      ShowMessage(Error.Message);
    end;
  end;
end;

procedure TFormParking.EditPlateLettersChange(Sender: TObject);
begin
  SetTextUpperCaseEditChange(Sender);
end;

procedure TFormParking.EditPlateLettersKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  //Permite apenas a digita��o de letras no campo editPlateLatters.
  AllowJustLettersEditKeyDown(Sender, Key, KeyChar, Shift);
end;

procedure TFormParking.EditPlateNumbersChange(Sender: TObject);
begin
  //Permite apenas a digita��o de n�meros no campo editPlateNumbers.
  editPlateNumbers.Text := GetJustNumbersOfString(editPlateNumbers.Text);
end;

procedure TFormParking.FormShow(Sender: TObject);
begin
  //Se n�o existir um usu�rio logado, oculta os cr�ditos dispon�veis.
  LayoutCreditsAvailable.Visible := DataModuleGeral.IsUserLogged;

  //Inicializa os componentes em uma Thread paralela.
  ExecuteAsync(LayoutPrincipal
   ,procedure
    begin
      //Inicializa os componentes.
      BeginComponents;
    end);
end;

procedure TFormParking.OnSucess;
begin
  //Executa na Thread principal.
  TThread.Synchronize(nil
    ,procedure
     begin
        //Exibe uma mensagem de sucesso para o usu�rio.
        ShowMessage('Pagamento realizado!');

        //O formul�rio � fechado.
        ModalResult := mrOk;
     end);
end;

procedure TFormParking.RenewTicket(Plate: String; DeadlineTime: TDateTime);
begin
  //Atribui a placa passada aos campos relacionados a placa.
  EditPlateLetters.Text := Copy(Plate, 1, 3);
  EditPlateNumbers.Text := Copy(Plate, 4, 4);

  //Atualiza os atributos de limite e indicador de renova��o.
  Self.IsRenew      := True;
  Self.DeadlineTime := DeadlineTime;

  //Busca na base local o tempo j� adquirido do t�quete a ser renovado.
  if (DataModuleGeral.IsUserLogged) then
  begin
    //Localiza o tempo do t�quete na consulta retornada pelo WebService.
    DataModuleGeral.DataSetTickets.Locate('Plate;IconIndex'
                                          ,VarArrayOf([Plate, '1'])
                                          ,[]);
    Self.TimeAlreadyPaid := DataModuleGeral.DataSetTicketsTime.AsInteger;
  end
  else
  begin
    //Localiza o tempo na base local.
    DataModuleLocal.DataSetTickets.Locate('Plate;IconIndex'
                                          ,VarArrayOf([Plate, '1'])
                                          ,[]);
    Self.TimeAlreadyPaid := DataModuleLocal.DataSetTickets.FieldByName('Time').AsInteger;
  end;

  //Verifica se o usu�rio j� adquiriu o tempo m�ximo permitido.
  if (Self.TimeAlreadyPaid = DataModuleGeral.GetMaxTime) then
  begin
    //Levanta uma exce��o informando que o tempo m�ximo permitido j� foi adquirido.
    raise Exception.Create('Tempo m�ximo permitido j� foi adquirido para este ve�culo');
  end;
end;

procedure TFormParking.SpinnerTimerOutSelectedValueChanged(Sender: TObject;
  Column: Integer; SelectedValue: Double; RangeType: TTMSFMXSpinnerRangeType);
begin
  //Valida se o tempo digitado satisfaz o intervalo do tempo m�nimo e m�ximo.
  Time := MinutesBetween(BeginTime, SpinnerTimerOut.Columns.Items[0].SelectedDateTime);
  Time := Max(Time, DataModuleGeral.GetMinTime);
  Time := Min(Time, DataModuleGeral.GetMaxTime);

  //Valida se o tempo satisfaz a unidade de tempo.
  Time := Round(Time / DataModuleGeral.GetUnitTime) * DataModuleGeral.GetUnitTime;

  //Atualiza os valores dos componentes referente a cr�ditos.
  UpdateValuesLabels;
end;

procedure TFormParking.OnError(Msg: String);
begin
  //Executa na Thread principal.
  TThread.Synchronize(nil
    ,procedure
     begin
        //Exibe a mensagem do erro para o usu�rio.
        ShowMessage(Msg);
     end);
end;

procedure TFormParking.TimerUpdateValuesTimer(Sender: TObject);
begin
  //Atualiza os valores dos componentes.
  UpdateValuesComponents;
end;

procedure TFormParking.UpdateValuesComponents;
var
ColumnSpinner : TTMSFMXColumn;
begin

  //Verifica se � uma renova��o de vaga.
  if (IsRenew) and (DeadlineTime > Now) then
  begin
    //O tempo inicial ser� o tempo de limite do t�quete a ser renovado.
    BeginTime    := DeadlineTime;
  end
  else
  begin
    //Para novos t�quetes o tempo inicial ser� a do dispositivo.
    BeginTime    := Date;
    BeginTime    := IncMinute(BeginTime, MinuteOf(Now));
    BeginTime    := IncHour(BeginTime, HourOf(Now));
  end;

  //Atualiza o Spinner de tempo.
  ColumnSpinner := SpinnerTimerOut.Columns.Items[0];
  ColumnSpinner.DateRangeFrom := IncMinute(BeginTime, DataModuleGeral.GetMinTime);
  ColumnSpinner.DateRangeTo   := IncMinute(BeginTime, DataModuleGeral.GetMaxTime - TimeAlreadyPaid);
  ColumnSpinner.Step          := DataModuleGeral.GetUnitTime;

  //Atualiza os valores dos labels.
  UpdateValuesLabels();
end;

procedure TFormParking.UpdateValuesLabels;
begin
  //Atualiza os valores dos campos do formul�rio.
  lblCreditsAvailable.Text := 'R$ '+FormatValue(DataModuleGeral.GetCreditsUser());
  ValueTotal               := Time
                              * DataModuleGeral.GetPriceTime()
                              * (1 - (DataModuleGeral.GetDiscountPrice/100));
  lblCreditsPay.Text       := 'R$ '+FormatValue(ValueTotal);
end;

procedure TFormParking.ValidateValuesComponents;
begin
  //Valida se foi informado todos os valores dos componentes.
  Focused := nil;
  EditPlateNumbers.Text := GetJustNumbersOfString(editPlateNumbers.Text);
  ValidateValueComponent(editPlateLetters, editPlateLetters.Text, 'Informe as letras da placa.', 3);
  ValidateValueComponent(editPlateNumbers, editPlateNumbers.Text, 'Informe os n�meros da placa.', 4);
end;

end.
