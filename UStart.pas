unit UStart;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TFormStart = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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
  FormStart.Hide();
  FormMain.Show();
end;

procedure TFormStart.Button3Click(Sender: TObject);
begin
  close;
end;

procedure TFormStart.FormCreate(Sender: TObject);
begin
  //FormMain.Hide;
  FormStart.Show;
end;

end.
