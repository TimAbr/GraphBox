unit UStart;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  System.ImageList, Vcl.ImgList;

type
  TFormStart = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Button3: TButton;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    ImageList1: TImageList;
    StaticText3: TStaticText;
    Label4: TLabel;
    Image1: TImage;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormStart: TFormStart;

implementation

{$R *.dfm}

uses UMain;

procedure TFormStart.Button1Click(Sender: TObject);
begin
  FormMain.ShowModal();
end;

procedure TFormStart.Button3Click(Sender: TObject);
begin
  close;
end;





end.
