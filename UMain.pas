unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus,
  Vcl.ComCtrls, Vcl.ToolWin, Vcl.Imaging.pngimage, Vcl.CheckLst, Vcl.Buttons,
  HelpTypes, UEditBlocks, UEditLines, UFiles, System.Actions, Vcl.ActnList,
  System.ImageList, Vcl.ImgList, Vcl.ActnMan, Vcl.ActnCtrls;

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
    FileName: TLabel;
    UpDown1: TUpDown;
    Field: TScrollBox;
    ChangeFontStyle: TComboBox;
    SaveDialog: TSaveDialog;
    InstrumentPanel: TPanel;
    Label2: TLabel;
    ShapePanel: TPanel;
    PaintField: TPaintBox;
    FrameEditBlocks: TFrameEditBlocks;
    ButtonBlocks: TSpeedButton;
    ButtonLines: TSpeedButton;
    FrameEditLines: TFrameEditLines;
    ActionList: TActionList;
    Save: TAction;
    SaveAs: TAction;
    Open: TAction;
    NewFile: TAction;
    ExportAsPng: TAction;
    ImageList1: TImageList;
    Saveas1: TMenuItem;
    N1: TMenuItem;
    ExportAsPng1: TMenuItem;
    OpenDialog: TOpenDialog;
    tbMain: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    SaveImageDialog: TSaveDialog;

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
    procedure BlockStartDrag(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ButtonBlocksClick(Sender: TObject);
    procedure ButtonLinesClick(Sender: TObject);
    procedure PaintFieldDblClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FieldMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SaveAsExecute(Sender: TObject);
    procedure SaveAsUpdate(Sender: TObject);
    procedure OpenExecute(Sender: TObject);
    procedure OpenUpdate(Sender: TObject);
    procedure ExportAsPngExecute(Sender: TObject);
    procedure ExportAsPngUpdate(Sender: TObject);
    procedure NewFileExecute(Sender: TObject);

  private

  public
    { Public declarations }
  end;

procedure MoveAllBlocks(bl: pBlock; X, Y: Integer);
function FindMinDist(X, Y: Integer; main: pointer): pBlock;
procedure FindMinDistInTree(bl: pBlock; X, Y: Integer; var Min: Real;
  var res: pBlock; main: pBlock);
procedure StructuriseBlocks();


var
  FormMain: TFormMain;
  Blocks: pAllBlocks;
  EditText: TProEdit;
  CurHighLightedBlock, HighLightBlock, HintBlock: pBlock;
  x0, y0, ConnectNum: Integer;
  curBlock: pBlock;
  flag: Boolean;
  HighLightColor, DefaultColor, HintBlockColor:Integer;
  HintBlockStyle: TPenStyle;
  Compact:Boolean;


implementation

{$R *.dfm}

Uses UStart;

// initialisation of the form
procedure TFormMain.FormCreate(Sender: TObject);
var
  StartBlock: TStartBlock;

begin
  flag := False;
  new(Blocks);
  Blocks.Next := nil;
  Blocks.Block := Nil;

  CurBlock:=nil;
  Compact:=True;

  EditText := TProEdit.Create(FormMain);
  EditText.Parent := Field;
  EditText.Hide;

  FrameEditBlocks.UpDownHeight.Position := 75;
  FrameEditBlocks.UpDownWidth.Position := 75;
  FrameEditLines.UpDownHorizontal.Position:=50;
  FrameEditLines.UpDownVertical.Position:=50;

  PaintField.width:=200;
  PaintField.height:=200;

  New(HighLightBlock);
  CurHighLightedBlock := nil;
  HighLightColor:=clHighLight;
  HighLightBlock.BorderColor:=HighLightColor;
  HighLightBlock.FillColor:=clWhite;
  HighLightBlock.ownCanvas:=PaintField.Canvas;
  HighLightBlock.Text:='';

  DefaultColor:=clBlack;

  HintBlock:=nil;
  New(HintBlock);
  HintBlock.Prev:=nil;

  PaintField.left:=0;
  PaintField.Top:=0;

  HintBlock.ownCanvas:=FormMain.PaintField.Canvas;
  HintBlock.w:=FormMain.FrameEditBlocks.UpDownWidth.Position;
  HintBlock.h:=FormMain.FrameEditBlocks.UpDownHeight.Position;

  HintBlockStyle:=psDash;
  HintBlockColor:=clGrayText;
  HintBlock.BorderColor:=HintBlockColor;
  HintBlock.FillColor:=clWhite;

  for var i := 0 to 4 do
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

      StartBlock.onMouseDown:=BlockStartDrag;

      Hint:='Pull me';
      ShowHint:=True;
    end;

  end;
  FileName.Caption:='';
end;



procedure TFormMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  num:Integer;
  AllDiagrams, nextDiag:pAllBlocks;
begin

 if (Key=$2e) and (CurhighLightedBlock<>nil) and not flag then
  begin
    AllDiagrams:=Blocks;

    while (AllDiagrams.Next<>nil) and (AllDiagrams.Next.Block<>CurHighLightedBlock) do
      AllDiagrams:=AllDiagrams.Next;

    if AllDiagrams.Next<>nil then
    begin
      nextDiag:=AllDiagrams.Next.Next;
      Dispose(AllDiagrams.Next);

      AllDiagrams.Next := NextDiag;
    end
    else
    begin
      num:=0;

      while CurHighLightedBlock.Prev.Next[num]<>CurHighLightedBlock do
        inc(num);

      CurHighLightedBlock.Prev.Next[num]:=nil;
    end;

    while (AllDiagrams.Next<>nil) do
      AllDiagrams:=AllDiagrams.Next;

    for num := Low(CurHighLightedBlock.Next) to High(CurHighLightedBlock.Next) do
    begin
      if CurHighLightedBlock.Next[num]<>nil then
      begin
        New(AllDiagrams.Next);
        AllDiagrams:=AllDiagrams.Next;
        AllDiagrams.Next:=nil;
        AllDiagrams.Block:=CurHighLightedBlock.Next[num];
        CurHighLightedBlock.Next[num].Prev:=nil;
        CurHighLightedBlock.Next[num]:=nil;
      end;
    end;
    Dispose(CurHighLightedBlock);
    CurHighLightedBlock:=nil;
    StructuriseBlocks();
    PaintField.Invalidate;
  end;

end;

procedure TFormMain.FormResize(Sender: TObject);
begin
  PaintField.Invalidate();
end;


procedure TFormMain.NewFileExecute(Sender: TObject);
begin
  DestroyAll(Blocks);
  Blocks:=nil;
  New(Blocks);
  Blocks.Next:=nil;
  Blocks.Block:=nil;
  PaintField.Invalidate;
end;

procedure TFormMain.OpenExecute(Sender: TObject);
var
  Arr: TArrBlocks;
  ArrPrev, ArrPos: TArrInt;
  len, n, ls, i:Integer;
  FName: String;
  temp: String[255];
  f:File;
  Start:pAllBlocks;
begin
  if (OpenDialog.Execute) then
  begin
    FName := OpenDialog.FileName;

    AssignFile(f,FName);
    Reset(f,1);

    FileName.Caption:=Copy(FName,1,length(FName)-3);

    DestroyAll(Blocks);

    Blocks:=nil;
    New(Blocks);
    Blocks.Next:=nil;

    BlockRead(f,n,4);
    Start:=Blocks;
    for var k := 1 to n do
    begin
      BlockRead(f,len,4);

      setlength(Arr,len);
      setlength(ArrPrev,len);
      setlength(ArrPos,len);

      for i := 0 to len-1 do
      begin
        New(Arr[i]);
        BlockRead(f, Arr[i]^, sizeOf(TBlock));
        Arr[i].ownCanvas:=PaintField.Canvas;
      end;

      for i := 0 to len-1 do
        BlockRead(f, ArrPrev[i], 4);

      for i := 0 to len-1 do
        BlockRead(f, ArrPos[i], 4);

      for i := 0 to len-1 do
      begin
        BlockRead(f,ls,4);
        setlength(temp,ls);
        BlockRead(f, temp, ls*2);

        Arr[i].Text:=temp;
      end;

      New(Blocks.Next);
      Blocks:=Blocks.Next;
      Blocks.Block:=ConverteToTree(Arr,ArrPrev,ArrPos);
      Blocks.Next:=nil;
    end;
    Blocks:=Start;
    StructuriseBlocks();
    PaintField.Invalidate();
  end;
end;

procedure TFormMain.OpenUpdate(Sender: TObject);
begin
  Open.Enabled:=True;
end;

procedure TFormMain.SaveAsExecute(Sender: TObject);
var
  Arr: TArrBlocks;
  ArrPrev, ArrPos: TArrInt;
  len, n, ls, i:Integer;
  FName: String;
  f:File;
  tempBlock:pAllBlocks;
  temp:String[255];
  tempArr: TNextArr;

begin
  if saveDialog.Execute then
  begin
    FName := SaveDialog.FileName;

    if LowerCase(Copy(FName,length(FName)-2))<>'.gb' then
    begin
      AssignFile(f,FName+'.gb');
      FileName.Caption:=FName;
    end
    else
    begin
      AssignFile(f,FName);
      FileName.Caption:=Copy(FName,1,length(FName)-3);
    end;
    Rewrite(f,1);

    tempBlock:=Blocks;
    n:=0;

    while tempBlock.Next<>nil do
    begin
      tempBlock:=tempBlock.Next;
      inc(n);
    end;

    BlockWrite(f, n, 4);
    tempBlock:=Blocks;

    for var k := 1 to n do
    begin
      tempBlock:=tempBlock.Next;

      len:=0;
      ConverteToMas(tempBlock.Block, Arr, ArrPrev,ArrPos,len);
      inc(len);

      BlockWrite(f, len, 4);

      for i := 0 to len-1 do
      begin
        temp:=Arr[i].Text;
        ls:=length(Arr[i].Text);

        Arr[i].Text:='';

        tempArr:=Arr[i].Next;
        Arr[i].Next:=nil;

        BlockWrite(f, Arr[i]^, sizeOf(TBlock));

        Arr[i].Next:=tempArr;
        Arr[i].text:=temp;
      end;

      for i := 0 to len-1 do
        BlockWrite(f, ArrPrev[i], 4);

      for i := 0 to len-1 do
        BlockWrite(f, ArrPos[i], 4);

      for i := 0 to len-1 do
      begin
        ls:=length(Arr[i].Text);
        BlockWrite(f, ls, 4);
        temp:=Arr[i].Text;
        BlockWrite(f, temp, ls*2);
      end;

    end;
    closefile(f);
  end;
end;

procedure TFormMain.SaveAsUpdate(Sender: TObject);
begin
  SaveAs.Enabled:=Blocks.Next<>nil;
end;

procedure TFormMain.ExportAsPngExecute(Sender: TObject);
var
  FName: String;
  BitMap: TBitMap;
  PNG: TPNGObject;
begin
  if saveImageDialog.Execute then
  begin
    BitMap:=TBitMap.Create;
    PNG:=TPNGObject.Create;
    BitMap.Height:=PaintField.Height;
    BitMap.width:=PaintField.width;

    BitMap.Canvas.CopyRect(Rect(0,0,BitMap.Height,BitMap.width),PaintField.Canvas,Rect(0,0,PaintField.Height,PaintField.width));
    PNG.Assign(BitMap);

    FName := SaveImageDialog.FileName;
    if LowerCase(Copy(FName,length(FName)-2))<>'.png' then
      FName:=FName+'.png';

    PNG.SaveToFile(FName);
    BitMap.Free;
    PNG.Free;
  end;
end;

procedure TFormMain.ExportAsPngUpdate(Sender: TObject);
begin
  ExportAsPng.Enabled:=Blocks.Next<>nil;
end;

procedure TFormMain.FieldMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);

