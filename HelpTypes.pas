unit HelpTypes;

interface
  Uses
    Vcl.ExtCtrls, Vcl.Graphics, System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls;
  Type

    pAllBlocks = ^AllBlocks;
    pBlock =  ^TBlock;

    TShapeType = (stRectangle, stCircle, stDecision, stCycle, stTerminator);
    TStartBlock = class(TShape)
    public
      FPen: TPen;
      FBrush: TBrush;
      FShape: TShapeType;
    public
      constructor Create (AOwner: TComponent); override;
      procedure SetBrush(Value: TBrush);
      procedure SetPen(Value: TPen);
      procedure SetShape(Value: TShapeType);
      procedure Paint; override;
      property Pen: TPen read FPen write SetPen;
      property Shape: TShapeType read FShape write SetShape default stRectangle;
    end;


    AllBlocks = record
      Block: pBlock;
      Next: pAllBlocks;
    end;

    THorAllign = (hLeft, hRight, hCenter);
    TVertAllign = (vUp, vCenter, vDown);
    TNextArr = Array of pBlock;

    TBlock = packed record
      BorderColor:Integer;
      FillColor:Integer;
      Text:String;
      Shape:TShapeType;
      x,y,w,h, FontSize:Integer;
      Next: TNextArr;
      Prev: pBlock;
      TextHorAllign:THorAllign;
      TextVertAllign:TVertAllign;
      TextInterval:Integer;

    end;

    TProEdit = class(TRichEdit)
    public
      prev: pBlock;
    end;

    pFilesArr = ^TFilesArr;

    TFilesArr = record
      Form: pBlock;
      Next: pFilesArr;
      FName: String;
      Diag: pAllBlocks;
    end;

    procedure DrawBlock(bl: pBlock; ownCanvas: TCanvas);
    procedure WriteText(bl: pBlock; ownCanvas: TCanvas);


implementation

constructor TStartBlock.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csReplicatable];
  Width := 50;
  Height := 50;
  FPen := TPen.Create;
  FPen.OnChange := StyleChanged;
  FBrush := TBrush.Create;
  FBrush.OnChange := StyleChanged;
end;

procedure TStartBlock.SetBrush(Value: TBrush);
begin
  FBrush.Assign(Value);
end;

procedure TStartBlock.SetPen(Value: TPen);
begin
  FPen.Assign(Value);
end;

procedure TStartBlock.SetShape(Value: TShapeType);
begin
  if FShape <> Value then
  begin
    FShape := Value;
    Invalidate;
  end;
end;

procedure TStartBlock.Paint;
var
  X, Y, W, H, r, tempColor: Integer;
begin

  with Canvas do
  begin
    Pen := FPen;
    Brush := FBrush;
    W := Width - Pen.Width + 1;
    H := Height - Pen.Width + 1;
    X := Pen.Width div 2;
    Y := X;
    if Pen.Width = 0 then
    begin
      Dec(W);
      Dec(H);
    end;
    case FShape of
      stRectangle:
        Rectangle(X+1, Y+1, X + W-1, Y + H-1);
      stCircle:
        Ellipse(X+1, Y+1, X + W-1, Y + H-1);
      stDecision:
      begin

        Polygon([Point(x+w-1, y+h div 2),
                 Point(x+w div 2,y+h-1),
                 Point(x+1,y+h div 2),
                 Point(x+w div 2,y)]);
      end;
      stCycle:
      begin
        Polygon([Point(x+(w div 3)*2, y),
                 Point(x+w-1, y+h div 2),
                 Point(x+(w div 3)*2, y+h-1),
                 Point(x+(w div 3), y+h-1),
                 Point(x+1,y+h div 2),
                 Point(x+w div 3,y)]);
      end;
      stTerminator:
      begin
        while w mod 4 <> 0 do
          dec(w);

        if h mod 2<>0 then
          dec(h);

        if 2*h<=w then
          r:=h div 2-1
        else
          r:=w div 4;


        Pie(x+1,y+1, x+2*r+1,y+h-1, x+r+1,y+1, x+r+1, y+h-1);
        Pie(x+w-1-2*r,y+1, x+w-1,y+h-1, x+w-r,y+h-1, x+w-r,y+1);

        tempColor:=Pen.Color;
        Pen.Color:=ClWhite;
        Rectangle(x+r,y+1,x+w-r,y+h-1);
        Pen.Color:=tempColor;

        moveto(x+r,y+1);
        lineto(x+w-r,y+1);
        moveto(x+r,y+h-1);
        lineto(x+w-r,y+h-1);
      end;
    end;
  end;
