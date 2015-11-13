unit UnitWelcome;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts
  , UnitCadastreUser, FMX.Controls.Presentation,
  FMX.StdCtrls, UnitLogin;

type
  TFormWelcome = class(TForm, ICadastreListener, ILoginListener)
    LayoutFrame: TLayout;
    LayoutButtons: TLayout;
    Layout3: TLayout;
    Layout5: TLayout;
    ButtonLogin: TSpeedButton;
    ButtonCadastreUser: TSpeedButton;
    Layout4: TLayout;
    ButtonStart: TSpeedButton;
    LayoutDescription: TLayout;
    LabelDescription: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ButtonCadastreUserClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonLoginClick(Sender: TObject);
  private
    { Private declarations }
    FrameCadastreNewUser : TFrameCadastreUser;
    FrameLogin : TFrameLogin;
    DisplayedFrame: TFrame;
  public
    { Public declarations }
    procedure Show(Frame : TFrame; Parent: TFmxObject);
    procedure HideDisplayedFrame;
    procedure ShowMainForm;
    procedure OnSucess;
  end;

var
  FormWelcome: TFormWelcome;

implementation

{$R *.fmx}

uses UnitDataModuleGeral, UnitMain, UnitRoutines;

procedure TFormWelcome.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  //Verifica se n�o existe um frame sendo exibido para o usu�rio - Cadastro ou Login.
  if not(LayoutButtons.Visible) then
  begin
    //Oculta o frame sendo exibido.
    HideDisplayedFrame;

    //N�o permite fechar o aplicativo.
    CanClose := False;
  end;
end;

procedure TFormWelcome.FormCreate(Sender: TObject);
begin
  //Instancia os frames de login e cadastro de usu�rio.
  FrameCadastreNewUser := TFrameCadastreUser.Create(Self, Self);
  FrameLogin           := TFrameLogin.Create(Self, Self);
end;

procedure TFormWelcome.HideDisplayedFrame;
begin
  //Remove do layout principal o frame ativo.
  DisplayedFrame.Parent := nil;

  //Exibe os layouts de bot�es e de descri��es.
  LayoutButtons.Visible := True;
  LayoutDescription.Visible := True;
end;

procedure TFormWelcome.OnSucess;
begin
  //Exibe o formul�rio principal do aplicativo.
  HideDisplayedFrame;
  ShowMainForm;
end;

procedure TFormWelcome.Show(Frame: TFrame; Parent: TFmxObject);
begin
  //Exibe o frame no layout principal.
  Frame.Parent := Parent;
  DisplayedFrame := Frame;

  //Oculta os layouts de descri��o e dos bot�es.
  LayoutDescription.Visible := False;
  LayoutButtons.Visible     := False;
end;

procedure TFormWelcome.ButtonCadastreUserClick(Sender: TObject);
begin
  //Exibe o frame de cadastro de usu�rio.
  Show(FrameCadastreNewUser, LayoutFrame);
end;

procedure TFormWelcome.ButtonLoginClick(Sender: TObject);
begin
  //Exibe o frame de login.
  Show(FrameLogin, LayoutFrame);
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
