unit UStart;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  System.ImageList, Vcl.ImgList, UWelcome, UCustiomize, IniFiles;

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
  //set values to the settings frame
  FrameCust.Initialise();

  //choose starting panel and frame
  CurPnlBtn := pnlDiagBtn;
  CurFrame := FrameWelcome;

  //create array of buttons and frames
  FrameArr[1]:=FrameWelcome;
  FrameArr[2]:=FrameCust;
  BtnArr[1]:=pnlDiagBtn;
  BtnArr[2]:=pnlCustBtn;

  //imitate button press
  pnlBtnClick(pnlDiagBtn);
end;

procedure TFormStart.pnlBtnClick(Sender: TObject);
var
  n: Integer;
begin
  //change color of the previous panel
  CurPnlBtn.Color := clBtnFace;
  CurPnlBtn.Font.Color := clBlack;

  //change color of the chosen panel
  (Sender as TPanel).Color := $00BF7526;
  (Sender as TPanel).Font.Color := clWhite;

  CurPnlBtn := (Sender as TPanel);

  //hide previous frame
  CurFrame.Hide;

  n:=1;

  while BtnArr[n]<>CurPnlBtn do
    inc(n);

  //show current frame
  FrameArr[n].Show;
  CurFrame:=FrameArr[n];
end;

end.