end;

procedure DrawBlock(bl: pBlock; ownCanvas: TCanvas);
var
  r, tempColor:Integer;
  tempBS:TBrushStyle;

begin

  with ownCanvas do
  begin
    Pen.Color := bl.BorderColor;
    if Brush.Style<>bsClear then
      Brush.Color := bl.FillColor;
    case bl.Shape of
      stRectangle:
        Rectangle(bl.X, bl.Y, bl.X + bl.W, bl.Y + bl.H);
      stCircle:
        Ellipse(bl.X+(bl.w-bl.h) div 2, bl.Y, bl.X + (bl.w+bl.h) div 2, bl.Y + bl.H);
      stDecision:
      begin

        Polygon([Point(bl.x+bl.w, bl.y+bl.h div 2),
                 Point(bl.x+bl.w div 2,bl.y+bl.h),
                 Point(bl.x,bl.y+bl.h div 2),
                 Point(bl.x+bl.w div 2,bl.y)]);
      end;
      stCycle:
      begin
        Polygon([Point(bl.x+(bl.w div 3)*2, bl.y),
                 Point(bl.x+bl.w, bl.y+bl.h div 2),
                 Point(bl.x+(bl.w div 3)*2, bl.y+bl.h),
                 Point(bl.x+(bl.w div 3), bl.y+bl.h),
                 Point(bl.x,bl.y+bl.h div 2),
                 Point(bl.x+bl.w div 3,bl.y)]);
      end;
      stTerminator:
      begin

        with bl^ do
        begin

          if 2*h<=w then
            r:=h div 2
          else
            r:=w div 4;


          Pie(x,y, x+2*r,y+h, x + r,y, x+r, y+h);
          Pie(x+w-2*r,y, x+w,y+h, x+w-r,y+h, x+w-r,y);

          tempColor:=Pen.Color;
          Pen.Color:=ClWhite;
          if Brush.Style<>bsClear then
            Rectangle(x+r-1,y,x+w-r+1,y+h)
          else
            Rectangle(x+r,y,x+w-r+1,y+h);
          Pen.Color:=tempColor;

          moveto(x+r-1,y);
          lineto(x+w-r+1,y);
          moveto(x+r-1,y+h);
          lineto(x+w-r+1,y+h);
        end;
      end;
    end;
  end;

  writetext(bl, ownCanvas);
end;

procedure WriteText(bl: pBlock; ownCanvas: TCanvas);
var
  th,tw:Integer;
  x,y:Integer;
  text:String;
begin
  tw:=0;

  if length(bl.text)<>0 then
  begin
    OwnCanvas.Font.Size:=bl.FontSize;
    OwnCanvas.Font.Name:='Tahoma';
    th:=0;
    for var n := 1 to length(bl.text) do
      if (bl.text[n]=#13) then
      begin
        th:=th+ownCanvas.textHeight(text)+bl.textInterval;
        text:='';
      end
      else
      if bl.text[n]<>#10 then
        text:=text+bl.text[n];

    th:=th+ownCanvas.textHeight(text);
    text:='';

    ownCanvas.Brush.Style:=bsClear;
    case bl.TextVertAllign of
      vUp:
        y:=bl.y+2;
      vCenter:
        y:=bl.y+2+(bl.h-4-th) div 2;
      vDown:
        y:=bl.y+2+bl.h-4-th;

    end;
    for var n := 1 to length(bl.text) do
    begin
      if (bl.text[n]=#13) then
      begin
        case bl.TextHorAllign of
          hLeft:
            x:=bl.x+2;
          hCenter:
            x:=bl.x+2+(bl.w-4-ownCanvas.textWidth(text)) div 2;
          hRight:
            x:=bl.x+2+(bl.w-4 - ownCanvas.textWidth(text));
        end;
        ownCanvas.textout(x,y,text);
        y:=y+ownCanvas.textHeight(text)+bl.textInterval;
        text:='';
      end
      else
      if bl.text[n]<>#10 then
        text:=text+bl.text[n];
    end;

      if text<>#10 then
      begin
        case bl.TextHorAllign of
          hLeft:
            x:=bl.x+2;
          hCenter:
            x:=bl.x+2+(bl.w-4-ownCanvas.textWidth(text)) div 2;
          hRight:
            x:=bl.x+2+(bl.w-4 - ownCanvas.textWidth(text));
        end;
        ownCanvas.textout(x,y,text);
        text:='';
      end;

    ownCanvas.Brush.Style:=bsSolid;
  end;



end;
end.