Var
  ScrollBar: TControlScrollBar;
  delta:Integer;
begin
  if ssShift in shift then
    ScrollBar:=Field.HorzScrollBar
  else
    ScrollBar:=Field.VertScrollBar;
  if WheelDelta>0 then
    delta:=-ScrollBar.Increment
  else
    delta:=ScrollBar.Increment;
  ScrollBar.Position:=ScrollBar.Position+delta;
end;


procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FormStart.Show();
end;


procedure IsInNext(cur, source: pBlock; var Flag: Boolean);
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

procedure DrawLine(bl: pBlock; num: Integer);
begin
  case bl.Prev.Shape of
  stRectangle, stCircle, stTerminator:
  begin
    case num of
    0:
    begin
      bl.ownCanvas.moveto(bl.Prev.x+bl.Prev.w div 2,bl.Prev.y+bl.Prev.h);
      bl.ownCanvas.lineto(bl.x+bl.w div 2,bl.y);
    end;
    1:
    begin
      bl.ownCanvas.moveto(bl.Prev.x+bl.Prev.w,bl.Prev.y+bl.Prev.h div 2);
      bl.ownCanvas.lineto(bl.x+bl.w div 2,bl.Prev.y+bl.Prev.h div 2);
      bl.ownCanvas.lineto(bl.x+bl.w div 2, bl.y);
    end;
    end;

  end;
  stDecision:
  begin
    case num of
    0:
    begin
      bl.ownCanvas.moveto(bl.Prev.x+bl.Prev.w div 2,bl.Prev.y+bl.Prev.h);
      bl.ownCanvas.lineto(bl.x+bl.w div 2,bl.y);
    end;
    2:
    begin
      bl.ownCanvas.moveto(bl.Prev.x+(bl.Prev.w*3) div 4,bl.Prev.y+(bl.Prev.h) div 4);
      bl.ownCanvas.lineto(bl.Prev.x+bl.Prev.w+FormMain.FrameEditLines.UpDownHorizontal.Position div 2,bl.Prev.y-FormMain.FrameEditLines.UpDownVertical.Position div 2);
      bl.ownCanvas.lineto(bl.x+bl.w div 2,bl.Prev.y-FormMain.FrameEditLines.UpDownVertical.Position div 2);
      bl.ownCanvas.lineto(bl.x+bl.w div 2, bl.y);
    end;
    1:
    begin

      bl.ownCanvas.moveto(bl.Prev.x+(bl.Prev.w*3) div 4,bl.Prev.y+(bl.Prev.h*3) div 4);
      bl.ownCanvas.lineto(bl.Prev.x+bl.Prev.w+FormMain.FrameEditLines.UpDownHorizontal.Position div 2,bl.Prev.y+bl.Prev.h + FormMain.FrameEditLines.UpDownVertical.Position div 2);
      bl.ownCanvas.lineto(bl.Prev.x+bl.Prev.w+FormMain.FrameEditLines.UpDownHorizontal.Position div 2,bl.y - FormMain.FrameEditLines.UpDownVertical.Position div 2);
      bl.ownCanvas.lineto(bl.Prev.x+bl.Prev.w+FormMain.FrameEditLines.UpDownHorizontal.Position div 2,bl.y - FormMain.FrameEditLines.UpDownVertical.Position div 2);
      bl.ownCanvas.lineto(bl.x+bl.w div 2,bl.y - FormMain.FrameEditLines.UpDownVertical.Position div 2);
      bl.ownCanvas.lineto(bl.x+bl.w div 2, bl.y);
    end;
    end;
  end;
  stCycle:
  begin

  end;

  end;
