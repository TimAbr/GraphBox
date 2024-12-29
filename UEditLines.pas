unit UEditLines;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, HelpTypes;

type
  TFrameEditLines = class(TFrame)
    EditVert: TEdit;
    LabelHeight: TLabel;
    UpDownVertical: TUpDown;
    LabelWidth: TLabel;
    EditHor: TEdit;
    UpDownHorizontal: TUpDown;
    procedure UpDownChanging(Sender: TObject; var AllowChange: Boolean);
    procedure EditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation
Uses UMain;

{$R *.dfm}


procedure TFrameEditLines.EditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);

var
  inputData: String;
  ErrorCode, res: Integer;
  CurUd: TUpDown;
begin
  if Key = 13 then
  begin
    if (Sender as TEdit) = EditVert then
      CurUD:=UpDownVertical
    else
      CurUD:=UpDownHorizontal;

    inputData:=(Sender as TEdit).text;
    val(InputData, res, ErrorCode);

    if (ErrorCode = 0) and (Res in [CurUD.Min..CurUD.Max]) then
    begin
      CurUD.Position:=res;
    end
    else
      (Sender as TEdit).text:=IntToStr(CurUD.Position);

    StructuriseBlocks(Blocks);
    FormMain.PaintField.Invalidate();
  end;
end;

procedure TFrameEditLines.UpDownChanging(Sender: TObject; var AllowChange: Boolean);
begin
  StructuriseBlocks(Blocks);
  FormMain.PaintField.Invalidate();
end;


end.
