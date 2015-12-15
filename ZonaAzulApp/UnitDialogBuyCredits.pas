unit UnitDialogBuyCredits;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  UnitBuyCredits, FMX.StdCtrls;

type
  TFormDialogBuyCredits = class(TForm, IBuyListener)
    LayoutPrincipal: TLayout;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    var
    FrameBuyCredits: TFrameBuyCredits;
  public
    { Public declarations }
    procedure SetCreditsForBuy(Value: Double);
    procedure OnSucess;
  end;

var
  FormDialogBuyCredits: TFormDialogBuyCredits;

implementation

{$R *.fmx}

uses UnitDataModuleGeral;

procedure TFormDialogBuyCredits.FormCreate(Sender: TObject);
begin
  //Instancia o frame de compra de cr�ditos.
  FrameBuyCredits := TFrameBuyCredits.Create(Self);
  FrameBuyCredits.SetBuyListener(Self);

  //Adiciona o frame de compra de cr�ditos no layout principal do formul�rio.
  FrameBuyCredits.Parent := LayoutPrincipal;
end;

procedure TFormDialogBuyCredits.FormShow(Sender: TObject);
begin
  //Atualiza os campos do frame de compra de cr�ditos.
  FrameBuyCredits.BeginComponents(False);
end;

procedure TFormDialogBuyCredits.OnSucess;
begin
  //Fecha o di�logo(formul�rio) de compra de cr�dito.
  ModalResult := mrOk;
end;

procedure TFormDialogBuyCredits.SetCreditsForBuy(Value: Double);
begin
  //Atribui ao componente da compra o valor de cr�dito a ser adquirido.
  FrameBuyCredits.SetCreditsForBuy(Value);
end;

end.