end;

procedure DrawTree(bl: pBlock; var maxx, maxy: Integer);
var
  temp: pBlock;
  num: Integer;
begin
  if bl <> nil then
  begin
    DrawBlock(bl);
    if bl.y+bl.h>maxy then
      maxy:=bl.y+bl.h;
    if bl.x+bl.w>maxx then
      maxx:=bl.x+bl.w;

    if bl.Prev<>nil then
    begin
      num:=0;
      while bl.Prev.Next[num]<>bl do
        inc(num);
      DrawLine(bl, num);
    end;

    temp := bl;
    for var i := 0 to High(temp.Next) do
    begin
      temp := bl.Next[i];
      DrawTree(temp,maxx, maxy);
    end;
  end;
end;

Procedure ShowHintBlock(num: Integer);

begin
  FormMain.PaintField.Canvas.Pen.Style:=HintBlockStyle;
  case num of
  0:
  begin
    HintBlock.y:=HintBlock.prev.y+HintBlock.prev.h+FormMain.FrameEditLines.UpDownVertical.Position;
    HintBlock.x:=HintBlock.Prev.x + (HintBlock.Prev.w-HintBlock.w) div 2;
  end;

  1:
  begin
    HintBlock.x:=HintBlock.Prev.x + HintBlock.Prev.w + FormMain.FrameEditLines.UpDownHorizontal.Position;
    HintBlock.y:=HintBlock.prev.y + HintBlock.prev.h + FormMain.FrameEditLines.UpDownVertical.Position;
  end;

  2:
  begin
    HintBlock.x:=HintBlock.Prev.x + HintBlock.Prev.w + FormMain.FrameEditLines.UpDownHorizontal.Position;
    HintBlock.y:=HintBlock.Prev.y;
  end;

  end;

  DrawBlock(HintBlock);
  DrawLine(HintBlock,num);

  FormMain.PaintField.Canvas.Pen.Style:=psSolid;
