unit UEditBlocks;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, HelpTypes;

type
  TFrameEditBlocks = class(TFrame)
    EditHeight: TEdit;
    LabelHeight: TLabel;
    UpDownHeight: TUpDown;
    LabelWidth: TLabel;
    EditWidth: TEdit;
    UpDownWidth: TUpDown;
    procedure UpDownChanging(Sender: TObject; var AllowChange: Boolean);
    procedure EditHeightKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);


  private
    { Private declarations }
  public
    { Public declarations }
  end;
  procedure ReSizeAll(w, h: Integer);
  procedure ReSizeTree(bl: pBlock; w, h: Integer);

implementation

Uses UMain;

{$R *.dfm}

procedure TFrameEditBlocks.EditHeightKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  inputData: String;
  ErrorCode, res: Integer;
  CurUd: TUpDown;
begin
  if (Key = 13) then
  begin
    if (Sender as TEdit) = EditHeight then
      CurUD:=UpDownHeight
    else
      CurUD:=UpDownWidth;

    inputData:=(Sender as TEdit).text;
    val(InputData, res, ErrorCode);
    if (ErrorCode = 0) and (Res in [CurUD.Min..CurUD.Max]) then
    begin
      CurUD.Position:=res;
      (Sender as TEdit).Text:=IntToStr(res);
      ReSizeAll(UpDownWidth.Position, UpDownHeight.Position);
      StructuriseBlocks(Blocks);
      FormMain.PaintField.Invalidate();
    end
    else
    begin
      (Sender as TEdit).text:=IntToStr(CurUD.Position);
    end;
  end;
end;

procedure TFrameEditBlocks.UpDownChanging(Sender: TObject; var AllowChange: Boolean);
var
  temp: pAllBlocks;
begin
  temp := Blocks;
  ReSizeAll(UpDownWidth.Position, UpDownHeight.Position);
  StructuriseBlocks(Blocks);
  FormMain.PaintField.Invalidate();
end;


procedure ReSizeAll(w, h: Integer);
var
  temp: pAllBlocks;
begin
  temp := Blocks;

  while temp.Next <> Nil do
  begin
    temp := temp.Next;
    ReSizeTree(temp.Block, w, h);
  end;

end;

procedure ReSizeTree(bl: pBlock; w, h: Integer);
var
  temp: pBlock;
begin
  if bl <> nil then
  begin
    bl.h := h;

    bl.w := w;

    temp := bl;
    for var i := 0 to High(temp.Next) do
    begin
      temp := bl.Next[i];
      ReSizeTree(temp, w, h);
    end;
  end;
end;


end.
