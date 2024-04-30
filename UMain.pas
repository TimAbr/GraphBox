unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus,
  Vcl.ComCtrls, Vcl.ToolWin, Vcl.Imaging.pngimage, Vcl.CheckLst, Vcl.Buttons,
  HelpTypes, UEditBlocks;

type

  TFormMain = class(TForm)
    MainMenu1: TMainMenu;
    Edit2: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;

    Panel1: TPanel;
    Button1: TButton;
    MenuPanel: TPanel;
    EditFontSize: TEdit;
    Label1: TLabel;
    Image1: TImage;
    UpDown1: TUpDown;
    Field: TScrollBox;
    ChangeFontStyle: TComboBox;
    SaveDialog1: TSaveDialog;
    InstrumentPanel: TPanel;
    Label2: TLabel;
    ShapePanel: TPanel;
    HighLightBlock: TShape;
    PaintField: TPaintBox;
    FrameEditBlocks: TFrameEditBlocks;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;

    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BlockMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BlockMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BlockMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure StartBlockDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure StartBlockDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure PaintFieldPaint(Sender: TObject);
    procedure ShapePanelStartDrag(Sender: TObject; var DragObject: TDragObject);

  private

    flag: Boolean;
  public
    { Public declarations }
  end;

procedure MoveAllBlocks(bl: pBlock; X, Y: Integer);
function FindMinDist(X, Y: Integer; main: pointer): pBlock;
procedure FindMinDistInTree(bl: pBlock; X, Y: Integer; var Min: Real;
  var res: pBlock; main: pBlock);


var
  FormMain: TFormMain;
  Blocks: pAllBlocks;
  EditText: TProEdit;
  CurHighLightedBlock: pBlock;
  x0, y0: Integer;
  curBlock: pBlock;

implementation

{$R *.dfm}

Uses UStart;

procedure IsInNext(cur, source: pBlock;var Flag: Boolean);
var
  temp: pBlock;
begin
  if (cur <> nil) and (not Flag) then
  begin
    if cur=source then
      Flag:=True;

    temp := cur;
    for var i := 0 to High(temp.Next) do
    begin
      temp := cur.Next[i];
      IsInNext(temp, source, Flag);
    end;
  end;
end;


procedure MoveAllBlocks(bl: pBlock; X, Y: Integer);
var
  temp: pBlock;
begin
  if bl <> nil then
  begin
    bl.y := bl.y - y0 + Y;
    bl.x := bl.x - x0 + X;

    temp := bl;
    for var i := 0 to High(temp.Next) do
    begin
      temp := bl.Next[i];
      MoveAllBlocks(temp, X, Y);
    end;
  end;
end;

procedure DrawTree(bl: pBlock);
var
  temp: pBlock;
begin
  if bl <> nil then
  begin
    DrawBlock(bl);

    temp := bl;
    for var i := 0 to High(temp.Next) do
    begin
      temp := bl.Next[i];
      DrawTree(temp);
    end;
  end;
end;

procedure DrawAllBlocks();
var
  temp: pAllBlocks;
begin
  temp := Blocks;
  while temp.Next <> Nil do
  begin
    temp := temp.Next;
    DrawTree(temp.Block);
  end;
  if CurBlock<>nil then
    DrawTree(CurBlock);

end;

procedure TFormMain.PaintFieldPaint(Sender: TObject);
begin
  DrawAllBlocks();
end;


Procedure ConnectBlocks(blmain,bl:pBlock);
var
  movx, movy: Integer;
  tg:real;
begin
  tg:=abs(((bl.x+bl.w div 2)-(blmain.x+blmain.w div 2))/((bl.y+bl.h div 2)-(blmain.y+blmain.h div 2)));
  case blMain.Shape of
  stRectangle, stCycle:
  begin
    if ((blmain.w div 2)/tg < blmain.h div 2) or ((blmain.y+blmain.h div 2)>=(bl.y+bl.h div 2)) then
    begin
      movx:=blmain.w+100;
      movy:=0;
    end
    else
    begin
      movy:=blmain.h+100;
      movx:=(blmain.w-bl.w) div 2;
    end
  end;
  stDecision:
  if ((blmain.y+blmain.h div 2)<=(bl.y+bl.h div 2)) then
  begin
    movx:=blmain.w+100;
    movy:=0;
  end
  else if tg>0.71 then
  begin
    movx:=blmain.w+100;
    movy:=blmain.h+100;
  end
  else
  begin
    movy:=blmain.h+100;
    movx:=(blmain.w-bl.w) div 2;
  end;

  end;

  moveAllBlocks(bl,movx-(bl.x-blmain.x)+x0, movy-(bl.y-blmain.y)+y0)
end;

procedure TFormMain.Button1Click(Sender: TObject);
begin
  close;
end;

procedure FindBlockInTree(bl: pBlock; x, y: Integer; var res: pBlock);
var
  temp: pBlock;