end;

procedure DrawAllBlocks();
var
  temp: pAllBlocks;
  maxx, maxy: Integer;
begin
  temp := Blocks;
  maxx:=0;
  maxy:=0;
  while temp.Next <> Nil do
  begin
    temp := temp.Next;
    DrawTree(temp.Block, maxx, maxy);
  end;
  if (CurBlock<>nil)then
  begin
    if CurBlock.y+200>maxy then
      maxy:=CurBlock.y+200;
    if CurBlock.x+200>maxx then
      maxx:=CurBlock.x+200;

    if Flag then
      DrawTree(CurBlock, maxx, maxy);
  end;


  FormMain.PaintField.width:=maxx+200;
  FormMain.PaintField.height:=maxy+200;

  if CurHighLightedBlock<>nil then
  begin
    HighLightBlock.ownCanvas.Pen.Width:=2;
    HighLightBlock.Shape:=CurHighLightedBlock.Shape;
    HighLightBlock.H := CurHighLightedBlock.H+1;
    HighLightBlock.W := CurHighLightedBlock.W+1;
    HighLightBlock.y := CurHighLightedBlock.y;
    HighLightBlock.x := CurHighLightedBlock.x;

    HighlightBlock.OwnCanvas.Brush.Style:=bsClear;
    DrawBlock(HighLightBlock);
    HighlightBlock.OwnCanvas.Brush.Style:=bsSolid;
    HighLightBlock.ownCanvas.Pen.Width:=1;
  end;

  if HintBlock.Prev<>nil then
    ShowHintBlock(ConnectNum);
