unit UCustiomize;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.ActnMan, Vcl.ActnColorMaps, Vcl.Imaging.jpeg,
  Vcl.Buttons;

type
  TFrameCust = class(TFrame)
    StaticText1: TStaticText;
    EditWidth: TLabeledEdit;
    EditHeight: TLabeledEdit;
    StaticText2: TStaticText;
    EditHor: TLabeledEdit;
    EditVert: TLabeledEdit;
    UpDownHeight: TUpDown;
    UpDownHor: TUpDown;
    UpDownVert: TUpDown;
    UpDownWidth: TUpDown;
    StaticText3: TStaticText;
    ColorDialog1: TColorDialog;
    HLColorBtn: TImage;
    EditHLColor: TEdit;
    StaticText4: TStaticText;
    HBColorBtn: TImage;
    EditHBColor: TEdit;
    shpShowHlColor: TShape;
    shpShowHBColor: TShape;
    Button1: TButton;
    procedure HLColorBtnClick(Sender: TObject);
    procedure HBColorBtnClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TFrameCust.HBColorBtnClick(Sender: TObject);
begin
  if ColorDialog1.Execute() then
  begin
    EditHBColor.Text:=IntToStr(ColorDialog1.Color);
    shpShowHBColor.Brush.Color:=ColorDialog1.Color;
  end;
end;

procedure TFrameCust.HLColorBtnClick(Sender: TObject);
begin
  if ColorDialog1.Execute() then
  begin
    EditHLColor.Text:=IntToStr(ColorDialog1.Color);
    shpShowHLColor.Brush.Color:=ColorDialog1.Color;
  end;

end;



end.
