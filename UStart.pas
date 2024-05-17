unit UStart;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  System.ImageList, Vcl.ImgList, UWelcome, UCustiomize;

type
  TFormStart = class(TForm)
    Panel1: TPanel;
    pnlDiagBtn: TPanel;
    Panel4: TPanel;
    pnlCustBtn: TPanel;
    Button3: TButton;
    StaticText3: TStaticText;
    Label4: TLabel;
    Image1: TImage;
    FrameWelcome: TFrameWelcome;
    FrameCust: TFrameCust;
    procedure Button3Click(Sender: TObject);
    procedure pnlBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormStart: TFormStart;
  CurPnlBtn: TPanel;
  CurFrame: TFrame;

implementation

{$R *.dfm}

uses UMain;
const
  numSections = 2;
var
  FrameArr: Array[1..2] of TFrame;
  BtnArr: Array[1..2] of TPanel;

procedure TFormStart.Button3Click(Sender: TObject);
begin
  close;
end;

procedure TFormStart.FormCreate(Sender: TObject);
begin
  CurPnlBtn := pnlDiagBtn;
  CurFrame := FrameWelcome;
  FrameArr[1]:=FrameWelcome;
  FrameArr[2]:=FrameCust;
  BtnArr[1]:=pnlDiagBtn;
  BtnArr[2]:=pnlCustBtn;
  pnlBtnClick(pnlDiagBtn);
end;

procedure TFormStart.pnlBtnClick(Sender: TObject);
var
  n: Integer;
begin
  CurPnlBtn.Color := clBtnFace;
  CurPnlBtn.Font.Color := clBlack;

  (Sender as TPanel).Color := $00BF7526;
  (Sender as TPanel).Font.Color := clWhite;

  CurPnlBtn := (Sender as TPanel);

  CurFrame.Hide;

  n:=1;

  while BtnArr[n]<>CurPnlBtn do
    inc(n);

  FrameArr[n].Show;
  CurFrame:=FrameArr[n];



end;

end.