end;






procedure TFormMain.PaintFieldDblClick(Sender: TObject);
begin
  if CurHighLightedBlock<>nil then
  begin
    EditText.Show;

    EditText.Left := CurHighLightedBlock.x;
    EditText.Top := CurHighLightedBlock.y;
    EditText.Height := CurHighLightedBlock.h;
    EditText.Width := CurHighLightedBlock.h;


    EditText.prev := CurHighLightedBlock;

    EditText.Alignment:=TAlignment(ord(EditText.Prev.TextHorAllign));
    EditText.Font.Size:=EditText.Prev.FontSize;

    EditText.Text := CurHighLightedBlock.Text;
    Flag:=False;
    CurHighLightedBlock:=nil;
  end;
end;

procedure TFormMain.PaintFieldPaint(Sender: TObject);
begin
  DrawAllBlocks();
end;


procedure FindBlockInTree(bl: pBlock; x, y: Integer; var res: pBlock);
var
  temp: pBlock;
begin
  if (bl <> nil) and (res=nil) then
  begin
    case bl.Shape of

      stRectangle..stTerminator:
      begin
        if (bl.x<=x) and (bl.y<=y) and (x<=bl.x+bl.w) and (y<=bl.y+bl.h)then
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



Function ConnectBlocks(blmain,bl:pBlock): Integer;

begin

  case blMain.Shape of
  stRectangle, stCycle:
    if (bl.x-blmain.x>=bl.y-blmain.y) or ((blmain.y+blmain.h div 2)>=(bl.y+bl.h div 2)) then
      Result:=1
    else
      Result:=0;

  stDecision:
    if ((blmain.y+blmain.h div 2)>=(bl.y+bl.h div 2)) then
      Result:=2
    else if (bl.x-blmain.x>=bl.y-blmain.y) then
      Result:=1
    else
      Result:=0;

  stCircle, stTerminator:
    Result:=0;
  end;
end;

procedure SetDefaultCoordsInTree(bl:pBlock; x, y: Integer);
begin
  if (bl<>nil) then
  begin
    if (bl.Prev<>nil) then
    begin
      bl.x:=x;
      bl.y:=y;
    end;
    for var i := High(bl.Next) downto Low(bl.Next) do
      SetDefaultCoordsInTree(bl.Next[i],x,y);
  end;
end;

Procedure SetDefaultCoords(x,y:Integer);
var
  temp: pAllBlocks;
begin
  temp := Blocks;
  while (temp.Next <> Nil) do
  begin
    temp := temp.Next;
    SetDefaultCoordsInTree(temp.Block,x,y);
  end;
end;



