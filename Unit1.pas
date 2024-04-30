unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    ScrollBox1: TScrollBox;
    PaintBox1: TPaintBox;
    procedure PaintBox1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
var
  x,y, width1:Integer;

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  x:=10;
  y:=10;
  width1:=100;
  Form1.Show;
end;

procedure TForm1.PaintBox1Click(Sender: TObject);
begin
  (Sender as TPaintBox).Canvas.Rectangle(x,y,x+width1, y+width1);
  x:=x+width1+10;
  if x>(Sender as TPaintBox).Width then
  begin
    (Sender as TPaintBox).Width:=x+100;
  end;

end;

end.
