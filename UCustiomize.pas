unit UCustiomize;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.ActnMan, Vcl.ActnColorMaps, Vcl.Imaging.jpeg,
  Vcl.Buttons, IniFiles;

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
    procedure SaveValues();
    procedure Button1Click(Sender: TObject);
    procedure Initialise();
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation
Uses UMain;

{$R *.dfm}

procedure TFrameCust.Button1Click(Sender: TObject);
begin
  SaveValues();
end;


procedure TFrameCust.Initialise();
var
  f: TIniFile;
begin
  f:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'\Settings.ini');

  if not f.SectionExists('Main') then
  begin
    f.writeInteger('Main','Block width',120);
    f.writeInteger('Main','Block height',60);
    f.writeInteger('Main','Horizontal distance',60);
    f.writeInteger('Main','Vertical distance',60);
    f.writeInteger('Main','Highlight color',clHighLight);
    f.writeInteger('Main','Hint color',clGrayText);
  end;

  UpDownWidth.Position:=f.ReadInteger('Main','Block width', 120);
  UpDownHeight.Position:=f.ReadInteger('Main','Block height', 60);


  UpDownHor.Position:=f.ReadInteger('Main','Horizontal distance', 60);
  UpDownVert.Position:=f.ReadInteger('Main','Vertical distance', 60);

  EditHLColor.text:=IntToStr(f.ReadInteger('Main','Highlight color',clHighLight));
  shpShowHLColor.Brush.Color:=StrToInt(EditHLColor.text);
  EditHBColor.text:=IntToStr(f.ReadInteger('Main','Hint color',clGrayText));
  shpShowHBColor.Brush.Color:=StrToInt(EditHBColor.text);

  f.free;
end;



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

procedure fillField(s,fieldName: String; var flag: Boolean; f: TIniFile);
var
  Cor: Boolean;
  ErrorCode, Num: Integer;
begin
  Cor:=True;
  val(s,Num,ErrorCode);
  Cor:=Cor and (ErrorCode = 0);
  if (ErrorCode = 0) then
    f.WriteInteger('Main',fieldName,Num);

end;


procedure TFrameCust.SaveValues();
var
  Cor: Boolean;
  ErrorCode, Num: Integer;
  f: TIniFile;
begin
  f:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'\Settings.ini');
  Cor:=True;
  fillField(EditWidth.text,'Block width',Cor,f);
  fillField(EditHeight.text,'Block height',Cor,f);

  fillField(EditHor.text,'Horizontal distance',Cor,f);
  fillField(EditVert.text,'Vertical distance',Cor,f);

  fillField(EditHLColor.text,'Highlight color',Cor,f);
  fillField(EditHBColor.text,'Hint color',Cor,f);

  if Cor then
  begin
    FormMain.SetDefaultValues();
    MessageBox(handle,'The changes were applied','Success',mb_OK);
  end
  else
    MessageBox(handle,'Incorrect data. Repeat the input','Error',mb_OK);
end;



end.