Procedure StructuriseBlocksInTree(bl:pBlock; Var dist: Integer; num, level: Integer);
var
  ContinueCompacting, temp1: Boolean;
  tempBlock: pBlock;
begin
  if (bl<>nil) then
  begin
    if bl.Prev<>nil then
    begin
      case num of
      0:
      begin
        bl.y:=dist+FormMain.FrameEditLines.UpDownVertical.Position;
        bl.x:=bl.Prev.x + (bl.Prev.w-bl.w) div 2;

      end;

      1:
      begin
        bl.x:=bl.Prev.x + bl.Prev.w + FormMain.FrameEditLines.UpDownHorizontal.Position;
        bl.y:=dist + FormMain.FrameEditLines.UpDownVertical.Position;
      end;

      2:
      begin
        bl.x:=bl.Prev.x + bl.Prev.w + FormMain.FrameEditLines.UpDownHorizontal.Position;
        bl.y:=bl.Prev.y;
      end;

      end;

      if ((Num = 0) or (num = 1)) and Compact and (level <> 1) then
      begin
        continueCompacting:=True;
        while ContinueCompacting do
        begin
          tempBlock:=findBlock(bl.x+bl.w div 2, bl.y-FormMain.FrameEditLines.UpDownVertical.Position-5);
          ContinueCompacting:=(tempBlock = nil);

          if length(bl.Next)=3 then
            temp1 := (bl.Next[1] = nil) and (bl.Next[2] = nil)
          else if length(bl.Next)=2 then
            temp1 := (bl.Next[1] = nil)
          else
            temp1:=True;

          tempBlock:=findBlock(bl.x+bl.w+FormMain.FrameEditLines.UpDownHorizontal.Position + 5, bl.y-FormMain.FrameEditLines.UpDownVertical.Position-5);
          ContinueCompacting:=ContinueCompacting and (temp1 or (tempBlock = nil));

          ContinueCompacting:=ContinueCompacting and (bl.y>bl.Prev.y+bl.prev.h+FormMain.FrameEditLines.UpDownVertical.Position*2);

          if ContinueCompacting then
            bl.y:=bl.y-(bl.h+FormMain.FrameEditLines.UpDownVertical.Position);
        end;
      end;

    end;

    if dist<=bl.y+bl.h then
      dist:=bl.y+bl.h;

    for var i := High(bl.Next) downto Low(bl.Next) do
    if i=0 then
      StructuriseBlocksInTree(bl.Next[i],dist, i,level)
    else
      StructuriseBlocksInTree(bl.Next[i],dist, i,level+1);
  end;
end;

Procedure StructuriseBlocks();
var
  temp: pAllBlocks;
  dist: Integer;
begin
  temp := Blocks;


  SetDefaultCoords(-1000,-1000);
  while (temp.Next <> Nil) do
  begin
    temp := temp.Next;
    dist:=0;
    StructuriseBlocksInTree(temp.Block, dist, 0, 1);
  end;
end;

procedure TFormMain.Button1Click(Sender: TObject);
begin
  close;
end;

procedure TFormMain.ButtonBlocksClick(Sender: TObject);
begin
  FrameEditBlocks.Show;
  FrameEditLines.Hide;
end;

procedure TFormMain.ButtonLinesClick(Sender: TObject);
begin
  FrameEditBlocks.Hide;
  FrameEditLines.Show;
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
      tempDist := sqrt(sqr(X - (bl.x+bl.w div 2)) + sqr(Y - (bl.y+bl.h div 2)));

      if (tempDist < Min) and (x < FormMain.FrameEditLines.UpDownHorizontal.Position+bl.x+bl.w +210)
         and (y < FormMain.FrameEditLines.UpDownVertical.Position+bl.y+bl.h+210) then
      begin
        if (bl.x-10<=x) and (y>=bl.y-FormMain.FrameEditLines.UpDownVertical.Position-210) then
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


function FindMinDist(X, Y: Integer; main: pointer): pBlock;
var
  temp: pAllBlocks;
  curMin: Real;
begin
  curMin := MaxInt;
  temp := Blocks;
  Result := Nil;
  if main<>nil then
  begin
    x:=x+pBlock(main).w div 2;
    y:=y+pBlock(main).h div 2;
  end;
  while temp.Next <> Nil do
  begin
    temp := temp.Next;
    FindMinDistInTree(temp.Block, X, Y, curMin, Result, main);
  end;