begin
  if (bl <> nil) and (res=nil) then
  begin
    case bl.Shape of

      stRectangle..stCycle:
      begin
        if (bl.x<=x) and (bl.y<=y) and (x<=bl.x+bl.w) and (y<=bl.y+bl.h) then
          res:=bl;
      end;

    end;
    if res=nil then
    begin
      temp := bl;
      for var i := 0 to High(temp.Next) do
      begin
        temp := bl.Next[i];
        FindBlockInTree(temp,x,y,res);
      end;
    end;
  end;
end;

function FindBlock(x,y:Integer):  pBlock;
var
  temp: pAllBlocks;
begin
  temp := Blocks;
  Result:=nil;
  while (temp.Next <> Nil) and (Result=nil) do
  begin
    temp := temp.Next;
    FindBlockInTree(temp.Block, x, y, Result);
  end;
end;

procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FormStart.Show();
end;

// initialisation of the form
procedure TFormMain.FormCreate(Sender: TObject);
var
  StartBlock: TStartBlock;
begin
  FormMain.Hide;
  FormStart.Show;
  flag := False;
  new(Blocks);
  Blocks.Next := nil;
  Blocks.Block := Nil;

  CurBlock:=nil;

  EditText := TProEdit.Create(FormMain);
  EditText.Parent := Field;
  EditText.Hide;

  FrameEditBlocks.UpDownHeight.Position := 75;
  FrameEditBlocks.UpDownWidth.Position := 75;

  HighLightBlock.Hide;
  CurHighLightedBlock := nil;

  for var i := 0 to 3 do
  begin

    StartBlock := TStartBlock.Create(ShapePanel);

    with StartBlock do
    begin

      Parent := ShapePanel;
      Shape := TShapeType(i);

      Width := ShapePanel.Width - 50;
      Height := Width;
      Left := 25;
      Top := 60 + (Width + 20) * i;

      dragMode := dmAutomatic;
    end;

  end;
end;

function FindMinDist(X, Y: Integer; main: pointer): pBlock;
var
  temp: pAllBlocks;
  curMin: Real;
begin
  curMin := MaxInt;
  temp := Blocks;
  Result := Nil;
  while temp.Next <> Nil do
  begin
    temp := temp.Next;
    FindMinDistInTree(temp.Block, X, Y, curMin, Result, main);
  end;

end;

procedure FindMinDistInTree(bl: pBlock; X, Y: Integer; var Min: Real;
  var res: pBlock; main: pBlock);
var
  temp: pBlock;
  tempDist: Real;
  Flag:Boolean;
begin
  if bl <> nil then
  begin
    Flag:=False;
    isInNext(main,bl,Flag);

    if not Flag then
      begin
      tempDist := sqrt(sqr(X - bl.x) + sqr(Y - bl.y));

      if (tempDist < Min) and (tempDist < 150) then
      begin
        if ((main<>nil) and (bl.x-10<=main.x)) or (main = nil) then
        begin
          Min := tempDist;
          res := bl;
        end;
      end;

      temp := bl;
      for var i := 0 to High(temp.Next) do
      begin
        temp := bl.Next[i];
        FindMinDistInTree(temp, X, Y, Min, res, main);
      end;
    end;
  end;
end;

procedure TFormMain.ShapePanelStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  CurHighLightedBlock:=nil;
  HighLightBlock.Hide;
end;

procedure TFormMain.StartBlockDragDrop(Sender, Source: TObject; X, Y: Integer);
Var
  AllDiagrams: pAllBlocks;
  temp:pBlock;
begin
  if CurHighLightedBlock = nil then
  begin
    AllDiagrams := Blocks;

    while AllDiagrams.Next <> nil do
      AllDiagrams := AllDiagrams.Next;

    new(AllDiagrams.Next);

    AllDiagrams := AllDiagrams.Next;
    AllDiagrams.Next := Nil;

    New(AllDiagrams.Block);

    temp:=AllDiagrams.Block;
    temp.Prev:=nil;

  end
  else
  begin
    New(CurHighLightedBlock.Next[0]);
    CurHighLightedBlock.Next[0].Prev:=CurHighLightedBlock;
    temp:=CurHighLightedBlock.Next[0];
  end;

  with AllDiagrams^ do
  begin

    temp.Shape := (Source as TStartBlock).Shape;

    case temp.Shape of
      stRectangle, stCycle:
        begin
          SetLength(Temp.Next, 2);
        end;
      stDecision:
        begin
          SetLength(Temp.Next, 3);
        end;

    end;

    for var i := 0 to High(Temp.Next) do
      Temp.Next[i] := nil;


    temp.x := X;
    temp.y := Y;
    with temp^ do
    begin
      W := FrameEditBlocks.UpDownWidth.Position;
      H := FrameEditBlocks.UpDownHeight.Position;
      ownCanvas:= (Sender as TPaintBox).Canvas;
      Pen:=ownCanvas.Pen;
      Brush:=ownCanvas.Brush;
      Brush.Color:=clWhite;
      Pen.Color:=clBlack;
    end;

  end;

  temp.Text := 'Hello';

  with (Source as TStartBlock) do
  begin
    Left := 25;
    Top := 60 + (Ord(Shape)) * (Width + 20);
    flag := False;
    (Source as TStartBlock).Parent := ShapePanel;
  end;

  if temp.prev<>nil then
  begin
    ConnectBlocks(temp.prev, temp);
  end;

  PaintField.Invalidate();
