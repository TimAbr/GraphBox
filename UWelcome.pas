unit UWelcome;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  System.ImageList, Vcl.ImgList, Vcl.ExtCtrls;

type
  TFrameWelcome = class(TFrame)
    Label3: TLabel;
    Label2: TLabel;
    Label1: TLabel;
    BtnNew: TButton;
    BtnOpen: TButton;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    ImageList1: TImageList;
    procedure BtnNewClick(Sender: TObject);
    procedure BtnOpenMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation
Uses UMain, UStart;

{$R *.dfm}

procedure TFrameWelcome.BtnNewClick(Sender: TObject);
begin
  FormMain.ShowModal();
end;


procedure TFrameWelcome.BtnOpenMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FormMain.ShowModal();
end;

end.