end;

procedure TFormMain.BlockStartDrag(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  CurHighLightedBlock:=nil;
  CurBlock:=nil;
  New(CurBlock);
  CurBlock.Shape:=(Sender as TStartBlock).Shape;
  CurBlock.W:=FrameEditBlocks.UpDownWidth.Position;
  CurBlock.h:=FrameEditBlocks.UpDownHeight.Position;
  SetLength(CurBlock.Next,1);
  CurBlock.Next[0]:=nil;
  CurBlock.Prev:=nil;
  if button=mbleft then
    TStartBlock(Sender).BeginDrag(True);
end;


procedure TFormMain.StartBlockDragDrop(Sender, Source: TObject; X, Y: Integer);
Var
  AllDiagrams: pAllBlocks;
  temp:pBlock;
  num: Integer;

begin
  Dispose(CurBlock);
  CurBlock:=nil;
  HintBlock.Prev:=nil;
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

    temp.x := X;
    temp.y := Y;

  end
  else
  begin
    temp:=nil;
    New(temp);

    temp.x:=x;
    temp.y:=y;
    temp.w:=FrameEditBlocks.UpDownWidth.Position;
    temp.h:=FrameEditBlocks.UpDownHeight.Position;

    num:=ConnectBlocks(CurHighLightedBlock, temp);

    if CurHighLightedBlock.Next[num]=nil then
    begin
      CurHighLightedBlock.Next[num]:=temp;
      CurHighLightedBlock.Next[num].Prev:=CurHighLightedBlock;
    end
    else
    begin
      AllDiagrams := Blocks;

      while AllDiagrams.Next <> nil do
        AllDiagrams := AllDiagrams.Next;

      new(AllDiagrams.Next);

      AllDiagrams := AllDiagrams.Next;
      AllDiagrams.Next := Nil;
      AllDiagrams.Block:=temp;
      temp.prev:=nil;
    end;
  end;

  temp.Shape := (Source as TStartBlock).Shape;

  case temp.Shape of
    stRectangle, stCycle:
        SetLength(Temp.Next, 2);

    stDecision:
        SetLength(Temp.Next, 3);

    stCircle, stTerminator:
        SetLength(Temp.Next, 1);
  end;

  for var i := 0 to High(Temp.Next) do
    Temp.Next[i] := nil;

  with temp^ do
  begin
    W := FrameEditBlocks.UpDownWidth.Position;
    H := FrameEditBlocks.UpDownHeight.Position;
    ownCanvas:= (Sender as TPaintBox).Canvas;
    FillColor:=clWhite;
    BorderColor:=clBlack;
  end;

  temp.Text := 'Hello';
  temp.FontSize:=10;
  temp.TextHorAllign:=hCenter;
  temp.TextInterval:=4;
  temp.TextVertAllign:=vCenter;

  with (Source as TStartBlock) do
  begin
    Left := 25;
    Top := 60 + (Ord(Shape)) * (Width + 20);
    flag := False;
    (Source as TStartBlock).Parent := ShapePanel;
  end;

  PaintField.EndDrag(True);
  StructuriseBlocks();

  CurHighLightedBlock := temp;
  HighLightBlock.Shape:=CurHighLightedBlock.Shape;
  HighLightBlock.H := CurHighLightedBlock.H+2;
  HighLightBlock.W := CurHighLightedBlock.W+2;
  HighLightBlock.y := CurHighLightedBlock.y-1;
  HighLightBlock.x := CurHighLightedBlock.x-1;

  PaintField.Invalidate();
end;

procedure TFormMain.StartBlockDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);

var
  Connect: Boolean;

Var
  num:Integer;
