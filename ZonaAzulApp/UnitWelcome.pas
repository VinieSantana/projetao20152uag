unit UnitWelcome;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts
  , UnitCadastreUser, FMX.Controls.Presentation,
  FMX.StdCtrls, UnitLogin, FMX.VirtualKeyboard, FMX.Platform;

type
  TFormWelcome = class(TForm, ICadastreListener, ILoginListener)
    LayoutFrame: TLayout;
    LayoutButtons: TLayout;
    Layout3: TLayout;
    ButtonCadastreUser: TSpeedButton;
    Layout4: TLayout;
    ButtonStart: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure ButtonCadastreUserClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ButtonStartClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
  private
    { Private declarations }
    FrameCadastreNewUser : TFrameCadastreUser;
    FrameLogin : TFrameLogin;
    VisibleFrame: TFrame;
  public
    { Public declarations }
    procedure Show(Frame : TFrame; Parent: TFmxObject);
    procedure ShowLoginFrame;
    procedure ShowMainForm;
    procedure OnSucess;
    procedure OnCancel;
  end;

var
  FormWelcome: TFormWelcome;

implementation

{$R *.fmx}

uses UnitDataModuleGeral, UnitMain, UnitRoutines;

procedure TFormWelcome.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  {$IFDEF Win32 or Win64}
  //Verifica se o frame exibido n�o � o de login.
  if (VisibleFrame <> FrameLogin) then
  begin
    //Exibe o frame de login.
    ShowLoginFrame;

    //N�o permite fechar o aplicativo.
    CanClose := False;
  end;
  {$ENDIF}
end;

procedure TFormWelcome.FormCreate(Sender: TObject);
begin
  //Instancia os frames de login e cadastro de usu�rio.
  FrameCadastreNewUser := TFrameCadastreUser.Create(Self, Self, True);
  FrameLogin           := TFrameLogin.Create(Self, Self);

  //Exibe o frame de login.
  Show(FrameLogin, LayoutFrame);
end;

procedure TFormWelcome.FormKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
var
  FService : IFMXVirtualKeyboardService;
begin
  {$IFDEF Android or iOS}
  TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService, IInterface(FService));
  if (FService = nil) or not(TVirtualKeyboardState.Visible in FService.VirtualKeyBoardState) then
  begin
    //Verifica se foi pressionado o bot�o voltar(Back).
    if (Key = vkHardwareBack) then
    begin
      //Exibe o frame de login.
      Show(FrameLogin, LayoutFrame);
      Key := 0;
    end;
  end;
  {$ENDIF}
end;

procedure TFormWelcome.ShowLoginFrame;
begin
  //Remove do layout principal o frame ativo.
  VisibleFrame.Parent := nil;

  //Exibe o Frame de login.
  Show(FrameLogin, LayoutFrame);
end;

procedure TFormWelcome.OnCancel;
begin
  //Exibe o Frame de Login.
  ShowLoginFrame;
end;

procedure TFormWelcome.OnSucess;
begin
  //Exibe o formul�rio principal do aplicativo.
  ShowLoginFrame;
  ShowMainForm;
end;

procedure TFormWelcome.Show(Frame: TFrame; Parent: TFmxObject);
begin
  //Verifica se existe um Frame sendo exibido.
  if (VisibleFrame <> nil) then
  begin
    //Oculta o frame atualmente sendo exibido.
    VisibleFrame.Parent := nil;
  end;

  //Exibe o frame no layout principal.
  Frame.Parent := Parent;
  VisibleFrame := Frame;

  //Se o Frame exibido for o de login, exibe o layout de bot�es.
  //Oculta o layout de bot�es.
  LayoutButtons.Visible     := (Frame = FrameLogin);
end;

procedure TFormWelcome.ButtonCadastreUserClick(Sender: TObject);
begin
  //Exibe o frame de cadastro de usu�rio.
  Show(FrameCadastreNewUser, LayoutFrame);
end;

procedure TFormWelcome.ButtonStartClick(Sender: TObject);
begin
  //Inicia o formul�rio principal.
  ShowMainForm();
end;

procedure TFormWelcome.ShowMainForm;
begin
  //Instancia o formul�rio principal.
  FormMain := TFormMain.Create(Application);

  //Oculta o formul�rio de boas vindas.
  Hide;

  //Exibe o formul�rio principal.
  UnitRoutines.Show(FormMain);

  //Fecha o formul�rio de boas vindas.
  //Close;
end;

end.