end;

procedure TFormMain.StartBlockDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  if Sender = PaintField then
  begin
    Accept := True;

    if FindMinDist(X, Y, nil) <> nil then
    begin
      CurHighLightedBlock := FindMinDist(X, Y, nil);
      HighLightBlock.Show;
      HighLightBlock.Height := CurHighLightedBlock.H;
      HighLightBlock.Width := CurHighLightedBlock.W;
      HighLightBlock.Top := CurHighLightedBlock.y;
      HighLightBlock.Left := CurHighLightedBlock.x;
    end
    else
    begin
      CurHighLightedBlock := nil;
      HighLightBlock.Hide;
    end;

  end;

end;


procedure TFormMain.BlockMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

begin
  flag:=False;

  curblock:=findBlock(x,y);

  if (CurBlock<>nil) and (CurHighLightedBlock=CurBlock) then
  begin

    EditText.Show;

    EditText.Left := CurBlock.x;
    EditText.Top := CurBlock.y;
    EditText.Height := CurBlock.h;
    EditText.Width := CurBlock.h;

    EditText.prev := CurBlock;

    EditText.Text := CurBlock.Text;
    Flag:=False;
    CurBlock:=nil;
  end
  else
  begin

    if EditText.Visible then
    begin
      EditText.prev.text := EditText.Text;
      EditText.Hide;
    end;

    if (CurHighLightedBlock <> Nil) then
    begin
      HighLightBlock.Hide;
      CurHighLightedBlock := Nil;
    end;

    if CurBlock<>nil then
    begin
      flag := True;
      x0 := X;
      y0 := Y;
      if CurBlock.Prev<>nil then
      begin
        CurBlock.Prev.Next[0]:=nil;
        CurBlock.Prev:=nil;
      end;
    end;

  end;

end;

procedure TFormMain.BlockMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);

begin

  if flag then
  begin
    MoveAllBlocks(CurBlock, X, Y);
    y0:=y;
    x0:=x;
    CurHighLightedBlock := FindMinDist(CurBlock.x, CurBlock.y, CurBlock);

    if (CurHighLightedBlock <> nil) then
    begin
      HighLightBlock.Show;
      HighLightBlock.Height := CurHighLightedBlock.h;
      HighLightBlock.Width := CurHighLightedBlock.w;
      HighLightBlock.Top := CurHighLightedBlock.y;
      HighLightBlock.Left := CurHighLightedBlock.x;
    end
    else
    begin
      HighLightBlock.Hide;
    end;

    PaintField.Invalidate();
  end;

end;

procedure TFormMain.BlockMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

var
  allDiagrams, nextDiag:pAllBlocks;

begin

  if Flag then
  begin
    flag := False;
    AllDiagrams:=Blocks;
    if CurHighLightedBlock <> nil then
    begin
      CurHighLightedBlock.Next[0] := CurBlock;
      CurBlock.prev := CurHighLightedBlock;


      ConnectBlocks(CurBlock.prev, CurBlock);


      while (AllDiagrams.Next<>nil) and (AllDiagrams.Next.Block<>CurBlock) do
        AllDiagrams:=AllDiagrams.Next;

      if AllDiagrams.Next<>nil then
      begin
        nextDiag:=AllDiagrams.Next.Next;
        Dispose(AllDiagrams.Next);

        AllDiagrams.Next := NextDiag;
      end;

    end
    else
    begin
      while (AllDiagrams.Next<>nil) and (AllDiagrams.Next.Block<>CurBlock) do
        AllDiagrams:=AllDiagrams.Next;

      if AllDiagrams.Next=nil then
      begin

        new(AllDiagrams.Next);

        AllDiagrams := AllDiagrams.Next;
        AllDiagrams.Next := Nil;

        AllDiagrams.Block:=CurBlock;
      end;
    end;
    CurHighLightedBlock := CurBlock;
    HighLightBlock.Show;
    HighLightBlock.Height := CurHighLightedBlock.h;
    HighLightBlock.Width := CurHighLightedBlock.w;
    HighLightBlock.Top := CurHighLightedBlock.y;
    HighLightBlock.Left := CurHighLightedBlock.x;

    PaintField.Invalidate;
  end;
end;

end.