begin
  if Sender = PaintField then
  begin

    Accept := True;
    CurBlock.x:=x;
    CurBlock.y:=y;
    HintBlock.prev:=nil;
    if FindMinDist(X, Y, nil) <> nil then
    begin
      CurHighLightedBlock := FindMinDist(X, Y, nil);

      num:=ConnectBlocks(CurHighLightedBlock, CurBlock);

      Connect:=(CurHighLightedBlock.Next[num]=nil);

      if (CurHighLightedBlock.Shape in [stCircle, stTerminator]) and (CurHighLightedBlock.Prev<>nil) then
        Connect:=False;

      if (CurBlock.Shape in [stCircle, stTerminator]) and (CurBlock.Next[0]<>nil) then
        Connect:=False;

      if Connect then
      begin
        HighLightBlock.Shape:=CurHighLightedBlock.Shape;
        HighLightBlock.H := CurHighLightedBlock.H+2;
        HighLightBlock.W := CurHighLightedBlock.W+2;
        HighLightBlock.y := CurHighLightedBlock.y-1;
        HighLightBlock.x := CurHighLightedBlock.x-1;
        HintBlock.Prev:=CurHighLightedBlock;
        HintBlock.Shape:=CurBlock.Shape;
        ConnectNum:=num;
      end
      else
      begin
        CurHighLightedBlock := nil;
      end;

    end
    else
    begin
      CurHighLightedBlock := nil;
    end;

  end;
  PaintField.Invalidate();

end;

procedure TFormMain.BlockMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  num: Integer;
begin
  flag:=False;

  curblock:=findBlock(x,y);

  if (EditText.Visible) and (curBlock<>EditText.Prev) then
  begin
    EditText.prev.text := EditText.Text;
    EditText.Hide;
  end;

  if (CurHighLightedBlock <> Nil) then
  begin
    CurHighLightedBlock := Nil;
  end;

  if CurBlock<>nil then
  begin
    flag := True;
    x0 := X;
    y0 := Y;

    if CurBlock.Prev<>nil then
    begin
      num:=0;
      while CurBlock.Prev.Next[num]<>CurBlock do
        inc(num);

      CurHighLightedBlock:=CurBlock.prev;
      HighLightBlock.Shape:=CurHighLightedBlock.Shape;
      HighLightBlock.H := CurHighLightedBlock.H+2;
      HighLightBlock.W := CurHighLightedBlock.W+2;
      HighLightBlock.y := CurHighLightedBlock.y-1;
      HighLightBlock.x := CurHighLightedBlock.x-1;

      CurBlock.Prev.Next[num]:=nil;
      CurBlock.Prev:=nil;
    end;
  end;

end;

procedure TFormMain.BlockMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  num: Integer;
  Connect:Boolean;

begin

  if flag then
  begin
    MoveAllBlocks(CurBlock, X, Y);

    y0:=y;
    x0:=x;

    CurHighLightedBlock := FindMinDist(CurBlock.x, CurBlock.y, CurBlock);
    HintBlock.Prev:=nil;

    if CurHighLightedBlock<>nil then
    begin
      num:=ConnectBlocks(CurHighLightedBlock, CurBlock);

      Connect:=(CurHighLightedBlock.Next[num]=nil);

      if (CurHighLightedBlock.Shape in [stCircle, stTerminator]) and (CurHighLightedBlock.Prev<>nil) then
        Connect:=False;

      if (CurBlock.Shape in [stCircle, stTerminator]) and (CurBlock.Next[0]<>nil) then
        Connect:=False;

      if Connect then
      begin
        HighLightBlock.Shape:=CurHighLightedBlock.Shape;
        HighLightBlock.H := CurHighLightedBlock.H+2;
        HighLightBlock.W := CurHighLightedBlock.W+2;
        HighLightBlock.y := CurHighLightedBlock.y-1;
        HighLightBlock.x := CurHighLightedBlock.x-1;
        HintBlock.Prev := CurHighLightedBlock;
        HintBlock.Shape:=CurBlock.Shape;
        ConnectNum:=num;
      end
      else
      begin
        CurHighLightedBlock := nil;
      end;
    end
    else
    begin
      CurHighLightedBlock := nil;
    end;

    PaintField.Invalidate();
  end;

end;

procedure TFormMain.BlockMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

var
  allDiagrams, nextDiag:pAllBlocks;
  num: Integer;

begin

  if Flag then
  begin
    flag := False;
    AllDiagrams:=Blocks;
    HintBlock.Prev:=nil;

    if CurHighLightedBlock <> nil then
    begin

      num:=ConnectBlocks(CurHighLightedBlock, CurBlock);

      if CurHighLightedBlock.Next[num]=nil then
      begin
        CurHighLightedBlock.Next[num] := CurBlock;
        CurBlock.prev := CurHighLightedBlock;
      end;


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

    StructuriseBlocks();

    CurHighLightedBlock := CurBlock;
    CurBlock:=nil;
  end;

  PaintField.Invalidate;
end;

end.
